#include "stdcore.h"

typedef struct _XPosList
{
	_XPosList *next,*prev;
	void *data;
}XPosList;

typedef struct
{
	XPosList	*head;
	XPosList	*tail;
	XPosList	*free;
	XNodeBlock	*block;
	XListState	xlist_state;
	U32			count;
}XListData;

voidp __regcall(2) xlist_new_node(void *_This,U32 xnode_size)
{
	XListData *This=(XListData *)_This;
	I32 num=This->xlist_state.block_size;

	XNodeBlock *block=(XNodeBlock *)(xmalloc(sizeof(XNodeBlock) + (xnode_size * num)));
	/* add to chain of blocks */
	block->next=This->block;
	This->block=block;

	XPosList *first=(XPosList *)(block+1);
	XPosList *node=first;
	/* setup free Nodes */
	while(--num)
	{
		XPosList *next=(XPosList *)(((U32)node)+xnode_size);

		node->next=next;
		node=next;
	}
	/* last Node points to nuthin */
	node->next=null;
	/* attach free nodes to list */
	D_ASSERT(!(This->free));
	This->free=first->next;
	return first;
}

void __regcall(1) xlist_free_nodes(void *_This)
{
	XListData *This=(XListData *)_This;

	XNodeBlock *block=This->block;

	while(block)
	{
		XNodeBlock *next;

		next=block->next;
		xfree(block);
		block=next;
	}
	This->block=null;
	This->free=null;
}

class XTreeNode;
class XTreeLevel;
class XFreeNode;

class XTreeData
{
public:
	XTreeNode	*root;
	XFreeNode	*free;
	XNodeBlock	*block;
	U32			block_size;
};

class XTreeLevel
{
public:
	XTreeNode	*head;
	XTreeNode	*tail;
	XTreeNode	*parent;
	
	void *reserved1;
	void *reserved2;
};

class XTreeNode
{
public:
	XTreeNode	*next;
	XTreeNode	*prev;
	XTreeLevel	*level;
	XTreeLevel	*child;
	
	void *data;
};

class XFreeNode
{
public:
	void *reserved1;
	void *reserved2;
	void *reserved3;
	void *reserved4;
	
	XFreeNode *next;
};

voidp __regcall(2) xtree_new_node(void *_This,U32 xnode_size)
{
	D_ASSERT(_This);

	XTreeData *This=(XTreeData *)_This;
	I32 num=This->block_size;

	XNodeBlock *block=(XNodeBlock *)(xmalloc(sizeof(XTreeNode) + (xnode_size * num)));
	/* add to chain of blocks */
	block->next=This->block;
	This->block=block;

	XFreeNode *first=(XFreeNode *)(block+1);
	XFreeNode *node=first;
	/* setup free Nodes */
	while(--num)
	{
		XFreeNode *next=(XFreeNode *)(((U32)node)+xnode_size);

		node->next=next;
		node=next;
	}
	/* last Node points to nuthin */
	node->next=null;
	/* attach free nodes to list */
	D_ASSERT(!(This->free));
	This->free=first->next;
	return first;
}

void __regcall(1) xtree_free_nodes(void *_This)
{
	D_ASSERT(_This);

	XTreeData *This=(XTreeData *)_This;

	XNodeBlock *block=This->block;

	while(block)
	{
		XNodeBlock *next;

		next=block->next;
		xfree(block);
		block=next;
	}
	This->block=null;
	This->free=null;
}
