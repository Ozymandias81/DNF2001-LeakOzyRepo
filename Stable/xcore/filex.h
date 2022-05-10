#ifndef _FILEX_H_
#define _FILEX_H_

#ifndef _XCORE_H_
#include <xcore.h>
#endif

class XCORE_API XFile : public CBaseStream , private CSysObj
{
	autochar	name;

	void base_init(void){CBaseStream::base_init();name=null;}
	U32 std_open(void);
	U32 std_close(void);
	U32	std_seek(I32 offset,U32 type);
	U32 destroy(void);
	U32 conv_flags(CC8 *flags);

	U32 seek_int(I32 delta){return std_seek(delta,NS_XFILE::FILE_SEEK_CUR);}

public:
	XFile(void);
	XFile(CC8 *Name,CC8 *file_flags);

	~XFile(void)
	{
		if (is_open())
			std_close();
	}

	U32 open(CC8 *Name,CC8 *file_flags);
	/* TODO: add separate seek for read and write */
	U32 seek(I32 offset,U32 type=NS_XFILE::FILE_SEEK_CUR);
	U32 load_in_memory(U32 max_size=16*1024*1024);
	U32 close(void);
	void pos_rd(U32 adj,U32 at_adj);
	void pos_wr(U32 adj,U32 ad_adj);
	XOBJ_DEFINE()
};

class XFindLevel;

#pragma pack(push,4)
class FindInfoFlags
{
public:
	U32 directory : 1;
	U32 read_only : 1;
	U32 hidden : 1;

	FindInfoFlags(void){((U32 *)this)[0]=0;}
	void reset(void){((U32 *)this)[0]=0;}
};
#pragma pack(pop)

class XFindInfo
{
	StrGrow name;
	StrGrow full_path;
	friend class XFindFile;

public:
	FindInfoFlags flags;

protected:
#ifdef _WIN32
	/* full path minus filename */
	void set(CC8 *path,X_WIN32_FIND_DATA *info);
	/* calculates full path minus file name based path parameter */
	void set_path(CC8 *path,X_WIN32_FIND_DATA *info);
#endif

public:
	CC8 *get_filename(void){return name;}
	CC8 *get_full_path(void){return full_path;}
	U32 is_dir(void){return flags.directory;}
};

enum find_enums{FIND_RECURSIVE=1,FIND_DIRECTORY=2,FIND_LIMIT_DIRECTORY=4,FIND_CASE_SENSITIVE=8,FIND_WILD_ACROSS_SLASH=0x10,FIND_MAX_DEPTH=1024};

class XCORE_API XFindLevel
{
	XHANDLE   handle;

	autochar str;
	autochar path;

public:
	XFindLevel(CC8 *path,CC8 *more_path,CC8 *search);
#ifdef _WINDOWS_
	U32 init(WIN32_FIND_DATA *data);
	U32 next(WIN32_FIND_DATA *data);
#endif
	U32 has_handle(void)
	{
		if (handle==INVALID_XHANDLE_VALUE)
			return FALSE;
		return TRUE;
	}
	CC8 *get_path(void){return path;}
};

#pragma pack(push,4)
class FindState
{
public:
	U32 has_info : 1;
	U32 is_recursive : 1;
	U32 search_extra : 1;
	U32 absolute_path : 1;
	U32 no_wildcard : 1;
	U32 server_type : 1;
	U32 local_type : 1;
	U32 base_is_volume : 1;
	U32 case_sensitive : 1;
	U32 wild_cross_slash : 1;
	U32 find_directories : 1;
	U32 want_dots : 1;
	U32 at_directory : 1;
	U32 depth : 10;

	FindState(void){((U32 *)this)[0]=0;}
	void reset(void){((U32 *)this)[0]=0;}
};
#pragma pack(pop)

/* supports wildcards, and commas */
class XCORE_API XFindFile
{
	autochar			base_path;
	autochar			match_str;
	autochar			search_str;
	XList<XFindLevel>	search_stack;
	XFindInfo			*info;
	XFindInfo			*private_info;
	FindState			state;
	X_WIN32_FIND_DATA	find_data;

protected:
	void search_end(void);
	U32 do_search(void);
	U32 match_request(void);
	CC8 *set_current_dir(CC8 *path,U32 size);
	CC8 *set_parent_dir(CC8 *path,U32 size);
	U32 find_dir(CC8 *path);
	U32 find_path(CC8 *path);
	U32 match_in_wild(CC8 *s_exp,CC8 *s_str,I32 exp_left,I32 str_left,char **partial);
	U32 fstrrexp_eq(CC8 *exp,CC8 *str,char **partial);
	void build_paths(CC8 *base,CC8 *match);
	void set_state(U32 flags);

public:
	XFindFile(void) : info(null),private_info(null) {}
	~XFindFile(void);
	U32 search(CC8 *path,CC8 *match,U32 flags=0);
	XFindInfo *next(U32 &depth);
};

#endif /*ifndef _FILEX_H_ */
