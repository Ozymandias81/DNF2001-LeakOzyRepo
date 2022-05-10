#include "stdcore.h"

using namespace NS_XFILE;

#pragma intrinsic(strlen)

void CBaseStream::base_init(void)
{
	state.XStreamState::XStreamState();
	handle=null;
	rd_int=null;
	wr_int=null;
}

void CBaseStream::set_rd_interface(XBufferReadInt *rd)
{
	delete rd_int;
	rd_int=rd;
}

void CBaseStream::set_wr_interface(XBufferWriteInt *wr)
{
	if (wr_int)
		wr_int->flush();

	delete wr_int;
	wr_int=wr;
}

U32 CBaseStream::write(cvoid *mem,U32 size,U32 &num_written)
{
	D_ASSERT(wr_int);
	U32 ret,direct_write;
	ret=wr_int->write(mem,size,num_written,direct_write);
	return ret;
}

U32 CBaseStream::read(void *mem,U32 size,U32 &num_read)
{
	D_ASSERT(rd_int);
	U32 ret,direct_read;
	ret=rd_int->read(mem,size,num_read,direct_read);
	return ret;
}

U32 XStreamRdDirect::read(void *mem,U32 size,U32 &num_copied,U32 &num_read)
{
	num_copied=0;
	if (!read_direct(mem,size,num_read))
		return FALSE;
	num_copied=num_read;
	return TRUE;
}

U32 XStreamWrDirect::write(cvoid *mem,U32 size,U32 &num_copied,U32 &num_written)
{
	num_copied=0;
	if (!write_direct(mem,size,num_written))
		return FALSE;
	num_copied=num_written;
	return TRUE;
}

U32 XMemRdBuffer::read(void *mem,U32 size,U32 &num_copied,U32 &num_read)
{
	if (!mem_buffer)
	{
		D_ASSERT(buf_size);
		mem_buffer=(char *)xmalloc(buf_size);
	}
	/* read in the whole thing */
	if (!is_read)
	{
		if (!read_direct(mem_buffer,buf_size,num_read))
			return FALSE;
		/* adjust for where read ptr should be */
		stream->pos_rd((-(I32)num_read),0);
		if (num_read!=buf_size)
			xxx_throw("XMemRdBuffer::read: read in less than whole file");
		cur=mem_buffer+stream->get_pos();
		is_read=TRUE;
	}
	D_ASSERT(cur>=(char *)mem_buffer);
	if ((cur+size) > (mem_buffer+buf_size))
		size=(U32)(mem_buffer + buf_size - cur);
	memcpy(mem,cur,size);
	cur+=size;
	num_copied=size;
	/* adjust position */
	stream->pos_rd(size,0);
	return TRUE;
}

U32 XMemRdBuffer::seek(I32 delta_pos)
{
	cur+=delta_pos;
	return TRUE;
}

CBaseStream &CBaseStream::operator << (CC8 *str)
{
	U32 len;

	len=strlen(str);
	if (!write(str,len))
		xxx_throw("CBaseStream(CC8 *): write to file failed");

	return *this;
}

CBaseStream &CBaseStream::operator << (U32 num)
{
	char num_str[12];
	U32 len;

	len=fitoa(num,num_str);
	if (!write(num_str,len))
		xxx_throw("CBaseStream(U32): write to file failed");

	return *this;
}

CBaseStream &CBaseStream::operator << (char val)
{
	if (!put(val))
		xxx_throw("CBaseStream(char): write to file failed");

	return *this;
}

U32 CBaseStream::write(cvoid *mem,U32 size)
{
	U32 num_write;

	if (!write(mem,size,num_write))
		state.error=FERROR_WRITE;

	return num_write;
}

U32 CBaseStream::read(void *mem,U32 size)
{
	U32 num_read;

	if (!read(mem,size,num_read))
		state.error=FERROR_READ;

	return num_read;
}

/* buffering not supported yet */
U32 CBaseStream::flush(void)
{
	return TRUE;
}
