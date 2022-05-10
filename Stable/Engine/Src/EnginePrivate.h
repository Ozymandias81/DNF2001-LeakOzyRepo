/*=============================================================================
	EnginePrivate.h: Unreal engine private header file.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.
=============================================================================*/

/*----------------------------------------------------------------------------
	Core public includes.
----------------------------------------------------------------------------*/

#include "Core.h"
#include "Window.h"

/*-----------------------------------------------------------------------------
	Locals functions.
-----------------------------------------------------------------------------*/

extern void appPlatformPreInit();
extern void appPlatformInit();
extern void appPlatformPreExit();
extern void appPlatformExit();

extern UBOOL GNoGC;
extern UBOOL GCheckConflicts;
extern UBOOL GExitPurge;

/*-----------------------------------------------------------------------------
	Includes.
-----------------------------------------------------------------------------*/


/*-----------------------------------------------------------------------------
	UTextBufferFactory.
-----------------------------------------------------------------------------*/

//
// Imports UTextBuffer objects.
//
class CORE_API UTextBufferFactory : public UFactory
{
	DECLARE_CLASS(UTextBufferFactory,UFactory,0)

	// Constructors.
	UTextBufferFactory();
	void StaticConstructor();

	// UFactory interface.
	UObject* FactoryCreateText( UClass* Class, UObject* InParent, FName Name, DWORD Flags, UObject* Context, const TCHAR* Type, const TCHAR*& Buffer, const TCHAR* BufferEnd, FFeedbackContext* Warn );
};



/*----------------------------------------------------------------------------
	Engine public includes.
----------------------------------------------------------------------------*/

#include "Engine.h"
#include "WinDrv.h"

/*-----------------------------------------------------------------------------
	Engine private includes.
-----------------------------------------------------------------------------*/

#include "UnPath.h"		// Path building.
#include "UnCon.h"		// Viewport console.
#include "UnNet.h"
#include "UnSocket.h"

/*-----------------------------------------------------------------------------
	Bind to next available port.
-----------------------------------------------------------------------------*/

//
// Bind to next available port.
//
inline int bindnextport( SOCKET s, struct sockaddr_in* addr, int portcount, int portinc )
{
	for( int i=0; i<portcount; i++ )
	{
		if( !bind( s, (sockaddr*)addr, sizeof(sockaddr_in) ) )
		{
			if (ntohs(addr->sin_port) != 0)
				return ntohs(addr->sin_port);
			else
			{
				// 0 means allocate a port for us, so find out what that port was
				struct sockaddr_in boundaddr;
				#if _MSC_VER
				INT size = sizeof(boundaddr);
				#else
				socklen_t size = sizeof(boundaddr);
				#endif
				getsockname ( s, (sockaddr*)(&boundaddr), &size);
				return ntohs(boundaddr.sin_port);
			}
		}
		if( addr->sin_port==0 )
			break;
		addr->sin_port = htons( ntohs(addr->sin_port) + portinc );
	}
	return 0;
}

inline int getlocalhostaddr( FOutputDevice& Out, in_addr &HostAddr )
{
	int CanBindAll = 0;
	IpSetInt( HostAddr, INADDR_ANY );
	TCHAR Home[256]=TEXT(""), HostName[256]=TEXT("");
	ANSICHAR AnsiHostName[256]="";
	if( gethostname( AnsiHostName, 256 ) )
		Out.Logf( TEXT("%s: gethostname failed (%s)"), SOCKET_API, SocketError() );
	appStrcpy( HostName, appFromAnsi(AnsiHostName) );
	if( Parse(appCmdLine(),TEXT("MULTIHOME="),Home,ARRAY_COUNT(Home)) )
	{
		TCHAR *A, *B, *C, *D;
		A=Home;
		if
		(	(A=Home)!=NULL
		&&	(B=appStrchr(A,'.'))!=NULL
		&&	(C=appStrchr(B+1,'.'))!=NULL
		&&	(D=appStrchr(C+1,'.'))!=NULL )
		{
			IpSetBytes( HostAddr, appAtoi(A), appAtoi(B+1), appAtoi(C+1), \
				appAtoi(D+1) );
		}
		else Out.Logf( TEXT("Invalid multihome IP address %s"), Home );
	}
	else
	{
		HOSTENT* HostEnt = gethostbyname( appToAnsi(HostName) ); 
		if( HostEnt==NULL )
		{
			Out.Logf( TEXT("gethostbyname failed (%s)"), SocketError() );
		}
		else if( HostEnt->h_addrtype!=PF_INET )
		{
			Out.Logf( TEXT("gethostbyname: non-Internet address (%s)"), \
				SocketError() );
		}
		else
		{
			HostAddr = *(in_addr*)( *HostEnt->h_addr_list );
			if( !ParseParam(appCmdLine(),TEXT("PRIMARYNET")) )
				CanBindAll = 1;

			static UBOOL First=0;
			if( !First )
			{
				First = 1;
				debugf( NAME_Init, TEXT("%s: I am %s (%s)"), SOCKET_API, HostName, *IpString( HostAddr ) );
			}
		}
	}
	return CanBindAll;
}

//
// Get local IP to bind to
//
inline in_addr getlocalbindaddr( FOutputDevice& Out )
{
	in_addr BindAddr;
	
	// If we can bind to all addresses, return 0.0.0.0
	if( getlocalhostaddr( Out, BindAddr ) )
		IpSetInt( BindAddr, INADDR_ANY );	
	
	return BindAddr;
}

#include "..\..\Render\Src\RenderPrivate.h"
#include "DnMeshPrivate.h"
#include "DnTextureCanvas.h"

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
