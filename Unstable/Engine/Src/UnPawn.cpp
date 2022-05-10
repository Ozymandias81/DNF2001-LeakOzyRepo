/*=============================================================================
	UnPawn.cpp: APawn AI implementation

  This contains both C++ methods (movement and reachability), as well as some 
  AI related natives

	Copyright 1997 Epic MegaGames, Inc. This software is a trade secret.

	Revision history:
		* Created by Steven Polge 3/97
=============================================================================*/

#include "EnginePrivate.h"
#include "DnMeshPrivate.h"

/*-----------------------------------------------------------------------------
	APawn object implementation.
-----------------------------------------------------------------------------*/

IMPLEMENT_CLASS(APawn);
IMPLEMENT_CLASS(APlayerPawn);

/*-----------------------------------------------------------------------------
	ANavigationPoint functions.
-----------------------------------------------------------------------------*/

enum EAIFunctions
{
	AI_PollMoveTo = 501,
	AI_PollMoveToward = 503,
	AI_PollStrafeTo = 505,
	AI_PollStrafeFacing = 507,
	AI_PollTurnTo = 509,
	AI_PollTurnToward = 511,
	AI_PollWaitForLanding = 528,
};

void AActor::execGetNextInt( FFrame& Stack, RESULT_DECL )
{
	P_GET_STR(ClassName);
	P_GET_INT(CurrentInt);
	P_FINISH;

	UClass* TempClass = FindObjectChecked<UClass>( ANY_PACKAGE, *ClassName );

	TArray<FRegistryObjectInfo> List;
	GetRegistryObjects( List, UClass::StaticClass(), TempClass, 0 );

	*(FString*)Result = (CurrentInt<List.Num()) ? List(CurrentInt).Object : TEXT("");
}

void AActor::execGetNextIntDesc( FFrame& Stack, RESULT_DECL )
{
	P_GET_STR(ClassName);
	P_GET_INT(CurrentInt);
	P_GET_STR_REF(EntryName);
	P_GET_STR_REF(Description);
	P_FINISH;

	UClass* TempClass = FindObjectChecked<UClass>( ANY_PACKAGE, *ClassName );

	TArray<FRegistryObjectInfo> List;
	GetRegistryObjects( List, UClass::StaticClass(), TempClass, 0 );

	*EntryName = (CurrentInt<List.Num()) ? List(CurrentInt).Object : TEXT("");
	*Description = (CurrentInt<List.Num()) ? List(CurrentInt).Description : TEXT("");
}

void APlayerPawn::execDoClientPossess( FFrame& Stack, RESULT_DECL )
{
	P_FINISH;

	if ( !GetLevel()->NetDriver )
		return;

	UNetConnection* Connection = GetLevel()->NetDriver->ServerConnection;

	if ( Connection )
		Connection->HandleClientPlayer( this );	
}

void APlayerPawn::execDoChangeClass( FFrame& Stack, RESULT_DECL )
{
	P_GET_STR(NewClass);
	P_FINISH;

	APlayerPawn *newPawn;
	FString		Error;

	debugf( TEXT("new class is %s"), *NewClass );

	// Spawning a new play actor will detach the old actor.
	newPawn = GetLevel()->SpawnNewPlayerClass( Player, ROLE_AutonomousProxy, *NewClass, Error ); 
	
	if( !newPawn )
	{		
		// Failed to connect.
		debugf( NAME_DevNet, TEXT("APlayerPawn::execDoChangeClass: Class change failure: %s"), *Error );
		*(DWORD*)Result = NULL;
	}
	else
	{
		// If this player has a viewport on the server (I.e. Listen server), then reset the input.
		if ( newPawn->Player && newPawn->Player->IsA( UViewport::StaticClass() ) )
		{			
			UViewport* Viewport = CastChecked<UViewport>( newPawn->Player );			
			Viewport->Input->ResetInput();

			// Set this so we get ticked properly on the server and on other clients
			newPawn->RemoteRole = ROLE_SimulatedProxy;
		}
		*(AActor**)Result = newPawn;
	}
}

void APlayerPawn::execUpdateURL( FFrame& Stack, RESULT_DECL )
{
	P_GET_STR(NewOption);
	P_GET_STR(NewValue);
	P_GET_UBOOL(bSaveDefault);
	P_FINISH;

	UGameEngine* GameEngine = CastChecked<UGameEngine>( GetLevel()->Engine );
	GameEngine->LastURL.AddOption( *(NewOption + TEXT("=") + NewValue) );
	if( bSaveDefault )
		GameEngine->LastURL.SaveURLConfig( TEXT("DefaultPlayer"), *NewOption, TEXT("User") );
}

void APlayerPawn::execGetDefaultURL( FFrame& Stack, RESULT_DECL )
{
	P_GET_STR(Option);
	P_FINISH;

	FURL URL;
	URL.LoadURLConfig( TEXT("DefaultPlayer"), TEXT("User") );

	*(FString*)Result = FString( URL.GetOption(*(Option + FString(TEXT("="))), TEXT("")) );
}

void AActor::execGetURLMap( FFrame& Stack, RESULT_DECL )
{
	P_FINISH;

	*(FString*)Result = ((UGameEngine*)GetLevel()->Engine)->LastURL.Map;
}

void AActor::execGetNextClass( FFrame& Stack, RESULT_DECL )
{
    P_GET_STR(BaseCharacterClass);
    P_GET_STR(CurrentCharacterClass);
    P_GET_INT(Dir);
	P_GET_STR_REF(CharacterClass);
	P_GET_STR_REF(ClassDesc);

	P_FINISH;

	TArray<FModelDataSpecification> List;
	GetModelDataSpecifications( List, TEXT("BaseCharacterClass"), TEXT(""), 0 );

    INT UseClass     = -1;
	INT FirstClass   = -1;
	INT PrevClass    = -1;
	INT UseNext     = 0;

    for ( INT i=0; i<List.Num(); i++ )
    {
        INT NumParents = List(i).Parent.Num();
        
        // Go through each parent and see if the BaseCharacterClass Matches
        for ( INT j=0; j<NumParents; j++ )
        {
            if ( !appStricmp( *List(i).Parent(j), *BaseCharacterClass ) )
                break;
        }
        
        if ( j == NumParents )
            continue;
        
        // If we got here, the parents matched
		if( UseNext )
		{
			UseClass = i;
			UseNext = 0;
			break;
		}

		if( FirstClass == -1 )
			FirstClass = i;

		if( appStricmp(*List(i).Object, *CurrentCharacterClass) == 0 ) 
		{
			if ( Dir == -1 )
			{
				UseClass = PrevClass;
				break;
			}
			else if ( Dir == 0 )
			{
				UseClass = i;
				break;
			}
			else
			{
				UseNext = 1;
			}
		}
		PrevClass = i;
    }

	if( UseNext )
		UseClass = FirstClass;

	if( UseClass == -1 )
		UseClass = PrevClass;

	if( UseClass >= 0 && UseClass < List.Num() )
	{
		*CharacterClass = List(UseClass).Object;
		*ClassDesc = List(UseClass).Description;
	}
	else
	{
		*CharacterClass = TEXT("");
		*ClassDesc = TEXT("");
	}

}

void AActor::execGetNextThing( FFrame& Stack, RESULT_DECL )
{
	P_GET_STR(ThingClass);
    P_GET_STR(BaseClass);
    P_GET_STR(CurrentThing);
    P_GET_INT(Dir);
	P_GET_STR_REF(ThingName);
	P_GET_STR_REF(ThingDesc);
	P_GET_STR_REF(ExtraData);

	P_FINISH;

	TArray<FModelDataSpecification> List;
	GetModelDataSpecifications( List, *ThingClass, TEXT(""), 0 );

    INT UseThing     = -1;
	INT FirstThing   = -1;
	INT PrevThing    = -1;
	INT UseNext      = 0;

    for ( INT i=0; i<List.Num(); i++ )
    {
        INT NumParents = List(i).Parent.Num();

        // Go through each parent and see if the mesh matches the specified character class
        for ( INT j=0; j<NumParents; j++ )
        {
            if ( !appStricmp( *List(i).Parent(j), *BaseClass ) )
                break;
        }
        
        if ( j == NumParents )
            continue;

        // If we got here, the parents matched
        if( UseNext )
		{
			UseThing = i;
			UseNext = 0;
			break;
		}

		if( FirstThing == -1 )
			FirstThing = i;

		if( appStricmp(*List(i).Object, *CurrentThing) == 0 ) 
		{
			if ( Dir == -1 )
			{
				UseThing = PrevThing;
				break;
			}
			else if ( Dir == 0 )
			{
				UseThing = i;
				break;
			}
			else
			{
				UseNext = 1;
			}
		}
		PrevThing = i;
    }

	if( UseNext )
		UseThing = FirstThing;

	if( UseThing == -1 )
		UseThing = PrevThing;

	if( UseThing >= 0 && UseThing < List.Num() )
	{
		*ThingName = List(UseThing).Object;
		*ThingDesc = List(UseThing).Description;
		*ExtraData = List(UseThing).ExtraData;
	}
	else
	{
		*ThingName = TEXT("");
		*ThingDesc = TEXT("");
		*ExtraData = TEXT("");
	}
}


void AActor::execGetSkinList( FFrame& Stack, RESULT_DECL )
{
	P_GET_STR(CategoryName);
	P_GET_ARRAY_REF(FString, ParentNames);
	P_GET_ARRAY_REF(FString, SkinNames);
	P_GET_ARRAY_REF(FString, SkinDescs);    
	P_FINISH;

	INT SkinNum=0;
	INT ParentNum=0;
	UBOOL Match=false;

	// Category is the type of thing we are looking for
    // ParentNames specifies a list of meshes and textures that a skin may be applied to.
    
	// Get a list of textures that can be applied to this category
    TArray<FModelDataSpecification> List;
	GetModelDataSpecifications( List, TEXT("Texture"), *CategoryName, 0 );

	//debugf( TEXT( "Looking for match in Category %s" ), CategoryName );

	for( INT i=0; i<List.Num(); i++ ) // Iterate through all the Textures in the game that match this category
	{
        ParentNum = 0;
		UBOOL MatchParent[4];
		UBOOL EarlyMatch=false;

		appMemset( MatchParent, 0, sizeof( MatchParent ) );

		for ( INT k=0; k<List(i).Parent.Num(); k++ )
		{
			if ( !appStricmp( TEXT( "ANYTHING" ), *List(i).Parent(k) ) )
            {																
				SkinNames[SkinNum] = List(i).Object;
				SkinDescs[SkinNum] = List(i).Description;
				SkinNum++;								
				EarlyMatch = true;
				break;
            }
		}

		// Early out if we matched ANYTHING keyword
		if ( EarlyMatch )
			continue;

		// For each passed in parent name
        while( ParentNames[ParentNum].Len() )
		{   
            // For each parent listed in this texture, check for a match with the current ParentName value
            for ( INT k=0; k<List(i).Parent.Num(); k++ )
            {                
				TArray<FModelDataGroup> GroupNames;
                
                GetModelDataGroups( GroupNames, *List(i).Parent(k), false );

				//debugf( TEXT( "Checking PARENT %s" ), *List(i).Parent(k) );

                if ( GroupNames.Num() == 0 ) // Single skin specified as a parent
                {
                    // No matching groups, so treat the entry as a regular mesh/skin

					//debugf( TEXT( "Checking texture %s against PARENT %s" ), *List(i).Object, *ParentNames[ParentNum] );

					if ( !appStricmp( *List(i).Parent(k), *ParentNames[ParentNum] ) )
                    {												
						MatchParent[ParentNum] = true;
                    }
                }
                else // group specified as a parent
                {					
                    // Check to see if the current ParentName matches any of the group's members
                    for( INT groupnum=0; groupnum < GroupNames.Num(); groupnum++ )
                    {
						//debugf( TEXT( "Checking texture %s for group %s" ), *List(i).Object, *GroupNames(groupnum).Group );

						INT NumMembers = GroupNames(groupnum).Members.Num();

                        for ( INT membernum=0; membernum < NumMembers; membernum++ )
                        {
                            if ( !appStricmp( *GroupNames(groupnum).Members(membernum), *ParentNames[ParentNum] ) )
                            {
								//debugf( TEXT( "Match found in group %s" ), *GroupNames(groupnum).Group );
								MatchParent[ParentNum] = true;								
                            }
                        }
                    }
                }
            }
			ParentNum++;

			// Max number of parent names
			if ( ParentNum == 4 )
				break;
        }
		
		Match = true;

		if ( ParentNum == 0 ) // No parents passed in at all
		{
			Match = false;
		}
		else
		{
			// Check to see if we matched up all the parents
			for ( INT check=0; check<ParentNum; check++ )
			{
				if ( !MatchParent[check] )
				{
					Match = false;
				}
			}
		}

		if ( Match )
		{
			// This item was found to be a match
			SkinNames[SkinNum] = List(i).Object;
			SkinDescs[SkinNum] = List(i).Description;
			SkinNum++;
		}

	}
}


void AActor::execGetNextSkin( FFrame& Stack, RESULT_DECL )
{
	P_GET_ARRAY_REF(FString, ParentNames);
    P_GET_STR(CategoryName);
	P_GET_STR(CurrentSkin);
	P_GET_INT(Dir);
	P_GET_STR_REF(SkinName);
	P_GET_STR_REF(SkinDesc);
	P_FINISH;

	INT UseSkin = -1;
	INT FirstSkin = -1;
	INT PrevSkin = -1;
	INT UseNext = 0;

    // ParentNames specifies a list of meshes and textures that a skin may be applied to.

    // Get a list of textures that can be applied to this category
    TArray<FModelDataSpecification> List;
	GetModelDataSpecifications( List, TEXT("Texture"), *CategoryName, 0 );

	for( INT i=0; i<List.Num(); i++ ) // Iterate through all the Textures in the game that match this category
	{
        UBOOL   noMatch     = false;
        INT     parentNum   = 0;

        // Each ParentName must be found in the groups that this skin can be applied to
        while ( !noMatch )
        {
            // Reached the end of the parent names list
            if ( !ParentNames[parentNum].Len() )
                break;
                       
            // For each group in this texture, check the members for a match
            for ( INT k=0; k<List(i).Parent.Num(); k++ )
            {
                TArray<FModelDataGroup> GroupNames;

                // This should make only one match, but do it generally now
                GetModelDataGroups( GroupNames, *List(i).Parent(k), false );

                if ( GroupNames.Num() == 0 )
                {
                    // No matching groups, so treat the entry as a regular mesh/skin
                    if ( !appStricmp( *List(i).Parent(k), *ParentNames[parentNum] ) )
                    {
                        goto Match;
                    }
                }
                else
                {
                    // Check to see if the group's members match the ParentName
                    for( INT groupnum=0; groupnum < GroupNames.Num(); groupnum++ )
                    {
                        for ( INT membernum=0; membernum < GroupNames(groupnum).Members.Num(); membernum++ )
                        {
                            if ( !appStricmp( *GroupNames(groupnum).Members(membernum), *ParentNames[parentNum] ) )
                            {
                                // Match
                                goto Match;
                            }
                        }
                    }
                }
            }
Match:            
            parentNum++;

            if ( k == List(i).Parent.Num() ) // We went through all the groups but didn't find a match, get out of here
            {
                noMatch = true;            
                break;
            }
        }
        
		if ( noMatch )
           continue;

		if( FirstSkin == -1 )
			FirstSkin = i;

        if( UseNext )
		{
			UseSkin = i;
			UseNext = 0;
			break;
		}

		if( appStricmp(*List(i).Object, *CurrentSkin) == 0 ) 
		{
			if ( Dir == -1 )
			{
				UseSkin = PrevSkin;
				break;
			}
			else if ( Dir == 0 )
			{
				UseSkin = i;
				break;
			}
			else
			{
				UseNext = 1;
			}
		}
		PrevSkin = i;
	}
	
	if( UseNext )
		UseSkin = FirstSkin;

	// if we wanted to use the previous skin and
	// it didn't exist, choose the last skin.
	if( UseSkin == -1 )
		UseSkin = PrevSkin;

	if( UseSkin >= 0 && UseSkin < List.Num() )
	{
		*SkinName = List(UseSkin).Object;
		*SkinDesc = List(UseSkin).Description;
	}
	else
	{
		*SkinName = TEXT("");
		*SkinDesc = TEXT("");
	}
}

void AActor::execGetNextMDSMap( FFrame& Stack, RESULT_DECL )
{
    P_GET_STR(MapList);
    P_GET_STR(CurrentMap);
    P_GET_INT(Dir);
	P_GET_STR_REF(MapName);
	P_GET_STR_REF(MapDesc);

	P_FINISH;

	TArray<FModelDataSpecification> List;
	
	GetModelDataSpecifications( List, TEXT("Map"), TEXT(""), 0 );

    INT UseMap     = -1;
	INT FirstMap   = -1;
	INT PrevMap    = -1;
	INT UseNext     = 0;

    for ( INT i=0; i<List.Num(); i++ )
    {
        INT NumParents = List(i).Parent.Num();
        
		// Check to see if this map belongs to the maplist
		for ( INT j=0; j<NumParents; j++ )
		{
			if ( !appStricmp( *List(i).Parent(j), *MapList ) )
				break;
		}
    
		if ( j == NumParents )
			continue;

        if( UseNext )
		{
			UseMap = i;
			UseNext = 0;
			break;
		}

		if( FirstMap == -1 )
			FirstMap = i;

		if( appStricmp(*List(i).Object, *CurrentMap) == 0 ) 
		{
			if ( Dir == -1 )
			{
				UseMap = PrevMap;
				break;
			}
			else if ( Dir == 0 )
			{
				UseMap = i;
				break;
			}
			else
			{
				UseNext = 1;
			}
		}
		PrevMap = i;
    }

	if( UseNext )
		UseMap = FirstMap;

	if( UseMap == -1 )
		UseMap = PrevMap;

	if( UseMap >= 0 && UseMap < List.Num() )
	{
		*MapName	= List(UseMap).Object;
		*MapDesc	= List(UseMap).Description;
	}
	else
	{
		*MapName	= TEXT("");
		*MapDesc    = TEXT("");
	}
}

void AActor::execGetNextMDSMapList( FFrame& Stack, RESULT_DECL )
{
    P_GET_STR(GameClass);
    P_GET_STR(CurrentMapList);
    P_GET_INT(Dir);
	P_GET_STR_REF(MapListName);
	P_GET_STR_REF(MapListDesc);

	P_FINISH;

	TArray<FModelDataSpecification> List;
	
	GetModelDataSpecifications( List, TEXT("MapList"), TEXT(""), 0 );

    INT UseMapList     = -1;
	INT FirstMapList   = -1;
	INT PrevMapList    = -1;
	INT UseNext     = 0;

    for ( INT i=0; i<List.Num(); i++ )
    {
        INT NumParents = List(i).Parent.Num();
        
		if ( appStrlen( *GameClass ) )
		{
			for ( INT j=0; j<NumParents; j++ )
			{
				if ( !appStricmp( *List(i).Parent(j), *GameClass ) )
					break;
			}
    
			if ( j == NumParents )
				continue;
		}

        if( UseNext )
		{
			UseMapList = i;
			UseNext = 0;
			break;
		}

		if( FirstMapList == -1 )
			FirstMapList = i;

		if( appStricmp(*List(i).Object, *CurrentMapList) == 0 ) 
		{
			if ( Dir == -1 )
			{
				UseMapList = PrevMapList;
				break;
			}
			else if ( Dir == 0 )
			{
				UseMapList = i;
				break;
			}
			else
			{
				UseNext = 1;
			}
		}
		PrevMapList = i;
    }

	if( UseNext )
		UseMapList = FirstMapList;

	if( UseMapList == -1 )
		UseMapList = PrevMapList;

	if( UseMapList >= 0 && UseMapList < List.Num() )
	{
		*MapListName	= List(UseMapList).Object;
		*MapListDesc	= List(UseMapList).Description;
	}
	else
	{
		*MapListName	= TEXT("");
		*MapListDesc    = TEXT("");
	}
}

void APlayerPawn::execGetEntryLevel( FFrame& Stack, RESULT_DECL )
{
	P_FINISH;

	check(XLevel);
	check(XLevel->Engine);
	check((UGameEngine*)(XLevel->Engine));
	check(((UGameEngine*)(XLevel->Engine))->GEntry);

	*(ALevelInfo**)Result = ((UGameEngine*)(XLevel->Engine))->GEntry->GetLevelInfo();
}

void APlayerPawn::execResetKeyboard( FFrame& Stack, RESULT_DECL )
{
	P_FINISH;

	UViewport* Viewport = Cast<UViewport>(Player);
	if( Viewport && Viewport->Input )
		ResetConfig(Viewport->Input->GetClass());
}

void APawn::execFindBestInventoryPath( FFrame& Stack, RESULT_DECL )
{
	P_GET_FLOAT_REF(Weight);
	P_GET_UBOOL(bPredictRespawns);
	P_FINISH;

	clock(GetLevel()->FindPathCycles);
	AActor * bestPath = NULL;
	AActor * newPath;
	FLOAT BestWeight = findPathTowardBestInventory(newPath, 1, *Weight, bPredictRespawns);
	//debugf(NAME_DevPath,"BestWeight is %f compared to weight %f", BestWeight, *Weight);
	if ( BestWeight > *Weight )
	{
		bestPath = newPath;
		*Weight = BestWeight;
		//debugf(NAME_DevPath,"Recommend move to %s", bestPath->GetName());

		SpecialPause = 0.0;
		bShootSpecial = 0;

		if ( bestPath && bestPath->IsProbing(NAME_SpecialHandling) )
		{
			//debugf(NAME_DevPath,"Handle Special");
			HandleSpecial(bestPath);
			//debugf(NAME_DevPath,"Done Handle Special");
		}

		if ( bestPath == SpecialGoal )
			SpecialGoal = NULL;
	}
	unclock(GetLevel()->FindPathCycles);
	//debugf("Find path to time was %f", GetLevel()->FindPathCycles * MSecPerCycle);

	*(AActor**)Result = bestPath; 
}

void AActor::execGetMapName( FFrame& Stack, RESULT_DECL )
{
	P_GET_STR(Prefix);
	P_GET_STR(MapName);
	P_GET_INT(Dir);
	P_FINISH;

	*(FString*)Result = TEXT("");
	TCHAR Wildcard[256];
	TArray<FString> MapNames;
	appSprintf( Wildcard, TEXT("*.%s"), *FURL::DefaultMapExt );
	for( INT DoCD=0; DoCD<1+(GCdPath[0]!=0); DoCD++ )
	{
		for( INT i=0; i<GSys->Paths.Num(); i++ )
		{
			if( appStrstr( *GSys->Paths(i), Wildcard ) )
			{
				TCHAR Tmp[256]=TEXT("");
				if( DoCD )
				{
					appStrcat( Tmp, GCdPath );
					appStrcat( Tmp, TEXT("System") PATH_SEPARATOR );
				}
				appStrcat( Tmp, *GSys->Paths(i) );
				*appStrstr( Tmp, Wildcard )=0;
				appStrcat( Tmp, *Prefix );
				appStrcat( Tmp, Wildcard );
				TArray<FString>	TheseNames = GFileManager->FindFiles(Tmp,1,0);
				for( INT i=0; i<TheseNames.Num(); i++ )
				{
					for( INT j=0; j<MapNames.Num(); j++ )
						if( appStricmp(*MapNames(j),*TheseNames(i))==0 )
							break;
					if( j==MapNames.Num() )
						new(MapNames)FString(TheseNames(i));
				}
			}
		}
	}
	for( INT i=0; i<MapNames.Num(); i++ )
	{
		if( appStrcmp(*MapNames(i),*MapName)==0 )
		{
			INT Offset = i+Dir;
			if( Offset < 0 )
				Offset = MapNames.Num() - 1;
			else if( Offset >= MapNames.Num() )
				Offset = 0;
			*(FString*)Result = MapNames(Offset);
			return;
		}
	}
	if( MapNames.Num() > 0 )
		*(FString*)Result = MapNames(0);
	else
		*(FString*)Result = FString(TEXT(""));
}

void APlayerPawn::execConsoleCommand( FFrame& Stack, RESULT_DECL )
{
	P_GET_STR(Command);
	P_GET_UBOOL_OPTX(bAllowExecFuncs, 0); // CDH: inherited from Actor, ignored by PlayerPawn
	P_GET_UBOOL_OPTX(bExecsOnly, 0); // CDH: inherited from Actor, ignored by PlayerPawn
	P_FINISH;

	*(FString*)Result = TEXT("");
	if( Player )
	{
		FStringOutputDevice StrOut;
		Player->Exec( *Command, StrOut );
		*(FString*)Result = *StrOut;
	}
}

void APawn::execStopWaiting( FFrame& Stack, RESULT_DECL )
{
	P_FINISH;

	if( GetStateFrame()->LatentAction == EPOLL_Sleep )
		LatentFloat = -1.0;
}

/* CanSee()
returns true if LineOfSightto object and it is within creature's field of view
*/

void APawn::execCanSee( FFrame& Stack, RESULT_DECL )
{
	P_GET_ACTOR(Other);
	P_FINISH;

	*(DWORD*)Result = LineOfSightTo(Other, true);
}

/* PlayerCanSeeMe()
	returns true if actor is visible to some player
*/
void AActor::execPlayerCanSeeMe( FFrame& Stack, RESULT_DECL )
{
	P_FINISH;

	int seen = 0;
	int NetMode = GetLevel()->GetLevelInfo()->NetMode;
	if ( (NetMode == NM_Standalone)
		|| ((NetMode == NM_Client) && (bNetTemporary || (Role == ROLE_Authority))) )
	{
		// just check local player visibility
		for( INT i=0; i<GetLevel()->Engine->Client->Viewports.Num(); i++ )
			if ( TestCanSeeMe( GetLevel()->Engine->Client->Viewports(i)->Actor ) )
			{
				seen = 1;
				break;
			}
	}
	else
	{
		for ( APawn *next=GetLevel()->GetLevelInfo()->PawnList; next!=NULL; next=next->nextPawn )
			if ( TestCanSeeMe((APlayerPawn *)next) )
			{
				seen = 1;
				break;
			}
	}
	*(DWORD*)Result = seen;
}

int AActor::TestCanSeeMe( APlayerPawn *Viewer )
{
	if ( !Viewer )
		return 0;
	if ( Viewer->ViewTarget == this )
		return 1;

	float distSq = (Location - Viewer->Location).SizeSquared();

	return ( (distSq < 100000.f * (CollisionRadius + 3.6)) 
		&& (Viewer->bBehindView 
			|| (Square(Viewer->ViewRotation.Vector() | (Location - Viewer->Location)) >= 0.25 * distSq)) 
		&& Viewer->LineOfSightTo(this, 1) );
}

/* execDescribeSpec - returns spec components to script
*/
void ANavigationPoint::execdescribeSpec( FFrame& Stack, RESULT_DECL )
{
	P_GET_INT(iSpec);
	P_GET_ACTOR_REF(Start);
	P_GET_ACTOR_REF(End);
	P_GET_INT_REF(reachFlags);
	P_GET_INT_REF(distance);
	P_FINISH;

	FReachSpec spec = GetLevel()->ReachSpecs(iSpec);
	*Start          = spec.Start;
	*End            = spec.End;
	*reachFlags     = spec.reachFlags;
	*distance       = spec.distance;
}

/*-----------------------------------------------------------------------------
	Pawn related functions.
-----------------------------------------------------------------------------*/

void APawn::execPickTarget( FFrame& Stack, RESULT_DECL )
{
	P_GET_FLOAT_REF(bestAim);
	P_GET_FLOAT_REF(bestDist);
	P_GET_VECTOR(FireDir);
	P_GET_VECTOR(projStart);
	P_FINISH;
	APawn *pick = NULL;
	for ( APawn *next=GetLevel()->GetLevelInfo()->PawnList; next!=NULL; next=next->nextPawn )
	{
		/*if ( (next != this) && (next->Health > 0) && next->bProjTarget
			&& (!PlayerReplicationInfo || !next->PlayerReplicationInfo
				|| !GetLevel()->GetLevelInfo()->Game->bTeamGame
				|| (PlayerReplicationInfo->Team != next->PlayerReplicationInfo->Team)) )*/
		if ( (next != this) && (next->Health > 0) && next->bProjTarget )
		{
			FLOAT newAim = FireDir | (next->Location - projStart);
			if ( newAim > 0 )
			{
				FLOAT FireDist = (next->Location - projStart).SizeSquared();
				if ( FireDist < 4000000.f )
				{
					FireDist = appSqrt(FireDist);
					newAim = newAim/FireDist;
					if ( (newAim > *bestAim) && LineOfSightTo(next) )
					{
						pick = next;
						*bestAim = newAim;
						*bestDist = FireDist;
					}
				}
			}
		}
	}
	*(APawn**)Result = pick; 
}

void APawn::execPickAnyTarget( FFrame& Stack, RESULT_DECL )
{
	P_GET_FLOAT_REF(bestAim);
	P_GET_FLOAT_REF(bestDist);
	P_GET_VECTOR(FireDir);
	P_GET_VECTOR(projStart);
	P_FINISH;
	AActor *pick = NULL;

	for( INT iActor=0; iActor<GetLevel()->Actors.Num(); iActor++ )
		if( GetLevel()->Actors(iActor) )
		{
			AActor* next = GetLevel()->Actors(iActor);
			if ( next->bProjTarget && !next->IsA(APawn::StaticClass()) )
			{
				FLOAT newAim = FireDir | (next->Location - projStart);
				if ( newAim > 0 )
				{
					FLOAT FireDist = (next->Location - projStart).SizeSquared();
					if ( FireDist < 4000000.f )
					{
						FireDist = appSqrt(FireDist);
						newAim = newAim/FireDist;
						if ( (newAim > *bestAim) && LineOfSightTo(next) )
						{
							pick = next;
							*bestAim = newAim;
							*bestDist = FireDist;
						}
					}
				}
			}
		}

	*(AActor**)Result = pick; 
}

void APawn::execAddPawn( FFrame& Stack, RESULT_DECL )
{
	P_FINISH;

	nextPawn = GetLevel()->GetLevelInfo()->PawnList;
	GetLevel()->GetLevelInfo()->PawnList = this;
}

void APawn::execRemovePawn( FFrame& Stack, RESULT_DECL )
{
	P_FINISH;

	APawn *next = GetLevel()->GetLevelInfo()->PawnList;
	if ( next == this )
		GetLevel()->GetLevelInfo()->PawnList = next->nextPawn;
	else
	{
		while ( next )
		{
			if ( next->nextPawn == this )
			{
				next->nextPawn = nextPawn;
				break;
			}
			next = next->nextPawn;
		}
	}
}

/* execWaitForLanding()
wait until physics is not PHYS_Falling
*/
void APawn::execWaitForLanding( FFrame& Stack, RESULT_DECL )
{
	P_FINISH;

	LatentFloat = 0.5;
	if (Physics == PHYS_Falling)
		GetStateFrame()->LatentAction = AI_PollWaitForLanding;
}

void APawn::execPollWaitForLanding( FFrame& Stack, RESULT_DECL )
{
	if( Physics != PHYS_Falling )
	{
		GetStateFrame()->LatentAction = 0;
	}
	else
	{
		FLOAT DeltaSeconds = *(FLOAT*)Result;
		LatentFloat -= DeltaSeconds;
		if ( LatentFloat < 0 )
			eventLongFall();
	}
}
IMPLEMENT_FUNCTION( APawn, AI_PollWaitForLanding, execPollWaitForLanding);

void APawn::execPickWallAdjust( FFrame& Stack, RESULT_DECL )
{
	P_FINISH;

	clock(GetLevel()->FindPathCycles);
	*(DWORD*)Result = PickWallAdjust();
	unclock(GetLevel()->FindPathCycles);
}

void APawn::execFindStairRotation( FFrame& Stack, RESULT_DECL )
{
	P_GET_FLOAT(deltaTime);
	P_FINISH;

	if (deltaTime > 0.33)
	{
		*(DWORD*)Result = ViewRotation.Pitch;
		return;
	}
	if (ViewRotation.Pitch > 32768)
		ViewRotation.Pitch = (ViewRotation.Pitch & 65535) - 65536;
	
	FCheckResult Hit(1.0);
	FRotator LookRot = ViewRotation;
	LookRot.Pitch = 0;
	FVector Dir = LookRot.Vector();
	FVector EyeSpot = Location + FVector(0,0,BaseEyeHeight);
	FLOAT height = CollisionHeight + BaseEyeHeight; 
	FVector CollisionSlice(CollisionRadius,CollisionRadius,1);

	GetLevel()->SingleLineCheck(Hit, this, EyeSpot + 2 * height * Dir, EyeSpot, TRACE_VisBlocking, CollisionSlice);
	FLOAT Dist = 2 * height * Hit.Time;
	int stairRot = 0;
	if (Dist > 0.8 * height)
	{
		FVector Spot = EyeSpot + 0.5 * Dist * Dir;
		FLOAT Down = 3 * height;
		GetLevel()->SingleLineCheck(Hit, this, Spot - FVector(0,0,Down), Spot, TRACE_VisBlocking, CollisionSlice);
		if (Hit.Time < 1.0)
		{
			FLOAT firstDown = Down * Hit.Time;
			if (firstDown < 0.7 * height - 6.0) // then up or level
			{
				Spot = EyeSpot + Dist * Dir;
				GetLevel()->SingleLineCheck(Hit, this, Spot - FVector(0,0,Down), Spot, TRACE_VisBlocking, CollisionSlice);
				stairRot = ::Max(0, ViewRotation.Pitch);
				if ( Down * Hit.Time < firstDown - 10 ) 
					stairRot = 5400;
			}
			else if  (firstDown > 0.7 * height + 6.0) // then down or level
			{
				GetLevel()->SingleLineCheck(Hit, this, Location + 0.9*Dist*Dir, Location, TRACE_VisBlocking);
				if (Hit.Time == 1.0)
				{
					Spot = EyeSpot + Dist * Dir;
					GetLevel()->SingleLineCheck(Hit, this, Spot - FVector(0,0,Down), Spot, TRACE_VisBlocking, CollisionSlice);
					stairRot = Min(0, ViewRotation.Pitch);
					if (Down * Hit.Time > firstDown + 10)
						stairRot = -5000;
				}
			}
		}
	}
	INT Diff = Abs(ViewRotation.Pitch - stairRot);
	if ( Diff > 0 )
	{
		FLOAT RotRate = 8;
		if ( Diff < 1000 )
			RotRate = 8000/Diff; 

		RotRate = ::Min(1.f, RotRate * deltaTime);
		stairRot = int(FLOAT(ViewRotation.Pitch) * ( 1 - RotRate) + FLOAT(stairRot) * RotRate);
	}
	*(DWORD*)Result = stairRot; 
}

void APawn::execEAdjustJump( FFrame& Stack, RESULT_DECL )
{
	FVector Landing;
	FVector vel = Velocity;
	SuggestJumpVelocity(Destination, vel);

	P_FINISH;

	*(FVector*)Result = vel;
}

void APawn::execactorReachable( FFrame& Stack, RESULT_DECL )
{
	P_GET_ACTOR(actor);
	P_FINISH;
	
	if ( !actor )
	{
		//debugf(NAME_DevPath,"Warning: No goal for ActorReachable by %s in %s",GetName(), GetStateFrame()->Describe() );
		*(DWORD*)Result = 0; 
		return;
	}
	clock(GetLevel()->FindPathCycles);
	AActor *RealActor = NULL;

	if ( actor->IsA(AInventory::StaticClass()) && ((AInventory *)actor)->myMarker )
	{
		RealActor = actor;
		actor = ((AInventory *)actor)->myMarker;
	}
	if ( actor->IsA(ANavigationPoint::StaticClass()) && GetLevel()->ReachSpecs.Num() && (CollisionRadius <= MAXCOMMONRADIUS) )
	{
		FLOAT MaxDistSq = ::Max(48.f, CollisionRadius);
		FVector Dir;
		INT bOnPath = 0;
		MaxDistSq = MaxDistSq * MaxDistSq;
		if ( MoveTarget && MoveTarget->IsA(ANavigationPoint::StaticClass())
			&& (Abs(MoveTarget->Location.Z - Location.Z) < CollisionHeight) ) 
		{
			Dir = MoveTarget->Location - Location;
			Dir.Z = 0;
			if ( (Dir | Dir) < MaxDistSq )
			{
				bOnPath = 1;
				if ( (MoveTarget == actor) || CanMoveTo(MoveTarget, actor) )
				{
					*(DWORD*)Result = 1;
					unclock(GetLevel()->FindPathCycles);
					return;
				}
			}
		}
		ANavigationPoint *Nav = GetLevel()->GetLevelInfo()->NavigationPointList;
		while (Nav)
		{
			if ( Abs(Nav->Location.Z - Location.Z) < CollisionHeight )
			{
				Dir = Nav->Location - Location;
				Dir.Z = 0;
				if ( (Dir | Dir) < MaxDistSq ) 
				{
					bOnPath = 1;
					if ( (Nav == actor) || CanMoveTo(Nav, actor) )
					{
						*(DWORD*)Result = 1;
						unclock(GetLevel()->FindPathCycles);
						return;
					}
				}
			}
			Nav = Nav->nextNavigationPoint;
		}
		if ( bOnPath && (Physics != PHYS_Flying) )
		{
			*(DWORD*)Result = 0;
			unclock(GetLevel()->FindPathCycles);
			return;
		}
	}	
	if ( RealActor )
		actor = RealActor;

	*(DWORD*)Result = actorReachable(actor);  
	unclock(GetLevel()->FindPathCycles);
}

void APawn::execpointReachable( FFrame& Stack, RESULT_DECL )
{
	P_GET_VECTOR(point);
	P_FINISH;

	clock(GetLevel()->FindPathCycles);
	*(DWORD*)Result = pointReachable(point);  
	unclock(GetLevel()->FindPathCycles);
}

/* FindPathTo()
returns the best pathnode toward a point - even if point is directly reachable
If there is no path, returns None
By default clears paths.  If script wants to preset some path weighting, etc., then
it can explicitly clear paths using execClearPaths before presetting the values and 
calling FindPathTo with clearpath = 0

  FIXME add optional bBlockDoors (no paths through doors), bBlockTeleporters, bBlockSwitches,
  maxNodes (max number of nodes), etc.
*/

void APawn::execFindPathTo( FFrame& Stack, RESULT_DECL )
{
	P_GET_VECTOR(point);
	P_GET_INT_OPTX(bSinglePath, 0); 
	P_GET_UBOOL_OPTX(bClearPaths, 1);
	P_FINISH;

	clock(GetLevel()->FindPathCycles);
	AActor * bestPath = NULL;
	AActor * newPath;
	if (findPathTo(point, bSinglePath, newPath, bClearPaths))
		bestPath = newPath;
	SpecialPause = 0.0;
	bShootSpecial = 0;

	if ( bestPath && bestPath->IsProbing(NAME_SpecialHandling) )
	{
		//debugf(NAME_DevPath,"Handle Special");
		HandleSpecial(bestPath);
		//debugf(NAME_DevPath,"Done Handle Special");
	}

	if ( bestPath == SpecialGoal )
		SpecialGoal = NULL;
	unclock(GetLevel()->FindPathCycles);
	//debugf("Find path to time was %f", GetLevel()->FindPathCycles * MSecPerCycle);

	*(AActor**)Result = bestPath; 
}

void APawn::execFindPathToward( FFrame& Stack, RESULT_DECL )
{
	P_GET_ACTOR(goal);
	P_GET_INT_OPTX(bSinglePath, 0);
	P_GET_UBOOL_OPTX(bClearPaths, 1);
	P_FINISH;

	if ( !goal )
	{
		//debugf(NAME_DevPath,"Warning: No goal for FindPathToward by %s in %s",GetName(), GetStateFrame()->Describe() );
		*(AActor**)Result = NULL; 
		return;
	}
	clock(GetLevel()->FindPathCycles);
	AActor * bestPath = NULL;
	AActor * newPath;
	if (findPathToward(goal, bSinglePath, newPath, bClearPaths))
		bestPath = newPath;
	SpecialPause = 0.0;
	bShootSpecial = 0;

	if ( bestPath && bestPath->IsProbing(NAME_SpecialHandling) )
	{
		//debugf(NAME_DevPath,"Handle Special");
		HandleSpecial(bestPath);
		//debugf(NAME_DevPath,"Done Handle Special");
	}

	if ( bestPath == SpecialGoal )
		SpecialGoal = NULL;
	unclock(GetLevel()->FindPathCycles);
	//debugf("Find path toward time was %f", GetLevel()->FindPathCycles * MSecPerCycle);

	*(AActor**)Result = bestPath; 
}

/* FindRandomDest()
returns a random pathnode which is reachable from the creature's location
*/
void APawn::execFindRandomDest( FFrame& Stack, RESULT_DECL )
{
	P_GET_UBOOL_OPTX(bClearPaths, 1);
	P_FINISH;

	clock(GetLevel()->FindPathCycles);
	if (bClearPaths)
		clearPaths();
	ANavigationPoint * bestPath = NULL;
	AActor * newPath;
	if ( findRandomDest(newPath) )
		bestPath = (ANavigationPoint *)newPath;

	unclock(GetLevel()->FindPathCycles);

	*(ANavigationPoint**)Result = bestPath; 
}

void APawn::execClearPaths( FFrame& Stack, RESULT_DECL )
{
	P_FINISH;

	clock(GetLevel()->FindPathCycles);
	clearPaths(); 
	unclock(GetLevel()->FindPathCycles);
}

/*MakeNoise
- check to see if other creatures can hear this noise
*/
void AActor::execMakeNoise( FFrame& Stack, RESULT_DECL )
{
	P_GET_FLOAT(Loudness);
	P_FINISH;
	
	//debugf(" %s Make Noise with instigator", GetFullName(),Instigator->GetClass()->GetName());
	if ( GetLevel()->GetLevelInfo()->NetMode != NM_Client )
		CheckNoiseHearing(Loudness);
}

void APawn::execLineOfSightTo( FFrame& Stack, RESULT_DECL )
{
	P_GET_ACTOR(Other);
	P_FINISH;
	
	*(DWORD*)Result = LineOfSightTo(Other);
}

/* execMoveTo()
start moving to a point -does not use routing
Destination is set to a point
//FIXME - don't use ground speed for flyers (or set theirs = flyspeed)
*/
void APawn::execMoveTo( FFrame& Stack, RESULT_DECL )
{
	P_GET_VECTOR(dest);
	P_GET_FLOAT_OPTX(speed, 1.0);
	P_FINISH;

	FVector Move = dest - Location;
	MoveTarget = NULL;
	bReducedSpeed = 0;
	DesiredSpeed = ::Max(0.f, Min(MaxDesiredSpeed, speed));
	FLOAT MoveSize = Move.Size();
	setMoveTimer(MoveSize); 
	GetStateFrame()->LatentAction = AI_PollMoveTo;
	Destination = dest;
	Focus = dest;
	rotateToward(Focus);
	moveToward(Destination);
}

void APawn::execPollMoveTo( FFrame& Stack, RESULT_DECL )
{
	rotateToward(Focus);
	if( moveToward(Destination) )
		GetStateFrame()->LatentAction = 0;
}
IMPLEMENT_FUNCTION( APawn, AI_PollMoveTo, execPollMoveTo);

/* execMoveToward()
start moving toward a goal actor -does not use routing
MoveTarget is set to goal
*/
void APawn::execMoveToward( FFrame& Stack, RESULT_DECL )
{
	P_GET_ACTOR(goal);
	P_GET_FLOAT_OPTX(speed, 1.0);
	P_FINISH;

	if (!goal)
	{
		//Stack.Log("MoveToward with no goal");
		return;
	}

	FVector Move = goal->Location - Location;	
	bReducedSpeed = 0;
	DesiredSpeed = ::Max(0.f, Min(MaxDesiredSpeed, speed));
	if (goal->IsA(APawn::StaticClass()))
		MoveTimer = 1.2; //max before re-assess movetoward
	else
	{
		FLOAT MoveSize = Move.Size();
		setMoveTimer(MoveSize);
	}
	MoveTarget = goal;
	Destination = MoveTarget->Location; 
	Focus = Destination;
	GetStateFrame()->LatentAction = AI_PollMoveToward;
	rotateToward(Focus);
	moveToward(Destination);
}

void APawn::execPollMoveToward( FFrame& Stack, RESULT_DECL )
{
	if( !MoveTarget )
	{
		//Stack.Log("MoveTarget cleared during movetoward");
		GetStateFrame()->LatentAction = 0;
		return;
	}

	Destination = MoveTarget->Location;
	if( Physics==PHYS_Flying && MoveTarget->IsA(APawn::StaticClass()) )
		Destination.Z += 0.7 * MoveTarget->CollisionHeight;
	else if( Physics == PHYS_Spider )
		Destination = Destination - MoveTarget->CollisionRadius * Floor;

	Focus = Destination;
	rotateToward(Focus);
	FLOAT oldDesiredSpeed = DesiredSpeed;
	if ( bAdvancedTactics && (Physics == PHYS_Walking) )
		eventAlterDestination();
	if( moveToward(Destination) )
		GetStateFrame()->LatentAction = 0;
	if ( bAdvancedTactics && (Physics == PHYS_Walking) )
		Destination = MoveTarget->Location;
	if( MoveTarget->IsA(APawn::StaticClass()) )
	{
		DesiredSpeed = oldDesiredSpeed; //don't slow down when moving toward a pawn
		if (!bCanSwim && MoveTarget->Region.Zone->bWaterZone)
			MoveTimer = -1.0; //give up
	}
}
IMPLEMENT_FUNCTION( APawn, AI_PollMoveToward, execPollMoveToward);

/* execStrafeTo()
Strafe to Destination, pointing at Focus
*/
void APawn::execStrafeTo( FFrame& Stack, RESULT_DECL )
{
	P_GET_VECTOR(Dest);
	P_GET_VECTOR(FocalPoint);
	P_GET_FLOAT_OPTX(speed, 1.0);
	P_FINISH;

	FVector Move = Dest - Location;
	MoveTarget = NULL;
	bReducedSpeed = 0;
/*	if (bIsPlayer)
		DesiredSpeed = MaxDesiredSpeed;
	else
		DesiredSpeed = 0.8 * MaxDesiredSpeed;
*/
	DesiredSpeed = ::Max(0.f, Min(MaxDesiredSpeed, speed));
	FLOAT MoveSize = Move.Size();
	setMoveTimer(MoveSize); 
	GetStateFrame()->LatentAction = AI_PollStrafeTo;
	Destination = Dest;
	Focus = FocalPoint;
	rotateToward(Focus);
	moveToward(Destination);
}

void APawn::execPollStrafeTo( FFrame& Stack, RESULT_DECL )
{
	rotateToward( Focus );
	if( moveToward(Destination) )
		GetStateFrame()->LatentAction = 0;
}
IMPLEMENT_FUNCTION( APawn, AI_PollStrafeTo, execPollStrafeTo);

/* execStrafeFacing()
strafe to Destination, pointing at FaceTarget
*/
void APawn::execStrafeFacing( FFrame& Stack, RESULT_DECL )
{
	P_GET_VECTOR(Dest)
	P_GET_ACTOR(goal);
	P_GET_FLOAT_OPTX(speed,1.0)
	P_FINISH;

	if (!goal)
	{
		//Stack.Log("StrafeFacing without goal");
		return;
	}
	FVector Move = Dest - Location;	
	bReducedSpeed = 0;
//	if (bIsPlayer)
//		DesiredSpeed = MaxDesiredSpeed;
//	else
//		DesiredSpeed = 0.8 * MaxDesiredSpeed;
	DesiredSpeed = ::Max(0.f, Min(MaxDesiredSpeed, speed));
	FLOAT MoveSize = Move.Size();
	setMoveTimer(MoveSize); 
	Destination = Dest;
	FaceTarget = goal;
	Focus = FaceTarget->Location;
	GetStateFrame()->LatentAction = AI_PollStrafeFacing;
	rotateToward(Focus);
	moveToward(Destination);
}

void APawn::execPollStrafeFacing( FFrame& Stack, RESULT_DECL )
{
	if( !FaceTarget )
	{
		//Stack.Log("FaceTarget cleared during strafefacing");
		GetStateFrame()->LatentAction = 0;
		return;
	}

	Focus = FaceTarget->Location;
	FVector RealDest = Destination;
	rotateToward( Focus );
	if ( bAdvancedTactics && (Physics == PHYS_Walking) )
		eventAlterDestination();
	if( moveToward(Destination) )
		GetStateFrame()->LatentAction = 0;
	Destination = RealDest;
}
IMPLEMENT_FUNCTION( APawn, AI_PollStrafeFacing, execPollStrafeFacing);

/* execTurnToward()
turn toward FaceTarget
*/
void APawn::execTurnToward( FFrame& Stack, RESULT_DECL )
{
	P_GET_ACTOR(goal);
	P_FINISH;
	
	if (!goal)
		return;

	FaceTarget = goal;
	GetStateFrame()->LatentAction = AI_PollTurnToward;
	if ( !bCanStrafe && ((Physics == PHYS_Flying) || (Physics == PHYS_Swimming)) )
		Acceleration = Rotation.Vector() * AccelRate;

	Focus = FaceTarget->Location;
	rotateToward(Focus);
}

void APawn::execPollTurnToward( FFrame& Stack, RESULT_DECL )
{
	if( !FaceTarget )
	{
		//Stack.Log("FaceTarget cleared during turntoward");
		GetStateFrame()->LatentAction = 0;
		return;
	}

	if( !bCanStrafe && (Physics==PHYS_Flying || Physics==PHYS_Swimming) )
		Acceleration = Rotation.Vector() * AccelRate;

	Focus = FaceTarget->Location;
	if( rotateToward(Focus) )
		GetStateFrame()->LatentAction = 0;  
}
IMPLEMENT_FUNCTION( APawn, AI_PollTurnToward, execPollTurnToward);

/* execTurnTo()
Turn to focus
*/
void APawn::execTurnTo( FFrame& Stack, RESULT_DECL )
{
	P_GET_VECTOR(FocalPoint);
	P_FINISH;

	MoveTarget = NULL;
	GetStateFrame()->LatentAction = AI_PollTurnTo;
	Focus = FocalPoint;
	if ( !bCanStrafe && ((Physics == PHYS_Flying) || (Physics == PHYS_Swimming)) )
		Acceleration = Rotation.Vector() * AccelRate;

	rotateToward(Focus);
}

void APawn::execPollTurnTo( FFrame& Stack, RESULT_DECL )
{
	if( !bCanStrafe && (Physics==PHYS_Flying || Physics==PHYS_Swimming) )
		Acceleration = Rotation.Vector() * AccelRate;

	if( rotateToward(Focus) )
		GetStateFrame()->LatentAction = 0;  
}
IMPLEMENT_FUNCTION( APawn, AI_PollTurnTo, execPollTurnTo);

//=================================================================================
void APawn::setMoveTimer(FLOAT MoveSize)
{
	FLOAT MaxSpeed = 200.0; //safety in case called with Physics = PHYS_None (shouldn't be)

	if (Physics == PHYS_Walking)
		MaxSpeed = GroundSpeed;
	else if (Physics == PHYS_Falling)
		MaxSpeed = GroundSpeed;
	else if (Physics == PHYS_Flying)
		MaxSpeed = AirSpeed;
	else if (Physics == PHYS_Swimming)
		MaxSpeed = WaterSpeed;
	else if (Physics == PHYS_Spider)
		MaxSpeed = GroundSpeed;

	if ( DesiredSpeed * MaxSpeed == 0.f )
		MoveTimer = 0.5;
	else
		MoveTimer = 1.0 + 1.3 * MoveSize/(DesiredSpeed * MaxSpeed); 
}

/* moveToward()
move Actor toward a point.  Returns 1 if Actor reached point
(Set Acceleration, let physics do actual move)
*/
int APawn::moveToward(const FVector &Dest)
{
	FVector Direction = Dest - Location;
	if( Enemy != NULL && bRotateToEnemy )
	{
		rotateToward( Enemy->Location );
	}
	if (Physics == PHYS_Walking) 
		Direction.Z = 0.0;
	else if (Physics == PHYS_Falling)
	{
		// use air control if low grav
		if ( Region.Zone->ZoneGravity.Z > 0.9 * ((AZoneInfo *)Region.Zone->GetClass()->GetDefaultObject())->ZoneGravity.Z )
		{
			Direction.Z = 0;
			Acceleration = Direction.SafeNormal();
			Acceleration *= AccelRate;
			if ( (Velocity.Z < 0) && (Location.Z + 100 < Dest.Z) )
				return 1;
		}
		return 0;
	}
	if ( MoveTarget && MoveTarget->IsA(AInventory::StaticClass()) 
		 && (Abs(Location.Z - MoveTarget->Location.Z) < CollisionHeight)
		 && (Square(Location.X - MoveTarget->Location.X) + Square(Location.Y - MoveTarget->Location.Y) < Square(CollisionRadius)) )
		 MoveTarget->eventTouch(this);
	
	FLOAT Distance = Direction.Size();
	INT bGlider = ( !bCanStrafe && ((Physics == PHYS_Flying) || (Physics == PHYS_Swimming)) ); 

	if ( (Direction.X * Direction.X + Direction.Y * Direction.Y < 256) 
			&& (Abs(Direction.Z) < ::Max(48.f, CollisionHeight)) ) 
	{
		if ( !bGlider )
			Acceleration = FVector(0,0,0);
		return 1;
	}
	else if ( bGlider )
		Direction = Rotation.Vector();
	else if ( Distance > 0.f )
		Direction = Direction/Distance;

	Acceleration = Direction * AccelRate;

	if (MoveTimer < 0.0)
		return 1; //give up
	if (MoveTarget && MoveTarget->IsA(APawn::StaticClass()))
	{
		if (Distance < CollisionRadius + MoveTarget->CollisionRadius + 0.8 * MeleeRange)
			return 1;
		return 0;
	}

	FLOAT speed = Velocity.Size(); 

	if ( !bGlider && (speed > 100) )
	{
		FVector VelDir = Velocity/speed;
		Acceleration -= 0.2 * (1 - (Direction | VelDir)) * speed * (VelDir - Direction); 
	}
	if (Distance < 1.4 * AvgPhysicsTime * speed )
	{
		if (!bReducedSpeed) //haven't reduced speed yet
		{
			DesiredSpeed = 0.5 * DesiredSpeed;
			bReducedSpeed = 1;
		}
		if (speed > 0)
			DesiredSpeed = Min(DesiredSpeed, 200.f/speed);
		if ( bGlider ) 
			return 1;
	}
	return 0;
}

/* rotateToward()
rotate Actor toward a point.  Returns 1 if target rotation achieved.
(Set DesiredRotation, let physics do actual move)
*/
int APawn::rotateToward(const FVector &FocalPoint)
{
	if (Physics == PHYS_Spider)
		return 1;
	FVector Direction = FocalPoint - Location;
	FRotator TempRot = FRotator( 0, 0, 0 );

	if( bFlyingVehicle )
		TempRot.Pitch = DesiredRotation.Pitch;

	// Rotate toward destination
	DesiredRotation = Direction.Rotation();
	if( bFlyingVehicle )
		DesiredRotation.Pitch = TempRot.Pitch;
	DesiredRotation.Yaw = DesiredRotation.Yaw & 65535;
	if ( (Physics == PHYS_Walking) && (!MoveTarget || !MoveTarget->IsA(APawn::StaticClass())) )
		DesiredRotation.Pitch = 0;

	//only base success on Yaw 
	int success = (Abs(DesiredRotation.Yaw - (Rotation.Yaw & 65535)) < 2000);
	if (!success) //check if on opposite sides of zero
		success = (Abs(DesiredRotation.Yaw - (Rotation.Yaw & 65535)) > 63535);	

	return success;
}

DWORD APawn::LineOfSightTo(AActor *Other, UBOOL bCheckCanSee)
{
	if (!Other)
		return 0;

	/*	CDH:
		bShowSelf was a complete misnomer; it had absolute nothing to do with showing yourself,
		but rather that it's the line of sight path taken by ShowSelf and CanSee.  Basically it's
		the "CanSee" line of sight check, i.e. a true line of "sight", checking a pawn's
		peripheral vision and all that jazz.  If bShowSelf was false, a regular LOS check is
		performed.  bShowSelf has been renamed to bCheckCanSee to correct this misnomer.
	*/

	/*	CDH:
		This function has been somewhat altered to remove some of the inherent "silliness",
		i.e. some of the inappropriate checks for players or pawns vs. non players and non pawns,
		as well as some inappropriate distance rejections based on these values, etc.
	*/

	//FIXME - when PVS, only do this test if in same PVS


	if (Other == Enemy)
		bCheckCanSee = 0;

	FLOAT DistanceSq = (Other->Location - Location).SizeSquared();
	FLOAT MaxDistanceSq; 

	if (bCheckCanSee || this->bForcePeriphery)
	{
		// check initial maximum distance
		FLOAT MaxDistance = SightRadius;

		if (Other->IsA(APawn::StaticClass()))
		{
			MaxDistance *= Min(1.f, (FLOAT)((APawn*)Other)->Visibility * (1.f/128.f));
			MaxDistance = Min(10000.f, MaxDistance); // CDH: bIsPlayer checks removed
		}

		MaxDistanceSq = MaxDistance * MaxDistance;

		if (DistanceSq > MaxDistanceSq)
			return 0;
		// check field of view
		// CDH: This calculation results in a bit of "hawk eye" peripheral vision checking, should be moved to script evaluation
		FVector SightDir = (Other->Location - Location).SafeNormal();
		FLOAT Stimulus = (SightDir | Rotation.Vector()) - PeripheralVision; // CDH: Note: this is the only engine-side use of PeripheralVision
		if ( Stimulus > 0 )
			Stimulus = 0.8 * Stimulus + 0.2;
		else
			Stimulus = 0.17 * Stimulus + 0.2;
		if ( Stimulus <= 0 )
			return 0;		

		FLOAT HeightMod = Abs(Other->Location.Z - Location.Z)/(::Max(1.f, Skill + 1));

		DistanceSq += HeightMod * HeightMod;
		if( !bNoRotConstraint )
			DistanceSq /= Stimulus * Stimulus;
		
		// JC: Multiplying MaxDistSq by 4 to increase distance.
		if (DistanceSq > ( MaxDistanceSq * 4 ))
			return 0;		
	}
	else
	{
		FLOAT MaxDistance = 4000.f;
		if (Other->IsA(APawn::StaticClass()))
		{
			MaxDistance *= Min(1.f, (FLOAT)(((APawn*)Other)->Visibility + 16) * 0.015f);
			MaxDistance = Min(4000.f, MaxDistance);
		}
		MaxDistanceSq = MaxDistance * MaxDistance;

		if (DistanceSq > MaxDistanceSq)
		{
			if( !Other->IsA( APawn::StaticClass()) || !( (APawn*)Other )->bNoHeightMod )
				return 0;
		}
	}

	FVector ViewPoint = Location;
	ViewPoint.Z += BaseEyeHeight; // look from eyes

	if (LineCheckTranslucency(Other->Location,ViewPoint))
	{
		if (Other == Enemy)
			eventSawEnemy();
		return 1;
	}
	if (Other == Enemy)
	{
		if (LineCheckTranslucency(Other->Location, Location))
		{
			eventSawEnemy();
			return 1;
		}
	}

	if (DistanceSq > 1000.f*1000.f)
	{
		if( !Other->IsA( APawn::StaticClass()) || !( (APawn*)Other )->bNoHeightMod )
			return 0;
	}

	// try viewpoint to head
	if (!bCheckCanSee)
	{
		FVector OtherBody = Other->Location;
		OtherBody.Z += Other->CollisionHeight * 0.8;
		if (LineCheckTranslucency(OtherBody, ViewPoint))
			return 1;
	}

	if ((DistanceSq > 500.f*500.f) /* || !Other->IsA(APawn::StaticClass())*/)
	{
		if( !Other->IsA( APawn::StaticClass()) || !( (APawn*)Other )->bNoHeightMod )
			return 0;
	}

	// try checking sides - look at dist to four side points, and cull furthest and closest
	FVector Points[4];
	Points[0] = Other->Location - FVector(Other->CollisionRadius, -1 * Other->CollisionRadius, 0);
	Points[1] = Other->Location + FVector(Other->CollisionRadius, Other->CollisionRadius, 0);
	Points[2] = Other->Location - FVector(Other->CollisionRadius, Other->CollisionRadius, 0);
	Points[3] = Other->Location + FVector(Other->CollisionRadius, -1 * Other->CollisionRadius, 0);
	int imin = 0;
	int imax = 0;
	FLOAT currentmin = Points[0].SizeSquared(); 
	FLOAT currentmax = currentmin; 
	for (INT i=1;i<4;i++)
	{
		FLOAT nextsize = Points[i].SizeSquared(); 
		if (nextsize > currentmax)
		{
			currentmax = nextsize;
			imax = i;
		}
		else if (nextsize < currentmin)
		{
			currentmin = nextsize;
			imin = i;
		}
	}
	for (i=0;i<4;i++)
	{
		if ((i != imin) && (i != imax))
		{
			if (LineCheckTranslucency(Points[i], ViewPoint))
				return 1;
		}
	}
	return 0;
}

int APawn::CanHear(FVector NoiseLoc, FLOAT Loudness, APawn *Other)
{
	FLOAT DistSq = (Location - NoiseLoc).SizeSquared();
	FVector ViewLoc = Location + FVector(0,0,BaseEyeHeight);
	if ( !bIsPlayer || !GetLevel()->GetLevelInfo()->Game->bTeamGame || !Other->bIsPlayer
		|| !PlayerReplicationInfo || !Other->PlayerReplicationInfo 
		|| (PlayerReplicationInfo->Team != Other->PlayerReplicationInfo->Team) )
	{
		if ( bMuffledHearing )
		{
			FCheckResult Hit(1.f);
			GetLevel()->SingleLineCheck(Hit, this, NoiseLoc, ViewLoc, TRACE_Level);
			FVector FirstHit = Hit.Location;
			GetLevel()->SingleLineCheck(Hit, this, ViewLoc, NoiseLoc, TRACE_Level);
			FLOAT WallDistSq = (FirstHit - Hit.Location).Size();
			Loudness *= 0.5;
			if( WallDistSq > 96 )
				return 0;
		}
		if ( DistSq > 4000000.f * Loudness * Loudness)
		  return 0;
		if ( DistSq == 0.f )
		  return 1;

		//FIXME - provide some hearing out of line of sight? (maybe PVS)
		// Note - a loudness of 1.0 is a typical loud noise

		FLOAT perceived = Min(1200000.f/DistSq, 2.f);
		
			// CDH: only engine-side use of Alertness, commented out for now to remove the reference to it (it's all magic voodoo code anyway, only affects noise hearing radius)
		//FLOAT Stimulus = Loudness * perceived + Alertness * Min(0.5f,perceived);
		FLOAT Stimulus = Loudness * perceived;

		if ( GetLevel()->Model->FastLineCheck(NoiseLoc, ViewLoc) )
			return 1;
		
		if (Stimulus < HearingThreshold) // CDH: only engine-side use of HearingThreshold
			return 0;
	}	
	else if ( DistSq > 16000000.f * Loudness * Loudness )
		return 0;

	//FIXME - check PVS
	if( bMuffledHearing )
		return 1;
	return ( GetLevel()->Model->FastLineCheck(NoiseLoc, Location) );
}

/* Send a HearNoise() message to all Pawns which could possibly hear this noise
NOTE that there is a hard-coded limit to the radius of hearing, which depends on the loudness of the noise
*/
void AActor::CheckNoiseHearing(FLOAT Loudness)
{
	APawn *NoiseOwner = this->Instigator;
	if ( !NoiseOwner )
		return;

	clock(GetLevel()->SeePlayer);
	float CurrentTime = GetLevel()->TimeSeconds;

	// allow only one noise per 0.2 seconds from a given instigator & area (within 50 units) unless much louder 
	if ( (NoiseOwner->noise1time > CurrentTime - 0.2)
		 && ((NoiseOwner->noise1spot - Location).SizeSquared() < 2500) 
		 && (NoiseOwner->noise1loudness >= 0.9 * Loudness) )
	{
		unclock(GetLevel()->SeePlayer);
		return;
	}

	if ( (NoiseOwner->noise2time > CurrentTime - 0.2)
		 && ((NoiseOwner->noise2spot - Location).SizeSquared() < 2500) 
		 && (NoiseOwner->noise2loudness >= 0.9 * Loudness) )
	{
		unclock(GetLevel()->SeePlayer);
		return;
	}

	// put this noise in a slot
	if ( NoiseOwner->noise1time < CurrentTime - 0.18 )
	{
		NoiseOwner->noise1time = CurrentTime;
		NoiseOwner->noise1spot = Location;
		NoiseOwner->noise1loudness = Loudness;
	}
	else if ( NoiseOwner->noise2time < CurrentTime - 0.18 )
	{
		NoiseOwner->noise2time = CurrentTime;
		NoiseOwner->noise2spot = Location;
		NoiseOwner->noise2loudness = Loudness;
	}
	else if ( ((NoiseOwner->noise1spot - Location).SizeSquared() < 2500) 
			  && (NoiseOwner->noise1loudness <= Loudness) ) 
	{
		NoiseOwner->noise1time = CurrentTime;
		NoiseOwner->noise1spot = Location;
		NoiseOwner->noise1loudness = Loudness;
	}
	else if ( NoiseOwner->noise2loudness <= Loudness ) 
	{
		NoiseOwner->noise1time = CurrentTime;
		NoiseOwner->noise1spot = Location;
		NoiseOwner->noise1loudness = Loudness;
	}

	if ( !NoiseOwner->bIsPlayer && (!NoiseOwner->Enemy || !( (APawn*)NoiseOwner->Enemy )->bIsPlayer) )
	{
		// non-player related noise. Inform only others of same class
		for ( APawn *next=GetLevel()->GetLevelInfo()->PawnList; next!=NULL; next=next->nextPawn )
			if ( (next != this->Instigator) && next->IsProbing(NAME_HearNoise)
				&& (next->IsA(GetClass()) || this->IsA(next->GetClass())) 
				&& next->CanHear(Location, Loudness, NoiseOwner) )
				next->eventHearNoise(Loudness, this);
		unclock(GetLevel()->SeePlayer);
		return;
	}

	// all pawns can hear this noise
	for ( APawn *P=GetLevel()->GetLevelInfo()->PawnList; P!=NULL; P=P->nextPawn )
		if ( !P->IsA(APlayerPawn::StaticClass())
			 && (P != this->Instigator) && P->IsProbing(NAME_HearNoise)
			 && P->CanHear(Location, Loudness, NoiseOwner) )
			 P->eventHearNoise(Loudness, this);

	unclock(GetLevel()->SeePlayer);
}

void APawn::CheckFocalPointVisible()
{
	clock(GetLevel()->SeePlayer);
	bNoHeightMod = true;
	if ( HeadTrackingActor )
	{
		check(HeadTrackingActor->IsValid());
//		if( HeadTrackingActor->IsA(AFocalPoint::StaticClass()) )
//			PeripheralVision = ((AFocalPoint*)HeadTrackingActor)->PeripheryMod;
		if( !LineOfSightTo(HeadTrackingActor, true) )
			eventFocalPointNotVisible();
	}
//	PeripheralVision = ((APawn*)APawn::StaticClass()->GetDefaultActor())->PeripheralVision;
	bNoHeightMod = false;
	unclock(GetLevel()->SeePlayer);
}

void APawn::CheckEnemyVisible()
{
	clock(GetLevel()->SeePlayer);
	if ( Enemy )
	{
		check(Enemy->IsValid());
		if ( !LineOfSightTo(Enemy) )
			eventEnemyNotVisible();
		else			
			eventEnemyIsVisible(); //LastSeenTime = GetLevel()->TimeSeconds;
	}
	unclock(GetLevel()->SeePlayer);
}

/* Player shows self to pawns that are ready
*/
void APawn::ShowSelf()
{
	clock(GetLevel()->SeePlayer);
	for ( APawn *Pawn=GetLevel()->GetLevelInfo()->PawnList; Pawn!=NULL; Pawn=Pawn->nextPawn )
		if ( (Pawn != this) && (Pawn->SightCounter < 0.0) )
		{
			//check visibility
			if ( ( Pawn->IsProbing(NAME_SeePlayer) || Pawn->IsProbing(NAME_SeeMonster) ) && Pawn->LineOfSightTo(this, true) )
			{
				if( this->IsA( APlayerPawn::StaticClass() ) && Pawn->IsProbing(NAME_SeePlayer) )
					Pawn->eventSeePlayer(this);
				else if( Pawn->IsProbing(NAME_SeeMonster) )
					Pawn->eventSeeMonster(this);
			}
		}

	unclock(GetLevel()->SeePlayer);
}

int APawn::actorReachable(AActor *Other, int bKnowVisible)
{
	if (!Other)
		return 0;

	FVector Dir = Other->Location - Location;
	FLOAT distsq = Dir.SizeSquared();
	checkSlow(Other->Region.Zone!=NULL);

	if ( !Other->IsA(APawn::StaticClass()) )
	{
		if ( !GIsEditor ) //only look past 800 for pawns
		{
			if (distsq > 640000.0) //non-pawns must be within 800.0
				return 0;
			if (Other->Region.Zone->DOT_Type != DOT_None) 
				return 0;
		}
	}
	else if ( ((APawn *)Other)->FootRegion.Zone->DOT_Type != DOT_None ) 
		return 0;
	
	if ( Other->Region.Zone->bWaterZone && !bCanSwim)
		return 0;

	//check other visible
	if ( !bKnowVisible )
	{
		FCheckResult Hit(1.0);
		FVector	ViewPoint = Location;
		ViewPoint.Z += BaseEyeHeight; //look from eyes
		GetLevel()->SingleLineCheck(Hit, this, Other->Location, ViewPoint, TRACE_VisBlocking);
		if ( (Hit.Time != 1.0) && (Hit.Actor != Other) )
			return 0;
	}

	if (Other->IsA(APawn::StaticClass()))
	{
		FLOAT Threshold = CollisionRadius + ::Min(1.5f * CollisionRadius, MeleeRange) + Other->CollisionRadius;
		FLOAT Thresholdsq = Threshold * Threshold;
		if (distsq <= Thresholdsq)
			return 1;
		else if (distsq > 640000.0)
		{
			FLOAT dist = Dir.Size();
			Threshold = ::Max(dist - 800.f, Threshold);
		}
		FVector realLoc = Location;
		FVector aPoint = Other->Location; //adjust destination
		if ( GetLevel()->FarMoveActor(this, Other->Location, 1) )
		{
			aPoint = Location;
			GetLevel()->FarMoveActor(this, realLoc,1,1);
		}
		return Reachable(aPoint, Threshold, Other);
	}
	else
	{
		FLOAT Threshold = 15.0;
		if ( Other->IsA(AInventory::StaticClass()) || Other->IsA(ATrigger::StaticClass()) )
			Threshold = CollisionRadius + Other->CollisionRadius - 2;
		FVector realLoc = Location;
		FVector aPoint = Other->Location;
		if ( GetLevel()->FarMoveActor(this, Other->Location, 1) )
		{
			aPoint = Location; //adjust destination
			GetLevel()->FarMoveActor(this, realLoc,1,1);
		}
		if ( Other->bBlockActors || Other->IsA(AWarpZoneMarker::StaticClass()) )
			return Reachable(aPoint, Threshold, Other);
		else
			return Reachable(aPoint, Threshold, NULL);
	}
	return 0;
}

int APawn::pointReachable(FVector aPoint, int bKnowVisible)
{
	if (!GIsEditor)
	{
		FVector Dir2D = aPoint - Location;
		Dir2D.Z = 0.0;
		if (Dir2D.SizeSquared() > 640000.0) //points must be within 800.0
			return 0;
	}

	FPointRegion NewRegion = GetLevel()->Model->PointRegion( Level, aPoint );
	if (!Region.Zone->bWaterZone && !bCanSwim && NewRegion.Zone->bWaterZone)
		return 0;

	if ( (FootRegion.Zone->DOT_Type == DOT_None) && (NewRegion.Zone->DOT_Type != DOT_None) )
		return 0;

	//check aPoint visible
	if ( !bKnowVisible )
	{
		FCheckResult Hit(1.0);
		FVector	ViewPoint = Location;
		ViewPoint.Z += BaseEyeHeight; //look from eyes
		if ( !GetLevel()->Model->FastLineCheck(aPoint, ViewPoint) )
			return 0;
	}

	FVector realLoc = Location;
	if ( GetLevel()->FarMoveActor(this, aPoint, 1) )
	{
		aPoint = Location; //adjust destination
		GetLevel()->FarMoveActor(this, realLoc,1,1);
	}
	return Reachable(aPoint, 15.0, NULL);
}

int APawn::Reachable(FVector aPoint, FLOAT Threshold, AActor* GoalActor)
{
	if ( Region.Zone->bWaterZone )
		return swimReachable(aPoint, Threshold, 0, GoalActor);
	else if ( (Physics == PHYS_Walking) || (Physics == PHYS_Swimming) ) 
		return walkReachable(aPoint, Threshold, 0, GoalActor);
	else if (Physics == PHYS_Flying)
		return flyReachable(aPoint, Threshold, 0, GoalActor);
	else //if (Physics == PHYS_Falling)
		return 0; // jumpReachable(aPoint, Threshold, 0, GoalActor);
}

int APawn::flyReachable(FVector Dest, FLOAT Threshold, int reachFlags, AActor* GoalActor)
{
	reachFlags = reachFlags | R_FLY;
	int success = 0;
	FVector OriginalPos = Location;
	FVector realVel = Velocity;
	int stillmoving = 1;
	FLOAT closeSquared = Threshold * Threshold; 
	FVector Direction = Dest - Location;
	FLOAT Movesize = ::Max(200.f, CollisionRadius);
	FLOAT MoveSizeSquared = Movesize * Movesize;
	int ticks = 100; 

	while (stillmoving) 
	{
		Direction = Dest - Location;
		FLOAT DistanceSquared = Direction.SizeSquared(); 
		if ( (DistanceSquared > closeSquared) || (Abs(Direction.Z) > CollisionHeight) )  //move not too small to do
		{
			if ( DistanceSquared < MoveSizeSquared ) 
				stillmoving = flyMove(Direction, GoalActor, 8.0, 0);
			else
			{
				Direction = Direction.SafeNormal();
				stillmoving = flyMove(Direction * Movesize, GoalActor, 4.1, 0);
			}
			if ( stillmoving == 5 ) //bumped into goal
			{
				stillmoving = 0;
				success = 1;
			}
			if ( stillmoving && Region.Zone->bWaterZone )
			{
				stillmoving = 0;
				if ( bCanSwim && (Region.Zone->DOT_Type == DOT_None) )
				{
					reachFlags = swimReachable(Dest, Threshold, reachFlags, GoalActor);
					success = reachFlags;
				}
			}
		}
		else
		{
			stillmoving = 0;
			success = 1;
		}
		ticks--;
		if (ticks < 0)
			stillmoving = 0;
	}

	if ( !success && GoalActor && GoalActor->IsA(AWarpZoneMarker::StaticClass()) )
		success = ( Region.Zone == ((AWarpZoneMarker *)GoalActor)->markedWarpZone );
	GetLevel()->FarMoveActor(this, OriginalPos, 1, 1); //move actor back to starting point
	Velocity = realVel;	
	if (success)
		return reachFlags;
	else
		return 0;
}

int APawn::swimReachable(FVector Dest, FLOAT Threshold, int reachFlags, AActor* GoalActor)
{
	//debugf("Swim reach to %f %f %f from %f %f %f",Dest.X,Dest.Y,Dest.Z,Location.X,Location.Y, Location.Z);
	reachFlags = reachFlags | R_SWIM;
	int success = 0;
	FVector OriginalPos = Location;
	FVector realVel = Velocity;
	int stillmoving = 1;
	FLOAT closeSquared = Threshold * Threshold; 
	FVector Direction = Dest - Location;
	FLOAT Movesize = ::Max(200.f, CollisionRadius);
	FLOAT MoveSizeSquared = Movesize * Movesize;
	int ticks = 100; 

	while (stillmoving) 
	{
		Direction = Dest - Location;
		FLOAT DistanceSquared = Direction.SizeSquared(); 
		if ( (DistanceSquared > closeSquared) || (Abs(Direction.Z) > CollisionHeight) )  //move not too small to do
		{
			if ( DistanceSquared < MoveSizeSquared ) 
				stillmoving = swimMove(Direction, GoalActor, 8.0, 0);
			else
			{
				Direction = Direction.SafeNormal();
				stillmoving = swimMove(Direction * Movesize, GoalActor, 4.1, 0);
			}
			if ( stillmoving == 5 ) //bumped into goal
			{
				stillmoving = 0;
				success = 1;
			}
			if ( !Region.Zone->bWaterZone )
			{
				stillmoving = 0;
				if (bCanFly)
				{
					reachFlags = flyReachable(Dest, Threshold, reachFlags, GoalActor);
					success = reachFlags;
				}
				else if ( bCanWalk && (Dest.Z < Location.Z + 50 + MaxStepHeight) ) // 50 = default navigationpoint height
				{
					FCheckResult Hit(1.0);
					GetLevel()->MoveActor(this, FVector(0,0,::Max(CollisionHeight + MaxStepHeight,Dest.Z - Location.Z)), Rotation, Hit, 1, 1);
					if (Hit.Time == 1.0)
					{
						success = flyReachable(Dest, Threshold, reachFlags, GoalActor);
						reachFlags = R_WALK | (success & !R_FLY);
					}
				}
			}
			else if ( Region.Zone->DOT_Type != DOT_None )
			{
				stillmoving = 0;
				success = 0;
			}
		}
		else
		{
			stillmoving = 0;
			success = 1;
		}
		ticks--;
		if (ticks < 0)
			stillmoving = 0;
	}

	if ( !success && GoalActor && GoalActor->IsA(AWarpZoneMarker::StaticClass()) )
		success = ( Region.Zone == ((AWarpZoneMarker *)GoalActor)->markedWarpZone );

	GetLevel()->FarMoveActor(this, OriginalPos, 1, 1); //move actor back to starting point
	Velocity = realVel;	
	if (success)
		return reachFlags;
	else
		return 0;
}
/*walkReachable() -
//walkReachable returns 0 if Actor cannot reach dest, and 1 if it can reach dest by moving in
// straight line
FIXME - take into account zones (lava, water, etc.). - note that pathbuilder should
initialize Scout to be able to do all these things
// actor must remain on ground at all times
// Note that Actor is not moved (when all is said and done)
// FIXME - allow jumping up and down if bCanJump (false for Scout!)

*/
int APawn::walkReachable(FVector Dest, FLOAT Threshold, int reachFlags, AActor* GoalActor)
{
	//debugf("Walk reach to %f %f %f from %f %f %f",Dest.X,Dest.Y,Dest.Z,Location.X,Location.Y, Location.Z);
	reachFlags = reachFlags | R_WALK;
	int success = 0;
	FVector OriginalPos = Location;
	FVector realVel = Velocity;
	int stillmoving = 1;
	FLOAT closeSquared = Threshold * Threshold; //should it be less for path building? its 15 * 15
	FLOAT Movesize = 16.0; 
	FVector Direction;
	if (!GIsEditor)
	{
		if (bCanJump)
			Movesize = ::Max(128.f, CollisionRadius);
		else
			Movesize = CollisionRadius;
	}
	
	int ticks = 100; 
	FLOAT MoveSizeSquared = Movesize * Movesize;
	FLOAT MaxZDiff = 0;
	if( SpecialHeight == 0 )
		MaxZDiff = CollisionHeight;
	else
		MaxZDiff = SpecialHeight;
	
	if ( GoalActor )
		MaxZDiff = ::Max(CollisionHeight, GoalActor->CollisionHeight);
	FCheckResult Hit(1.0);

	while (stillmoving == 1) 
	{
		Direction = Dest - Location;
		FLOAT Zdiff = Direction.Z;
		Direction.Z = 0; //this is a 2D move
		FLOAT DistanceSquared = Direction.SizeSquared(); //2D size
		if ( (Zdiff > MaxZDiff) && (DistanceSquared < 0.8 * (Zdiff - MaxZDiff) * (Zdiff - MaxZDiff)) )
			stillmoving = 0; //too steep to get there
		else
		{
			if (DistanceSquared > closeSquared) //move not too small to do
			{
				if (DistanceSquared < MoveSizeSquared) 
					stillmoving = walkMove(Direction, Hit, GoalActor, 8.0, 0);
				else
				{
					Direction = Direction.SafeNormal();
					stillmoving = walkMove(Direction * Movesize, Hit, GoalActor, 4.1, 0);
				} 
				if (stillmoving != 1)
				{
					if ( stillmoving == 5 ) //bumped into goal
					{
						stillmoving = 0;
						success = 1;
					}
					else if ( Region.ZoneNumber == 0 )
					{
						stillmoving = 0;
						success = 0;
					}
					else if (bCanFly)
					{
						stillmoving = 0;
						reachFlags = flyReachable(Dest, Threshold, reachFlags, GoalActor);
						success = reachFlags;
					}
					else if (bCanJump) 
					{
						//debugf("try to jump");
						reachFlags = reachFlags | R_JUMP;
						if (stillmoving == -1) 
						{
							FVector Landing;
							Direction = Direction.SafeNormal();
							stillmoving = FindBestJump(Dest, GroundSpeed * Direction, Landing, 1);
						}
						else if (stillmoving == 0)
						{
							FVector Landing;
							Direction = Direction.SafeNormal();
							stillmoving = FindJumpUp(Dest, GroundSpeed * Direction, Landing, 1);
						}
					}
					else if ( (stillmoving == -1) && (Movesize > MaxStepHeight) ) //try smaller  
					{
						stillmoving = 1;
						Movesize = MaxStepHeight;
					}
				}
				/*else // FIXME - make sure fully on path
				{
					FCheckResult Hit(1.0);
					GetLevel()->SingleLineCheck(Hit, this, Location + FVector(0,0,-1 * (0.5 * CollisionHeight + MaxStepHeight + 4.0)) , Location, TRACE_VisBlocking, 0.5 * GetCylinderExtent());
					if ( Hit.Time == 1.0 )
						reachFlags = reachFlags | R_JUMP;	
				}
				*/
				if ( FootRegion.Zone->DOT_Type != DOT_None ) 
				{
					stillmoving = 0;
					success = 0;
				}
				if ( Region.Zone->bWaterZone ) 
				{
					//debugf("swim from walk");
					stillmoving = 0;
					if ( bCanSwim && (Region.Zone->DOT_Type == DOT_None) )
					{
						reachFlags = swimReachable(Dest, Threshold, reachFlags, GoalActor);
						success = reachFlags;
					}
				}
			}
			else
			{
				stillmoving = 0;
				if ( Abs(Zdiff) < MaxZDiff )
					success = 1;
				else if ( (Hit.Normal.Z < 0.95) && (Hit.Normal.Z > 0.7) )
				{
					// check if above because of slope
					if ( (Zdiff < 0) 
						&& (Zdiff * -1 < CollisionHeight + CollisionRadius * appSqrt(1/(Hit.Normal.Z * Hit.Normal.Z) - 1)) )
						success = 1;
					else 
					{
						// might be below because on slope
						FLOAT adjRad = 46; //Navigation point default
						if ( GoalActor )
							adjRad = GoalActor->CollisionRadius;
						if ( (CollisionRadius < adjRad) 
							&& (Zdiff < MaxZDiff + (adjRad + 15 - CollisionRadius) * appSqrt(1/(Hit.Normal.Z * Hit.Normal.Z) - 1)) ) 
							success = 1;
					}
				}
			}
			ticks--;
			if (ticks < 0)
				stillmoving = 0;
		}
	}

	if ( !success && GoalActor && GoalActor->IsA(AWarpZoneMarker::StaticClass()) )
		success = ( Region.Zone == ((AWarpZoneMarker *)GoalActor)->markedWarpZone );

	GetLevel()->FarMoveActor(this, OriginalPos, 1, 1); //move actor back to starting point
	Velocity = realVel;
	if (success)
		return reachFlags;
	else
		return 0;
}

int APawn::jumpReachable(FVector Dest, FLOAT Threshold, int reachFlags, AActor* GoalActor)
{
	//debugf("Jump reach to %f %f %f from ",Dest.X,Dest.Y,Dest.Z,Location.X,Location.Y, Location.Z);
	reachFlags = reachFlags | R_JUMP;
	FVector OriginalPos = Location;
	FVector Landing;
	jumpLanding(Velocity, Landing, 1); 
	if ( Landing == OriginalPos )
		return 0;
	int success = walkReachable(Dest, Threshold, reachFlags, GoalActor);
	GetLevel()->FarMoveActor(this, OriginalPos, 1, 1); //move actor back to starting point
	return success;
}

/* jumpLanding()
determine landing position of current fall, given testVel as initial velocity.
Assumes near-zero acceleration by pawn during jump (make sure creatures do this FIXME)
*/
void APawn::jumpLanding(FVector testVel, FVector &Landing, int movePawn)
{
	FVector OriginalPos = Location;
	int landed = 0;
	int ticks = 0;
	FLOAT tickTime = 0.1;
	//debugf("Jump vel %f %f %f", testVel.X, testVel.Y, testVel.Z);
	while (!landed)
	{
		testVel = testVel * (1 - Region.Zone->ZoneFluidFriction * tickTime) + Region.Zone->ZoneGravity * tickTime; 
		FVector Adjusted = (testVel + Region.Zone->ZoneVelocity) * tickTime;
		FCheckResult Hit(1.0);
		GetLevel()->MoveActor(this, Adjusted, Rotation, Hit, 1, 1);
		if ( Region.Zone->bWaterZone ) 
			landed = 1;
		else if (Hit.Time < 1.0)
		{
			if ( Hit.Normal.Z > 0.7 )
				landed = 1;
			else
			{
				FVector OldHitNormal = Hit.Normal;
				FVector Delta = (Adjusted - Hit.Normal * (Adjusted | Hit.Normal)) * (1.0 - Hit.Time);
				if( (Delta | Adjusted) >= 0 )
				{
					GetLevel()->MoveActor(this, Delta, Rotation, Hit, 1, 1);
					if (Hit.Time < 1.0) //hit second wall
					{
						if (Hit.Normal.Z > 0.7)
							landed = 1;	
						FVector DesiredDir = Adjusted.SafeNormal();
						TwoWallAdjust(DesiredDir, Delta, Hit.Normal, OldHitNormal, Hit.Time);
						GetLevel()->MoveActor(this, Delta, Rotation, Hit, 1, 1);
						if (Hit.Normal.Z > 0.7)
							landed = 1;
					}
				}
			}
		}
		ticks++;
		if ( (Region.ZoneNumber == 0) || (ticks > 35) || (testVel.SizeSquared() > 2500000.f) ) 
		{
			GetLevel()->FarMoveActor(this, OriginalPos, 1, 1); //move actor back to starting point
			landed = 1;
		}
	}

	Landing = Location;
	if (!movePawn)
		GetLevel()->FarMoveActor(this, OriginalPos, 1, 1); //move actor back to starting point
}

int APawn::FindJumpUp(FVector Dest, FVector vel, FVector &Landing, int moveActor)
{
	//debugf("Jump up to %f %f %f from %f %f %f",Dest.X,Dest.Y,Dest.Z,Location.X,Location.Y, Location.Z);
	float realStep = MaxStepHeight;
	MaxStepHeight = 48; 
	FVector Direction = vel.SafeNormal();
	FCheckResult Hit(1.0);
	int success = walkMove(Direction * realStep, Hit, NULL, 4.1, 1);
	if ( success == 5 )
		success = 1;
	MaxStepHeight = realStep;
	return success;
}

void APawn::SuggestJumpVelocity(FVector Dest, FVector &vel)
{
	//determine how long I might be in the air 
	// FIXME - need support for air control

	FLOAT gravZ = Region.Zone->ZoneGravity.Z;
	if ( gravZ >= 0 ) // negative gravity - pretend its low gravity
		gravZ = -100.f;
	FLOAT StartVelZ = vel.Z;
	FLOAT floor = Dest.Z - Location.Z;
	FLOAT currentZ = 0.0;
	FLOAT ticks = 0.0;
	while ( (currentZ > floor) || (vel.Z > 0.0) )
	{
		vel.Z = vel.Z + gravZ * 0.05;
		ticks += 0.05; 
		currentZ = currentZ + vel.Z * 0.05;
	}
	if (Abs(vel.Z) > 1.0) 
		ticks = ticks - (currentZ - floor)/vel.Z; //correct overshoot
	vel = Dest - Location;
	vel.Z = 0.0;
	if (ticks > 0.0)
	{
		FLOAT velsize = vel.Size();
		if ( velsize > 0.f )
			vel = vel/velsize;
		velsize = Min(1.f * GroundSpeed, velsize/ticks); //FIXME - longwinded because of compiler bug
		vel *= velsize;
	}
	else
	{
		vel = vel.SafeNormal();
		vel *= GroundSpeed;
	}

	vel.Z = StartVelZ;
}

/* Find best jump from current position toward destination.  Assumes that there is no immediate 
barrier.  Sets vel to the suggested initial velocity, Landing to the expected Landing, 
and moves actor if moveActor is set */
int APawn::FindBestJump(FVector Dest, FVector vel, FVector &Landing, int movePawn)
{
	FVector realLocation = Location;

	//debugf("Jump best to %f %f %f from %f %f %f",Dest.X,Dest.Y,Dest.Z,Location.X,Location.Y, Location.Z);
	vel.Z = JumpZ;
	SuggestJumpVelocity(Dest, vel);

	// Now imagine jump
	jumpLanding(vel, Landing, 1);
	FVector olddist = Dest - realLocation;
	FVector dist = Dest - Location;
	int success;
	if ( FootRegion.Zone->DOT_Type != DOT_None ) 
		success = 0;
	else if (!bCanSwim && Region.Zone->bWaterZone)
		success = 0;
	else
	{
		FLOAT netchange = olddist.Size();
		netchange -= dist.Size();
		success = (netchange > 8.0);
	}
	//debugf("New Loc %f %f %f success %d",Location.X, Location.Y, Location.Z, success);
	// FIXME - if failed, imagine with no jumpZ (step out first)
	if (!movePawn)
		GetLevel()->FarMoveActor(this, realLocation, 1, 1); //move actor back to starting point
	return success;
}


/* walkMove() 
- returns 1 if move happened, zero if it didn't because of barrier, and -1
if it didn't because of ledge
Move direction must not be adjusted.
*/
int APawn::walkMove(FVector Delta, FCheckResult& Hit, AActor* GoalActor, FLOAT threshold, int bAdjust)
{
	FVector StartLocation = Location;
	Delta.Z = 0.0;
	//-------------------------------------------------------------------------------------------
	//Perform the move
	FVector GravDir = FVector(0,0,-1);
	if (Region.Zone->ZoneGravity.Z > 0)
		GravDir.Z = 1; 
	FVector Down = GravDir * MaxStepHeight;
	FVector Up = -1 * Down;

	GetLevel()->MoveActor(this, Delta, Rotation, Hit, 1, 1);
	if ( GoalActor && (Hit.Actor == GoalActor) )
		return 5; //bumped into goal
	if (Hit.Time < 1.0) //try to step up
	{
		Delta = Delta * (1.0 - Hit.Time);
		GetLevel()->MoveActor(this, Up, Rotation, Hit, 1, 1); 
		GetLevel()->MoveActor(this, Delta, Rotation, Hit, 1, 1);
		if ( GoalActor && (Hit.Actor == GoalActor) )
			return 5; //bumped into goal
		GetLevel()->MoveActor(this, Down, Rotation, Hit, 1, 1);
		if ( GoalActor && (Hit.Actor == GoalActor) )
			return 5; //bumped into goal
		//Scouts want only good floors, else undo move
		if ((Hit.Time < 1.0) && (Hit.Normal.Z < 0.7))
		{
			GetLevel()->FarMoveActor(this, StartLocation, 1, 1);
			return 0;
		}
	}

	//drop to floor
	FVector Loc = Location;
	Down = GravDir * (MaxStepHeight + 2.0);
	GetLevel()->MoveActor(this, Down, Rotation, Hit, 1, 1);
	if (Hit.Time == 1.0) //then falling
	{
		if (bAdjust) 
			GetLevel()->FarMoveActor(this, StartLocation, 1, 1);
		else
			GetLevel()->FarMoveActor(this, Loc, 1, 1);
		return -1;
	}
	else if (Hit.Normal.Z < 0.7)
	{
		GetLevel()->FarMoveActor(this, StartLocation, 1, 1);
		return -1;
	}

	//check if move successful
	FVector RealMove = Location - StartLocation;
	if (RealMove.SizeSquared() < threshold * threshold) 
	{
		if (bAdjust)
			GetLevel()->FarMoveActor(this, StartLocation, 1, 1);
		return 0;
	}

	return 1;
}

int APawn::flyMove(FVector Delta, AActor* GoalActor, FLOAT threshold, int bAdjust)
{
	int result = 1;
	FVector StartLocation = Location;

	//-------------------------------------------------------------------------------------------
	//Perform the move
	FVector Down = FVector(0,0,-1) * MaxStepHeight;
	FVector Up = -1 * Down;
	FCheckResult Hit(1.0);

	GetLevel()->MoveActor(this, Delta, Rotation, Hit, 1, 1);
	if ( GoalActor && (Hit.Actor == GoalActor) )
		return 5; //bumped into goal
	if (Hit.Time < 1.0) //try to step up
	{
		Delta = Delta * (1.0 - Hit.Time);
		GetLevel()->MoveActor(this, Up, Rotation, Hit, 1, 1); 
		GetLevel()->MoveActor(this, Delta, Rotation, Hit, 1, 1);
		if ( GoalActor && (Hit.Actor == GoalActor) )
			return 5; //bumped into goal
		//GetLevel()->MoveActor(this, Down, Rotation, Hit, 1, 1);
	}

	FVector RealMove = Location - StartLocation;
	if (RealMove.SizeSquared() < threshold * threshold) 
	{
		if (bAdjust)
			GetLevel()->FarMoveActor(this, StartLocation, 1, 1);
		result = 0;
	}
	return result;
}

int APawn::swimMove(FVector Delta, AActor* GoalActor, FLOAT threshold, int bAdjust)
{
	int result = 1;
	FVector StartLocation = Location;

	//-------------------------------------------------------------------------------------------
	//Perform the move
	FVector Down = FVector(0,0,-1) * MaxStepHeight;
	FVector Up = -1 * Down;
	FCheckResult Hit(1.0);

	GetLevel()->MoveActor(this, Delta, Rotation, Hit, 1, 1);
	if ( GoalActor && (Hit.Actor == GoalActor) )
		return 5; //bumped into goal
	if (!Region.Zone->bWaterZone)
	{
		FVector End = Location;
		findWaterLine(GetLevel(), Level, StartLocation, End);
		if (End != Location)
			GetLevel()->MoveActor(this, End - Location, Rotation, Hit, 1, 1);
		return 0;
	}
	else if (Hit.Time < 1.0) //try to step up
	{
		Delta = Delta * (1.0 - Hit.Time);
		GetLevel()->MoveActor(this, Up, Rotation, Hit, 1, 1); 
		GetLevel()->MoveActor(this, Delta, Rotation, Hit, 1, 1);
		if ( GoalActor && (Hit.Actor == GoalActor) )
			return 5; //bumped into goal
		//GetLevel()->MoveActor(this, Down, Rotation, Hit, 1, 1);
	}

	FVector RealMove = Location - StartLocation;
	if (RealMove.SizeSquared() < threshold * threshold) 
	{
		if (bAdjust)
			GetLevel()->FarMoveActor(this, StartLocation, 1, 1);
		result = 0;
	}
	return result;
}

/* PickWallAdjust()
Check if could jump up over obstruction (only if there is a knee height obstruction)
If so, start jump, and return current destination
Else, try to step around - return a destination 90 degrees right or left depending on traces
out and floor checks

*/
int APawn::PickWallAdjust()
{
	if ( Physics == PHYS_Falling )
		return 0;

	// first pick likely dir with traces, then check with testmove
	FCheckResult Hit(1.0);
	FVector ViewPoint = Location;
	ViewPoint.Z += BaseEyeHeight; //look from eyes
	FVector Dir = Destination - Location;
	FLOAT zdiff = Dir.Z;
	FLOAT AdjustDist = CollisionRadius + 16;
	if ( bIsPlayer ) //bots only, till I test this for all!!! FIXME
		AdjustDist += 0.5 * CollisionRadius;
	Dir.Z = 0;
	int bCheckUp = 0;
	if ( zdiff < CollisionHeight )
	{
		FLOAT DistDiff = (Dir | Dir ) - CollisionRadius * CollisionRadius;
		if ( DistDiff < 0 )
			return 0;
		if ( ((Physics == PHYS_Swimming) || (Physics == PHYS_Flying))
			&& (Dir.SizeSquared() < 4 * CollisionHeight * CollisionHeight) )
		{
			FVector Up = FVector(0,0,CollisionHeight);
			bCheckUp = 1;
			if ( Location.Z < Destination.Z )
			{
				bCheckUp = -1;
				Up *= -1;
			}
			GetLevel()->SingleLineCheck(Hit, this, Location + Up, Location, TRACE_VisBlocking, GetCylinderExtent());
			if (Hit.Time == 1.0)
			{
				FVector ShortDir = Dir.SafeNormal();
				ShortDir *= CollisionRadius;
				GetLevel()->SingleLineCheck(Hit, this, Location + Up + ShortDir, Location + Up, TRACE_VisBlocking, GetCylinderExtent());
				if (Hit.Time == 1.0)
				{
					Destination = Location + Up;
					return 1;
				}
			}
		}
	}

	FLOAT Dist = Dir.Size();
	if ( Dist == 0.f )
		return 0;
	Dir = Dir/Dist;
	if ( !GetLevel()->Model->FastLineCheck(Destination, ViewPoint) )
	{
		if ( (Physics != PHYS_Swimming) && (Physics != PHYS_Flying) )
		{
			AdjustDist += CollisionRadius;
			if ( zdiff > 256 )
				return 0;
		}
		else if (zdiff > 0)
		{
			FVector Up = FVector(0,0, CollisionHeight);
			GetLevel()->SingleLineCheck(Hit, this, Location + 2 * Up, Location, TRACE_VisBlocking, GetCylinderExtent());
			if (Hit.Time == 1.0)
			{
				Destination = Location + Up;
				return 1;
			}
		}
	}

	//look left and right
	FVector Left = FVector(Dir.Y, -1 * Dir.X, 0);
	INT bCheckRight = 0;
	FVector CheckLeft = Left * 1.42 * CollisionRadius;
	GetLevel()->SingleLineCheck(Hit, this, Destination, ViewPoint + CheckLeft, TRACE_VisBlocking); 
	if (Hit.Time < 1.0) //try right
	{
		bCheckRight = 1;
		Left *= -1;
		CheckLeft *= -1;
		GetLevel()->SingleLineCheck(Hit, this, Destination, ViewPoint + CheckLeft, TRACE_VisBlocking); 
	}

	if (Hit.Time < 1.0) //neither side has visibility
		return 0;

	FVector Out = 14 * Dir;
	INT bCheckStepUp = 0;
	if ( bIsPlayer //&& (Dist < 3 * CollisionRadius) 
		&& (Physics == PHYS_Walking) && bCanJump ) //FIXME - for all, not just players
	{
		// try step up first
		bCheckStepUp = 1;
		FVector Up = FVector(0,0,48); 
		GetLevel()->SingleLineCheck(Hit, this, Location + Up, Location, TRACE_VisBlocking, GetCylinderExtent());
		if (Hit.Time > 0.5)
		{
			GetLevel()->SingleLineCheck(Hit, this, Location + Up * Hit.Time + Out, Location + Up * Hit.Time, TRACE_VisBlocking, GetCylinderExtent());
			if (Hit.Time == 1.0)
			{
				if ( bIsPlayer && (appFrand() < 0.5) ) //FIXME - pass hitnormal in, & do for all
				{
					GetLevel()->SingleLineCheck(Hit, this, Location + Out, Location, TRACE_VisBlocking, GetCylinderExtent());
					if ( Hit.Time < 1.0 )
						Dir = -1 * Hit.Normal;
				}
				Velocity = GroundSpeed * Dir;
				Acceleration = AccelRate * Dir;
				Velocity.Z = JumpZ;
				bJumpOffPawn = true; // don't let script adjust this jump again
				setPhysics(PHYS_Falling);
				return 1;
			}
		}
	}

	//try step left or right
	Left *= AdjustDist;
	GetLevel()->SingleLineCheck(Hit, this, Location + Left, Location, TRACE_VisBlocking, GetCylinderExtent());
	if (Hit.Time == 1.0)
	{
		GetLevel()->SingleLineCheck(Hit, this, Location + Left + Out, Location + Left, TRACE_VisBlocking, GetCylinderExtent());
		if (Hit.Time == 1.0)
		{
			Destination = Location + Left;
			return 1;
		}
	}
	
	if ( !bCheckRight ) // if didn't already try right, now try it
	{
		CheckLeft *= -1;
		GetLevel()->SingleLineCheck(Hit, this, Destination, ViewPoint + CheckLeft, TRACE_VisBlocking); 
		if ( Hit.Time < 1.0 )
			return 0;
		Left *= -1;
		GetLevel()->SingleLineCheck(Hit, this, Location + Left, Location, TRACE_VisBlocking, GetCylinderExtent());
		if (Hit.Time == 1.0)
		{
			GetLevel()->SingleLineCheck(Hit, this, Location + Left + Out, Location + Left, TRACE_VisBlocking, GetCylinderExtent());
			if (Hit.Time == 1.0)
			{
				Destination = Location + Left;
				return 1;
			}
		}
	}

	//try jump up if walking, or adjust up or down if swimming
	if ( Physics == PHYS_Walking )
	{
		if ( bCheckStepUp || !bCanJump )
			return 0;
		FVector Up;
		Up = FVector(0,0,48); 

		GetLevel()->SingleLineCheck(Hit, this, Location + Up, Location, TRACE_VisBlocking, GetCylinderExtent());
		if (Hit.Time == 1.0)
		{
			GetLevel()->SingleLineCheck(Hit, this, Location + Up + Out, Location + Up, TRACE_VisBlocking, GetCylinderExtent());
			if (Hit.Time == 1.0)
			{
				if ( bIsPlayer ) //FIXME - pass hitnormal in, & do for all
				{
					GetLevel()->SingleLineCheck(Hit, this, Location + Out, Location, TRACE_VisBlocking, GetCylinderExtent());
					if ( Hit.Time < 1.0 )
						Dir = -1 * Hit.Normal;
				}
				Velocity = GroundSpeed * Dir;
				Acceleration = AccelRate * Dir;
				Velocity.Z = JumpZ;
				bJumpOffPawn = true; // don't let script adjust this jump again
				setPhysics(PHYS_Falling);
				return 1;
			}
		}
	}
	else 
	{
		FVector Up = FVector(0,0,CollisionHeight);

		if ( bCheckUp != 1 )
		{
			GetLevel()->SingleLineCheck(Hit, this, Location + Up, Location, TRACE_VisBlocking, GetCylinderExtent());
			if (Hit.Time == 1.0)
			{
				GetLevel()->SingleLineCheck(Hit, this, Location + Up + Out, Location + Up, TRACE_VisBlocking, GetCylinderExtent());
				if (Hit.Time == 1.0)
				{
					Destination = Location + Up;
					return 1;
				}
			}
		}

		if ( bCheckUp != -1 )
		{
			Up *= -1; //try adjusting down
			GetLevel()->SingleLineCheck(Hit, this, Location + Up, Location, TRACE_VisBlocking, GetCylinderExtent());
			if (Hit.Time == 1.0)
			{
				GetLevel()->SingleLineCheck(Hit, this, Location + Up + Out, Location + Up, TRACE_VisBlocking, GetCylinderExtent());
				if (Hit.Time == 1.0)
				{
					Destination = Location + Up;
					return 1;
				}
			}
		}
	}

	return 0;
}

void APawn::HandleSpecial(AActor *&bestPath)
{
	AActor * realPath = bestPath;
	AActor * newPath = bestPath->eventSpecialHandling(this);
	bestPath = newPath;
	if ( !newPath)
		return;

	if ( bestPath && (bestPath != realPath) )
	{
		if ( !bCanDoSpecial )
		{
			bestPath = NULL;
			return;
		}
		SpecialGoal = bestPath;
		if ( actorReachable(bestPath) )
		{
			if ( bestPath->IsProbing(NAME_SpecialHandling) )
			{
				AActor * ReturnedActor = bestPath->eventSpecialHandling(this);
				if ( !ReturnedActor )
					bestPath = NULL;
				else if ( bestPath != ReturnedActor )
				{
					if ( (bestPath != realPath) && actorReachable(ReturnedActor) )
						bestPath = ReturnedActor;
					else
						bestPath = NULL;
				}
			}
		}
		else 
		{
			int success = findPathToward(bestPath, 0, newPath, 1);
			if ( !success || (newPath == realPath) ) 
				bestPath = NULL;
			else
			{
				SpecialGoal = bestPath; 
				bestPath = newPath;
			}
		}
	}
}

/*-----------------------------------------------------------------------------
	Networking functions.
-----------------------------------------------------------------------------*/

FLOAT APawn::GetNetPriority( AActor* Recent, FLOAT Time, FLOAT Lag )
{
	if
	(	bIsPlayer
	&&	Recent
	&&	!Recent->bNetOwner
	&&	Weapon==((APawn*)Recent)->Weapon
	&&  Recent->bHidden==bHidden
	&&	Physics==PHYS_Walking )
	{
		FLOAT LocationError = ((Recent->Location+(Time+0.5*Lag)*Recent->Velocity) - (Location+0.5*Lag*Velocity)).Size();
		FLOAT MaxVelocity   = GroundSpeed;
		/*
		// Note: Lags and surges in position occur for other players because of
		// ServerMove/ClientAdjustPosition temporal wobble.
		if( LocationError )
			debugf
			(
				"%f / %f + %f (%f) %f=%f",
				Time,
				(Recent->Location+Time*Recent->Velocity - Location).Size(),
				((0.5*Lag*Recent->Velocity) - (0.5*Lag*Velocity)).Size(),
				(Recent->Location+Time*Recent->Velocity - Location).Size()/Recent->Velocity.Size(),
				Velocity.Size(),
				(Recent->Location-Location).Size()/Time
			);
		*/
		//if( LocationError )
		//	debugf("%f %f",Time,3.0*LocationError / MaxVelocity);
		Time = Time*0.5 + 2.0*LocationError / MaxVelocity;
	}
	return NetPriority * Time;
}

/*-----------------------------------------------------------------------------
	Rope functions.
-----------------------------------------------------------------------------*/
void APlayerPawn::PositionPlayerOnRope( void )
{   
    CMacBone    *targetBone=NULL;
    FCoords     targetBoneCoords;
    FVector     delta(0,0,0), ropeDir(0,0,0);

    if ( !this->currentRope )
        return;

    if ( this->boneRopeHandle == -1 )
        return;
   
    ABoneRope *rope = this->currentRope;
    UDukeMeshInstance *MeshInst = Cast<UDukeMeshInstance>( rope->GetMeshInstance() );

    if ( !MeshInst )
        return;

    CMacBone *bone = (CMacBone*)rope->GetBoneFromHandle( this->boneRopeHandle );

    if ( !bone )
        return;

    FCoords BoneCoords;

    MeshInst->GetBoneCoords( bone, BoneCoords );    
    BoneCoords = BoneCoords.Transpose();

	targetBoneCoords = FCoords();            

    // Assume that the current rope handle is between the first and last bone on the rope.  Because the server
    // shouldn't let the player be on that particular bone.

    if ( this->ropeOffset >= 0 ) 
    {
        // Currently going up the rope, calc dir to above bone
        targetBone       = bone - 1;
        MeshInst->GetBoneCoords( targetBone, targetBoneCoords );
        targetBoneCoords = targetBoneCoords.Transpose();
        delta            = targetBoneCoords.Origin - BoneCoords.Origin;
        ropeDir          = delta;
        ropeDir.Normalize();
    }         
    else if ( this->ropeOffset < 0 )
    {
        // Pushing down, or currently going down the rope, move towards the bone below
        targetBone       = bone + 1;
        MeshInst->GetBoneCoords( targetBone, targetBoneCoords );
        targetBoneCoords = targetBoneCoords.Transpose();
        delta            = targetBoneCoords.Origin - BoneCoords.Origin;
        ropeDir          = -delta;
        ropeDir.Normalize();
    }
    

    FRotator tempRot;
    FVector  forward,left,up;
    tempRot = Rotation;

    // Delta is how far we need to move to the rope
    delta = BoneCoords.Origin + ( this->ropeOffset * ropeDir ) - this->Location;

    ViewRotation.AngleVectors( forward, left, up );
    tempRot.Pitch = 0;
    
    delta   += tempRot.Vector() * -rope->m_riderRopeOffset; // Offset from the rope in the direction we are looking
    delta.Z += rope->m_riderVerticalOffset;                 // vertical offset
    delta   += left * rope->m_riderHorizontalOffset;        // horizontal offset

    moveSmooth( delta );
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
