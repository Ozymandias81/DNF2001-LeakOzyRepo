/*=============================================================================
	AController.h: AI or player.
	Copyright 2000 Epic Games, Inc. All Rights Reserved.
=============================================================================*/

#if 0
	INT* GetOptimizedRepList( BYTE* InDefault, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map, INT NumReps );
	//UBOOL Tick( FLOAT DeltaTime, enum ELevelTick TickType );

	// Seeing and hearing checks
	int CanHear(FVector NoiseLoc, FLOAT Loudness, AActor *Other); 
	virtual void CheckHearSound(AActor* SoundMaker, INT Id, USound* Sound, FVector Parameters, FLOAT RadiusSquared);
	void ShowSelf();
	DWORD SeePawn(APawn *Other);
	DWORD LineOfSightTo(AActor *Other, INT bUseLOSFlag=0);
	void CheckEnemyVisible();
	void StartAnimPoll();

	AActor* HandleSpecial(AActor *bestPath);
	INT AcceptNearbyPath(AActor* goal);
	virtual void AdjustFromWall(FVector HitNormal, AActor* HitActor);
	void SetRouteCache(ANavigationPoint *EndPath, FLOAT StartDist, FLOAT EndDist);
	AActor* FindPath(FVector point, AActor* goal, INT bClearPaths);
	AActor* AController::SetPath(INT bInitialPath=1);

	// Natives.
	DECLARE_FUNCTION(execPollWaitForLanding)
	DECLARE_FUNCTION(execPollMoveTo)
	DECLARE_FUNCTION(execPollMoveToward)
	DECLARE_FUNCTION(execPollFinishRotation)
#endif

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
