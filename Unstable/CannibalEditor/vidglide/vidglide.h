#ifndef _VIDGLIDE_H_
#define _VIDGLIDE_H_

#ifndef _XCORE_H_
#include <xcore.h>
#endif

#ifndef _XIMAGE_H_
#include <ximage.h>
#endif

#ifndef __GLIDE_H__
#include <glide.h>
#endif

class GlTex;

typedef struct
{
	float x, y, z;
	float r, g, b;
	float ooz;
	float a;
	float oow;
	float s0,t0,w0;
	float s1,t1,w1;
}GVertex;

class GCacheEntry
{
	U32 address;
	U32 size;
	U32 flags;
	GlTex *tex;

public:
	GCacheEntry *next;
	GCacheEntry *prev;

public:
	GCacheEntry(void) : tex(null),flags(0) {}
	U32 get_address(void){return address;}
	U32 get_size(void){return size;}
	U32 invalidate(void);
	void set_texture(GlTex *Tex);
	void set_address(U32 Address){address=Address;}
	void set_size(U32 Size){size=Size;}
	GlTex *get_tex(void){return tex;}
};

class GlTex
{
public:
	I32			small_lod;
	I32			large_lod;
	I32			aspect;
	U32			format;
	char		*data;
	GCacheEntry	*cache_info;
	float		scale_s,scale_t;

public:
	GlTex(void) : cache_info(null),data(null) {}
	~GlTex(void)
	{
		if (cache_info)
			cache_info->invalidate();
	}
	U32 init(U32 width,U32 height,U32 format);
	U32 get_address(void){return cache_info->get_address();}
	float get_scale_s0(void){return scale_s;}
	float get_scale_t0(void){return scale_t;}
};

class GVidTex : public VidTex
{
public:
	GlTex	gl_info;
protected:
	GlTex	*x0;
	GlTex	*y0;

	XImageRef image;

public:
	GVidTex	*next;
	GVidTex	*prev;

public:
	GVidTex(CC8 *Name,U32 width,U32 height,U32 format);
	GVidTex(CC8 *Name,XImageRef const &image);
	~GVidTex(void);

	U32 load(void);
	U32 reload(void);
	U32 select(void);
	U32 select_x0(void);
	U32 select_y0(void);
	U32 is_cached(void){return (U32)(gl_info.cache_info);}
	U32 get_required_size(void){return grTexCalcMemRequired(gl_info.small_lod,gl_info.large_lod,gl_info.aspect,gl_info.format);}
	GlTex *get(void){return &gl_info;}
	void take_name(CC8 *Name);

	void *operator new(size_t size);
	void operator delete(void *ptr);
};

class GlTexCache
{
	U32 base_address;
	U32 end_address;
	U32 size;

	U32 max_texture_size;

	XRingChain<GCacheEntry> active;
	XChain<GCacheEntry>		avail;

	GCacheEntry *get_avail(void);
public:
	U32 init(void);
	U32 cache(GVidTex *tex);
	U32 reload(GVidTex *tex);
};

inline GCacheEntry *GlTexCache::get_avail(void)
{
	GCacheEntry *entry;

	entry=avail.remove_head();
	if (!entry)
		entry=new GCacheEntry;

	return entry;
}

#define FONTDATA_WIDTH 6
#define FONTDATA_HEIGHT 6

typedef struct
{
	char marker[4];
	char versionMajor;
	char versionMinor;
	short numFrames;
	int flags;
	int reserved;
} gbaheader_t;

typedef struct
{
	int frameOfs;
	int frameFlags;
	char frameName[24];
} gbaframeentry_t;

typedef struct
{
	short width;
	short height;
	short originX;
	short originY;
	char data[FONTDATA_HEIGHT][FONTDATA_WIDTH];
} gbaframe_t;

class GFont
{
	autoptr<char>	name;

	GVidTex			*font_letter[256];
	
	XChain<GVidTex> font_list;
public:
	GFont(void);

	GVidTex *get_tex(U8 letter);
	U32 load(CC8 *name,U32 fatal);
	void add_letter(CC8 *letter,GVidTex *tex);
};

class VGlideDll : public XDll
{
	XChain<GVidTex>	avail_tex;
	XChain<GVidTex>	used_tex;

	XChain<GVidTex>	keyed_x_tex;
	XChain<GVidTex>	keyed_y_tex;

	GlTexCache		tex_cache;
	ImgDevice		img_device;

	XList<GVidTex>	dev_tex_list;

	XList<GVidTex>	named_list;
	
	autoptr<GFont>	font;

public:
	VGlideDll(void);
	~VGlideDll(void);
	GVidTex *alloc_tex(void);
	void free_tex(GVidTex *tex);
	ImgDevice *get_img_device(void){return &img_device;}
	VidTex *get_named_tex(CC8 *name);
	GlTexCache *get_cache(void){return &tex_cache;}
	U32 init_cache(void){return tex_cache.init();}
	U32 register_name(GVidTex *tex);
	U32 unregister_name(GVidTex *tex);
	void add_device_tex(GVidTex *tex){dev_tex_list.add_head(tex);}
	GFont *get_font(void){return font;}
	U32 load_font(CC8 *filename,U32 fatal);
};

extern VGlideDll _vg_dll;

int VID_TexActivate(VidTex *tex, vidtexactivatetype_t vta);
int VID_TexUpload(VidTex *Tex);
int VID_TexReload(VidTex *tex);
int VID_TexRelease(VidTex *tex);
int VID_TexLoadGBAFont(CC8 *filename, U8 fatal);

GVidTex *CreateBlankVidtex(void);

extern "C"{
void VID_DrawPolygonFlags(U32 flags,int numverts, vector_type *p, vector_type *c, float *a, vector_type *tv,U8 useDepth);

void SafeRead(void *ptr, int elemSize, int numElems, FILE *fp);
void SafeWrite(void *ptr, int elemSize, int numElems, FILE *fp);
}

#endif /* ifndef _VIDGLIDE_H_ */