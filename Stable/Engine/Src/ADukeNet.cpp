/*=============================================================================
	ADukeNet.cpp: DukeNet Script interface code.
	Copyright 1999-2000 3D Realms, Inc. All Rights Reserved.
=============================================================================*/
#include "EnginePrivate.h"
#include "dnClient.h"		/* Dukenet client header. */

static ADukeNet *currentThis;
static void dncHandleCommandCallback(char *command)
{
	if(currentThis)
		currentThis->eventdncServerCommand(FString(appFromAnsi(command)));
}

/*-----------------------------------------------------------------------------
	ADukeNet object implementation.
-----------------------------------------------------------------------------*/
IMPLEMENT_CLASS(ADukeNet);

UBOOL ADukeNet::ConditionalDestroy()
{
	dncShutdown();
	return Super::ConditionalDestroy();
}


void ADukeNet::execdncInitialize( FFrame& Stack, RESULT_DECL )
{
	P_GET_STR(ServerAddress);
	P_GET_INT(Port);
	P_FINISH;

	dncInitialize((char *)ServerAddress.toAnsi(),Port);
}

void ADukeNet::execdncShutdown( FFrame& Stack, RESULT_DECL )
{
	P_FINISH;

	dncShutdown();
}

void ADukeNet::execdncUpdate( FFrame& Stack, RESULT_DECL )
{
	P_FINISH;

	if(currentThis!=NULL) appErrorf(TEXT("execdncUpdate re-entered."));
	currentThis=this;	/* Set the global pointer. */
		BYTE newState=dncUpdate(dncHandleCommandCallback);
	currentThis=NULL;	/* Pop it off. */
	*((BYTE *)Result)=newState;

	DisconnectReason=appFromAnsi(dncGetDisconnectReason());
}

void ADukeNet::execdncCommand( FFrame& Stack, RESULT_DECL )
{
	P_GET_STR(Command);
	P_FINISH;
	dncSendCommand((char *)Command.toAnsi());
}

void ADukeNet::execURLDownloadBanner( FFrame& Stack, RESULT_DECL )
{
}

/*-----------------------------------------------------------------------------
	End of Line.     ( - MCP )
-----------------------------------------------------------------------------*/