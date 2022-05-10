#ifndef __VECMAIN_H__
#define __VECMAIN_H__
//****************************************************************************
//**
//**    VECMAIN.H
//**    Header - Vector Math
//**
//**	Note: The function bodies are not extensively documented, since the
//**	the classes are of such a primitive nature that they're basically
//**	self-documenting.  A background in vector geometry should be
//**	sufficient enough to understand the contents of these classes.
//**
//****************************************************************************
//============================================================================
//    HEADERS
//============================================================================
#include "Kernel.h"
#include "MathFlt.h"
//============================================================================
//    DEFINITIONS / ENUMERATIONS / SIMPLE TYPEDEFS
//============================================================================
#ifdef KRN_MSVC6
#define VEC_INLINE __forceinline
#else
#define VEC_INLINE inline
#endif

#ifdef KRN_INTEL
//#define VEC_ASM
#endif

//============================================================================
//    CLASSES / STRUCTURES
//============================================================================
class VVec2; // 2D vector/point
class VVec3; // 3D vector/point
class VVec4; // 4D vector/point
class VQuat3; // 3D quaternion
class VEulers3; // 3D Roll/Pitch/Yaw eulers
class VAxes3; // 3D orthonormal axial frame
class VCoords3; // 3D orthonormal coordinate system

/*
	VVec2
	2D vector/point
*/
class VVec2
{
public:
	float x, y;

	VEC_INLINE VVec2() {}
	VEC_INLINE VVec2(const VVec2& inV) { x = inV.x; y = inV.y; }
	VEC_INLINE VVec2(float inX, float inY) { x = inX; y = inY; }

	VEC_INLINE VVec2& operator = (const VVec2& inV) { x = inV.x; y = inV.y; return(*this); }
	VEC_INLINE VVec2& operator += (const VVec2& inV) { x += inV.x; y += inV.y; return(*this); }
	VEC_INLINE VVec2& operator -= (const VVec2& inV) { x -= inV.x; y -= inV.y; return(*this); }
	VEC_INLINE VVec2& operator *= (const VVec2& inV) { x *= inV.x; y *= inV.y; return(*this); } // component multiply
	VEC_INLINE VVec2& operator /= (const VVec2& inV) { x /= inV.x; y /= inV.y; return(*this); } // component divide
	VEC_INLINE VVec2& operator *= (float inScale) { x *= inScale; y *= inScale; return(*this); }
	VEC_INLINE VVec2& operator /= (float inScale) { x /= inScale; y /= inScale; return(*this); }

	VEC_INLINE operator float* () { return((float*)this); }
	
	VEC_INLINE float Length2() const { return(x*x + y*y); }
	VEC_INLINE float Length() const { return((float)sqrt(x*x + y*y)); }
	VEC_INLINE float Normalize() { float a(Length()); float b(1.0f/a); x *= b; y *= b; return(a); }
	VEC_INLINE int Dominant()
	{
		int d(0);
		if (M_Fabs(y) > M_Fabs(x))
			d=1;
		return(d);
	}

	VEC_INLINE friend VVec2 operator - (const VVec2& inV) { return(VVec2(-inV.x, -inV.y)); }
	VEC_INLINE friend VVec2 operator + (const VVec2& inV1, const VVec2& inV2) { return(VVec2(inV1.x+inV2.x, inV1.y+inV2.y)); }
	VEC_INLINE friend VVec2 operator - (const VVec2& inV1, const VVec2& inV2) { return(VVec2(inV1.x-inV2.x, inV1.y-inV2.y)); }
	VEC_INLINE friend VVec2 operator * (const VVec2& inV1, const VVec2& inV2) { return(VVec2(inV1.x*inV2.x, inV1.y*inV2.y)); } // component multiply
	VEC_INLINE friend VVec2 operator / (const VVec2& inV1, const VVec2& inV2) { return(VVec2(inV1.x/inV2.x, inV1.y/inV2.y)); } // component divide
	VEC_INLINE friend VVec2 operator * (const VVec2& inV, float inScale) { return(VVec2(inV.x*inScale, inV.y*inScale)); }
	VEC_INLINE friend VVec2 operator / (const VVec2& inV, float inScale) { return(VVec2(inV.x/inScale, inV.y/inScale)); }
	VEC_INLINE friend float operator & (const VVec2& inV1, const VVec2& inV2) { return((inV2 - inV1).Length()); } // distance between
	VEC_INLINE friend float operator | (const VVec2& inV1, const VVec2& inV2) { return(inV1.x*inV2.x + inV1.y*inV2.y); } // dot product
	VEC_INLINE friend VVec2 operator ~ (const VVec2& inV) { return(VVec2(inV.y, -inV.x)); } // perpendicular
	VEC_INLINE friend bool operator ! (const VVec2& inV) { return(inV.Length2() <= M_EPSILON2); } // near-zero length
	VEC_INLINE friend bool operator == (const VVec2& inV1, const VVec2& inV2) { return((inV2-inV1).Length2() <= M_EPSILON2); } // equality operators test approximately equal position
	VEC_INLINE friend bool operator != (const VVec2& inV1, const VVec2& inV2) { return((inV2-inV1).Length2() > M_EPSILON2); }
	VEC_INLINE friend bool operator <= (const VVec2& inV1, const VVec2& inV2) { return(inV1.Length2() <= (inV2.Length2()+M_EPSILON2)); } // lesser/greater operators test relative length
	VEC_INLINE friend bool operator >= (const VVec2& inV1, const VVec2& inV2) { return(inV1.Length2() >= (inV2.Length2()-M_EPSILON2)); }
	VEC_INLINE friend bool operator < (const VVec2& inV1, const VVec2& inV2) { return(inV1.Length2() < (inV2.Length2()-M_EPSILON2)); }
	VEC_INLINE friend bool operator > (const VVec2& inV1, const VVec2& inV2) { return(inV1.Length2() > (inV2.Length2()+M_EPSILON2)); }
};

/*
	VVec3
	3D vector/point
*/
class VVec3
{
public:
	float x, y, z;

	VEC_INLINE VVec3() {}
	VEC_INLINE VVec3(const VVec3& inV) { x = inV.x; y = inV.y; z = inV.z; }	
	VEC_INLINE VVec3(float inX, float inY, float inZ) { x = inX; y = inY; z = inZ; }
	VEC_INLINE VVec3(const VVec2& inV) { x = inV.x; y = inV.y; z = 0.0; }

	VEC_INLINE VVec3& operator = (const VVec3& inV) { x = inV.x; y = inV.y; z = inV.z; return(*this); }
	VEC_INLINE VVec3& operator += (const VVec3& inV) { x += inV.x; y += inV.y; z += inV.z; return(*this); }
	VEC_INLINE VVec3& operator -= (const VVec3& inV) { x -= inV.x; y -= inV.y; z -= inV.z; return(*this); }
	VEC_INLINE VVec3& operator *= (const VVec3& inV) { x *= inV.x; y *= inV.y; z *= inV.z; return(*this); }
	VEC_INLINE VVec3& operator /= (const VVec3& inV) { x /= inV.x; y /= inV.y; z /= inV.z; return(*this); }
	VEC_INLINE VVec3& operator *= (float inScale) { x *= inScale; y *= inScale; z *= inScale; return(*this); }
	VEC_INLINE VVec3& operator /= (float inScale) { x /= inScale; y /= inScale; z /= inScale; return(*this); }
	VEC_INLINE VVec3& operator >>= (const VAxes3& inF); // world vector -> frame vector
	VEC_INLINE VVec3& operator <<= (const VAxes3& inF); // frame vector -> world vector
	VEC_INLINE VVec3& operator >>= (const VCoords3& inC); // world position -> coords position
	VEC_INLINE VVec3& operator <<= (const VCoords3& inC); // coords position -> world position

	VEC_INLINE operator float* () { return((float*)this); }
	VEC_INLINE operator float* () const { return((float*)this); }

	VEC_INLINE float Length2() const { return(x*x + y*y + z*z); }
	VEC_INLINE float Length() const { return((float)sqrt(x*x + y*y + z*z)); }
	VEC_INLINE float Normalize() { float a(Length()); float b(1.0f/a); x *= b; y *= b; z *= b; return(a); }
	VEC_INLINE int Dominant() const
	{
		int d(0);
		if (M_Fabs(y) > M_Fabs(x))
			d=1;
		if (M_Fabs(z) > M_Fabs((*this)[d]))
			d=2;
		return(d);
	}

	VEC_INLINE friend VVec3 operator - (const VVec3& inV) { return(VVec3(-inV.x, -inV.y, -inV.z)); }
	VEC_INLINE friend VVec3 operator + (const VVec3& inV1, const VVec3& inV2) { return(VVec3(inV1.x+inV2.x, inV1.y+inV2.y, inV1.z+inV2.z)); }
	VEC_INLINE friend VVec3 operator - (const VVec3& inV1, const VVec3& inV2) { return(VVec3(inV1.x-inV2.x, inV1.y-inV2.y, inV1.z-inV2.z)); }
	VEC_INLINE friend VVec3 operator * (const VVec3& inV1, const VVec3& inV2) { return(VVec3(inV1.x*inV2.x, inV1.y*inV2.y, inV1.z*inV2.z)); }
	VEC_INLINE friend VVec3 operator / (const VVec3& inV1, const VVec3& inV2) { return(VVec3(inV1.x/inV2.x, inV1.y/inV2.y, inV1.z/inV2.z)); }
	VEC_INLINE friend VVec3 operator * (const VVec3& inV, float inScale) { return(VVec3(inV.x*inScale, inV.y*inScale, inV.z*inScale)); }
	VEC_INLINE friend VVec3 operator / (const VVec3& inV, float inScale) { return(VVec3(inV.x/inScale, inV.y/inScale, inV.z/inScale)); }
	VEC_INLINE friend float operator & (const VVec3& inV1, const VVec3& inV2) { return((inV2 - inV1).Length()); }
	VEC_INLINE friend float operator | (const VVec3& inV1, const VVec3& inV2) { return(inV1.x*inV2.x + inV1.y*inV2.y + inV1.z*inV2.z); }
	VEC_INLINE friend VVec3 operator ^ (const VVec3& inV1, const VVec3& inV2) // cross product
	{
		return(VVec3(inV1.y*inV2.z-inV1.z*inV2.y, inV1.z*inV2.x-inV1.x*inV2.z, inV1.x*inV2.y-inV1.y*inV2.x));
	}
	VEC_INLINE friend VVec3 operator ~ (const VVec3& inV) // arbitrary perpendicular
	{
		VVec3 a(0,0,0);
		a[(inV.Dominant()+1)%3] = 1.f;
		return(a ^ inV);
	}
	VEC_INLINE friend bool operator ! (const VVec3& inV) { return(inV.Length2() <= M_EPSILON2); }
	VEC_INLINE friend bool operator == (const VVec3& inV1, const VVec3& inV2) { return((inV2-inV1).Length2() <= M_EPSILON2); }
	VEC_INLINE friend bool operator != (const VVec3& inV1, const VVec3& inV2) { return((inV2-inV1).Length2() > M_EPSILON2); }
	VEC_INLINE friend bool operator <= (const VVec3& inV1, const VVec3& inV2) { return(inV1.Length2() <= (inV2.Length2()+M_EPSILON2)); }
	VEC_INLINE friend bool operator >= (const VVec3& inV1, const VVec3& inV2) { return(inV1.Length2() >= (inV2.Length2()-M_EPSILON2)); }
	VEC_INLINE friend bool operator < (const VVec3& inV1, const VVec3& inV2) { return(inV1.Length2() < (inV2.Length2()-M_EPSILON2)); }
	VEC_INLINE friend bool operator > (const VVec3& inV1, const VVec3& inV2) { return(inV1.Length2() > (inV2.Length2()+M_EPSILON2)); }
};

/*
	VVec4
	4D vector/point
*/
class VVec4
{
public:
	float x, y, z, w;

	VEC_INLINE VVec4() {}
	VEC_INLINE VVec4(const VVec4& inV) { x = inV.x; y = inV.y; z = inV.z; w = inV.w; }
	VEC_INLINE VVec4(float inX, float inY, float inZ, float inW) { x = inX; y = inY; z = inZ; w = inW; }
	VEC_INLINE VVec4(const VVec3& inV) { x = inV.x; y = inV.y; z = inV.z; w = 0.0; }
	VEC_INLINE VVec4(const VVec2& inV) { x = inV.x; y = inV.y; z = 0.0; w = 0.0; }

	VEC_INLINE VVec4& operator = (const VVec4& inV) { x = inV.x; y = inV.y; z = inV.z; w = inV.w; return(*this); }
	VEC_INLINE VVec4& operator += (const VVec4& inV) { x += inV.x; y += inV.y; z += inV.z; w += inV.w; return(*this); }
	VEC_INLINE VVec4& operator -= (const VVec4& inV) { x -= inV.x; y -= inV.y; z -= inV.z; w -= inV.w; return(*this); }
	VEC_INLINE VVec4& operator *= (const VVec4& inV) { x *= inV.x; y *= inV.y; z *= inV.z; w *= inV.w; return(*this); }
	VEC_INLINE VVec4& operator /= (const VVec4& inV) { x /= inV.x; y /= inV.y; z /= inV.z; w /= inV.w; return(*this); }
	VEC_INLINE VVec4& operator *= (float inScale) { x *= inScale; y *= inScale; z *= inScale; w *= inScale; return(*this); }
	VEC_INLINE VVec4& operator /= (float inScale) { x /= inScale; y /= inScale; z /= inScale; w *= inScale; return(*this); }

	VEC_INLINE operator float* () { return((float*)this); }

	VEC_INLINE float Length2() const { return(x*x + y*y + z*z + w*w); }
	VEC_INLINE float Length() const { return((float)sqrt(x*x + y*y + z*z + w*w)); }
	VEC_INLINE float Normalize() { float a(Length()); float b(1.0f/a); x *= b; y *= b; z *= b; w *= b; return(a); }
	VEC_INLINE int Dominant()
	{
		int d(0);
		if (M_Fabs(y) > M_Fabs(x))
			d=1;
		if (M_Fabs(z) > M_Fabs((*this)[d]))
			d=2;
		if (M_Fabs(w) > M_Fabs((*this)[d]))
			d=3;
		return(d);
	}

	VEC_INLINE friend VVec4 operator - (const VVec4& inV) { return(VVec4(-inV.x, -inV.y, -inV.z, -inV.w)); }
	VEC_INLINE friend VVec4 operator + (const VVec4& inV1, const VVec4& inV2) { return(VVec4(inV1.x+inV2.x, inV1.y+inV2.y, inV1.z+inV2.z, inV1.w+inV2.w)); }
	VEC_INLINE friend VVec4 operator - (const VVec4& inV1, const VVec4& inV2) { return(VVec4(inV1.x-inV2.x, inV1.y-inV2.y, inV1.z-inV2.z, inV1.w-inV2.w)); }
	VEC_INLINE friend VVec4 operator * (const VVec4& inV1, const VVec4& inV2) { return(VVec4(inV1.x*inV2.x, inV1.y*inV2.y, inV1.z*inV2.z, inV1.w*inV2.w)); }
	VEC_INLINE friend VVec4 operator / (const VVec4& inV1, const VVec4& inV2) { return(VVec4(inV1.x/inV2.x, inV1.y/inV2.y, inV1.z/inV2.z, inV1.w/inV2.w)); }
	VEC_INLINE friend VVec4 operator * (const VVec4& inV, float inScale) { return(VVec4(inV.x*inScale, inV.y*inScale, inV.z*inScale, inV.w*inScale)); }
	VEC_INLINE friend VVec4 operator / (const VVec4& inV, float inScale) { return(VVec4(inV.x/inScale, inV.y/inScale, inV.z/inScale, inV.w/inScale)); }
	VEC_INLINE friend float operator & (const VVec4& inV1, const VVec4& inV2) { return((inV2 - inV1).Length()); }
	VEC_INLINE friend float operator | (const VVec4& inV1, const VVec4& inV2) { return(inV1.x*inV2.x + inV1.y*inV2.y + inV1.z*inV2.z + inV1.w*inV2.w); }
	VEC_INLINE friend bool operator ! (const VVec4& inV) { return(inV.Length2() <= M_EPSILON2); }
	VEC_INLINE friend bool operator == (const VVec4& inV1, const VVec4& inV2) { return((inV2-inV1).Length2() <= M_EPSILON2); }
	VEC_INLINE friend bool operator != (const VVec4& inV1, const VVec4& inV2) { return((inV2-inV1).Length2() > M_EPSILON2); }
	VEC_INLINE friend bool operator <= (const VVec4& inV1, const VVec4& inV2) { return(inV1.Length2() <= (inV2.Length2()+M_EPSILON2)); }
	VEC_INLINE friend bool operator >= (const VVec4& inV1, const VVec4& inV2) { return(inV1.Length2() >= (inV2.Length2()-M_EPSILON2)); }
	VEC_INLINE friend bool operator < (const VVec4& inV1, const VVec4& inV2) { return(inV1.Length2() < (inV2.Length2()-M_EPSILON2)); }
	VEC_INLINE friend bool operator > (const VVec4& inV1, const VVec4& inV2) { return(inV1.Length2() > (inV2.Length2()+M_EPSILON2)); }
};

/*
	VQuat3
	3D quaternion
*/
class VQuat3
{
public:
	VVec3 v; // vector component
	float s; // scalar component

	VEC_INLINE VQuat3() {}
	VEC_INLINE VQuat3(const VQuat3& inQ) { v = inQ.v; s = inQ.s; }
	VEC_INLINE VQuat3(const VVec3& inV, float inS) { v = inV; s = inS; } // raw components, NOT axis/angle
	VEC_INLINE void AxisAngle(const VVec3& inAxis, float inAngle) // construct in axis/angle form (named constructor)
	{
		v = -inAxis; v.Normalize(); v *= (float)sin(inAngle*0.5f); s = (float)cos(inAngle*0.5f);
	}
	VEC_INLINE VQuat3(const VAxes3& inF);

	VEC_INLINE VQuat3& operator = (const VQuat3& inQ) { v = inQ.v; s = inQ.s; return(*this); }
	VEC_INLINE VQuat3& operator += (const VQuat3& inQ) { v += inQ.v; s += inQ.s; return(*this); }
	VEC_INLINE VQuat3& operator -= (const VQuat3& inQ) { v -= inQ.v; s -= inQ.s; return(*this); }
	VEC_INLINE VQuat3& operator *= (const VQuat3& inQ) { *this = *this * inQ; return(*this); }
	VEC_INLINE VQuat3& operator *= (float inScale) { v *= inScale; s *= inScale; return(*this); }
	VEC_INLINE VQuat3& operator /= (float inScale) { v /= inScale; s /= inScale; return(*this); }

	VEC_INLINE float Length2() const { return(v.x*v.x + v.y*v.y + v.z*v.z + s*s); }
	VEC_INLINE float Length() const { return((float)sqrt(v.x*v.x + v.y*v.y + v.z*v.z + s*s)); }
	VEC_INLINE float Normalize() { float a(Length()); float b(1.0f/a); v *= b; s *= b; return(a); }
	VEC_INLINE void Slerp(const VQuat3& inQ1, const VQuat3& inQ2, float inAlpha1, float inAlpha2, bool lerpOnly=0);

	VEC_INLINE friend VQuat3 operator - (const VQuat3& inQ) { return(VQuat3(-inQ.v, -inQ.s)); }
	VEC_INLINE friend VQuat3 operator + (const VQuat3& inQ1, const VQuat3& inQ2) { return(VQuat3(inQ1.v+inQ2.v, inQ1.s+inQ2.s)); }
	VEC_INLINE friend VQuat3 operator - (const VQuat3& inQ1, const VQuat3& inQ2) { return(VQuat3(inQ1.v-inQ2.v, inQ1.s-inQ2.s)); }
	VEC_INLINE friend VQuat3 operator * (const VQuat3& inQ1, const VQuat3& inQ2)
	{
		return(VQuat3(inQ2.v*inQ1.s + inQ1.v*inQ2.s + (inQ1.v ^ inQ2.v), inQ1.s*inQ2.s - (inQ1.v | inQ2.v)));
	}
	VEC_INLINE friend VQuat3 operator * (const VQuat3& inQ, float inScale) { return(VQuat3(inQ.v*inScale, inQ.s*inScale)); }
	VEC_INLINE friend VQuat3 operator / (const VQuat3& inQ, float inScale) { return(VQuat3(inQ.v/inScale, inQ.s/inScale)); }
	VEC_INLINE friend float operator | (const VQuat3& inQ1, const VQuat3& inQ2) { return((inQ1.v | inQ2.v) + (inQ1.s * inQ2.s)); }
	VEC_INLINE friend bool operator == (const VQuat3& inQ1, const VQuat3& inQ2)
	{
		return((M_Fabs(inQ1.s - inQ2.s) <= M_EPSILON)
			&& (M_Fabs(inQ1.v.x - inQ2.v.x) <= M_EPSILON)
			&& (M_Fabs(inQ1.v.y - inQ2.v.y) <= M_EPSILON)
			&& (M_Fabs(inQ1.v.z - inQ2.v.z) <= M_EPSILON));
	}
	VEC_INLINE friend bool operator != (const VQuat3& inQ1, const VQuat3& inQ2) { return(!(inQ1 == inQ2)); }
};

/*
	VEulers3
	3D Roll/Pitch/Yaw eulers

	All angles are in radians, following right-hand rule conventions (CCW winding about near-pointed axis)
*/
class VEulers3
{
public:
	float r; // roll in radians, about Z axis
	float p; // pitch in radians, about X axis
	float y; // yaw in radians, about Y axis

	VEC_INLINE VEulers3() : r(0), p(0), y(0) {}
	VEC_INLINE VEulers3(const VEulers3& inE) { r = inE.r; p = inE.p; y = inE.y; }
	VEC_INLINE VEulers3(float inRoll, float inPitch, float inYaw) { r = inRoll; p = inPitch; y = inYaw; }
	VEC_INLINE VEulers3(const VAxes3& inF);

	VEC_INLINE VEulers3& operator = (const VEulers3& inE) { r = inE.r; p = inE.p; y = inE.y; return(*this); }
	VEC_INLINE VEulers3& operator += (const VEulers3& inE) { r += inE.r; p += inE.p; y += inE.y; return(*this); }
	VEC_INLINE VEulers3& operator -= (const VEulers3& inE) { r -= inE.r; p -= inE.p; y -= inE.y; return(*this); }

	VEC_INLINE friend VEulers3 operator + (const VEulers3& inE1, const VEulers3& inE2) { return(VEulers3(inE1.r+inE2.r, inE1.p+inE2.p, inE1.y+inE2.y)); }
	VEC_INLINE friend VEulers3 operator - (const VEulers3& inE1, const VEulers3& inE2) { return(VEulers3(inE1.r-inE2.r, inE1.p-inE2.p, inE1.y-inE2.y)); }
	VEC_INLINE friend bool operator == (const VEulers3& inE1, const VEulers3& inE2)
	{
		return((M_Fabs(inE1.r - inE2.r) <= M_EPSILON)
			&& (M_Fabs(inE1.p - inE2.p) <= M_EPSILON)
			&& (M_Fabs(inE1.y - inE2.y) <= M_EPSILON));
	}
	VEC_INLINE friend bool operator != (const VEulers3& inE1, const VEulers3& inE2) { return(!(inE1 == inE2)); }
};

/*
	VAxes3
	3D orthonormal axial frame
*/
class VAxes3
{
public:
	VVec3 vX, vY, vZ; // local normalized X, Y, and Z axes

	VEC_INLINE VAxes3() : vX(1,0,0), vY(0,1,0), vZ(0,0,1) {}
	VEC_INLINE VAxes3(const VAxes3& inF) { vX = inF.vX; vY = inF.vY; vZ = inF.vZ; }
	VEC_INLINE VAxes3(const VVec3& inX, const VVec3& inY, const VVec3& inZ) { vX = inX; vY = inY; vZ = inZ; }
	VEC_INLINE VAxes3(const VVec3& inAxis, float inAngle) { VQuat3 q; q.AxisAngle(inAxis,inAngle); *this = q; }
	VEC_INLINE VAxes3(const VQuat3& inQ)
	{
		float x(inQ.v.x), y(inQ.v.y), z(inQ.v.z), w(inQ.s);
		float x2(x*2.0f), y2(y*2.0f), z2(z*2.0f), w2(w*2.0f);
		float xx2(x*x2), yy2(y*y2), zz2(z*z2), ww2(w*w2);
		float xy2(x*y2), xz2(x*z2), xw2(x*w2), yz2(y*z2), yw2(y*w2), zw2(z*w2);

		vX = VVec3(1.0f-(yy2+zz2), xy2+zw2, xz2-yw2);
		vY = VVec3(xy2-zw2, 1.0f-(xx2+zz2), yz2+xw2);
		vZ = VVec3(xz2+yw2, yz2-xw2, 1.0f-(xx2+yy2));
	}
	VEC_INLINE VAxes3(const VEulers3& inE)
	{
		VQuat3 q;
		*this = VAxes3();
		q.AxisAngle(VVec3(0,0,1), inE.r);
		*this >>= q;
		q.AxisAngle(VVec3(1,0,0), inE.p);
		*this >>= q;
		q.AxisAngle(VVec3(0,1,0), inE.y);
		*this >>= q;
	}
	VEC_INLINE VAxes3(const VVec3& inV)
	{
		vZ = inV; vZ.Normalize();
		vY = ~inV; vY.Normalize();
		vX = vY ^ vZ; vX.Normalize();
	}

	VEC_INLINE VAxes3& operator = (const VAxes3& inF) { vX = inF.vX; vY = inF.vY; vZ = inF.vZ; return(*this); }
	VEC_INLINE VAxes3& operator >>= (const VAxes3& inF) { *this = *this >> inF; return(*this); }
	VEC_INLINE VAxes3& operator <<= (const VAxes3& inF) { *this = *this << inF; return(*this); }

	VEC_INLINE friend VAxes3 operator ~ (const VAxes3& inF) { return(VAxes3() >> inF); } // inverse (transpose)
	VEC_INLINE friend VAxes3 operator & (const VAxes3& inF1, const VAxes3& inF2) { return(~inF2 << inF1); } // delta frame, frame1 >> result == frame2
	VEC_INLINE friend VVec3 operator >> (const VVec3& inV, const VAxes3& inF) // world vector -> frame vector
	{
		return(VVec3(
			(inV|inF.vX),
			(inV|inF.vY),
			(inV|inF.vZ)
			));
	}
	VEC_INLINE friend VVec3 operator << (const VVec3& inV, const VAxes3& inF) // frame vector -> world vector
	{
		return(VVec3(
			(inV.x*inF.vX.x + inV.y*inF.vY.x + inV.z*inF.vZ.x),
			(inV.x*inF.vX.y + inV.y*inF.vY.y + inV.z*inF.vZ.y),
			(inV.x*inF.vX.z + inV.y*inF.vY.z + inV.z*inF.vZ.z)
			));
	}
	VEC_INLINE friend VAxes3 operator >> (const VAxes3& inF1, const VAxes3& inF2) // world frame1 -> frame2-relative frame1
	{
		return(VAxes3(inF1.vX >> inF2, inF1.vY >> inF2, inF1.vZ >> inF2));
	}
	VEC_INLINE friend VAxes3 operator << (const VAxes3& inF1, const VAxes3& inF2) // frame2-relative frame1 -> world frame1
	{
		return(VAxes3(inF1.vX << inF2, inF1.vY << inF2, inF1.vZ << inF2));
	}
};

/*
	VCoords3
	3D orthonormal coordinate system
	TRS inbound, SRT outbound
*/
#undef VEC_INLINE
#define VEC_INLINE

class VCoords3
{
public:	
	VAxes3 r; // axial frame (rotation)
	VVec3 t; // local origin (translation)
	VVec3 s; // axis scale values (scale)

	VEC_INLINE VCoords3() : r(), t(0,0,0), s(1,1,1) {}
	VEC_INLINE VCoords3(const VCoords3& inC) { r = inC.r; t = inC.t; s = inC.s; }
	VEC_INLINE VCoords3(const VAxes3& inRotate, const VVec3& inTranslate = VVec3(0,0,0), const VVec3& inScale = VVec3(1,1,1) )
	{
		r = inRotate; t = inTranslate; s = inScale;
	}

	VEC_INLINE VCoords3& operator = (const VCoords3& inC){ r = inC.r; t = inC.t; s = inC.s; return(*this); }
	VEC_INLINE VCoords3& operator += (const VVec3& inTranslate) { t += inTranslate; return(*this); }
	VEC_INLINE VCoords3& operator -= (const VVec3& inTranslate) { t -= inTranslate; return(*this); }
	VEC_INLINE VCoords3& operator *= (const VVec3& inScale) { s *= inScale; return(*this); }
	VEC_INLINE VCoords3& operator /= (const VVec3& inScale) { s /= inScale; return(*this); }
	VEC_INLINE VCoords3& operator *= (float inScale) { s *= inScale; return(*this); }
	VEC_INLINE VCoords3& operator /= (float inScale) { s /= inScale; return(*this); }
	VEC_INLINE VCoords3& operator >>= (const VCoords3& inC) { *this = *this >> inC; return(*this); }
	VEC_INLINE VCoords3& operator <<= (const VCoords3& inC) { *this = *this << inC; return(*this); }

	VEC_INLINE friend VCoords3 operator ~ (const VCoords3& inC) { return(VCoords3() >> inC); } // inverse
	VEC_INLINE friend VCoords3 operator & (const VCoords3& inC1, const VCoords3& inC2) { return(~inC2 << inC1); } // delta coords, coords1 >> result == coords2
	VEC_INLINE friend VVec3 operator >> (const VVec3& inV, const VCoords3& inC) // world position -> coords position
	{
		return(((inV-inC.t) >> inC.r) / inC.s);
	}
	VEC_INLINE friend VVec3 operator << (const VVec3& inV, const VCoords3& inC) // coords position -> world position
	{
		return(((inV*inC.s) << inC.r) + inC.t);
	}
	VEC_INLINE friend VCoords3 operator >> (const VCoords3& inC1, const VCoords3& inC2) // world coords1 -> coords2-relative coords1
	{
		return(VCoords3(inC1.r >> inC2.r, inC1.t >> inC2, inC1.s / inC2.s));	
	}
	VEC_INLINE friend VCoords3 operator << (const VCoords3& inC1, const VCoords3& inC2) // coords2-relative coords1 -> world coords1
	{
		return(VCoords3(inC1.r << inC2.r, inC1.t << inC2, inC1.s * inC2.s));
	}
};

#undef VEC_INLINE
#define VEC_INLINE __forceinline

//============================================================================
//    GLOBAL DATA
//============================================================================
//============================================================================
//    GLOBAL FUNCTIONS
//============================================================================
/*
	Color conversion convenience functions.
	Components in both RGB and HSV are in the [0,1] range.
*/
inline VVec3 VEC_RGBToHSV(const VVec3& inRGB)
{
	float r = inRGB.x, g = inRGB.y, b = inRGB.z, v, x, f;
	int i;
	x = M_MIN3(r, g, b);
	v = M_MAX3(r, g, b);
	if (v == x)
		return(VVec3(0, 0, v));
	f = (r == x) ? g - b : ((g == x) ? b - r : r - g);
	i = (r == x) ? 3 : ((g == x) ? 5 : 1);
	return(VVec3((i-f/(v-x))/6.f, (v-x)/v, v));
}

inline VVec3 VEC_HSVToRGB(const VVec3& inHSV)
{
	float h = inHSV.x*6.f, s = inHSV.y, v = inHSV.z, m, n, f;
	int i;
	if (s == 0.f)
		return(VVec3(v,v,v));
	i = (int)h;
	f = h - i;
	if (!(i & 1))
		f = 1 - f;
	m = v * (1 - s);
	n = v * (1 - s*f);
	switch(i)
	{
	case 0: case 6: return(VVec3(v,n,m));
	case 1: return(VVec3(n,v,m));
	case 2: return(VVec3(m,v,n));
	case 3: return(VVec3(m,n,v));
	case 4: return(VVec3(n,m,v));
	case 5: return(VVec3(v,m,n));
	default: return(VVec3(0,0,0));
	}
}

//============================================================================
//    INLINE CLASS METHODS
//============================================================================

/*
	VVec3
*/
VEC_INLINE VVec3& VVec3::operator >>= (const VAxes3& inF) { *this = *this >> inF; return(*this); }
VEC_INLINE VVec3& VVec3::operator <<= (const VAxes3& inF) { *this = *this << inF; return(*this); }
VEC_INLINE VVec3& VVec3::operator >>= (const VCoords3& inC) { *this = *this >> inC; return(*this); }
VEC_INLINE VVec3& VVec3::operator <<= (const VCoords3& inC) { *this = *this << inC; return(*this); }

/*
	VQuat3
*/
VEC_INLINE VQuat3::VQuat3(const VAxes3& inF)
{
	// verify the axes are completely normalized
	VAxes3 adjF(inF);
	adjF.vX.Normalize();
	adjF.vY.Normalize();
	adjF.vZ.Normalize();
	
	static int rot1[3] = { 1, 2, 0 };
	const float* c[3] = { &adjF.vX.x, &adjF.vY.x, &adjF.vZ.x };
	int i, j, k;
	float d, sq, q[4];
	d = c[0][0] + c[1][1] + c[2][2];
	if (d > 0.0)
	{
		sq = (float)sqrt(d+1.0f);
		s = sq * 0.5f;
		sq = 0.5f / sq;
		v.x = (c[1][2] - c[2][1])*sq;
		v.y = (c[2][0] - c[0][2])*sq;
		v.z = (c[0][1] - c[1][0])*sq;		
		return;
	}
	i=0;
	if (c[1][1] > c[0][0]) i=1;
	if (c[2][2] > c[i][i]) i=2;
	j = rot1[i];
	k = rot1[j];
	sq = (float)sqrt((c[i][i]-(c[j][j]+c[k][k])) + 1.0f);
	q[i] = sq*0.5f;
	if (sq!=0.0f)
		sq = 0.5f / sq;
	s = (c[j][k] - c[k][j])*sq;
	q[j] = (c[i][j] + c[j][i])*sq;
	q[k] = (c[i][k] + c[k][i])*sq;
	v.x = q[0];
	v.y = q[1];
	v.z = q[2];
}

VEC_INLINE void VQuat3::Slerp(const VQuat3& inQ1, const VQuat3& inQ2, float inAlpha1, float inAlpha2, bool lerpOnly)
{
	if (inQ1 == inQ2)
	{
		*this = inQ1;
		return;
	}

	VQuat3 q2temp;
	float om, cosom, sinom, cosinom;
	float s1, s2;

	q2temp = inQ2;
	cosom = inQ1 | inQ2;
	if (cosom < 0.0)
	{
		cosom = -cosom;
		q2temp = -q2temp;
	}
	if (((1.0f - cosom) > M_EPSILON) && (!lerpOnly))
	{
		om = (float)acos(cosom);
		if ((om >= M_EPSILON) && ((M_PI-om) >= M_EPSILON) && _finite(om))
		{
			sinom = (float)sin(om);
			cosinom = 1.0f / sinom;
			s1 = (float)sin(inAlpha1*om)*cosinom;
			s2 = (float)sin(inAlpha2*om)*cosinom;
			
			s = inQ1.s*s1 + q2temp.s*s2;
			v = inQ1.v*s1 + q2temp.v*s2;
			return;
		}
	}
	s = inQ1.s*inAlpha1 + q2temp.s*inAlpha2;
	v = inQ1.v*inAlpha1 + q2temp.v*inAlpha2;
	Normalize();
}

/*
	VEulers3
*/
VEC_INLINE VEulers3::VEulers3(const VAxes3& inF)
{
	// pitch is extrapolated from the Z axis, based on its two-dimensional
	// length in the ZX plane, and its Y value
	VVec2 pitchTemp(inF.vZ.z, inF.vZ.x);
	p = (float)-atan2(inF.vZ.y, pitchTemp.Length());

	// yaw is extrapolated from the Z axis as well, based simply on its two-dimensional aspect
	// if the pitch is completely vertical, then this value should be forced to zero since the
	// yaw is indeterminate in such as case
	y = 0.f;
	if (M_Fabs(inF.vZ | VVec3(0,1,0)) < (1.f-M_EPSILON))
		y = (float)atan2(inF.vZ.x, inF.vZ.z);

	// roll is the tricky one.  Do the lame method for now by generating a frame
	// from the roll-less eulers, and checking the axis difference
	r = 0.f;
	VAxes3 f(*this);
	r = (float)-atan2(inF.vY | f.vX, inF.vX | f.vX);
}

/*
	VAxes3
*/
#if 0
VEC_INLINE VVec3 operator >> (const VVec3& inV, const VAxes3& inF) // world vector -> frame vector
{
	return(VVec3(
		(inV|inF.vX),
		(inV|inF.vY),
		(inV|inF.vZ)
		));

	/*
	return(VVec3(
		(inV.x*inF.vX.x + inV.y*inF.vX.y + inV.z*inF.vX.z),
		(inV.x*inF.vY.x + inV.y*inF.vY.y + inV.z*inF.vY.z),
		(inV.x*inF.vZ.x + inV.y*inF.vZ.y + inV.z*inF.vZ.z)
		));

	V: (0, 4, 8)
	A: vX(0, 4, 8) vY(12, 16, 20) vZ(24, 28, 32)

	return(VVec3(
		(v0 * a0 + v4 * a4 + v8 * a8),
		(v0 * a12 + v4 * a16 + v8 * a20),
		(v0 * a24 + v4 * a28 + v8 * a32)));
	*/
	VVec3 result;
	VVec3& outV = result;
	_asm
	{
		mov esi, [inV]
		mov edi, [outV]
		mov ebx, [inF]

		fld dword ptr [esi+0] // x
		fld dword ptr [esi+4] // y x
		fld dword ptr [esi+8] // z y x
		fxch st(2) // x y z

		fld st(0) // x x y z
		fmul dword ptr [ebx+0] // x*vXx x y z
		fld st(1) // x x*vXx x y z
		fmul dword ptr [ebx+12] // x*vYx x*vXx x y z
		fxch st(2) // x x*vY x*vX y z
		fmul dword ptr [ebx+24] // x*vZx x*vYx x*vXx y z
		fxch st(4) // y x*vZx x*vYx x*vXx z

		fld st(0) // y y x*vZx x*vYx x*vXx z
		fmul dword ptr [ebx+4] // y*vXy y x*vZx x*vYx x*vXx z

	}
	return(result);
}
#endif

//============================================================================
//    TRAILING HEADERS
//============================================================================

//****************************************************************************
//**
//**    END HEADER VECMAIN.H
//**
//****************************************************************************
#endif // __VECMAIN_H__
