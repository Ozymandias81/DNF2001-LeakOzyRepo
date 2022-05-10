/*=============================================================================
	ABeamSystem.cpp: BeamSystem Script interface code.
	Copyright 1999-2000 3D Realms, Inc. All Rights Reserved.
=============================================================================*/
#include "EnginePrivate.h"

/*-----------------------------------------------------------------------------
	ABeamSystem object implementation.
-----------------------------------------------------------------------------*/
IMPLEMENT_CLASS(ABeamSystem);

FBox ABeamSystem::ComputeBoundingBox()
{
	FBox b;

	BoundingBoxMin=Location-FVector(5,5,5);
	BoundingBoxMax=Location+FVector(5,5,5);

	if(BeamType!=BST_Spline)
	{
		for(INT i=0;i<NumberDestinations;i++)
		{
			FVector DestinationLocation = DestinationActor[i]->Location + DestinationOffset[i];

				 if(DestinationLocation.X<BoundingBoxMin.X) BoundingBoxMin.X=DestinationLocation.X;
			else if(DestinationLocation.X>BoundingBoxMax.X) BoundingBoxMax.X=DestinationLocation.X;

				 if(DestinationLocation.Y<BoundingBoxMin.Y) BoundingBoxMin.Y=DestinationLocation.Y;
			else if(DestinationLocation.Y>BoundingBoxMax.Y) BoundingBoxMax.Y=DestinationLocation.Y;

				 if(DestinationLocation.Z<BoundingBoxMin.Z) BoundingBoxMin.Z=DestinationLocation.Z;
			else if(DestinationLocation.Z>BoundingBoxMax.Z) BoundingBoxMax.Z=DestinationLocation.Z;
		}
	} else
	{
		for(INT i=0;i<ControlPointCount;i++)
		{
			if(ControlPoint[i].PositionActor)
				ControlPoint[i].Position=ControlPoint[i].PositionActor->Location;

			FVector DestinationLocation = ControlPoint[i].Position;

			
				 if(DestinationLocation.X<BoundingBoxMin.X) BoundingBoxMin.X=DestinationLocation.X;
			else if(DestinationLocation.X>BoundingBoxMax.X) BoundingBoxMax.X=DestinationLocation.X;

				 if(DestinationLocation.Y<BoundingBoxMin.Y) BoundingBoxMin.Y=DestinationLocation.Y;
			else if(DestinationLocation.Y>BoundingBoxMax.Y) BoundingBoxMax.Y=DestinationLocation.Y;

				 if(DestinationLocation.Z<BoundingBoxMin.Z) BoundingBoxMin.Z=DestinationLocation.Z;
			else if(DestinationLocation.Z>BoundingBoxMax.Z) BoundingBoxMax.Z=DestinationLocation.Z;

		}
	}

	b.Min=BoundingBoxMin;
	b.Max=BoundingBoxMax;
	return b;
}
