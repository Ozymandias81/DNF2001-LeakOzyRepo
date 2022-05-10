/*=============================================================================
	UnLodMesh.cpp: Unreal mesh animation functions
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by Tim Sweeney
		* Subclassed for level-of-detail meshes by Erik de Neve
		 
	    * Remarks
		  - New methods: the explicit ctor, and GetFrame()
		  - Distinguishing Mesh from LodMesh : if( Mesh->IsA(UUnrealLodMesh::StaticClass()) )
		  - No specific amd3d support.

=============================================================================*/ 

#include "EnginePrivate.h"
#include "UnMeshPrivate.h"

class ENGINE_API UUnrealLodMeshInstance : public UUnrealMeshInstance
{
	DECLARE_CLASS(UUnrealLodMeshInstance,UUnrealMeshInstance,CLASS_Transient)

	// UMeshInstance
	INT GetFrame(FVector* Verts, BYTE* VertsEnabled, INT Size, FCoords Coords, FLOAT LodLevel);
};

/*-----------------------------------------------------------------------------
	UUnrealLodMesh object implementation.
-----------------------------------------------------------------------------*/

IMPLEMENT_CLASS(UUnrealLodMesh);
IMPLEMENT_CLASS(UUnrealLodMeshInstance);

void UUnrealLodMesh::Serialize( FArchive& Ar )
{

	// Empty those structures not needed for LOD mesh rendering.
	// Vertlinks and Connects already empty for LOD meshes.
	if( Ar.IsSaving() )
	{
		Tris.Empty();
	}

	// Serialize parent's variables
	Super::Serialize(Ar);

	// Serialize the additional LodMesh variables.
	Ar << CollapsePointThus;
	Ar << FaceLevel;
	Ar << Faces;
	Ar << CollapseWedgeThus;
	Ar << Wedges;
	Ar << Materials;
	Ar << SpecialFaces;
	Ar << ModelVerts << SpecialVerts;
	Ar << MeshScaleMax;
	Ar << LODHysteresis << LODStrength << LODMinVerts << LODMorph << LODZDisplace;
	Ar << RemapAnimVerts << OldFrameVerts;

	// Quickly remap animation vertices at loading time.
	if( Ar.IsLoading() )
	{
		if ( RemapAnimVerts.Num() )
		{
			// Make sure lazy arrays got loaded.
			Verts.Load();

			// Bigass new array.
			TArray<FMeshVert> NewVerts;
			NewVerts.Add( FrameVerts * AnimFrames);
			for( INT f=0; f<AnimFrames; f++ )
			{
				INT FrameStart = f * OldFrameVerts;
				INT FullFrameStart = f * FrameVerts;
				// Copy permutated.
				for( INT v=0; v<FrameVerts; v++ )
				{
					// If necessary this process duplicates or throws out vertices...
					NewVerts(FullFrameStart + v) = Verts( RemapAnimVerts(v) + FrameStart); 					
				}
			}

			// Kludgy array exchange.
			Verts.Empty();
			Verts.Add(NewVerts.Num());
			ExchangeArray(Verts, NewVerts);
			NewVerts.Empty();			

			// Discard remapping array
			RemapAnimVerts.Empty();
		}
	}

}

void UUnrealLodMesh::SetScale(FVector InScale)
{
	Super::SetScale(InScale);
	// Maximum mesh scaling dimension for LOD gauging.
	MeshScaleMax = (1.f/ 128.f) * BoundingSphere.W * Max(Abs(Scale.X), Max(Abs(Scale.Y), Abs(Scale.Z)));
	//debugf(TEXT("New MeshScaleMax %f "),MeshScaleMax); 
}

UClass* UUnrealLodMesh::GetInstanceClass()
{
	return(UUnrealLodMeshInstance::StaticClass());
}

/*-----------------------------------------------------------------------------
	UUnrealLodMesh constructor.
-----------------------------------------------------------------------------*/
//
// UUnrealLodMesh constructor.
//
UUnrealLodMesh::UUnrealLodMesh( INT NumPolys, INT NumVerts, INT NumFrames)
{
	// Default LOD settings.
	LODMinVerts		= 10;		// Minimum number of vertices with which to draw a model. (Minimum for a cube = 8...)
	LODStrength		= 1.00f;	// Scales the (not necessarily linear) falloff of vertices with distance.
	LODMorph        = 0.30f;	// Morphing range. 0.0 = no morphing.
	LODZDisplace    = 0.00f;    // Z-displacement (in world units) for falloff function tweaking.
	LODHysteresis	= 0.00f;	// Controls LOD-level change delay/morphing. (unused)

	// Set counts.
	FrameVerts	= NumVerts;
	AnimFrames	= NumFrames;

	// Allocate all stuff.
	Tris			.Add(NumPolys);
	Verts			.Add(NumVerts * NumFrames);
	BoundingBoxes	.Add(NumFrames);
	/* CDH: removed from class (never used)
	BoundingSpheres .Add(NumFrames);
	*/

	// Init textures.
	for( INT i=0; i<Textures.Num(); i++ )
		Textures(i) = NULL;

}


/*-----------------------------------------------------------------------------
	UUnrealLodMesh animation interface.
-----------------------------------------------------------------------------*/

// Cached frame header struct for temp cached meshes.
struct CFLodHeader
{
	UMesh	*CachedMesh;
	FLOAT	CachedFrame;
	FName	CachedSeq;	
	INT     CachedLodVerts;
	FLOAT   TweenIndicator;
};	

INT UUnrealLodMeshInstance::GetFrame
(
	FVector*	ResultVerts,
	BYTE*		VertsEnabled,
	INT			Size,
	FCoords		Coords,
	FLOAT		LodLevel
)
{
	if (!Actor || !Mesh || !Mesh->IsA(UUnrealLodMesh::StaticClass()))
		return(0);
	UUnrealLodMesh* LodMesh = Cast<UUnrealLodMesh>(Mesh);

	INT LODRequest = LodLevel*LodMesh->ModelVerts;
	
	// Make sure any used lazy-loadable arrays are ready.
	Mesh->Verts.Load();

	AActor*	AnimOwner = NULL;

	// Check to see if bAnimByOwner
	if ((Actor->bAnimByOwner) && (Actor->Owner != NULL))
		AnimOwner = Actor->Owner;
	else
		AnimOwner = Actor;

	// Determine how many vertices to lerp; in case of tweening, we're limited 
	// by the previous cache size also.
	INT VertsRequested = Min(LODRequest + LodMesh->SpecialVerts, Mesh->FrameVerts);	
	INT VertexNum = VertsRequested;

	// Create or get cache memory.
	FCacheItem* Item = NULL;
	UBOOL WasCached  = 1;
	QWORD CacheID    = MakeCacheID( CID_TweenAnim, Actor, NULL );
	BYTE* Mem = GCache.Get( CacheID, Item );
	CFLodHeader* FrameHdr = (CFLodHeader*)Mem;

	if( Mem==NULL || FrameHdr->CachedMesh !=Mesh )
	{
		if( Mem != NULL )
		{
			// Actor's mesh changed.
			Item->Unlock();
			GCache.Flush( CacheID );
		}
		// Full size cache (for now.) We don't want to have to realloc every time our LOD scales up a bit...
		Mem = GCache.Create( CacheID, Item, sizeof(CFLodHeader) + Mesh->FrameVerts * sizeof(FVector) );
		FrameHdr = (CFLodHeader*)Mem;
		WasCached = 0;
		FrameHdr->TweenIndicator = 1.0f;
	}

	if( !WasCached )
	{
		FrameHdr->CachedMesh  = Mesh;
		FrameHdr->CachedSeq   = NAME_None;
		FrameHdr->CachedFrame = 0.0;
		FrameHdr->CachedLodVerts = 0;
	}

	// Get stuff.
	FLOAT    DrawScale      = AnimOwner->bParticles ? 1.0 : Actor->DrawScale;
	FVector* CachedVerts    = (FVector*)((BYTE*)Mem + sizeof(CFLodHeader));
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


	if( AnimOwner->AnimFrame>=0.0  || !WasCached )
	{
		LODRequest = VertexNum - LodMesh->SpecialVerts; // How many regular vertices returned.
		FrameHdr->CachedLodVerts = VertexNum;  //

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
		

		// Special case Alpha 0. 
		if ( Alpha <= 0.0f)
		{
			// Initialize a single frame.
			FMeshVert* MeshVertex1 = &Mesh->Verts( iFrameOffset1 );

			for( INT i=0; i<VertexNum; i++ )
			{
				// Expand new vector from stored compact integers.
				CachedVerts[i] = FVector( MeshVertex1[i].X, MeshVertex1[i].Y, MeshVertex1[i].Z );
				// Transform all points into screenspace.
				*ResultVerts = (CachedVerts[i] - Mesh->Origin).TransformPointBy(Coords);
				*(BYTE**)&ResultVerts += Size;
			}	
		}
		else
		{	
			// Interpolate two frames.
			FMeshVert* MeshVertex1 = &Mesh->Verts( iFrameOffset1 );
			FMeshVert* MeshVertex2 = &Mesh->Verts( iFrameOffset2 );
			for( INT i=0; i<VertexNum; i++ )
			{
				FVector V1( MeshVertex1[i].X, MeshVertex1[i].Y, MeshVertex1[i].Z );
				FVector V2( MeshVertex2[i].X, MeshVertex2[i].Y, MeshVertex2[i].Z );
				CachedVerts[i] = V1 + (V2-V1)*Alpha;
				*ResultVerts = (CachedVerts[i] - Mesh->Origin).TransformPointBy(Coords);
				*(BYTE**)&ResultVerts += Size;
			}
		}	
	}
	else // Tween: cache present, and starting from Animframe < 0.0
	{
		// Any requested number within CACHE limit is ok, since 
		// we cannot tween more than we have in the cache.
		VertexNum  = Min(VertexNum,FrameHdr->CachedLodVerts);
		FrameHdr->CachedLodVerts = VertexNum;
		LODRequest = VertexNum - LodMesh->SpecialVerts; // how many regular vertices returned.

		// Compute tweening numbers.
		FLOAT StartFrame = Seq ? (-1.0 / Seq->NumFrames) : 0.0;
		INT iFrameOffset = Seq ? Seq->StartFrame * Mesh->FrameVerts : 0;
		FLOAT Alpha = 1.0 - AnimOwner->AnimFrame / FrameHdr->CachedFrame;

		if( FrameHdr->CachedSeq!=AnimOwner->AnimSequence )
		{
			FrameHdr->TweenIndicator = 0.0f;
		}
		
		// Original:
		if( FrameHdr->CachedSeq!=AnimOwner->AnimSequence || Alpha<0.0f || Alpha>1.0f)
		{
			FrameHdr->CachedFrame = StartFrame; 
			Alpha       = 0.0f;
			FrameHdr->CachedSeq = AnimOwner->AnimSequence;
		}
				
		// Tween indicator says destination has been (practically) reached ?
		FrameHdr->TweenIndicator += (1.0f - FrameHdr->TweenIndicator) * Alpha;
		if( FrameHdr->TweenIndicator > 0.97f ) 
		{
			// We can set Alpha=0 (faster).
			Alpha = 0.0f;

			// LOD fix: if the cache has too little vertices, 
			// now is the time to fill it out to the requested number.
			if (VertexNum < VertsRequested )
			{
				FMeshVert* MeshVertex = &Mesh->Verts( iFrameOffset );
				for( INT i=VertexNum; i<VertsRequested; i++ )
				{
					CachedVerts[i]= FVector( MeshVertex[i].X, MeshVertex[i].Y, MeshVertex[i].Z );
				}
				VertexNum = VertsRequested;
				LODRequest = VertexNum - LodMesh->SpecialVerts; 
				FrameHdr->CachedLodVerts = VertexNum;   
			}
		}
		
		// Special case Alpha 0.
		if (Alpha <= 0.0f)
		{
			for( INT i=0; i<VertexNum; i++ )
			{
				*ResultVerts = (CachedVerts[i] - Mesh->Origin).TransformPointBy(Coords);
				*(BYTE**)&ResultVerts += Size;
			}
		}
		else
		{
			// Tween all points between cached value and new one.
			FMeshVert* MeshVertex = &Mesh->Verts( iFrameOffset );
			for( INT i=0; i<VertexNum; i++ )
			{
				FVector V2( MeshVertex[i].X, MeshVertex[i].Y, MeshVertex[i].Z );
				CachedVerts[i] += (V2 - CachedVerts[i]) * Alpha;
				*ResultVerts = (CachedVerts[i] - Mesh->Origin).TransformPointBy(Coords);
				*(BYTE**)&ResultVerts += Size;
			}
		}
		// Update cached frame.
		FrameHdr->CachedFrame = AnimOwner->AnimFrame;
	}

	Item->Unlock();

	return(LODRequest);
}

/*-----------------------------------------------------------------------------
	The end.
-----------------------------------------------------------------------------*/
