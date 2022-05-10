#ifndef _XSTREAM_H_
#define _XSTREAM_H_

namespace NS_XFILE
{
	enum file_seek_enums
	{
		FILE_SEEK_SET	= 0x01,
		FILE_SEEK_CUR	= 0x02,
		FILE_SEEK_END	= 0x03
	};

	enum file_error_enums
	{
		FERROR_WRITE	= 0x01,
		FERROR_READ		= 0x02
	};
}

class CBaseStream;

/*--------------------------------------------*/
/* XBufferReadInt */
/*--------------------------------------------*/
/* description: Buffered read interface base class */
/*--------------------------------------------*/
class XCORE_API XBufferReadInt
{
protected:
	CBaseStream *stream;

	virtual U32 read_direct(void *mem,U32 size,U32 &num_read);
public:
	XBufferReadInt(CBaseStream *Stream) : stream(Stream) {}
	virtual U32 read(void *mem,U32 size,U32 &num_copied,U32 &num_read)=null;
	virtual U32 seek(I32 delta_pos)=null;
	virtual ~XBufferReadInt(void){}
};

/*--------------------------------------------*/
/* XBufferWriteInt */
/*--------------------------------------------*/
/* description: Buffered write interface base class */
/*--------------------------------------------*/
class XCORE_API XBufferWriteInt
{
protected:
	CBaseStream *stream;

	virtual U32 write_direct(cvoid *mem,U32 size,U32 &num_written);
public:
	XBufferWriteInt(CBaseStream *Stream) : stream(Stream) {}
	virtual U32 write(cvoid *mem,U32 size,U32 &num_copied,U32 &num_written)=null;
	virtual U32 seek(I32 delta_pos)=null;
	virtual U32 flush(void)=null;
	virtual ~XBufferWriteInt(void){}
};

/*--------------------------------------------*/
/* XStreamRdDirect */
/*--------------------------------------------*/
/* description: Non-buffered read interface class */
/*--------------------------------------------*/
class XCORE_API XStreamRdDirect : public XBufferReadInt
{
public:
	XStreamRdDirect(CBaseStream *Stream) : XBufferReadInt(Stream){}
	U32 read(void *mem,U32 size,U32 &num_copied,U32 &num_read);
	/* since we aren't buffering, don't need to do anything */
	U32 seek(I32 delta_pos){return TRUE;}
	~XStreamRdDirect(void){}
	XOBJ_DEFINE()
};

/*--------------------------------------------*/
/* XStreamWrDirect */
/*--------------------------------------------*/
/* description: Non-buffered write interface class */
/*--------------------------------------------*/
class XCORE_API XStreamWrDirect : public XBufferWriteInt
{
public:
	XStreamWrDirect(CBaseStream *Stream) : XBufferWriteInt(Stream){}
	U32 write(cvoid *mem,U32 size,U32 &num_copied,U32 &num_written);
	/* since we aren't buffering, don't need to do anything */
	U32 seek(I32 delta_pos){return TRUE;}
	U32 flush(void){return TRUE;}
	~XStreamWrDirect(void){}
	XOBJ_DEFINE()
};

/*--------------------------------------------*/
/* XMemRdBuffer */
/*--------------------------------------------*/
/* description: fully buffered read interface class */
/*--------------------------------------------*/
class XCORE_API XMemRdBuffer : public XBufferReadInt
{
	autochar	mem_buffer;
	U32			buf_size;

	U32			is_read;
	char		*cur;

public:
	XMemRdBuffer(CBaseStream *Stream,U32 size);
	U32 read(void *mem,U32 size,U32 &num_copied,U32 &num_read);
	U32 seek(I32 delta_pos);
	~XMemRdBuffer(void){}
	XOBJ_DEFINE()
};

#pragma pack(push,4)
class XCORE_API XStreamState
{
public:
	U32 loaded : 1;
	U32 read : 1;
	U32 write : 1;
	U32 append : 1;
	U32 binary : 1;
	U32 text : 1;
	U32 create : 1;
	U32 truncate : 1;
	U32 is_open : 1;
	U32 error : 3;

	I32 pos_at;
	I32 pos_should;

	XStreamState(void) : loaded(0),read(0),write(0),append(0),binary(1),text(0),create(0),truncate(0),is_open(0),error(0),pos_at(0),pos_should(0) {}
};
#pragma pack(pop)

/*--------------------------------------------*/
/* CBaseStream */
/*--------------------------------------------*/
/* description: Base stream class */
/*--------------------------------------------*/
class XCORE_API CBaseStream
{
protected:
	XStreamState state;

#ifdef _WIN32
	XHANDLE handle;
#else
	int file_desc;
#endif
	XBufferReadInt	*rd_int;
	XBufferWriteInt	*wr_int;

	virtual void base_init(void);

	inline U32 is_open(void){return (state.is_open);}
	inline void set_open(void){state.is_open=TRUE;}

	void set_rd_interface(XBufferReadInt *rd);
	void set_wr_interface(XBufferWriteInt *wr);
	
	/* for internal adjustment of file pointer */
	/* adjusts only file ptr, not interfaces */
	virtual I32 seek_int(void){return TRUE;}

public:
	~CBaseStream(void)
	{
		delete rd_int;
		delete wr_int;
	}
	virtual U32 close(void)=null;
	/* ignored for default streams */
	virtual U32 ioctl_read(U32 type,U32 size){return TRUE;}
	virtual U32 ioctl_write(U32 type,U32 size){return TRUE;}

	virtual U32 write(cvoid *mem,U32 size,U32 &num_written);
	virtual U32 write(cvoid *mem,U32 size);
	virtual U32 read(void *mem,U32 size,U32 &num_read);
	virtual U32 read(void *mem,U32 size);
	virtual U32 flush(void);
	virtual U32 put(char val){return write(&val,1);}

	virtual CBaseStream & operator << (CC8 *str);
	virtual CBaseStream & operator << (U32 num);
	virtual CBaseStream & operator << (char val);

	virtual void pos_rd(U32 adj,U32 at_adj){}
	virtual void pos_wr(U32 adj,U32 at_adj){}

	U32 get_pos(void){return state.pos_should;}
	U32 get_pos_at(void){return state.pos_at;}
#ifdef _WIN32
	XHANDLE get_handle(void){return handle;}
#endif
};

/*--------------------------------------------*/
/* CStdOut */
/*--------------------------------------------*/
/* description: Base stream class */
/*--------------------------------------------*/
/* Notes: */
/* not fully compatible with std c library, */
/* due to buffering issues */
/*--------------------------------------------*/
class XCORE_API CStdOut : public CBaseStream
{
public:
	CStdOut(void);
	U32 open(void);
	U32 close(void);
	XOBJ_DEFINE()
};

#endif /* ifndef _XSTREAM_H_ */

