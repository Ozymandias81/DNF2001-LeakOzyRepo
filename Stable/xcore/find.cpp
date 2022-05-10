#include "stdcore.h"
#include <malloc.h>

class FindHandle
{
	XHANDLE handle;

public:
	FindHandle(void) : handle(INVALID_XHANDLE_VALUE) {}
	~FindHandle(void) {if (handle!=INVALID_XHANDLE_VALUE) FindClose(handle);}

	inline FindHandle &operator = (XHANDLE hnd)
	{
		handle=hnd;
		return *this;
	}
	inline operator XHANDLE () {return handle;}
	inline operator const XHANDLE () const {return handle;}
};

class restore_path
{
	char *start_path;
public:
	restore_path(U32 Init) : start_path(null) {if (Init) init();}
	restore_path(void) : start_path(null) {init();}
	~restore_path(void);
	void init(void);
};

void restore_path::init(void)
{
	U32 size=GetCurrentDirectory(0,null);

	start_path=(char *)xmalloc(size);
	GetCurrentDirectory(size,start_path);
}

restore_path::~restore_path(void)
{
	if (start_path)
	{
		if (!SetCurrentDirectory(start_path))
			xxx_throw("Unable to restore path");
	}
}

XFindFile::~XFindFile(void)
{
	delete info;
	info=null;
	delete private_info;
	private_info=null;
}

CC8 *XFindFile::set_current_dir(CC8 *path,U32 len)
{
	autochar new_path;

	U32 size=GetCurrentDirectory(0,null);
	if (len<3)
	{
		/* just set current directory to working path */
		if (len==2)
		{
			new_path=(char *)xmalloc(size);
			GetCurrentDirectory(size,new_path);
			return new_path;
		}
		else
			xxx_throw("XFindFile::set_current_dir: invalid_params");
	}
	/* more than enough */
	new_path=(char *)xmalloc(size+len);
	GetCurrentDirectory(size,new_path);

	/* tack on path after .\ to end */
	if ((path[0]!='.') && (path[1]!=OS_SLASH))
		xxx_throw("XFindFile::set_current_dir: path variable is bad");
	
	path+=2;
	new_path[size]=OS_SLASH;
	fstrcpy(new_path+size+1,path);

	return new_path.release();
}

CC8 *XFindFile::set_parent_dir(CC8 *path,U32 len)
{
	autochar new_path;

	char *file_part;

	U32 size=GetFullPathName("..",0,null,&file_part);

	if (len<4)
	{
		/* just set current directory to working path */
		if (len==3)
		{
			new_path=(char *)xmalloc(size);
			GetCurrentDirectory(size,new_path);
			return new_path;
		}
		else
			xxx_throw("XFindFile::set_parent_dir: invalid_params");
	}
	/* more than enough */
	new_path=(char *)xmalloc(size+len);
	GetFullPathName("..",size,new_path,&file_part);

	/* tack on path after .\ to end */
	if ((path[0]!='.') && (path[1]!='.') && (path[2]!=OS_SLASH))
		xxx_throw("XFindFile::set_parent_dir: path variable is bad");
	
	path+=3;
	new_path[size]=OS_SLASH;
	fstrcpy(new_path+size+1,path);

	return new_path.release();
}

void XFindFile::set_state(U32 flags)
{
	/* reset search state */
	state.reset();
	/* delete ptrs */
	if (base_path)
		delete base_path;
	if (match_str)
		delete match_str;
	if (search_str)
		delete search_str;

	/* set flags */
	if (flags & FIND_RECURSIVE)
	{
		state.is_recursive=TRUE;
		state.search_extra=TRUE;
	}
	if (flags & FIND_CASE_SENSITIVE)
		state.case_sensitive=TRUE;
	if (flags & FIND_WILD_ACROSS_SLASH)
		state.wild_cross_slash=TRUE;
	if (flags & FIND_DIRECTORY)
		state.find_directories=TRUE;

	state.search_extra=TRUE;
}

void XFindFile::build_paths(CC8 *base,CC8 *match)
{
	search_str=CStr("*");
	
	if (!state.absolute_path)
	{
		char *part;
		U32 size;

		size=GetFullPathName(base,0,null,&part);
		char *tmp=(char *)_alloca(size);
		GetFullPathName(base,size,tmp,&part);
		
		size--;
		base_path=CStr(tmp,size);
	}
	else
	{
		base_path=CStr(base);
	}

	U32 len=fstrlen(base_path);

	if (len==3)
	{
		if ((is_alpha(base_path[0])) && (base_path[1]==':') && (base_path[2]==OS_SLASH))
			state.base_is_volume=TRUE;
	}

	match_str=CStr(match);
}

U32 XFindFile::search(CC8 *base,CC8 *match,U32 flags)
{
	if (!match)
		return FALSE;

	/* make sure we aren't already doing a search with this object */
	D_ASSERT(!search_stack.get_head());

	/* allocate info structure if doesn't exist */
	if (!info)
		info=new XFindInfo;

	autochar clean_path;
	autochar clean_match;

	U32 len,len_match;
	/* tidy up path strings */
	if (base)
	{
		len=fstrlen(base);
		if (fstrchr(base,'*'))
			xxx_throw("XFindFile::search: Invalid path format");
		base=clean_path=(char *)fclean_path(base,len);
		if (!base)
			xxx_throw("XFindFile::search: Invalid path format");
	}
	
	len_match=fstrlen(match);
	match=clean_match=(char *)fclean_path(match,len_match);
	if (!match)
		xxx_throw("XFindFile::search: Invalid match format");

	set_state(flags);

	if ((base) && (len > 1))
	{
		/* probably absolute path using ..\ or .\  or c:\ \\server */
		if ((base[0]=='.') || (base[1]==':') || (base[0]==OS_SLASH))
		{
			autochar	new_path;

			if ((base[0]=='.') && (base[1]==OS_SLASH))
			{
				new_path=(char *)set_current_dir(base,len);
				return search(new_path,match,flags);
			}
			
			/* if server share based string */
			if ((base[0]=='\\') && (base[1]=='\\'))
			{
				if (len < 3)
					return FALSE;
				if (!is_alpha(base[2]))
					return FALSE;

				state.absolute_path=TRUE;
				state.server_type=TRUE;
			}

			if (len > 2)
			{
				if ((base[1]=='.') && (base[2]=='.') && (base[3]==OS_SLASH))
				{
					new_path=(char *)set_parent_dir(base,len);
					return search(new_path,match,flags);
				}
				if ((base[1]==':') && (is_alpha(base[0])) && (base[2]=='\\'))
				{
					state.absolute_path=TRUE;
					state.local_type=TRUE;
				}
			}
		}
	}

	if (!base)
	{
		U32 size=GetCurrentDirectory(0,null);
		char *tmp=(char *)_alloca(size);
		GetCurrentDirectory(size,tmp);
		base=tmp;
		state.absolute_path=TRUE;
	}

	/* check for wildcards */
	if (!fstrchr(match,'*'))
		state.no_wildcard=TRUE;

	/* calculate needed paths base_path,search_str*/
	build_paths(base,match);

	/* if base_path is volume, like c:\ */
	/* then check if volume is available */
	if (state.base_is_volume)
	{
		U32 volume=GetLogicalDrives();
		U32 letter=base_path[0];

		letter=fsetlower(letter) - 'a';
		if (!((1<<letter) & volume))
			return FALSE;
	}
	else
	{
		if (!find_dir(base_path))
			return FALSE;
	}

	XFindLevel *level=new XFindLevel(base_path,null,search_str);
	search_stack.add_head(level);

	/* actually do search */
	if (do_search())
		return TRUE;

	return FALSE;
}

XFindInfo *XFindFile::next(U32 &depth)
{
	while(!state.has_info)
	{
		/* if search fails */
		if (!do_search())
			return null;
	}

	state.has_info=FALSE;
	depth=state.depth;
	return info;
}

U32 XFindFile::do_search(void)
{
	while(1)
	{
		U32 skip;

		if (state.has_info)
			return TRUE;

		XFindLevel *head=search_stack.get_head();
		if (!head)
			return FALSE;

		skip=FALSE;

		/* if at directory we need to go down tree instead of finding next file */
		if (state.at_directory)
		{
			state.at_directory=FALSE;
			if (state.is_recursive)
				goto skip_to_recursive;
		}
		/* reset at directory state */
		state.at_directory=FALSE;
		if (!head->has_handle())
		{
			if (!head->init(&find_data))
			{
				search_stack.remove_head();
				continue;
			}
		}
		else
		{
			if (!head->next(&find_data))
			{
				head=search_stack.remove_head();
				delete head;
				state.depth--;
				continue;
			}
		}
		info->set(head->get_path(),&find_data);
		if (state.search_extra)
		{
			if (info->is_dir())
			{
				CC8 *name=info->get_filename();
				U32 len=fstrlen(name);

				if (len==1)
				{
					if (name[0]=='.')
						skip=TRUE;
				}
				else if (len==2)
				{
					if ((name[0]=='.') && (name[1]=='.'))
						skip=TRUE;
				}
			}
			if ((!skip) || (state.want_dots))
			{
				if (match_request())
				{
					state.has_info=TRUE;
					if (info->is_dir())
						state.at_directory=TRUE;
					return TRUE;
				}
			}
skip_to_recursive:
			if (state.is_recursive)
			{
				if (info->is_dir())
				{
					/* don't change directories if the directory is "." or ".." */
					if (!skip)
					{
						if (state.depth<FIND_MAX_DEPTH)
						{
							state.depth++;
							XFindLevel *level=new XFindLevel(head->get_path(),info->get_filename(),search_str);
							search_stack.add_head(level);
						}
					}
				}
			}
		}
		else
			return TRUE;
		/* keep on searching along */
	}
}

U32 XFindFile::find_dir(CC8 *path)
{
	U32 ret=find_path(path);

	return private_info->is_dir();
}

U32 XFindFile::find_path(CC8 *path)
{
	FindHandle handle;
	
	if (!private_info)
		private_info=new XFindInfo;

	handle=FindFirstFile(path,&find_data);
	if ((HANDLE)handle!=INVALID_XHANDLE_VALUE)
	{
		private_info->set_path(path,&find_data);
		return TRUE;
	}
	return FALSE;
}

#define MATCH_PARTIAL 1
#define MATCH_EXACT	  2
U32 XFindFile::match_in_wild(CC8 *s_exp,CC8 *s_str,I32 exp_left,I32 str_left,char **partial)
{
	CC8 *exp=s_exp;
	CC8 *str=s_str;

	U32 key1,key2;

	/* advance key1 to non-wildcard */
	do
	{
		D_ASSERT(exp_left>=0);
		key1=exp[exp_left--];
		if (key1!='*')
			break;
		if (exp_left<0)
			return MATCH_EXACT;
	}while(1);
	/* scan till we hit matching character */
	U32 match_left;

find_match:
	do
	{
		D_ASSERT(str_left>=0);
		key2=str[str_left--];
		if (key2==OS_SLASH)
		{
			if (!state.wild_cross_slash)
				return FALSE;
		}
		if (key2==key1)
			break;
		if (str_left<0)
			return FALSE;
	}while(1);
	match_left=str_left;
	/* scan matches till failure */
	do
	{
		if (exp_left<0)
		{
			/* if no string and no expression left, is match */
			if (str_left<0)
				return MATCH_EXACT;

			if (str[str_left]==OS_SLASH)
				return MATCH_PARTIAL;

			return FALSE;
		}
		if (str_left<0)
		{
			/* still have some expression left, but no more string */
			/* no match */
			return FALSE;
		}
		D_ASSERT(exp_left>=0);D_ASSERT(str_left>=0);
		key1=exp[exp_left--];
		key2=str[str_left--];
		if (key1=='*')
		{
			/* special case if * is first character */
			if (exp_left<0)
				return MATCH_EXACT;

			U32 ret;
			if (ret=match_in_wild(exp,str,exp_left,++str_left,partial))
				return ret;

			/* go to next matching character and continue */
			str_left=match_left;
			goto find_match;
		}
		else if (key1!=key2)
			return FALSE;
	}while(1);
}

U32 XFindFile::fstrrexp_eq(CC8 *exp,CC8 *str,char **partial)
{
	I32 len_exp,len_str;

	D_ASSERT(exp);D_ASSERT(str);
	
	len_exp=fstrlen(exp);
	len_str=fstrlen(str);

	/* convert the strings to lower case, if not case sensitive */
	if (!state.case_sensitive)
	{
		char *new_exp=(char *)_alloca(len_exp+1);
		char *new_str=(char *)_alloca(len_str+1);

		fstrcpy_tolower(new_exp,exp);
		fstrcpy_tolower(new_str,str);

		exp=new_exp;
		str=new_str;
	}

	/* if either string is empty */
	if ((!len_exp) || (!len_str))
	{
		/* if both strings are empty */
		if ((!len_str)&&(!len_exp))
			return TRUE;
		return FALSE;
	}

	len_str--;len_exp--;

	do
	{
		U32 key1,key2;

		key1=exp[len_exp--];
		key2=str[len_str--];

		if (key1=='*')
		{
			/* special case if * is first character */
			if (len_exp<0)
				return MATCH_EXACT;
			return match_in_wild(exp,str,len_exp,++len_str,partial);
		}
		else if (key1!=key2)
			return FALSE;
		if (len_exp<0)
		{
			if (len_str<0)
				return MATCH_EXACT;
			if (str[len_str]==OS_SLASH)
				return MATCH_PARTIAL;
			return FALSE;
		}
		if (len_str<0)
		{
			/* still have some expression left, but no more string */
			/* no match */
			return FALSE;
		}
	}while(1);

	return TRUE;
}

/* TODO: bug in that match can occur past before base directory */
U32 XFindFile::match_request(void)
{
	char *partial;

	if ((state.find_directories) && (info->is_dir()))
		return TRUE;

	U32 ret=fstrrexp_eq(match_str,info->get_full_path(),&partial);

	if (!ret)
		return FALSE;

	return TRUE;
}

void XFindInfo::set_path(CC8 *path,WIN32_FIND_DATAA *info)
{
	char *file_part;

	U32 size=GetFullPathName(path,0,null,&file_part);
	char *tmp_path=(char *)_alloca(size);
	GetFullPathName(path,size,tmp_path,&file_part);

	if (file_part)
	{
		/* chop off filename */
		if (file_part > tmp_path)
			file_part[-1]=0;
	}

	set(tmp_path,info);
}

void XFindInfo::set(CC8 *path,WIN32_FIND_DATAA *info)
{
	D_ASSERT(path);D_ASSERT(info);

	flags.reset();

	if (info->dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY)
		flags.directory=TRUE;
	if (info->dwFileAttributes & FILE_ATTRIBUTE_HIDDEN)
		flags.hidden=TRUE;
	if (info->dwFileAttributes & FILE_ATTRIBUTE_READONLY)
		flags.read_only=TRUE;

	name=info->cFileName;
	full_path=path;

	full_path.path_append(info->cFileName);
}

XFindLevel::XFindLevel(CC8 *Path,CC8 *add_path,CC8 *search) : handle(INVALID_HANDLE_VALUE)
{
	if (add_path)
		path=(char *)fpath_append(Path,add_path);
	else
		path=CStr(Path);

	str=(char *)fpath_append(path,search);
}

U32 XFindLevel::init(WIN32_FIND_DATA *data)
{
	handle=FindFirstFile(str,data);
	if (handle==INVALID_HANDLE_VALUE)
		return FALSE;
	return TRUE;
}

U32 XFindLevel::next(WIN32_FIND_DATA *data)
{
	if (!FindNextFile(handle,data))
		return FALSE;

	return TRUE;
}

