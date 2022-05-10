#include "stdd3d.h"

#define REND_DEBUG

volatile U32 _deb_rend=FALSE;

#ifdef REND_DEBUG
#define REND_POLY_BEGIN() rend_begin_debug()
#define REND_POLY_END()   rend_end_debug()
#else
#define REND_POLY_BEGIN()
#define REND_POLY_END()
#endif

volatile U32 _deb_val=0;


ViewD3D::ViewD3D(XWnd *Wnd,IDirect3DDevice8 *Dev,U32 Width,U32 Height,U32 Bpp) : VidView(Width,Height,Bpp)
{
	wnd=Wnd;
	dev=Dev;
}

U32 VidD3D::Swap(U32 wait)
{
	dev->Present(null,null,null,null);
	return TRUE;
}

void VidD3D::ClearScreen(U32 color)
{
	U32 ret;

	D3DRECT rect;

	rect.x1=vid_state.clip_x;
	rect.y1=vid_state.clip_y;
	rect.x2=rect.x1 + vid_state.clip_width;
	rect.y2=rect.y1 + vid_state.clip_height;

	float clear_far=1.0f;
#if 0
	if (!vid_state.support_wbuffer)
		clear_far=1.0f;
#endif

	if (vid_state.has_stencil)
	{
		ret=dev->Clear(1,&rect,
					   D3DCLEAR_STENCIL|D3DCLEAR_TARGET|D3DCLEAR_ZBUFFER,
					   color,clear_far,0);
	}
	else
	{
		ret=dev->Clear(1,&rect,
					   D3DCLEAR_TARGET|D3DCLEAR_ZBUFFER,
					   color,clear_far,0);
	}
	if (ret!=D3D_OK)
		xxx_fatal("VidD3D::ClearScreen: failed");
}

void VidD3D::ClipWindow(U32 x,U32 y,U32 x2,U32 y2)
{
	D_ASSERT(dev);

	D3DVIEWPORT8 viewport;

	if ((I32)x<0)
		x=0;
	if ((I32)y<0)
		y=0;
	if (x2>res.width)
		x2=res.width;
	if (y2>res.height)
		y2=res.height;

	D_ASSERT((((I32)y2) - ((I32)y))>=0);

	viewport.X=x;
	viewport.Y=y;
	viewport.Width=x2 - x;
	viewport.Height=y2 -y;
	viewport.MinZ=0.0;
	viewport.MaxZ=1.0f;

	vbuffers->flush();

	dev->SetViewport(&viewport);

	vid_state.clip_x=(U16)x;
	vid_state.clip_width=(U16)(x2 - x);
	vid_state.clip_y=(U16)y;
	vid_state.clip_height=(U16)(y2 - y);

	_deb_clip_x=(float)vid_state.clip_x;
	_deb_clip_y=(float)vid_state.clip_y;
	_deb_clip_width=(float)vid_state.clip_width;
	_deb_clip_height=(float)vid_state.clip_height;
}

void VidD3D::SetClipBounds(U32 x,U32 y,U32 x2,U32 y2)
{
	_deb_clip_x=(float)vid_state.clip_x;
	_deb_clip_y=(float)vid_state.clip_y;
	_deb_clip_width=(float)vid_state.clip_width;
	_deb_clip_height=(float)vid_state.clip_height;
}

void VidD3D::ColorWrite(U8 enable)
{
	D_ASSERT(((enable==0)||(enable==1)));
	D_ASSERT(dev);

	vbuffers->flush();

	if (enable)
		dev->SetRenderState(D3DRS_COLORWRITEENABLE,D3DCOLORWRITEENABLE_RED|D3DCOLORWRITEENABLE_GREEN|D3DCOLORWRITEENABLE_BLUE);
	else
		dev->SetRenderState(D3DRS_COLORWRITEENABLE,0);

	vid_state.color_write=enable;
}

void VidD3D::DepthWrite(U8 enable)
{
	D_ASSERT(((enable==0)||(enable==1)));
	D_ASSERT(dev);

	vbuffers->flush();

	dev->SetRenderState(D3DRS_ZWRITEENABLE,enable);
	vid_state.depth_write=enable;
}

void VidD3D::FlatColor(U8 r,U8 g,U8 b)
{
	vid_state.color_r=r;
	vid_state.color_g=g;
	vid_state.color_b=b;
}

void VidD3D::FlatAlpha(U8 a)
{
	vid_state.color_a=a;
}

U8 VidD3D::AlphaTestValue(U8 a)
{
	D_ASSERT(dev);
	
	vbuffers->flush();

	U8 ret=vid_state.alpha_test_val;
	vid_state.alpha_test_val=a;
	dev->SetRenderState(D3DRS_ALPHAREF,a);

	return ret;
}

vidcolormodetype_t VidD3D::ColorMode(vidcolormodetype_t vcmtype)
{
	D_ASSERT(dev);

	vidcolormodetype_t ret=(vidcolormodetype_t)vid_state.color_mode;

#if 0
	if (vcmtype==ret)
		return ret;
#endif

	vbuffers->flush();

	switch(vcmtype)
	{
		case VCM_FLAT:
			d3d_state.color_op0=D3DTOP_SELECTARG1;
			d3d_state.color1_arg0=D3DTA_DIFFUSE;
			d3d_state.color2_arg0=D3DTA_DIFFUSE;
			vid_state.flat_shade=TRUE;
			break;
		case VCM_GOURAUD:
			d3d_state.color_op0=D3DTOP_SELECTARG1;
			d3d_state.color1_arg0=D3DTA_DIFFUSE;
			d3d_state.color2_arg0=D3DTA_DIFFUSE;
			vid_state.flat_shade=FALSE;
			break;
		case VCM_TEXTURE:
			d3d_state.color_op0=D3DTOP_SELECTARG2;
			d3d_state.color1_arg0=D3DTA_DIFFUSE;
			d3d_state.color2_arg0=D3DTA_TEXTURE;
			break;
		case VCM_FLATTEXTURE:
			d3d_state.color_op0=D3DTOP_MODULATE;
			d3d_state.color1_arg0=D3DTA_DIFFUSE;
			d3d_state.color2_arg0=D3DTA_TEXTURE;
			vid_state.flat_shade=TRUE;
			break;
		case VCM_GOURAUDTEXTURE:
			d3d_state.color_op0=D3DTOP_MODULATE;
			d3d_state.color1_arg0=D3DTA_DIFFUSE;
			d3d_state.color2_arg0=D3DTA_TEXTURE;
			vid_state.flat_shade=FALSE;
			break;
		default:
			xxx_fatal("VidD3D::ColorMode: bogus type");
			break;
	}
	
	if (dev->SetTextureStageState(0,D3DTSS_COLOROP,d3d_state.color_op0)!=D3D_OK)
		xxx_fatal("Texture stage failure");
	if (dev->SetTextureStageState(0,D3DTSS_COLORARG1,d3d_state.color1_arg0)!=D3D_OK)
		xxx_fatal("Texture stage failure");
	if (dev->SetTextureStageState(0,D3DTSS_COLORARG2,d3d_state.color2_arg0)!=D3D_OK)
		xxx_fatal("Texture stage failure");

	vid_state.color_mode=vcmtype;
	
	return ret;
}

vidalphamodetype_t VidD3D::AlphaMode(vidalphamodetype_t vamtype)
{
	D_ASSERT(dev);
	
	vidalphamodetype_t ret=(vidalphamodetype_t)vid_state.alpha_mode;

#if 0
	if (vamtype==ret)
		return ret;
#endif
	
	vbuffers->flush();

	switch(vamtype)
	{
		case VAM_FLAT:
			d3d_state.alpha_op0=D3DTOP_SELECTARG1;
			d3d_state.alpha1_arg0=D3DTA_DIFFUSE;
			d3d_state.alpha2_arg0=D3DTA_DIFFUSE;
			vid_state.flat_alpha=TRUE;
			break;
		case VAM_GOURAUD:
			d3d_state.alpha_op0=D3DTOP_SELECTARG1;
			d3d_state.alpha1_arg0=D3DTA_DIFFUSE;
			d3d_state.alpha2_arg0=D3DTA_DIFFUSE;
			vid_state.flat_alpha=FALSE;
			break;
		case VAM_TEXTURE:
			d3d_state.alpha_op0=D3DTOP_SELECTARG2;
			d3d_state.alpha1_arg0=D3DTA_DIFFUSE;
			d3d_state.alpha2_arg0=D3DTA_TEXTURE;
			break;
		case VAM_MODULATE_TEXTURE:
			d3d_state.alpha_op0=D3DTOP_MODULATE;
			d3d_state.alpha1_arg0=D3DTA_DIFFUSE;
			d3d_state.alpha2_arg0=D3DTA_TEXTURE;
			vid_state.flat_alpha=FALSE;
			break;
		default:
			xxx_fatal("VidD3D::AlphaMode: bogus type");
			break;
	}

	vid_state.alpha_mode=vamtype;
	dev->SetTextureStageState(0,D3DTSS_ALPHAOP,d3d_state.alpha_op0);
	dev->SetTextureStageState(0,D3DTSS_ALPHAARG1,d3d_state.alpha1_arg0);
	dev->SetTextureStageState(0,D3DTSS_ALPHAARG2,d3d_state.alpha2_arg0);

	return ret;
}

vidblendmodetype_t VidD3D::BlendMode(vidblendmodetype_t vbmtype)
{
	D_ASSERT(dev);

	vidblendmodetype_t ret=(vidblendmodetype_t)vid_state.blend_mode;

#if 0
	if (vbmtype==ret)
		return ret;
#endif

	vbuffers->flush();

	switch(vbmtype)
	{
		case VBM_OPAQUE:
			d3d_state.src_blend=D3DBLEND_ONE;
			d3d_state.dst_blend=D3DBLEND_ZERO;
			break;
		case VBM_OPAQUETOTAL:
			d3d_state.src_blend=D3DBLEND_ONE;
			d3d_state.dst_blend=D3DBLEND_ONE;
			break;
		case VBM_TRANS:
			d3d_state.src_blend=D3DBLEND_SRCALPHA;
			d3d_state.dst_blend=D3DBLEND_ZERO;
			break;
		case VBM_TRANSTOTAL:
			d3d_state.src_blend=D3DBLEND_SRCALPHA;
			d3d_state.dst_blend=D3DBLEND_ONE;
			break;
		case VBM_TRANSMERGE:
			d3d_state.src_blend=D3DBLEND_SRCALPHA;
			d3d_state.dst_blend=D3DBLEND_INVSRCALPHA;
			break;
		default:
			xxx_fatal("VidD3D::BlendMode: bogus type");
			break;
	}

	dev->SetRenderState(D3DRS_SRCBLEND,d3d_state.src_blend);
	dev->SetRenderState(D3DRS_DESTBLEND,d3d_state.dst_blend);

	vid_state.blend_mode=vbmtype;

	return ret;
}

vidwindingmodetype_t VidD3D::WindingMode(vidwindingmodetype_t vwmmode)
{
	D_ASSERT(dev);
	
	vbuffers->flush();

	vidwindingmodetype_t ret=(vidwindingmodetype_t)vid_state.cull_mode;
	dev->SetRenderState(D3DRS_CULLMODE,vwmmode);
	vid_state.cull_mode=vwmmode;
	return ret;
}

vidfiltermodetype_t VidD3D::MinFilterMode(vidfiltermodetype_t vfmmode)
{
	D_ASSERT(dev);
	
	vbuffers->flush();

	vidfiltermodetype_t ret=(vidfiltermodetype_t)vid_state.min_filter_mode;
	dev->SetTextureStageState(0,D3DTSS_MINFILTER,vfmmode);
	vid_state.min_filter_mode=vfmmode;
	return ret;
}

vidfiltermodetype_t VidD3D::MagFilterMode(vidfiltermodetype_t vfmmode)
{
	D_ASSERT(dev);
	
	vbuffers->flush();

	vidfiltermodetype_t ret=(vidfiltermodetype_t)vid_state.mag_filter_mode;
	dev->SetTextureStageState(0,D3DTSS_MAGFILTER,vfmmode);
	vid_state.mag_filter_mode=vfmmode;
	return ret;
}

vidatestmodetype_t VidD3D::AlphaTestMode(vidatestmodetype_t vatmode)
{
	D_ASSERT(dev);
	
	vbuffers->flush();

	vidatestmodetype_t ret=(vidatestmodetype_t)vid_state.alpha_test_mode;
	dev->SetRenderState(D3DRS_ALPHAFUNC,vatmode);
	vid_state.alpha_test_mode=vatmode;
	return ret;
}

U32 VidD3D::AlphaTestEnable(U32 enable)
{
	D_ASSERT(dev);

	vbuffers->flush();
	
	U32 ret=vid_state.alpha_test_enable;
	
	vid_state.alpha_test_enable=FALSE;
	if (enable)
		vid_state.alpha_test_enable=TRUE;
	dev->SetRenderState(D3DRS_ALPHATESTENABLE,vid_state.alpha_test_enable);

	return ret;
}

void VidD3D::ForceDraw(U8 enable)
{
	vid_state.force_draw=FALSE;
	if (enable)
		vid_state.force_draw=TRUE;
}

void VidD3D::Antialias(U8 enable)
{
	vid_state.antialias=FALSE;
	if (enable)
		vid_state.antialias=TRUE;
}

zfunc_modetype_t VidD3D::DepthFunc(zfunc_modetype_t zfunc)
{
	zfunc_modetype_t ret=(zfunc_modetype_t)vid_state.zfunc;
	dev->SetRenderState(D3DRS_ZFUNC,vid_state.zfunc);
	vid_state.zfunc=zfunc;

	return ret;
}

void VidD3D::DepthEnable(U8 enable)
{
	D_ASSERT(((enable==0)||(enable==1)));

#if 0
	if (vid_state.depth_enabled==enable)
		return;
#endif
	
	vbuffers->flush();

	vid_state.depth_enabled=TRUE;
	if (enable)
	{
		if (vid_state.support_wbuffer)
			dev->SetRenderState(D3DRS_ZENABLE,D3DZB_USEW);
		else
			dev->SetRenderState(D3DRS_ZENABLE,D3DZB_TRUE);
		dev->SetRenderState(D3DRS_ZFUNC,vid_state.zfunc);
	}
	else
	{
		dev->SetRenderState(D3DRS_ZFUNC,D3DCMP_ALWAYS);
		dev->SetRenderState(D3DRS_ZENABLE,D3DZB_FALSE);
		vid_state.depth_enabled=FALSE;
	}
}

static U32 poly_clear=0xFF;

__declspec(naked) void _clip_test_vector(vector_type *p)
{
	_asm
	{
		mov		eax,dword ptr[esp+4]
		fld		dword ptr[eax]
		fld		dword ptr[eax+4]
		fld		dword ptr[eax+8]
		fstp	st(0)
		fstp	st(0)
		fstp	st(0)
		ret
	}
}

__declspec(naked) void _clip_sanity_vector(vector_type *p)
{
	/* just check for bad float's */
	_asm
	{
		mov		eax,dword ptr[esp+4]
		fld		dword ptr[eax]
		fld		dword ptr[eax+4]
		fld		dword ptr[eax+8]
		fstp	st(0)
		fstp	st(0)
		fstp	st(0)
		ret
	}
}

float _deb_x=-50;
float _deb_y=-50;
float _deb_width=0.0f;
float _deb_height=0.0f;

U32 match_deb_coords(DxVertexT *v1,DxVertexT *v2,DxVertexT *v3)
{
	DxVertexT *v[3];

	v[0]=v1;
	v[1]=v2;
	v[2]=v3;

	for (U32 i=0;i<3;i++)
	{
		U32 fit=0;
		if (v[i]->x >= _deb_x)
			fit++;
		if (v[i]->y >= _deb_y)
			fit++;
		if (v[i]->x <= (_deb_x + _deb_width))
			fit++;
		if (v[i]->y <= (_deb_y + _deb_height))
			fit++;

		if (fit==4)
			return TRUE;
	}

	return FALSE;
}

U32 VidD3D::check_clip(DxVertexT *v1,DxVertexT *v2,DxVertexT *v3)
{
	if (!vid_state.clip_good)
		return FALSE;

	DxVertexT *v[3];

	v[0]=v1;
	v[1]=v2;
	v[2]=v3;

	for (U32 i=0;i<3;i++)
	{
		U32 fit=0;
		if (v[i]->x >= _deb_clip_x)
			fit++;
		if (v[i]->y >= _deb_clip_y)
			fit++;
		if (v[i]->x <= (_deb_clip_x + _deb_clip_width))
			fit++;
		if (v[i]->y <= (_deb_clip_y + _deb_clip_height))
			fit++;

		if (fit!=4)
			return TRUE;
	}

	return FALSE;
}

void VidD3D::DrawLine(vector_type *p1, vector_type *p2, vector_type *c1, vector_type *c2)
{
	vidcolormodetype_t old_mode;

	/* don't set state if in primitive batch */
	if (!vid_state.in_prim)
	{
		REND_POLY_BEGIN();

		old_mode=VCM_GOURAUD;
		if (vid_state.color_mode!=VCM_GOURAUD)
			old_mode=ColorMode(VCM_GOURAUD);
	}

	DxVertexT v1,v2;

	D_ASSERT(p1);D_ASSERT(p2);
		
	v1.x=p1->x;v1.y=p1->y;
	v2.x=p2->x;v2.y=p2->y;
	v1.z=v1.rhw=1.0f;
	v2.z=v2.rhw=1.0f;
	if (vid_state.depth_enabled)
	{
		v1.z=p1->z;
		v2.z=p2->z;
		v1.rhw=1.0f/v1.z;
		v2.rhw=1.0f/v2.z;
	}
	if ((!c1)||(!c2))
	{
		v1.color=GetColor();
		v2.color=v1.color;
	}
	else
	{
		v1.color=VEC_TO_1RGB(*c1);
		v2.color=VEC_TO_1RGB(*c2);
	}

	if (!vid_state.in_prim)
	{
		DxVertexT *space=begin_prim(PRIM_LINELIST,1*2);
		set_vert_adv(space,&v1);
		set_vert_adv(space,&v2);
		end_prim(space,1);
		
		if (old_mode!=VCM_GOURAUD)
			ColorMode(old_mode);
		REND_POLY_END();
	}
	else
	{
		set_vert_adv(prim_space,&v1);
		set_vert_adv(prim_space,&v2);
		prim_count++;
		D_ASSERT(prim_count<=prim_guess);
		/* see if we need to dump what we have */
		if (prim_count>=prim_guess)
			EndLines();
	}
}

void VidD3D::DrawLineBox(vector_type *p1, vector_type *p2, vector_type *c1, vector_type *c2)
{
	REND_POLY_BEGIN();

	vidcolormodetype_t old_mode;
	DxVertexT v1,v2,v3,v4;
	vector_type avg;

	D_ASSERT(p1);D_ASSERT(p2);

	old_mode=VCM_GOURAUD;
	if (vid_state.color_mode!=VCM_GOURAUD)
		old_mode=ColorMode(VCM_GOURAUD);

	if ((!c1)||(!c2))
	{
		v1.color=GetColor();
		v2.color=v1.color;
		v3.color=v1.color;
		v4.color=v1.color;
	}
	else
	{
		v1.color=VEC_TO_1RGB(*c1);
		v2.color=VEC_TO_1RGB(*c2);
		avg.x=(c1->x+c2->x)/2.0f;
		avg.y=(c1->y+c2->y)/2.0f;
		avg.z=(c1->z+c2->z)/2.0f;
		v3.color=VEC_TO_1RGB(avg);
		v4.color=v3.color;
	}

	v1.z = v1.rhw = v2.z = v2.rhw = v3.z = v3.rhw = v4.z = v4.rhw = 1.0f;
	if (vid_state.depth_enabled)
	{
		v1.z = p1->z; v1.rhw = 1.0f / v1.z;
		v2.z = p2->z; v2.rhw = 1.0f / v2.z;
		v3.z = v4.z = (p1->z+p2->z)/2.0f; v3.rhw = v4.rhw = 1.0f / v3.z;
	}

	v1.x=p1->x;
	v1.y=p1->y;
	v2.x=p1->x;
	v2.y=p2->y;
	v3.x=p2->x;
	v3.y=p2->y;
	v4.x=p2->x;
	v4.y=p1->y;

	DxVertexT *space=begin_prim(PRIM_LINELIST,4*2);
	set_vert_adv(space,&v1);
	set_vert_adv(space,&v4);
	set_vert_adv(space,&v4);
	set_vert_adv(space,&v3);
	set_vert_adv(space,&v3);
	set_vert_adv(space,&v2);
	set_vert_adv(space,&v2);
	set_vert_adv(space,&v1);
	end_prim(space,4);

	if (old_mode!=VCM_GOURAUD)
		ColorMode(old_mode);

	REND_POLY_END();
}

void VidD3D::DrawTriangle(vector_type *p, vector_type *c, float *a, vector_type *tv)
{
	REND_POLY_BEGIN();

	DxVertexT verts[3];
	U32 i;

	if (c)
	{
		for(i=0;i<3;i++)
			verts[i].color=VEC_TO_0RGB(c[i]);
	}
	else
	{
		U32 flat_color=GetColor();
		
		if (vid_state.color_mode!=VCM_FLAT)
			flat_color=0x00FFFFFF;

		for(i=0;i<3;i++)
			verts[i].color=flat_color;
	}
	if (a)
	{
		for(i=0;i<3;i++)
			verts[i].color|=FLOAT_A_TO_A(a[i]);
	}
	else
	{
		U32 flat_alpha=GetColor() & 0xFF000000;

		if (vid_state.alpha_mode!=VAM_FLAT)
			flat_alpha=0xFF000000;

		for(i=0;i<3;i++)
			verts[i].color|=flat_alpha;
	}
	if (tv)
	{
		/* uber hack to get around glide'isms */
		/* need to convert tex coords from glide format to d3d's */
		float mod_s,mod_t;

		mod_s=1.0f;
		mod_t=1.0f;

		if (active_tex)
		{
			/* if s major */
			if (active_tex->width >= active_tex->height)
			{
				mod_t*=(float)(active_tex->width/active_tex->height);
			}
			else /* if t major */
			{
				mod_s*=(float)(active_tex->height/active_tex->width);
			}
		}
		mod_s*=1.0f/255.0f;
		mod_t*=1.0f/255.0f;
		for(i=0;i<3;i++)
		{
			verts[i].s=tv[i].x*mod_s;
			verts[i].t=tv[i].y*mod_t;
		}
	}
	for (i=0;i<3;i++)
	{
		verts[i].x=p[i].x;
		verts[i].y=p[i].y;
		verts[i].z=verts[i].rhw=1.0f;
	}
	if (vid_state.depth_enabled)
	{
		for (i=0;i<3;i++)
		{
			verts[i].z=p[i].z;
			verts[i].rhw = 1.0f / verts[i].z;
		}
	}
	DxVertexT *space=begin_prim(PRIM_TRIANGLELIST,3);
	set_vert_adv(space,&verts[0]);
	set_vert_adv(space,&verts[1]);
	set_vert_adv(space,&verts[2]);
	end_prim(space,1);

	REND_POLY_END();
}

/* we don't have to convert these vertices */
void VidD3D::draw_polygon(U32 num_verts,CVert *verts)
{
	U32 num_tris=(num_verts-2);
	DxVertexT *space=begin_prim(PRIM_TRIANGLELIST,num_tris*3);
	for (U32 i=0;i<num_tris;i++)
	{
		set_vert_adv(space,(DxVertexT *)&verts[0]);
		set_vert_adv(space,(DxVertexT *)&verts[i+1]);
		set_vert_adv(space,(DxVertexT *)&verts[i+2]);
	}
	end_prim(space,num_tris);
}

void VidD3D::DrawClippedPolygon(U32 numverts, vector_type *p, vector_type *c, float *a, vector_type *tv)
{
	REND_POLY_BEGIN();

	D_ASSERT(numverts<16);

	DxVertexT verts[16];
	U32 i;

	if (c)
	{
		for(i=0;i<numverts;i++)
			verts[i].color=VEC_TO_0RGB(c[i]);
	}
	else
	{
		U32 flat_color=GetColor();
		
		if (vid_state.color_mode!=VCM_FLAT)
			flat_color=0x00FFFFFF;

		for(i=0;i<numverts;i++)
			verts[i].color=flat_color;
	}
	if (a)
	{
		for(i=0;i<numverts;i++)
			verts[i].color|=FLOAT_A_TO_A(a[i]);
	}
	else
	{
		U32 flat_alpha=GetColor() & 0xFF000000;

		if (vid_state.alpha_mode!=VAM_FLAT)
			flat_alpha=0xFF000000;

		for(i=0;i<numverts;i++)
			verts[i].color|=flat_alpha;
	}
	if (tv)
	{
		/* uber hack to get around glide'isms */
		/* need to convert tex coords from glide format to d3d's */
		float mod_s,mod_t;

		mod_s=1.0f;
		mod_t=1.0f;

		if (active_tex)
		{
			/* if s major */
			if (active_tex->width >= active_tex->height)
			{
				mod_t*=(float)(active_tex->width/active_tex->height);
			}
			else /* if t major */
			{
				mod_s*=(float)(active_tex->height/active_tex->width);
			}
		}
		mod_s*=1.0f/255.0f;
		mod_t*=1.0f/255.0f;
		for(i=0;i<numverts;i++)
		{
			verts[i].s=tv[i].x*mod_s;
			verts[i].t=tv[i].y*mod_t;
		}
	}
	for (i=0;i<numverts;i++)
	{
		verts[i].x=p[i].x;
		verts[i].y=p[i].y;
		verts[i].z=verts[i].rhw=1.0f;
	}
	if (vid_state.depth_enabled)
	{
		for (i=0;i<numverts;i++)
		{
			//verts[i].z=((p[i].z)+0.5f) * (65535.0f/1024.5f);
			verts[i].z=p[i].z;
			verts[i].rhw = 1.0f / verts[i].z;
			if ((p[i].z < 0.5f) || (p[i].z > 1024.0f))
				_deb_val++;
		}
	}

	U32 num_tris=(numverts-2);
	DxVertexT *space=begin_prim(PRIM_TRIANGLELIST,num_tris*3);
	for (i=0;i<num_tris;i++)
	{
		set_vert_adv(space,&verts[0]);
		set_vert_adv(space,&verts[i+1]);
		set_vert_adv(space,&verts[i+2]);
	}
	end_prim(space,num_tris);
	D_ASSERT(((I32)num_tris > 0));

	REND_POLY_END();
}

void VidD3D::DrawPolygon(U32 numverts, vector_type *p, vector_type *c, float *a, vector_type *tv)
{
	REND_POLY_BEGIN();

	D_ASSERT(numverts<16);

	DxVertexT verts[16];
	U32 i;

	if (c)
	{
		for(i=0;i<numverts;i++)
			verts[i].color=VEC_TO_0RGB(c[i]);
	}
	else
	{
		U32 flat_color=GetColor();
		
		if (vid_state.color_mode!=VCM_FLAT)
			flat_color=0x00FFFFFF;

		for(i=0;i<numverts;i++)
			verts[i].color=flat_color;
	}
	if (a)
	{
		for(i=0;i<numverts;i++)
			verts[i].color|=FLOAT_A_TO_A(a[i]);
	}
	else
	{
		U32 flat_alpha=GetColor() & 0xFF000000;

		if (vid_state.alpha_mode!=VAM_FLAT)
			flat_alpha=0xFF000000;

		for(i=0;i<numverts;i++)
			verts[i].color|=flat_alpha;
	}
	if (tv)
	{
		/* uber hack to get around glide'isms */
		/* need to convert tex coords from glide format to d3d's */
		float mod_s,mod_t;

		mod_s=1.0f;
		mod_t=1.0f;

		if (active_tex)
		{
			/* if s major */
			if (active_tex->width >= active_tex->height)
			{
				mod_t*=(float)(active_tex->width/active_tex->height);
			}
			else /* if t major */
			{
				mod_s*=(float)(active_tex->height/active_tex->width);
			}
		}
		mod_s*=1.0f/255.0f;
		mod_t*=1.0f/255.0f;
		for(i=0;i<numverts;i++)
		{
			verts[i].s=tv[i].x*mod_s;
			verts[i].t=tv[i].y*mod_t;
		}
	}
	for (i=0;i<numverts;i++)
	{
		_clip_sanity_vector(&p[i]);

		verts[i].x=p[i].x;
		verts[i].y=p[i].y;
		verts[i].z=verts[i].rhw=1.0f;
	}
	if (vid_state.depth_enabled)
	{
		for (i=0;i<numverts;i++)
		{
			//verts[i].z=((p[i].z)+0.5f) * (65535.0f/1024.5f);
			verts[i].z=p[i].z;
			verts[i].rhw = 1.0f / verts[i].z;
			if ((p[i].z < 0.5f) || (p[i].z > 1024.0f))
				_deb_val++;
		}
	}

#if 1
	U32 num_tris=(numverts-2);
	DxVertexT *space=begin_prim(PRIM_TRIANGLELIST,num_tris*3);
	for (i=0;i<num_tris;i++)
	{
		set_vert_adv(space,&verts[0]);
		set_vert_adv(space,&verts[i+1]);
		set_vert_adv(space,&verts[i+2]);
	}
	end_prim(space,num_tris);
	D_ASSERT(((I32)num_tris > 0));
#else
	DxVertexT *space=begin_prim(PRIM_TRIANGLELIST,3);
	set_vert_adv(space,&verts[0]);
	set_vert_adv(space,&verts[1]);
	set_vert_adv(space,&verts[2]);
	end_prim(space,1);
#endif
	
	REND_POLY_END();
}

static U32 old_x,old_y,old_width,old_height;

void VidD3D::rend_begin_debug(void)
{
	if (_deb_rend)
	{
		old_x=vid_state.clip_x;
		old_y=vid_state.clip_y;
		old_width=vid_state.clip_width;
		old_height=vid_state.clip_height;

		ClipWindow(0,0,res.width,res.height);
		
		ClearScreen(0);
		poly_clear=_rotl(poly_clear,8);
	}
}

void VidD3D::rend_end_debug(void)
{
	if (_deb_rend)
	{
		vbuffers->flush();
		Swap();

		ClipWindow(old_x,old_y,old_x+old_width,old_y+old_height);
	}
}

void VidD3D::DrawPolygonFlags(U32 flags,U32 numverts, vector_type *p, vector_type *c, float *a, vector_type *tv)
{
	REND_POLY_BEGIN();

	D_ASSERT(numverts<16);

#if 0
	vidatestmodetype_t atest;
	if (flags & TF_TEXBLEND)
		atest=AlphaTestMode(VCMP_GREATER);
#endif

	DxVertexT verts[16];
	U32 i;

	if (c)
	{
		for(i=0;i<numverts;i++)
			verts[i].color=VEC_TO_0RGB(c[i]);
	}
	else
	{
		U32 flat_color=GetColor();
		
		if (vid_state.color_mode!=VCM_FLAT)
			flat_color=0x00FFFFFF;

		for(i=0;i<numverts;i++)
			verts[i].color=flat_color;
	}
	if (a)
	{
		for(i=0;i<numverts;i++)
			verts[i].color|=FLOAT_A_TO_A(a[i]);
	}
	else
	{
		U32 flat_alpha=GetColor() & 0xFF000000;

		if (vid_state.alpha_mode!=VAM_FLAT)
			flat_alpha=0xFF000000;

		for(i=0;i<numverts;i++)
			verts[i].color|=flat_alpha;
	}
	if (tv)
	{
		/* uber hack to get around glide'isms */
		/* need to convert tex coords from glide format to d3d's */
		float mod_s,mod_t;

		mod_s=1.0f;
		mod_t=1.0f;

		if (active_tex)
		{
			/* if s major */
			if (active_tex->width >= active_tex->height)
			{
				mod_t*=(float)(active_tex->width/active_tex->height);
			}
			else /* if t major */
			{
				mod_s*=(float)(active_tex->height/active_tex->width);
			}
		}
		mod_s*=1.0f/255.0f;
		mod_t*=1.0f/255.0f;
		for(i=0;i<numverts;i++)
		{
			verts[i].s=tv[i].x*mod_s;
			verts[i].t=tv[i].y*mod_t;
		}
	}
	for (i=0;i<numverts;i++)
	{
		verts[i].x=p[i].x;
		verts[i].y=p[i].y;
		verts[i].z=verts[i].rhw=1.0f;
	}
	if (vid_state.depth_enabled)
	{
		for (i=0;i<numverts;i++)
		{
			verts[i].z=p[i].z;
			verts[i].rhw = 1.0f / verts[i].z;
		}
	}

	U32 num_tris=(numverts-2);
	DxVertexT *space=begin_prim(PRIM_TRIANGLELIST,num_tris*3);
	for (i=0;i<num_tris;i++)
	{
		set_vert_adv(space,&verts[0]);
		set_vert_adv(space,&verts[i+1]);
		set_vert_adv(space,&verts[i+2]);
	}
	end_prim(space,num_tris);
	D_ASSERT(((I32)num_tris > 0));

#if 0
	if (flags & TF_TEXBLEND)
		AlphaTestMode(atest);
#endif

	REND_POLY_END();
}

void VidD3D::DrawString(int x1, int y1, int dx, int dy, char *str, U8 filtered, int r, int g, int b)
{
	REND_POLY_BEGIN();

	/* validate that depth is not enabled */
	D_ASSERT(!vid_state.depth_enabled);

	if (!str)
		return;

	U32 len=fstrlen(str);
	if (!len)
		return;

	DxVertexT verts[4];

	/* select font texture */
	TexActivate(font,VTA_NORMAL);
	
	vidcolormodetype_t	cmode;
	vidfiltermodetype_t fmode;
	vidalphamodetype_t	amode;
	vidblendmodetype_t	bmode;
	vidatestmodetype_t	atmode;

	/* setup masked alpha texture settings */
	cmode=ColorMode(VCM_TEXTURE);
	atmode=AlphaTestMode(VCMP_NOTEQUAL);
	AlphaTestValue(0);
	amode=AlphaMode(VAM_TEXTURE);
	bmode=BlendMode(VBM_OPAQUE);
	if (filtered)
		fmode = MagFilterMode(VFM_BILINEAR);
	else
		fmode = MagFilterMode(VFM_POINT);

	float l_width,l_height;

	font->get_pitch(&l_width,&l_height);

	float dxf,dyf;

	dxf=(float)dx;
	dyf=(float)dy;

	verts[0].x=((float)x1) - dxf;
	verts[0].y=(float)y1;
	verts[0].z=1.0f;
	verts[0].rhw=1.0f;
	verts[0].color=0xFFFFFFFF;

	verts[1].x=((float)(x1+dx)) - dxf;
	verts[1].y=(float)y1;
	verts[1].z=1.0f;
	verts[1].rhw=1.0f;
	verts[1].color=0xFFFFFFFF;

	verts[2].x=((float)(x1+dx)) - dxf;
	verts[2].y=(float)(y1+dy);
	verts[2].z=1.0f;
	verts[2].rhw=1.0f;
	verts[2].color=0xFFFFFFFF;

	verts[3].x=((float)x1) - dxf;
	verts[3].y=(float)(y1+dy);
	verts[3].z=1.0f;
	verts[3].rhw=1.0f;
	verts[3].color=0xFFFFFFFF;

	char key;

	/* make room for string */
	DxVertexT *space=begin_prim(PRIM_TRIANGLELIST,3*2*len);
	U32 tri_count=0;
	while(key=*str++)
	{
		float s,t;

		font->get_letter(key,&s,&t);
		
		verts[0].x += dxf;
		verts[0].s = s;
		verts[0].t = t;

		verts[1].x += dxf;
		verts[1].s = s + l_width;
		verts[1].t = t;

		verts[2].x += dxf;
		verts[2].s = s + l_width;
		verts[2].t = t + l_height;

		verts[3].x += dxf;
		verts[3].s = s;
		verts[3].t = t + l_height;

		/* don't render spaces */
		if (key!=' ')
		{
			set_vert_adv(space,&verts[0]);
			set_vert_adv(space,&verts[1]);
			set_vert_adv(space,&verts[2]);

			set_vert_adv(space,&verts[0]);
			set_vert_adv(space,&verts[2]);
			set_vert_adv(space,&verts[3]);

			tri_count+=2;
		}
	}

	end_prim(space,tri_count);

	REND_POLY_END();

	/* restore for regular rendering */
	ColorMode(cmode);
	AlphaTestMode(atmode);
	AlphaMode(amode);
	BlendMode(bmode);
	MagFilterMode(fmode);
}

U32 VidD3D::is_char_drawable(char key)
{
	return font->is_drawable(key);
}

U32 VidD3D::LockScreen(vidlockscreentype_t lock, unsigned short **buffer, int *pitch)
{
	D_ASSERT(!locked_surf);

	if (dev->GetBackBuffer(0,D3DBACKBUFFER_TYPE_MONO,&locked_surf)!=D3D_OK)
		xxx_throw("VidD3D::LockScreen: unable to get surface");

	switch(lock)
	{
		case VLS_READBACK:
			break;
		case VLS_WRITEBACK:
			break;
		default:
			xxx_throw("VidD3D::LockScreen: unsupported locking surface");
			break;
	}
	D3DLOCKED_RECT lock_rect;

	if (locked_surf->LockRect(&lock_rect,null,0)!=D3D_OK)
		xxx_throw("VidD3D::LockScreen: unable to lock surface");

	return TRUE;
}

void VidD3D::UnlockScreen(void)
{
	if (locked_surf->UnlockRect()!=D3D_OK)
		xxx_throw("VidD3D::UnlockScreen: unable to unlock rect");
	locked_surf->Release();
	locked_surf=null;
}

void VidD3D::BeginScene(void)
{
	if (dev->BeginScene()!=D3D_OK)
		xxx_fatal("VidD3D::BeginScene failed");

	vid_state.in_scene=TRUE;
	vbuffers->BeginNewFrame();
}

void VidD3D::EndScene(void)
{
	D_ASSERT(vid_state.in_scene);
	vbuffers->flush();

	//VidTexD3D *old_tex=active_tex;

	//TexActivate(GetBlankTex(),VTA_NORMAL);
	//vbuffers->EndScene();
	//TexActivate(old_tex,VTA_NORMAL);

	if (dev->EndScene()!=D3D_OK)
		xxx_fatal("VidD3D::EndScene failed");

#if 0
	if (dev->GetBackBuffer(0,D3DBACKBUFFER_TYPE_MONO,&locked_surf)!=D3D_OK)
		xxx_throw("VidD3D::LockScreen: unable to get surface");
	
	D3DLOCKED_RECT lock_rect;
	if (locked_surf->LockRect(&lock_rect,null,0)!=D3D_OK)
		xxx_throw("VidD3D::LockScreen: unable to lock surface");

	if (locked_surf->UnlockRect()!=D3D_OK)
		xxx_throw("VidD3D::UnlockScreen: unable to unlock rect");

	locked_surf->Release();
	locked_surf=null;
#endif
	vid_state.in_scene=FALSE;
}

void VidD3D::ClipGood(void)
{
	if (!vid_state.clip_good)
		vbuffers->flush();

	vid_state.clip_good=TRUE;
}

void VidD3D::ClipBad(void)
{
	vid_state.clip_good=FALSE;
}

void VidD3D::BeginLines(U32 guess_num)
{
	D_ASSERT(!vid_state.in_prim);
	vid_state.in_prim=TRUE;
	prim_guess=guess_num;
	prim_space=begin_prim(PRIM_LINELIST,guess_num*2);
	prim_start=prim_space;
	prim_count=0;
}

void VidD3D::EndLines(void)
{
	if (!vid_state.in_prim)
		return;
	D_ASSERT((I32)(prim_space-prim_start)<=(I32)(prim_guess*2));
	D_ASSERT((prim_count*2)==(U32)(prim_space-prim_start));
	end_prim(prim_space,prim_count);
	prim_space=null;
	vid_state.in_prim=FALSE;
}

void VidD3D::SetHooptiFrustum(float fov_angle,float xy_ratio,float znear,float zfar)
{
#if 0
	float xmax=tanf(fov_angle)*near;
	float ymax=xmax/xy_ratio;
#endif

	D3DXMATRIX matrix;

	matrix.m[2][2]=(zfar+znear) / (zfar-znear);
	matrix.m[2][3]=(-2*zfar*znear) / (zfar - znear);

	matrix.m[0][0]=1.0f;matrix.m[0][1]=0.0f;matrix.m[0][2]=0.0f;matrix.m[0][3]=0.0f;
	matrix.m[1][0]=0.0f;matrix.m[1][1]=1.0f;matrix.m[1][2]=0.0f;matrix.m[1][3]=0.0f;
	matrix.m[2][0]=0.0f;matrix.m[2][1]=0.0f;
	matrix.m[3][0]=0.0f;matrix.m[3][1]=0.0f;matrix.m[2][2]=0.0f;matrix.m[3][3]=1.0f;

	D3DXMatrixPerspectiveLH(&matrix,1.0f,1.0f,0.5f,1024.0f);

	dev->SetTransform(D3DTS_PROJECTION,&matrix);
}