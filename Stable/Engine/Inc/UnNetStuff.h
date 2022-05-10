// Net stuff.

/*-----------------------------------------------------------------------------
	IpDrv Definitions.
-----------------------------------------------------------------------------*/

// An IP address.
struct FIpAddr
{
	DWORD Addr;
	DWORD Port;
};

// SocketData.
struct FSocketData
{
	SOCKADDR_IN Addr;
	INT Port;
	SOCKET Socket;
};

// OperationStats
struct FOperationStats
{
	INT MessagesServiced;
	INT BytesReceived;
	INT BytesSent;
};

// Globals.
extern UBOOL GInitialized;

/*-----------------------------------------------------------------------------
	Host resolution thread.
-----------------------------------------------------------------------------*/

#if __GNUG__
void* ResolveThreadEntry( void* Arg );
#else
DWORD STDCALL ResolveThreadEntry( void* Arg );
#endif

//
// Class for creating a background thread to resolve a host.
//
class FResolveInfo
{
public:
	// Variables.
	in_addr Addr;
	DWORD   ThreadId;
	TCHAR   HostName[256];
	TCHAR   Error[256];

	#if __GNUG__
	pthread_t	ResolveThread;
	#endif

	// Functions.
	FResolveInfo( const TCHAR* InHostName )
	{	
		debugf( TEXT("Resolving %s..."), InHostName );
		appStrcpy( HostName, InHostName );
		*Error = 0;

#if _MSC_VER
		HANDLE hThread = CreateThread( NULL, 0, ResolveThreadEntry, this, 0, &ThreadId );
		check(hThread);
		CloseHandle( hThread );
#else
		ThreadId = 1;
		pthread_attr_t ThreadAttributes;
		pthread_attr_init( &ThreadAttributes );
		pthread_attr_setdetachstate( &ThreadAttributes, PTHREAD_CREATE_DETACHED );
		pthread_create( &ResolveThread, &ThreadAttributes, &ResolveThreadEntry, this );
#endif

	}
	UBOOL Resolved()
	{
		return ThreadId==0;
	}
	const TCHAR* GetError()
	{
		return *Error ? Error : NULL;
	}
	const in_addr GetAddr()
	{
		return Addr;
	}
	const TCHAR* GetHostName()
	{
		return HostName;
	}
};
