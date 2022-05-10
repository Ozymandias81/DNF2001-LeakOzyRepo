#include <xcore.h>
#include <vid_main.h>
#include <stdio.h>
#include "vidglide.h"

VGlideDll _vg_dll;
VGlideDll *_vg_dll_ptr=null;

VGlideDll::VGlideDll(void)
{
	img_device.set_support(IMG_SUPPORTS_I8|
						IMG_SUPPORTS_P8|
						IMG_SUPPORTS_AP88|
						IMG_SUPPORTS_RGB_565|
						IMG_SUPPORTS_ARGB_1555|
						IMG_SUPPORTS_ARGB_4444);

	img_device.set_restrict(IMG_RESTRICT_NO_32|
						IMG_RESTRICT_POW_2|
						IMG_RESTRICT_256|
						IMG_RESTRICT_ASPECT_8);
	_vg_dll_ptr=this;
}

VGlideDll::~VGlideDll(void)
{
	_vg_dll_ptr=null;

	dev_tex_list.free_list();
	named_list.lose_list();
	avail_tex.free_list();
}

GVidTex *VGlideDll::alloc_tex(void)
{
	GVidTex *tex=avail_tex.remove_head();

	if (!tex)
		tex=(GVidTex *)xmalloc(sizeof(GVidTex));

	return tex;
}

void VGlideDll::free_tex(GVidTex *tex)
{
	if (_vg_dll_ptr)
	{
		/* so we don't free up ptr again */
		tex->name=null;
		tex->tex_data=null;
		tex->tex_free=null;
		avail_tex.add_head(tex);
	}
	else
		xfree(tex);
}
