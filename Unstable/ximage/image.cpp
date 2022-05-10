#include "ximage.h"

CC8 *_extensions[]={"tga",null};

XImageLib	_ximg;

namespace NS_IMAGE
{
	ImgFormatInfo format_list[IMG_FORMAT_MAX]=
	{
		{IMG_FORMAT_I8,1,0},
		{IMG_FORMAT_P8,1,0},
		{IMG_FORMAT_AP88,2,0},
		{IMG_FORMAT_RGB_565,2,0},
		{IMG_FORMAT_ARGB_1555,2,0},
		{IMG_FORMAT_ARGB_4444,2,0},
		{IMG_FORMAT_RGB_888,3,0},
		{IMG_FORMAT_ARGB_8888,4,0}
	};
}

XImageLib::XImageLib(void)
{
	if (!init())
		xxx_throw("XImageLib: unable to intialize");
}

U32 XImageLib::init(void)
{
	extensions=_extensions;
	CC8 **src=_extensions;

	while(*src)
	{
		num_extensions++;
		src++;
	}

	conv_mem_size=512*512*4;
	conv_mem=(char *)xmalloc(512*512*4);
	return TRUE;
}

U32 XImageLib::QueryImageFileSupport(CC8 **&Extensions,U32 &NumExtensions)
{
	Extensions=extensions;
	NumExtensions=num_extensions;
	
	return TRUE;
}

char *XImageLib::get_conv_mem(U32 size)
{
	if (size > conv_mem_size)
	{
		xxx_bitch("reallocating conversion memory");
		xfree(conv_mem);
		conv_mem=(char *)xmalloc(size);
	}
	return conv_mem;
}

XImage::XImage(void *Data,U32 Width,U32 Height,U32 Format)
{
	/* TODO: speed this up */
	format=(U16)Format;
	bpp=(U16)format_to_bpp(Format);

	data=(char *)Data;
}

XImage::XImage(U32 Width,U32 Height,U32 Format) : width((U16)Width),height((U16)Height)
{
	/* TODO: speed this up */
	format=(U16)Format;
	bpp=(U16)format_to_bpp(Format);

	U32 size=bpp*width*height;
	
	data=(char *)xmalloc(size);
}

U32 XImage::format_to_bpp(U32 Format)
{
	switch(Format)
	{
		case IMG_FORMAT_I8:
			return 1;
		case IMG_FORMAT_P8:
			return 1;
		case IMG_FORMAT_AP88:
			return 2;
		case IMG_FORMAT_RGB_565:
			return 2;
		case IMG_FORMAT_ARGB_1555:
			return 2;
		case IMG_FORMAT_ARGB_4444:
			return 2;
		case IMG_FORMAT_RGB_888:
			return 3;
		case IMG_FORMAT_ARGB_8888:
			return 4;
		default:
			xxx_throw("XImage: Invalid format");
			break;
	}
	return 0;
}

U32 ImgConvertTrueTo1555(void *dst,void *src,U32 width,U32 height)
{
	D_ASSERT(dst);D_ASSERT(src);

	U32 *src32=(U32 *)src;
	U16 *dst16=(U16 *)dst;
	U32 num_pixels=width*height;

	while(num_pixels--)
	{
		U32 pix=*src32++;
		*dst16++=ARGB32_To_1555(pix);
	}
	return TRUE;
}

U32 ImgConvertTrueTo565(void *dst,void *src,U32 width,U32 height)
{
	D_ASSERT(dst);D_ASSERT(src);

	U32 *src32=(U32 *)src;
	U16 *dst16=(U16 *)dst;
	U32 num_pixels=width*height;

	while(num_pixels--)
	{
		U32 pix=*src32++;
		*dst16++=ARGB32_To_565(pix);
	}
	return TRUE;
}

U32 ImgConvertTrueTo4444(void *dst,void *src,U32 width,U32 height)
{
	D_ASSERT(dst);D_ASSERT(src);

	U32 *src32=(U32 *)src;
	U16 *dst16=(U16 *)dst;
	U32 num_pixels=width*height;

	while(num_pixels--)
	{
		U32 pix=*src32++;
		*dst16++=ARGB32_To_4444(pix);
	}
	return TRUE;
}


/* TODO: better way to do this */
U32 ImgDevice::best_match(U32 img_format)
{
	U32 has_alpha=FALSE;
	U32 has_palette=FALSE;

	switch(img_format)
	{
		case IMG_FORMAT_I8:
			if (support & IMG_SUPPORTS_I8)
				return IMG_FORMAT_I8;
			break;
		case IMG_FORMAT_P8:
			if (support & IMG_SUPPORTS_P8)
				return IMG_FORMAT_P8;
			has_palette=TRUE;
			break;
		case IMG_FORMAT_AP88:
			if (support & IMG_SUPPORTS_AP88)
				return IMG_FORMAT_AP88;
			has_alpha=TRUE;
			has_palette=TRUE;
			break;
		case IMG_FORMAT_RGB_565:
			if (support & IMG_SUPPORTS_RGB_565)
				return IMG_FORMAT_RGB_565;
			break;
		case IMG_FORMAT_ARGB_1555:
			if (support & IMG_SUPPORTS_ARGB_1555)
				return IMG_FORMAT_ARGB_1555;
			has_alpha=TRUE;
			break;
		case IMG_FORMAT_ARGB_4444:
			if (support & IMG_SUPPORTS_RGB_565)
				return IMG_FORMAT_RGB_565;
			has_alpha=TRUE;
			break;
		case IMG_FORMAT_RGB_888:
			if (support & IMG_SUPPORTS_RGB_888)
				return IMG_FORMAT_RGB_888;
			break;
		case IMG_FORMAT_ARGB_8888:
			if (support & IMG_SUPPORTS_ARGB_8888)
				return IMG_FORMAT_ARGB_8888;
			has_alpha=TRUE;
			break;
	}
	if (has_alpha)
	{
		if (support & IMG_SUPPORTS_ARGB_8888)
			return IMG_FORMAT_ARGB_8888;
		if (support & IMG_SUPPORTS_ARGB_4444)
			return IMG_FORMAT_ARGB_4444;
		if (support & IMG_SUPPORTS_ARGB_1555)
			return IMG_FORMAT_ARGB_1555;
	}
	if (support & IMG_SUPPORTS_RGB_565)
		return IMG_FORMAT_RGB_565;
	if (support & IMG_SUPPORTS_ARGB_1555)
		return IMG_FORMAT_ARGB_1555;

	return 0;
}

void XImage::generate_mask(U32 color)
{
	switch(format)
	{
		case IMG_FORMAT_ARGB_1555:
			generate_mask_1555(color);
			break;
		default:
			xxx_throw("XImage::generate_mask: unsupported type to generate mask");
	}
}

#define PACKED_TO_X444(color)

void XImage::generate_mask_1555(U32 color)
{
	D_ASSERT(data);

	U32 num=get_num_pixels();
	U16 *src16=(U16 *)data.get_ptr();
	U16 col16=PACKED_TO_X555(color);

	while(num--)
	{
		U16 val=*src16 & 0x7FFF;
		if (val==col16)
			*src16=val;
		else
			*src16=val|0x8000;
		src16++;
	}
}

void flip_image(U32 *data,U32 width,U32 height,U32 flipx,U32 flipy)
{
	U32 num_x,num_y;
	U32 *src,*dst;
	I32 x_inc,y_inc;
	
	src=data;
	dst=src;
	
	x_inc=1;y_inc=1;

	if ((flipx) && (flipy))
	{
		num_x=width>>1;
		num_y=(height>>1) + (height & 1);
		dst+=(height * width) - 1;
		x_inc=-1;
		y_inc=0;
	}
	else if (flipy)
	{
		num_x=width;
		num_y=(height>>1);
		dst+=((height - 1) * width);
		x_inc=1;
		y_inc=0 - (width * 2);
	}
	else if (flipx)
	{
		num_x=width>>1;
		num_y=height;
		dst+=width - 1;
		x_inc=-1;
		y_inc=width * 2;
	}
	
	while(num_y--)
	{
		U32 count_x=num_x;
		while(count_x--)
		{
			U32 pix_near,pix_far;

			pix_near=*src;
			pix_far=*dst;

			*src++=pix_far;
			*dst=pix_near;

			dst+=x_inc;
		}
		dst+=y_inc;
	}
}
