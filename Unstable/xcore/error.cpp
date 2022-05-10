#include "stdcore.h"
#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>
#include <malloc.h>

#if 0
default types of error output

If console app use console output
if !console app, check to see if a local log process is active
if !local log process, then fall back to Win32 Message boxes.

console output
	> Stdout

local log process
	> Can look like anything really, even a console
	> Will require IPC, memory mapping messaging

message boxes
	> Win Gui boxes
	> ? Maybe specail gui boxes?
#endif

void __regcall(1) xxx_throw(CC8 *string)
{
	if (_global)
		_global->throw_msg(ERROR_NORMAL,string);
	else
	{
		WinMessage(GetForegroundWindow(),string);
		exit(1);
	}
}

void __regcall(2) xxx_throw_level(U32 level,CC8 *string)
{
	if (_global)
		_global->throw_msg(level,string);
	else
	{
		WinMessage(GetForegroundWindow(),string);
		exit(1);
	}
}

void __regcall(1) xxx_bitch(CC8 *string)
{
	if (_global)
		_global->message(ERROR_BITCH,string);
	else
		WinMessage(GetForegroundWindow(),string);
}

void __regcall(1) xxx_fatal(CC8 *string)
{
	if (_global)
		_global->message(ERROR_FATAL,string);
	else
	{
		WinMessage(GetForegroundWindow(),string);
		exit(1);
	}
}

void __regcall(2) xxx_message(U32 error_level,CC8 *string)
{
	if (_global)
		_global->message(error_level,string);
	else
	{
		WinMessage(GetForegroundWindow(),string);
		exit(1);
	}
}

void xxx_printf_noglobal(U32 error_level,CC8 *string,...)
{
	va_list  args;
	I32      num;

	va_start(args,string);

	char *mem=(char *)_alloca(512);

	num=_vsnprintf(mem,511,string,args);

	va_end(args);

	WinMessage(GetForegroundWindow(),string);
	exit(1);
}

#if 0
void xxx_printf(U32 error_level,CC8 *string,...)
{
}
#endif

void CError::assert(CC8 *file,U32 line)
{
	_asm int 3
}

void CError::throw_msg(U32 level,CC8 *str)
{
	_asm int 3
	throw;
}

void CError::message(U32 level,CC8 *str)
{
	_asm int 3
}

void ConMessage(CC8 *string)
{
	printf("%s",string);
}

