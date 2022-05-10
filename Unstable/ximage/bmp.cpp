#include "ximage.h"
#include "xbmp.h"

using namespace NS_BMP;

XImage *XLoadBMPDevice(CC8 *name,ImgDevice *device,U32 format)
{
	XBmpFile file;

	if (!file.open(name,"r"))
		return null;

	return file.load_device_image(device,format);
}

CBaseStream &XBmpFile::operator >> (BmpFileHeader &dst)
{
	U32 num_read;
	
	if (!read(&dst,sizeof(BmpFileHeader),num_read))
		xxx_throw("XBmpFile: read failed");
	
	return *this;
}

U32 XBmpFile::read_header(void)
{
	U32 num_read;

	/* findout how much of the header is there */
	if (!read(&header.bSize,sizeof(U32),num_read))
		xxx_throw("XBmpFile::read_header: read failed on header");

	/* read in the rest of the header */
	if (!read(&header.bWidth,header.bSize - sizeof(U32),num_read))
		xxx_throw("XBmpFile::read_header: read failed on header");

	return TRUE;
}

U32 XBmpFile::set_bmp_format(void)
{
	bmp_format=BMP_TYPE_INVALID;
	if (header.bSize==sizeof(BmpHeaderCore))
	{
		switch(header.bBitCount)
		{
			case 1:
				bmp_format=BMP_PALETTIZED_1;
				return IMG_FORMAT_INVALID;
			case 4:
				bmp_format=BMP_PALETTIZED_4;
				return IMG_FORMAT_INVALID;
			case 8:
				bmp_format=BMP_PALETTIZED_8;
				return IMG_FORMAT_P8;
			default:
				xxx_throw("XBmpFile::find_bmp_format: bad number of bits");
		}
	}
	else if (header.bSize>sizeof(BmpHeaderCore))
	{
		if ((header.bSize!=sizeof(BmpHeader)) && (header.bSize!=sizeof(BmpHeader4)) && (header.bSize!=sizeof(BmpHeader5)))
			xxx_bitch("Bitmap format is unexpectedly large, new type of bitmap?");
	}
	else
		xxx_throw("XBmpFile::find_bmp_format: improper bitmap format");

	switch(header.bCompression)
	{
		case BMP_COMP_RGB:
			if (header.bBitCount==24)
			{
				bmp_format=BMP_TYPE_TRUE_24;
				return IMG_FORMAT_RGB_888;
			}
			else if (header.bBitCount==8)
			{
				/* probably palettized */
				bmp_format=BMP_PALETTIZED_8;
				return IMG_FORMAT_P8;
			}
			return IMG_FORMAT_INVALID;
		case BMP_COMP_RLE8:
			return IMG_FORMAT_INVALID;
		case BMP_COMP_RLE4:
			return IMG_FORMAT_INVALID;
		case BMP_COMP_BITFIELDS:
			return IMG_FORMAT_INVALID;
		case BMP_COMP_JPEG:
			return IMG_FORMAT_INVALID;
		case BMP_COMP_PNG:
			return IMG_FORMAT_INVALID;
		default:
			return IMG_FORMAT_INVALID;
	}
	return IMG_FORMAT_INVALID;
}

XImage *XBmpFile::load_device_image(ImgDevice *device,U32 format)
{
	if (!load_in_memory())
		return null;

	*this >> file_header;

	if (file_header.bfType != 0x4D42) // "BM"
	{
		xxx_bitch("XBmpFile::load_device_image: file type is incorrect");
		return null;
	}

	/* read in the bitmap header cause it is a little funky depending on type */
	read_header();

	src_format=set_bmp_format();
	dst_format=format;

	if (!dst_format)
	{
		dst_format=src_format;
		if (device)
			dst_format=device->best_match(src_format);
	}
	
	image=new XImage(header.bWidth,header.bHeight,dst_format);

	switch(bmp_format)
	{
		case BMP_PALETTIZED_8:
			load_indexed8();
			break;
		case BMP_TYPE_TRUE_24:
			load_rgb24();
			break;
		default:
			xxx_bitch("Unable to load this type of bitmap");
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

		convert(image->get_data(),src_ptr,header.bWidth,header.bHeight);
	}

	return image.release();
}

U32 XBmpFile::load_indexed8(void)
{
	xxx_fatal("XBmpFile::load_indexed8: Yeah, well I'm busy.");
	return TRUE;
}

U32 XBmpFile::load_rgb24(void)
{
	U32 tmp_flag=0;
	
	/* if we are going to have to convert alloc tmp memory */
	if (src_format!=dst_format)
		tmp_flag=TRUE;
		
	U32 image_size=(header.bWidth * 3) * header.bHeight;
	U32 num_read, dst_size;

	dst_size=header.bWidth * 4 * header.bHeight;
	
	char *data;
	if (!tmp_flag)
		data=image->get_data();
	else
		data=src_ptr=_ximg.get_conv_mem(dst_size);

	/* seek to image data */
	seek(file_header.bfOffBits - header.bSize - sizeof(BmpFileHeader));

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
	/* bmp's by nature seem to be flipped */
	flip_image((U32 *)data,
				header.bWidth,
				header.bHeight,
				FALSE,
				TRUE);

	return TRUE;
}

#if 0
// Texture management
VidTex *VID_TexLoadBMP(CC8 *filename, boolean fatal)
{
	GVidTex *tex;
	bmpimg_t bmpInfo;
	int i, k;
	int val, wval, r, g, b;

	if (!OpenBMP(filename, &bmpInfo))
	{
		if (fatal)
			sys.Error("Unable to load %s\n", filename);
		return(NULL);
	}
	tex=new GVidTex(sys.GetFileRoot(filename),bmpInfo.width,bmpInfo.height,IMG_FORMAT_ARGB_1555);
	U16 *tex16=(U16 *)tex->tex_data;
	for (i=0;i<(int)tex->height;i++)
	{
		for (k=0;k<(int)tex->width;k++)
		{
			val = *((int *)((U8 *)bmpInfo.imagedata+((tex->height-i-1)*bmpInfo.width+k)*3));
			r = (val >> 16) & 255; g = (val >> 8) & 255; b = val & 255;
			r >>= 3; g >>= 3; b >>= 3;
			wval = (r << 10) + (g << 5) + b + 0x8000;
			tex16[i*tex->width+k] = wval;
		}
	}
	FreeBMP(&bmpInfo);
#if 0
	if (_stricmp(tex->name,"but_blist")==0)
		delete tex;
#endif
	return(tex);
}

static int OpenBMP(CC8 *filename, bmpimg_t *bInfo)
{
	BITMAPFILEHEADER fhdr;
	char filebuf[_MAX_PATH];
	
	bInfo->totaldata = NULL;
	
	strcpy(filebuf, filename);
	
	sys.ForceFileExtention(filebuf, "BMP");
	
	FILE *fp = fopen(filebuf, "rb");
	if (!fp)
		return(0);
	
	SafeRead(&fhdr, sizeof(BITMAPFILEHEADER), 1, fp);	
	if (fhdr.bfType != 0x4D42) // "BM"
	{
		fclose(fp);
		return(0);
	}
	bInfo->totaldata = ALLOC(char, fhdr.bfSize-sizeof(BITMAPFILEHEADER));
	SafeRead(bInfo->totaldata, 1, fhdr.bfSize-sizeof(BITMAPFILEHEADER), fp);
	bInfo->info = (BITMAPINFO *)bInfo->totaldata;
	bInfo->imagedata = (U8 *)bInfo->totaldata
		+ fhdr.bfOffBits - sizeof(BITMAPFILEHEADER);
	fclose(fp);
	
	bInfo->width = bInfo->info->bmiHeader.biWidth;
	bInfo->height = bInfo->info->bmiHeader.biHeight;
	bInfo->bitdepth = bInfo->info->bmiHeader.biBitCount;
	return(1);
}
#endif

