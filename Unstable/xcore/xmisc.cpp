#include "stdcore.h"

RingBuffer::RingBuffer(cvoid *mem,U32 Size)
{
	mem_base=(char *)mem;
	size=Size;
	mem_end=mem_base+Size;
	write_ptr=mem_base;
	read_ptr=mem_base;
}

void RingBuffer::adjust_read(U32 amount)
{
	char *cur=read_ptr;

	cur+=amount;
	if (cur > mem_end)
		cur-=size;

	read_ptr=cur;
	depth_write-=amount;
}

U32 RingBuffer::get_room(void)
{
	U32 room;

	if (write_ptr>=read_ptr)
	{
		if ((write_ptr==read_ptr) && depth_write)
			return 0;
		room=mem_end - write_ptr;
		return room;
	}
	room=read_ptr - write_ptr;
	return room;
}

U32 RingBuffer::get_total_room(void)
{
	U32 room;
	if (write_ptr>=read_ptr)
	{
		if ((write_ptr==read_ptr) && depth_write)
			return 0;
		room=mem_end - write_ptr;
		room+=(U32)(read_ptr - mem_base);
		return room;
	}
	room=read_ptr - write_ptr;
	return room;
}

void RingBuffer::wrap(void)
{
	write_ptr=mem_base;
}

U32 RingBuffer::write(cvoid *mem,U32 size)
{
	U32 total_size=size;

	while(size)
	{
		U32 room,working_size;

		room=get_room();
		
		working_size=size;
		if (working_size>room)
			working_size=room;
		memcpy(write_ptr,mem,working_size);
		size-=working_size;
		write_ptr+=working_size;
		depth_write+=working_size;
		if (write_ptr==mem_end)
			wrap();
	}
	return total_size;
}

void MemGrow::realloc(U32 inc_size)
{
	char *new_base=(char *)xmalloc(size+inc_size);
	memcpy(new_base,base,size);
	xfree(base);
	base=new_base;
	size=size+inc_size;
}
