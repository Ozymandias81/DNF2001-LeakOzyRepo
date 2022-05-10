#include "stdcore.h"
#include <winalloc.h>

CMemManage _mem_manage;
extern "C"{
extern void *_gmalloc;
}

/* really not 64 bit ptr safe */
void *CVirtualBase::operator new(size_t size,U32 reserve_size,U32 commit_size)
{
	void *base,*commit;

	base=VirtualAlloc(null,reserve_size,MEM_RESERVE,PAGE_READWRITE);
	if (!base)
	{
		xxx_bitch("CVirtualBase: Unable to reserve base page of memory");
		return null;
	}
	commit=VirtualAlloc(base,commit_size,MEM_COMMIT,PAGE_READWRITE);
	if (!commit)
	{
		xxx_fatal("CVirtualBase: Unable to commit memory");
		return null;
	}
	CVirtualBase *obj=(CVirtualBase *)commit;
	obj->base_address=(U32)commit;
	obj->first_mem=ALIGN_POW2((obj+1),32);
	obj->end_commited=obj->base_address+commit_size;
	obj->reserve_size=reserve_size;
	obj->commit_size=commit_size;
	return commit;
}

/* FIXUP */
void CVirtualBase::operator delete(void *ptr)
{
	_asm int 3
}

void CVirtualBase::operator delete(void *ptr,U32 reserve_size,U32 commit_size)
{
	_asm int 3
}

CVirtualBlock::CVirtualBlock(void) : next(null)
{
}

void *CVirtualBlock::operator new(size_t size,U32 reserve_size)
{
	/* align reservation of private memory data to 4M */
	reserve_size=ALIGN_POW2(reserve_size,4*1024*1024);

	void *base=VirtualAlloc(null,reserve_size,MEM_RESERVE,PAGE_READWRITE);
	if (!base)
	{
		xxx_bitch("CVirtualBase: Unable to reserve base page of memory");
		return null;
	}
	D_ASSERT(_gmalloc);
	CVirtualBlock *obj=(CVirtualBlock *)_mem_manage.private_alloc(size);
	obj->address=base;
	obj->size=reserve_size;

	return obj;
}

CVirtualBase::CVirtualBase(void)
{
}

CMemManage::CMemManage(void)
{
}

U32 CMemManage::init(void)
{
#if 0
	_gmalloc=this;

	/* allocate private memory block */
	base=new(16*1024*1024,8*1024) CVirtualBase();
	if (!base)
		xxx_fatal("CMemManage::init: Unable to allocate required memory");

	cur=base->first_mem;
	end=base->end_commited;

	end-=sizeof(CommitBlock);

	CVirtualBlock *block;

	/* primary block */
	block=new(64*1024*1024) CVirtualBlock();
	if (!block)
		xxx_fatal("CMemManage::init: Unable to allocate required memory");
	primary=block;

	/* large block */
	block=new(32*1024*1024) CVirtualBlock();
	if (!block)
		xxx_fatal("CMemManage::init: Unable to allocate required memory");
	large=block;

	small_allocs[0]=alloc_8;
	small_allocs[1]=alloc_16;
	small_allocs[2]=alloc_32;
	small_allocs[3]=alloc_64;
	small_allocs[4]=alloc_96;
	small_allocs[5]=alloc_128;
	small_allocs[6]=alloc_192;
	small_allocs[7]=alloc_256;
#endif
	return TRUE;
}

U32 CMemManage::close(void)
{
#if 0
	/* free primary memory blocks */
	while(primary)
	{
		CVirtualBlock *tmp;
		
		tmp=primary->next;
		delete primary;
		primary=tmp;
	}
	/* free large memory blocks */
	while(large)
	{
		CVirtualBlock *tmp;
		
		tmp=large->next;
		delete primary;
		large=tmp;
	}
	/* free private memory */
	delete base;
	base=null;

	_gmalloc=null;
#endif
	return TRUE;
}

void *CMemManage::private_alloc(U32 size)
{
	cur=ALIGN_POW2(cur,32);
	void *ret=(void *)cur;

	if ((cur+size) > end)
		commit_more(size);

	cur+=size;
	return ret;
}

void CMemManage::commit_block(CommitBlock *block,U32 size)
{
	size=ALIGN_POW2(size,page_size);

	void *page=VirtualAlloc((void *)end,size,MEM_COMMIT,PAGE_READWRITE);
	
	block->address=(U32)page;
	block->size=size;
	block->next=committed;
}

void CMemManage::commit_more(U32 size)
{
	if (free_commit)
	{
		commit_block(free_commit,size);
		free_commit=free_commit->next;
		return;
	}
}

#if 0
void CMemManage::expand_small(void)
{
	if ((cur_small+SMALL_BLOCK_SIZE) < cur_large))
		cur_small+=SMALL_BLOCK_SIZE;

	if (cur_small > commit_left)
}
#endif

void *CMemManage::alloc_8(CMemManage *This)
{
#if 0
	if (!hole)
		expand_small();

	obj=small_hole;
	if (small_hole->next)
	{
		small_hole->next->down=small_hole->down;
		small_hole=small_hole->next;
	}
	else
		small_hole=small_hole->down;
	/* make hole available */
	obj->next=hole_avail;
	hole_avail=hole;
	
	return obj->address;
#endif
	return null;
}

void *CMemManage::alloc_16(CMemManage *This)
{
	return null;
}

void *CMemManage::alloc_32(CMemManage *This)
{
	return null;
}

void *CMemManage::alloc_64(CMemManage *This)
{
	return null;
}

void *CMemManage::alloc_96(CMemManage *This)
{
	return null;
}

void *CMemManage::alloc_128(CMemManage *This)
{
	return null;
}

void *CMemManage::alloc_192(CMemManage *This)
{
	return null;
}

void *CMemManage::alloc_256(CMemManage *This)
{
	return null;
}

void *CMemManage::alloc_large(U32 size)
{
	return null;
}

void *CMemManage::alloc_huge(U32 size)
{
	return null;
}

void CMemManage::free(void *ptr)
{
}

void _mem_debug_init(void);
void _mem_debug_close(void);

void _mem_init(void)
{
	_mem_manage.init();
	_mem_debug_init();
}

void _mem_close(void)
{
	_mem_debug_close();
	_mem_manage.close();
}
