/*=============================================================================
	UnController.cpp: AI implementation

  This contains both C++ methods (movement and reachability), as well as some 
  AI related natives

	Copyright 2000 Epic MegaGames, Inc. This software is a trade secret.

	Revision history:
		* Created by Steven Polge 4/00
=============================================================================*/
#include "EnginePrivate.h"
#include "UnNet.h"
#include "FConfigCacheIni.h"

//-------------------------------------------------------------------------------------------------
/*
Node Evaluation functions, used with APawn::BreadthPathTo()
*/

// declare type for node evaluation functions
typedef FLOAT ( *NodeEvaluator ) (ANavigationPoint*, APawn*, FLOAT);
#if 0
FLOAT FindBestInventory( ANavigationPoint* CurrentNode, APawn* seeker, FLOAT bestWeight )
{
	if ( !CurrentNode->IsA(AInventorySpot::StaticClass()) )
		return 0;

	APickup* item = ((AInventorySpot *)CurrentNode)->markedItem;
	//if ( item )
	//	debugf(NAME_DevPath,"looking at %s with weight %f (dist %d) (and touch %d with latent %f)", item->GetName(), item->eventBotDesireability(this)/currentnode->visitedWeight, currentnode->visitedWeight, item->IsProbing(NAME_Touch), item->LatentFloat );
	// FIXME - not all predict respawns???
	if ( item && (item->IsProbing(NAME_Touch) || (item->LatentFloat < 5.f)) 
			&& (item->MaxDesireability/CurrentNode->visitedWeight > bestWeight) )
		return item->eventBotDesireability(seeker)/CurrentNode->visitedWeight;
	return 0.f;
}

FLOAT FindRandomPath( ANavigationPoint* CurrentNode, APawn* seeker, FLOAT bestWeight )
{
	return appRand();
}
//----------------------------------------------------------------------------------

enum EAIFunctions
{
	AI_PollMoveTo = 501,
	AI_PollMoveToward = 503,
	AI_PollStrafeTo = 505,
	AI_PollStrafeFacing = 507,
	AI_PollFinishRotation = 509,
	AI_PollWaitForLanding = 528,
};

void APlayerController::execUpdateURL( FFrame& Stack, RESULT_DECL )
{
	guard(APlayerController::execUpdateURL);

	P_GET_STR(NewOption);
	P_GET_STR(NewValue);
	P_GET_UBOOL(bSaveDefault);
	P_FINISH;

	UGameEngine* GameEngine = CastChecked<UGameEngine>( GetLevel()->Engine );
	GameEngine->LastURL.AddOption( *(NewOption + TEXT("=") + NewValue) );
	if( bSaveDefault )
		GameEngine->LastURL.SaveURLConfig( TEXT("DefaultPlayer"), *NewOption, TEXT("User") );
	unguard;
}

void APlayerController::execGetDefaultURL( FFrame& Stack, RESULT_DECL )
{
	guard(APlayerController::execGetDefaultURL);

	P_GET_STR(Option);
	P_FINISH;

	FURL URL;
	URL.LoadURLConfig( TEXT("DefaultPlayer"), TEXT("User") );

	*(FString*)Result = FString( URL.GetOption(*(Option + FString(TEXT("="))), TEXT("")) );
	unguard;
}


void APlayerController::execGetEntryLevel( FFrame& Stack, RESULT_DECL )
{
	guard(APlayerController::execGetEntryLevel);
	P_FINISH;

	check(XLevel);
	check(XLevel->Engine);
	check((UGameEngine*)(XLevel->Engine));
	check(((UGameEngine*)(XLevel->Engine))->GEntry);

	*(ALevelInfo**)Result = ((UGameEngine*)(XLevel->Engine))->GEntry->GetLevelInfo();

	unguard;
}

void APlayerController::execSetViewTarget( FFrame& Stack, RESULT_DECL )
{
	guard(APlayerController::execResetKeyboard);

	P_GET_ACTOR(NewViewTarget);
	P_FINISH;

	if ( NewViewTarget )
		ViewTarget = NewViewTarget;
	else if ( Pawn && !Pawn->bDeleteMe )
		ViewTarget = Pawn;
	else
		ViewTarget = this;
	
	unguard;
}

void APlayerController::execResetKeyboard( FFrame& Stack, RESULT_DECL )
{
	guard(APlayerController::execResetKeyboard);

	P_FINISH;

	UViewport* Viewport = Cast<UViewport>(Player);
	if( Viewport && Viewport->Input )
		ResetConfig(Viewport->Input->GetClass());
	unguard;
}

void AController::execFindBestInventoryPath( FFrame& Stack, RESULT_DECL )
{
	guard(APawn::execFindBestInventoryPath);

	P_GET_FLOAT_REF(Weight);
	P_GET_UBOOL(bPredictRespawns);
	P_FINISH;

	clock(GetLevel()->FindPathCycles);

	if ( !Pawn )
	{
		*(AActor**)Result = NULL; 
		return;
	}
	AActor * bestPath = NULL;
	*Weight = Pawn->findPathToward(NULL,FVector(0,0,0),&FindBestInventory, 1, *Weight);
	if ( *Weight > 0.f )
		bestPath = SetPath();
	unclock(GetLevel()->FindPathCycles);
	//debugf("Find path to time was %f", GetLevel()->FindPathCycles * MSecPerCycle);

	*(AActor**)Result = bestPath; 
	unguard;
}

void APlayerController::execConsoleCommand( FFrame& Stack, RESULT_DECL )
{
	guard(APlayerController::execConsoleCommand);

	P_GET_STR(Command);
	P_FINISH;

	*(FString*)Result = TEXT("");
	FStringOutputDevice StrOut;
	if( Player )
	{

		Player->Exec( *Command, StrOut );
		*(FString*)Result = *StrOut;
	}
	else
	{
		GetLevel()->Engine->Exec( *Command, StrOut );
		*(FString*)Result = *StrOut;
	}

	unguard;
}

void AController::execStopWaiting( FFrame& Stack, RESULT_DECL )
{
	guardSlow(AController::execStopWaiting);

	P_FINISH;

	if( GetStateFrame()->LatentAction == EPOLL_Sleep )
		LatentFloat = -1.f;

	unguardSlow;
}

/* CanSee()
returns true if LineOfSightto object and it is within creature's 
peripheral vision
*/

void AController::execCanSee( FFrame& Stack, RESULT_DECL )
{
	guardSlow(APawn::execCanSee);

	P_GET_ACTOR(Other);
	P_FINISH;

	*(DWORD*)Result = SeePawn((APawn *)Other);
	unguardSlow;
}

void AController::execPickTarget( FFrame& Stack, RESULT_DECL )
{
	guardSlow(AController::execPickTarget);

	P_GET_FLOAT_REF(bestAim);
	P_GET_FLOAT_REF(bestDist);
	P_GET_VECTOR(FireDir);
	P_GET_VECTOR(projStart);
	P_FINISH;
	APawn *pick = NULL;
	FLOAT VerticalAim = *bestAim * 3.f - 2.f;

	for ( AController *next=GetLevel()->GetLevelInfo()->ControllerList; next!=NULL; next=next->nextController )
	{
		if ( (next != this) && next->Pawn && (next->Pawn->Health > 0) && next->Pawn->bProjTarget
			&& (!PlayerReplicationInfo || !next->PlayerReplicationInfo
				|| !Level->Game->bTeamGame
				|| (PlayerReplicationInfo->Team != next->PlayerReplicationInfo->Team)) )
		{
			FVector AimDir = next->Pawn->Location - projStart;
			FLOAT newAim = FireDir | AimDir;
			FVector FireDir2D = FireDir;
			FireDir2D.Z = 0;
			FireDir2D.Normalize();
			FLOAT newAim2D = FireDir2D | AimDir;
			if ( newAim > 0 )
			{
				FLOAT FireDist = AimDir.SizeSquared();
				if ( ((FireDist < 16000000.f) 
					|| (IsA(APlayerController::StaticClass()) && (FovAngle != ((APlayerController*)this)->DefaultFOV))) )
				{
					FireDist = appSqrt(FireDist);
					newAim = newAim/FireDist;
					if ( newAim > *bestAim )
					{
						if( GetLevel()->Model->FastLineCheck(next->Pawn->Location, Pawn->Location + FVector(0,0,Pawn->EyeHeight)) 
							|| GetLevel()->Model->FastLineCheck(next->Pawn->Location + FVector(0,0,next->Pawn->EyeHeight), Pawn->Location + FVector(0,0,Pawn->EyeHeight)) )
						{
							pick = next->Pawn;
							*bestAim = newAim;
							*bestDist = FireDist;
						}
					}
					else if ( !pick )
					{
						newAim2D = newAim2D/FireDist;
						if ( (newAim2D > *bestAim) && (newAim > VerticalAim) 
							&& (GetLevel()->Model->FastLineCheck(next->Pawn->Location, Pawn->Location + FVector(0,0,Pawn->EyeHeight))
							|| GetLevel()->Model->FastLineCheck(next->Pawn->Location + FVector(0,0,next->Pawn->EyeHeight), Pawn->Location + FVector(0,0,Pawn->EyeHeight))) )
						{
							pick = next->Pawn;
							*bestDist = FireDist;
						}
					}
				}
			}
		}
	}

	*(APawn**)Result = pick; 
	unguardSlow;
}

void AController::execPickAnyTarget( FFrame& Stack, RESULT_DECL )
{
	guardSlow(APawn::execPickAnyTarget);

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
			if ( next->bProjTarget && !next->bIsPawn )
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
	unguardSlow;
}

void AController::execAddController( FFrame& Stack, RESULT_DECL )
{
	guardSlow(APawn::execAddController);

	P_FINISH;

	nextController = Level->ControllerList;
	Level->ControllerList = this;
	unguardSlow;
}

void AController::execRemoveController( FFrame& Stack, RESULT_DECL )
{
	guardSlow(APawn::execRemoveController);

	P_FINISH;

	AController *next = Level->ControllerList;
	if ( next == this )
		Level->ControllerList = next->nextController;
	else
	{
		while ( next )
		{
			if ( next->nextController == this )
			{
				next->nextController = nextController;
				break;
			}
			next = next->nextController;
		}
	}

	unguardSlow;
}

/* execWaitForLanding()
wait until physics is not PHYS_Falling
*/
void AController::execWaitForLanding( FFrame& Stack, RESULT_DECL )
{
	guardSlow(AController::execWaitForLanding);

	P_FINISH;

	LatentFloat = 2.5;
	if ( Pawn && (Pawn->Physics == PHYS_Falling) )
		GetStateFrame()->LatentAction = AI_PollWaitForLanding;
	unguardSlow;
}

void AController::execPollWaitForLanding( FFrame& Stack, RESULT_DECL )
{
	guardSlow(AController::execPollWaitForLanding);
	if( Pawn && (Pawn->Physics != PHYS_Falling) )
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
	unguardSlow;
}
IMPLEMENT_FUNCTION( AController, AI_PollWaitForLanding, execPollWaitForLanding);

void AController::execPickWallAdjust( FFrame& Stack, RESULT_DECL )
{
	guardSlow(AController::execPickWallAdjust);

	P_FINISH;
	if ( !Pawn )
		return;
	clock(GetLevel()->FindPathCycles);
	*(DWORD*)Result = Pawn->PickWallAdjust();
	unclock(GetLevel()->FindPathCycles);
	unguardSlow;
}

void AController::execFindStairRotation( FFrame& Stack, RESULT_DECL )
{
	guardSlow(APawn::execFindStairRotation);

	P_GET_FLOAT(deltaTime);
	P_FINISH;

	if ( !Pawn || (deltaTime > 0.33) )
	{
		*(DWORD*)Result = Rotation.Pitch;
		return;
	}
	if (Rotation.Pitch > 32768)
		Rotation.Pitch = (Rotation.Pitch & 65535) - 65536;
	
	FCheckResult Hit(1.f);
	FRotator LookRot = Rotation;
	LookRot.Pitch = 0;
	FVector Dir = LookRot.Vector();
	FVector EyeSpot = Pawn->Location + FVector(0,0,Pawn->BaseEyeHeight);
	FLOAT height = Pawn->CollisionHeight + Pawn->BaseEyeHeight; 
	FVector CollisionSlice(Pawn->CollisionRadius,Pawn->CollisionRadius,1);

	GetLevel()->SingleLineCheck(Hit, this, EyeSpot + 2 * height * Dir, EyeSpot, TRACE_VisBlocking, CollisionSlice);
	FLOAT Dist = 2 * height * Hit.Time;
	int stairRot = 0;
	if (Dist > 0.8 * height)
	{
		FVector Spot = EyeSpot + 0.5 * Dist * Dir;
		FLOAT Down = 3 * height;
		GetLevel()->SingleLineCheck(Hit, this, Spot - FVector(0,0,Down), Spot, TRACE_VisBlocking, CollisionSlice);
		if (Hit.Time < 1.f)
		{
			FLOAT firstDown = Down * Hit.Time;
			if (firstDown < 0.7f * height - 6.f) // then up or level
			{
				Spot = EyeSpot + Dist * Dir;
				GetLevel()->SingleLineCheck(Hit, this, Spot - FVector(0,0,Down), Spot, TRACE_VisBlocking, CollisionSlice);
				stairRot = ::Max(0, Rotation.Pitch);
				if ( Down * Hit.Time < firstDown - 10 ) 
					stairRot = 3600;
			}
			else if  (firstDown > 0.7f * height + 6.f) // then down or level
			{
				GetLevel()->SingleLineCheck(Hit, this, Location + 0.9*Dist*Dir, Location, TRACE_VisBlocking);
				if (Hit.Time == 1.f)
				{
					Spot = EyeSpot + Dist * Dir;
					GetLevel()->SingleLineCheck(Hit, this, Spot - FVector(0,0,Down), Spot, TRACE_VisBlocking, CollisionSlice);
					stairRot = Min(0, Rotation.Pitch);
					if (Down * Hit.Time > firstDown + 10)
						stairRot = -4000;
				}
			}
		}
	}
	INT Diff = Abs(Rotation.Pitch - stairRot);
	if( (Diff > 0) && (Level->TimeSeconds - GroundPitchTime > 0.25) )
	{
		FLOAT RotRate = 4;
		if( Diff < 1000 )
			RotRate = 4000/Diff; 

		RotRate = ::Min(1.f, RotRate * deltaTime);
		stairRot = appRound(FLOAT(Rotation.Pitch) * (1 - RotRate) + FLOAT(stairRot) * RotRate);
	}
	else
	{
		if ( (Diff < 10) && (stairRot < 10) )
			GroundPitchTime = Level->TimeSeconds;
		stairRot = Rotation.Pitch;
	}
	*(DWORD*)Result = stairRot; 
	unguardSlow;
}

void AController::execEAdjustJump( FFrame& Stack, RESULT_DECL )
{
	guardSlow(AController::execEAdjustJump);

	FVector Landing;
	FVector vel = Velocity;

	P_FINISH;
	if ( Pawn )
		Pawn->SuggestJumpVelocity(Destination, vel);

	*(FVector*)Result = vel;
	unguardSlow;
}

void AController::execactorReachable( FFrame& Stack, RESULT_DECL )
{
	guardSlow(AController::execActorReachable);

	P_GET_ACTOR(actor);
	P_FINISH;

	if ( !actor || !Pawn )
	{
		//debugf(NAME_DevPath,"Warning: No goal for ActorReachable by %s in %s",GetName(), GetStateFrame()->Describe() );
		*(DWORD*)Result = 0; 
		return;
	}

	clock(GetLevel()->FindPathCycles);

	*(DWORD*)Result = Pawn->actorReachable(actor);  
	unclock(GetLevel()->FindPathCycles);
	unguardSlow;
}

void AController::execpointReachable( FFrame& Stack, RESULT_DECL )
{
	guardSlow(AController::execPointReachable);

	P_GET_VECTOR(point);
	P_FINISH;

	clock(GetLevel()->FindPathCycles);
	if ( !Pawn )
	{
		*(DWORD*)Result = 0;  
		unclock(GetLevel()->FindPathCycles);
		return;
	}

	*(DWORD*)Result = Pawn->pointReachable(point);  
	unclock(GetLevel()->FindPathCycles);
	unguardSlow;
}

/* FindPathTo() and FindPathToward()
returns the best pathnode toward a point or actor - even if it is directly reachable
If there is no path, returns None
By default clears paths.  If script wants to preset some path weighting, etc., then
it can explicitly clear paths using execClearPaths before presetting the values and 
calling FindPathTo with clearpath = 0
*/
AActor* AController::FindPath(FVector point, AActor* goal, INT bClearPaths)
{
	guard(AController::FindPath);
	clock(GetLevel()->FindPathCycles);
	if ( !Pawn )
		return NULL;
	AActor * bestPath = NULL;
	if ( Pawn->findPathToward(goal,point,NULL, bClearPaths) > 0.f )
		bestPath = SetPath();

	unclock(GetLevel()->FindPathCycles);
	//debugf("Find path to time was %f", GetLevel()->FindPathCycles * MSecPerCycle);
	return bestPath;
	unguard;
}

void AController::execFindPathTo( FFrame& Stack, RESULT_DECL )
{
	guardSlow(AController::execFindPathTo);

	P_GET_VECTOR(point);
	P_GET_UBOOL_OPTX(bClearPaths, 1);
	P_FINISH;

	*(AActor**)Result = FindPath(point, NULL, bClearPaths);
	unguardSlow;
}

void AController::execFindPathToward( FFrame& Stack, RESULT_DECL )
{
	guardSlow(AController::execFindPathToward);

	P_GET_ACTOR(goal);
	P_GET_UBOOL_OPTX(bClearPaths, 1);
	P_FINISH;

	if ( !goal )
	{
		debugf(NAME_DevPath,TEXT("Warning: No goal for FindPathToward by %s in %s"),GetName(), GetStateFrame()->Describe() );
		*(AActor**)Result = NULL; 
		return;
	}
	*(AActor**)Result = FindPath(FVector(0,0,0), goal, bClearPaths);
	unguardSlow;
}

void AController::execFindPathTowardNearest( FFrame& Stack, RESULT_DECL )
{
	guardSlow(AController::execFindPathToward);

	P_GET_OBJECT(UClass,GoalClass);
	P_FINISH;

	if ( !GoalClass || !Pawn )
	{
		debugf(NAME_DevPath,TEXT("Warning: No goal for FindPathTowardNearest by %s in %s"),GetName(), GetStateFrame()->Describe() );
		*(AActor**)Result = NULL; 
		return;
	}
	Pawn->clearPaths();
	ANavigationPoint* Found = NULL;

	// mark appropriate Navigation points
	for ( ANavigationPoint* Nav=Level->NavigationPointList; Nav; Nav=Nav->nextNavigationPoint )
		if ( Nav->GetClass() == GoalClass )
		{
			Nav->bEndPoint = 1;
			Found = Nav;
		}
	if ( Found )
		*(AActor**)Result = FindPath(FVector(0,0,0), Found, 0);
	else
		*(AActor**)Result = NULL;
	unguardSlow;
}

/* FindRandomDest()
returns a random pathnode which is reachable from the creature's location.  Note that the path to
this destination is in the RouteCache.
*/
void AController::execFindRandomDest( FFrame& Stack, RESULT_DECL )
{
	guardSlow(AController::execFindPathTo);

	P_GET_UBOOL_OPTX(bClearPaths, 1);
	P_FINISH;

	if ( !Pawn )
		return;

	clock(GetLevel()->FindPathCycles);
	if (bClearPaths)
		Pawn->clearPaths();
	ANavigationPoint * bestPath = NULL;
	if ( Pawn->findPathToward(NULL,FVector(0,0,0),&FindRandomPath) > 0 )
		bestPath = Cast<ANavigationPoint>(RouteGoal);

	unclock(GetLevel()->FindPathCycles);

	*(ANavigationPoint**)Result = bestPath; 
	unguardSlow;
}

void AController::execClearPaths( FFrame& Stack, RESULT_DECL )
{
	guardSlow(AController::execClearPaths);

	P_FINISH;
	if ( !Pawn )
		return;
	clock(GetLevel()->FindPathCycles);
	Pawn->clearPaths(); 
	unclock(GetLevel()->FindPathCycles);
	unguardSlow;
}


void AController::execLineOfSightTo( FFrame& Stack, RESULT_DECL )
{
	guardSlow(AController::execLineOfSightTo);

	P_GET_ACTOR(Other);
	P_FINISH;

	*(DWORD*)Result = LineOfSightTo(Other);
	unguardSlow;
}

/* execMoveTo()
start moving to a point -does not use routing
Destination is set to a point
//FIXME - don't use ground speed for flyers (or set theirs = flyspeed)
*/
void AController::execMoveTo( FFrame& Stack, RESULT_DECL )
{
	guardSlow(AController::execMoveTo);

	P_GET_VECTOR(dest);
	P_GET_ACTOR_OPTX(viewfocus, NULL);
	P_GET_FLOAT_OPTX(speed, 1.f);
	P_FINISH;

	if ( !Pawn )
		return;
	Pawn->bIsCrouching = false;
	FVector MoveDir = dest - Pawn->Location;
	FLOAT MoveSize = MoveDir.Size();
	MoveTarget = NULL;
	Pawn->bReducedSpeed = 0;
	Pawn->DesiredSpeed = Clamp(Pawn->MaxDesiredSpeed, 0.f, speed);
	Focus = viewfocus;
	if ( !bIsPlayer && Focus )
		Pawn->DesiredSpeed *= 0.8f;
	Pawn->setMoveTimer(MoveSize); 
	GetStateFrame()->LatentAction = AI_PollMoveTo;
	Destination = dest;
	if ( !Focus )
		FocalPoint = Destination;
	bAdjusting = false;
	Pawn->moveToward(Destination, NULL);
	unguardSlow;
}

void AController::execPollMoveTo( FFrame& Stack, RESULT_DECL )
{
	guardSlow(AController::execPollMoveTo);
	if( !Pawn )
	{
		GetStateFrame()->LatentAction = 0; 
		return;
	}
	if ( bAdjusting )
		bAdjusting = !Pawn->moveToward(AdjustLoc, NULL);
	if( !bAdjusting && Pawn->moveToward(Destination, NULL) )
		GetStateFrame()->LatentAction = 0; 
	unguardSlow;
}
IMPLEMENT_FUNCTION( AController, AI_PollMoveTo, execPollMoveTo);

/* execMoveToward()
start moving toward a goal actor -does not use routing
MoveTarget is set to goal
*/
void AController::execMoveToward( FFrame& Stack, RESULT_DECL )
{
	guardSlow(AController::execMoveToward);

	P_GET_ACTOR(goal);
	P_GET_ACTOR_OPTX(viewfocus, goal);
	P_GET_FLOAT_OPTX(speed, 1.f);
	P_FINISH;

	if ( !goal || !Pawn )
	{
		//Stack.Log("MoveToward with no goal");
		return;
	}

	FVector Move = goal->Location - Pawn->Location;	
	Pawn->bIsCrouching = false;
	Pawn->bReducedSpeed = 0;
	Pawn->DesiredSpeed = Clamp(Pawn->MaxDesiredSpeed, 0.f, speed);
	MoveTarget = goal;
	Focus = viewfocus;
	if ( !bIsPlayer && (Focus != MoveTarget) )
		Pawn->DesiredSpeed *= 0.8f;
	if (goal->bIsPawn)
		MoveTimer = 1.2f; //max before re-assess movetoward
	else
	{
		FLOAT MoveSize = Move.Size();
		Pawn->setMoveTimer(MoveSize);
	}
	Destination = MoveTarget->Location; 
	GetStateFrame()->LatentAction = AI_PollMoveToward;
	bAdjusting = false;
	// if necessary, allow the pawn to prepare for this move
	// give pawn the opportunity if its a navigation network move,
	// based on the reachspec
	ANavigationPoint *NavGoal = Cast<ANavigationPoint>(goal);

	if ( NavGoal )
	{
		FLOAT Rad = Pawn->CollisionRadius;
		FLOAT Hgt = Pawn->CollisionHeight;
		if ( Pawn->ValidAnchor() )
		{
			// find the reachspec
			FReachSpec *spec = NULL;
			for (INT i=0; i<16; i++ )
			{
				if ( Pawn->Anchor->Paths[i] == -1 )
					break;
				spec = &GetLevel()->ReachSpecs(Pawn->Anchor->Paths[i]);
				if ( spec->End == goal )
					break;
			}
			if ( spec && (spec->End == goal) )
			{
				Rad = spec->CollisionRadius;
				Hgt = spec->CollisionHeight;
			}
		}
		// if the reachspec isn't currently supported by the pawn
		// then give the pawn
		// and opportunity to perform some latent preparation (Pawn will set its bPreparingMove=true if it needs latent preparation)
		
		if ( (Rad < Pawn->CollisionRadius) || (Hgt < Pawn->CollisionHeight) || NavGoal->bSpecialMove )
			Pawn->eventPrepareForMove(NavGoal, Rad, Hgt);
	}
	if ( !Pawn->bPreparingMove )
		Pawn->moveToward(Destination, MoveTarget);
	if ( bAdvancedTactics )
	{
		// make sure that if dest is a NavigationPoint, it doesn't discourage strafing to it
		ANavigationPoint *NavDest = Cast<ANavigationPoint>(MoveTarget);
		if ( NavDest && NavDest->bNeverUseStrafing )
			bAdvancedTactics = false;
	}
	unguardSlow;
}

void AController::execPollMoveToward( FFrame& Stack, RESULT_DECL )
{
	guardSlow(AController::execPollMoveToward);

	if( !MoveTarget || !Pawn )
	{
		//Stack.Log("MoveTarget cleared during movetoward");
		GetStateFrame()->LatentAction = 0;
		return;
	}
	if ( Pawn->bPreparingMove )
		return;
	if ( bAdjusting )
		bAdjusting = !Pawn->moveToward(AdjustLoc, MoveTarget);
	if ( !bAdjusting )
	{
		Destination = MoveTarget->Location;
		if( Pawn->Physics==PHYS_Flying && MoveTarget->IsA(APawn::StaticClass()) )
			Destination.Z += 0.7 * MoveTarget->CollisionHeight;
		else if( Pawn->Physics == PHYS_Spider )
			Destination = Destination - MoveTarget->CollisionRadius * Pawn->Floor;

		FLOAT oldDesiredSpeed = Pawn->DesiredSpeed;
		if ( bAdvancedTactics )
		{
			if ( TacticalOffset < Level->TimeSeconds - 0.5f )
			{
				TacticalOffset = Level->TimeSeconds;
				eventUpdateTactics();
			}
			if ( Pawn->Physics == PHYS_Walking )
			{
				FLOAT Dist = (Destination - Pawn->Location).Size();
				if ( Dist < 120.f )
					bAdvancedTactics = false;	// close to destination, stop weaving
				else if (!bNoTact )
				{
					FLOAT Dir = -1.f;
					if ( bTacticalDir )
						Dir = 1.f;
					FVector OldDir = (Destination - Pawn->Location).SafeNormal();
					Destination = Destination + 1.2f * Dir * Dist * (OldDir ^ FVector(0,0,1));
				}
			}
		}
		if( Pawn->moveToward(Destination, MoveTarget) )
			GetStateFrame()->LatentAction = 0;
		Destination = MoveTarget->Location;
		if( MoveTarget->bIsPawn )
		{
			Pawn->DesiredSpeed = oldDesiredSpeed; //don't slow down when moving toward a pawn
			if (!Pawn->bCanSwim && MoveTarget->Region.Zone->bWaterZone)
				MoveTimer = -1.f; //give up
		}
	}
	unguardSlow;
}
IMPLEMENT_FUNCTION( AController, AI_PollMoveToward, execPollMoveToward);

/* execTurnToward()
turn toward Focus
*/
void AController::execFinishRotation( FFrame& Stack, RESULT_DECL )
{
	guardSlow(AController::execFinishRotation);

	P_FINISH;

	GetStateFrame()->LatentAction = AI_PollFinishRotation;
	unguardSlow;
}

void AController::execPollFinishRotation( FFrame& Stack, RESULT_DECL )
{
	guardSlow(AController::execPollFinishRotation);

	if( !Pawn )
	{
		GetStateFrame()->LatentAction = 0;
		return;
	}

	//only base success on Yaw 
	int success = (Abs(Pawn->DesiredRotation.Yaw - (Pawn->Rotation.Yaw & 65535)) < 2000);
	if (!success) //check if on opposite sides of zero
		success = (Abs(Pawn->DesiredRotation.Yaw - (Pawn->Rotation.Yaw & 65535)) > 63535);	
	if( success )
		GetStateFrame()->LatentAction = 0;  

	unguardSlow;
}
IMPLEMENT_FUNCTION( AController, AI_PollFinishRotation, execPollFinishRotation);

/* 
SeePawn()

returns true is Other was seen by this controller's pawn.  Chance of seeing other pawn decreases with increasing 
distance or angle in peripheral vision
*/
DWORD AController::SeePawn(APawn *Other)
{
	guard(AController::SeePawn);
	//FIXME - MOVE TO AICONTROLLER
	if ( !Other || !Pawn )
		return 0;

	//FIXME - when PVS, only do this test if in same PVS

	if (Other != Enemy)
		bLOSflag = !bLOSflag;
	else
	{
		FVector ViewPoint = Pawn->Location + FVector(0,0,Pawn->BaseEyeHeight);
		if ( GetLevel()->Model->FastLineCheck(Other->Location, ViewPoint) 
		|| GetLevel()->Model->FastLineCheck(Other->Location + FVector(0,0,Other->CollisionHeight * 0.9), ViewPoint) )
		{
			LastSeeingPos = Pawn->Location;
			LastSeenPos = Enemy->Location;
			return 1;
		}
		return 0;
	}

	FLOAT distSq = (Other->Location - Pawn->Location).SizeSquared();
	FLOAT maxdist = SightRadius * Min(1.f, (FLOAT)(Other->Visibility * 0.0078125f)); 

	// non-players have fixed max sight distance in same zone, while bots can see infinitely in same zone
	if ( (distSq > maxdist * maxdist) 
			&& (!bIsPlayer || (Pawn->Region.Zone != Other->Region.Zone) || (appRand() * distSq > maxdist * maxdist )) )
			return 0;

	// check field of view - reduce odds of seeing if more on periphery
	// no FOV check if extremely close
	if ( distSq > 10000.f )
	{
		FVector SightDir = (Other->Location - Pawn->Location).SafeNormal();
		FVector LookDir = Rotation.Vector();
		Stimulus = (SightDir | LookDir) - PeripheralVision;
		if ( Stimulus < 0 )
			return 0;

		// lower FOV vertically
		SightDir.Z *= 2.f;
		SightDir.Normalize();
		Stimulus = (SightDir | LookDir) - PeripheralVision;
		if ( Stimulus < 0 )
			return 0;

		// notice other pawns at very different heights more slowly
		FLOAT heightMod = Abs(Other->Location.Z - Pawn->Location.Z);
		if ( appRand() < heightMod * heightMod/distSq )
			return 0;
	}

	Stimulus = 1;
	if ( (distSq > 4000000.f) && !bIsPlayer && (appFrand() < 0.5) )
			return 0;
	
	return LineOfSightTo(Other, 1);

	unguard;
}

/* 
LineOfSightTo()
returns true if controller's pawn can see Other actor.
Checks line to center of other actor, and possibly to head or box edges depending on distance
*/
DWORD AController::LineOfSightTo(AActor *Other, INT bUseLOSFlag)
{
	guard(AController::LineOfSightTo);
	if ( !Other )
		return 0;

	//FIXME - when PVS, only do this test if in same PVS

	AActor* ViewTarg = NULL;
	
	if ( IsA(APlayerController::StaticClass()) )
		ViewTarg = ((APlayerController *)this)->ViewTarget;
	if ( !ViewTarg && Pawn )
		ViewTarg = Pawn;
	else
		ViewTarg = this;

	FVector ViewPoint = ViewTarg->Location;
	if ( ViewTarg == Pawn )
		ViewPoint.Z += Pawn->BaseEyeHeight; //look from eyes

	if (Other == Enemy)
	{
		if ( GetLevel()->Model->FastLineCheck(Other->Location, ViewPoint) 
		|| ((ViewTarg == Pawn) && GetLevel()->Model->FastLineCheck(Other->Location, ViewTarg->Location)) )
		{
			LastSeeingPos = ViewTarg->Location;
			LastSeenPos = Enemy->Location;
			return 1;
		}
		return 0;
	}

	if ( GetLevel()->Model->FastLineCheck(Other->Location, ViewPoint) )
		return 1;

	FLOAT distSq = (Other->Location - ViewTarg->Location).SizeSquared();
	if ( distSq > 64000000.f )
		return 0;
	if ( (!bIsPlayer || !Other->bIsPawn) && (distSq > 4000000.f) ) 
		return 0;
	
	//try viewpoint to head
	if ( (!bUseLOSFlag || !bLOSflag) 
		&& GetLevel()->Model->FastLineCheck(Other->Location + FVector(0,0,Other->CollisionHeight * 0.8), ViewPoint) )
		return 1;

	// bLOSFlag used by SeePawn to reduce visibility checks
	if ( bUseLOSFlag && !bLOSflag )
		return 0;

	// only check sides if width of other is significant compared to distance
	if ( Other->CollisionRadius * Other->CollisionRadius/distSq < 0.0001f )
		return 0;

	//try checking sides - look at dist to four side points, and cull furthest and closest
	FVector Points[4];
	Points[0] = Other->Location - FVector(Other->CollisionRadius, -1 * Other->CollisionRadius, 0);
	Points[1] = Other->Location + FVector(Other->CollisionRadius, Other->CollisionRadius, 0);
	Points[2] = Other->Location - FVector(Other->CollisionRadius, Other->CollisionRadius, 0);
	Points[3] = Other->Location + FVector(Other->CollisionRadius, -1 * Other->CollisionRadius, 0);
	int imin = 0;
	int imax = 0;
	FLOAT currentmin = Points[0].SizeSquared(); 
	FLOAT currentmax = currentmin; 
	for ( INT i=1; i<4; i++ )
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

	for ( i=0; i<3; i++ )
		if	( (i != imin) && (i != imax)
			&& GetLevel()->Model->FastLineCheck(Points[i], ViewPoint) )
			return 1;

	return 0;
	unguard;
}

/* CanHear()

Returns 1 if controller can hear this noise
Several types of hearing are supported

Noises must be perceptible (based on distance, loudness, and the alerntess of the controller
Teammates may hear noises made by their team better (if TeammateHearingBoost > 1.f)

  Options for hearing are: (assuming the noise is perceptible

  bSameZoneHearing = Hear any perceptible noise made in the same zone 
  bAdjacentZoneHearing = Hear any perceptible noise made in the same or an adjacent zone
  bLOSHearing = Hear any perceptible noise which is not blocked by geometry
  bAroundCornerHearing = Hear any noise around one corner (bLOSHearing must also be true)

*/
INT AController::CanHear(FVector NoiseLoc, FLOAT Loudness, AActor *Other)
{
	guard(AController::CanHear);

	if ( !Other->Instigator || !Other->Instigator->Controller || !Pawn )
		return 0; //ignore sounds from uncontrolled (dead) pawns, or if don't have a pawn to control

	FLOAT DistSq = (Location - NoiseLoc).SizeSquared();
	FLOAT Perceived = Loudness * Pawn->HearingThreshold * Pawn->HearingThreshold;

	if ( PlayerReplicationInfo && Other->Instigator->PlayerReplicationInfo
		&& (PlayerReplicationInfo->Team == Other->Instigator->PlayerReplicationInfo->Team) )
		Perceived *= Pawn->TeammateHearingBoost;

	// take controller alertness into account (it ranges from -1 to 1 normally)
	Perceived *= ::Max(0.f,(Alertness + 1.f));

	// check if sound is too quiet to hear
	if ( Perceived < DistSq )
		return 0;

	// check if in same zone 
	if ( (Pawn->bSameZoneHearing || Pawn->bAdjacentZoneHearing) && (Region.Zone == Other->Region.Zone) )
		return 1;

	// check if in adjacent zone 
	if ( Pawn->bAdjacentZoneHearing 
		&& (GetLevel()->Model->Zones[Region.ZoneNumber].Connectivity & (1<<Other->Region.ZoneNumber)) )
		return 1;

	if ( !Pawn->bLOSHearing )
		return 0;

	// check if Line of Sight
	FVector ViewLoc = Pawn->Location + FVector(0,0,Pawn->BaseEyeHeight);
	if ( GetLevel()->Model->FastLineCheck(NoiseLoc, ViewLoc) )
		return 1;

	if ( Pawn->bMuffledHearing )
	{
		// sound distance increased to double plus 4x the distance through walls
		if ( Perceived > 4 * DistSq )
		{
			// check dist inside of walls
			FCheckResult Hit(1.f);
			GetLevel()->SingleLineCheck(Hit, this, NoiseLoc, ViewLoc, TRACE_VisBlocking);
			FVector FirstHit = Hit.Location;
			GetLevel()->SingleLineCheck(Hit, this, ViewLoc, NoiseLoc, TRACE_VisBlocking);
			FLOAT WallDistSq = (FirstHit - Hit.Location).SizeSquared();

			if ( Perceived > 4 * DistSq + WallDistSq * WallDistSq )
				return 1;
		}
	}

	if ( !Pawn->bAroundCornerHearing )
		return 0;

	// check if around corner 
	// using navigation network
	Perceived *= 0.125f; // distance to corner must be < 0.7 * max distance
	FSortedPathList SoundPoints;

	// find potential waypoints for sound propagation
	for ( ANavigationPoint *Nav=Level->NavigationPointList; Nav; Nav=Nav->nextNavigationPoint )
		if ( Nav->bPropagatesSound )
		{
			FLOAT D1 = (Nav->Location - Location).SizeSquared();
			FLOAT D2 = (Nav->Location - Other->Location).SizeSquared();
			if ( (D1 < Perceived) && (D2 < Perceived) )
				SoundPoints.addPath(Nav, D1+D2);
		}

	if ( SoundPoints.numPoints == 0 )
		return 0;

	for ( INT i=0; i<SoundPoints.numPoints; i++ )
		if ( GetLevel()->Model->FastLineCheck(SoundPoints.Path[i]->Location, NoiseLoc) 
			&& GetLevel()->Model->FastLineCheck(SoundPoints.Path[i]->Location, ViewLoc) )
			return 1;
	return 0;
	unguard;
}

/* Send a HearNoise() message to all Controllers which could possibly hear this noise
*/
void AActor::CheckNoiseHearing(FLOAT Loudness)
{
	guard(AActor::CheckNoiseHearing);

	if ( !Instigator || !Instigator->Controller )
		return;

	FLOAT CurrentTime = GetLevel()->TimeSeconds;

	// allow only one noise per 0.2 seconds from a given instigator & area (within 50 units) unless much louder 
	// check the two sound slots
	if ( (Instigator->noise1time > CurrentTime - 0.2f)
		 && ((Instigator->noise1spot - Location).SizeSquared() < 2500.f) 
		 && (Instigator->noise1loudness >= 0.9f * Loudness) )
	{
		return;
	}

	if ( (Instigator->noise2time > CurrentTime - 0.2f)
		 && ((Instigator->noise2spot - Location).SizeSquared() < 2500.f) 
		 && (Instigator->noise2loudness >= 0.9f * Loudness) )
	{
		return;
	}

	// put this noise in a slot
	if ( Instigator->noise1time < CurrentTime - 0.18f )
	{
		Instigator->noise1time = CurrentTime;
		Instigator->noise1spot = Location;
		Instigator->noise1loudness = Loudness;
	}
	else if ( Instigator->noise2time < CurrentTime - 0.18f )
	{
		Instigator->noise2time = CurrentTime;
		Instigator->noise2spot = Location;
		Instigator->noise2loudness = Loudness;
	}
	else if ( ((Instigator->noise1spot - Location).SizeSquared() < 2500) 
			  && (Instigator->noise1loudness <= Loudness) ) 
	{
		Instigator->noise1time = CurrentTime;
		Instigator->noise1spot = Location;
		Instigator->noise1loudness = Loudness;
	}
	else if ( Instigator->noise2loudness <= Loudness ) 
	{
		Instigator->noise1time = CurrentTime;
		Instigator->noise1spot = Location;
		Instigator->noise1loudness = Loudness;
	}

	// if the noise is not made by a player or an AI with a player as an enemy, then only send it to
	// other AIs with the same tag
	if ( !Instigator->IsPlayer() 
		&& (!Instigator->Controller->Enemy || !Instigator->Controller->Enemy->IsPlayer()) )
	{
		for ( AController *next=Level->ControllerList; next!=NULL; next=next->nextController )
			if ( (next->Pawn != Instigator) && next->IsProbing(NAME_HearNoise)
				&& (next->Tag == Tag) 
				&& next->CanHear(Location, Loudness, this) )
				next->eventHearNoise(Loudness, this);
		return;
	}

	// all pawns can hear this noise
	for ( AController *P=Level->ControllerList; P!=NULL; P=P->nextController )
		if ( (P->Pawn != Instigator) && P->IsProbing(NAME_HearNoise)
			 && P->CanHear(Location, Loudness, this) )
			 P->eventHearNoise(Loudness, this);

	unguard;
}

void AController::CheckEnemyVisible()
{
	guard(AController::CheckEnemyVisible);

	clock(GetLevel()->SeePlayer);
	if ( Enemy )
	{
		check(Enemy->IsValid());
		if ( !LineOfSightTo(Enemy) )
			eventEnemyNotVisible();
		else
			LastSeenTime = GetLevel()->TimeSeconds;
	}
	unclock(GetLevel()->SeePlayer);

	unguard;
}

/* Player shows self to pawns that are ready
*/
void AController::ShowSelf()
{
	guard(AController::ShowSelf);

	clock(GetLevel()->SeePlayer);
	if ( !Pawn )
		return;
	for ( AController *C=Level->ControllerList; C!=NULL; C=C->nextController )
		if( C!=this  && (bIsPlayer || C->bIsPlayer) && C->SightCounter<0.f )
		{
			//check visibility
			if ( C->IsProbing(NAME_SeePlayer) && C->SeePawn(Pawn) )
			{
				if ( bIsPlayer )
					C->eventSeePlayer(Pawn);
				else
					C->eventSeeMonster(Pawn);
			}
		}

	unclock(GetLevel()->SeePlayer);
	unguard;
}

/* 
SetPath()
Based on the results of the navigation network (which are stored in RouteCache[],
return the desired path.  Check if there are any intermediate goals (such as hitting a 
switch) which must be completed before continuing toward the main goal
*/
AActor* AController::SetPath(INT bInitialPath)
{
	guard(AController::SetPath);

	AActor * bestPath = RouteCache[0];

	if ( !Pawn->ValidAnchor() )
		return bestPath;	// make sure on network before trying to find complex routes

	if ( bInitialPath )
	{
		// if this is setting the path toward the main (final) goal
		// make sure still same goal as before
		if ( RouteGoal == GoalList[0] )
		{
			// check for existing intermediate goals
			if ( GoalList[1] )
			{
				INT i = 1;
				while ( GoalList[i] )
					i++;
				AActor* RealGoal = GoalList[i-1];
				if ( Pawn->actorReachable(RealGoal) )
				{
					// I can reach the intermediate goal, so 
					GoalList[i-1] = NULL;
					return RealGoal;
				}
				// find path to new goal
				if ( Pawn->findPathToward(RealGoal,RealGoal->Location,NULL, 1) > 0.f )
				{
					bestPath = SetPath(0);
				}
			}
		}
		else
		{
			GoalList[0] = RouteGoal;
			for ( INT i=1; i<4; i++ )
				GoalList[i] = NULL;
		}
	}
	else
	{
		// add new goal to goal list
		for ( INT i=0; i<4; i++ )
		{
			if ( GoalList[i] == RouteGoal )
				break;
			if ( !GoalList[i] )
			{
				GoalList[i] = RouteGoal;
				break;
			}
		}
	}
	if ( bestPath && bestPath->IsProbing(NAME_SpecialHandling) )
		bestPath = HandleSpecial(bestPath);
	return bestPath;
	unguard;
}

AActor* AController::HandleSpecial(AActor *bestPath)
{
	guard(AController::HandleSpecial);

	if ( !bCanDoSpecial || GoalList[3] )
		return bestPath;	//limit AI intermediate goal depth to 4

	AActor * newGoal = bestPath->eventSpecialHandling(Pawn);

	if ( newGoal && (newGoal != bestPath) )
	{
		// if can reach intermediate goal directly, return it
		if ( Pawn->actorReachable(newGoal) )
			return newGoal;

		// find path to new goal
		if ( Pawn->findPathToward(newGoal,newGoal->Location,NULL, 1) > 0.f )
		{
			bestPath = SetPath(0);
		}
	}
	return bestPath;

	unguard;
}

/* AcceptNearbyPath() returns true if the controller will accept a path which gets close to
and withing sight of the destination if no reachable path can be found.
*/
INT AController::AcceptNearbyPath(AActor *goal)
{
	return 0;
}

INT AAIController::AcceptNearbyPath(AActor *goal)
{
	return (bHunting && goal && goal->bIsPawn);
}

/* AdjustFromWall()
Gives controller a chance to adjust around an obstacle and keep moving
*/

void AController::AdjustFromWall(FVector HitNormal, AActor* HitActor)
{
}

void AAIController::AdjustFromWall(FVector HitNormal, AActor* HitActor)
{
	guard(AAIController::AdjustFromWall);

	if ( bAdjustFromWalls 
		&& ((GetStateFrame()->LatentAction == AI_PollMoveTo)
			|| (GetStateFrame()->LatentAction == AI_PollMoveToward)) )
	{
		AMover *HitMover = Cast<AMover>(HitActor);
		if ( HitMover && Pawn && (Pawn->PendingMover == HitMover) )
		{
			eventNotifyHitMover(HitNormal,HitMover);
			return;
		}
		if ( bAdjusting )
		{
			MoveTimer = -1.f;
		}
		else
		{
			bTacticalDir = !bTacticalDir;
			bAdjusting = true;
			if ( !Pawn->PickWallAdjust() )
				MoveTimer = -1.f;
			else if ( !Pawn->IsAnimating() )
				eventAnimEnd();
			if ( Pawn->Physics == PHYS_Falling )
				Pawn->eventFalling();
		}
	}
	unguard;
}

#endif