#ifndef _XBMP_H_
#define _XBMP_H_

namespace NS_BMP
{
	enum bmp_comp_enums
	{
		BMP_COMP_RGB        =0,
		BMP_COMP_RLE8       =1,
		BMP_COMP_RLE4       =2,
		BMP_COMP_BITFIELDS  =3,
		BMP_COMP_JPEG       =4,
		BMP_COMP_PNG        =5
	};

	enum bmp_file_types
	{
		BMP_TYPE_INVALID	=0,
		BMP_PALETTIZED_1	=1,
		BMP_PALETTIZED_4	=2,
		BMP_PALETTIZED_8	=3,
		BMP_TYPE_TRUE_24	=4,
	};

	typedef struct
	{
		I32	xyzX;
		I32	xyzY;
		I32	xyzZ;
	}ImgCIEXYZ;

	typedef struct
	{
		ImgCIEXYZ	red;
		ImgCIEXYZ	green;
		ImgCIEXYZ	blue;
	}ImgCIEXYZTriple;

#pragma pack(push,1)
	typedef struct
	{
        U16		bfType;
        U32		bfSize;
        U16		bfReserved1;
        U16		bfReserved2;
        U32		bfOffBits;
	}BmpFileHeader;

	typedef struct
	{
		U32		bSize;
		I32		bWidth; 
		I32		bHeight; 
		U16		bPlanes; 
		U16		bBitCount; 
	}BmpHeaderCore;

	typedef struct
	{
		U32		bSize;
		I32		bWidth; 
		I32		bHeight; 
		U16		bPlanes; 
		U16		bBitCount; 
		U32		bCompression; 
		U32		bSizeImage; 
		I32		bXPelsPerMeter; 
		I32		bYPelsPerMeter; 
		U32		bClrUsed; 
		U32		bClrImportant; 
	}BmpHeader;

	typedef struct
	{
		U32		bSize;
		I32		bWidth; 
		I32		bHeight; 
		U16		bPlanes; 
		U16		bBitCount; 
		U32		bCompression; 
		U32		bSizeImage; 
		I32		bXPelsPerMeter; 
		I32		bYPelsPerMeter; 
		U32		bClrUsed; 
		U32		bClrImportant; 
		U32		bRedMask; 
		U32		bGreenMask; 
		U32		bBlueMask; 
		U32		bAlphaMask; 
		U32		bCSType; 
		ImgCIEXYZTriple bEndpoints; 
		U32		bGammaRed; 
		U32		bGammaGreen; 
		U32		bGammaBlue; 
		U32		bIntent; 
	}BmpHeader4;

	typedef struct
	{
		U32		bSize;
		I32		bWidth; 
		I32		bHeight; 
		U16		bPlanes; 
		U16		bBitCount; 
		U32		bCompression; 
		U32		bSizeImage; 
		I32		bXPelsPerMeter; 
		I32		bYPelsPerMeter; 
		U32		bClrUsed; 
		U32		bClrImportant; 
		U32		bRedMask; 
		U32		bGreenMask; 
		U32		bBlueMask; 
		U32		bAlphaMask; 
		U32		bCSType; 
		ImgCIEXYZTriple bEndpoints;
		U32		bGammaRed; 
		U32		bGammaGreen; 
		U32		bGammaBlue; 
		U32		bIntent; 
		U32		bProfileData; 
		U32		bProfileSize; 
		U32		bReserved; 
	}BmpHeader5;

#pragma pack(pop)

	class XBmpFile : public XFile
	{
		BmpFileHeader	file_header;
		BmpHeader5		header;

		U32				bmp_format;

		U32				src_format;
		U32				dst_format;
		
		autoptr<XImage>	image;
		
		char			*src_ptr;
		char			*dst_ptr;

		U32 read_header(void);
		U32 set_bmp_format(void);

		U32 load_indexed8(void);
		U32 load_rgb24(void);

	public:
		XImage *load_device_image(ImgDevice *device,U32 format);
		CBaseStream & operator >> (BmpFileHeader &dst);
	};
}

#endif /* ifndef _XBMP_H_ */