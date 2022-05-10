#include "stdcore.h"
#include <stdio.h>
#include <stdarg.h>

#pragma intrinsic(strlen,memcpy,strcmp)

U32 __regcall(2) fitoa(I32 val,char *str)
{
	U8 stack[12];
	U8 *cur=stack;
	char *base=str;

	if (val&0x80000000)
	{
		val=-val;
		*str++='-';
	}
	do
	{
		U32 digit;

		digit=(val%10) + '0';
		val/=10;
		*cur++=(U8)digit;
	}while(val);
	/* reverse out */
	do
	{
		*str++=(char)(*(--cur));
	}while(stack!=cur);
	/* end string */
	str[0]=0;

	/* return number of characters */
	return ((U32)(str - base));
}

U32 __regcall(2) futoa(U32 val,char *str)
{
	U8 stack[12];
	U8 *cur=stack;
	char *base=str;

	do
	{
		U32 digit;

		digit=(val%10) + '0';
		val/=10;
		*cur++=(U8)digit;
	}while(val);
	/* reverse out */
	do
	{
		*str++=(char)(*(--cur));
	}while(stack!=cur);
	/* end string */
	str[0]=0;

	/* return number of characters */
	return ((U32)(str - base));
}

CC8P __regcall(3) fscan_f(CC8 *&text,CU8 *flag_list,U32 flags)
{
   U8 *src=(U8 *)(*text);
   U32 key;

   while(key=*src++)
   {
      if (flag_list[key] & flags)
      {
         *((U8 **)text)=(--src);
         return ((CC8P)src);
      }
   }
   *((U8 **)text)=src;
   return null;
}

CC8P __regcall(3) fscan_nf(CC8 *&text,CU8 *flag_list,U32 flags)
{
   U8 *src=(U8 *)(*text);
   U32 key;

   while(key=*src++)
   {
      if (!(flag_list[key] & flags))
      {
         *((U8 **)text)=(--src);
         return ((CC8P)src);
      }
   }
   *((U8 **)text)=src;
   return null;
}

CStr::CStr(CC8 *Str,U32 Size) : size(Size)
{
	str=(char *)xmalloc(size+1);
	memcpy(str,Str,size);
	str[size]=0;
}

CStr::CStr(CC8 *Str)
{
	size=strlen(Str);
	str=(char *)xmalloc(size+1);
	memcpy(str,Str,size+1);
}

CStrLow::CStrLow(CC8 *Str,U32 Size) : size(Size)
{
	str=(char *)xmalloc(size+1);
	fstrncpy_tolower(str,Str,size+1);
}

CStrLow::CStrLow(CC8 *Str)
{
	size=strlen(Str);
	str=(char *)xmalloc(size+1);
	fstrncpy_tolower(str,Str,size+1);
}

CStrCat::CStrCat(CC8 *str1,CC8 *str2)
{
	U32 len1=strlen(str1);
	U32 len2=strlen(str2);

	size=len1+len2;

	str=(char *)xmalloc(size+1);
	memcpy(str,str1,len1);
	memcpy(str+len1,str2,len2+1);
}

U32 __regcall(2) fstreq(CC8 *str1,CC8 *str2)
{
	if (strcmp(str1,str2)==0)
		return TRUE;
	return FALSE;
}

U32 __regcall(2) fstrexp_eq(CC8 *exp,CC8 *str)
{
	D_ASSERT(exp);D_ASSERT(str);

	while(1)
	{
		U32 key1,key2;

		key1=*exp++;
		key2=*str++;

		if ((!key2)||(!key1))
		{
			if ((!key1) && (!key2))
				return TRUE;
			if (key1=='*')
				return TRUE;
			return FALSE;
		}

		/* if in wildcard */
		if (key1=='*')
		{
			/* advance key1 to non-wildcard */
			while(1)
			{
				key1=*exp++;
				if (!key1)
					return TRUE;
				if (key1!='*')
					break;
			}
		}
		if (key1!=key2)
			return FALSE;
	}
	return TRUE;
}

U32 __regcall(3) fstrneq(CC8 *str1,CC8 *str2,U32 size)
{
	while(size--)
	{
		U32 key1=*str1++;
		U32 key2=*str2++;
		if (key1!=key2)
			return FALSE;
		if (!key1)
			return TRUE;
	}
	return TRUE;
}

/* TODO: assembly-ize */
charp __regcall(2) fstrchr(CC8 *str,char key)
{
	U32 val;

	while(val=*str++)
	{
		if (val==(U32)key)
			return (char *)str-1;
	}
	return null;
}

charp __regcall(2) fstrcpy(char *dst,CC8 *src)
{
	U8 key;
	
	while(key=*src++)
		*dst++=key;
	
	dst[0]=0;
	return dst;
}

/* fstrncpy does not write more than size characters including terminating null */
U32 __regcall(3) fstrncpy(char *dst,CC8 *src,U32 size)
{
	U32 i;

	if (size==0)
		return 0;

	for(i=0;i<size;i++)
	{
		*dst++=*src++;
		if (src[-1]==0)
			return i;
	}
	dst[-1]=0;
	return (i-1);
}

charp __regcall(2) fstrcpy_tolower(char *dst,CC8 *src)
{
	U8 key;
	
	while(key=*src++)
		*dst++=fsetlower(key);
	
	dst[0]=0;
	return dst;
}

/* fstrncpy does not write more than size characters including terminating null */
U32 __regcall(3) fstrncpy_tolower(char *dst,CC8 *src,U32 size)
{
	U32 i;

	if (size==0)
		return 0;

	for(i=0;i<size;i++)
	{
		U8 key=fsetlower(*src);src++;
		*dst++=key;
		if (key==0)
			return i;
	}
	dst[-1]=0;
	return (i-1);
}

CC8P __regcall(3) fstrnrchr(CC8 *text,U32 key,U32 size)
{
   U8 *src=(U8 *)text;

   while(((I32)(size--))>0)
   {
      if (((U32)(*src--))==key)
         return ((CC8P)(src + 1));
   }
   return null;
}

CC8P __regcall(3) fstrprchr(CC8 *text,U32 key,CC8 *end)
{
   U8 *src=(U8 *)text;
   I32 size=text - end;
   
   D_ASSERT(size>0);

   while((size--)>0)
   {
      if (((U32)(*src--))==key)
         return ((CC8P)(src + 1));
   }
   return null;
}

U32 __regcall(2) hex32(U32 val,char *ptr)
{
   char stack[12];
   char *cur,*base=ptr;

   cur=stack;
   while(val)
   {
      U32 nibble;

      nibble=(val&0xF);
      if (nibble<0xA)
         *cur++=(char)(nibble+48);
      else
         *cur++=(char)(nibble+55);
      val>>=4;
   }
   do
   {
      *ptr++=(char)(*(--cur));
   }while(stack!=cur);
   ptr[0]=0;
   return ptr - base;
}

U32 hex64(U64 val,char *ptr)
{
   char stack[20];
   char *cur,*base=ptr;

   cur=stack;
   while(val)
   {
      U32 nibble;

      nibble=(U32)(val&0xF);
      if (nibble<0xA)
         *cur++=(char)(nibble+48);
      else
         *cur++=(char)(nibble+55);
      val>>=4;
   }
   do
   {
      *ptr++=(char)(*(--cur));
   }while(stack!=cur);
   ptr[0]=0;
   return ptr - base;
}

CStrObj::CStrObj(CC8 *Str)
{
	size=strlen(Str);
	str=(char *)xmalloc(size+1);
	memcpy(str,Str,size+1);
}

CStrRef::CStrRef(CC8 *str)
{
	node=new CStrObj(str);
	node->rcount=1;
}

CStrRef & CStrRef::operator = (CC8 *ptr)
{
	DelRef();
	node=null;
	if (!ptr)
		return *this;
	node=new CStrObj(ptr);
	node->rcount=1;
	return *this;
}

U32 CPathObj::file_exist(void)
{
	XFile file;

	/* default to using relative or short path */
	CC8 *path=file_path;
	/* but use absolute path if available */
	if (abs_path)
		path=abs_path;

	if (file.open(path,"r"))
		return TRUE;
	return FALSE;
}

void CPathObj::set_extension(void)
{
	D_ASSERT(file_path);
	CC8 *dot=fstrprchr(file_path+file_path_len-1,'.',file_path);
	if (dot)
		dot++;
	ext=dot;
	flags|=SETUP_EXT;
}

void CPathObj::set_name(void)
{
	D_ASSERT(file_path);
	CC8 *slash=fstrprchr(file_path+file_path_len-1,OS_SLASH,file_path);
	if (slash)
		slash++;
	file_name=slash;
	flags|=SETUP_NAME;
}

CC8 *CPathObj::get_extension(void)
{
	/* if we haven't setup the extension member yet */
	if (!(flags & SETUP_EXT))
		set_extension();
	return ext;
}

CC8 *CPathObj::get_filename(void)
{
	if (!(flags & SETUP_NAME))
		set_name();
	return file_name;
}

void CPathObj::init_name_path(CC8 *name,CC8 *path)
{
	TmpPrintf tmp(XMAX_PATH);

	if (*path)
	{
		tmp << path;
		char last=*(tmp.get_last());
		if (!((last=='\\') || (last=='/')))
			tmp << OS_SLASH;
		flags|=HAS_REL_PATH;
	}
	U32 name_offset=tmp.get_len();
	
	tmp << name;

	U32 len=tmp.get_len();

	/* pad for some growth/manipulation */
	len+=16;

	file_path=(char *)xmalloc(len);
	file_path_size=(U16)len;

	fstrcpy(file_path,tmp.get_str());
	ext=null;
	file_name=file_path+name_offset;
	file_path_len=(U16)tmp.get_len();

	flags|=SETUP_NAME;
}

void CPathObj::init_abs_path(CC8 *abs_name)
{
	U32 len=fstrlen(abs_name);
	
	/* pad for some growth */
	file_path_len=(U16)len;
	file_path_size=file_path_len+16;

	file_path=(char *)xmalloc(file_path_size);
	fstrcpy(file_path,abs_name);
	file_name=null;
	
	
	flags|=HAS_REL_PATH;
}

void CPathObj::init_name(CC8 *name)
{
	U32 len=fstrlen(name);

	/* pad for some growth */
	file_path_len=(U16)len;
	file_path_size=file_path_len+16;

	file_path=(char *)xmalloc(file_path_size);
	fstrcpy(file_path,name);
	file_name=null;
}

CC8 *CPathRef::init(CC8 *Filename,CC8 *Pathname)
{
	DelRef();

	node=new CPathObj;
	node->init_name_path(Filename,Pathname);

	AddRef();
	
	return node->file_path;
}

CPathRef::CPathRef(CC8 *str)
{
	node=new CPathObj;
	node->init_name(str);

	AddRef();
}

void CPathRef::set_absolute(CC8 *abs_name)
{
	DelRef();

	node=new CPathObj;
	node->init_abs_path(abs_name);
	
	AddRef();
}

U32 CPathObj::is_ext(CC8 *Ext)
{
	if (!ext)
		return FALSE;
	return fstreq(ext,Ext);
}

U32 CPathObj::is_room(U32 more)
{
	if ((file_path_size - file_path_len) > (I32)more) 
		return TRUE;

	return FALSE;
}

void CPathObj::set_extension(CC8 *Ext)
{
	if (ext)
	{
		fstrcpy((char *)ext,Ext);
		return;
	}
	
	CPrintf obj(file_path,file_path_size,file_path_len);

	obj << '.';
	ext=obj.get_cur();
	obj << Ext;
	flags|=SETUP_EXT;
}

void CPathRef::set_extension(CC8 *ext)
{
	D_ASSERT(ext);
	D_ASSERT(node);

	/* if extension isn't really changing */
	if (node->is_ext(ext))
		return;

	/* if we are the only reference */
	if (node->rcount==1)
	{
		if (node->is_room(fstrlen(ext)+1))
		{
			node->set_extension(ext);
			return;
		}
	}
	
	/* ok we need a new node */
	CPathObj *tmp=new CPathObj;
	tmp->init_new_ext(node,ext);
	DelRef();
	node=tmp;
	AddRef();
}

U32 CPathObj::init_new_ext(CPathObj *obj,CC8 *new_ext)
{
	TmpPrintf tmp(XMAX_PATH);

	tmp << obj->file_path;
	
	CC8 *start=tmp.get_str();
	CC8 *end=tmp.get_cur();

	U32 tmp_size=end - start;
	ext=fstrprchr(end-1,'.',start);
	if (ext)
		tmp.set_cur(ext);
	else
		ext=tmp.get_cur();

	if (*ext!='.')
		tmp << '.';

	tmp << ext;
	
	return TRUE;
}

CPathObj::~CPathObj(void)
{
	if (file_path)
		xfree(file_path);
	if (abs_path)
		xfree((void *)abs_path);
	if (just_path)
		xfree((void *)just_path);
}

void StrGrow::copy(CC8 *str)
{
	if (!base)
	{
		U32 len=fstrlen(str);
		init(inc_size+len);
		cur=::fstrcpy(base,str);
		end=base+size;
		return;
	}

keep_copying:
	I32 size_left=end - cur;
	while(size_left-- > 0)
	{
		if (!(*cur=*str++))
			return;
		cur++;
	}

	realloc(inc_size);
	goto keep_copying;
}

U32 StrGrow::copy(CC8 *str,U32 size)
{
	if (size==0)
		return 0;

	I32 size_left=end - cur;

	if ((size_left-size) < 0)
		realloc(inc_size,size);

	U32 i;

	for(i=0;i<size;i++)
	{
		U8 key;

		*cur=key=str[i];
		if (key==0)
			return i;
		cur++;
	}
	*(--cur)=0;
	return (i-1);
}

void StrGrow::path_append(CC8 *more)
{
	if (!base)
	{
		copy(more);
		return;
	}

	U32 size_left=end - cur;

	if (size_left<1)
	{
		U32 len=fstrlen(more);
		realloc(inc_size+len+1);
	}

	if (cur!=base)
	{
		/* if slash is missing put it in */
		if ((cur[-1]!=OS_SLASH) && (cur[-1]!=OS_SLASH_OTHER))
			*cur++=OS_SLASH;
	}

keep_copying:
	size_left=end - cur;
	while(size_left--)
	{
		if (!(*cur=*more++))
			return;
		cur++;
	}

	realloc(inc_size);
	goto keep_copying;
}

/* TODO: eventually write a decent printf class that does more than return a minus 1 when it overflows */
U32 StrGrow::printf(CC8 *str,...)
{
	va_list  args;
	I32      num;

	va_start(args,str);

	while(1)
	{
		/* minus 1 for safety*/
		I32 size_left=end - cur - 1;
		if (size_left > 1)
		{
			num=_vsnprintf(cur,size_left-1,str,args);
			if (num!=-1)
				break;
		}
		realloc(inc_size);
	}
	cur+=num;

	va_end(args);

	return num;
}

U32 StrGrow::num(U32 val)
{
	I32 size_left=end - cur;
	if (size_left < 13)
		realloc(inc_size,13);

	U32 ret=futoa(val,cur);
	cur+=ret;
	return ret;
}

U32 StrGrow::num(I32 val)
{
	I32 size_left=end - cur;
	if (size_left < 13)
		realloc(inc_size,13);
	
	U32 ret=fitoa(val,cur);
	cur+=ret;
	return ret;
}

U32 StrGrow::chr(char key)
{
	I32 size_left=end - cur;
	if (size_left < 1)
		realloc(inc_size,1);

	*cur++=key;
	*cur=0;
	return 1;
}

charp __regcall(1) fset_extension(char *path,CC8 *the_ext)
{
	U32 size=fstrlen(path);
	char *ext;

	for (U32 i=size-1;i>0;i--)
	{
		char key=path[i];

		if (key=='.')
		{
			ext=path+i+1;
			goto found;
		}
		/* if we get to a slash before the '.' */
		if ((key=='\\') || (key=='/'))
		{
			if (i==(size-1))
				xxx_throw("fset_extension: invalid path to set extension");
			break;
		}
	}
	ext=path+size;
	*ext++='.';
found:
	return fstrcpy(ext,the_ext);
}

CC8P __regcall(1) fget_extension(CC8 *path)
{
	U32 size=fstrlen(path);

	for (U32 i=size-1;i>0;i--)
	{
		char key=path[i];

		if (key=='.')
		{
			if (i==size)
				return null;
			return path+i+1;
		}
		/* if we get to a slash before the '.' */
		if ((key=='\\') || (key=='/'))
			return null;
	}
	return null;
}

CC8P __regcall(1) fget_filename(CC8 *path)
{
	U32 size=fstrlen(path);

	for (U32 i=size;i>0;i--)
	{
		char key=path[i];

		if ((key=='\\') || (key=='/'))
		{
			if (i==size)
				return null;
			return path+i+1;
		}
	}
	return path;
}

CC8P __regcall(2) fpath_append(CC8 *path,CC8 *more)
{
	U32 len1,len2;

	len1=fstrlen(path);
	len2=fstrlen(more);

	char *str=(char *)xmalloc(len1+len2+2);

	char *cur=fstrcpy(str,path);
	if ((path[len1-1]=='\\')||(path[len1-1]=='/'))
		fstrcpy(cur,more);
	else
	{
		*cur++=OS_SLASH;
		cur=fstrcpy(cur,more);
	}
	return str;
}
