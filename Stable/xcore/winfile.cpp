#include "stdcore.h"

using namespace NS_XFILE;

XMemRdBuffer::XMemRdBuffer(CBaseStream *Stream,U32 size) : XBufferReadInt(Stream),buf_size(size),is_read(0)
{
}

U32 XBufferReadInt::read_direct(void *mem,U32 size,U32 &num_read)
{
	if (!ReadFile(stream->get_handle(),mem,size,&num_read,null))
		return 0;

	stream->pos_rd(num_read,num_read);

	return TRUE;
}

U32 XBufferWriteInt::write_direct(cvoid *mem,U32 size,U32 &num_written)
{
	if (!size)
		return 0;
	
	if (!WriteFile(stream->get_handle(),mem,size,&num_written,null))
		return 0;

	stream->pos_wr(num_written,num_written);

	return TRUE;
}

U32 XFile::std_close(void)
{
	if (handle)
		CloseHandle(handle);

	handle=null;
	return TRUE;
}

U32 XFile::destroy(void)
{
	if (handle)
		CloseHandle(handle);
	handle=null;
	return TRUE;
}

U32 XFile::std_open(void)
{
	SECURITY_ATTRIBUTES security;
	U32 access,share_mode,create;

	access=0;
	if (state.read)
		access|=GENERIC_READ;
	if (state.write)
		access|=GENERIC_WRITE;
	
	create=OPEN_EXISTING;
	if (state.create)
		create=OPEN_ALWAYS;
	if (state.truncate)
		create=CREATE_ALWAYS;

	share_mode=FILE_SHARE_READ|FILE_SHARE_WRITE;

	security.bInheritHandle=TRUE;
	security.lpSecurityDescriptor=null;
	security.nLength=sizeof(SECURITY_ATTRIBUTES);

	handle=CreateFile(name,
					  access,share_mode,
					  &security,
					  create,FILE_ATTRIBUTE_NORMAL,
					  null);
	
	if (((I32)handle)<=0)
		return FALSE;

	if (state.append)
	{
		if (!std_seek(0,FILE_SEEK_END))
		{
			CloseHandle(handle);
			return FALSE;
		}
	}

	state.is_open=TRUE;
	return TRUE;
}

U32 XFile::std_seek(I32 offset,U32 type)
{
	I32 ret;

	switch(type)
	{
		case FILE_SEEK_SET:
			type=FILE_BEGIN;
			break;
		case FILE_SEEK_CUR:
			type=FILE_CURRENT;
			break;
		case FILE_SEEK_END:
			type=FILE_END;
			break;
		default:
			xxx_fatal("XFile::std_seek: invalid type of seek");
			break;
	}
	
	ret=SetFilePointer(handle,offset,null,type);
	if (ret<0)
		return FALSE;

	state.pos_at=ret;
	state.pos_should=ret;
	return TRUE;
}

U32 XFile::load_in_memory(U32 max_size)
{
	if (!state.is_open)
		return FALSE;

	U32 file_size,file_size_high;

	file_size=GetFileSize(handle,&file_size_high);
	if (((I32)file_size)==-1)
		xxx_throw("XFile::load_in_memory: Unable to get file size");

	/* don't handle LARGE file sizes for loading in memory */
	if (file_size_high)
		return FALSE;

	/* if exceeds max size */
	if (file_size > ((U64)max_size))
		return FALSE;

	U32 buf_size=(U32)file_size;

	set_rd_interface(new XMemRdBuffer(this,buf_size));

	return TRUE;
}

#if 0
U32 CBaseStream::write(cvoid *mem,U32 size,U32 &num_written)
{
	U32 num_write;

	if (!size)
		return 0;
	
	if (!WriteFile((HANDLE)handle,mem,size,&num_write,null))
		return 0;

	return num_write;
}

U32 CBaseStream::read(void *mem,U32 size,U32 &num_read)
{
	if (!ReadFile((HANDLE)handle,mem,size,&num_read,null))
		return 0;

	return num_read;
}
#endif

U32 CStdOut::open(void)
{
	base_init();

	handle=GetStdHandle(STD_OUTPUT_HANDLE);
	if (!handle)
		return FALSE;

	set_wr_interface(new XStreamWrDirect(this));
	
	state.is_open=TRUE;

	return TRUE;
}

/* so we don't need the psdk */
#ifndef FILE_ATTRIBUTE_DEVICE
#define FILE_ATTRIBUTE_DEVICE 0x40
#endif

/* probably faster than opening the file up */
U32 __regcall(1) file_exist(CC8 *path)
{
	U32 attr=GetFileAttributes(path);
	
	if (attr==-1)
		return FALSE;

	if (attr&(FILE_ATTRIBUTE_DIRECTORY|FILE_ATTRIBUTE_DEVICE))
		return FALSE;

	return TRUE;
}
