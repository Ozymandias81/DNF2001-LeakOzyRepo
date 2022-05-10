/*=============================================================================
	UnMath.cpp: Unreal math routines, implementation of FGlobalMath class
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by Tim Sweeney
=============================================================================*/

#include "..\..\Engine\Src\EnginePrivate.h"

/*-----------------------------------------------------------------------------
	FGlobalMath constructor.
-----------------------------------------------------------------------------*/

// Constructor.
FGlobalMath::FGlobalMath()
:	WorldMin			(-32700.0,-32700.0,-32700.0),
	WorldMax			(32700.0,32700.0,32700.0),
	UnitCoords			(FVector(0,0,0),FVector(1,0,0),FVector(0,1,0),FVector(0,0,1)),
	ViewCoords			(FVector(0,0,0),FVector(0,1,0),FVector(0,0,-1),FVector(1,0,0)),
	UnitScale			(FVector(1,1,1),0.0,SHEER_ZX)
{
	// Init base angle table.
	{for( INT i=0; i<NUM_ANGLES; i++ )
		TrigFLOAT[i] = appSin((FLOAT)i * 2.0 * PI / (FLOAT)NUM_ANGLES);}

	// Init square root table.
	{for( INT i=0; i<NUM_SQRTS; i++ )
		SqrtFLOAT[i] = appSqrt((FLOAT)i / 16384.0);}
}

/*-----------------------------------------------------------------------------
	Conversion functions.
-----------------------------------------------------------------------------*/

// Return the FRotator corresponding to the direction that the vector
// is pointing in.  Sets Yaw and Pitch to the proper numbers, and sets
// roll to zero because the roll can't be determined from a vector.
FRotator FVector::Rotation()
{
	FRotator R;

	// Find yaw.
	R.Yaw = (INT)(appAtan2(Y,X) * (FLOAT)MAXWORD / (2.f*PI));

	// Find pitch.
	R.Pitch = (INT)(appAtan2(Z,appSqrt(X*X+Y*Y)) * (FLOAT)MAXWORD / (2.f*PI));

	// Find roll.
	R.Roll = 0;

	return R;
}

//
// Find good arbitrary axis vectors to represent U and V axes of a plane
// given just the normal.
//
void FVector::FindBestAxisVectors( FVector& Axis1, FVector& Axis2 )
{

	FLOAT NX = Abs(X);
	FLOAT NY = Abs(Y);
	FLOAT NZ = Abs(Z);

	// Find best basis vectors.
	if( NZ>NX && NZ>NY )	Axis1 = FVector(1,0,0);
	else					Axis1 = FVector(0,0,1);

	Axis1 = (Axis1 - *this * (Axis1 | *this)).SafeNormal();
	Axis2 = Axis1 ^ *this;

}

// NJS: Note Roll will always be zero when converting a vector to Euler's
void FVector::AngleVectors( FVector &forward, FVector &left, FVector &up )
{
	FRotator Rot=Rotation();
	Rot.AngleVectors(forward,left,up);
}

/*-----------------------------------------------------------------------------
	Matrix inversion.
-----------------------------------------------------------------------------*/

//
// Coordinate system inverse.
//
FCoords FCoords::Inverse() const
{
	FLOAT Div = FTriple( XAxis, YAxis, ZAxis );
	if( !Div ) Div = 1.f;

	FLOAT RDet = 1.f / Div;
	return FCoords
	(	-Origin.TransformVectorBy(*this)
	,	RDet * FVector
		(	(YAxis.Y * ZAxis.Z - YAxis.Z * ZAxis.Y)
		,	(ZAxis.Y * XAxis.Z - ZAxis.Z * XAxis.Y)
		,	(XAxis.Y * YAxis.Z - XAxis.Z * YAxis.Y) )
	,	RDet * FVector
		(	(YAxis.Z * ZAxis.X - ZAxis.Z * YAxis.X)
		,	(ZAxis.Z * XAxis.X - XAxis.Z * ZAxis.X)
		,	(XAxis.Z * YAxis.X - XAxis.X * YAxis.Z))
	,	RDet * FVector
		(	(YAxis.X * ZAxis.Y - YAxis.Y * ZAxis.X)
		,	(ZAxis.X * XAxis.Y - ZAxis.Y * XAxis.X)
		,	(XAxis.X * YAxis.Y - XAxis.Y * YAxis.X) )
	);
}

//
// Convert this orthogonal coordinate system to a rotation.
//
FRotator FCoords::OrthoRotation() const
{
	FRotator R
	(
		(INT)(appAtan2( XAxis.Z, appSqrt(Square(XAxis.X)+Square(XAxis.Y)) ) * 32768.0 / PI),
		(INT)(appAtan2( XAxis.Y, XAxis.X                                  ) * 32768.0 / PI),
		0
	);
	FCoords S = GMath.UnitCoords / R;
	R.Roll = (INT)(appAtan2( ZAxis | S.YAxis, YAxis | S.YAxis ) * 32768.0 / PI);
	return R;
}

/*-----------------------------------------------------------------------------
	FSphere implementation.
-----------------------------------------------------------------------------*/

//
// Compute a bounding sphere from an array of points.
//
FSphere::FSphere( const FVector* Pts, INT Count )
: FPlane(0,0,0,0)
{
	if( Count )
	{
		FBox Box( Pts, Count );
		*this = FSphere( (Box.Min+Box.Max)/2, 0 );
		for( INT i=0; i<Count; i++ )
		{
			FLOAT Dist = FDistSquared(Pts[i],*this);
			if( Dist > W )
				W = Dist;
		}
		W = appSqrt(W) * 1.001;
	}
}

/*-----------------------------------------------------------------------------
	FBox implementation.
-----------------------------------------------------------------------------*/

FBox::FBox( const FVector* Points, INT Count )
: Min(0,0,0), Max(0,0,0), IsValid(0)
{
	for( INT i=0; i<Count; i++ )
		*this += Points[i];
}


// SafeNormal
FVector FVector::SafeNormal() const
{
	FLOAT SquareSum = X*X + Y*Y + Z*Z;
	if( SquareSum < SMALL_NUMBER )
		return FVector( 0.f, 0.f, 0.f );

	FLOAT Size = appSqrt(SquareSum); 
	FLOAT Scale = 1.f/Size;
	return FVector( X*Scale, Y*Scale, Z*Scale );
}

UBOOL Cylinder::Inside( FVector p )
{
    // Distance is positive if the point is within the cylinder
    if ( Distance( p ) >= 0.0 )
        return true;
    else
        return false;
}

FLOAT Cylinder::Distance( FVector p )
{
    // Check to see if it's within the radius, then check to see if it's within the height
    FVector delta = p - m_Origin;
    FLOAT   dAxis = delta | m_Axis;
    FLOAT   r     = sqrt( delta.SizeSquared() + dAxis*dAxis );
    return  m_Radius - r;
}

UBOOL Cylinder::ClipObj
    (
    FVector&  	rayBase,	/* Base of the intersection ray */
	FVector&	rayDir,  	/* Direction of the ray     */
	FPlane&		bot,		/* Bottom end-cap plane		*/
	FPlane&		top,		/* Top end-cap plane		*/
	FLOAT&      objin,		/* Entering distance		*/
	FLOAT&		objout	    /* Exiting  distance		*/
    )

{
	FLOAT	dc, dw, t;
	FLOAT	in, out;		/* Object  intersection dists.	*/

	in  = objin;
	out = objout;

    /*	Intersect the ray with the bottom end-cap plane.		*/
    dc = ( bot | rayDir );
	dw = ( bot | rayBase ) + bot.W;

	if  ( dc == 0.0 ) {		/* If parallel to bottom plane	*/
	    if	( dw >= 0. ) return (false);
	} else {
	    t  = - dw / dc;

        debugf( TEXT( "t = %f" ), t );

        FVector IntersectionPoint = rayBase + t * rayDir;

	    if	( dc >= 0.0 ) {			    /* If far plane	*/
		if  ( t > in && t < out ) { out = t; }
		if  ( t < in  ) return (false);
	     } else {				    /* If near plane	*/
		if  ( t > in && t < out ) { in	= t; }
		if  ( t > out ) return (false);
	    }
	}

    /*	Intersect the ray with the top end-cap plane.			*/

	dc = top.X*rayDir.X  + top.Y*rayDir.Y  + top.Z*rayDir.Z;
	dw = top.X*rayBase.X + top.Y*rayBase.Y + top.Z*rayBase.Z + top.W;

	if  ( dc == 0.0 ) {		/* If parallel to top plane	*/
	    if	( dw >= 0. ) return (false);
	} else {
	    t  = - dw / dc;
	    if	( dc >= 0.0 ) {			    /* If far plane	*/
		if  ( t > in && t < out ) { out = t; }
		if  ( t < in  ) return (false);
	     } else {				    /* If near plane	*/
		if  ( t > in && t < out ) { in	= t; }
		if  ( t > out ) return (false);
	    }
	}
    objin  = in;
    objout = out;
	return (in < out);    
}

UBOOL Cylinder::Intersect
    (
    FVector rayOrigin,
    FVector rayDir,
    FLOAT   *in_distance,
    FLOAT   *out_distance
    )

{
    UBOOL   hit; // True if ray intersect cylinder
    FVector RC;  // RayOrigin to Cylinder Base
    FLOAT   d;   // Shortest distance between ray and the cylinder
    FLOAT   t,s; // Distances along the ray
    FLOAT   in,out;
    FVector n,D,O;
    FLOAT   ln;
    //const double pinf = HUGE;

    RC = rayOrigin - m_Origin;
    n  = rayDir ^ m_Axis;     // Cross Product
    ln = n.Size();

    if ( ln == 0 ) // Ray is parallel to cylinder
    {
        d = RC | m_Axis;
        D = RC - ( d * m_Axis );
        d = D.Size();
        in  = -1.0e21; //INF
        out = 1.0e21;  //INF
        return ( d <= m_Radius ); // True if ray is in cylinder 
    }

    n.Normalize();
    d   = fabs( RC | n );
    hit = ( d <= m_Radius );

    if ( !hit )
        return false;

    if ( hit )
    {
        O   = RC ^ m_Axis;
        t   = - O | n / ln;
        O   = n ^ m_Axis;
        O.Normalize();
        s   = fabs( sqrt( m_Radius*m_Radius - d*d ) / ( rayDir | O ) );
	    in	= t - s;			/* entering distance	*/
	    out = t + s;			/* exiting  distance	*/

        FVector InHitPoint   = rayOrigin + in * rayDir;
        FVector OutHitPoint  = rayOrigin + out * rayDir;

        FVector topPoint = m_Origin;
        FVector bottomPoint = m_Origin + m_Axis * m_Height;

        FPlane top = FPlane( topPoint,    -m_Axis );
        FPlane bot = FPlane( bottomPoint, m_Axis );

        FLOAT pd_Top = top.PlaneDot( InHitPoint );
        FLOAT pd_Bot = bot.PlaneDot( InHitPoint );
        
        if ( in_distance )
            *in_distance = in;
        if ( out_distance )
            *out_distance = out;

        if ( ( pd_Top < 0 ) && ( pd_Bot < 0 ) )
            return true;
    }

    return false;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
