#include <xcore.h>
#include <stdlib.h>
#include <vid_main.h>
#include <stdio.h>
#include "vidglide.h"

#pragma intrinsic(abs,memset)

U32 GlTexCache::init(void)
{
	U32 min,max;

	min=grTexMinAddress(GR_TMU0);
	max=grTexMaxAddress(GR_TMU0);

	base_address=min;
	size=max - min;
	end_address=base_address+size;

	/* calculate maximum allowable texture size */
	max_texture_size=(max - min);
	if (max_texture_size > 0x100000)
		max_texture_size=0x100000;

	U32 size_left=size;
	U32 last_address=base_address;

	/* prep the cache entries */
	GCacheEntry *first=null;
	while(size_left)
	{
		GCacheEntry *entry=new GCacheEntry;
		if (!first)
			first=entry;
		entry->set_address(last_address);
		entry->set_size(size_left);
		if (size_left > 0x200000)
			entry->set_size(0x200000);
		active.insert_after(entry);
		last_address+=entry->get_size();
		size_left-=entry->get_size();
	}
	active.set_cur(first);

	return TRUE;
}

U32 cross_2meg(U32 address,U32 size)
{
	U32 mask=~(0x200000 - 1);
	U32 start,end;
	
	end=(address+size)&mask;
	start=address & mask;

	if (end!=start)
		return TRUE;
	return FALSE;
}

U32 GlTexCache::reload(GVidTex *tex)
{
	if (!tex->is_cached())
		cache(tex);

	GCacheEntry *entry=tex->gl_info.cache_info;

	grTexDownloadMipMap(GR_TMU0,entry->get_address(),GR_MIPMAPLEVELMASK_BOTH,(GrTexInfo *)entry->get_tex());
	return TRUE;
}

U32 GlTexCache::cache(GVidTex *tex)
{
	if (tex->is_cached())
		return TRUE;

	GCacheEntry *start=active.get_cur();
	U32 size_needed;

	size_needed=tex->get_required_size();
	if (size_needed>max_texture_size)
	{
		xxx_bitch("GlTexCache::cache: Texture size is too big");
		return FALSE;
	}

	U32 start_addr=start->get_address();
	/* check if it will cross the 2 Meg boundary */
	while (cross_2meg(start_addr,size_needed))
	{
		/*skip to texture that is on other side of boundary */
		start=active.get_next(start);
		start_addr=start->get_address();
	}
	/* now make sure we have room before end of buffer */
	while ((start_addr+size_needed) > end_address)
	{
		start=active.get_next(start);
		start_addr=start->get_address();
	}
	/* now invalidate all textures we are going to stomp */
	U32 total_size=0;
	do
	{
		GCacheEntry *end;
		/* remove from cache loop */
		end=active.remove_cur();
		/* invalidate texture */
		end->invalidate();
		/* add to available list */
		avail.add_head(end);

		total_size+=end->get_size();
	}while(total_size<size_needed);
	
	GCacheEntry *entry;

	entry=get_avail();
	entry->set_texture(tex->get());
	entry->set_address(start_addr);
	entry->set_size(size_needed);
	active.insert_before(entry);

	U32 size_left=total_size - size_needed;
	
	if (size_left)
	{
		GCacheEntry *hole;

		hole=get_avail();
		hole->set_texture(null);
		hole->set_address(start_addr+size_needed);
		hole->set_size(size_left);
		active.insert_after(hole);
	}

	grTexDownloadMipMap(GR_TMU0,entry->get_address(),GR_MIPMAPLEVELMASK_BOTH,(GrTexInfo *)entry->get_tex());
	return TRUE;
}

U32 GCacheEntry::invalidate(void)
{
	if (tex)
		tex->cache_info=null;
	return TRUE;
}

void GCacheEntry::set_texture(GlTex *Tex)
{	
	tex=Tex;
	if (Tex)
		Tex->cache_info=this;
}

int VID_TexUpload(VidTex *Tex)
{
	GVidTex *tex=(GVidTex *)Tex;

	//tex->load();
	tex->select();

	return TRUE;
}

int VID_TexReload(VidTex *Tex)
{
	GVidTex *tex=(GVidTex *)Tex;

	tex->reload();
	
	return TRUE;
}

int VID_TexActivate(VidTex *Tex, vidtexactivatetype_t vta)
{
	GVidTex *tex=(GVidTex *)Tex;

	if (tex == *vid.activeTex)
		return(1); // already the active texture

	if (!tex)
		sys.Error("VID_TexActivate: Invalid vidtex");
	
	tex->timestamp = sys.GetTimeFloat();

	switch(vta)
	{
		case VTA_NORMAL:
			tex->select();
			break;
		case VTA_XO:
			tex->select_x0();
			break;
		case VTA_YO:
			tex->select_y0();
			break;
		default:
			sys.Error("VID_TexActivate: Invalid activate type");
	}
	*vid.activeTex = tex;
	return(1);
}

#if 0
grColorCombine(GR_COMBINE_FUNCTION_SCALE_OTHER_ADD_LOCAL, GR_COMBINE_FACTOR_ONE,
	GR_COMBINE_LOCAL_CONSTANT, GR_COMBINE_OTHER_TEXTURE, FXFALSE);
grAlphaCombine(GR_COMBINE_FUNCTION_LOCAL, GR_COMBINE_FACTOR_ONE,
	GR_COMBINE_LOCAL_CONSTANT, GR_COMBINE_OTHER_NONE, FXFALSE);
grAlphaBlendFunction(GR_BLEND_ONE, GR_BLEND_ZERO, GR_BLEND_ONE, GR_BLEND_ZERO);
grChromakeyMode(GR_CHROMAKEY_ENABLE);
#endif

static I32 _gl_convert[IMG_FORMAT_MAX]=
{
	-1,
	GR_TEXFMT_INTENSITY_8,
	GR_TEXFMT_P_8,
	GR_TEXFMT_AP_88,
	GR_TEXFMT_RGB_565,
	GR_TEXFMT_ARGB_1555,
	GR_TEXFMT_ARGB_4444,
	-1,
	-1
};

inline U32 GlideConvertFormat(U32 format)
{
	I32 fmt=_gl_convert[format];

	D_ASSERT(fmt>=0);
	
	return fmt;
}

U32 GlTex::init(U32 width,U32 height,U32 Format)
{
	D_ASSERT(IS_POW2(width));
	D_ASSERT(IS_POW2(height));
	D_ASSERT(width<=256);
	D_ASSERT(height<=256);

	U32 slog=0,tlog=0;

	U32 tmp_width=width,tmp_height=height;

	while(tmp_width>>=1)slog++;
	while(tmp_height>>=1)tlog++;

	U32 smajor=((tlog - slog) & 0x80000000);
	I32 diff=tlog - slog;

	D_ASSERT(abs(diff)<=3);

	aspect=diff+3;

	U32 lod;

	if (smajor)
	{
		lod=8-slog;
		scale_s=255.0f;
		scale_t=scale_s/(float)(abs(diff+1));
	}
	else
	{
		lod=8-tlog;
		scale_t=255.0f;
		scale_s=scale_t/(float)(abs(diff+1));
	}

	small_lod=lod;
	large_lod=lod;
	format=GlideConvertFormat(Format);

	return TRUE;
}

U32 GVidTex::select(void)
{
	GlTexCache *cache=_vg_dll.get_cache();

	gl_info.data=tex_data;
	if (!is_cached())
		cache->cache(this);

	grTexSource(GR_TMU0,gl_info.get_address(),
				GR_MIPMAPLEVELMASK_BOTH,(GrTexInfo *)&gl_info);

	return TRUE;
}

U32 GVidTex::select_x0(void)
{
	_asm int 3
	return TRUE;
}

U32 GVidTex::select_y0(void)
{
	_asm int 3
	return TRUE;
}

U32 GVidTex::load(void)
{
	_asm int 3
	return TRUE;
}

U32 GVidTex::reload(void)
{
	GlTexCache *cache=_vg_dll.get_cache();

	gl_info.data=tex_data;
	if (!is_cached())
		cache->cache(this);
	else
		cache->reload(this);

	grTexSource(GR_TMU0,gl_info.get_address(),
				GR_MIPMAPLEVELMASK_BOTH,(GrTexInfo *)&gl_info);

	return TRUE;
}

GVidTex *CreateBlankVidtex(void)
{
	GVidTex *tex;

	tex = new GVidTex("_blank_",16,16,IMG_FORMAT_RGB_565);

	_vg_dll.add_device_tex(tex);
	
	memset(tex->tex_data,0,tex->width * tex->height * tex->bpp);

	return(tex);
}

GVidTex::GVidTex(CC8 *Name,U32 Width,U32 Height,U32 format)
{
	ImgFormatInfo *fmt_info;

	if (Name)
	{
		name=Name;
		_vg_dll.register_name(this);
	}

	width=Width;
	height=Height;
	fmt_info=ImgGetFormatInfo(format);
	bpp=fmt_info->bpp;
	tex_free=(char *)xmalloc(fmt_info->bpp * width * height);
	tex_data=tex_free;
	timestamp=sys.GetTimeFloat();

	gl_info.init(width,height,format);
	gl_info.data=tex_data;
}

GVidTex::GVidTex(CC8 *Name,XImageRef const &Image)
{
	if (Name)
	{
		name=Name;
		_vg_dll.register_name(this);
	}

	image=Image;

	width=image->get_width();
	height=image->get_height();
	bpp=image->get_bpp();
	tex_data=image->get_data();
	tex_free=null;
	timestamp=sys.GetTimeFloat();

	gl_info.init(width,height,image->get_format());
	gl_info.data=tex_data;
}

void GVidTex::take_name(CC8 *Name)
{
	name=Name;

	_vg_dll.register_name(this);
}

GVidTex::~GVidTex(void)
{
	if (name)
		_vg_dll.unregister_name(this);
}

U32 VGlideDll::register_name(GVidTex *tex)
{
	/* check if already registered */
	if (get_named_tex(tex->name))
		return FALSE;

	named_list.add_head(tex);
	return TRUE;
}

U32 VGlideDll::unregister_name(GVidTex *tex)
{
	XPos *node;

	if (!tex->name)
		xxx_bitch("VGlideDll::unregister_name: texture has no name");

	node=named_list.get_head_position();
	while(node)
	{
		GVidTex *obj=named_list.get_at(node);
		if (tex==obj)
		{
			named_list.remove(node);
			return TRUE;
		}
		node=named_list.get_next(node);
	}
	xxx_bitch("VGlideDll::unregister_name: name not registered");
	return FALSE;
}

void *GVidTex::operator new(size_t size)
{
	return _vg_dll.alloc_tex();
}

void GVidTex::operator delete(void *ptr)
{
	_vg_dll.free_tex((GVidTex *)ptr);
}

VidTex *VGlideDll::get_named_tex(CC8 *name)
{
	XPos *node;

	D_ASSERT(name);
	node=named_list.get_head_position();
	while(node)
	{
		GVidTex *tex=named_list.get_at(node);
		if (tex->name)
		{
			if (fstreq(tex->name,name))
				return tex;
		}
		node=named_list.get_next(node);
	}
	return null;
}

int VID_TexRelease(VidTex *tex)
{
	delete ((GVidTex *)tex);
	return TRUE;
}

