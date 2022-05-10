/******************************************************************************
				DNCLIENT.C - The Dukenet Client API (Tab=4 Width=79)
*******************************************************************************
      DNCLIENT.C is (C) Copyright 1999 by 3D Realms. All rights reserved.
    Copying, modification, distribution or publication without prior written
                    consent the 3D Realms is prohibited.
*******************************************************************************
******************************************************************************/

/******************************************************************************
                              Included Files:
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
#include <process.h>

#include "dnclient.h"
#include "network.h"

/******************************************************************************
								Globals:
******************************************************************************/
static volatile dncConnectionStatus dncConnectionState=DNC_DISCONNECTED; /* Current Connection State. */
static volatile int   dncClientSocket=-1;
static char dncCommandBuffer[4096];
static char *dncClientCommandBuffer=NULL;
static char DisconnectReason[4096]="unknown";

/******************************************************************************
                         Async Client Socket Lookup:
******************************************************************************/
static volatile char          *dncServerName;
static volatile unsigned short dncPort;
void __cdecl asyncTCPClientSocket( void *argument )
{
	dncClientSocket=TCPClientSocket((char *)dncServerName,(unsigned short)dncPort);
	free((char *)dncServerName); dncServerName=NULL;
	dncPort=0;

	if(dncClientSocket<0)						/* Did I fail to get a valid socket? */
	{
		dncConnectionState=DNC_DISCONNECTED;	/* I'm in the disconnected state. */
		strcpy(DisconnectReason,"TCPClientSocket failed.");
		return;									/* Terminate. */
	}

	dncConnectionState=DNC_CONNECTED;			/* I'm connected. */
}

/******************************************************************************
                              Public Interface:
******************************************************************************/
char dncInitialize(char *serverName,unsigned short port)  /* Init and begin connection procedure */
{
	NetworkInitialize();
	dncClientCommandBuffer=NULL;
	dncCommandBuffer[0]='\0';
	dncConnectionState=DNC_CONNECTING;		     /* Begin connecting. */
	dncServerName=strdup(serverName);
	dncPort=port;
	_beginthread(asyncTCPClientSocket,0,NULL);   /* Start connecting to the client. */
	return 0;
}

void dncShutdown()					             /* Disconnect and shutdown. */
{
	dncCommandBuffer[0]='\0';
	dncConnectionState=DNC_DISCONNECTED;         /* I'm outta there. */
	strcpy(DisconnectReason,"dncShutdown() called.");

	if(dncClientSocket>0)      { CLOSE(dncClientSocket); dncClientSocket=-1; }
	if(dncClientCommandBuffer) { free(dncClientCommandBuffer); dncClientCommandBuffer=NULL; }
	NetworkShutdown();
}

void dncSendCommand(char *command)
{
	dncClientCommandBuffer=strcata(dncClientCommandBuffer,command);
	dncClientCommandBuffer=strcata(dncClientCommandBuffer,"\r\n");
}

dncConnectionStatus dncUpdate(void (*dncHandleCommand)(char *command)) /* Updates the dukenet client, returns nonzero if connected */
{
	int charactersGotten;
	char character;

	/* Do nothing if not yet connected. */
	if(dncConnectionState!=DNC_CONNECTED) return dncConnectionState;
	
	/* Update my current command buffer: */
	while(charactersGotten=TCPRead(dncClientSocket,&character,1))
	{
		if(charactersGotten<0)						/* Socket has been disconnected. */
		{
			strcpy(DisconnectReason,"TCPRead error.");
			dncConnectionState=DNC_DISCONNECTED;	/* Mark connection state as such. */
			return dncConnectionState;				/* And disconnect. */
		} else if(charactersGotten>0)
		{
			if(character=='\n') 
			{
				int length=strlen(dncCommandBuffer); /* Grab the length of the command. */

				/* Strip trailing \r\n */
				if(dncCommandBuffer[length-1]=='\r') dncCommandBuffer[length-1]='\0';
				(*dncHandleCommand)(dncCommandBuffer);	/* Process command. */
				strcpy(dncCommandBuffer,"");		/* Clear out command buffer. */
			}
			else 
				strcatc(dncCommandBuffer,character);
		}
	}

	/* Splorf the client command buffer: */
	if(dncClientCommandBuffer&&strlen(dncClientCommandBuffer))
	{
		size_t sizeToWrite=strlen(dncClientCommandBuffer);
		char *endOfLine=strchr(dncClientCommandBuffer,'\n');

		if(endOfLine) sizeToWrite=(endOfLine-dncClientCommandBuffer)+1;
		charactersGotten=TCPWrite( dncClientSocket, dncClientCommandBuffer, sizeToWrite, 0 );
		if(charactersGotten<0)
		{
			dncConnectionState=DNC_DISCONNECTED;
			strcpy(DisconnectReason,"TCPWrite failed.");
			return dncConnectionState;
		}
		if(charactersGotten>0) 
			strcpy(dncClientCommandBuffer,dncClientCommandBuffer+charactersGotten);
		
	}

	return dncConnectionState; /* Return the default state. */
}

char *dncGetDisconnectReason()
{
	return DisconnectReason;
}

/******************************************************************************
                              Sample Test Proggie:
******************************************************************************/
#ifdef TEST
int main(int argc, char *argv[])
{
	dncInitialize("192.168.1.135"/*"localhost"*/,4662);

	while(dncUpdate()!=DNC_DISCONNECTED)
	{
		if(kbhit()) 	
		{
			getch();
			dncSendCommand("testo");
		}
		//puts("hehehehe");
	}
		
	dncShutdown();


	return EXIT_SUCCESS;
}
#endif