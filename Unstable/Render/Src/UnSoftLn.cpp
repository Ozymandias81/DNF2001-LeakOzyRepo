/*=============================================================================
	UnSoftLn.cpp: DukeForever software line drawing.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by Tim Sweeney
=============================================================================*/

#include "..\..\Engine\Src\EnginePrivate.h"

/*-----------------------------------------------------------------------------
	Projection.
-----------------------------------------------------------------------------*/

//
// Figure out the unclipped screen location of a 3D point taking into account either
// a perspective or orthogonal projection.  Returns 1 if view is orthogonal or point 
// is visible in 3D view, 0 if invisible in 3D view (behind the viewer).
//
// Scale = scale of one world unit (at this point) relative to screen pixels,
// for example 0.5 means one world unit is 0.5 pixels.
//
UBOOL __fastcall URender::Project( FSceneNode* Frame, const FVector& V, FLOAT& ScreenX, FLOAT& ScreenY, FLOAT* Scale )
{
	FVector	Temp = V - Frame->Coords.Origin;
	if( Frame->Viewport->Actor->RendMap == REN_OrthXY )
	{
		ScreenX = +Temp.X / Frame->Zoom + Frame->FX2;
		ScreenY = +Temp.Y / Frame->Zoom + Frame->FY2;
		if( Scale )
			*Scale = 1.0/Frame->Zoom;
		return 1;
	}
	else if( Frame->Viewport->Actor->RendMap==REN_OrthXZ )
	{
		ScreenX = +Temp.X / Frame->Zoom + Frame->FX2;
		ScreenY = -Temp.Z / Frame->Zoom + Frame->FY2;
		if( Scale )
			*Scale = 1.0/Frame->Zoom;
		return 1;
	}
	else if( Frame->Viewport->Actor->RendMap==REN_OrthYZ )
	{
		ScreenX = +Temp.Y / Frame->Zoom + Frame->FX2;
		ScreenY = -Temp.Z / Frame->Zoom + Frame->FY2;
		if( Scale )
			*Scale = 1.0/Frame->Zoom;
		return 1;
	}
	else
	{
		Temp     = Temp.TransformVectorBy( Frame->Coords );
		FLOAT Z  = Temp.Z; if (Abs (Z)<0.01) Z+=0.02;
		FLOAT RZ = Frame->Proj.Z / Z;
		ScreenX = Temp.X * RZ + Frame->FX2;
		ScreenY = Temp.Y * RZ + Frame->FY2;

		if( Scale  )
			*Scale = RZ;

		return Z > 0.1; // NJS: Used to be 1.0 
	}
}

//
// Convert a particular screen location to a world location.  In ortho views,
// sets non-visible component to zero.  In persp views, places at viewport location
// unless UseEdScan=1 and the user just clicked on a wall (a Bsp polygon).
// Sets V to location and returns 1, or returns 0 if couldn't perform conversion.
//
UBOOL __fastcall URender::Deproject( FSceneNode* Frame, INT ScreenX, INT ScreenY, FVector& V )
{

	FVector  Origin = Frame->Coords.Origin;
	FLOAT	 SX		= (FLOAT)ScreenX - Frame->FX2;
	FLOAT	 SY		= (FLOAT)ScreenY - Frame->FY2;

	switch( Frame->Viewport->Actor->RendMap )
	{
		case REN_OrthXY:
			V.X = +SX * Frame->Zoom + Origin.X;
			V.Y = +SY * Frame->Zoom + Origin.Y;
			V.Z = 0;
			return 1;
		case REN_OrthXZ:
			V.X = +SX * Frame->Zoom + Origin.X;
			V.Y = 0.0;
			V.Z = -SY * Frame->Zoom + Origin.Z;
			return 1;
		case REN_OrthYZ:
			V.X = 0.0;
			V.Y = +SX * Frame->Zoom + Origin.Y;
			V.Z = -SY * Frame->Zoom + Origin.Z;
			return 1;
		default:
			V = Origin;
			return 0;
	}
}

/*-----------------------------------------------------------------------------
	Cylinder drawing.
-----------------------------------------------------------------------------*/

//
// Draw an 8 sided cylinder.
//
void URender::DrawCylinder
(
	FSceneNode*		Frame,
	FPlane			Color,
	DWORD			LineFlags,
	FVector&		Location,
	FLOAT			Radius,
	FLOAT			Height
)
{
//	guard(URender::DrawCylinder);

	FVector Origin = FVector( Radius, 0, 0);
	FRotator StepRotation( 0, 8192, 0 );	// 8192 = 8 sides
	FVector Ext(Radius,Radius,Height), Min(Location - Ext), Max(Location + Ext);
	FLOAT NewHeight = Max.Z - Min.Z;

	FVector P1 = Origin.TransformVectorBy( GMath.UnitCoords * StepRotation) + Location, P2;
	URenderDevice *RenDev=Frame->Viewport->RenDev;

	for( int i=0; i<=8; i++ )
	{
		P2 = Origin.TransformVectorBy( GMath.UnitCoords * (StepRotation * (i+1))) + Location;
		RenDev->Queue3DLine( Frame, Color, LineFlags, P1 + FVector(0,0,-(NewHeight/2)), P2  + FVector(0,0,-(NewHeight/2)));
		RenDev->Queue3DLine( Frame, Color, LineFlags, P1 + FVector(0,0,NewHeight/2), P2  + FVector(0,0,NewHeight/2));
		RenDev->Queue3DLine( Frame, Color, LineFlags, P1 + FVector(0,0,NewHeight/2), P1  + FVector(0,0,-(NewHeight/2)));
		P1 = P2;
	}

	RenDev->Queued3DLinesFlush(Frame); 

//	unguard;
}

/*-----------------------------------------------------------------------------
	Circle drawing.
-----------------------------------------------------------------------------*/

//
// Draw a circle.
//
void URender::DrawCircle
(
	FSceneNode*		Frame,
	FPlane			Color,
	DWORD			LineFlags,
	FVector&		Location,
	FLOAT			Radius,
	UBOOL			bScaleRadiusByZoom
)
{
	const int MAX_SUBDIVIDE=64;//256;
	const float MAX_THRESH=1024; //2048;

	FVector A = Frame->Coords.XAxis;
	FVector B = Frame->Coords.YAxis;

	int Subdivide = 8;
	for(FLOAT Thresh = Frame->Viewport->Actor->OrthoZoom/Radius;	
		Subdivide<MAX_SUBDIVIDE && Thresh<MAX_THRESH;	
		Thresh*=2.f,Subdivide*=2 )
		;

	//debugf(_T("*** %i"),Subdivide);

	FLOAT   F  = 0.f;
	FLOAT   AngleDelta = (2.f*PI) / Subdivide;
	FLOAT	ScaledRadius = (bScaleRadiusByZoom ? (Radius * (Frame->Viewport->Actor->OrthoZoom / 10000.f)) : Radius);
	ScaledRadius = ::Max( ScaledRadius, Radius );	// Never go below the original value

	// Compute the first vertex:
	FVector P1 = Location + ScaledRadius * (A * appCos(F) + B * appSin(F));

	// Draw the circle, using Subdivide segments:
	URenderDevice *RenDev=Frame->Viewport->RenDev;
	for( int i=0; i<Subdivide; i++ )
	{
		F  += AngleDelta;
		FVector P2  = Location + ScaledRadius * (A * appCos(F) + B * appSin(F));
		RenDev->Queue3DLine( Frame, Color, LineFlags, P1, P2 );
		P1 = P2;
	}
}

/*-----------------------------------------------------------------------------
	Box drawing.
-----------------------------------------------------------------------------*/
//
// Draw a box centered about a location.
//
void URender::DrawBox
(
	FSceneNode*		Frame,
	FPlane			Color,
	DWORD			LineFlags,
	FVector			Min,
	FVector			Max
)
{

	FVector A,B;
	FVector Location = Min+Max;
	if	   ( Frame->Viewport->Actor->RendMap==REN_OrthXY )	{A=FVector(Max.X-Min.X,0,0); B=FVector(0,Max.Y-Min.Y,0);}
	else if( Frame->Viewport->Actor->RendMap==REN_OrthXZ )	{A=FVector(Max.X-Min.X,0,0); B=FVector(0,0,Max.Z-Min.Z);}
	else													{A=FVector(0,Max.Y-Min.Y,0); B=FVector(0,0,Max.Z-Min.Z);}

	URenderDevice *RenDev=Frame->Viewport->RenDev;

	RenDev->Queue3DLine( Frame, Color, LineFlags, (Location+A+B)/2, (Location+A-B)/2 );
	RenDev->Queue3DLine( Frame, Color, LineFlags, (Location-A+B)/2, (Location-A-B)/2 );
	RenDev->Queue3DLine( Frame, Color, LineFlags, (Location+A+B)/2, (Location-A+B)/2 );
	RenDev->Queue3DLine( Frame, Color, LineFlags, (Location+A-B)/2, (Location-A-B)/2 );
	RenDev->Queued3DLinesFlush(Frame); 

}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
