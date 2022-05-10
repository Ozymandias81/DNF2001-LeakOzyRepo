/*=============================================================================
	UnEdCnst.cpp: Editor movement contraints.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.
=============================================================================*/

#include "EditorPrivate.h"

/*------------------------------------------------------------------------------
	Functions.
------------------------------------------------------------------------------*/

void FEditorConstraints::Snap( FVector& Point, FVector GridBase )
{
	if( GridEnabled )
		Point = (Point - GridBase).GridSnap( GridSize ) + GridBase;
}
void FEditorConstraints::Snap( FRotator& Rotation )
{
	if( RotGridEnabled )
		Rotation = Rotation.GridSnap( RotGridSize );
}
UBOOL FEditorConstraints::Snap( ULevel* Level, FVector& Location, FVector GridBase, FRotator& Rotation )
{
	UBOOL Snapped = 0;
	Snap( Rotation );
	if( Level && SnapVertices )
	{
		FVector	DestPoint;
		INT Temp;
		if( Level->Model->FindNearestVertex( Location, DestPoint, SnapDistance, Temp ) >= 0.0)
		{
			Location = DestPoint;
			Snapped = 1;
		}
	}
	if( !Snapped )
		Snap( Location, GridBase );
	return Snapped;
}

/*------------------------------------------------------------------------------
	The end.
------------------------------------------------------------------------------*/
