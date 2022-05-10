/*=============================================================================
	UnLevCol.cpp: Actor list collision code.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

Design goal:
	To be self-contained. This collision code maintains its own collision hash
	table and doesn't know about any far-away data structures like the level BSP.

Revision history:
	* Created by Tim Sweeney
=============================================================================*/

#include "EnginePrivate.h"

/*-----------------------------------------------------------------------------
	FCollisionHash.
-----------------------------------------------------------------------------*/

//
// A collision hash table.
//
class ENGINE_API FCollisionHash : public FCollisionHashBase
{
public:
	// FCollisionHashBase interface.
	FCollisionHash();
	~FCollisionHash();
	void Tick();
	void AddActor( AActor *Actor );
	void RemoveActor( AActor *Actor );
	FCheckResult* ActorLineCheck( FMemStack& Mem, FVector End, FVector Start, FVector Extent, BYTE ExtraNodeFlags, UBOOL bMeshAccurate=0 );
	FCheckResult* ActorPointCheck( FMemStack& Mem, FVector Location, FVector Extent, DWORD ExtraNodeFlags );
	FCheckResult* ActorRadiusCheck( FMemStack& Mem, FVector Location, FLOAT Radius, DWORD ExtraNodeFlags );
	FCheckResult* ActorEncroachmentCheck( FMemStack& Mem, AActor* Actor, FVector Location, FRotator Rotation, DWORD ExtraNodeFlags );
	void CheckActorNotReferenced( AActor* Actor );

	// Constants.
	enum { BULK_ALLOC  = 1024              };
	enum { NUM_BUCKETS = 16384             };
	enum { BASIS_BITS  = 8                 };
	enum { BASIS_MASK  = (1<<BASIS_BITS)-1 };
	enum { GRAN_XY     = 256               };
	enum { GRAN_Z      = 256               };
	enum { XY_OFS      = 32768             };
	enum { Z_OFS       = 32768             };

	// Linked list item.
	struct FCollisionLink
	{
		// Varibles.
		AActor*          Actor;     // The actor.
		FCollisionLink*  Next;      // Next link belonging to this collision bucket.
		INT				 iLocation; // Based hash location.
	} *Hash[NUM_BUCKETS], *Available;
	TArray<FCollisionLink*> LinksToFree;

	// Statics.
	static UBOOL Inited;
	static INT CollisionTag;
	static INT HashX[NUM_BUCKETS];
	static INT HashY[NUM_BUCKETS];
	static INT HashZ[NUM_BUCKETS];

	// Implementation.
	void GetActorExtent( AActor* Actor, INT& iX0, INT& iX1, INT& iY0, INT& iY1, INT& iZ0, INT& iZ1 );
	void GetHashIndices( FVector Location, INT& iX, INT& iY, INT& iZ )
	{
		iX = Clamp<INT>(appRound( (Location.X + XY_OFS) * (1.f/GRAN_XY) ), 0, NUM_BUCKETS-1 );
		iY = Clamp<INT>(appRound( (Location.Y + XY_OFS) * (1.f/GRAN_XY) ), 0, NUM_BUCKETS-1 );
		iZ = Clamp<INT>(appRound( (Location.Z + Z_OFS ) * (1.f/GRAN_Z ) ), 0, NUM_BUCKETS-1 );
	}
	struct FCollisionLink*& GetHashLink( INT iX, INT iY, INT iZ, INT& iLocation )
	{
		iLocation = iX + (iY << BASIS_BITS) + (iZ << (BASIS_BITS*2));
		return Hash[ HashX[iX] ^ HashY[iY] ^ HashZ[iZ] ];
	}
};

ENGINE_API FCollisionHashBase* GNewCollisionHash()
{
	return new(TEXT("FCollisionHash"))FCollisionHash;
}

/*-----------------------------------------------------------------------------
	FCollisionHash statics.
-----------------------------------------------------------------------------*/

// FCollisionHash statics.
UBOOL FCollisionHash::Inited=0;
INT FCollisionHash::CollisionTag=0;
INT FCollisionHash::HashX[NUM_BUCKETS];
INT FCollisionHash::HashY[NUM_BUCKETS];
INT FCollisionHash::HashZ[NUM_BUCKETS];	

// Global statistics.
static INT GActorsAdded=0, GFragsAdded=0, GUsed=0, GChecks=0;

/*-----------------------------------------------------------------------------
	FCollisionHash init/exit.
-----------------------------------------------------------------------------*/

//
// Initialize the actor collision information.
//
FCollisionHash::FCollisionHash()
: Available( NULL )
, LinksToFree(  )
{
	// Initialize static collision basis tables if necessary.
	if( !Inited )
	{
		Inited = 1;
		for( INT i=0; i<NUM_BUCKETS; i++ )
		{
			HashX[i] = HashY[i] = HashZ[i] = i;
		}
		for( i=0; i<NUM_BUCKETS; i++ )
		{
			Exchange( HashX[i], HashX[appRand() % NUM_BUCKETS] );
			Exchange( HashY[i], HashY[appRand() % NUM_BUCKETS] );
			Exchange( HashZ[i], HashZ[appRand() % NUM_BUCKETS] );
		}
	}

	// Init hash table.
	for( INT i=0; i<NUM_BUCKETS; i++ )
		Hash[i] = NULL;
}

//
// Shut down the actor collision information.
//
FCollisionHash::~FCollisionHash()
{
	// Free all collision links.
	for( INT i=0; i<LinksToFree.Num(); i++ )
		appFree( LinksToFree(i) );
}

/*-----------------------------------------------------------------------------
	FCollisionHash tick - clean up collision info.
-----------------------------------------------------------------------------*/

//
// Cleanup the collision info.
//
void FCollisionHash::Tick()
{
	// All we do here is stats.
	//debugf(NAME_Log,"Used=%i Added=%i Frags=%i Checks=%i",GUsed,GActorsAdded,GFragsAdded,GChecks);
	GActorsAdded = GFragsAdded = GChecks = 0;
}

/*-----------------------------------------------------------------------------
	FCollisionHash extent.
-----------------------------------------------------------------------------*/

//
// Compute the extent of an actor in hash coordinates.
//
void FCollisionHash::GetActorExtent
(
	AActor *Actor,
	INT &X0, INT &X1, INT &Y0, INT &Y1, INT &Z0, INT &Z1
)
{
	// Get actor's bounding box.
	FBox Box = Actor->GetPrimitive()->GetCollisionBoundingBox( Actor );

	// Discretize to hash coordinates.
	GetHashIndices( Box.Min, X0, Y0, Z0 );
	GetHashIndices( Box.Max, X1, Y1, Z1 );
}

/*-----------------------------------------------------------------------------
	FCollisionHash adding/removing.
-----------------------------------------------------------------------------*/

//
// Add an actor to the collision info.
//
void FCollisionHash::AddActor( AActor *Actor )
{
	//debugf( NAME_Log, TEXT("FCollisionHash::AddActor Entered."));

	check(Actor->bCollideActors);
	if( Actor->bDeleteMe )
		return;
	//debugf( NAME_Log, TEXT("Pre-CheckActorNotReferenced."));

	CheckActorNotReferenced( Actor );
	GActorsAdded++;

	// Add actor in all the specified places.
	INT X0,Y0,Z0,X1,Y1,Z1;
	//debugf( NAME_Log, TEXT("Pre-GetActorExtent."));
	GetActorExtent( Actor, X0, X1, Y0, Y1, Z0, Z1 );
	//debugf( NAME_Log, TEXT("Pre-loop."));
	for( INT X=X0; X<=X1; X++ )
	{
		for( INT Y=Y0; Y<=Y1; Y++ )
		{
			for( INT Z=Z0; Z<=Z1; Z++ )
			{
				INT iLocation;
				FCollisionLink*& Link = GetHashLink( X, Y, Z, iLocation );
				if( !Available )
				{
					// Allocate a lot of new links.
					Available = new(TEXT("FCollisionLink"))FCollisionLink[BULK_ALLOC];
					LinksToFree.AddItem( Available );
					for( INT i=0; i<BULK_ALLOC-1; i++ )
						Available[i].Next = &Available[i+1];
					Available[BULK_ALLOC-1].Next = NULL;
				}
				FCollisionLink* NewLink = Available;
				Available               = Available->Next;
				NewLink->Actor          = Actor;
				NewLink->Next           = Link;
				NewLink->iLocation      = iLocation;
				Link                    = NewLink;
				GUsed++;
				GFragsAdded++;
			}
		}
	}
	Actor->ColLocation = Actor->Location;
	//debugf( NAME_Log, TEXT("FCollisionHash::AddActor Left."));

}

//
// Remove an actor from the collision info.
//
void FCollisionHash::RemoveActor( AActor* Actor )
{
	if( Actor->bDeleteMe )
		return;
	check(Actor->bCollideActors);
	if( Actor->Location!=Actor->ColLocation )
		appErrorf( TEXT("%s moved without proper hashing"), Actor->GetFullName() );

	// Remove actor.
	INT X0,Y0,Z0,X1,Y1,Z1;
	GetActorExtent( Actor, X0, X1, Y0, Y1, Z0, Z1 );
	for( INT X=X0; X<=X1; X++ )
	{
		for( INT Y=Y0; Y<=Y1; Y++ )
		{
			for( INT Z=Z0; Z<=Z1; Z++ )
			{
				INT iLocation;
				FCollisionLink** Link = &GetHashLink( X, Y, Z, iLocation );
				while( *Link )
				{
					if( (*Link)->Actor != Actor )
					{
						Link = &(*Link)->Next;
					}
					else
					{
						FCollisionLink* Scrap = *Link;
						*Link                 = (*Link)->Next;
						Scrap->Next           = Available;
						Available	          = Scrap;
						GUsed--;
					}
				}
			}
		}
	}
	CheckActorNotReferenced( Actor );
}

/*-----------------------------------------------------------------------------
	FCollisionHash collision checking.
-----------------------------------------------------------------------------*/

//
// Make a list of all actors which overlap with a cylinder at Location
// with the given collision size.
//
FCheckResult* FCollisionHash::ActorPointCheck
(
	FMemStack&		Mem,
	FVector			Location,
	FVector			Extent,
	DWORD			ExtraNodeFlags
)
{
	FCheckResult* Result=NULL;

	// Get extent indices.
	INT X0,Y0,Z0,X1,Y1,Z1;
	GetHashIndices( Location - Extent, X0, Y0, Z0 );
	GetHashIndices( Location + Extent, X1, Y1, Z1 );
	CollisionTag++;
	INT CurrentCollisionTag = CollisionTag;

	// Check all actors in this neighborhood.
	for( INT X=X0; X<=X1; X++ ) for( INT Y=Y0; Y<=Y1; Y++ ) for( INT Z=Z0; Z<=Z1; Z++ )
	{
		INT iLocation;
		for( FCollisionLink* Link = GetHashLink( X, Y, Z, iLocation ); Link; Link=Link->Next )
		{
			// Skip if we've already checked this actor.
			if
			(	Link->Actor->CollisionTag != CurrentCollisionTag
			&&	Link->iLocation           == iLocation )
			{
				// Collision test.
				FCheckResult TestHit(1.0);
				if( Link->Actor->GetPrimitive()->PointCheck( TestHit, Link->Actor, Location, Extent, 0 )==0 )
				{
					check(TestHit.Actor==Link->Actor);
					FCheckResult* New = new(GMem)FCheckResult;
					*New = TestHit;
					New->GetNext() = Result;
					Result = New;
				}
				Link->Actor->CollisionTag = CurrentCollisionTag;
			}
		}
	}
	return Result;
}

//
// Make a list of all actors which are within a given radius.
//
FCheckResult* FCollisionHash::ActorRadiusCheck
(
	FMemStack&		Mem,
	FVector			Location,
	FLOAT			Radius,
	DWORD			ExtraNodeFlags
)
{
	FCheckResult* Result=NULL;

	// Get extent indices.
	INT X0,Y0,Z0,X1,Y1,Z1;
	GetHashIndices( Location - FVector(Radius,Radius,Radius), X0, Y0, Z0 );
	GetHashIndices( Location + FVector(Radius,Radius,Radius), X1, Y1, Z1 );
	CollisionTag++;
	INT CurrentCollisionTag = CollisionTag;
	FLOAT RadiusSq = Radius * Radius;

	// Check all actors in this neighborhood.
	for( INT X=X0; X<=X1; X++ ) for( INT Y=Y0; Y<=Y1; Y++ ) for( INT Z=Z0; Z<=Z1; Z++ )
	{
		INT iLocation;
		for( FCollisionLink* Link = GetHashLink( X, Y, Z, iLocation ); Link; Link=Link->Next )
		{
			// Skip if we've already checked this actor.
			if
			(	Link->Actor->CollisionTag != CurrentCollisionTag 
			&&	Link->iLocation           == iLocation )
			{
				// Collision test.
				if( (Link->Actor->Location - Location).SizeSquared() < RadiusSq )
				{
					FCheckResult* New = new(GMem)FCheckResult;
					New->Actor = Link->Actor;
					New->GetNext() = Result;
					Result = New;
				}
				Link->Actor->CollisionTag = CurrentCollisionTag;
			}
		}
	}
	return Result;
}

//
// Check for encroached actors.
//
FCheckResult* FCollisionHash::ActorEncroachmentCheck
(
	FMemStack&		Mem,
	AActor*			Actor,
	FVector			Location,
	FRotator		Rotation,
	DWORD			ExtraNodeFlags
)
{
	check(Actor!=NULL);

	// Save actor's location and rotation.
	Exchange( Location, Actor->Location );
	Exchange( Rotation, Actor->Rotation );

	// Get extent indices.
	INT X0,Y0,Z0,X1,Y1,Z1;
	GetActorExtent( Actor, X0, X1, Y0, Y1, Z0, Z1 );
	FCheckResult *Result, **PrevLink = &Result;
	CollisionTag++;
	INT CurrentCollisionTag = CollisionTag;

	// Check all actors in this neighborhood.
	for( INT X=X0; X<=X1; X++ ) for( INT Y=Y0; Y<=Y1; Y++ ) for( INT Z=Z0; Z<=Z1; Z++ )
	{
		INT iLocation;
		for( FCollisionLink* Link = GetHashLink( X, Y, Z, iLocation ); Link; Link=Link->Next )
		{
			// Skip if we've already checked this actor.
			if
			(	Link->Actor->CollisionTag != CurrentCollisionTag
			&&	Link->iLocation           == iLocation )
			{
				FCheckResult TestHit(1.0);
				if
				(	!Link->Actor->IsMovingBrush()
				&&	Link->Actor!=Actor
				&&	Actor->GetPrimitive()->PointCheck( TestHit, Actor, Link->Actor->Location, Link->Actor->GetCylinderExtent(), 0 )==0 )
				{
					TestHit.Actor     = Link->Actor;
					TestHit.Primitive = NULL;
					*PrevLink         = new(GMem)FCheckResult;
					**PrevLink        = TestHit;
					PrevLink          = &(*PrevLink)->GetNext();
				}
				Link->Actor->CollisionTag = CurrentCollisionTag;
			}
		}
	}

	// Restore actor's location and rotation.
	Exchange( Location, Actor->Location );
	Exchange( Rotation, Actor->Rotation );

	*PrevLink = NULL;
	return Result;
}

//
// Make a time-sorted list of all actors which overlap a cylinder moving 
// along a line from Start to End. If LevelInfo is specified, also checks for
// collision with the level itself and terminates collision when the trace
// hits solid space.
//
// Note: This routine is very inefficient for large lines, because it checks
// collision with all actors inside a bounding box containing the line's start
// and end point. This is a reasonable approach for regular actor movement
// like player walking, but it becomes very inefficient for long line traces, such
// as checking the collision of a bullet. To handle these cases, it would be smart
// to do the following optimizations:
//
// * Only test hash cubes which the line actually falls into. This could be done using
//   a raycasting-style algorithm.
//
// * Stop tracing once we have hit an actor which we know is guaranteed to be the 
//   nearest possible actor along the line.
//
FCheckResult* FCollisionHash::ActorLineCheck
(
	FMemStack&		Mem,
	FVector			End,
	FVector			Start,
	FVector			Size,
	BYTE			ExtraNodeFlags,
	UBOOL			bMeshAccurate
)
{
	FCheckResult* Result=NULL;

	// Get extent.
	CollisionTag++;
	INT CurrentCollisionTag = CollisionTag;
	INT X0,Y0,Z0,X1,Y1,Z1,X;
	FBox Box( FBox(0) + Start + End );
	GetHashIndices( Box.Min - Size, X0, Y0, Z0 );
	GetHashIndices( Box.Max + Size, X1, Y1, Z1 );

	// Check all potentially colliding actors in the hash.
	for( X=X0; X<=X1; X++ )
	{
		for( INT Y=Y0; Y<=Y1; Y++ )
		{
			for( INT Z=Z0; Z<=Z1; Z++ )
			{
				INT iLocation;
				for( FCollisionLink* Link = GetHashLink( X, Y, Z, iLocation ); Link; Link=Link->Next )
				{
					// Skip if we've already checked this actor.
					if
					(	Link->Actor->CollisionTag != CurrentCollisionTag
					&&	Link->iLocation           == iLocation )
					{
						// Check collision.
						FCheckResult Hit(0);
						if( Link->Actor->GetPrimitive()->LineCheck( Hit, Link->Actor, End, Start, Size, ExtraNodeFlags, bMeshAccurate )==0 )
						{
							FCheckResult* Link = new(Mem)FCheckResult(Hit);
							Link->GetNext() = Result;
							Result = Link;
						}
						Link->Actor->CollisionTag = CurrentCollisionTag;
					}
				}
			}
		}
	}
	return Result;
}

/*-----------------------------------------------------------------------------
	Checks.
-----------------------------------------------------------------------------*/

//
// Make sure the actor isn't referenced in the collision hash.
//
void FCollisionHash::CheckActorNotReferenced( AActor* Actor )
{
	if( DO_GUARD_SLOW && !GIsEditor )
		for( INT i=0; i<NUM_BUCKETS; i++ )
			for( FCollisionLink* Link=Hash[i]; Link; Link=Link->Next )
				if( Link->Actor == Actor )
					appErrorf( TEXT("%s has collision hash fragments"), Actor->GetFullName() );
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
