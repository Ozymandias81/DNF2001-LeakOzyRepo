#include "stdd3d.h"

VidDll _dll_vid;

float _deb_clip_x;
float _deb_clip_y;
float _deb_clip_width;
float _deb_clip_height;

VidDll::VidDll(void) : d3d(null),version(VID_D3D_VERSION)
{
	d3d=new VidD3D;
}

VidDll::~VidDll(void)
{
	close();
}

U32 VidDll::close(void)
{
	if (d3d)
		delete d3d;
	d3d=null;
	return TRUE;
}

U32 VidDll::vid_release(void)
{
	if (d3d)
		delete d3d;
	d3d=null;
	return TRUE;
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

U32 __cdecl VidVersion(void)
{
	return(_dll_vid.get_version());
}

VidIf* __cdecl VidQuery(void)
{
	return(_dll_vid.get_if());
}

U32 __cdecl VidRelease(void)
{
	return _dll_vid.vid_release();
}
