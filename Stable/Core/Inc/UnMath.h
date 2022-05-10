/*=============================================================================
	UnMath.h: Unreal math routines
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by Tim Sweeney
=============================================================================*/

/*-----------------------------------------------------------------------------
	Defintions.
-----------------------------------------------------------------------------*/

// Forward declarations.
class  FVector;
class  FPlane;
class  FCoords;
class  FRotator;
class  FScale;
class  FGlobalMath;
class  FMatrix;

// Fixed point conversion.
__forceinline INT Fix  (INT A)		{ return A<<16; };
__forceinline INT Fix  (FLOAT A)	{ return (INT)(A*65536.f); };
//__forceinline INT Unfix(INT A)		{ return A>>16; };
#define Unfix(A)	((A)>>16)

// Constants.
#undef  PI
#define PI 					(3.1415926535897932)
#define FLOAT_PI			(3.1415926535897932f)
#define SMALL_NUMBER		(1.e-8)
#define KINDA_SMALL_NUMBER	(1.e-4)

// Aux constants.
#define INV_PI			(0.31830988618)
#define HALF_PI			(1.57079632679)

// Magic numbers for numerical precision.
#define DELTA			(0.00001f)
#define SLERP_DELTA		(0.0001f)

/*-----------------------------------------------------------------------------
	Global functions.
-----------------------------------------------------------------------------*/

//
// Snap a value to the nearest grid multiple.
//
__forceinline FLOAT FSnap( FLOAT Location, FLOAT Grid )
{
	if( Grid==0.f )	return Location;
	else			return appFloor((Location + 0.5f*Grid)/Grid)*Grid;
}

//
// Internal sheer adjusting function so it snaps nicely at 0 and 45 degrees.
//
__forceinline FLOAT FSheerSnap (FLOAT Sheer)
{
	if		(Sheer < -0.65f)	return Sheer + 0.15f;
	else if (Sheer > +0.65f)	return Sheer - 0.15f;
	else if (Sheer < -0.55f)	return -0.50f;
	else if (Sheer > +0.55f)	return 0.50f;
	else if (Sheer < -0.05f)	return Sheer + 0.05f;
	else if (Sheer > +0.05f)	return Sheer - 0.05f;
	else						return 0.f;
}

//
// Find the closest power of 2 that is >= N.
//
inline DWORD FNextPowerOfTwo( DWORD N )
{
	if (N<=0L	 ) return 0L;
	if (N<=1L	 ) return 1L;
	if (N<=2L	 ) return 2L;
	if (N<=4L	 ) return 4L;
	if (N<=8L	 ) return 8L;
	if (N<=16L	 ) return 16L;
	if (N<=32L	 ) return 32L;
	if (N<=64L 	 ) return 64L;
	if (N<=128L  ) return 128L;
	if (N<=256L  ) return 256L;
	if (N<=512L  ) return 512L;
	if (N<=1024L ) return 1024L;
	if (N<=2048L ) return 2048L;
	if (N<=4096L ) return 4096L;
	if (N<=8192L ) return 8192L;
	if (N<=16384L) return 16384L;
	if (N<=32768L) return 32768L;
	if (N<=65536L) return 65536L;
	else		   return 0;
}

//
// Add to a word angle, constraining it within a min (not to cross)
// and a max (not to cross).  Accounts for funkyness of word angles.
// Assumes that angle is initially in the desired range.
//
inline _WORD __fastcall FAddAngleConfined( INT Angle, INT Delta, INT MinThresh, INT MaxThresh )
{
	if( Delta < 0 )
	{
		if ( Delta<=-0x10000L || Delta<=-(INT)((_WORD)(Angle-MinThresh)))
			return MinThresh;
	}
	else if( Delta > 0 )
	{
		if( Delta>=0x10000L || Delta>=(INT)((_WORD)(MaxThresh-Angle)))
			return MaxThresh;
	}
	return (_WORD)(Angle+Delta);
}

//
// Eliminate all fractional precision from an angle.
//
INT ReduceAngle( INT Angle );

//
// Fast 32-bit float evaluations. 
// Warning: likely not portable, and useful on Pentium class processors only.
//

__forceinline UBOOL IsSmallerPositiveFloat(float F1,float F2)
{
	return ( (*(DWORD*)&F1) < (*(DWORD*)&F2));
}

__forceinline FLOAT MinPositiveFloat(float F1, float F2)
{
	if ( (*(DWORD*)&F1) < (*(DWORD*)&F2)) return F1; else return F2;
}

//
// Warning: 0 and -0 have different binary representations.
//

__forceinline UBOOL EqualPositiveFloat(float F1, float F2)
{
	return ( *(DWORD*)&F1 == *(DWORD*)&F2 );
}

__forceinline UBOOL IsNegativeFloat(float F1)
{
	return ( (*(DWORD*)&F1) >= (DWORD)0x80000000 ); // Detects sign bit.
}

__forceinline FLOAT MaxPositiveFloat(float F1, float F2)
{
	if ( (*(DWORD*)&F1) < (*(DWORD*)&F2)) return F2; else return F1;
}

// Clamp F0 between F1 and F2, all positive assumed.
__forceinline FLOAT ClampPositiveFloat(float F0, float F1, float F2)
{
	if      ( (*(DWORD*)&F0) < (*(DWORD*)&F1)) return F1;
	else if ( (*(DWORD*)&F0) > (*(DWORD*)&F2)) return F2;
	else return F0;
}

// Clamp any float F0 between zero and positive float Range
#define ClipFloatFromZero(F0,Range)\
{\
	if ( (*(DWORD*)&F0) >= (DWORD)0x80000000) F0 = 0.f;\
	else if	( (*(DWORD*)&F0) > (*(DWORD*)&Range)) F0 = Range;\
}

/*-----------------------------------------------------------------------------
	FVector.
-----------------------------------------------------------------------------*/

// Information associated with a floating point vector, describing its
// status as a point in a rendering context.
enum EVectorFlags
{
	FVF_OutXMin		= 0x04,	// Outcode rejection, off left hand side of screen.
	FVF_OutXMax		= 0x08,	// Outcode rejection, off right hand side of screen.
	FVF_OutYMin		= 0x10,	// Outcode rejection, off top of screen.
	FVF_OutYMax		= 0x20,	// Outcode rejection, off bottom of screen.
	FVF_OutNear     = 0x40, // Near clipping plane.
	FVF_OutFar      = 0x80, // Far clipping plane.
	FVF_OutReject   = (FVF_OutXMin | FVF_OutXMax | FVF_OutYMin | FVF_OutYMax), // Outcode rejectable.
	FVF_OutSkip		= (FVF_OutXMin | FVF_OutXMax | FVF_OutYMin | FVF_OutYMax), // Outcode clippable.
};

//
// Floating point vector.
//

// I added these because remembering which symbol does what is confusing.
// So instead of writing "v1^v2" you can write "v1 cross v2" if you want to.
// - Warren
//
#define dot |
#define cross ^

class CORE_API FVector 
{
public:
	// Variables.
	FLOAT X,Y,Z;

	// Constructors.
	FVector()
	{}
	FVector( FLOAT InX, FLOAT InY, FLOAT InZ )
	:	X(InX), Y(InY), Z(InZ)
	{}

	// Binary math operators.
	__forceinline FVector operator^( const FVector& V ) const
	{
		return FVector
		(
			Y * V.Z - Z * V.Y,
			Z * V.X - X * V.Z,
			X * V.Y - Y * V.X
		);
	}
	__forceinline FLOAT operator|( const FVector& V ) const
	{
		return X*V.X + Y*V.Y + Z*V.Z;
	}
	friend FVector operator*( FLOAT Scale, const FVector& V )
	{
		return FVector( V.X * Scale, V.Y * Scale, V.Z * Scale );
	}
	__forceinline FVector operator+( const FVector& V ) const
	{
		return FVector( X + V.X, Y + V.Y, Z + V.Z );
	}
	__forceinline FVector operator-( const FVector& V ) const
	{
		return FVector( X - V.X, Y - V.Y, Z - V.Z );
	}
	__forceinline FVector operator*( FLOAT Scale ) const
	{
		return FVector( X * Scale, Y * Scale, Z * Scale );
	}
	__forceinline FVector operator/( FLOAT Scale ) const
	{
		FLOAT RScale = 1.f/Scale;
		return FVector( X * RScale, Y * RScale, Z * RScale );
	}
	__forceinline FVector operator*( const FVector& V ) const
	{
		return FVector( X * V.X, Y * V.Y, Z * V.Z );
	}

	// Binary comparison operators.
	__forceinline UBOOL operator==( const FVector& V ) const
	{
		return X==V.X && Y==V.Y && Z==V.Z;
	}
	__forceinline UBOOL operator!=( const FVector& V ) const
	{
		return X!=V.X || Y!=V.Y || Z!=V.Z;
	}

	// Unary operators.
	__forceinline FVector operator-() const
	{
		return FVector( -X, -Y, -Z );
	}

	// Assignment operators.
	__forceinline FVector operator+=( const FVector& V )
	{
		X += V.X; Y += V.Y; Z += V.Z;
		return *this;
	}
	__forceinline FVector operator-=( const FVector& V )
	{
		X -= V.X; Y -= V.Y; Z -= V.Z;
		return *this;
	}
	__forceinline FVector operator*=( FLOAT Scale )
	{
		X *= Scale; Y *= Scale; Z *= Scale;
		return *this;
	}
	__forceinline FVector operator/=( FLOAT V )
	{
		FLOAT RV = 1.f/V;
		X *= RV; Y *= RV; Z *= RV;
		return *this;
	}
	__forceinline FVector operator*=( const FVector& V )
	{
		X *= V.X; Y *= V.Y; Z *= V.Z;
		return *this;
	}
	__forceinline FVector operator/=( const FVector& V )
	{
		X /= V.X; Y /= V.Y; Z /= V.Z;
		return *this;
	}
    FLOAT& operator[]( INT i )
	{
		check(i>-1);
		check(i<3);
		if( i == 0 )		return X;
		else if( i == 1)	return Y;
		else				return Z;
	}

	// Simple functions.
	FLOAT Size() const
	{
		return appSqrt( X*X + Y*Y + Z*Z );
	}
	__forceinline FLOAT SizeSquared() const
	{
		return X*X + Y*Y + Z*Z;
	}
	__forceinline FLOAT Size2D() const 
	{
		return appSqrt( X*X + Y*Y );
	}
	__forceinline FLOAT SizeSquared2D() const 
	{
		return X*X + Y*Y;
	}
	__forceinline int IsNearlyZero() const
	{
		return
				Abs(X)<KINDA_SMALL_NUMBER
			&&	Abs(Y)<KINDA_SMALL_NUMBER
			&&	Abs(Z)<KINDA_SMALL_NUMBER;
	}
	__forceinline UBOOL IsZero() const
	{
		return X==0.f && Y==0.f && Z==0.f;
	}
	__forceinline UBOOL Normalize()
	{
		FLOAT SquareSum = X*X+Y*Y+Z*Z;
		if( SquareSum >= SMALL_NUMBER )
		{
			FLOAT Scale = 1.f/appSqrt(SquareSum);
			X *= Scale; Y *= Scale; Z *= Scale;
			return 1;
		}
		else return 0;
	}
	__forceinline FVector Projection() const
	{
		FLOAT RZ = 1.f/Z;
		return FVector( X*RZ, Y*RZ, 1 );
	}
	__forceinline FVector UnsafeNormal() const
	{
		FLOAT Scale = 1.f/appSqrt(X*X+Y*Y+Z*Z);
		return FVector( X*Scale, Y*Scale, Z*Scale );
	}
	__forceinline FVector GridSnap( const FVector& Grid )
	{
		return FVector( FSnap(X, Grid.X),FSnap(Y, Grid.Y),FSnap(Z, Grid.Z) );
	}
	__forceinline FVector BoundToCube( FLOAT Radius )
	{
		return FVector
		(
			Clamp(X,-Radius,Radius),
			Clamp(Y,-Radius,Radius),
			Clamp(Z,-Radius,Radius)
		);
	}
	__forceinline void AddBounded( const FVector& V, FLOAT Radius=MAXSWORD )
	{
		*this = (*this + V).BoundToCube(Radius);
	}
	__forceinline FLOAT& Component( INT Index )
	{
		return (&X)[Index];
	}

	// Return a boolean that is based on the vector's direction.
	// When      V==(0.0.0) Booleanize(0)=1.
	// Otherwise Booleanize(V) <-> !Booleanize(!B).
	__forceinline UBOOL Booleanize()
	{
		return
			X >  0.f ? 1 :
			X <  0.f ? 0 :
			Y >  0.f ? 1 :
			Y <  0.f ? 0 :
			Z >= 0.f ? 1 : 0;
	}

	// Transformation.
	FVector TransformVectorBy( const FCoords& Coords ) const;
	FVector TransformPointBy( const FCoords& Coords ) const;
	FVector MirrorByVector( const FVector& MirrorNormal ) const;
	FVector MirrorByPlane( const FPlane& MirrorPlane ) const;

	// Complicated functions.
	FRotator Rotation();
	void FindBestAxisVectors( FVector& Axis1, FVector& Axis2 );
	FVector SafeNormal() const; //warning: Not inline because of compiler bug.

	// Friends.
	friend FLOAT FDist( const FVector& V1, const FVector& V2 );
	friend FLOAT FDistSquared( const FVector& V1, const FVector& V2 );
	friend UBOOL FPointsAreSame( const FVector& P, const FVector& Q );
	friend UBOOL FPointsAreNear( const FVector& Point1, const FVector& Point2, FLOAT Dist);
	friend FLOAT FPointPlaneDist( const FVector& Point, const FVector& PlaneBase, const FVector& PlaneNormal );
	friend FVector FLinePlaneIntersection( const FVector& Point1, const FVector& Point2, const FVector& PlaneOrigin, const FVector& PlaneNormal );
	friend FVector FLinePlaneIntersection( const FVector& Point1, const FVector& Point2, const FPlane& Plane );
	friend UBOOL FParallel( const FVector& Normal1, const FVector& Normal2 );
	friend UBOOL FCoplanar( const FVector& Base1, const FVector& Normal1, const FVector& Base2, const FVector& Normal2 );

	// Serializer.
	friend FArchive& operator<<( FArchive& Ar, FVector& V )
	{
		return Ar << V.X << V.Y << V.Z;
	}

    void AngleVectors( FVector &forward, FVector &left, FVector &up );

#if DNF
	// CDH: Additional functions and operators for notational convenience

	// transform by coordinate frame
	FVector& operator >>= (const FCoords& inC); // in to
	FVector operator >> (const FCoords& inC) const;
	FVector& operator <<= (const FCoords& inC); // out of
	FVector operator << (const FCoords& inC) const;

	// Unreal<->Standard coordinate frame conversions
	//      Unreal form: X back, Y left, Z up
	//      Standard form: X right, Y up, Z back	
	FVector ToStd() const { return(FVector(-Y, Z, X)); } // Unreal->Standard
	FVector ToUnr() const { return(FVector(Z, -X, Y)); } // Standard->Unreal

#endif // #if DNF
};

// NJS: Rotate a point or vector about an axis.
inline FVector RotateAboutAxis(FVector &p,FLOAT theta,FVector &r)
{
   FVector q(0,0,0);

   r.Normalize();
   float costheta = cos(theta);
   float sintheta = sin(theta);

   q.X += (costheta + (1 - costheta) * r.X * r.X) * p.X;
   q.X += ((1 - costheta) * r.X * r.Y - r.Z * sintheta) * p.Y;
   q.X += ((1 - costheta) * r.X * r.Z + r.Y * sintheta) * p.Z;

   q.Y += ((1 - costheta) * r.X * r.Y + r.Z * sintheta) * p.X;
   q.Y += (costheta + (1 - costheta) * r.Y * r.Y) * p.Y;
   q.Y += ((1 - costheta) * r.Y * r.Z - r.X * sintheta) * p.Z;

   q.Z += ((1 - costheta) * r.X * r.Z - r.Y * sintheta) * p.X;
   q.Z += ((1 - costheta) * r.Y * r.Z + r.X * sintheta) * p.Y;
   q.Z += (costheta + (1 - costheta) * r.Z * r.Z) * p.Z;

   return(q);
}

class CORE_API FVectorDouble 
{
public:
	// Variables.
	DOUBLE X,Y,Z;

	// Constructors.
	FVectorDouble() {}
	FVectorDouble( DOUBLE InX, DOUBLE InY, DOUBLE InZ )
	:	X(InX), Y(InY), Z(InZ)
	{}

	// Binary math operators.
	__forceinline FVectorDouble operator^( const FVectorDouble& V ) const
	{
		return FVectorDouble
		(
			Y * V.Z - Z * V.Y,
			Z * V.X - X * V.Z,
			X * V.Y - Y * V.X
		);
	}
	__forceinline FLOAT operator|( const FVectorDouble& V ) const
	{
		return X*V.X + Y*V.Y + Z*V.Z;
	}
	friend FVectorDouble operator*( DOUBLE Scale, const FVectorDouble& V )
	{
		return FVectorDouble( V.X * Scale, V.Y * Scale, V.Z * Scale );
	}
	__forceinline FVectorDouble operator+( const FVectorDouble& V ) const
	{
		return FVectorDouble( X + V.X, Y + V.Y, Z + V.Z );
	}
	__forceinline FVectorDouble operator-( const FVectorDouble& V ) const
	{
		return FVectorDouble( X - V.X, Y - V.Y, Z - V.Z );
	}
	__forceinline FVectorDouble operator*( DOUBLE Scale ) const
	{
		return FVectorDouble( X * Scale, Y * Scale, Z * Scale );
	}
	__forceinline FVectorDouble operator/( DOUBLE Scale ) const
	{
		
		DOUBLE RScale = 1.0/Scale;
		return FVectorDouble( X * RScale, Y * RScale, Z * RScale );
	}
	__forceinline FVectorDouble operator*( const FVectorDouble& V ) const
	{
		return FVectorDouble( X * V.X, Y * V.Y, Z * V.Z );
	}

	// Binary comparison operators.
	__forceinline UBOOL operator==( const FVectorDouble& V ) const
	{
		return X==V.X && Y==V.Y && Z==V.Z;
	}
	__forceinline UBOOL operator!=( const FVectorDouble& V ) const
	{
		return X!=V.X || Y!=V.Y || Z!=V.Z;
	}

	// Unary operators.
	__forceinline FVectorDouble operator-() const
	{
		return FVectorDouble( -X, -Y, -Z );
	}

	// Assignment operators.
	__forceinline FVectorDouble operator+=( const FVectorDouble& V )
	{
		X += V.X; Y += V.Y; Z += V.Z;
		return *this;
	}
	__forceinline FVectorDouble operator-=( const FVectorDouble& V )
	{
		X -= V.X; Y -= V.Y; Z -= V.Z;
		return *this;
	}
	__forceinline FVectorDouble operator*=( DOUBLE Scale )
	{
		X *= Scale; Y *= Scale; Z *= Scale;
		return *this;
	}
	__forceinline FVectorDouble operator/=( DOUBLE V )
	{
		DOUBLE RV = 1.0/V;
		X *= RV; Y *= RV; Z *= RV;
		return *this;
	}
	__forceinline FVectorDouble operator*=( const FVectorDouble& V )
	{
		X *= V.X; Y *= V.Y; Z *= V.Z;
		return *this;
	}
	__forceinline FVectorDouble operator/=( const FVectorDouble& V )
	{
		X /= V.X; Y /= V.Y; Z /= V.Z;
		return *this;
	}
    DOUBLE& operator[]( INT i )
	{
		check(i>-1);
		check(i<3);
		if( i == 0 )		return X;
		else if( i == 1)	return Y;
		else				return Z;
	}

	// Simple functions.
	DOUBLE Size() const
	{
		return appSqrt( X*X + Y*Y + Z*Z );
	}
	__forceinline DOUBLE SizeSquared() const
	{
		return X*X + Y*Y + Z*Z;
	}
	__forceinline DOUBLE Size2D() const 
	{
		return appSqrt( X*X + Y*Y );
	}
	__forceinline DOUBLE SizeSquared2D() const 
	{
		return X*X + Y*Y;
	}
	__forceinline int IsNearlyZero() const
	{
		return
				Abs(X)<KINDA_SMALL_NUMBER
			&&	Abs(Y)<KINDA_SMALL_NUMBER
			&&	Abs(Z)<KINDA_SMALL_NUMBER;
	}
	__forceinline UBOOL IsZero() const
	{
		return X==0.f && Y==0.f && Z==0.f;
	}
	__forceinline UBOOL Normalize()
	{
		DOUBLE SquareSum = X*X+Y*Y+Z*Z;
		if( SquareSum >= SMALL_NUMBER )
		{
			FLOAT Scale = 1.0/appSqrt(SquareSum);
			X *= Scale; Y *= Scale; Z *= Scale;
			return 1;
		}
		else return 0;
	}
	__forceinline FVectorDouble Projection() const
	{
		DOUBLE RZ = 1.0/Z;
		return FVectorDouble( X*RZ, Y*RZ, 1 );
	}
	__forceinline FVectorDouble UnsafeNormal() const
	{
		DOUBLE Scale = 1.0/appSqrt(X*X+Y*Y+Z*Z);
		return FVectorDouble( X*Scale, Y*Scale, Z*Scale );
	}
	__forceinline FVectorDouble GridSnap( const FVectorDouble& Grid )
	{
		return FVectorDouble( FSnap(X, Grid.X),FSnap(Y, Grid.Y),FSnap(Z, Grid.Z) );
	}
	__forceinline FVectorDouble BoundToCube( DOUBLE Radius )
	{
		return FVectorDouble
		(
			Clamp(X,-Radius,Radius),
			Clamp(Y,-Radius,Radius),
			Clamp(Z,-Radius,Radius)
		);
	}
	__forceinline void AddBounded( const FVectorDouble& V, DOUBLE Radius=MAXSWORD )
	{
		*this = (*this + V).BoundToCube(Radius);
	}
	__forceinline DOUBLE& Component( INT Index )
	{
		return (&X)[Index];
	}

	// Return a boolean that is based on the vector's direction.
	// When      V==(0.0.0) Booleanize(0)=1.
	// Otherwise Booleanize(V) <-> !Booleanize(!B).
	__forceinline UBOOL Booleanize()
	{
		return
			X >  0.f ? 1 :
			X <  0.f ? 0 :
			Y >  0.f ? 1 :
			Y <  0.f ? 0 :
			Z >= 0.f ? 1 : 0;
	}

	// Serializer.
	friend FArchive& operator<<( FArchive& Ar, FVectorDouble& V )
	{
		return Ar << V.X << V.Y << V.Z;
	}

	// Unreal<->Standard coordinate frame conversions
	//      Unreal form: X back, Y left, Z up
	//      Standard form: X right, Y up, Z back	
	FVectorDouble ToStd() const { return(FVectorDouble(-Y, Z, X)); } // Unreal->Standard
	FVectorDouble ToUnr() const { return(FVectorDouble(Z, -X, Y)); } // Standard->Unreal
};

#if DNF
/*
	FQuat (CDH)
*/
class CORE_API FQuat
{
public:
	FVector V;
	FLOAT S;

	FQuat() {}
	FQuat(const FQuat& inQ) : V(inQ.V), S(inQ.S) {}
	FQuat(const FVector& inV, FLOAT inS) : V(inV), S(inS) {}
	
	FQuat(const FCoords& inC); // only uses axes of coords, ignores origin
	
	inline void AxisAngle(const FVector& inAxis, FLOAT inAngle) // named constructor
	{
		V = -inAxis;
		V.Normalize();
		V *= (FLOAT)appSin(inAngle*.5f);
		S = (FLOAT)appCos(inAngle*.5f);
	}

	FQuat& operator = (const FQuat& inQ) { V = inQ.V; S = inQ.S; return(*this); }
	FQuat& operator += (const FQuat& inQ) { V += inQ.V; S += inQ.S; return(*this); }
	FQuat& operator -= (const FQuat& inQ) { V -= inQ.V; S -= inQ.S; return(*this); }
	FQuat& operator *= (const FQuat& inQ) { *this = *this * inQ; return(*this); }
	FQuat& operator *= (FLOAT inScale) { V *= inScale; S *= inScale; return(*this); }
	FQuat& operator /= (FLOAT inScale) { V /= inScale; S /= inScale; return(*this); }

	inline FLOAT SizeSquared() const { return(V.X*V.X + V.Y*V.Y + V.Z*V.Z + S*S); }
	inline FLOAT Size() const { return(appSqrt(SizeSquared())); }
	inline FLOAT Normalize() { FLOAT A(Size()); FLOAT B(1.f/A); V *= B; S *= B; return(A); }

	void Slerp(const FQuat& inQ1, const FQuat& inQ2, FLOAT inAlpha1, FLOAT inAlpha2, UBOOL bLerpOnly);

	inline FQuat operator - () const { return(FQuat(-V, -S)); }
	inline FQuat operator + (const FQuat& inQ) const { return(FQuat(V+inQ.V, S+inQ.S)); }
	inline FQuat operator - (const FQuat& inQ) const { return(FQuat(V-inQ.V, S-inQ.S)); }
	inline FQuat operator * (const FQuat& inQ) const { return(FQuat(inQ.V*S + V*inQ.S + (V^inQ.V), S*inQ.S - (V|inQ.V))); }
	inline FQuat operator * (FLOAT inScale) const { return(FQuat(V*inScale, S*inScale)); }
	inline FQuat operator / (FLOAT inScale) const { return(FQuat(V/inScale, S/inScale)); }
	inline FLOAT operator | (const FQuat& inQ) const { return((V|inQ.V)+(S*inQ.S)); }
	inline UBOOL operator == (const FQuat& inQ) const { return(V==inQ.V && S==inQ.S); }
	inline UBOOL operator != (const FQuat& inQ) const { return(!(*this == inQ)); }
};
#endif

// Used by the multiple vertex editing function to keep track of selected vertices.
class ABrush;
class CORE_API FVertexHit
{
public:
	// Variables.
	ABrush* pBrush;
	INT PolyIndex;
	INT VertexIndex;

	// Constructors.
	FVertexHit()
	{
		pBrush = NULL;
		PolyIndex = VertexIndex = 0;
	}
	FVertexHit( ABrush* InBrush, INT InPolyIndex, INT InVertexIndex )
	{
		pBrush = InBrush;
		PolyIndex = InPolyIndex;
		VertexIndex = InVertexIndex;
	}

	// Functions.
	UBOOL operator==( const FVertexHit& V ) const
	{
		return pBrush==V.pBrush && PolyIndex==V.PolyIndex && VertexIndex==V.VertexIndex;
	}
	UBOOL operator!=( const FVertexHit& V ) const
	{
		return pBrush!=V.pBrush || PolyIndex!=V.PolyIndex || VertexIndex!=V.VertexIndex;
	}
};

/*-----------------------------------------------------------------------------
	FEdge.
-----------------------------------------------------------------------------*/

class CORE_API FEdge
{
public:
	// Constructors.
	FEdge()
	{}
	FEdge( FVector v1, FVector v2)
	{
		Vertex[0] = v1;
		Vertex[1] = v2;
	}

	FVector Vertex[2];

	UBOOL operator==( const FEdge& E ) const
	{
		return ( (E.Vertex[0] == Vertex[0] && E.Vertex[1] == Vertex[1]) 
			|| (E.Vertex[0] == Vertex[1] && E.Vertex[1] == Vertex[0]) );
	}
};

/*-----------------------------------------------------------------------------
	FPlane.
-----------------------------------------------------------------------------*/

class CORE_API FPlane : public FVector
{
public:
	// Variables.
	FLOAT W;

	// Constructors.
	FPlane()
	{}
	FPlane( const FPlane& P )
	:	FVector(P)
	,	W(P.W)
	{}
	FPlane( const FVector& V )
	:	FVector(V)
	,	W(0)
	{}
	FPlane( FLOAT InX, FLOAT InY, FLOAT InZ, FLOAT InW )
	:	FVector(InX,InY,InZ)
	,	W(InW)
	{}
	FPlane( FVector InNormal, FLOAT InW )
	:	FVector(InNormal), W(InW)
	{}
	FPlane( FVector InBase, const FVector &InNormal )
	:	FVector(InNormal)
	,	W(InBase | InNormal)
	{}
	FPlane( FVector A, FVector B, FVector C )
	:	FVector( ((B-A)^(C-A)).SafeNormal() )
	,	W( A | ((B-A)^(C-A)).SafeNormal() )
	{}

	// Functions.
	FLOAT PlaneDot( const FVector &P ) const
	{
		return X*P.X + Y*P.Y + Z*P.Z - W;
	}
	FPlane Flip() const
	{
		return FPlane(-X,-Y,-Z,-W);
	}
	FPlane TransformPlaneByOrtho( const FCoords &Coords ) const;
	UBOOL operator==( const FPlane& V ) const
	{
		return X==V.X && Y==V.Y && Z==V.Z && W==V.W;
	}
	UBOOL operator!=( const FPlane& V ) const
	{
		return X!=V.X || Y!=V.Y || Z!=V.Z || W!=V.W;
	}

	// Serializer.
	friend FArchive& operator<<( FArchive& Ar, FPlane &P )
	{
		return Ar << (FVector&)P << P.W;
	}
};

/*-----------------------------------------------------------------------------
	FSphere.
-----------------------------------------------------------------------------*/

class CORE_API FSphere : public FPlane
{
public:
	// Constructors.
	FSphere()
	{}
	FSphere( INT )
	:	FPlane(0,0,0,0)
	{}
	FSphere( FVector V, FLOAT W )
	:	FPlane( V, W )
	{}
	FSphere( const FVector* Pts, INT Count );
	friend FArchive& operator<<( FArchive& Ar, FSphere& S )
	{
		if( Ar.Ver()<=61 )//oldver
			Ar << (FVector&)S;
		else
			Ar << (FPlane&)S;
		return Ar;
	}
};

/*-----------------------------------------------------------------------------
	FScale.
-----------------------------------------------------------------------------*/

// An axis along which sheering is performed.
enum ESheerAxis
{
	SHEER_None = 0,
	SHEER_XY   = 1,
	SHEER_XZ   = 2,
	SHEER_YX   = 3,
	SHEER_YZ   = 4,
	SHEER_ZX   = 5,
	SHEER_ZY   = 6,
};

//
// Scaling and sheering info associated with a brush.  This is 
// easily-manipulated information which is built into a transformation
// matrix later.
//
class CORE_API FScale
{
public:
	// Variables.
	FVector		Scale;
	FLOAT		SheerRate;
	BYTE		SheerAxis; // From ESheerAxis

	// Serializer.
	friend FArchive& operator<<( FArchive& Ar, FScale &S )
	{
		return Ar << S.Scale << S.SheerRate << S.SheerAxis;
	}

	// Constructors.
	FScale() {}
	FScale( const FVector &InScale, FLOAT InSheerRate, ESheerAxis InSheerAxis )
	:	Scale(InScale), SheerRate(InSheerRate), SheerAxis(InSheerAxis) {}

	// Operators.
	UBOOL operator==( const FScale &S ) const
	{
		return Scale==S.Scale && SheerRate==S.SheerRate && SheerAxis==S.SheerAxis;
	}

	// Functions.
	FLOAT  Orientation()
	{
		return Sgn(Scale.X * Scale.Y * Scale.Z);
	}
};

/*-----------------------------------------------------------------------------
	FCoords.
-----------------------------------------------------------------------------*/

//
// A coordinate system matrix.
//
class CORE_API FCoords
{
public:
	FVector	Origin;
	FVector	XAxis;
	FVector YAxis;
	FVector ZAxis;

	// Constructors.
	FCoords() {}
	FCoords( const FVector &InOrigin )
	:	Origin(InOrigin), XAxis(1,0,0), YAxis(0,1,0), ZAxis(0,0,1) {}
	FCoords( const FVector &InOrigin, const FVector &InX, const FVector &InY, const FVector &InZ )
	:	Origin(InOrigin), XAxis(InX), YAxis(InY), ZAxis(InZ) {}

	// Functions.
	FCoords MirrorByVector( const FVector& MirrorNormal ) const;
	FCoords MirrorByPlane( const FPlane& MirrorPlane ) const;
	FCoords	Transpose() const;
	FCoords Inverse() const;
	FRotator OrthoRotation() const;

	// CDH: Unreal<->Standard coordinate frame conversions
	//      Unreal form: X back, Y left, Z up
	//      Standard form: X right, Y up, Z back	
	FCoords ToStd() const { return(FCoords(Origin.ToStd(), -YAxis.ToStd(), ZAxis.ToStd(), XAxis.ToStd())); } // Unreal->Standard
	FCoords ToUnr() const { return(FCoords(Origin.ToUnr(), ZAxis.ToUnr(), -XAxis.ToUnr(), YAxis.ToUnr())); } // Standard->Unreal

	// Operators.
	FCoords& operator*=	(const FCoords   &TransformCoords);
	FCoords	 operator*	(const FCoords   &TransformCoords) const;
	FCoords& operator*=	(const FVector   &Point);
	FCoords  operator*	(const FVector   &Point) const;
	FCoords& operator*=	(const FRotator  &Rot);
	FCoords  operator*	(const FRotator  &Rot) const;
	FCoords& operator*=	(const FScale    &Scale);
	FCoords  operator*	(const FScale    &Scale) const;
	FCoords& operator/=	(const FVector   &Point);
	FCoords  operator/	(const FVector   &Point) const;
	FCoords& operator/=	(const FRotator  &Rot);
	FCoords  operator/	(const FRotator  &Rot) const;
	FCoords& operator/=	(const FScale    &Scale);
	FCoords  operator/	(const FScale    &Scale) const;

	// Serializer.
	friend FArchive& operator<<( FArchive& Ar, FCoords& F )
	{
		return Ar << F.Origin << F.XAxis << F.YAxis << F.ZAxis;
	}
#if DNF
	// CDH: Additional functions and operators for notational convenience
	
	FCoords(const FQuat& inQ);

	// another coordinate frame
	FCoords& operator >>= (const FCoords& inC); // in to
	FCoords operator >> (const FCoords& inC) const;
	FCoords& operator <<= (const FCoords& inC); // out of
	FCoords operator << (const FCoords& inC) const;

	// identity coordinate frame with point as origin
	FCoords& operator >>= (const FVector& inP); // in to
	FCoords operator >> (const FVector& inP) const;
	FCoords& operator <<= (const FVector& inP); // out of
	FCoords operator << (const FVector& inP) const;

	// identity coordinate frame rotated by a rotator
	FCoords& operator >>= (const FRotator& inR); // in to
	FCoords operator >> (const FRotator& inR) const;
	FCoords& operator <<= (const FRotator& inR); // out of
	FCoords operator << (const FRotator& inR) const;
	
	FCoords operator ~ () const; // transpose
	FCoords operator & (const FCoords& inC) const; // delta coords, this >> result == inC, inC << result == this

	FCoords Axes() const; // coords without an origin, i.e. axes only

#endif // #if DNF
};

/*-----------------------------------------------------------------------------
	FModelCoords.
-----------------------------------------------------------------------------*/

//
// A model coordinate system, describing both the covariant and contravariant
// transformation matrices to transform points and normals by.
//
class CORE_API FModelCoords
{
public:
	// Variables.
	FCoords PointXform;		// Coordinates to transform points by  (covariant).
	FCoords VectorXform;	// Coordinates to transform normals by (contravariant).

	// Constructors.
	FModelCoords()
	{}
	FModelCoords( const FCoords& InCovariant, const FCoords& InContravariant )
	:	PointXform(InCovariant), VectorXform(InContravariant)
	{}

	// Functions.
	FModelCoords Inverse()
	{
		return FModelCoords( VectorXform.Transpose(), PointXform.Transpose() );
	}
};

/*-----------------------------------------------------------------------------
	FRotator.
-----------------------------------------------------------------------------*/

//
// Rotation.
//
class CORE_API FRotator
{
public:
	// Variables.
	INT Pitch; // Looking up and down (0=Straight Ahead, +Up, -Down).
	INT Yaw;   // Rotating around (running in circles), 0=East, +North, -South.
	INT Roll;  // Rotation about axis of screen, 0=Straight, +Clockwise, -CCW.

	// Serializer.
	friend FArchive& operator<<( FArchive& Ar, FRotator& R )
	{
		return Ar << R.Pitch << R.Yaw << R.Roll;
	}

	// Constructors.
	FRotator() {}
	FRotator( INT InPitch, INT InYaw, INT InRoll )
	:	Pitch(InPitch), Yaw(InYaw), Roll(InRoll) {}

	// Binary arithmetic operators.
	FRotator operator+( const FRotator &R ) const
	{
		return FRotator( Pitch+R.Pitch, Yaw+R.Yaw, Roll+R.Roll );
	}
	FRotator operator-( const FRotator &R ) const
	{
		return FRotator( Pitch-R.Pitch, Yaw-R.Yaw, Roll-R.Roll );
	}
	FRotator operator*( FLOAT Scale ) const
	{
		return FRotator( Pitch*Scale, Yaw*Scale, Roll*Scale );
	}
	friend FRotator operator*( FLOAT Scale, const FRotator &R )
	{
		return FRotator( R.Pitch*Scale, R.Yaw*Scale, R.Roll*Scale );
	}
	FRotator operator*= (FLOAT Scale)
	{
		Pitch = (INT)(Pitch*Scale); Yaw = (INT)(Yaw*Scale); Roll = (INT)(Roll*Scale);
		return *this;
	}
	// Binary comparison operators.
	UBOOL operator==( const FRotator &R ) const
	{
		return Pitch==R.Pitch && Yaw==R.Yaw && Roll==R.Roll;
	}
	UBOOL operator!=( const FRotator &V ) const
	{
		return Pitch!=V.Pitch || Yaw!=V.Yaw || Roll!=V.Roll;
	}
	// Assignment operators.
	FRotator operator+=( const FRotator &R )
	{
		Pitch += R.Pitch; Yaw += R.Yaw; Roll += R.Roll;
		return *this;
	}
	FRotator operator-=( const FRotator &R )
	{
		Pitch -= R.Pitch; Yaw -= R.Yaw; Roll -= R.Roll;
		return *this;
	}
	// Functions.
	FRotator Reduce() const
	{
		return FRotator( ReduceAngle(Pitch), ReduceAngle(Yaw), ReduceAngle(Roll) );
	}
	int IsZero() const
	{
		return ((Pitch&65535)==0) && ((Yaw&65535)==0) && ((Roll&65535)==0);
	}
	FRotator Add( INT DeltaPitch, INT DeltaYaw, INT DeltaRoll )
	{
		Yaw   += DeltaYaw;
		Pitch += DeltaPitch;
		Roll  += DeltaRoll;
		return *this;
	}
	FRotator AddBounded( INT DeltaPitch, INT DeltaYaw, INT DeltaRoll )
	{
		Yaw  += DeltaYaw;
		Pitch = FAddAngleConfined(Pitch,DeltaPitch,192*0x100,64*0x100);
		Roll  = FAddAngleConfined(Roll, DeltaRoll, 192*0x100,64*0x100);
		return *this;
	}
	FRotator GridSnap( const FRotator &RotGrid )
	{
		return FRotator
		(
			FSnap(Pitch,RotGrid.Pitch),
			FSnap(Yaw,  RotGrid.Yaw),
			FSnap(Roll, RotGrid.Roll)
		);
	}
	FVector Vector();
    inline void AngleVectors( FVector &forward, FVector &left, FVector &up );
};

/*-----------------------------------------------------------------------------
	FRange.
-----------------------------------------------------------------------------*/

//
// Floating point range. Aaron Leiby
//
class CORE_API FRange 
{
public:
	// Variables.
	FLOAT A, B;

	// Constructors.
	FRange()
	{}
	FRange( FLOAT InA, FLOAT InB )
	:	A(InA), B(InB)
	{}

	// Binary math operators.
	friend FRange operator*( FLOAT Scale, const FRange& R )
	{
		return FRange( R.A * Scale, R.B * Scale );
	}
	FRange operator+( const FRange& R ) const
	{
		return FRange( A + R.A, B + R.B );
	}
	FRange operator-( const FRange& R ) const
	{
		return FRange( A - R.A, B - R.B );
	}
	FRange operator*( FLOAT Scale ) const
	{
		return FRange( A * Scale, B * Scale );
	}
	FRange operator/( FLOAT Scale ) const
	{
		FLOAT RScale = 1.0/Scale;
		return FRange( A * RScale, B * RScale );
	}
	FRange operator*( const FRange& R ) const
	{
		return FRange( A * R.A, B * R.B );
	}

	// Binary comparison operators.
	UBOOL operator==( const FRange& R ) const
	{
		return A==R.A && B==R.B;
	}
	UBOOL operator!=( const FRange& R ) const
	{
		return A!=R.A || B!=R.B;
	}

	// Unary operators.
	FRange operator-() const
	{
		return FRange( -A, -B );
	}

	// Assignment operators.
	FRange operator+=( const FRange& R )
	{
		A += R.A; B += R.B;
		return *this;
	}
	FRange operator-=( const FRange& R )
	{
		A -= R.A; B -= R.B;
		return *this;
	}
	FRange operator*=( FLOAT Scale )
	{
		A *= Scale; B *= Scale;
		return *this;
	}
	FRange operator/=( FLOAT Scale )
	{
		FLOAT RScale = 1.0/Scale;
		A *= RScale; B *= RScale;
		return *this;
	}
	FRange operator*=( const FRange& R )
	{
		A *= R.A; B *= R.B;
		return *this;
	}
	FRange operator/=( const FRange& R )
	{
		A /= R.A; B /= R.B;
		return *this;
	}

	// Simple functions.
	FLOAT GetMax() const
	{
		return Max( A, B );
	}
	FLOAT GetMin() const
	{
		return Min( A, B );
	}
	FLOAT Size() const
	{
		//return GetMax() - GetMin();
		INT Min, Max;
		if( A < B ){ Min=A; Max=B; }
		else       { Min=B; Max=A; }
		return Max - Min;
	}
	FLOAT GetRand() const
	{
		//return GetMin() + Size() * appFrand();
		//INT Min, Max;
		//if( A < B ){ Min=A; Max=B; }
		//else       { Min=B; Max=A; }
		//return Min + (Max - Min) * appFrand();
		//return RandRange( A, B );
		return B + (A - B) * appFrand();	// order is irrelevant since appFrand() is equally distributed between 0 and 1.
	}
#if 0
	INT GetRandInt() const
	{
		return appRandRange( (INT)A, (INT)B );
	} 
#endif
	int IsNearlyZero() const
	{
		return
				Abs(A)<KINDA_SMALL_NUMBER
			&&	Abs(B)<KINDA_SMALL_NUMBER;
	}
	UBOOL IsZero() const
	{
		return A==0.0 && B==0.0;
	}
	FRange GridSnap( const FRange& Grid )
	{
		return FRange( FSnap(A, Grid.A),FSnap(B, Grid.B) );
	}
	FLOAT& Component( INT Index )
	{
		return (&A)[Index];
	}

	// When      R==(0.0) Booleanize(0)=1.
	// Otherwise Booleanize(R) <-> !Booleanize(!R).
	UBOOL Booleanize()
	{
		return
			A >  0.0 ? 1 :
			A <  0.0 ? 0 :
			B >= 0.0 ? 1 : 0;
	}

	// Serializer.
	friend FArchive& operator<<( FArchive& Ar, FRange& R )
	{
		return Ar << R.A << R.B;
	}
};

/*-----------------------------------------------------------------------------
	Bounds.
-----------------------------------------------------------------------------*/

//
// A rectangular minimum bounding volume.
//
class CORE_API FBox
{
public:
	// Variables.
	FVector Min;
	FVector Max;
	BYTE IsValid;

	// Constructors.
	FBox() {}
	FBox(INT) { Init(); }
	FBox( const FVector& InMin, const FVector& InMax ) : Min(InMin), Max(InMax), IsValid(1) {}
	FBox( const FVector* Points, INT Count );

	// Accessors.
	FVector& GetExtrema( int i )
	{
		return (&Min)[i];
	}
	const FVector& GetExtrema( int i ) const
	{
		return (&Min)[i];
	}

	// Functions.
	void Init()
	{
		Min = Max = FVector(0,0,0);
		IsValid = 0;
	}
	FBox& operator+=( const FVector &Other )
	{
		if( IsValid )
		{
			Min.X = ::Min( Min.X, Other.X );
			Min.Y = ::Min( Min.Y, Other.Y );
			Min.Z = ::Min( Min.Z, Other.Z );

			Max.X = ::Max( Max.X, Other.X );
			Max.Y = ::Max( Max.Y, Other.Y );
			Max.Z = ::Max( Max.Z, Other.Z );
		}
		else
		{
			Min = Max = Other;
			IsValid = 1;
		}
		return *this;
	}
	FBox operator+( const FVector& Other ) const
	{
		return FBox(*this) += Other;
	}
	FBox& operator+=( const FBox& Other )
	{
		if( IsValid && Other.IsValid )
		{
			Min.X = ::Min( Min.X, Other.Min.X );
			Min.Y = ::Min( Min.Y, Other.Min.Y );
			Min.Z = ::Min( Min.Z, Other.Min.Z );

			Max.X = ::Max( Max.X, Other.Max.X );
			Max.Y = ::Max( Max.Y, Other.Max.Y );
			Max.Z = ::Max( Max.Z, Other.Max.Z );
		}
		else *this = Other;
		return *this;
	}
	FBox operator+( const FBox& Other ) const
	{
		return FBox(*this) += Other;
	}
    FVector& operator[]( INT i )
	{
		check(i>-1);
		check(i<2);
		if( i == 0 )		return Min;
		else				return Max;
	}
	FBox TransformBy( const FCoords& Coords ) const
	{
		FBox NewBox(0);
		for( int i=0; i<2; i++ )
			for( int j=0; j<2; j++ )
				for( int k=0; k<2; k++ )
					NewBox += FVector( GetExtrema(i).X, GetExtrema(j).Y, GetExtrema(k).Z ).TransformPointBy( Coords );
		return NewBox;
	}
	FBox ExpandBy( FLOAT W ) const
	{
		return FBox( Min - FVector(W,W,W), Max + FVector(W,W,W) );
	}

	// Serializer.
	friend FArchive& operator<<( FArchive& Ar, FBox& Bound )
	{
		return Ar << Bound.Min << Bound.Max << Bound.IsValid;
	}
};

/*-----------------------------------------------------------------------------
	FGlobalMath.
-----------------------------------------------------------------------------*/

//
// Global mathematics info.
//
class CORE_API FGlobalMath
{
public:
	// Constants.
	enum {ANGLE_SHIFT 	= 2};		// Bits to right-shift to get lookup value.
	enum {ANGLE_BITS	= 14};		// Number of valid bits in angles.
	enum {NUM_ANGLES 	= 16384}; 	// Number of angles that are in lookup table.
	enum {NUM_SQRTS		= 16384};	// Number of square roots in lookup table.
	enum {ANGLE_MASK    =  (((1<<ANGLE_BITS)-1)<<(16-ANGLE_BITS))};

	// Class constants.
	const FVector  	WorldMin;
	const FVector  	WorldMax;
	const FCoords  	UnitCoords;
	const FScale   	UnitScale;
	const FCoords	ViewCoords;

	// Basic math functions.
	FLOAT Sqrt( int i )
	{
		return SqrtFLOAT[i]; 
	}
	FLOAT SinTab( int i )
	{
		return TrigFLOAT[((i>>ANGLE_SHIFT)&(NUM_ANGLES-1))];
	}
	FLOAT CosTab( int i )
	{
		return TrigFLOAT[(((i+16384)>>ANGLE_SHIFT)&(NUM_ANGLES-1))];
	}
	FLOAT SinFloat( FLOAT F )
	{
		return SinTab((F*65536)/(2.f*PI));
	}
	FLOAT CosFloat( FLOAT F )
	{
		return CosTab((F*65536)/(2.f*PI));
	}

	// Constructor.
	FGlobalMath();

private:
	// Tables.
	FLOAT  TrigFLOAT		[NUM_ANGLES];
	FLOAT  SqrtFLOAT		[NUM_SQRTS];
	FLOAT  LightSqrtFLOAT	[NUM_SQRTS];
};

inline INT ReduceAngle( INT Angle )
{
	return Angle & FGlobalMath::ANGLE_MASK;
};

/*-----------------------------------------------------------------------------
	Floating point constants.
-----------------------------------------------------------------------------*/

//
// Lengths of normalized vectors (These are half their maximum values
// to assure that dot products with normalized vectors don't overflow).
//
#define FLOAT_NORMAL_THRESH				(0.0001)

//
// Magic numbers for numerical precision.
//
#define THRESH_POINT_ON_PLANE			(0.10f)		/* Thickness of plane for front/back/inside test */
#define THRESH_POINT_ON_SIDE			(0.20f)		/* Thickness of polygon side's side-plane for point-inside/outside/on side test */
#define THRESH_POINTS_ARE_SAME			(0.002f)	/* Two points are same if within this distance */
#define THRESH_POINTS_ARE_NEAR			(0.015f)	/* Two points are near if within this distance and can be combined if imprecise math is ok */
#define THRESH_NORMALS_ARE_SAME			(0.00002f)	/* Two normal points are same if within this distance */
													/* Making this too large results in incorrect CSG classification and disaster */
#define THRESH_VECTORS_ARE_NEAR			(0.0004f)	/* Two vectors are near if within this distance and can be combined if imprecise math is ok */
													/* Making this too large results in lighting problems due to inaccurate texture coordinates */
#define THRESH_SPLIT_POLY_WITH_PLANE	(0.25f)		/* A plane splits a polygon in half */
#define THRESH_SPLIT_POLY_PRECISELY		(0.01f)		/* A plane exactly splits a polygon */
#define THRESH_ZERO_NORM_SQUARED		(0.0001f)	/* Size of a unit normal that is considered "zero", squared */
#define THRESH_VECTORS_ARE_PARALLEL		(0.02f)		/* Vectors are parallel if dot product varies less than this */

/*-----------------------------------------------------------------------------
	FVector transformation.
-----------------------------------------------------------------------------*/

//
// Transformations in optimized assembler format.
// An adaption of Michael Abrash' optimal transformation code.
//
#if ASM
inline void ASMTransformPoint(const FCoords &Coords, const FVector &InVector, FVector &OutVector)
{
	// FCoords is a structure of 4 vectors: Origin, X, Y, Z
	//				 	  x  y  z
	// FVector	Origin;   0  4  8
	// FVector	XAxis;   12 16 20
	// FVector  YAxis;   24 28 32
	// FVector  ZAxis;   36 40 44
	//
	//	task:	Temp = ( InVector - Coords.Origin );
	//			Outvector.X = (Temp | Coords.XAxis);
	//			Outvector.Y = (Temp | Coords.YAxis);
	//			Outvector.Z = (Temp | Coords.ZAxis);
	//
	// About 33 cycles on a Pentium.
	//
	__asm
	{
		mov     esi,[InVector]
		mov     edx,[Coords]     
		mov     edi,[OutVector]

		// get source
		fld     dword ptr [esi+0]
		fld     dword ptr [esi+4]
		fld     dword ptr [esi+8] // z y x
		fxch    st(2)     // xyz

		// subtract origin
		fsub    dword ptr [edx + 0]  // xyz
		fxch    st(1)  
		fsub	dword ptr [edx + 4]  // yxz
		fxch    st(2)
		fsub	dword ptr [edx + 8]  // zxy
		fxch    st(1)        // X Z Y

		// triplicate X for  transforming
		fld     st(0)	// X X   Z Y
        fmul    dword ptr [edx+12]     // Xx X Z Y
        fld     st(1)   // X Xx X  Z Y 
        fmul    dword ptr [edx+24]   // Xy Xx X  Z Y 
		fxch    st(2)    
		fmul    dword ptr [edx+36]  // Xz Xx Xy  Z  Y 
		fxch    st(4)     // Y  Xx Xy  Z  Xz

		fld     st(0)			// Y Y    Xx Xy Z Xz
		fmul    dword ptr [edx+16]     
		fld     st(1) 			// Y Yx Y    Xx Xy Z Xz
        fmul    dword ptr [edx+28]    
		fxch    st(2)			// Y  Yx Yy   Xx Xy Z Xz
		fmul    dword ptr [edx+40]	 // Yz Yx Yy   Xx Xy Z Xz
		fxch    st(1)			// Yx Yz Yy   Xx Xy Z Xz

        faddp   st(3),st(0)	  // Yz Yy  XxYx   Xy Z  Xz
        faddp   st(5),st(0)   // Yy  XxYx   Xy Z  XzYz
        faddp   st(2),st(0)   // XxYx  XyYy Z  XzYz
		fxch    st(2)         // Z     XyYy XxYx XzYz

		fld     st(0)         //  Z  Z     XyYy XxYx XzYz
		fmul    dword ptr [edx+20]     
		fld     st(1)         //  Z  Zx Z  XyYy XxYx XzYz
        fmul    dword ptr [edx+32]      
		fxch    st(2)         //  Z  Zx Zy
		fmul    dword ptr [edx+44]	  //  Zz Zx Zy XyYy XxYx XzYz
		fxch    st(1)         //  Zx Zz Zy XyYy XxYx XzYz

		faddp   st(4),st(0)   //  Zz Zy XyYy  XxYxZx  XzYz
		faddp   st(4),st(0)	  //  Zy XyYy     XxYxZx  XzYzZz
		faddp   st(1),st(0)   //  XyYyZy      XxYxZx  XzYzZz
		fxch    st(1)		  //  Xx+Xx+Zx   Xy+Yy+Zy  Xz+Yz+Zz  

		fstp    dword ptr [edi+0]       
        fstp    dword ptr [edi+4]                               
        fstp    dword ptr [edi+8]     
	}
}
#elif ASMLINUX
inline void ASMTransformPoint(const FCoords &Coords, const FVector &InVector, FVector &OutVector)
{
	__asm__ __volatile__ ("
		# Get source.
		flds	0(%%esi);			# x
		flds	4(%%esi);			# y x
		flds	8(%%esi);			# z y x
		fxch	%%st(2);

		# Subtract origin.
		fsubs	0(%1);
		fxch	%%st(1);
		fsubs	4(%1);
		fxch	%%st(2);
		fsubs	8(%1);
		fxch	%%st(1);

		# Triplicate X for transforming.
		fld		%%st(0);
		fmuls	12(%1);
		fld		%%st(1);
		fmuls	24(%1);
		fxch	%%st(2);
		fmuls	36(%1);
		fxch	%%st(4);
		
		fld		%%st(0);
		fmuls	16(%1);
		fld		%%st(1);
		fmuls	28(%1);
		fxch	%%st(2);
		fmuls	40(%1);
		fxch	%%st(1);

		faddp	%%st(0),%%st(3);
		faddp	%%st(0),%%st(5);
		faddp	%%st(0),%%st(2);
		fxch	%%st(2);
		
		fld		%%st(0);
		fmuls	20(%1);
		fld		%%st(1);
		fmuls	32(%1);
		fxch	%%st(2);
		fmuls	44(%1);
		fxch	%%st(1);
		
		faddp	%%st(0),%%st(4);
		faddp	%%st(0),%%st(4);
		faddp	%%st(0),%%st(1);
		fxch	%%st(1);

		fstps	0(%%edi);
		fstps	4(%%edi);
		fstps	8(%%edi);
	"
	:
	:	"S" (&InVector),
		"q" (&Coords),
		"D" (&OutVector)
	: "memory"
	);
}
#endif

#if ASM
__forceinline void ASMTransformVector(const FCoords &Coords, const FVector &InVector, FVector &OutVector)
{
	__asm
	{
		mov     esi,[InVector]
		mov     edx,[Coords]     
		mov     edi,[OutVector]

		// get source
		fld     dword ptr [esi+0]
		fld     dword ptr [esi+4]
		fxch    st(1)
		fld     dword ptr [esi+8] // z x y 
		fxch    st(1)             // x z y

		// triplicate X for  transforming
		fld     st(0)	// X X   Z Y
        fmul    dword ptr [edx+12]     // Xx X Z Y
        fld     st(1)   // X Xx X  Z Y 
        fmul    dword ptr [edx+24]   // Xy Xx X  Z Y 
		fxch    st(2)    
		fmul    dword ptr [edx+36]  // Xz Xx Xy  Z  Y 
		fxch    st(4)     // Y  Xx Xy  Z  Xz

		fld     st(0)			// Y Y    Xx Xy Z Xz
		fmul    dword ptr [edx+16]     
		fld     st(1) 			// Y Yx Y    Xx Xy Z Xz
        fmul    dword ptr [edx+28]    
		fxch    st(2)			// Y  Yx Yy   Xx Xy Z Xz
		fmul    dword ptr [edx+40]	 // Yz Yx Yy   Xx Xy Z Xz
		fxch    st(1)			// Yx Yz Yy   Xx Xy Z Xz

        faddp   st(3),st(0)	  // Yz Yy  XxYx   Xy Z  Xz
        faddp   st(5),st(0)   // Yy  XxYx   Xy Z  XzYz
        faddp   st(2),st(0)   // XxYx  XyYy Z  XzYz
		fxch    st(2)         // Z     XyYy XxYx XzYz

		fld     st(0)         //  Z  Z     XyYy XxYx XzYz
		fmul    dword ptr [edx+20]     
		fld     st(1)         //  Z  Zx Z  XyYy XxYx XzYz
        fmul    dword ptr [edx+32]      
		fxch    st(2)         //  Z  Zx Zy
		fmul    dword ptr [edx+44]	  //  Zz Zx Zy XyYy XxYx XzYz
		fxch    st(1)         //  Zx Zz Zy XyYy XxYx XzYz

		faddp   st(4),st(0)   //  Zz Zy XyYy  XxYxZx  XzYz
		faddp   st(4),st(0)	  //  Zy XyYy     XxYxZx  XzYzZz
		faddp   st(1),st(0)   //  XyYyZy      XxYxZx  XzYzZz
		fxch    st(1)		  //  Xx+Xx+Zx   Xy+Yy+Zy  Xz+Yz+Zz  

		fstp    dword ptr [edi+0]       
        fstp    dword ptr [edi+4]                               
        fstp    dword ptr [edi+8]     
	}
}
#endif

#if ASMLINUX
__forceinline void ASMTransformVector(const FCoords &Coords, const FVector &InVector, FVector &OutVector)
{
	asm volatile("
		# Get source.
		flds	0(%%esi);
		flds	4(%%esi);
		fxch	%%st(1);
		flds	8(%%esi);
		fxch	%%st(1);

		# Triplicate X for transforming.
		fld		%%st(0);
		fmuls	12(%1);
		fld		%%st(1);
		fmuls	24(%1);
		fxch	%%st(2);
		fmuls	36(%1);
		fxch	%%st(4);

		fld		%%st(0);
		fmuls	16(%1);
		fld		%%st(1);
		fmuls	28(%1);
		fxch	%%st(2);
		fmuls	40(%1);
		fxch	%%st(1);

		faddp	%%st(0),%%st(3);
		faddp	%%st(0),%%st(5);
		faddp	%%st(0),%%st(2);
		fxch	%%st(2);

		fld		%%st(0);
		fmuls	20(%1);
		fld		%%st(1);
		fmuls	32(%1);
		fxch	%%st(2);
		fmuls	44(%1);
		fxch	%%st(1);

		faddp	%%st(0),%%st(4);
		faddp	%%st(0),%%st(4);
		faddp	%%st(0),%%st(1);
		fxch	%%st(1);

		fstps	0(%%edi);
		fstps	4(%%edi);
		fstps	8(%%edi);
	"
	:
	: "S" (&InVector),
	  "q" (&Coords),
	  "D" (&OutVector)
	: "memory"
	);
}
#endif

//
// Transform a point by a coordinate system, moving
// it by the coordinate system's origin if nonzero.
//
inline FVector FVector::TransformPointBy( const FCoords &Coords ) const
{
#if ASM
	FVector Temp;
	ASMTransformPoint( Coords, *this, Temp);
	return Temp;
#elif ASMLINUX
	static FVector Temp;
	ASMTransformPoint( Coords, *this, Temp);
	return Temp;
#else
	FVector Temp = *this - Coords.Origin;
	return FVector(	Temp | Coords.XAxis, Temp | Coords.YAxis, Temp | Coords.ZAxis );
#endif
}

//
// Transform a directional vector by a coordinate system.
// Ignore's the coordinate system's origin.
//
__forceinline FVector FVector::TransformVectorBy( const FCoords &Coords ) const
{
#if ASM
	FVector Temp;
	ASMTransformVector( Coords, *this, Temp);
	return Temp;
#elif ASMLINUX
	FVector Temp;
	ASMTransformVector( Coords, *this, Temp);
	return Temp;
#else
	return FVector(	*this | Coords.XAxis, *this | Coords.YAxis, *this | Coords.ZAxis );
#endif
}

//
// Mirror a vector about a normal vector.
//
inline FVector FVector::MirrorByVector( const FVector& MirrorNormal ) const
{
	return *this - MirrorNormal * (2.f * (*this | MirrorNormal));
}

//
// Mirror a vector about a plane.
//
inline FVector FVector::MirrorByPlane( const FPlane& Plane ) const
{
	return *this - Plane * (2.f * Plane.PlaneDot(*this) );
}

/*-----------------------------------------------------------------------------
	FVector friends.
-----------------------------------------------------------------------------*/

//
// Compare two points and see if they're the same, using a threshold.
// Returns 1=yes, 0=no.  Uses fast distance approximation.
//
inline int FPointsAreSame( const FVector &P, const FVector &Q )
{
	FLOAT Temp;
	Temp=P.X-Q.X;
	if( (Temp > -THRESH_POINTS_ARE_SAME) && (Temp < THRESH_POINTS_ARE_SAME) )
	{
		Temp=P.Y-Q.Y;
		if( (Temp > -THRESH_POINTS_ARE_SAME) && (Temp < THRESH_POINTS_ARE_SAME) )
		{
			Temp=P.Z-Q.Z;
			if( (Temp > -THRESH_POINTS_ARE_SAME) && (Temp < THRESH_POINTS_ARE_SAME) )
			{
				return 1;
			}
		}
	}
	return 0;
}

//
// Compare two points and see if they're the same, using a threshold.
// Returns 1=yes, 0=no.  Uses fast distance approximation.
//
inline int FPointsAreNear( const FVector &Point1, const FVector &Point2, FLOAT Dist )
{
	FLOAT Temp;
	Temp=(Point1.X - Point2.X); if (Abs(Temp)>=Dist) return 0;
	Temp=(Point1.Y - Point2.Y); if (Abs(Temp)>=Dist) return 0;
	Temp=(Point1.Z - Point2.Z); if (Abs(Temp)>=Dist) return 0;
	return 1;
}

//
// Calculate the signed distance (in the direction of the normal) between
// a point and a plane.
//
inline FLOAT FPointPlaneDist
(
	const FVector &Point,
	const FVector &PlaneBase,
	const FVector &PlaneNormal
)
{
	return (Point - PlaneBase) | PlaneNormal;
}

//
// Euclidean distance between two points.
//
inline FLOAT FDist( const FVector &V1, const FVector &V2 )
{
	return appSqrt( Square(V2.X-V1.X) + Square(V2.Y-V1.Y) + Square(V2.Z-V1.Z) );
}

//
// Squared distance between two points.
//
inline FLOAT FDistSquared( const FVector &V1, const FVector &V2 )
{
	return Square(V2.X-V1.X) + Square(V2.Y-V1.Y) + Square(V2.Z-V1.Z);
}

//
// See if two normal vectors (or plane normals) are nearly parallel.
//
inline int FParallel( const FVector &Normal1, const FVector &Normal2 )
{
	FLOAT NormalDot = Normal1 | Normal2;
	return (Abs (NormalDot - 1.f) <= THRESH_VECTORS_ARE_PARALLEL);
}

//
// See if two planes are coplanar.
//
inline int FCoplanar( const FVector &Base1, const FVector &Normal1, const FVector &Base2, const FVector &Normal2 )
{
	if      (!FParallel(Normal1,Normal2)) return 0;
	else if (FPointPlaneDist (Base2,Base1,Normal1) > THRESH_POINT_ON_PLANE) return 0;
	else    return 1;
}

//
// Triple product of three vectors.
//
inline FLOAT FTriple( const FVector& X, const FVector& Y, const FVector& Z )
{
	return
	(	(X.X * (Y.Y * Z.Z - Y.Z * Z.Y))
	+	(X.Y * (Y.Z * Z.X - Y.X * Z.Z))
	+	(X.Z * (Y.X * Z.Y - Y.Y * Z.X)) );
}

/*-----------------------------------------------------------------------------
	FPlane implementation.
-----------------------------------------------------------------------------*/

//
// Transform a point by a coordinate system, moving
// it by the coordinate system's origin if nonzero.
//
inline FPlane FPlane::TransformPlaneByOrtho( const FCoords &Coords ) const
{
	FVector Normal( *this | Coords.XAxis, *this | Coords.YAxis, *this | Coords.ZAxis );
	return FPlane( Normal, W - (Coords.Origin.TransformVectorBy(Coords) | Normal) );
}

/*-----------------------------------------------------------------------------
	FCoords functions.
-----------------------------------------------------------------------------*/

//
// Return this coordinate system's transpose.
// If the coordinate system is orthogonal, this is equivalent to its inverse.
//
inline FCoords FCoords::Transpose() const
{
	return FCoords
	(
		-Origin.TransformVectorBy(*this),
		FVector( XAxis.X, YAxis.X, ZAxis.X ),
		FVector( XAxis.Y, YAxis.Y, ZAxis.Y ),
		FVector( XAxis.Z, YAxis.Z, ZAxis.Z )
	);
}

//
// Mirror the coordinates about a normal vector.
//
inline FCoords FCoords::MirrorByVector( const FVector& MirrorNormal ) const
{
	return FCoords
	(
		Origin.MirrorByVector( MirrorNormal ),
		XAxis .MirrorByVector( MirrorNormal ),
		YAxis .MirrorByVector( MirrorNormal ),
		ZAxis .MirrorByVector( MirrorNormal )
	);
}

//
// Mirror the coordinates about a plane.
//
inline FCoords FCoords::MirrorByPlane( const FPlane& Plane ) const
{
	return FCoords
	(
		Origin.MirrorByPlane ( Plane ),
		XAxis .MirrorByVector( Plane ),
		YAxis .MirrorByVector( Plane ),
		ZAxis .MirrorByVector( Plane )
	);
}

/*-----------------------------------------------------------------------------
	FCoords operators.
-----------------------------------------------------------------------------*/

//
// Transform this coordinate system by another coordinate system.
//
inline FCoords& FCoords::operator*=( const FCoords& TransformCoords )
{
	//!! Proper solution:
	//Origin = Origin.TransformPointBy( TransformCoords.Inverse().Transpose() );
	// Fast solution assuming orthogonal coordinate system:
	Origin = Origin.TransformPointBy ( TransformCoords );
	XAxis  = XAxis .TransformVectorBy( TransformCoords );
	YAxis  = YAxis .TransformVectorBy( TransformCoords );
	ZAxis  = ZAxis .TransformVectorBy( TransformCoords );
	return *this;
}
inline FCoords FCoords::operator*( const FCoords &TransformCoords ) const
{
	return FCoords(*this) *= TransformCoords;
}

//
// Transform this coordinate system by a pitch-yaw-roll rotation.
//
inline FCoords& FCoords::operator*=( const FRotator &Rot )
{
	// Apply yaw rotation.
	*this *= FCoords
	(	
		FVector( 0.f, 0.f, 0.f ),
		FVector( +GMath.CosTab(Rot.Yaw), +GMath.SinTab(Rot.Yaw), +0.f ),
		FVector( -GMath.SinTab(Rot.Yaw), +GMath.CosTab(Rot.Yaw), +0.f ),
		FVector( +0.f, +0.f, +1.f )
	);

	// Apply pitch rotation.
	*this *= FCoords
	(	
		FVector( 0.f, 0.f, 0.f ),
		FVector( +GMath.CosTab(Rot.Pitch), +0.f, +GMath.SinTab(Rot.Pitch) ),
		FVector( +0.f, +1.f, +0.f ),
		FVector( -GMath.SinTab(Rot.Pitch), +0.f, +GMath.CosTab(Rot.Pitch) )
	);

	// Apply roll rotation.
	*this *= FCoords
	(	
		FVector( 0.f, 0.f, 0.f ),
		FVector( +1.f, +0.f, +0.f ),
		FVector( +0.f, +GMath.CosTab(Rot.Roll), -GMath.SinTab(Rot.Roll) ),
		FVector( +0.f, +GMath.SinTab(Rot.Roll), +GMath.CosTab(Rot.Roll) )
	);
	return *this;
}
inline FCoords FCoords::operator*( const FRotator &Rot ) const
{
	return FCoords(*this) *= Rot;
}

inline FCoords& FCoords::operator*=( const FVector &Point )
{
	Origin -= Point;
	return *this;
}
inline FCoords FCoords::operator*( const FVector &Point ) const
{
	return FCoords(*this) *= Point;
}

//
// Detransform this coordinate system by a pitch-yaw-roll rotation.
//
inline FCoords& FCoords::operator/=( const FRotator &Rot )
{
	// Apply inverse roll rotation.
	*this *= FCoords
	(
		FVector( 0.0, 0.0, 0.0 ),
		FVector( +1.0, -0.0, +0.0 ),
		FVector( -0.0, +GMath.CosTab(Rot.Roll), +GMath.SinTab(Rot.Roll) ),
		FVector( +0.0, -GMath.SinTab(Rot.Roll), +GMath.CosTab(Rot.Roll) )
	);

	// Apply inverse pitch rotation.
	*this *= FCoords
	(
		FVector( 0.0, 0.0, 0.0 ),
		FVector( +GMath.CosTab(Rot.Pitch), +0.0, -GMath.SinTab(Rot.Pitch) ),
		FVector( +0.0, +1.0, -0.0 ),
		FVector( +GMath.SinTab(Rot.Pitch), +0.0, +GMath.CosTab(Rot.Pitch) )
	);

	// Apply inverse yaw rotation.
	*this *= FCoords
	(
		FVector( 0.0, 0.0, 0.0 ),
		FVector( +GMath.CosTab(Rot.Yaw), -GMath.SinTab(Rot.Yaw), -0.0 ),
		FVector( +GMath.SinTab(Rot.Yaw), +GMath.CosTab(Rot.Yaw), +0.0 ),
		FVector( -0.0, +0.0, +1.0 )
	);
	return *this;
}
inline FCoords FCoords::operator/( const FRotator &Rot ) const
{
	return FCoords(*this) /= Rot;
}

inline FCoords& FCoords::operator/=( const FVector &Point )
{
	Origin += Point;
	return *this;
}
inline FCoords FCoords::operator/( const FVector &Point ) const
{
	return FCoords(*this) /= Point;
}

//
// Transform this coordinate system by a scale.
// Note: Will return coordinate system of opposite handedness if
// Scale.X*Scale.Y*Scale.Z is negative.
//
inline FCoords& FCoords::operator*=( const FScale &Scale )
{
	// Apply sheering.
	FLOAT   Sheer      = FSheerSnap( Scale.SheerRate );
	FCoords TempCoords = GMath.UnitCoords;
	switch( Scale.SheerAxis )
	{
		case SHEER_XY:
			TempCoords.XAxis.Y = Sheer;
			break;
		case SHEER_XZ:
			TempCoords.XAxis.Z = Sheer;
			break;
		case SHEER_YX:
			TempCoords.YAxis.X = Sheer;
			break;
		case SHEER_YZ:
			TempCoords.YAxis.Z = Sheer;
			break;
		case SHEER_ZX:
			TempCoords.ZAxis.X = Sheer;
			break;
		case SHEER_ZY:
			TempCoords.ZAxis.Y = Sheer;
			break;
		default:
			break;
	}
	*this *= TempCoords;

	// Apply scaling.
	XAxis    *= Scale.Scale;
	YAxis    *= Scale.Scale;
	ZAxis    *= Scale.Scale;
	Origin.X /= Scale.Scale.X;
	Origin.Y /= Scale.Scale.Y;
	Origin.Z /= Scale.Scale.Z;

	return *this;
}
inline FCoords FCoords::operator*( const FScale &Scale ) const
{
	return FCoords(*this) *= Scale;
}

//
// Detransform a coordinate system by a scale.
//
inline FCoords& FCoords::operator/=( const FScale &Scale )
{
	// Deapply scaling.
	XAxis    /= Scale.Scale;
	YAxis    /= Scale.Scale;
	ZAxis    /= Scale.Scale;
	Origin.X *= Scale.Scale.X;
	Origin.Y *= Scale.Scale.Y;
	Origin.Z *= Scale.Scale.Z;

	// Deapply sheering.
	FCoords TempCoords(GMath.UnitCoords);
	FLOAT Sheer = FSheerSnap( Scale.SheerRate );
	switch( Scale.SheerAxis )
	{
		case SHEER_XY:
			TempCoords.XAxis.Y = -Sheer;
			break;
		case SHEER_XZ:
			TempCoords.XAxis.Z = -Sheer;
			break;
		case SHEER_YX:
			TempCoords.YAxis.X = -Sheer;
			break;
		case SHEER_YZ:
			TempCoords.YAxis.Z = -Sheer;
			break;
		case SHEER_ZX:
			TempCoords.ZAxis.X = -Sheer;
			break;
		case SHEER_ZY:
			TempCoords.ZAxis.Y = -Sheer;
			break;
		default: // SHEER_NONE
			break;
	}
	*this *= TempCoords;

	return *this;
}
inline FCoords FCoords::operator/( const FScale &Scale ) const
{
	return FCoords(*this) /= Scale;
}

/*-----------------------------------------------------------------------------
	Random numbers.
-----------------------------------------------------------------------------*/

//
// Compute pushout of a box from a plane.
//
inline FLOAT FBoxPushOut( FVector Normal, FVector Size )
{
	return Abs(Normal.X*Size.X) + Abs(Normal.Y*Size.Y) + Abs(Normal.Z*Size.Z);
}

//
// Return a uniformly distributed random unit vector.
//
inline FVector VRand()
{
	FVector Result;
	do
	{
		// Check random vectors in the unit sphere so result is statistically uniform.
		Result.X = appFrand()*2 - 1;
		Result.Y = appFrand()*2 - 1;
		Result.Z = appFrand()*2 - 1;
	} while( Result.SizeSquared() > 1.0 );
	return Result.UnsafeNormal();
}

// NJS: Return a random VRand scale:
inline FVector VRandScale()
{
	FVector Result(appFrand()*2-1,appFrand()*2-1,appFrand()*2-1);
	return Result;
}

/*-----------------------------------------------------------------------------
	Texturing.
-----------------------------------------------------------------------------*/

// Accepts a triangle (XYZ and ST values for each point) and returns a poly base and UV vectors
inline void FTexCoordsToVectors( FVector V0, FVector ST0, FVector V1, FVector ST1, FVector V2, FVector ST2, FVector* InBaseResult, FVector* InUResult, FVector* InVResult )
{
	// Create polygon normal.
	FVector PN = FVector((V0-V1) ^ (V2-V0));
	PN = PN.SafeNormal();

	// Fudge UV's to make sure no infinities creep into UV vector math, whenever we detect identical U or V's.
	if( ( ST0.X == ST1.X ) || ( ST2.X == ST1.X ) || ( ST2.X == ST0.X ) ||
		( ST0.Y == ST1.Y ) || ( ST2.Y == ST1.Y ) || ( ST2.Y == ST0.Y ) )
	{
		ST1 += FVector(0.004173f,0.004123f,0.0f);
		ST2 += FVector(0.003173f,0.003123f,0.0f);
	}

	//
	// Solve the equations to find our texture U/V vectors 'TU' and 'TV' by stacking them 
	// into a 3x3 matrix , one for  u(t) = TU dot (x(t)-x(o) + u(o) and one for v(t)=  TV dot (.... , 
	// then the third assumes we're perpendicular to the normal. 
	//
	FCoords TexEqu; 
	TexEqu.XAxis = FVector(	V1.X - V0.X, V1.Y - V0.Y, V1.Z - V0.Z );
	TexEqu.YAxis = FVector( V2.X - V0.X, V2.Y - V0.Y, V2.Z - V0.Z );
	TexEqu.ZAxis = FVector( PN.X,        PN.Y,        PN.Z        );
	TexEqu.Origin =FVector( 0.0f, 0.0f, 0.0f );
	TexEqu = TexEqu.Inverse();

	FVector UResult( ST1.X-ST0.X, ST2.X-ST0.X, 0.0f );
	FVector TUResult = UResult.TransformVectorBy( TexEqu );

	FVector VResult( ST1.Y-ST0.Y, ST2.Y-ST0.Y, 0.0f );
	FVector TVResult = VResult.TransformVectorBy( TexEqu );

	//
	// Adjust the BASE to account for U0 and V0 automatically, and force it into the same plane.
	//				
	FCoords BaseEqu;
	BaseEqu.XAxis = TUResult;
	BaseEqu.YAxis = TVResult; 
	BaseEqu.ZAxis = FVector( PN.X, PN.Y, PN.Z );
	BaseEqu.Origin = FVector( 0.0f, 0.0f, 0.0f );

	FVector BResult = FVector( ST0.X - ( TUResult|V0 ), ST0.Y - ( TVResult|V0 ),  0.0f );

	*InBaseResult = - 1.0f *  BResult.TransformVectorBy( BaseEqu.Inverse() );
	*InUResult = TUResult;
	*InVResult = TVResult;
}

/*-----------------------------------------------------------------------------
	Advanced geometry.
-----------------------------------------------------------------------------*/

//
// Find the intersection of an infinite line (defined by two points) and
// a plane.  Assumes that the line and plane do indeed intersect; you must
// make sure they're not parallel before calling.
//
inline FVector FLinePlaneIntersection
(
	const FVector &Point1,
	const FVector &Point2,
	const FVector &PlaneOrigin,
	const FVector &PlaneNormal
)
{
	return
		Point1
	+	(Point2-Point1)
	*	(((PlaneOrigin - Point1)|PlaneNormal) / ((Point2 - Point1)|PlaneNormal));
}
inline FVector FLinePlaneIntersection
(
	const FVector &Point1,
	const FVector &Point2,
	const FPlane  &Plane
)
{
	return
		Point1
	+	(Point2-Point1)
	*	((Plane.W - (Point1|Plane))/((Point2 - Point1)|Plane));
}

/*-----------------------------------------------------------------------------
	FPlane functions.
-----------------------------------------------------------------------------*/

//
// Compute intersection point of three planes.
// Return 1 if valid, 0 if infinite.
//
inline UBOOL FIntersectPlanes3( FVector& I, const FPlane& P1, const FPlane& P2, const FPlane& P3 )
{
	// Compute determinant, the triple product P1|(P2^P3)==(P1^P2)|P3.
	FLOAT Det = (P1 ^ P2) | P3;
	if( Square(Det) < Square(0.001) )
	{
		// Degenerate.
		I = FVector(0,0,0);
		return 0;
	}
	else
	{
		// Compute the intersection point, guaranteed valid if determinant is nonzero.
		I = (P1.W*(P2^P3) + P2.W*(P3^P1) + P3.W*(P1^P2)) / Det;
	}
	return 1;
}

//
// Compute intersection point and direction of line joining two planes.
// Return 1 if valid, 0 if infinite.
//
inline UBOOL FIntersectPlanes2( FVector& I, FVector& D, const FPlane& P1, const FPlane& P2 )
{
	// Compute line direction, perpendicular to both plane normals.
	D = P1 ^ P2;
	FLOAT DD = D.SizeSquared();
	if( DD < Square(0.001f) )
	{
		// Parallel or nearly parallel planes.
		D = I = FVector(0,0,0);
		return 0;
	}
	else
	{
		// Compute intersection.
		I = (P1.W*(P2^D) + P2.W*(D^P1)) / DD;
		D.Normalize();
		return 1;
	}
}

/*-----------------------------------------------------------------------------
	FRotator functions.
-----------------------------------------------------------------------------*/

//
// Convert a rotation into a vector facing in its direction.
//
inline FVector FRotator::Vector()
{
	return (GMath.UnitCoords / *this).XAxis;
}

inline void FRotator::AngleVectors( FVector &forward, FVector &left, FVector &up )
{
    static FLOAT sr, sp, sy, cr, cp, cy;
    
    sy = GMath.SinTab(Yaw);
    cy = GMath.CosTab(Yaw);
            
    sp = GMath.SinTab(Pitch);
    cp = GMath.CosTab(Pitch);

    forward.X = cp*cy;
    forward.Y = cp*sy;
    forward.Z = -sp;

    sr = GMath.SinTab(Roll);
    cr = GMath.CosTab(Roll);

    left.X = (sr*sp*cy+cr*-sy);
    left.Y = (sr*sp*sy+cr*cy);
    left.Z = (sr*cp);

    up.X = (cr*sp*cy+-sr*-sy);
    up.Y = (cr*sp*sy+-sr*cy);
    up.Z = (cr*cp);
}


/*-----------------------------------------------------------------------------
	FMatrix.          
-----------------------------------------------------------------------------*/
// Floating point 4 x 4  (4 x 3)  KNI-friendly matrix
class CORE_API FMatrix
{
public:

	// Variables.
	union
	{
		FLOAT M[4][4]; 
		struct
		{
			FPlane XPlane; // each plane [x,y,z,w] is a *column* in the matrix.
			FPlane YPlane;
			FPlane ZPlane;
			FPlane WPlane;
		};
	};

	// Constructors.
	FMatrix()
	{}
	FMatrix( FPlane InX, FPlane InY, FPlane InZ )
	:	XPlane(InX), YPlane(InY), ZPlane(InZ), WPlane(0,0,0,0)
	{}
	FMatrix( FPlane InX, FPlane InY, FPlane InZ, FPlane InW )
	:	XPlane(InX), YPlane(InY), ZPlane(InZ), WPlane(InW)
	{}


	// Regular transform
	FVector TransformFVector(const FVector &V) const
	{
		FVector FV;

		FV.X = V.X * M[0][0] + V.Y * M[0][1] + V.Z * M[0][2] + M[0][3];
		FV.Y = V.X * M[1][0] + V.Y * M[1][1] + V.Z * M[1][2] + M[1][3];
		FV.Z = V.X * M[2][0] + V.Y * M[2][1] + V.Z * M[2][2] + M[2][3];

		return FV;
	}

	// Homogeneous transform
	FPlane TransformFPlane(const FPlane &P) const
	{
		FPlane FP;

		FP.X = P.X * M[0][0] + P.Y * M[0][1] + P.Z * M[0][2] + M[0][3];
		FP.Y = P.X * M[1][0] + P.Y * M[1][1] + P.Z * M[1][2] + M[1][3];
		FP.Z = P.X * M[2][0] + P.Y * M[2][1] + P.Z * M[2][2] + M[2][3];
		FP.W = P.X * M[3][0] + P.Y * M[3][1] + P.Z * M[3][2] + M[3][3];

		return FP;
	}

	FQuat FMatrixToFQuat();

	// Combine transforms binary operation MxN
	friend FMatrix CombineTransforms(const FMatrix& M, const FMatrix& N);
	friend FMatrix FMatrixFromFCoords(const FCoords& FC);
	friend FCoords FCoordsFromFMatrix(const FMatrix& FM);

};

FMatrix CombineTransforms(const FMatrix& M, const FMatrix& N);

// Conversions for Unreal1 coordinate system class.

inline FMatrix FMatrixFromFCoords(const FCoords& FC) 
{
	FMatrix M;
	M.XPlane = FPlane( FC.XAxis.X, FC.XAxis.Y, FC.XAxis.Z, FC.Origin.X );
	M.YPlane = FPlane( FC.YAxis.X, FC.YAxis.Y, FC.YAxis.Z, FC.Origin.Y );
	M.ZPlane = FPlane( FC.ZAxis.X, FC.ZAxis.Y, FC.ZAxis.Z, FC.Origin.Z );
	M.WPlane = FPlane( 0.f,        0.f,        0.f,        1.f         );
	return M;
}

inline FCoords FCoordsFromFMatrix(const FMatrix& FM)
{
	FCoords C;
	C.Origin = FVector( FM.XPlane.W, FM.YPlane.W, FM.ZPlane.W );
	C.XAxis  = FVector( FM.XPlane.X, FM.XPlane.Y, FM.XPlane.Z );
	C.YAxis  = FVector( FM.YPlane.X, FM.YPlane.Y, FM.YPlane.Z );
	C.ZAxis  = FVector( FM.ZPlane.X, FM.ZPlane.Y, FM.ZPlane.Z );
	return C;
}
/*-----------------------------------------------------------------------------
	CDH: Additional coords-related functions and operators
-----------------------------------------------------------------------------*/
#if DNF

inline FVector& FVector::operator >>= (const FCoords& inC) { *this = TransformPointBy(inC); return(*this); }
inline FVector FVector::operator >> (const FCoords& inC) const { return(TransformPointBy(inC)); }
inline FVector& FVector::operator <<= (const FCoords& inC) { *this = TransformPointBy(inC.Transpose()); return(*this); }
inline FVector FVector::operator << (const FCoords& inC) const { return(TransformPointBy(inC.Transpose())); }

inline FCoords& FCoords::operator >>= (const FCoords& inC) { return(*this *= inC); }
inline FCoords FCoords::operator >> (const FCoords& inC) const { return(*this * inC); }
inline FCoords& FCoords::operator <<= (const FCoords& inC) { return(*this *= inC.Transpose()); }
inline FCoords FCoords::operator << (const FCoords& inC) const { return(*this * inC.Transpose()); }

inline FCoords& FCoords::operator >>= (const FVector& inP) { return(*this *= inP); }
inline FCoords FCoords::operator >> (const FVector& inP) const { return(*this * inP); }
inline FCoords& FCoords::operator <<= (const FVector& inP) { return(*this /= inP); }
inline FCoords FCoords::operator << (const FVector& inP) const { return(*this / inP); }

inline FCoords& FCoords::operator >>= (const FRotator& inR) { return(*this *= inR); }
inline FCoords FCoords::operator >> (const FRotator& inR) const { return(*this * inR); }
inline FCoords& FCoords::operator <<= (const FRotator& inR) { return(*this /= inR); }
inline FCoords FCoords::operator << (const FRotator& inR) const { return(*this / inR); }

inline FCoords FCoords::operator ~ () const { return(Transpose()); }
inline FCoords FCoords::operator & (const FCoords& inC) const { return(~(*this) << inC); }

inline FCoords FCoords::Axes() const { return(FCoords(FVector(0,0,0), XAxis, YAxis, ZAxis)); }

inline FCoords::FCoords(const FQuat& inQ)
{
	FLOAT x(inQ.V.X), y(inQ.V.Y), z(inQ.V.Z), w(inQ.S);
	FLOAT x2(x*2.0f), y2(y*2.0f), z2(z*2.0f), w2(w*2.0f);
	FLOAT xx2(x*x2), yy2(y*y2), zz2(z*z2);
	FLOAT xy2(x*y2), xz2(x*z2), xw2(x*w2), yz2(y*z2), yw2(y*w2), zw2(z*w2);

	XAxis = FVector(1.0f-(yy2+zz2), xy2+zw2, xz2-yw2);
	YAxis = FVector(xy2-zw2, 1.0f-(xx2+zz2), yz2+xw2);
	ZAxis = FVector(xz2+yw2, yz2-xw2, 1.0f-(xx2+yy2));
	Origin = FVector(0,0,0);
}

// FQuat functions
inline FQuat::FQuat(const FCoords& inC)
{
	// verify the axes are completely normalized
	FCoords adjC(inC);
	adjC.XAxis.Normalize();
	adjC.YAxis.Normalize();
	adjC.ZAxis.Normalize();
	
	static INT rot1[3] = { 1, 2, 0 };
	const FLOAT* c[3] = { &adjC.XAxis.X, &adjC.YAxis.X, &adjC.ZAxis.X };
	INT i, j, k;
	FLOAT d, sq, q[4];
	d = c[0][0] + c[1][1] + c[2][2];
	if (d > 0.0)
	{
		sq = (FLOAT)appSqrt(d+1.0f);
		S = sq * 0.5f;
		sq = 0.5f / sq;
		V.X = (c[1][2] - c[2][1])*sq;
		V.Y = (c[2][0] - c[0][2])*sq;
		V.Z = (c[0][1] - c[1][0])*sq;		
		return;
	}
	i=0;
	if (c[1][1] > c[0][0]) i=1;
	if (c[2][2] > c[i][i]) i=2;
	j = rot1[i];
	k = rot1[j];
	sq = (FLOAT)appSqrt((c[i][i]-(c[j][j]+c[k][k])) + 1.0f);
	q[i] = sq*0.5f;
	if (sq!=0.0f)
		sq = 0.5f / sq;
	S = (c[j][k] - c[k][j])*sq;
	q[j] = (c[i][j] + c[j][i])*sq;
	q[k] = (c[i][k] + c[k][i])*sq;
	V.X = q[0];
	V.Y = q[1];
	V.Z = q[2];
}
inline void FQuat::Slerp(const FQuat& inQ1, const FQuat& inQ2, FLOAT inAlpha1, FLOAT inAlpha2, UBOOL bLerpOnly)
{
	if (inQ1 == inQ2)
	{
		*this = inQ1;
		return;
	}

	FQuat q2temp;
	FLOAT om, cosom, sinom, cosinom;
	FLOAT s1, s2;

	q2temp = inQ2;
	cosom = inQ1 | inQ2;
	if (cosom < 0.0)
	{
		cosom = -cosom;
		q2temp = -q2temp;
	}
	if (((1.0f - cosom) > KINDA_SMALL_NUMBER) && (!bLerpOnly))
	{
		om = (FLOAT)appAcos(cosom);
		if ((om >= KINDA_SMALL_NUMBER) && ((PI-om) >= KINDA_SMALL_NUMBER)/* && _finite(om)*/)
		{
			sinom = (FLOAT)appSin(om);
			cosinom = 1.0f / sinom;
			s1 = (FLOAT)appSin(inAlpha1*om)*cosinom;
			s2 = (FLOAT)appSin(inAlpha2*om)*cosinom;
			
			S = inQ1.S*s1 + q2temp.S*s2;
			V = inQ1.V*s1 + q2temp.V*s2;
			return;
		}
	}
	S = inQ1.S*inAlpha1 + q2temp.S*inAlpha2;
	V = inQ1.V*inAlpha1 + q2temp.V*inAlpha2;
	Normalize();
}

#endif // #if DNF

// NJS:
inline void KRSpline_Sample( float t, 
					         FVector &NewLocation,  FRotator &NewRotation,
  					         FVector p1,			FRotator PreviousRotation,
					         FVector p2,		    FRotator Rotation,
					         FVector p3,			FRotator NextRotation,
					         FVector p4,			FRotator Next2Rotation)

{
    float t3, t2, opt1, opt2, opt3, opt4;
    
    t2 = t*t;
    t3 = t2*t;

 // Q(t) = .5(P1(-t^3+2t^2-t) + P2(3t^3-5t^2+2) + P3(-3t^3+4t^2+t) + P4(t^3-t^2))

	opt1 = -t3+2.f*t2-t;
	opt2 = 3.f*t3-5.f*t2+2.;
	opt3 = -3.f*t3+4.f*t2+t;
	opt4 = t3-t2;

	NewLocation=.5f*((p1*opt1)+(p2*opt2)+(p3*opt3)+(p4*opt4));
	NewRotation=.5f*((PreviousRotation*opt1)+(Rotation*opt2)+(NextRotation*opt3)+(Next2Rotation*opt4));

}

inline FLOAT Splerp( FLOAT F )
{
	FLOAT S = Square(F);
	return (1.f/16.f)*S*S - (1.f/2.f)*S + 1;
}

inline void CubicSpline_Sample(float PhysAlpha,
					           FVector &NewLocation,  FRotator &NewRotation,
  					           FVector p1,		  	  FRotator PreviousRotation,
					           FVector p2,		      FRotator Rotation,
					           FVector p3,			  FRotator NextRotation,
					           FVector p4,			  FRotator Next2Rotation)
{
	// Cubic spline interpolation.
	FLOAT W0 = Splerp(PhysAlpha+1.f);
	FLOAT W1 = Splerp(PhysAlpha+0.f);
	FLOAT W2 = Splerp(PhysAlpha-1.f);
	FLOAT W3 = Splerp(PhysAlpha-2.f);
	FLOAT RW = 1.f / (W0 + W1 + W2 + W3);
	NewLocation = (W0*p1 + W1*p2 + W2*p3 + W3*p4)*RW;
	NewRotation = (W0*PreviousRotation + W1*Rotation + W2*NextRotation + W3*Next2Rotation)*RW;
}

class CORE_API Cylinder
{
    protected:
        FVector m_Origin;
        FVector m_Axis;
        FLOAT   m_Radius;
        FLOAT   m_Height;

    public:
        Cylinder() { m_Radius=0; m_Height=0; };
        Cylinder( FVector origin, FVector axis, FLOAT radius, FLOAT height );
        inline void setOrigin( FVector o ){ m_Origin = o; };
        inline void setAxis( FVector a ){ m_Axis = a; };
        inline void setHeight( FLOAT h ){ m_Height = h; };
        inline void setRadius( FLOAT r ){ m_Radius = r; };
        UBOOL       Intersect( FVector rayOrigin, FVector rayDir, FLOAT *in_dist=NULL, FLOAT *out_dist=NULL );
        UBOOL       Inside( FVector p );
        FLOAT       Distance( FVector p );
        UBOOL       ClipObj (
                            FVector  	&raybase,	/* Base of the intersection ray */
	                        FVector		&raycos,  	/* Direction cosines of the ray */
	                        FPlane		&bot,		/* Bottom end-cap plane		*/
	                        FPlane		&top,		/* Top end-cap plane		*/
	                        FLOAT       &objin,		/* Entering distance		*/
	                        FLOAT		&objout	    /* Exiting  distance		*/
                            );
};


/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
