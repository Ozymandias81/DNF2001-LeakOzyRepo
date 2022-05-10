#include "stdcore.h"

XMutex::XMutex(U32 create,U32 own,CC8 *Name) : handle(null)
{
	if (!init(create,own,Name))
		xxx_throw("XMutex: Unable to create mutex");
}

U32 XMutex::init(U32 create,U32 own,CC8 *Name)
{
	if (name)
		delete name;

	if (Name)
		name=CStr(Name);

	flags=0;
	if (create)
	{
		handle=CreateMutex(null,own,name);
		if (!handle)
		{
			xxx_bitch("XMutex::init Unable to create mutex");
			U32 err=GetLastError();
			if (err==ERROR_ALREADY_EXISTS)
				xxx_bitch("XMutex::init: mutex already exists");
			return FALSE;
		}
	}
	else
	{
		handle=OpenMutex(MUTEX_ALL_ACCESS,own,name);
		xxx_bitch("XMutex::init Unable to open mutex");
		return FALSE;
	}
	if (own)
		flags|=IS_LOCKED;

	return TRUE;
}

U32 XMutex::lock(U32 timeout)
{
	if (flags & IS_LOCKED)
	{
		xxx_bitch("XMutex::lock: already locked");
		return TRUE;
	}
	err=ERR_NONE;
	U32 ret=WaitForSingleObject(handle,timeout);
	if (ret!=WAIT_OBJECT_0)
	{
		if (ret==WAIT_TIMEOUT)
			err=ERR_TIMEOUT;
		if (ret==WAIT_ABANDONED)
			err=ERR_ABANDONED;
		return FALSE;
	}
	return TRUE;
}

U32 XMutex::unlock(void)
{
	if (!(flags & IS_LOCKED))
	{
		xxx_bitch("XMutex::unlock: not locked");
		return TRUE;
	}
	
	if (!ReleaseMutex(handle))
		return FALSE;

	return TRUE;
}

U32 XMutex::destroy(void)
{
	if (handle)
		CloseHandle(handle);
	handle=null;
	return TRUE;
}

XEvent::XEvent(U32 create,U32 manual_reset,U32 state,CC8 *Name)
{
	if (!init(create,manual_reset,state,Name))
		xxx_throw("XEvent: Unable to initialize");
}

U32 XEvent::init(U32 create,U32 manual_reset,U32 state,CC8 *Name)
{
	if (name)
		delete name;

	name=CStr(Name);

	if (create)
	{
		handle=CreateEvent(null,manual_reset,state,name);
		
		if (!handle)
		{
			xxx_bitch("XEvent::init: Unable to create event");
			return FALSE;
		}
		U32 ret=GetLastError();
		if (ret==ERROR_ALREADY_EXISTS)
			xxx_bitch("XEvent::init: Event already exists");
	}
	else
	{
		handle=OpenEvent(EVENT_ALL_ACCESS,FALSE,name);
		if (!handle)
		{
			xxx_bitch("XEvent::init: Unable to open event");
			return FALSE;
		}
	}
	return TRUE;
}

U32 XEvent::destroy(void)
{
	if (handle)
		CloseHandle(handle);

	handle=null;
	return TRUE;
}

CMemMap::CMemMap(U32 create,CC8 *Name,U32 size)
{
	if (!init(create,Name,size))
		xxx_throw("CMemMap: Unable to initialize");
}

CMemMap::CMemMap(CC8 *Name)
{
	if (!init(FALSE,Name,0))
		xxx_throw("CMemMap: Unable to initialize");
}

U32 CMemMap::init(U32 create,CC8 *Name,U32 size)
{
	D_ASSERT(Name);
	
	if (name)
		delete name;

	name=CStr(Name);

	size=ALIGN_POW2(size,32*1024);
	if (create)
	{
		handle=CreateFileMapping(INVALID_HANDLE_VALUE,null,PAGE_READWRITE,0,size,name);
		if (!handle)
		{
			xxx_bitch("CMemMap::init: Unable to create memory map");
			return FALSE;
		}
		U32 err=GetLastError();
		if (err==ERROR_ALREADY_EXISTS)
			xxx_bitch("CMemMAp::init: Mapping already exists");
	}
	else
	{
		handle=OpenFileMapping(FILE_MAP_ALL_ACCESS,FALSE,name);
		if (!handle)
		{
			xxx_bitch("CMemMap::init: Unable to open memory map");
			return FALSE;
		}
	}
	return TRUE;
}

U32 CMemMap::destroy(void)
{
	if (handle)
		CloseHandle(handle);

	handle=null;
	return TRUE;
}

WinMsgDef _win_error;

void WinMsgDef::set_window(XHWND Hwnd)
{
	hwnd=Hwnd;
}

void WinMsgDef::no_window(void)
{
	hwnd=null;
}

void WinMsgDef::assert(CC8 *file,U32 line)
{
	CPrintf obj(_err_printf_string,MAX_PRINTF_SIZE);

	obj << "Assertion Failure: " << file << " line " << line;
	
	WinMessage(hwnd,obj.get_str());
	
	_global->fatal();
}

void WinMsgDef::message(U32 level,CC8 *message)
{
	WinMessage(hwnd,message);
	if (level<=ERROR_SEVERE)
		_global->fatal();
}

void WinMsgDef::throw_msg(U32 level,CC8 *message)
{
	WinMessage(hwnd,message);
	throw level;
}

void WinMessage(HWND hwnd,CC8 *string)
{
	MessageBoxEx(hwnd,string,"Error",
				MB_OK|MB_ICONERROR|MB_TASKMODAL,
				MAKELANGID(LANG_ENGLISH,SUBLANG_DEFAULT));
}