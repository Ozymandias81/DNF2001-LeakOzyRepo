/*=============================================================================
	UnMesh.cpp: Unreal mesh animation functions
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by Tim Sweeney
=============================================================================*/

#include "EnginePrivate.h"
#include "Amd3d.h"

#include "UnMeshPrivate.h"

/*-----------------------------------------------------------------------------
	UMesh object implementation.
-----------------------------------------------------------------------------*/
EXECVAR(INT, mesh_InstanceCount, 0);

IMPLEMENT_CLASS(UMesh);
IMPLEMENT_CLASS(UMeshInstance);

UMesh::UMesh()
{
	DefaultInstance = NULL;

	//DefaultInstance = GetInstance(NULL);
}

void UMesh::Destroy() 
{
	if (DefaultInstance)
	{
		DefaultInstance->RemoveFromRoot();
		DefaultInstance->ConditionalDestroy();
		delete DefaultInstance;
		DefaultInstance = NULL;
		mesh_InstanceCount--;
	}

	/* commented out... defaultinstances are left as transient standalones alongside their owning meshes
	if (DefaultInstance)
	{
		DefaultInstance->RemoveFromRoot();
		DefaultInstance->ConditionalDestroy();
		delete DefaultInstance;
		DefaultInstance = NULL;
	}
	*/
	Super::Destroy();
}

UMeshInstance* UMesh::GetInstance(AActor* InActor)
{
	if (InActor)
	{
		if (!InActor->IsValid() || InActor->bDeleteMe || InActor->bDestroyed)
			return(NULL);
		
		if (InActor->MeshInstance && InActor->MeshInstance->IsValid())
		{
			if ((InActor->MeshInstance->GetMesh()==this) && (InActor->MeshInstance->GetActor()==InActor))
				return(InActor->MeshInstance); // actor's mesh instance is valid
			
			// JEP ...
		#if 1
			// Invalid instance, check to see if the last instance will work...
			if (InActor->LastMeshInstance)
			{
				if ((InActor->LastMeshInstance->GetMesh()==this) && (InActor->LastMeshInstance->GetActor()==InActor))
				{
					// Last instance matches, make it current, and return it
					Exchange(InActor->LastMeshInstance, InActor->MeshInstance);
					return InActor->MeshInstance;
				}

				// Both instances bad, free the last one, and make the current one the last one instead (rotate them)
				InActor->LastMeshInstance->ConditionalDestroy();
				delete InActor->LastMeshInstance;
				InActor->LastMeshInstance = NULL;
				mesh_InstanceCount--;
			}
			
			InActor->LastMeshInstance = InActor->MeshInstance;
			InActor->MeshInstance = NULL;
			// ... JEP
		#else
			// invalid instance, eliminate it
			//InActor->MeshInstance->RemoveFromRoot();
			InActor->MeshInstance->ConditionalDestroy();
			delete InActor->MeshInstance;
			InActor->MeshInstance = NULL;
			mesh_InstanceCount--;
		#endif
		}

		UClass* Cls = GetInstanceClass();
		if (!Cls)
			Cls = UMeshInstance::StaticClass();
		InActor->MeshInstance = (UMeshInstance*)StaticConstructObject(Cls, GetOuter()/*InActor*/, NAME_None, RF_Transient, Cls->GetDefaultObject());
		//InActor->MeshInstance->AddToRoot();
		InActor->MeshInstance->SetMesh(this);
		InActor->MeshInstance->SetActor(InActor);
		mesh_InstanceCount++;
		return(InActor->MeshInstance);
	}
	else
	{
		if (DefaultInstance && DefaultInstance->IsValid())
			return(DefaultInstance);

		UClass* Cls = GetInstanceClass();
		if (!Cls)
			Cls = UMeshInstance::StaticClass();
		DefaultInstance = (UMeshInstance*)StaticConstructObject(Cls, GetOuter()/*this*/, NAME_None, RF_Transient|RF_Public|RF_Standalone, Cls->GetDefaultObject());
		DefaultInstance->AddToRoot();
		DefaultInstance->SetMesh(this);
		DefaultInstance->SetActor(NULL);
		mesh_InstanceCount++;
		return(DefaultInstance);
	}
}

IMPLEMENT_CLASS(UUnrealMesh);
IMPLEMENT_CLASS(UUnrealMeshInstance);

UUnrealMesh::UUnrealMesh()
{

	// Scaling.
	Scale			 = FVector(1,1,1);
	Origin			 = FVector(0,0,0);
	RotOrigin		 = FRotator(0,0,0);

	// Flags.
	/* CDH: removed (never used)
	AndFlags		 = ~(DWORD)0;
	OrFlags			 = 0;
	*/

}
void UUnrealMesh::Serialize( FArchive& Ar )
{
	Super::Serialize(Ar);

#if DNF
	if (Ar.IsLoading() && (Ar.MergeVer() > 63))
	{
		GWarn->Logf(NAME_Log, TEXT("DukeMesh conversion: %s: Warning: Loading UUnrealMesh"), GetName());
		return;
	}
#endif

	// Serialize this.
	Ar << Verts;
	Ar << Tris;
	if( Tris.Num() )
		check(Tris(0).iVertex[0]<Verts.Num());
	Ar << AnimSeqs;
	Ar << Connects << BoundingBox << BoundingSphere << VertLinks << Textures;
	
	Ar << BoundingBoxes;
	
	TArray<FSphere> BoundingSpheres; // CDH: removed from class (never used)
	Ar << BoundingSpheres;
	
	Ar << FrameVerts << AnimFrames;
	
	DWORD AndFlags=0, OrFlags=0; // CDH: removed from class (never used)
	Ar << AndFlags << OrFlags;
	
	Ar << Scale << Origin << RotOrigin;
	
	INT CurPoly=0, CurVertex=0; // CDH: removed from class (never used)
	Ar << CurPoly << CurVertex;
	
	if( Ar.Ver()==65 )
		{FLOAT F; Ar << F;}
	if( Ar.Ver()>=66 )
		Ar << TextureLOD;
}

//
// Get the rendering bounding box for this primitive, as owned by Owner.
//
FBox UUnrealMesh::GetRenderBoundingBox( const AActor* Owner, UBOOL Exact )
{
	FBox Bound;

	Bound = BoundingBox;

	// Get frame indices.
	INT iFrame1 = 0, iFrame2 = 0;
	FMeshAnimSeq* Seq = NULL;
	for (INT iSeq=0;iSeq<AnimSeqs.Num();iSeq++)
	{
		if (Owner->AnimSequence==AnimSeqs(iSeq).Name)
		{
			Seq = &AnimSeqs(iSeq);
			break;
		}
	}

	if( Seq && Owner->AnimFrame>=0.0 )
	{
		// Animating, so use bound enclosing two frames' bounds.
		INT iFrame = appFloor((Owner->AnimFrame+1.0) * Seq->NumFrames);
		iFrame1    = Seq->StartFrame + ((iFrame + 0) % Seq->NumFrames);
		iFrame2    = Seq->StartFrame + ((iFrame + 1) % Seq->NumFrames);
		Bound      = BoundingBoxes(iFrame1) + BoundingBoxes(iFrame2);
	}
	else
	{
		// Interpolating, so be pessimistic and use entire-mesh bound.
		Bound = BoundingBox;
	}

	// Transform Bound by owner's scale and origin.
	FLOAT DrawScale = Owner->bParticles ? 1.5 : Owner->DrawScale;
	Bound = FBox( Scale*DrawScale*(Bound.Min - Origin), Scale*DrawScale*(Bound.Max - Origin) ).ExpandBy(1.0);
	FCoords Coords = GMath.UnitCoords / RotOrigin / Owner->Rotation;
	Coords.Origin  = Owner->Location + Owner->PrePivot;
	return Bound.TransformBy( Coords.Transpose() );
}
//
// Get the rendering bounding sphere for this primitive, as owned by Owner.
//
/* CDH: removed (never used)
FSphere UUnrealMesh::GetRenderBoundingSphere( const AActor* Owner, UBOOL Exact )
{
	return FSphere(0);
}
*/
//
// Primitive box line check.
//
UBOOL UUnrealMesh::LineCheck
(
	FCheckResult	&Result,
	AActor			*Owner,
	FVector			End,
	FVector			Start,
	FVector			Extent,
	DWORD           ExtraNodeFlags,
	UBOOL			bMeshAccurate
)
{
	if( Extent != FVector(0,0,0) )
	{
		// Use cylinder.
		return UPrimitive::LineCheck( Result, Owner, End, Start, Extent, ExtraNodeFlags, bMeshAccurate );
	}
	else
	{
		// Could use exact mesh collision.
		// 1. Reject with local bound.
		// 2. x-wise intersection test with all polygons.
		return UPrimitive::LineCheck( Result, Owner, End, Start, FVector(0,0,0), ExtraNodeFlags, bMeshAccurate );
	}
}

UClass* UUnrealMesh::GetInstanceClass()
{
	return(UUnrealMeshInstance::StaticClass());
}

//
// UMesh constructor.
//
UUnrealMesh::UUnrealMesh( INT NumPolys, INT NumVerts, INT NumFrames )
{

	// Set counts.
	FrameVerts	= NumVerts;
	AnimFrames	= NumFrames;

	// Allocate all stuff.
	Tris			.Add(NumPolys);
	Verts			.Add(NumVerts * NumFrames);
	Connects		.Add(NumVerts);
	BoundingBoxes	.Add(NumFrames);
	/* CDH: removed from class (never used)
	BoundingSpheres .Add(NumFrames);
	*/

	// Init textures.
	for( INT i=0; i<Textures.Num(); i++ )
		Textures(i) = NULL;


}
void UUnrealMesh::SetScale(FVector InScale)
{
	Scale = InScale;
}

/*
	UUnrealMeshInstance
*/
UUnrealMeshInstance::UUnrealMeshInstance()
{
	Mesh = NULL;
	Actor = NULL;
}

UMesh* UUnrealMeshInstance::GetMesh()
{
	return(Mesh);
}
void UUnrealMeshInstance::SetMesh(UMesh* InMesh)
{
	Mesh = Cast<UUnrealMesh>(InMesh);
}

AActor* UUnrealMeshInstance::GetActor()
{
	return(Actor);
}
void UUnrealMeshInstance::SetActor(AActor* InActor)
{
	Actor = InActor;
}

INT UUnrealMeshInstance::GetNumSequences()
{
	if (!Mesh)
		return(0);
	return(Mesh->AnimSeqs.Num());
}
HMeshSequence UUnrealMeshInstance::GetSequence(INT SeqIndex)
{
	if (!Mesh)
		return(NULL);
	return(&Mesh->AnimSeqs(SeqIndex));
}
HMeshSequence UUnrealMeshInstance::FindSequence(FName SeqName)
{
	if (!Mesh)
		return(NULL);
	for (INT i=0;i<Mesh->AnimSeqs.Num();i++)
	{
		if (SeqName==Mesh->AnimSeqs(i).Name)
			return(&Mesh->AnimSeqs(i));
	}
	return(NULL);
}

FName UUnrealMeshInstance::GetSeqName(HMeshSequence Seq)
{
	FMeshAnimSeq* S = (FMeshAnimSeq*)Seq;
	return(S->Name);
}
FName UUnrealMeshInstance::GetSeqGroupName(FName SequenceName)
{
	FMeshAnimSeq* S = (FMeshAnimSeq*) FindSequence(SequenceName);
	return(S->Group);
}
INT UUnrealMeshInstance::GetSeqNumFrames(HMeshSequence Seq)
{
	FMeshAnimSeq* S = (FMeshAnimSeq*)Seq;
	return(S->NumFrames);
}
FLOAT UUnrealMeshInstance::GetSeqRate(HMeshSequence Seq)
{
	FMeshAnimSeq* S = (FMeshAnimSeq*)Seq;
	return(S->Rate);
}
INT UUnrealMeshInstance::GetSeqNumEvents(HMeshSequence Seq)
{
	FMeshAnimSeq* S = (FMeshAnimSeq*)Seq;
	return(S->Notifys.Num());
}
EMeshSeqEvent UUnrealMeshInstance::GetSeqEventType(HMeshSequence Seq, INT Index)
{
	return(MESHSEQEV_Trigger);
}
FLOAT UUnrealMeshInstance::GetSeqEventTime(HMeshSequence Seq, INT Index)
{
	FMeshAnimSeq* S = (FMeshAnimSeq*)Seq;
	return(S->Notifys(Index).Time);
}
const TCHAR* UUnrealMeshInstance::GetSeqEventString(HMeshSequence Seq, INT Index)
{
	FMeshAnimSeq* S = (FMeshAnimSeq*)Seq;
	if (S->Notifys(Index).Function==NAME_None)
		return(NULL);
	return(*S->Notifys(Index).Function);
}

UBOOL UUnrealMeshInstance::PlaySequence(HMeshSequence Seq, BYTE Channel, UBOOL bLoop, FLOAT Rate, FLOAT MinRate, FLOAT TweenTime)
{
	if (!Actor || !Seq || Channel)
		return(0);

	if (Rate != 0.f)
	{
		// PlayAnim or LoopAnim
		if (!bLoop)
		{
			// PlayAnim - Set one-shot animation
			if( Actor->AnimSequence == NAME_None )
				TweenTime = 0.0;
			Actor->AnimSequence  = GetSeqName(Seq);
			Actor->AnimRate      = Rate * GetSeqRate(Seq) / GetSeqNumFrames(Seq);
			Actor->AnimLast      = 1.0 - 1.0 / GetSeqNumFrames(Seq);
			Actor->bAnimNotify   = GetSeqNumEvents(Seq)!=0;
			Actor->bAnimFinished = 0;
			Actor->bAnimLoop     = 0;
			if( Actor->AnimLast == 0.0 )
			{
				Actor->AnimMinRate   = 0.0;
				Actor->bAnimNotify   = 0;
				Actor->OldAnimRate   = 0;
				if( TweenTime > 0.0 )
					Actor->TweenRate = 1.0 / TweenTime;
				else
					Actor->TweenRate = 10.0; //tween in 0.1 sec
				Actor->AnimFrame = -1.0/GetSeqNumFrames(Seq);
				Actor->AnimRate = 0;
			}
			else if( TweenTime>0.0 )
			{
				Actor->TweenRate = 1.0 / (TweenTime * GetSeqNumFrames(Seq));
				Actor->AnimFrame = -1.0/GetSeqNumFrames(Seq);
			}
			else if ( TweenTime == -1.0 )
			{
				Actor->AnimFrame = -1.0/GetSeqNumFrames(Seq);
				if ( Actor->OldAnimRate > 0 )
					Actor->TweenRate = Actor->OldAnimRate;
				else if ( Actor->OldAnimRate < 0 ) //was velocity based looping
					Actor->TweenRate = ::Max(0.5f * Actor->AnimRate, -1 * Actor->Velocity.Size() * Actor->OldAnimRate );
				else
					Actor->TweenRate = 1.0/(0.025 * GetSeqNumFrames(Seq));
			}
			else
			{
				Actor->TweenRate = 0.0;
				Actor->AnimFrame = 0.001;
			}
			FPlane OldSimAnim = Actor->SimAnim;
			Actor->OldAnimRate = Actor->AnimRate;
			Actor->SimAnim.X = 10000 * Actor->AnimFrame;
			Actor->SimAnim.Y = 5000 * Actor->AnimRate;
			if ( Actor->SimAnim.Y > 32767 )
				Actor->SimAnim.Y = 32767;
			Actor->SimAnim.Z = 1000 * Actor->TweenRate;
			Actor->SimAnim.W = 10000 * Actor->AnimLast;
			/*
			if ( IsA(AWeapon::StaticClass())
				&& (PlayAnimRate * Seq->GetRate() < 0.21) )
			{
				SimAnim.X = 0;
				SimAnim.Z = 0;
			} */				
			if ( OldSimAnim == Actor->SimAnim )
				Actor->SimAnim.W = Actor->SimAnim.W + 1;
		}
		else
		{
			// LoopAnim - Set looping animation
			if ( (Actor->AnimSequence == GetSeqName(Seq)) && Actor->bAnimLoop && Actor->IsAnimating(0) )
			{
				Actor->AnimRate = Rate * GetSeqRate(Seq) / GetSeqNumFrames(Seq);
				Actor->bAnimFinished = 0;
				Actor->AnimMinRate = MinRate!=0.0 ? MinRate * (GetSeqRate(Seq) / GetSeqNumFrames(Seq)) : 0.0;
				FPlane OldSimAnim = Actor->SimAnim;
				Actor->OldAnimRate = Actor->AnimRate;		
				Actor->SimAnim.Y = 5000 * Actor->AnimRate;
				Actor->SimAnim.W = -10000 * (1.0 - 1.0 / GetSeqNumFrames(Seq));
				if ( OldSimAnim == Actor->SimAnim )
					Actor->SimAnim.W = Actor->SimAnim.W + 1;
				return(1);
			}
			if( Actor->AnimSequence == NAME_None )
				TweenTime = 0.0;
			Actor->AnimSequence  = GetSeqName(Seq);
			Actor->AnimRate      = Rate * GetSeqRate(Seq) / GetSeqNumFrames(Seq);
			Actor->AnimLast      = 1.0 - 1.0 / GetSeqNumFrames(Seq);
			Actor->AnimMinRate   = MinRate!=0.0 ? MinRate * (GetSeqRate(Seq) / GetSeqNumFrames(Seq)) : 0.0;
			Actor->bAnimNotify   = GetSeqNumEvents(Seq)!=0;
			Actor->bAnimFinished = 0;
			Actor->bAnimLoop     = 1;
			if ( Actor->AnimLast == 0.0 )
			{
				Actor->AnimMinRate   = 0.0;
				Actor->bAnimNotify   = 0;
				Actor->OldAnimRate   = 0;
				if ( TweenTime > 0.0 )
					Actor->TweenRate = 1.0 / TweenTime;
				else
					Actor->TweenRate = 10.0; //tween in 0.1 sec
				Actor->AnimFrame = -1.0/GetSeqNumFrames(Seq);
				Actor->AnimRate = 0;
			}
			else if( TweenTime>0.0 )
			{
				Actor->TweenRate = 1.0 / (TweenTime * GetSeqNumFrames(Seq));
				Actor->AnimFrame = -1.0/GetSeqNumFrames(Seq);
			}
			else if ( TweenTime == -1.0 )
			{
				Actor->AnimFrame = -1.0/GetSeqNumFrames(Seq);
				if ( Actor->OldAnimRate > 0 )
					Actor->TweenRate = Actor->OldAnimRate;
				else if ( Actor->OldAnimRate < 0 ) //was velocity based looping
					Actor->TweenRate = ::Max(0.5f * Actor->AnimRate, -1 * Actor->Velocity.Size() * Actor->OldAnimRate );
				else
					Actor->TweenRate = 1.0/(0.025 * GetSeqNumFrames(Seq));
			}
			else
			{
				Actor->TweenRate = 0.0;
				Actor->AnimFrame = 0.0001;
			}
			Actor->OldAnimRate = Actor->AnimRate;
			Actor->SimAnim.X = 10000 * Actor->AnimFrame;
			Actor->SimAnim.Y = 5000 * Actor->AnimRate;
			if ( Actor->SimAnim.Y > 32767 )
				Actor->SimAnim.Y = 32767;
			Actor->SimAnim.Z = 1000 * Actor->TweenRate;
			Actor->SimAnim.W = -10000 * Actor->AnimLast;
		}
	}
	else // (Rate == 0.f)
	{
		// TweenAnim - Tweening an animation from wherever it is, to the start of a specified sequence.
		Actor->AnimSequence  = GetSeqName(Seq);
		Actor->AnimLast      = 0.0;
		Actor->AnimMinRate   = 0.0;
		Actor->bAnimNotify   = 0;
		Actor->bAnimFinished = 0;
		Actor->bAnimLoop     = 0;
		Actor->AnimRate      = 0;
		Actor->OldAnimRate   = 0;
		if( TweenTime>0.0 )
		{
			Actor->TweenRate =  1.0/(TweenTime * GetSeqNumFrames(Seq));
			Actor->AnimFrame = -1.0/GetSeqNumFrames(Seq);
		}
		else
		{
			Actor->TweenRate = 0.0;
			Actor->AnimFrame = 0.0;
		}
		Actor->SimAnim.X = 10000 * Actor->AnimFrame;
		Actor->SimAnim.Y = 5000 * Actor->AnimRate;
		if ( Actor->SimAnim.Y > 32767 )
			Actor->SimAnim.Y = 32767;
		Actor->SimAnim.Z = 1000 * Actor->TweenRate;
		Actor->SimAnim.W = 10000 * Actor->AnimLast;
	}

	return(1);
}
void UUnrealMeshInstance::DriveSequences(FLOAT DeltaSeconds)
{

	if (!Actor)
		return;
	
	UBOOL bSimulatedPawn = (Cast<APawn>(Actor) && (Actor->Role==ROLE_SimulatedProxy));

	// Update all animation, including multiple passes if necessary.
	INT Iterations = 0;
	FLOAT Seconds = DeltaSeconds;
	while
	(	Actor->IsAnimating(0)
	&&	(Seconds>0.0)
	&&	(++Iterations <= 4) )
	{
		// Remember the old frame.
		FLOAT OldAnimFrame = Actor->AnimFrame;

		// Update animation, and possibly overflow it.
		if( Actor->AnimFrame >= 0.0 )
		{
			// Update regular or velocity-scaled animation.
			if( Actor->AnimRate >= 0.0 )
				Actor->AnimFrame += Actor->AnimRate * Seconds;
			else
				Actor->AnimFrame += ::Max( Actor->AnimMinRate, Actor->Velocity.Size() * -Actor->AnimRate ) * Seconds;

			// Handle all animation sequence notifys.
			if( Actor->bAnimNotify )
			{
				HMeshSequence Seq = FindSequence(Actor->AnimSequence);
				if( Seq )
				{
					FLOAT BestElapsedFrames = 100000.0;
					INT BestNotify = -1;
					for( INT i=0; i<GetSeqNumEvents(Seq); i++ )
					{
						if (GetSeqEventType(Seq, i) != MESHSEQEV_Trigger)
							continue;
						FLOAT EventTime = GetSeqEventTime(Seq, i);
						if( OldAnimFrame<EventTime && Actor->AnimFrame>=EventTime )
						{
							FLOAT ElapsedFrames = EventTime - OldAnimFrame;
							if ((BestNotify==-1) || (ElapsedFrames<BestElapsedFrames))
							{
								BestElapsedFrames = ElapsedFrames;
								BestNotify        = i;
							}
						}
					}
					if (BestNotify != -1)
					{
						Seconds   = Seconds * (Actor->AnimFrame - GetSeqEventTime(Seq, BestNotify)) / (Actor->AnimFrame - OldAnimFrame);
						Actor->AnimFrame = GetSeqEventTime(Seq, BestNotify);
						UFunction* Function = Actor->FindFunction( FName(GetSeqEventString(Seq, BestNotify)) );
						if( Function )
							Actor->ProcessEvent( Function, NULL );
						continue;
					}
				}
			}

			// Handle end of animation sequence.
			if( Actor->AnimFrame < Actor->AnimLast )
			{
				// We have finished the animation updating for this tick.
				break;
			}
			else if( Actor->bAnimLoop )
			{
				if( Actor->AnimFrame < 1.0 )
				{
					// Still looping.
					Seconds = 0.0;
				}
				else
				{
					// Just passed end, so loop it.
					Seconds = Seconds * (Actor->AnimFrame - 1.0) / (Actor->AnimFrame - OldAnimFrame);
					Actor->AnimFrame = 0.0;
				}
				if( OldAnimFrame < Actor->AnimLast )
				{
					if( Actor->GetStateFrame()->LatentAction == EPOLL_FinishAnim )
					{
						if (!Actor->LatentInt) // ChannelIndex
							Actor->bAnimFinished = 1;
					}
					if( !bSimulatedPawn )
					{
						AActor* Act = Actor; // need to duplicate since this meshinstance may be destroyed if actor dies in animend
						Actor->eventAnimEnd();
						if (!Act->IsValid() || Act->bDeleteMe)
							return;
					}
				}
			}
			else 
			{
				// Just passed end-minus-one frame.
				Seconds = Seconds * (Actor->AnimFrame - Actor->AnimLast) / (Actor->AnimFrame - OldAnimFrame);
				Actor->AnimFrame = Actor->AnimLast;
				Actor->bAnimFinished = 1;
				Actor->AnimRate = 0.0;
				if ( !bSimulatedPawn )
				{
					AActor* Act = Actor; // need to duplicate since this meshinstance may be destroyed if actor dies in animend
					Actor->eventAnimEnd();
					if (!Act->IsValid() || Act->bDeleteMe)
						return;
				}
				
				if ( (Actor->RemoteRole < ROLE_SimulatedProxy) && !Actor->IsA(AWeapon::StaticClass()) )
				{
					Actor->SimAnim.X = 10000 * Actor->AnimFrame;
					Actor->SimAnim.Y = 5000 * Actor->AnimRate;
					if ( Actor->SimAnim.Y > 32767 )
						Actor->SimAnim.Y = 32767;
				}
			}
		}
		else
		{
			// Update tweening.
			Actor->AnimFrame += Actor->TweenRate * Seconds;
			if( Actor->AnimFrame >= 0.0 )
			{
				// Finished tweening.
				Seconds = Seconds * (Actor->AnimFrame-0) / (Actor->AnimFrame - OldAnimFrame);
				Actor->AnimFrame = 0.0;
				if( Actor->AnimRate == 0.0 )
				{
					Actor->bAnimFinished = 1;
					if ( !bSimulatedPawn )
					{
						AActor* Act = Actor; // need to duplicate since this meshinstance may be destroyed if actor dies in animend
						Actor->eventAnimEnd();
						if (!Act->IsValid() || Act->bDeleteMe)
							return;
					}
				}
			}
			else
			{
				// Finished tweening.
				break;
			}
		}
	}
}

UTexture* UUnrealMeshInstance::GetTexture(INT Count)
{
	if (!Mesh)
		return(NULL);
	if( Actor && Actor->GetSkin( Count ) )
		return Actor->GetSkin( Count );
	else if( Count!=0 && Mesh->Textures(Count) )
		return Mesh->Textures(Count);
	else if( Actor && Actor->Skin )
		return Actor->Skin;
	else
		return Mesh->Textures(Count);
}
void UUnrealMeshInstance::GetStringValue(FOutputDevice& Ar, const TCHAR* Key, INT Index)
{
	if (!Mesh)
		return;

	if(!appStricmp(Key,TEXT("NUMANIMSEQS")))
	{
		Ar.Logf(TEXT("%i"), Mesh->AnimSeqs.Num());
	}
	else if(!appStricmp(Key,TEXT("ANIMSEQNAME")))
	{
		if ((Index >= 0) && (Index < Mesh->AnimSeqs.Num()))
		{
			FMeshAnimSeq& Seq = Mesh->AnimSeqs(Index);
			if (Seq.Name!=NAME_None)
				Ar.Logf(TEXT("%s"), *Seq.Name);
		}
	}
	else if(!appStricmp(Key,TEXT("ANIMSEQRATE")))
	{
		if ((Index >= 0) && (Index < Mesh->AnimSeqs.Num()))
		{
			FMeshAnimSeq& Seq = Mesh->AnimSeqs(Index);
			if (Seq.Name!=NAME_None)
				Ar.Logf(TEXT("%f"), Seq.Rate);
		}
	}
	else if(!appStricmp(Key,TEXT("ANIMSEQFRAMES")))
	{
		if ((Index >= 0) && (Index < Mesh->AnimSeqs.Num()))
		{
			FMeshAnimSeq& Seq = Mesh->AnimSeqs(Index);
			if (Seq.Name!=NAME_None)
				Ar.Logf(TEXT("%d"), Seq.NumFrames);
		}
	}
}
void UUnrealMeshInstance::SendStringCommand(const TCHAR* Cmd)
{
}
FCoords UUnrealMeshInstance::GetBasisCoords(FCoords Coords)
{
	if (!Actor || !Mesh)
		return(Coords);
	FLOAT DrawScale = Actor->bParticles ? 1.f : Actor->DrawScale;
	//UBOOL NotWeaponHeuristic = ((!Viewport) || (Owner->Owner != Viewport->Actor));
	FLOAT HeightAdjust = 0;//Actor->bMeshLowerByCollision ? Actor->CollisionHeight : Actor->MeshLowerHeight;
	Coords = Coords * (Actor->Location + Actor->PrePivot) * Actor->Rotation * Mesh->RotOrigin
		* FVector(0,0,-HeightAdjust) * FScale(Mesh->Scale * DrawScale, 0.f, SHEER_None);
	return(Coords);
}

// Get the transformed point set corresponding to the animation frame 
// of this primitive owned by Owner. Returns the total outcode of the points.
#pragma warning (disable:4799) /* NJS: "function has no EMMS instruction" */
INT UUnrealMeshInstance::GetFrame(FVector* ResultVerts, BYTE* VertsEnabled, INT Size, FCoords Coords, FLOAT LodLevel)
{
	if (!Actor || !Mesh)
		return(0);

	// Make sure lazy-loadable arrays are ready.
	Mesh->Verts.Load();
	Mesh->Tris.Load();
	Mesh->Connects.Load();
	Mesh->VertLinks.Load();

#if ASM3DNOW
	if( GIs3DNow )
	{
		return(AMD3DGetFrame( ResultVerts, VertsEnabled, Size, Coords, LodLevel ));
	}
#endif

	AActor*	AnimOwner = NULL;

	// Check to see if bAnimByOwner
	if( Actor->bAnimByOwner && Actor->Owner!=NULL )
		AnimOwner = Actor->Owner;
	else
		AnimOwner = Actor;

	// Create or get cache memory.
	FCacheItem* Item = NULL;
	UBOOL WasCached  = 1;
	QWORD CacheID    = MakeCacheID( CID_TweenAnim, Actor, NULL );
	BYTE* Mem        = GCache.Get( CacheID, Item );
	if( Mem==NULL || *(UUnrealMesh**)Mem!=Mesh )
	{
		if( Mem != NULL )
		{
			// Actor's mesh changed.
			Item->Unlock();
			GCache.Flush( CacheID );
		}
		Mem = GCache.Create( CacheID, Item, sizeof(UUnrealMesh*) + sizeof(FLOAT) + sizeof(FName) + Mesh->FrameVerts * sizeof(FVector) );
		WasCached = 0;
	}
	UUnrealMesh*& CachedMesh  = *(UUnrealMesh**)Mem; Mem += sizeof(UUnrealMesh*);
	FLOAT&  CachedFrame = *(FLOAT *)Mem; Mem += sizeof(FLOAT );
	FName&  CachedSeq   = *(FName *)Mem; Mem += sizeof(FName);
	if( !WasCached )
	{
		CachedMesh  = Mesh;
		CachedSeq   = NAME_None;
		CachedFrame = 0.0;
	}

	// Get stuff.
	FLOAT    DrawScale      = AnimOwner->bParticles ? 1.0 : Actor->DrawScale;
	FVector* CachedVerts    = (FVector*)Mem;
	Coords                  = Coords * (Actor->Location + Actor->PrePivot) * Actor->Rotation * Mesh->RotOrigin * FScale(Mesh->Scale * DrawScale,0.0,SHEER_None);
	FMeshAnimSeq* Seq = NULL;
	for (INT iSeq=0;iSeq<Mesh->AnimSeqs.Num();iSeq++)
	{
		if (AnimOwner->AnimSequence==Mesh->AnimSeqs(iSeq).Name)
		{
			Seq = &Mesh->AnimSeqs(iSeq);
			break;
		}
	}

	// Transform all points into screenspace.
	if( AnimOwner->AnimFrame>=0.0 || !WasCached )
	{
		// Compute interpolation numbers.
		FLOAT Alpha=0.0;
		INT iFrameOffset1=0, iFrameOffset2=0;
		if( Seq )
		{
			FLOAT Frame   = ::Max(AnimOwner->AnimFrame,0.f) * Seq->NumFrames;
			INT iFrame    = appFloor(Frame);
			Alpha         = Frame - iFrame;
			iFrameOffset1 = (Seq->StartFrame + ((iFrame + 0) % Seq->NumFrames)) * Mesh->FrameVerts;
			iFrameOffset2 = (Seq->StartFrame + ((iFrame + 1) % Seq->NumFrames)) * Mesh->FrameVerts;
		}

		// Interpolate two frames.
		FMeshVert* MeshVertex1 = &Mesh->Verts( iFrameOffset1 );
		FMeshVert* MeshVertex2 = &Mesh->Verts( iFrameOffset2 );
		for( INT i=0; i<Mesh->FrameVerts; i++ )
		{
			FVector V1( MeshVertex1[i].X, MeshVertex1[i].Y, MeshVertex1[i].Z );
			FVector V2( MeshVertex2[i].X, MeshVertex2[i].Y, MeshVertex2[i].Z );
			CachedVerts[i] = V1 + (V2-V1)*Alpha;
			*ResultVerts = (CachedVerts[i] - Mesh->Origin).TransformPointBy(Coords);
			*(BYTE**)&ResultVerts += Size;
		}
	}
	else
	{
		// Compute tweening numbers.
		FLOAT StartFrame = Seq ? (-1.0 / Seq->NumFrames) : 0.0;
		INT iFrameOffset = Seq ? Seq->StartFrame * Mesh->FrameVerts : 0;
		FLOAT Alpha = 1.0 - AnimOwner->AnimFrame / CachedFrame;
		if( CachedSeq!=AnimOwner->AnimSequence || Alpha<0.0 || Alpha>1.0)
		{
			CachedSeq   = AnimOwner->AnimSequence;
			CachedFrame = StartFrame;
			Alpha       = 0.0;
		}

		// Tween all points.
		FMeshVert* MeshVertex = &Mesh->Verts( iFrameOffset );
		for( INT i=0; i<Mesh->FrameVerts; i++ )
		{
			FVector V2( MeshVertex[i].X, MeshVertex[i].Y, MeshVertex[i].Z );
			CachedVerts[i] += (V2 - CachedVerts[i]) * Alpha;
			*ResultVerts = (CachedVerts[i] - Mesh->Origin).TransformPointBy(Coords);
			*(BYTE**)&ResultVerts += Size;
		}

		// Update cached frame.
		CachedFrame = AnimOwner->AnimFrame;
	}
	Item->Unlock();
	return(Mesh->FrameVerts);
}

void UUnrealMeshInstance::Draw(/* FSceneNode* */void* InFrame, /* FDynamicSprite* */void* InSprite,
	FCoords InCoords, DWORD InPolyFlags)
{
}

/*-----------------------------------------------------------------------------
	3DNow! code.
-----------------------------------------------------------------------------*/
#if ASM3DNOW

#pragma pack( 8 )
#pragma warning( disable : 4799 )

//
// K6 3D Optimized version of the interpolation loop of UUnrealMesh::GetFrame
//
inline void DoInterpolateLoop
(
	FMeshVert*	MeshVertex1,
	FMeshVert*	MeshVertex2,
	INT			FrameVerts,
	FVector&	Origin,
	FLOAT		Alpha,
	FCoords&	Coords,
	FVector*	CachedVerts,
	FVector*	ResultVerts,
	INT			ResultVertSize
)
{
	FVector CombinedOrigin;
	FLOAT TmpAlpha=Alpha; // Bloody compiler.
	struct
	{
		float X,Y;
	} Vertex1, Vertex2;
	__asm
	{
		femms

		// Calculate combined origin.
		mov		ebx,Origin
		mov		edx,Coords
		movq	mm2,[ebx]FVector.X
		movq	mm4,[edx]FCoords.Origin.X
		pfadd	(m4,m2)
		movd	mm3,[ebx]FVector.Z
		movd	mm5,[edx]FCoords.Origin.Z
		pfadd	(m5,m3)
		movq	CombinedOrigin.X,mm4
		movd	CombinedOrigin.Z,mm5

		// Set up for loop.
		mov		eax,MeshVertex1
		mov		ecx,FrameVerts
		mov		esi,ResultVerts
		mov		edi,CachedVerts
		sub		esi,4				// Move ESI back a bit to prevent plain [esi] addressing.
		cmp		ecx,0
		jz		Done

InterpolateLoop:
		// Expand packed FMeshVerts
		mov		FrameVerts,ecx		// Save count, mm7=0|A
		movd	mm7,TmpAlpha
		mov		ebx,[eax]			// Get packed V1
		shl		ebx,21				// Extract X1
		sar		ebx,21
		mov		ecx,[eax]			// Get packed V1
		mov		Vertex1.X,ebx		// Save X1
		shl		ecx,10				// Extract Y1
		sar		ecx,21
		mov		edx,[eax]			// Get packed V1
		mov		Vertex1.Y,ecx		// Save Y1
		add		eax,TYPE FMeshVert	// Increment MeshVertex1 ptr
		mov		ebx,MeshVertex2		// Get ptr to MeshVertes2
		mov		MeshVertex1,eax		// Save updated MeshVertex1
		sar		edx,22				// Extract Z1
		movq	mm0,Vertex1.X		// mm0=(int)Y1|X1 
		movd	mm1,edx				// Save Z1 directly to MMX register (mm1=(int)0|Z1)
		mov		ecx,[ebx]			// Get packed V2
		shl		ecx,21				// Extract X2
		sar		ecx,21
		mov		eax,[ebx]			// Get packed V2
		mov		Vertex2.X,ecx		// Save X2
		shl		eax,10				// Extract Y2
		sar		eax,21
		mov		edx,[ebx]			// Get packed V2
		mov		Vertex2.Y,eax		// Save Y2
		add		ebx,TYPE FMeshVert	// Increment MeshVertex2 ptr
		sar		edx,22				// Extract Z2
		mov		MeshVertex2,ebx		// Save updated MeshVertex2
		movq	mm2,Vertex2.X		// mm2=int(Y2|X2)
		movd	mm3,edx				// Save Z2 directly to MMX register (mm3=(int)0|Z2)

		// Now do interpolation and transformation.
		pi2fd	(m0,m0)					// mm0=Y1|X1, edx=ptr to Coords
		mov		ecx,Coords
		pi2fd	(m2,m2)					// mm2=Y2|X2, mm7=A|A
		punpckldq mm7,mm7
		pfsub	(m2,m0)					// mm2=Y2-Y1|X2-X1, mm1=0|Z1
		pi2fd	(m1,m1)
		pfmul	(m2,m7)					// mm2=(Y2-Y1)A|(X2-X1)A, mm3=0|Z2
		pi2fd	(m3,m3)
		pfsub	(m3,m1)					// mm3=0|Z2-Z1, mm4=Yo|Xo
		movq	mm4,CombinedOrigin.X
		pfmul	(m3,m7)					// mm3=0|(Z2-Z1)A, mm5=0|Zo
		movd	mm5,CombinedOrigin.Z
		pfadd	(m0,m2)					// mm0=Y1+(Y2-Y1)A|X1+(X2-X1)A=Ycv|Xcv, mm6=Yxa|Xxa
		movq	mm6,[ecx]FCoords.XAxis.X
		pfadd	(m1,m3)					// mm1=0|Z1+(Z2-Z1)A=0|Zcv, mm7=0|Zxa
		movd	mm7,[ecx]FCoords.XAxis.Z
		pfsubr	(m4,m0)					// mm4=Ycv-Yo|Xcv-Xo=Y|X, mm2=Yya|Xya
		movq	mm2,[ecx]FCoords.YAxis.X
		pfsubr	(m5,m1)					// mm5=0|Z0-Zcv=0|Z, mm3=0|Zya
		movd	mm3,[ecx]FCoords.YAxis.Z
		pfmul	(m6,m4)					// mm6=YxaY|XxaX=Yx|Xx, save Ycv|Xcv
		movq	[edi]FVector.X,mm0
		pfmul	(m7,m5)					// mm7=0|ZxaZ=0|Zx, mm0=Yza|Xza
		movq	mm0,[ecx]FCoords.ZAxis.X
		pfmul	(m2,m4)					// mm2=YyaY|XyaX=Yy|Xy, save Zcv
		movd	[edi]FVector.Z,mm1
		pfmul	(m3,m5)					// mm3=0|ZyaZ=0|Zy, mm1=0|Zza
		movd	mm1,[ecx]FCoords.ZAxis.Z
		pfmul	(m4,m0)					// mm4=YzaY|XzaX=Yz|Xz,mm6=Xy+Yy|Xx+Yx
		pfacc	(m6,m2)
		punpckldq mm7,mm3				// mm7=Zy|Zx, mm5=0|ZzaZ=0|Zz
		pfmul	(m5,m1)
		pfacc	(m4,m4)					// mm4=Yz+Xz|Yz+Xz, ecx=Count
		mov		ecx,FrameVerts			
		pfadd	(m6,m7)					// mm6=Xy+Yy+Zy|Xx+Yx+Zx=Y'|X', eax=ptr to MeshVertex1
		mov		eax,MeshVertex1
		pfadd	(m5,m4)					// mm5=Yz+Xz|Zz+Yz+Xz=?|Z', inc ptr to CachedVerts
		add		edi,TYPE FVector
		movq	[esi+4]FVector.X,mm6	// save Y'|X', save Z'
		movd	[esi+4]FVector.Z,mm5
		add		esi,ResultVertSize		// inc ptr to ResultVerts, loop
		dec		ecx
		jnz		InterpolateLoop
Done:
		femms
	}
}

//
// K6 3D Optimized version of the tween loop of UUnrealMesh::GetFrame
// This routine is almost identical to DoInterpolateLoop except CacheVerts is used
// in place of MeshVertex1
//
static inline void DoTweenLoop
(
	FMeshVert*	MeshVertex,
	INT			FrameVerts,
	FVector&	Origin,
	FLOAT		Alpha,
	FCoords&	Coords,
	FVector*	CachedVerts,
	FVector*	ResultVerts,
	INT			ResultVertSize
)
{
	FVector CombinedOrigin;
	FLOAT TmpAlpha=Alpha; // Bloody compiler.
	struct
	{
		float X,Y;
	} Vertex;
	__asm
	{
		femms

		// Calculate combined origin.
		mov		ebx,Origin
		mov		edx,Coords
		movq	mm2,[ebx]FVector.X
		movq	mm4,[edx]FCoords.Origin.X
		pfadd	(m4,m2)
		movd	mm3,[ebx]FVector.Z
		movd	mm5,[edx]FCoords.Origin.Z
		pfadd	(m5,m3)
		movq	CombinedOrigin.X,mm4
		movd	CombinedOrigin.Z,mm5

		// Set up for loop.
		mov		eax,MeshVertex
		mov		ecx,FrameVerts
		mov		esi,ResultVerts
		mov		edi,CachedVerts
		sub		esi,4				// Move ESI back a bit to prevent plain [esi] addressing.
		cmp		ecx,0
		jz		Done

InterpolateLoop:
		// Expand packed FMeshVerts
		mov		FrameVerts,ecx		// Save count, mm7=0|A
		movd	mm7,TmpAlpha
		mov		ebx,[eax]			// Get packed V1
		shl		ebx,21				// Extract X1
		sar		ebx,21
		mov		ecx,[eax]			// Get packed V1
		mov		Vertex.X,ebx		// Save X1
		shl		ecx,10				// Extract Y1
		sar		ecx,21
		mov		edx,[eax]			// Get packed V1
		mov		Vertex.Y,ecx		// Save Y1
		add		eax,TYPE FMeshVert	// Increment MeshVertex1 ptr
		mov		MeshVertex,eax		// Save updated MeshVertex1
		sar		edx,22				// Extract Z1
		movq	mm2,Vertex.X		// mm0=(int)Y1|X1 
		movd	mm3,edx				// Save Z1 directly to MMX register (mm1=(int)0|Z1)
		// Now do interpolation and transformation.
		movq	mm0,[edi]FVector.X		// mm0=Y1|X1, edx=ptr to Coords
		mov		ecx,Coords
		pi2fd	(m2,m2)					// mm2=Y2|X2, mm7=A|A
		punpckldq mm7,mm7
		pfsub	(m2,m0)					// mm2=Y2-Y1|X2-X1, mm1=0|Z1
		movd	mm1,[edi]FVector.Z
		pfmul	(m2,m7)					// mm2=(Y2-Y1)A|(X2-X1)A, mm3=0|Z2
		pi2fd	(m3,m3)
		pfsub	(m3,m1)					// mm3=0|Z2-Z1, mm4=Yo|Xo
		movq	mm4,CombinedOrigin.X
		pfmul	(m3,m7)					// mm3=0|(Z2-Z1)A, mm5=0|Zo
		movd	mm5,CombinedOrigin.Z
		pfadd	(m0,m2)					// mm0=Y1+(Y2-Y1)A|X1+(X2-X1)A=Ycv|Xcv, mm6=Yxa|Xxa
		movq	mm6,[ecx]FCoords.XAxis.X
		pfadd	(m1,m3)					// mm1=0|Z1+(Z2-Z1)A=0|Zcv, mm7=0|Zxa
		movd	mm7,[ecx]FCoords.XAxis.Z
		pfsubr	(m4,m0)					// mm4=Ycv-Yo|Xcv-Xo=Y|X, mm2=Yya|Xya
		movq	mm2,[ecx]FCoords.YAxis.X
		pfsubr	(m5,m1)					// mm5=0|Z0-Zcv=0|Z, mm3=0|Zya
		movd	mm3,[ecx]FCoords.YAxis.Z
		pfmul	(m6,m4)					// mm6=YxaY|XxaX=Yx|Xx, save Ycv|Xcv
		movq	[edi]FVector.X,mm0
		pfmul	(m7,m5)					// mm7=0|ZxaZ=0|Zx, mm0=Yza|Xza
		movq	mm0,[ecx]FCoords.ZAxis.X
		pfmul	(m2,m4)					// mm2=YyaY|XyaX=Yy|Xy, save Zcv
		movd	[edi]FVector.Z,mm1
		pfmul	(m3,m5)					// mm3=0|ZyaZ=0|Zy, mm1=0|Zza
		movd	mm1,[ecx]FCoords.ZAxis.Z
		pfmul	(m4,m0)					// mm4=YzaY|XzaX=Yz|Xz,mm6=Xy+Yy|Xx+Yx
		pfacc	(m6,m2)
		punpckldq mm7,mm3				// mm7=Zy|Zx, mm5=0|ZzaZ=0|Zz
		pfmul	(m5,m1)
		pfacc	(m4,m4)					// mm4=Yz+Xz|Yz+Xz, ecx=Count
		mov		ecx,FrameVerts			
		pfadd	(m6,m7)					// mm6=Xy+Yy+Zy|Xx+Yx+Zx=Y'|X', eax=ptr to MeshVertex1
		mov		eax,MeshVertex
		pfadd	(m5,m4)					// mm5=Yz+Xz|Zz+Yz+Xz=?|Z', inc ptr to CachedVerts
		add		edi,TYPE FVector
		movq	[esi+4]FVector.X,mm6	// save Y'|X', save Z'
		movd	[esi+4]FVector.Z,mm5
		add		esi,ResultVertSize		// inc ptr to ResultVerts, loop
		dec		ecx
		jnz		InterpolateLoop
Done:
		femms
	}
}

//
// Get the transformed point set corresponding to the animation frame 
// of this primitive owned by Owner. Returns the total outcode of the points.
//
inline INT UUnrealMeshInstance::AMD3DGetFrame
(
	FVector*	ResultVerts,
	BYTE*		VertsEnabled, 
	INT			Size,
	FCoords		Coords,
	FLOAT		LodLevel
)
{
	if (!Actor || !Mesh)
		return(0);

	// Create or get cache memory.
	FCacheItem* Item = NULL;
	UBOOL WasCached  = 1;
	QWORD CacheID    = MakeCacheID( CID_TweenAnim, Actor, NULL );
	BYTE* Mem        = GCache.Get( CacheID, Item );
	if( Mem==NULL || *(UUnrealMesh**)Mem!=Mesh )
	{
		if( Mem != NULL )
		{
			// Actor's mesh changed.
			Item->Unlock();
			GCache.Flush( CacheID );
		}
		Mem = GCache.Create( CacheID, Item, sizeof(UUnrealMesh*) + sizeof(FLOAT) + sizeof(FName) + Mesh->FrameVerts * sizeof(FVector) );
		WasCached = 0;
	}
	UUnrealMesh*& CachedMesh  = *(UUnrealMesh**)Mem; Mem += sizeof(UUnrealMesh*);
	FLOAT&  CachedFrame = *(FLOAT *)Mem; Mem += sizeof(FLOAT );
	FName&  CachedSeq   = *(FName *)Mem; Mem += sizeof(FName);
	if( !WasCached )
	{
		CachedMesh  = Mesh;
		CachedSeq   = NAME_None;
		CachedFrame = 0.0;
	}

	// Get stuff.
	FLOAT    DrawScale      = Actor->bParticles ? 1.0 : Actor->DrawScale;
	FVector* CachedVerts    = (FVector*)Mem;
	Coords                  = Coords * (Actor->Location + Actor->PrePivot) * Actor->Rotation * Mesh->RotOrigin * FScale(Mesh->Scale * DrawScale,0.0,SHEER_None);
	FMeshAnimSeq* Seq = NULL;
	for (INT iSeq=0;iSeq<Mesh->AnimSeqs.Num();iSeq++)
	{
		if (Actor->AnimSequence==Mesh->AnimSeqs(iSeq).Name)
		{
			Seq = &Mesh->AnimSeqs(iSeq);
			break;
		}
	}

	// Transform all points into screenspace.
	if( Actor->AnimFrame>=0.0 || !WasCached )
	{
		// Compute interpolation numbers.
		FLOAT Alpha=0.0;
		INT iFrameOffset1=0, iFrameOffset2=0;
		if( Seq )
		{
			FLOAT Frame   = ::Max(Actor->AnimFrame,0.f) * Seq->NumFrames;
			INT iFrame    = appFloor(Frame);
			Alpha         = Frame - iFrame;
			iFrameOffset1 = (Seq->StartFrame + ((iFrame + 0) % Seq->NumFrames)) * Mesh->FrameVerts;
			iFrameOffset2 = (Seq->StartFrame + ((iFrame + 1) % Seq->NumFrames)) * Mesh->FrameVerts;
		}

		// Interpolate two frames.
		FMeshVert* MeshVertex1 = &Mesh->Verts( iFrameOffset1 );
		FMeshVert* MeshVertex2 = &Mesh->Verts( iFrameOffset2 );
		DoInterpolateLoop
		(
			MeshVertex1,
			MeshVertex2,
			Mesh->FrameVerts,
			Mesh->Origin,
			Alpha,
			Coords,
			CachedVerts,
			ResultVerts,
			Size
		);
	}
	else
	{
		// Compute tweening numbers.
		FLOAT StartFrame = Seq ? (-1.0 / Seq->NumFrames) : 0.0;
		INT iFrameOffset = Seq ? Seq->StartFrame * Mesh->FrameVerts : 0;
		FLOAT Alpha = 1.0 - Actor->AnimFrame / CachedFrame;
		if( CachedSeq!=Actor->AnimSequence || Alpha<0.0 || Alpha>1.0)
		{
			CachedSeq   = Actor->AnimSequence;
			CachedFrame = StartFrame;
			Alpha       = 0.0;
		}

		// Tween all points.
		FMeshVert* MeshVertex = &Mesh->Verts( iFrameOffset );
		DoTweenLoop
		(
			MeshVertex,
			Mesh->FrameVerts,
			Mesh->Origin,
			Alpha,
			Coords,
			CachedVerts,
			ResultVerts,
			Size
		);

		// Update cached frame.
		CachedFrame = Actor->AnimFrame;
	}
	Item->Unlock();
	return(Mesh->FrameVerts);
}

#pragma warning( default : 4799 )
#pragma pack()

#endif

/*-----------------------------------------------------------------------------
	The end.
-----------------------------------------------------------------------------*/
