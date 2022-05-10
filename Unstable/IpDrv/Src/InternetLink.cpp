/*=============================================================================
	InternetLink.cpp: Unreal Internet Connection Superclass
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

Revision history:
	* Created by Brandon Reinhart
=============================================================================*/

#include "..\..\Engine\Src\EnginePrivate.h"

#define PRIVATE_BUILD 1
#if PRIVATE_BUILD
	#include "GameSpyClasses.h"
#else
	#include "GameSpyClassesPublic.h"
#endif

/*-----------------------------------------------------------------------------
	AInternetLink implementation.
-----------------------------------------------------------------------------*/

IMPLEMENT_CLASS(AInternetLink);

//
// Constructor.
//
AInternetLink::AInternetLink()
{
	FString Error;
	InitSockets( Error );

	LinkMode     = MODE_Text;
	ReceiveMode  = RMODE_Event;
	DataPending  = 0;
	Port         = 0;
	Socket       = INVALID_SOCKET;
	RemoteSocket = INVALID_SOCKET;
}

//
// Destroy.
//
void AInternetLink::Destroy()
{
	Super::Destroy();
}

//
// Time passing.
//
UBOOL __fastcall AInternetLink::Tick( FLOAT DeltaTime, enum ELevelTick TickType )
{
	UBOOL Result = Super::Tick( DeltaTime, TickType );

	if( GetResolveInfo() && GetResolveInfo()->Resolved() )
	{
		if( GetResolveInfo()->GetError() )
		{
			debugf( NAME_Log, TEXT("AInternetLink Resolve failed: %s"), GetResolveInfo()->GetError() );
			eventResolveFailed();
		}
		else
		{
			debugf( TEXT("Resolved %s (%s)"), GetResolveInfo()->GetHostName(), *IpString(GetResolveInfo()->GetAddr()) );
			FIpAddr Result;
			IpGetInt( GetResolveInfo()->GetAddr(), Result.Addr );
			Result.Addr = htonl( Result.Addr );
			Result.Port = 0;
			eventResolved( Result );
		}
		delete GetResolveInfo();
		GetResolveInfo() = NULL;
	}

	return Result;
}

//
// IsDataPending: Returns true if data is pending.
//
void AInternetLink::execIsDataPending( FFrame& Stack, RESULT_DECL )
{
	P_FINISH;

	if ( DataPending ) {
		*(DWORD*)Result = 1;
		return;
	}

	*(DWORD*)Result = 0;
}

//
// ParseURL: Parses an Unreal URL into its component elements.
// Returns false if the URL was invalid.
//
void AInternetLink::execParseURL( FFrame& Stack, RESULT_DECL )
{
	P_GET_STR(URL);
	P_GET_STR_REF(Addr);
	P_GET_INT_REF(Port);
	P_GET_STR_REF(Level);
	P_GET_STR_REF(Portal);
	P_FINISH;

	FURL TheURL( 0, *URL, TRAVEL_Absolute );
	*Addr   = TheURL.Host;
	*Port   = TheURL.Port;
	*Level  = TheURL.Map;
	*Portal = TheURL.Portal;

	*(DWORD*)Result = 1;
}

//
// Resolve a domain or dotted IP.
// Nonblocking operation.  
// Triggers Resolved event if successful.
// Triggers ResolveFailed event if unsuccessful.
//
void AInternetLink::execResolve( FFrame& Stack, RESULT_DECL )
{
	P_GET_STR(Domain);
	P_FINISH;

	// If not, start asynchronous name resolution.
	DWORD addr = inet_addr(appToAnsi(*Domain));
	if( addr==INADDR_NONE && Domain!=TEXT("255.255.255.255") )
	{
		// Success or failure will be called from Tick().
		GetResolveInfo() = new(TEXT("InternetLinkResolve"))FResolveInfo( *Domain );
	}
	else if( addr == INADDR_NONE )
	{
		// Immediate failure.
		eventResolveFailed();
	}
	else
	{
		// Immediate success.
		FIpAddr Result;
		Result.Addr = htonl( addr );
		Result.Port = 0;
		eventResolved( Result );
	}
}

//
// Convert IP address to string.
//
void AInternetLink::execIpAddrToString( FFrame& Stack, RESULT_DECL )
{
	P_GET_STRUCT(FIpAddr,Arg);
	P_FINISH;

	//!!byte order dependence?
	*(FString*)Result = FString::Printf( TEXT("%i.%i.%i.%i:%i"), (BYTE)((Arg.Addr)>>24), (BYTE)((Arg.Addr)>>16), (BYTE)((Arg.Addr)>>8), (BYTE)((Arg.Addr)>>0), Arg.Port );
}

//
// Convert string to an IP address.
//
void AInternetLink::execStringToIpAddr( FFrame& Stack, RESULT_DECL )
{
	P_GET_STR(Str);
	P_GET_STRUCT_REF(FIpAddr,IpAddr);
	P_FINISH;

	DWORD addr = inet_addr(appToAnsi(*Str));
	if( addr!=INADDR_NONE )
	{
		IpAddr->Addr = htonl( addr );
		IpAddr->Port = 0;
		*(UBOOL*)Result = 1;
		return;
	}
	*(UBOOL*)Result = 0;
}

//
// Return most recent Winsock error.
//
void AInternetLink::execGetLastError( FFrame& Stack, RESULT_DECL )
{
	P_FINISH;
	*(DWORD*)Result = WSAGetLastError();
}

//
// Validate a GameSpy Query
//
void AInternetLink::execValidate( FFrame& Stack, RESULT_DECL )
{
	P_GET_STR(ValidationString);
	P_GET_STR(GameName);
	P_FINISH;

	const INT ValidateSize = 6;
	BYTE SecretKey[7];
	GenerateSecretKey(SecretKey, *GameName);
	BYTE EncryptedString[ValidateSize];
	BYTE EncodedString[(ValidateSize * 4) / 3 + 1];

	BYTE* Pos = EncryptedString;
	const TCHAR* Tmp = *ValidationString;
	while( *Tmp )
		*Pos++ = *Tmp++;

	gs_encrypt( EncryptedString, ValidateSize, SecretKey );
	gs_encode( EncryptedString, ValidateSize, EncodedString );
	*(FString*)Result = appFromAnsi((ANSICHAR*)EncodedString);
}

//
// Return the local IP address
//
void AInternetLink::execGetLocalIP( FFrame& Stack, RESULT_DECL )
{
	P_GET_STRUCT_REF(FIpAddr,Arg);
	P_FINISH;

	in_addr LocalAddr;

	getlocalhostaddr( Stack, LocalAddr );
	IpGetInt( LocalAddr, Arg->Addr );
	Arg->Addr = htonl( Arg->Addr );
	Arg->Port = 0;
}

/*-----------------------------------------------------------------------------
	The end.
-----------------------------------------------------------------------------*/
