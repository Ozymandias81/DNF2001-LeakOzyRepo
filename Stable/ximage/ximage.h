#ifndef _XIMAGE_H_
#define _XIMAGE_H_

#ifndef _XCORE_H_
#include <xcore.h>
#endif

#ifdef XIMAGE_LIBRARY
#define XIMAGE_API	XDLL_EXPORT
#else
#define XIMAGE_API	XDLL_IMPORT
#endif

enum img_type_enums
{
	IMG_FORMAT_INVALID	=0,
	IMG_FORMAT_I8		=1,
	IMG_FORMAT_P8		=2,
	IMG_FORMAT_AP88		=3,
	IMG_FORMAT_RGB_565	=4,
	IMG_FORMAT_ARGB_1555=5,
	IMG_FORMAT_ARGB_4444=6,
	IMG_FORMAT_RGB_888	=7,
	IMG_FORMAT_ARGB_8888=8,
	IMG_FORMAT_MAX		=9
};

enum img_device_restrict
{
	IMG_RESTRICT_NO_PALETTE	=0x01,
	IMG_RESTRICT_NO_32		=0x02,
	IMG_RESTRICT_NO_ALPHA	=0x04,
	IMG_RESTRICT_POW_2		=0x08,
	IMG_RESTRICT_256		=0x10,
	IMG_RESTRICT_ASPECT_8	=0x20
};

enum img_device_support
{
	IMG_SUPPORTS_I8			=0x00001,
	IMG_SUPPORTS_P8			=0x00002,
	IMG_SUPPORTS_AP88		=0x00004,
	IMG_SUPPORTS_RGB_565	=0x00008,
	IMG_SUPPORTS_RGB_888	=0x00010,
	IMG_SUPPORTS_ARGB_1555	=0x00020,
	IMG_SUPPORTS_ARGB_4444	=0x00040,
	IMG_SUPPORTS_ARGB_8888	=0x00080,
	IMG_SUPPORTS_S3TC		=0x00100,
	IMG_SUPPORTS_DXT1		=0x00200,
	IMG_SUPPORTS_DXT2		=0x00400,
	IMG_SUPPORTS_DXT3		=0x00800,
	IMG_SUPPORTS_DXT4		=0x01000,
	IMG_SUPPORTS_DXT5		=0x02000
};

class ImgFormatInfo
{
public:
	U32 format;
	U32 bpp;
	U32 flags;
};

namespace NS_IMAGE
{
	extern ImgFormatInfo XIMAGE_API format_list[IMG_FORMAT_MAX];
}

class XIMAGE_API ImgDevice
{
	U32 restrict;
	U32 support;
public:
	ImgDevice(void) : restrict(0),support(0) {}
	void set_support(U32 val){support=val;}
	void set_restrict(U32 val){restrict=val;}
	virtual U32 best_match(U32 img_format);
};

#define ARGB32_To_4444(pix) \
	((U16)(((pix>>16)&0xF000) | \
	((pix>>12)&0x0F00) | \
	((pix>>8)&0x00F0) | \
	((pix>>4)&0x000F)))

#define ARGB32_To_565(pix) \
	((U16)(((pix>>8)&0xF800) | \
	((pix>>5)&0x07E0) | \
	((pix>>3)&0x001F)))

#define ARGB32_To_1555(pix) \
	((U16)(((pix>>16)&0x8000) | \
	((pix>>9)&0x7C00) | \
	((pix>>6)&0x03E0) | \
	((pix>>3)&0x001F)))

#define PACKED_TO_X555(color) ((U16)(((color>>3)&0x1F) | ((color>>6)&0x3E0) | ((color>>9)&0x7C00)))

class XPalette
{
	U32		data[256];
};

class XIMAGE_API XImage
{
	U16				width;
	U16				height;
	U16				bpp;
	U16				format;
	autochar		data;
	autochar		palette;

	static U32 format_to_bpp(U32 Format);

protected:
	void generate_mask_1555(U32 color);

public:
	XImage(U32 Width,U32 Height,U32 format);
	XImage(void *data,U32 Width,U32 Height,U32 format);
	char *get_data(void){return data;}
	U32 get_num_pixels(void){return (width * height);}
	U32 get_size(void){return (width * height * bpp);}
	U32 get_width(void){return width;}
	U32 get_height(void){return height;}
	U32 get_bpp(void){return bpp;}
	U32 get_format(void){return format;}
	void generate_mask(U32 color);
};

class XImageLib
{
	CC8 **extensions;
	U32 num_extensions;

	U32 conv_mem_size;
	autochar conv_mem;

public:
	XImageLib(void);
	U32 init(void);
	U32 QueryImageFileSupport(CC8 **&extensions,U32 &num_extension);
	char *get_conv_mem(U32 size);
};

extern XImageLib	_ximg;

extern "C" {
XIMAGE_API XImage *XLoadBMPDevice(CC8 *name,ImgDevice *device,U32 format=0);
XIMAGE_API XImage *XLoadTGADevice(CC8 *name,ImgDevice *device,U32 format=0);
}

typedef U32 (*ImgConvert_f)(void *dst,void *src,U32 width,U32 height);

U32 ImgConvertTrueTo4444(void *dst,void *src,U32 width,U32 height);
U32 ImgConvertTrueTo565(void *dst,void *src,U32 width,U32 height);
U32 ImgConvertTrueTo1555(void *dst,void *src,U32 width,U32 height);

void flip_image(U32 *data,U32 width,U32 height,U32 flipx,U32 flipy);

inline ImgFormatInfo *ImgGetFormatInfo(U32 format)
{
	return &NS_IMAGE::format_list[format];
}

#endif /* ifndef _XIMAGE_H_ */