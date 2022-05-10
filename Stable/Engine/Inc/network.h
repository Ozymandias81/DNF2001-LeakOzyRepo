/******************************************************************************
                            Simple Networking Layer:
*******************************************************************************
******************************************************************************/
#ifndef __NETWORK_H__
#define __NETWORK_H__


#ifdef __cplusplus
extern "C" {
#endif

/******************************************************************************
                            Standard Include Files:
******************************************************************************/
#include <stdlib.h>

/******************************************************************************
               Windows/Unix Networking Compatibility Layer:
******************************************************************************/
#ifdef _WIN32    /* When running under windows, include the windows headers. */

    #include <process.h>
    #include <windows.h>
    #include <winsock.h>
	#include <wininet.h>

    #define READ(A,B,C)  recv(A,B,C,0)
    #define WRITE(A,B,C) send(A,B,C,0)
    #define CLOSE(A)     closesocket(A)
    #define IOCTL(A,B,C) ioctlsocket(A,B,C)
    void gettimeofday(struct timeval *t, void *bogus);

    /* Windows socket -> Posix translations: */
    #define ENOTSOCK    WSAENOTSOCK      /* Descriptor references a file, not socket. */
    #define EOPNOTSUPP  WSAEOPNOTSUPP
    #define EWOULDBLOCK WSAEWOULDBLOCK

    #define ERRNO WSAGetLastError()

#else                                               /* Assuming unix system. */

    #include <sys/types.h>
    #include <sys/time.h>
    #include <sys/socket.h>
    #include <sys/ioctl.h>
    #include <netinet/in.h>
    #include <arpa/inet.h>
    #include <netdb.h>

    #define READ(A,B,C)  read(A,B,C)
    #define WRITE(A,B,C) write(A,B,C)
    #define CLOSE(A)     close(A)
    #define IOCTL(A,B,C) ioctl(A,B,C)

    #define ERRNO errno

#endif

/******************************************************************************
                             External Hooks:
******************************************************************************/
extern void  (*ErrorVector)(char *format,...);
extern void *(*MallocVector)(size_t size);
extern void  (*FreeVector)(void *block);

/******************************************************************************
                          Misc Utility Functions:
******************************************************************************/
#define ARRAY_COUNT(XXX) (sizeof(XXX)/sizeof(*(XXX)))
char *strcata(char *string, char *add);
char *strcatc(char *string, char add);
char *rmlws(char *s);                          /* Remove leading whitespace. */

/******************************************************************************
                             Network Subsystem:
******************************************************************************/
extern unsigned long localhost;           /* Address of local machine (or 0) */
char NetworkInitialize();
void NetworkShutdown();

/******************************************************************************
                                DNS Subsystem:
******************************************************************************/
unsigned long DNSLookup(char *hostname);
char          DNSAsyncLookup(char *hostname, volatile unsigned long *returnaddress, volatile char *returndone);
char         *FormatAddress(unsigned long address);

/******************************************************************************
                                UDP Subsystem:
******************************************************************************/
int UDPSocket(unsigned short port);  /* Initialize to the given socket. */
char UDPSend(int Socket, void *Buffer,unsigned short Size,unsigned long ToAddress);
unsigned long UDPReceive(int Socket, unsigned char **BufferAddress,unsigned short *ReturnLength);

/******************************************************************************
                                TCP Subsystem:
******************************************************************************/
int  TCPServerSocket(short Port,int numListen);/* Create a server socket on the given port. */
int  TCPServerAccept(int serverSocket);
int  TCPClientSocket(char *address,unsigned short port);
char TCPAsyncClientSocket(char *address,unsigned short port, volatile int *returnSocket, volatile char *returndone);
int  TCPRead( int sock, void *buffer, size_t size );
int  TCPGets( int sock, char *buffer, size_t size );
int  TCPWrite( int sock, unsigned char *buffer, size_t size, char block );
int  TCPPrintf( int sock, char *Format, ... );

/******************************************************************************
                              Finger Subsystem:
******************************************************************************/
char *finger(char *URL);              /* Returns finger text from given URL. */

/******************************************************************************
                             Telnet Subsystem:
*******************************************************************************
    Manages an arbitrary number of asyncronous telnet connections, as either a
client or a server.
******************************************************************************/
#define TELNET_MAGIC 'TELN'                          /* Telnet magic number. */
#define TELNET_BUFFER_GROW 64 /* Increment by which the telnet buffer grows. */

typedef struct TelnetConnection
{
    unsigned long Magic;                             /* Set to TELNET_MAGIC. */

    unsigned char LocalEcho  : 1,            /* 1 if input should be echoed. */
                  Destroy    : 1;                       /* Set to 1 to kill. */

    int Socket;                                    /* The socket descriptor. */
    char *Address;        /* Location the socket is connected from (string). */

    char *InputBuffer;                  /* Data received (less than a line). */
    long InputBufferSize;
    long InputBufferUsed;

    char *OutputBuffer;                        /* Data pending transmission. */
    long OutputBufferSize;
    long OutputBufferUsed;

    clock_t lastInput;                 /* Last time that input was received. */

    void *User;                                                /* User data. */

    struct TelnetConnection *Next;              /* Next descriptor, or NULL. */

} TelnetConnection;

extern TelnetConnection *TelnetConnections; /* The list of valid descriptors */
extern unsigned long totalBytesRead,            /* Keep track of total read. */
                     totalBytesWritten;      /* Keep track of total written. */

char TelnetInitialize(short Port, int telnetListen);
void TelnetPrintf(TelnetConnection *Connection,char *Format,...);
void TelnetBroadcast(char *Format,...);
float TelnetUpdate(float UpdateTime,
                   void (*Constructor)(TelnetConnection *),
                   void (*Destructor) (TelnetConnection *),
                   void (*HandleLine) (TelnetConnection *,char *));
void TelnetShutdown(void (*Destructor) (TelnetConnection *));
TelnetConnection *TelnetConnect(char *address,
                                unsigned short port,
                                void (*Constructor)(TelnetConnection *));

/******************************************************************************
                          E-mail and News Subsystem:
******************************************************************************/
char SMTPSend(char *server, char *to, char *from, char *subject, char *body);
char POPReceive(char *server, char *username, char *password, void (*callback)(char *msg));
char NNTPSend(char *server, char *newsgroups, char *from, char *subject, char *body);

/******************************************************************************
                              HTTP Subsystem:
*******************************************************************************
	Pretty much just an HTTP server at the moment. Eventually, I should add
client side HTTP functions as well.
******************************************************************************/
typedef struct HTTPConnection                      /* A web connection node. */
{
    int socket;                       /* Socket descriptor or -1 if invalid. */

    unsigned char *input,                                  /* Incoming text. */
                  *output;                          /* Outgoing binary data. */
    size_t         outputSize;                 /* Size of the output stream. */

    unsigned char destroy : 1;           /* Slated for destruction when set. */

    struct HTTPConnection *next;             /* Next connection on the list. */
} HTTPConnection;

void HTTPSendData( HTTPConnection *c, void *buffer, size_t size);

/* HTTPDefaultFileRequest serves files from the directory specified by 'user' and down. */
char HTTPDefaultFileRequest(HTTPConnection *connection, char *filename, void *user);
char HTTPUpdate( int serverSocket, char (*fileRequest)(HTTPConnection *connection, char *filename, void *user), void *user );

/******************************************************************************
                              Generic URL Subsystem:
******************************************************************************/
unsigned long URLOpen(char *URL);
unsigned long URLRead(unsigned long URLHandle,void *buffer,unsigned long bytesToRead,char block);
void URLClose(unsigned long URLHandle);

/* URLLoad loads a url in it's entirity.  The returned pointer is to the 
   allocated buffer, whose size is returned in size. 
*/
void *URLLoad(char *URL, unsigned long *size);	
void URLAsyncLoad(char *URL, volatile unsigned long *returnSize, volatile char **returnBuffer, volatile char *done);
#ifdef __cplusplus
};
#endif


#endif