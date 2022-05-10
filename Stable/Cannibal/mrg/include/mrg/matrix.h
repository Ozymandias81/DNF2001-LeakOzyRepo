/**
 ** MRG
 **
 ** (c)1997 Sven Technologies, Inc.
 **
 ** All rights regarding distribution, reproduction, reuse, or modification,
 ** in part or in whole, of source code, or supporting data files, are totally
 ** reserved and limited by Sven Technologies, Inc.
 **
 **/

////////////////////////////////////////////////////////////////////////////
// matrix.h
// --------
// declarations for MrgMatrix class

#pragma once

class MrgCoord3D;
class MrgRotation;
#ifndef NOSTREAMS
class ostream;
class istream;
#endif //!NOSTREAMS

class MrgMatrix
{
public:
	// Constructors -- default leaves matrix undefined!
	MrgMatrix() { }

	// Construct from values in row-major order
	MrgMatrix(float a11,float a12,float a13,float a14,
		float a21,float a22,float a23,float a24,
		float a31,float a32,float a33,float a34,
		float a41,float a42,float a43,float a44);
	MrgMatrix( float m[4][4]);

	// Construct from a rotation
	MrgMatrix(const MrgRotation& rot) { setRotate(rot); }

	// Construct from a translation
	MrgMatrix(const MrgCoord3D& trans) { setTranslate(trans); }

	// Construct from a non-uniform scale
	MrgMatrix(float scaleX,float scaleY,float scaleZ) { setScale(scaleX,scaleY,scaleZ); }

	// identity matrix stuff
	void							makeIdentity(void) { *this = sIdentity; }
	static const MrgMatrix&	identity(void) { return sIdentity; }

	// calculate matrix determinant
	float					det3(void) const { return det3(0,1,2,0,1,2); }
	float					det3(int r1,int r2,int r3,int c1,int c2,int c3) const;
	float					det4(void) const;

	// inverse and transpose
	MrgMatrix				inverse(void) const;
	MrgMatrix				transpose(void) const;

	// get values, in row-major order
	const float *		getValue(void) const { return &mat[0][0]; }
	void					getValue(float m[4][4]) const;
	void					getRowMajor(float m[4][4]) const { getValue(m); }

	// get values, in column-major order
	void					getColMajor(float m[4][4]) const;

	float *				operator [](int i) { return &mat[i][0]; }
	const float *		operator [](int i) const { return &mat[i][0]; }

	// assign from a translation or rotation
	MrgMatrix&			operator =(const MrgCoord3D& trans);
	MrgMatrix&			operator =(const MrgRotation& rot);

	// set matrix to be translate, rotate, or scale
	void					setTranslate(const MrgCoord3D& trans) { *this = trans; }
	void					setRotate(const MrgRotation& rot) { *this = rot; }
	void					setScale(float scaleX,float scaleY,float scaleZ);
	void					setScale(const MrgCoord3D& scale);

	// matrix multiplication
	void					multLeft(const MrgMatrix& m);
	void					multRight(const MrgMatrix& m);

	MrgMatrix&			operator *=(const MrgMatrix& m) { multRight(m); return *this; }

	// vector multiplication
	void					multVecMatrix(const MrgCoord3D& src,MrgCoord3D& dst) const;
	void					multMatrixVec(const MrgCoord3D& src,MrgCoord3D& dst) const;
	void					multMatrixVecSp(const MrgCoord3D& src,MrgCoord3D& dst) const;
	void					multMatrixVector(const MrgCoord3D& src, MrgCoord3D& dst) const;

	// scalar multiplication and division
	MrgMatrix&			operator *=(float f);
	MrgMatrix&			operator /=(float f);

	// binary matrix operations
	friend MrgMatrix	operator *(const MrgMatrix& m1,const MrgMatrix& m2) { MrgMatrix t = m1; return t *= m2; }
	friend int			operator ==(const MrgMatrix& m1,const MrgMatrix& m2);
	friend int			operator !=(const MrgMatrix& m1,const MrgMatrix& m2) { return !(m1 == m2); }

	// binary scalar operations
	friend MrgMatrix	operator *(const MrgMatrix& m,float f) { MrgMatrix t = m; return t *= f; }
	friend MrgMatrix	operator *(float f,const MrgMatrix& m) { return m * f; }
	friend MrgMatrix	operator /(const MrgMatrix& m,float f) { MrgMatrix t = m; return t /= f; }
	
	// input/output
#ifndef NOSTREAMS
	friend ostream&	operator << (ostream& stream, const MrgMatrix& mat);
	friend istream&	operator >> (istream& stream, MrgMatrix& mat);
#endif //!NOSTREAMS


protected:
	// matrix, stored in row-major order
	float	mat[4][4];

	// the identity matrix
	static MrgMatrix	sIdentity;
};
