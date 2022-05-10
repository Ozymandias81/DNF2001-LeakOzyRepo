/*=============================================================================
	RenderPrivate.h: Rendering package private header.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.
=============================================================================*/

#if _MSC_VER
	#pragma warning( disable : 4201 )
#endif

// Socket API.
#if _MSC_VER
	#define __WINSOCK__ 1
	#define SOCKET_API TEXT("WinSock")
#else
	#define __BSD_SOCKETS__ 1
	#define SOCKET_API TEXT("Sockets")
#endif

// WinSock includes.
#if __WINSOCK__
	#include <windows.h>
	#include <winsock.h>
	#include <conio.h>
#endif

// BSD socket includes.
#if __BSD_SOCKETS__
	#include <stdio.h>
	#include <unistd.h>
	#include <sys/types.h>
	#include <sys/socket.h>
	#include <netinet/in.h>
	#include <arpa/inet.h>
	#include <netdb.h>
	#include <sys/uio.h>
	#include <sys/ioctl.h>
	#include <sys/time.h>
	#include <errno.h>
	#include <pthread.h>
	#include <fcntl.h>
#endif

/*----------------------------------------------------------------------------
	API.
----------------------------------------------------------------------------*/
/* CDH...
#ifndef RENDER_API
	#define RENDER_API DLL_IMPORT
#endif
...CDH */

/*------------------------------------------------------------------------------------
	Dependencies.
------------------------------------------------------------------------------------*/

#include "Engine.h"
#include "UnRender.h"

/*------------------------------------------------------------------------------------
	Render package private.
------------------------------------------------------------------------------------*/

// CDH: Everything previously private to Render has been merged into UnRender.h,
//      now that Render is integrated with Engine.


/*------------------------------------------------------------------------------------
	The End.
------------------------------------------------------------------------------------*/
