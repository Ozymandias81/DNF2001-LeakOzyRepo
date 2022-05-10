#ifndef _VIDD3D_H_
#define _VIDD3D_H_

#define VID_D3D_VERSION	1

class VidD3D;

class ViewD3D : public VidView
{
	IDirect3DDevice8 *dev;
	XWnd *wnd;
public:
	ViewD3D(XWnd *Wnd,IDirect3DDevice8 *Dev,U32 Width,U32 Height,U32 Bpp);
};

/* normal direct x transformed vert */
typedef struct
{
	float x,y,z;
	float rhw;
	U32 color;
	float s,t;
}DxVertexT;

typedef enum
{
	PRIM_POINTLIST		=1,
	PRIM_LINELIST		=2,
	PRIM_LINESTRIP		=3,
	PRIM_TRIANGLELIST	=4,
	PRIM_TRIANGLESTRIP	=5,
	PRIM_TRIANGLEFAN	=6
}prim_d3d_types;

#pragma pack(push,2)
class PrimD3D
{
public:
	U16 type;
	U16 count;
	U16 start;
public:
	PrimD3D(void) : type(0),count(0) {}
};
#pragma pack(pop)

class PrimBuffer : public MemGrow
{
	PrimD3D	*prim;
	char	*cur;
	char	*end;
	U32		inc_size;

	/* TODO: Low priority, instead of copying memory, flush then realloc */
	/* Low priority because realloc will probably never happen */
	inline void realloc(U32 inc,U32 need=0)
	{
		U32 diff=cur - base;
		if (need > inc)
			inc=need;
		MemGrow::realloc(inc);
		cur=base+diff;
		end=base+size;
	}
public:
	inline void reset(void)
	{
		cur=base;
		if (base)
			end=cur+size;
		prim=(PrimD3D *)base;
		prim->type=0;
	}
	PrimBuffer(U32 size=1024*2,U32 IncSize=1024) : MemGrow(ALIGN_POW2(size,64)),inc_size(IncSize)
	{
		reset();
	}
	void make_room(U32 bytes)
	{
		I32 size_left=(end - cur);
		if ((((I32)(end - cur)) - bytes) < 0)
			realloc(inc_size,bytes);
	}
	void add_prim(U16 type,U16 vindex)
	{
		if (prim->type==type)
			prim->count++;
		else
		{
			prim++;
			prim->type=type;
			prim->count=1;
			prim->start=vindex;
		}
	}
	U32 get_room(void){return (((PrimD3D *)end) - prim);}
	PrimD3D *get_prim_list(U32 &count)
	{
		PrimD3D *start=(PrimD3D *)base;
		count=prim - start;
		return start+1;
	}
	void begin_frame(void);
};

#pragma pack(push,4)
class VBState
{
public:
	U32 has_lock : 1;
	U32 is_finished : 1;
	U32 begin : 1;
	U32 vsize : 5;

	VBState(void) : has_lock(0),is_finished(0),vsize(0) {}
};
#pragma pack(pop)

class VManager;

class VBuffer
{
	friend class VManager;
	friend class XRingChain<VBuffer>;

	VBuffer					*next;
	VBuffer					*prev;

protected:
	IDirect3DDevice8		*dev;
	IDirect3DVertexBuffer8	*vbuffer;
	U32						*vcur32;

	U32						cur_off;
	U32						lock_end;
	U32						vindex;

	U32						size;

	VBState					state;
	U32						count;
	U32						fvf;

	U32						*scur32;
	autochar				shadow;

public:
	inline void *Lock(U32 lock_size)
	{
		if (state.begin)
		{
			if (vbuffer->Lock(cur_off,lock_size,(U8 **)&vcur32,D3DLOCK_DISCARD)!=D3D_OK)
				xxx_fatal("Unable to lock vertex buffer");
			state.begin=FALSE;
		}
		else
		{
			if (vbuffer->Lock(cur_off,lock_size,(U8 **)&vcur32,D3DLOCK_NOOVERWRITE)!=D3D_OK)
				xxx_fatal("Unable to lock vertex buffer");
		}
		lock_end=cur_off+lock_size;
		vindex=cur_off/(state.vsize*4);
		state.has_lock=TRUE;
		return vcur32;
	}
	void Unlock(void *end_ptr)
	{
		D_ASSERT(state.has_lock);
		if (vbuffer->Unlock()!=D3D_OK)
			xxx_fatal("Unable to unlock vertex buffer");
		cur_off=lock_end;
		vindex=cur_off/(state.vsize*4);
		state.has_lock=FALSE;
		//_fence();
	}

public:
	VBuffer(IDirect3DDevice8 *dev,U32 fvf_flags,U32 count);
	~VBuffer(void);
	/* add primitives */
	void finished(void);
	void begin_frame(void);
	I32 get_room(void){return (size-lock_end)/(state.vsize*4);}
	U32 is_finished(void){return state.is_finished;}
	void select(void);
};

#pragma pack(push,4)
class VBManState
{
public:
	U32 in_prim : 1;

	VBManState(void) : in_prim(0) {}
};
#pragma pack(pop)

/* manager vertex buffer pool */
/* anytime we cycle through a frame needing to lock a buffer twice alloc another */
class VManager : public XRingChain<VBuffer>
{
protected:
	IDirect3DDevice8	*dev;
	VidD3D				*vid;
	PrimBuffer			*prims;
	I32					room;

	U32					fvf;
	U32					def_count;

	U32					vindex;
	PrimD3D				cur_prim;
	DxVertexT			*lock_space;
	VBManState			state;

	void MakeRoom(U32 need);
	void CheckRoom(U16 vcount)
	{
		if ((room-=(I16)vcount)<0)
			MakeRoom(vcount);
		lock_space=(DxVertexT *)cur->Lock(vcount*28);
		vindex=cur->vindex;
	}
	VBuffer *alloc_vbuffer(VBuffer *after,U32 need);

public:
	VManager(VidD3D *Vid,IDirect3DDevice8 *Dev,U32 num_buffers,U32 count,U32 fvf_flags);
	~VManager(void){delete prims;}
	void BeginNewFrame(void);
	void EndScene(void);
	void flush(void);
	DxVertexT *begin_prim(U32 type,U32 num_verts)
	{
#ifdef DEBUG
		if (state.in_prim)
			xxx_throw("Already in primitive");
		state.in_prim=TRUE;
#endif
		CheckRoom((U16)num_verts);
		cur_prim.start=(U16)vindex;
		cur_prim.type=(U16)type;
		return lock_space;
	}
	void end_prim(DxVertexT *space,U32 count)
	{
#ifdef DEBUG
		if (!state.in_prim)
			xxx_throw("Not in primitive");
		state.in_prim=FALSE;
		if ((cur_prim.type!=PRIM_TRIANGLELIST)&&(cur_prim.type!=PRIM_LINELIST))
			xxx_fatal("bad primitive type");
#endif
		if (!count)
			return;
		cur->Unlock(space);
		if (dev->DrawPrimitive((D3DPRIMITIVETYPE)cur_prim.type,cur_prim.start,count)!=D3D_OK)
			xxx_fatal("VManager::end_prim: DrawPrimitive failed");
	}
};

class VidTexD3D : public VidTex
{
	autoptr<XImage>		image;
	IDirect3DTexture8	*d3d;
	U32					d3d_format;

public:
	VidTexD3D(CC8 *name,XImage *image);
	VidTexD3D(CC8 *name,U32 width,U32 height,U32 format);
	~VidTexD3D(void);
	U32 get_image_format(void){return image->get_format();}
	void create_d3d(IDirect3DDevice8 *dev);
	void load_tex(void);
	IDirect3DTexture8 *get_d3d(void){return d3d;}
	void release_d3d(void);
};

class TexList : public XList<VidTexD3D>
{
public:
	TexList(void) : XList<VidTexD3D>(32,TRUE) {}
	VidTexD3D *remove(VidTexD3D *obj);
	VidTexD3D *find_named(CC8 *name);
	void release_d3d(void);
};

typedef struct
{
	char marker[4];
	char versionMajor;
	char versionMinor;
	I16 numFrames;
	I32 flags;
	I32 reserved;
} gbaheader_t;

typedef struct
{
	I32 frameOfs;
	I32 frameFlags;
	char frameName[24];
}gbaframeentry_t;

#define FONTDATA_WIDTH 6
#define FONTDATA_HEIGHT 6

typedef struct
{
	U16 width;
	U16 height;
	U16 originX;
	U16 originY;
	char data[FONTDATA_HEIGHT][FONTDATA_WIDTH];
}gbaframe_t;

class XFont;

class FontFile : public XFile
{
	gbaheader_t		header;
	XImage			*image;
	autoptr<XFont>	font;
public:
	XFont *load_font(void);
};

class XFontLetter
{
public:
	float s,t;
	U32 drawable;
public:
	XFontLetter(void) : s(0.0f),t(0.0f),drawable(0){}
	void set(float S,float T){s=S;t=T;}
	void get(float *S,float *T){*S=s;*T=t;}
	void set_drawable(U32 enable){drawable=enable;}
};

class XFont : public VidTexD3D
{
	XFontLetter		letters[256];
	float			width,height;
public:
	XFont(XImage *Image);
	void set_letter(char letter,U32 s,U32 t)
	{
		letters[letter].set(s/256.0f,t/256.0f);
		letters[letter].set_drawable(TRUE);
	}
	void get_letter(char letter,float *s,float *t){letters[letter].get(s,t);}
	void get_pitch(float *Width,float *Height){*Width=width;*Height=height;}
	U32 is_drawable(char letter){return letters[letter].drawable;}
};

#pragma pack(push,4)
class D3DState
{
public:
	U32 src_blend : 4;
	U32 dst_blend : 4;

	U32 color_op0 : 5;
	U32 color_op1 : 5;
	U32 color_op2 : 5;

	U32 alpha_op0 : 5;
	U32 alpha_op1 : 5;
	U32 alpha_op2 : 5;

	U8 color1_arg0;
	U8 color2_arg0;
	U8 alpha1_arg0;
	U8 alpha2_arg0;

	U8 color1_arg1;
	U8 color2_arg1;
	U8 alpha1_arg1;
	U8 alpha2_arg1;

	U8 color1_arg2;
	U8 color2_arg2;
	U8 alpha1_arg2;
	U8 alpha2_arg2;

	D3DState(void) : src_blend(0),dst_blend(0),color_op0(0),color_op1(0),color_op2(0),
					alpha_op0(0),alpha_op1(0),alpha_op2(0),
					color1_arg0(0),color2_arg0(),alpha1_arg0(),alpha2_arg0(),
					color1_arg1(0),color2_arg1(),alpha1_arg1(),alpha2_arg1(),
					color1_arg2(0),color2_arg2(),alpha1_arg2(),alpha2_arg2(){}
};
#pragma pack(pop)


class VidD3D : public VidIf
{
	IDirect3D8			*id3d;
	IDirect3DDevice8	*dev;
	VidView				*view;

	IDirect3DSurface8	*locked_surf;

	VManager			*vbuffers;

	D3DState			d3d_state;
	D3DCAPS8			caps;

	ImgDevice			img_device;

	VidTexD3D			*active_tex;
	VidTexD3D			*blank_tex;
	XFont				*font;

	XWnd				*dev_wnd;

	TexList				tex_list;

	U32					prim_guess;
	U32					prim_count;
	DxVertexT			*prim_space;
	DxVertexT			*prim_start;

	U32 num_adaptor;
	U32 adaptor_id;
protected:
	U32 create_device(XWnd *wnd,U32 width,U32 height,U32 byte_pp);
	void depth_init(void);
	void init_tex_stages(void);
	void init_font(void);
	void create_vbuffers(void);
	void flush_vbuffers(void);
	void CreateBlankTex(void);
	void restore_state(void);
	void rend_begin_debug(void);
	void rend_end_debug(void);

	inline DxVertexT *begin_prim(U32 type,U32 num_verts)
	{
		DxVertexT *space=vbuffers->begin_prim(type,num_verts);
		return space;
	}
	inline void set_vert(DxVertexT *space,DxVertexT *v)
	{
		*space=*v;
	}
	inline void set_vert_adv(DxVertexT *&space,DxVertexT *v)
	{
		*space=*v;
		space++;
	}
	inline void end_prim(DxVertexT *space,U32 count)
	{
		vbuffers->end_prim(space,count);
	}

public:
	VidD3D(void);
	~VidD3D(void);

	U32 init(XWnd *wnd,U32 width,U32 height,U32 byte_pp);
	U32 close(void);
	void set_default(void);

	void Activate(void);
	void Deactivate(void);

	/* rendering functions */
	U32 Swap(U32 wait=1);
	void ClearScreen(U32 color=0);
	void ClipWindow(U32 x,U32 y,U32 x2,U32 y2);
	void SetClipBounds(U32 x,U32 y,U32 x2,U32 y2);
	void DepthEnable(U8 enable);
	void ColorWrite(U8 enable);
	void DepthWrite(U8 enable);
	void FlatColor(U8 r,U8 g,U8 b);
	void FlatAlpha(U8 a);
	U8 AlphaTestValue(U8 a);
	
	vidcolormodetype_t ColorMode(vidcolormodetype_t vcmtype);
	vidalphamodetype_t AlphaMode(vidalphamodetype_t vamtype);
	vidblendmodetype_t BlendMode(vidblendmodetype_t vbmtype);
	vidwindingmodetype_t WindingMode(vidwindingmodetype_t vwmmode);
	vidfiltermodetype_t MinFilterMode(vidfiltermodetype_t vfmmode);
	vidfiltermodetype_t MagFilterMode(vidfiltermodetype_t vfmmode);
	vidatestmodetype_t AlphaTestMode(vidatestmodetype_t vatmode);
	zfunc_modetype_t DepthFunc(zfunc_modetype_t zfunc);
	U32 AlphaTestEnable(U32 enable);

	void ForceDraw(U8 enable);
	void Antialias(U8 enable);

	void draw_polygon(U32 num_verts,CVert *verts);

	void DrawLine(vector_type *p1, vector_type *p2, vector_type *c1, vector_type *c2);
	void DrawLineBox(vector_type *p1, vector_type *p2, vector_type *c1, vector_type *c2);
	void DrawTriangle(vector_type *p, vector_type *c, float *a, vector_type *tv);
	void DrawClippedPolygon(U32 numverts, vector_type *p, vector_type *c, float *a, vector_type *tv);
	void DrawPolygon(U32 numverts, vector_type *p, vector_type *c, float *a, vector_type *tv);
	void DrawPolygonFlags(U32 flags,U32 numverts, vector_type *p, vector_type *c, float *a, vector_type *tv);
	void DrawString(int x1, int y1, int dx, int dy, char *str, U8 filtered, int r, int g, int b);

	U32 is_char_drawable(char key);

	void SetFontTexture(void);

	void get_fontdim(float *lwidth,float *lheight);
	void get_fontletter(char key,float *s,float *t);

	U32 TexActivate(VidTex *tex, vidtexactivatetype_t vta);
	VidTex *TexLoad(CC8 *path,U8 fatal,U32 flags=0,U32 mask_color=0);
	VidTex *TexLoadBMP(CC8 *filename, U8 fatal,U32 flags=0);
	VidTex *TexLoadTGA(CC8 *filename, U8 fatal,U32 flags=0);
	U32 TexRelease(VidTex *tex);
	U32 TexReload(VidTex *tex);
	VidTex *TexForName(CC8 *name);
	VidTex *GetBlankTex(void);

	U32 LockScreen(vidlockscreentype_t lock, unsigned short **buffer, int *pitch);
	void UnlockScreen(void);

	void BeginScene(void);
	void EndScene(void);

	void SetHooptiFrustum(float fov_angle,float xy_ratio,float near,float far);

	void ClipBad(void);
	void ClipGood(void);

	void Diags(void);
	
	void BeginLines(U32 guess_num);
	void EndLines(void);

	U32 check_clip(DxVertexT *v1,DxVertexT *v2,DxVertexT *v3);
};

class VidDll : public XDll
{
	VidD3D	*d3d;
	U32 version;

	U32 close(void);
public:
	VidDll(void);
	~VidDll(void);

	VidD3D *get_if(void){return d3d;}
	U32 get_version(void){return version;}
	U32 vid_release(void);
};

extern float _deb_clip_x;
extern float _deb_clip_y;
extern float _deb_clip_width;
extern float _deb_clip_height;

extern VidDll _dll_vid;

#endif _VIDD3D_H_