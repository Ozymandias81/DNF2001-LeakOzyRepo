#ifndef __VECPRIM_H__
#define __VECPRIM_H__
//****************************************************************************
//**
//**    VECPRIM.H
//**    Header - Vector Math Primitives
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
//============================================================================
//    DEFINITIONS / ENUMERATIONS / SIMPLE TYPEDEFS
//============================================================================
//============================================================================
//    CLASSES / STRUCTURES
//============================================================================
class VLine2; // 2D line
class VLine3; // 3D line
class VPlane3; // 3D plane
class VSphere3; // 3D sphere
class VBox3; // 3D bounding box

/*
	VLine2
	2D line
*/
class VLine2
{
public:
	VVec2 u, v;

	VLine2();
	VLine2(const VLine2& inL);
	VLine2(const VVec2& inU, const VVec2& inV); // raw components, NOT two-point
	void TwoPoint(const VVec2& inP, const VVec2& inQ); // construct in two-point form (named constructor)
	VLine2& operator = (const VLine2& inL);

	VVec2 Nearest(const VVec2& inP) const;
	VVec2 Intersection(const VLine2& inL, float* outT=0) const;

	friend float operator & (const VLine2& inL, const VVec2& inP); // distance from point to line
	friend float operator & (const VVec2& inP, const VLine2& inL); // same
};

/*
	VLine3
	3D line
*/
class VLine3
{
public:
	VVec3 u, v;

	VLine3();
	VLine3(const VLine3& inL);
	VLine3(const VLine2& inL);
	VLine3(const VVec3& inU, const VVec3& inV); // raw components, NOT two-point
	void TwoPoint(const VVec3& inP, const VVec3& inQ); // construct in two-point form (named constructor)
	VLine3& operator = (const VLine3& inL);

	VVec3 Nearest(const VVec3& inP) const;
	VVec3 Intersection(const VLine3& inL, float* outT=0) const;

	friend float operator & (const VLine3& inL, const VVec3& inP); // distance from point to line
	friend float operator & (const VVec3& inP, const VLine3& inL); // same
};

/*
	VPlane3
	3D plane
*/
class VPlane3
{
public:
	VVec3 n;
	float d;

	VPlane3();
	VPlane3(const VPlane3& inJ);
	VPlane3(const VVec3& inN, float inD);
	VPlane3(const VVec3& inDir, const VVec3& inPos);
	VPlane3(const VVec3& inP1, const VVec3& inP2, const VVec3& inP3, bool inCCW=0);
	
	VPlane3& operator = (const VPlane3& inJ);

	VVec3 Nearest(const VVec3& inP) const;
	VVec3 Intersection(const VLine3& inL, float* outT=0) const;
	VLine3 Intersection(VPlane3& inJ);

	friend float operator & (const VPlane3& inJ, const VVec3& inP); // distance from point to plane
	friend float operator & (const VVec3& inP, const VPlane3& inJ); // same
};

/*
	VSphere3
	3D sphere
*/
class VSphere3
{
public:
	VVec3 c;
	float r;

	VSphere3();
	VSphere3(const VSphere3& inS);
	VSphere3(const VVec3& inC, float inR);

	VSphere3& operator = (const VSphere3& inS);

	VVec3 Nearest(const VVec3& inP) const;
	VVec3 Intersection(const VLine3& inL, float* outT=0) const;

	friend float operator & (const VSphere3& inS, const VVec3& inP); // distance from point to sphere
	friend float operator & (const VVec3& inP, const VSphere3& inS); // same
};

/*
	VBox3
	3D bounding box
	Form of coordinate system, where t is the min and (t+s) is max, along r axes
*/
class VBox3
{
public:
	VCoords3 c;

	VBox3();
	VBox3(const VBox3& inB);
	VBox3(const VVec3& inMin, const VVec3& inMax);

	VBox3& operator = (const VBox3& inB);

	NBool Contains(const VVec3& inP);
	NBool Intersects(const VLine3& inL, NFloat* outNear=NULL, NFloat* outFar=NULL) const;
};

//============================================================================
//    GLOBAL DATA
//============================================================================
//============================================================================
//    GLOBAL FUNCTIONS
//============================================================================
//============================================================================
//    INLINE CLASS METHODS
//============================================================================
/*
	VLine2
*/
VEC_INLINE VLine2::VLine2() {}
VEC_INLINE VLine2::VLine2(const VLine2& inL) { u = inL.u; v = inL.v; }
VEC_INLINE VLine2::VLine2(const VVec2& inU, const VVec2& inV) { u = inU; v = inV; v.Normalize(); }
VEC_INLINE void VLine2::TwoPoint(const VVec2& inP, const VVec2& inQ) { u = inP; v = inQ - inP; v.Normalize(); }
VEC_INLINE VLine2& VLine2::operator = (const VLine2& inL) { u = inL.u; v = inL.v; return(*this); }

VEC_INLINE VVec2 VLine2::Nearest(const VVec2& inP) const
{
	VVec3 p(inP);
	VLine3 l(*this);
	p = l.Nearest(p);
	return(VVec2(p.x,p.y));
}
VEC_INLINE VVec2 VLine2::Intersection(const VLine2& inL, float* outT) const
{
	VVec2 n(~inL.v);
	float c = -(n|inL.u);
	float d = (n|v);
	float t;
	if (M_Fabs(d) < M_EPSILON2)
		t = FLT_MAX;
	else
		t = -((c+(n|u))/d);
	if (outT)
		*outT = t;
	return(u + (v*t));
}

VEC_INLINE float operator & (const VLine2& inL, const VVec2& inP) // distance from point to line
{
	return(inP & inL.Nearest(inP));
}
VEC_INLINE float operator & (const VVec2& inP, const VLine2& inL) { return(inL & inP); } // same

/*
	VLine3
*/
VEC_INLINE VLine3::VLine3() {}
VEC_INLINE VLine3::VLine3(const VLine3& inL) { u = inL.u; v = inL.v; }
VEC_INLINE VLine3::VLine3(const VLine2& inL) { u = inL.u; v = inL.v; }
VEC_INLINE VLine3::VLine3(const VVec3& inU, const VVec3& inV) { u = inU; v = inV; v.Normalize(); }
VEC_INLINE void VLine3::TwoPoint(const VVec3& inP, const VVec3& inQ) { u = inP; v = inQ - inP; v.Normalize(); }
VEC_INLINE VLine3& VLine3::operator = (const VLine3& inL) { u = inL.u; v = inL.v; return(*this); }

VEC_INLINE VVec3 VLine3::Nearest(const VVec3& inP) const
{
	VPlane3 j(v, inP);
	return(j.Intersection(*this));
}
VEC_INLINE VVec3 VLine3::Intersection(const VLine3& inL, float* outT) const
{
	float t, n, d;
	VVec3 v1, v2, v3;
	
	v3 = v ^ inL.v;
	d = v3.Length2();
	if (M_Fabs(d) < M_EPSILON2)
		t = FLT_MAX;
	else
	{
		v1 = inL.u - u;
		v2 = inL.v;
		n = M_Det3x3(v1.x, v1.y, v1.z, v2.x, v2.y, v2.z, v3.x, v3.y, v3.z);
		t = n / d;
	}
	if (outT)
		*outT = t;
	return(u + (v*t));
}

VEC_INLINE float operator & (const VLine3& inL, const VVec3& inP) // distance from point to line
{
	return(inP & inL.Nearest(inP));
}
VEC_INLINE float operator & (const VVec3& inP, const VLine3& inL) { return(inL & inP); } // same

/*
	VPlane3
*/
VEC_INLINE VPlane3::VPlane3() {}
VEC_INLINE VPlane3::VPlane3(const VPlane3& inJ) { n = inJ.n; d = inJ.d; }
VEC_INLINE VPlane3::VPlane3(const VVec3& inN, float inD) { n = inN; d = inD; }
VEC_INLINE VPlane3::VPlane3(const VVec3& inDir, const VVec3& inPos) { n = inDir; n.Normalize(); d = -(n|inPos); }
VEC_INLINE VPlane3::VPlane3(const VVec3& inP1, const VVec3& inP2, const VVec3& inP3, bool inCCW)
{
	VVec3 t1, t2;
	t1 = inP1-inP2;
	t2 = inP3-inP2;
	n = t1 ^ t2; // clockwise front by default
	n.Normalize();
	if (inCCW)
		n = -n; // counterclockwise front if requested
	d = -(n|inP2);
}

VEC_INLINE VPlane3& VPlane3::operator = (const VPlane3& inJ) { n = inJ.n; d = inJ.d; return(*this); }

VEC_INLINE VVec3 VPlane3::Nearest(const VVec3& inP) const
{
	return( inP - (n * ( (d + (n|inP)) / (n|n) )) );
}
VEC_INLINE VVec3 VPlane3::Intersection(const VLine3& inL, float* outT) const
{
	float t, denom(inL.v | n);
	if (M_Fabs(denom) < M_EPSILON)
		t = FLT_MAX;
	else
		t = -((d+(inL.u|n))/denom);
	if (outT)
		*outT = t;
	return(inL.u + (inL.v*t));
}
VEC_INLINE VLine3 VPlane3::Intersection(VPlane3& inJ)
{
	VLine3 r;
	VVec3 l;
	static int rot1[3] = {1,2,0};
	static int rot2[3] = {2,0,1};

	l = n ^ inJ.n;
	int w = l.Dominant();
	int u = rot1[w];
	int v = rot2[w];
	if (M_Fabs(l[w]) < M_EPSILON2)
		return(VLine3(VVec3(FLT_MAX,FLT_MAX,FLT_MAX), VVec3(0,0,0)));
	r.u[u] = (n[v]*inJ.d - inJ.n[v]*d) / l[w];
	r.u[v] = (inJ.n[u]*d - n[u]*inJ.d) / l[w];
	r.u[w] = 0.f;
	r.v = l; r.v.Normalize();
	return(r);
}

VEC_INLINE float operator & (const VPlane3& inJ, const VVec3& inP) // distance from point to plane
{
	return(inP & inJ.Nearest(inP));
}
VEC_INLINE float operator & (const VVec3& inP, const VPlane3& inJ) { return(inJ & inP); } // same

/*
	VSphere3
*/
VEC_INLINE VSphere3::VSphere3() {}
VEC_INLINE VSphere3::VSphere3(const VSphere3& inS) { c = inS.c; r = inS.r; }
VEC_INLINE VSphere3::VSphere3(const VVec3& inC, float inR) { c = inC; r = inR; }

VEC_INLINE VSphere3& VSphere3::operator = (const VSphere3& inS) { c = inS.c; r = inS.r; return(*this); }

VEC_INLINE VVec3 VSphere3::Nearest(const VVec3& inP) const
{
	VVec3 v(inP - c);
	v.Normalize();
	v *= r;
	v += c;
	return(v);
}
VEC_INLINE VVec3 VSphere3::Intersection(const VLine3& inL, float* outT) const
{
	float t1, t2, t;
	VVec3 g(inL.u - c);
	float a(inL.v | inL.v);
	float b(2.f*(inL.v | g));
	float c((g | g) - (r*r));
	float d((b*b) - (4.f*a*c));
	if (d < 0.f)
		t = FLT_MAX;
	else
	{
		float a2 = 2.f*a;
		float sd = (float)sqrt(d);
		t1 = (-b + sd) / a2;
		t2 = (-b - sd) / a2;
		t = (t1 < t2) ? t1 : t2;
	}
	if (outT)
		*outT = t;
	return(inL.u + (inL.v*t));
}

VEC_INLINE float operator & (const VSphere3& inS, const VVec3& inP) // distance from point to sphere
{
	return(inP & inS.Nearest(inP));
}
VEC_INLINE float operator & (const VVec3& inP, const VSphere3& inS) { return(inS & inP); } // same

/*
	VBox3
*/
VEC_INLINE VBox3::VBox3() {}
VEC_INLINE VBox3::VBox3(const VBox3& inB) { c = inB.c; }
VEC_INLINE VBox3::VBox3(const VVec3& inMin, const VVec3& inMax) { c.t = inMin; c.s = inMax - inMin; }

VEC_INLINE VBox3& VBox3::operator = (const VBox3& inB) { c = inB.c; return(*this); }

VEC_INLINE NBool VBox3::Contains(const VVec3& inP)
{
	VVec3 p(inP >> c);
	return((p.x >= 0.f) && (p.x <= 1.f) && (p.y >= 0.f) && (p.y <= 1.f) && (p.z >= 0.f) && (p.z <= 1.f));
}
VEC_INLINE NBool VBox3::Intersects(const VLine3& inL, NFloat* outNear, NFloat* outFar) const
{
	VLine3 l; l.TwoPoint(inL.u >> c, (inL.u + inL.v) >> c);

	NFloat tn(-FLT_MAX), tf(FLT_MAX);
	NFloat t;

	// The line is transformed into the space of the box, so the planes to check are constant
	// using the box (0,0,0) to (1,1,1).  The code is a slim form of the standard planar solid
	// line intersection test, optimized for these fixed planes
	for (NInt i=0;i<3;i++)
	{
		if (M_Fabs(l.v[i]) < M_EPSILON)
		{
			if (((l.u[i] - 1.f) > M_EPSILON) || (l.u[i] < M_EPSILON))
				return(0);
			continue;
		}
		t = -(l.u[i] - 1.f) / l.v[i];
		if (l.v[i] > 0.f)
		{
			if (t < 0.f) return(0);
			if (t < tf) tf = t;
			if (tn > tf) return(0);
			t = -l.u[i] / l.v[i];
			if (t > tn) tn = t;
			if (tn > tf) return(0);
		}
		else
		{
			if (t > tn) tn = t;
			if (tn > tf) return(0);
			t = -l.u[i] / l.v[i];
			if (t < 0.f) return(0);
			if (t < tf) tf = t;
			if (tn > tf) return(0);
		}
	}
	if (outNear)
	{
		VVec3 v = l.u + l.v*tn;
		v <<= c;
		*outNear = inL.v | (v - inL.u);
	}
	if (outFar)
	{
		VVec3 v = l.u + l.v*tf;
		v <<= c;
		*outFar = inL.v | (v - inL.u);
	}
	return(1);
}

//============================================================================
//    TRAILING HEADERS
//============================================================================

//****************************************************************************
//**
//**    END HEADER VECPRIM.H
//**
//****************************************************************************
#endif // __VECPRIM_H__
