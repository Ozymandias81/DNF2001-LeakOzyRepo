/** AVATARMAKER
 **
 ** (c)1996 Sven Technologies, Inc.
 **
 ** All rights regarding distribution, reproduction, reuse, or modification,
 ** in part or in whole, of source code, or supporting data files, are totally
 ** reserved and limited by Sven Technologies, Inc.
 **
 **/

//////////////////////////////////////////////////////////////////////////////
// rotation.h
// ----------
// Declarations for MrgRotation class.
// Note that all angles are in degrees! This is different from Inventor!
// But this is the same as OpenGL!

#pragma once

class MrgCoord3D;
class MrgMatrix;
#ifndef NOSTREAMS
class istream;
class ostream;
#endif //!NOSTREAMS

class MrgRotation
{
public:
	// Constructors -- default leaves rotation undefined!
	MrgRotation() { }
	MrgRotation(float q0,float q1,float q2,float q3) { setValue(q0,q1,q2,q3); }
	MrgRotation(const float q[4]) { setValue(q); }
	MrgRotation(const MrgCoord3D& axis,float degrees) { setValue(axis,degrees); }
	MrgRotation(const MrgMatrix& m) { setValue(m); }
	MrgRotation(const MrgCoord3D& rotateFrom,const MrgCoord3D& rotateTo) { setValue(rotateFrom,rotateTo); }
	MrgRotation(const MrgRotation& src);

	// get values
	const float *	getValue(void) const { return quat; }
	void				getValue(float& q0,float& q1,float& q2,float& q3) const;
	void				getValue(MrgCoord3D& axis,float& degrees) const;
	void				getValue(MrgMatrix& m) const;

	// set values
	void				setValue(float q0,float q1,float q2,float q3);
	void				setValue(const float q[4]);
	void				setValue(const MrgCoord3D& axis,float degrees);
	void				setValue(const MrgMatrix& m);
	void				setValue(const MrgCoord3D& rotateFrom,const MrgCoord3D& rotateTo);

	// make rotation be the empty (identity) rotation
	void				makeIdentity(void);

	// change a rotation to be its inverse, in place
	void				invert(void);

	// return the inverse of the rotation
	MrgRotation		inverse(void) const;

	// multiply by another rotation
	MrgRotation&		operator *=(const MrgRotation& rot);

	// unary negation (return inverse of rotation)
	MrgRotation		operator -(void) const { return inverse(); }

	// put a vector through a rotation about the origin
	void				multVec(const MrgCoord3D& src,MrgCoord3D& dst) const;

	// equality comparison
	friend int		operator ==(const MrgRotation& rot1,const MrgRotation& rot2);
	friend int		operator !=(const MrgRotation& rot1,const MrgRotation& rot2) { return !(rot1 == rot2); }

	// return identity (empty) rotation
	static const MrgRotation &	identity(void) { return sIdentity; }

	// adjust rotation for reflection
	MrgRotation	reflect() const;

	// input/output
#ifndef NOSTREAMS
	friend ostream&	operator << (ostream& stream, const MrgRotation& rot);
	friend istream&	operator >> (istream& stream, MrgRotation& rot);
#endif //!NOSTREAMS

protected:
	
	// return the norm (length) of the quaternion
	float				norm(void) const;

	// normalize to a unit-length quaternion
	void				normalize(void);

	// the quaternion: q0 + q1*I + q2*J + q3*K
	float		quat[4];

	// identity (empty) rotation
	static const MrgRotation		sIdentity;
};

inline MrgRotation
operator * (const MrgRotation &rot1, const MrgRotation &rot2)
{
	MrgRotation rtrn(rot1);
	return (rtrn *= rot2);
}
