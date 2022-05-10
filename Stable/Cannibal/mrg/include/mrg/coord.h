/** MRG
 **
 ** (c)1997-1998 Sven Technologies, Inc.
 **
 ** All rights regarding distribution, reproduction, reuse, or modification,
 ** in part or in whole, of source code, or supporting data files, are totally
 ** reserved and limited by Sven Technologies, Inc.
 **
 **/

//////////////////////////////////////////////////////////////////////////////
// coord.h
// -------
// defintions for coordinate classes, MrgCoord3D

#ifndef _COORD_H_INC
#define _COORD_H_INC

#include "mrg/types.h"

#ifndef NOSTREAMS
class istream;
class ostream;
#endif //NOSTREAMS
class MrgMatrix;

class MrgCoord3D
{
public:
	// Constructors -- default leaves vector undefined!
	MrgCoord3D() { }
	MrgCoord3D(float x,float y,float z) { vec[0] = x; vec[1] = y; vec[2] = z; }
	MrgCoord3D(const float v[3]) { vec[0] = v[0]; vec[1] = v[1]; vec[2] = v[2]; }
	MrgCoord3D(const MrgMatrix& m) { setValue(m); }

	// get values
	const float *	getValue(void) const { return vec; }
	void				getValue(float& x,float& y,float &z) const { x = vec[0]; y = vec[1]; z = vec[2]; }

	// set values
	void				setValue(float x,float y,float z) { vec[0] = x; vec[1] = y; vec[2] = z; }
	void				setValue(const float v[3]) { vec[0] = v[0]; vec[1] = v[1]; vec[2] = v[2]; }
	void				setValue(const MrgMatrix& m);

	// indexed component return
	float&			operator [](int i) { return vec[i]; }
	const float&	operator [](int i) const { return vec[i]; }

	// negate the vector in place
	void				negate(void) { vec[0] = -vec[0]; vec[1] = -vec[1]; vec[2] = -vec[2]; }

	// component-wise scalar multiplication and division operators
	MrgCoord3D&		operator *=(float d);
	MrgCoord3D&		operator /=(float d);

	// component-wise vector addition and subtraction operators
	MrgCoord3D&		operator +=(const MrgCoord3D& v);
	MrgCoord3D&		operator -=(const MrgCoord3D& v);

	// non-destructive unary negation operator
	MrgCoord3D		operator -(void) const { return MrgCoord3D(-vec[0],-vec[1],-vec[2]); }

	// component-wise binary scalar multiplication and division operators
	friend MrgCoord3D		operator *(const MrgCoord3D& v,float d);
	friend MrgCoord3D		operator *(float d,const MrgCoord3D& v) { return v * d; }
	friend MrgCoord3D		operator /(const MrgCoord3D& v,float d);

	// component-wise binary addition and subtraction operators
	friend MrgCoord3D		operator +(const MrgCoord3D& v1,const MrgCoord3D& v2);
	friend MrgCoord3D		operator -(const MrgCoord3D& v1,const MrgCoord3D& v2);

	// equality comparison operators
	friend int				operator ==(const MrgCoord3D& v1,const MrgCoord3D& v2);
	friend int				operator !=(const MrgCoord3D& v1,const MrgCoord3D& v2) { return !(v1 == v2); }

	// get the length of this vector
	float				length(void) const;

	// normalize a vector to unit length
	void				normalize(void) { float len = length(); if (len > 0.0f) *this /= len; }

	// return the dot-product of this vector with another
	float				dot(const MrgCoord3D& v) const;

	// return the cross product of this vector with another
	MrgCoord3D			cross(const MrgCoord3D& v) const;

	// input/output
#ifndef NOSTREAMS
	friend ostream&	operator << (ostream& stream, const MrgCoord3D& v);
	friend istream&	operator >> (istream& stream, MrgCoord3D& v);
#endif //NOSTREAMS

protected:
	float	vec[3];
};

class MrgCoord2Df
{
public:
	// Constructors -- default leaves vector undefined!
	MrgCoord2Df() { }
	MrgCoord2Df(float x,float y) { vec[0] = x; vec[1] = y; }
	MrgCoord2Df(const float v[2]) { vec[0] = v[0]; vec[1] = v[1]; }
	
	// get values
	const float *	getValue(void) const { return vec; }
	void			getValue(float& x,float& y) const { x = vec[0]; y = vec[1]; }

	// set values
	void			setValue(float x,float y) { vec[0] = x; vec[1] = y; }
	void			setValue(const float v[2]) { vec[0] = v[0]; vec[1] = v[1]; }

	// indexed component return
	float&			operator [](int i) { return vec[i]; }
	const float&	operator [](int i) const { return vec[i]; }

	// negate the vector in place
	void			negate(void) { vec[0] = -vec[0]; vec[1] = -vec[1]; }

	// component-wise scalar multiplication and division operators
	MrgCoord2Df&		operator *=(float d);
	MrgCoord2Df&		operator /=(float d);

	// component-wise vector addition and subtraction operators
	MrgCoord2Df&		operator +=(const MrgCoord2Df& v);
	MrgCoord2Df&		operator -=(const MrgCoord2Df& v);

	// non-destructive unary negation operator
	MrgCoord2Df		operator -(void) const { return MrgCoord2Df(-vec[0],-vec[1]); }

	// component-wise binary scalar multiplication and division operators
	friend MrgCoord2Df		operator *(const MrgCoord2Df& v,float d);
	friend MrgCoord2Df		operator *(float d,const MrgCoord2Df& v) { return v * d; }
	friend MrgCoord2Df		operator /(const MrgCoord2Df& v,float d);

	// component-wise binary addition and subtraction operators
	friend MrgCoord2Df		operator +(const MrgCoord2Df& v1,const MrgCoord2Df& v2);
	friend MrgCoord2Df		operator -(const MrgCoord2Df& v1,const MrgCoord2Df& v2);

	// equality comparison operators
	friend int				operator ==(const MrgCoord2Df& v1,const MrgCoord2Df& v2);
	friend int				operator !=(const MrgCoord2Df& v1,const MrgCoord2Df& v2) { return !(v1 == v2); }

	// stream input/output
#ifndef NOSTREAMS
	friend ostream&		operator <<(ostream& stream,const MrgCoord2Df& coord);
	friend istream&		operator >>(istream& stream,MrgCoord2Df& coord);
#endif //NOSTREAMS

protected:
	float	vec[2];
};

class MrgCoord2Di
{
public:
	// Constructors -- default leaves vector undefined!
	MrgCoord2Di() { }
	MrgCoord2Di(MrgSint32 x,MrgSint32 y) { vec[0] = x; vec[1] = y; }
	MrgCoord2Di(const MrgSint32 v[2]) { vec[0] = v[0]; vec[1] = v[1]; }

	// get values
	const MrgSint32 *	getValue(void) const { return vec; }
	void			getValue(MrgSint32& x,MrgSint32& y) const { x = vec[0]; y = vec[1]; }

	// set values
	void			setValue(MrgSint32 x,MrgSint32 y) { vec[0] = x; vec[1] = y; }
	void			setValue(const MrgSint32 v[2]) { vec[0] = v[0]; vec[1] = v[1]; }

	// indexed component return
	MrgSint32&			operator [](int i) { return vec[i]; }
	const MrgSint32&	operator [](int i) const { return vec[i]; }

	// negate the vector in place
	void			negate(void) { vec[0] = -vec[0]; vec[1] = -vec[1]; }

	// component-wise scalar multiplication and division operators
	MrgCoord2Di&		operator *=(MrgSint32 d);
	MrgCoord2Di&		operator /=(MrgSint32 d);

	// component-wise vector addition and subtraction operators
	MrgCoord2Di&		operator +=(const MrgCoord2Di& v);
	MrgCoord2Di&		operator -=(const MrgCoord2Di& v);

	// non-destructive unary negation operator
	MrgCoord2Di		operator -(void) const { return MrgCoord2Di(-vec[0],-vec[1]); }

	// component-wise binary scalar multiplication and division operators
	friend MrgCoord2Di		operator *(const MrgCoord2Di& v,MrgSint32 d);
	friend MrgCoord2Di		operator *(MrgSint32 d,const MrgCoord2Di& v) { return v * d; }
	friend MrgCoord2Di		operator /(const MrgCoord2Di& v,MrgSint32 d);

	// component-wise binary addition and subtraction operators
	friend MrgCoord2Di		operator +(const MrgCoord2Di& v1,const MrgCoord2Di& v2);
	friend MrgCoord2Di		operator -(const MrgCoord2Di& v1,const MrgCoord2Di& v2);

	// equality comparison operators
	friend int				operator ==(const MrgCoord2Di& v1,const MrgCoord2Di& v2);
	friend int				operator !=(const MrgCoord2Di& v1,const MrgCoord2Di& v2) { return !(v1 == v2); }

	// stream input/output
#ifndef NOSTREAMS
	friend ostream&		operator <<(ostream& stream,const MrgCoord2Di& coord);
	friend istream&		operator >>(istream& stream,MrgCoord2Di& coord);
#endif //NOSTREAMS

protected:
	MrgSint32	vec[2];
};

#endif /*_COORD_H_INC*/
