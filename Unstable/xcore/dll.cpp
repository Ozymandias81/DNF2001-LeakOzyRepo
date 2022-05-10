#include "stdcore.h"

extern XDll *_xcore_dll;

BOOL __stdcall DllMain(HANDLE hmodule,DWORD reason,void *reserved)
{
	switch(reason)
	{
		case DLL_PROCESS_ATTACH:
			return _xcore_dll->attach_process(hmodule);
		case DLL_THREAD_ATTACH:
			return _xcore_dll->attach_thread(hmodule);
		case DLL_PROCESS_DETACH:
			return _xcore_dll->detach_process(hmodule);
		case DLL_THREAD_DETACH:
			return _xcore_dll->detach_thread(hmodule);
	}
	return TRUE;
}

U32 XDll::attach_process(XHandle hmod)
{
	return TRUE;
}

U32 XDll::detach_process(XHandle hmod)
{
	return TRUE;
}

U32 XDll::attach_thread(XHandle hmod)
{
	return TRUE;
}

U32 XDll::detach_thread(XHandle hmod)
{
	return TRUE;
}


