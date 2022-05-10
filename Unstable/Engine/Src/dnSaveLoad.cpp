//========================================================================================
//	dnSaveLoad.cpp
//	John Pollard
//		Saving/Loading support code for script
//========================================================================================
#include "EnginePrivate.h"		// Big momma include

//
// NOTEZ - 
//	To add a new type, you must modify NUM_LISTS to relefect the highest enum in ESaveType
//	You must then register the type in dnSaveLoad_InitSavedGames (using SetupListType)
//

UTexture		*GThumbnailTexture;
UBOOL			GAutoSaveGame;

UBOOL			dnSaveLoad_GSaveGame;
ESaveType		dnSaveLoad_GSaveType;
INT				dnSaveLoad_GSaveListIndex;
FString			dnSaveLoad_GSaveDescription;
UTexture		*dnSaveLoad_GSaveScreenshot;

// JP_REMOVE! Put these in dnSaveLoad.h
void	dnSaveLoad_InitSavedGames();
void	dnSaveLoad_ResetSavedGames();
FString dnSaveLoad_BuildSaveGameFileNameFromListIndex(ESaveType SaveType, INT Index);
void	dnSaveLoad_IncreaseSaves(UGameEngine *Engine);
void	dnSaveLoad_DecreaseSaves(UGameEngine *Engine);
void	dnSaveLoad_IncreaseLoads(UGameEngine *Engine, INT Index);
UBOOL	dnSaveLoad_SaveGame(UGameEngine *Engine, ULevel *Level, ESaveType SaveType, INT Num, const TCHAR *Desc, UTexture *Screenshot);

// Tag and Version numbers for save game info files
const unsigned int Info_Tag = 'INFO';			// Short info file (description, date/time, num saves/loads, etc)
const unsigned int Info_Version = 0;

#define	MAX_SAVED_GAMES				(9999)		// Max saved games for ALL types
#define NUM_NORMAL_SAVES			(MAX_SAVED_GAMES)
#define NUM_QUICK_SAVES				(3)
#define NUM_AUTO_SAVES				(3)
#define INVALID_SAVED_GAME_INDEX	(-1)
#define	DIGIT_POSITIONS				(4)
#define	NUM_LISTS					(3)

typedef struct dnSaveLoad_Type			dnSaveLoad_Type;			// Holds info for a save game type
typedef struct dnSaveLoad_ListInfo		dnSaveLoad_ListInfo;		// Holds info for a saved game
typedef struct dnSaveLoad_InfoData		dnSaveLoad_InfoData;		// Holds data from Info.dat files

typedef TArray<dnSaveLoad_ListInfo>	dnSaveLoad_List;				// List of saved games for a type (dnSaveLoad_ListInfo)
typedef INT							dnSaveLoad_ListIndex;			// Index into a dnSaveLoad_List list in memory
typedef INT							dnSaveLoad_HDIndex;				// Saved index number on the hard drive

typedef struct dnSaveLoad_Type
{
	dnSaveLoad_List			List;					// List of dnSaveLoad_ListInfo's for this type
	FString					TypeName;				// Name of this type (used to name mangle the saved dir's, and to enumerate them)
	UBOOL					OverwriteOldest;		// If true, it will overwrite the oldest saved file when MaxAmount is exceeded
	INT						MaxAmount;				// Max amount of saved games for this type, if exceeded, OverwriteOldest is checked (see above)
	FString					ConfigKeyName;			// Name of key name in the dukeforever.ini file
} dnSaveLoad_Type;

typedef struct dnSaveLoad_InfoData		// For Info.dat files
{
	FString		Description;

	INT			Month;
	INT			Day;
	INT			DayOfWeek;
	INT			Year;
	INT			Hour;
	INT			Minute;
	INT			Second;

	FString		LocationName;
	INT			NumSaves;
	INT			NumLoads;
	float		TotalGameTimeSeconds;
} dnSaveLoad_InfoData;

typedef struct dnSaveLoad_ListInfo
{
	FString					Name;					// Name of the directory for this saved game
	dnSaveLoad_InfoData		Info;					// Cached out Info.dat file for this saved game
} dnSaveLoad_ListInfo;

static UBOOL							g_SavedGamesInitialized;
dnSaveLoad_Type							g_SaveLoadTypes[NUM_LISTS];

// JP_REMOVE!! (put in dnPlayerProfile.h)
FString			g_BuildPlayerBaseDir();
FString			g_BuildPlayerSubDir(const TCHAR *PlayerName);
FString			g_BuildPlayerIniName(const FString PlayerName);
FString			g_BuildPlayerSystemIniName(const FString PlayerName, const FString IniName);
FString			g_BuildProfilePath();
FString			g_GetCurrentProfile();
void			g_InitPlayerProfiles();
void			g_ResetPlayerProfiles();

//========================================================================================
//	****** Local Static Support Code ******
//========================================================================================

//========================================================================================
//	SaveListPointerFromType
//========================================================================================
static dnSaveLoad_List *SaveListPointerFromType(ESaveType SaveType)
{
	check(SaveType >= 0 && SaveType < NUM_LISTS);
	return &g_SaveLoadTypes[SaveType].List;
}

//========================================================================================
//	ListInfoPointerFromIndex
//========================================================================================
static dnSaveLoad_ListInfo *ListInfoPointerFromIndex(ESaveType SaveType, INT Index)
{
	dnSaveLoad_List		*Result;

	Result = SaveListPointerFromType(SaveType);

	if (!Result)
	{
		debugf( NAME_Log, TEXT("SaveListIsValid: Invalid Type: %i"), SaveType);
		return NULL;
	}

	if (Index < 0 || Index >= Result->Num())
	{
		debugf( NAME_Log, TEXT("SaveListIsValid: Invalid Index: %i, %i"), SaveType, Index);
		return NULL;
	}

	return &(*Result)(Index);
}

//========================================================================================
//	SaveListFromType
//========================================================================================
static dnSaveLoad_List &SaveListFromType(ESaveType SaveType)
{
	dnSaveLoad_List	*Result = SaveListPointerFromType(SaveType);

	if (!Result)
		appThrowf(TEXT("SaveListIsValid: Invalid type: %i"), SaveType);

	return *Result;
}

//========================================================================================
//	ListInfoFromIndex
//========================================================================================
static dnSaveLoad_ListInfo &ListInfoFromIndex(ESaveType SaveType, INT Index)
{
	dnSaveLoad_ListInfo	*Result = ListInfoPointerFromIndex(SaveType, Index);

	if (!Result)
		appThrowf(TEXT("SaveListIsValid: Invalid index or type: %i, %i"), SaveType, Index);

	return *Result;
}

//========================================================================================
//	g_BuildSaveGameBaseDir
//========================================================================================
static FString g_BuildSaveGameBaseDir()
{
	FString	PlayerProfile = g_GetCurrentProfile();

	if (PlayerProfile == TEXT(""))
		return GSys->SavePath;		// No playerprofile in use, just return the oldschool savegame directory

	// Go up a directory into the root ("c:\Duke4\Players\Player_Name\Save" for example)
	return g_BuildPlayerSubDir(*PlayerProfile) + PATH_SEPARATOR + TEXT("Save");
}

//========================================================================================
//	NameForType
//========================================================================================
static const TCHAR *NameForType(ESaveType SaveType)
{
	check(SaveType >=0 && SaveType < NUM_LISTS);
	return *(g_SaveLoadTypes[SaveType].TypeName);
}

//========================================================================================
//	g_BuildNewSaveGameSubDirFromHDIndex
//========================================================================================
static FString g_BuildNewSaveGameSubDirFromHDIndex(ESaveType SaveType, INT Index)
{
	TCHAR	Temp[256];

	// Build a string in the format of "%s\%s%04i"
	appSprintf(Temp, TEXT("%%s") PATH_SEPARATOR TEXT("%%s") TEXT("%%0%ii"), DIGIT_POSITIONS);
	// Use this formatted string to build another formatted string!
	return FString::Printf(Temp, *g_BuildSaveGameBaseDir(), NameForType(SaveType), Index);
}

//========================================================================================
//	g_BuildSaveGameSubDirFromListIndex
//========================================================================================
static FString g_BuildSaveGameSubDirFromListIndex(ESaveType SaveType, INT Index)
{
	dnSaveLoad_InitSavedGames();

	return g_BuildSaveGameBaseDir() + PATH_SEPARATOR + ListInfoFromIndex(SaveType, Index).Name;
}

//========================================================================================
//	g_BuildSaveGameSubDirFromName
//========================================================================================
static FString g_BuildSaveGameSubDirFromName(const TCHAR *Name)
{
	dnSaveLoad_InitSavedGames();

	return g_BuildSaveGameBaseDir() + PATH_SEPARATOR + Name;
}

//========================================================================================
//	SaveString
//========================================================================================
static const void SaveString(const TCHAR *Str, FArchive *Ar)
{
	const ANSICHAR	*AnsiStr = appToAnsi(Str);
	INT				StrLen = appStrlen(Str);

	if (StrLen > 1024)
		StrLen = 1024;

	// Save length
	Ar->Serialize(&StrLen, sizeof(StrLen));
	// Save string
	Ar->Serialize((void*)AnsiStr, StrLen*sizeof(ANSICHAR));
}

//========================================================================================
//	ReadString
//========================================================================================
static const TCHAR *ReadString(FArchive *Ar)
{
	ANSICHAR	AnsiStr[1024];
	INT			StrLen;

	// Read length
	Ar->Serialize(&StrLen, sizeof(StrLen));
	
	if (StrLen > 1024)
		StrLen = 1024;
	
	// Read string
	Ar->Serialize(AnsiStr, StrLen*sizeof(ANSICHAR));
	// NULL terminate the str
	AnsiStr[StrLen] = 0;

	return appFromAnsi(AnsiStr);
}

//========================================================================================
//	MySaveGame
//========================================================================================
static UBOOL MySaveGame(UGameEngine *Engine, const TCHAR *Path)
{
	UBOOL		Result = true;

	Engine->GLevel->GetLevelInfo()->LevelAction=LEVACT_Saving;
	Engine->PaintProgress();
	GWarn->BeginSlowTask( LocalizeProgress("Saving"), 1, 0 );
	if( Engine->GLevel->BrushTracker )
	{
		delete Engine->GLevel->BrushTracker;
		Engine->GLevel->BrushTracker = NULL;
	}
	Engine->GLevel->CleanupDestroyed( 1 );

	dnSaveLoad_IncreaseSaves(Engine);

	GSaveLoadHack = true;
	Result &= Engine->SavePackage( Engine->GLevel->GetOuter(), Engine->GLevel, 0, Path, GLog );
	GSaveLoadHack = false;
	
	if (!Result)
		dnSaveLoad_DecreaseSaves(Engine);

	for( INT i=0; i<Engine->GLevel->Actors.Num(); i++ )
		if( Cast<AMover>(Engine->GLevel->Actors(i)) )
			Cast<AMover>(Engine->GLevel->Actors(i))->SavedPos = FVector(-1,-1,-1);
	Engine->GLevel->BrushTracker = GNewBrushTracker( Engine->GLevel );
	GWarn->EndSlowTask();
	Engine->GLevel->GetLevelInfo()->LevelAction=LEVACT_None;
	GCache.Flush();

	return Result;
}

//========================================================================================
//	LoadInfo
//	Kind of hacked.  Loads bits directly into the global screenshot texture...
//========================================================================================
static UBOOL LoadInfo(const TCHAR *FileName, dnSaveLoad_InfoData *pInfo)
{
	DWORD					*pDstBits = NULL;
	unsigned int			Version, Tag;
	FArchive				*Ar = NULL;

	check(FileName);
	check(pInfo);

	appMemset(pInfo, 0, sizeof(*pInfo));
	
	Ar = GFileManager->CreateFileReader(FileName);

	if (!Ar)
		goto ExitWithError;

	// Tag
	Ar->Serialize( (void*)&Tag, sizeof(Tag));
		
	if (Tag != Info_Tag)
		goto ExitWithError;

	// Version
	Ar->Serialize( (void*)&Version, sizeof(Version));

	if (Version != Info_Version)
		goto ExitWithError;

	// Description
	pInfo->Description = FString(ReadString(Ar));
	// Date/Time
	Ar->Serialize(&pInfo->Month, sizeof(pInfo->Month));
	Ar->Serialize(&pInfo->Day, sizeof(pInfo->Day));
	Ar->Serialize(&pInfo->DayOfWeek, sizeof(pInfo->DayOfWeek));
	Ar->Serialize(&pInfo->Year, sizeof(pInfo->Year));
	Ar->Serialize(&pInfo->Hour, sizeof(pInfo->Hour));
	Ar->Serialize(&pInfo->Minute, sizeof(pInfo->Minute));
	Ar->Serialize(&pInfo->Second, sizeof(pInfo->Second));

	// Read strings
	pInfo->LocationName = FString(ReadString(Ar));
	// Num saves
	Ar->Serialize(&pInfo->NumSaves, sizeof(pInfo->NumSaves));
	// Num loads
	Ar->Serialize(&pInfo->NumLoads, sizeof(pInfo->NumLoads));
	// GameTimeInSeconds
	Ar->Serialize(&pInfo->TotalGameTimeSeconds, sizeof(pInfo->TotalGameTimeSeconds));

	// Success.
	delete Ar;
	return true;

	ExitWithError:
	{
		if (Ar)
			delete Ar;

		return false;
	}
}

//========================================================================================
//	SaveInfo
//========================================================================================
static UBOOL SaveInfo(const TCHAR *FileName, dnSaveLoad_InfoData *pInfo)
{
	FArchive		*Ar = NULL;
	
	//
	// FIXME: Use FILEWRITE_Append to update NumLoads...  Currently we read the ENTIRE file in
	//	and then write the ENTIRE file back out.  I suppose it's no big deal though.  Currently
	//	the Info.dat file is not that big, and only contains little info+screenshot.
	//	

	Ar = GFileManager->CreateFileWriter(FileName);

	if (!Ar)
		return false;

	// Tag
	Ar->Serialize( (void*)&Info_Tag, sizeof(Info_Tag));
	// Version
	Ar->Serialize( (void*)&Info_Version, sizeof(Info_Version));

	// Description
	SaveString(*pInfo->Description, Ar);

	// Date/Time
	Ar->Serialize(&pInfo->Month, sizeof(pInfo->Month));
	Ar->Serialize(&pInfo->Day, sizeof(pInfo->Day));
	Ar->Serialize(&pInfo->DayOfWeek, sizeof(pInfo->DayOfWeek));
	Ar->Serialize(&pInfo->Year, sizeof(pInfo->Year));
	Ar->Serialize(&pInfo->Hour, sizeof(pInfo->Hour));
	Ar->Serialize(&pInfo->Minute, sizeof(pInfo->Minute));
	Ar->Serialize(&pInfo->Second, sizeof(pInfo->Second));

	// LocationName
	SaveString(*(pInfo->LocationName), Ar);
	// Num saves
	Ar->Serialize(&pInfo->NumSaves, sizeof(pInfo->NumSaves));
	// Num loads
	Ar->Serialize(&pInfo->NumLoads, sizeof(pInfo->NumLoads));
	// GameTimeInSeconds
	Ar->Serialize(&pInfo->TotalGameTimeSeconds, sizeof(pInfo->TotalGameTimeSeconds));

	// Success.
	delete Ar;

	return true;
}

//========================================================================================
//	FindHDIndexFromListIndex
//========================================================================================
static INT FindHDIndexFromListIndex(ESaveType SaveType, INT ListIndex)
{
	dnSaveLoad_List	&List = SaveListFromType(SaveType);
	INT				DigitLoc = appStrlen(NameForType(SaveType));

	return appAtoi(*List(ListIndex).Name.Mid(DigitLoc));
}

//========================================================================================
//	SetLastHDIndexForType
//========================================================================================
static void SetLastHDIndexForType(ESaveType SaveType, INT HDIndex)
{
	check(SaveType >=0 && SaveType < NUM_LISTS);
	GConfig->SetInt(TEXT("SaveLoad"), *g_SaveLoadTypes[SaveType].ConfigKeyName, HDIndex);
}

//========================================================================================
//	InfoIsNewer
//========================================================================================
static UBOOL InfoIsNewer(dnSaveLoad_InfoData *a, dnSaveLoad_InfoData *b)
{
	// See if the info is newer than the current one
	if (a->Year > b->Year)
		return true;					// Newer
	if (a->Year < b->Year)
		return false;					// Older
	if (a->Month > b->Month)
		return true;					// Newer
	if (a->Month < b->Month)
		return false;					// Older
	if (a->Day > b->Day)
		return true;					// Newer
	if (a->Day < b->Day)
		return false;					// Older
	if (a->Hour > b->Hour)
		return true;					// Newer
	if (a->Hour < b->Hour)
		return false;					// Older
	if (a->Minute > b->Minute)
		return true;					// Newer
	if (a->Minute < b->Minute)
		return false;					// Older
	if (a->Second > b->Second)
		return true;					// Newer
	if (a->Second < b->Second)
		return false;					// Older

	return false;						// Same (so theorectially, it's NOT newer)
}

//========================================================================================
//	FindMostRecentListIndex
//========================================================================================
static INT FindMostRecentListIndex(ESaveType SaveType)
{
	INT		BestIndex = -1;

	if (!SaveListFromType(SaveType).Num())
		return -1;		// Nothing in the list, return -1

	dnSaveLoad_InfoData		*Info, *CurrentInfo = NULL;

	for (INT i = 0; i< SaveListFromType(SaveType).Num(); i++)
	{
		Info = &ListInfoFromIndex(SaveType, i).Info;

		if (CurrentInfo && !InfoIsNewer(Info, CurrentInfo))
			continue;

		// Either this is the first one, or it's newer
		CurrentInfo = Info;
		BestIndex = i;
	}

	return BestIndex;
}

//========================================================================================
//	FindOldestListIndex
//========================================================================================
static INT FindOldestListIndex(ESaveType SaveType)
{
	INT		BestIndex = -1;

	if (!SaveListFromType(SaveType).Num())
		return -1;		// Nothing in the list, return -1

	dnSaveLoad_InfoData		*Info, *CurrentInfo = NULL;

	for (INT i = 0; i< SaveListFromType(SaveType).Num(); i++)
	{
		Info = &ListInfoFromIndex(SaveType, i).Info;

		if (CurrentInfo && InfoIsNewer(Info, CurrentInfo))
			continue;

		// Either this is the first one, or it's older
		CurrentInfo = Info;
		BestIndex = i;
	}

	return BestIndex;
}

//========================================================================================
//	FindOldestHDIndex
//========================================================================================
static INT FindOldestHDIndex(ESaveType SaveType)
{
	INT ListIndex = FindOldestListIndex(SaveType);

	if (ListIndex == -1)
		return -1;
	
	return FindHDIndexFromListIndex(SaveType, ListIndex);
}

//========================================================================================
//	MakeAutoLoadListIndexForType
//========================================================================================
static INT MakeAutoLoadListIndexForType(ESaveType SaveType)
{
	return FindMostRecentListIndex(SaveType);
}

//========================================================================================
//	MakeUniqueHDIndex
//========================================================================================
static INT MakeUniqueHDIndex(ESaveType SaveType)
{
	INT		HDIndex = 0;

	check(SaveType >=0 && SaveType < NUM_LISTS);

	dnSaveLoad_InitSavedGames();

	// This algo will take the first avail HDIndex
	for (INT i=0; i< SaveListFromType(SaveType).Num(); i++)
	{
		INT	CurHDIndex = FindHDIndexFromListIndex(SaveType, i);

		if (HDIndex == CurHDIndex)
			HDIndex++;		// Already taken, try next
	}
	
	// If they maxed out, overwrite the oldest saved game of this type
	if (HDIndex >= g_SaveLoadTypes[SaveType].MaxAmount && g_SaveLoadTypes[SaveType].OverwriteOldest)
		HDIndex = FindOldestHDIndex(SaveType);

	if (HDIndex >= MAX_SAVED_GAMES)
		return INVALID_SAVED_GAME_INDEX;

	// Remember the last saved game of this type
	SetLastHDIndexForType(SaveType, HDIndex);

	return HDIndex;
}

//========================================================================================
//	SerializeBmp
//========================================================================================
static UBOOL SerializeBmp(FArchive *Ar, UTexture *Texture)
{
	DWORD		*SrcBits = (DWORD*)&Texture->Mips(0).DataArray(0);

	// Types.
	#if _MSC_VER
		#pragma pack (push,1)
	#endif
	struct BITMAPFILEHEADER
	{
		_WORD   bfType GCC_PACK(1);
		DWORD   bfSize GCC_PACK(1);
		_WORD   bfReserved1 GCC_PACK(1); 
		_WORD   bfReserved2 GCC_PACK(1);
		DWORD   bfOffBits GCC_PACK(1);
	} FH; 
	struct BITMAPINFOHEADER
	{
		DWORD  biSize GCC_PACK(1); 
		INT    biWidth GCC_PACK(1);
		INT    biHeight GCC_PACK(1);
		_WORD  biPlanes GCC_PACK(1);
		_WORD  biBitCount GCC_PACK(1);
		DWORD  biCompression GCC_PACK(1);
		DWORD  biSizeImage GCC_PACK(1);
		INT    biXPelsPerMeter GCC_PACK(1); 
		INT    biYPelsPerMeter GCC_PACK(1);
		DWORD  biClrUsed GCC_PACK(1);
		DWORD  biClrImportant GCC_PACK(1); 
	} IH;
	#if _MSC_VER
		#pragma pack (pop)
	#endif

	// File header.
	FH.bfType		= 'B' + 256*'M';
	FH.bfSize		= sizeof(BITMAPFILEHEADER) + sizeof(BITMAPINFOHEADER) + 3 * Texture->USize * Texture->VSize;
	FH.bfReserved1	= 0;
	FH.bfReserved2	= 0;
	FH.bfOffBits	= sizeof(BITMAPFILEHEADER) + sizeof(BITMAPINFOHEADER);
	Ar->Serialize( &FH, sizeof(FH) );

	// Info header.
	IH.biSize			= sizeof(BITMAPINFOHEADER);
	IH.biWidth			= Texture->USize;
	IH.biHeight			= Texture->VSize;
	IH.biPlanes			= 1;
	IH.biBitCount		= 24;
	IH.biCompression	= 0; //BI_RGB
	IH.biSizeImage		= Texture->USize * Texture->VSize * 3;
	IH.biXPelsPerMeter	= 0;
	IH.biYPelsPerMeter	= 0;
	IH.biClrUsed		= 0;
	IH.biClrImportant	= 0;
	Ar->Serialize( &IH, sizeof(IH) );

	if (Ar->IsLoading())
	{
		if (FH.bfType != ('B' + 256*'M'))
			return false;
		if (IH.biWidth != Texture->USize)
			return false;
		if (IH.biHeight != Texture->VSize)
			return false;
	}

	// Colors.
#if _MSC_VER
	for( INT i=Texture->VSize-1; i>=0; i-- )
	{
		for( INT j=0; j<Texture->USize; j++ )
		{
			Ar->Serialize( &SrcBits[i*Texture->USize+j], 3 );
		}
	}
#else
	for( INT i=Texture->VSize; i>=0; i-- )
	{
		for( INT j=0; j<Texture->USize; j++ )
		{
			Ar->Serialize( &SrcBits[i*Texture->USize+j], 3 );
		}
	}
#endif

	if (Ar->IsLoading())
	{
		for( INT i=0; i< Texture->USize*Texture->VSize; i++)
			SrcBits[i] |= 0xff000000;
		
		Texture->bRealtimeChanged = true;
	}

	return true;
}

//========================================================================================
//	SetupListType
//========================================================================================
static UBOOL SetupListType(ESaveType SaveType, const TCHAR *BaseDir, const TCHAR *TypeName, const TCHAR *ConfigKeyName, UBOOL OverwriteOldest, INT MaxAmount)
{
	INT		i, j;

	check(SaveType >=0 && SaveType < NUM_LISTS);

	// Create the search criteria
	FString DirSearch = FString::Printf(TEXT("%s") PATH_SEPARATOR TEXT("%s") TEXT("*.*"), BaseDir, TypeName);

	TArray<FString>		List = GFileManager->FindFiles(*DirSearch, 0, 1);

	g_SaveLoadTypes[SaveType].TypeName = TypeName;
	g_SaveLoadTypes[SaveType].ConfigKeyName = ConfigKeyName;
	g_SaveLoadTypes[SaveType].OverwriteOldest = OverwriteOldest;
	g_SaveLoadTypes[SaveType].MaxAmount = MaxAmount;

	// Remove invalid saved game dir's
	for(j=0; j<List.Num(); j++ )
	{
		dnSaveLoad_ListInfo		ListInfo;

		INT StrLen = appStrlen(TypeName);

		if (List(j).Left(StrLen) != TypeName)
			continue;
		
		// Make sure Dir name follows the "TYPENAMExxxx" convention
		{
			FString			FStr = List(j).Mid(StrLen);
			const TCHAR		*Str = *FStr;

			if (appStrlen(Str) != DIGIT_POSITIONS)
				continue;

			for (i = 0; i< DIGIT_POSITIONS; i++)
			{
				if (Str[i] < '0' || Str[i] > '9')
					break;
			}

			if (i != DIGIT_POSITIONS)
				continue;
		}

		// Make sure there are only EXACTLY 3 files in the dir, and make sure they are ones we recognize
		{
			FString		Dir			= g_BuildSaveGameSubDirFromName(*List(j));
			FString		Info		= Dir + PATH_SEPARATOR + TEXT("Info.dat");
			FString		SC			= Dir + PATH_SEPARATOR + TEXT("Screenshot.bmp");
			FString		GameFile	= Dir + PATH_SEPARATOR + TEXT("Game.dns");

			//if (GFileManager->FindFiles(*Dir, 1, 0).Num() != 3)
			//	continue;

			if (GFileManager->FileSize(*Info) < 0)
				continue;

			if (GFileManager->FileSize(*SC) < 0)
				continue;

			if (GFileManager->FileSize(*GameFile) < 0)
				continue;
		
			// Load the data file
			if (!LoadInfo(*Info, &ListInfo.Info))
				continue;
		}

		ListInfo.Name = List(j);
		
		g_SaveLoadTypes[SaveType].List.AddItem(ListInfo);
	}

	List.Clear();

	return true;
}

//========================================================================================
//	Global engine support code
//========================================================================================

//========================================================================================
//	dnSaveLoad_InitSavedGames
//========================================================================================
void dnSaveLoad_InitSavedGames()
{
	if (g_SavedGamesInitialized)
		return;		// Already initialized

	g_SavedGamesInitialized = true;		// So this is not re-entrant

	// Build the players base dir
	FString BaseDir = g_BuildSaveGameBaseDir();

	// Make the base dir (if it does not already exist)
	GFileManager->MakeDirectory(*BaseDir, true);

	// Register all the types
	SetupListType(SAVE_Normal, *BaseDir, TEXT("Save"), TEXT("LastNormalSave"), true, NUM_NORMAL_SAVES);
	SetupListType(SAVE_Quick, *BaseDir, TEXT("Quick"), TEXT("LastQuickSave"), true, NUM_QUICK_SAVES);
	SetupListType(SAVE_Auto, *BaseDir, TEXT("Auto"), TEXT("LastAutoSave"), true, NUM_AUTO_SAVES);
}

//========================================================================================
//	dnSaveLoad_ResetSavedGames
//========================================================================================
void dnSaveLoad_ResetSavedGames()
{
	for (INT i = 0; i < NUM_LISTS; i++)
		g_SaveLoadTypes[i].List.Clear();

	g_SavedGamesInitialized = false;
	dnSaveLoad_InitSavedGames();
}

//========================================================================================
//	dnSaveLoad_BuildSaveGameFileNameFromListIndex
//========================================================================================
FString dnSaveLoad_BuildSaveGameFileNameFromListIndex(ESaveType SaveType, INT Index)
{
	dnSaveLoad_InitSavedGames();

	if (!ListInfoPointerFromIndex(SaveType, Index))
	{
		debugf( NAME_Log, TEXT("dnSaveLoad_BuildSaveGameFileNameFromListIndex: Invalid Saved Game slot: %i"), Index);
		return TEXT("");
	}

	return g_BuildSaveGameSubDirFromListIndex(SaveType, Index) + PATH_SEPARATOR + TEXT("Game.dns");
}

//========================================================================================
//	dnSaveLoad_IncreaseSaves
//========================================================================================
void dnSaveLoad_IncreaseSaves(UGameEngine *Engine)
{
	Engine->GLevel->GetLevelInfo()->NumSaves++;
}

//========================================================================================
//	dnSaveLoad_DecreaseSaves
//========================================================================================
void dnSaveLoad_DecreaseSaves(UGameEngine *Engine)
{
	Engine->GLevel->GetLevelInfo()->NumSaves--;
}

//========================================================================================
//	dnSaveLoad_IncreaseLoads
//========================================================================================
void dnSaveLoad_IncreaseLoads(UGameEngine *Engine, ESaveType SaveType, INT Index)
{
	dnSaveLoad_ListInfo		*ListInfo;

	// Make sure the list is up to date
	dnSaveLoad_InitSavedGames();

	// Check to see if the index is out of range
	ListInfo = ListInfoPointerFromIndex(SaveType, Index);

	if (!ListInfo)
	{
		debugf( NAME_Log, TEXT("dnSaveLoad_IncreaseLoads: Invalid Saved Game slot: %i"), Index);
		return;
	}

	// Get the file name to the data file for this saved game
	dnSaveLoad_InfoData	Info;
	FString				FileName = g_BuildSaveGameSubDirFromListIndex(SaveType, Index) + PATH_SEPARATOR + TEXT("Info.dat");

	// Load the data file for good measure
	if (!LoadInfo(*FileName, &ListInfo->Info))
		return;

	// Increment the load counter
	ListInfo->Info.NumLoads++;
	// Update the levelinfo with the current load count
	Engine->GLevel->GetLevelInfo()->NumLoads = ListInfo->Info.NumLoads;
	// Save the data back out 
	//	(NOTE - the levelinfo is not up to date on this, only the separate info.dat file is)
	SaveInfo(*FileName, &ListInfo->Info);
}

//========================================================================================
//	dnSaveLoad_SaveGame
//========================================================================================
UBOOL dnSaveLoad_SaveGame(UGameEngine *Engine, ULevel *Level, ESaveType SaveType, INT Num, const TCHAR *Desc, UTexture *Screenshot)
{
	FString		Dir;

	// Make sure the list is up to date
	dnSaveLoad_InitSavedGames();

	if (Num == -1)		// Auto build a new index
	{
		Num = MakeUniqueHDIndex((ESaveType)SaveType);

		if (Num == INVALID_SAVED_GAME_INDEX)
			return false;

		Dir = g_BuildNewSaveGameSubDirFromHDIndex((ESaveType)SaveType, Num);
	}
	else 
	{
		if (!ListInfoPointerFromIndex((ESaveType)SaveType, Num))
			return false;
		
		Dir = g_BuildSaveGameSubDirFromListIndex((ESaveType)SaveType, Num);
	}

	FString		Info		= Dir + PATH_SEPARATOR + TEXT("Info.dat");
	FString		SC			= Dir + PATH_SEPARATOR + TEXT("Screenshot.bmp");
	FString		GameFile	= Dir + PATH_SEPARATOR + TEXT("Game.dns");
	
	// Make the save game dir
	GFileManager->MakeDirectory(*Dir, true);
	
	//debugf( NAME_Log, TEXT("JohnTest: saving %s"), *Dir);

	// Save the level package
	if (!MySaveGame(Engine, *GameFile))
		return false;

	dnSaveLoad_InfoData	InfoD;

	InfoD.Description = Desc;

	if (InfoD.Description == TEXT(""))
		InfoD.Description = TEXT("Unknown");

	ALevelInfo		*LInfo = Level->GetLevelInfo();

	InfoD.Month		= LInfo->Month;
	InfoD.Day		= LInfo->Day;
	InfoD.DayOfWeek	= LInfo->DayOfWeek;
	InfoD.Year		= LInfo->Year;
	InfoD.Hour		= LInfo->Hour;
	InfoD.Minute	= LInfo->Minute;
	InfoD.Second	= LInfo->Second;

	InfoD.LocationName = LInfo->LocationName;

	if (InfoD.LocationName == TEXT(""))
		InfoD.LocationName = TEXT("Unknown");

	InfoD.NumSaves = LInfo->NumSaves;		
	InfoD.NumLoads = LInfo->NumLoads;

	InfoD.TotalGameTimeSeconds = LInfo->TotalGameTimeSeconds;

	// Save "Info.dat"
	SaveInfo(*Info, &InfoD);

	// Save screenshot
	FArchive *Ar = GFileManager->CreateFileWriter(*SC);
		
	if (Ar)
	{
		SerializeBmp(Ar, Screenshot);
		delete Ar;
	}

	// Update the list
	dnSaveLoad_ResetSavedGames();

	return true;
}

//========================================================================================
//			***** Script Support Code *****
//========================================================================================

//========================================================================================
//	AActor::execLoadGame
//========================================================================================
void AActor::execLoadGame( FFrame& Stack, RESULT_DECL )
{
	P_GET_BYTE(SaveType);
	P_GET_INT(Num);
	P_FINISH;

	dnSaveLoad_InitSavedGames();

	if (Num == -1)	// Autoload.  
	{
		Num = MakeAutoLoadListIndexForType((ESaveType)SaveType);

		if (Num == -1)
		{
			*(UBOOL*)Result = 0;
			return;
		}
	}

	if (!ListInfoPointerFromIndex((ESaveType)SaveType, Num))
	{
		*(UBOOL*)Result = 0;
		debugf( NAME_Log, TEXT("execLoadGame: Invalid Saved Game slot: %i"), Num);
		return;
	}

	//debugf( NAME_Log, TEXT("execLoadGame: Attempt to load game: %s"), ListInfoFromIndex((ESaveType)SaveType, Num));

	APlayerPawn *Pawn = NULL;
	
	if(IsA(APlayerPawn::StaticClass()) )
		Pawn = Cast<APlayerPawn>(this);

	if (Pawn && Pawn->Player)
	{
		FString URL = FString::Printf( TEXT("?load2=%i?load2type=%i"), Num, SaveType);
		
		debugf( NAME_Log, TEXT("execLoadGame: URL: %s"), *URL);

		// Warn the client.
		Pawn->eventPreClientTravel();

		// Do the travel.
		GetLevel()->Engine->SetClientTravel( Pawn->Player, *URL, false, TRAVEL_Absolute);
		*(UBOOL*)Result = 1;
	}
	else
	{
		debugf( NAME_Log, TEXT("execLoadGame: Load game failed, not a pawn: %s"), ListInfoFromIndex((ESaveType)SaveType, Num));
		*(UBOOL*)Result = 0;
	}
}

//========================================================================================
//	AActor::execSaveGame
//========================================================================================
void AActor::execSaveGame( FFrame& Stack, RESULT_DECL )
{
	P_GET_BYTE(SaveType);
	P_GET_INT(Num);
	P_GET_STR(Description);
	P_GET_OBJECT(UTexture, Screenshot);
	P_FINISH;

#if 1
	if (!dnSaveLoad_SaveGame((UGameEngine*)GetLevel()->Engine, GetLevel(), (ESaveType)SaveType, Num, *Description, Screenshot))
		*(UBOOL*)Result = 0;
	else
		*(UBOOL*)Result = 1;
#else
	dnSaveLoad_GSaveGame = true;
	dnSaveLoad_GSaveType = (ESaveType)SaveType;
	dnSaveLoad_GSaveListIndex = Num;
	dnSaveLoad_GSaveDescription = Description;
	dnSaveLoad_GSaveScreenshot = Screenshot;
	*(UBOOL*)Result = 1;
#endif
}

//========================================================================================
//	AActor::execDeleteSavedGame
//========================================================================================
void AActor::execDeleteSavedGame( FFrame& Stack, RESULT_DECL )
{
	P_GET_BYTE(SaveType);
	P_GET_INT(Num);
	P_FINISH;

	// Make sure the list is up to date
	dnSaveLoad_InitSavedGames();

	// Check to see if the index is out of range
	if (!ListInfoPointerFromIndex((ESaveType)SaveType, Num))
	{
		*(UBOOL*)Result = 0;
		debugf( NAME_Log, TEXT("execDeleteSavedGame: Invalid Saved Game slot: %i"), Num);
		return;
	}

	// Build the path to the directory
	FString		Dir = g_BuildSaveGameSubDirFromListIndex((ESaveType)SaveType, Num);
	
	FString		Info		= Dir + PATH_SEPARATOR + TEXT("Info.dat");
	FString		SC			= Dir + PATH_SEPARATOR + TEXT("Screenshot.bmp");
	FString		GameFile	= Dir + PATH_SEPARATOR + TEXT("Game.dns");

	debugf( NAME_Log, TEXT("execDeleteSavedGame: Deleting saved game: %s"), *Dir);

	// Delete the 3 saved game files
	GFileManager->Delete(*Info);
	GFileManager->Delete(*SC);
	GFileManager->Delete(*GameFile);

	// Delete the directory
	//if (GFileManager->DeleteDirectory(*Dir, 0, 1))
	if (GFileManager->DeleteDirectory(*Dir))
		debugf( NAME_Log, TEXT("execDeleteSavedGame: Deleted saved game: %s"), *Dir);

	// Rebuild the list
	dnSaveLoad_ResetSavedGames();

	*(UBOOL*)Result = 1;
}

//========================================================================================
//	AActor::execGetNumSavedGames
//========================================================================================
void AActor::execGetNumSavedGames( FFrame& Stack, RESULT_DECL )
{
	P_GET_BYTE(SaveType);
	P_FINISH;

	// Make sure the list is up to date
	dnSaveLoad_InitSavedGames();

	if (!SaveListPointerFromType((ESaveType)SaveType))
	{
		*(int*)Result = 0;
		debugf( NAME_Log, TEXT("execGetNumSavedGames: Invalid Saved Game type: %i"), SaveType);
		return;
	}

	*(int*)Result = SaveListPointerFromType((ESaveType)SaveType)->Num();
}

//========================================================================================
//	AActor::execGetSavedGameInfo
//========================================================================================
void AActor::execGetSavedGameInfo( FFrame& Stack, RESULT_DECL )
{
	P_GET_BYTE(SaveType);
	P_GET_INT(Num);
	P_GET_STR_REF(Description);
	P_GET_INT_REF(Month);
	P_GET_INT_REF(Day);
	P_GET_INT_REF(DayOfWeek);
	P_GET_INT_REF(Year);
	P_GET_INT_REF(Hour);
	P_GET_INT_REF(Minute);
	P_GET_INT_REF(Second);
	P_FINISH;

	// Make sure the list is up to date
	dnSaveLoad_InitSavedGames();

	if (Num == -1)
	{
		Num = MakeAutoLoadListIndexForType((ESaveType)SaveType);

		if (Num == -1)
		{
			*(UBOOL*)Result = 0;
			return;
		}
	}

	// Check to see if the index is out of range
	dnSaveLoad_ListInfo *ListInfo = ListInfoPointerFromIndex((ESaveType)SaveType, Num);

	if (!ListInfo)
	{
		*(UBOOL*)Result = 0;
		debugf( NAME_Log, TEXT("execGetSavedGameInfo: Invalid Saved Game slot: %i"), Num);
		return;
	}

	*Description = ListInfo->Info.Description;
	*Month = ListInfo->Info.Month;
	*Day = ListInfo->Info.Day;
	*DayOfWeek = ListInfo->Info.DayOfWeek;
	*Year = ListInfo->Info.Year;
	*Hour = ListInfo->Info.Hour;
	*Minute = ListInfo->Info.Minute;
	*Second = ListInfo->Info.Second;

	*(UBOOL*)Result = 1;
}

//========================================================================================
//	AActor::execGetSavedGameLongInfo
//========================================================================================
void AActor::execGetSavedGameLongInfo( FFrame& Stack, RESULT_DECL )
{
	P_GET_BYTE(SaveType);
	P_GET_INT(Num);
	P_GET_STR_REF(LocationName);
	P_GET_INT_REF(NumSaves);
	P_GET_INT_REF(NumLoads);
	P_GET_FLOAT_REF(TotalGameTimeSeconds);
	P_GET_OBJECT_REF(UTexture, Screenshot);
	P_FINISH;

	// Make sure the list is up to date
	dnSaveLoad_InitSavedGames();

	if (Num == -1)
	{
		Num = MakeAutoLoadListIndexForType((ESaveType)SaveType);

		if (Num == -1)
		{
			*(UBOOL*)Result = 0;
			return;
		}
	}

	// Check to see if the index is out of range
	dnSaveLoad_ListInfo *ListInfo = ListInfoPointerFromIndex((ESaveType)SaveType, Num);
	
	if (!ListInfo)
	{
		*(UBOOL*)Result = 0;
		debugf( NAME_Log, TEXT("execGetSavedGameLongInfo: Invalid Saved Game slot: %i"), Num);
		return;
	}

	*LocationName = ListInfo->Info.LocationName;
	*NumSaves = ListInfo->Info.NumSaves;
	*NumLoads = ListInfo->Info.NumLoads;
	*TotalGameTimeSeconds = ListInfo->Info.TotalGameTimeSeconds;

	// Build the filename for the screenshot
	FString		SC = g_BuildSaveGameSubDirFromListIndex((ESaveType)SaveType, Num) + PATH_SEPARATOR + TEXT("Screenshot.bmp");

	// Read screenshot
	FArchive *Ar = GFileManager->CreateFileReader(*SC);
		
	if (Ar)
	{
		SerializeBmp(Ar, GThumbnailTexture);
		delete Ar;
	}

	*Screenshot = GThumbnailTexture;

	*(UBOOL*)Result = 1;
}


	// practice code :)
	/*
	// JP_TEST:
	{
		USaveGameInfo		*SaveGameInfo;
		UTexture			*Texture;
		UPackage			*Package;
		
		Package = CreatePackage(NULL, TEXT("TempPackage"));

		SaveGameInfo = (USaveGameInfo*)StaticConstructObject(USaveGameInfo::StaticClass(), Package, TEXT("SaveGameInfo"), RF_Native );
		
		Texture = (UTexture*)StaticConstructObject( UTexture::StaticClass(), Package, TEXT("TestTexture"), RF_Native );
		Texture->Format = TEXF_RGBA8;
		Texture->Init(128, 128);
		Texture->PostLoad();

		SaveGameInfo->Screenshot = Texture;
		SaveGameInfo->Description = TEXT("My Saved Game");

		SavePackage(Package, SaveGameInfo, 0, TEXT("TestPackage.u"), GLog);
		

		//Package->AddToRoot();

		SaveGameInfo->Screenshot = NULL;
		delete Texture;
		delete SaveGameInfo;

		Package = (UPackage*)LoadPackage(NULL, TEXT("TestPackage.u"), LOAD_NoFail);

		if (!Package)
			appThrowf(TEXT("Failed to load Package") );
	
		for( FObjectIterator It; It; ++It )
		{
			if(It->IsIn(Package))
				debugf( NAME_Log, TEXT("JohnTest: %s"), It->GetName());
		}
	}

	{
		UPackage			*Package;

		Package = (UPackage*)LoadPackage(NULL, TEXT("TestPackage.u"), LOAD_NoFail);
		
		for( FObjectIterator It; It; ++It )
		{
			if(It->IsIn(Package) && !appStrcmp(It->GetName(), TEXT("SaveGameInfo")) )
				debugf( NAME_Log, TEXT("JohnTest: %s"), It->GetName());
		}
	}
	*/
	/*
	// JP_TEST:
	{
		UTexture		*Texture;
		UPackage		*Package;

		Package = CreatePackage(NULL, TEXT("TestPackage"));

		Texture = (UTexture*)StaticConstructObject( UTexture::StaticClass(), Package, TEXT("TestTexture"), RF_Native );
		Texture->Init(64, 64);
		Texture->PolyFlags = PF_Masked;
		Texture->PostLoad();

		SavePackage(Package, Texture, 0, TEXT("TestPackage.u"), GLog);

		delete Package;
		delete Texture;
	}
	*/

