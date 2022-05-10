/* for interprocess communication */
#ifndef _XIPC_H_
#define _XIPC_H_

/* IPC Explanation */
/* The IPCServer creates a mutex with the name given */
/* It then creates a memory mapped file with the name with _map at end */
/* like if name is IPC_Logging, then mapped name is IPC_Logging_map */

/* IPC Servers are required to support at least 2 messages */
/* MSG_CHANNEL- which basically requests a communication channel for a process */
/* MSG_ALLOC- which allows allocation of memory in memory mapped space */

/* -------------------------------*/
/* CoreHeader */
/* -------------------------------*/
/* Header at beginning of memory map, pointing to the core read write com blocks */
class CoreHeader
{
public:
	U32 read_offset;
	U32 write_offset;
};

/* -------------------------------*/
/* ComBlock */
/* -------------------------------*/
/* IPC block representing one way state of the communication system */
/* can represent the write or read portion */
class ComBlock
{
public:
	U32 offset;		/* offset of com_buffer off of base of memory map */
	U32 size;		/* size of com_buffer */

	U32	stamp;		/* communication stamp */
	U32	location;	/* current offset_location of write_ptr */

	void init(U32 Offset,U32 Size)
	{
		offset=Offset;size=Size;
		stamp=0;location=Offset;
	}
};

class ComInfo
{
	char		*map_base;
	char		*buffer_ptr;
	U32			buffer_offset;
	U32			buffer_size;
	ComBlock	*com;

public:
	ComInfo(char *MapBase,char *ptr,U32 Size);
	ComInfo *split(U32 size);
	U32 get_size(void){return buffer_size;}
};

/* -------------------------------*/
/* IPCChannel */
/* -------------------------------*/
/* represents a channel between processes */
class IPCChannel
{
	volatile ComBlock	*read_com;
	char				*read_base;
	U32					read_size;
	volatile ComBlock	*write_com;
	char				*write_base;
	U32					write_size;


	RingBuffer write_buffer;
	RingBuffer read_buffer;
	
	XEvent	write_event;
	XEvent	read_event;

	void set_read(char *ptr)
	{
		D_ASSERT(ptr > read_base);
		D_ASSERT(ptr <= (read_base + read_size));
		
		read_com->location=ptr - read_base;
	}
	void set_write(char *ptr)
	{
		D_ASSERT(ptr > write_base);
		D_ASSERT(ptr <= (write_base + write_size));
		
		write_com->location=ptr - write_base;
	}
public:
	U32 read_block(void *mem,U32 size);
	U32 write(cvoid *mem,U32 size);
};

class ClientChannel
{
	XMutex		core_mutex;

public:
	U32 init(XMutex *core,ComBlock *read_com,ComBlock *write_com);
};

class PrivateChannel
{
	volatile ComBlock *com;

public:
	U32 init(ComBlock *read_com,ComBlock *write_com);
};

class IPCHeader
{
public:
	U32 type;
	U32 size;
	U32 wakeup;

	U32 pkt_id;

	inline IPCHeader(U32 Type,U32 Size,U32 Wakeup=FALSE) : type(Type),size(Size),wakeup(Wakeup) {}
};

class IPCServer
{
	enum ipc_enums{MEM_MAP_DEFAULT=32*1024};
	autochar			name;
	autoptr<CMemMap>	mapping;
	autochar			map_name;
	U32					map_size;
	XMutex				mutex;

	ComInfo				*write_core;
	ComInfo				*read_core;

	/* server doesn't need mutex lock for using core_channel */
	PrivateChannel			core_channel;
	XList<PrivateChannel>	private_channels;
	XList<ComInfo>			free_channels;
	XList<ComInfo>			used_channels;

	U32 handle_response(IPCHeader *header);
	ComInfo *get_channel(U32 size);

public:
	IPCServer(CC8 *name,U32 MapSize=MEM_MAP_DEFAULT);
	U32 init(CC8 *name,U32 MapSize=MEM_MAP_DEFAULT);
};

class IPCClient
{
	autochar			name;
	U32					timeout;
	XMutex				mutex;
	autochar			map_name;
	autoptr<CMemMap>	mapping;
	
	ClientChannel		core_channel;
	PrivateChannel		main_channel;

	IPCHeader			*header;

	IPCChannel *get_channel(void);

	U32 handle_response(IPCHeader *header);

public:
	IPCClient(CC8 *name,U32 Timeout=TIMEOUT_INFINITE);
	U32 init(CC8 *name,U32 Timeout=TIMEOUT_INFINITE);
	U32 end(void);
	U32 send(cvoid *data,U32 size);
	U32 send_block(cvoid *data,U32 size);
	IPCClient & operator << (CC8 *str);
	IPCClient & operator << (U32 num);
	IPCClient & operator << (IPCHeader *header);
};

enum ipc_message_enums
{
	/* system messages */
	RESP_MSG_UNSUPPORTED	=0,
	/* request for dedicated channel */
	IPC_MSG_CHANNEL			=1,
	/* channel responses */
	RESP_MSG_CHANNEL_PTR	=1,	/* response for dedicated IPC channel, giving a ptr */
	RESP_MSG_CHANNEL_MAP	=2, /* response for dedicated IPC channel, giving info for a memory map */
	/* request for dedicated memory block */
	IPC_MSG_ALLOC			=2,	/* request for IPC memory */

	/* implementation specific messages */
	IPC_MSG_START	=0x10000
};

namespace NS_LOG
{
	enum log_message_enums
	{
		LOG_MSG_START		=IPC_MSG_START,
		LOG_MSG_ERROR		=0 + LOG_MSG_START,
		LOG_MSG_FILE_LOAD	=1 + LOG_MSG_START
	};

	class IPCLogServer : public IPCServer
	{
	public:
		IPCLogServer(void) : IPCServer("XLog") {}
	};

	class IPCLogClient : public IPCClient
	{
	public:
		IPCLogClient(void) : IPCClient("XLog") {}
	};
} /* end of namespace NS_LOG */

#endif /* ifndef _XIPC_H_ */