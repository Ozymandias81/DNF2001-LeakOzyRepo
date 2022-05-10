#ifndef _XTGA_H_
#define _XTGA_H_

namespace NS_TGA
{
#pragma pack(push,1)
	class TGAHeader
	{
	public:
		U8	length;
		U8	map_type;
		U8	image_type;
		
		U16	cmap_start;
		U16 cmap_length;
		U8	cmap_depth;

		U16	x_origin;
		U16 y_origin;

		U16 img_width;
		U16 img_height;
		U8	pixel_depth;
		U8	img_desc;
	};
#pragma pack(pop)

	enum tga_type_enums
	{
		TGA_NULL			=0,
		TGA_PALETTE			=1,
		TGA_TRUE_COLOR		=2,
		TGA_MONO			=3,
		TGA_RLE_PALETTE		=9,
		TGA_RLE_TRUE_COLOR	=10,
		TGA_RLE_MONO		=11
	};

	class XTgaFile : public XFile
	{
		TGAHeader		header;
		U32				src_format;
		U32				dst_format;
		
		autoptr<XImage>	image;
		
		char			*src_ptr;
		char			*dst_ptr;

		U32 find_tga_format(void);
		U32 true_color_format(void);
		U32 load_true_color(void);
		U32 skip_color_map(void);
		U32 load_rgb32(void);
		U32 load_rgb24(void);

	public:
		CBaseStream & operator >> (TGAHeader &dst);
		XImage *load_device_image(ImgDevice *device,U32 format);
	};
}

#endif /*ifndef _XTGA_H_ */