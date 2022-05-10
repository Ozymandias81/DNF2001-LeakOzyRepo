/******************************************************************************
                         Simple Networking Layer:
******************************************************************************/
#include <assert.h>
#include <ctype.h>
#include <stdarg.h>                        /* Handling length argument lists */
#include <stdio.h>                                    /* Needed for vsprintf */
#include <stdlib.h>             /* Needed for most of the C run time library */
#include <string.h>
#include <time.h>          /* Various functions for aquiring the time of day */
#include <errno.h>
#include <signal.h>
#include <memory.h>

#include "network.h"                               /* Include my own header. */

#ifdef _WIN32							/* Link to required Win32 libraries. */
	#pragma comment(lib,"wsock32.lib")					 /* Link to winsock. */
	#pragma comment(lib,"wininet.lib")						 /* And WinInet. */
	#pragma comment(lib,"kernel32.lib")		   /* And of course to kernel32. */
#endif

/******************************************************************************
               Windows/Unix Networking Compatibility Layer:
******************************************************************************/
#ifdef _WIN32
void gettimeofday(struct timeval *t, void *bogus)
{
    unsigned long ticks=GetTickCount();

    assert(t);
    t->tv_usec=(ticks%1000)*1000000/1000;
    t->tv_sec =ticks/1000;
}
#endif

/******************************************************************************
                             External Hooks:
******************************************************************************/
void  (*ErrorVector)(char *format,...)=printf;
void *(*MallocVector)(size_t size)=malloc;
void  (*FreeVector)(void *block)=free;


/******************************************************************************
                          Utility Functions:
******************************************************************************/
#define ARRAY_COUNT(XXX) (sizeof(XXX)/sizeof(*(XXX)))

char *strcata(char *string, char *add)
{
    size_t newLength;

    if(!string) return strdup(add);

    newLength=strlen(string)+strlen(add)+1;
    string=realloc(string,newLength);
    strcat(string,add);
    return string;
}

char *strcatc(char *string, char add)
{
	size_t length;
	if(!string) return NULL;

	length=strlen(string);
	string[length]=add;
	string[length+1]='\0';
	return string;
}

char *rmlws(char *s)                           /* Remove leading whitespace. */
{
    if(!s) return NULL;                                     /* s is invalid. */
    for(;isspace(*s);s++) ; /* Skip whitespace (Note: '\0' isn't whitespace) */
    return s;                                          /* Return the string. */
}

/******************************************************************************
                                Network Subsystem:
******************************************************************************/
unsigned long localhost=0;                       /* Address of current host. */
static long True=1, False=0;                 /* Needed for socket functions. */
#ifdef _WIN32
	static HINTERNET win32InternetHandle;		   /* Win32 internet handle. */
#endif

char NetworkInitialize()
{
    char hostname[256];

#ifdef _WIN32
    WSADATA wsaData;                    /* The data returned by WSAStartup() */
    WSAStartup(0x101,&wsaData);                        /* Initialize winsock */

	/* Open the internet handle: */
	if(!(win32InternetHandle=InternetOpen(TEXT(__FILE__),INTERNET_OPEN_TYPE_PRECONFIG,NULL,NULL,0)))
		ErrorVector("Failed to open internet");
#endif

    /* Snag the localhost: */
    gethostname(hostname,sizeof(hostname));       /* Grab name of localhost. */
    localhost=DNSLookup(hostname);                             /* Get my IP. */

    return 1;                                  /* Initialization successful. */
}

void NetworkShutdown()
{
#ifdef _WIN32
	/* Close the internet handle: */
	if(win32InternetHandle) 
	{
		InternetCloseHandle(win32InternetHandle);
		win32InternetHandle=NULL;
	}

	/* Close winsock: */
    WSACleanup();                                       /* shut down winsock */
#endif
    localhost=0;                             /* Clear out localhost address. */
}

/******************************************************************************
                                DNS Subsystem:
******************************************************************************/
unsigned long DNSLookup(char *hostname)
{
    HOSTENT *hostEntry;

    if(!(hostEntry=gethostbyname(hostname))) return 0;  /* Get address list. */
    return *((unsigned long **)hostEntry->h_addr_list)[0]; /* Return first.  */
}

/* DNSAsyncLookupThread() subsystem: */
typedef struct _DNSAsyncLookupStruct
{
	volatile char          *hostname;
	volatile unsigned long *address;
	volatile char          *done;
} DNSAsyncLookupStruct;

static void __cdecl DNSAsyncLookupThread(void *arg)
{
	DNSAsyncLookupStruct *lookupStruct=(DNSAsyncLookupStruct *)arg;
	if(!lookupStruct) return;

	/* Perform the lookup. */
	*((unsigned long *)(lookupStruct->address))=DNSLookup((char *)lookupStruct->hostname);
	*((char *)(lookupStruct->done))=1;	/* Signal as done. */

	FreeVector((char *)lookupStruct->hostname);
	FreeVector((char *)lookupStruct);
}

char DNSAsyncLookup(char *_hostname, volatile unsigned long *_address, volatile char *_done)
{
	DNSAsyncLookupStruct *lookupStruct;

	if(!_hostname||!_address||!_done) return 0;

	lookupStruct=MallocVector(sizeof(*lookupStruct));
	lookupStruct->hostname=strdup(_hostname);
	lookupStruct->address=_address;
	lookupStruct->done=_done;

	#ifdef _WIN32
		/* Create a thread to perform the lookup: */
		_beginthread(DNSAsyncLookupThread,0,lookupStruct); /* Start connecting to the client. */

	#else
		/* FIXME: Default behavior is direct lookup. */
		DNSAsyncLookupThread(lookupStruct);
	#endif

	return 1;
}

char *FormatAddress(unsigned long address)
{
    static char buffer[128];
    sprintf(buffer,"%d.%d.%d.%d",(address>>24)&0xFF,(address>>16)&0xFF,
                                 (address>>8 )&0xFF,address&0xFF);

    return buffer;
}

/******************************************************************************
                                UDP Subsystem:
******************************************************************************/
static struct sockaddr_in Address;           /* A scratch intenal structure. */

int UDPSocket(unsigned short port)          /* Initialize UDP subsystem */
{
    int Socket;

    /* Open up the socket: */
    if(FAILED(Socket=socket(PF_INET,SOCK_DGRAM,IPPROTO_UDP)))
    { WSACleanup(); return -1; }           /* Couldn't create the socket. */

    /* Bind the socket to the local address and port: */
    ZeroMemory(&Address,sizeof(Address));
    Address.sin_family=AF_INET; Address.sin_port=htons(port);

    if(FAILED(bind(Socket,(struct sockaddr *)&Address,sizeof(Address))))
    { CLOSE(Socket); return -1; }                 /* Couldn't bind the socket */

    if(FAILED(IOCTL(Socket,FIONBIO,&True)))              /* Set non-blocking */
    { CLOSE(Socket); return -1; }               /* Couldn't set non blocking */

    /* Initialize the socket for broadcasting: (success isn't critical) */
    setsockopt(Socket,SOL_SOCKET,SO_BROADCAST,(char *)&True,sizeof(True));

    return Socket;                                               /* Success! */
}

/* UDPSend attempts to dispatch a packet to the given address. If it
   returns non-zero then the packet was successfully dispatched, otherwise
   there was an error.
   Zero size packets can be sent. (So long as buffer is valid)
*/
char UDPSend(int Socket, void *Buffer,unsigned short Size,unsigned long ToAddress)
{
    Address.sin_addr.S_un.S_addr=ToAddress;   /* Set the destination address */

    if(FAILED(sendto(Socket,(char *)Buffer,Size,0,(struct sockaddr *)&Address,sizeof(Address))))
        return 0;

    return 1;
}

/* UDPReceive() receives a packet from UDP.
   A pointer to the sending IP is returned, and optionally a pointer to the
   statically allocated buffer holding the message and and the length of the
   packet in ReturnLength.
   Note: A valid packet can have a length of zero.
 */
unsigned long UDPReceive(int Socket, unsigned char **BufferAddress,unsigned short *ReturnLength)
{
    static char ReceiveBuffer[65536];  /* Static buffer to receive data into */
    int Temp=sizeof(Address); /* Needed so I can pass sizeof(Address) by address */
    if(Socket<0) return 0;                      /* Make sure I'm initialized */

    if(FAILED((Temp=recvfrom(Socket,ReceiveBuffer,sizeof(ReceiveBuffer),0,
                             (struct sockaddr *)&Address,&Temp))))
        return 0;                    /* Erroneous (possibly blocking) packet */

    /* Make sure this isn't from myself: */
    if(Address.sin_addr.S_un.S_addr==localhost) return 0;

    if(ReturnLength) *ReturnLength=Temp;                      /* Data length */
    if(BufferAddress) *BufferAddress=(unsigned char *)ReceiveBuffer;  /* Return static buffer */
    return Address.sin_addr.S_un.S_addr;          /* Return Sender's address */
}


/******************************************************************************
                                TCP Subsystem:
******************************************************************************/
int TCPServerSocket(short Port, int numListen) /* Create a server socket on the given port. */
{
    struct sockaddr_in server;
    int newSocket;

    /* Server initialization: */
    if((newSocket=socket(AF_INET,SOCK_STREAM,0))<0)    /* Create new master. */
        return -1;

    /* Disable blocking on the server socket: */
    IOCTL(newSocket,FIONBIO,&True);

    memset(&server,0,sizeof(server));        /* clear out the server socket. */
    server.sin_family=AF_INET;
    server.sin_addr.s_addr=INADDR_ANY;
    server.sin_port=htons(Port);

    if(bind(newSocket,(struct sockaddr *)&server,sizeof(server))<0)
    {
        CLOSE(newSocket);
        return -1;
    }

    listen(newSocket,numListen);                /* Max incoming connections. */
    return newSocket;                                       /* Give to user. */
}

int TCPServerAccept( int serverSocket )
{
    int newSocket;

    /* Attempt to accept a pending connection (if any are present). */
    if((newSocket=accept(serverSocket,NULL,NULL))<=0)
        return 0;                       /* Failed to accept the connection. */

    IOCTL(newSocket,FIONBIO,&True);   /* Disable blocking on the new socket: */

    return newSocket;
}

int TCPClientSocket(char *address,unsigned short port)
{
    struct  sockaddr_in server;
    int     Socket;

    memset(&server, 0, sizeof(server));
    server.sin_family = AF_INET;
    server.sin_port = htons(port);

    server.sin_addr.s_addr = DNSLookup(address);
    if(!server.sin_addr.s_addr) return -1;  /* If I didn't find the address. */

    if((Socket=socket(AF_INET, SOCK_STREAM, 0))<0) return -1;

    if(connect(Socket, (struct sockaddr *)&server, sizeof(server)) < 0)
    {
        CLOSE(Socket);
        return -1;
    }

    /* Disable blocking on the master socket: */
    IOCTL(Socket,FIONBIO,&True);

    return Socket;
}

char TCPAsyncClientSocket(char *address,unsigned short port, volatile int *returnSocket, volatile char *returndone)
{
	ErrorVector("TCPAsybncClientSocket not yet implemented.");
	return 0;
}

int TCPRead( int sock, void *buffer, size_t size )
{
    int bytesRead;

    if((bytesRead=READ(sock,buffer,size))<=0)
    {
        if(bytesRead==0)        return -1;     /* 0 means connection closed. */
        if(ERRNO==EWOULDBLOCK)  return 0;                /* Excuse blocking. */
        else                    return -1;               /* Otherwise error. */
    }

    return bytesRead;
}

int TCPGets( int sock, char *buffer, size_t size )
{
    int result=0, bytesRead;

    for(bytesRead=0;bytesRead<(int)size;bytesRead+=result)
    {
        result=TCPRead(sock,buffer+bytesRead,1);
        if(result<0) return -1;
        if((*(buffer+bytesRead)=='\n'))
        {
            *(buffer+bytesRead-1)='\0';                    /* Strip off \r\n */
            return strlen(buffer);
        }
    }

    return bytesRead;
}

int TCPWrite( int sock, unsigned char *buffer, size_t size, char block )
{
    size_t result, bytesWritten=0;

    if(block)                      /* If I should block to get all data out. */
    {
        while(bytesWritten<size)
        {
            result=WRITE(sock,buffer+bytesWritten,size-bytesWritten);
            if(result<0)
            {
                if(ERRNO!=EWOULDBLOCK) return -1;
            } else
                bytesWritten+=result;
        }
    } else
    {

        if((bytesWritten=WRITE(sock,buffer,size))<0)
            if(ERRNO==EWOULDBLOCK) return 0;             /* Excuse blocking. */
            else                   return -1;            /* Otherwise error. */
    }

    return bytesWritten;
}

int TCPPrintf( int sock, char *Format, ... )
{
    char buffer[4096];
    va_list Arguments;

    /* Process variable argument list: */
    va_start(Arguments,Format);
    vsprintf(buffer,Format,Arguments);
    va_end(Arguments);

    /* Write formatted data to the socket (blocking): */
    return TCPWrite(sock,buffer,strlen(buffer),1);
}

/******************************************************************************
                              Finger Subsystem:
******************************************************************************/
char *finger(char *URL)               /* Returns finger text from given URL. */
{
    char buffer[256], *username, *domain, *returnValue=NULL;
    int Socket, bytesRead;

    if(!URL) return NULL;                         /* Make sure URL is valid. */
    strcpy(buffer,URL);                           /* Save a copy of the url. */
    username=buffer;                                /* Username starts here. */

    if(!(domain=strchr(buffer,'@'))) return NULL;            /* Missing '@'. */

    *domain='\0'; domain++;                /* Seperate domain from username. */

    if((Socket=TCPClientSocket(domain,79))<0)          /* Connect to domain. */
        return NULL;                           /* Failed to make connection. */

    TCPPrintf(Socket,"%s\r\n",username);               /* Send the username. */

    /* Grab all remaining data: */
    while((bytesRead=TCPRead(Socket,buffer,sizeof(buffer)-1))>=0)
        if(bytesRead)                         /* Was anything actually read? */
        {
            buffer[bytesRead]='\0';             /* NUL terminate the buffer. */
            returnValue=strcata(returnValue,buffer);
        }

    CLOSE(Socket);

    return returnValue;
}

/******************************************************************************
                             Telnet Subsystem:
******************************************************************************/
static int MasterTelnetSocket=-1;               /* The master network socket */

TelnetConnection *TelnetConnections=NULL;   /* The list of valid descriptors */
unsigned long totalBytesRead=0,                 /* Keep track of total read. */
              totalBytesWritten=0;           /* Keep track of total written. */

/* Allocates and partially iniailizes a new connection: */
static TelnetConnection *TelnetCreateConnection()
{
    TelnetConnection *NewConnection;

    /* Allocate space for the connection */
    if(!(NewConnection=(TelnetConnection *)MallocVector(sizeof(TelnetConnection))))
        return NULL;

    /* Set up the structure: */
    memset(NewConnection,0,sizeof(*NewConnection));         /* Clear it out. */
    NewConnection->Magic=TELNET_MAGIC;                     /* Make it valid. */
    NewConnection->Next=TelnetConnections;         /* Attach myself to list. */
    TelnetConnections=NewConnection;               /* Attach the list to me. */

    return NewConnection;
}

char TelnetInitialize(short Port, int telnetListen)
{
    MasterTelnetSocket=-1;               /* Default state for server socket. */
    if(telnetListen)                                  /* Am I actually a server? */
        if((MasterTelnetSocket=TCPServerSocket(Port,telnetListen))<0)
            return 0;

    return 1;
}

/* Writes text to a telnet connection */
void TelnetPrintf(TelnetConnection *Connection,char *Format,...)
{
    long NewSize;
    va_list Arguments;
    char Text[4096];

    /* Process the argument list */
    if(!Format) Format="";                  /* Force the format string valid */

    va_start(Arguments,Format);    /* Start the variable argument processing */
    vsprintf(Text,Format,Arguments);                    /* Format parameters */
    va_end(Arguments);                            /* End argument processing */

    NewSize=Connection->OutputBufferUsed+1+strlen(Text)+1;
    if(NewSize>=Connection->OutputBufferSize)  /* Resize the buffer */
    {
        Connection->OutputBufferSize=NewSize+TELNET_BUFFER_GROW;
        if(!(Connection->OutputBuffer=realloc(Connection->OutputBuffer,Connection->OutputBufferSize)))
            ErrorVector("Failed to resize OutputBuffer.");

        if(!Connection->OutputBufferUsed) *(Connection->OutputBuffer)='\0';
    }

    strcat(Connection->OutputBuffer,Text);                /* Append the text */
    Connection->OutputBufferUsed=NewSize-2;              /* Forget the NUL's */

    if(Connection->OutputBufferUsed>=Connection->OutputBufferSize)
        ErrorVector("OutputBuffer overrun!");
}

/* Broadcast a message to all clients. */
void TelnetBroadcast(char *Format,...)
{
    char text[4096];
    va_list Arguments;
    TelnetConnection *iterator;

    /* Process the argument list */
    if(!Format) Format="";                  /* Force the format string valid */

    va_start(Arguments,Format);    /* Start the variable argument processing */
    vsprintf(text,Format,Arguments);                    /* Format parameters */
    va_end(Arguments);

    for(iterator=TelnetConnections;iterator;iterator=iterator->Next)
        TelnetPrintf(iterator,text);
}

/* TelnetUpdate updates the telnet for the given number of seconds and
   calls HandleLine for each complete line of input, if UpdateTime is 0,
   then this just runs once and returns.
    The function is a bit monolithic at the moment, but pretty much does
    everything it should.

    Returns the amount of time (seconds) actually spent in the function.
*/
float TelnetUpdate(float UpdateTime,
                   void (*Constructor)(TelnetConnection *),
                   void (*Destructor) (TelnetConnection *),
                   void (*HandleLine) (TelnetConnection *,char *))
{
    TelnetConnection *Iterator, *Iterator_Next, *Previous;
    char *Temp;
    struct timeval EndTime, WaitTime, CurrentTime, StartTime;
    fd_set InputSet,OutputSet,ErrorSet;
    int HighestSocket, Index;
    float elapsedTime;
    char Buffer[256];                                   /* Temporary buffer. */

    gettimeofday(&StartTime,NULL); memcpy(&EndTime,&StartTime,sizeof(EndTime));
    gettimeofday(&CurrentTime,NULL);

    /* Normalize the time */
    EndTime.tv_usec+=(unsigned)(UpdateTime*(float)(1000*1000));
    while(EndTime.tv_usec>1000000) { EndTime.tv_usec-=1000000; EndTime.tv_sec++; }

    for(;;)
    {
        /* Compute the wait delay */
        WaitTime.tv_sec=EndTime.tv_sec-CurrentTime.tv_sec;
        if(CurrentTime.tv_usec>EndTime.tv_usec)      /* Do I need to borrow? */
        {
            WaitTime.tv_sec--;
            WaitTime.tv_usec=(1000000+EndTime.tv_usec)-CurrentTime.tv_usec;
        } else WaitTime.tv_usec=EndTime.tv_usec-CurrentTime.tv_usec;

        HighestSocket=0;                            /* Reset highest socket. */

        /* Clear all socket groups: */
        FD_ZERO(&InputSet); FD_ZERO(&OutputSet); FD_ZERO(&ErrorSet);

        if(MasterTelnetSocket>=0)        /* Do I have a valid server socket? */
        {
            FD_SET(MasterTelnetSocket,&InputSet);
            HighestSocket=MasterTelnetSocket;
        }

        /* Add the various client sockets to their respected lists*/
        for(Iterator=TelnetConnections;Iterator;Iterator=Iterator->Next)
        {
            if(Iterator->Magic!=TELNET_MAGIC)      /* Ensure node integrity. */
                ErrorVector("Telnet: List blown!");            /* Not valid. */

            if(Iterator->Destroy) continue;   /* Don't bother with this one. */

            if(HighestSocket<Iterator->Socket) /* Is this the HighestSocket? */
                HighestSocket=Iterator->Socket;        /* Set it up as such. */

            FD_SET(Iterator->Socket,&ErrorSet);      /* All check for errors */
            FD_SET(Iterator->Socket,&InputSet);       /* All check for input */

            if(Iterator->OutputBufferUsed)  /* Do I have any pending output? */
                FD_SET(Iterator->Socket,&OutputSet);  /* Put on output list. */
        }
        WaitTime.tv_sec=WaitTime.tv_usec=0;  /* Testo. */

        /* Wait until status changes or time expires: */
        if(HighestSocket)
            if(select(HighestSocket+1,&InputSet,&OutputSet,&ErrorSet,&WaitTime)<0)
                ErrorVector("Telnet: Select() failed.");

        /***************** Handle incoming connections: **********************/
        if((MasterTelnetSocket>=0)             /* If I have a server socket. */
         &&(FD_ISSET(MasterTelnetSocket,&InputSet)))   /* If it's triggered. */
        {
            TelnetConnection *NewConnection;

            if(!(NewConnection=TelnetCreateConnection()))
                ErrorVector("Telnet: Failed to allocate connection!");

            /* Initialize the socket */
            if((NewConnection->Socket=TCPServerAccept(MasterTelnetSocket))<0)
                ErrorVector("Telnet: accept() failed.");
            else
            {
                struct sockaddr_in sock;
                int sockSize=sizeof(sock);

                /* Get the host ip.address: */
                getpeername(NewConnection->Socket,(struct sockaddr *)&sock,&sockSize);
                strcpy(Buffer,FormatAddress(ntohl(sock.sin_addr.s_addr)));

                /* Try to get the hostname: */
                /* NJS: Note that the following is slow and blocking: */
                /* Perhaps put it on a background thread? */
				{
					HOSTENT *from=gethostbyaddr((char *)&sock.sin_addr,sizeof(sock.sin_addr),AF_INET);
					if(from)                      /* Did I get a valid from address? */
					{
						char tempBuffer[256];
						strcpy(tempBuffer,Buffer);
						sprintf(Buffer,"%s (%s)",from->h_name,tempBuffer);
					}
				}

                /* Attach the incoming address to the connection: */
                NewConnection->Address=(char *)strdup(Buffer);

                if(Constructor)             /* If I have a constructor, call it: */
                    Constructor(NewConnection);
            }
        }

        /* Cycle through list, see who needs to be killed, read and written: */
        for(Iterator=TelnetConnections,Previous=NULL;Iterator;Iterator=Iterator_Next)
        {
            if(Iterator->Magic!=TELNET_MAGIC)      /* Verify node integrity. */
                ErrorVector("Telnet: List Blown!");

            Iterator_Next=Iterator->Next;                       /* Next node */

            if(FD_ISSET(Iterator->Socket,&ErrorSet))       /* Socket errors. */
                Iterator->Destroy=1;               /* Kill the weirdo freak! */

            if(FD_ISSET(Iterator->Socket,&InputSet))         /* Read socket. */
            {
                /* Resize the input buffer if necessecary: */
                if(Iterator->InputBufferSize-Iterator->InputBufferUsed<TELNET_BUFFER_GROW)
                {
                    Iterator->InputBufferSize+=TELNET_BUFFER_GROW;/* Enlarge. */
                    if(!(Iterator->InputBuffer=realloc(Iterator->InputBuffer,Iterator->InputBufferSize)))
                        ErrorVector("Telnet: Memory allocation failure!");
                }

                if((Index=TCPRead(Iterator->Socket,Iterator->InputBuffer+Iterator->InputBufferUsed,TELNET_BUFFER_GROW-1))>0)
                {
                    totalBytesRead+=Index;      /* Keep track of total read. */

                    Iterator->InputBufferUsed+=Index; /* Increase used size. */
                    Iterator->InputBuffer[Iterator->InputBufferUsed]='\0';

                    if(Temp=(char *)strchr(Iterator->InputBuffer,'\n'))
                    {
                        *Temp='\0';              /* NUL terminate the string */
						if(*(Temp-1)=='\r') *(Temp-1)='\0';     /* Strip \r. */

                        /* Handle the incoming line: */
                        if(HandleLine)          /* Process the line normally */
                            (*HandleLine)(Iterator,Iterator->InputBuffer);

                        strcpy(Iterator->InputBuffer,Temp+1);   /* Overwrite */
                        Iterator->InputBufferUsed=strlen(Iterator->InputBuffer);
                    }
                } else if(Index<0)          /* EOF or error, kill either way */
                    Iterator->Destroy=1;
            }

            if(FD_ISSET(Iterator->Socket,&OutputSet))     /* Write to socket */
            {
                Index=Iterator->OutputBufferUsed;

                if((Index=TCPWrite(Iterator->Socket,Iterator->OutputBuffer,Index,0))>0)
                {
                    totalBytesWritten+=Index;/* Keep track of total written. */

                    /* Move the rest of the buffer down */
                    strcpy(Iterator->OutputBuffer,Iterator->OutputBuffer+Iterator->OutputBufferUsed);
                    //Iterator->OutputBufferUsed-=Index; /* Reduce output buffer */
                    Iterator->OutputBufferUsed=strlen(Iterator->OutputBuffer);
                }
                else if(Index<0)             /* EOF or error, die either way */
                    Iterator->Destroy=1;
            }

            /* If I'm slated for destruction, then kill myself: */
            if(Iterator->Destroy)
            {
                /* Call my user destructor: */
                if(Destructor) Destructor(Iterator);

                /* Remove myself from the list */
                if(!Previous) TelnetConnections=Iterator_Next; /* List head. */
                else Previous->Next=Iterator_Next;     /* Middle/End of list */

                /* Release the connection's resources: */
                if(Iterator->Socket>=0)    CLOSE(Iterator->Socket);
                if(Iterator->Address)      FreeVector(Iterator->Address);
                if(Iterator->InputBuffer)  FreeVector(Iterator->InputBuffer);
                if(Iterator->OutputBuffer) FreeVector(Iterator->OutputBuffer);
                Iterator->Magic=0;                  /* Obliterate the magic. */
                FreeVector(Iterator);               /* Toast the connection. */
            } else Previous=Iterator;               /* Set the next previous */
        }

        gettimeofday(&CurrentTime,NULL);            /* Snag the current time */

        /* Check to see if I'm finished: */
        if(CurrentTime.tv_sec>EndTime.tv_sec) break;
        if((CurrentTime.tv_sec==EndTime.tv_sec)
         &&(CurrentTime.tv_usec>=EndTime.tv_usec))
            break;
    }

    /* Compute elapsed time: */
    gettimeofday(&EndTime,NULL);
    elapsedTime =(float)(EndTime.tv_sec-StartTime.tv_sec);
    elapsedTime+=(float)((EndTime.tv_usec-StartTime.tv_usec)/1000000.0);

    return elapsedTime;
}

void TelnetShutdown(void (*Destructor) (TelnetConnection *))
{
    TelnetConnection *Iterator;

    /* Slate all existing connections for destruction. */
    for(Iterator=TelnetConnections;Iterator;Iterator=Iterator->Next)
        Iterator->Destroy=1;

    TelnetUpdate(0,NULL,Destructor,NULL);                      /* Kill them. */

    if(MasterTelnetSocket>=0)               /* Close down the master socket. */
    {
        CLOSE(MasterTelnetSocket);                       /* Kill the master. */
        MasterTelnetSocket=-1;                        /* Mark it as invalid. */
    }
}

TelnetConnection *TelnetConnect(char *address,
                                unsigned short port,
                                void (*Constructor)(TelnetConnection *))
{
    TelnetConnection *NewConnection;
    int     Socket;

    if((Socket=TCPClientSocket(address,port))<0)/* Try to connect to server. */
        return NULL;

    if(!(NewConnection=TelnetCreateConnection())) /* Allocate the structure. */
        ErrorVector("Telnet: Failed to create connection.");

    if(!(NewConnection->Address=strdup(address)))       /* Save the address. */
        ErrorVector("Telnet: Memory allocation failure.");

    NewConnection->Socket=Socket;                         /* Set the socket. */

    if(Constructor)                              /* If I have a constructor, */
        (*Constructor)(NewConnection);                           /* Call it. */

    return NewConnection;
}

/******************************************************************************
                              Email Subsystem:
******************************************************************************/
static char SMTPCheckCode(int Socket)       /* Verify an incoming SMTP code. */
{
    char buffer[4096];
    if(TCPGets(Socket,buffer,sizeof(buffer))>0)
        if((buffer[0]=='1')||(buffer[0]=='2')||(buffer[0]=='3'))
            return 1;

    CLOSE(Socket);
    return 0;
}

char SMTPSend(char *server, char *to, char *from, char *subject, char *body)
{
    int Socket;

    if((Socket=TCPClientSocket(server,25))<0)      /* Connect to the server. */
        return 0;                                       /* Couldn't connect. */

    if(!SMTPCheckCode(Socket)) return 0;       /* Validate SMTP return code. */
    TCPPrintf(Socket,"HELO\r\n");                  /* Log on to SMTP server. */
    if(!SMTPCheckCode(Socket)) return 0;       /* Validate SMTP return code. */
    TCPPrintf(Socket,"MAIL FROM: <%s>\r\n",from);             /* Set 'from:' */
    if(!SMTPCheckCode(Socket)) return 0;       /* Validate SMTP return code. */
    TCPPrintf(Socket,"RCPT TO: <%s>\r\n",to);                   /* Set 'to:' */
    if(!SMTPCheckCode(Socket)) return 0;       /* Validate SMTP return code. */
    TCPPrintf(Socket,"DATA\r\n");                          /* Start message. */
    if(!SMTPCheckCode(Socket)) return 0;       /* Validate SMTP return code. */
    TCPPrintf(Socket,"From: %s\r\n"                               /* sender. */
                     "To: %s\r\n",from,to);                    /* Recipient. */
    if(subject)                                      /* If I have a subject. */
        TCPPrintf(Socket,"Subject: %s\r\n",from,to,subject);     /* Send it. */

    TCPPrintf(Socket,"\r\n%s\r\n.\r\n",body);       /* Dump body of message. */
    if(!SMTPCheckCode(Socket)) return 0;       /* Validate SMTP return code. */
    TCPPrintf(Socket,"QUIT\r\n");                 /* Log off of SMTP server. */
    CLOSE(Socket);                                      /* Close the socket. */
    return 1;
}

static char POPCheckCode(int Socket)         /* Verify an incoming POP code. */
{
    char buffer[4096];
    if(TCPGets(Socket,buffer,sizeof(buffer))>0)
        if(buffer[0]=='+')
            return 1;

    CLOSE(Socket);
    return 0;
}

char POPReceive(char *server, char *username, char *password, void (*callback)(char *msg))
{
    int Socket, index, count, bytesRead;
    char buffer[256];
    char *message;

    if(!callback) return 0;                 /* Verify the callback function. */
    if((Socket=TCPClientSocket(server,110))<0)     /* Connect to the server. */
        return 0;
    if(!POPCheckCode(Socket)) return 0;          /* Make sure I'm connected. */

    TCPPrintf(Socket,"USER %s\r\n",username);              /* Send username. */
    if(!POPCheckCode(Socket)) return 0;             /* Validate return code. */
    if(password)                                    /* Do I have a password? */
    {
        TCPPrintf(Socket,"PASS %s\r\n",password);          /* Send password. */
        if(!POPCheckCode(Socket)) return 0;         /* Validate return code. */
    }
    TCPPrintf(Socket,"STAT\r\n");             /* Get the number of messages: */

    /* Grab the status line: */
    if(TCPGets(Socket,buffer,sizeof(buffer))<=0||(buffer[0]!='+'))
    {
        CLOSE(Socket);                             /* Close down the socket. */
        return 0;                                         /* Return failure. */
    }

    count=atoi(buffer+4);                         /* Grab the message count. */

    for(index=1;index<=count;index++)       /* Iterate through each message. */
    {
        TCPPrintf(Socket,"RETR %i\r\n",index);          /* Grab the message. */
        if(!POPCheckCode(Socket)) return 0;                  /* Verify code. */

        /* Snarf down the message: */
        message=strcata(NULL,"");                 /* Initialize the message. */
        do
        {
            /* Read a chunk: */
            if((bytesRead=TCPRead(Socket, buffer, sizeof(buffer)-1 ))<0)
            {
                CLOSE(Socket);                          /* Close the socket. */
                return 0;                                   /* Return error. */
            }
            if(bytesRead>0)                 /* Did I actually get some data? */
            {
                buffer[bytesRead]='\0';                 /* NUL terminate it. */
                message=strcata(message,buffer);    /* Append it to message. */
            }
        } while(!strstr(message,"\r\n.\r\n"));  /* Wait for terminating dot. */

        (*callback)(message);                     /* Return message to user. */
        FreeVector(message);                            /* Free the message. */

        TCPPrintf(Socket,"DELE %i\r\n",index);        /* Delete the message. */
        if(!POPCheckCode(Socket)) return 0;         /* Validate return code. */
    }

    TCPPrintf(Socket,"QUIT\r\n");                  /* Terminate the session. */
    CLOSE(Socket);                                  /* Close the connection. */
    return 1;                                                    /* Success. */
}

static char NNTPCheckCode(int Socket, int expectedCode)
{
    char buffer[256];
    if((TCPGets(Socket,buffer,sizeof(buffer))<0)    /* Try to get the value. */
     ||(atoi(buffer)!=expectedCode))
    {
        CLOSE(Socket);
        return 0;
    }

    return 1;
}

char NNTPSend(char *server, char *newsgroups, char *from, char *subject, char *body)
{
    int Socket;

    if((Socket=TCPClientSocket(server,119))<0)     /* Connect to the server. */
        return 0;

    if(!NNTPCheckCode(Socket,200)) return 0;    /* Validate the return code. */

    TCPPrintf(Socket,"POST\r\n");                    /* Send a post command. */
    if(!NNTPCheckCode(Socket,340)) return 0;    /* Validate the return code. */

    TCPPrintf(Socket,"Newsgroups: %s\r\n"                  /* Where to post. */
                     "From: %s\r\n"                               /* Sender. */
                     "Subject: %s\r\n"                   /* Message subject. */
                     "\r\n"         /* Empty line indicatine end of headers. */
                     "%s\r\n.\r\n",newsgroups,from,subject,body);

    if(!NNTPCheckCode(Socket,240)) return 0;    /* Validate the return code. */
    TCPPrintf(Socket,"QUIT\r\n");                    /* Send a post command. */

    return 1;
}

/******************************************************************************
                              HTTP Subsystem:
******************************************************************************/
HTTPConnection *HTTPConnectionList;           /* List of active connections. */

static HTTPConnection *newHTTPConnection(int socket)
{
    HTTPConnection *returnValue;

    /* Allocate memory for it: */
    if(!(returnValue=(HTTPConnection *)MallocVector(sizeof(*returnValue))))
        return NULL;

    /* Clear it out: */
    memset(returnValue,0,sizeof(*returnValue));

    /* Attach it to the list: */
    returnValue->next=HTTPConnectionList;
    HTTPConnectionList=returnValue;

    /* Set up the important data: */
    returnValue->socket=socket;

    return returnValue;
}

static void HTTPWriteConnection( HTTPConnection *c, void *buffer, size_t size )
{
    size_t newSize=c->outputSize+size;

    assert(c);
    assert(buffer);

    c->output=realloc(c->output,newSize);
    memcpy(c->output+c->outputSize,buffer,size);
    c->outputSize+=size;
}

/* Public interface: */
void HTTPSendData( HTTPConnection *c, void *buffer, size_t size )
{
    char textBuffer[4096];

    assert(c);
    assert(buffer);

    sprintf(textBuffer,"HTTP/1.0 200 OK\r\n"
                       "Accept-Ranges: bytes\r\n"
                       "Content-Length: %i\r\n"
                       "Connection: close\r\n"
                       "Content-Type: text/html\r\n\r\n",size);
    HTTPWriteConnection(c,textBuffer,strlen(textBuffer));
    HTTPWriteConnection(c,buffer,size);
}

char HTTPUpdate( int serverSocket, char (*fileRequest)(HTTPConnection *connection, char *filename, void *user), void *user )
{
    HTTPConnection *iterator, *iteratorNext, *previous;
    int newSocket, amount;
    char buffer[4096], *index, *commandIndex, *tempIndex;

    /* check for incoming requests: */
    while(newSocket=TCPServerAccept(serverSocket))
        /* We've got a live one here, pop it on the list: */
        iterator=newHTTPConnection(newSocket);

    /* Scan through the list of connections, and see who needs updating: */
    for(iterator=HTTPConnectionList,previous=NULL;iterator;iterator=iteratorNext)
    {
        iteratorNext=iterator->next;                            /* Next node */

        if(iterator->destroy)         /* Is this guy slated for destruction? */
        {
            /* Detach myself from the list: */
            if(!previous) HTTPConnectionList=iteratorNext;     /* List head. */
            else previous->next=iteratorNext;          /* Middle/End of list */

            closesocket(iterator->socket);              /* Close the socket. */
            iterator->socket=-1;            /* Invalidate socket descriptor. */

            if(iterator->input)  FreeVector(iterator->input);
            if(iterator->output) FreeVector(iterator->output);

            FreeVector(iterator);                 /* Kill associated memory. */
        } else
        {
            previous=iterator;                           /* Set up previous. */

            /* Attempt to read from the connection: */
            if((amount=TCPRead(iterator->socket,buffer,ARRAY_COUNT(buffer)))>0)
            {
                buffer[amount]='\0';                    /* NUL terminate it. */
                iterator->input=strcata(iterator->input,buffer);

                /* Break up individual lines: */
                while(index=strstr(iterator->input,"\r\n")) /* Is there a complete line? */
                {
                    *index='\0'; index+=2;                 /* Skip over EOL. */
                    commandIndex=rmlws(iterator->input);
                    if(!strncmp(commandIndex,"GET",3))
                    {
                        commandIndex=rmlws(commandIndex+3); /* Strip whitespace. */

                        /* Extract up to next space break: */
                        for(tempIndex=commandIndex;*tempIndex;tempIndex++)
                            if(isspace(*tempIndex))
                            {
                                *tempIndex='\0';  /* Skip spaces. */
                                break;
                            }

                        if(fileRequest)
                            if(!fileRequest(iterator,commandIndex,user))
                            {
                                /* Unknown resource, look for it on disk: */
                            }
                    }
                    strcpy(iterator->input,index);   /* Copy remaining line. */
                }

            } else if(amount<0) iterator->destroy=1;/* Kill on socket error. */

            if(iterator->output&&iterator->outputSize)  /* Do I need to send anything? */
                if((amount=TCPWrite(iterator->socket,iterator->output,iterator->outputSize,0))>0)
                {
                    iterator->outputSize-=amount;      /* Shrink output size */
                    if(iterator->outputSize)
                        memmove(iterator->output,iterator->output+amount,iterator->outputSize);
                    else iterator->destroy=1;              /* Out of output. */
                } else if(amount<0) iterator->destroy=1; /* Kill on socket error. */
        }
    }
    return 1;                                        /* I handled a request. */
}

/******************************************************************************
                              Generic URL Subsystem:
******************************************************************************/
#ifdef UNICODE_SUPPORT_FOR_WIN32_ADDED
unsigned long URLOpen(char *URL)
{
#if _WIN32
	char canonicalURL[4096];
	unsigned long canonicalURLSize=ARRAY_COUNT(canonicalURL);
	HINTERNET URLHandle;

	if(!InternetCanonicalizeUrl(URL,canonicalURL,&canonicalURLSize,0))
		return 0;
	
	URL=canonicalURL;								 /* Reference URL by URL */

	if(!(URLHandle=InternetOpenUrl(win32InternetHandle,URL,NULL,0,INTERNET_FLAG_RESYNCHRONIZE,0)))
		return 0;
	
	return (unsigned long)URLHandle;
#else
	return 0;
#endif
}

unsigned long URLRead(unsigned long URLHandle,void *buffer,unsigned long bytesToRead,char block)
{
#if _WIN32
	INTERNET_BUFFERS internalStruct;
	unsigned long bytesRead=0;
	
	if(!InternetReadFile((HINTERNET)URLHandle,buffer,bytesToRead,&bytesRead))
		return -1;

	return bytesRead;
#else
	return 0;
#endif
}

void URLClose(unsigned long URLHandle)
{
#if _WIN32
	InternetCloseHandle((HINTERNET)URLHandle);
#endif
}

/* URLLoad loads a url in it's entirity.  The returned pointer is to the 
   allocated buffer, whose size is returned in size. 
   Should work with any os
*/
void *URLLoad(char *URL, unsigned long *size)
{
	         char *returnBuffer=NULL;
	unsigned long returnBufferSize=0;
	unsigned long internalSize;
	unsigned long URLHandle;
	const int readChunkSize=1024;
	unsigned long amountRead=0;

	if(!size) size=&internalSize;		 /* Make sure size pointer is valid. */
	*size=0;											   /* Reset the size */

	if(!(URLHandle=URLOpen(URL))) return NULL;	/* Open the URL. */

	do
	{
		if((*size)+readChunkSize>=returnBufferSize)
		{
			returnBufferSize+=readChunkSize;
			returnBuffer=(char *)realloc(returnBuffer,returnBufferSize);
		}

		if((amountRead=URLRead(URLHandle,returnBuffer+*size,readChunkSize,1))==-1)
			break;
		(*size)+=amountRead;
	} while(amountRead);

	URLClose(URLHandle);						/* Close URL. */
	return returnBuffer;
}


#ifdef _WIN32
typedef struct _URLAsyncLoadParameters
{
	volatile		  char *URL;
	volatile unsigned long *returnSize;
	volatile unsigned char **returnBuffer;
	volatile unsigned char *done;
} URLAsyncLoadParameters;

static void __cdecl URLAsyncLoadThread(void *arg)
{
	URLAsyncLoadParameters *asyncLoadStruct=(URLAsyncLoadParameters *)arg;
	*(asyncLoadStruct->returnBuffer)=(char *)URLLoad((char *)asyncLoadStruct->URL,(unsigned long *)asyncLoadStruct->returnSize);
	*(asyncLoadStruct->done)=(char)1;
	FreeVector((char *)asyncLoadStruct->URL);
	FreeVector((URLAsyncLoadParameters *)asyncLoadStruct);

}
#endif

void URLAsyncLoad(char *URL, volatile unsigned long *returnSize, volatile char **returnBuffer, volatile char *done)
{
#ifdef _WIN32
	URLAsyncLoadParameters *asyncLoadStruct=MallocVector(sizeof(*asyncLoadStruct));
	asyncLoadStruct->URL=strdup(URL);
	asyncLoadStruct->returnSize=returnSize;
	asyncLoadStruct->returnBuffer=returnBuffer;
	asyncLoadStruct->done=done;

	_beginthread(URLAsyncLoadThread,0,asyncLoadStruct); /* Start connecting to the client. */
#endif
}

#endif
/******************************************************************************
                                Test App:
******************************************************************************/
#ifdef TESTO
#define PORT 80
char fileRequest(HTTPConnection *connection, char *filename, void *user)
{
    char *buffer=NULL, *temp=NULL;

    printf("Requesting file:%s\n",filename);

    buffer=strcata(buffer,"<HTML>\r\n"
                   "<HEAD>\r\n"
                   "<TITLE>Application Profile Information:</TITLE>\r\n"
                   "<META NAME=\"GENERATOR\" CONTENT=\"Mozilla/3.01Gold (Win95; I) [Netscape]\">\r\n"
                   "</HEAD>\r\n"
                   "<BODY TEXT=\"#FFFFFF\" BGCOLOR=\"#000000\" LINK=\"#00FFFF\" VLINK=\"#008080\" ALINK=\"#0099FF\">\r\n"
                   "<B><FONT FACE=\"Courier\"><FONT SIZE=+1><FONT COLOR=\"#33FF33\">\r\n");

    buffer=strcata(buffer,temp=getBasicProfileStringInfo());
    buffer=strcata(buffer,"</B></FONT></FONT></BODY>\r\n");

    HTTPSendData(connection,buffer,strlen(buffer));
    if(temp)   FreeVector(temp);
    if(buffer) FreeVector(buffer);
    return 0;                           /* Not handled. */
}


int main(int argc, char *argv[])
{
    int serverSocket;
    char *fingerText;

    /* Initialize everything. */
    NetworkInitialize();

    //if(!(SMTPSend("SMTP.3DREALMS.COM", "nicks@3drealms.com", "nicks@3drealms.com", "testing...", "This is a test!")))
    //    puts("Send failure!");

    //if(!(NNTPSend("news.concentric.net","alt.test","nicks@3drealms.com","Blargo!","This is a test this is a test")))
    //    puts("News send failure.");

    if(fingerText=finger("nicks@imail.3drealms.com"))
        puts(fingerText);
    else puts("Finger failure.");

    printf("Web server initializing on port %i.\n",PORT);
    serverSocket=TCPServerSocket(PORT,5); /* Create a tcp server socket on the http port. */

    /* Main loop: */
    while(!kbhit())
        HTTPUpdate(serverSocket,fileRequest,NULL);

    /* Uninitialize everything: */
    puts("Web server uninitializing...");
    CLOSE(serverSocket);                                /* Close the socket. */

    NetworkShutdown();

    /* Done, outta here: */
    puts("Web server terminating.");

    return EXIT_SUCCESS;
}
#endif
