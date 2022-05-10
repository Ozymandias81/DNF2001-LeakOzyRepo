#include <xtypes.h>
#include <stdio.h>
#include "winalloc.h"

int main(void)
{
	U32 page_size=oof(CMemManage,page_size);
	U32 small_alloc=oof(CMemManage,small_allocs);

	printf("%%define PAGE_SIZE_OFF %d\n",page_size);
	printf("%%define ALLOC_OFF %d\n",small_alloc);
	printf("%%define BLOCK_NEXT_OFF %d\n",oof(CVirtualBlock,next));

	fflush(stdout);
	return 0;
}