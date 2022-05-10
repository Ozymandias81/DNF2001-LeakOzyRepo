#include "stdd3d.h"

static U32 tex_d3d_format(U32 img_format)
{
	switch(img_format)
	{
		case IMG_FORMAT_I8:
			return D3DFMT_L8;
		case IMG_FORMAT_P8:
			return D3DFMT_P8;
		case IMG_FORMAT_AP88:
			return D3DFMT_A8P8;
		case IMG_FORMAT_RGB_565:
			return D3DFMT_R5G6B5;
		case IMG_FORMAT_ARGB_1555:
			return D3DFMT_A1R5G5B5;
		case IMG_FORMAT_ARGB_4444:
			return D3DFMT_A4R4G4B4;
		case IMG_FORMAT_RGB_888:
			return D3DFMT_R8G8B8;
		case IMG_FORMAT_ARGB_8888:
			return D3DFMT_A8R8G8B8;
		default:
			return 0;
	}
}

VidTexD3D::VidTexD3D(CC8 *Name,XImage *Image) : image(Image),d3d(null),d3d_format(D3DFMT_UNKNOWN)
{
	if (Name)
		name=CStr(Name);

	width=image->get_width();
	height=image->get_height();
	bpp=image->get_bpp();
	d3d_format=tex_d3d_format(image->get_format());
	tex_data=image->get_data();
}

VidTexD3D::VidTexD3D(CC8 *Name,U32 Width,U32 Height,U32 Format)  : d3d(null),d3d_format(D3DFMT_UNKNOWN)
{
	ImgFormatInfo *fmt_info;

	if (Name)
		name=CStr(Name);

	width=Width;
	height=Height;
	fmt_info=ImgGetFormatInfo(Format);
	bpp=fmt_info->bpp;
	d3d_format=tex_d3d_format(Format);
	tex_free=(char *)xmalloc(width*height*bpp);
	tex_data=tex_free;
}

VidTexD3D::~VidTexD3D(void)
{
	if (d3d)
		d3d->Release();
	d3d=null;
}

void VidTexD3D::create_d3d(IDirect3DDevice8 *dev)
{
	if (dev->CreateTexture(width,height,0,0,(D3DFORMAT)d3d_format,D3DPOOL_MANAGED,&d3d)!=D3D_OK)
		xxx_fatal("VidTexD3D::create_d3d: Unable to create texture");
	
	load_tex();
}

void VidTexD3D::load_tex(void)
{
	D_ASSERT(d3d);
	IDirect3DSurface8 *surf;

	if (d3d->GetSurfaceLevel(0,&surf)!=D3D_OK)
		xxx_fatal("VidTexD3D::create_d3d: Unable to get surface of texture");

	RECT rect;

	rect.top=0;
	rect.left=0;
	rect.bottom=height;
	rect.right=width;

	if (D3DXLoadSurfaceFromMemory(surf,null,null,tex_data,(D3DFORMAT)d3d_format,bpp*width,null,&rect,D3DX_DEFAULT,0)!=D3D_OK)
		xxx_fatal("VidTexD3D::create_d3d: failed to load texture");

	if (D3DXFilterTexture(d3d,null,0,D3DX_DEFAULT)!=D3D_OK)
		xxx_fatal("VidTexD3D::create_d3d: failed to create mips");

	surf->Release();
}

void VidTexD3D::release_d3d(void)
{
	if (d3d)
		d3d->Release();
	d3d=null;
}

VidTexD3D *TexList::remove(VidTexD3D *obj)
{
	XNode *node;

	node=head;
	while(node)
	{
		if (node->data==obj)
		{
			XList<VidTexD3D>::remove((XPos *)node);
			return node->data;
		}
		node=node->next;
	}
	return null;
}

VidTexD3D *TexList::find_named(CC8 *name)
{
	XNode *node;

	node=head;
	while(node)
	{
		VidTexD3D *tex=node->data;

		if (tex->name)
		{
			if (_stricmp(tex->name,name)==0)
				return tex;
		}
		node=node->next;
	}
	return null;
}

void TexList::release_d3d(void)
{
	XNode *node;

	node=head;
	while(node)
	{
		VidTexD3D *tex=node->data;

		tex->release_d3d();

		node=node->next;
	}
}

U32 VidD3D::TexActivate(VidTex *Tex, vidtexactivatetype_t vta)
{
	VidTexD3D *tex=(VidTexD3D *)Tex;

	/* if already current texture */
	if (tex==active_tex)
		return TRUE;

	vbuffers->flush();

	if (!tex)
		xxx_fatal("VidD3D::TexActivate: Null texture");

	if (!tex->get_d3d())
		tex->create_d3d(dev);

	if (dev->SetTexture(0,tex->get_d3d())!=D3D_OK)
		xxx_fatal("VidD3D::TexActivate: Unable to set texture");

	active_tex=tex;

	return FALSE;
}

VidTex *VidD3D::TexLoad(CC8 *path,U8 fatal,U32 flags,U32 mask_color)
{
	VidTexD3D *tex;
	XImage *image;

	CC8 *ext=fget_extension(path);
	
	U32 is_tga=FALSE;
	if (_stricmp(ext,"tga")==0)
	{
		image=XLoadTGADevice(path,&img_device);
		is_tga=TRUE;
	}
	else
		image=XLoadBMPDevice(path,&img_device,IMG_FORMAT_ARGB_1555);
	if (!image)
	{
		if (fatal)
			xxx_printf(ERROR_SEVERE,"Unable to load %s\n",path);
		return null;
	}

	/* TODO: clean up this hack around true color and masking */
	if (!is_tga)
	{
		if (flags & TEX_LOAD_MASKED)
			image->generate_mask(mask_color);
	}

	CC8 *filename=fget_filename(path);
	tex=new VidTexD3D(filename,image);
	tex_list.add_head(tex);
	
	return tex;
}

VidTex *VidD3D::TexLoadBMP(CC8 *filename,U8 fatal,U32 flags)
{
	VidTexD3D *tex;
	/* try and load image to best fit device */
	XImage *image=XLoadBMPDevice(filename,&img_device,IMG_FORMAT_ARGB_1555);
	if (!image)
	{
		if (fatal)
			xxx_printf(ERROR_SEVERE,"Unable to load %s\n",filename);
		return null;
	}
	if (flags & TEX_LOAD_MASKED)
		image->generate_mask(0);
	tex=new VidTexD3D(filename,image);
	tex_list.add_head(tex);

	return tex;
}

VidTex *VidD3D::TexLoadTGA(CC8 *filename,U8 fatal,U32 flags)
{
	VidTexD3D	*tex;

	tex=(VidTexD3D *)TexForName(filename);
	if (tex)
		xxx_fatal("VidD3D::TexLoadTGA: already loaded");

	/* try and load image to best fit device */
	XImage *image=XLoadTGADevice(filename,&img_device);
	if (!image)
	{
		if (fatal)
			xxx_printf(ERROR_SEVERE,"Unable to load %s\n",filename);
		return null;
	}

	tex=new VidTexD3D(filename,image);
	tex_list.add_head(tex);
	
	return tex;
}

U32 VidD3D::TexRelease(VidTex *Tex)
{
	if (!Tex)
		return TRUE;

	VidTexD3D *tex=(VidTexD3D *)Tex;

	if (!tex_list.remove(tex))
		xxx_fatal("VidD3D::TexRelease: Unable to find texture for freeing");

	delete tex;

	return TRUE;
}

U32 VidD3D::TexReload(VidTex *Tex)
{
	VidTexD3D *tex=(VidTexD3D *)Tex;
	
	if (!tex->get_d3d())
		tex->create_d3d(dev);
	else
		tex->load_tex();

	return TRUE;
}

VidTex *VidD3D::TexForName(CC8 *name)
{
	return tex_list.find_named(name);
}

void VidD3D::CreateBlankTex(void)
{
	VidTexD3D *tex;

	D_ASSERT(!blank_tex);

	tex=new VidTexD3D("_blank_",16,16,IMG_FORMAT_RGB_565);
	tex_list.add_head(tex);

	memset(tex->tex_data,0,tex->width*tex->height*tex->bpp);

	blank_tex=tex;
}

VidTex *VidD3D::GetBlankTex(void)
{
	if (!blank_tex)
		CreateBlankTex();

	return blank_tex;
}
