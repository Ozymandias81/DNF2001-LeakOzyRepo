#include <windows.h>
#include <xcore.h>
#include <vid_main.h>
#include <d3d8.h>

class VidD3D : public VidIf
{
	IDirect3D8 *id3d;

	VidView			*full_view;
	XList<VidView>	view_list;

	U32 num_adaptor;
	U32 adaptor_id;
	U32 windowed : 1;
public:
	VidD3D(void);
	~VidD3D(void);

	U32 init(void);
	VidView *init_view(XHandle hwnd,U32 x,U32 y,U32 bpp,U32 fullscreen);
	U32 close_view(VidView *view);
	U32 close(void);
	U32 destroy(void);
	U32 swap(U32 wait=1);
};

class ViewD3D : public VidView
{
	IDirect3DDevice8 *dev;
public:
	ViewD3D(IDirect3DDevice8 *Dev,
};

VidD3D *d3d=null;

VidD3D::VidD3D(void) : id3d(null),dev(null),full_view(null)
{
	d3d=this;
}

U32 VidD3D::init(void)
{
	id3d=Direct3DCreate8(D3D_SDK_VERSION);
	if (!id3d)
		return FALSE;
	return TRUE;
}

VidView *VidD3D::init_view(XHandle hwnd,U32 x,U32 y,U32 bpp,U32 fullscreen)
{
	D_ASSERT(id3d);

	if ((fullscreen) && (full_view))
		return null;

	num_adaptor=id3d->GetAdapterCount();

	adaptor_id=D3DADAPTER_DEFAULT;

	U32 i,mode_count;
	
	mode_count=id3d->GetAdapterModeCount(adaptor_id);

	U32 bformat,dformat;

	switch(bpp)
	{
		case 2:
			bformat=D3DFMT_R5G6B5;
			dformat=D3DFMT_D16;
			break;
		case 4:
			bformat=D3DFMT_A8R8G8B8;
			dformat=D3DFMT_D24S8;
			break;
		default:
			return FALSE;
	}
	
	for (i=0;i<mode_count;i++)
	{
		D3DDISPLAYMODE mode;

		if (id3d->EnumAdapterModes(adaptor_id,i,&mode)==D3D_OK)
		{
			if ((mode.Width==x) && (mode.Height=y) && ((U32)mode.Format==bformat))
				break;
		}
	}
	if (i==mode_count)
		return FALSE;

	D3DPRESENT_PARAMETERS present;

	present.BackBufferWidth=x;
	present.BackBufferHeight=y;
	present.BackBufferFormat=(D3DFORMAT)dformat;
	present.BackBufferCount=1;
	present.MultiSampleType=D3DMULTISAMPLE_NONE;
	if (!windowed)
		present.SwapEffect=D3DSWAPEFFECT_FLIP;
	else
		present.SwapEffect=D3DSWAPEFFECT_COPY_VSYNC;

	present.hDeviceWindow=(HWND)hwnd;
	present.Windowed=windowed;
	present.EnableAutoDepthStencil=TRUE;
	present.AutoDepthStencilFormat=(D3DFORMAT)dformat;

	present.Flags=0;
	present.FullScreen_RefreshRateInHz=D3DPRESENT_RATE_DEFAULT;
	present.FullScreen_PresentationInterval=D3DPRESENT_INTERVAL_ONE;

	if (id3d->CreateDevice(adaptor_id,D3DDEVTYPE_HAL,(HWND)hwnd,0,&present,&dev)!=D3D_OK)
		return FALSE;

	VidView *view=new ViewD3D(dev,x,y,bpp);
	if (fullscreen)
		full_view=view;

	view_list.add_head(view);

	return view;
}

U32 VidD3D::close_view(VidView *view)
{
}

U32 VidD3D::close(void)
{
	if (dev)
		dev->Release();
	dev=null;

	if (id3d)
		id3d->Release();
	id3d=null;
	
	d3d=null;
}

U32 VidD3D::destroy(void)
{
	close();
}

U32 swap(U32 wait)
{

}

class VidInterface : public XDll
{
//	vid_import_t	imp;
//	vid_export_t	exp;
	VidD3D			*d3d;

public:
	VidInterface(void);
	~VidInterface(void);
	U32 close(void);
};

VidInterface _dll_vid;

VidInterface::VidInterface(void)
{
	d3d=new VidD3D;
}

VidInterface::~VidInterface(void)
{
	close();
}

U32 VidInterface::close(void)
{
	if (d3d)
		delete d3d;
	d3d=null;
}

BOOL __stdcall DllMain(HANDLE hmodule,DWORD reason,void *reserved)
{
	switch(reason)
	{
		case DLL_PROCESS_ATTACH:
			return _dll_vid.attach_process(hmodule);
		case DLL_THREAD_ATTACH:
			return _dll_vid.attach_thread(hmodule);
		case DLL_PROCESS_DETACH:
			return _dll_vid.detach_process(hmodule);
		case DLL_THREAD_DETACH:
			return _dll_vid.detach_thread(hmodule);
	}

	return TRUE;
}

VidIf* __cdecl VidQueryAPI(void)
{
	return(d3d);
}

void VidClipWindow(I32 x1,I32 y1,I32 x2,I32 y2)
{
}