/*=============================================================================
	UnLevTic.cpp: Level timer tick function
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by Tim Sweeney
=============================================================================*/

#include "EnginePrivate.h"
#include "UnNet.h"

/*-----------------------------------------------------------------------------
	Helper classes.
-----------------------------------------------------------------------------*/

//
// Priority sortable list.
//
struct FActorPriority
{
	INT			    Priority;	// Update priority, higher = more important.
	AActor*			Actor;		// Actor.
	UActorChannel*	Channel;	// Actor channel.
	FActorPriority()
	{}
	FActorPriority( FVector& ViewPos, FVector& ViewDir, UNetConnection* InConnection, AActor* InActor )
	{
		guard(FActorPriority::FActorPriority);
		Actor       = InActor;
		Channel     = InConnection->ActorChannels.FindRef(Actor);
		FLOAT Time  = Channel ? (InConnection->Driver->Time - Channel->LastUpdateTime) : InConnection->Driver->SpawnPrioritySeconds;
		FLOAT Dot   = ViewDir | (Actor->Location - ViewPos).SafeNormal();
		Priority    = appRound(65536.0 * (3.0+Dot) * Actor->GetNetPriority( (Channel && Channel->Recent.Num()) ? (AActor*)&Channel->Recent(0) : NULL, Time, InConnection->BestLag ));
		if( InActor->bNetOptional )
			Priority -= 100000;
		unguard;
	}
	friend INT Compare( const FActorPriority* A, const FActorPriority* B )
	{
		return B->Priority - A->Priority;
	}
};

/*-----------------------------------------------------------------------------
	Tick a single actor.
-----------------------------------------------------------------------------*/

UBOOL AActor::Tick( FLOAT DeltaSeconds, ELevelTick TickType )
{
	guard(AActor::Tick);

	// Ignore actors in stasis
	if
	(	bStasis 
	&&	(bForceStasis || (Physics==PHYS_None) || (Physics == PHYS_Rotating))
	&&	(GetLevel()->TimeSeconds - GetLevel()->Model->Zones[Region.ZoneNumber].LastRenderTime > 5)
	&&	(Level->NetMode == NM_Standalone) )
		return 1;

	// Handle owner-first updating.
	if( Owner && (INT)Owner->bTicked!=GetLevel()->Ticked )
	{
		GetLevel()->NewlySpawned = new(GEngineMem)FActorLink(this,GetLevel()->NewlySpawned);
		return 0;
	}
	bTicked = GetLevel()->Ticked;
	APawn* Pawn = NULL;
	if( bIsPawn )
		Pawn = Cast<APawn>(this);

	INT bSimulatedPawn = ( Pawn && (Role == ROLE_SimulatedProxy) );

	// Update all animation, including multiple passes if necessary.
	INT Iterations = 0;
	FLOAT Seconds = DeltaSeconds;
	//if ( bSimulatedPawn )
	//	debugf("Animation %s frame %f rate %f tween %f",*AnimSequence,AnimFrame, AnimRate, TweenRate);
	while
	(	IsAnimating()
	&&	(Seconds>0.0)
	&&	(++Iterations <= 4) )
	{
		// Remember the old frame.
		FLOAT OldAnimFrame = AnimFrame;

		// Update animation, and possibly overflow it.
		if( AnimFrame >= 0.0 )
		{
			// Update regular or velocity-scaled animation.
			if( AnimRate >= 0.0 )
				AnimFrame += AnimRate * Seconds;
			else
				AnimFrame += ::Max( AnimMinRate, Velocity.Size() * -AnimRate ) * Seconds;

			// Handle all animation sequence notifys.
			if( bAnimNotify && Mesh )
			{
				const FMeshAnimSeq* Seq = Mesh->GetAnimSeq( AnimSequence );
				if( Seq )
				{
					FLOAT BestElapsedFrames = 100000.0;
					const FMeshAnimNotify* BestNotify = NULL;
					for( INT i=0; i<Seq->Notifys.Num(); i++ )
					{
						const FMeshAnimNotify& Notify = Seq->Notifys(i);
						if( OldAnimFrame<Notify.Time && AnimFrame>=Notify.Time )
						{
							FLOAT ElapsedFrames = Notify.Time - OldAnimFrame;
							if( BestNotify==NULL || ElapsedFrames<BestElapsedFrames )
							{
								BestElapsedFrames = ElapsedFrames;
								BestNotify        = &Notify;
							}
						}
					}
					if( BestNotify )
					{
						Seconds   = Seconds * (AnimFrame - BestNotify->Time) / (AnimFrame - OldAnimFrame);
						AnimFrame = BestNotify->Time;
						UFunction* Function = FindFunction( BestNotify->Function );
						if( Function )
							ProcessEvent( Function, NULL );
						continue;
					}
				}
			}

			// Handle end of animation sequence.
			if( AnimFrame<AnimLast )
			{
				// We have finished the animation updating for this tick.
				break;
			}
			else if( bAnimLoop )
			{
				if( AnimFrame < 1.0 )
				{
					// Still looping.
					Seconds = 0.0;
				}
				else
				{
					// Just passed end, so loop it.
					Seconds = Seconds * (AnimFrame - 1.0) / (AnimFrame - OldAnimFrame);
					AnimFrame = 0.0;
				}
				if( OldAnimFrame < AnimLast )
				{
					if( GetStateFrame()->LatentAction == EPOLL_FinishAnim )
						bAnimFinished = 1;
					if( !bSimulatedPawn )
						eventAnimEnd();
				}
			}
			else 
			{
				// Just passed end-minus-one frame.
				Seconds = Seconds * (AnimFrame - AnimLast) / (AnimFrame - OldAnimFrame);
				AnimFrame	 = AnimLast;
				bAnimFinished = 1;
				AnimRate      = 0.0;
				if ( !bSimulatedPawn )
					eventAnimEnd();
				
				if ( (RemoteRole < ROLE_SimulatedProxy) && !IsA(AWeapon::StaticClass()) )
				{
					SimAnim.X = 10000 * AnimFrame;
					SimAnim.Y = 5000 * AnimRate;
					if ( SimAnim.Y > 32767 )
						SimAnim.Y = 32767;
				}
			}
		}
		else
		{
			// Update tweening.
			AnimFrame += TweenRate * Seconds;
			if( AnimFrame >= 0.0 )
			{
				// Finished tweening.
				Seconds          = Seconds * (AnimFrame-0) / (AnimFrame - OldAnimFrame);
				AnimFrame = 0.0;
				if( AnimRate == 0.0 )
				{
					bAnimFinished = 1;
					if ( !bSimulatedPawn )
						eventAnimEnd();
				}
			}
			else
			{
				// Finished tweening.
				break;
			}
		}
	}

	// This actor is tickable.
	if( bSimulatedPawn )
	{
		// FIXME - predict fall for all pawns (COOP) - but need
		// new replicated bool for pawns which don't fly but don't fall
		// (i.e. stuck on wall, PHYS_Spider, etc.)
		if ( Pawn->bIsPlayer && !Pawn->bCanFly && !Region.Zone->bWaterZone )
		{
			// only add gravity if pawn is not resting on valid floor
			FCheckResult Hit(1.0);
			GetLevel()->SingleLineCheck(Hit, this, Location - FVector(0,0,8), Location, TRACE_VisBlocking, GetCylinderExtent());
			if ( (Hit.Time == 1.0) || (Hit.Normal.Z < 0.7) )
				Velocity += 0.5 * Region.Zone->ZoneGravity * DeltaSeconds;
		}
		//simulated pawns just predict location, no script execution
		moveSmooth(Velocity * DeltaSeconds);

		// Tick the nonplayer.
		if ( IsProbing(NAME_Tick) )
			eventTick(DeltaSeconds);
	}
	else if( RemoteRole == ROLE_AutonomousProxy ) 
	{
		if( Role == ROLE_Authority )
		{
			// update viewtarget replicated info
			APlayerPawn* PlayerPawn = NULL;
			if( Pawn )
			{
				PlayerPawn = Cast<APlayerPawn>(this);
			}
			if( PlayerPawn && PlayerPawn->ViewTarget )
			{
				APawn* TargetPawn = Cast<APawn>(PlayerPawn->ViewTarget);
				if ( TargetPawn )
				{
					PlayerPawn->TargetViewRotation = TargetPawn->ViewRotation;
					PlayerPawn->TargetEyeHeight = TargetPawn->EyeHeight;
					if ( TargetPawn->Weapon )
						PlayerPawn->TargetWeaponViewOffset = TargetPawn->Weapon->PlayerViewOffset;
				}
			}

			// Server handles timers for autonomous proxy.
			if( (TimerRate>0.0) && (TimerCounter+=DeltaSeconds)>=TimerRate )
			{
				// Normalize the timer count.
				INT TimerTicksPassed = 1;
				if( TimerRate > 0.0 )
				{
					TimerTicksPassed     = (int)(TimerCounter/TimerRate);
					TimerCounter -= TimerRate * TimerTicksPassed;
					if( TimerTicksPassed && !bTimerLoop )
					{
						// Only want a one-shot timer message.
						TimerTicksPassed = 1;
						TimerRate = 0.0;
					}
				}

				// Call timer routine with count of timer events that have passed.
				eventTimer();
			}
		}
	}
	else if( Role>=ROLE_SimulatedProxy )
	{
		APlayerPawn* PlayerPawn = NULL;
		if ( Pawn )
			PlayerPawn = Cast<APlayerPawn>(this);
		if( !PlayerPawn || !PlayerPawn->Player )
		{
			// Non-player update.
			if( TickType==LEVELTICK_ViewportsOnly )
				return 1;

			// Tick the nonplayer.
			if ( IsProbing(NAME_Tick) )
				eventTick(DeltaSeconds);
		}
		else
		{
			// Player update.
			if( PlayerPawn->IsA(ACamera::StaticClass()) && !(PlayerPawn->ShowFlags & SHOW_PlayerCtrl) )
				return 1;

			// Process PlayerTick with input.
			PlayerPawn->Player->ReadInput( DeltaSeconds );
			PlayerPawn->eventPlayerInput( DeltaSeconds );
			PlayerPawn->eventPlayerTick( DeltaSeconds );
			PlayerPawn->Player->ReadInput( -1.0 );

			if( GetLevel()->DemoRecDriver && !GetLevel()->DemoRecDriver->ServerConnection )
			{
				PlayerPawn->DemoViewPitch = PlayerPawn->ViewRotation.Pitch;
				PlayerPawn->DemoViewYaw = PlayerPawn->ViewRotation.Yaw;
			}
		}

		// Update the actor's script state code.
		ProcessState( DeltaSeconds );

		// Update timers.
		if( TimerRate>0.0 && (TimerCounter+=DeltaSeconds)>=TimerRate )
		{
			// Normalize the timer count.
			INT TimerTicksPassed = 1;
			if( TimerRate > 0.0 )
			{
				TimerTicksPassed     = (int)(TimerCounter/TimerRate);
				TimerCounter -= TimerRate * TimerTicksPassed;
				if( TimerTicksPassed && !bTimerLoop )
				{
					// Only want a one-shot timer message.
					TimerTicksPassed = 1;
					TimerRate = 0.0;
				}
			}

			// Call timer routine with count of timer events that have passed.
			eventTimer();
		}

		// Update LifeSpan.
		if( LifeSpan!=0.f )
		{
			LifeSpan -= DeltaSeconds;
			if( LifeSpan <= 0.0001 )
			{
				// Actor's LifeSpan expired.
				eventExpired();
				GetLevel()->DestroyActor( this );
				return 1;
			}
		}

		// Perform physics.
		if( Physics!=PHYS_None && Role!=ROLE_AutonomousProxy )
			performPhysics( DeltaSeconds );
	}
	else if ( Physics == PHYS_Falling ) // dumbproxies simulate falling if client side physics set
		performPhysics( DeltaSeconds );

	// During demo playback, setup view offsets for viewtarget
	if( GetLevel()->DemoRecDriver && GetLevel()->DemoRecDriver->ServerConnection )
	{
		if( Role == ROLE_Authority )
		{
			// update viewtarget replicated info
			APlayerPawn* PlayerPawn = NULL;
			if( Pawn )
			{
				PlayerPawn = Cast<APlayerPawn>(this);
			}
			if( PlayerPawn && PlayerPawn->ViewTarget && !PlayerPawn->bBehindView )
			{
				APawn* TargetPawn = Cast<APawn>(PlayerPawn->ViewTarget);
				if ( TargetPawn )
				{
					PlayerPawn->TargetViewRotation = TargetPawn->ViewRotation;
					PlayerPawn->TargetEyeHeight = TargetPawn->EyeHeight;
					if ( TargetPawn->Weapon )
						PlayerPawn->TargetWeaponViewOffset = TargetPawn->Weapon->PlayerViewOffset;
				}
			}
		}
	}
	
	// Update eyeheight and send visibility updates
	// with PVS, monsters look for other monsters, rather than sending msgs
	// Also sends PainTimer messages if PainTime
	if( Pawn )
	{
		if( Pawn->bIsPlayer && Role>=ROLE_AutonomousProxy )
		{
			if ( Pawn->bViewTarget )
				Pawn->eventUpdateEyeHeight( DeltaSeconds );
			else
				Pawn->ViewRotation = Rotation;
		}

		// update weapon location (in case its playing sounds, etc.)
		if ( Pawn->Weapon )
		{
			GetLevel()->FarMoveActor( Pawn->Weapon, Location );
		}
		if( Role==ROLE_Authority && TickType==LEVELTICK_All )
		{
			if( Pawn->SightCounter < 0.0 )
			{
				Pawn->SightCounter += 0.2;
			}
			Pawn->SightCounter = Pawn->SightCounter - DeltaSeconds; 
			if( Pawn->bIsPlayer && !Pawn->bHidden )
			{
				Pawn->ShowSelf();
			}
			if( Pawn->SightCounter<0.0 && Pawn->IsProbing(NAME_EnemyNotVisible) )
			{
				Pawn->CheckEnemyVisible();
				Pawn->SightCounter = 0.1;
			}
			if( Pawn->PainTime > 0.0 )
			{
				Pawn->PainTime -= DeltaSeconds;
				if (Pawn->PainTime < 0.001)
				{
					Pawn->PainTime = 0.0;
					Pawn->eventPainTimer();
				}
			}
			if( Pawn->SpeechTime > 0.0 )
			{
				Pawn->SpeechTime -= DeltaSeconds;
				if (Pawn->SpeechTime < 0.001)
				{
					Pawn->SpeechTime = 0.0;
					Pawn->eventSpeechTimer();
				}
			}
			if ( Pawn->bAdvancedTactics )
				Pawn->eventUpdateTactics(DeltaSeconds);
		}
	}

	return 1;
	unguard;
}

/*-----------------------------------------------------------------------------
	Network client tick.
-----------------------------------------------------------------------------*/

void ULevel::TickNetClient( FLOAT DeltaSeconds )
{
	guard(ULevel::TickNetClient);
	clock(NetTickCycles);
	if( NetDriver->ServerConnection->State==USOCK_Open )
	{
		for( TMap<AActor*,UActorChannel*>::TIterator ItC(NetDriver->ServerConnection->ActorChannels); ItC; ++ItC )
		{
			guard(UpdateLocalActors);
			UActorChannel* It = ItC.Value();
			APlayerPawn* PlayerPawn = Cast<APlayerPawn>(It->GetActor());
			if( PlayerPawn && PlayerPawn->Player )
				It->ReplicateActor();
			unguard;
		}
	}
	else if( NetDriver->ServerConnection->State==USOCK_Closed )
	{
		// Server disconnected.
		check(Engine->Client->Viewports.Num());
		Engine->SetClientTravel( Engine->Client->Viewports(0), TEXT("?failed"), 0, TRAVEL_Absolute );
	}
	unclock(NetTickCycles);
	unguard;
}

/*-----------------------------------------------------------------------------
	Network server ticking individual client.
-----------------------------------------------------------------------------*/

UBOOL ActorCanSee( AActor* Actor, APlayerPawn* RealViewer, AActor* Viewer, FVector SrcLocation )
{
	guardSlow(ActorCanSee);
	if( Actor->bAlwaysRelevant || Actor->IsOwnedBy(Viewer) || Actor->IsOwnedBy(RealViewer) || Actor==Viewer || Actor==RealViewer )
		return 1;
	else if( Actor->AmbientSound 
			&& ((Actor->Location-Viewer->Location).SizeSquared() < 0.3*Actor->WorldSoundRadius()*Actor->WorldSoundRadius()) )
		return 1;
	else if( Actor->Owner && Actor->Owner->bIsPawn && Actor==((APawn*)Actor->Owner)->Weapon )
		return ActorCanSee( Actor->Owner, RealViewer, Viewer, SrcLocation );
	else if( (Actor->bHidden || Actor->bOnlyOwnerSee) && !Actor->bBlockPlayers && !Actor->AmbientSound )
		return 0;
	else
		return Actor->GetLevel()->Model->FastLineCheck(Actor->Location,SrcLocation);
	unguardSlow;
}

INT ULevel::ServerTickClient( UNetConnection* Connection, FLOAT DeltaSeconds )
{
	guard(ULevel::ServerTickClient);
	check(Connection);
	check(Connection->State==USOCK_Pending || Connection->State==USOCK_Open || Connection->State==USOCK_Closed);
	DOUBLE CullTime=0.0, TraceTime=0.0, RepTime=0.0; INT CullCount=0, RepCount=0;

	// Handle not ready channels.
	INT Updated=0;
	if( Connection->Actor && Connection->IsNetReady(0) && Connection->State==USOCK_Open )
	{
		// Get list of visible/relevant actors.
		FMemMark Mark(GMem);
		NetTag++;
		Connection->TickCount++;

		// Set up to skip all sent temporary actors.
		guard(SkipSentTemporaries);
		for( INT i=0; i<Connection->SentTemporaries.Num(); i++ )
			Connection->SentTemporaries(i)->NetTag = NetTag;
		unguard;

		// Get viewer coordinates.
		AActor*      Viewer    = Connection->Actor;
		APlayerPawn* InViewer  = Connection->Actor;
		FVector      Location  = InViewer->Location;
		FRotator     Rotation  = InViewer->ViewRotation;
		InViewer->eventPlayerCalcView( Viewer, Location, Rotation );
		check(Viewer);

		// Compute ahead-vectors for prediction.
		FVector Ahead = FVector(0,0,0);
		if( Connection->TickCount & 1 )
		{
			FLOAT PredictSeconds = (Connection->TickCount&2) ? 0.4 : 0.9;
			Ahead = PredictSeconds * Viewer->Velocity;
			if( Viewer->Base )
				Ahead += PredictSeconds * Viewer->Base->Velocity;
			FCheckResult Hit(1.0);
			Hit.Location = Location + Ahead;
			Viewer->GetLevel()->Model->LineCheck(Hit,NULL,Hit.Location,Location,FVector(0,0,0),NF_NotVisBlocking);
			Location = Hit.Location;
		}

		// Make list of all actors to consider.
		CullTime-=appSeconds();
		INT              ConsiderCount  = 0;
		FActorPriority*  PriorityList   = new(GMem,Actors.Num())FActorPriority;
		FActorPriority** PriorityActors = new(GMem,Actors.Num())FActorPriority*;
		FVector          ViewPos        = Viewer->Location;
		FVector          ViewDir        = InViewer->ViewRotation.Vector();
		DOUBLE			 LastTime		= Connection->LastRepTime;
		DOUBLE           ThisTime       = Connection->Driver->Time;
		guard(MakeConsiderList);
		for( INT i=0; i<Actors.Num(); i++ )
		{
			AActor* Actor = Actors(i);
			if( Actor )
			{
				if
				(	(i>=iFirstDynamicActor || Actor->bAlwaysRelevant)
				&&	(Actor->NetTag!=NetTag)
				&&	(Actor->RemoteRole!=ROLE_None)
				&&	(appRound(LastTime*Actor->NetUpdateFrequency)!=appRound(ThisTime*Actor->NetUpdateFrequency)) )
				{
					CullCount++;
					Actor->NetTag                 = NetTag;
					PriorityList  [ConsiderCount] = FActorPriority( ViewPos, ViewDir, Connection, Actor );
					PriorityActors[ConsiderCount] = PriorityList + ConsiderCount++;
				}
				LastTime += 0.023;
				ThisTime += 0.023;
			}
		}
		Connection->LastRepTime = Connection->Driver->Time;
		CullTime+=appSeconds();
		unguard;

		// Sort by priority.
		guard(SortConsiderList);
		Sort( PriorityActors, ConsiderCount );
		unguard;

		// Update all relevant actors in sorted order.
		guard(UpdateRelevant);
		for( INT j=0; j<ConsiderCount && Connection->IsNetReady(0); j++ )
		{
			AActor*        Actor       = PriorityActors[j]->Actor;
			UActorChannel* Channel     = PriorityActors[j]->Channel;
			TraceTime-=appSeconds();
			UBOOL          CanSee      = ActorCanSee( Actor, InViewer, Viewer, Location );
			TraceTime+=appSeconds();
			if( CanSee || (Channel && NetDriver->Time-Channel->RelevantTime<NetDriver->RelevantTimeout) )
			{
				// Find or create the channel for this actor.
				Actor->GetLevel()->NumPV++;
				if( !Channel && Connection->PackageMap->ObjectToIndex(Actor->GetClass())!=INDEX_NONE )
				{
					// Create a new channel for this actor.
					Channel = (UActorChannel*)Connection->CreateChannel( CHTYPE_Actor, 1 );
					if( Channel )
						Channel->SetChannelActor( Actor );
				}
				if( Channel )
				{
					if( CanSee )
						Channel->RelevantTime = NetDriver->Time;
					if( Channel->IsNetReady(0) )
					{
						RepTime-=appSeconds();
						RepCount++;
						Channel->ReplicateActor();
						RepTime+=appSeconds();
						Updated++;
					}
				}
			}
			else if( Channel )
				Channel->Close();
		}
		unguard;
		Mark.Pop();
	}
	if( NetDriver->ProfileStats )
		debugf(TEXT("Cull=%01.4f (%03i) Trace=%01.4f Rep=%01.4f (%03i)"),CullTime*1000,CullCount,TraceTime*1000,RepTime*1000,RepCount);
	return Updated;
	unguard;
}

/*-----------------------------------------------------------------------------
	Network server tick.
-----------------------------------------------------------------------------*/

void ULevel::TickNetServer( FLOAT DeltaSeconds )
{
	guard(ULevel::TickNetServer);

	// Update all clients.
	clock(NetTickCycles);
	INT Updated=0;
	for( INT i=NetDriver->ClientConnections.Num()-1; i>=0; i-- )
		Updated += ServerTickClient( NetDriver->ClientConnections(i), DeltaSeconds );
	unclock(NetTickCycles);

	// Log message.
	if( (INT)(TimeSeconds-DeltaSeconds)!=(INT)(TimeSeconds) )
		debugf( NAME_Title, LocalizeProgress("RunningNet"), *GetLevelInfo()->Title, *URL.Map, NetDriver->ClientConnections.Num() );

	// Stats.
	if( Updated )
	{
		for( i=0; i<NetDriver->ClientConnections.Num(); i++ )
		{
			UNetConnection* Connection = NetDriver->ClientConnections(i);
			if( Connection->Actor && Connection->State==USOCK_Open )
			{
				if( Connection->UserFlags&1 )
				{
					// Send stats.
					INT NumActors=0;
					for( INT i=0; i<Actors.Num(); i++ )
						NumActors += Actors(i)!=NULL;
					FString Stats = FString::Printf
					(
						TEXT("r=%i cli=%i act=%03.1f (%i) net=%03.1f pv/c=%i rep/c=%i rpc/c=%i"),
						appRound(Engine->GetMaxTickRate()),
						NetDriver->ClientConnections.Num(),
						GSecondsPerCycle*1000*ActorTickCycles,
						NumActors,
						GSecondsPerCycle*1000*NetTickCycles,
						NumPV  /NetDriver->ClientConnections.Num(),
						NumReps/NetDriver->ClientConnections.Num(),
						NumRPC /NetDriver->ClientConnections.Num()
					);
					Connection->Actor->eventClientMessage( *Stats, NAME_None, 0 );
				}
				if( Connection->UserFlags&2 )
				{
					FString Stats = FString::Printf
					(
						TEXT("snd=%02.1f recv=%02.1f"),
						GSecondsPerCycle*1000*Connection->Driver->SendCycles,
						GSecondsPerCycle*1000*Connection->Driver->RecvCycles
					);
					Connection->Actor->eventClientMessage( *Stats, NAME_None, 0 );
				}
			}
		}
	}
	unguard;
}

/*-----------------------------------------------------------------------------
	Demo Recording tick.
-----------------------------------------------------------------------------*/

INT ULevel::TickDemoRecord( FLOAT DeltaSeconds )
{
	guard(ULevel::TickDemo);

	// All replicatable actors are assumed to be relevant for demo recording.
	UNetConnection* Connection = DemoRecDriver->ClientConnections(0);
	for( INT i=0; i<Actors.Num(); i++ )
	{
		AActor* Actor = Actors(i);
		UBOOL IsNetClient = (GetLevelInfo()->NetMode == NM_Client);
		if
		(	Actor
		&&	(Actor->RemoteRole!=ROLE_None || (IsNetClient && Actor->Role!=ROLE_None && Actor->Role != ROLE_Authority))
		&&  (i>=iFirstDynamicActor || Actor->IsA(AZoneInfo::StaticClass()))
		&&  (!Actor->bNetTemporary || Connection->SentTemporaries.FindItemIndex(Actor)==INDEX_NONE)
		&&  (Actor->bStatic || !Actor->GetClass()->GetDefaultActor()->bStatic))
		{
			// Create a new channel for this actor.
			UActorChannel* Channel = Connection->ActorChannels.FindRef( Actor );
			if( !Channel && Connection->PackageMap->ObjectToIndex(Actor->GetClass())!=INDEX_NONE )
			{
				// Check we haven't run out of actor channels.
				Channel = (UActorChannel*)Connection->CreateChannel( CHTYPE_Actor, 1 );
				check(Channel);
				Channel->SetChannelActor( Actor );
			}
			if( Channel )
			{
				// Send it out!
				check(!Channel->Closing);
				if( Channel->IsNetReady(0) )
				{
					Actor->bDemoRecording = 1;
					Actor->bClientDemoRecording = IsNetClient;
					if(IsNetClient)
						Exchange(Actor->RemoteRole, Actor->Role);
					Channel->ReplicateActor();
					if(IsNetClient)
						Exchange(Actor->RemoteRole, Actor->Role);
					Actor->bDemoRecording = 0;
					Actor->bClientDemoRecording = 0;
				}
			}
		}
	}
	return 1;
	unguard;
}
INT ULevel::TickDemoPlayback( FLOAT DeltaSeconds )
{
	guard(ULevel::TickDemoPlayback);
	if
	(	GetLevelInfo()->LevelAction==LEVACT_Connecting 
	&&	DemoRecDriver->ServerConnection->State!=USOCK_Pending )
	{
		GetLevelInfo()->LevelAction = LEVACT_None;
		Engine->SetProgress( TEXT(""), TEXT(""), 0.0 );
	} 
	if( DemoRecDriver->ServerConnection->State==USOCK_Closed )
	{
		// Demo stopped playing
		check(Engine->Client->Viewports.Num());
		Engine->SetClientTravel( Engine->Client->Viewports(0), TEXT("?entry"), 0, TRAVEL_Absolute );
	}
	return 1;
	unguard;
}

/*-----------------------------------------------------------------------------
	Main level timer tick handler.
-----------------------------------------------------------------------------*/

//
// Update the level after a variable amount of time, DeltaSeconds, has passed.
// All child actors are ticked after their owners have been ticked.
//
void ULevel::Tick( ELevelTick TickType, FLOAT DeltaSeconds )
{
	guard(ULevel::Tick);
	ALevelInfo* Info = GetLevelInfo();
	InitStats();
	FMemMark Mark(GMem);
	FMemMark EngineMark(GEngineMem);
	GInitRunaway();
	InTick=1;

	//Keep actor time profile FIXME TEMP!!!
	Info->AvgAITime = 0.95 * GetLevelInfo()->AvgAITime + 0.05 * 1000 * GSecondsPerCycle * ActorTickCycles;
	FLOAT ratio = GSecondsPerCycle * ActorTickCycles/DeltaSeconds;
	INT offset = (INT)(10 * ratio);
	if ( offset > 7 )
		offset = 7;
	else if ( offset < 0 )
		offset = 0;
	//debugf("ratio is %f, offset is %d",ratio,offset);
	Info->AIProfile[offset] += 1;

	// Update the net code and fetch all incoming packets.
	guard(UpdatePreNet);
	if( NetDriver )
	{
		NetDriver->TickDispatch( DeltaSeconds );
		if( NetDriver->ServerConnection )
			TickNetClient( DeltaSeconds );
	}
	unguard;

	// Fetch demo playback packets from demo file.
	guard(UpdatePreDemoRec);
	if( DemoRecDriver )
	{
		DemoRecDriver->TickDispatch( DeltaSeconds );
		if( DemoRecDriver->ServerConnection )
			TickDemoPlayback( DeltaSeconds );
	}
	unguard;

	// Update collision.
	guard(UpdateCollision);
	if( Hash )
		Hash->Tick();
	unguard;

	// Update time.
	guard(UpdateTime);
	DeltaSeconds *= Info->TimeDilation;
	TimeSeconds += DeltaSeconds;
	Info->TimeSeconds = TimeSeconds;
	UpdateTime(Info);
	if( Info->bPlayersOnly )
		TickType = LEVELTICK_ViewportsOnly;
	unguard;

	// Clamp time between 200 fps and 2.5 fps.
	DeltaSeconds = Clamp(DeltaSeconds,0.005f,0.40f);

	// If caller wants time update only, or we are paused, skip the rest.
	clock(ActorTickCycles);
	if
	(	(TickType!=LEVELTICK_TimeOnly)
	&&	Info->Pauser==TEXT("")
	&&	(!NetDriver || !NetDriver->ServerConnection || NetDriver->ServerConnection->State==USOCK_Open) )
	{
		// Tick all actors, owners before owned.
		guard(TickAllActors);
		NewlySpawned = NULL;
		INT Updated  = 0;
		for( INT iActor=iFirstDynamicActor; iActor<Actors.Num(); iActor++ )
			if( Actors( iActor ) )
				Updated += Actors( iActor )->Tick(DeltaSeconds,TickType);
		while( NewlySpawned && Updated )
		{
			FActorLink* Link = NewlySpawned;
			NewlySpawned     = NULL;
			Updated          = 0;
			for( Link; Link; Link=Link->Next )
				if( Link->Actor->bTicked!=(DWORD)Ticked )
					Updated += Link->Actor->Tick( DeltaSeconds, TickType );
		}
		unguard;
	}
	else if( Info->Pauser!=TEXT("") )
	{
		// Absorb input if paused.
		guard(AbsorbedPaused);
		for( INT iActor=iFirstDynamicActor; iActor<Actors.Num(); iActor++ )
		{
			APlayerPawn* PlayerPawn=Cast<APlayerPawn>(Actors(iActor));
			if( PlayerPawn && PlayerPawn->Player )
			{
				PlayerPawn->Player->ReadInput( DeltaSeconds );
				PlayerPawn->eventPlayerInput( DeltaSeconds );
				for( TFieldIterator<UFloatProperty> It(PlayerPawn->GetClass()); It; ++It )
					if( It->PropertyFlags & CPF_Input )
						*(FLOAT*)((BYTE*)PlayerPawn + It->Offset) = 0.f;
			}
			else if( Actors(iActor) && Actors(iActor)->bAlwaysTick )
				Actors(iActor)->Tick(DeltaSeconds,TickType);
		}
		unguard;
	}
	unclock(ActorTickCycles);

	// Update net server and flush networking.
	guard(UpdateNetServer);
	if( NetDriver )
	{
		if( !NetDriver->ServerConnection )
			TickNetServer( DeltaSeconds );
		NetDriver->TickFlush();
	}
	unguard;

	// Demo Recording.
	guard(UpdatePostDemoRec);
	if( DemoRecDriver )
	{
		if( !DemoRecDriver->ServerConnection )
			TickDemoRecord( DeltaSeconds );
		DemoRecDriver->TickFlush();
	}
	unguard;

	// Finish up.
	Ticked = !Ticked;
	InTick = 0;
	Mark.Pop();
	EngineMark.Pop();
	CleanupDestroyed( 0 );

	unguardf(( TEXT("(NetMode=%i)"), GetLevelInfo()->NetMode ));
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
