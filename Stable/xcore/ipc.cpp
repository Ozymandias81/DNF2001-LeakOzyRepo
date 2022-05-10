#include <windows.h>
#include "xcore.h"

#pragma intrinsic(strlen)


ComInfo::ComInfo(char *MapBase,char *ptr,U32 Size)
{
	map_base=MapBase;

	/* align com block */
	com=(ComBlock *)ALIGN_POW2(ptr,8);

	/* align buffer to 32 byte boundary */
	buffer_ptr=(char *)ALIGN_POW2((com+1),32);
	buffer_offset=(U32)(buffer_ptr - map_base);

	/* adjust size to compensate for structures and alignment */
	buffer_size=Size - (buffer_ptr - ptr);

	com->init(buffer_offset,buffer_size);
}

ComInfo *ComInfo::split(U32 Size)
{
	ComBlock *new_block;
	
	new_block=(ComBlock *)ALIGN_POW2((buffer_ptr+Size),8);
	char *new_buffer=(char *)ALIGN_POW2((new_block+1),32);
	U32 size_left=(U32)((buffer_ptr + buffer_size) - new_buffer);
	/* if not a reasonable size left, don't split */
	if (size_left < 512)
		return null;

	size_left=(U32)(buffer_size - (((char *)new_block) - buffer_ptr));
	ComInfo *node=new ComInfo(map_base,(char *)new_block,size_left);
	return node;
}

IPCServer::IPCServer(CC8 *Name,U32 MapSize)
{
	if (!init(Name,map_size))
		xxx_throw("IPCServer: Unable to intialize");
}

U32 IPCServer::init(CC8 *Name,U32 MapSize)
{
	D_ASSERT(Name);
	
	/* align memory map size to 32K */
	map_size=ALIGN_POW2(MapSize,32*1024);

	/* setup interprocess mutex */
	if (!mutex.init(TRUE,TRUE,Name))
		xxx_bitch("IPCServer: Unable to initialize mutex");

	D_ASSERT(mutex.is_locked());

	if (map_name)
		delete map_name;

	map_name=CStrCat(Name,"_map");

	/* protects us from any potential throws */
	AutoMutex automutex(&mutex);

	/* setup memory mapping for IPC message passing */
	mapping=new CMemMap(TRUE,map_name,map_size);
	if (!mapping->is_mapped())
	{
		xxx_bitch("IPCServer: Unable to obtain memory map");
		delete mapping;
		return FALSE;
	}
	
	/* setup list of available channels */
	ComInfo *free_com=new ComInfo((char *)mapping->get_ptr(),(char *)mapping->get_ptr(),mapping->get_size());
	free_channels.add_head(free_com);

	/* get block for server write to client */
	write_core=get_channel(2048);
	used_channels.add_head(write_core);
	/* get block for server reads from client */
	read_core=get_channel(4096);
	used_channels.add_head(read_core);

	/* if we got this far, we should be ready for messages */
	/* so lets release the mutex */
	mutex.unlock();
	return TRUE;
}

ComInfo *IPCServer::get_channel(U32 size)
{
	ComInfo *info;

	while(info=free_channels.get_head())
	{
		if (info->get_size() >= size)
			break;
	}
	/* didn't find free space big enough for channel */
	if (!info)
		return FALSE;

	/* we are taking the head, so take it off the free list */
	free_channels.remove_head();

	/* split the existing block */
	ComInfo *new_block=info->split(size);
	/* if a new block was created add it to the free list */
	if (new_block)
		free_channels.add_head(new_block);

	return info;
}

IPCClient::IPCClient(CC8 *Name,U32 Timeout)
{
	if (!init(Name,timeout))
		xxx_throw("IPCClient: Unable to initialize");
}

U32 IPCClient::init(CC8 *Name,U32 Timeout)
{
	timeout=Timeout;
	D_ASSERT(Name);

	if (!mutex.init(FALSE,FALSE,Name))
		xxx_bitch("IPCClient: Unable to initialize mutex");

	/* aquire the mutex */
	AutoMutex	mlock(&mutex,timeout);

	if (!mlock.is_locked())
	{
		xxx_bitch("IPCClient: Unable to obtain mutex");
		return FALSE;
	}

	if (map_name)
		delete map_name;

	map_name=CStrCat(Name,"_map");

	/* we aquired the mutex, so we lets get the memory mapping now */
	mapping=new CMemMap(map_name);
	if (!mapping->is_mapped())
	{
		xxx_bitch("IPCClient: Unable to obtain memory map");
		delete mapping;
		return FALSE;
	}
	
	char *map_base=(char *)mapping->get_ptr();
	CoreHeader *map_info=(CoreHeader *)map_base;
	ComBlock *read_base=(ComBlock *)(map_info->read_offset + map_base);
	ComBlock *write_base=(ComBlock *)(map_info->write_offset + map_base);

	/* get base communication channel */
	if (!core_channel.init(&mutex,read_base,write_base))
	{
		xxx_bitch("IPCClient: Unable to initialize core channel");
		return FALSE;
	}

	/* use base channel to request private channel for most data interaction so we don't stall */
	if (!core_channel.request_new(&client_channel,16*1024))
	{
		xxx_bitch("IPCClient: Unable to get dedicated private channel");
		return FALSE;
	}

	return TRUE;
}

class ChannelReq : public IPCHeader
{
	U32 req_size;
};

U32 IPCChannel::read_block(void *mem,U32 size)
{
	U32 total_size=size;

	while(size)
	{
		/* clear signal */
		ResetEvent(read_event);

		/* read whatever is currently in buffer */
		U32 num_read=read_buffer.read(mem,size);
		size-=num_read;
		/* if size left, wait for more data from server */
		if (size)
		{
			ret=WaitForSingleObject(read_event,timeout);
			if (ret!=WAIT_OBJECT_0)
				return FALSE;
		}
	}	
	
	return total_size;
}

U32 CoreChannel::write(cvoid *mem,U32 size)
{
	if (!write_buffer.write(mem,size))
		return FALSE;
	/* signal server that data is waiting */
	SetEvent(write_event);
}

U32 CoreChannel::init(XMutex *mutex,ComBlock *com)
{
	AutoMutex mlock(mutex);

	if (!mutex->is_locked())
	{
		xxx_bitch("CoreChannel::init: Unable to lock mutex");
		return FALSE;
	}

	write_buffer.init(com->get_write(),com->size);
	read_buffer.init(com->get_read(),com->size);
	
	/* request channel of default size, but require wakeup */
	ChannelReq	request(0,TRUE);
	
	if (!write(request,sizeof(ChannelReq)))
		xxx_throw("CoreChannel::init: write failure");
	
	if (!read_block(response,sizeof(IpcHeader))
		xxx_throw("CoreChannel::init: read failed");

	handle_response(response);
}

using namespace NS_LOG;

class IPCErrorHeader : public IPCHeader
{
	U32 level;
public:
	inline IPCErrorHeader(U32 Level)
		: IPCHeader(LOG_MSG_ERROR,sizeof(IPCErrorHeader)),
		level(Level){}
};

IPCClient &IPCClient::operator << (IPCHeader *Header)
{
	if (header)
	{
		xxx_bitch("IPCClient: Last packet is never sent");
		end();
	}
	header=Header;
	return *this;
}

IPCClient &IPCClient::operator << (CC8 *str)
{
	U32 len=strlen(str);
	header->size+=len;
	if (!send(str,len))
		xxx_throw("IPCClient(U32): send failed");
	
	return *this;
}

IPCClient &IPCClient::operator << (U32 num)
{
	char num_str[12];
	U32 len;

	len=fitoa(num,num_str);
	header->size+=len;
	if (!send(num_str,len))
		xxx_throw("IPCClient(U32): send failed");

	return *this;
}

get mutex
send data
send notification
wait for response
etc...
release

/* basic client channel aquiring phase */
get_mutex + channel_avail;
take channel_info
reset channel_avail
set channel_taken
release mutex

/* server client channel aquiring phase */
wait for channel_taken to be signaled
reset channel_taken
set channel_avail

core_channel.init();

U32 CoreChannel::init(ComBlock *com)
{
	AutoMutex mutex(core_mutex);

	if (!mutex.is_locked()
		return FALSE;
}

void CoreChannel::acquire_channel(void)
{	
	AutoMutex	auto_mutex(core_mutex);	
}


void IPCBuffer::set_read(void)
{
	read_ptr=(char *)(*server_read);
}

/* set server read ptr */
IPCBuffer *IPCClient::get_packet(void)
{
	channel.set_read();

	return &channel;
}

U32 IPCClient::send(cvoid *data,U32 size)
{
	IPCBuffer *packet;

	if ((size+header->size) > max_packet_size)
		xxx_throw("IPCClient::send: packet exceeds max size");

	packet=get_packet();

	/* FIXUP */
	/* add support for this */
	if (packet->get_total_room() < size)
		xxx_throw("IPCClient::send: not room for packet");
	
	packet.write(data,size);
	/* notify server of new packet */
	packet.bump();

	return TRUE;
}

class CErrorIPC : public CError
{
	IPCLogClient	client;

public:
	CErrorIPC(void);
	void message(U32 level,CC8 *str);
	void throw_msg(U32 level,CC8 *str);
	void assert(CC8 *file,U32 line);
};

void CErrorIPC::message(U32 level,CC8 *str)
{
	IPCErrorHeader	header(level);

	client << &header;
	client << str;
	client.end();

	if (level==ERROR_FATAL)
		_dll._fatal_exit();
}

void CErrorIPC::throw_msg(U32 level,CC8 *str)
{
	IPCErrorHeader	header(level);

	client << &header;
	client << str;
	client.end();

	throw;
}

/* right now asserts are fatal */
void CErrorIPC::assert(CC8 *file,U32 line)
{
	IPCErrorHeader header(ERROR_FATAL);

	client << &header;
	client << "Assert: file: " << file << "on line " << line;
	client.end();

	_dll._fatal_exit();
}