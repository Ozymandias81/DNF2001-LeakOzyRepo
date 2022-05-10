#include "stdcore.h"
#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>

#pragma warning(disable:4073)
#pragma init_seg(lib)

class XCoreDll : public XDll,public XGlobal
{
public:
	XCoreDll(void);
	~XCoreDll(void);
	U32 attach_thread(XHandle hmod);
	U32 detach_thread(XHandle hmod);
	U32 detach_process(XHandle hmod);
};

/* private functions */
void _mem_init(void);
void _mem_close(void);
void _flush_printf_mem(void);

XCoreDll xcore_dll;
XDll *_xcore_dll=null;
XApp XCORE_API *_xapp=null;
XGlobal XCORE_API *_global=null;
extern "C"{
	void *_gmalloc=null;
	U32 _mem_lock=0;
}

XCoreDll::XCoreDll(void)
{
	_xcore_dll=this;
}

XCoreDll::~XCoreDll(void)
{
	_xcore_dll=null;
}

U32 XCoreDll::detach_process(XHandle hmod)
{
	_global->close();
	return TRUE;
}

U32 XCoreDll::attach_thread(XHandle hmod)
{
	_global->attach_thread(hmod);
	return TRUE;
}

U32 XCoreDll::detach_thread(XHandle hmod)
{
	_global->detach_thread(hmod);
	return TRUE;
}

extern "C" {
XCORE_API char _err_printf_string[MAX_PRINTF_SIZE];
}

XGlobal::XGlobal(void) : sys_flags(0)
{
	_global=this;
	_mem_init();
	error=&_win_error;
	fallback=&_win_error;
}

XGlobal::~XGlobal(void)
{
	/* if we failed to call close */
	if (_global)
		close();
}

void XGlobal::close(void)
{
	_flush_printf_mem();

	/* free raw globally allocated memory */
	_free_raw();

#ifdef DEBUG
	if (_test_leak())
		xxx_bitch("Memory Leak");
#endif
	
	/* clean up badly handled stuff */
	_handle_unclean();

	_global=null;
	stats.close();
	_mem_close();
}

void XGlobal::_free_raw(void)
{
	void **tmp_handle;
	
	while(tmp_handle=raw_handles.remove_head())
	{
		xfree(*tmp_handle);
		*tmp_handle=null;
	}
	/* need to free list too since this gets called when we are dumping memory */
	raw_handles.free_list();
}

void XGlobal::reg_global_handle_rawptr(void **ptr)
{
	raw_handles.add_head(ptr);
}

void XGlobal::reg_global_object(CSysObj *obj)
{
	sys_objects.add_head(obj);
}

void XGlobal::unreg_global_object(CSysObj *ptr)
{
	CSysObj *obj;

	obj=sys_objects.get_head();
	while(obj)
	{
		if (obj==ptr)
		{
			sys_objects.remove(obj);
			return;
		}
		obj=sys_objects.get_next(obj);
	}
}

void XGlobal::_handle_unclean(void)
{
	/* run through list of registered system objects */
	/* and destroy them */
	CSysObj *obj;
	
	/* kernel objects come first */

	/* NOTE: destroy must not free up memory or destruct them */
	/* it simply frees up system resources if it can */
	while(obj=sys_objects.remove_head())
		obj->destroy();

	/* now file objects, since they are riskier */

	/* NOTE: destroy must not free up memory or destruct objects */
	/* it simply frees up system resources if it can */
	while(obj=file_objects.remove_head())
		obj->destroy();
}

/*--------------------------------------*/
/* _fatal_exit() */
/*--------------------------------------*/
/* free up all system level resources, and call exit */
/* -------------------------------------*/
/* Even if this is called recursively, it "should" be safe */
/* since we are plucking off elements, if an element */
/* causes another fatal error, next recursive loop through, */
/* it will continue on the next object. */
void XGlobal::_fatal_exit(void)
{
	/* try and clean up */
	_handle_unclean();
	/* might make sense to call _exit instead */
	exit(1);
}

ErrMem::ErrMem(void) : rotate(1)
{
	tls_index=TlsAlloc();
	/* main thread gets default memory */
	TlsSetValue(tls_index,&rotate);
}

ErrMem::~ErrMem(void)
{
	/* release tls */
	TlsFree(tls_index);
}

char *ErrMem::get(U32 size)
{
	ErrMem *emem=(ErrMem *)TlsGetValue(tls_index);

	if (!emem)
		return null;

	size=ALIGN_POW2(size,ERR_MEM_CHUNK);
	U32 bits=size/ERR_MEM_CHUNK;

	if (bits>32)
		return null;

	U32 loc=_bsf(emem->rotate) - 1;

	/* wrap memory, start at beginning */
	if ((loc+bits)>32)
	{
		emem->rotate=1<<bits;
		return emem->def_mem;
	}
	
	char *ptr=emem->def_mem+(loc*ERR_MEM_CHUNK);
	_rotl(rotate,bits);
	return ptr;
}

char *ErrMem::get_more(char *mem,U32 inc_size)
{
	ErrMem *emem=(ErrMem *)TlsGetValue(tls_index);
	
	if (!emem)
		return null;

	inc_size=ALIGN_POW2(inc_size,ERR_MEM_CHUNK);
	U32 bits=inc_size/ERR_MEM_CHUNK;

	U32 off=(U32)(mem - emem->def_mem);
	
	off/=ERR_MEM_CHUNK;
	U32 end=(_bsf(emem->rotate) - 1);

	U32 total_bits=end - off + bits;

	/* if asking for too much */
	if (total_bits>32)
		return null;

	/* wrap memory, start at beginning */
	if ((end + bits) > 32)
	{
		emem->rotate=_rotl(1,total_bits);
		return emem->def_mem;
	}

	_rotl(emem->rotate,bits);
	return mem;
}

void ErrMem::add_thread(void)
{
	ErrMem *emem=(ErrMem *)xmalloc(sizeof(ErrMem));
	TlsSetValue(tls_index,emem);
}

void ErrMem::remove_thread(void)
{
	ErrMem *emem=(ErrMem *)TlsGetValue(tls_index);
	
	if (emem)
	{
		/* for my sanity */
		if (emem!=this)
			xfree(emem);
	}

	TlsSetValue(tls_index,null);
}

void XGlobal::message(U32 level,CC8 *str)
{
	error->message(level,str);
}

void XGlobal::attach_thread(XHandle hmod)
{
	err_mem.add_thread();
}

void XGlobal::detach_thread(XHandle hmod)
{
	err_mem.remove_thread();
}

void XGlobal::printf(U32 level,CC8 *str,...)
{
	char *mem;
	U32 size=512;
	
	mem=err_mem.get(size);

	va_list  args;
	I32      num;

	va_start(args,str);

	while(1)
	{
		num=_vsnprintf(mem,size-1,str,args);
		if (num!=-1)
			break;
		/* try and get a little more mem */
		if (!err_mem.get_more(mem,512))
		{
			/* send it out even if incomplete, so we can get a clue */
			error->message(level,str);
			xxx_fatal("XGlobal::printf: Out of error memory");
			return;
		}
		size+=512;
	}

	va_end(args);

	/* send out as message */
	error->message(level,str);
}

void XGlobal::throw_msg(U32 level,CC8 *str)
{
	if (sys_flags & SYS_IN_THROW)
		fallback->throw_msg(level,str);
	else
	{
		sys_flags|=SYS_IN_THROW;
		error->throw_msg(level,str);
	}
}

/* clear flags */
void XGlobal::caught(void)
{
	D_ASSERT(sys_flags & SYS_IN_THROW);

	sys_flags &=~ SYS_IN_THROW;
}

void XGlobal::fatal(void)
{
	/* use an alternate error mechanism */
	/* if already in fatal error */
	if (sys_flags & SYS_IN_FATAL)
		_fatal_exit();
	else
	{
		sys_flags|=SYS_IN_FATAL;
		_fatal_exit();
	}
}

void XGlobal::set_error(CError *Error)
{
	D_ASSERT(Error);
	error=Error;
}