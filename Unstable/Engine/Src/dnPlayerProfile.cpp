//========================================================================================
//	dnPlayerProfile.cpp
//	John Pollard
//		Player Profile support code for script
//========================================================================================
#include "EnginePrivate.h"		// Big momma include
#include "FConfigCacheIni.h"

/*
#ifndef DN_PLAYERPROFILE_H
#define DN_PLAYERPROFILE_H

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __cplusplus
};
#endif

#endif
*/

static TArray<FString>	g_PlayerProfiles;
static UBOOL			g_PlayerProfilesInitialized = false;
static UBOOL			g_DeletedCurrentProfile;

static FString			dnPlayerProfile_CurrentProfile;

FString			g_BuildPlayerBaseDir();
FString			g_BuildPlayerSubDir(const TCHAR *PlayerName);
FString			g_BuildPlayerIniName(const FString PlayerName);
FString			g_BuildPlayerSystemIniName(const FString PlayerName, const FString IniName);
FString			g_BuildProfilePath();
FString			g_GetCurrentProfile();
void			dnPlayerProfile_InitPlayerProfiles();
void			dnPlayerProfile_ResetPlayerProfiles();
UBOOL			dnPlayerProfile_ProfileExists(const TCHAR *PlayerName);
UBOOL			dnPlayerProfile_SelectProfile(const TCHAR *PlayerName, UBOOL WriteToHD);
UBOOL			dnPlayerProfile_CreateProfile(const TCHAR *PlayerName, UBOOL ForceOriginalIni);
FString			dnPlayerProfile_GetSavedProfile(void);
UBOOL			dnPlayerProfile_ResetPlayerProfile(const TCHAR *PlayerName);

#define TEMP_PROFILE		TEXT("DukeTemp")

#define PACKAGE_NAME		TEXT("DukeForever")

#define ORIGINAL_SYSTEM_INI	(FString(appBaseDir()) + PATH_SEPARATOR TEXT("Default.ini"))
#define ORIGINAL_USER_INI	(FString(appBaseDir()) + PATH_SEPARATOR TEXT("DefUser.ini"))

//========================================================================================
//	g_BuildPlayerBaseDir
//========================================================================================
FString g_BuildPlayerBaseDir()
{
	// Go up a directory into the root ("c:\Duke4\Players" for example)
	return FString(appBaseDir()) + TEXT("..") PATH_SEPARATOR TEXT("Players");
}

//========================================================================================
//	g_BuildPlayerSubDir
//========================================================================================
FString g_BuildPlayerSubDir(const TCHAR *PlayerName)
{
	// ("c:\Duke4\Players\PlayerName" for example)
	return g_BuildPlayerBaseDir() + PATH_SEPARATOR + PlayerName;
}

//========================================================================================
//	g_BuildPlayerIniName
//========================================================================================
FString g_BuildPlayerIniName(const FString PlayerName)
{
	// ("c:\Duke4\Players\PlayerName\PlayerName.ini" for example)
	return g_BuildPlayerSubDir(*PlayerName) + PATH_SEPARATOR TEXT("User.ini");
}

//========================================================================================
//	g_BuildPlayerSystemIniName
//========================================================================================
FString g_BuildPlayerSystemIniName(const FString PlayerName, const FString IniName)
{
	// ("c:\Duke4\Players\PlayerName\PlayerName.ini" for example)
	return g_BuildPlayerSubDir(*PlayerName) + PATH_SEPARATOR + IniName + TEXT(".ini");
}

//========================================================================================
//	g_BuildProfilePath
//========================================================================================
FString g_BuildProfilePath()
{
	return FString(appBaseDir()) + PATH_SEPARATOR TEXT("System.ini");
}

//========================================================================================
//	g_GetCurrentProfile
//========================================================================================
FString g_GetCurrentProfile()
{
	if (!dnPlayerProfile_ProfileExists(*dnPlayerProfile_CurrentProfile))
		dnPlayerProfile_CurrentProfile = TEXT("");

	return dnPlayerProfile_CurrentProfile;	
}

//========================================================================================
//	dnPlayerProfile_InitPlayerProfiles
//========================================================================================
void dnPlayerProfile_InitPlayerProfiles()
{
	if (g_PlayerProfilesInitialized)
		return;		// Already initialized

	// Build the players base dir
	FString BaseDir = g_BuildPlayerBaseDir();
	
	// Make the players base dir (if it does not already exist)
	GFileManager->MakeDirectory(*BaseDir, true);

	// Create the search criteria
	FString PlayerDirSearch = BaseDir + PATH_SEPARATOR TEXT("*.*");

	// Build the player profile file list
	g_PlayerProfiles = GFileManager->FindFiles(*PlayerDirSearch, 0, 1);

	// Make sure the profile dir all contain .ini's.  Remove the profiles which do not
	for(INT j=0; j<g_PlayerProfiles.Num(); j++ )
	{
		if (GFileManager->FindFiles(*g_BuildPlayerIniName(g_PlayerProfiles(j)), 1, 1).Num() != 1)
			g_PlayerProfiles.Remove(j--);
	}

	g_PlayerProfilesInitialized = true;
}

//========================================================================================
//	dnPlayerProfile_ResetPlayerProfiles
//========================================================================================
void dnPlayerProfile_ResetPlayerProfiles()
{
	g_PlayerProfiles.Empty();
	g_PlayerProfilesInitialized = false;
	dnPlayerProfile_InitPlayerProfiles();
}

//========================================================================================
//	dnPlayerProfile_ProfileExists
//========================================================================================
UBOOL dnPlayerProfile_ProfileExists(const TCHAR *PlayerName)
{
	if (g_PlayerProfiles.FindItemIndex(PlayerName) == INDEX_NONE)
		return false;

	return true;
}

//========================================================================================
//	CompareFiles
//========================================================================================
static UBOOL CompareFiles(const TCHAR *File1, const TCHAR *File2)
{
	FString f1, f2;

	appLoadFileToString(f1, File1, GFileManager );
	appLoadFileToString(f2, File2, GFileManager );
		
	return (f1 == f2);
}

//========================================================================================
//	ProfileNeedsReLaunch
//========================================================================================
static UBOOL ProfileNeedsReLaunch(FString PlayerName)
{
	FString				Ini1, Ini2;
	FConfigCacheIni		*GConfigIni = (FConfigCacheIni*)GConfig;
	
	check(GConfigIni != NULL);

	if (g_DeletedCurrentProfile)
		return true;			// Special case, always reboot when they delete the current profile

	if (GConfigIni->SystemIni == TEXT("") || GConfigIni->UserIni == TEXT(""))
		return false;			// no config currently set, special case (this happens for first .ini)

	GConfig->Flush( 0 );		// Make sure the HD has current version of GConfig in memory

	if (!CompareFiles(*GConfigIni->SystemIni, *g_BuildPlayerSystemIniName(*PlayerName, PACKAGE_NAME)))
		return 1;

	if (!CompareFiles(*GConfigIni->UserIni, *g_BuildPlayerIniName(*PlayerName)) )
		return 1;

	return 0;
}

//========================================================================================
//	RequestRelaunch
//========================================================================================
static void RequestRelaunch(void)
{
	GConfig->Flush( 0 );
#if UNICODE
	if( !GUnicodeOS )
	{
		ANSICHAR ThisFile[256];
		GetModuleFileNameA( NULL, ThisFile, ARRAY_COUNT(ThisFile) );
		ShellExecuteA( NULL, "open", ThisFile, "", TCHAR_TO_ANSI(appBaseDir()), SW_SHOWNORMAL );
	}
	else
#endif
	{
		TCHAR ThisFile[256];
		GetModuleFileName( NULL, ThisFile, ARRAY_COUNT(ThisFile) );
		ShellExecute( NULL, TEXT("open"), ThisFile, TEXT(""), appBaseDir(), SW_SHOWNORMAL );
	}
	appRequestExit( 0 );
}

//========================================================================================
//	dnPlayerProfile_SelectProfile
//========================================================================================
UBOOL dnPlayerProfile_SelectProfile(const TCHAR *PlayerName, UBOOL WriteToHD)
{
	check(GConfig != NULL);

	// Make sure the profiles are up to date
	dnPlayerProfile_InitPlayerProfiles();

	// Make sure the profile is valid
	if (!dnPlayerProfile_ProfileExists(PlayerName))
		return false;

	if (g_GetCurrentProfile() == PlayerName)
		return true;			// Profile is the same, no need to do anything...

	// Save to the system.ini if requested (this is done so we can remember it for the next startup)
	if (WriteToHD)
	{
		FConfigCache	*TempConfig = FConfigCacheIni::Factory();

		// Write out the current profile so we can catch it at startup
		if (TempConfig)
		{
			TempConfig->SetString(TEXT("Profile"), TEXT("CurrentProfile"), PlayerName, *g_BuildProfilePath());

			delete TempConfig;
			TempConfig = NULL;
		}
	}
	
	// See if the ini's are different.  if so, we need to relaunch
	if (ProfileNeedsReLaunch(PlayerName))
	{
		RequestRelaunch();
	}
	else
	{
		// No relaunch was needed, but we changed profiles.  Update the .ini path's
		FConfigCacheIni		*GConfigIni = (FConfigCacheIni*)GConfig;

		GConfigIni->Exit();
		GConfigIni->Init(*g_BuildPlayerSystemIniName(PlayerName, PACKAGE_NAME), *g_BuildPlayerIniName(PlayerName), true);
	}

	// Remember current Profile
	dnPlayerProfile_CurrentProfile = PlayerName;

	return true;
}

//========================================================================================
//	dnPlayerProfile_CreateProfile
//========================================================================================
UBOOL dnPlayerProfile_CreateProfile(const TCHAR *PlayerName, UBOOL ForceOriginalIni)
{
	dnPlayerProfile_InitPlayerProfiles();

	if (g_PlayerProfiles.Num() >= 64)		// Guard against someone maliciously trying to create profiles
		return false;

	if (dnPlayerProfile_ProfileExists(PlayerName))
		return false;			// Profile already exists

	FString DefIni, DefUserIni;

	// Make sure the current config is on the HD
	GConfig->Flush(0);

	// Default to the originals
	DefIni = ORIGINAL_SYSTEM_INI;
	DefUserIni = ORIGINAL_USER_INI;

	// If this is currently the temp profile, copy it instead, to avoid a reboot
	//	We do this, because we only use the temp when a profile was not chosen yet
	//	and this avoids a reboot on their very first startup
	if (!ForceOriginalIni && dnPlayerProfile_CurrentProfile == TEMP_PROFILE)
	{
		// If we are the temp profile, special case it, and copy from that (so we don't need to reboot)
		DefIni = g_BuildPlayerSystemIniName(dnPlayerProfile_CurrentProfile, PACKAGE_NAME);
		DefUserIni = g_BuildPlayerIniName(dnPlayerProfile_CurrentProfile);
	}

	if (GFileManager->FileSize(*DefIni) < 0)
		appErrorf( LocalizeError("MisingIni"), *DefIni );
	if (GFileManager->FileSize(*DefUserIni) < 0)
		appErrorf( LocalizeError("MisingIni"), *DefUserIni );

	// Make the directory, and copy over the default ini file
	if (GFileManager->MakeDirectory(*g_BuildPlayerSubDir(PlayerName)))
	{
		// Copy default.ini and defuser.ini over
		GFileManager->Copy(*g_BuildPlayerSystemIniName(PlayerName, PACKAGE_NAME), *DefIni);
		GFileManager->Copy(*g_BuildPlayerIniName(PlayerName), *DefUserIni);
	}

	// Rebuild the list
	dnPlayerProfile_ResetPlayerProfiles();

	return true;
}

//========================================================================================
//	dnPlayerProfile_GetSavedProfile
//========================================================================================
FString dnPlayerProfile_GetSavedProfile(void)
{
	FString			SavedProfile;
	FConfigCache	*TempConfig = FConfigCacheIni::Factory();

	// Write out the current profile so we can catch it at startup
	if (TempConfig)
	{
		SavedProfile = TempConfig->GetStr(TEXT("Profile"), TEXT("CurrentProfile"), *g_BuildProfilePath());

		if (!dnPlayerProfile_ProfileExists(*SavedProfile))
		{
			SavedProfile = TEXT("");
			TempConfig->SetString(TEXT("Profile"), TEXT("CurrentProfile"), TEXT(""), *g_BuildProfilePath());
		}
			
		delete TempConfig;
		TempConfig = NULL;
	}

	return SavedProfile;
}

//========================================================================================
//	dnPlayerProfile_ResetPlayerProfile
//========================================================================================
UBOOL dnPlayerProfile_ResetPlayerProfile(const TCHAR *PlayerName)
{
	FString DefIni, DefUserIni;

	if (!dnPlayerProfile_ProfileExists(PlayerName))
		return false;

	if (dnPlayerProfile_CurrentProfile == PlayerName)
		return false;		// Code cannot handle resetting the current profile yet... (FIXME)

	// Default to the originals
	GFileManager->Copy(*g_BuildPlayerSystemIniName(PlayerName, PACKAGE_NAME), *ORIGINAL_SYSTEM_INI);
	GFileManager->Copy(*g_BuildPlayerIniName(PlayerName), *ORIGINAL_USER_INI);
	
	return true;
}

//========================================================================================
//	Script support
//========================================================================================

//========================================================================================
//	AActor::execGetCurrentPlayerProfile
//========================================================================================
void AActor::execGetCurrentPlayerProfile( FFrame& Stack, RESULT_DECL )
{
	P_FINISH;

	if (g_GetCurrentProfile() == TEMP_PROFILE)		// Special hidden temp profile
		*(FString*)Result = TEXT("");
	else
		*(FString*)Result = g_GetCurrentProfile();
}

//========================================================================================
//	AActor::execProfileSwitchNeedsReLaunch
//========================================================================================
void AActor::execProfileSwitchNeedsReLaunch( FFrame& Stack, RESULT_DECL )
{
	P_GET_STR(PlayerName);
	P_FINISH;

	*(UBOOL*)Result = ProfileNeedsReLaunch(PlayerName);
}

//========================================================================================
//	AActor::execSwitchToPlayerProfile
//========================================================================================
void AActor::execSwitchToPlayerProfile( FFrame& Stack, RESULT_DECL )
{
	P_GET_STR(PlayerName);
	P_FINISH;

	if (dnPlayerProfile_SelectProfile(*PlayerName, true))
		*(UBOOL*)Result = 1;
	else
		*(UBOOL*)Result = 0;
}

//========================================================================================
//	AActor::execCreatePlayerProfile
//========================================================================================
void AActor::execCreatePlayerProfile( FFrame& Stack, RESULT_DECL )
{
	P_GET_STR(PlayerName);
	P_FINISH;

	*(UBOOL*)Result = 0;

	if (PlayerName == TEMP_PROFILE)		// Don't let script create the temp profile
		return;

	if (dnPlayerProfile_CreateProfile(*PlayerName, false))
		*(UBOOL*)Result = 1;
}

//========================================================================================
//	AActor::execDestroyPlayerProfile
//========================================================================================
void AActor::execDestroyPlayerProfile( FFrame& Stack, RESULT_DECL )
{
	P_GET_STR(PlayerName);
	P_FINISH;

	dnPlayerProfile_InitPlayerProfiles();

	if (!dnPlayerProfile_ProfileExists(*PlayerName))
	{
		*(UBOOL*)Result = 0;		// Profile not found
		return;
	}
	
	if (g_GetCurrentProfile() == PlayerName)		// Are they deleting the current selected profile?
	{
		// Yes, special case, and detach the current .ini's so they won't save anymore
		GConfig->Detach(*g_BuildPlayerSystemIniName(PlayerName, PACKAGE_NAME));
		GConfig->Detach(*g_BuildPlayerIniName(PlayerName));
		dnPlayerProfile_CurrentProfile = TEXT("");		// Set the current profile to ""
		g_DeletedCurrentProfile	= true;
	}

	// Delete the .ini files
	GFileManager->Delete(*g_BuildPlayerSystemIniName(PlayerName, PACKAGE_NAME));
	GFileManager->Delete(*g_BuildPlayerIniName(PlayerName));
	
	// Delete the directory
	GFileManager->DeleteDirectory(*g_BuildPlayerSubDir(*PlayerName));

	// Rebuild the list
	dnPlayerProfile_ResetPlayerProfiles();

	*(UBOOL*)Result = 1;
}

//========================================================================================
//	GetNextPlayerProfile
//========================================================================================
static FString GetNextPlayerProfile(const TCHAR *Start)
{
	dnPlayerProfile_InitPlayerProfiles();

	// Nothing in the list, return nothing
	if (g_PlayerProfiles.Num() <= 0)
		return TEXT("");

	// This case is easy, they want the first thing in the list
	if (!appStrcmp(Start, TEXT("")) )
		return g_PlayerProfiles(0);
	
	// Search for it
	INT Index = g_PlayerProfiles.FindItemIndex(Start);
	
	if (Index != INDEX_NONE && Index < g_PlayerProfiles.Num()-1)
		return g_PlayerProfiles(Index+1);

	return TEXT("");
}

//========================================================================================
//	AActor::execGetNextPlayerProfile
//========================================================================================
void AActor::execGetNextPlayerProfile( FFrame& Stack, RESULT_DECL )
{
	P_GET_STR(Start);
	P_FINISH;

	*(FString*)Result = GetNextPlayerProfile(*Start);

	if (*(FString*)Result == TEMP_PROFILE)		// Don't show hidden temp profile
		*(FString*)Result = GetNextPlayerProfile(TEMP_PROFILE);
}