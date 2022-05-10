/*=============================================================================
	UnEngine.cpp: Unreal engine main.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by Tim Sweeney
=============================================================================*/

#include "EnginePrivate.h"

/*-----------------------------------------------------------------------------
	CDH: Cannibal connection
-----------------------------------------------------------------------------*/
#include "..\..\Cannibal\CannibalUnr.h"

class CUnrealLogTarget
: public ILogTarget
{
public:
	void Init(NChar* inTitle) {}
	void Shutdown() {}
	void Write(NChar* inStr)
	{
		if (!inStr)
			return;
		if (inStr[0])
			inStr[strlen(inStr)-1] = 0; // cut off trailing \n which is automatically added
		debugf(TEXT("Cannibal Log: %s"), appFromAnsi(inStr));
	}
};

static CUnrealLogTarget GCannibalUnrealLogTarget;

static void CannibalQuit()
{
	appErrorf(TEXT("Cannibal Fatal Error"));
}

static void CannibalInit()
{
	STR_ArgInit(__argc,__argv);
	FILE_BoxInit(NULL);
	LOG_Init("Cannibal", CannibalQuit, LOGLVL_Normal, 0);
	LOG_AddTarget(&GCannibalUnrealLogTarget);
	TIME_Init();
	MSG_Init();
	OBJ_Init(NULL);
	PLG_Init(".\\");
	IPC_Init("IPC_DNF");
}

static void CannibalShutdown()
{
	GLog->Logf( TEXT("Cannibal shutdown...") );
	//GLog->Logf( TEXT("...IPC...") );
	//IPC_Shutdown();
	//GLog->Logf( TEXT("...OBJ...") );
	//OBJ_Shutdown();
	//GLog->Logf( TEXT("...PLG...") );
	//PLG_Shutdown();
	//GLog->Logf( TEXT("...MSG...") );
	//MSG_Shutdown();
	//GLog->Logf( TEXT("...LOG...") );
	//LOG_Shutdown();
	GLog->Logf( TEXT("...Cannibal shutdown complete.") );
}

/*-----------------------------------------------------------------------------
	Object class implementation.
-----------------------------------------------------------------------------*/

IMPLEMENT_CLASS(UEngine);
IMPLEMENT_CLASS(URenderDevice);
IMPLEMENT_CLASS(URenderIterator);

/*-----------------------------------------------------------------------------
	Engine init and exit.
-----------------------------------------------------------------------------*/

//
// Construct the engine.
//
UEngine::UEngine()
{
}

//
// Init class.
//
void UEngine::StaticConstructor()
{
	new(GetClass(),TEXT("CacheSizeMegs"),      RF_Public)UIntProperty (CPP_PROPERTY(CacheSizeMegs      ), TEXT("Settings"), CPF_Config );
	new(GetClass(),TEXT("UseSound"),           RF_Public)UBoolProperty(CPP_PROPERTY(UseSound           ), TEXT("Settings"), CPF_Config );
	CurrentTickRate = 0.f;
}

// Register things.
#define NAMES_ONLY
#define AUTOGENERATE_NAME(name) ENGINE_API FName ENGINE_##name;
#define AUTOGENERATE_FUNCTION(cls,idx,name) IMPLEMENT_FUNCTION(cls,idx,name)
#include "EngineClasses.h"
#undef AUTOGENERATE_FUNCTION
#undef AUTOGENERATE_NAME
#undef NAMES_ONLY

//
// Init audio.
//
void UEngine::InitAudio()
{
	if
	(	!Audio
	&&  UseSound
	&&	GIsClient
	&&	!ParseParam(appCmdLine(),TEXT("NOSOUND")) )
	{
		UClass* AudioClass = StaticLoadClass( UAudioSubsystem::StaticClass(), NULL, TEXT("ini:Engine.Engine.AudioDevice"), NULL, LOAD_NoFail, NULL );
		Audio = ConstructObject<UAudioSubsystem>( AudioClass );
		if( !Audio->Init() )
		{
			debugf( NAME_Log, TEXT("Audio initialization failed.") );
			delete Audio;
			Audio = NULL;
		}
	}
}

//
// Initialize the engine.
//
static TCHAR YesKey=0, NoKey=0;//oldver
void UEngine::Init()
{
	// CDH: Cannibal global initialization
	CannibalInit();

	// Add the intrinsic names.
	#define NAMES_ONLY
	#define AUTOGENERATE_NAME(name) ENGINE_##name = FName(TEXT(#name),FNAME_Intrinsic);
	#define AUTOGENERATE_FUNCTION(cls,idx,name)
	#include "EngineClasses.h"
	#undef AUTOGENERATE_FUNCTION
	#undef AUTOGENERATE_NAME
	#undef NAMES_ONLY

	// Subsystems.
	FURL::StaticInit();
	GEngineMem.Init( 65536 );
	GCache.Init( 1024 * 1024 * Clamp(GIsClient ? CacheSizeMegs : 1,1,1024), 4096 );

	// Translation.
	YesKey = appToUpper( *Localize( "General", "Yes", TEXT("Core") ) );
	NoKey  = appToUpper( *Localize( "General", "No",  TEXT("Core") ) );

	// Objects.
	Cylinder = new UPrimitive;

	// Add to root.
	AddToRoot();

	debugf( NAME_Init, TEXT("Unreal engine initialized.  Lincoln is pleased.") );
}

//
// Pre shutdown.
//
void UEngine::Exit()
{
	// Exit sound.
	if( Audio )
	{
		delete Audio;
		Audio = NULL;
	}
}

//
// Exit the engine.
//
void UEngine::Destroy()
{
	// Remove from root.
	RemoveFromRoot();

	// Shut down all subsystems.
	Audio  = NULL;
	Render = NULL;
	Client = NULL;
	FURL::StaticExit();
	GEngineMem.Exit();
	GCache.Exit( 1 );

	// CDH: Cannibal global shutdown
	CannibalShutdown();

	Super::Destroy();
}

//
// Flush all caches.
//
void UEngine::Flush( UBOOL AllowPrecache )
{
	GCache.Flush();
	if( Client )
		Client->Flush( AllowPrecache );
}

//
// Tick rate.
//
FLOAT UEngine::GetMaxTickRate()
{
	return 0;
}

//
// Progress indicator.
//
void UEngine::SetProgress( const TCHAR* Str1, const TCHAR* Str2, FLOAT Seconds )
{
}

//
// Serialize.
//
void UEngine::Serialize( FArchive& Ar )
{
	Super::Serialize( Ar );
	Ar << Cylinder << Client << Render << Audio;
}

/*-----------------------------------------------------------------------------
	Input.
-----------------------------------------------------------------------------*/

//
// This always going to be the last exec handler in the chain. It
// handles passing the command to all other global handlers.
//
UBOOL UEngine::Exec( const TCHAR* Cmd, FOutputDevice& Ar )
{
	// See if any other subsystems claim the command.
	if( GSys    && GSys->Exec		(Cmd,Ar) ) return 1;
	if( UObject::StaticExec			(Cmd,Ar) ) return 1;
	if( GCache.Exec					(Cmd,Ar) ) return 1;
	if( GExec   && GExec->Exec      (Cmd,Ar) ) return 1;
	if( Client  && Client->Exec		(Cmd,Ar) ) return 1;
	if( Render  && Render->Exec		(Cmd,Ar) ) return 1;
	if( Audio   && Audio->Exec		(Cmd,Ar) ) return 1;

#if DNF
	if( GDnExec && GDnExec->Exec	(Cmd,Ar) ) return 1; // CDH
#endif

	// Handle engine command line.	
	if( ParseCommand(&Cmd,TEXT("FLUSH")) )
	{
		Flush(1);
		Ar.Log( TEXT("Flushed engine caches") );
		return 1;
	}
	else if( ParseCommand(&Cmd,TEXT("CRACKURL")) )
	{
		FURL URL(NULL,Cmd,TRAVEL_Absolute);
		if( URL.Valid )
		{
			Ar.Logf( TEXT("     Protocol: %s"), *URL.Protocol );
			Ar.Logf( TEXT("         Host: %s"), *URL.Host );
			Ar.Logf( TEXT("         Port: %i"), URL.Port );
			Ar.Logf( TEXT("          Map: %s"), *URL.Map );
			Ar.Logf( TEXT("   NumOptions: %i"), URL.Op.Num() );
			for( INT i=0; i<URL.Op.Num(); i++ )
				Ar.Logf( TEXT("     Option %i: %s"), i, *URL.Op(i) );
			Ar.Logf( TEXT("       Portal: %s"), *URL.Portal );
			Ar.Logf( TEXT("       String: '%s'"), **URL.String() );
		}
		else Ar.Logf( TEXT("BAD URL") );
		return 1;
	}
	else return 0;
}

//
// Key handler.
//
UBOOL UEngine::Key( UViewport* Viewport, EInputKey Key )
{
	if (Viewport->Actor && Viewport->Actor->eventKeyType(Key))
		return 1;
	else 
		return Viewport->Console && Viewport->Console->eventKeyType( Key );
}

//
// Input event handler.
//
UBOOL UEngine::InputEvent( UViewport* Viewport, EInputKey iKey, EInputAction State, FLOAT Delta )
{
	// Process it.
	if (Viewport->Actor && Viewport->Actor->eventKeyEvent(iKey, State, Delta))
	{
		return 1;		// Player handled it
	}
	else if( Viewport->Console && Viewport->Console->eventKeyEvent( iKey, State, Delta ) )
	{
		//!! fix for continuous mouse-up events!
		if( State == IST_Release )
			Viewport->Input->PreProcess( iKey, State, Delta );
		// Player console handled it.
		return 1;
	}
	else if
	(	Viewport->Input->PreProcess( iKey, State, Delta )
	&&	Viewport->Input->Process( Viewport->Console ? (FOutputDevice&)*Viewport->Console : *GLog, iKey, State, Delta ) )
	{
		// Input system handled it.
		return 1;
	}
	else
	{
		// Nobody handled it.
		return 0;
	}
}

INT UEngine::ChallengeResponse( INT Challenge )
{
	return 0;
}

/*-----------------------------------------------------------------------------
	UServerCommandlet.
-----------------------------------------------------------------------------*/

class UServerCommandlet : public UCommandlet
{
	DECLARE_CLASS(UServerCommandlet,UCommandlet,CLASS_Transient);
	void StaticConstructor()
	{
		LogToStdout = 1;
		IsClient    = 0;
		IsEditor    = 0;
		IsServer    = 1;
		LazyLoad    = 1;
	}
	INT Main( const TCHAR* Parms )
	{
		// Create the editor class.
		UClass* EngineClass = UObject::StaticLoadClass( UEngine::StaticClass(), NULL, TEXT("ini:Engine.Engine.GameEngine"), NULL, LOAD_NoFail | LOAD_DisallowFiles, NULL );
		UEngine* Engine = ConstructObject<UEngine>( EngineClass );
		Engine->Init();

		// Main loop.
		GIsRunning = 1;
		DOUBLE OldTime = appSeconds();
		DOUBLE SecondStartTime = OldTime;
		INT TickCount = 0;
		while( GIsRunning && !GIsRequestingExit )
		{
			// Update the world.
			DOUBLE NewTime = appSeconds();
			Engine->Tick( NewTime - OldTime );
			OldTime = NewTime;
			TickCount++;
			if( OldTime > SecondStartTime + 1 )
			{
				Engine->CurrentTickRate = (FLOAT)TickCount / (OldTime - SecondStartTime);
				SecondStartTime = OldTime;
				TickCount = 0;
			}

			// Enforce optional maximum tick rate.
			FLOAT MaxTickRate = Engine->GetMaxTickRate();
			if( MaxTickRate>0.0 )
			{
				FLOAT Delta = (1.0/MaxTickRate) - (appSeconds()-OldTime);
				appSleep( Max(0.f,Delta) );
			}
		}
		GIsRunning = 0;
		return 0;
	}
};
IMPLEMENT_CLASS(UServerCommandlet)

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
