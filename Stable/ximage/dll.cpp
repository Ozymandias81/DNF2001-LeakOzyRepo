#include <windows.h>
#include <xcore.h>

class XImageDll : public XDll
{
public:
	XImageDll(void);
	~XImageDll(void);
};

XImageDll _dll_image;

XImageDll::XImageDll(void)
{
}

XImageDll::~XImageDll(void)
{
}

BOOL __stdcall DllMain(HANDLE hmodule,DWORD reason,void *reserved)
{
	switch(reason)
	{
		case DLL_PROCESS_ATTACH:
			return _dll_image.attach_process(hmodule);
		case DLL_THREAD_ATTACH:
			return _dll_image.attach_thread(hmodule);
		case DLL_PROCESS_DETACH:
			return _dll_image.detach_process(hmodule);
		case DLL_THREAD_DETACH:
			return _dll_image.detach_thread(hmodule);
	}

	return TRUE;
}
