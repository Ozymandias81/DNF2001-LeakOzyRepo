/* NJS: A bit meganast at the moment, but soon will be clean :^) */
#pragma warning (disable : 4115 4711)

#include "..\..\Engine\Src\EnginePrivate.h"
//#include "network.h"
#include "mail.h"

#pragma comment(lib,"wsock32.lib")

inline char *appRmlws(char *s)
{
	while(isspace(*s)) s++;
	return s;
}

static void InternalError(char *msg)
{
    MessageBoxA(0,msg,"Error",0);
}   

void (*Error)(char *msg)=InternalError;	// NJS: Future error vector.

unsigned long RegistryLoad(char *Key, void *Buffer,unsigned long MaxLength)
{
    HKEY RegistryKey, BaseKey;                  /* A handle to HKEY_CURRENT_USER\Software */
    char DupeKey[1024];
    char *pastBase, *finalPiece;

    /* Initialize: */
    strcpy(DupeKey,Key);
    pastBase=strchr(DupeKey,'\\');
    if(pastBase) { *pastBase='\0'; pastBase++; }

    finalPiece=strrchr(pastBase,'\\');
    if(finalPiece) { *finalPiece='\0'; finalPiece++; }
    else { finalPiece=pastBase; pastBase=NULL; }

         if(!strcmpi(DupeKey,"HKEY_CLASSES_ROOT"))     BaseKey=HKEY_CLASSES_ROOT;
    else if(!strcmpi(DupeKey,"HKEY_CURRENT_CONFIG"))   BaseKey=HKEY_CURRENT_CONFIG;
    else if(!strcmpi(DupeKey,"HKEY_CURRENT_USER"))     BaseKey=HKEY_CURRENT_USER;
    else if(!strcmpi(DupeKey,"HKEY_LOCAL_MACHINE"))    BaseKey=HKEY_LOCAL_MACHINE;
    else if(!strcmpi(DupeKey,"HKEY_USERS"))            BaseKey=HKEY_USERS;
    else if(!strcmpi(DupeKey,"HKEY_PERFORMANCE_DATA")) BaseKey=HKEY_PERFORMANCE_DATA;
    else if(!strcmpi(DupeKey,"HKEY_DYN_DATA"))         BaseKey=HKEY_DYN_DATA;
    else											   BaseKey=HKEY_CURRENT_USER;

    RegOpenKeyExA(BaseKey,pastBase,0,KEY_READ,&RegistryKey);

    if(RegQueryValueExA(RegistryKey,finalPiece,0,NULL,(unsigned char *)Buffer,&MaxLength)
       ==ERROR_SUCCESS)
        return MaxLength;                 /* Return the size read on success */

    /* Shutdown: */
    RegCloseKey(RegistryKey);
    return 0;                                         /* Return 0 on Failure */
}

void Abort(char *msg,char *process)
{
    char string[200];
    sprintf(string,"Transfer Aborted: \"%s\" ",msg);
	debugf(_T("Abort()"));
    MessageBoxA(0,string,process,0);
}

void NoTempFile(char *filename, char *process)
{
	char string[200];
	sprintf(string,"Can't open temp file %s",filename);
	MessageBoxA(0,string,process,0);
}

// receive an SMTP message
int receivesmtp(SOCKET S, int val, char *process)

{
	char string[512];
	int i = recv(S,string,sizeof(string),0);
    if (i == SOCKET_ERROR)
    {
		Abort("WINSOCK error",process);
		WSACleanup();
		return 1;
	}

	i = atoi(string);
    if (val && i != val)
    {
		Abort(string,process);
		WSACleanup();
		return 1;
	}
	return 0;
}
// send an SMTP message
int sendsmtp(SOCKET S, char *process, char *fmt,...)
{
	char string[512];
	va_list argptr;

	va_start( argptr, fmt);
  	vsprintf(string, fmt, argptr);
	va_end(argptr);
	strcat(string,"\r\n");
    if (send(S,string,strlen(string),0) == SOCKET_ERROR)
    {
		Abort("WINSOCK error",process);
		WSACleanup();
		return 1;
	}
	return 0;
}

int sendsmtpputs(SOCKET S, char *process, char *fmt)
{
    if (send(S,fmt,strlen(fmt),0) == SOCKET_ERROR)
    {
		Abort("WINSOCK error",process);
		WSACleanup();
		return 1;
	}

    if (send(S,"\r\n",strlen("\r\n"),0) == SOCKET_ERROR)
    {
		Abort("WINSOCK error",process);
		WSACleanup();
		return 1;
	}

	return 0;
}
int CORE_API SendMultiMailMessage(char *smtpserver, char *sender, char *rcpts[], char *subject, char *message)
{
	static char *procname = "send mail SMTP";
    char smtpBuffer[1024], senderBuffer[1024], senderBuffer2[1024];
	int i,e;
	struct sockaddr_in Sa;
	WSADATA Ws;
	SOCKET S;
	struct hostent *H;

	//subject="test";
	//message="Test";

	// Preprocess each of my parameters:
	if(smtpserver) { smtpserver=appRmlws(smtpserver);  if(!*smtpserver) smtpserver=NULL; }
	if(sender)	   { sender    =appRmlws(sender);	   if(!*sender)     sender=NULL;		}
	if(subject)    { subject   =appRmlws(subject);	   if(!*subject)    subject=NULL;	}
	if(message)	   { message   =appRmlws(message);	   if(!*message)    message=NULL; }

	/* no smtp server specified, look for it in the registry: */
    if(!smtpserver)
    {
		if(RegistryLoad("HKEY_CURRENT_USER\\Software\\Microsoft\\Internet Account Manager\\Accounts\\00000001\\SMTP Server", smtpBuffer,sizeof(smtpBuffer)))
            smtpserver=smtpBuffer;
        else
        {
			debugf(_T("Can't find smtpserver."));
			GDnExec->Printf(_T("Can't find smtpserver"));
			return 0;
        }
    }

	/* no sender specified, look for it in the registry: */
	if(!sender)
	{
		if(RegistryLoad("HKEY_CURRENT_USER\\Software\\Microsoft\\Internet Account Manager\\Accounts\\00000001\\SMTP Email Address", senderBuffer,sizeof(senderBuffer)))
            sender=senderBuffer;
        else
			sender="<DukeNukem@3drealms.com>";
	}

	// Make sure email is in brackets:
	if(*sender!='<')
	{
		strcpy(senderBuffer2,"<"); strcat(senderBuffer2,sender); strcat(senderBuffer2,">");
		sender=senderBuffer2;
	}

	if(!rcpts||!(rcpts[0]))
	{
		static char *internalRcpts[] = { sender, NULL };
		rcpts = internalRcpts;
		return 0;
	}



	if(!subject) subject="Message From Duke Nukem";
	if(!message) message="I was born to rock the world!";

	/* Check for network available */
	e=WSAStartup(0x0101,&Ws);
    if (e)
    {
		GDnExec->Printf(_T("Network not available"));
        return 1;
	}

	/* Get a socket */
	S=socket(AF_INET, SOCK_STREAM,0);
	Sa.sin_family=AF_INET;
	Sa.sin_port = htons(25);
	H=gethostbyname(smtpserver);
    if (!H)
    {
		GDnExec->Printf(_T("Host \"%s\" Not Available"),ANSI_TO_TCHAR(smtpserver));
		return 0;
	}

	// connect
	Sa.sin_addr.s_addr=*((unsigned long *) H->h_addr);
	i=connect(S,(struct sockaddr *) &Sa,sizeof(Sa));
    if (i == SOCKET_ERROR)
    {
        Abort("WINSOCK: Can't connect",procname);
		return 0;
	}

    if (receivesmtp(S,220,procname)) return 0;

	// say hello (yes only one L )
    if (sendsmtp(S,procname,"HELO %s","3drealms.com")) return 0; // Source can be anything 
    if (receivesmtp(S,250,procname))           return 0;

	// sender
    if (sendsmtp(S,procname,"MAIL FROM: %s",sender)) return 0;
    if (receivesmtp(S,250,procname))                return 0;

	int j;

	
	char rcptBuffer[1024];
    // recipient
	for(j=0;rcpts[j];j++)
	{
		char *rcpt=rcpts[j];
		// Make sure email is in brackets:
		if(*rcpt!='<')
		{
			strcpy(rcptBuffer,"<"); strcat(rcptBuffer,rcpt); strcat(rcptBuffer,">");
			rcpt=rcptBuffer;
		}

		//debugf(_T("RCPT TO:%s"),ANSI_TO_TCHAR(rcpt));

		if (sendsmtp(S,procname,"RCPT TO: %s",rcpt)) return 0;
		if (receivesmtp(S,250,procname))			 return 0;
	}

	// tell it we have a message
    if (sendsmtp(S,procname,"DATA")) return 0;
    if (receivesmtp(S,354,procname)) return 0;

	// now send the text of the message
/*
	for(j=0;rcpts[j];j++)
	{
		if(sendsmtp(S,procname,"To: %s",rcpts[j])) 
			return 0;
	}
*/
    if(sendsmtp(S,procname,"Subject: %s\r\n",subject)) return 0;
    if(sendsmtpputs(S,procname,message)) return 0;

	// terminate the message
    if (sendsmtp(S,procname,"."))    return 0;
    if (receivesmtp(S,250,procname)) return 0;

	// and exit
    if (sendsmtp(S,procname,"QUIT")) return 0;
    if (receivesmtp(S,0,procname))   return 0;


	/* Clean up network */
	WSACleanup();


	return 1;

}

/* main line for semnding message */
int CORE_API SendMailMessage(char *smtpserver, char *sender, char *rcpt, char *subject, char *message)
{
	static char *procname = "send mail SMTP";
    char smtpBuffer[1024], senderBuffer[1024], senderBuffer2[1024], rcptBuffer[1024];
	int i,e;
	struct sockaddr_in Sa;
	WSADATA Ws;
	SOCKET S;
	struct hostent *H;

	//subject="test";
	//message="Test";

	// Preprocess each of my parameters:
	if(smtpserver) { smtpserver=appRmlws(smtpserver);  if(!*smtpserver) smtpserver=NULL; }
	if(sender)	   { sender    =appRmlws(sender);	   if(!*sender)     sender=NULL;		}
	if(rcpt)	   { rcpt      =appRmlws(rcpt);		   if(!*rcpt)       rcpt=NULL;		}
	if(subject)    { subject   =appRmlws(subject);	   if(!*subject)    subject=NULL;	}
	if(message)	   { message   =appRmlws(message);	   if(!*message)    message=NULL; }

	/* no smtp server specified, look for it in the registry: */
    if(!smtpserver)
    {
		if(RegistryLoad("HKEY_CURRENT_USER\\Software\\Microsoft\\Internet Account Manager\\Accounts\\00000001\\SMTP Server", smtpBuffer,sizeof(smtpBuffer)))
            smtpserver=smtpBuffer;
        else
        {
			debugf(_T("Can't find smtpserver."));
			GDnExec->Printf(_T("Can't find smtpserver"));
			return 0;
        }
    }

	/* no sender specified, look for it in the registry: */
	if(!sender)
	{
		if(RegistryLoad("HKEY_CURRENT_USER\\Software\\Microsoft\\Internet Account Manager\\Accounts\\00000001\\SMTP Email Address", senderBuffer,sizeof(senderBuffer)))
            sender=senderBuffer;
        else
			sender="<DukeNukem@3drealms.com>";
	}

	// Make sure email is in brackets:
	if(*sender!='<')
	{
		strcpy(senderBuffer2,"<"); strcat(senderBuffer2,sender); strcat(senderBuffer2,">");
		sender=senderBuffer2;
	}

	if(!rcpt)
	{
		rcpt=sender;
		return 0;
	}

	// Make sure email is in brackets:
	if(*rcpt!='<')
	{
		strcpy(rcptBuffer,"<"); strcat(rcptBuffer,rcpt); strcat(rcptBuffer,">");
		rcpt=rcptBuffer;
	}


	if(!subject) subject="Message From Duke Nukem";
	if(!message) message="I was born to rock the world!";

	/* Check for network available */
	e=WSAStartup(0x0101,&Ws);
    if (e)
    {
		GDnExec->Printf(_T("Network not available"));
        return 1;
	}

	/* Get a socket */
	S=socket(AF_INET, SOCK_STREAM,0);
	Sa.sin_family=AF_INET;
	Sa.sin_port = htons(25);
	H=gethostbyname(smtpserver);
    if (!H)
    {
		GDnExec->Printf(_T("Host \"%s\" Not Available"),ANSI_TO_TCHAR(smtpserver));
		return 0;
	}

	// connect
	Sa.sin_addr.s_addr=*((unsigned long *) H->h_addr);
	i=connect(S,(struct sockaddr *) &Sa,sizeof(Sa));
    if (i == SOCKET_ERROR)
    {
        Abort("WINSOCK: Can't connect",procname);
		return 0;
	}

    if (receivesmtp(S,220,procname)) return 0;

	// say hello (yes only one L )
    if (sendsmtp(S,procname,"HELO %s","3drealms.com")) return 0; // Source can be anything 
    if (receivesmtp(S,250,procname))           return 0;

	// sender
    if (sendsmtp(S,procname,"MAIL FROM: %s",sender)) return 0;
    if (receivesmtp(S,250,procname))                return 0;

    // recipient
    if (sendsmtp(S,procname,"RCPT TO: %s",rcpt))  return 0;
    if (receivesmtp(S,250,procname))             return 0;

	// tell it we have a message
    if (sendsmtp(S,procname,"DATA")) return 0;
    if (receivesmtp(S,354,procname)) return 0;

	// now send the text of the message
    if(sendsmtp(S,procname,"Subject: %s\r\n",subject)) return 0;
    if(sendsmtpputs(S,procname,message)) return 0;

	// terminate the message
    if (sendsmtp(S,procname,"."))    return 0;
    if (receivesmtp(S,250,procname)) return 0;

	// and exit
    if (sendsmtp(S,procname,"QUIT")) return 0;
    if (receivesmtp(S,0,procname))   return 0;


	/* Clean up network */
	WSACleanup();


	return 1;
}

volatile char *Async_smtpserver;
volatile char *Async_sender;
volatile char *Async_rcpt;
volatile char *Async_subject;
volatile char *Async_message;

static void __cdecl AsyncSendMailMessageThread(void *arglist)
{
	volatile static bool Entered=false;

	if(!Entered)
	{
		Entered=true;	// No one allowed in till I finish
		SendMailMessage((char *)Async_smtpserver,(char *)Async_sender,(char *)Async_rcpt,(char *)Async_subject,(char *)Async_message);
		Entered=false;	// I'm finished
	}
}

int CORE_API AsyncSendMailMessage(char *smtpserver, char *sender, char *rcpt, char *subject, char *message)
{
	Async_smtpserver=smtpserver;
	Async_sender=sender;
	Async_rcpt=rcpt;
	Async_subject=subject;
	Async_message=message;

	_beginthread( AsyncSendMailMessageThread, 0, NULL );	
	return 1;
}

struct 
{
	char *name, *email;
} emailLookup[] =
{
	{ "nick",    "nicks@3drealms.com" },
	{ "brandon", "brandonr@3drealms.com" },
	{ "jess",    "jessc@3drealms.com" },
	{ "scott",	 "scotta@3drealms.com" },
	{ "chris",   "chrish@3drealms.com" },
	{ "keith",   "keiths@3drealms.com" },
	{ "allen",   "allenb@3drealms.com" },
	{ "steven",  "stevenc@3drealms.com" },
	{ "charlie", "charliew@3drealms.com" },
	{ "john",    "johna@3drealms.com" },
	{ "matt",    "mattw@3drealms.com" },
	{ "george",  "georgeb@3drealms.com" },
	{ "scott",   "scottm@3drealms.com" },
	{ NULL, NULL }
};

EXECFUNC(Bug)
{
	if(argc==1)
	{
		GDnExec->Printf(_T("USAGE: Bug <username> <message>"));

		GDnExec->Printf(_T(""));
		GDnExec->Printf(_T("Possible usernames:"));
		for(int i=0;emailLookup[i].name;i++)
		{
			GDnExec->Printf(_T("     %s"),ANSI_TO_TCHAR(emailLookup[i].name),ANSI_TO_TCHAR(emailLookup[i].email));
		}
	} else
	{
		char email[256];

		if(argc>1) 
		{
			for(int i=0;emailLookup[i].name;i++)
				if(!strcmpi(TCHAR_TO_ANSI(argv[1]),emailLookup[i].name))
				{
					strcpy(email,emailLookup[i].email);
					break;
				}

			if(!emailLookup[i].name)
			{
				GDnExec->Printf(_T("Unknown recipient."));
				return;
			}
		}
		
		if(argc<2)
		{
			GDnExec->Printf(_T("No message!"));
			return;
		}
		
		if(SendMailMessage("smtp.3drealms.com",NULL,email, "bug", TCHAR_TO_ANSI(argv[2])))
			GDnExec->Printf(_T("Mail Sent!"));
		else 
			GDnExec->Printf(_T("Couldn't send mail."));
	
	}

	return;
}

EXECFUNC(Mail)
{
	if(argc==1)
	{
		GDnExec->Printf(_T("USAGE: Mail <to> <subject> <message> [<smtp server>]"));
		return;
	} else
	{
		char to[256];
		char subject[256];
		char body[1024];
		char smtpServer[1024]="";

		if(argc>1) 
		{
			/* Possibly strip quotes: */
			if(*argv[1]=='\"')
			{
				strcpy(to,TCHAR_TO_ANSI(argv[1])+1);
				to[strlen(to)-1]='\0';
			} else
				strcpy(to, TCHAR_TO_ANSI(argv[1])); 
		}
		if(argc>2) 
		{
			if(*argv[2]=='\"')
			{
				strcpy(subject,TCHAR_TO_ANSI(argv[2])+1);
				subject[strlen(subject)-1]='\0';
			} else
				strcpy(subject, TCHAR_TO_ANSI(argv[2])); 
		} else strcpy(subject,"Message from Duke");
		
		if(argc>3) 
		{
			if(*argv[3]=='\"')
			{
				strcpy(body,TCHAR_TO_ANSI(argv[3])+1);
				body[strlen(body)-1]='\0';
			} else
				strcpy(body, TCHAR_TO_ANSI(argv[3])); 
		} else strcpy(body,"I was born to rock the world!");
	
		if(argc>4) 
		{
			if(*argv[4]=='\"')
			{
				strcpy(smtpServer,TCHAR_TO_ANSI(argv[4])+1);
				smtpServer[strlen(smtpServer)-1]='\0';
			} else
				strcpy(smtpServer, TCHAR_TO_ANSI(argv[4])); 
		} 

		char *s=NULL;
		if(*smtpServer) s=smtpServer;

		if(SendMailMessage(s,NULL,to, subject, body))
			GDnExec->Printf(_T("Mail Sent!"));
		else 
			GDnExec->Printf(_T("Couldn't send mail."));
	}
}

#define MESSAGELEN 8192

void NoHost(char *filename, char *process)
{
    char string[200];
    sprintf(string,"Host \"%s\" Not Available",filename);
    MessageBoxA(0,string,process,0);
}


// Receive from NNTP, put up an error if necessary
int receiveNNTP(SOCKET S, int val, char *process)
{
    char string[MESSAGELEN];
    // get the data
    int i = recv(S,string,MESSAGELEN,0);
    if (i == SOCKET_ERROR)
    {
        Abort("WINSOCK error",process);
        WSACleanup();
        return 1;
    }

    // now check the return value to see if it is correct
    i = atoi(string);
    if (val && i != val)
    {
        Abort(string,process);
        WSACleanup();
        return 1;
    }
    return 0;
}
// Send data to the NNTP socket
int sendNNTP(SOCKET S, char *process, char *fmt,...)
{
    char string[MESSAGELEN];
    va_list argptr;

    va_start( argptr, fmt);
    vsprintf(string, fmt, argptr);
    va_end(argptr);
    strcat(string,"\r\n");
    if (send(S,string,strlen(string),0) == SOCKET_ERROR)
    {
        Abort("WINSOCK error",process);
        WSACleanup();
        return 1;
    }
    return 0;
}

// main line for sending a message
int SendNewsMessage(char *nntpServer, char *rcpt, char *name,char *subject, char *message)
{
    static char *procname = "send news NNTP";
    int i,e;
    struct sockaddr_in Sa;
    WSADATA Ws;
    SOCKET S;
    struct hostent *H;

    // see if file to post exists:
    if (!message) return 0;

    /* Check for network available */
    e=WSAStartup(0x0101,&Ws);
    if (e)
    {
		Error("Network not available");
        //NoNetwork(procname);
        return 1;
    }

    /* Get a socket and find the host */
    S=socket(AF_INET, SOCK_STREAM,0);
    Sa.sin_family=AF_INET;
    Sa.sin_port = htons(119); // 119 is the NNTP port:
    H=gethostbyname(nntpServer);
    if (!H)
    {
        NoHost(nntpServer, procname);
        return 0;
    }

    /* connect */
    Sa.sin_addr.s_addr=*((unsigned long *) H->h_addr);
    i=connect(S,(struct sockaddr *) &Sa,sizeof(Sa));
    if(i == SOCKET_ERROR)
    {
        Abort("WINSOCK: Can't connect",procname);
        return 0;
    }
    if(receiveNNTP(S,200,procname)) return 0;

    // send POST command
    if(sendNNTP(S,procname,"POST")) return 0;

    if(receiveNNTP(S,340,procname)) return 0;

    // Send the actual message:
    if(sendNNTP(S,procname,"newsgroups: %s",rcpt)) return 0;
    if(sendNNTP(S,procname,"subject: %s",subject)) return 0;
    if(sendNNTP(S,procname,"from: %s",name))       return 0;
    if(sendNNTP(S,procname,"\n%s",message))        return 0;

    // Send the dot
    if(sendNNTP(S,procname,"."))    return 0;
    if(receiveNNTP(S,240,procname)) return 0;

    // now exit NNTP
    if (sendNNTP(S,procname,"QUIT")) return 0;
    if (receiveNNTP(S,0,procname))   return 0;

    /* Clean up network */
    WSACleanup();

    return 1;
}

EXECFUNC(News)
{
	SendNewsMessage("news.concentric.net","alt.test","dukeNukem@3drealms.com","testiofunko","Testing testing testing, keep them doggies testing\ntest test testdaaklsadjdafjfdsajlfadskjldfaj;dfsajklfadjklafjk;lfdsfadsjajfdjklfajklasdfjkdfskjldfskjlfajkldfjkladfjlkfakjlfdjlkafjlk;fdjlkasdfjkfadjldafljfdslajalsfdj;ljjjasdjjfda;kljsfdljfdsjkl;dk;ljaf;lkj");
}
