#include "stdcore.h"
#include "malloc.h"

#ifdef DEBUG
	#ifndef MEM_DEBUG
	#define MEM_DEBUG
	#endif
	#ifndef MEM_TRACK
	#define MEM_TRACK
	#endif
#endif

#undef MEM_TRACK
//#undef MEM_DEBUG

#if 0
extern "C"{
	void * __fastcall _xalloc(U32 size);
	void * __fastcall _xfree(void *ptr);
}
#else
#define _xalloc(x) ::malloc(x)
#define _xfree(x) ::free(x)
#endif

class MemDebug;

class MallocInfo
{
public:
	U32 *ptr;
	U32	size;

	MallocInfo *next;
	MallocInfo *prev;
private:
	void *operator new(size_t size){}
	void operator delete(void *ptr){}
public:
	MallocInfo(void){}
	MallocInfo(void *ptr,U32 size);
	~MallocInfo(void);

	void *operator new(size_t size,MemDebug *This);
	void operator delete(void *ptr,MemDebug *This);
};

#define MALLOC_BLOCK_SIZE 512

class MallocBlock
{
public:
	U8			info_block[MALLOC_BLOCK_SIZE * sizeof(MallocInfo)];
	MallocInfo	*info;

	MallocBlock	*next;
	MallocBlock	*prev;
public:
	MallocBlock(void){info=(MallocInfo *)&info_block[0];}
	void *operator new(size_t size);
	void operator delete(void *ptr);
};

class MemDebug
{
	U32 num_mallocs;
	U32 num_frees;
	U32 active_count;
	U32 closed;

	XChain<MallocInfo>	free_list;
	XChain<MallocInfo>	used_list;
	
	XChain<MallocBlock>	block_list;

	void alloc_block(void);
	MallocInfo *find_ptr(void *ptr);

public:
	MemDebug(void) : active_count(0),closed(0),free_list(0),used_list(0) {}
	
	void init(void);
	void close(void);

	void *alloc(U32 size);
	void free(void *ptr);

	MallocInfo *alloc_info(void);
	void free_info(MallocInfo *ptr);
	U32 leak(void);
};

MemDebug *mem_debug=null;
MemDebug *mem_debug2=null;
MemDebug *mem_debug3=null;
MemDebug *mem_debug4=null;

void _mem_debug_init(void)
{
	mem_debug=(MemDebug *)malloc(sizeof(MemDebug));
	mem_debug->MemDebug::MemDebug();
	mem_debug2=(MemDebug *)malloc(sizeof(MemDebug));
	mem_debug2->MemDebug::MemDebug();
	mem_debug3=(MemDebug *)malloc(sizeof(MemDebug));
	mem_debug3->MemDebug::MemDebug();
	mem_debug4=(MemDebug *)malloc(sizeof(MemDebug));
	mem_debug4->MemDebug::MemDebug();
}

void _mem_debug_close(void)
{
	if (!mem_debug)
		return;

	mem_debug->close();
	free(mem_debug);
	mem_debug2->close();
	free(mem_debug2);
	mem_debug3->close();
	free(mem_debug3);
	mem_debug4->close();
	free(mem_debug4);
	
	mem_debug=null;
	mem_debug2=null;
	mem_debug3=null;
	mem_debug4=null;
}

MallocInfo::MallocInfo(void *Ptr,U32 Size)
{
	ptr=(U32 *)Ptr;
	size=Size;

	ptr[0]=0xdeadcafe;
	ptr++;
	
	U32 *end=(U32 *)(((U32)ptr)+size);
	end[0]=0xdeadcafe;
}

MallocInfo::~MallocInfo(void)
{
	if (ptr[-1]!=0xdeadcafe)
		xxx_throw("MallocInfo: Memory Overflow low");
	
	U32 *end=(U32 *)(((U32)ptr)+size);
	if (end[0]!=0xdeadcafe)
		xxx_throw("MallocInfo: Memory Overflow high");
}

void *MallocBlock::operator new(size_t size)
{
	return _xalloc(size);
}

void MallocBlock::operator delete(void *ptr)
{
	_xfree(ptr);
}

void MemDebug::init(void)
{
	active_count=0;
	closed=0;

	num_mallocs=0;
	num_frees=0;

	alloc_block();
}

void MemDebug::alloc_block(void)
{
	MallocBlock *block=new MallocBlock;
	block_list.add_head(block);

	for (U32 i=0;i<MALLOC_BLOCK_SIZE;i++)
	{
		free_list.add_head(&block->info[i]);
	}
}

volatile U32 dev_val=0;

void MemDebug::close(void)
{
	block_list.free_list();
	closed=TRUE;
}

void *MemDebug::alloc(U32 size)
{
	void *mem=_xalloc(size+8);

	MallocInfo *info=new(this) MallocInfo(mem,size);

	used_list.add_head(info);

	if ((U32)info->ptr==0x0393eb34)
		dev_val++;
	if ((U32)info->ptr==0x0393e80c)
		dev_val++;
	if ((U32)info->ptr==0x038b15ac)
		dev_val++;

	active_count++;
	return (void *)info->ptr;
}

U32 _deb_free=0xdeadcafe;

void MemDebug::free(void *ptr)
{
	if (closed)
		xxx_bitch("MemDebug::free: already closed");

	if ((U32)ptr==_deb_free)
		dev_val++;
	MallocInfo *info=find_ptr(ptr);
	if (!info)
		xxx_throw("MemDebug::free: Unable to find handle to memory");

	info->~MallocInfo();
	MallocInfo::operator delete(info,this);

	active_count--;
}

MallocInfo *MemDebug::find_ptr(void *ptr)
{
	MallocInfo *info=used_list.get_head();
	while(info)
	{
		if (info->ptr==((U32 *)ptr))
			return info;

		info=used_list.get_next(info);
	}
	return null;
}

void *MallocInfo::operator new(size_t size,MemDebug *This)
{
	MallocInfo *info=This->alloc_info();

	return info;
}

void MallocInfo::operator delete(void *ptr,MemDebug *This)
{
	This->free_info((MallocInfo *)ptr);
}

MallocInfo *MemDebug::alloc_info(void)
{
	MallocInfo *free=free_list.remove_head();
	if (!free)
	{
		alloc_block();
		free=free_list.remove_head();
	}

	return free;
}

void MemDebug::free_info(MallocInfo *info)
{
	used_list.remove(info);
	free_list.add_head(info);
}

U32 MemDebug::leak(void)
{
	MallocInfo *obj=used_list.get_head();
	
	U32 count=0;
	while(obj)
	{
		obj=used_list.get_next(obj);
		count++;
	}
	return count;
}

U32 _test_leak(void)
{
	return mem_debug->leak();
}

class CTrackObj
{
public:
	char *ptr;
	U32 size;

	void check_tags(void)
	{
		U32 *tmp,*tmp2;

		tmp=(U32 *)(ptr-4);
		tmp2=(U32 *)(ptr+size);
		if (*tmp!=0xdeadcafe)
			xxx_bitch("whooznat");
		if (*tmp2!=0xdeadbeef)
			xxx_bitch("wheezer");
	}
	void set_tags(void)
	{
		U32 *tmp,*tmp2;

		tmp=(U32 *)(ptr-4);
		tmp2=(U32 *)(ptr+size);

		*tmp=0xdeadcafe;
		*tmp2=0xdeadbeef;
	}
};

class CTrackList
{
	CTrackObj list[1024];
	U32 active;
	U32 total_mem;
public:
	CTrackList(void){active=0;total_mem=0;}
	void alloc(char *ptr,U32 size);
	void free(char *ptr);
};

void CTrackList::alloc(char *ptr,U32 size)
{
	list[active].ptr=ptr;
	list[active].size=size;
	list[active].set_tags();
	active++;
	total_mem+=size;
}

void CTrackList::free(char *ptr)
{
	for (U32 i=0;i<active;i++)
	{
		if (list[i].ptr==ptr)
		{
			list[i].check_tags();
			list[i].ptr=null;
			return;
		}
	}
	xxx_bitch("Whizzer not found");
}

CTrackList track_list;

U32 _active_count=0;

void _xheap_check(void)
{
	U32 res=_heapchk();

	if ((res!=_HEAPOK)&&(res!=_HEAPEMPTY))
	{
		switch (res)
		{
			case _HEAPBADPTR:
				xxx_bitch( "ERROR - bad pointer to heap\n" );
				break;
			case _HEAPBADBEGIN:
				xxx_bitch( "ERROR - bad start of heap\n" );
				break;
			case _HEAPBADNODE:
				xxx_bitch( "ERROR - bad node in heap\n" );
				break;
		}
		xxx_bitch("Heap is broken");
	}

	_HEAPINFO hinfo;
	int heapstatus;
	hinfo._pentry = NULL;
	
	while( ( heapstatus = _heapwalk( &hinfo ) ) == _HEAPOK );

	if (heapstatus==_HEAPEMPTY)
		return;

	if (heapstatus==_HEAPEND)
		return;

	switch( heapstatus )
	{
		case _HEAPBADPTR:
			xxx_bitch( "ERROR - bad pointer to heap\n" );
			break;
		case _HEAPBADBEGIN:
			xxx_bitch( "ERROR - bad start of heap\n" );
			break;
		case _HEAPBADNODE:
			xxx_bitch( "ERROR - bad node in heap\n" );
			break;
	}
}

voidp __regcall(1) xmalloc(U32 size)
{
	void *ptr;

#ifdef MEM_DEBUG
	ptr=mem_debug->alloc(size);
#else
	D_ASSERT(size);
	ptr=_xalloc(size);
#endif
#ifdef MEM_TRACK
	_global->stats.add_alloc();
#endif
	_active_count++;
	if ((U32)ptr==0x01343890)
		dev_val++;
	if ((U32)ptr==0x01343030)
		dev_val++;
	
	return ptr;
}

voidp __regcall(1) xrealloc(void *ptr,U32 size)
{
	_asm int 3
	return ptr;
}

voidp __regcall(1) xmalloc_tmp(U32 size)
{
#ifdef MEM_DEBUG
	return mem_debug->alloc(size);
#else
	return _xalloc(size+8);
#endif
}

void __regcall(1) xfree(void *ptr)
{
	if (!ptr)
		return;

	if ((U32)ptr==0x01343890)
		dev_val++;
#ifdef MEM_DEBUG
	mem_debug->free(ptr);
#else
	_xfree(ptr);
#endif
}

voidp __regcall(1) xmalloc2(U32 size)
{
	void *ptr;
#ifdef MEM_DEBUG
	ptr=mem_debug2->alloc(size);
#else
	ptr=_xalloc(size+8);
#endif
#ifdef MEM_TRACK
	_global->stats.add_alloc2();
#endif
	return ptr;
}

void __regcall(1) xfree2(void *ptr)
{
	if (!ptr)
		return;
#ifdef MEM_DEBUG
	mem_debug2->free(ptr);
#else
	_xfree(ptr);
#endif
}

voidp __regcall(1) xmalloc3(U32 size)
{
	void *ptr;
#ifdef MEM_DEBUG
	ptr=mem_debug3->alloc(size);
#else
	ptr=_xalloc(size+8);
#endif
#ifdef MEM_TRACK
	_global->stats.add_alloc3();
#endif
	return ptr;
}

void __regcall(1) xfree3(void *ptr)
{
	if (!ptr)
		return;
#ifdef MEM_DEBUG
	mem_debug3->free(ptr);
#else
	_xfree(ptr);
#endif
}

voidp __regcall(1) xmalloc4(U32 size)
{
#ifdef MEM_DEBUG
	return mem_debug4->alloc(size);
#else
	return _xalloc(size+8);
#endif
}

void __regcall(1) xfree4(void *ptr)
{
	if (!ptr)
		return;
#ifdef MEM_DEBUG
	mem_debug4->free(ptr);
#else
	_xfree(ptr);
#endif
}

CMallocBlock::~CMallocBlock(void)
{
   if (cur!=num_blocks)
      xxx_bitch("Never fully allocated");
}

void *CMallocBlock::get_next(void)
{
	if (cur>=num_blocks)
	{
		xxx_throw("CMallocBlock::get_next: attempted to get more blocks than allocated");
		return null;
	}

	return ((void *)(list_base())[cur++]);
}

void *CMallocBlock::operator new(size_t size,U32 num,CU32 *list,U32 align)
{
	CMallocBlock   *obj;
	U32 i,size_align,addr,*ptr_list;

	D_ASSERT(num<256);
	D_ASSERT(IS_POW2(align));
	D_ASSERT(align<=128);

	U32 tmp_mask=align - 1;
	U32 tmp_not=~tmp_mask;
	size_align=align - 1;

	for (i=0,size=0;i<num;i++)
	{
		U32 tmp=list[i],tmp2;

		tmp2=tmp&tmp_mask;

		size_align+=((tmp2 + tmp_mask) & tmp_not) - tmp2;

		size+=tmp;
	}
	/* add room for worst case alignment */
	size+=size_align;
	/* make room for object itself */
	size+=sizeof(CMallocBlock);
	/* make room for the ptr list */
	size+=num*4;
	obj=(CMallocBlock *)xmalloc(size);

	obj->num_blocks=(U8)num;
	obj->align_size=(U8)align;

	/* setup ptr list */
	ptr_list=(U32 *)(obj+1);
	addr=((U32)ptr_list)+num*4;
	/* align ptrs to align value */
	addr=ALIGN_POW2(addr,align);
	for (i=0;i<num;i++)
	{
		ptr_list[i]=addr;
		if (!list[i])
			ptr_list[i]=null;
		addr=ALIGN_POW2((addr + list[i]),align);
	}
	if (addr > (((U32)obj)+size))
		xxx_throw("CMallocBlock::new: final address is bad");

	return obj;
}

