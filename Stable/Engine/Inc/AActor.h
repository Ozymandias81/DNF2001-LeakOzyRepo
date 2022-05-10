/*=============================================================================
	AActor.h.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.
=============================================================================*/

	// Constructors.
	AActor() {}
	void Destroy();

	// UObject interface.
	virtual INT* GetOptimizedRepList( BYTE* InDefault, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map );
	virtual UBOOL ShouldDoScriptReplication() {return 1;}
	void ProcessEvent( UFunction* Function, void* Parms, void* Result=NULL );
	void ProcessState( FLOAT DeltaSeconds );
	UBOOL ProcessRemoteFunction( UFunction* Function, void* Parms, FFrame* Stack );
	UBOOL AActor::LineCheckTranslucency( FVector TraceEnd, FVector TraceStart );
	void ProcessDemoRecFunction( UFunction* Function, void* Parms, FFrame* Stack );
	//void Serialize( FArchive& Ar );
	void InitExecution();
	void PostEditChange();
	void PostLoad();

	// AActor interface.
	//class ULevel* GetLevel() const;
	class ULevel* GetLevel() const { return XLevel; } //const;
	class APlayerPawn* GetPlayerPawn() const;
	UBOOL IsPlayer() const;
	UBOOL IsOwnedBy( const AActor *TestOwner ) const;
	FLOAT WorldSoundRadius() const {return 25.f * ((int)SoundRadius+1);}
	FLOAT WorldVolumetricRadius() const {return 25.f * ((int)VolumeRadius+1);}
	UBOOL IsBlockedBy( const AActor* Other ) const;
	UBOOL IsInZone( const AZoneInfo* Other ) const;
	UBOOL IsBasedOn( const AActor *Other ) const;
	virtual FLOAT GetNetPriority( AActor* Sent, FLOAT Time, FLOAT Lag );
	virtual FLOAT WorldLightRadius() const {return 25.f * ((int)LightRadius+1);}
	virtual UBOOL __fastcall Tick( FLOAT DeltaTime, enum ELevelTick TickType );
	virtual void __fastcall UpdateTimers( FLOAT DeltaTime );
	virtual void PostEditMove() {}
	virtual void PreRaytrace() {}
	virtual void PostRaytrace() {}
	virtual void Spawned() {}
	virtual void PreNetReceive();
	virtual void PostNetReceive();
	virtual UTexture* GetSkin( INT Index );
	virtual FCoords ToLocal() const
	{
		return GMath.UnitCoords / Rotation / Location;
	}
	virtual FCoords ToWorld() const
	{
		return GMath.UnitCoords * Location * Rotation;
	}
	FLOAT LifeFraction()
	{
		return Clamp( 1.f - LifeSpan / GetClass()->GetDefaultActor()->LifeSpan, 0.f, 1.f );
	}
	FVector GetCylinderExtent() const {return FVector(CollisionRadius,CollisionRadius,CollisionHeight);}
	AActor* GetTopOwner();
	UBOOL IsPendingKill() {return bDeleteMe;}

	// AActor collision functions.
	virtual UPrimitive* GetPrimitive() const;
	UBOOL IsOverlapping( const AActor *Other ) const;

	// AActor general functions.
	void __fastcall BeginTouch(AActor *Other);
	void __fastcall EndTouch(AActor *Other, UBOOL NoNotifySelf);
	void __fastcall SetOwner( AActor *Owner );
	UBOOL IsBrush()       const;
	UBOOL IsStaticBrush() const;
	UBOOL IsMovingBrush() const;
	UBOOL __fastcall IsAnimating(INT Channel);
    virtual void UpdateNetAnimationChannels(UMeshInstance *minst);
	UMeshInstance* GetMeshInstance()
	{
		if (!Mesh)
			return(NULL);
		return(Mesh->GetInstance(this));
	}
	void SetCollision( UBOOL NewCollideActors, UBOOL NewBlockActors, UBOOL NewBlockPlayers);
	void SetCollisionSize( FLOAT NewRadius, FLOAT NewHeight );
	void __fastcall SetBase(AActor *NewBase, int bNotifyActor=1);
	FRotator GetViewRotation();

	// AActor audio.
	void MakeSound( USound *Sound, FLOAT Radius=0.f, FLOAT Volume=1.f, FLOAT Pitch=1.f );
	void CheckHearSound(APawn* Hearer, INT Id, USound* Sound, FVector Parameters, FLOAT RadiusSquared);

	// Physics functions.
	void setPhysics(BYTE NewPhysics, AActor *NewFloor = NULL);
	void FindBase();
	virtual void performPhysics(FLOAT DeltaSeconds);
	void physProjectile(FLOAT deltaTime, INT Iterations);
	void processHitWall(FVector HitNormal, AActor *HitActor);
	void processLanded(FVector HitNormal, AActor *HitActor, FLOAT remainingTime, INT Iterations);
	void physFalling(FLOAT deltaTime, INT Iterations);
	void physRolling(FLOAT deltaTime, INT Iterations);
	void physicsRotation(FLOAT deltaTime);
	int fixedTurn(int current, int desired, int deltaRate); 
	inline void TwoWallAdjust(FVector &DesiredDir, FVector &Delta, FVector &HitNormal, FVector &OldHitNormal, FLOAT HitTime)
	{
		if ((OldHitNormal | HitNormal) <= 0) //90 or less corner, so use cross product for dir
		{
			FVector NewDir = (HitNormal ^ OldHitNormal);
			NewDir = NewDir.SafeNormal();
			Delta = (Delta | NewDir) * (1.f - HitTime) * NewDir;
			if ((DesiredDir | Delta) < 0)
				Delta = -1 * Delta;
		}
		else //adjust to new wall
		{
			Delta = (Delta - HitNormal * (Delta | HitNormal)) * (1.f - HitTime); 
			if ((Delta | DesiredDir) <= 0)
				Delta = FVector(0,0,0);
		}
	}
	void physPathing(FLOAT DeltaTime);
	virtual void physMovingBrush(FLOAT DeltaTime);
	void physTrailer(FLOAT DeltaTime);
	int moveSmooth(FVector Delta);

	// AI functions.
	void CheckNoiseHearing(FLOAT Loudness);
	int TestCanSeeMe(APlayerPawn *Viewer);

	// NJS Playing with sounds:
	void PlayActorSound(USound *Sound, unsigned char Slot, FLOAT Volume, UBOOL bNoOverride,FLOAT Radius,FLOAT Pitch=1.0,UBOOL bMonitorSound=0);

	// NJS: A backwards compatibility function used to get an actor's core poly flags using the legacy STY_ and other settings.
	void __fastcall STY2PolyFlags( struct FSceneNode* Frame, DWORD &PolyFlags, DWORD &PolyFlagsEx);

	// Natives.
	DECLARE_FUNCTION(execPollSleep)
	DECLARE_FUNCTION(execPollFinishAnim)
	DECLARE_FUNCTION(execPollFinishInterpolation)

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
