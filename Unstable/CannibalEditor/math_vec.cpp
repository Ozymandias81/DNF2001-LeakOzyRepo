//****************************************************************************
//**
//**    MATH_VEC.CPP
//**    Vector Math
//**
//****************************************************************************
//----------------------------------------------------------------------------
//    Headers
//----------------------------------------------------------------------------
#include "cbl_defs.h"
#include "math_vec.h"

//----------------------------------------------------------------------------
//    Private Definitions
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Private Structures
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Additional External References
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Private Data
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Public Data
//----------------------------------------------------------------------------
vector_t vec_BaseVec;
//----------------------------------------------------------------------------
//    Private Code
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Public Code
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Class Member Code
//----------------------------------------------------------------------------
//****************************************************************************
//**
//**    CLASS vector_t
//**
//****************************************************************************
//----------------------------------------------------------------------------
//    Public Construction
//----------------------------------------------------------------------------
vector_t::vector_t()
{
//    x = 0.0; y = 0.0; z = 0.0;
}

vector_t::vector_t(float nx, float ny, float nz)
{
    x = nx; y = ny; z = nz;
}

vector_t::vector_t(vector_t& invec)
{
    x = invec.x; y = invec.y; z = invec.z;
}

//----------------------------------------------------------------------------
//    Public Internal Operators
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Public Methods
//----------------------------------------------------------------------------
void vector_t::Set(float nx, float ny, float nz)
{
	x = nx; y = ny; z = nz;
}

float vector_t::Length()
{
    return(sqrt(x*x + y*y + z*z));
}

float vector_t::Normalize()
{
    float length = Length();
    *this /= length;
    return(length);
}

float vector_t::Distance(vector_t &v1)
{
    vector_t temp = v1 - *this;
    return(temp.Length());
}
/*
void vector_t::Project(vector_t &res, float cenx, float ceny)
{
	vec_BaseVec.x = cenx;
	vec_BaseVec.y = ceny;
	vec_BaseVec.z = 256.0;
	res.x = (int)(vec_BaseVec.z*x/(-z) + vec_BaseVec.x);
	res.y = (int)(vec_BaseVec.y - vec_BaseVec.z*y/(-z));
	res.z = -z;
}
*/
float vector_t::NearestUV(vector_t &lu, vector_t &lv, vector_t &out)
{
	plane_t j(lv, *this);
	return(j.IntersectionUV(lu, lv, out));
}
//----------------------------------------------------------------------------
//    External Operators
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Friend Functions
//----------------------------------------------------------------------------

//****************************************************************************
//**
//**    END CLASS vector_t
//**
//****************************************************************************
//****************************************************************************
//**
//**    CLASS matrix_t
//**
//****************************************************************************
//----------------------------------------------------------------------------
//    Public Construction
//----------------------------------------------------------------------------
matrix_t::matrix_t()
{
}

matrix_t::matrix_t(matrix_t& m)
{
    int i,k;
    for (i=0;i<4;i++)
        for (k=0;k<4;k++)
            Data[i][k] = m.Data[i][k];
}

matrix_t::matrix_t(float a1, float a2, float a3, float a4,
                 float b1, float b2, float b3, float b4,
                 float c1, float c2, float c3, float c4,
                 float d1, float d2, float d3, float d4)
{
    Data[0][0] = a1;
    Data[0][1] = a2;
    Data[0][2] = a3;
    Data[0][3] = a4;
    Data[1][0] = b1;
    Data[1][1] = b2;
    Data[1][2] = b3;
    Data[1][3] = b4;
    Data[2][0] = c1;
    Data[2][1] = c2;
    Data[2][2] = c3;
    Data[2][3] = c4;
    Data[3][0] = d1;
    Data[3][1] = d2;
    Data[3][2] = d3;
    Data[3][3] = d4;
}

//----------------------------------------------------------------------------
//    Public Internal Operators
//----------------------------------------------------------------------------
matrix_t& matrix_t::operator = (const matrix_t& insrc)
{
    int i, k;

    for (i=0;i<4;i++)
        for (k=0;k<4;k++)
            Data[i][k] = insrc.Data[i][k];
    return(*this);
}

matrix_t& matrix_t::operator += (const matrix_t& insrc)
{
    int i, k;

    for (i=0;i<4;i++)
        for (k=0;k<4;k++)
            Data[i][k] += insrc.Data[i][k];
    return(*this);
}

matrix_t& matrix_t::operator -= (const matrix_t& insrc)
{
    int i, k;

    for (i=0;i<4;i++)
        for (k=0;k<4;k++)
            Data[i][k] -= insrc.Data[i][k];
    return(*this);
}

matrix_t& matrix_t::operator *= (const float s)
{
    int i, k;

    for (i=0;i<4;i++)
        for (k=0;k<4;k++)
            Data[i][k] *= s;
    return(*this);
}

matrix_t& matrix_t::operator /= (const float s)
{
    int i, k;

    for (i=0;i<4;i++)
        for (k=0;k<4;k++)
            Data[i][k] /= s;
    return(*this);
}

//----------------------------------------------------------------------------
//    Public Methods
//----------------------------------------------------------------------------
matrix_t matrix_t::Transpose()
{
    matrix_t res(*this);
    res.Data[0][0] = Data[0][0];
    res.Data[0][1] = Data[1][0];
    res.Data[0][2] = Data[2][0];
    res.Data[0][3] = Data[3][0];
    res.Data[1][0] = Data[0][1];
    res.Data[1][1] = Data[1][1];
    res.Data[1][2] = Data[2][1];
    res.Data[1][3] = Data[3][1];
    res.Data[2][0] = Data[0][2];
    res.Data[2][1] = Data[1][2];
    res.Data[2][2] = Data[2][2];
    res.Data[2][3] = Data[3][2];
    res.Data[3][0] = Data[0][3];
    res.Data[3][1] = Data[1][3];
    res.Data[3][2] = Data[2][3];
    res.Data[3][3] = Data[3][3];
    return(res);
}

matrix_t matrix_t::Inverse() // FIXME: I seriously doubt this works
{
    matrix_t a(*this);
    matrix_t b = MatIdentity();
    int i,j,i1,k;
    float temp[4];

    for (j=0;j<4;j++)
    {
        i1 = j;
        for (i=j+1; i<4; i++)
            if (fabs(a.Data[i][j]) > fabs(a.Data[i1][j]))
                i1 = i;
        for (i=0;i<4;i++)
        {
            temp[i] = a.Data[i1][i];
            a.Data[i1][i] = a.Data[j][i];
            a.Data[j][i] = temp[i];
            temp[i] = b.Data[i1][i];
            b.Data[i1][i] = b.Data[j][i];
            b.Data[j][i] = temp[i];
        }
        if (a.Data[j][j] == 0.)
            return(*this);
            //mCD.Quit(1,"I_Matrix: Can't invert a singular matrix.\n");
        for (i=0;i<4;i++)
        {
            b.Data[j][i] /= a.Data[j][j];
            a.Data[j][i] /= a.Data[j][j];
        }
        for (i=0;i<4;i++)
        {
            if (i != j)
            {
                for (k=0;k<4;k++)
                    b.Data[i][k] -= a.Data[i][j]*b.Data[j][k];
                for (k=0;k<4;k++)
                    a.Data[i][k] -= a.Data[i][j]*a.Data[j][k];
            }
        }
    }
    return(b);
}

//----------------------------------------------------------------------------
//    External Operators
//----------------------------------------------------------------------------
matrix_t operator - (const matrix_t& v)
{
    int i, k;
    matrix_t res;
    res = v;

    for (i=0;i<4;i++)
        for (k=0;k<4;k++)
            res.Data[i][k] = -v.Data[i][k];
    return(res);
}

matrix_t operator + (const matrix_t& v1, const matrix_t& v2)
{
    int i, k;
    matrix_t res;
    res = v1;

    for (i=0;i<4;i++)
        for (k=0;k<4;k++)
            res.Data[i][k] = v1.Data[i][k] + v2.Data[i][k];
    return(res);
}

matrix_t operator - (const matrix_t& v1, const matrix_t& v2)
{
    int i, k;
    matrix_t res;
    res = v1;

    for (i=0;i<4;i++)
        for (k=0;k<4;k++)
            res.Data[i][k] = v1.Data[i][k] - v2.Data[i][k];
    return(res);
}

matrix_t operator * (const matrix_t& v1, const matrix_t& v2)
{
    int k,l,x;
    float temp;
    matrix_t res;
    res = v1;
    for (k=0;k<4;k++)
    {
        for(l=0;l<4;l++)
        {
            temp = 0;
            for (x=0;x<4;x++)
                temp += v1.Data[k][x] * v2.Data[x][l];
            res.Data[k][l] = temp;
        }
    }
    return(res);
}

matrix_t operator * (const matrix_t& v1, const float s)
{
    int i, k;
    matrix_t res;
    res = v1;

    for (i=0;i<4;i++)
        for (k=0;k<4;k++)
            res.Data[i][k] = v1.Data[i][k] * s;
    return(res);
}

matrix_t operator / (const matrix_t& v1, const float s)
{
    int i, k;
    matrix_t res;
    res = v1;

    for (i=0;i<4;i++)
        for (k=0;k<4;k++)
            res.Data[i][k] = v1.Data[i][k] / s;
    return(res);
}

//----------------------------------------------------------------------------
//    Friend Functions
//----------------------------------------------------------------------------
matrix_t MatIdentity()
{
    matrix_t res( 1.0, 0.0, 0.0, 0.0,
                0.0, 1.0, 0.0, 0.0,
                0.0, 0.0, 1.0, 0.0,
                0.0, 0.0, 0.0, 1.0 );
    return(res);
}

matrix_t MatTranslation(vector_t& translator)
{
    matrix_t res( 1.0, 0.0, 0.0, 0.0,
                0.0, 1.0, 0.0, 0.0,
                0.0, 0.0, 1.0, 0.0,
                translator.x, translator.y, translator.z, 1.0 );
    return(res);
}

matrix_t MatRotation(char axisnum, float angle)
{
    matrix_t res( 1.0, 0.0, 0.0, 0.0,
                0.0, 1.0, 0.0, 0.0,
                0.0, 0.0, 1.0, 0.0,
                0.0, 0.0, 0.0, 1.0 );
    if (axisnum == AXIS_X)
    {
        res.Data[1][1] = cos(angle);
        res.Data[1][2] = sin(angle);
        res.Data[2][1] = -sin(angle);
        res.Data[2][2] = cos(angle);
    }
    else
    if (axisnum == AXIS_Y)
    {
        res.Data[0][0] = cos(angle);
        res.Data[2][0] = sin(angle);
        res.Data[0][2] = -sin(angle);
        res.Data[2][2] = cos(angle);
    }
    else
    if (axisnum == AXIS_Z)
    {
        res.Data[0][0] = cos(angle);
        res.Data[0][1] = sin(angle);
        res.Data[1][0] = -sin(angle);
        res.Data[1][1] = cos(angle);
    }
    return(res);
}

matrix_t MatShear(char shearnum, float s1, float s2)
{
    matrix_t res( 1.0, 0.0, 0.0, 0.0,
                0.0, 1.0, 0.0, 0.0,
                0.0, 0.0, 1.0, 0.0,
                0.0, 0.0, 0.0, 1.0 );
    if (shearnum == SHEAR_XY)
    {
        res.Data[2][0] = s1;
        res.Data[2][1] = s2;
    }
    else
    if (shearnum == SHEAR_YZ)
    {
        res.Data[0][1] = s1;
        res.Data[0][2] = s2;
    }
    else
    if (shearnum == SHEAR_XZ)
    {
        res.Data[1][0] = s1;
        res.Data[1][2] = s2;
    }
    return(res);
}

matrix_t MatRotation(quatern_t& q)
{
    float x = q.x;
    float y = q.y;
    float z = q.z;
    float w = q.w;
    matrix_t res( 1.0-(2*y*y)-(2*z*z), (2*x*y)-(2*w*z), (2*x*z)+(2*w*y), 0.0,
                (2*x*y)+(2*w*z), 1.0-(2*x*x)-(2*z*z), (2*y*z)-(2*w*x), 0.0,
                (2*x*z)-(2*w*y), (2*y*z)+(2*w*x), 1.0-(2*x*x)-(2*y*y), 0.0,
                0.0, 0.0, 0.0, 1.0 );
    return(res);
}

matrix_t MatRotation(vector_t &newz, vector_t &vup)
{ // orient to frame where newz is the new (outward pointing) z axis
	vector_t nup = vup;
	if (VEC_Near(fabs(nup * newz), 1.0))
	{
		matrix_t tempMat = MatRotation(AXIS_Z, PI/2.0);
		nup = nup * tempMat;
	}
	vector_t ycdof = nup ^ newz;
	ycdof.Normalize();
	vector_t dof = newz ^ ycdof;
	dof.Normalize();
	matrix_t omat(ycdof.x, dof.x, newz.x, 0.0,
		ycdof.y, dof.y, newz.y, 0.0,
		ycdof.z, dof.z, newz.z, 0.0,
		0.0, 0.0, 0.0, 1.0);
	return(omat);
}

matrix_t MatScaling(vector_t& scalar)
{
    matrix_t res( scalar.x, 0.0, 0.0, 0.0,
                0.0, scalar.y, 0.0, 0.0,
                0.0, 0.0, scalar.z, 0.0,
                0.0, 0.0, 0.0, 1.0 );
    return(res);
}

//****************************************************************************
//**
//**    END CLASS matrix_t
//**
//****************************************************************************
//****************************************************************************
//**
//**    CLASS quatern_t
//**
//****************************************************************************
//----------------------------------------------------------------------------
//    Public Construction
//----------------------------------------------------------------------------
quatern_t::quatern_t()
{
    x = 0.; y = 0.; z = 0.; w = 1.;
}

quatern_t::quatern_t(vector_t& nv, float nt)
{
    vector_t temp = nv * sin(nt/2.0);
    x = temp.x; y = temp.y; z = temp.z;
    w = cos(nt/2.0);
}

quatern_t::quatern_t(const quatern_t& q)
{
    x = q.x; y = q.y; z = q.z; w = q.w;
}

quatern_t::quatern_t(float f1, float f2, float f3, float f4)
{
	x = f1; y = f2; z = f3; w = f4;
}

//----------------------------------------------------------------------------
//    Public Internal Operators
//----------------------------------------------------------------------------
quatern_t& quatern_t::operator = (const quatern_t& q)
{
    x = q.x; y = q.y; z = q.z; w = q.w;
    return(*this);
}

quatern_t& quatern_t::operator += (const quatern_t& q)
{
    x += q.x; y += q.y; z += q.z; w += q.w;
    return(*this);
}

quatern_t& quatern_t::operator -= (const quatern_t& q)
{
    x -= q.x; y -= q.y; z -= q.z; w -= q.w;
    return(*this);
}

quatern_t& quatern_t::operator *= (const quatern_t& q)
{
//   q3 = q1*q2 - (s1*s2 - v1ùv2, s1*v2 + s2*v1 + v1xv2)
    quatern_t p(*this);
    vector_t v1(p.x, p.y, p.z);
    vector_t v2(q.x, q.y, q.z);
    vector_t temp;
    w = p.w*q.w - (v1*v2);
    temp = (v2*p.w) + (v1*q.w) + (v1 ^ v2);
    x = temp.x; y = temp.y; z = temp.z;
    return(*this);
}

quatern_t& quatern_t::operator *= (const float s)
{
    x *= s; y *= s; z *= s; w *= s;
    return(*this);
}

quatern_t& quatern_t::operator /= (const float s)
{
    x /= s; y /= s; z /= s; w /= s;
    return(*this);
}

//----------------------------------------------------------------------------
//    Public Methods
//----------------------------------------------------------------------------
float quatern_t::Normalize()
{
    float length = Length();
    *this /= length;
    return(length);
}

float quatern_t::Length()
{
    return(sqrt(x*x + y*y + z*z + w*w));
}

void quatern_t::Init(vector_t& nv, float nt)
{
    vector_t temp = nv * sin(nt/2.0);
    x = temp.x; y = temp.y; z = temp.z;
    w = cos(nt/2.0);
}

void quatern_t::Init(float nx, float ny, float nz, float nw)
{
	x = nx; y = ny; z = nz; w = nw;
}

void quatern_t::Init(matrix_t &imat) // FIXME: the +-sqrt issue has to be resolved for this to work
{
	x = sqrt((imat.Data[0][0] - imat.Data[1][1] - imat.Data[2][2] + imat.Data[3][3])/4.0);
	y = sqrt((-imat.Data[0][0] + imat.Data[1][1] - imat.Data[2][2] + imat.Data[3][3])/4.0);
	z = sqrt((-imat.Data[0][0] - imat.Data[1][1] + imat.Data[2][2] + imat.Data[3][3])/4.0);
	w = sqrt((imat.Data[0][0] + imat.Data[1][1] + imat.Data[2][2] + imat.Data[3][3])/4.0);
	Normalize();
}

//----------------------------------------------------------------------------
//    External Operators
//----------------------------------------------------------------------------
quatern_t operator - (const quatern_t& v1)
{
    quatern_t res;
    res.x = -v1.x; res.y = -v1.y; res.z = -v1.z; res.w = -v1.w;
    return(res);
}

quatern_t operator + (const quatern_t& v1, const quatern_t& v2)
{
    quatern_t res;
    res.x = v1.x + v2.x;
    res.y = v1.y + v2.y;
    res.z = v1.z + v2.z;
    res.w = v1.w + v2.w;
    return(res);
}

quatern_t operator - (const quatern_t& v1, const quatern_t& v2)
{
    quatern_t res;
    res.x = v1.x - v2.x;
    res.y = v1.y - v2.y;
    res.z = v1.z - v2.z;
    res.w = v1.w - v2.w;
    return(res);
}

quatern_t operator * (const quatern_t& v1, const quatern_t& v2)
{
    quatern_t res = v1;
    res *= v2;
    return(res);
}

//----------------------------------------------------------------------------
//    Friend Functions
//----------------------------------------------------------------------------

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
//----------------------------------------------------------------------------
//    Public Construction
//----------------------------------------------------------------------------
plane_t::plane_t()
{
}

plane_t::plane_t(vector_t &n1, float d1)
{
	n = n1; d = d1;
}

plane_t::plane_t(vector_t &n1, vector_t &p)
{
	n = n1; d = -(n*p);
}

plane_t::plane_t(vector_t &p1, vector_t &p2, vector_t &p3)
{
	TriExtract(p1, p2, p3);
}

plane_t::plane_t(float a1, float b1, float c1, float d1)
{
	n.x = a1; n.y = b1; n.z = c1; d = d1;
}

//----------------------------------------------------------------------------
//    Public Internal Operators
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Public Methods
//----------------------------------------------------------------------------
float plane_t::Distance(vector_t &p)
{
	vector_t q = Nearest(p);
	return(q.Distance(p));
}

vector_t plane_t::Nearest(vector_t &p)
{
	vector_t q = p - (n * ((d + (n*p))/(n*n)));
	return(q);
}

float plane_t::IntersectionUV(vector_t &lu, vector_t &lv, vector_t &out)
{
	float denom = lv * n;
	if (VEC_Near(denom, 0.0))
		return(FLT_MAX);
	float t = -((d+(lu * n))/denom);
	out = lv*t;
	out += lu;
	return(t);
}

float plane_t::IntersectionPQ(vector_t &p, vector_t &q, vector_t &out)
{
	vector_t lv = q;
	lv -= p;
	lv.Normalize();
	return(IntersectionUV(p, lv, out));
}

void plane_t::TriExtract(vector_t &p1, vector_t &p2, vector_t &p3)
{
	vector_t t1, t2;
	t1 = p1-p2;
	t2 = p3-p2;	
	n = t1 ^ t2; // clockwise forward
	n.Normalize();
	d = -(n*p2);
}

//----------------------------------------------------------------------------
//    External Operators
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Friend Functions
//----------------------------------------------------------------------------
//****************************************************************************
//**
//**    END CLASS plane_t
//**
//****************************************************************************


//****************************************************************************
//**
//**    END MODULE MATH_VEC.CPP
//**
//****************************************************************************

