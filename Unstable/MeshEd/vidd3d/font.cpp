#include "stdd3d.h"

XFont::XFont(XImage *image) : VidTexD3D(null,image)
{
	width=6.0f/256.0f;
	height=6.0f/256.0f;
}

void VidD3D::init_font(void)
{
	FontFile file;

	if (!file.open("resource\\fontdata.gba","r"))
		xxx_fatal("Unable to find required resource: resource\\fontdata.gba");

	font=file.load_font();
	tex_list.add_head(font);
}

void VidD3D::SetFontTexture(void)
{
	TexActivate(font,VTA_NORMAL);
}

void VidD3D::get_fontdim(float *lwidth,float *lheight)
{
	font->get_pitch(lwidth,lheight);
}

void VidD3D::get_fontletter(char key,float *s,float *t)
{
	font->get_letter(key,s,t);
}

XFont *FontFile::load_font(void)
{
	using namespace NS_XFILE;
	U32 num_read;

	if (!read(&header,sizeof(gbaheader_t),num_read))
		xxx_throw("FontFile::load_image: Invalid header");

	if ((header.marker[0] != 'A') || (header.marker[1] != 'G') || (header.marker[2] != 'B') || (header.marker[3] != 'A'))
		xxx_throw("FontFile::load_image: Invalid marker");

	if ((header.versionMajor != 1) || (header.versionMinor != 0))
		xxx_throw("FontFile::load_image: Invalid version");

	if (header.numFrames>256)
		xxx_throw("FontFile::load_image: Containes too many frames");

	image=new XImage(256,256,IMG_FORMAT_ARGB_1555);
	font=new XFont(image);

	/* blacken it */
	memset(image->get_data(),0,image->get_width()*image->get_height()*image->get_bpp());

	U32 slot_x,slot_y;
	U32 i,j,k;
	U32 width=image->get_width();
	U32 height=image->get_height();

	slot_x=slot_y=0;
	U16 *tex16=(U16 *)image->get_data();
	for (i=0;i<(U32)header.numFrames;i++)
	{
		gbaframeentry_t entry;
		gbaframe_t frame;

		seek(sizeof(gbaheader_t) + i*sizeof(gbaframeentry_t),FILE_SEEK_SET);
		if (!read(&entry,sizeof(gbaframeentry_t),num_read))
			xxx_throw("FontFile::load_image: read error");
		seek(entry.frameOfs,FILE_SEEK_SET);
		if (!read(&frame,sizeof(gbaframe_t),num_read))
			xxx_throw("FontFile::load_image: read error");

		font->set_letter(entry.frameName[0],slot_x*8,slot_y*8);
		
		tex16=((U16 *)image->get_data()) + slot_y*width*8 + slot_x*8;
		for (j=0;j<FONTDATA_HEIGHT;j++)
		{
			for (k=0;k<FONTDATA_WIDTH;k++)
			{
				if (frame.data[j][k])
					tex16[j*width + k]=0x8000 | (31<<10) | (31<<5) | 31;
			}
		}
		slot_x+=1;
		if (slot_x&0x8)
			slot_y++;
		slot_x&=0x7;
	}

	/* set space */
	if (!font->is_drawable(' '))
		font->set_letter(' ',slot_x*8,slot_y*8);
	
	return font.release();
}