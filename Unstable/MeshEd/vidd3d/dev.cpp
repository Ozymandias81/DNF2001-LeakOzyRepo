#include "stdd3d.h"

VidD3D::VidD3D(void) : id3d(null),dev(null),view(null),locked_surf(null),vbuffers(null),active_tex(null),blank_tex(null),font(null),dev_wnd(null)
{
}

VidD3D::~VidD3D(void)
{
	close();
}

U32 VidD3D::create_device(XWnd *wnd,U32 width,U32 height,U32 byte_pp)
{
	num_adaptor=id3d->GetAdapterCount();

	adaptor_id=D3DADAPTER_DEFAULT;

	U32 i,mode_count;
	
	mode_count=id3d->GetAdapterModeCount(adaptor_id);

	U32 bformat,dformat,has_stencil;

	has_stencil=FALSE;
	switch(byte_pp)
	{
		case 2:
			bformat=D3DFMT_R5G6B5;
			dformat=D3DFMT_D16;
			break;
		case 4:
			bformat=D3DFMT_A8R8G8B8;
			dformat=D3DFMT_D24S8;
			has_stencil=TRUE;
			break;
		default:
			return FALSE;
	}
	
	for (i=0;i<mode_count;i++)
	{
		D3DDISPLAYMODE mode;

		if (id3d->EnumAdapterModes(adaptor_id,i,&mode)==D3D_OK)
		{
			if ((mode.Width==width) && (mode.Height=height) && ((U32)mode.Format==bformat))
				break;
		}
	}
	if (i==mode_count)
		return FALSE;

	D3DPRESENT_PARAMETERS present;

	present.BackBufferWidth=width;
	present.BackBufferHeight=height;
	present.BackBufferFormat=(D3DFORMAT)bformat;
	present.BackBufferCount=1;
	present.MultiSampleType=D3DMULTISAMPLE_NONE;
	present.SwapEffect=D3DSWAPEFFECT_FLIP;

	present.hDeviceWindow=wnd->get_hwnd();
	present.Windowed=FALSE;
	present.EnableAutoDepthStencil=TRUE;
	present.AutoDepthStencilFormat=(D3DFORMAT)dformat;

	present.Flags=D3DPRESENTFLAG_LOCKABLE_BACKBUFFER;
	present.FullScreen_RefreshRateInHz=D3DPRESENT_RATE_DEFAULT;
	present.FullScreen_PresentationInterval=D3DPRESENT_INTERVAL_ONE;

	dev=null;
	if (id3d->CreateDevice(adaptor_id,D3DDEVTYPE_HAL,wnd->get_hwnd(),D3DCREATE_MIXED_VERTEXPROCESSING,&present,&dev)!=D3D_OK)
		return FALSE;
	
	if (id3d->GetDeviceCaps(adaptor_id,D3DDEVTYPE_HAL,&caps)!=D3D_OK)
		xxx_fatal("Unable to get device caps");

	vid_state.has_stencil=has_stencil;

	img_device.set_support(IMG_SUPPORTS_RGB_565|
						IMG_SUPPORTS_ARGB_1555|
						IMG_SUPPORTS_ARGB_4444);

	img_device.set_restrict(IMG_RESTRICT_NO_32|
						IMG_RESTRICT_POW_2|
						IMG_RESTRICT_256|
						IMG_RESTRICT_ASPECT_8);

	res.width=width;
	res.height=height;
	res.bpp=byte_pp;

	view=new ViewD3D(wnd,dev,width,height,byte_pp);

	create_vbuffers();

	return TRUE;
}

U32 VidD3D::init(XWnd *wnd,U32 width,U32 height,U32 byte_pp)
{
	if (id3d)
		return FALSE;
	id3d=Direct3DCreate8(D3D_SDK_VERSION);
	if (!id3d)
		return FALSE;

	if (view)
		return null;

	dev_wnd=wnd;

	if (!create_device(wnd,width,height,byte_pp))
		return FALSE;

	set_default();

	init_font();

	vid_state.active=TRUE;

	return TRUE;
}

U32 VidD3D::close(void)
{
	delete view;
	view=null;

	//release_resources();
	if (locked_surf)
	{
		xxx_bitch("VidD3D::close: still has locked surface");
		locked_surf->UnlockRect();
		locked_surf->Release();
		locked_surf=null;
	}
	
	/* release texture resources */
	tex_list.release_d3d();

	if (vbuffers)
		delete vbuffers;
	vbuffers=null;

	/* release device */
	U32 d3d_leak=FALSE;
	if (dev)
	{
		while(dev->Release())
			d3d_leak=TRUE;
	}
	dev=null;

	/* release interface */
	if (id3d)
		id3d->Release();

	id3d=null;

	if (d3d_leak)
		xxx_bitch("D3D Leak");

	return TRUE;
}

void VidD3D::Activate(void)
{
	if (vid_state.active)
		return;

	create_device(dev_wnd,res.width,res.height,res.bpp);
	
	restore_state();

	vid_state.active=TRUE;
}

void VidD3D::Deactivate(void)
{
	if (!vid_state.active)
		return;

	delete view;
	view=null;

	//release_resources();
	if (locked_surf)
	{
		xxx_bitch("VidD3D::close: still has locked surface");
		locked_surf->UnlockRect();
		locked_surf->Release();
		locked_surf=null;
	}

	/* release texture resources */
	tex_list.release_d3d();

	if (vbuffers)
		delete vbuffers;
	vbuffers=null;

	/* release device */
	U32 d3d_leak=FALSE;
	if (dev)
	{
		while(dev->Release())
			d3d_leak=TRUE;
	}
	dev=null;

	vid_state.active=FALSE;
	
	if (d3d_leak)
		xxx_bitch("D3D Leak");
}

void VidD3D::create_vbuffers(void)
{
	D_ASSERT(dev);
	
	U32 fvf;

	fvf=D3DFVF_XYZRHW|D3DFVF_DIFFUSE|D3DFVF_TEX1;
	vbuffers=new VManager(this,dev,4,8192,fvf);
}

void VidD3D::depth_init(void)
{
	if (caps.RasterCaps & D3DPRASTERCAPS_WBUFFER)
		vid_state.support_wbuffer=TRUE;

	if (vid_state.support_wbuffer)
		dev->SetRenderState(D3DRS_ZENABLE,D3DZB_USEW);
	else
		dev->SetRenderState(D3DRS_ZENABLE,D3DZB_TRUE);

	vid_state.depth_enabled=TRUE;
}

void VidD3D::init_tex_stages(void)
{
	d3d_state.color_op0=D3DTOP_SELECTARG1;
	d3d_state.color1_arg0=D3DTA_DIFFUSE;
	d3d_state.color2_arg0=D3DTA_DIFFUSE;
	vid_state.flat_shade=FALSE;
	vid_state.color_mode=VCM_GOURAUD;

	d3d_state.alpha_op0=D3DTOP_SELECTARG1;
	d3d_state.alpha1_arg0=D3DTA_DIFFUSE;
	d3d_state.alpha2_arg0=D3DTA_DIFFUSE;
	vid_state.flat_alpha=FALSE;
	vid_state.alpha_mode=VAM_GOURAUD;

	d3d_state.color_op1=D3DTOP_DISABLE;
	d3d_state.color1_arg1=D3DTA_DIFFUSE;
	d3d_state.color2_arg1=D3DTA_DIFFUSE;

	d3d_state.alpha_op1=D3DTOP_DISABLE;
	d3d_state.alpha1_arg1=D3DTA_DIFFUSE;
	d3d_state.alpha2_arg1=D3DTA_DIFFUSE;

	d3d_state.color_op2=D3DTOP_DISABLE;
	d3d_state.color1_arg2=D3DTA_DIFFUSE;
	d3d_state.color2_arg2=D3DTA_DIFFUSE;

	d3d_state.alpha_op2=D3DTOP_DISABLE;
	d3d_state.alpha1_arg2=D3DTA_DIFFUSE;
	d3d_state.alpha2_arg2=D3DTA_DIFFUSE;

	dev->SetTextureStageState(0,D3DTSS_COLOROP,d3d_state.color_op0);
	dev->SetTextureStageState(0,D3DTSS_COLORARG1,d3d_state.color1_arg0);
	dev->SetTextureStageState(0,D3DTSS_COLORARG2,d3d_state.color2_arg0);
	dev->SetTextureStageState(0,D3DTSS_ALPHAOP,d3d_state.alpha_op0);
	dev->SetTextureStageState(0,D3DTSS_ALPHAARG1,d3d_state.alpha1_arg0);
	dev->SetTextureStageState(0,D3DTSS_ALPHAARG2,d3d_state.alpha2_arg0);

	dev->SetTextureStageState(1,D3DTSS_COLOROP,d3d_state.color_op1);
	dev->SetTextureStageState(1,D3DTSS_COLORARG1,d3d_state.color1_arg1);
	dev->SetTextureStageState(1,D3DTSS_COLORARG2,d3d_state.color2_arg1);
	dev->SetTextureStageState(1,D3DTSS_ALPHAOP,d3d_state.alpha_op1);
	dev->SetTextureStageState(1,D3DTSS_ALPHAARG1,d3d_state.alpha1_arg1);
	dev->SetTextureStageState(1,D3DTSS_ALPHAARG2,d3d_state.alpha2_arg1);

	dev->SetTextureStageState(2,D3DTSS_COLOROP,d3d_state.color_op2);
	dev->SetTextureStageState(2,D3DTSS_COLORARG1,d3d_state.color1_arg2);
	dev->SetTextureStageState(2,D3DTSS_COLORARG2,d3d_state.color2_arg2);
	dev->SetTextureStageState(2,D3DTSS_ALPHAOP,d3d_state.alpha_op2);
	dev->SetTextureStageState(2,D3DTSS_ALPHAARG1,d3d_state.alpha1_arg2);
	dev->SetTextureStageState(2,D3DTSS_ALPHAARG2,d3d_state.alpha2_arg2);
}

void VidD3D::set_default(void)
{
	D_ASSERT(dev);
	
	dev->ShowCursor(FALSE);

	vid_state.in_scene=FALSE;

	/* set active texture to null */
	active_tex=null;

	/* initialze depth buffering */
	depth_init();
	//vid_state.zfunc=ZCMP_GREATER;
	vid_state.zfunc=ZCMP_LESS;
	dev->SetRenderState(D3DRS_ZFUNC,vid_state.zfunc);
	/* enable writing to depth buffer */
	vid_state.depth_write=TRUE;
	dev->SetRenderState(D3DRS_ZWRITEENABLE,vid_state.depth_write);

	/* enable writing to color buffer */
	vid_state.color_write=TRUE;
	dev->SetRenderState(D3DRS_COLORWRITEENABLE,D3DCOLORWRITEENABLE_RED|D3DCOLORWRITEENABLE_GREEN|D3DCOLORWRITEENABLE_BLUE);

	/* turn on dithering */
	dev->SetRenderState(D3DRS_DITHERENABLE,TRUE);

	dev->SetRenderState(D3DRS_FILLMODE,D3DFILL_SOLID);

	/* setup clip window */
	ClipWindow(0,0,res.width,res.height);

	/* init texture stages */
	init_tex_stages();

	/* setup shade mode */
	dev->SetRenderState(D3DRS_SHADEMODE,D3DSHADE_GOURAUD);

	/* init alpha test */
	vid_state.alpha_test_enable=TRUE;
	dev->SetRenderState(D3DRS_ALPHATESTENABLE,TRUE);
	vid_state.alpha_test_mode=VCMP_ALWAYS;
	dev->SetRenderState(D3DRS_ALPHAFUNC,vid_state.alpha_test_mode);

	/* init tex filter modes test */
	vid_state.min_filter_mode=VFM_POINT;
	dev->SetTextureStageState(0,D3DTSS_MINFILTER,vid_state.min_filter_mode);
	vid_state.mag_filter_mode=VFM_BILINEAR;
	dev->SetTextureStageState(0,D3DTSS_MAGFILTER,vid_state.mag_filter_mode);
	dev->SetTextureStageState(0,D3DTSS_MIPFILTER,D3DTEXF_NONE);
	//dev->SetTextureStageState(0,D3DTSS_MIPFILTER,D3DTEXF_LINEAR);

	/* init cull state */
	vid_state.cull_mode=VWM_SHOWALL;
	dev->SetRenderState(D3DRS_CULLMODE,vid_state.cull_mode);

	/* init blend modes */
	d3d_state.src_blend=D3DBLEND_ONE;
	d3d_state.dst_blend=D3DBLEND_ZERO;
	vid_state.blend_mode=VBM_OPAQUE;
	dev->SetRenderState(D3DRS_ALPHABLENDENABLE,TRUE);
	dev->SetRenderState(D3DRS_SRCBLEND,d3d_state.src_blend);
	dev->SetRenderState(D3DRS_DESTBLEND,d3d_state.dst_blend);

	D3DMATRIX matrix;

	matrix.m[0][0]=1.0f;matrix.m[0][1]=0.0f;matrix.m[0][2]=0.0f;matrix.m[0][3]=0.0f;
	matrix.m[1][0]=0.0f;matrix.m[1][1]=1.0f;matrix.m[1][2]=0.0f;matrix.m[1][3]=0.0f;
	matrix.m[2][0]=0.0f;matrix.m[2][1]=0.0f;matrix.m[2][2]=1.0f;matrix.m[2][3]=0.0f;
	matrix.m[3][0]=0.0f;matrix.m[3][1]=0.0f;matrix.m[2][2]=0.0f;matrix.m[3][3]=1.0f;

	dev->SetTransform(D3DTS_VIEW,&matrix);
	dev->SetTransform(D3DTS_TEXTURE0,&matrix);
	dev->SetTransform(D3DTS_PROJECTION,&matrix);
}

void VidD3D::restore_state(void)
{
	VidState old_state=vid_state;

	set_default();
	
	ColorMode((vidcolormodetype_t)old_state.color_mode);
	AlphaMode((vidalphamodetype_t)old_state.alpha_mode);
	BlendMode((vidblendmodetype_t)old_state.blend_mode);
	WindingMode((vidwindingmodetype_t)old_state.cull_mode);
	MinFilterMode((vidfiltermodetype_t)old_state.min_filter_mode);
	MagFilterMode((vidfiltermodetype_t)old_state.mag_filter_mode);
	AlphaTestMode((vidatestmodetype_t)old_state.alpha_test_mode);
	AlphaTestEnable(old_state.alpha_test_enable);
	DepthFunc((zfunc_modetype_t)old_state.zfunc);
	FlatColor(old_state.color_r,old_state.color_g,old_state.color_b);
	FlatAlpha(old_state.color_a);
	AlphaTestValue(old_state.alpha_test_val);
	ClipWindow(old_state.clip_x,old_state.clip_y,old_state.clip_x + old_state.clip_width,old_state.clip_y + old_state.clip_height);
	ColorWrite(old_state.color_write);
	DepthWrite(old_state.depth_write);

	BeginScene();
	ClearScreen();
	EndScene();
	Swap();

	if (old_state.in_scene)
		BeginScene();
}

void VidD3D::flush_vbuffers(void)
{

}

void VidD3D::Diags(void)
{
	U32 colors=0xFF;
	
	//VidTex *tex=TexLoad("..\\ximage\\images\\test.tga",TRUE);
	//VidTex *tex=TexLoad("resource\\but_aforward.bmp",TRUE);
	VidTex *tex1=TexLoad("meshes\\flamethrower\\flamethrower1BC.BMP",TRUE,TEX_LOAD_MASKED,0x00FF00FF);
	VidTex *tex2=TexLoad("meshes\\flamethrower\\flamethrower2BC.BMP",TRUE,TEX_LOAD_MASKED,0x00FF00FF);
	VidTex *tex3=TexLoad("meshes\\flamethrower\\flamethrower3BC.tga",TRUE,TEX_LOAD_MASKED,0x00FF00FF);

	TexActivate(tex1,VTA_NORMAL);
	TexActivate(tex2,VTA_NORMAL);
	TexActivate(tex3,VTA_NORMAL);
	DepthEnable(FALSE);
	SetHooptiFrustum(0.0f,1.0f,0.5f,1024.0f);
	while(1)
	{
		ClearScreen(colors);
		BeginScene();

		//AlphaMode(VAM_TEXTURE);
		AlphaMode(VAM_TEXTURE);
		ColorMode(VCM_TEXTURE);
		BlendMode(VBM_OPAQUE);
		AlphaTestMode(VCMP_GREATER);
		AlphaTestValue(0);
		MagFilterMode(VFM_POINT);
		MinFilterMode(VFM_POINT);

		vector_str v[3];
		vector_str tv[3];
		
		v[0].x=25.0f;
		v[0].y=25.0f;
		v[0].z=0.5f;
		v[1].x=400.0f;
		v[1].y=575.0f;
		v[1].z=0.5f;
		v[2].x=775.0f;
		v[2].y=25.0f;
		v[2].z=0.5f;

		tv[0].x=0.0f;
		tv[0].y=0.0f;
		tv[1].x=127.0f;
		tv[1].y=255.0f;
		tv[2].x=255.0f;
		tv[2].y=0.0f;

		//DrawTriangle(&v[0],null,null,&tv[0]);
		//DrawPolygon(3,&v[0],null,null,&tv[0]);
		DrawPolygonFlags(0,3,&v[0],null,null,&tv[0]);

		EndScene();
		Swap();

		colors=_rotl(colors,8);
	}
	TexRelease(tex1);
	TexRelease(tex2);
	TexRelease(tex3);
}

#if 0
void VidD3D::Diags(void)
{
	U32 colors=0xFF;
	
	//VidTex *tex=TexLoad("..\\ximage\\images\\test.tga",TRUE);
	//VidTex *tex=TexLoad("resource\\but_aforward.bmp",TRUE);
	VidTex *tex=TexLoad("hair_long1\\hair_long2RC.tga",TRUE);

	TexActivate(tex,VTA_NORMAL);
	DepthEnable(FALSE);
	SetHooptiFrustum(0.0f,1.0f,0.5f,1024.0f);
	while(1)
	{
		ClearScreen(colors);
		BeginScene();

		//AlphaMode(VAM_TEXTURE);
		AlphaMode(VAM_FLAT);
		FlatAlpha(30);
		ColorMode(VCM_GOURAUDTEXTURE);
		BlendMode(VBM_TRANSMERGE);

		vector_str v[3];
		vector_str tv[3];
		
		v[0].x=25.0f;
		v[0].y=25.0f;
		v[0].z=0.5f;
		v[1].x=400.0f;
		v[1].y=575.0f;
		v[1].z=0.5f;
		v[2].x=775.0f;
		v[2].y=25.0f;
		v[2].z=0.5f;

		tv[0].x=0.0f;
		tv[0].y=0.0f;
		tv[1].x=127.0f;
		tv[1].y=255.0f;
		tv[2].x=255.0f;
		tv[2].y=0.0f;

		//DrawTriangle(&v[0],null,null,&tv[0]);
		//DrawPolygon(3,&v[0],null,null,&tv[0]);
		DrawPolygonFlags(0,3,&v[0],null,null,&tv[0]);

		EndScene();
		Swap();

		colors=_rotl(colors,8);
	}
	TexRelease(tex);
}
#endif

#if 0
void VidD3D::Diags(void)
{
	U32 colors=0xFF;

	ColorMode(VCM_GOURAUDTEXTURE);
	
	//VidTex *tex=TexLoad("..\\ximage\\images\\test.tga",TRUE);
	VidTex *tex=TexLoad("resource\\but_aforward.bmp",TRUE);

	TexActivate(tex,VTA_NORMAL);
	DepthEnable(FALSE);
	while(1)
	{
		ClearScreen(colors);
		BeginScene();

		DrawString(10,10,20,20,"abcdefghijklmnopqrstuvwxyz",FALSE,0,0,0);
		DrawString(10,20,20,20,"abcdefghijklmnopqrstuvwxyz",FALSE,0,0,0);
		DrawString(10,30,20,20,"abcdefghijklmnopqrstuvwxyz",FALSE,0,0,0);

		EndScene();
		Swap();

		colors=_rotl(colors,8);
	}
	TexRelease(tex);
}

void VidD3D::Diags(void)
{
	U32 colors=0xFF;

	ColorMode(VCM_FLAT);
	
	//VidTex *tex=TexLoad("..\\ximage\\images\\test.tga",TRUE);
	//VidTex *tex=TexLoad("resource\\but_aforward.bmp",TRUE);

	//TexActivate(tex,VTA_NORMAL);
	DepthEnable(TRUE);
	SetHooptiFrustum(0.0f,1.0f,0.5f,1024.0f);

	vector_str v[3];

	while(1)
	{
		ClearScreen(colors);
		BeginScene();

		for (U32 i=0;i<4000;i++)
		{
			v[0].x=25.0f;
			v[0].y=25.0f;
			v[0].z=0.5f;
			v[1].x=30.0f;
			v[1].y=30.0f;
			v[1].z=1024.0f;
			v[2].x=35.0f;
			v[2].y=25.0f;
			v[2].z=0.5f;

			FlatColor(0xFF,0xFF,0);
			DrawTriangle(&v[0],null,null,null);
		}
		
		EndScene();
		Swap();

		colors=_rotl(colors,8);
	}
	//TexRelease(tex);
}

void VidD3D::Diags(void)
{
	U32 colors=0xFF;

	ColorMode(VCM_FLAT);
	
	//VidTex *tex=TexLoad("..\\ximage\\images\\test.tga",TRUE);
	//VidTex *tex=TexLoad("resource\\but_aforward.bmp",TRUE);

	//TexActivate(tex,VTA_NORMAL);
	DepthEnable(TRUE);
	SetHooptiFrustum(0.0f,1.0f,0.5f,1024.0f);

	vector_str v[3];

	while(1)
	{
		ClearScreen(colors);
		BeginScene();

		v[0].x=25.0f;
		v[0].y=25.0f;
		v[0].z=0.5f;
		v[1].x=400.0f;
		v[1].y=575.0f;
		v[1].z=1024.0f;
		v[2].x=775.0f;
		v[2].y=25.0f;
		v[2].z=0.5f;

		FlatColor(0xFF,0xFF,0);
		DrawTriangle(&v[0],null,null,null);

		v[0].x=25.0f;
		v[0].y=575.0f;
		v[0].z=0.5f;
		v[1].x=400.0f;
		v[1].y=25.0f;
		v[1].z=1024.0f;
		v[2].x=775.0f;
		v[2].y=575.0f;
		v[2].z=0.5f;

		FlatColor(0,0xFF,0xFF);
		DrawTriangle(&v[0],null,null,null);

		EndScene();
		Swap();

		colors=_rotl(colors,8);
	}
	//TexRelease(tex);
}

void VidD3D::Diags(void)
{
	U32 colors=0xFF;

	while(1)
	{
		ClearScreen(colors);
		BeginScene();

		DxVertexT verts[3];

		verts[0].x=400.0f;
		verts[0].y=50.0f;
		verts[0].z=1.0f;
		verts[0].rhw=1.0f;
		verts[0].color=0xFFFFFFFF;

		verts[1].x=200.0f;
		verts[1].y=400.0f;
		verts[1].z=1.0f;
		verts[1].rhw=1.0f;
		verts[1].color=0xFFFFFFFF;

		verts[2].x=600.0f;
		verts[2].y=400.0f;
		verts[2].z=1.0f;
		verts[2].rhw=1.0f;
		verts[2].color=0xFFFFFFFF;

		vbuffers->AddTri(&verts[0],&verts[1],&verts[2]);

		EndScene();
		Swap();

		colors=_rotl(colors,8);
	}
}
#endif

