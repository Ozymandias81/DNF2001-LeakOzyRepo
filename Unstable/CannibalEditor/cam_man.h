#ifndef __CAM_MAN_H__
#define __CAM_MAN_H__
//****************************************************************************
//**
//**    CAM_MAN.H
//**    Header - Camera Management
//**
//****************************************************************************
//----------------------------------------------------------------------------
//    Headers
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Definitions
//----------------------------------------------------------------------------
#define CAMF_CLIPACTIVE		0x00000001 // clip all incoming primitives to frustum

//----------------------------------------------------------------------------
//    Class Prototypes
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Required External Class References
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Structures
//----------------------------------------------------------------------------
typedef struct
{
	vector_t p[24];
	vector_t c[24];
	vector_t tv[24];
	float a[24];
} cliptri_t;

//----------------------------------------------------------------------------
//    Public Data Declarations
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Public Function Declarations
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Class Headers
//----------------------------------------------------------------------------
//****************************************************************************
//**
//**    CLASS frustum_t
//**
//****************************************************************************

class frustum_t
{
public:
    // data
	float xr, yr, fd, bd;

	plane_t top;
	plane_t bottom;
	plane_t left;
	plane_t right;
	plane_t front;
	plane_t back;
    // construction
	frustum_t();
	frustum_t(float xres, float yres, float frontlim, float backlim);
	~frustum_t();
    // internal operators
    // methods
	void Set(float xres, float yres, float frontlim, float backlim);
	int ClipPoly(int numverts, vector_t *p, vector_t *c, float *a, vector_t *tv, cliptri_t *out);
	int ClipLine(vector_t *inp, vector_t *inc, vector_t *outp, vector_t *outc);
    // external operators
    // friend functions
    // friend classes

};

//****************************************************************************
//**
//**    END CLASS frustum_t
//**
//****************************************************************************
//****************************************************************************
//**
//**    CLASS camera_t
//**
//****************************************************************************

class camera_t
{
private:	
	void CalcViewTransform();

public:
    // data
		// 3d view frustum
	frustum_t frust;
		// 2d screen box
	vector_t scrStart;
	vector_t scrEnd;
	vector_t scrDim;
	vector_t scrCenter; // precalculated for projections
	vector_t scrScale;
		// projection fov factors
	vector_t fovFactor;
		// physical camera orientation
	vector_t position;
	vector_t target;
	float rollangle;
		// extrapolated coordinate frame
	vector_t vforward; // extrapolated, normalize(target-position)
	vector_t vup;
	vector_t vright;
		// extrapolated geometric transforms
	matrix_t rollmat; // roll axis component of xform
	matrix_t xform; // final rotation transform
	matrix_t invxform; // inverse of xform (transpose)
	
	unsigned long flags;

    // construction
	camera_t();
	~camera_t();

	// internal operators
    // methods
	void Init();

	void TransCameraToView(vector_t *v);
	void TransWorldToCamera(vector_t *v);
	void TransCameraToWorld(vector_t *v);
	void TransViewToWorldLine(vector_t &inScr, vector_t &outU, vector_t &outV);
	void SetScreenBox(int x1, int y1, int dx, int dy);
	void SetViewVolume(float xres, float yres, float frontlim, float backlim);
	void SetFOV(float xfactor, float yfactor);
	void SetPosition(vector_t &npos);
	void SetPosition(float px, float py, float pz);
	void SetTarget(vector_t &ntarg);
	void SetTarget(float tx, float ty, float tz);
	void SetRoll(float nroll);
		// turning and motion
	void TiltX(float xtilt);
	void TiltY(float ytilt);
	void TiltZ(float ztilt);
	void LookTilt(float xtilt, float ytilt);
	void MoveForward(float forward);
	void MoveRight(float right);
	void MoveUp(float up);

	// worldspace 3d versions of 2d drawing primitives
	void SetDrawDepthBias(float bias);
	void DrawLine(vector_t *p1, vector_t *p2, vector_t *c1, vector_t *c2, boolean useDepth);
	void DrawTriangle(vector_t *p /* 3 */, vector_t *c /* 3 */, float *a /* 3 */, vector_t *tv, boolean useDepth);
	void DrawTriangleFlags(U32 flags,vector_t *p,vector_t *c, float *a, vector_t *tv, boolean useDepth);
	void DrawPolygon(int numverts, vector_t *p, vector_t *c, float *a, vector_t *tv, boolean useDepth);
	void DrawPolygonFlags(U32 flags,int numverts, vector_t *p, vector_t *c, float *a, vector_t *tv, boolean useDepth);
	void DrawProjectedString(vector_t *inp, char *str, boolean filtered, int r, int g, int b, boolean useDepth);
	void DrawBox(vector_t *p1, vector_t *p2, vector_t *colors /* box, border, text */, char *str, boolean useDepth, boolean extBorder);
    
	// external operators
    // friend functions
    // friend classes

};

//****************************************************************************
//**
//**    END CLASS camera_t
//**
//****************************************************************************
//****************************************************************************
//**
//**    END HEADER CAM_MAN.H
//**
//****************************************************************************
#endif // __CAM_MAN_H__
