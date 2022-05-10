#ifndef __MATH_VEC_H__
#define __MATH_VEC_H__
//****************************************************************************
//**
//**    MATH_VEC.H
//**    Header - Vector Math
//**
//****************************************************************************
//----------------------------------------------------------------------------
//    Headers
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Definitions
//----------------------------------------------------------------------------
#define PI		3.1415926535897932385
#define PI_f	3.1415926535897932385f

#define AXIS_X 1
#define AXIS_Y 2
#define AXIS_Z 3
#define SHEAR_XY 1
#define SHEAR_YZ 2
#define SHEAR_XZ 3

//----------------------------------------------------------------------------
//    Class Prototypes
//----------------------------------------------------------------------------
class vector_t;
class matrix_t;
class quatern_t;
class plane_t;
class pluckline_t;
//----------------------------------------------------------------------------
//    Required External Class References
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Structures
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Public Data Declarations
//----------------------------------------------------------------------------
extern vector_t vec_BaseVec;
//----------------------------------------------------------------------------
//    Public Function Declarations
//----------------------------------------------------------------------------
inline int VEC_Near(float val1, float val2)
{
    float temp = val1 - val2;
    return((temp <= 1E-4) && (temp >= -1E-4));
}

inline int VEC_NearEx(float val1, float val2, float tolerance)
{
    float temp = val1 - val2;
    return((temp <= tolerance) && (temp >= -tolerance));
}

//----------------------------------------------------------------------------
//    Class Headers
//----------------------------------------------------------------------------
//****************************************************************************
//**
//**    CLASS matrix_t
//**
//****************************************************************************

class matrix_t
{
public:
    // data
    float Data[4][4];

    // construction
    matrix_t();
    matrix_t(matrix_t& m);
    matrix_t(float a1, float a2, float a3, float a4,
    float b1, float b2, float b3, float b4,
    float c1, float c2, float c3, float c4,
    float d1, float d2, float d3, float d4);

    // internal operators
    matrix_t& operator = (const matrix_t& insrc);
    matrix_t& operator += (const matrix_t& insrc);
    matrix_t& operator -= (const matrix_t& insrc);
    matrix_t& operator *= (const float s);
    matrix_t& operator /= (const float s);

    // methods
    matrix_t Transpose();
    matrix_t Inverse(); // FIXME

    // external operators
    friend matrix_t operator - (const matrix_t& v);
    friend matrix_t operator + (const matrix_t& v1, const matrix_t& v2);
    friend matrix_t operator - (const matrix_t& v1, const matrix_t& v2);
    friend matrix_t operator * (const matrix_t& v1, const matrix_t& v2);
    friend matrix_t operator * (const matrix_t& v1, const float s);
    friend matrix_t operator / (const matrix_t& v1, const float s);

    // friend functions
    friend matrix_t MatIdentity();
    friend matrix_t MatTranslation(vector_t& translator);
    friend matrix_t MatRotation(char axisnum, float angle);
    friend matrix_t MatRotation(quatern_t& q);
	friend matrix_t MatRotation(vector_t &newz, vector_t &vup);
    friend matrix_t MatScaling(vector_t& scalar);
    friend matrix_t MatShear(char shearnum, float s1, float s2);

    // friend classes

};

//****************************************************************************
//**
//**    END CLASS matrix_t
//**
//****************************************************************************
//****************************************************************************
//**
//**    CLASS vector_t
//**
//****************************************************************************

class vector_t
{
public:
    // data
	union
	{
		float v[3];
		struct
		{
			float x;
			float y;
			float z;
		};
	};

    // construction
    vector_t();
    vector_t(float nx, float ny, float nz);
    vector_t(vector_t& invec);

    // internal operators
    inline vector_t& operator = (const vector_t& insrc)
	{
		x = insrc.x; y = insrc.y; z = insrc.z;
		return (*this);
	}

    inline vector_t& operator = (const float filler)
	{
		x = filler; y = filler; z = filler;
		return (*this);
	}

    inline vector_t& operator += (const vector_t& insrc)
	{
		x += insrc.x; y += insrc.y; z += insrc.z;
		return (*this);
	}

    inline vector_t& operator -= (const vector_t& insrc)
	{
		x -= insrc.x; y -= insrc.y; z -= insrc.z;
		return (*this);
	}

    inline vector_t& operator *= (const float scalar)
	{
		x *= scalar; y *= scalar; z *= scalar;
		return (*this);
	}

	/*inline*/ vector_t& operator *= (const matrix_t& m)
	{
		float oldx, oldy, oldz;
        oldx = x;
        oldy = y;
        oldz = z;
		x = oldx*m.Data[0][0] + oldy*m.Data[1][0]
			+ oldz*m.Data[2][0] + m.Data[3][0];
		y = oldx*m.Data[0][1] + oldy*m.Data[1][1]
			+ oldz*m.Data[2][1] + m.Data[3][1];
		z = oldx*m.Data[0][2] + oldy*m.Data[1][2]
			+ oldz*m.Data[2][2] + m.Data[3][2];
		return (*this);
	}

    inline vector_t& operator /= (const float scalar)
	{
		float t = 1.0f / scalar;
		x *= t; y *= t; z *= t;
		return (*this);
	}

    // methods
    void Setf(float nx, float ny, float nz);
	void Seti(I32 nx,I32 ny,I32 nz){Setf((float)nx,(float)ny,(float)nz);}
	float Length();
    float Normalize();
	float Distance(vector_t &v1);
	//void Project(vector_t &res, float cenx, float ceny);
	float NearestUV(vector_t &lu, vector_t &lv, vector_t &out);

    // external operators
    friend vector_t operator - (const vector_t& negator);
    friend vector_t operator + (const vector_t& v1, const vector_t& v2);
    friend vector_t operator - (const vector_t& v1, const vector_t& v2);
    friend vector_t operator * (const vector_t& v1, const float scalar);
    friend vector_t operator * (const vector_t& v1, const matrix_t& m);
    friend vector_t operator / (const vector_t& v1, const float scalar);
    friend vector_t operator % (const vector_t& v1, const vector_t& v2);
    friend float operator * (const vector_t& v1, const vector_t& v2);
    friend vector_t operator ^ (const vector_t& v1, const vector_t& v2);
    friend int operator ! (const vector_t &v1);
	friend int operator == (const vector_t& v1, const vector_t& v2);
    friend int operator != (const vector_t& v1, const vector_t& v2);
    friend int operator < (vector_t& v1, vector_t& v2);
    friend int operator > (vector_t& v1, vector_t& v2);
    friend int operator <= (vector_t& v1, vector_t& v2);
    friend int operator >= (vector_t& v1, vector_t& v2);

    // friend functions
    // friend classes

};

inline vector_t operator - (const vector_t& negator)
{
    vector_t res(-negator.x, -negator.y, -negator.z);
    return(res);
}

inline vector_t operator + (const vector_t& v1, const vector_t& v2)
{
    vector_t res(v1.x+v2.x, v1.y+v2.y, v1.z+v2.z);
    return(res);
}

inline vector_t operator - (const vector_t& v1, const vector_t& v2)
{
    vector_t res(v1.x-v2.x, v1.y-v2.y, v1.z-v2.z);
    return(res);
}

inline vector_t operator * (const vector_t& v1, const float scalar)
{
    vector_t res(v1.x*scalar, v1.y*scalar, v1.z*scalar);
    return(res);
}

inline vector_t operator * (const vector_t& v1, const matrix_t& m)
{
    vector_t res(v1.x,v1.y,v1.z);
	res *= m;
    return(res);
}

inline vector_t operator / (const vector_t& v1, const float scalar) // beware DBZ
{
    vector_t res(v1.x/scalar, v1.y/scalar, v1.z/scalar);
    return(res);
}

inline vector_t operator % (const vector_t& v1, const vector_t& v2)
{
    vector_t res(v1.x*v2.x, v1.y*v2.y, v1.z*v2.z); // element multiply
    return(res);
}

inline float operator * (const vector_t& v1, const vector_t& v2)
{
    return(v1.x*v2.x + v1.y*v2.y + v1.z*v2.z); // dot product
}

inline vector_t operator ^ (const vector_t& v1, const vector_t& v2)
{
    vector_t res(v1.y*v2.z - v1.z*v2.y,
               v1.z*v2.x - v1.x*v2.z,
               v1.x*v2.y - v1.y*v2.x);
    return(res);
}

inline int operator ! (const vector_t &v1)
{
	return(VEC_Near(v1.x,0.0) && VEC_Near(v1.y,0.0) && VEC_Near(v1.z,0.0));
}

inline int operator == (const vector_t& v1, const vector_t& v2)
{
    return(VEC_Near(v1.x,v2.x) && VEC_Near(v1.y,v2.y) && VEC_Near(v1.z,v2.z));
}

inline int operator != (const vector_t& v1, const vector_t& v2)
{
    return(!(VEC_Near(v1.x,v2.x) && VEC_Near(v1.y,v2.y) && VEC_Near(v1.z,v2.z)));
}

inline int operator < (vector_t& v1, vector_t& v2)
{
    return(v1.Length() < v2.Length());
}

inline int operator > (vector_t& v1, vector_t& v2)
{
    return(v1.Length() > v2.Length());
}

inline int operator <= (vector_t& v1, vector_t& v2)
{
    return(v1.Length() <= v2.Length());
}

inline int operator >= (vector_t& v1, vector_t& v2)
{
    return(v1.Length() >= v2.Length());
}

//****************************************************************************
//**
//**    END CLASS vector_t
//**
//****************************************************************************
//****************************************************************************
//**
//**    CLASS quatern_t
//**
//****************************************************************************

class quatern_t
{
public:
    // data
	float x;
	float y;
	float z;
    float w;

    // construction
    quatern_t();
    quatern_t(vector_t& nv, float nt);
    quatern_t(const quatern_t& q);
	quatern_t(float f1, float f2, float f3, float f4);

    // internal operators
    quatern_t& operator = (const quatern_t& q);
    quatern_t& operator += (const quatern_t& q);
    quatern_t& operator -= (const quatern_t& q);
    quatern_t& operator *= (const quatern_t& q);
    quatern_t& operator *= (const float s);
    quatern_t& operator /= (const float s);

    // methods
    float Normalize();
    float Length();
    void Init(vector_t& nv, float nt);
	void Init(float nx, float ny, float nz, float nw);
	void Init(matrix_t &imat);

    // external operators
    friend quatern_t operator - (const quatern_t& v1);
    friend quatern_t operator + (const quatern_t& v1, const quatern_t& v2);
    friend quatern_t operator - (const quatern_t& v1, const quatern_t& v2);
    friend quatern_t operator * (const quatern_t& v1, const quatern_t& v2);

    // friend functions
    // friend classes

};

//****************************************************************************
//**
//**    END CLASS quatern_t
//**
//****************************************************************************
//****************************************************************************
//**
//**    CLASS plane_t
//**
//****************************************************************************

class plane_t
{
public:
    // data
	vector_t n;
	float d; // -n.p such that ax+by+cz+d=0

    // construction
	plane_t();
	plane_t(vector_t &n1, float d1);
	plane_t(vector_t &n1, vector_t &p);
	plane_t(vector_t &p1, vector_t &p2, vector_t &p3);
	plane_t(float a1, float b1, float c1, float d1);

    // internal operators
    // methods
	float Distance(vector_t &p);
	vector_t Nearest(vector_t &p);
	float IntersectionUV(vector_t &lu, vector_t &lv, vector_t &out);
	float IntersectionPQ(vector_t &p, vector_t &q, vector_t &out);
	void TriExtract(vector_t &p1, vector_t &p2, vector_t &p3);

    // external operators
    // friend functions
    // friend classes

};

//****************************************************************************
//**
//**    END CLASS plane_t
//**
//****************************************************************************
//****************************************************************************
//**
//**    CLASS pluckline_t
//**	Plucker-coordinate specified line (the 'u' in Plucker is umlauted)
//**
//****************************************************************************
class pluckline_t
{
public:
    // data
	float v[6];

    // methods
	void Set(vector_t &p, vector_t& q)
	{
		// p=[a,b,c,d] q=[w,x,y,z] a&w are 1, b-d and x-z are vec3's
		// v = {a*x-b*w, a*y-c*w, b*y-c*x, a*z-d*w, b*z-d*x, c*z-d*y}
		// Pluckers always satisfy the eq: V0*V5 - V1*V4 + V2*V3 = 0
		// They are described by a direction vector (line V) and the
		// cross product of the vectors of two points on the line
		float a,b,c,d,w,x,y,z;
		a = w = 1;
		b = p.x; c = p.y; d = p.z;
		x = q.x; y = q.y; z = q.z;

		v[0] = a*x - b*w;
		v[1] = a*y - c*w;
		v[2] = b*y - c*x;
		v[3] = a*z - d*w;
		v[4] = b*z - d*x;
		v[5] = c*z - d*y;		
	}

	float RelationshipTo(pluckline_t &p)
	{
		// when looking down the pluckline p, returns if this pluckline
		// intersects p, moves counterclockwise to p, or clockwise to p.
		// returns < 0 for CW, 0 for intersect, > 0 for CCW
		return(v[0]*p.v[5] - v[1]*p.v[4] + v[2]*p.v[3] + v[3]*p.v[2] - v[4]*p.v[1] + v[5]*p.v[0]);
	}

	int IntersectsConvexPoly(int numedges, pluckline_t *edges, float tolerance)
	{
		int re[64]; // maxedges
		int reval, decision = 0;
		for (int i=0;i<numedges;i++)
		{
			re[i] = (int)RelationshipTo(edges[i]);
			reval = 0;
			if (re[i] < -tolerance)
				reval = -1;
			else if (re[i] > tolerance)
				reval = 1;
			if ((decision) && (reval != decision))
				return(0);
			decision = reval;
		}
		return(1);
	}

	int IntersectsTri(pluckline_t &e0, pluckline_t &e1, pluckline_t& e2)
	{
		pluckline_t e[3] = {e0, e1, e2};
		return(IntersectsConvexPoly(3, e, 0.0001f));
	}

    // construction
	pluckline_t() {}
	pluckline_t(vector_t &p, vector_t& q) { Set(p, q); }

    // external operators
    // friend functions
    // friend classes

};

//****************************************************************************
//**
//**    END CLASS pluckline_t
//**
//****************************************************************************

//****************************************************************************
//**
//**    END HEADER MATH_VEC.H
//**
//****************************************************************************
#endif // __MATH_VEC_H__
