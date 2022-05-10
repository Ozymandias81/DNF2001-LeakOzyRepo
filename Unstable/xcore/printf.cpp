#include "stdcore.h"

U32 CPrintf::fstrcpy_lim(CC8 *src)
{
	U32 i,src_size;

	if (size==0)
	{
		src_size=fstrlen(src);
		if (src[0])
			flags=(flags|PRINT_FULL) + src_size;
		return 0;
	}

	for(i=0;i<size+1;i++)
	{
		*cur++=*src++;
		if (src[-1]==0)
		{
			size-=i;cur--;
			return i;
		}
	}
	cur--;src--;
	src_size=fstrlen(src);
	size=0;
	cur[0]=0;
	flags=(flags|PRINT_FULL) + src_size;
	return i - 1;
}

U32 CPrintf::fstrncpy_lim(CC8 *src,U32 src_size)
{
	U32 i,tmp_size;

	if (size==0)
	{
		if (src[0])
			flags=(flags|PRINT_FULL) + src_size;
		return 0;
	}

	tmp_size=src_size;
	if (src_size>(size+1))
		tmp_size=size+1;

	for(i=0;i<tmp_size;i++)
	{
		*cur++=*src++;
		if (src[-1]==0)
		{
			size-=i;cur--;
			return i;
		}
	}
	size-=tmp_size-1;
	cur--;src--;
	cur[0]=0;
	if (!size)
		flags=(flags|PRINT_FULL) + (src_size - tmp_size);

	return i;
}

U32 CPrintf::num(U32 val)
{
	char num_str[13];

	fitoa(val,num_str);
	return fstrcpy_lim(num_str);
}

U32 CPrintf::num(I32 val)
{
	char num_str[13];

	fitoa(val,num_str);
	return fstrcpy_lim(num_str);
}

U32 CPrintf::chr(char val)
{
	if (size<1)
	{
		if (val)
		{
			flags|=PRINT_FULL;
			flags+=1;
		}
		cur[0]=0;
		return 0;
	}

	cur[0]=val;
	cur[1]=0;
	cur++;
	size--;
	return 1;
}

U32 CPrintf::hex(U32 num)
{
	char num_str[12];
	U32 len;

	len=hex32(num,num_str);

	fstrcpy_lim(num_str);

	return len;
}

U32 CPrintf::hex64(U64 num)
{
	char num_str[20];
	U32 len;

	len=::hex64(num,num_str);

	fstrcpy_lim(num_str);

	return len;
}

U32 CPrintf::add_path(CC8 *str)
{
	if (cur==dst)
		goto skip;
	if (cur[-1]!=OS_SLASH)
		*this << OS_SLASH;
skip:
	*this << str;
	return TRUE;
}

class PrintfManage
{
protected:
	XList<CPrintfT>		full_list;
	XChain<CPrintfT>	hash[5];

	CPrintfT *alloc(U32 index,U32 size);

	CPrintfT *get_large(U32 size)
	{
		CPrintfT *cur;

		cur=hash[4].get_head();
		while(cur)
		{
			if (cur->start_size >= size)
				return hash[4].remove(cur);
		}
		return alloc(4,size);
	}
	CPrintfT *get_normal(U32 index)
	{
		U32 tmp_index=index;
		CPrintfT *cur;

		cur=hash[index].get_head();
		while(!cur)
		{
			tmp_index++;
			if (tmp_index==4)
				return alloc(index,(128<<index));

			cur=hash[tmp_index].get_head();
		}
		/* if size disparity 2x, alloc new size */
		if ((tmp_index-index)>1)
			return alloc(index,(128<<index));

		/* else found one */
		return hash[tmp_index].remove(cur);
	}

public:
	PrintfManage(void);
	~PrintfManage(void){flush_all();}

	CPrintfT *get(U32 size)
	{
		if (size >= 2048)
			return get_large(size);

		U32 index,bsize;

		bsize=128;
		index=0;
		while(size > bsize)
		{
			bsize<<=1;
			index++;
		}
		return get_normal(index);
	}
	void release(CPrintfT *obj)
	{
		U32 size=obj->start_size;

		if (size>2048)
		{
			hash[4].add_head(obj);
			return;
		}

		U32 index=_bsf(size) - 7;

		hash[index].add_head(obj);
		obj->reset();
	}
	void flush_all(void);
};

PrintfManage _printf_manage;

CPrintfT::CPrintfT(CMallocBlock *_block,U32 _size)
  : block(_block),next(null),prev(null),alloc_next(null)
{
	CPrintf::init((char *)block->get_next(),_size);
}

void CPrintfT::free_mem(void *ptr)
{
	CMallocBlock *block=((CPrintfT *)ptr)->block;

	delete block;
}

PrintfManage::PrintfManage(void)
{
}

void PrintfManage::flush_all(void)
{
	full_list.free_list();
	for (U32 i=0;i<5;i++)
		hash[i].lose_list();
}

/* does not attach to hash table, only release does */
CPrintfT *PrintfManage::alloc(U32 index,U32 size)
{
	U32 list[2]={sizeof(CPrintfT),size};
	CMallocBlock *block;
	CPrintfT     *obj;

	D_ASSERT(index<5);

	block=new(2,list,4) CMallocBlock;
	obj=(CPrintfT *)block->get_next();
	obj=new(obj) CPrintfT(block,size);

	/* add to list, so we can free it */
	full_list.add_head(obj);

	return obj;
}

CPrintfT *get_printf(U32 size)
{
	return _printf_manage.get(size);
}

void release_printf(CPrintfT *obj)
{
	_printf_manage.release(obj);
}

void _flush_printf_mem(void)
{
	_printf_manage.flush_all();
}

