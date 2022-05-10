/*=============================================================================
	UnLevAct.cpp: Level actor functions
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

Revision history:
	* Created by Tim Sweeney
=============================================================================*/

#include "EnginePrivate.h"

/*-----------------------------------------------------------------------------
	Level actor management.
-----------------------------------------------------------------------------*/

//
// Create a new actor. Returns the new actor, or NULL if failure.
//
AActor* ULevel::SpawnActor
(
	UClass*			Class,
	FName			InName,
	AActor*			Owner,
	class APawn*	Instigator,
	FVector			Location,
	FRotator		Rotation,
	FName			SpawnName,
	AActor*			Template,
	UBOOL			bNoCollisionFail,
	UBOOL			bRemoteOwned
)
{
	// Make sure this class is spawnable.
	if( !Class )
	{
		debugf( NAME_Warning, TEXT("SpawnActor failed because no class was specified") );
		return NULL;
	}
	if( Class->ClassFlags & CLASS_Abstract )
	{
		debugf( NAME_Warning, TEXT("SpawnActor failed because class %s is abstract"), Class->GetName() );
		return NULL;
	}
	else if( !Class->IsChildOf(AActor::StaticClass()) )
	{
		debugf( NAME_Warning, TEXT("SpawnActor failed because %s is not an actor class"), Class->GetName() );
		return NULL;
	}
	else if( !GIsEditor && (Class->GetDefaultActor()->bStatic || Class->GetDefaultActor()->bNoDelete) )
	{
		debugf( NAME_Warning, TEXT("SpawnActor failed because class %s has bStatic or bNoDelete"), Class->GetName() );
		return NULL;		
	} else if( Class->ClassFlags & CLASS_Obsolete )
	{
		debugf( NAME_Warning, TEXT("SpawnActor failed because class %s is an obsolete"), Class->GetName() );
		return NULL;
	}

	
	// Use class's default actor as a template.
	if( !Template )
		Template = Class->GetDefaultActor();
	check(Template!=NULL);

	// Make sure actor will fit at desired location, and adjust location if necessary.
	if( (Template->bCollideWorld || (Template->bCollideWhenPlacing && (GetLevelInfo()->NetMode != NM_Client))) && !bNoCollisionFail )
		if( !FindSpot( Template->GetCylinderExtent(), Location, 0, 1 ) )
			return NULL;

	// Add at end of list.
	INT iActor = Actors.Add();
    AActor* Actor = Actors(iActor) = (AActor*)StaticConstructObject( Class, GetOuter(), InName, 0, Template );
	Actor->SetFlags( RF_Transactional );

	// Set base actor properties.
	if (SpawnName == NAME_None)
		Actor->Tag		= Class->GetFName();
	else
		Actor->Tag		= SpawnName;
	Actor->Region	= FPointRegion( GetLevelInfo() );
	Actor->Level	= GetLevelInfo();
	Actor->bTicked  = !Ticked;
	Actor->XLevel	= this;

	// Set network role.
	check(Actor->Role==ROLE_Authority);
	if( bRemoteOwned )
		Exchange( Actor->Role, Actor->RemoteRole );

	// Remove the actor's brush, if it has one, because moving brushes are not duplicatable.
	if( Actor->Brush )
		Actor->Brush = NULL;

	// Set the actor's location and rotation.
	Actor->Location = Location;
	Actor->OldLocation = Location;
	Actor->Rotation = Rotation;
	if( Actor->bCollideActors && Hash  )
		Hash->AddActor( Actor );

	// Init the actor's zone.
	Actor->Region = FPointRegion(GetLevelInfo());
	if( Actor->IsA(APawn::StaticClass()) )
		((APawn*)Actor)->FootRegion = ((APawn*)Actor)->HeadRegion = FPointRegion(GetLevelInfo());

	// Set owner.
	Actor->SetOwner( Owner );

	// Set instigator
	Actor->Instigator = Instigator;

	// Send messages.
	if (Actor->Level->bBegunPlay)
	{
		Actor->InitExecution();
		Actor->Spawned();
		Actor->eventSpawned();
		Actor->eventPreBeginPlay();
		Actor->eventBeginPlay();
	}
	if( Actor->bDeleteMe )
		return NULL;

	// Set the actor's zone.
	if (Actor->Level->bBegunPlay)
		SetActorZone( Actor, iActor==0, 1 );

	// Send PostBeginPlay.
	if (Actor->Level->bBegunPlay)
		Actor->eventPostBeginPlay();

	// Check for encroachment.
	if( !bNoCollisionFail && CheckEncroachment( Actor, Actor->Location, Actor->Rotation, 1 ) )
	{
		DestroyActor( Actor );
		return NULL;
	}

	// Init scripting.
	if (Actor->Level->bBegunPlay)
		Actor->eventSetInitialState();

	// Find Base
	if( !Actor->Base && Actor->bCollideWorld
		 && (Actor->IsA(ADecoration::StaticClass()) || Actor->IsA(AInventory::StaticClass()) || Actor->IsA(APawn::StaticClass())) 
		 && ((Actor->Physics == PHYS_None) || (Actor->Physics == PHYS_Rotating)) )
		Actor->FindBase();

	// Success: Return the actor.
	if( InTick )
		NewlySpawned = new(GEngineMem)FActorLink(Actor,NewlySpawned);

	static UBOOL InsideNotification = 0;
	if( !InsideNotification )
	{
		InsideNotification = 1;
		// Spawn notification
		for( ASpawnNotify* N = GetLevelInfo()->SpawnNotify; N; N = N->Next )
		{
			if( N->ActorClass && Actor->IsA(N->ActorClass) )
				Actor = N->eventSpawnNotification( Actor );
		}
		InsideNotification = 0;
	}

	if (Actor->Level->bBegunPlay)
		Actor->bSpawnInitialized2 = true;

	return Actor;
}

//
// Spawn a brush.
//
ABrush* ULevel::SpawnBrush()
{
	ABrush* Result = (ABrush*)SpawnActor( ABrush::StaticClass() );
	check(Result);

	return Result;
}

//
// Destroy an actor.
// Returns 1 if destroyed, 0 if it couldn't be destroyed.
//
// What this routine does:
// * Remove the actor from the actor list.
// * Generally cleans up the engine's internal state.
//
// What this routine does not do, but is done in ULevel::Tick instead:
// * Removing references to this actor from all other actors.
// * Killing the actor resource.
//
// This routine is set up so that no problems occur even if the actor
// being destroyed inside its recursion stack.
//
UBOOL ULevel::DestroyActor( AActor* ThisActor, UBOOL bNetForce )
{
	check(ThisActor);
	check(ThisActor->IsValid());
	//debugf( NAME_Log, "Destroy %s", ThisActor->GetClass()->GetName() );

	ThisActor->bDeleting = true;

	// In-game deletion rules.
	if( !GIsEditor )
	{
		// Can't kill bStatic and bNoDelete actors during play.
		if( ThisActor->bStatic || ThisActor->bNoDelete )
			return 0;

		// If already on list to be deleted, pretend the call was successful.
		if( ThisActor->bDeleteMe )
			return 1;

		// Can't kill if wrong role.
		if( ThisActor->Role!=ROLE_Authority && !bNetForce && !ThisActor->bNetTemporary )
			return 0;

		// Don't destroy player actors.
		APlayerPawn* P = Cast<APlayerPawn>( ThisActor );
		if( P )
		{
			UNetConnection* C = Cast<UNetConnection>(P->Player);
			if( C && C->Channels[0] && C->State!=USOCK_Closed )
			{
				C->Channels[0]->Close();
				return 0;
			}
		}
	}

	//if(ThisActor)
	//	debugf(TEXT("*** DESTROY:%s"),ThisActor->GetName());

	// Get index.
	INT iActor = GetActorIndex( ThisActor );
	Actors.ModifyItem( iActor );
	ThisActor->Modify();

	// Send EndState notification.
	if( ThisActor->GetStateFrame() && ThisActor->GetStateFrame()->StateNode && ThisActor->IsProbing(NAME_EndState) )
	{
		ThisActor->eventEndState();
		if( ThisActor->bDeleteMe )
			return 1;
	}

	// Remove from base.
	if( ThisActor->Base )
	{
		ThisActor->SetBase( NULL );
		if( ThisActor->bDeleteMe )
			return 1;
	}
	if( ThisActor->StandingCount > 0 )
		for( INT i=0; i<Actors.Num(); i++ )
			if( Actors(i) && Actors(i)->Base == ThisActor ) 
				Actors(i)->SetBase( NULL );

	// Remove from world collision hash.
	if( Hash )
	{
		if( ThisActor->bCollideActors )
			Hash->RemoveActor( ThisActor );
		Hash->CheckActorNotReferenced( ThisActor );
	}

	// Remove from view portal list if needed.
	if( ThisActor->bPortalView )
	{
		ThisActor->bPortalView = false;
		PortalViewMap.Remove( ThisActor->PortalViewName );
	}

	// Tell this actor it's about to be destroyed.
	ThisActor->eventDestroyed();
	if( ThisActor->bDeleteMe )
		return 1;

	// Call untouch on all actors touching me
	{
		for ( INT j=ThisActor->Touching.Num()-1; j>=0; j-- )
		{
			ThisActor->EndTouch( ThisActor->Touching(j), 1 );
			if( ThisActor->bDeleteMe )
				return 1;
		}
	}

	// Clean up all owned and touching actors.
	INT iTemp = 0;
	for( INT iActor2=0; iActor2<Actors.Num(); iActor2++ )
	{
		AActor* Other = Actors(iActor2);
		if( Other )
		{
			if( Other->Owner==ThisActor )
			{
				Other->SetOwner( NULL );
				if( ThisActor->bDeleteMe )
					return 1;
			}
			
			// CDH...
			if( Other->MountParent==ThisActor )
			{
				Other->MountParent = NULL;
				
				// NJS: When a parent is destroyed, set the children to their desired physics type 
				// (Default Value of DismountPhysics is: PHYS_falling)
				Other->setPhysics(Other->DismountPhysics);

				// NJS: Possibly destroy a mounted actor that can't cope without it's parent being gone.
				if(Other->DestroyOnDismount)
				{
					DestroyActor(Other);
					
					if( ThisActor->bDeleteMe )		// JEP
						return 1;
					//continue;						// JEP commented out
				}
			}
			// ...CDH

			/* // JEP: Moved up some (look above)
			else if ( Other->Touching.FindItem(ThisActor, iTemp) )
			{
				ThisActor->EndTouch( Other, 1 );
				if( ThisActor->bDeleteMe )
					return 1;
			}
			*/
		}
	}

	// If this actor has an owner, notify it that it has lost a child.
	if( ThisActor->Owner )
	{
		ThisActor->Owner->eventLostChild( ThisActor );
		if( ThisActor->bDeleteMe )
			return 1;
	}

	// Notify net players that this guy has been destroyed.
	if( NetDriver )
		NetDriver->NotifyActorDestroyed( ThisActor );

	// If demo recording, notify the demo.
	if( DemoRecDriver && !DemoRecDriver->ServerConnection )
		DemoRecDriver->NotifyActorDestroyed( ThisActor );

	// Remove the actor from the actor list.
	check(Actors(iActor)==ThisActor);
	Actors(iActor) = NULL;

	ThisActor->bDeleteMe = 1;

	// Do object destroy.
	if( Engine->Audio )
		Engine->Audio->NoteDestroy( ThisActor );
	
	//ThisActor->ConditionalDestroy();		// JEP: Done in ULevel::CleanupDestroyed now

	// Cleanup.
	if( !GIsEditor )
	{
		// During play, just add to delete-list list and destroy when level is unlocked.
		ThisActor->Deleted = FirstDeleted;
		FirstDeleted       = ThisActor;
	}
	else
	{
		// JEP: This was added since it's safe in editor mode (and it's not done in CleanupDestroyed when in editor mode)
		ThisActor->ConditionalDestroy();		

		// Destroy them now.
		CleanupDestroyed( 1 );
	}

	// Return success.
	return 1;
}

//
// Compact the actor list.
//
void ULevel::CompactActors()
{
	INT c = iFirstDynamicActor;
	for( INT i=iFirstDynamicActor; i<Actors.Num(); i++ )
	{
		if( Actors(i) )
		{
			if( !Actors(i)->bDeleteMe )
				Actors(c++) = Actors(i);
			else
				debugf( TEXT("Undeleted %s"), Actors(i)->GetFullName() );
		}
	}
	if( c != Actors.Num() )
		Actors.Remove( c, Actors.Num()-c );
}

//
// Cleanup destroyed actors.
// During gameplay, called in ULevel::Unlock.
// During editing, called after each actor is deleted.
//
void ULevel::CleanupDestroyed( UBOOL bForce )
{
	// Pack actor list.
	if( !GIsEditor && !bForce )
		CompactActors();

	// If nothing deleted, exit.
	if( !FirstDeleted )
		return;

	// Don't do anything unless a bunch of actors are in line to be destroyed.
	INT c=0;
	for( AActor* A=FirstDeleted; A; A=A->Deleted )
		c++;
	if( c<128 && !bForce )
		return;

	// Remove all references to actors tagged for deletion.
	for( INT iActor=0; iActor<Actors.Num(); iActor++ )
	{
		AActor* Actor = Actors(iActor);
		if( Actor )
		{
			// Would be nice to say if(!Actor->bStatic), but we can't count on it.
			checkSlow(!Actor->bDeleteMe);
            Actor->GetClass()->CleanupDestroyed( (BYTE*)Actor );			
		}
	}

	// If editor, let garbage collector destroy objects.
	if( GIsEditor )
		return;

	while( FirstDeleted!=NULL )
	{
		// Physically destroy the actor-to-delete.
		check(FirstDeleted->bDeleteMe);
		AActor* ActorToKill = FirstDeleted;
		FirstDeleted        = FirstDeleted->Deleted;
		check(ActorToKill->bDeleteMe);

		check(ActorToKill->Touching.Num() == 0);		// JEP: I should be touching no one if being destroyed!

		// Destroy the actor.
		ActorToKill->ConditionalDestroy();		// JEP: Moved down to here, gonna see if this is safer
		delete ActorToKill;
	}
}

/*-----------------------------------------------------------------------------
	Player spawning.
-----------------------------------------------------------------------------*/

//
// Find an available camera actor in the level and return it, or spawn a new
// one if none are available.  Returns actor number or NULL if none are
// available.
//
void ULevel::SpawnViewActor( UViewport* Viewport )
{
	check(Engine->Client);
	check(Viewport->Actor==NULL);

	// Find an existing camera actor.
	for( INT iActor=0; iActor<Actors.Num(); iActor++ )
	{
		ACamera* TestActor = Cast<ACamera>( Actors(iActor) );
		if( TestActor && !TestActor->Player && (Viewport->GetFName()==TestActor->Tag) ) 
		{
			Viewport->Actor = TestActor;
            break;
		}
    }

    if( !Viewport->Actor )
	{
		// None found, spawn a new one and set default position.
		Viewport->Actor = (ACamera*)SpawnActor( ACamera::StaticClass(), NAME_None, NULL, NULL, FVector(-500,-300,+300), FRotator(0,0,0), NAME_None, NULL, 1 );
		check(Viewport->Actor);
		Viewport->Actor->Tag = Viewport->GetFName();
	}

	// Set the new actor's properties.
	Viewport->Actor->SetFlags( RF_NotForClient | RF_NotForServer );
	Viewport->Actor->ClearFlags( RF_Transactional );
	Viewport->Actor->Player		= Viewport;
	Viewport->Actor->ShowFlags	= SHOW_Frame | SHOW_MovingBrushes | SHOW_Actors | SHOW_Brush;
	Viewport->Actor->RendMap    = REN_DynLight;
	Viewport->Actor->bAdmin     = 1;

	// Set the zone.
	SetActorZone( Viewport->Actor, 0, 1 );
}

//
// Spawn an actor for gameplay.
//
struct FAcceptInfo
{
	AActor*			Actor;
	FString			Name;
	TArray<FString> Parms;
	FAcceptInfo( AActor* InActor, const TCHAR* InName )
	: Actor( InActor ), Name( InName ), Parms()
	{}
};

APlayerPawn* ULevel::SpawnNewPlayerClass( UPlayer* Player, ENetRole RemoteRole, const TCHAR *NewClass, FString& Error )
{
	Error=TEXT("");

	// Get package map.
	UPackageMap*    PackageMap = NULL;
	UNetConnection* Conn       = Cast<UNetConnection>( Player );
	
	if( Conn )
		PackageMap = Conn->PackageMap;

	// Get PlayerClass.
	UClass* PlayerClass=NULL;

	debugf( TEXT( "SpawnNewPlayerClass %s" ), NewClass );

	if( !NewClass )
	{		
		return NULL;
	}
	else
	{
		PlayerClass = StaticLoadClass( APlayerPawn::StaticClass(), NULL, NewClass, NULL, LOAD_NoWarn, PackageMap );
	}

	if( !PlayerClass )
	{
		debugf( NAME_Warning, TEXT("SpawnNewPlayerClass failed - Couldn't StaticLoadClass: %s"), *Error);
		return NULL;
	}

	// Login this new class
	TCHAR Options[1024]=TEXT("");
	APlayerPawn* Actor = NULL;

	if ( Player && Player->Actor )
	{
		APlayerPawn *OldPlayer = (APlayerPawn *)Player->Actor;
		// Use the PlayerReplicationInfo from the old player
		Actor  = GetLevelInfo()->Game->eventLoginNewClass( OldPlayer, PlayerClass, Error );
	}

	if( !Actor )
	{
		debugf( NAME_Warning, TEXT("SpawnNewPlayerClass failed: %s"), *Error);
		return NULL;
	}

	// Possess the newly-spawned player. 
	Actor->SetPlayer( Player );
	Actor->Role       = ROLE_Authority;
	Actor->RemoteRole = RemoteRole;
	Actor->ShowFlags  = SHOW_Backdrop | SHOW_Actors | SHOW_PlayerCtrl | SHOW_RealTime;
	Actor->RendMap	  = REN_DynLight;	

	return Actor;
}

APlayerPawn* ULevel::SpawnPlayActor( UPlayer* Player, ENetRole RemoteRole, const FURL& URL, FString& Error )
{
	Error=TEXT("");

	// Get package map.
	UPackageMap*    PackageMap = NULL;
	UNetConnection* Conn       = Cast<UNetConnection>( Player );
	if( Conn )
		PackageMap = Conn->PackageMap;

	// Get PlayerClass.
	UClass* PlayerClass=NULL;
	const TCHAR* Str = URL.GetOption( TEXT("CLASS="), NULL );
	if( Str )
		PlayerClass = StaticLoadClass( APlayerPawn::StaticClass(), NULL, Str, NULL, LOAD_NoWarn, PackageMap );
	if( !PlayerClass )
		PlayerClass = StaticLoadClass( APlayerPawn::StaticClass(), NULL, TEXT("usr:DefaultPlayer.Class"), NULL, LOAD_NoWarn, PackageMap );
	if( !PlayerClass )
		PlayerClass = StaticLoadClass( APlayerPawn::StaticClass(), NULL, TEXT("ini:URL.Class"), NULL, LOAD_NoWarn, PackageMap );
	if( !PlayerClass )
		appErrorf( TEXT("%s"), LocalizeError("LoadPlayerClass") );

	//debugf( TEXT( "Ulevel::SpawnPlayActor:Player class is %s" ), PlayerClass->GetFullName() );

	// Make the option string.
	TCHAR Options[1024]=TEXT("");
	for( INT i=0; i<URL.Op.Num(); i++ )
	{
		appStrcat( Options, TEXT("?") );
		appStrcat( Options, *URL.UnEscape( *URL.Op(i) ) );
	}
	
	//debugf( TEXT( "Ulevel::SpawnPlayActor:Player Options: %s" ), Options );

	// Tell UnrealScript to log in.
	INT SavedActorCount = Actors.Num();//oldver: Login should say whether to accept inventory.
	APlayerPawn* Actor = GetLevelInfo()->Game->eventLogin( *URL.Portal, Options, Error, PlayerClass );

	if( !Actor )
	{
		debugf( NAME_Warning, TEXT("Login failed: %s"), *Error);
		return NULL;
	}

	//debugf( TEXT( "Ulevel::SpawnPlayActor:Login Successful - Spawned %s" ), Actor->GetFullName() );

	UBOOL AcceptInventory = (SavedActorCount!=Actors.Num());//oldver: Hack, accepts inventory iff actor was spawned.

	// Possess the newly-spawned player.
	//debugf( TEXT( "Ulevel::SpawnPlayActor:Setting Player to %s" ), Player ? Player->GetFullName() : TEXT("None") );

	Actor->SetPlayer( Player );
	Actor->Role       = ROLE_Authority;
	Actor->RemoteRole = RemoteRole;
	Actor->ShowFlags  = SHOW_Backdrop | SHOW_Actors | SHOW_PlayerCtrl | SHOW_RealTime;
	Actor->RendMap	  = REN_DynLight;
	if( ParseParam(appCmdLine(),TEXT("alladmin")) || !NetDriver )
		Actor->bAdmin = 1;
	Actor->eventTravelPreAccept();

	// Any saved items?
	Str = NULL;
	if( AcceptInventory )
	{
		const TCHAR* PlayerName = URL.GetOption( TEXT("NAME="), *FURL::DefaultName );
		if( PlayerName )
		{
			FString* FoundItems = TravelInfo.Find( PlayerName );
			if( FoundItems )
				Str = **FoundItems;
		}
		if( !Str && GetLevelInfo()->NetMode==NM_Standalone )
		{
			TMap<FString,FString>::TIterator It(TravelInfo);
			if( It )
				Str = *It.Value();
		}
	}

	// Handle inventory items.
	TCHAR ClassName[256], ActorName[256];
	TArray<FAcceptInfo> Accepted;
	while( Str && Parse(Str,TEXT("CLASS="),ClassName,ARRAY_COUNT(ClassName)) && Parse(Str,TEXT("NAME="),ActorName,ARRAY_COUNT(ActorName)) )
	{
		// Load class.
		debugf( TEXT("Incoming travelling actor of class %s"), ClassName );//!!xyzzy
		FAcceptInfo* Accept=NULL;
		AActor* Spawned=NULL;
		UClass* Class=StaticLoadClass( AActor::StaticClass(), NULL, ClassName, NULL, LOAD_NoWarn|LOAD_AllowDll, PackageMap );
		if( !Class )
		{
			debugf( NAME_Log, TEXT("SpawnPlayActor: Cannot accept travelling class '%s'"), ClassName );
		}
		else if( Class->IsChildOf(APlayerPawn::StaticClass()) )
		{
			Accept = new(Accepted)FAcceptInfo(Actor,ActorName);
		}
		else if( (Spawned=SpawnActor( Class, NAME_None, Actor, NULL, Actor->Location, Actor->Rotation, NAME_None, NULL, 1 ))==NULL )
		{
			debugf( NAME_Log, TEXT("SpawnPlayActor: Failed to spawn travelling class '%s'"), ClassName );
		}
		else
		{
			debugf( NAME_Log, TEXT("SpawnPlayActor: Spawned travelling actor") );
			Accept = new(Accepted)FAcceptInfo(Spawned,ActorName);
		}

		// Save properties.
		TCHAR Buffer[256];
		ParseLine(&Str,Buffer,ARRAY_COUNT(Buffer),1);
		ParseLine(&Str,Buffer,ARRAY_COUNT(Buffer),1);
		while( ParseLine(&Str,Buffer,ARRAY_COUNT(Buffer),1) && appStrcmp(Buffer,TEXT("}"))!=0 )
			if( Accept )
				new(Accept->Parms)FString(Buffer);
	}

	// Import properties.
	for( i=0; i<Accepted.Num(); i++ )
	{
		// Parse all properties.
		for( INT j=0; j<Accepted(i).Parms.Num(); j++ )
		{
			const TCHAR* Ptr = *Accepted(i).Parms(j);
			while( *Ptr==' ' )
				Ptr++;
			TCHAR VarName[256], *VarEnd=VarName;
			while( appIsAlnum(*Ptr) || *Ptr=='_' )
				*VarEnd++ = *Ptr++;
			*VarEnd=0;
			INT Element=0;
			if( *Ptr=='[' )
			{
				Element=appAtoi(++Ptr);
				while( appIsDigit(*Ptr) )
					Ptr++;
				if( *Ptr++!=']' )
					continue;
			}
			if( *Ptr++!='=' )
				continue;
			for( TFieldIterator<UProperty> It(Accepted(i).Actor->GetClass()); It; ++It )
			{
				if (!(It->PropertyFlags & CPF_Travel))
					continue;
				if (appStricmp(It->GetName(), VarName) || (Element >= It->ArrayDim))
					continue;

				// Import the property.
				BYTE* Data = (BYTE*)Accepted(i).Actor + It->Offset + Element*It->ElementSize;
				UObjectProperty* Ref = Cast<UObjectProperty>( *It );
				if( Ref && Ref->PropertyClass->IsChildOf(AActor::StaticClass()) )
				{
					for( INT k=0; k<Accepted.Num(); k++ )
					{
						if( Accepted(k).Name==Ptr )
						{
							*(UObject**)Data = Accepted(k).Actor;
							break;
						}
					}
				}
				else
                {
					It->ImportText( Ptr, Data, 0 );
                }
			}
		}
	}

	// Call travel-acceptance functions in reverse order to avoid inventory flipping.
	for( i=Accepted.Num()-1; i>=0; i-- )
		Accepted(i).Actor->eventTravelPreAccept();
	GetLevelInfo()->Game->eventAcceptInventory( Actor );
	for( i=Accepted.Num()-1; i>=0; i-- )
		Accepted(i).Actor->eventTravelPostAccept();
	Actor->eventTravelPostAccept();
	GetLevelInfo()->Game->eventPostLogin( Actor );

	return Actor;
}

/*-----------------------------------------------------------------------------
	Level actor moving/placing.
-----------------------------------------------------------------------------*/

//
// Find a suitable nearby location to place a collision box.
// No suitable location will ever be found if Location is not a valid point inside the level ( and not in 
// a wall)

// AdjustSpot used by FindSpot
void ULevel::AdjustSpot( FVector& Adjusted, FVector TraceDest, FLOAT TraceLen, FCheckResult& Hit )
{
	SingleLineCheck( Hit, NULL, TraceDest, Adjusted, TRACE_VisBlocking );
	if( Hit.Time < 1.0 )
		Adjusted = Adjusted + Hit.Normal * (1.05 - Hit.Time) * TraceLen;
}

UBOOL ULevel::FindSpot
(
	FVector  Extent,
	FVector& Location,
	UBOOL	 bCheckActors,
	UBOOL	 bAssumeFit
)
{
	// trace to all corners to find interpenetrating walls
	FCheckResult Hit(1.0);
	if( Extent==FVector(0,0,0) )
		return SinglePointCheck( Hit, Location, Extent, 0, GetLevelInfo(), bCheckActors )==1;

	if( bAssumeFit && SinglePointCheck( Hit,Location, Extent, 0, GetLevelInfo(), bCheckActors )==1 )
		return 1;
	FVector Adjusted = Location;
	FLOAT TraceLen = Extent.Size() + 2.0;

	for (int i=-1;i<2;i+=2)
	{
		AdjustSpot(Adjusted, Adjusted + FVector(i * Extent.X,0,0), Extent.X, Hit); 
		AdjustSpot(Adjusted, Adjusted + FVector(0,i * Extent.Y,0), Extent.Y, Hit); 
		AdjustSpot(Adjusted, Adjusted + FVector(0,0,i * Extent.Z), Extent.Z, Hit); 
	}
	if( SinglePointCheck( Hit, Adjusted, Extent, 0, GetLevelInfo(), bCheckActors )==1 )
	{
		Location = Adjusted;
		return 1;
	}

	for (i=-1;i<2;i+=2)
		for (int j=-1;j<2;j+=2)
			for (int k=-1;k<2;k+=2)
				AdjustSpot(Adjusted, Adjusted + FVector(i * Extent.X, j * Extent.Y, k * Extent.Z), TraceLen, Hit); 

	if( (Adjusted - Location).SizeSquared() > 1.5 * Extent.SizeSquared() )
		return 0;

	if( SinglePointCheck( Hit, Adjusted, Extent, 0, GetLevelInfo(), bCheckActors )==1 )
	{
		Location = Adjusted;
		return 1;
	}
	return 0;
}

//
// Try to place an actor that has moved a long way.  This is for
// moving actors through teleporters, adding them to levels, and
// starting them out in levels.  The results of this function is independent
// of the actor's current location and rotation.
//
// If the actor doesn't fit exactly in the location specified, tries
// to slightly move it out of walls and such.
//
// Returns 1 if the actor has been successfully moved, or 0 if it couldn't fit.
//
// Updates the actor's Zone and sends ZoneChange if it changes.
//
UBOOL ULevel::FarMoveActor( AActor* Actor, FVector DestLocation,  UBOOL test, UBOOL bNoCheck )
{
	check(Actor!=NULL);
	if( (Actor->bStatic || !Actor->bMovable) && !GIsEditor )
		return 0;

	if( Actor->bCollideActors && Hash ) //&& !test
		Hash->RemoveActor( Actor );

	FVector newLocation = DestLocation;
	int result = 1;
	if (!bNoCheck && (Actor->bCollideWorld || (Actor->bCollideWhenPlacing && (GetLevelInfo()->NetMode != NM_Client))) ) 
		result = FindSpot( Actor->GetCylinderExtent(), newLocation, 0, 0 );

	if (result && !test && !bNoCheck)
		result = !CheckEncroachment( Actor, newLocation, Actor->Rotation, 1);
	
	if( result )
	{
		if( !test )
		{
			if( Actor->StandingCount > 0 )
				for( INT i=0; i<Actors.Num(); i++ )
					if( Actors(i) && Actors(i)->Base == Actor ) 
						Actors(i)->SetBase( NULL );
			Actor->bJustTeleported = true;
		}
		Actor->Location = newLocation;
		Actor->OldLocation = newLocation; //to zero velocity
	}

	if( Actor->bCollideActors && Hash ) //&& !test
		Hash->AddActor( Actor );

	// Set the zone after moving, so that if a ZoneChange or ActorEntered/ActorEntered message
	// tries to move the actor, the hashing will be correct.
	if( result )
		SetActorZone( Actor, test );

	return result;
}

//
// Place the actor on the floor below.  May move the actor a long way down.
// Updates the actor's Zone and sends ZoneChange if it changes.
//
//

UBOOL ULevel::DropToFloor( AActor *Actor)
{
	check(Actor!=NULL);

	// Try moving down a long way and see if we hit the floor.

	FCheckResult Hit(1.0);
	MoveActor( Actor, FVector( 0, 0, -1000 ), Actor->Rotation, Hit );
	return (Hit.Time < 1.f);
}

//
// Tries to move the actor by a movement vector.  If no collision occurs, this function 
// just does a Location+=Move.
//
// Assumes that the actor's Location is valid and that the actor
// does fit in its current Location. Assumes that the level's 
// Dynamics member is locked, which will always be the case during
// a call to ULevel::Tick; if not locked, no actor-actor collision
// checking is performed.
//
// If bCollideWorld, checks collision with the world.
//
// For every actor-actor collision pair:
//
// If both have bCollideActors and bBlocksActors, performs collision
//    rebound, and dispatches Touch messages to touched-and-rebounded 
//    actors.  
//
// If both have bCollideActors but either one doesn't have bBlocksActors,
//    checks collision with other actors (but lets this actor 
//    interpenetrate), and dispatches Touch and UnTouch messages.
//
// Returns 1 if some movement occured, 0 if no movement occured.
//
// Updates actor's Zone and sends ZoneChange if it changes.
//
// If Test = 1 (default 0), do not send notifications.
//
UBOOL ULevel::MoveActor
(
	AActor*			Actor,
	FVector			Delta,
	FRotator		NewRotation,
	FCheckResult&	Hit,
	UBOOL			bTest,
	UBOOL			bIgnorePawns,
	UBOOL			bIgnoreBases,
	UBOOL			bNoFail
)
{
	check(Actor!=NULL);
	if( (Actor->bStatic || !Actor->bMovable) && !GIsEditor )
		return 0;

	// Skip if no vector.
	if( Delta.IsNearlyZero() )
	{
		if( NewRotation==Actor->Rotation )
		{
			return 1;
		}
		else if( !Actor->StandingCount && !Actor->IsMovingBrush() )
		{
			Actor->Rotation  = NewRotation;
			return 1;
		}
	}

	// Set up.
	Hit = FCheckResult(1.0);
	NumMoves++;
	clock(MoveCycles);
	FMemMark Mark(GMem);
	FLOAT DeltaSize;
	FVector DeltaDir;
	if( Delta.IsNearlyZero() )
	{
		DeltaSize = 0;
		DeltaDir = Delta;
	}
	else
	{
		DeltaSize = Delta.Size();
		DeltaDir       = Delta/DeltaSize;
	}
	FLOAT TestAdjust	   = 2.0;
	FVector TestDelta      = Delta + TestAdjust * DeltaDir;
	INT     MaybeTouched   = 0;
	FCheckResult* FirstHit = NULL;

	UBOOL IsGlass = Actor->IsA(ABreakableGlass::StaticClass());		// JEP: Litle hack-a-rooey

	// Perform movement collision checking if needed for this actor.
	if( (Actor->bCollideActors || Actor->bCollideWorld) && !Actor->IsMovingBrush() && !IsGlass && Delta!=FVector(0,0,0))
	{
		// Check collision along the line.
		FirstHit = MultiLineCheck
		(
			GMem,
			Actor->Location + TestDelta,
			Actor->Location,
			Actor->GetCylinderExtent(),
			(Actor->bCollideActors && !Actor->IsMovingBrush()) ? 1              : 0,
			(Actor->bCollideWorld  && !Actor->IsMovingBrush()) ? GetLevelInfo() : NULL,
			0
		);

		// Handle first blocking actor.
		if(Actor->bCollideWorld || Actor->bBlockActors || Actor->bBlockPlayers)
		{
			for( FCheckResult* Test=FirstHit; Test; Test=Test->GetNext() )
			{
				if
				(	(!bIgnorePawns || Test->Actor->bStatic || (!Test->Actor->IsA(APawn::StaticClass()) && !Test->Actor->IsA(ADecoration::StaticClass())))
				&&	(!bIgnoreBases || !Actor->IsBasedOn(Test->Actor))
				&&	(!Test->Actor->IsBasedOn(Actor)               ) )
				{
					MaybeTouched = 1;
					if( Actor->IsBlockedBy(Test->Actor) )
					{
						Hit = *Test;
						break;
					}
				}
			}
		}
	}

	// Attenuate movement.
	FVector FinalDelta = Delta;
	if( Hit.Time < 1.0 && !bNoFail )
	{
		// Fix up delta, given that TestDelta = Delta + TestAdjust.
		FLOAT FinalDeltaSize = (DeltaSize + TestAdjust) * Hit.Time;
		if ( FinalDeltaSize <= TestAdjust)
		{
			FinalDelta = FVector(0,0,0);
			Hit.Time = 0;
		}
		else 
		{
			FinalDelta = TestDelta * Hit.Time - TestAdjust * DeltaDir;
			Hit.Time   = (FinalDeltaSize - TestAdjust) / DeltaSize;
		}
	}

	// Move the based actors (before encroachment checking).
	if( Actor->StandingCount && !bTest )
	{
		for( int i=0; i<Actors.Num(); i++ )
		{
			AActor* Other = Actors(i);
			if( Other && Other->Base==Actor )
			{
				// Move base.
				FVector   RotMotion( 0, 0, 0 );
				FRotator DeltaRot ( 0, NewRotation.Yaw - Actor->Rotation.Yaw, 0 );
				if( NewRotation != Actor->Rotation )
				{
					// Handle rotation-induced motion.
					FRotator ReducedRotation = FRotator( 0, ReduceAngle(NewRotation.Yaw) - ReduceAngle(Actor->Rotation.Yaw), 0 );
					FVector   Pointer         = Actor->Location - Other->Location;
					RotMotion                 = Pointer - Pointer.TransformVectorBy( GMath.UnitCoords * ReducedRotation );
				}
				FCheckResult Hit(1.0);
				MoveActor( Other, FinalDelta + RotMotion, Other->Rotation + DeltaRot, Hit, 0, 0, 1 );

				// Update pawn view.
				if( Other->IsA(APawn::StaticClass()) )
					((APawn*)Other)->ViewRotation += DeltaRot;
			}
		}
	}

	// Abort if encroachment declined.
	if( !bTest && !bNoFail && !Actor->IsA(APawn::StaticClass()) && !IsGlass && CheckEncroachment( Actor, Actor->Location + FinalDelta, NewRotation, 0 ))
	{
		unclock(MoveCycles);
		return 0;
	}

	// Update the location.
	if( Actor->bCollideActors && Hash )
		Hash->RemoveActor( Actor );
	Actor->Location += FinalDelta;
	Actor->Rotation  = NewRotation;
	if( Actor->bCollideActors && Hash )
		Hash->AddActor( Actor );

	// Handle bump and touch notifications.
	if( !bTest )
	{
		// Notify first bumped actor unless it's the level or the actor's base.
		if( Hit.Actor && Hit.Actor!=GetLevelInfo() && !Actor->IsBasedOn(Hit.Actor) )
		{
			// Notify both actors of the bump.
			Hit.Actor->eventBump(Actor);
			Actor->eventBump(Hit.Actor);
		}

		// Handle Touch notifications.
		if( MaybeTouched || !Actor->bBlockActors || !Actor->bBlockPlayers )
			for( FCheckResult* Test=FirstHit; Test && Test->Time<Hit.Time; Test=Test->GetNext() )
				if
				(	(!Test->Actor->IsBasedOn(Actor))
				&&	(!bIgnoreBases || !Actor->IsBasedOn(Test->Actor))
				&&	(!Actor->IsBlockedBy(Test->Actor)) )
				{
				/*	// JEP: Commented out, but left in for reference
				// JEP...
				#if 1
					// Faster, but lets object pass over each other, and never touch...
					if (Test->Actor->IsOverlapping(Actor))			
				#else
					// Slower, but does not allow object to pass over each other without touching...
					FCheckResult	Hit2(0);
					FVector			End;
					FVector			Start;
					FVector			Extent;

					Start	= Actor->Location-FinalDelta;		// Actor already moved, so subtract movement to get start
					End		= Actor->Location;
					Extent	= Actor->GetCylinderExtent();

					if (Test->Actor->GetPrimitive()->LineCheck( Hit2, Test->Actor, End, Start, Extent, 0, 0)==0)
				#endif
				// ...JEP
				*/
						Actor->BeginTouch( Test->Actor );
				}

		// UnTouch notifications.
		for( int i=0; i<Actor->Touching.Num(); i++ )
		{
			if( Actor->Touching(i) && !Actor->IsOverlapping(Actor->Touching(i)) )
				Actor->EndTouch( Actor->Touching(i), 0 );		
		}
	}

	// Set actor zone.
	SetActorZone( Actor, bTest );
	Mark.Pop();

	// Return whether we moved at all.
	unclock(MoveCycles);
	return Hit.Time>0.0;
}

/*-----------------------------------------------------------------------------
	Encroachment.
-----------------------------------------------------------------------------*/

/*
static void MyCheapBroadcastMessage(AActor* inActor, TCHAR* inFmt, ... )
{ 
	static TCHAR buf[256];
	GET_VARARGS( buf, ARRAY_COUNT(buf), inFmt );
	inActor->Level->eventBroadcastMessage(FString(buf),0,NAME_None);
}
*/

//
// Check whether Actor is encroaching other actors after a move, and return
// 0 to ok the move, or 1 to abort it.
//
UBOOL ULevel::CheckEncroachment
(
	AActor*		Actor,
	FVector		TestLocation,
	FRotator	TestRotation,
	UBOOL		bTouchNotify
)
{
	check(Actor);

	// If this actor doesn't need encroachment checking, allow the move.
	if( !Actor->bCollideActors && !Actor->bBlockActors && !Actor->bBlockPlayers && !Actor->IsMovingBrush() )
		return 0;

	//return 0;

	// Query the mover about what he wants to do with the actors he is encroaching.
	FMemMark Mark(GMem);
	FCheckResult* FirstHit = Hash ? Hash->ActorEncroachmentCheck( GMem, Actor, TestLocation, TestRotation, 0 ) : NULL;	
	for( FCheckResult* Test = FirstHit; Test!=NULL; Test=Test->GetNext() )
	{
		int noProcess = 0;
		if
		(	Test->Actor!=Actor
		&&	Test->Actor!=GetLevelInfo()
		&&	Actor->IsBlockedBy( Test->Actor ) )
		{
			if ( Actor->IsMovingBrush() && !Test->Actor->IsMovingBrush() ) 
			{
				if (!Actor->bPushByRotation || Test->Actor->bCancelPushByRotation)
				{
					//
					// (JP) Old code (Does NOT work with rotating movers)
					//

					// check if mover can safely push encroached actor
					//Move test actor away from mover
					FVector MoveDir = TestLocation - Actor->Location;
					FVector OldLoc = Test->Actor->Location;
					Test->Actor->moveSmooth(MoveDir);
					// see if mover still encroaches test actor
					FCheckResult* RecheckHit = Hash->ActorEncroachmentCheck( GMem, Actor, TestLocation, TestRotation, 0 );
					noProcess = 1;
					for ( FCheckResult* Recheck = RecheckHit; Recheck!=NULL; Recheck=Recheck->GetNext() )
						if ( Recheck->Actor == Test->Actor )
						{
							noProcess = 0;
							break;
						}
					if ( !noProcess ) //push test actor back toward brush
					{
						FVector realLoc = Actor->Location;
						Actor->Location = TestLocation;
						Test->Actor->moveSmooth(-1 * MoveDir);
						Actor->Location = realLoc;
					}
					else
					{
						// Send the event that we are pushing the actor out of the way
						Test->Actor->eventPushedByMover(Actor, MoveDir*Actor->PushVelocityScale);
					}

				}
				else
				{
					//
					// (JP) New Code (Works for rotating movers now...)
					//

					FVector		Loc1, Loc2;
					FVector		OriginalLoc = Actor->Location;
					FRotator	OriginalRot = Actor->Rotation;

					// Remember original location
					FVector		OldLoc = Test->Actor->Location;

					//MyCheapBroadcastMessage(Actor, TEXT("Testing Actor: %s"), Test->Actor->GetName());

					// Loc1 will be in the movers original local space
					Loc1 = Test->Actor->Location.TransformPointBy(Actor->ToLocal());

					// Move the mover into the new location
					Actor->Location = TestLocation;
					Actor->Rotation = TestRotation;

					// Loc2 will be in the movers new local space
					Loc2 = Test->Actor->Location.TransformPointBy(Actor->ToLocal());

					Actor->Location = OriginalLoc;
					Actor->Rotation = OriginalRot;

					// Move Loc1 and Loc2 into world so we can make a vector out of them (could also just rotate the vector)
					Loc1 = Loc1.TransformPointBy(Actor->ToWorld());
					Loc2 = Loc2.TransformPointBy(Actor->ToWorld());

				#if 1
					// Make a vector that goes with the actors movement
					FVector MoveDir = Loc1 - Loc2;

					Test->Actor->moveSmooth(MoveDir*1.1);

					noProcess = 1;

					// See if mover still encroaches test actor
					FCheckResult* RecheckHit = Hash->ActorEncroachmentCheck( GMem, Actor, TestLocation, TestRotation, 0 );
					
					for ( FCheckResult* Recheck = RecheckHit; Recheck!=NULL; Recheck=Recheck->GetNext() )
					{
						if ( Recheck->Actor == Test->Actor )
						{
							noProcess = 0;
							break;
						}
					}

					if (!noProcess) 
					{
						// Cancel the move, and tell the mover not to move as well
						FarMoveActor(Test->Actor, OldLoc);
					}
					else
					{
						// Send the event that we are pushing the actor out of the way
						Test->Actor->eventPushedByMover(Actor, MoveDir*Actor->PushVelocityScale);
					}
				#else
					
					// Make a vector that goes against the actors movement
					FVector MoveDir = Loc1 - Loc2;

					noProcess = 1;

					// See if we can move out of the way
					FCheckResult Hit(1.f);
					MoveActor(Test->Actor, MoveDir, Test->Actor->Rotation, Hit );

					// If we can't back out, tell the mover he can't move
					if (Hit.Time < 1.0)
					{
						// Reset the actors location, and tell mover it's a no go
						noProcess = 0;
						FarMoveActor(Test->Actor, OldLoc);
					}
					else
					{
						// Send the event that we are pushing the actor out of the way
						Test->Actor->eventPushedByMover(Actor, MoveDir*Actor->PushVelocityScale);
					}
				#endif
				}
			}

			if (!noProcess && Actor->eventEncroachingOn(Test->Actor) )
			{
				Mark.Pop();
				return 1;
			}
		}
	}

	// If bTouchNotify, send Touch and UnTouch notifies.
	if( bTouchNotify )
	{
		// UnTouch notifications.
		for( int i=0; i<Actor->Touching.Num(); i++ )
			if( !Actor->IsOverlapping(Actor->Touching(i)) )
				Actor->EndTouch( Actor->Touching(i), 0 );
	}

	// Notify the encroached actors but not the level.
	for( Test = FirstHit; Test; Test=Test->GetNext() )
		if
		(	Test->Actor!=Actor
		&&	Test->Actor!=GetLevelInfo() )
		{ 
			if( Actor->IsBlockedBy(Test->Actor) ) 
				Test->Actor->eventEncroachedBy(Actor);
			else if( bTouchNotify )
				Actor->BeginTouch( Test->Actor );
		}
							
	Mark.Pop();


	// Ok the move.
	return 0;
}

/*-----------------------------------------------------------------------------
	SinglePointCheck.
-----------------------------------------------------------------------------*/

//
// Check for nearest hit.
// Return 1 if no hit, 0 if hit.
//
UBOOL ULevel::SinglePointCheck
(
	FCheckResult&	Hit,
	FVector			Location,
	FVector			Extent,
	DWORD			ExtraNodeFlags,
	ALevelInfo*		Level,
	UBOOL			bActors
)
{
	FMemMark Mark(GMem);
	FCheckResult* Hits = MultiPointCheck( GMem, Location, Extent, ExtraNodeFlags, Level, bActors );
	if( !Hits )
	{
		Mark.Pop();
		return 1;
	}
	Hit = *Hits;
	for( Hits = Hits->GetNext(); Hits!=NULL; Hits = Hits->GetNext() )
		if( (Hits->Location-Location).SizeSquared() < (Hit.Location-Location).SizeSquared() )
			Hit = *Hits;
	Mark.Pop();
	return 0;
}

/*-----------------------------------------------------------------------------
	MultiPointCheck.
-----------------------------------------------------------------------------*/

FCheckResult* ULevel::MultiPointCheck( FMemStack& Mem, FVector Location, FVector Extent, DWORD ExtraNodeFlags, ALevelInfo* Level, UBOOL bActors )
{
	FCheckResult* Result=NULL;

	// Check with actors.
	if( bActors && Hash )
		Result = Hash->ActorPointCheck( Mem, Location, Extent, ExtraNodeFlags );

	// Check with level.
	if( Level )
	{
		FCheckResult TestHit(1.f);
		if( Level->GetLevel()->Model->PointCheck( TestHit, NULL, Location, Extent, 0 )==0 )
		{
			// Hit.
			TestHit.GetNext() = Result;
			Result            = new(GMem)FCheckResult(TestHit);
			Result->Actor     = Level;
		}
	}
	return Result;
}

/*-----------------------------------------------------------------------------
	SingleLineCheck.
-----------------------------------------------------------------------------*/

//
// Trace a line and return the first hit actor (LevelInfo means hit the world geomtry).
//
UBOOL ULevel::SingleLineCheck
(
	FCheckResult&	Hit,
	AActor*			SourceActor,
	const FVector&	End,
	const FVector&	Start,
	DWORD           TraceFlags,
	FVector			Extent,
	BYTE			ExtraNodeFlags,
	UBOOL			bMeshAccurate
)
{

	// Get list of hit actors.
	FMemMark Mark(GMem);
	FCheckResult* FirstHit = MultiLineCheck
	(
		GMem,
		End,
		Start,
		Extent,
		(TraceFlags & TRACE_AllColliding) ? 1 : 0,
		(TraceFlags & TRACE_Level       ) ? GetLevelInfo() : NULL,
		ExtraNodeFlags,
		bMeshAccurate
	);

	// Skip owned actors and return the one nearest actor.
	for( FCheckResult* Check = FirstHit; Check!=NULL; Check=Check->GetNext() )
	{
		if( !SourceActor || !SourceActor->IsOwnedBy( Check->Actor ) )
		{
			if( Check->Actor->IsA(ALevelInfo::StaticClass()) )
			{
				if( TraceFlags & TRACE_Level )
					break;
			}
			else if( Check->Actor->IsA(APawn::StaticClass()) )
			{
				if( TraceFlags & TRACE_Pawns )
					break;
			}
			else if( Check->Actor->IsA(AMover::StaticClass()) )
			{
				if( TraceFlags & TRACE_Movers )
					break;
			}
			else if( Check->Actor->IsA(AZoneInfo::StaticClass()) )
			{
				if( TraceFlags & TRACE_ZoneChanges )
					break;
			}
			else
			{
				if( TraceFlags & TRACE_Others )
				{
					if( TraceFlags & TRACE_OnlyProjActor )
					{
						if( Check->Actor->bProjTarget || (Check->Actor->bBlockActors && Check->Actor->bBlockPlayers) )
							break;
					}
					else break;
				}
			}
		}
	}
	if( Check )
	{
		Hit = *Check;
	}
	else
	{
		Hit.Time = 1.0;
		Hit.Actor = NULL;
	}

	Mark.Pop();
	return Check==NULL;
}

/*-----------------------------------------------------------------------------
	MultiLineCheck.
-----------------------------------------------------------------------------*/

FCheckResult* ULevel::MultiLineCheck
(
	FMemStack&		Mem,
	FVector			End,
	FVector			Start,
	FVector			Extent,
	UBOOL			bCheckActors,
	ALevelInfo*		LevelInfo,
	BYTE			ExtraNodeFlags,
	UBOOL			bMeshAccurate
)
{
	INT NumHits=0;
	FCheckResult Hits[64];

	STAT(GStat.CollisionCount++);			// JEP
	STAT(clock(GStat.CollisionCycles));		// JEP

	// Check for collision with the level, and cull by the end point for speed.
	FLOAT Dilation = 1.0;
	INT bOnlyCheckForMovers = 0;
	INT bHitWorld = 0;

	if( LevelInfo && LevelInfo->GetLevel()->Model->LineCheck( Hits[NumHits], NULL, End, Start, Extent, ExtraNodeFlags, bMeshAccurate )==0 )
	{
		bHitWorld = 1;
		Hits[NumHits].Actor = LevelInfo;
		FLOAT Dist = (Hits[NumHits].Location - Start).Size();
		Dilation = ::Min(1.f, Hits[NumHits].Time * (Dist + 5)/(Dist+0.0001f));
		End = Start + (End - Start) * Dilation;
		if( (Hits[NumHits].Time < 0.01f) && (Dist < 30) )
			bOnlyCheckForMovers = 1;
		NumHits++;
	}

	// Check with actors.
	if( bCheckActors && Hash )
	{
		for( FCheckResult* Link=Hash->ActorLineCheck( Mem, End, Start, Extent, ExtraNodeFlags, bMeshAccurate ); Link && NumHits<ARRAY_COUNT(Hits); Link=Link->GetNext() )
		{
			if ( !bOnlyCheckForMovers || Link->Actor->IsA(AMover::StaticClass()) )
			{
				if ( bHitWorld && Link->Actor->IsA(AMover::StaticClass()) 
					&& (Link->Normal == Hits[0].Normal)
					&& ((Link->Location - Hits[0].Location).SizeSquared() < 4) ) // make sure it wins compared to world
				{
					FVector TraceDir = End - Start;
					// Unprog fix by Gary Priest:
					FLOAT TraceDist = TraceDir.Size() + 0.0001f; // Add small fraction to avoid divide by zero error later

					TraceDir = TraceDir/TraceDist;
					Link->Location = Hits[0].Location - 2 * TraceDir;
					Link->Time = (Link->Location - Start).Size();
					Link->Time = Link->Time/TraceDist;
				}
				Link->Time *= Dilation;
				Hits[NumHits++] = *Link;
			}
		}
	}

	// Sort the list.
	FCheckResult* Result = NULL;
	if( NumHits )
	{
		appQsort( Hits, NumHits, sizeof(Hits[0]), (QSORT_COMPARE)CompareHits );
		Result = new(Mem,NumHits)FCheckResult;
		for( INT i=0; i<NumHits; i++ )
		{
			Result[i]      = Hits[i];
			Result[i].Next = (i+1<NumHits) ? &Result[i+1] : NULL;
		}
	}

	STAT(unclock(GStat.CollisionCycles));		// JEP

	return Result;
}

/*-----------------------------------------------------------------------------
	ULevel zone functions.
-----------------------------------------------------------------------------*/

//
// Figure out which zone an actor is in, update the actor's iZone,
// and notify the actor of the zone change.  Skips the zone notification
// if the zone hasn't changed.
//
void ULevel::SetActorZone( AActor* Actor, UBOOL bTest, UBOOL bForceRefresh )
{
	check(Actor);
	if( Actor->bDeleteMe )
		return;

	// If LevelInfo actor, handle specially.
	if( Actor == GetLevelInfo() )
	{
		Actor->Region = FPointRegion( GetLevelInfo() );
		return;
	}

	// See if this is a pawn.
	APawn* Pawn = Actor->IsA(APawn::StaticClass()) ? (APawn*)Actor : NULL;

	// If refreshing, init the actor's current zone.
	if( bForceRefresh )
	{
		// Init the actor's zone.
		Actor->Region = FPointRegion(GetLevelInfo());
		if( Pawn )
			Pawn->FootRegion = Pawn->HeadRegion = FPointRegion(GetLevelInfo());
	}

	// Find zone based on actor's location and see if it has changed.
	FPointRegion NewRegion = Model->PointRegion( Actors.Num() ? GetLevelInfo() : (ALevelInfo*)Actor, Actor->Location );
	if( NewRegion.Zone!=Actor->Region.Zone )
	{
		// Notify old zone info of player leaving.
		if( !bTest )
		{
			Actor->Region.Zone->eventActorLeaving(Actor);
			Actor->eventZoneChange( NewRegion.Zone );
		}
		Actor->Region = NewRegion;
		if( !bTest )
		{
			Actor->Region.Zone->eventActorEntered(Actor);
		}
	}
	else Actor->Region = NewRegion;
	checkSlow(Actor->Region.Zone!=NULL);

	if( Pawn )
	{
		// Update foot region.
		FPointRegion NewFootRegion = Model->PointRegion( GetLevelInfo(), Pawn->Location - FVector(0,0,Pawn->CollisionHeight) );
		if( NewFootRegion.Zone!=Pawn->FootRegion.Zone && !bTest )
			Pawn->eventFootZoneChange(NewFootRegion.Zone);
		Pawn->FootRegion = NewFootRegion;

		// Update head region.
		FPointRegion NewHeadRegion = Model->PointRegion( GetLevelInfo(), Pawn->Location + FVector(0,0,Pawn->EyeHeight) );
		if( NewHeadRegion.Zone!=Pawn->HeadRegion.Zone && !bTest )
			Pawn->eventHeadZoneChange(NewHeadRegion.Zone);
		Pawn->HeadRegion = NewHeadRegion;

		// update player replication info
		if ( (GetLevelInfo()->NetMode != NM_Client) && Pawn->PlayerReplicationInfo )
			Pawn->PlayerReplicationInfo->PlayerZone = Pawn->Region.Zone;
	}
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
