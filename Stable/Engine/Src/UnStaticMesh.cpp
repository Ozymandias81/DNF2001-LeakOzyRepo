/*=============================================================================
	UnStaticMesh.cpp: Static mesh class implementation.
	Copyright 1997-2000 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by Andrew Scheidecker
=============================================================================*/

#include "EnginePrivate.h"

IMPLEMENT_CLASS(UStaticMesh);
IMPLEMENT_CLASS(AStaticMeshActor);

/*
	UStaticMesh::UStaticMesh
*/

UStaticMesh::UStaticMesh()
{
}

/*
	UStaticMesh::GetRenderBoundingBox
*/

FBox UStaticMesh::GetRenderBoundingBox(AActor* Owner,UBOOL Exact)
{
	return BoundingBox.ExpandBy(1.0f).TransformBy(LocalToWorld(Owner));
}

/*
	UStaticMesh::GetCollisionBoundingBox
*/

FBox UStaticMesh::GetCollisionBoundingBox(const AActor* Owner) const
{
	return BoundingBox.ExpandBy(1.0f).TransformBy(LocalToWorld(Owner));
}

/*
	UStaticMesh::LineCheck
*/

UBOOL UStaticMesh::LineCheck(FCheckResult& Result,AActor* Owner,FVector End,FVector Start,FVector Extent,DWORD ExtraNodeFlags)
{
	guard(UStaticMesh::LineCheck);

	return CollisionModel->LineCheck(Result,Owner,End,Start,FVector(0,0,0) /*Extent*/,ExtraNodeFlags);

	unguard;
}

/*
	UStaticMesh::Raytrace
*/

void UStaticMesh::Raytrace(FRaytracerInterface* Raytracer,AActor* Owner)
{
	guard(UStaticMesh::Raytrace);

	LightInfos.Empty();

	if(Owner->bStatic)
	{
		FCoords	ToWorld = LocalToWorld(Owner);
		INT		NumLights = Raytracer->GetNumLights();

		RaytraceCoords = ToWorld;

		for(INT LightIndex = 0;LightIndex < NumLights;LightIndex++)
		{
			FStaticMeshLightInfo*	LightInfo = new(LightInfos) FStaticMeshLightInfo(Raytracer->GetLightActor(LightIndex));

			LightInfo->VisibilityBitmap.AddZeroed((VertexBuffer->Vertices.Num() + 7) / 8);
		}

		INT		BitmapIndex = 0;
		BYTE	BitMask = 1;

		for(INT Index = 0;Index < VertexBuffer->Vertices.Num();Index++)
		{
			FPlane	Color = FPlane(0,0,0,0);
			FVector	SamplePoint = VertexBuffer->Vertices(Index).Position.TransformPointBy(ToWorld),
					SampleNormal = VertexBuffer->Vertices(Index).Normal.TransformVectorBy(ToWorld);

			GWarn->StatusUpdatef(Index,VertexBuffer->Vertices.Num(),TEXT("Raytracing StaticMesh..."));

			SamplePoint += SampleNormal;

			for(LightIndex = 0;LightIndex < NumLights;LightIndex++)
			{
				AActor* LightActor = LightInfos(LightIndex).LightActor;
				FLOAT WorldLightRadiusSquared = LightActor->WorldLightRadius();
				WorldLightRadiusSquared *= WorldLightRadiusSquared;

				if(	
					(LightActor->Location - SamplePoint).SizeSquared() < WorldLightRadiusSquared &&
					(SampleNormal | (LightActor->Location - SamplePoint)) > 0.0 &&
					Raytracer->Raytrace(SamplePoint,LightIndex,0)
				)
					LightInfos(LightIndex).VisibilityBitmap(BitmapIndex) |= BitMask;
			}

			BitMask <<= 1;

			if(!BitMask)
			{
				BitmapIndex++;
				BitMask = 1;
			}
		}

		for( INT i=0;i<LightInfos.Num();i++ )
		{
			for( INT j=0;j<LightInfos(i).VisibilityBitmap.Num(); j++ )
				if( LightInfos(i).VisibilityBitmap(j) )
					goto LightVisible;

			LightInfos(i).VisibilityBitmap.Empty();
			LightInfos.Remove(i);
			i--;
	LightVisible:
			;
		}
	}

	unguard;
}

/*
	UStaticMesh::Serialize
*/

void UStaticMesh::Serialize(FArchive& Ar)
{
	guard(UStaticMesh::Serialize);

	Super::Serialize(Ar);

	Ar	<< VertexBuffer
		<< IndexBuffer
		<< Sections
		<< BoundingBox
		<< CollisionModel
		<< LightInfos
		<< RaytraceCoords;

	unguard;
}
