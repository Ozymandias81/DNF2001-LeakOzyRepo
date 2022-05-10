/******************************************************************************
				DNCLIENT.H - The Dukenet Client API (Tab=4 Width=79)
*******************************************************************************
      DNCLIENT.C is (C) Copyright 1999 by 3D Realms. All rights reserved.
    Copying, modification, distribution or publication without prior written
                    consent the 3D Realms is prohibited.
*******************************************************************************
	This interface essentially encapsulates most of the 'back end' 
functionality that a dukenet client would need.  From connecting to DukeNet, to
maintaining user/channel lists/etc.
	This client library works via the dncUpdate() mechinism more than anything.
******************************************************************************/
#ifdef __cplusplus
extern "C" {
#endif

typedef enum 
{
	DNC_CONNECTING,
	DNC_CONNECTED,
	DNC_DISCONNECTED
} dncConnectionStatus;

char dncInitialize(char *serverName,unsigned short port);				  /* Init and begin connection procedure */
void dncShutdown();																	 /* Disconnect and shutdown. */
void dncSendCommand(char *command);
dncConnectionStatus dncUpdate(void (*dncHandleCommand)(char *command)); /* Updates the dukenet client, returns nonzero if connected */
char *dncGetDisconnectReason();


#ifdef __cplusplus
};
#endif
