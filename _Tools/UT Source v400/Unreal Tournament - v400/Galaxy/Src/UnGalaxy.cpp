/*=============================================================================
	Galaxy.cpp: Unreal audio interface object.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

Revision history:
	* Created by Tim Sweeney.
	- Revision by Carlo Vogelsang.
=============================================================================*/

/*------------------------------------------------------------------------------------
	Dependencies.
------------------------------------------------------------------------------------*/

#define USE_A3D2 1 /* To enable A3D 2.x support */

#pragma warning (disable:4201)
#include <windows.h>
#include <mmsystem.h>
#if USE_A3D2
#include "A3D.h"
#else
#include "Engine.h"
#include "UnRender.h"
#endif
#include "FRiffChunk.h"

#define SUPPORT_EAX  1
#define SUPPORT_EAX2 1
#define SUPPORT_A3D  1
#define SUPPORT_A3D2 1

/*------------------------------------------------------------------------------------
	Galaxy includes.
------------------------------------------------------------------------------------*/

#include "Galaxy.h"

/*------------------------------------------------------------------------------------
	Definitions.
------------------------------------------------------------------------------------*/

//
// Constants.
//
#define MAX_EFFECTS_CHANNELS 32
#define MUSIC_CHANNELS       32
#define EFFECT_FACTOR        1.0

//
// Macros.
//
#define safecall(f) \
{ \
	guard(f); \
	INT Error=f; \
	if( Error ) \
		debugf( NAME_Warning, TEXT("%s failed: %i"), TEXT(#f), Error ); \
	unguard; \
}
#define silentcall(f) \
{ \
	guard(f); \
	f; \
	unguard; \
}

//
// Information about a playing sound.
//
class FPlayingSound
{
public:
	glxVoice*	Channel;
	AActor*		Actor;
	INT			Id;
	UBOOL		Is3D;
	USound*		Sound;
	FVector		Location;
	FLOAT		Volume;
	FLOAT		Radius;
	FLOAT		Pitch;
	FLOAT		Priority;
	FPlayingSound()
	:	Channel	(NULL)
	,	Actor	(NULL)
	,	Id		(0)
	,	Is3D	(0)
	,	Sound	(0)
	,	Priority(0)
	{}
	FPlayingSound( AActor* InActor, INT InId, USound* InSound, FVector InLocation, FLOAT InVolume, FLOAT InRadius, FLOAT InPitch, FLOAT InPriority )
	:	Channel	(NULL)
	,	Actor	(InActor)
	,	Id		(InId)
	,	Is3D    (0)
	,	Sound	(InSound)
	,	Location(InLocation)
	,	Volume	(InVolume)
	,	Radius	(InRadius)
	,	Pitch	(InPitch)
	,	Priority(InPriority)
	{}
};

/*------------------------------------------------------------------------------------
	Memory interface.
------------------------------------------------------------------------------------*/

void* galaxyMalloc( size_t Size )
{
	guard(galaxyMalloc);
	return appMalloc( Size, TEXT("Galaxy malloc") );
	unguard;
}
void* galaxyRealloc( void* Ptr, size_t Size )
{
	guard(galaxyRealloc);
	return appRealloc( Ptr, Size, TEXT("Galaxy realloc") );
	unguard;
}
void galaxyFree( void* Ptr )
{
	guard(galaxyFree);
	appFree( Ptr );
	unguard;
}
//!!glxSetMemInterface( galaxyMalloc, galaxyRealloc, galaxyFree );

/*------------------------------------------------------------------------------------
	Callback interface.
------------------------------------------------------------------------------------*/

int __cdecl galaxyCallback(glxVoice *Voice,void *Param1,int Param2)
{
	if (!Voice)
	{
		if (Param1)
		{
			//Score callback (used internally)
			*((void **)Param1)=NULL;
			return 0;
		}
		else
		{
			//End of music callback
			return 0;
		}
	}
	else
	{
		if ((Param1)&&(Param2))
		{
			//Streaming callback, returns number of bytes actually written
			return Param2; 
		}
		else
		{
			//End of sample callback
			return 0;
		}
	}
}

/*------------------------------------------------------------------------------------
	UGalaxyAudioSubsystem.
------------------------------------------------------------------------------------*/

//
// The Galaxy implementation of UAudioSubsystem.
//
class DLL_EXPORT UGalaxyAudioSubsystem : public UAudioSubsystem
{
	DECLARE_CLASS(UGalaxyAudioSubsystem,UAudioSubsystem,CLASS_Config)

	// Configuration.
	BITFIELD		UseDirectSound;
	BITFIELD		UseFilter;
	BITFIELD		UseSurround;
	BITFIELD		UseStereo;
	BITFIELD		UseCDMusic;
	BITFIELD		UseDigitalMusic;
	BITFIELD		UseReverb;
	BITFIELD		Use3dHardware;
	BITFIELD		ReverseStereo;
	BITFIELD		LowSoundQuality;
	BITFIELD		Initialized;
	FLOAT			AmbientFactor;
	FLOAT			DopplerSpeed;
	INT				Latency;
	INT				EffectsChannels;
	BYTE			OutputRate;
	BYTE			MusicVolume;
	BYTE			SoundVolume;
	UBOOL			AudioStats;
	UBOOL			DetailStats;

	// Variables.
	BITFIELD		ReallyUse3dHardware;
	BITFIELD		ReallyUseA3D2;
	UViewport*		Viewport;
	FPlayingSound	PlayingSounds[MAX_EFFECTS_CHANNELS];
	DOUBLE			LastTime;
	UMusic*			CurrentMusic;
	BYTE			CurrentCDTrack;
	BYTE			CurrentSection;
	glxReverb		CurrentReverb;
	INT				FreeSlot;
	FLOAT			MusicFade;

	// Constructor.
	UGalaxyAudioSubsystem();
	void StaticConstructor();

	// UObject interface.
	void Destroy();
	void PostEditChange();
	void ShutdownAfterError();

	// UAudioSubsystem interface.
	UBOOL Init();
	void SetViewport( UViewport* Viewport );
	UBOOL Exec( const TCHAR* Cmd, FOutputDevice& Ar=*GLog );
	void Update( FPointRegion Region, FCoords& Coords );
	void UnregisterSound( USound* Sound );
	void UnregisterMusic( UMusic* Music );
	UBOOL PlaySound( AActor* Actor, INT Id, USound* Sound, FVector Location, FLOAT Volume, FLOAT Radius, FLOAT Pitch );
	void NoteDestroy( AActor* Actor );
	void RegisterSound( USound* Sound );
	void RegisterMusic( UMusic* Music ) {};
	UBOOL GetLowQualitySetting() {return LowSoundQuality;}
	UViewport* GetViewport();
	void RenderAudioGeometry( FSceneNode* Frame );
	void PostRender( FSceneNode* Frame );

	// Internal functions.
	void SetVolumes();
	void StopSound( INT Index );
	UBOOL IsObstructed( AActor* Actor );
	FPlayingSound* FindActiveSound( INT Id, INT& Index );

	// Inlines.
	glxSample* GetSound( USound* Sound )
	{
		check(Sound);
		if( !Sound->Handle )
			RegisterSound( Sound );
		return (glxSample*)Sound->Handle;
	}
	FLOAT SoundPriority( UViewport* Viewport, FVector Location, FLOAT Volume, FLOAT Radius )
	{
		return Volume * (1.0 - (Location - (Viewport->Actor->ViewTarget?Viewport->Actor->ViewTarget:Viewport->Actor)->Location).Size()/Radius);
	}
};

/*-----------------------------------------------------------------------------
	Class and package registration.
-----------------------------------------------------------------------------*/

IMPLEMENT_CLASS(UGalaxyAudioSubsystem);
IMPLEMENT_PACKAGE(Galaxy);

/*-----------------------------------------------------------------------------
	Sound control.
-----------------------------------------------------------------------------*/

UGalaxyAudioSubsystem::UGalaxyAudioSubsystem()
{
	guard(UGalaxyAudioSubsystem::UGalaxyAudioSubsystem);

	// Set variables.
	MusicFade			= 1.0;
	CurrentCDTrack		= 255;
	LastTime			= appSeconds();

	unguard;
}

//
// Static class initializer.
//
void UGalaxyAudioSubsystem::StaticConstructor()
{
	guard(UGalaxyAudioSubsystem::StaticConstructor);

	UEnum* OutputRates = new( GetClass(), TEXT("OutputRates") )UEnum( NULL );
		new( OutputRates->Names )FName( TEXT("8000Hz" ) );
		new( OutputRates->Names )FName( TEXT("11025Hz") );
		new( OutputRates->Names )FName( TEXT("16000Hz") );
		new( OutputRates->Names )FName( TEXT("22050Hz") );
		new( OutputRates->Names )FName( TEXT("32000Hz") );
		new( OutputRates->Names )FName( TEXT("44100Hz") );
		new( OutputRates->Names )FName( TEXT("48000Hz") );
	new(GetClass(),TEXT("UseDirectSound"),  RF_Public)UBoolProperty  (CPP_PROPERTY(UseDirectSound ), TEXT("Audio"), CPF_Config );
	new(GetClass(),TEXT("UseFilter"),       RF_Public)UBoolProperty  (CPP_PROPERTY(UseFilter      ), TEXT("Audio"), CPF_Config );
	new(GetClass(),TEXT("UseSurround"),     RF_Public)UBoolProperty  (CPP_PROPERTY(UseSurround    ), TEXT("Audio"), CPF_Config );
	new(GetClass(),TEXT("UseStereo"),       RF_Public)UBoolProperty  (CPP_PROPERTY(UseStereo      ), TEXT("Audio"), CPF_Config );
	new(GetClass(),TEXT("UseCDMusic"),      RF_Public)UBoolProperty  (CPP_PROPERTY(UseCDMusic     ), TEXT("Audio"), CPF_Config );
	new(GetClass(),TEXT("UseDigitalMusic"), RF_Public)UBoolProperty  (CPP_PROPERTY(UseDigitalMusic), TEXT("Audio"), CPF_Config );
	new(GetClass(),TEXT("UseReverb"),       RF_Public)UBoolProperty  (CPP_PROPERTY(UseReverb      ), TEXT("Audio"), CPF_Config );
	new(GetClass(),TEXT("Use3dHardware"),   RF_Public)UBoolProperty  (CPP_PROPERTY(Use3dHardware  ), TEXT("Audio"), CPF_Config );
	new(GetClass(),TEXT("ReverseStereo"),   RF_Public)UBoolProperty  (CPP_PROPERTY(ReverseStereo  ), TEXT("Audio"), CPF_Config );
	new(GetClass(),TEXT("LowSoundQuality"), RF_Public)UBoolProperty  (CPP_PROPERTY(LowSoundQuality), TEXT("Audio"), CPF_Config );
	new(GetClass(),TEXT("Latency"),         RF_Public)UIntProperty   (CPP_PROPERTY(Latency        ), TEXT("Audio"), CPF_Config );
	new(GetClass(),TEXT("OutputRate"),      RF_Public)UByteProperty  (CPP_PROPERTY(OutputRate     ), TEXT("Audio"), CPF_Config, OutputRates );
	new(GetClass(),TEXT("EffectsChannels"), RF_Public)UIntProperty   (CPP_PROPERTY(EffectsChannels), TEXT("Audio"), CPF_Config );
	new(GetClass(),TEXT("MusicVolume"),     RF_Public)UByteProperty  (CPP_PROPERTY(MusicVolume    ), TEXT("Audio"), CPF_Config );
	new(GetClass(),TEXT("SoundVolume"),     RF_Public)UByteProperty  (CPP_PROPERTY(SoundVolume    ), TEXT("Audio"), CPF_Config );
	new(GetClass(),TEXT("AmbientFactor"),   RF_Public)UFloatProperty (CPP_PROPERTY(AmbientFactor  ), TEXT("Audio"), CPF_Config );
	new(GetClass(),TEXT("DopplerSpeed"),    RF_Public)UFloatProperty (CPP_PROPERTY(DopplerSpeed   ), TEXT("Audio"), CPF_Config );

	unguard;
}

UBOOL UGalaxyAudioSubsystem::Init()
{
	guard(UGalaxyAudioSubsystem::Init);

	// Prevent A3D splash screen.
	guard(ShutUpA3DSplashScreen);
	#define REG_SETTINGS_KEY			TEXT("Software\\Aureal\\A3D")
	#define REG_SETTING_SPLASH_SCREEN   TEXT("SplashScreen")
	#define REG_SETTING_SPLASH_AUDIO    TEXT("Splashaudio")
	HKEY hReg;
	DWORD dwCreateDisposition;
	if( ERROR_SUCCESS==RegCreateKeyEx(HKEY_LOCAL_MACHINE, REG_SETTINGS_KEY, 0, NULL, 0, KEY_WRITE, NULL, &hReg, &dwCreateDisposition) )
	{
		DWORD dwVal=0;
		RegSetValueEx( hReg, REG_SETTING_SPLASH_SCREEN, 0, REG_DWORD, (LPBYTE)&dwVal, sizeof(DWORD) );
		RegSetValueEx( hReg, REG_SETTING_SPLASH_AUDIO, 0, REG_DWORD, (LPBYTE)&dwVal, sizeof(DWORD) );
		RegCloseKey( hReg );
	}
	unguard;
	
	// Preinit checks.
	check(GLX_TOTALVOICES>=64);
	check(MAX_EFFECTS_CHANNELS+MUSIC_CHANNELS<=GLX_TOTALVOICES);

	// Initialize Galaxy.
	guard(glxInit);
	verify(glxInit()==0);
	unguard;

	// Set Galaxy callback.
	guard(glxSetCallback);
	verify(glxSetCallback((glxCallback *)galaxyCallback)==GLXERR_NOERROR);
	unguard;

	// Handle modes.
	if( !GIsMMX )
		glxMMXFound = 0;
	if( !GIsKatmai )
		glxKNIFound = 0;
	if( !GIs3DNow )
		glxK3DFound = 0;

	// Clear reverb structure
	memset( &CurrentReverb, 0, sizeof(CurrentReverb) );

	// Allocate channels for sound effects.
	guard(glxAllocateEffectChannels);
    verify(glxSetSampleVoices( EffectsChannels )!=0);
	unguard;

	// Detect hardware.
	guard(glxDetectOutput);
    if
	(	UseDirectSound
	&& !ParseParam(appCmdLine(), TEXT("nodsound"))
	&& !GIsEditor
	&&	glxDetectOutput(GLX_DIRECTSOUND,0)==GLXERR_NOERROR )
		debugf( NAME_Init, TEXT("Galaxy is using DirectSound") );
	else
		debugf( NAME_Init, TEXT("Galaxy is using WinMM") );
	unguard;

	// Handle 3d sound.
	if( glxAudioOutput.Type==GLX_A3D2 )
	{
		debugf( NAME_Init, TEXT("Aureal A3D 2.x 3D sound hardware found!") );
		ReallyUseA3D2 = ReallyUse3dHardware = Use3dHardware && SUPPORT_A3D2 && !ParseParam(appCmdLine(),TEXT("no3dsound"));
	}
	if( glxAudioOutput.Type==GLX_A3D )
	{
		debugf( NAME_Init, TEXT("Aureal A3D 1.x 3D sound hardware found!") );
		ReallyUse3dHardware = Use3dHardware && SUPPORT_A3D && !ParseParam(appCmdLine(),TEXT("no3dsound"));
	}
	if( glxAudioOutput.Type==GLX_EAX2 )
	{
		debugf( NAME_Init, TEXT("EAX 2.x sound hardware found!") );
		ReallyUse3dHardware = Use3dHardware && SUPPORT_EAX2 && !ParseParam(appCmdLine(),TEXT("no3dsound"));
	}
	if( glxAudioOutput.Type==GLX_EAX )
	{
		debugf( NAME_Init, TEXT("EAX 1.x sound hardware found!") );
		ReallyUse3dHardware = Use3dHardware && SUPPORT_EAX && !ParseParam(appCmdLine(),TEXT("no3dsound"));
	}

	// Set initialized flag.
	USound::Audio = this;
	UMusic::Audio = this;
	Initialized = 1;

	debugf( NAME_Init, TEXT("Galaxy initialized") );
	return 1;
	unguard;
}

void UGalaxyAudioSubsystem::PostEditChange()
{
	guard(UGalaxyAudioSubsystem::PostEditChange);

	// Validate configurable variables.
	OutputRate      = Clamp(OutputRate,(BYTE)0,(BYTE)6);
	Latency         = Clamp(Latency,10,250);
	EffectsChannels = Clamp(EffectsChannels,0,MAX_EFFECTS_CHANNELS);
	DopplerSpeed    = Clamp(DopplerSpeed,1.f,100000.f);
	AmbientFactor   = Clamp(AmbientFactor,0.f,10.f);
	SetVolumes();

	unguard;
}

void UGalaxyAudioSubsystem::SetViewport( UViewport* InViewport )
{
	guard(UGalaxyAudioSubsystem::SetViewport);
	debugf( NAME_DevAudio, TEXT("Galaxy SetViewport: %s"), InViewport ? InViewport->GetName() : TEXT("NULL") );

	// Stop all playing sounds.
	for( INT i=0; i<EffectsChannels; i++ )
		StopSound( i );

	// Remember the viewport.
	if( Viewport != InViewport )
	{
		if( Viewport )
		{
			// Unregister everything.
			for( TObjectIterator<UMusic> MusicIt; MusicIt; ++MusicIt )
				if( MusicIt->Handle )
					UnregisterMusic( *MusicIt );

			// Shut down Galaxy.
			safecall(glxStopOutput());
		}
		Viewport = InViewport;
		if( Viewport )
		{
			// Figure out startup parameters.
			DWORD OutputMode = GLX_16BIT;
			if( UseFilter )
				OutputMode |= GLX_COSINE;
			if( UseStereo )
				OutputMode |= GLX_STEREO;
			if( ReallyUse3dHardware )
				OutputMode |= GLX_3DAUDIO;
			else
				OutputMode |= GLX_2DAUDIO;
			if( Viewport->Actor->Song && Viewport->Actor->Transition==MTRAN_None )
				Viewport->Actor->Transition = MTRAN_Instant;

			// Start sound output.
			guard(glxStartOutput);
			check(Viewport->GetWindow());
			INT Rates[] = {8000,11025,16000,22050,32000,44100,48000};
			INT Rate = Rates[OutputRate];
			INT Result;
			try
			{
				if( UseDirectSound )
				{
					Result = glxStartOutput( Viewport->GetWindow(), Rate, OutputMode, Latency );
#if USE_A3D2
					if( Result==GLXERR_NOERROR && ReallyUseA3D2 )
						A3D_UnrealInit( (LPIA3D3)glxAudioOutput.Extensions, (LPA3DLISTENER)glxAudioOutput.Listener );
#endif
				}
				else Result = glxStartOutput( NULL, Rate, OutputMode, Latency );
			}
			catch( ... )
			{
				Result = -1;
			}
			if( Result!=GLXERR_NOERROR )
			{
				// Initialization failed.
				debugf( NAME_Init, TEXT("Safely failed to initialize Galaxy: %i"), Result );
				Viewport = NULL;
				return;
			}
			unguard;
			glxSetSampleReverb( &CurrentReverb );
			SetVolumes();
		}

		// Register sounds.
		for( TObjectIterator<USound> It; It; ++It )
			RegisterSound(*It);
	}
	unguard;
}

UViewport* UGalaxyAudioSubsystem::GetViewport()
{
	guard(UGalaxyAudioSubsystem::GetViewport);
	return Viewport;
	unguard;
}

void UGalaxyAudioSubsystem::SetVolumes()
{
	guard(UGalaxyAudioSubsystem::SetVolumes);

	// Normalize the volumes.
	FLOAT NormSoundVolume = SoundVolume/255.0;
	FLOAT NormMusicVolume = Clamp(MusicVolume/255.0,0.0,1.0);

	// Set music and effects volumes.
	verify(glxSetSampleVolume(127*NormSoundVolume,GLX_VOLSET)==0);
	if( UseDigitalMusic )
		verify(glxSetMusicVolume(127*NormMusicVolume*Max(MusicFade,0.f),GLX_VOLSET)==0);
	if( UseCDMusic )
		glxSetCDAudioVolume(127*NormMusicVolume*Max(MusicFade,0.f),GLX_VOLSET);

	unguard;
}

void UGalaxyAudioSubsystem::Destroy()
{
	guard(UGalaxyAudioSubsystem::Destroy);
	if( Initialized )
	{
		// Unhook.
		USound::Audio = NULL;
		UMusic::Audio = NULL;

		// Shut down viewport.
		SetViewport( NULL );

		// Stop CD.
		if( UseCDMusic && CurrentCDTrack!=255 )
			glxStopCDAudio();

#if USE_A3D2
		//	Kill geometry.
		if( ReallyUseA3D2 )
			A3D_UnrealDestroy();
#endif

		// Deinitialize sound.
		safecall(glxDeinit());

		debugf( NAME_Exit, TEXT("Galaxy shut down") );
	}
	Super::Destroy();
	unguard;
}

void UGalaxyAudioSubsystem::ShutdownAfterError()
{
	guard(UGalaxyAudioSubsystem::ShutdownAfterError);

	// Unhook.
	USound::Audio = NULL;
	UMusic::Audio = NULL;

	// Safely shut down.
	debugf( NAME_Exit, TEXT("UGalaxyAudioSubsystem::ShutdownAfterError") );
	safecall(glxStopOutput());
	if( Viewport )
		safecall(glxDeinit());
	Super::ShutdownAfterError();
	unguard;
}

/*-----------------------------------------------------------------------------
	Sound and music registration.
-----------------------------------------------------------------------------*/

void UGalaxyAudioSubsystem::RegisterSound( USound* Sound )
{
	guard(UGalaxyAudioSubsystem::RegisterSound);
	checkSlow(Sound);
	if( !Sound->Handle )
	{
		// Temporarily set the handle to avoid reentrance.
		Sound->Handle = (void*)-1;

		// Load the data.
		Sound->Data.Load();
		debugf( NAME_DevSound, TEXT("Register sound: %s (%i)"), Sound->GetPathName(), Sound->Data.Num() );
		check(Sound->Data.Num()>0);

		// Register the sound.
		guard(glxLoadSample);
		glxMemory Mem;
		Mem.FourCC   = GLX_FOURCC_MEMO;
		Mem.Size     = sizeof(Mem)-8;
		Mem.Length   = Sound->Data.Num();
		Mem.DataPos  = 0;
		Mem.Data     = &Sound->Data(0);
		Sound->Handle = glxLoadSample( &Mem, GLX_LOADFROMMEMORY );
		if( !Sound->Handle )
			appErrorf( TEXT("Invalid sound format in %s"), Sound->GetFullName() );
		unguardf(( TEXT("(%i)"), Sound->Data.Num() ));

		// Scrap the source data we no longer need.
		Sound->Data.Unload();
	}
	unguard;
}
void UGalaxyAudioSubsystem::UnregisterSound( USound* Sound )
{
	guard(UGalaxyAudioSubsystem::UnregisterSound);
	check(Sound);
	if( Sound->Handle )
	{
		debugf( NAME_DevSound, TEXT("Unregister sound: %s"), Sound->GetFullName() );

		// Shut it up.
		for( INT i=0; i<EffectsChannels; i++ )
			if( PlayingSounds[i].Sound==Sound )
				StopSound( i );

		// Unload from Galaxy.
		safecall(glxUnloadSample( (glxSample*)Sound->Handle ));
	}
	unguard;
}
void UGalaxyAudioSubsystem::UnregisterMusic( UMusic* Music )
{
	guard(UGalaxyAudioSubsystem::UnregisterMusic);
	check(Music);
	if( Music->Handle )
	{
		check(Music==CurrentMusic);
		debugf( NAME_DevMusic, TEXT("Unregister music: %s"), Music->GetFullName() );

		// Stop the current music, if it's playing (may return failure code).
		guard(glxStopMusic);
		glxStopMusic();
		unguard;

		// Unload the current music.
		guard(glxUnloadMusic);
		safecall(glxUnloadMusic());
		unguard;

		// Disown.
		Music->Handle = NULL;
	}
	if( CurrentMusic==Music )
	{
		// Don't reference destroyed music.
		CurrentMusic = NULL;
	}
	unguard;
}

/*-----------------------------------------------------------------------------
	Command line.
-----------------------------------------------------------------------------*/

// Recording experimentation.
//note: 16-bit sound is signed words; 8-bit sound is unsigned bytes
HWAVEIN hWaveIn=NULL;
WAVEFORMATEX WaveInFormat;
WAVEHDR WaveInHeader;
BYTE WaveInBuffer[65536];
UBOOL UGalaxyAudioSubsystem::Exec( const TCHAR* Cmd, FOutputDevice& Ar )
{
	guard(UGalaxyAudioSubsystem::Exec);
	if( Viewport && ParseCommand( &Cmd, TEXT("CDTRACK")) )
	{
		INT i = appAtoi(Cmd);
		Ar.Logf( TEXT("CD Track %i"), i );
		Viewport->Actor->CdTrack = i;
		Viewport->Actor->Transition = MTRAN_Instant;
		return 1;
	}
	else if( ParseCommand( &Cmd, TEXT("CDVOLUME")) )
	{
		glxSetCDAudioVolume(127*appAtof(Cmd),GLX_VOLSET);
		return 1;
	}
	else if( CurrentMusic && ParseCommand( &Cmd, TEXT("MUSICORDER")) )
	{
		INT i = appAtoi(Cmd);
		Ar.Logf( TEXT("Galaxy order %i"), i );
		glxControlMusic( GLX_SETPOSITION, i );
		return 1;
	}
	else if( ParseCommand(&Cmd,TEXT("RECORDSOUND")) )
	{
		// RIFF reading test.
		//FRiffChunk_WAVE* Wave = LoadRiffFile<FRiffChunk_WAVE>( TEXT("\\unreal\\botpack\\sounds\\ctf\\ctf1.wav") );
		//check(Wave);
		//verify(SaveRiffFile( Wave, TEXT("tmp.wav") ));
		//delete Wave;

		// Recording experimentation.
		appMemzero( &WaveInFormat, sizeof(WaveInFormat) );
		WaveInFormat.wFormatTag			= WAVE_FORMAT_PCM;//from mmreg.h
		WaveInFormat.nChannels			= 1;
		WaveInFormat.nSamplesPerSec		= 8000;
		WaveInFormat.wBitsPerSample		= 16;
		WaveInFormat.nBlockAlign		= WaveInFormat.nChannels * WaveInFormat.wBitsPerSample / 8;
		WaveInFormat.nAvgBytesPerSec	= WaveInFormat.nSamplesPerSec * WaveInFormat.nBlockAlign;
		WaveInFormat.cbSize				= 0;
		verify(waveInOpen( &hWaveIn, WAVE_MAPPER, &WaveInFormat, NULL, NULL, CALLBACK_NULL )==MMSYSERR_NOERROR);
		check(hWaveIn);
		appMemzero( &WaveInHeader, sizeof(WaveInHeader) );
		WaveInHeader.lpData				= (char*)WaveInBuffer;
		WaveInHeader.dwBufferLength		= sizeof(WaveInBuffer);
		WaveInHeader.dwFlags			= 0;
		verify(waveInPrepareHeader(hWaveIn,&WaveInHeader,sizeof(WaveInHeader))==MMSYSERR_NOERROR);
		verify(waveInAddBuffer(hWaveIn,&WaveInHeader,sizeof(WaveInHeader))==MMSYSERR_NOERROR);
		verify(waveInStart(hWaveIn)==MMSYSERR_NOERROR);
		debugf(TEXT("RecordSound begin"));
		return 1;
	}
	else if( ParseCommand(&Cmd,TEXT("ENDRECORDSOUND")) )
	{
		// Recording experimentation.
		if( hWaveIn )
		{
			// Stop recording.
			verify(waveInReset(hWaveIn)==MMSYSERR_NOERROR);
			verify(waveInStop(hWaveIn)==MMSYSERR_NOERROR);
			INT Samples = WaveInHeader.dwBytesRecorded*8/WaveInFormat.wBitsPerSample;
			debugf(TEXT("RecordSound end (%i samples)"),Samples);

			// Reset recording.
			verify(waveInUnprepareHeader(hWaveIn,&WaveInHeader,sizeof(WaveInHeader))==MMSYSERR_NOERROR);
			verify(waveInClose(hWaveIn)==MMSYSERR_NOERROR);
			hWaveIn=NULL;

			// carlo: 1-bit sound ... 
			// mek: eliminate blank space.
			// mek: auto record option, recognize noies.
			SWORD* W = (SWORD*)WaveInBuffer;
			long Step=1*256;
			long Amp=0,Error=0;
			for( INT i=3; i<Samples; i++ )
			{
				if (((W[i-3]<W[i-2])&&(W[i-2]<W[i-1]))||((W[i-3]>W[i-2])&&(W[i-2]>W[i-1])))
					Step=(Step*3)/2;
				else 
					Step=(Step*2)/3;

				Step = Clamp ((long)Step, (long)(2*128), (long)(16*128));
			
				if (Amp<(W[i]+Error)) 
					Amp+=Step;
				else
					Amp-=Step;
				
				Amp = Clamp ((long)Amp, (long)-32768, (long)32767);
				Error = W[i]-Amp;
				W[i] = Amp;

//				debugf( TEXT("Amp : %i"),Amp);
//				debugf( TEXT("Error : %i"),Error);
//				debugf( TEXT("Step : %i\n"),Step);

//				W[i] = W[i+1] = This<Next ? 0x4000 : 0;
			}
			//Get rid of Fs/2 noise.. (1 pole IIR)
			float a=0.6f;
			for (INT j=3;j<Samples;j++)
				W[j]=(W[j]*(1.0f-a)+W[j-1]*a);

			// Save to disk file.
			FRiffChunk_fmt* FmtChunk   = new FRiffChunk_fmt;
			appMemcpy( &FmtChunk->wFormatTag, &WaveInFormat, sizeof(WAVEFORMATEX) );

			FRiffChunk_data* DataChunk = new FRiffChunk_data;
			DataChunk->Bits.Add( WaveInHeader.dwBytesRecorded );
			appMemcpy( &DataChunk->Bits(0), WaveInBuffer, DataChunk->Bits.Num() );

			FRiffChunk_WAVE* WaveChunk = new FRiffChunk_WAVE;
			WaveChunk->SubChunks.AddItem( FmtChunk );
			WaveChunk->SubChunks.AddItem( DataChunk );

			SaveRiffFile( WaveChunk, TEXT("Test.wav") );

			// Play Galaxy sound.
			if( Viewport && Samples )
			{
				USound* Sound = new USound;
				//FBufferWriter Writer( Sound->Data );
				//WaveChunk->Save( Writer );
				if( appLoadFileToArray( Sound->Data, TEXT("Test.wav") ) )
					PlaySound( Viewport->Actor, 2*SLOT_Misc, Sound, Viewport->Actor->Location, 1000.0, 4096.0, 1.0 );
			}
		}
		return 1;
	}
	else if( ParseCommand(&Cmd,TEXT("ASTAT")) )
	{
		if( ParseCommand(&Cmd,TEXT("Audio")) )
		{
			AudioStats ^= 1;
			return 1;
		}
		if( ParseCommand(&Cmd,TEXT("Detail")) )
		{
			DetailStats ^= 1;
			return 1;
		}
		return 1;
	}
#if USE_A3D2
	else if( ReallyUseA3D2 && A3D_Exec(Cmd, Ar, 1) )
	{
		return 1;
	}
#endif
	else return 0;
	unguard;
}

/*-----------------------------------------------------------------------------
	Internal functions.
-----------------------------------------------------------------------------*/

//
// Stop an active sound effect.
//
void UGalaxyAudioSubsystem::StopSound( INT Index )
{
	guard(UGalaxyAudioSubsystem::StopSound);
	FPlayingSound& Playing = PlayingSounds[Index];

	//debugf( "Stop %s", Actives(Index).Sound->GetName() );
	if( Playing.Channel )
	{
		guard(StopSample);
		if( Playing.Is3D ) 
			glxStopSample3D( Playing.Channel );
		else
			glxStopSample( Playing.Channel );
		unguard;
	}
	PlayingSounds[Index] = FPlayingSound();

	unguard;
}

//
// Do occlusion check
//
UBOOL UGalaxyAudioSubsystem::IsObstructed( AActor* Actor )
{
	return Viewport->Actor->XLevel->Model->FastLineCheck(Viewport->Actor->Location,Actor->Location)==0;
}

/*-----------------------------------------------------------------------------
	Sound playing.
-----------------------------------------------------------------------------*/

UBOOL UGalaxyAudioSubsystem::PlaySound
(
	AActor*	Actor,
	INT		Id,
	USound*	Sound,
	FVector	Location,
	FLOAT	Volume,
	FLOAT	Radius,
	FLOAT	Pitch
)
{
	guard(UGalaxyAudioSubsystem::StartSound);
	check(Radius);
	if( !Viewport || !Sound )
		return 0;

	// Allocate a new slot if requested.
	if( (Id&14)==2*SLOT_None )
		Id = 16 * --FreeSlot;

	// Compute priority.
	FLOAT Priority = SoundPriority( Viewport, Location, Volume, Radius );

	// If already playing, stop it.
	INT   Index        = -1;
	FLOAT BestPriority = Priority;
	for( INT i=0; i<EffectsChannels; i++ )
	{
		FPlayingSound& Playing = PlayingSounds[i];
		if( (Playing.Id&~1)==(Id&~1) )
		{
			// Skip if not interruptable.
			if( Id&1 )
				return 0;

			// Stop the sound.
			Index = i;
			break;
		}
		else if( Playing.Priority<=BestPriority )
		{
			Index = i;
			BestPriority = Playing.Priority;
		}
	}

	// If no sound, or its priority is overruled, stop it.
	if( Index==-1 )
		return 0;

	// Put the sound on the play-list.
	StopSound( Index );
	if( Sound!=(USound*)-1 )
		PlayingSounds[Index] = FPlayingSound( Actor, Id, Sound, Location, Volume, Radius, Pitch, Priority );
	return 1;

	unguard;
}

void UGalaxyAudioSubsystem::NoteDestroy( AActor* Actor )
{
	guard(UGalaxyAudioSubsystem::NoteDestroy);
	check(Actor);
	check(Actor->IsValid());

	// Stop referencing actor.
	for( INT i=0; i<EffectsChannels; i++ )
	{
		if( PlayingSounds[i].Actor==Actor )
		{
			if( (PlayingSounds[i].Id&14)==SLOT_Ambient*2 )
			{
				// Stop ambient sound when actor dies.
				StopSound( i );
			}
			else
			{
				// Unbind regular sounds from actors.
				PlayingSounds[i].Actor = NULL;
			}
		}
	}

	unguard;
}

/*-----------------------------------------------------------------------------
	Give the audio a chance to deal with the listener's geometry.
-----------------------------------------------------------------------------*/

void UGalaxyAudioSubsystem::RenderAudioGeometry( FSceneNode* Frame )
{
	guard(UGalaxyAudioSubsystem::RenderAudioGeometry);
#if USE_A3D2
	if( ReallyUseA3D2 )
		A3D_RenderAudioGeometry( Frame );
#endif
	unguard;
}

/*-----------------------------------------------------------------------------
	Stats
-----------------------------------------------------------------------------*/

void UGalaxyAudioSubsystem::PostRender( FSceneNode* Frame )
{
	guard(UGalaxyAudioSubsystem::PostRender);

	Frame->Viewport->Canvas->Color = FColor(255,255,255);
	if( AudioStats )
	{
		Frame->Viewport->Canvas->CurX=0;
		Frame->Viewport->Canvas->CurY=16;
		Frame->Viewport->Canvas->WrappedPrintf
		(
			Frame->Viewport->Canvas->SmallFont,
			0, TEXT("GalaxyAudioSubsystem Statistics")
		);
		for (INT i=0; i<EffectsChannels; i++)
		{
			if (PlayingSounds[i].Channel)
			{
				INT Factor;
				if (DetailStats)
					Factor = 16;
				else
					Factor = 8;
					
				// Current Sound.
				Frame->Viewport->Canvas->CurX=10;
				Frame->Viewport->Canvas->CurY=24 + Factor*i;
				Frame->Viewport->Canvas->WrappedPrintf
				( Frame->Viewport->Canvas->SmallFont, 0, TEXT("Channel %2i: %s"),
					i, PlayingSounds[i].Sound->GetFullName() );

				if (DetailStats)
				{
					// Play meter.
					Frame->Viewport->Canvas->CurX=10;
					Frame->Viewport->Canvas->CurY=32 + Factor*i;
					Frame->Viewport->Canvas->WrappedPrintf
					( Frame->Viewport->Canvas->SmallFont, 0, TEXT("  Vol: %05.2f Pitch: %05.2f Radius: %07.2f Priority: %05.2f"),
						PlayingSounds[i].Volume, PlayingSounds[i].Pitch, PlayingSounds[i].Radius, PlayingSounds[i].Priority);
				}
			} else {
				INT Factor;
				if (DetailStats)
					Factor = 16;
				else
					Factor = 8;
					
				Frame->Viewport->Canvas->CurX=10;
				Frame->Viewport->Canvas->CurY=24 + Factor*i;
				if (i >= 10)
					Frame->Viewport->Canvas->WrappedPrintf
					( Frame->Viewport->Canvas->SmallFont, 0, TEXT("Channel %i:  None"),
						i );
				else
					Frame->Viewport->Canvas->WrappedPrintf
					( Frame->Viewport->Canvas->SmallFont, 0, TEXT("Channel %i: None"),
						i );

				if (DetailStats)
				{
					// Play meter.
					Frame->Viewport->Canvas->CurX=10;
					Frame->Viewport->Canvas->CurY=32 + Factor*i;
					Frame->Viewport->Canvas->WrappedPrintf
					( Frame->Viewport->Canvas->SmallFont, 0, TEXT("  ...") );
				}
			}
		}
	}

	unguard;
}

/*-----------------------------------------------------------------------------
	Timer update.
-----------------------------------------------------------------------------*/

//
// Update all active sound effects.
//
void UGalaxyAudioSubsystem::Update( FPointRegion Region, FCoords& Coords )
{
	guard(UGalaxyAudioSubsystem::Update);
	if( !Viewport )
		return;

	// Lock Galaxy so that all sound starting is synched.
	glxLock();

	// Get time passed.
	DOUBLE DeltaTime = appSeconds() - LastTime;
	LastTime += DeltaTime;
	DeltaTime = Clamp( DeltaTime, 0.0, 1.0 );

	// Update A3D.
#if USE_A3D2
	if( ReallyUseA3D2 )
		A3D_Update( Coords );
#endif

	AActor *ViewActor = Viewport->Actor->ViewTarget?Viewport->Actor->ViewTarget:Viewport->Actor;

	// See if any new ambient sounds need to be started.
	UBOOL Realtime = Viewport->IsRealtime() && Viewport->Actor->Level->Pauser==TEXT("");
	if( Realtime )
	{
		guard(StartAmbience);
		for( INT i=0; i<Viewport->Actor->GetLevel()->Actors.Num(); i++ )
		{
			AActor* Actor = Viewport->Actor->GetLevel()->Actors(i);
			if
			(	Actor
			&&	Actor->AmbientSound
			&&	FDistSquared(ViewActor->Location,Actor->Location)<=Square(Actor->WorldSoundRadius()) )
			{
				INT Id = Actor->GetIndex()*16+SLOT_Ambient*2;
				for( INT j=0; j<EffectsChannels; j++ )
					if( PlayingSounds[j].Id==Id )
						break;
				if( j==EffectsChannels )
				{
					//debugf( "Start ambient %s (%s)", Actor->AmbientSound->GetName(), Actor->GetFullName() );
					PlaySound( Actor, Id, Actor->AmbientSound, Actor->Location, AmbientFactor*Actor->SoundVolume/255.0, Actor->WorldSoundRadius(), Actor->SoundPitch/64.0 );
				}
			}
		}
		unguard;
	}

	// Update all playing ambient sounds.
	guard(UpdateAmbience);
	for( INT i=0; i<EffectsChannels; i++ )
	{
		FPlayingSound& Playing = PlayingSounds[i];
		if( (Playing.Id&14)==SLOT_Ambient*2 )
		{
			check(Playing.Actor);
			if
			(	FDistSquared(ViewActor->Location,Playing.Actor->Location)>Square(Playing.Actor->WorldSoundRadius())
			||	Playing.Actor->AmbientSound!=Playing.Sound 
			||  !Realtime )
			{
				// Ambient sound went out of range.
				StopSound( i );
				//debugf( "Stop ambient out" );
			}
			else
			{
				// Update basic sound properties.
				FLOAT Brightness = 2.0 * (AmbientFactor*Playing.Actor->SoundVolume/255.0);
				if( Playing.Actor->LightType!=LT_None )
				{
					FPlane Color;
					Brightness *= Playing.Actor->LightBrightness/255.0;
					Viewport->GetOuterUClient()->Engine->Render->GlobalLighting( (Viewport->Actor->ShowFlags & SHOW_PlayerCtrl)!=0, Playing.Actor, Brightness, Color );
				}
				Playing.Volume = Brightness;
				Playing.Radius = Playing.Actor->WorldSoundRadius();
				Playing.Pitch  = Playing.Actor->SoundPitch/64.0;
			}
		}
	}
	unguard;

	// Update all active sounds.
	guard(UpdateSounds);
	for( INT Index=0; Index<EffectsChannels; Index++ )
	{
		FPlayingSound& Playing = PlayingSounds[Index];
		if( Playing.Actor )
			check(Playing.Actor->IsValid());
		if( PlayingSounds[Index].Id==0 )
		{
			// Sound is not playing.
			continue;
		}
		else if( Playing.Channel && !glxControlVoice(Playing.Channel,GLX_GETSTATUS,0,0) )
		{
			// Sound is finished.
			StopSound( Index );
		}
		else
		{
			// Update positioning from actor, if available.
			if( Playing.Actor )
				Playing.Location = Playing.Actor->Location;

			// Update the priority.
			Playing.Priority = SoundPriority( Viewport, Playing.Location, Playing.Volume, Playing.Radius );

			// Compute the spatialization.
			FVector Location = Playing.Location.TransformPointBy( Coords );
			FLOAT   PanAngle = appAtan2(Location.X, Abs(Location.Z));

			// Despatialize sounds when you get real close to them.
			FLOAT CenterDist  = 0.1*Playing.Radius;
			FLOAT Size        = Location.Size();
			if( Location.SizeSquared() < Square(CenterDist) )
				PanAngle *= Size / CenterDist;

			// Compute panning and volume.
			INT     GlxPan      = Clamp( (INT)(GLX_MAXSMPPANNING/2 + PanAngle*GLX_MAXSMPPANNING*7/8/PI), 0, GLX_MAXSMPPANNING );
			FLOAT   Attenuation = Clamp(1.0-Size/Playing.Radius,0.0,1.0);
			INT     GlxVolume   = Clamp( (INT)(GLX_MAXSMPVOLUME * Playing.Volume * Attenuation * EFFECT_FACTOR), 0, GLX_MAXSMPVOLUME );
			if( ReverseStereo )
				GlxPan = GLX_MAXSMPPANNING-GlxPan;
			if( Location.Z<0.0 && UseSurround )
				GlxPan = GLX_MIDSMPPANNING | GLX_SURSMPPANNING;

			// Compute ambient sound doppler shifting (doesn't account for player's velocity).
			FLOAT Doppler=1.0;
			if( Playing.Actor && (Playing.Id&14)==SLOT_Ambient*2 )
			{
				FLOAT V = (Playing.Actor->Velocity/*-ViewActor->Velocity*/) | (Playing.Actor->Location - ViewActor->Location).SafeNormal();
				Doppler = Clamp( 1.0 - V/DopplerSpeed, 0.5, 2.0 );
			}

			// Update the sound.
			glxSample* Sample = GetSound(Playing.Sound);
			FVector Z(0,0,0);
			FVector L(Location.X/400.0,Location.Y/400.0,Location.Z/400.0);

			if( Playing.Channel )
			{
				// Update an existing sound.
				guard(ControlSample);
				if( Playing.Is3D ) glxControlSample3D
				(
					Playing.Channel,
					Sample->C4Speed * Playing.Pitch * Doppler,
					GlxVolume,
					(glxVector*)&L,
					(glxVector*)&Z
				);
				else glxControlSample
				(	
					Playing.Channel,
					Sample->C4Speed * Playing.Pitch * Doppler,
					GlxVolume,
					GlxPan
				);
				Playing.Channel->BasePanning = GlxPan;
#if USE_A3D2
				if( ReallyUseA3D2 && Playing.Channel && Playing.Is3D)
					A3D_UpdateSource
					( 
						(LPA3DSOURCE)Playing.Channel->Custom1, 
						FALSE, // Not a new sound
						FALSE  // No transformation needed
					);
#endif
				unguard;
			}
			else
			{
				// Start this new sound.
				guard(StartSample);
				if( ReallyUse3dHardware ) Playing.Channel = glxStartSample3D
				(
					Index+1, 
					Sample, 
					Sample->C4Speed * Playing.Pitch * Doppler, 
					GlxVolume, 
					(glxVector*)&L,
					(glxVector*)&Z,
					GLX_NORMAL
				);
				Playing.Is3D = Playing.Channel!=NULL;
				if( !Playing.Channel ) Playing.Channel = glxStartSample
				(
					Index+1, 
					Sample, 
					Sample->C4Speed * Playing.Pitch * Doppler, 
					GlxVolume, 
					GlxPan, 
					GLX_NORMAL
				);
				check(Playing.Channel);
#if USE_A3D2
				if( ReallyUseA3D2 && Playing.Channel && Playing.Is3D)
					A3D_UpdateSource
					( 
						(LPA3DSOURCE)Playing.Channel->Custom1, 
						TRUE, // New sound
						FALSE // No transformation needed
					);
#endif
				unguard;
			}
		}
	}
	unguard;

	// Handle music transitions.
	guard(UpdateMusic);
	if( Viewport->Actor->Transition!=MTRAN_None )
	{
		UBOOL ChangeMusic = CurrentMusic!=Viewport->Actor->Song;
		/*debugf
		(
			"MTRAN %s %i %s %i -- %i",
			CurrentMusic?CurrentMusic->GetName():"NONE",
			CurrentSection,
			Viewport->Actor->Song?Viewport->Actor->Song->GetName():"NONE",
			Viewport->Actor->SongSection,
			Viewport->Actor->Transition
		);*/
		if( CurrentMusic!=NULL || CurrentCDTrack!=255 )
		{
			// Do music transition.
			UBOOL Ready = 0;
			guard(UpdateStatus);
			if( CurrentSection==255 )
			{
				Ready = 1;
			}
			else if( Viewport->Actor->Transition == MTRAN_Fade )
			{
				MusicFade -= DeltaTime * 1.0;
				Ready = (MusicFade<-1.0*2.0*Latency/1000.f);
			}
			else if( Viewport->Actor->Transition == MTRAN_SlowFade )
			{
				MusicFade -= DeltaTime * 0.2;
				Ready = (MusicFade<-0.2*2.0*Latency/1000.f);
			}
			else if( Viewport->Actor->Transition == MTRAN_FastFade )
			{
				MusicFade -= DeltaTime * 3.0;
				Ready = (MusicFade<-3.0*2.0*Latency/1000.f);
			}
			else
			{
				Ready = 1;
			}
			unguard;
			//debugf("FADING %f ready %i",MusicFade,Ready);

			// Stop old music if done waiting for transition.
			guard(ShutUpMusic);
			if( Ready )
			{
				//debugf("READY");
				if( CurrentMusic && ChangeMusic )
				{
					UnregisterMusic( CurrentMusic );
				}
				if( UseCDMusic && CurrentCDTrack!=255 )
				{
					guard(glxStopCDAudio);
					glxStopCDAudio();
					unguard;
				}
				CurrentMusic   = NULL;
				CurrentCDTrack = 255;
			}
			else
			{
				SetVolumes();
			}
			unguard;
		}
		if( CurrentMusic==NULL && CurrentCDTrack==255 )
		{
			guard(NewMusic);
			MusicFade = 1.0;
			SetVolumes();
			CurrentMusic   = Viewport->Actor->Song;
			CurrentCDTrack = Viewport->Actor->CdTrack;
			CurrentSection = Viewport->Actor->SongSection;
			if( CurrentMusic && UseDigitalMusic )
			{
				// !!memory inefficient - duplicates in memory.
				guard(StartNewMusic);
				if( ChangeMusic )
				{
					debugf( NAME_DevMusic, TEXT("Load music: %s"), CurrentMusic->GetFullName() );
					CurrentMusic->Data.Load();
					CurrentMusic->Data.Add(1024); /* Workaround to carlo reading outside of memory bug!! */
					glxMemory Mem;
					Mem.FourCC   = GLX_FOURCC_MEMO;
					Mem.Size     = sizeof(Mem)-8;
					Mem.Length   = CurrentMusic->Data.Num();
					Mem.DataPos  = 0;
					Mem.Data     = &CurrentMusic->Data(0);
					safecall( glxLoadMusic(&Mem, GLX_LOADFROMMEMORY ));
					CurrentMusic->Handle = (void*)-1;
					CurrentMusic->Data.Unload();
				}
				SetVolumes();
				if( CurrentSection!=255 )
				{
					silentcall(glxStartMusic());
					safecall(glxControlMusic( GLX_SETPOSITION, Viewport->Actor->SongSection ));
				}
				else
				{
					silentcall(glxStopMusic());
				}
				unguardf(( TEXT("(%s)"), CurrentMusic->GetFullName() ));
			}
			if( CurrentCDTrack!=255 && UseCDMusic )
			{
				// Start CD.
				silentcall(glxStartCDAudio( Viewport->Actor->CdTrack,Viewport->Actor->CdTrack ));
			}
			Viewport->Actor->Transition = MTRAN_None;
			unguard;
		}
		/*else
		{
			CurrentSection = 255;
		}*/
	}
	unguard;

	// Update reverb.
	guard(UpdateReverb);
	glxReverb Reverb;
	appMemzero( &Reverb, sizeof(Reverb) );
	if( UseReverb && ViewActor->Region.Zone && ViewActor->Region.Zone->bReverbZone )
	{
		AZoneInfo* ReverbZone = ViewActor->Region.Zone;
		Reverb.Volume     = ReverbZone->MasterGain/255.0;
		Reverb.HFDamp     = Clamp(ReverbZone->CutoffHz,0,44100);//max samp rate
		for( INT i=0; i<ARRAY_COUNT(ReverbZone->Delay); i++ )
		{
			Reverb.Delay[i].Time = Clamp(ReverbZone->Delay[i]/500.0f, 0.001f, 0.340f);
			Reverb.Delay[i].Gain = Clamp(ReverbZone->Gain[i] /255.0f, 0.001f, 0.999f);
		}
	}
	if( memcmp(&CurrentReverb,&Reverb,sizeof(Reverb))!=0 )
	{
		memcpy(&CurrentReverb,&Reverb,sizeof(Reverb));
		safecall(glxSetSampleReverb(&Reverb));
	}
	unguard;

	// Update A3D.
	if( ReallyUseA3D2 && glxAudioOutput.Extensions )
		((LPIA3D3)glxAudioOutput.Extensions)->Flush();

	// Unlock Galaxy.
	glxUnlock();
	unguard;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
