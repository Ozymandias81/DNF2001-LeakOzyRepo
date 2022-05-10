#include <xcore.h>
#include <stdlib.h>
#include <stdio.h>
#include <vid_main.h>
#include "vidglide.h"

#pragma intrinsic(memset)

GFont::GFont(void)
{
	/* nullify letter hash */
	memset(font_letter,0,256*sizeof(void *));
}

void GFont::add_letter(CC8 *letter,GVidTex *tex)
{
	D_ASSERT(letter);
	font_letter[*letter]=tex;

	font_list.add_head(tex);
}

U32 VGlideDll::load_font(CC8 *filename,U32 fatal)
{
	if (font)
		delete font;

	font=new GFont;

	return font->load(filename,fatal);
}

U32 GFont::load(CC8 *filename,U32 fatal)
{
	gbaheader_t hdr;
	FILE *fp;

	if (name)
		delete name;

	name=CStr(filename);

	fp = fopen(filename, "rb");
	if (!fp)
	{
		if (fatal)
			sys.Error("VID_TexLoadGBAFont: File not found");
		return(FALSE);
	}
	SafeRead(&hdr, sizeof(gbaheader_t), 1, fp);
	if ((hdr.marker[0] != 'A') || (hdr.marker[1] != 'G') || (hdr.marker[2] != 'B') || (hdr.marker[3] != 'A'))
	{
		if (fatal)
			sys.Error("VID_TexLoadGBAFont: Invalid GBA file");
		return(FALSE);
	}
	if ((hdr.versionMajor != 1) || (hdr.versionMinor != 0))
	{
		if (fatal)
			sys.Error("VID_TexLoadGBAFont: Invalid GBA version");
		return(FALSE);
	}

	I32 i,k,m;
	for (i=0;i<hdr.numFrames;i++)
	{
		gbaframeentry_t entry;
		gbaframe_t frame;
		GVidTex *tex;

		fseek(fp, sizeof(gbaheader_t) + i*sizeof(gbaframeentry_t), SEEK_SET);
		SafeRead(&entry, sizeof(gbaframeentry_t), 1, fp);		
		fseek(fp, entry.frameOfs, SEEK_SET);
		SafeRead(&frame, sizeof(gbaframe_t), 1, fp);
		//tex = AllocVidtex();
		tex=new GVidTex(null,8,8,IMG_FORMAT_ARGB_1555);
		add_letter(entry.frameName,tex);
		vid.charDrawable[entry.frameName[0]] = 1;
		/* blacken it out */
		memset(tex->tex_data,0,tex->width * tex->height * tex->bpp);
		/* set font in tex */
		U16 *tex16=(U16 *)tex->tex_data;
		for (k=0;k<FONTDATA_HEIGHT;k++)
		{
			for (m=0;m<FONTDATA_WIDTH;m++)
			{
				if (frame.data[k][m])
					tex16[k*tex->width+m] = (16<<10)+(16<<5)+16;
			}
		}
	}
	fclose(fp);
	return(1);
}

GVidTex *GFont::get_tex(U8 letter)
{
	GVidTex *tex;

	if (tex=font_letter[letter])
		return tex;
	
	tex=(GVidTex *)*vid.blankTex;
	return tex;
}

int VID_TexLoadGBAFont(CC8 *filename,U8 fatal)
{
	return _vg_dll.load_font(filename,fatal);
}

