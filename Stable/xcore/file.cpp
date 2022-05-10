#include "stdcore.h"

using namespace NS_XFILE;

U32 XFile::conv_flags(CC8 *file_flags)
{
	char key;
	U32 flags=0;
	
	while(key=*file_flags++)
	{
		switch(key)
		{
			case 'a':
				state.append=TRUE;
				break;
			case 'w':
				state.write=TRUE;
				break;
			case 'r':
				state.read=TRUE;
				break;
			case 'b':
				state.binary=TRUE;
				break;
			case 't':
				state.text=TRUE;
				break;
			case 'c':
				state.create=TRUE;
				break;
			case 'n':
				state.truncate=TRUE;
				break;
		}
	}
	if (state.binary & state.text)
		return FALSE;

	return TRUE;
}

XFile::XFile(void)
{
}

XFile::XFile(CC8 *Name,CC8 *file_flags)
{
	base_init();

	name=CStr(Name);

	if (!conv_flags(file_flags))
		xxx_throw("XFile::XFile: invalid flags to open file");

	if (!std_open())
		xxx_throw("XFile::XFile: unable to open file");

	set_rd_interface(new XStreamRdDirect(this));
	set_wr_interface(new XStreamWrDirect(this));
}

U32 XFile::open(CC8 *Name,CC8 *file_flags)
{
	if (is_open())
		close();

	base_init();

	if (name)
		delete name;

	name=CStr(Name);

	if (!conv_flags(file_flags))
		return FALSE;

	if (!std_open())
		return FALSE;

	set_rd_interface(new XStreamRdDirect(this));
	set_wr_interface(new XStreamWrDirect(this));

	return TRUE;
}

U32 XFile::close(void)
{
	if (name)
		delete name;
	name=null;
	
	if (!std_close())
		return FALSE;

	state.is_open=FALSE;

	return TRUE;
}

/* TODO: only seek if we actually have to */
/* TODO: avoid seeks if we have loaded it all in memory */
U32 XFile::seek(I32 offset,U32 type)
{
	I32 old_pos_should,delta;

	if (type==FILE_SEEK_CUR)
		offset=(state.pos_should + offset);

#if 0
	switch(type)
	{
		case FILE_SEEK_SET:
			delta=(offset - state.pos_should);
			break;
		case FILE_SEEK_CUR:
			delta=offset;
			offset=(state.pos_should - offset);
			break;
		case FILE_SEEK_END:
			delta=;
			break;
	}
#endif
	
	old_pos_should=state.pos_should;
	U32 ret=std_seek(offset,FILE_SEEK_SET);
	if (!ret)
		return FALSE;

	delta=state.pos_should - old_pos_should;

	rd_int->seek(delta);
	wr_int->seek(delta);
	return TRUE;
}

void XFile::pos_rd(U32 adj,U32 at_adj)
{
	state.pos_should+=adj;
	state.pos_at+=at_adj;
	wr_int->seek(adj);
}

void XFile::pos_wr(U32 adj,U32 at_adj)
{
	state.pos_should+=adj;
	state.pos_at+=at_adj;
	rd_int->seek(adj);
}

CStdOut::CStdOut(void)
{
	if (!open())
		xxx_throw("CStdOut: unable to open stdout in constructor");
}

U32 CStdOut::close(void)
{
	handle=null;
	state.is_open=FALSE;
	
	return TRUE;
}

/* make slashes go proper direction */
/* remove middle doubles slashes like c:\blah\\stuff */
/* remove leading slash like \obj */
	/* don't on unix
/* remove end slash like c:\stupid\
/* TODO: remove same directory stuff like c:\\blah\.\more */
/* TODO: remove parent directory stuff like c:\\stupid\..\dumb */
CC8P __regcall(2) fclean_path(CC8 *path,U32 len)
{
	char *cur;
	
	if (!path)
		xxx_throw("fclean_path: path is null");

	if (!len)
		fstrlen(path);
	
	autochar new_path;

	new_path=(char *)xmalloc(len+1);
	cur=new_path;

	/* clean up slashes */
	while(1)
	{
		U8 key=*path++;
		if (key==OS_SLASH_OTHER)
			key=OS_SLASH;
		*cur++=key;
		if (!key)
			break;
	}

	/* check for more than 2 slashes at beginning */
	if (len > 2)
	{
		if ((new_path[0]==OS_SLASH) && 
			(new_path[1]==OS_SLASH) &&
			(new_path[2]==OS_SLASH))
			return null;
	}
	
	/* validate and determine path like \\server\share */
	U32 server_type=FALSE;
	if (len > 1)
	{
		if ((new_path[0]==OS_SLASH) && 
			(new_path[1]==OS_SLASH))
		{
			if (len<3)
				return null;
			server_type=TRUE;
		}
	}
	/* remove double slashes */
	if (len > 1)
	cur=new_path;
	/* if server type path, skip past first double slash */
	if (server_type)
		cur+=2;
	while(1)
	{
		cur=fstrchr(cur,OS_SLASH);
		if (!cur)
			break;
		/* if double slash, reduce it to one */
		if (cur[1]==OS_SLASH) /* safe since it will be null if we are at end */
		{
			fstrcpy(cur,cur+1);
			len--;
			/* so we redo, in case there is another slash following */
			cur--;
		}
		cur++;
	}

	/* chop off starting slash */
	if (!server_type)
	{
		if (new_path[0]==OS_SLASH)
			fstrcpy(new_path,new_path+1);
	}

	/* skip past end slash chopping if something like c:\ */
	if (len==3)
	{
		if ((new_path[1]==':') && (new_path[2]==OS_SLASH) && (is_alpha(new_path[0])))
			goto done_path;
	}

	/* chop off end slash */
	len=fstrlen(new_path);
	if (new_path[len-1]==OS_SLASH)
		new_path[len-1]=0;

done_path:
	return new_path.release();
}

