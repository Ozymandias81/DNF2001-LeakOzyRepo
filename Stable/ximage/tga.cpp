#include "ximage.h"
#include "xtga.h"

using namespace NS_TGA;

XImage *XLoadTGADevice(CC8 *name,ImgDevice *device,U32 format)
{
	XTgaFile file;

	if (!file.open(name,"r"))
		return null;

	return file.load_device_image(device,format);
}

CBaseStream &XTgaFile::operator >> (TGAHeader &dst)
{
	U32 num_read;
	
	if (!read(&dst,sizeof(TGAHeader),num_read))
		xxx_throw("XTgaFile: read failed");
	
	return *this;
}

XImage *XTgaFile::load_device_image(ImgDevice *device,U32 format)
{
	if (!load_in_memory())
		return null;

	*this >> header;

	src_format=find_tga_format();
	dst_format=format;

	if (!dst_format)
	{
		dst_format=src_format;
		if (device)
			dst_format=device->best_match(src_format);
	}

	image=new XImage(header.img_width,header.img_height,dst_format);

	switch (header.image_type)
	{
		case TGA_TRUE_COLOR:
			load_true_color();
			break;
		case TGA_NULL:
		case TGA_PALETTE:
		case TGA_MONO:
		case TGA_RLE_PALETTE:
		case TGA_RLE_TRUE_COLOR:
		case TGA_RLE_MONO:
		default:
			xxx_bitch("XTgaFile::load: Unsupported TGA image type");
			return null;
	}

	if (src_format!=dst_format)
	{
		ImgConvert_f convert;
		U32 bpp;

		switch(dst_format)
		{
			case IMG_FORMAT_ARGB_4444:
				bpp=16;
				convert=ImgConvertTrueTo4444;
				break;
			case IMG_FORMAT_RGB_565:
				bpp=16;
				convert=ImgConvertTrueTo565;
				break;
			case IMG_FORMAT_ARGB_1555:
				bpp=16;
				convert=ImgConvertTrueTo1555;
				break;
			default:
				xxx_bitch("XTgaFile::load: Unsupported conversion");
				return FALSE;
		}

		convert(image->get_data(),src_ptr,header.img_width,header.img_height);
	}

	return image.release();
}

U32 XTgaFile::load_true_color(void)
{
	skip_color_map();

	switch(header.pixel_depth)
	{
		case 24:
			load_rgb24();
			break;
		case 32:
			load_rgb32();
			break;
		case 15:
		case 16:
		default:
			xxx_bitch("XTgaFile::load_true_color: Unsupported pixel depth");
			return FALSE;
	}
	return TRUE;
}

U32 XTgaFile::find_tga_format(void)
{
	switch (header.image_type)
	{
		case TGA_TRUE_COLOR:
			return true_color_format();
		case TGA_NULL:
		case TGA_PALETTE:
		case TGA_MONO:
		case TGA_RLE_PALETTE:
		case TGA_RLE_TRUE_COLOR:
		case TGA_RLE_MONO:
		default:
			return IMG_FORMAT_INVALID;
	}
	return IMG_FORMAT_INVALID;
}

U32 XTgaFile::true_color_format(void)
{
	switch(header.pixel_depth)
	{
		case 24:
			return IMG_FORMAT_RGB_888;
		case 32:
			return IMG_FORMAT_ARGB_8888;
		case 15:
			return IMG_FORMAT_ARGB_1555;
		case 16:
			return IMG_FORMAT_RGB_565;
		default:
			xxx_bitch("XTgaFile::true_color_format: Unsupported pixel depth");
			return FALSE;
	}
}

U32 XTgaFile::load_rgb24(void)
{
	U32 tmp_flag=0;
	
	/* if we are going to have to convert alloc tmp memory */
	if (src_format!=dst_format)
		tmp_flag=TRUE;
		
	U32 image_size=(header.img_width * 3) * header.img_height;
	U32 num_read, dst_size;

	dst_size=header.img_width * 4 * header.img_height;
	
	char *data;
	if (!tmp_flag)
		data=image->get_data();
	else
		data=src_ptr=_ximg.get_conv_mem(dst_size);

	if (!read(data,image_size,num_read))
		xxx_throw("XTgaImage::load_rgb24: Read failed in load");

	/* convert 24 -> 32 */
	/* inflate in existing data buffer */
	U8 *src=(U8 *)(data+num_read-3);
	U32 *dst=(U32 *)(data + dst_size);
	U32 i,num_pixels=dst_size/4;
	dst--;
	for (i=0;i<num_pixels;i++)
	{
		*dst--=(((U32 *)src)[0] & 0x00FFFFFF) | 0xFF000000;
		src-=3;
	}

	/* adjust flip sanity */
	U32 flip=(header.img_desc ^ 0x20);
	if (flip & 0x30)
	{
		flip_image((U32 *)data,
					header.img_width,
					header.img_height,
					flip & 0x10,
					flip & 0x20);
	}
	return TRUE;
}

U32 XTgaFile::load_rgb32(void)
{
	U32 tmp_flag=0;
	
	/* if we are going to have to convert alloc tmp memory */
	if (src_format!=dst_format)
		tmp_flag=TRUE;
		
	U32 image_size=(header.img_width * 4) * header.img_height;
	U32 num_read,dst_size;

	dst_size=header.img_width * 4 * header.img_height;
	
	char *data;
	if (!tmp_flag)
		data=image->get_data();
	else
		data=src_ptr=_ximg.get_conv_mem(dst_size);

	if (!read(data,image_size,num_read))
		xxx_throw("XTgaFile::load_rgb32: Read failed in load");

	/* adjust flip sanity */
	U32 flip=(header.img_desc ^ 0x20);
	if (flip & 0x30)
	{
		flip_image((U32 *)data,
					header.img_width,
					header.img_height,
					flip & 0x10,
					flip & 0x20);
	}

	return TRUE;
}

U32 XTgaFile::skip_color_map(void)
{
	U32 map_bpp=header.cmap_depth >> 3;
	U32 map_size=header.cmap_length * map_bpp;
	
	if (!seek(map_size))
		xxx_throw("XTgaFile::skip_color_map: Unable to seek past color map");

	return TRUE;
}

#if 0
XImageRef XLoadTGA(CC8 *Name,U32 format)
{
	CPathRef name=Name;
	XTgaImage image;

	if (!image.load(name,format))
		return null;

	return image.get_ref();
}

XImageRef XLoadTGADevice(CC8 *Name,ImgDevice *device,U32 format)
{
	CPathRef name=Name;

	return XLoadTGADevice(name,device,format);
}

XImageRef XLoadTGADevice(CPathRef &name,ImgDevice *device,U32 format)
{
	XTgaImage image(device);
	
	if (!image.load(name,format))
		return null;

	return image.get_ref();
}

U32 XTgaImage::load(CPathRef &name,U32 final_format)
{
	if (!file.open(name->get_path(),"r"))
	{
		xxx_bitch("XTgaFile::load: Unable to open file");
		return FALSE;
	}

	file >> header;

	src_format=find_tga_format();
	dst_format=final_format;

	if (!dst_format)
	{
		dst_format=src_format;
		if (device)
			dst_format=device->best_match(src_format);
	}

	switch (header.image_type)
	{
		case TGA_TRUE_COLOR:
			load_true_color();
			break;
		case TGA_NULL:
		case TGA_PALETTE:
		case TGA_MONO:
		case TGA_RLE_PALETTE:
		case TGA_RLE_TRUE_COLOR:
		case TGA_RLE_MONO:
		default:
			xxx_bitch("XTgaImage::load: Unsupported TGA image type");
			return FALSE;
	}

	if (src_format!=dst_format)
	{
		ImgConvert_f convert;
		U32 bpp;

		switch(dst_format)
		{
			case IMG_FORMAT_ARGB_4444:
				bpp=16;
				convert=ImgConvertTrueTo4444;
				break;
			case IMG_FORMAT_RGB_565:
				bpp=16;
				convert=ImgConvertTrueTo565;
				break;
			default:
				xxx_bitch("XTgaFile::load: Unsupported conversion");
				return FALSE;
		}

		XImageRef dst=new XImage(header.img_width,header.img_height,dst_format);
		convert(dst.get_ptr(),image.get_ptr());
		/* replace(and release) image with destination */
		image=dst;
	}

	return TRUE;
}

U32 XTgaImage::find_tga_format(void)
{
	switch (header.image_type)
	{
		case TGA_TRUE_COLOR:
			return true_color_format();
		case TGA_NULL:
		case TGA_PALETTE:
		case TGA_MONO:
		case TGA_RLE_PALETTE:
		case TGA_RLE_TRUE_COLOR:
		case TGA_RLE_MONO:
		default:
			return IMG_FORMAT_INVALID;
	}
	return IMG_FORMAT_INVALID;
}

U32 XTgaImage::true_color_format(void)
{
	switch(header.pixel_depth)
	{
		case 24:
			return IMG_FORMAT_RGB_888;
		case 32:
			return IMG_FORMAT_ARGB_8888;
		case 15:
			return IMG_FORMAT_ARGB_1555;
		case 16:
			return IMG_FORMAT_RGB_565;
		default:
			xxx_bitch("XTgaFile::true_color_format: Unsupported pixel depth");
			return FALSE;
	}
}

U32 XTgaImage::load_true_color(void)
{
	skip_color_map();

	switch(header.pixel_depth)
	{
		case 24:
			load_rgb24();
			break;
		case 32:
			load_rgb32();
			break;
		case 15:
		case 16:
		default:
			xxx_bitch("XTgaFile::load_true_color: Unsupported pixel depth");
			return FALSE;
	}
	return TRUE;
}

U32 XTgaImage::load_rgb24(void)
{
	U32 tmp_flag=0;
	
	/* if we are going to have to convert alloc tmp memory */
	if (src_format!=dst_format)
		tmp_flag=TMP_MEMORY;
		
	image=new XImage(header.img_width,header.img_height,IMG_FORMAT_ARGB_8888,tmp_flag);

	U32 image_size=(header.img_width * 3) * header.img_height;
	U32 num_read;
	char *data=image->get_data();
	
	if (!file.read(data,image_size,num_read))
		xxx_throw(ERROR_IMPORTANT,"XTgaImage::load_rgb24: Read failed in load");

	/* close out file, should have everything we need */
	file.close();
	
	/* convert 24 -> 32 */
	/* inflate in existing data buffer */
	U8 *src=(U8 *)(data+num_read-3);
	U32 *dst=(U32 *)(data + image->get_size());
	U32 i,num_pixels=image->get_num_pixels();
	dst--;
	for (i=0;i<num_pixels;i++)
	{
		*dst--=((U32 *)src)[0] & 0x00FFFFFF;
		src-=3;
	}

	/* adjust flip sanity */
	U32 flip=(header.img_desc ^ 0x20);
	if (flip & 0x30)
	{
		flip_image((U32 *)data,
					header.img_width,
					header.img_height,
					flip & 0x10,
					flip & 0x20);
	}
	return TRUE;
}

U32 XTgaImage::load_rgb32(void)
{
	U32 tmp_flag=0;
	
	/* if we are going to have to convert alloc tmp memory */
	if (src_format!=dst_format)
		tmp_flag=TMP_MEMORY;
		
	image=new XImage(header.img_width,header.img_height,IMG_FORMAT_ARGB_8888,tmp_flag);

	char *data=image->get_data();

	U32 image_size=(header.img_width * 4) * header.img_height;
	U32 num_read;
	if (!file.read(data,image_size,num_read))
		xxx_throw(ERROR_IMPORTANT,"XTgaImage::load_rgb32: Read failed in load");

	/* adjust flip sanity */
	U32 flip=(header.img_desc ^ 0x20);
	if (flip & 0x30)
	{
		flip_image((U32 *)data,
					header.img_width,
					header.img_height,
					flip & 0x10,
					flip & 0x20);
	}

	/* close out file, should have everything we need */
	file.close();

	return TRUE;
}
#endif