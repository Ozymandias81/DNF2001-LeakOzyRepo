#ifndef __VG_LIB_H__
#define __VG_LIB_H__
//****************************************************************************
//**
//**    VG_LIB.H
//**    Header - Vector Geometry Library
//**
//****************************************************************************
//============================================================================
//    INTERFACE REQUIRED HEADERS
//============================================================================
#include <math.h>
#include <float.h>

#pragma warning(disable:4244 4305) // double/float warnings

//============================================================================
//    INTERFACE DEFINITIONS / ENUMERATIONS / SIMPLE TYPEDEFS
//============================================================================
#define VG_PI 3.1415926535897932385
#define VG_EPSILON (1E-3)
#define VG_EPSILON2 (1E-6)

#define VG_AXIS_RIGHT					(0)
#define VG_AXIS_UP						(1)
#define VG_AXIS_FORWARD					(2)

#define VG_AXIS_RIGHT_SIGN				(1)
#define VG_AXIS_UP_SIGN					(1)
#define VG_AXIS_FORWARD_SIGN			(-1)

//============================================================================
//    INTERFACE CLASS PROTOTYPES / EXTERNAL CLASS REFERENCES
//============================================================================

class vgvec2; // 2D vector/point
class vgvec3; // 3D vector/point
class vgvec4; // 4D vector/point

class vgrotax3; // 3D rotation axis
class vgquat3; // 3D quaternion
class vgframe3; // 3D axial frame
class vgocs3; // 3D orthogonal coordinate system

class vglineseg3; // 3D line segment
class vgline3; // 3D line
class vgplane3; // 3D plane

//============================================================================
//    INTERFACE STRUCTURES / UTILITY CLASSES
//============================================================================
//============================================================================
//    INTERFACE DATA DECLARATIONS
//============================================================================
//============================================================================
//    INTERFACE FUNCTION PROTOTYPES
//============================================================================
inline float VG_Fabs(float f)
{
	return(*((unsigned long *)(&f)) & 0x7fffffff);
}

//============================================================================
//    INTERFACE OBJECT CLASS DEFINITIONS
//============================================================================

//----------------------------------------
//
// vgvec2
// 2D vector/point
//
//----------------------------------------

class CBLTK_API vgvec2
{
public:
	float x, y;

	vgvec2();
	vgvec2(const vgvec2& inV);
	vgvec2(float inX, float inY);

	vgvec2& operator = (const vgvec2& inV);
	vgvec2& operator += (const vgvec2& inV);
	vgvec2& operator -= (const vgvec2& inV);
	vgvec2& operator *= (const vgvec2& inV);
	vgvec2& operator /= (const vgvec2& inV);
	vgvec2& operator *= (float inScale);
	vgvec2& operator /= (float inScale);

	float& operator [] (int i);
	
	float Length2() const;
	float Length() const;
	float Normalize();
	int Dominant();

	friend vgvec2 operator - (const vgvec2& inV);
	friend vgvec2 operator + (const vgvec2& inV1, const vgvec2& inV2);
	friend vgvec2 operator - (const vgvec2& inV1, const vgvec2& inV2);
	friend vgvec2 operator * (const vgvec2& inV1, const vgvec2& inV2);
	friend vgvec2 operator / (const vgvec2& inV1, const vgvec2& inV2);
	friend vgvec2 operator * (const vgvec2& inV, float inScale);
	friend vgvec2 operator / (const vgvec2& inV, float inScale);
	friend float operator & (const vgvec2& inV1, const vgvec2& inV2);
	friend float operator | (const vgvec2& inV1, const vgvec2& inV2);
	friend vgvec2 operator ~ (const vgvec2& inV);
	friend bool operator ! (const vgvec2& inV);
	friend bool operator == (const vgvec2& inV1, const vgvec2& inV2);
	friend bool operator != (const vgvec2& inV1, const vgvec2& inV2);
	friend bool operator <= (const vgvec2& inV1, const vgvec2& inV2);
	friend bool operator >= (const vgvec2& inV1, const vgvec2& inV2);
	friend bool operator < (const vgvec2& inV1, const vgvec2& inV2);
	friend bool operator > (const vgvec2& inV1, const vgvec2& inV2);
};


//----------------------------------------
//
// vgvec3
// 3D vector/point
//
//----------------------------------------

class CBLTK_API vgvec3
{
public:
	float x, y, z;

	vgvec3();
	vgvec3(const vgvec3& inV);
	vgvec3(float inX, float inY, float inZ);
	vgvec3(const vgvec2& inV);

	vgvec3& operator = (const vgvec3& inV);
	vgvec3& operator += (const vgvec3& inV);
	vgvec3& operator -= (const vgvec3& inV);
	vgvec3& operator *= (const vgvec3& inV);
	vgvec3& operator /= (const vgvec3& inV);
	vgvec3& operator *= (float inScale);
	vgvec3& operator /= (float inScale);
	vgvec3& operator >>= (const vgframe3& inF);
	vgvec3& operator <<= (const vgframe3& inF);
	vgvec3& operator >>= (const vgocs3& inOCS);
	vgvec3& operator <<= (const vgocs3& inOCS);

	float& operator [] (int i);

	float Length2() const;
	float Length() const;
	float Normalize();
	int Dominant();

	friend vgvec3 operator - (const vgvec3& inV);
	friend vgvec3 operator + (const vgvec3& inV1, const vgvec3& inV2);
	friend vgvec3 operator - (const vgvec3& inV1, const vgvec3& inV2);
	friend vgvec3 operator * (const vgvec3& inV1, const vgvec3& inV2);
	friend vgvec3 operator / (const vgvec3& inV1, const vgvec3& inV2);
	friend vgvec3 operator * (const vgvec3& inV, float inScale);
	friend vgvec3 operator / (const vgvec3& inV, float inScale);
	friend float operator & (const vgvec3& inV1, const vgvec3& inV2);
	friend float operator | (const vgvec3& inV1, const vgvec3& inV2);
	friend vgvec3 operator ^ (const vgvec3& inV1, const vgvec3& inV2);
	friend bool operator ! (const vgvec3& inV);
	friend bool operator == (const vgvec3& inV1, const vgvec3& inV2);
	friend bool operator != (const vgvec3& inV1, const vgvec3& inV2);
	friend bool operator <= (const vgvec3& inV1, const vgvec3& inV2);
	friend bool operator >= (const vgvec3& inV1, const vgvec3& inV2);
	friend bool operator < (const vgvec3& inV1, const vgvec3& inV2);
	friend bool operator > (const vgvec3& inV1, const vgvec3& inV2);
};


//----------------------------------------
//
// vgvec4
// 4D vector/point
//
//----------------------------------------

class CBLTK_API vgvec4
{
public:
	float x, y, z, w;

	vgvec4();
	vgvec4(const vgvec4& inV);
	vgvec4(float inX, float inY, float inZ, float inW);
	vgvec4(const vgvec3& inV);
	vgvec4(const vgvec2& inV);

	vgvec4& operator = (const vgvec4& inV);
	vgvec4& operator += (const vgvec4& inV);
	vgvec4& operator -= (const vgvec4& inV);
	vgvec4& operator *= (const vgvec4& inV);
	vgvec4& operator /= (const vgvec4& inV);
	vgvec4& operator *= (float inScale);
	vgvec4& operator /= (float inScale);

	float& operator [] (int i);

	float Length2() const;
	float Length() const;
	float Normalize();
	int Dominant();

	friend vgvec4 operator - (const vgvec4& inV);
	friend vgvec4 operator + (const vgvec4& inV1, const vgvec4& inV2);
	friend vgvec4 operator - (const vgvec4& inV1, const vgvec4& inV2);
	friend vgvec4 operator * (const vgvec4& inV1, const vgvec4& inV2);
	friend vgvec4 operator / (const vgvec4& inV1, const vgvec4& inV2);
	friend vgvec4 operator * (const vgvec4& inV, float inScale);
	friend vgvec4 operator / (const vgvec4& inV, float inScale);
	friend float operator & (const vgvec4& inV1, const vgvec4& inV2);
	friend float operator | (const vgvec4& inV1, const vgvec4& inV2);
	friend bool operator ! (const vgvec4& inV);
	friend bool operator == (const vgvec4& inV1, const vgvec4& inV2);
	friend bool operator != (const vgvec4& inV1, const vgvec4& inV2);
	friend bool operator <= (const vgvec4& inV1, const vgvec4& inV2);
	friend bool operator >= (const vgvec4& inV1, const vgvec4& inV2);
	friend bool operator < (const vgvec4& inV1, const vgvec4& inV2);
	friend bool operator > (const vgvec4& inV1, const vgvec4& inV2);
};


//----------------------------------------
//
// vgrotax3
// 3D rotation axis
//
//----------------------------------------

class CBLTK_API vgrotax3
{
public:
	vgvec3 axis; // axis of rotation
	float angle; // radian rotation angle

	vgrotax3();
	vgrotax3(const vgrotax3& inR);
	vgrotax3(const vgvec3& inAxis, float inAngle);

	vgrotax3& operator = (const vgrotax3& inR);
};


//----------------------------------------
//
// vgquat3
// 3D quaternion
//
//----------------------------------------

class CBLTK_API vgquat3
{
public:
	vgvec3 v; // vector component
	float s; // scalar component

	vgquat3();
	vgquat3(const vgquat3& inQ);
	vgquat3(const vgvec3& inV, float inS);
	vgquat3(const vgrotax3& inR); // incoming axis MUST be normalized before entry
	vgquat3(const vgframe3& inF);

	vgquat3& operator = (const vgquat3& inQ);
	vgquat3& operator += (const vgquat3& inQ);
	vgquat3& operator -= (const vgquat3& inQ);
	vgquat3& operator *= (const vgquat3& inQ);
	vgquat3& operator *= (float inScale);
	vgquat3& operator /= (float inScale);

	float Length2() const;
	float Length() const;
	float Normalize();

	friend vgquat3 operator - (const vgquat3& inQ);
	friend vgquat3 operator + (const vgquat3& inQ1, const vgquat3& inQ2);
	friend vgquat3 operator - (const vgquat3& inQ1, const vgquat3& inQ2);
	friend vgquat3 operator * (const vgquat3& inQ1, const vgquat3& inQ2);
	friend vgquat3 operator * (const vgquat3& inQ, float inScale);
	friend vgquat3 operator / (const vgquat3& inQ, float inScale);
};


//----------------------------------------
//
// vgframe3
// 3D axial frame
//
//----------------------------------------

class CBLTK_API vgframe3
{
public:
	vgvec3 vX, vY, vZ; // local normalized X, Y, and Z axes

	vgframe3();
	vgframe3(const vgframe3& inF);
	vgframe3(const vgvec3& inX, const vgvec3& inY, const vgvec3& inZ);
	vgframe3(const vgquat3& inQ);

	vgframe3& operator = (const vgframe3& inF);
	vgframe3& operator >>= (const vgframe3& inF);
	vgframe3& operator <<= (const vgframe3& inF);

	friend vgvec3 operator >> (const vgvec3& inV, const vgframe3& inF); // world vector -> frame vector
	friend vgvec3 operator << (const vgvec3& inV, const vgframe3& inF); // frame vector -> world vector
	friend vgframe3 operator >> (const vgframe3& inF1, const vgframe3& inF2); // world frame1 -> frame2-relative frame1
	friend vgframe3 operator << (const vgframe3& inF1, const vgframe3& inF2); // frame2-relative frame1 -> world frame1
};


//----------------------------------------
//
// vgocs3
// 3D orthogonal coordinate system
//
//----------------------------------------

class CBLTK_API vgocs3
{
public:	
	vgframe3 frame; // axial frame
	vgvec3 translate; // translation to local origin
	vgvec3 scale; // axis scale values

	vgocs3();
	vgocs3(const vgocs3& inOCS);
	vgocs3(const vgframe3& inFrame, const vgvec3& inTranslate = vgvec3(0,0,0), const vgvec3& inScale = vgvec3(1,1,1) );

	vgocs3& operator = (const vgocs3& inOCS);
	vgocs3& operator += (const vgvec3& inTranslate);
	vgocs3& operator -= (const vgvec3& inTranslate);	
	vgocs3& operator *= (const vgvec3& inScale);
	vgocs3& operator /= (const vgvec3& inScale);
	vgocs3& operator *= (float inScale);
	vgocs3& operator /= (float inScale);
	vgocs3& operator >>= (const vgocs3& inOCS);
	vgocs3& operator <<= (const vgocs3& inOCS);

	friend vgvec3 operator >> (const vgvec3& inV, const vgocs3& inOCS); // world position -> OCS position
	friend vgvec3 operator << (const vgvec3& inV, const vgocs3& inOCS); // OCS position -> world position
	friend vgocs3 operator >> (const vgocs3& inOCS1, const vgocs3& inOCS2); // world OCS1 -> OCS2-relative OCS1
	friend vgocs3 operator << (const vgocs3& inOCS1, const vgocs3& inOCS2); // OCS2-relative OCS1 -> world OCS1
};

//----------------------------------------
//
// vglineseg3
// 3D line segment
//
//----------------------------------------

class CBLTK_API vglineseg3
{
public:
	vgvec3 v1, v2;

	vglineseg3();
	vglineseg3(const vglineseg3& inLS);
	vglineseg3(const vgvec3& inV1, const vgvec3& inV2);
	
	vglineseg3& operator = (const vglineseg3& inLS);
};


//----------------------------------------
//
// vgline3
// 3D line
//
//----------------------------------------

class CBLTK_API vgline3
{
public:
	vgvec3 u, v;

	vgline3();
	vgline3(const vgline3& inL);
	vgline3(const vgvec3& inU, const vgvec3& inV);
	vgline3(const vglineseg3& inLS);
	vgline3& operator = (const vgline3& inL);

	vgvec3 Nearest(const vgvec3& inP) const;

	friend float operator & (const vgline3& inL, const vgvec3& inP); // distance from point to line
	friend float operator & (const vgvec3& inP, const vgline3& inL); // same
};


//----------------------------------------
//
// vgplane3
// 3D plane
//
//----------------------------------------

class CBLTK_API vgplane3
{
public:
	vgvec3 n;
	float d;

	vgplane3();
	vgplane3(const vgplane3& inJ);
	vgplane3(const vgvec3& inN, float inD);
	vgplane3(const vgvec3& inDir, const vgvec3& inPos);
	
	vgplane3& operator = (const vgplane3& inJ);

	vgvec3 Nearest(const vgvec3& inP) const;
	vgvec3 Intersection(const vgline3& inL, float* outT=0) const;

	friend float operator & (const vgplane3& inJ, const vgvec3& inP); // distance from point to plane
	friend float operator & (const vgvec3& inP, const vgplane3& inJ); // same
};


//============================================================================
//    INTERFACE TRAILING HEADERS
//============================================================================
#define VG_CALL __forceinline
#include "vg_lib.cpp"

//****************************************************************************
//**
//**    END HEADER VG_LIB.H
//**
//****************************************************************************
#endif // __VG_LIB_H__
