//****************************************************************************
//**
//**    CAM_MAN.CPP
//**    Camera Management
//**
//****************************************************************************
//----------------------------------------------------------------------------
//    Headers
//----------------------------------------------------------------------------
#include "cbl_defs.h"
#include "cam_man.h"
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
static float drawDepthBias = 0.0;
//----------------------------------------------------------------------------
//    Public Data
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Private Code
//----------------------------------------------------------------------------
static int Near(float val1, float val2)
{
    float temp = val1 - val2;
    return((temp <= 1E-4) && (temp >= -1E-4));
}

static int ClipToPlane(cliptri_t *in, int innum, cliptri_t *out, plane_t &pln, boolean clipC, boolean clipTV, boolean clipA)
{
	//static vector_t p1, p2;
	static float dist, frac, onemfrac;
	static int nextin, curin;
	static int i, j, allin, allout, val;
	static int inflags[24];
	int outnum = 0;
	
	int clipFlags=0;
	if (clipC)
		clipFlags |= 1;
	if (clipTV)
		clipFlags |= 2;
	if (clipA)
		clipFlags |= 4;

	allin = 1; allout = 1;
	for (i=0;i<innum;i++)
	{
		val = (inflags[i] = ((in->p[i] * pln.n) + pln.d) > 0.0);
		allin &= val;
		allout &= !(val);
	}
	if (allout)
		return(0);
	if (allin)
	{
		// this is a lot faster than a pure memcpy
		for (i=0;i<innum;i++)
		{
			out->p[i] = in->p[i];
		}
		switch(clipFlags)
		{
		case 1:
			for (i=0;i<innum;i++)
			{
				out->c[i] = in->c[i];
			}
			break;
		case 2:
			for (i=0;i<innum;i++)
			{
				out->tv[i] = in->tv[i];
			}
			break;
		case 3:
			for (i=0;i<innum;i++)
			{
				out->c[i] = in->c[i];
				out->tv[i] = in->tv[i];
			}
			break;
		case 4:
			for (i=0;i<innum;i++)
			{
				out->a[i] = in->a[i];
			}
			break;
		case 5:
			for (i=0;i<innum;i++)
			{
				out->c[i] = in->c[i];
				out->a[i] = in->a[i];
			}
			break;
		case 6:
			for (i=0;i<innum;i++)
			{
				out->tv[i] = in->tv[i];
				out->a[i] = in->a[i];
			}
			break;
		case 7:
			for (i=0;i<innum;i++)
			{
				out->c[i] = in->c[i];
				out->tv[i] = in->tv[i];
				out->a[i] = in->a[i];
			}
			break;
		}
		return(innum);
	}

	curin = inflags[0];
	for (i=0;i<innum;i++)
	{
		j = i+1;
		if (j == innum) j = 0;
		if (curin)
		{
			out->p[outnum] = in->p[i];
			switch(clipFlags)
			{
			case 1:
				out->c[outnum] = in->c[i];
				break;
			case 2:
				out->tv[outnum] = in->tv[i];
				break;
			case 3:
				out->c[outnum] = in->c[i];
				out->tv[outnum] = in->tv[i];
				break;
			case 4:
				out->a[outnum] = in->a[i];
				break;
			case 5:
				out->c[outnum] = in->c[i];
				out->a[outnum] = in->a[i];
				break;
			case 6:
				out->tv[outnum] = in->tv[i];
				out->a[outnum] = in->a[i];
				break;
			case 7:
				out->c[outnum] = in->c[i];
				out->tv[outnum] = in->tv[i];
				out->a[outnum] = in->a[i];
				break;
			}
			outnum++;
		}
		nextin = inflags[j];
		if (curin != nextin)
		{
			dist = pln.IntersectionPQ(in->p[i], in->p[j], out->p[outnum]);
			frac = dist / in->p[i].Distance(in->p[j]);
			onemfrac = 1.0 - frac;
			switch(clipFlags)
			{
			case 1:
				out->c[outnum] = in->c[j]*frac+in->c[i]*onemfrac;
				break;
			case 2:
				out->tv[outnum] = in->tv[j]*frac+in->tv[i]*onemfrac;
				break;
			case 3:
				out->c[outnum] = in->c[j]*frac+in->c[i]*onemfrac;
				out->tv[outnum] = in->tv[j]*frac+in->tv[i]*onemfrac;
				break;
			case 4:
				out->a[outnum] = in->a[j]*frac+in->a[i]*onemfrac;
				break;
			case 5:
				out->c[outnum] = in->c[j]*frac+in->c[i]*onemfrac;
				out->a[outnum] = in->a[j]*frac+in->a[i]*onemfrac;
				break;
			case 6:
				out->tv[outnum] = in->tv[j]*frac+in->tv[i]*onemfrac;
				out->a[outnum] = in->a[j]*frac+in->a[i]*onemfrac;
				break;
			case 7:
				out->c[outnum] = in->c[j]*frac+in->c[i]*onemfrac;
				out->tv[outnum] = in->tv[j]*frac+in->tv[i]*onemfrac;
				out->a[outnum] = in->a[j]*frac+in->a[i]*onemfrac;
				break;
			}
			outnum++;
		}
		curin = nextin;
	}
	return(outnum);
}

//----------------------------------------------------------------------------
//    Public Code
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Class Member Code
//----------------------------------------------------------------------------
//****************************************************************************
//**
//**    CLASS frustum_t
//**
//****************************************************************************
//----------------------------------------------------------------------------
//    Public Construction
//----------------------------------------------------------------------------
frustum_t::frustum_t()
{
	if (vid.resolution)
        Set(vid.resolution->width, vid.resolution->height, 16, 1024);
    else
        Set(640, 480, 16, 1024);
}

frustum_t::frustum_t(float xres, float yres, float frontlim, float backlim)
{
	Set(xres, yres, frontlim, backlim);
}

frustum_t::~frustum_t()
{
}

//----------------------------------------------------------------------------
//    Public Methods
//----------------------------------------------------------------------------
void frustum_t::Set(float xres, float yres, float frontlim, float backlim)
{
	xr = xres;
	yr = yres;
	fd = frontlim;
	bd = backlim;

	vector_t ul(-xres/2.0+1, yres/2.0-1, -256.0);
	vector_t ur(xres/2.0-1, yres/2.0-1, -256.0);
	vector_t ll(-xres/2.0+1, -yres/2.0+1, -256.0);
	vector_t lr(xres/2.0-1, -yres/2.0+1, -256.0);
	left.n = ll ^ ul;
	right.n = ur ^ lr;
	top.n = ul ^ ur;
	bottom.n = lr ^ ll;
	front.n.Set(0, 0, -1);
	back.n.Set(0, 0, 1);
	left.n.Normalize();
	right.n.Normalize();
	top.n.Normalize();
	bottom.n.Normalize();
	left.d = 0;
	right.d = 0;
	top.d = 0;
	bottom.d = 0;
	front.d = -frontlim;
	back.d = backlim;
}

int frustum_t::ClipPoly(int numverts, vector_t *p, vector_t *c, float *a, vector_t *tv, cliptri_t *out)
{
	static cliptri_t b1, b2;
	int i;
	boolean clipC=true, clipTV=true, clipA=true;

	if (!p)
		return(0);
	if (!c)
		clipC=false;
	if (!tv)
		clipTV=false;
	if (!a)
		clipA=false;
	for (i=0;i<numverts;i++)
	{
		b1.p[i] = p[i];
		if (clipC)
			b1.c[i] = c[i];
		if (clipTV)
			b1.tv[i] = tv[i];
		if (clipA)
			b1.a[i] = a[i];
	}	
	i = ClipToPlane(&b1, numverts, &b2, front, clipC, clipTV, clipA);
	i = ClipToPlane(&b2, i, &b1, back, clipC, clipTV, clipA);
	i = ClipToPlane(&b1, i, &b2, top, clipC, clipTV, clipA);
	i = ClipToPlane(&b2, i, &b1, bottom, clipC, clipTV, clipA);
	i = ClipToPlane(&b1, i, &b2, left, clipC, clipTV, clipA);
	i = ClipToPlane(&b2, i, out, right, clipC, clipTV, clipA);
	if (i < 3)
		return(0);
	else
		return(i);
}

int frustum_t::ClipLine(vector_t *inp, vector_t *inc, vector_t *outp, vector_t *outc)
{
	static cliptri_t b1, b2;
	int i;
	boolean clipC=true;

	if (!inp || !outp)
		return(0);
	if (!inc || !outc)
		clipC=false;
	
	b1.p[0] = inp[0]; b1.p[1] = inp[1];
	if (clipC)
	{
		b1.c[0] = inc[0]; b1.c[1] = inc[1];
	}
	i = ClipToPlane(&b1, 2, &b2, front, clipC, false, false);
	i = ClipToPlane(&b2, i, &b1, back, clipC, false, false);
	i = ClipToPlane(&b1, i, &b2, top, clipC, false, false);
	i = ClipToPlane(&b2, i, &b1, bottom, clipC, false, false);
	i = ClipToPlane(&b1, i, &b2, left, clipC, false, false);
	i = ClipToPlane(&b2, i, &b1, right, clipC, false, false);
	if (i < 2)
		return(0);
	outp[0] = b1.p[0]; outp[1] = b1.p[1];
	if (clipC)
	{
		outc[0] = b1.c[0]; outc[1] = b1.c[1];
	}
	return(i);
}

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
//----------------------------------------------------------------------------
//    Private Methods
//----------------------------------------------------------------------------
void camera_t::CalcViewTransform()
{
	vector_t rotaxis(0.0, 1.0, 0.0);
		
	if (fabs(rotaxis * vforward) > 0.9997)
		rotaxis = vup; // looking right at yaxis, so use existing vup instead

	vright = vforward ^ rotaxis;
	vright.Normalize();
	vup = vright ^ vforward;
	rollmat = MatRotation(AXIS_Z, rollangle);
	matrix_t omat(vright.x, vup.x, -vforward.x, 0.0,
		vright.y, vup.y, -vforward.y, 0.0,
		vright.z, vup.z, -vforward.z, 0.0,
		0.0, 0.0, 0.0, 1.0);
	xform = omat * rollmat;
	invxform = xform.Transpose();
}

//----------------------------------------------------------------------------
//    Public Construction
//----------------------------------------------------------------------------
camera_t::camera_t()
{
	Init();
}

camera_t::~camera_t()
{
}

//----------------------------------------------------------------------------
//    Public Internal Operators
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Public Methods
//----------------------------------------------------------------------------
void camera_t::Init()
{
	position.Set(0, 0, 256);
	target.Set(0, 0, 0);
	rollangle = 0;
	vforward = target - position;
	vforward.Normalize();
	vup.Set(0, 1, 0);
    if (vid.resolution)
    {
        SetScreenBox(0, 0, vid.resolution->width, vid.resolution->height);
	    SetViewVolume(vid.resolution->width, vid.resolution->height, 2, 1024);
    }
    else
    {
	    SetScreenBox(0, 0, 640, 480);
	    SetViewVolume(640, 480, 2, 1024);
    }
	fovFactor.Set(256, 256, 0);
	CalcViewTransform();

	flags = CAMF_CLIPACTIVE;
}

void camera_t::TransCameraToView(vector_t *v)
{
	static vector_t temp;
	if (!v->z)
		SYS_Error("camera_t::TransCameraToView - Divide by zero");
	temp = *v;
	v->x = (int)(scrScale.x*fovFactor.x*temp.x/(-temp.z) + scrCenter.x);
	v->y = (int)(scrCenter.y - scrScale.y*fovFactor.y*temp.y/(-temp.z));
	v->z = -temp.z;
}

void camera_t::TransWorldToCamera(vector_t *v)
{
	*v -= position;
	*v *= xform;
}

void camera_t::TransCameraToWorld(vector_t *v)
{
	*v *= invxform;
	*v += position;
}

void camera_t::TransViewToWorldLine(vector_t &inScr, vector_t &outU, vector_t &outV)
{
	outU.x = (inScr.x - (scrDim.x/2.0)) * 256.0 / (scrScale.x * vid.resolution->width);
	outU.y = ((scrDim.y/2.0) - inScr.y) * 256.0 / (scrScale.y * vid.resolution->height);
	outV = outU;
	outU.x /= (fovFactor.x);
	outU.y /= (fovFactor.y);
	outU.z = -1;
	outV.z = -256;
	TransCameraToWorld(&outU);
	TransCameraToWorld(&outV);
	outV -= outU;
	outV.Normalize();
}

void camera_t::SetScreenBox(int x1, int y1, int dx, int dy)
{
	scrStart.Set(x1, y1, 0);
	scrEnd.Set(x1+dx, y1+dy, 0);
	scrDim.Set(scrEnd.x-scrStart.x, scrEnd.y-scrStart.y, 0);
	if (vid.resolution)
        scrScale.Set(scrDim.x/vid.resolution->width, scrDim.y/vid.resolution->height, 0);
    else
	    scrScale.Set(scrDim.x/640.0, scrDim.y/480.0, 0);
	scrCenter.Set(scrStart.x + scrDim.x/2, scrStart.y + scrDim.y/2, 0);
}

void camera_t::SetViewVolume(float xres, float yres, float frontlim, float backlim)
{
	frust.Set(xres, yres, frontlim, backlim);
}

void camera_t::SetFOV(float xfactor, float yfactor)
{
	float adjx = fovFactor.x / xfactor;
	float adjy = fovFactor.y / yfactor;

	fovFactor.Set(xfactor, yfactor, 0);
	frust.Set(frust.xr*adjx, frust.yr*adjy, frust.fd, frust.bd);
}

void camera_t::SetPosition(vector_t &npos)
{
	position = npos;
	vforward = target - position;
	if (!vforward)
	{
		target.z -= 256.0;
		vforward = target - position;
	}
	vforward.Normalize();
	CalcViewTransform();
}

void camera_t::SetPosition(float px, float py, float pz)
{
	vector_t temp;
	temp.Set(px, py, pz);
	SetPosition(temp);
}

void camera_t::SetTarget(vector_t &ntarg)
{
	target = ntarg;
	vforward = target - position;
	if (!vforward)
	{
		target.z -= 256.0;
		vforward = target - position;
	}
	vforward.Normalize();
	CalcViewTransform();
}

void camera_t::SetTarget(float tx, float ty, float tz)
{
	vector_t temp;
	temp.Set(tx, ty, tz);
	SetTarget(temp);
}

void camera_t::SetRoll(float nroll)
{
	rollangle = nroll;
	CalcViewTransform();
}

void camera_t::TiltX(float xtilt)
{
	//matrix_t tiltmat = MatRotation(AXIS_Y, -xtilt);
	quatern_t q(vup, xtilt);
	matrix_t tiltmat = MatRotation(q);
	
	vforward = vforward * tiltmat;
	target = position + vforward;
	CalcViewTransform();
}

void camera_t::TiltY(float ytilt)
{
	//matrix_t tiltmat = MatRotation(AXIS_X, -ytilt);
	quatern_t q(vright, -ytilt);
	matrix_t tiltmat = MatRotation(q);

	vector_t oview = vforward;
	vforward = vforward * tiltmat;
	while (fabs(vforward.y) > 0.9997)
	{
		vforward = oview; // don't allow pure vertical
		ytilt += 0.015; // add about a degree to the angle
		tiltmat = MatRotation(AXIS_X, -ytilt);
		vforward = vforward * tiltmat;
	}
	target = position + vforward;
	CalcViewTransform();
}

void camera_t::TiltZ(float ztilt)
{
	SetRoll(rollangle+ztilt);
}

void camera_t::LookTilt(float xtilt, float ytilt) // tilts are roughly in screen coordinates
{
	quatern_t q1(vforward, -rollangle);
	matrix_t xmat = MatRotation(q1);
	vector_t pvec = position;

	quatern_t q2(vup * xmat, xtilt*PI/512.0);
	matrix_t rmat = MatRotation(q2);
	pvec -= target;
	pvec *= rmat;
	pvec += target;
	SetPosition(pvec);

	quatern_t q3(vright * xmat, ytilt*PI/512.0);
	rmat = MatRotation(q3);
	pvec -= target;
	pvec *= rmat;
	pvec += target;
	SetPosition(pvec);
}

void camera_t::MoveForward(float forward)
{
	position += (vforward * forward);
//	target += (vforward * forward);
	CalcViewTransform();
}

void camera_t::MoveRight(float right)
{
	position += (vright * right);
	target += (vright * right);
	CalcViewTransform();
}

void camera_t::MoveUp(float up)
{
	position += (vup * up);
	target += (vup * up);
	CalcViewTransform();
}

void camera_t::SetDrawDepthBias(float bias)
{
	drawDepthBias = bias;
}

void camera_t::DrawLine(vector_t *p1, vector_t *p2, vector_t *c1, vector_t *c2, boolean useDepth)
{
	static vector_t np[4];
	static vector_t nc[4];

	if (!p1 || !p2)
		return;
	np[0] = *p1;
	TransWorldToCamera(&np[0]);
	np[1] = *p2;
	TransWorldToCamera(&np[1]);
	if (c1 && c2)
	{
		nc[0] = *c1;
		nc[1] = *c2;
	}
	if (flags & CAMF_CLIPACTIVE)
	{
		if (c1 && c2)
		{
			if (!frust.ClipLine(&np[0], &nc[0], &np[2], &nc[2]))
				return;
		}
		else
		{
			if (!frust.ClipLine(&np[0], NULL, &np[2], NULL))
				return;
		}
	}
	else
	{
		np[2] = np[0]; np[3] = np[1];
		if (c1 && c2)
		{
			nc[2] = nc[0]; nc[3] = nc[1];
		}
	}
	TransCameraToView(&np[2]); np[2].z += drawDepthBias;
	TransCameraToView(&np[3]); np[3].z += drawDepthBias;
	if (c1 && c2)
		vid.DrawLine(&np[2], &np[3], &nc[2], &nc[3], useDepth);
	else
		vid.DrawLine(&np[2], &np[3], NULL, NULL, useDepth);
}

void camera_t::DrawTriangle(vector_t *p /* 3 */, vector_t *c /* 3 */, float *a /* 3 */, vector_t *tv, boolean useDepth)
{
	DrawPolygon(3, p, c, a, tv, useDepth);
}

void camera_t::DrawTriangleFlags(U32 flags,vector_t *p /* 3 */, vector_t *c /* 3 */, float *a /* 3 */, vector_t *tv, boolean useDepth)
{
	DrawPolygonFlags(flags,3, p, c, a, tv, useDepth);
}

void camera_t::DrawPolygon(int numverts, vector_t *p, vector_t *c, float *a, vector_t *tv, boolean useDepth)
{
	static vector_t np[24];
	int i, num;
	static cliptri_t b1;
	vector_t *oc, *otv;
	float *oa;

	if (!p)
		return;
	for (i=0;i<numverts;i++)
	{
		np[i] = p[i];
		TransWorldToCamera(&np[i]);
	}
	if (flags & CAMF_CLIPACTIVE)
	{
		if (!(num = frust.ClipPoly(numverts, np, c, a, tv, &b1)))
			return;
	}
	else
	{
		for (i=0;i<numverts;i++)
		{
			b1.p[i] = np[i];
			if (c)
				b1.c[i] = c[i];
			if (a)
				b1.a[i] = a[i];
			if (tv)
				b1.tv[i] = tv[i];
		}
		num = numverts;
	}
	
	oa = NULL;
	oc = otv = NULL;
	if (c) oc = b1.c;
	if (a) oa = b1.a;
	if (tv) otv = b1.tv;
	for (i=0;i<num;i++)
	{
		TransCameraToView(&b1.p[i]);
		b1.p[i].z += drawDepthBias;
	}
	vid.DrawPolygonFlags(flags,num, b1.p, oc, oa, otv, useDepth);
}

void camera_t::DrawPolygonFlags(U32 Flags,int numverts, vector_t *p, vector_t *c, float *a, vector_t *tv, boolean useDepth)
{	
	static vector_t np[24];
	int i, num;
	static cliptri_t b1;
	vector_t *oc, *otv;
	float *oa;

	if (!p)
		return;
	for (i=0;i<numverts;i++)
	{
		np[i] = p[i];
		TransWorldToCamera(&np[i]);
	}
	if (flags & CAMF_CLIPACTIVE)
	{
		if (!(num = frust.ClipPoly(numverts, np, c, a, tv, &b1)))
			return;
	}
	else
	{
		for (i=0;i<numverts;i++)
		{
			b1.p[i] = np[i];
			if (c)
				b1.c[i] = c[i];
			if (a)
				b1.a[i] = a[i];
			if (tv)
				b1.tv[i] = tv[i];
		}
		num = numverts;
	}
	
	oa = NULL;
	oc = otv = NULL;
	if (c) oc = b1.c;
	if (a) oa = b1.a;
	if (tv) otv = b1.tv;
	for (i=0;i<num;i++)
	{
		TransCameraToView(&b1.p[i]);
		b1.p[i].z += drawDepthBias;
	}
	vid.DrawPolygonFlags(Flags,num, b1.p, oc, oa, otv, useDepth);
}

void camera_t::DrawProjectedString(vector_t *inp, char *str, boolean filtered, int r, int g, int b, boolean useDepth)
{
	vidcolormodetype_t vcm;
	vidmaskmodetype_t vmm;
	vidfiltermodetype_t vfm;
	vidalphamodetype_t vam;
	vidblendmodetype_t vbm;
	vector_t p[4], tv[4];
	char *ptr;
	static char tbuffer[4] = "*x";
	int i, oldmaskcolor, oldflatcolor, len;
	vector_t grad;

	if (!str || !inp)
		return;
	tv[0].Set(0, 0, 0);
	tv[1].Set(192, 0, 0); // 192 since font texture is 8x8 but chars are only 6x6
	tv[2].Set(192, 192, 0);
	tv[3].Set(0, 192, 0);
	ptr = str;
	oldmaskcolor = *vid.maskColor;
	oldflatcolor = *vid.flatshadeColor;
	vid.MaskColor(0, 0, 0, 0);
	vid.FlatColor(r, g, b);
	vcm = vid.ColorMode(VCM_FLATTEXTURE);
	vmm = vid.MaskMode(VMM_ENABLE);
	if (filtered)
		vfm = vid.FilterMode(VFM_BILINEAR);
	else
		vfm = vid.FilterMode(VFM_NONE);
	vam = vid.AlphaMode(VAM_FLAT);
	vbm = vid.BlendMode(VBM_OPAQUE);
	len = strlen(str);
	grad = (inp[1] - inp[0])/(float)len;
	p[0] = inp[0];
	p[2] = inp[2]-(grad*(len-1));
	p[1] = inp[1]-(grad*(len-1));
	p[3] = inp[3];
	for (i=0;*ptr;i++,ptr++)
	{
		tbuffer[1] = *ptr;
		vid.TexActivate(vid.TexForName(tbuffer), VTA_NORMAL);
		DrawPolygon(4, p, NULL, NULL, tv, useDepth);
		p[0] += grad;
		p[1] += grad;
		p[2] += grad;
		p[3] += grad;
	}
	vid.ColorMode(vcm);
	vid.AlphaMode(vam);
	vid.MaskMode(vmm);
	vid.FilterMode(vfm);
	vid.BlendMode(vbm);
	vid.MaskColor(oldmaskcolor&255, (oldmaskcolor>>8)&255, (oldmaskcolor>>16)&255, (oldmaskcolor>>24)&255);
	vid.FlatColor(oldflatcolor&255, (oldflatcolor>>8)&255, (oldflatcolor>>16)&255);
}

void camera_t::DrawBox(vector_t *p1, vector_t *p2, vector_t *colors /* box, border, text */, char *str, boolean useDepth, boolean extBorder)
{
	static vector_t boxp[8], ptemp[4];
	int i, oldflatcolor;
	static int faces[6][4] = {{0,1,2,3},{5,4,7,6},{4,0,3,7},{1,5,6,2},{4,5,1,0},{3,2,6,7}};
	static int vadj[2][6]={{2,2,0,0,1,1},{1,-1,-1,1,1,-1}};
	vidcolormodetype_t vcm;

	// p1,p2 are bbMin and bbMax
	if (!p1 || !p2 || !colors)
		return;
	boxp[0].Set(p1->x,p2->y,p2->z);
	boxp[1].Set(p2->x,p2->y,p2->z);
	boxp[2].Set(p2->x,p1->y,p2->z);
	boxp[3].Set(p1->x,p1->y,p2->z);
	boxp[4].Set(p1->x,p2->y,p1->z);
	boxp[5].Set(p2->x,p2->y,p1->z);
	boxp[6].Set(p2->x,p1->y,p1->z);
	boxp[7].Set(p1->x,p1->y,p1->z);
	vcm = vid.ColorMode(VCM_FLAT);
	oldflatcolor = *vid.flatshadeColor;
	vid.FlatColor(colors[0].x, colors[0].y, colors[0].z);
	for (i=0;i<6;i++)
	{
		ptemp[0] = boxp[faces[i][0]];
		ptemp[1] = boxp[faces[i][1]];
		ptemp[2] = boxp[faces[i][2]];
		ptemp[3] = boxp[faces[i][3]];
		DrawPolygon(4, ptemp, NULL, NULL, NULL, useDepth);
	}
	vid.FlatColor(colors[1].x, colors[1].y, colors[1].z);
	for (i=0;i<6;i++)
	{
		SetDrawDepthBias(-0.3);
		ptemp[0] = boxp[faces[i][0]];
		ptemp[1] = boxp[faces[i][1]];
		ptemp[2] = boxp[faces[i][2]];
		ptemp[3] = boxp[faces[i][3]];
		DrawLine(&ptemp[0], &ptemp[1], NULL, NULL, useDepth);
		DrawLine(&ptemp[1], &ptemp[2], NULL, NULL, useDepth);
		DrawLine(&ptemp[2], &ptemp[3], NULL, NULL, useDepth);
		DrawLine(&ptemp[3], &ptemp[0], NULL, NULL, useDepth);
		SetDrawDepthBias(0);
		if (extBorder)
		{
			ptemp[0].v[vadj[0][i]] += vadj[1][i];
			ptemp[1].v[vadj[0][i]] += vadj[1][i];
			ptemp[2].v[vadj[0][i]] += vadj[1][i];
			ptemp[3].v[vadj[0][i]] += vadj[1][i];
			DrawLine(&ptemp[0], &ptemp[1], NULL, NULL, useDepth);
			DrawLine(&ptemp[1], &ptemp[2], NULL, NULL, useDepth);
			DrawLine(&ptemp[2], &ptemp[3], NULL, NULL, useDepth);
			DrawLine(&ptemp[3], &ptemp[0], NULL, NULL, useDepth);
			ptemp[0].v[vadj[0][i]] -= vadj[1][i];
			ptemp[1].v[vadj[0][i]] -= vadj[1][i];
			ptemp[2].v[vadj[0][i]] -= vadj[1][i];
			ptemp[3].v[vadj[0][i]] -= vadj[1][i];
		}
		if (str)
		{
			SetDrawDepthBias(-0.3);
			DrawProjectedString(ptemp, str, true, colors[2].x, colors[2].y, colors[2].z, useDepth);
			SetDrawDepthBias(0.0);
		}
	}
	vid.ColorMode(vcm);
	vid.FlatColor(oldflatcolor&255, (oldflatcolor>>8)&255, (oldflatcolor>>16)&255);
}

//----------------------------------------------------------------------------
//    External Operators
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Friend Functions
//----------------------------------------------------------------------------

//****************************************************************************
//**
//**    END CLASS camera_t
//**
//****************************************************************************
//****************************************************************************
//**
//**    END MODULE CAM_MAN.CPP
//**
//****************************************************************************

