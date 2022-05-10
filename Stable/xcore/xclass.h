#ifndef _XCLASS_H_
#define _XCLASS_H_

/*--------------------------------------------*/
/* Debugging assertions */
/*--------------------------------------------*/
#if defined(_DEBUG) || defined(DEBUG) || defined(DBG_ASSERT)
#define D_ASSERT(expr)	\
do{						\
if (!(expr))			\
	_d_assert(__FILE__,(U32)__LINE__); \
}while(0)
#define D_VALIDATE(expr)	\
do{						\
if (!(expr))			\
	_d_assert(__FILE__,(U32)__LINE__); \
}while(0)
#else /* if no asserts to be used */
#define D_ASSERT(expr)
#define D_VALIDATE(expr) expr
#endif

/*--------------------------------------------*/
/* autoptr */
/*--------------------------------------------*/
/* description: self destructing ptr template */
/*--------------------------------------------*/
template <class X> class autoptr
{
	X *ptr;

public:
	inline autoptr(void) : ptr(null) {}
	inline autoptr(X *Ptr) : ptr(Ptr) {}
	inline ~autoptr(void){delete ptr;ptr=null;}
	inline autoptr &operator = (X *p)
	{
		ptr=p;
		return *this;
	}
	inline operator X * () {return ptr;}
	inline operator const X * () const {return ptr;}

	inline X *operator -> () {return ptr;}
	inline const X * operator -> () const {return ptr;}

	inline X *get(void) {return ptr;}
	inline X *&get_ref(void) {return ptr;}
	inline X *release(void)
	{
		X *ret=ptr;
		ptr=null;
		return ret;
	}
};

/*--------------------------------------------*/
/* autochar */
/*--------------------------------------------*/
/* description: self destructing char ptr class */
/* Note: requires allocation using xmalloc */
/*--------------------------------------------*/
class XCORE_API autochar
{
	char *ptr;
public:
	inline autochar(void) : ptr(null) {}
	inline autochar(char *p) : ptr(p) {}
	inline ~autochar(void){xfree(ptr);ptr=null;}
	inline autochar &operator = (char *p)
	{
		ptr=p;
		return *this;
	}
	inline operator char * () {return ptr;}
	inline operator CC8 * () const {return ptr;}

	inline char *operator -> () {return ptr;}
	inline CC8 * operator -> () const {return ptr;}
	inline CC8 *release(void)
	{
		CC8 *ret=ptr;
		ptr=null;
		return ret;
	}
	inline void *get_ptr(void){return ptr;}
};

/*--------------------------------------------*/
/* XRef_T */
/*--------------------------------------------*/
/* description: Reference counting wrapper */
/*--------------------------------------------*/
template <class TYPE> class XRef_T
{
public:
	U32		rcount;
	TYPE	data;
public:
	XRef_T(void) : rcount(0) {}
};

/*--------------------------------------------*/
/* XRef */
/*--------------------------------------------*/
/* description: Reference counting base object */
/*--------------------------------------------*/
class XCORE_API XRef
{
public:
	U32 rcount;
public:
	XRef(void) : rcount(0) {}
};

/*--------------------------------------------*/
/* XRcPtr */
/*--------------------------------------------*/
/* description: Reference counting ptr */
/*--------------------------------------------*/
template <class TYPE> class XRcPtr
{
protected:
	TYPE *node;

public:
	XRcPtr(void);
	XRcPtr(XRcPtr const &other);
	XRcPtr(TYPE *ptr);

	~XRcPtr(void);
	void AddRef(void);
	void DelRef(void);
	XRcPtr & operator = (XRcPtr const &other);
	XRcPtr & operator = (TYPE *ptr);

	inline const TYPE& operator * () const {return *node;}
	inline TYPE&  operator * () {return *node;}

	inline operator const TYPE * () const {return node;}
	inline operator TYPE * () {return node;}

	inline const TYPE* operator->() const {return node;}
	inline TYPE* operator->() {return node;}

	inline TYPE *get_ptr(void){return node;}
};

template <class TYPE>
inline XRcPtr<TYPE>::XRcPtr(void) : node(null){}

template <class TYPE>
inline XRcPtr<TYPE>::XRcPtr(XRcPtr const &other)
{
	node = other.node;
	AddRef();
}

template <class TYPE>
inline XRcPtr<TYPE>::XRcPtr(TYPE *ptr)
{
	node = ptr;
	if (node)
		node->rcount=1;
}

template <class TYPE>
inline void XRcPtr<TYPE>::AddRef(void)
{
	if (!node)
		return;
	node->rcount++;
}

template <class TYPE>
inline void XRcPtr<TYPE>::DelRef(void)
{
	if (!node)
		return;
	D_ASSERT(((I32)node->rcount)>0);
	if (--node->rcount == 0)
		delete node;
}

template <class TYPE>
XRcPtr<TYPE> &XRcPtr<TYPE>::operator = (TYPE *ptr)
{
	DelRef();
	node = ptr;
	if (node)
		node->rcount=1;

	return *this;
}

template <class TYPE>
inline XRcPtr<TYPE>::~XRcPtr(void)
{
	DelRef();
	node=null;
}

template <class TYPE>
XRcPtr<TYPE> &XRcPtr<TYPE>::operator = (XRcPtr const &other)
{
	if (this == &other)
		return *this;

	DelRef();
	node=other.node;
	AddRef();
	return *this;
}

/*--------------------------------------------*/
/* XRcBase */
/*--------------------------------------------*/
/* description: Reference counting ptr */
/*--------------------------------------------*/
template <class TYPE> class XRcBase
{
protected:
	TYPE *node;

public:
	XRcBase(void);
	XRcBase(XRcBase const &other);
	XRcBase(TYPE *ptr);

	~XRcBase(void);
	void AddRef(void);
	void DelRef(void);
	XRcBase & operator = (XRcBase const &other);
	XRcBase & operator = (TYPE *ptr);
};

template <class TYPE>
inline XRcBase<TYPE>::XRcBase(void)
{
	node=null;
}

template <class TYPE>
inline XRcBase<TYPE>::XRcBase(XRcBase const &other)
{
	node = other.node;
	AddRef();
}

template <class TYPE>
inline XRcBase<TYPE>::~XRcBase(void)
{
	DelRef();
	node=null;
}

template <class TYPE>
XRcBase<TYPE> &XRcBase<TYPE>::operator = (XRcBase const &other)
{
	if (this == &other)
		return *this;

	DelRef();
	node=other.node;
	AddRef();
	return *this;
}

template <class TYPE>
inline void XRcBase<TYPE>::AddRef(void)
{
	if (!node)
		return;
	node->rcount++;
}

template <class TYPE>
inline void XRcBase<TYPE>::DelRef(void)
{
	if (!node)
		return;
	if (--node->rcount == 0)
		delete node;
}

/* Node for list classes */
typedef struct _XPos
{
	void *reserved;
}XPos;

typedef struct _XLevel
{
	void *reserved;
}XLevel;

typedef struct _XNodeBlock
{
	struct _XNodeBlock *next;
}XNodeBlock;

/* TODO: Not finished */
template <class TYPE> class XArray
{
	U32 alloc_size;
	U32 size;
	U32 used;
	TYPE *array;
public:
	XArray(U32 allocsize=16) : alloc_size(allocsize),size(0),used(0),array(null) {}
};

extern "C" {
XCORE_API voidp __regcall(2) xlist_new_node(void *This,U32 xnode_size);
XCORE_API void __regcall(1) xlist_free_nodes(void *This);
XCORE_API voidp __regcall(2) xtree_new_node(void *This,U32 xnode_size);
XCORE_API void __regcall(1) xtree_free_nodes(void *This);
}


#pragma pack(push,4)
class XListState
{
public:
	U32 block_size : 24;
	U32 owned : 1;

	XListState(void) : block_size(5),owned(1) {}
	XListState(U32 BlockSize,U32 Owned) : block_size(BlockSize),owned(Owned){}
};
#pragma pack(pop)

/* normal container list */
/* doubly linked */
template <class TYPE> class XList
{
protected:
	struct XNode
	{
		XNode	*next;
		XNode	*prev;
		TYPE	*data;
	};

	XNode		*head;
	XNode		*tail;
	XNode		*free;
	XNodeBlock	*block;
	XListState	xlist_state;
	U32			count;

	inline XNode *new_node(void){return (XNode *)xlist_new_node(&this->head,sizeof(XNode));}
	inline void free_nodes(void){xlist_free_nodes(&this->head);}

public:
	/* 5 cause fits in 64 byte block normally */
	/* when data is a 32 bit ptr */
	XList(U32 block_size,U32 owned);
	XList(void);
	~XList(void);

	void free_list(void);
	void lose_list(void);

	XPos *add_head(TYPE *ptr);
	XPos *add_tail(TYPE *ptr);

	TYPE *remove_head(void);
	TYPE *remove_tail(void);

	void remove(XPos *pos);

	inline TYPE *get_head(void)
	{
		if (!head)
			return null;
		return head->data;
	}
	inline TYPE *get_tail(void)
	{
		if (!tail)
			return null;
		return tail->data;
	}

	inline XPos *get_head_position(void){return (XPos *)head;}
	inline XPos *get_tail_position(void){return (XPos *)tail;}

	TYPE *get_at(XPos *pos)
	{
		D_ASSERT(pos);
		return ((XNode *)pos)->data;
	}
	XPos *get_next(XPos *pos){return (XPos *)(((XNode *)pos)->next);}
};

template <class TYPE>
inline XList<TYPE>::XList(void)
 : head(null),tail(null),free(null),block(null),
	count(0)
{
}

template <class TYPE>
inline XList<TYPE>::XList(U32 block_size,U32 owned)
 : head(null),tail(null),free(null),block(null),
	count(0),xlist_state(block_size,owned)
{
}

template <class TYPE>
inline XList<TYPE>::~XList(void)
{
	if (xlist_state.owned)
	{
		while(head)
		{
			delete head->data;
			head=head->next;
		}
	}
	free_nodes();
}

template <class TYPE>
inline void XList<TYPE>::free_list(void)
{
	if (xlist_state.owned)
	{
		while(head)
		{
			delete head->data;
			head=head->next;
		}
	}
	head=null;tail=null;
	free_nodes();
}

template <class TYPE>
inline void XList<TYPE>::lose_list(void)
{
	head=null;
	tail=null;
	free_nodes();
}

template <class TYPE>
inline XPos *XList<TYPE>::add_head(TYPE *ptr)
{
	if (!free)
		free=new_node();

	XNode *node=free;

	free=free->next;
	node->data=ptr;
	
	node->next=head;
	node->prev=null;
	if (!head)
		tail=node;
	else
		head->prev=node;
	
	head=node;

	return (XPos *)head;
}

template <class TYPE>
inline XPos *XList<TYPE>::add_tail(TYPE *ptr)
{
	if (!free)
		free=new_node();

	XNode *node=free;

	free=free->next;
	node->data=ptr;
	
	node->prev=tail;
	node->next=null;
	if (!tail)
		head=node;
	else
		tail->next=node;
	
	tail=node;

	return (XPos *)tail;
}

template <class TYPE>
inline TYPE *XList<TYPE>::remove_head(void)
{
	if (!head)
		return null;

	TYPE *ret=head->data;
	XNode *old=head;

	head=head->next;
	if (head)
		head->prev=null;
	else
	{
		head=null;
		tail=null;
	}

	old->next=free;
	free=old;

	return ret;
}

template <class TYPE>
inline void XList<TYPE>::remove(XPos *ptr)
{
	XNode *node=(XNode *)ptr;

	if (node->prev)
		node->prev->next=node->next;
	else
		head=node->next;

	if (node->next)
		node->next->prev=node->prev;
	else
		tail=node->prev;

	((XNode *)ptr)->next=free;
	free=(XNode *)ptr;
}

template <class TYPE> class XTree
{
protected:
	class XTreeNode;
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
		
		TYPE *data;
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

	XTreeNode	*root;
	XFreeNode	*free;
	XNodeBlock	*block;
	U32			block_size;

	inline XFreeNode *new_node(void){return (XFreeNode *)xtree_new_node(&this->root,sizeof(XTreeNode));}
	inline void free_nodes(void){xtree_free_nodes(&this->root);}

public:
	XTree(U32 def_block=16); /* useful trees usually require at least 16 nodes */
	~XTree(void);
	XLevel *set_root(TYPE *ptr);
	XLevel *add_level(XPos *node);
	XPos *add_node_head(XLevel *level,TYPE *ptr);
	XPos *add_node_tail(XLevel *level,TYPE *ptr);
	void insert_node(XLevel *level,TYPE *ptr);

	TYPE *get_at(XLevel *level);
	TYPE *get_at(XPos *pos);
	XLevel *get_parent(XLevel *level);

	void free_branch(XPos *Node);
	void free_all(void);
};

template <class TYPE>
inline XTree<TYPE>::XTree(U32 def_block) : root(null),free(null),block(null),block_size(def_block)
{
	D_ASSERT(def_block);
}

/* uglier than I wanted, but I didn't want it to be recursive */
/* nodes,levels are "freed" are added to free list on way down */
/* technically they continue to get used until the end of function */
template <class TYPE>
inline void XTree<TYPE>::free_branch(XPos *Node)
{
	XTreeNode *node=(XTreeNode *)Node;

	/* remove references to branch */
	if (node==root)
		root=null;
	else
	{
		if (node->prev)
			node->prev->next=node->next;
		else
			node->level->head=node->next;

		if (node->next)
			node->next->prev=node->prev;
		else
			node->level->tail=node->prev;
	}

	/* lets free it now */
	while(node)
	{
		XTreeNode *cur;
		XTreeLevel *level;

		delete node->data;

		/* use data ptr as next, so we can continue */
		/* to use the node, while freeing branch */
		((XFreeNode *)node)->next=free;
		free=(XFreeNode *)node;

		cur=null;
		level=node->child;
		/* try and go down first */
		if (level)
		{
			cur=level->head;
			/* free up level node */
			((XFreeNode *)level)->next=free;
			free=(XFreeNode *)level;
		}
		/* now lets try and got in same level */
		if (!cur)
		{
			/* advance to next node on this level */
			cur=node->next;
			level=node->level;
			/* if at end of this level, lets go up till we find a level with a node */
			while(!cur)
			{
				/* if at top level we are done */
				if (!level)
					return;
				/* else continue on at the head of the level */
				cur=level->parent->next;
				level=level->parent->level;
			}
			/* adjust head of the level */
			level->head=cur;
		}
		node=cur;
	}
}

template <class TYPE>
inline void XTree<TYPE>::free_all(void)
{
	free_branch((XPos *)root);
	free_nodes();
}

template <class TYPE>
inline XTree<TYPE>::~XTree(void)
{
	free_branch((XPos *)root);
	free_nodes();
}

template <class TYPE>
inline TYPE *XTree<TYPE>::get_at(XPos *node)
{
	D_ASSERT(node);
	return ((XTreeNode *)node)->data;
}

template <class TYPE>
inline TYPE *XTree<TYPE>::get_at(XLevel *level)
{
	D_ASSERT(level);
	return ((XTreeLevel *)level)->parent->data;
}

template <class TYPE>
inline XLevel *XTree<TYPE>::get_parent(XLevel *Level)
{
	D_ASSERT(Level);
	XTreeLevel *level=(XTreeLevel *)Level;
	return ((XLevel *)level->parent->level);
}

template <class TYPE>
inline XLevel *XTree<TYPE>::set_root(TYPE *ptr)
{
	if (!free)
		free=new_node();

	XTreeNode *node=(XTreeNode *)free;

	free=free->next;
	
	node->data=ptr;
	
	node->next=null;
	node->prev=null;
	node->level=null;
	node->child=null;

	root=node;

	return add_level((XPos *)node);
}

template <class TYPE>
inline XLevel *XTree<TYPE>::add_level(XPos *parent)
{
	D_ASSERT(parent);
	if (!free)
		free=new_node();

	XTreeLevel *level=(XTreeLevel *)free;

	free=free->next;

	((XTreeNode *)parent)->child=level;
	level->head=null;
	level->tail=null;
	level->parent=(XTreeNode *)parent;

	return (XLevel *)level;
}

template <class TYPE>
inline XPos *XTree<TYPE>::add_node_head(XLevel *Level,TYPE *ptr)
{
	D_ASSERT(Level);

	if (!free)
		free=new_node();

	XTreeLevel *level=(XTreeLevel *)Level;
	XTreeNode *node=(XTreeNode *)free;

	free=free->next;
	node->data=ptr;
	node->prev=null;
	node->next=level->head;
	node->child=null;
	node->level=(XTreeLevel *)Level;

	if (!level->head)
		level->tail=node;
	else
		level->head->prev=node;

	level->head=node;
	
	return (XPos *)node;
}

template <class TYPE>
inline XPos *XTree<TYPE>::add_node_tail(XLevel *Level,TYPE *ptr)
{
	D_ASSERT(Level);

	if (!free)
		free=new_node();

	XTreeLevel *level=(XTreeLevel *)Level;
	XTreeNode *node=(XTreeNode *)free;

	free=free->next;
	node->data=ptr;
	node->prev=level->tail;
	node->next=null;
	node->child=null;
	node->level=(XTreeLevel *)Level;

	if (!level->tail)
		level->head=node;
	else
		level->tail->next=node;

	level->tail=node;
	
	return (XPos *)node;
}

#pragma pack(push,4)
class XChainState
{
public:
	U32	count : 31;
	U32 owned : 1;

	XChainState(void) : owned(0),count(0) {}
	XChainState(U32 Owned) : owned(Owned),count(0) {}
};
#pragma pack(pop)

/* normal chain list */
/* doubly linked */
/* requires publicly available ->next and ->prev */
template <class TYPE> class XChain
{
	TYPE		*head;
	TYPE		*tail;
	XChainState	xchain_state;

public:
	XChain(void) : head(null),tail(null) {}
	XChain(U32 owned) : head(null),tail(null),xchain_state(owned) {}
	~XChain();

	void lose_list(void);
	void free_list(void);

	TYPE *add_head(TYPE *ptr);
	TYPE *add_tail(TYPE *ptr);

	TYPE *get_next(TYPE *ptr){return ptr->next;}
	TYPE *get_prev(TYPE *ptr){return ptr->prev;}

	TYPE *remove_head(void);
	TYPE *remove_tail(void);
	TYPE *remove(TYPE *ptr);

	inline TYPE *get_head(void){return head;}
	inline TYPE *get_tail(void){return tail;}
};

template <class TYPE>
inline XChain<TYPE>::~XChain(void)
{
	if (xchain_state.owned)
	{
		while(head)
		{
			TYPE *tmp=(TYPE *)head->next;
			delete head;
			head=tmp;
		}
	}
	head=null;
	tail=null;
}

template <class TYPE>
inline void XChain<TYPE>::lose_list(void)
{
	head=null;tail=null;xchain_state.count=0;
}

template <class TYPE>
inline void XChain<TYPE>::free_list(void)
{
	if (xchain_state.owned)
	{
		while(head)
		{
			TYPE *tmp=(TYPE *)head->next;
			delete head;
			head=tmp;
		}
	}
	head=null;tail=null;
}

template <class TYPE>
inline TYPE *XChain<TYPE>::add_head(TYPE *ptr)
{
	ptr->next=head;
	ptr->prev=null;
	if (head)
		head->prev=ptr;
	else
		tail=ptr;
	
	head=ptr;

	return head;
}

template <class TYPE>
inline TYPE *XChain<TYPE>::add_tail(TYPE *ptr)
{
	ptr->prev=tail;
	ptr->next=null;
	if (tail)
		tail->next=ptr;
	else
		head=ptr;
	
	tail=ptr;

	return tail;
}

template <class TYPE>
inline TYPE *XChain<TYPE>::remove(TYPE *ptr)
{
	if (ptr->prev)
		ptr->prev->next=ptr->next;
	else
		head=ptr->next;

	if (ptr->next)
		ptr->next->prev=ptr->prev;
	else
		tail=ptr->prev;

	return ptr;
}

template <class TYPE>
inline TYPE *XChain<TYPE>::remove_head(void)
{
	if (!head)
		return null;

	TYPE *ret=head;

	head=head->next;
	if (!head)
		tail=null;
	else
		head->prev=null;

	return ret;
}

template <class TYPE>
inline TYPE *XChain<TYPE>::remove_tail(void)
{
	if (!tail)
		return null;

	TYPE *ret=tail;

	tail=tail->prev;
	if (!tail)
		head=null;
	else
		tail->next=null;

	return ret;
}

/* normal chain ring list */
/* doubly linked */
/* requires publicly available ->next and ->prev */
template <class TYPE> class XRingChain
{
protected:
	TYPE     *cur;
	U32		count;

public:
	XRingChain(void) : cur(null),count(0) {}
	~XRingChain(void);
	void lose_list(void);

	TYPE *insert_after(TYPE *prev,TYPE *obj);
	TYPE *insert_before(TYPE *next,TYPE *obj);

	TYPE *remove_cur(void);

	inline TYPE *get_cur(void){return cur;}
	/* TODO: put in some error checking here */
	inline void set_cur(TYPE *&ptr){cur=ptr;}
	inline TYPE *get_next(TYPE *&ptr)
	{
		cur=ptr->next;
		return cur;
	}
};

template <class TYPE>
inline XRingChain<TYPE>::~XRingChain(void)
{
	if (!cur)
		return;
	
	/* terminate loop */
	cur->prev->next=null;
	/* free loop */
	while(cur)
	{
		TYPE *next=(TYPE *)cur->next;
		delete cur;
		cur=next;
	}
}

template <class TYPE>
inline void XRingChain<TYPE>::lose_list(void)
{
	cur=null;count=0;
}

template <class TYPE>
inline TYPE *XRingChain<TYPE>::insert_after(TYPE *prev,TYPE *ptr)
{
	cur=ptr;
	if (!prev)
	{
		ptr->next=ptr;
		ptr->prev=ptr;
		return ptr;
	}
	
	TYPE *next=prev->next;

	ptr->next=next;
	next->prev=ptr;
	prev->next=ptr;
	ptr->prev=prev;

	return cur;
}

template <class TYPE>
inline TYPE *XRingChain<TYPE>::insert_before(TYPE *next,TYPE *ptr)
{
	cur=ptr;
	if (!next)
	{
		ptr->next=ptr;
		ptr->prev=ptr;
		return null;
	}
	
	TYPE *prev=next->prev;

	ptr->prev=prev;
	prev->next=ptr;
	next->prev=ptr;
	ptr->next=next;
	
	return cur;
}

template <class TYPE>
inline TYPE *XRingChain<TYPE>::remove_cur(void)
{
	if (!cur)
		return null;

	/* if last entry */
	if (cur->next==cur)
	{
		cur=null;
		return cur;
	}

	cur->prev->next=cur->next;
	cur->next->prev=cur->prev;
	
	TYPE *ret=cur;
	cur=cur->next;

	return ret;
}

class XCORE_API CMallocBlock
{
private:
   U8 num_blocks;
   U8 cur;
   U8 align_size;
   U8 pad2;

   U32 *list_base(void){return ((U32 *)(this+1));}

public:
   void *operator new(size_t size,U32 num,CU32 *list,U32 align);
   void operator delete(void *ptr,U32 num,CU32 *list,U32 align){xfree(ptr);}
   void operator delete(void *ptr){xfree(ptr);}
   CMallocBlock(void){cur=0;}
   ~CMallocBlock(void);
   void *get_next(void);
};

class XCORE_API RingBuffer
{
protected:
	char *mem_base;
	char *mem_end;
	U32	 size;

	char *write_ptr;
	char *read_ptr;

	U32 depth_write;

public:
	RingBuffer(cvoid *mem,U32 size);
	U32 get_room(void);
	U32 get_total_room(void);
	void adjust_read(U32 amount);
	U32 write(cvoid *mem,U32 size);
	void wrap(void);
	XOBJ_DEFINE()
};

class XCORE_API MemGrow
{
protected:
	char *base;
	U32 size;
public:
	MemGrow(void) : size(0),base(null) {}
	MemGrow(U32 start) : size(start) {base=(char *)xmalloc(size);}
	~MemGrow(void){xfree(base);}

	void init(U32 start){size=start;base=(char *)xmalloc(size);}
	void close(void){xfree(base);base=null;}
	void realloc(U32 inc_size);
	XOBJ_DEFINE()
};

class XCORE_API CSysObj
{
public:
	CSysObj			*next;
	CSysObj			*prev;
public:
	CSysObj(void);
	~CSysObj(void);
	virtual U32 destroy(void)=null;
};

class MemStats
{
public:
	U32 alloc_count;
	U32 free_count;
public:
	MemStats(void) : alloc_count(0),free_count(0) {}
	XOBJ_DEFINE()
};

class XCORE_API XStatistic
{
	U32			count;
	U64			tick_total;
	MemStats	mem_stats0;
	MemStats	mem_stats1;
	MemStats	mem_stats2;
public:
	XStatistic *next;
	XStatistic *prev;
public:
	XStatistic(void) : count(0),tick_total(0) {}
	void add_count(void){count++;}
	void add_tick(U64 tick){tick_total+=tick;}
	void add_alloc(void){mem_stats0.alloc_count++;}
	void add_alloc2(void){mem_stats1.alloc_count++;}
	void add_alloc3(void){mem_stats2.alloc_count++;}
	XOBJ_DEFINE()
};

class XCORE_API XStatManager
{
	U32 cur_id;
	XChain<XStatistic> stats;
public:
	XList<XStatistic> stack;
public:
	XStatManager(void) : cur_id(0) {}
	U32 get_id(void){return cur_id++;}
	U32 stats_write(CC8 *filename);
	void push(XStatistic *stat){stack.add_head(stat);}
	void pop(XStatistic *stat){stack.remove_head();}
	void add_alloc(void)
	{
		XStatistic *head=stack.get_head();
		if (head)
			head->add_alloc();
	}
	void add_alloc2(void)
	{
		XStatistic *head=stack.get_head();
		if (head)
			head->add_alloc2();
	}
	void add_alloc3(void)
	{
		XStatistic *head=stack.get_head();
		if (head)
			head->add_alloc3();
	}
	void close(void)
	{
		stats.free_list();
		stack.free_list();
	}
	XOBJ_DEFINE()
};

class XCORE_API XStat
{
	XStatistic *stat;
	U64 tick_start;
	U64 tick_end;

public:
	XStat(XStatistic *Stat);
	~XStat(void);
	XOBJ_DEFINE()
};

class XCORE_API CError
{
public:
	virtual void message(U32 level,CC8 *str);
	virtual void throw_msg(U32 level,CC8 *str);
	virtual void assert(CC8 *file,U32 line);
	inline void bitch(CC8 *str){message(ERROR_BITCH,str);}
	inline void fatal(CC8 *str){message(ERROR_FATAL,str);}
	inline void throw_msg(CC8 *str){throw_msg(ERROR_NORMAL,str);}
};

class XCORE_API WinMsgDef : public CError
{
	XHWND hwnd;

public:
	WinMsgDef(void) : hwnd(null) {}

	virtual void message(U32 level,CC8 *str);
	virtual void throw_msg(U32 level,CC8 *str);
	virtual void assert(CC8 *file,U32 line);

	virtual void set_window(XHWND Hwnd);
	virtual void no_window(void);
};

extern XCORE_API WinMsgDef _win_error;

enum timeout_enums {TIMEOUT_INFINITE=0xFFFFFFFF};

class XEvent : private CSysObj
{
	XHandle		handle;
	autochar	name;

	U32 destroy(void);

public:
	XEvent(U32 create,U32 manual_reset,U32 state,CC8 *Name=null);
	U32 init(U32 create,U32 manual_reset,U32 state,CC8 *Name);
	XOBJ_DEFINE()
};

template class XCORE_API XChain<CSysObj>;

class XMutex : private CSysObj
{
	enum mutex_enums{IS_LOCKED=1};

	XHandle		handle;
	autochar	name;
	U32			flags;
	U32			err;

private:
	U32 destroy(void);
	
public:
	XMutex(U32 create,U32 own,CC8 *Name=null);
	XMutex(void) : handle(null) {}
	~XMutex(void){destroy();}
	U32 init(U32 create,U32 own,CC8 *Name=null);
	U32 lock(U32 timeout=TIMEOUT_INFINITE);
	U32 unlock(void);
	
	inline CC8 *get_name(void){return name;}
	inline U32 is_locked(void){return (flags & IS_LOCKED);}
	XOBJ_DEFINE()
};

class AutoMutex
{
	XMutex *mutex;
public:
	AutoMutex(XMutex *Mutex,U32 timeout=TIMEOUT_INFINITE) : mutex(Mutex)
	{
		if (!mutex->is_locked())
			mutex->lock(timeout);
	}
	~AutoMutex(void)
	{
		if (mutex->is_locked())
			mutex->unlock();
	}
	inline U32 is_locked(void){return mutex->is_locked();}
};

class CMemMap : public CSysObj
{
	enum mem_map_enums{MEMORY_MAPPED=1};

	autochar	name;
	U32			flags;
	XHandle		handle;
	void		*ptr;
	U32			size;

private:
	U32 destroy(void);
public:
	CMemMap(U32 create,CC8 *name,U32 size);
	CMemMap(CC8 *name);
	~CMemMap(void){destroy();}
	U32 init(U32 create,CC8 *name,U32 size);
	inline U32 is_mapped(void){return (flags & MEMORY_MAPPED);}
	inline void *get_ptr(void){return ptr;}
	inline U32 get_size(void){return size;}
	XOBJ_DEFINE()
};

#define ERR_MEM_SIZE	8192
/* must be power of 2 */
#define ERR_MEM_CHUNK	(ERR_MEM_SIZE/32)

#pragma pack(push,4)
class XCORE_API ErrMem
{
	U32		rotate;
	char	def_mem[ERR_MEM_SIZE];
	U32		tls_index;

public:
	ErrMem(void);
	~ErrMem(void);
	char *get(U32 size);
	char *get_more(char *cur,U32 inc_size);
	void add_thread(void);
	void remove_thread(void);
};
#pragma pack(pop)

#ifdef _WIN32

class XGlobal;

extern XGlobal XCORE_API *_global;

class XCORE_API XGlobal
{
	enum dll_sysflag_enums {SYS_CORRUPT=1,
							SYS_IN_THROW=2,
							SYS_IN_FATAL=4};

	ErrMem			err_mem;
	CError			*error;
	CError			*fallback;

	XChain<CSysObj>	sys_objects;
	XChain<CSysObj>	file_objects;
	XList<void *>	raw_handles;

	U32 sys_flags;
public:
	XStatManager	stats;

protected:
	void _handle_unclean(void);
	void _free_raw(void);

public:
	XGlobal(void);
	~XGlobal(void);
	virtual void close(void);

	/* register global objects and handles for global deconstruction */
	void reg_global_object(CSysObj *obj);
	void unreg_global_object(CSysObj *obj);
	/* for raw memory ptrs to be freed and null'd */
	void reg_global_handle_rawptr(void **ptr);

#if 0
	void add_system_obj(CSysObj *obj);
	void remove_system_obj(CSysObj *obj);
#endif

	void message(U32 level,CC8 *str);
	void throw_msg(U32 level,CC8 *str);
	void fatal(void);
	void caught(void);

	inline void bitch(CC8 *str){error->message(ERROR_BITCH,str);}
	inline void throw_msg(CC8 *str){error->throw_msg(ERROR_NORMAL,str);}
	inline void assert(CC8 *file,U32 line){error->assert(file,line);}
	inline void printf(U32 level,CC8 *string,...);

	/* fatal error, this is a last ditch call before exit */
	void _fatal_exit(void);

	void set_error(CError *error);
	void attach_thread(XHandle hmod);
	void detach_thread(XHandle hmod);
};

class XApp;
class XDll;

//extern XDll XCORE_API *_dll;
extern XApp XCORE_API *_xapp;

class XCORE_API XDll
{
public:
	virtual U32 attach_process(XHandle handle);
	virtual U32 detach_process(XHandle handle);
	
	U32 attach_thread(XHandle handle);
	U32 detach_thread(XHandle handle);
};

class XCORE_API XApp
{
public:
	XApp(void){_xapp=this;}
	~XApp(void){_xapp=null;}
};

inline XStat::XStat(XStatistic *Stat) : stat(Stat)
{
	_global->stats.push(stat);
	begin_tick(&tick_start);
}

inline XStat::~XStat(void)
{
	end_tick(&tick_end);
	stat->add_count();
	stat->add_tick(tick_end - tick_start);
	_global->stats.pop(stat);
}


/* TODO: get this to not use statics.  Statics suck */
#define XSTAT(x) \
	static XStatistic *_stat=_stats.get(x); \
	XStat	_stat_obj(_stat);


inline CSysObj::CSysObj(void){_global->reg_global_object(this);}
inline CSysObj::~CSysObj(void){_global->unreg_global_object(this);}

extern "C" {
XCORE_API void __regcall(2) xxx_message(U32 error_level,CC8 *string);
XCORE_API void __regcall(2) xxx_throw_level(U32 error_level,CC8 *string);
XCORE_API void __regcall(1) xxx_throw(CC8 *string);
XCORE_API void __regcall(1) xxx_fatal(CC8 *string);
XCORE_API void __regcall(1) xxx_bitch(CC8 *string);
XCORE_API void xxx_printf(U32 error_level,CC8 *string,...);
XCORE_API void xxx_printf_noglobal(U32 error_level,CC8 *string,...);
}

inline void _d_assert(CC8 *file,U32 line)
{
	_global->assert(file,line);
}

#endif

#endif /* ifndef _XCLASS_H_ */
