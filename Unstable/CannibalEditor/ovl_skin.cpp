//****************************************************************************
//**
//**    OVL_SKIN.CPP
//**    Overlays - Skin View
//**
//****************************************************************************
//----------------------------------------------------------------------------
//    Headers
//----------------------------------------------------------------------------
#include "cbl_defs.h"
#include "ovl_defs.h"
#include "ovl_cc.h"
#include "ovl_work.h"
#include "ovl_skin.h"
#include "ovl_frm.h"

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
CONVAR(float, skin_zoomSpeed, 60.0, 0, NULL);
CONVAR(float, skin_panSpeed, 60.0, 0, NULL);
CONVAR(vector_t, skin_curColor, vector_t(0.0, 0.0, 0.0), 0, NULL);

CONVAR(boolean, skin_hsvMode, 1, 0, NULL);
//----------------------------------------------------------------------------
//    Public Data
//----------------------------------------------------------------------------
U32 _draw_front=0;
//----------------------------------------------------------------------------
//    Private Code Prototypes
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Private Code
//----------------------------------------------------------------------------
#define RETURN_HSV(h,s,v) {HSV.x=(h)*255.0/6.0; HSV.y=(s)*255.0; HSV.z=(v)*255.0; return HSV;}
#define RETURN_RGB(r,g,b) {RGB.x=(r)*255.0; RGB.y=(g)*255.0; RGB.z=(b)*255.0; return RGB;}
#define min(AAA,BBB) ((AAA) < (BBB) ? (AAA) : (BBB))
#define max(AAA,BBB) ((AAA) > (BBB) ? (AAA) : (BBB))
#define min3(AAA,BBB,CCC) min((AAA),min((BBB),(CCC)))
#define max3(AAA,BBB,CCC) max((AAA),max((BBB),(CCC)))

vector_t RGB2HSV(vector_t RGB)
{
    // RGB are each on [0, 1]. S and V are returned on [0, 1] and H is
    // returned on [0, 6]. Exception: H is returned UNDEFINED if S==0.
    float R=RGB.x/255.0, G=RGB.y/255.0, B=RGB.z/255.0, v,x,f;
    int i;
    vector_t HSV;
    x=min3(R,G,B);
    v=max3(R,G,B);
    if(v==x) RETURN_HSV(0,0,v);
    f=(R==x)?G-B:((G==x)?B-R:R-G); i=(R==x)?3:((G==x)?5:1);
    RETURN_HSV(i-f/(v-x),(v-x)/v,v);
}

vector_t HSV2RGB(vector_t HSV)
{
    // H is given on [0, 6] or UNDEFINED. S and V are given on [0, 1].
    // RGB are each returned on [0, 1].
    float h=HSV.x*6.0/255.0, s=HSV.y/255.0, v=HSV.z/255.0, m,n,f;
    int i;
    vector_t RGB;
    if(s==0.0) RETURN_RGB(v,v,v);
    i=(int)h;
    f=h-i;
    if(!(i&1)) f=1-f; // if i is even
    m=v*(1-s);
    n=v*(1-s*f);
    switch (i)
    {
        case 6:
        case 0: RETURN_RGB(v,n,m);
        case 1: RETURN_RGB(n,v,m);
        case 2: RETURN_RGB(m,v,n);
        case 3: RETURN_RGB(m,n,v);
        case 4: RETURN_RGB(n,m,v);
        case 5: RETURN_RGB(v,m,n);
		default:
			RETURN_RGB(0,0,0); // should never happen
    }
}
/*
static boolean PointInPoly(vector_t &p, plane_t &tplane, vector_t &p1, vector_t &p2, vector_t &p3)
{
	int i;
	vector_t enorms[3], v[3], tvec;
	boolean vals[3];

	v[0] = p1; v[1] = p2; v[2] = p3;
	tvec = v[1] - v[0]; tvec.Normalize(); enorms[0] = tplane.n ^ tvec;
	tvec = v[2] - v[1]; tvec.Normalize(); enorms[1] = tplane.n ^ tvec;
	tvec = v[0] - v[2]; tvec.Normalize(); enorms[2] = tplane.n ^ tvec;
	for (i=0;i<3;i++)
	{
		vals[i] = ((p * enorms[i]) > (v[i] * enorms[i]));
	}
	if ((vals[0] == vals[1]) && (vals[0] == vals[2]))
		return(true);
	return(false);
}
*/
static int PointInPoly(vector_t &p, vector_t *v, plane_t &tplane)
{
	int i;
	vector_t enorms[3], tvec;
	
	tvec = v[1] - v[0]; tvec.Normalize();
	enorms[0] = tvec ^ tplane.n;
	tvec = v[2] - v[1]; tvec.Normalize();
	enorms[1] = tvec ^ tplane.n;
	tvec = v[0] - v[2]; tvec.Normalize();
	enorms[2] = tvec ^ tplane.n;
	
	for (i=0;i<3;i++)
	{
		if ((p * enorms[i]) > (v[i] * enorms[i]))
			return(0);
	}
	return(1);
}

static int PointInPolyReverse(vector_t &p, vector_t *v, plane_t &tplane)
{
	int i;
	vector_t enorms[3], tvec;
	
	tvec = v[1] - v[0]; tvec.Normalize();
	enorms[0] = tvec ^ tplane.n;
	tvec = v[2] - v[1]; tvec.Normalize();
	enorms[1] = tvec ^ tplane.n;
	tvec = v[0] - v[2]; tvec.Normalize();
	enorms[2] = tvec ^ tplane.n;
	
	for (i=0;i<3;i++)
	{
		if ((p * enorms[i]) < (v[i] * enorms[i]))
			return(0);
	}
	return(1);
}

//----------------------------------------------------------------------------
//    Public Code
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//    Class Member Code
//----------------------------------------------------------------------------
///////////////////////////////////////////
////    OPalette
///////////////////////////////////////////

REGISTEROVLTYPE(OPalette, OWindow);

void OPalette::InvalidatePalColors()
{
	int i, k;
	for (i=0;i<32;i++)
	{
		for (k=0;k<32;k++)
		{
			palColors[i][k].x = skin_curColor.x;
			palColors[i][k].y = k<<3;
			palColors[i][k].z = i<<3;
			if (skin_hsvMode)
			{ // hsv
				palColors[i][k] = HSV2RGB(palColors[i][k]);
			}
		}
		palColors[32][i].x = i<<3;
		palColors[32][i].y = 0;
		palColors[32][i].z = 0;
		if (skin_hsvMode)
		{ // hsv
			palColors[32][i].x = i<<3;
			palColors[32][i].y = 255;
			palColors[32][i].z = 255;
			palColors[32][i] = HSV2RGB(palColors[32][i]);
		}
	}
}

/*
void OPalette::OnSave()
{
}
*/

/*
void OPalette::OnLoad()
{
}
*/

/*
void OPalette::OnResize()
{
}
*/

void OPalette::OnDraw(int sx, int sy, int dx, int dy, ovlClipBox_t *clipbox)
{
	int i, k, x, y;
	vector_t p[4];

	x = sx; y = sy;
	vid.ColorMode(VCM_FLAT);
	for (i=0;i<32;i++)
	{
		for (k=0;k<32;k++)
		{
			p[0].Set(x+(k<<2), y+(i<<2), 0);
			p[1].Set(x+(k<<2)+4, y+(i<<2), 0);
			p[2].Set(x+(k<<2)+4, y+(i<<2)+4, 0);
			p[3].Set(x+(k<<2), y+(i<<2)+4, 0);
			vid.FlatColor(palColors[i][k].x, palColors[i][k].y, palColors[i][k].z);
			vid.DrawPolygon(4, p, NULL, NULL, NULL, false);
		}
		p[0].Set(x+(i<<2), y+128, 0);
		p[1].Set(x+(i<<2)+4, y+128, 0);
		p[2].Set(x+(i<<2)+4, y+128+8, 0);
		p[3].Set(x+(i<<2), y+128+8, 0);
		vid.FlatColor(palColors[32][i].x, palColors[32][i].y, palColors[32][i].z);
		vid.DrawPolygon(4, p, NULL, NULL, NULL, false);
	}
	k = (int)skin_curColor.y >> 3;
	i = (int)skin_curColor.z >> 3;
	vid.FlatColor(255, 255, 255);
	p[0].Set(x+(k<<2), y+(i<<2), 0);
	p[1].Set(x+(k<<2)+3, y+(i<<2)+3, 0);
	vid.DrawLineBox(&p[0], &p[1], NULL, NULL, false);
	i = (int)skin_curColor.x >> 3;
	p[0].Set(x+(i<<2), y+128, 0);
	p[1].Set(x+(i<<2)+3, y+7+128, 0);
	vid.DrawLineBox(&p[0], &p[1], NULL, NULL, false);
	p[0].Set(x, y+128, 0);
	p[1] = p[0]; p[1].x += 128;
	vid.DrawLine(&p[0], &p[1], NULL, NULL, false);
	vector_t palColor;
	if (!skin_hsvMode)
	{
		palColor = skin_curColor;
	}
	else
	{
		palColor = HSV2RGB(skin_curColor);
	}
	p[0].Set(x+dim.x-26, y-11, 0);
	p[2].Set(x+dim.x-18, y-4, 0);
	p[1].Set(p[2].x, p[0].y, 0);
	p[3].Set(p[0].x, p[2].y, 0);
	vid.FlatColor(palColor.x, palColor.y, palColor.z);
	vid.DrawPolygon(4, p, NULL, NULL, NULL, false);
}

boolean OPalette::OnPress(inputevent_t *event)
{
	if (event->key != KEY_MOUSELEFT)
		return(Super::OnPress(event));

	if (event->mouseY < 128)
	{
		skin_curColor.y = (event->mouseX>>2)<<3;
		skin_curColor.z = (event->mouseY>>2)<<3;
	}
	else
	{
		skin_curColor.x = (event->mouseX>>2)<<3;
		InvalidatePalColors();
	}
	return(1);
}

/*
boolean OPalette::OnDrag(inputevent_t *event)
{
}
*/

/*
boolean OPalette::OnRelease(inputevent_t *event)
{
}
*/

/*
boolean OPalette::OnPressCommand(int argNum, char **argList)
{
}
*/

/*
boolean OPalette::OnDragCommand(int argNum, char **argList)
{
}
*/

/*
boolean OPalette::OnReleaseCommand(int argNum, char **argList)
{
}
*/

/*
boolean OPalette::OnMessage(ovlmsg_t *msg)
{
}
*/

///////////////////////////////////////////
////    OSkinView
///////////////////////////////////////////

REGISTEROVLTYPE(OSkinView, OToolWindow);

void Undo_SkinPaint(char *sig)
{
	int i, val, r, g, b, px, py, modified;
	byte changed[32];
	modelSkin_t *skin, *skinlist;
	if (strcmp(sig, "$skinpaint"))
		return;
	VCR_ReadSetForward();
	skinlist = (modelSkin_t *)VCR_ReadInt();
	VCR_ReadSetBackward();
	memset(changed, 0, 32);
	while (VCR_ReadRemaining() >= 5)
	{
		val = VCR_ReadByte();
		skin = &skinlist[(val & 31)];
		modified = val & 128;
		val = VCR_ReadInt();
		if ((!(skin->flags & MRF_INUSE)) || (!skin->tex))
			continue;
		py = (val >> 24) & 255;
		px = (val >> 16) & 255;
		r = (val >> 10) & 31;
		g = (val >> 5) & 31;
		b = val & 31;
		if (skin->tex->bpp=2)
			((U16 *)skin->tex->tex_data)[py*skin->tex->width+px] = (r << 10) + (g << 5) + b;
		changed[skin->index & 31] = 1;
		if (!modified)
			skin->flags &= ~MRF_MODIFIED;
	}
	for (i=0;i<32;i++)
	{
		if (changed[i])
			vid.TexReload(skinlist[i].tex);
	}
}

void Undo_BaseManip(char *sig)
{
	int i, k, modified, num;
	OWorkspace *ws;
	modelFrame_t *f;
	baseTri_t *baseTris;

	if (strcmp(sig, "$basemanip"))
		return;
	VCR_ReadSetForward();
	VCR_ReadBulk(&ws, 4);
	VCR_ReadBulk(&f, 4);
//	if ((refOverride) && (f != ws->refFrame))
//		return;
//	if ((!refOverride) && (f != ws->GetTopmostFrame()))
//		return;
	modified = VCR_ReadInt();
	num = VCR_ReadInt();
	baseTris = f->GetBaseTris();
	for (i=0;i<num;i++)
	{
		for (k=0;k<3;k++)
		{
			baseTris[i].tverts[k].x = VCR_ReadFloat();
			baseTris[i].tverts[k].y = VCR_ReadFloat();
			baseTris[i].tverts[k].z = VCR_ReadFloat();
		}
	}
	if (!modified)
		f->flags &= ~MRF_MODIFIED;
}

void OVL_SkinPaint(modelSkin_t *skin, int px, int py, int size, float alpha, boolean reload, boolean aa)
{
	int r, g, b, val, wv;
	byte buf[5];
	vector_t pcolor;

	if (size > 0)
	{
		OVL_SkinPaint(skin, px, py, 0, 1.0, reload, aa);
		OVL_SkinPaint(skin, px-1, py, 0, 0.4, reload, aa);
		OVL_SkinPaint(skin, px+1, py, 0, 0.4, reload, aa);
		OVL_SkinPaint(skin, px, py-1, 0, 0.4, reload, aa);
		OVL_SkinPaint(skin, px, py+1, 0, 0.4, reload, aa);
		if (size > 1)
		{
			OVL_SkinPaint(skin, px-1, py-1, 0, 0.25, reload, aa);
			OVL_SkinPaint(skin, px+1, py-1, 0, 0.25, reload, aa);
			OVL_SkinPaint(skin, px+1, py+1, 0, 0.25, reload, aa);
			OVL_SkinPaint(skin, px-1, py+1, 0, 0.25, reload, aa);
		}
		return;
	}
	if ((px < 0) || (px >= (I32)skin->tex->width) || (py < 0) || (py >= (I32)skin->tex->height))
		return;
	val = skin->index & 31;
	if (skin->flags & MRF_MODIFIED)
		val |= 128;
	buf[4] = (byte)val;
	if (skin->tex->bpp==2)
		wv = ((U16 *)skin->tex->tex_data)[py*skin->tex->width+px];

	val = ((py & 255) << 24) + ((px & 255) << 16) + wv;	
	*((int *)buf) = val;
	if (!VCR_WriteBulk(buf, 5))
		return;
	pcolor = skin_curColor;
	if (skin_hsvMode)
		pcolor = HSV2RGB(pcolor);
	r = pcolor.x;
	g = pcolor.y;
	b = pcolor.z;
	if (aa)
	{
		r = (((wv >> 10) & 31) << 3) * (1.0-alpha) + (r * alpha);
		g = (((wv >> 5) & 31) << 3) * (1.0-alpha) + (g * alpha);
		b = ((wv & 31) << 3) * (1.0-alpha) + (b * alpha);
	}
	r >>= 3; g >>= 3; b >>= 3;
	if (skin->tex->bpp==2)
		((U16 *)skin->tex->tex_data)[py*skin->tex->width+px] = (r << 10) + (g << 5) + b;
	skin->flags |= MRF_MODIFIED;
	if (reload)
		vid.TexReload(skin->tex);
}

void OVL_SkinLine(modelSkin_t *skin, int x1, int y1, int x2, int y2, int size, float alpha, boolean aa)
{
	// Yes this is slow, but I need to back up each pixel for undo, so oh well
	int i,x,y,xinc,yinc,temp;

	if (size > 0)
	{
		OVL_SkinLine(skin, x1, y1, x2, y2, 0, 1.0, aa);
		OVL_SkinLine(skin, x1-1, y1, x2-1, y2, 0, 0.4, aa);
		OVL_SkinLine(skin, x1, y1-1, x2, y2-1, 0, 0.4, aa);
		OVL_SkinLine(skin, x1, y1+1, x2, y2+1, 0, 0.4, aa);
		OVL_SkinLine(skin, x1+1, y1, x2+1, y2, 0, 0.4, aa);
		if (size > 1)
		{
			OVL_SkinLine(skin, x1-1, y1-1, x2-1, y2-1, 0, 0.25, aa);
			OVL_SkinLine(skin, x1-1, y1+1, x2-1, y2+1, 0, 0.25, aa);
			OVL_SkinLine(skin, x1+1, y1-1, x2+1, y2-1, 0, 0.25, aa);
			OVL_SkinLine(skin, x1+1, y1+1, x2+1, y2+1, 0, 0.25, aa);
		}
		return;
	}
	// check if x-major or y-major and branch
	if (abs(x2-x1) >= abs(y2-y1)) // X-major
	{
		if (x2 < x1)
		{
			temp = x1;
			x1 = x2;
			x2 = temp;
			temp = y1;
			y1 = y2;
			y2 = temp;
		}

		if ((x2-x1) == 0) return;
		yinc = ((y2-y1) << 16) / (x2-x1);
		y = y1 << 16;

		for (i=x1;i<=x2;i++)
		{
			temp = y>>16;
            OVL_SkinPaint(skin,i,temp,0,alpha,false,aa);
            y += yinc;
		}
	}
	else // Y-major
	{
		if (y2 < y1)
		{
			temp = x1;
			x1 = x2;
			x2 = temp;
			temp = y1;
			y1 = y2;
			y2 = temp;
		}

		if ((y2-y1) == 0) return;
		xinc = ((x2-x1) << 16) / (y2-y1);
		x = x1 << 16;

		for (i=y1;i<=y2;i++)
		{
			temp = x>>16;
            OVL_SkinPaint(skin,temp,i,0,alpha,false,aa);
            x += xinc;
		}
	}
}

void OSkinView::OnSave()
{
	Super::OnSave();
	VCR_EnlargeActionDataBuffer(384);
	if (!skin)
		VCR_WriteByte(0xFF);
	else
		VCR_WriteByte(skin - ((OWorkspace *)this->parent)->mdx->skins);
	VCR_WriteBulk(&camera, sizeof(camera_t));
	VCR_WriteByte(skinbrushsize);
	VCR_WriteByte(skinantialias);
	VCR_WriteByte(skinfiltered);
	VCR_WriteByte(refOverride);
	VCR_WriteByte(selectionMarks);
	VCR_WriteByte(wireframeActive);
}

void OSkinView::OnLoad()
{
	OWorkspace *ws;
	int i;
	
	Super::OnLoad();
	skin = NULL;
	ws = (OWorkspace *)this->parent;
	i = VCR_ReadByte();
	if (i == 0xFF)
		skin = NULL;
	else
		skin = &ws->mdx->skins[i];
	VCR_ReadBulk(&camera, sizeof(camera_t));
	skinbrushsize = VCR_ReadByte();
	skinantialias = VCR_ReadByte();
	skinfiltered = VCR_ReadByte();
	refOverride = VCR_ReadByte();
	selectionMarks = VCR_ReadByte();
	wireframeActive = VCR_ReadByte();
}

/*
void OSkinView::OnResize()
{
}
*/

void OSkinView::OnDraw(int sx, int sy, int dx, int dy, ovlClipBox_t *clipbox)
{
	vector_t p[4], tv[4];
	int i;
	baseTri_t *baseTris, *tri;
	meshTri_t *ftri;
	modelFrame_t *f;
	//boolean usedepth;

	if (_draw_front)
		vid.DebugFront();

	if ((!skin) || (!(skin->flags & MRF_INUSE)))
	{
		flags |= OVLF_TAGDESTROY;
		return;
	}

	baseTris = NULL;
	if (refOverride)
		f = ((OWorkspace *)this->parent)->mdx->refFrame;
	else
		f = ((OWorkspace *)this->parent)->GetTopmostFrame();
	if (f)
		baseTris = f->GetBaseTris();
	
	strcpy(name, SYS_GetFileRoot(skin->name));
	camera.SetScreenBox(sx, sy, dx+1, dy+1);
	//vid.ClipWindow(sx, sy, sx+dx, sy+dy);
	p[0].Set(-((I32)skin->tex->width/2), skin->tex->height/2, 0.1);
	p[1].Set(skin->tex->width/2, skin->tex->height/2, 0.1);
	p[2].Set(skin->tex->width/2, -((I32)skin->tex->height/2), 0.1);
	p[3].Set(-((I32)skin->tex->width/2), -((I32)skin->tex->height/2), 0.1);
	vid.ColorMode(VCM_FLAT);
	vid.FlatColor(255, 255, 255);
	camera.DrawLine(&p[0], &p[1], NULL, NULL, true);
	camera.DrawLine(&p[1], &p[2], NULL, NULL, true);
	camera.DrawLine(&p[2], &p[3], NULL, NULL, true);
	camera.DrawLine(&p[3], &p[0], NULL, NULL, true);
	p[0].z = p[1].z = p[2].z = p[3].z = 0;
	
	/*
	// for reasons unknown, this doesn't work (wraps around etc)... aspect ratio prob?
	tv[0].Set(0, 0, 0);
	tv[1].Set(256, 0, 0);
	tv[2].Set(256, 256, 0);
	tv[3].Set(0, 256, 0);
	*/
	int tx, ty;
	if (skin->tex->width >= skin->tex->height)
	{
		tx = 256;
		ty = 256*skin->tex->height/skin->tex->width;
	}
	else
	{
		tx = 256*skin->tex->width/skin->tex->height;
		ty = 256;
	}
	tv[0].Set(0, 0, 0);
	tv[1].Set(tx, 0, 0);
	tv[2].Set(tx, ty, 0);
	tv[3].Set(0, ty, 0);

	vid.ColorMode(VCM_TEXTURE);
	vid.TexActivate(skin->tex, VTA_NORMAL);
	if (skinfiltered)
		vid.FilterMode(VFM_BILINEAR);
	camera.DrawPolygon(4, p, NULL, NULL, tv, true);
	vid.FilterMode(VFM_NONE);
	if ((skinlineStart.x != -1) && (skinlineStart.y != -1))
	{
		int mx, my;
		mx = in_MouseX; my = in_MouseY; OVL_MousePosWindowRelative(this, &mx, &my);
		vector_t mpoint, lu, lv;
		mpoint.x = mx; mpoint.y = my;
		camera.TransViewToWorldLine(mpoint, lu, lv);
		plane_t pln; pln.n.Set(0, 0, 1); pln.d = 0;
		float dist = pln.IntersectionUV(lu, lv, mpoint);
		if (dist < 0.0)
			return;
		p[0].Set(skinlineStart.x - skin->tex->width/2, -(skinlineStart.y - skin->tex->height/2), 0.1);
		p[1].Set(mpoint.x, mpoint.y, 0.1);
		p[0].x += 0.5; p[0].y -= 0.5;
		vid.ColorMode(VCM_FLAT);
		vid.FlatColor(255, 255, 255);
		camera.DrawLine(&p[0], &p[1], NULL, NULL, true);
	}
	if ((baseboxStart.x != -1) && (baseboxStart.y != -1))
	{
		int xo, yo, mx, my;
		mx = in_MouseX; my = in_MouseY; OVL_MousePosWindowRelative(this, &mx, &my);
		vector_t mpoint, lu, lv;
		mpoint.x = mx; mpoint.y = my;
		camera.TransViewToWorldLine(mpoint, lu, lv);
		plane_t pln; pln.n.Set(0, 0, 1); pln.d = 0;
		float dist = pln.IntersectionUV(lu, lv, mpoint);
		if (dist < 0.0)
			return;
		xo = mpoint.x + skin->tex->width/2; yo = -mpoint.y + skin->tex->height/2;
		p[0].Set(baseboxStart.x, baseboxStart.y, 0.1);
		p[2].Set(mpoint.x, mpoint.y, 0.1);
		p[0].x += 0.5; p[0].y -= 0.5;
		p[1].Set(p[2].x, p[0].y, 0.1);
		p[3].Set(p[0].x, p[2].y, 0.1);
		vid.ColorMode(VCM_FLAT);
		vid.FlatColor(255, 255, 255);
		camera.DrawLine(&p[0], &p[1], NULL, NULL, true);
		camera.DrawLine(&p[1], &p[2], NULL, NULL, true);
		camera.DrawLine(&p[2], &p[3], NULL, NULL, true);
		camera.DrawLine(&p[3], &p[0], NULL, NULL, true);
	}
	if ((baseTris) && (wireframeActive))
	{
		vid.ColorMode(VCM_FLAT);
		vid.FlatColor(255, 255, 255);
		vid.WindingMode(VWM_SHOWALL);
		for (i=0;i<f->numTris;i++)
		{
			tri = &baseTris[i];
			ftri = &f->mdl->mesh.meshTris[i];
			if (ftri->flags & TF_SELECTED)
				continue;
			if (!(tri->flags & BTF_INUSE))
				continue;
            if (tri->flags & BTF_HIDDEN)
                continue;
			p[0].Set(tri->tverts[0].x - skin->tex->width/2 + 0.5, -(tri->tverts[0].y - skin->tex->height/2) - 0.5, 0.1);
			p[1].Set(tri->tverts[1].x - skin->tex->width/2 + 0.5, -(tri->tverts[1].y - skin->tex->height/2) - 0.5, 0.1);
			p[2].Set(tri->tverts[2].x - skin->tex->width/2 + 0.5, -(tri->tverts[2].y - skin->tex->height/2) - 0.5, 0.1);
			camera.DrawLine(&p[0], &p[1], NULL, NULL, false);
			camera.DrawLine(&p[1], &p[2], NULL, NULL, false);
			camera.DrawLine(&p[2], &p[0], NULL, NULL, false);
		}

		for (i=0;i<f->numTris;i++)
		{
			tri = &baseTris[i];
			ftri = &f->mdl->mesh.meshTris[i];
			if (!(ftri->flags & TF_SELECTED))
				continue;
			if (!(tri->flags & BTF_INUSE))
				continue;
            if (tri->flags & BTF_HIDDEN)
                continue;

			float width=((skin->tex->width/2.0f) - 0.5f);
			float height=((skin->tex->height/2.0f) - 0.5f);

			p[0].Set(tri->tverts[0].x - width, (height - tri->tverts[0].y), 0.1f);
			p[1].Set(tri->tverts[1].x - width, (height - tri->tverts[1].y), 0.1f);
			p[2].Set(tri->tverts[2].x - width, (height - tri->tverts[2].y), 0.1f);
			
			vid.FlatColor(255, 0, 0);
			camera.DrawLine(&p[0], &p[1], NULL, NULL, false);
			camera.DrawLine(&p[1], &p[2], NULL, NULL, false);
			camera.DrawLine(&p[2], &p[0], NULL, NULL, false);
			vid.FlatColor(255, 255, 255);
			vector_t c = (p[0]+p[1]+p[2])/3.0;
			if (selectionMarks)
			{
				vector_t m1, m2, m3, m4;
				int k, n;
				float frac;
				vid.FlatColor(255, 16, 0);
				for (k=0;k<3;k++)
				{
					m1 = p[k]; m2 = p[(k+1)%3];
					for (frac=0.0,n=0;n<8;n++,frac+=0.125)
					{
						m3 = (m1*(1.0-frac)+m2*frac);
						m4 = ((c-m3)*0.15)+m3;
						camera.DrawLine(&m3, &m4, NULL, NULL, false);
					}
				}
			}
			if (tri->flags & (BTF_VM0|BTF_VM1|BTF_VM2))
			{
				vid.FlatColor(0, 255, 0);
				if (tri->flags & BTF_VM0)
					camera.DrawLine(&p[0], &c, NULL, NULL, false);
				if (tri->flags & BTF_VM1)
					camera.DrawLine(&p[1], &c, NULL, NULL, false);
				if (tri->flags & BTF_VM2)
					camera.DrawLine(&p[2], &c, NULL, NULL, false);
				vid.FlatColor(255, 255, 255);
			}
		}
		vid.WindingMode(VWM_SHOWCLOCKWISE);
	}

	if (axislockmode)
	{
		if (axislockmode==1)
			vid.DrawString(sx+1, sy+1, 6, 6, "X Only", true, 128, 128, 0);
		if (axislockmode==2)
			vid.DrawString(sx+1, sy+1, 6, 6, "Y Only", true, 128, 128, 0);
	}

	Super::OnDraw(sx, sy, dx, dy, clipbox);
}

/*
boolean OSkinView::OnPress(inputevent_t *event)
{
}
*/

/*
boolean OSkinView::OnDrag(inputevent_t *event)
{
}
*/

/*
boolean OSkinView::OnRelease(inputevent_t *event)
{
}
*/

boolean OSkinView::OnPressCommand(int argNum, char **argList)
{
	OVLCMDSTART

	OVLCMD("zoomin") { if (camera.position.z > 6.0) camera.MoveForward(skin_zoomSpeed*sys_frameTime); return(1); }
	OVLCMD("zoomout") { if (camera.position.z < 1000.0) camera.MoveForward(-skin_zoomSpeed*sys_frameTime); return(1); }
	OVLCMD("panup") { if (camera.position.y < skin->tex->height/2) camera.MoveUp(skin_panSpeed*sys_frameTime); return(1); }
	OVLCMD("pandown") { if (camera.position.y > -((I32)skin->tex->height/2)) camera.MoveUp(-skin_panSpeed*sys_frameTime); return(1); }
	OVLCMD("panright") { if (camera.position.x < skin->tex->width/2) camera.MoveRight(skin_panSpeed*sys_frameTime); return(1); }
	OVLCMD("panleft") { if (camera.position.x > -((I32)skin->tex->width/2)) camera.MoveRight(-skin_panSpeed*sys_frameTime); return(1); }

	OVLCMD("pan")
    {
		int mx, my;
        mx = in_MouseX; my = in_MouseY; OVL_MousePosWindowRelative(this, &mx, &my);
		if ((mx < 0) || (my < 0) || (mx >= dim.x-6) || (my >= dim.y-6-12))
			return(1);
		oldMouseX = mx; oldMouseY = my;
		OVL_LockInput(this);
		return(1);
    }
    OVLCMD("skinpaint")
	{
		int xo, yo, mx, my;
		if ((!skin) || (!skin->tex))
			return(1);
		mx = in_MouseX; my = in_MouseY; OVL_MousePosWindowRelative(this, &mx, &my);
		if ((mx < 0) || (my < 0) || (mx >= dim.x-6) || (my >= dim.y-6-12))
			return(1);
		/*
		xo = (float)mx * skin->tex->width / (float)(dim.x-6);
		yo = (float)my * skin->tex->height / (float)(dim.y-6-12);
		*/
		vector_t mpoint, lu, lv;
		mpoint.x = mx; mpoint.y = my;
		camera.TransViewToWorldLine(mpoint, lu, lv);
		plane_t pln; pln.n.Set(0, 0, 1); pln.d = 0;
		float dist = pln.IntersectionUV(lu, lv, mpoint);
		if (dist < 0.0)
			return(1);
		xo = mpoint.x + skin->tex->width/2; yo = -mpoint.y + skin->tex->height/2;

		VCR_Record(VCRA_UNDO, "$skinpaint", Undo_SkinPaint, 8192, NULL);
		VCR_WriteInt((unsigned long)(((OWorkspace *)this->parent)->mdx->skins));
		OVL_SkinPaint(skin, xo, yo, skinbrushsize, 1.0, false, skinantialias);
		vid.TexReload(skin->tex);
		return(1);
	}
	OVLCMD("skinline")
	{
		int xo, yo, mx, my;
		if ((!skin) || (!skin->tex))
			return(1);
		mx = in_MouseX; my = in_MouseY; OVL_MousePosWindowRelative(this, &mx, &my);
		if ((mx < 0) || (my < 0) || (mx >= dim.x-6) || (my >= dim.y-6-12))
			return(1);
		vector_t mpoint, lu, lv;
		mpoint.x = mx; mpoint.y = my;
		camera.TransViewToWorldLine(mpoint, lu, lv);
		plane_t pln; pln.n.Set(0, 0, 1); pln.d = 0;
		float dist = pln.IntersectionUV(lu, lv, mpoint);
		if (dist < 0.0)
			return(1);
		xo = mpoint.x + skin->tex->width/2; yo = -mpoint.y + skin->tex->height/2;
		skinlineStart.Set(xo, yo, 0);
		OVL_LockInput(this);
		return(1);
	}
	OVLCMD("skineyedrop")
	{
		int xo, yo, mx, my, r, g, b, wv;
		if ((!skin) || (!skin->tex))
			return(1);
		mx = in_MouseX; my = in_MouseY; OVL_MousePosWindowRelative(this, &mx, &my);
		oldMouseX = mx;
		oldMouseY = my;
		if ((mx < 0) || (my < 0) || (mx >= dim.x-6) || (my >= dim.y-6-12))
			return(1);
		/*
		xo = (float)mx * skin->tex->width / (float)(dim.x-6);
		yo = (float)my * skin->tex->height / (float)(dim.y-6-12);
		*/
		vector_t mpoint, lu, lv;
		mpoint.x = mx; mpoint.y = my;
		camera.TransViewToWorldLine(mpoint, lu, lv);
		plane_t pln; pln.n.Set(0, 0, 1); pln.d = 0;
		float dist = pln.IntersectionUV(lu, lv, mpoint);
		if (dist < 0.0)
			return(1);
		xo = mpoint.x + skin->tex->width/2; yo = -mpoint.y + skin->tex->height/2;
		if ((xo < 0) || (xo >= (I32)skin->tex->width) || (yo < 0) || (yo >= (I32)skin->tex->height))
			return(1);
		wv = skin->tex->tex_data[yo*skin->tex->width+xo];
		r = (wv >> 10) & 31; g = (wv >> 5) & 31; b = wv & 31;
		skin_curColor.Set(r<<3, g<<3, b<<3);
		if (skin_hsvMode)
			skin_curColor = RGB2HSV(skin_curColor);
		if (OPalette *palw = (OPalette *)OVL_FindChild(NULL, NULL, "OPalette", NULL))
			palw->InvalidatePalColors();
		return(1);
	}
	OVLCMD("baseselect")
	{
		int i, mx, my;
		baseTri_t *baseTris, *tri;
		meshTri_t *ftri;
		modelFrame_t *f;
		vector_t p[4], nearvert;
		float dist, neardist;

		baseTris = NULL;
		if (refOverride)
			f = ((OWorkspace *)this->parent)->mdx->refFrame;
		else
			f = ((OWorkspace *)this->parent)->GetTopmostFrame();
		if (f)
			baseTris = f->GetBaseTris();

		if (!baseTris)
			return(1);
		mx = in_MouseX; my = in_MouseY; OVL_MousePosWindowRelative(this, &mx, &my);
		if ((mx < 0) || (my < 0) || (mx >= dim.x-6) || (my >= dim.y-6-12))
			return(1);
		vector_t mpoint, lu, lv;
		mpoint.x = mx; mpoint.y = my;
		camera.TransViewToWorldLine(mpoint, lu, lv);
		plane_t pln; pln.n.Set(0, 0, 1); pln.d = 0;
		dist = pln.IntersectionUV(lu, lv, mpoint);
		if (dist < 0.0)
			return(1);
		if (in_keyFlags & KF_SHIFT)
		{
			int xo, yo;
			if ((!skin) || (!skin->tex))
				return(1);
			mx = in_MouseX; my = in_MouseY; OVL_MousePosWindowRelative(this, &mx, &my);
			if ((mx < 0) || (my < 0) || (mx >= dim.x-6) || (my >= dim.y-6-12))
				return(1);
			vector_t mpoint, lu, lv;
			mpoint.x = mx; mpoint.y = my;
			camera.TransViewToWorldLine(mpoint, lu, lv);
			plane_t pln; pln.n.Set(0, 0, 1); pln.d = 0;
			float dist = pln.IntersectionUV(lu, lv, mpoint);
			if (dist < 0.0)
				return(1);
			xo = mpoint.x; yo = mpoint.y;
			baseboxStart.Set(xo, yo, 0);
			OVL_LockInput(this);
		}
		else
		if (!(in_keyFlags & KF_ALT))
		{
			for (i=0;i<f->numTris;i++)
			{			
				tri = &baseTris[i];
				ftri = &f->mdl->mesh.meshTris[i];
				if (!(in_keyFlags & KF_CONTROL))
					ftri->flags &= ~TF_SELECTED;
				if (!(tri->flags & BTF_INUSE))
					continue;
                if (tri->flags & BTF_HIDDEN)
                    continue;
				if (ftri->flags & TF_HIDDEN)
					continue;
				p[0].Set(tri->tverts[0].x - skin->tex->width/2 + 0.5, -(tri->tverts[0].y - skin->tex->height/2) - 0.5, 0.0);
				p[1].Set(tri->tverts[1].x - skin->tex->width/2 + 0.5, -(tri->tverts[1].y - skin->tex->height/2) - 0.5, 0.0);
				p[2].Set(tri->tverts[2].x - skin->tex->width/2 + 0.5, -(tri->tverts[2].y - skin->tex->height/2) - 0.5, 0.0);
				if (PointInPoly(mpoint, p, pln) || PointInPolyReverse(mpoint, p, pln))
				{
					ftri->flags ^= TF_SELECTED;
					tri->flags &= ~(BTF_VM0|BTF_VM1|BTF_VM2);
				}
			}
		}
		else
		{
			neardist = FLT_MAX;
			for (i=0;i<f->numTris;i++)
			{			
				tri = &baseTris[i];
				ftri = &f->mdl->mesh.meshTris[i];
				if (!(tri->flags & BTF_INUSE))
					continue;
                if (tri->flags & BTF_HIDDEN)
                    continue;
				if ((ftri->flags & TF_HIDDEN) || (!(ftri->flags & TF_SELECTED)))
					continue;
				p[0].Set(tri->tverts[0].x - skin->tex->width/2 + 0.5, -(tri->tverts[0].y - skin->tex->height/2) - 0.5, 0.0);
				p[1].Set(tri->tverts[1].x - skin->tex->width/2 + 0.5, -(tri->tverts[1].y - skin->tex->height/2) - 0.5, 0.0);
				p[2].Set(tri->tverts[2].x - skin->tex->width/2 + 0.5, -(tri->tverts[2].y - skin->tex->height/2) - 0.5, 0.0);
				if ((dist = mpoint.Distance(p[0])) < neardist) { neardist = dist; nearvert = p[0]; }
				if ((dist = mpoint.Distance(p[1])) < neardist) { neardist = dist; nearvert = p[1]; }
				if ((dist = mpoint.Distance(p[2])) < neardist) { neardist = dist; nearvert = p[2]; }
			}
			for (i=0;i<f->numTris;i++)
			{			
				tri = &baseTris[i];
				ftri = &f->mdl->mesh.meshTris[i];
                if (tri->flags & BTF_HIDDEN)
                    continue;
				if ((ftri->flags & TF_HIDDEN) || (!(ftri->flags & TF_SELECTED)))
					continue;
				if (!(in_keyFlags & KF_CONTROL))
					tri->flags &= ~(BTF_VM0|BTF_VM1|BTF_VM2);
				p[0].Set(tri->tverts[0].x - skin->tex->width/2 + 0.5, -(tri->tverts[0].y - skin->tex->height/2) - 0.5, 0.0);
				p[1].Set(tri->tverts[1].x - skin->tex->width/2 + 0.5, -(tri->tverts[1].y - skin->tex->height/2) - 0.5, 0.0);
				p[2].Set(tri->tverts[2].x - skin->tex->width/2 + 0.5, -(tri->tverts[2].y - skin->tex->height/2) - 0.5, 0.0);
				if ((p[0].x == nearvert.x) && (p[0].y == nearvert.y) && (p[0].z == nearvert.z))
					tri->flags ^= BTF_VM0;
				if ((p[1].x == nearvert.x) && (p[1].y == nearvert.y) && (p[1].z == nearvert.z))
					tri->flags ^= BTF_VM1;
				if ((p[2].x == nearvert.x) && (p[2].y == nearvert.y) && (p[2].z == nearvert.z))
					tri->flags ^= BTF_VM2;
			}
		}
		return(1);
	}
	OVLCMD("basemove")
	{
		int i, k, mx, my;
		vector_t p[4];
		float dist;
		baseTri_t *baseTris, *tri;
		meshTri_t *ftri;
		modelFrame_t *f;

		baseTris = NULL;
		if (refOverride)
			f = ((OWorkspace *)this->parent)->mdx->refFrame;
		else
			f = ((OWorkspace *)this->parent)->GetTopmostFrame();
		if (f)
			baseTris = f->GetBaseTris();

		if (!baseTris)
			return(1);
		mx = in_MouseX; my = in_MouseY; OVL_MousePosWindowRelative(this, &mx, &my);
		if ((mx < 0) || (my < 0) || (mx >= dim.x-6) || (my >= dim.y-6-12))
			return(1);
		vector_t mpoint, lu, lv;
		mpoint.x = mx; mpoint.y = my;
		camera.TransViewToWorldLine(mpoint, lu, lv);
		plane_t pln; pln.n.Set(0, 0, 1); pln.d = 0;
		dist = pln.IntersectionUV(lu, lv, mpoint);
		if (dist < 0.0)
			return(1);
		bftransStart = mpoint;
		bfmode = 0;
		bfaltmode = 0;
		VCR_Record(VCRA_UNDO, "$basemanip", Undo_BaseManip, f->numTris*36 + 16, NULL);
		VCR_WriteBulk(&this->parent, 4);
		VCR_WriteBulk(&f, 4);
		VCR_WriteInt(f->flags & MRF_MODIFIED);
		VCR_WriteInt(f->numTris);
		for (i=0;i<f->numTris;i++)
		{
			tri = &baseTris[i];
			ftri = &f->mdl->mesh.meshTris[i];
			for (k=0;k<3;k++)
			{
				VCR_WriteFloat(tri->tverts[k].x);
				VCR_WriteFloat(tri->tverts[k].y);
				VCR_WriteFloat(tri->tverts[k].z);
			}
            if (tri->flags & BTF_HIDDEN)
                continue;
			if ((ftri->flags & TF_HIDDEN) || (!(ftri->flags & TF_SELECTED)))
				continue;
			if (tri->flags & (BTF_VM0|BTF_VM1|BTF_VM2))
				bfaltmode = 1;
		}
		OVL_LockInput(this);
		return(1);
	}
	OVLCMD("baserotate")
	{
		int i, k, mx, my;
		vector_t p[4];
		float dist;
		baseTri_t *baseTris;
		modelFrame_t *f;

		baseTris = NULL;
		if (refOverride)
			f = ((OWorkspace *)this->parent)->mdx->refFrame;
		else
			f = ((OWorkspace *)this->parent)->GetTopmostFrame();
		if (f)
			baseTris = f->GetBaseTris();

		if (!baseTris)
			return(1);
		mx = in_MouseX; my = in_MouseY; OVL_MousePosWindowRelative(this, &mx, &my);
		if ((mx < 0) || (my < 0) || (mx >= dim.x-6) || (my >= dim.y-6-12))
			return(1);
		oldMouseX = mx;
		oldMouseY = my;
		vector_t mpoint, lu, lv;
		mpoint.x = mx; mpoint.y = my;
		camera.TransViewToWorldLine(mpoint, lu, lv);
		plane_t pln; pln.n.Set(0, 0, 1); pln.d = 0;
		dist = pln.IntersectionUV(lu, lv, mpoint);
		if (dist < 0.0)
			return(1);
		bftransStart.Set(((int)(mpoint.x + skin->tex->width/2)), ((int)(-(mpoint.y - skin->tex->height/2))), 0);
		bfmode = 1;
		VCR_Record(VCRA_UNDO, "$basemanip", Undo_BaseManip, f->numTris*36 + 16, NULL);
		VCR_WriteBulk(&this->parent, 4);
		VCR_WriteBulk(&f, 4);
		VCR_WriteInt(f->flags & MRF_MODIFIED);
		VCR_WriteInt(f->numTris);
		for (i=0;i<f->numTris;i++)
		{
			for (k=0;k<3;k++)
			{
				VCR_WriteFloat(baseTris[i].tverts[k].x);
				VCR_WriteFloat(baseTris[i].tverts[k].y);
				VCR_WriteFloat(baseTris[i].tverts[k].z);
			}
			baseTris[i].trverts[0] = baseTris[i].tverts[0] - bftransStart;
			baseTris[i].trverts[1] = baseTris[i].tverts[1] - bftransStart;
			baseTris[i].trverts[2] = baseTris[i].tverts[2] - bftransStart;
		}
		OVL_LockInput(this);
		return(1);
	}
	OVLCMD("basescale")
	{
		int i, k, mx, my;
		vector_t p[4];
		float dist;
		baseTri_t *baseTris;
		modelFrame_t *f;

		baseTris = NULL;
		if (refOverride)
			f = ((OWorkspace *)this->parent)->mdx->refFrame;
		else
			f = ((OWorkspace *)this->parent)->GetTopmostFrame();
		if (f)
			baseTris = f->GetBaseTris();

		if (!baseTris)
			return(1);

		mx = in_MouseX; my = in_MouseY; OVL_MousePosWindowRelative(this, &mx, &my);
		if ((mx < 0) || (my < 0) || (mx >= dim.x-6) || (my >= dim.y-6-12))
			return(1);
		oldMouseX = mx;
		oldMouseY = my;
		vector_t mpoint, lu, lv;
		mpoint.x = mx; mpoint.y = my;
		camera.TransViewToWorldLine(mpoint, lu, lv);
		plane_t pln; pln.n.Set(0, 0, 1); pln.d = 0;
		dist = pln.IntersectionUV(lu, lv, mpoint);
		if (dist < 0.0)
			return(1);
		bftransStart.Set(((int)(mpoint.x + skin->tex->width/2)), ((int)(-(mpoint.y - skin->tex->height/2))), 0);
		bfmode = 2;
		VCR_Record(VCRA_UNDO, "$basemanip", Undo_BaseManip, f->numTris*36 + 16, NULL);
		VCR_WriteBulk(&this->parent, 4);
		VCR_WriteBulk(&f, 4);
		VCR_WriteInt(f->flags & MRF_MODIFIED);
		VCR_WriteInt(f->numTris);
		for (i=0;i<f->numTris;i++)
		{
			for (k=0;k<3;k++)
			{
				VCR_WriteFloat(baseTris[i].tverts[k].x);
				VCR_WriteFloat(baseTris[i].tverts[k].y);
				VCR_WriteFloat(baseTris[i].tverts[k].z);
			}
			baseTris[i].trverts[0] = baseTris[i].tverts[0] - bftransStart;
			baseTris[i].trverts[1] = baseTris[i].tverts[1] - bftransStart;
			baseTris[i].trverts[2] = baseTris[i].tverts[2] - bftransStart;
		}
		OVL_LockInput(this);
		return(1);
	}
	OVLCMD("basexflipselected")
	{
		int i, k, numverts;
		vector_t tempv, vcenter;
		vector_t bbMin(FLT_MAX,FLT_MAX,FLT_MAX);
		vector_t bbMax(-FLT_MAX,-FLT_MAX,-FLT_MAX);
		modelFrame_t *f;
		meshTri_t *ftri;
		baseTri_t *baseTris, *tri;

		baseTris = NULL;
		if (refOverride)
			f = ((OWorkspace *)this->parent)->mdx->refFrame;
		else
			f = ((OWorkspace *)this->parent)->GetTopmostFrame();
		if (f)
			baseTris = f->GetBaseTris();
		if (!baseTris)
			return(1);
		numverts = 0;
		for (i=0;i<f->mdl->mesh.numTris;i++)
		{
			tri = &baseTris[i];
			ftri = &f->mdl->mesh.meshTris[i];
			if (!(ftri->flags & TF_SELECTED))
				continue;
			if (!(tri->flags & BTF_INUSE))
				continue;
			numverts += 3;
			for (k=0;k<3;k++)
			{
				tempv = tri->tverts[k];
				if (tempv.x < bbMin.x)
					bbMin.x = tempv.x;
				if (tempv.y < bbMin.y)
					bbMin.y = tempv.y;
				if (tempv.z < bbMin.z)
					bbMin.z = tempv.z;
				if (tempv.x > bbMax.x)
					bbMax.x = tempv.x;
				if (tempv.y > bbMax.y)
					bbMax.y = tempv.y;
				if (tempv.z > bbMax.z)
					bbMax.z = tempv.z;
			}
		}
		if (!numverts)
			return(1);
		vcenter = (bbMin + bbMax)/2;
		for (i=0;i<f->mdl->mesh.numTris;i++)
		{
			tri = &baseTris[i];
			ftri = &f->mdl->mesh.meshTris[i];
			if (!(ftri->flags & TF_SELECTED))
				continue;
			if (!(tri->flags & BTF_INUSE))
				continue;
			for (int k=0;k<3;k++)
			{
				tri->tverts[k].x -= vcenter.x;
				tri->tverts[k].x *= -1;
				tri->tverts[k].x += vcenter.x;
			}
		}
		return(1);
	}
	OVLCMD("baseyflipselected")
	{
		int i, k, numverts;
		vector_t tempv, vcenter;
		vector_t bbMin(FLT_MAX,FLT_MAX,FLT_MAX);
		vector_t bbMax(-FLT_MAX,-FLT_MAX,-FLT_MAX);
		modelFrame_t *f;
		meshTri_t *ftri;
		baseTri_t *baseTris, *tri;

		baseTris = NULL;
		if (refOverride)
			f = ((OWorkspace *)this->parent)->mdx->refFrame;
		else
			f = ((OWorkspace *)this->parent)->GetTopmostFrame();
		if (f)
			baseTris = f->GetBaseTris();
		if (!baseTris)
			return(1);
		numverts = 0;
		for (i=0;i<f->mdl->mesh.numTris;i++)
		{
			tri = &baseTris[i];
			ftri = &f->mdl->mesh.meshTris[i];
			if (!(ftri->flags & TF_SELECTED))
				continue;
			if (!(tri->flags & BTF_INUSE))
				continue;
			numverts += 3;
			for (k=0;k<3;k++)
			{
				tempv = tri->tverts[k];
				if (tempv.x < bbMin.x)
					bbMin.x = tempv.x;
				if (tempv.y < bbMin.y)
					bbMin.y = tempv.y;
				if (tempv.z < bbMin.z)
					bbMin.z = tempv.z;
				if (tempv.x > bbMax.x)
					bbMax.x = tempv.x;
				if (tempv.y > bbMax.y)
					bbMax.y = tempv.y;
				if (tempv.z > bbMax.z)
					bbMax.z = tempv.z;
			}
		}
		if (!numverts)
			return(1);
		vcenter = (bbMin + bbMax)/2;
		for (i=0;i<f->mdl->mesh.numTris;i++)
		{
			tri = &baseTris[i];
			ftri = &f->mdl->mesh.meshTris[i];
			if (!(ftri->flags & TF_SELECTED))
				continue;
			if (!(tri->flags & BTF_INUSE))
				continue;
			for (int k=0;k<3;k++)
			{
				tri->tverts[k].y -= vcenter.y;
				tri->tverts[k].y *= -1;
				tri->tverts[k].y += vcenter.y;
			}
		}
		return(1);
	}
	OVLCMD("cycleaxislock")
	{
		axislockmode = (axislockmode+1)%3;
	}
	OVLCMD("skinbrushsize")
	{
		if (argNum < 2)
			return(1);
		skinbrushsize = atoi(argList[1]);
		return(1);
	}
	OVLCMD("skinantialias")
	{
		if (argNum < 2)
			return(1);
		skinantialias = (atoi(argList[1]) != 0);
		return(1);
	}
	OVLCMD("skinfiltered")
	{
		if (argNum < 2)
			return(1);
		skinfiltered = (atoi(argList[1]) != 0);
		return(1);
	}
	OVLCMD("skinnext")
	{
		modelSkin_t *oldskin = skin;
		OWorkspace *ws = ((OWorkspace *)(this->parent));
		int i, index = skin - ws->mdx->skins;
		for (i=index+1; ;i++)
		{
			if (i == WS_MAXSKINS)
				i = 0;
			if (i == index)
				break;
			if (!(ws->mdx->skins[i].flags & MRF_INUSE))
				continue;
			skin = &ws->mdx->skins[i];
			break;
		}
		if (skin != oldskin)
		{
			if (skin->tex->width >= skin->tex->height)
				camera.SetPosition(0, 0, skin->tex->width);
			else
				camera.SetPosition(0, 0, skin->tex->height);
			camera.SetTarget(0, 0, 0);
			strcpy(name, SYS_GetFileRoot(skin->name));
		}
		return(1);
	}
	OVLCMD("skinprev")
	{
		modelSkin_t *oldskin = skin;
		OWorkspace *ws = ((OWorkspace *)(this->parent));
		int i, index = skin - ws->mdx->skins;
		for (i=index-1; ;i--)
		{
			if (i == -1)
				i = WS_MAXSKINS-1;
			if (i == index)
				break;
			if (!(ws->mdx->skins[i].flags & MRF_INUSE))
				continue;
			skin = &ws->mdx->skins[i];
			break;
		}
		if (skin != oldskin)
		{
			if (skin->tex->width >= skin->tex->height)
				camera.SetPosition(0, 0, skin->tex->width);
			else
				camera.SetPosition(0, 0, skin->tex->height);
			camera.SetTarget(0, 0, 0);
			strcpy(name, SYS_GetFileRoot(skin->name));
		}
		return(1);
	}
	OVLCMD("deleteselected")
	{
		int i;
		modelFrame_t *f;
		meshTri_t *ftri;
		baseTri_t *baseTris, *tri;

		baseTris = NULL;
		if (refOverride)
			f = ((OWorkspace *)this->parent)->mdx->refFrame;
		else
			f = ((OWorkspace *)this->parent)->GetTopmostFrame();
		if (f)
			baseTris = f->GetBaseTris();
		if (!baseTris)
			return(1);
		for (i=0;i<f->mdl->mesh.numTris;i++)
		{
			tri = &baseTris[i];
			ftri = &f->mdl->mesh.meshTris[i];
			if (ftri->flags & TF_SELECTED)
			{
				tri->flags &= ~BTF_INUSE;
				tri->tverts[0].Set(-1,-1,0);
				tri->tverts[1].Set(-1,-1,0);
				tri->tverts[2].Set(-1,-1,0);
			}
		}
		return(1);
	}
	OVLCMD("rollselectedleft")
	{
		int i;
		modelFrame_t *f;
		meshTri_t *ftri;
		baseTri_t *baseTris, *tri;
		vector_t tempv;

		baseTris = NULL;
		if (refOverride)
			f = ((OWorkspace *)this->parent)->mdx->refFrame;
		else
			f = ((OWorkspace *)this->parent)->GetTopmostFrame();
		if (f)
			baseTris = f->GetBaseTris();
		if (!baseTris)
			return(1);
		for (i=0;i<f->mdl->mesh.numTris;i++)
		{
			tri = &baseTris[i];
			ftri = &f->mdl->mesh.meshTris[i];
			if (ftri->flags & TF_SELECTED)
			{
				tempv = tri->tverts[0];
				tri->tverts[0] = tri->tverts[1];
				tri->tverts[1] = tri->tverts[2];
				tri->tverts[2] = tempv;
			}
		}
		return(1);
	}
	OVLCMD("rollselectedright")
	{
		int i;
		modelFrame_t *f;
		meshTri_t *ftri;
		baseTri_t *baseTris, *tri;
		vector_t tempv;

		baseTris = NULL;
		if (refOverride)
			f = ((OWorkspace *)this->parent)->mdx->refFrame;
		else
			f = ((OWorkspace *)this->parent)->GetTopmostFrame();
		if (f)
			baseTris = f->GetBaseTris();
		if (!baseTris)
			return(1);
		for (i=0;i<f->mdl->mesh.numTris;i++)
		{
			tri = &baseTris[i];
			ftri = &f->mdl->mesh.meshTris[i];
			if (ftri->flags & TF_SELECTED)
			{
				tempv = tri->tverts[0];
				tri->tverts[0] = tri->tverts[2];
				tri->tverts[2] = tri->tverts[1];
				tri->tverts[1] = tempv;
			}
		}
		return(1);
	}
	OVLCMD("reverseselected")
	{
		int i;
		modelFrame_t *f;
		meshTri_t *ftri;
		baseTri_t *baseTris, *tri;
		vector_t tempv;

		baseTris = NULL;
		if (refOverride)
			f = ((OWorkspace *)this->parent)->mdx->refFrame;
		else
			f = ((OWorkspace *)this->parent)->GetTopmostFrame();
		if (f)
			baseTris = f->GetBaseTris();
		if (!baseTris)
			return(1);
		for (i=0;i<f->mdl->mesh.numTris;i++)
		{
			tri = &baseTris[i];
			ftri = &f->mdl->mesh.meshTris[i];
			if (ftri->flags & TF_SELECTED)
			{
				tempv = tri->tverts[0];
				tri->tverts[0] = tri->tverts[2];
				tri->tverts[2] = tempv;
			}
		}
		return(1);
	}
	OVLCMD("selectall")
	{
		int i;
		meshTri_t *tri;
		modelFrame_t *f;

		if (refOverride)
			f = ((OWorkspace *)this->parent)->mdx->refFrame;
		else
			f = ((OWorkspace *)this->parent)->GetTopmostFrame();
		if (!f)
			return(1);
		for (i=0;i<f->mdl->mesh.numTris;i++)
		{
			tri = &f->mdl->mesh.meshTris[i];
			tri->flags |= TF_SELECTED;
		}
		return(1);
	}	
	OVLCMD("unselectall")
	{
		int i;
		meshTri_t *tri;
		modelFrame_t *f;

		if (refOverride)
			f = ((OWorkspace *)this->parent)->mdx->refFrame;
		else
			f = ((OWorkspace *)this->parent)->GetTopmostFrame();
		if (!f)
			return(1);
		for (i=0;i<f->mdl->mesh.numTris;i++)
		{
			tri = &f->mdl->mesh.meshTris[i];
			tri->flags &= ~TF_SELECTED;
		}
		return(1);
	}	
	OVLCMD("spawnpalettewindow")
	{
		overlay_t *palw;
		if (!(palw = OVL_FindChild(NULL, NULL, "OPalette", NULL)))
		{ // create a palette box if it doesn't already exist
			OVL_CreateOverlay("OPalette", "Palette", NULL, 0, 0, 128+6, 136+12+6,
				OVLF_ALWAYSTOP|OVLF_NORESIZE|OVLF_NODRAGDROP|OVLF_NOTITLEMINMAX|OVLF_NOFOCUS, true);
		}
		else
			OVL_SetTopmost(palw);
	}
	OVLCMD("referenceoverride")
	{
		if (argNum < 2)
			return(1);
		if (atoi(argList[1]))
			refOverride = 1;
		else
			refOverride = 0;
		return(1);
	}
	OVLCMD("selectionmarks")
	{
		if (argNum < 2)
			return(1);
		if (atoi(argList[1]))
			selectionMarks = 1;
		else
			selectionMarks = 0;
		return(1);
	}
	OVLCMD("wireframe")
	{
		if (argNum < 2)
			return(1);
		if (atoi(argList[1]))
			wireframeActive = 1;
		else
			wireframeActive = 0;
		return(1);
	}

	OVLCMD("cut")
	{
		int i, num;
		modelFrame_t *f;
		meshTri_t *ftri;
		baseTri_t *baseTris, *tri;

		baseTris = NULL;
		if (refOverride)
			f = ((OWorkspace *)this->parent)->mdx->refFrame;
		else
			f = ((OWorkspace *)this->parent)->GetTopmostFrame();
		if (f)
			baseTris = f->GetBaseTris();
		if (!baseTris)
			return(1);
		VCR_Record(VCRA_CLIPBOARD, "$skinbasecopy", NULL, 12*f->mdl->mesh.numTris+16, NULL);
		num = 0;
		for (i=0;i<f->mdl->mesh.numTris;i++)
		{
			tri = &baseTris[i];
			ftri = &f->mdl->mesh.meshTris[i];
			if ((ftri->flags & TF_SELECTED))// && (tri->flags & BTF_INUSE))
			{
				VCR_WriteShort((short)tri->tverts[0].x);
				VCR_WriteShort((short)tri->tverts[0].y);
				VCR_WriteShort((short)tri->tverts[1].x);
				VCR_WriteShort((short)tri->tverts[1].y);
				VCR_WriteShort((short)tri->tverts[2].x);
				VCR_WriteShort((short)tri->tverts[2].y);
				tri->flags &= ~BTF_INUSE;
				tri->tverts[0].Set(-1,-1,0);
				tri->tverts[1].Set(-1,-1,0);
				tri->tverts[2].Set(-1,-1,0);
				num++;
			}
		}
		VCR_WriteShort(num);
		return(1);
	}

	OVLCMD("copy")
	{
		int i, num;
		modelFrame_t *f;
		meshTri_t *ftri;
		baseTri_t *baseTris, *tri;

		baseTris = NULL;
		if (refOverride)
			f = ((OWorkspace *)this->parent)->mdx->refFrame;
		else
			f = ((OWorkspace *)this->parent)->GetTopmostFrame();
		if (f)
			baseTris = f->GetBaseTris();
		if (!baseTris)
			return(1);
		VCR_Record(VCRA_CLIPBOARD, "$skinbasecopy", NULL, 12*f->mdl->mesh.numTris+16, NULL);
		num = 0;
		for (i=0;i<f->mdl->mesh.numTris;i++)
		{
			tri = &baseTris[i];
			ftri = &f->mdl->mesh.meshTris[i];
			if ((ftri->flags & TF_SELECTED))// && (tri->flags & BTF_INUSE))
			{
				VCR_WriteShort((short)tri->tverts[0].x);
				VCR_WriteShort((short)tri->tverts[0].y);
				VCR_WriteShort((short)tri->tverts[1].x);
				VCR_WriteShort((short)tri->tverts[1].y);
				VCR_WriteShort((short)tri->tverts[2].x);
				VCR_WriteShort((short)tri->tverts[2].y);
				num++;
			}
		}
		VCR_WriteShort(num);
		return(1);
	}

	OVLCMD("paste")
	{
		int i, num;
		modelFrame_t *f;
		meshTri_t *ftri;
		baseTri_t *baseTris, *tri;

		baseTris = NULL;
		if (refOverride)
			f = ((OWorkspace *)this->parent)->mdx->refFrame;
		else
			f = ((OWorkspace *)this->parent)->GetTopmostFrame();
		if (f)
			baseTris = f->GetBaseTris();
		if (!baseTris)
			return(1);
		VCR_ActivateAction(VCRA_CLIPBOARD);
		if (strcmp(VCR_ActiveActionName(), "$skinbasecopy"))
			return(1);
		VCR_ResetActionRead();
		VCR_ReadSetBackward();
		num = VCR_ReadShort();
		VCR_ReadSetForward();
		if (!num)
			return(1);
		for (i=0;i<f->mdl->mesh.numTris;i++)
		{
			tri = &baseTris[i];
			ftri = &f->mdl->mesh.meshTris[i];
			if (ftri->flags & TF_SELECTED)
			{
				tri->tverts[0].x = VCR_ReadShort();
				tri->tverts[0].y = VCR_ReadShort();
				tri->tverts[0].z = 0.0f;
				tri->tverts[1].x = VCR_ReadShort();
				tri->tverts[1].y = VCR_ReadShort();
				tri->tverts[1].z = 0.0f;
				tri->tverts[2].x = VCR_ReadShort();
				tri->tverts[2].y = VCR_ReadShort();
				tri->tverts[2].z = 0.0f;
				tri->flags |= BTF_INUSE;
				if ((tri->tverts[0].x == -1) || (tri->tverts[0].y == -1)
				 || (tri->tverts[1].x == -1) || (tri->tverts[1].y == -1)
				 || (tri->tverts[2].x == -1) || (tri->tverts[2].y == -1))
					tri->flags &= ~BTF_INUSE;
				num--;
				if (!num)
				{ // loop through as many times as we have tris
					VCR_ResetActionRead();
					VCR_ReadSetBackward();
					num = VCR_ReadShort();
					VCR_ReadSetForward();
				}
			}
		}
		return(1);
	}

	return(Super::OnPressCommand(argNum, argList));
}

boolean OSkinView::OnDragCommand(int argNum, char **argList)
{
	OVLCMDSTART
	OVLCMD("pan")
    {
		int mx, my;
        mx = in_MouseX; my = in_MouseY; OVL_MousePosWindowRelative(this, &mx, &my);
		if (axislockmode != 1)
		{
			if ((oldMouseY-my) >= 0)
			{
				if (camera.position.y < skin->tex->height/2)
					camera.MoveUp(oldMouseY-my);
			}
			else
			{
				if (camera.position.y > -((I32)skin->tex->height/2))
					camera.MoveUp(oldMouseY-my);
			}
		}
        if (axislockmode != 2)
		{
			if ((mx-oldMouseX) >= 0)
			{
				if (camera.position.x < skin->tex->width/2)
					camera.MoveRight(mx-oldMouseX);
			}
			else
			{
				if (camera.position.x > -((I32)skin->tex->width/2))
					camera.MoveRight(mx-oldMouseX);
			}
		}
        oldMouseX = mx;
		oldMouseY = my;
		return(1);
    }
	OVLCMD("skinpaint")
	{
		int xo, yo, mx, my;
		if ((!skin) || (!skin->tex))
			return(1);
		mx = in_MouseX; my = in_MouseY; OVL_MousePosWindowRelative(this, &mx, &my);
		if ((mx == oldMouseX) && (my == oldMouseY))
			return(1); // hasn't moved
		oldMouseX = mx;
		oldMouseY = my;
		if ((mx < 0) || (my < 0) || (mx >= dim.x-6) || (my >= dim.y-6-12))
			return(1);
		/*
		xo = (float)mx * skin->tex->width / (float)(dim.x-6);
		yo = (float)my * skin->tex->height / (float)(dim.y-6-12);
		*/
		vector_t mpoint, lu, lv;
		mpoint.x = mx; mpoint.y = my;
		camera.TransViewToWorldLine(mpoint, lu, lv);
		plane_t pln; pln.n.Set(0, 0, 1); pln.d = 0;
		float dist = pln.IntersectionUV(lu, lv, mpoint);
		if (dist < 0.0)
			return(1);
		xo = mpoint.x + skin->tex->width/2; yo = -mpoint.y + skin->tex->height/2;

		OVL_SkinPaint(skin, xo, yo, skinbrushsize, 1.0, false, skinantialias);
		vid.TexReload(skin->tex);
		return(1);
	}

	// zoom controls
	OVLCMD("zoomin") { if (camera.position.z > 6.0) camera.MoveForward(skin_zoomSpeed*sys_frameTime); return(1); }
	OVLCMD("zoomout") { if (camera.position.z < 1000.0) camera.MoveForward(-skin_zoomSpeed*sys_frameTime); return(1); }
	OVLCMD("panup") { if (camera.position.y < skin->tex->height/2) camera.MoveUp(skin_panSpeed*sys_frameTime); return(1); }
	OVLCMD("pandown") { if (camera.position.y > -((I32)skin->tex->height/2)) camera.MoveUp(-skin_panSpeed*sys_frameTime); return(1); }
	OVLCMD("panright") { if (camera.position.x < skin->tex->width/2) camera.MoveRight(skin_panSpeed*sys_frameTime); return(1); }
	OVLCMD("panleft") { if (camera.position.x > -((I32)skin->tex->width/2)) camera.MoveRight(-skin_panSpeed*sys_frameTime); return(1); }

	OVLCMD("basemove")
	{
		int i, mx, my, vmode;
		vector_t p[4];
		float dist;
		baseTri_t *baseTris, *tri;
		meshTri_t *ftri;
		modelFrame_t *f;

		baseTris = NULL;
		if (refOverride)
			f = ((OWorkspace *)this->parent)->mdx->refFrame;
		else
			f = ((OWorkspace *)this->parent)->GetTopmostFrame();
		if (f)
			baseTris = f->GetBaseTris();

		if (!baseTris)
			return(1);

		if (bfmode)
			return(1);
		mx = in_MouseX; my = in_MouseY; OVL_MousePosWindowRelative(this, &mx, &my);
		if ((mx < 0) || (my < 0) || (mx >= dim.x-6) || (my >= dim.y-6-12))
			return(1);
		vector_t mpoint, lu, lv;
		mpoint.x = mx; mpoint.y = my;
		camera.TransViewToWorldLine(mpoint, lu, lv);
		plane_t pln; pln.n.Set(0, 0, 1); pln.d = 0;
		dist = pln.IntersectionUV(lu, lv, mpoint);
		if (dist < 0.0)
			return(1);
		for (i=0;i<f->numTris;i++)
		{			
			tri = &baseTris[i];
			ftri = &f->mdl->mesh.meshTris[i];
			if (!(ftri->flags & TF_SELECTED))
				continue;
			vmode = 0;
			if ((bfaltmode) || (tri->flags & (BTF_VM0|BTF_VM1|BTF_VM2)))
				vmode = 1;
			if ((!vmode) || (tri->flags & BTF_VM0))
			{
				f->flags |= MRF_MODIFIED;
				if (axislockmode!=2) tri->tverts[0].x += mpoint.x - bftransStart.x;// tri->tverts[0][0] = (int)(tri->tverts[0][0] + 0.5);
				if (axislockmode!=1) tri->tverts[0].y -= mpoint.y - bftransStart.y;// tri->tverts[0][1] = (int)(tri->tverts[0][1] + 0.5);
			}
			if ((!vmode) || (tri->flags & BTF_VM1))
			{
				f->flags |= MRF_MODIFIED;
				if (axislockmode!=2) tri->tverts[1].x += mpoint.x - bftransStart.x;// tri->tverts[1][0] = (int)(tri->tverts[1][0] + 0.5);
				if (axislockmode!=1) tri->tverts[1].y -= mpoint.y - bftransStart.y;// tri->tverts[1][1] = (int)(tri->tverts[1][1] + 0.5);
			}
			if ((!vmode) || (tri->flags & BTF_VM2))
			{
				f->flags |= MRF_MODIFIED;
				if (axislockmode!=2) tri->tverts[2].x += mpoint.x - bftransStart.x;// tri->tverts[2][0] = (int)(tri->tverts[2][0] + 0.5);
				if (axislockmode!=1) tri->tverts[2].y -= mpoint.y - bftransStart.y;// tri->tverts[2][1] = (int)(tri->tverts[2][1] + 0.5);
			}
		}
		bftransStart = mpoint;
		return(1);
	}
	OVLCMD("baserotate")
	{
		int i, mx, my;
		vector_t v;
		float dist;
		baseTri_t *baseTris, *tri;
		meshTri_t *ftri;
		modelFrame_t *f;

		baseTris = NULL;
		if (refOverride)
			f = ((OWorkspace *)this->parent)->mdx->refFrame;
		else
			f = ((OWorkspace *)this->parent)->GetTopmostFrame();
		if (f)
			baseTris = f->GetBaseTris();

		if (!baseTris)
			return(1);

		if (bfmode != 1)
			return(1);
		mx = in_MouseX; my = in_MouseY; OVL_MousePosWindowRelative(this, &mx, &my);
		if ((mx < 0) || (my < 0) || (mx >= dim.x-6) || (my >= dim.y-6-12))
			return(1);
		vector_t mpoint, lu, lv;
		mpoint.x = mx; mpoint.y = my;
		camera.TransViewToWorldLine(mpoint, lu, lv);
		plane_t pln; pln.n.Set(0, 0, 1); pln.d = 0;
		dist = pln.IntersectionUV(lu, lv, mpoint);
		if (dist < 0.0)
			return(1);
		matrix_t mxform = MatRotation(AXIS_Z, (mx - oldMouseX)*PI/128.0);
		for (i=0;i<f->numTris;i++)
		{			
			tri = &baseTris[i];
			ftri = &f->mdl->mesh.meshTris[i];
			if (!(ftri->flags & TF_SELECTED))
				continue;
			f->flags |= MRF_MODIFIED;
			tri->tverts[0] = tri->trverts[0] * mxform; tri->tverts[0] += bftransStart;
			tri->tverts[1] = tri->trverts[1] * mxform; tri->tverts[1] += bftransStart;
			tri->tverts[2] = tri->trverts[2] * mxform; tri->tverts[2] += bftransStart;
		}
		return(1);
	}
	OVLCMD("basescale")
	{
		int i, mx, my;
		vector_t v;
		float scale, dist;
		baseTri_t *baseTris, *tri;
		meshTri_t *ftri;
		modelFrame_t *f;

		baseTris = NULL;
		if (refOverride)
			f = ((OWorkspace *)this->parent)->mdx->refFrame;
		else
			f = ((OWorkspace *)this->parent)->GetTopmostFrame();
		if (f)
			baseTris = f->GetBaseTris();

		if (!baseTris)
			return(1);

		if (bfmode != 2)
			return(1);
		mx = in_MouseX; my = in_MouseY; OVL_MousePosWindowRelative(this, &mx, &my);
		if ((mx < 0) || (my < 0) || (mx >= dim.x-6) || (my >= dim.y-6-12))
			return(1);
		vector_t mpoint, lu, lv;
		mpoint.x = mx; mpoint.y = my;
		camera.TransViewToWorldLine(mpoint, lu, lv);
		plane_t pln; pln.n.Set(0, 0, 1); pln.d = 0;
		dist = pln.IntersectionUV(lu, lv, mpoint);
		if (dist < 0.0)
			return(1);
		scale = 1.0+(my - oldMouseY)*0.05;
		if ((my - oldMouseY) < 0)
			scale = 1.0/(1.0+(oldMouseY - my)*0.05);
		for (i=0;i<f->numTris;i++)
		{			
			tri = &baseTris[i];
			ftri = &f->mdl->mesh.meshTris[i];
			if (!(ftri->flags & TF_SELECTED))
				continue;
			f->flags |= MRF_MODIFIED;
			for (int j=0;j<3;j++)
			{
				tri->tverts[j] = tri->trverts[j];
				if (axislockmode!=2) tri->tverts[j].x *= scale;
				if (axislockmode!=1) tri->tverts[j].y *= scale;
				tri->tverts[j] += bftransStart;
			}
		}
		return(1);
	}
	
	return(Super::OnDragCommand(argNum, argList));
}

static boolean Inbox(vector_t *p, int x1, int y1, int x2, int y2)
{
	int temp;
	if (x2 < x1)
	{
		temp = x2;
		x2 = x1;
		x1 = temp;
	}
	if (y2 < y1)
	{
		temp = y2;
		y2 = y1;
		y1 = temp;
	}
	if ((p->x >= x1) && (p->x <= x2) && (p->y >= y1) && (p->y <= y2))
		return(1);
	return(0);
}

boolean OSkinView::OnReleaseCommand(int argNum, char **argList)
{
	OVLCMDSTART
	OVLCMD("skinline")
	{
		int xo, yo, mx, my;
		OVL_UnlockInput(this);
		if ((!skin) || (!skin->tex))
			return(1);
		if ((skinlineStart.x == -1) || (skinlineStart.y == -1))
			return(1);
		mx = in_MouseX; my = in_MouseY; OVL_MousePosWindowRelative(this, &mx, &my);
		vector_t mpoint, lu, lv;
		mpoint.x = mx; mpoint.y = my;
		camera.TransViewToWorldLine(mpoint, lu, lv);
		plane_t pln; pln.n.Set(0, 0, 1); pln.d = 0;
		float dist = pln.IntersectionUV(lu, lv, mpoint);
		if (dist < 0.0)
			return(1);
		xo = mpoint.x + skin->tex->width/2; yo = -mpoint.y + skin->tex->height/2;
		VCR_Record(VCRA_UNDO, "$skinpaint", Undo_SkinPaint, 8192, NULL);
		VCR_WriteInt((unsigned long)(((OWorkspace *)this->parent)->mdx->skins));
		OVL_SkinLine(skin, skinlineStart.x, skinlineStart.y, xo, yo, skinbrushsize, 1.0, skinantialias);
		vid.TexReload(skin->tex);
		skinlineStart.Set(-1, -1, 0);
		return(1);
	}
	OVLCMD("baseselect")
	{
		int i, mx, my;
		baseTri_t *baseTris, *tri;
		meshTri_t *ftri;
		modelFrame_t *f;
		vector_t p[4];

		OVL_UnlockInput(this);
		if ((!skin) || (!skin->tex))
			return(1);
		if ((baseboxStart.x == -1) || (baseboxStart.y == -1))
			return(1);
		baseTris = NULL;
		if (refOverride)
			f = ((OWorkspace *)this->parent)->mdx->refFrame;
		else
			f = ((OWorkspace *)this->parent)->GetTopmostFrame();
		if (f)
			baseTris = f->GetBaseTris();
		if (!baseTris)
		{
			baseboxStart.Set(-1, -1, 0);
			return(1);
		}
		mx = in_MouseX; my = in_MouseY; OVL_MousePosWindowRelative(this, &mx, &my);
		vector_t mpoint, lu, lv;
		mpoint.x = mx; mpoint.y = my;
		camera.TransViewToWorldLine(mpoint, lu, lv);
		plane_t pln; pln.n.Set(0, 0, 1); pln.d = 0;
		float dist = pln.IntersectionUV(lu, lv, mpoint);
		if (dist < 0.0)
		{
			baseboxStart.Set(-1, -1, 0);
			return(1);
		}
		for (i=0;i<f->numTris;i++)
		{			
			tri = &baseTris[i];
			ftri = &f->mdl->mesh.meshTris[i];
			if (!(in_keyFlags & KF_CONTROL))
				ftri->flags &= ~TF_SELECTED;
			if (!(tri->flags & BTF_INUSE))
				continue;
            if (tri->flags & BTF_HIDDEN)
                continue;
			if (ftri->flags & TF_HIDDEN)
				continue;
			p[0].Set(tri->tverts[0].x - skin->tex->width/2 + 0.5, -(tri->tverts[0].y - skin->tex->height/2) - 0.5, 0.0);
			p[1].Set(tri->tverts[1].x - skin->tex->width/2 + 0.5, -(tri->tverts[1].y - skin->tex->height/2) - 0.5, 0.0);
			p[2].Set(tri->tverts[2].x - skin->tex->width/2 + 0.5, -(tri->tverts[2].y - skin->tex->height/2) - 0.5, 0.0);
			if (Inbox(&p[0], mpoint.x, mpoint.y, baseboxStart.x, baseboxStart.y)
			 || Inbox(&p[1], mpoint.x, mpoint.y, baseboxStart.x, baseboxStart.y)
			 || Inbox(&p[2], mpoint.x, mpoint.y, baseboxStart.x, baseboxStart.y))
			{
				ftri->flags ^= TF_SELECTED;
				tri->flags &= ~(BTF_VM0|BTF_VM1|BTF_VM2);
			}
		}		
		baseboxStart.Set(-1, -1, 0);
		return(1);
	}
	OVLCMD("basemove")
	{
		int i, vmode;
		baseTri_t *baseTris, *tri;
		meshTri_t *ftri;
		modelFrame_t *f;

		baseTris = NULL;
		if (refOverride)
			f = ((OWorkspace *)this->parent)->mdx->refFrame;
		else
			f = ((OWorkspace *)this->parent)->GetTopmostFrame();
		if (f)
			baseTris = f->GetBaseTris();

		if (!baseTris)
			return(1);

		OVL_UnlockInput(this);		
		for (i=0;i<f->numTris;i++)
		{			
			tri = &baseTris[i];
			ftri = &f->mdl->mesh.meshTris[i];
			if (!(ftri->flags & TF_SELECTED))
				continue;
			vmode = 0;
			if (tri->flags & (BTF_VM0|BTF_VM1|BTF_VM2))
				vmode = 1;
			if ((!vmode) || (tri->flags & BTF_VM0))
			{
				tri->tverts[0].x = (int)(tri->tverts[0].x + 0.5);
				tri->tverts[0].y = (int)(tri->tverts[0].y + 0.5);
			}
			if ((!vmode) || (tri->flags & BTF_VM1))
			{
				tri->tverts[1].x = (int)(tri->tverts[1].x + 0.5);
				tri->tverts[1].y = (int)(tri->tverts[1].y + 0.5);
			}
			if ((!vmode) || (tri->flags & BTF_VM2))
			{
				tri->tverts[2].x = (int)(tri->tverts[2].x + 0.5);
				tri->tverts[2].y = (int)(tri->tverts[2].y + 0.5);
			}
		}
		return(1);
	}
	OVLCMD("baserotate")
	{
		int i;
		baseTri_t *baseTris, *tri;
		meshTri_t *ftri;
		modelFrame_t *f;

		baseTris = NULL;
		if (refOverride)
			f = ((OWorkspace *)this->parent)->mdx->refFrame;
		else
			f = ((OWorkspace *)this->parent)->GetTopmostFrame();
		if (f)
			baseTris = f->GetBaseTris();

		if (!baseTris)
			return(1);

		OVL_UnlockInput(this);		
		for (i=0;i<f->numTris;i++)
		{			
			tri = &baseTris[i];
			ftri = &f->mdl->mesh.meshTris[i];
			if (!(ftri->flags & TF_SELECTED))
				continue;
			tri->tverts[0].x = (int)(tri->tverts[0].x + 0.5);
			tri->tverts[0].y = (int)(tri->tverts[0].y + 0.5);
			tri->tverts[1].x = (int)(tri->tverts[1].x + 0.5);
			tri->tverts[1].y = (int)(tri->tverts[1].y + 0.5);
			tri->tverts[2].x = (int)(tri->tverts[2].x + 0.5);
			tri->tverts[2].y = (int)(tri->tverts[2].y + 0.5);
		}
		return(1);
	}
	OVLCMD("basescale")
	{
		int i;
		baseTri_t *baseTris, *tri;
		meshTri_t *ftri;
		modelFrame_t *f;

		baseTris = NULL;
		if (refOverride)
			f = ((OWorkspace *)this->parent)->mdx->refFrame;
		else
			f = ((OWorkspace *)this->parent)->GetTopmostFrame();
		if (f)
			baseTris = f->GetBaseTris();

		if (!baseTris)
			return(1);

		OVL_UnlockInput(this);		
		for (i=0;i<f->numTris;i++)
		{			
			tri = &baseTris[i];
			ftri = &f->mdl->mesh.meshTris[i];
			if (!(ftri->flags & TF_SELECTED))
				continue;
			tri->tverts[0].x = (int)(tri->tverts[0].x + 0.5);
			tri->tverts[0].y = (int)(tri->tverts[0].y + 0.5);
			tri->tverts[1].x = (int)(tri->tverts[1].x + 0.5);
			tri->tverts[1].y = (int)(tri->tverts[1].y + 0.5);
			tri->tverts[2].x = (int)(tri->tverts[2].x + 0.5);
			tri->tverts[2].y = (int)(tri->tverts[2].y + 0.5);
		}
		return(1);
	}
	return(Super::OnReleaseCommand(argNum, argList));
}


/*
boolean OSkinView::OnMessage(ovlmsg_t *msg)
{
	OVLMSGSTART
	OVLMSG("SkinView_SetSkin")
	{
		skin = OVLMSGPARM(0, modelSkin_t *);
		return(1);
	}
	return(Super::OnMessage(msg));
}
*/

/*
boolean OSkinView::OnDragDrop(overlay_t *dropovl)
{
	baseTri_t *baseTris;
	frameVert_t *frameVerts;

	if (!dropovl)
		return(1);

	if (OVL_IsOverlayType(dropovl, "OFrameView"))
	{
	}
	//return(Super::OnDragDrop(dropovl));
	return(1);
}
*/

//****************************************************************************
//**
//**    END MODULE OVL_SKIN.CPP
//**
//****************************************************************************

