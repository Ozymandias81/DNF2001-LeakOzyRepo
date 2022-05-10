#ifndef __VID_MAIN_H__
#define __VID_MAIN_H__

#define VID_API_VERSION 13

#define TF_SELECTED			0x00000001
#define TF_HIDDEN			0x00000002
#define TF_NOVERTLIGHT		0x00000004 // triangle does not influence vertex normal light calcs
#define TF_TRANSPARENT		0x00000008
#define TF_SPECULAR			0x00000010
#define TF_UNLIT            0x00000020
#define TF_TWOSIDED         0x00000040
#define TF_MASKING          0x00000080
#define TF_MODULATED		0x00000100
#define TF_ENVMAP			0x00000200
#define TF_NONCOLLIDE		0x00000400
#define TF_TEXBLEND			0x00000800
#define TF_ZLATER			0x00001000

typedef enum
{
	VCM_FLAT			= 0,
	VCM_GOURAUD			= 1,
	VCM_TEXTURE			= 2,
	VCM_FLATTEXTURE		= 3,
	VCM_GOURAUDTEXTURE	= 4,

	VCM_NUMTYPES		= 5
} vidcolormodetype_t;

typedef enum
{
	VAM_FLAT			= 0,
	VAM_GOURAUD			= 1,
	VAM_TEXTURE			= 2,
	VAM_MODULATE_TEXTURE= 3,

	VAM_NUMTYPES		= 4
} vidalphamodetype_t;

typedef enum
{
	VCMP_NEVER			= 1,
	VCMP_LESS			= 2,
	VCMP_EQUAL			= 3,
	VCMP_LESSEQUAL		= 4,
	VCMP_GREATER		= 5,
	VCMP_NOTEQUAL		= 6,
	VCMP_GREATEREQUAL	= 7,
	VCMP_ALWAYS			= 8,

	VCMP_NUMTYPES		= 8
} vidatestmodetype_t;

typedef enum
{
	VBM_OPAQUE			= 0,
	VBM_OPAQUETOTAL		= 1,
	VBM_TRANS			= 2,
	VBM_TRANSTOTAL		= 3,
	VBM_TRANSMERGE		= 4,

	VBM_NUMTYPES		= 5
} vidblendmodetype_t;

typedef enum
{
	VWM_SHOWALL					= 1,
	VWM_SHOWCLOCKWISE			= 2,
	VWM_SHOWCOUNTERCLOCKWISE	= 3,
	VWM_SHOWCCW					= 3,

	VWM_NUMTYPES				= 3
} vidwindingmodetype_t;

typedef enum
{
	VFM_NONE			=0,
	VFM_POINT			=1,
	VFM_BILINEAR		=2,
	VFM_ANISOTROPIC		=3,
	VFM_FLATCUBIC		=4,
	VFM_GAUSSIANCUBIC	=5,

	VFM_NUMTYPES		=6
} vidfiltermodetype_t;

typedef enum
{
	VMM_ENABLE,
	VMM_DISABLE,

	VMM_NUMTYPES
} vidmaskmodetype_t;

typedef enum
{
	VTA_NORMAL,
	VTA_XO,
	VTA_YO,

	VTA_NUMTYPES
} vidtexactivatetype_t;

typedef enum
{
	ZCMP_NEVER			= 1,
	ZCMP_LESS			= 2,
	ZCMP_EQUAL			= 3,
	ZCMP_LESSEQUAL		= 4,
	ZCMP_GREATER		= 5,
	ZCMP_NOTEQUAL		= 6,
	ZCMP_GREATEREQUAL	= 7,
	ZCMP_ALWAYS			= 8
}zfunc_modetype_t;

typedef enum
{
	VLS_READFRONT,
	VLS_READBACK,
	VLS_WRITEFRONT,
	VLS_WRITEBACK,

	VLS_NUMTYPES
} vidlockscreentype_t;

typedef struct
{
	float x;
	float y;
	float z;
} vector_str;

#ifdef CANNIBAL_TOOL
#define vector_type vector_t
#else
#define vector_type vector_str
#endif

#define VEC_TO_1RGB(v) ((0xFF000000) | ((((U32)(v).x) & 0xFF) << 16) | ((((U32)(v).y) & 0xFF) << 8) | ((((U32)(v).z) & 0xFF)))
#define VEC_TO_0RGB(v) (((((U32)(v).x) & 0xFF) << 16) | ((((U32)(v).y) & 0xFF) << 8) | ((((U32)(v).z) & 0xFF)))
#define FLOAT_A_TO_A(v) (((U32)(v))<<24)

class CVert
{
public:
	float x,y,z;
	float rhw;
	U32 color;
	float s,t;
public:
	void set(vector_type &vect){x=vect.x;y=vect.y;z=vect.z;}
};

class VidTex
{
	/* Grrr... */
public:
	autochar	name;
	U32			width,height;
	U32			bpp;
	char		*tex_data;
	autochar	tex_free;

	float timestamp;
public:
	VidTex(CC8 *Name,U32 width,U32 height,U32 format);
	VidTex(void){}
	virtual ~VidTex(void){}
};

typedef struct
{
	U32 width;
	U32 height;
	U32 bpp;
}vidresolution_t;

class VidView
{
	U32 width,height;
	U32 bpp;
public:
	VidView(U32 Width,U32 Height,U32 Bpp) : width(Width),height(Height),bpp(Bpp) {}
	virtual ~VidView(void){}
};

#pragma pack(push,4)
class VidState
{
public:
	U32 active : 1;
	U32 in_prim : 1;
	U32 in_scene : 1;
	U32 support_wbuffer : 1;
	U32 has_stencil : 1;
	U32 force_draw : 1;
	U32 antialias : 1;
	U32 depth_enabled : 1;
	U32 zfunc : 4;
	U32 depth_write : 1;
	U32 color_write : 1;
	U32 color_mode : 3;
	U32 alpha_mode : 3;
	U32 blend_mode : 3;
	U32 flat_shade : 1;
	U32 flat_alpha : 1;
	U32 alpha_test_enable : 1;
	U32 alpha_test_val : 8;
	U32 alpha_test_mode : 4;
	U32 min_filter_mode : 3;
	U32 mag_filter_mode : 3;
	U32 mip_filter_mode : 3;
	U32 cull_mode :2;
	U32 clip_good : 1;
	U32 color_a : 8;
	U32 color_r : 8;
	U32 color_g : 8;
	U32 color_b : 8;

	U16 clip_x;
	U16 clip_y;
	U16 clip_width;
	U16 clip_height;

	VidState(void) : active(0),in_prim(0),in_scene(0),support_wbuffer(0),has_stencil(0),force_draw(0),antialias(0),
					depth_enabled(0),zfunc(8),depth_write(1),color_write(1),color_mode(0),alpha_mode(0),blend_mode(0),
					flat_shade(0),flat_alpha(0),alpha_test_enable(0),alpha_test_val(0),alpha_test_mode(0),
					min_filter_mode(VFM_POINT),mag_filter_mode(VFM_POINT),
					mip_filter_mode(VFM_NONE),cull_mode(VWM_SHOWALL),clip_good(TRUE),color_a(0),color_r(0),color_g(0),color_b(0),
					clip_x(0),clip_y(0),clip_width(0),clip_height(){}
};
#pragma pack(pop)

enum tex_load_flags
{
	TEX_LOAD_MASKED=1
};

class VidIf
{
protected:
	VidState	vid_state;

public:
	vidresolution_t res;

public:
	virtual ~VidIf(void){}
	virtual U32 init(XWnd *wnd,U32 width,U32 height,U32 byte_pp)=null;
	virtual U32 close(void)=null;
	virtual void set_default(void)=null;

	virtual void Activate(void)=null;
	virtual void Deactivate(void)=null;


	/* rendering functions */
	virtual U32 Swap(U32 wait=1)=null;
	virtual void ClearScreen(U32 color=0)=null;
	virtual void ClipWindow(U32 x,U32 y,U32 x2,U32 y2)=null;
	virtual void SetClipBounds(U32 x,U32 y,U32 x2,U32 y2)=null;
	virtual void DepthEnable(U8 enable)=null;
	virtual void ColorWrite(U8 enable)=null;
	virtual void DepthWrite(U8 enable)=null;
	virtual U32 GetColor(void)
	{
		return ((vid_state.color_a<<24) | 
				(vid_state.color_r<<16) |
				(vid_state.color_g<<8) |
				(vid_state.color_b));
	}
	virtual void FlatColor(U32 color)
	{
		vid_state.color_a=color>>24;
		vid_state.color_r=(color>>16)&0xFF;
		vid_state.color_g=(color>>8)&0xFF;
		vid_state.color_b=(color)&0xFF;
	}
	virtual void FlatColor(U8 r,U8 g,U8 b)=null;
	inline void FlatColorf(float r,float g,float b){FlatColor((U8)r,(U8)g,(U8)b);}
	virtual void FlatAlpha(U8 a)=null;
	virtual U8 AlphaTestValue(U8 a)=null;
	
	virtual vidcolormodetype_t ColorMode(vidcolormodetype_t vcmtype)=null;
	virtual vidalphamodetype_t AlphaMode(vidalphamodetype_t vamtype)=null;
	virtual vidblendmodetype_t BlendMode(vidblendmodetype_t vbmtype)=null;
	virtual vidwindingmodetype_t WindingMode(vidwindingmodetype_t vwmmode)=null;
	virtual vidfiltermodetype_t MinFilterMode(vidfiltermodetype_t vfmmode)=null;
	virtual vidfiltermodetype_t MagFilterMode(vidfiltermodetype_t vfmmode)=null;
	virtual vidatestmodetype_t AlphaTestMode(vidatestmodetype_t vatmode)=null;
	virtual zfunc_modetype_t DepthFunc(zfunc_modetype_t zfunc)=null;
	virtual U32 AlphaTestEnable(U32 enable)=null;

	virtual void ForceDraw(U8 enable)=null;
	virtual void Antialias(U8 enable)=null;

	virtual void draw_polygon(U32 num_verts,CVert *verts)=null;

	virtual void DrawLine(vector_type *p1, vector_type *p2, vector_type *c1, vector_type *c2)=null;
	virtual void DrawLineBox(vector_type *p1, vector_type *p2, vector_type *c1, vector_type *c2)=null;
	virtual void DrawTriangle(vector_type *p, vector_type *c, float *a, vector_type *tv)=null;
	virtual void DrawClippedPolygon(U32 numverts, vector_type *p, vector_type *c, float *a, vector_type *tv)=null;
	virtual void DrawPolygon(U32 numverts, vector_type *p, vector_type *c, float *a, vector_type *tv)=null;
	virtual void DrawPolygonFlags(U32 flags,U32 numverts, vector_type *p, vector_type *c, float *a, vector_type *tv)=null;
	virtual void DrawString(int x1, int y1, int dx, int dy, char *str, U8 filtered, int r, int g, int b)=null;

	virtual U32 is_char_drawable(char key)=null;

	virtual void SetFontTexture(void)=null;

	virtual void get_fontdim(float *lwidth,float *lheight)=null;
	virtual void get_fontletter(char key,float *s,float *t)=null;

	virtual U32 TexActivate(VidTex *tex, vidtexactivatetype_t vta)=null;
	virtual VidTex *TexLoad(CC8 *path,U8 fatal,U32 flags=0,U32 mask_color=0)=null;
	virtual VidTex *TexLoadBMP(CC8 *filename, U8 fatal,U32 flags=0)=null;
	virtual VidTex *TexLoadTGA(CC8 *filename, U8 fatal,U32 flags=0)=null;
	virtual U32 TexRelease(VidTex *tex)=null;
	virtual U32 TexReload(VidTex *tex)=null;
	virtual VidTex *TexForName(CC8 *name)=null;
	virtual VidTex *GetBlankTex(void)=null;

	virtual U32 LockScreen(vidlockscreentype_t lock, unsigned short **buffer, int *pitch)=null;
	virtual void UnlockScreen(void)=null;

	virtual void BeginScene(void){}
	virtual void EndScene(void){}

	virtual void ClipBad(void)=null;
	virtual void ClipGood(void)=null;
	virtual void Diags(void){}

	virtual void SetHooptiFrustum(float fov_angle,float xy_ratio,float near,float far)=null;

	virtual void BeginLines(U32 guess_num){}
	virtual void EndLines(void){}

	U32 is_active(void){return vid_state.active;}
};

//----------------------------------------------------------------------------
//    Public Data Declarations
//----------------------------------------------------------------------------
extern U8 vid_dllActive;

typedef U32 (*VidVersion_f)(void);
typedef VidIf *(*VidQuery_f)(void);
typedef U32 (*VidRelease_f)(void);

#endif // __VID_MAIN_H__
