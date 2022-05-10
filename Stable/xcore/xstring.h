#ifndef _XSTRING_H_
#define _XSTRING_H_

/*--------------------------------------------*/
/* CStr */
/*--------------------------------------------*/
/* description: takes a string and allocates and creates duplicate */
/*--------------------------------------------*/
class XCORE_API CStr
{
	U32 size;
	char *str;
public:
	CStr(CC8 *Str,U32 Size);
	CStr(CC8 *Str);
	operator CC8 *() const{return str;}
	operator char *() const{return str;}
};

/*--------------------------------------------*/
/* CStrLow */
/*--------------------------------------------*/
/* description: takes a string and allocates and creates duplicate */
/*--------------------------------------------*/
class XCORE_API CStrLow
{
	U32 size;
	char *str;
public:
	CStrLow(CC8 *Str,U32 Size);
	CStrLow(CC8 *Str);
	operator CC8 *() const{return str;}
	operator char *() const{return str;}
};

/*--------------------------------------------*/
/* CStrCat */
/*--------------------------------------------*/
/* description: takes a two strings and allocates and creates a */
/* concatenated version */
/* used like path=CStrCat("../drivers/","glide.dll"); */
/* path would become "../drivers/glide.dll" */
/*--------------------------------------------*/
class XCORE_API CStrCat
{
	U32 size;
	char *str;
public:
	CStrCat(CC8 *str1,CC8 *str2);
	operator CC8 *() const{return str;}
	operator char *() const{return str;}
};

/*--------------------------------------------*/
/* CStrObj */
/*--------------------------------------------*/
/* description: Base Ref String object */
/*--------------------------------------------*/
class XCORE_API CStrObj : public XRef
{
public:
	char *str;
	U32 size;
public:
	CStrObj(CC8 *Str);
	~CStrObj(void)
	{
		xfree(str);
		str=null;
	}
	XOBJ_DEFINE()
};

/*--------------------------------------------*/
/* CStrRef */
/*--------------------------------------------*/
/* description: Reference String class */
/*--------------------------------------------*/
class XCORE_API CStrRef : public XRcBase<CStrObj>
{
public:
	CStrRef(void){}
	CStrRef(CC8 *str);
	CStrRef & operator = (CC8 *ptr);
	
	inline operator char * ()
	{
		if (!node)
			return null;
		return node->str;
	}
	inline operator CC8 * () const
	{
		if (!node)
			return null;
		return node->str;
	}
	inline char * operator -> ()
	{
		if (!node)
			return null;
		return node->str;
	}
	inline CC8 * operator -> () const
	{
		if (!node)
			return null;
		return node->str;
	}
};

class CPathRef;

/*--------------------------------------------*/
/* CPathObj */
/*--------------------------------------------*/
/* description: Reference Path object */
/*--------------------------------------------*/
class XCORE_API CPathObj : public XRef
{
	friend CPathRef;
	enum path_enums
	{
		SETUP_EXT=1,
		HAS_REL_PATH=2,
		SETUP_NAME=4
	};

public:
	U16		file_path_size;
	U16		file_path_len;
	char	*file_path;
	CC8		*file_name;
	CC8		*ext;

	U16		abs_path_size;
	U16		abs_path_len;
	CC8		*abs_path;

	U16		just_path_size;
	U16		just_path_len;
	CC8		*just_path;

	U32		flags;
protected:	
	void set_extension(void);
	void set_name(void);
	void set_extension(CC8 *ext);
	U32 is_room(U32 more);

public:
	CPathObj(void) : file_path(null),abs_path(null),just_path(null) {}
	~CPathObj(void);
	U32 init_new_ext(CPathObj *obj,CC8 *NewExt);
	void init_name_path(CC8 *name,CC8 *path);
	void init_abs_path(CC8 *abs_name);
	void init_name(CC8 *name);
	CC8 *get_extension(void);
	CC8 *get_filename(void);
	CC8 *get_path(void){return file_path;}
	U32 file_exist(void);
	U32 is_ext(CC8 *ext);
};

/*--------------------------------------------*/
/* CPathRef */
/*--------------------------------------------*/
/* description: Reference Path class */
/*--------------------------------------------*/
class XCORE_API CPathRef : public XRcPtr<CPathObj>
{
public:
	CPathRef(void){}
	CPathRef(CC8 *str);
	CPathRef & operator = (CC8 *ptr);
	
	CC8 *init(CC8 *filename,CC8 *pathname=null);
	void set_extension(CC8 *ext);
	void set_absolute(CC8 *name);
	
	inline CPathObj * operator -> () {return node;}
	inline const CPathObj * operator -> () const {return node;}
};

/*--------------------------------------------*/
/* CPrintf */
/*--------------------------------------------*/
/* description: Safe string operation class */
/*--------------------------------------------*/
class XCORE_API CPrintf
{
protected:
   enum flag_enum{PRINT_FULL=0x80000000};
   char *dst;
   char *cur;
   U32  size;
   U32  start_size;
   U32  flags;

   U32 fstrcpy_lim(CC8 *src);
   U32 fstrncpy_lim(CC8 *src,U32 src_size);

public:
	CPrintf(void) : dst(null),cur(null),size(0) {}
	CPrintf(char *_dst,U32 _size) : dst(_dst),cur(_dst),start_size(_size),size(_size-1),flags(0)
	{
		D_ASSERT(_size>0);
		dst[0]=0;
	}
	CPrintf(char *_dst,U32 _size,U32 _start) : dst(_dst),cur(_dst+_start),start_size(_size),size(_start),flags(0)
	{
		D_ASSERT(_size>0);
	}
	__inline void init(char *_dst,U32 _size)
	{
		D_ASSERT(_size>0);
		dst=_dst;dst[0]=0;cur=_dst;start_size=_size;size=_size - 1;flags=0;
	}
	__inline void reset(void){cur=dst;size=start_size-1;flags=0;}

	__inline CPrintf & operator << (CC8 *src){fstrcpy_lim(src);return *this;}
	__inline CPrintf & operator << (U32 val){num(val);return *this;}
	__inline CPrintf & operator << (I32 val){num(val);return *this;}
	__inline CPrintf & operator << (char val){chr(val);return *this;}
	U32 chr(char key);
	U32 num(I32 val);
	U32 num(U32 val);
	U32 hex(U32 num);
	U32 hex64(U64 num);
	U32 add_path(CC8 *str);
	__inline U32 str(CC8 *src) {return fstrcpy_lim(src);}
	__inline U32 strn(CC8 *src,U32 src_size) {return fstrncpy_lim(src,src_size);}
	__inline U32 overflow(void) {return (flags & (~PRINT_FULL));}
	__inline U32 get_len(void) {return (cur - dst);}
	__inline CC8 *get_str(void){return dst;}
	__inline char *get_cur(void) {return cur;}
	__inline char *get_last(void){return cur - 1;}
	char *set_cur(CC8 *Cur)
	{
		size=start_size - (Cur - dst) - 1;
		return (cur=(char *)Cur);
	}
	char *set_cur(U32 offset)
	{
		size=start_size - offset - 1;
		return (cur=dst+offset);
	}
};

/*--------------------------------------------*/
/* CPrintfT */
/*--------------------------------------------*/
/* description: Safe string operation class (temporary) */
/*--------------------------------------------*/
class CPrintfT : public CPrintf
{
   friend class PrintfManage;
   friend class TmpPrintf;

public:
	CPrintfT     *prev;
	CPrintfT     *next;
	CPrintfT     *alloc_next;

	CMallocBlock *block;
public:
	CPrintfT(CMallocBlock *block,U32 size);
	void init(char *_dst,U32 _size){xxx_throw("Cannot init CPrintfT");}
	void *operator new(size_t size,void *ptr){return ptr;}
	void operator delete(void *ptr,void *ptr2){free_mem(ptr);}
	void operator delete(void *ptr){free_mem(ptr);}
	static void free_mem(void *ptr);
};

XCORE_API CPrintfT *get_printf(U32 size);
XCORE_API void release_printf(CPrintfT *ptr);

/*--------------------------------------------*/
/* TmpPrintf */
/*--------------------------------------------*/
/* description: Gets temporary CPrintf Object */
/*--------------------------------------------*/
class TmpPrintf
{
   CPrintfT *ptr;

public:
	/* TODO assembly'ize constructor in future */
	__inline TmpPrintf(U32 size){ptr=get_printf(size);}
	__inline ~TmpPrintf(void){release_printf(ptr);}

	__inline TmpPrintf & operator << (CC8 *str){ptr->str(str);return *this;}
	__inline TmpPrintf & operator << (char val){ptr->chr(val);return *this;}
	__inline TmpPrintf & operator << (U32 val){ptr->num(val);return *this;}
	__inline TmpPrintf & operator << (I32 val){ptr->num(val);return *this;}

	CC8 *get_str(void){return ptr->get_str();}
	CC8 *get_cur(void){return ptr->get_cur();}
	U32 get_size(void){return ptr->start_size;}
	U32 get_len(void){return ptr->get_len();}
	char *get_last(void){return ptr->get_last();}
	void reset(void){ptr->reset();}
	char *set_cur(CC8 *cur){return ptr->set_cur(cur);}
	U32 add_path(CC8 *str){return ptr->add_path(str);}
};

class XCORE_API StrGrow : protected MemGrow
{
	char *cur;
	char *end;
	U32 inc_size;

protected:
	inline void realloc(U32 inc,U32 need=0)
	{
		U32 diff=cur - base;
		if (need > inc)
			inc=need;
		MemGrow::realloc(inc);
		cur=base+diff;
		end=base+size;
	}
public:
	inline void reset(void)
	{
		cur=base;
		if (base)
			end=cur+size;
	}
	inline StrGrow(U32 size=64,U32 IncSize=64) : MemGrow(ALIGN_POW2(size,64)),inc_size(IncSize)
	{
		reset();
	}
	StrGrow & operator = (CC8 *ptr)
	{
		reset();
		copy(ptr);
		return *this;
	}

	/* copies characters until and including null */
	void copy(CC8 *str);
	/* copies size characters including null */
	/* copy("blah",4) == "bla" */
	U32 copy(CC8 *str,U32 size);

	U32 num(U32 val);
	U32 num(I32 val);
	U32 chr(char key);
	U32 printf(CC8 *str,...);
	void path_append(CC8 *path);

	inline operator char * () {return base;}
	inline operator CC8 * () const {return base;}

	inline char *operator -> () {return base;}
	inline CC8 * operator -> () const {return base;}
	
	inline StrGrow & operator << (CC8 *src){copy(src);return *this;}
	inline StrGrow & operator << (U32 val){num(val);return *this;}
	inline StrGrow & operator << (I32 val){num(val);return *this;}
	inline StrGrow & operator << (char val){chr(val);return *this;}
};


#endif /*ifndef _XSTRING_H_ */