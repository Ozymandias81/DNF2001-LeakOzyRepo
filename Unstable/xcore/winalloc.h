#ifndef _WINALLOC_H_
#define _WINALLOC_H_

enum mem_sizes_enum
{
	SMALL_BLOCK_SIZE	= 512,
	MIN_PAGE_SIZE		= 8192
};

class CMemPage;
class CMemManage;

/* used for private memory pool */
/* special since it reserves space for itself out of Virtual Alloc'd block */
class CVirtualBase
{
public:
	U32	base_address;
	U32 reserve_size;
	U32 commit_size;

	U32 end_commited;
	U32 first_mem;

private:
	void *operator new(size_t size);
	void operator delete(void *ptr);

public:
	void *operator new(size_t size,U32 reserve_size,U32 commit_size);
	void operator delete(void *ptr,U32 reserve_size,U32 commit_size);

	CVirtualBase(void);
};

/* used for application specific needs */
class CVirtualBlock
{
	void *address;
	U32 size;

public:
	CVirtualBlock *next;

private:
	void *operator new(size_t size);
	void operator delete(void *ptr){}
public:
	void *operator new(size_t size,U32 reserve_size);
	void operator delete(void *ptr,U32 reserve_size){} /* mem never freed */

	CVirtualBlock(void);
};

class CMemHandle
{
	void		*ptr;
	U32			size;
	U32			flags;
	CMemPage	*page;
public:
	CMemHandle	*next;
	CMemHandle	*prev;
public:
	virtual void free(void *ptr);
};

class CMemHandleBlock
{
	U32			used;
	CMemHandle	*handle_array;
};

/* one or more pages in memory allocated with a commit call */
class CMemPage
{
	U32 size;
};

class XMemHole
{
	XMemHole *next;
	XMemHole *next_layer;
};

class CommitBlock
{
public:
	U32 address;
	U32 size;

	CommitBlock *next;
};

typedef void *(__fastcall * sm_alloc_f)(CMemManage *This);

class CMemManage
{
public:
	sm_alloc_f		small_allocs[8];
	XMemHole		*small_hole;
	XMemHole		*hole_avail;

	U32				page_size;

	CVirtualBase	*base;
	CVirtualBlock	*primary;
	CVirtualBlock	*large;

	CommitBlock		*committed;
	CommitBlock		*free_commit;

	/* ptr to end of allocated private heap */
	U32				cur;
	/* end of committed private heap */
	U32				end;

private:
	static void * __fastcall alloc_8(CMemManage *This);
	static void * __fastcall alloc_16(CMemManage *This);
	static void * __fastcall alloc_32(CMemManage *This);
	static void * __fastcall alloc_64(CMemManage *This);
	static void * __fastcall alloc_96(CMemManage *This);
	static void * __fastcall alloc_128(CMemManage *This);
	static void * __fastcall alloc_192(CMemManage *This);
	static void * __fastcall alloc_256(CMemManage *This);

	void commit_more(U32 size);
	void commit_block(CommitBlock *block,U32 size);
	void free(void *ptr);

public:
	CMemManage(void);
	U32 init(void);
	U32 close(void);
	/* private memory is never freed */
	void *private_alloc(U32 size);

	void *alloc_handle(void);
	void free_handle(void *ptr);
	
	void *alloc_hole(void);
	void free_hole(void *ptr);

	void *alloc_large(U32 size);
	void *alloc_huge(U32 size);
};

#endif /*ifndef _WINALLOC_H_ */