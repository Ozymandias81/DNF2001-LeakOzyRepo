/*=============================================================================
	UnActor.cpp: AActor implementation
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by Tim Sweeney
=============================================================================*/

#include "EnginePrivate.h"

/*-----------------------------------------------------------------------------
	AActor object implementations.
-----------------------------------------------------------------------------*/

IMPLEMENT_CLASS(AActor);
IMPLEMENT_CLASS(AInfoActor);
IMPLEMENT_CLASS(ARenderActor);
IMPLEMENT_CLASS(AClipMarker);
IMPLEMENT_CLASS(APolyMarker);
IMPLEMENT_CLASS(ALight);
IMPLEMENT_CLASS(AWeapon);
IMPLEMENT_CLASS(ALevelInfo);
IMPLEMENT_CLASS(AGameInfo);
IMPLEMENT_CLASS(ACamera);
IMPLEMENT_CLASS(AZoneInfo);
IMPLEMENT_CLASS(ASkyZoneInfo);
IMPLEMENT_CLASS(APathNode);
IMPLEMENT_CLASS(ANavigationPoint);
IMPLEMENT_CLASS(AScout);
IMPLEMENT_CLASS(AInterpolationPoint);
IMPLEMENT_CLASS(ADecoration);
IMPLEMENT_CLASS(AProjectile);
IMPLEMENT_CLASS(AWarpZoneInfo);
IMPLEMENT_CLASS(ATeleporter);
IMPLEMENT_CLASS(APlayerStart);
IMPLEMENT_CLASS(AKeypoint);
IMPLEMENT_CLASS(AInventory);
IMPLEMENT_CLASS(AInventorySpot);
IMPLEMENT_CLASS(ATriggers);
IMPLEMENT_CLASS(ATrigger);
IMPLEMENT_CLASS(ATriggerMarker);
IMPLEMENT_CLASS(AButtonMarker);
IMPLEMENT_CLASS(AWarpZoneMarker);
IMPLEMENT_CLASS(AHUD);
IMPLEMENT_CLASS(ASavedMove);
IMPLEMENT_CLASS(ACarcass);
IMPLEMENT_CLASS(ALiftCenter);
IMPLEMENT_CLASS(ALiftExit);
IMPLEMENT_CLASS(AInfo);
IMPLEMENT_CLASS(AReplicationInfo);
IMPLEMENT_CLASS(APlayerReplicationInfo);
IMPLEMENT_CLASS(AInternetInfo);
IMPLEMENT_CLASS(AGameReplicationInfo);
IMPLEMENT_CLASS(ULevelSummary);
IMPLEMENT_CLASS(Alocationid);
IMPLEMENT_CLASS(ADecal);
IMPLEMENT_CLASS(ASpawnNotify);
IMPLEMENT_CLASS(AItem);
IMPLEMENT_CLASS(AMeshEffect);
IMPLEMENT_CLASS(AInterpolationStation);		  // NJS
IMPLEMENT_CLASS(AMeshDecal);
IMPLEMENT_CLASS(ATriggerLight);
IMPLEMENT_CLASS(AMutator);
IMPLEMENT_CLASS(ADamageType);
IMPLEMENT_CLASS(AFlareLight);
IMPLEMENT_CLASS(AFocalPoint);
IMPLEMENT_CLASS(AActorDamageEffect);
IMPLEMENT_CLASS(ADOTAffector);
IMPLEMENT_CLASS(AMapLocations);					// JEP

/*-----------------------------------------------------------------------------
	Replication.
-----------------------------------------------------------------------------*/

UBOOL NEQ(BYTE A,BYTE B,UPackageMap* Map) {return A!=B;}
UBOOL NEQ(INT A,INT B,UPackageMap* Map) {return A!=B;}
UBOOL NEQ(BITFIELD A,BITFIELD B,UPackageMap* Map) {return A!=B;}
UBOOL NEQ(FLOAT& A,FLOAT& B,UPackageMap* Map) {return *(INT*)&A!=*(INT*)&B;}
UBOOL NEQ(FVector& A,FVector& B,UPackageMap* Map) {return ((INT*)&A)[0]!=((INT*)&B)[0] || ((INT*)&A)[1]!=((INT*)&B)[1] || ((INT*)&A)[2]!=((INT*)&B)[2];}
UBOOL NEQ(FRotator& A,FRotator& B,UPackageMap* Map) {return A.Pitch!=B.Pitch || A.Yaw!=B.Yaw || A.Roll!=B.Roll;}
UBOOL NEQ(UObject* A,UObject* B,UPackageMap* Map) {return (Map->CanSerializeObject(A)?A:NULL)!=B;}
UBOOL NEQ(FName& A,FName B,UPackageMap* Map) {return *(INT*)&A!=*(INT*)&B;}
UBOOL NEQ(FColor& A,FColor& B,UPackageMap* Map) {return *(INT*)&A!=*(INT*)&B;}
UBOOL NEQ(FPlane& A,FPlane& B,UPackageMap* Map) {return
((INT*)&A)[0]!=((INT*)&B)[0] || ((INT*)&A)[1]!=((INT*)&B)[1] ||
((INT*)&A)[2]!=((INT*)&B)[2] || ((INT*)&A)[3]!=((INT*)&B)[3];}
UBOOL NEQ(FString A,FString B,UPackageMap* Map) {return A!=B;}

#define DOREP(c,v) \
	if( NEQ(v,((A##c*)Recent)->v,Map) ) \
	{ \
		static UProperty* sp##v = FindObjectChecked<UProperty>(A##c::StaticClass(),TEXT(#v)); \
		*Ptr++ = sp##v->RepIndex; \
	}
#define DOREPARRAY(c,v) \
	static UProperty* sp##v = FindObjectChecked<UProperty>(A##c::StaticClass(),TEXT(#v)); \
    {\
    for( INT i=0; i<ARRAY_COUNT(v); i++ ) \
		if( NEQ(v[i],((A##c*)Recent)->v[i],Map) ) \
			*Ptr++ = sp##v->RepIndex+i; \
    }

INT* AActor::GetOptimizedRepList( BYTE* Recent, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map )
{
	if( StaticClass()->ClassFlags & CLASS_NativeReplication )
	{
		if( Role==ROLE_Authority )
		{
			DOREP(Actor,Owner);
			DOREP(Actor,Role);
			DOREP(Actor,RemoteRole);
			DOREP(Actor,bCollideActors);
			DOREP(Actor,bCollideWorld);
			DOREP(Actor,LightType);
			DOREP(Actor,bHidden);
			DOREP(Actor,Texture);
			DOREP(Actor,DrawScale);
			DOREP(Actor,PrePivot);
			DOREP(Actor,DrawType);
			DOREP(Actor,AmbientGlow);
			DOREP(Actor,Fatness);
			DOREP(Actor,ScaleGlow);
			DOREP(Actor,bUnlit);
			DOREP(Actor,Style);

			// Mount stuff
			DOREP(Actor,MountParent);
			DOREP(Actor,MountMeshSurfaceTri);
			DOREP(Actor,MountType);
			DOREP(Actor,IndependentRotation);
			DOREP(Actor,MountParentTag);
			DOREP(Actor,MountMeshItem);
			DOREP(Actor,bMountRotationRelative);
            DOREP(Actor,MountOrigin);
            DOREP(Actor,MountAngles);

			if( bNetOwner )
			{
				DOREP(Actor,bNetOwner);
				DOREP(Actor,Inventory);
			}
			if( bReplicateInstigator && RemoteRole>=ROLE_SimulatedProxy )
			{
				DOREP(Actor,Instigator);
			}
			if  ( !bNetOwner || !bClientAnim )
			{
				DOREP(Actor,AmbientSound);
			}

			if( (AmbientSound!=NULL) && (!bNetOwner || !bClientAnim) )
			{
				DOREP(Actor,SoundRadius);
				DOREP(Actor,SoundVolume);
				DOREP(Actor,SoundPitch);
			}
			if( bCollideActors || bCollideWorld || bForceCollisionRep )
			{
				DOREP(Actor,bProjTarget);
				DOREP(Actor,bBlockActors);
				DOREP(Actor,bBlockPlayers);
				DOREP(Actor,CollisionRadius);
				DOREP(Actor,CollisionHeight);
			}
			if( !bCarriedItem && (bNetInitial || bDontSimulateMotion || bSimulatedPawn || RemoteRole<ROLE_SimulatedProxy) )
			{
				DOREP(Actor,Location);
			}
			if( !bCarriedItem && (DrawType==DT_Mesh || DrawType==DT_Brush) && (bNetInitial || bDontSimulateMotion || bSimulatedPawn || RemoteRole<ROLE_SimulatedProxy) )
			{
				DOREP(Actor,Rotation);
			}
			if( DrawType==DT_Mesh )
			{
				if ( !bDontReplicateMesh )
				{
					DOREP(Actor,Mesh);
					DOREP(Actor,bMeshEnviroMap);
				}
				if ( !bDontReplicateSkin )
					DOREP(Actor,Skin);
				if( ((RemoteRole<=ROLE_SimulatedProxy) && (!bNetOwner || !bClientAnim)) || bDemoRecording )
				{
					DOREP(Actor,AnimSequence);
					DOREP(Actor,SimAnim);
					DOREP(Actor,AnimMinRate);
					DOREP(Actor,bAnimNotify);                                        
				}
			}
			else if( DrawType==DT_Sprite )
			{
				if( !bHidden )
				{
					DOREP(Actor,Sprite);
				}
			}
			if( DrawType==DT_Brush )
			{
				DOREP(Actor,Brush);
			}
			if( LightType!=LT_None )
			{
				DOREP(Actor,LightEffect);
				DOREP(Actor,LightBrightness);
				DOREP(Actor,LightHue);
				DOREP(Actor,LightSaturation);
				DOREP(Actor,LightRadius);
				DOREP(Actor,LightPeriod);
				DOREP(Actor,LightPhase);
				DOREP(Actor,VolumeBrightness);
				DOREP(Actor,VolumeRadius);
				DOREP(Actor,bSpecialLit);
			}
			if( RemoteRole==ROLE_SimulatedProxy )
			{
				DOREP(Actor,Base);
				if( bNetInitial )
				{
					if( !bSimulatedPawn )
					{
						DOREP(Actor,Physics);
						DOREP(Actor,Acceleration);
						DOREP(Actor,bBounce);
					}
					if( Physics==PHYS_Rotating )
					{
						DOREP(Actor,bFixedRotationDir);
						DOREP(Actor,bRotateToDesired);
						DOREP(Actor,RotationRate);
						DOREP(Actor,DesiredRotation);
					}
				}
			}
			else if ( bSimFall )
			{
				DOREP(Actor,Physics);
				DOREP(Actor,Acceleration);
				DOREP(Actor,bBounce);
			}

			if( bSimFall || bIsMover || (RemoteRole==ROLE_SimulatedProxy && (bNetInitial || bSimulatedPawn)) )
			{
				DOREP(Actor,Velocity);
			}
		}
	}
	return Ptr;
}
INT* ARenderActor::GetOptimizedRepList( BYTE* Recent, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map )
{
	Ptr = Super::GetOptimizedRepList(Recent,Retire,Ptr,Map);
	if( StaticClass()->ClassFlags & CLASS_NativeReplication )
	{
		if( Role==ROLE_Authority )
		{
			DOREP(RenderActor,bOnlyOwnerSee);
			DOREP(RenderActor,ItemName);
			DOREP(RenderActor,Health);
			DOREP(RenderActor,ShrinkActor);
			DOREP(RenderActor,ImmolationActor);
			if( DrawType==DT_Mesh )
			{
				if ( !bDontReplicateMesh )
				{
					DOREPARRAY(RenderActor,MultiSkins);
				}
				if( ((RemoteRole<=ROLE_SimulatedProxy) && (!bNetOwner || !bClientAnim)) || bDemoRecording )
				{
                    // Net animation stuff
                    DOREPARRAY(RenderActor,net_AnimSequence);
					DOREPARRAY(RenderActor,net_SimAnim);
					DOREPARRAY(RenderActor,net_AnimMinRate);
					DOREPARRAY(RenderActor,net_bAnimNotify);
                    DOREPARRAY(RenderActor,net_AnimBlend);
                    DOREPARRAY(RenderActor,net_bAnimBlendAdditive);
				}
			}
		}
	}
	return Ptr;
}
INT* APawn::GetOptimizedRepList( BYTE* Recent, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map )
{
	Ptr = Super::GetOptimizedRepList(Recent,Retire,Ptr,Map);
	if( StaticClass()->ClassFlags & CLASS_NativeReplication )
	{
		if( Role==ROLE_Authority )
		{
			DOREP(Pawn,Weapon);
			DOREP(Pawn,PlayerReplicationInfo);
			DOREP(Pawn,bCanFly);
			DOREP(Pawn,UsedItem);
			DOREP(Pawn,ShieldItem);
			DOREPARRAY(Pawn,BoneScales);
			DOREP(Pawn,ShrinkCounterDestination);
			DOREP(Pawn,bNotShrunkAtAll);
			DOREP(Pawn,bFullyShrunk);
			DOREP(Pawn,DOTAffectorList);
			DOREP(Pawn,ShieldProtection);
			if( bNetOwner )
			{
				 DOREP(Pawn,bIsPlayer);
				 DOREP(Pawn,CarriedDecoration);
				 DOREP(Pawn,SelectedItem);
				 DOREP(Pawn,GroundSpeed);
				 DOREP(Pawn,WaterSpeed);
				 DOREP(Pawn,AirSpeed);
				 DOREP(Pawn,AccelRate);
				 DOREP(Pawn,JumpZ);
				 DOREP(Pawn,AirControl);
				 DOREP(Pawn,bBehindView);
				 DOREP(Pawn,MoveTarget);
                 DOREP(Pawn,RemainingAir);
		  		 DOREP(Pawn,Energy);
				 DOREP(Pawn,Cash);

			}
            else
            {
	            DOREP(Pawn,bOnLadder);
                DOREP(Pawn,bOnRope);
                DOREP(Pawn,bOnTurret);
                DOREP(Pawn,PostureState);
                DOREP(Pawn,ViewRotationInt);
            }
		}
		if( (bNetOwner && bIsPlayer && bNetInitial) || bDemoRecording )
		{
			DOREP(Pawn,ViewRotation);
		}
		if( bDemoRecording )
		{
			DOREP(Pawn,EyeHeight);
		}
	}
	return Ptr;
}
INT* APlayerPawn::GetOptimizedRepList( BYTE* Recent, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map )
{
	Ptr = Super::GetOptimizedRepList(Recent,Retire,Ptr,Map);
	if( StaticClass()->ClassFlags & CLASS_NativeReplication )
	{
		if( Role==ROLE_Authority )
		{
			if( bNetOwner )
			{
				DOREP(PlayerPawn,ViewTarget);
				DOREP(PlayerPawn,ScoreboardType);
				DOREP(PlayerPawn,HUDType);
				DOREP(PlayerPawn,GameReplicationInfo);
				DOREP(PlayerPawn,bFixedCamera);
				DOREP(PlayerPawn,bNeverAutoSwitch);
				DOREP(PlayerPawn,bCheatsEnabled);
				DOREP(PlayerPawn,TargetViewRotation);
				DOREP(PlayerPawn,TargetEyeHeight);
				DOREP(PlayerPawn,TargetWeaponViewOffset);
				DOREPARRAY(PlayerPawn,RecentPickups);
				DOREP(PlayerPawn,RecentPickupsIndex);
				DOREP(PlayerPawn,bCanPlantBomb);
			}
            else
            {
                DOREP(PlayerPawn,currentRope);
                DOREP(PlayerPawn,boneRopeHandle);
                DOREP(PlayerPawn,ropeOffset);
				DOREP(PlayerPawn,bNoTracking);
            }
			if( bDemoRecording )
			{
				DOREP(PlayerPawn,DemoViewPitch);
				DOREP(PlayerPawn,DemoViewYaw);
			}
		}
		else
		{
			DOREP(PlayerPawn,Password);
			DOREP(PlayerPawn,bReadyToPlay);
			DOREP(PlayerPawn,VehicleRoll);
			DOREP(PlayerPawn,VehiclePitch);
		}
	}
	return Ptr;
}
INT* AMover::GetOptimizedRepList( BYTE* Recent, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map )
{
	Ptr = Super::GetOptimizedRepList(Recent,Retire,Ptr,Map);
	if( StaticClass()->ClassFlags & CLASS_NativeReplication )
	{
		if( Role==ROLE_Authority )
		{
			DOREP(Mover,SimOldPos);
			DOREP(Mover,SimOldRotPitch);
			DOREP(Mover,SimOldRotYaw);
			DOREP(Mover,SimOldRotRoll);
			DOREP(Mover,SimInterpolate);
			DOREP(Mover,RealPosition);
			DOREP(Mover,RealRotation);
		}
	}
	return Ptr;
}
INT* AZoneInfo::GetOptimizedRepList( BYTE* Recent, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map )
{
	Ptr = Super::GetOptimizedRepList(Recent,Retire,Ptr,Map);
	if( StaticClass()->ClassFlags & CLASS_NativeReplication )
	{
		if( Role==ROLE_Authority )
		{
			DOREP(ZoneInfo,ZoneGravity);
			DOREP(ZoneInfo,ZoneVelocity);
			DOREP(ZoneInfo,AmbientBrightness);
			DOREP(ZoneInfo,AmbientHue);
			DOREP(ZoneInfo,AmbientSaturation);
			DOREP(ZoneInfo,TexUPanSpeed);
			DOREP(ZoneInfo,TexVPanSpeed);
			DOREP(ZoneInfo,bReverbZone);
			DOREP(ZoneInfo,FogColor);
		}
	}
	return Ptr;
}
INT* APlayerReplicationInfo::GetOptimizedRepList( BYTE* Recent, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map )
{
	if ( bNetInitial )
		Ptr = Super::GetOptimizedRepList(Recent,Retire,Ptr,Map);
	if( StaticClass()->ClassFlags & CLASS_NativeReplication )
	{
		if( Role==ROLE_Authority )
		{
			DOREP(PlayerReplicationInfo,PlayerName);
			DOREP(PlayerReplicationInfo,OldName);
			DOREP(PlayerReplicationInfo,PlayerID);
			DOREP(PlayerReplicationInfo,TeamName);
			DOREP(PlayerReplicationInfo,Team);
			DOREP(PlayerReplicationInfo,TeamID);
			DOREP(PlayerReplicationInfo,Score);
			DOREP(PlayerReplicationInfo,Deaths);
			DOREP(PlayerReplicationInfo,Kills);
			DOREP(PlayerReplicationInfo,Credits);
			DOREP(PlayerReplicationInfo,VoiceType);
			DOREP(PlayerReplicationInfo,HasFlag);
			DOREP(PlayerReplicationInfo,Ping);
			DOREP(PlayerReplicationInfo,PacketLoss);
			DOREP(PlayerReplicationInfo,bIsFemale);
			DOREP(PlayerReplicationInfo,bIsABot);
			DOREP(PlayerReplicationInfo,bIsSpectator);
			DOREP(PlayerReplicationInfo,bWaitingPlayer);
			DOREP(PlayerReplicationInfo,bAdmin);
			DOREP(PlayerReplicationInfo,Icon);
			DOREP(PlayerReplicationInfo,PlayerZone);
			DOREP(PlayerReplicationInfo,PlayerLocation);
			DOREP(PlayerReplicationInfo,StartTime);
			DOREP(PlayerReplicationInfo,bHasBomb);
		}
	}
	return Ptr;
}
INT* AGameReplicationInfo::GetOptimizedRepList( BYTE* Recent, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map )
{
	Ptr = Super::GetOptimizedRepList(Recent,Retire,Ptr,Map);
	if( StaticClass()->ClassFlags & CLASS_NativeReplication )
	{
		if( Role==ROLE_Authority )
		{
			DOREP(GameReplicationInfo,GameName);
			DOREP(GameReplicationInfo,GameClass);
			DOREP(GameReplicationInfo,bTeamGame);
			DOREP(GameReplicationInfo,ServerName);
			DOREP(GameReplicationInfo,ShortName);
			DOREP(GameReplicationInfo,AdminName);
			DOREP(GameReplicationInfo,AdminEmail);
			DOREP(GameReplicationInfo,Region);
			DOREP(GameReplicationInfo,MOTDLine1);
			DOREP(GameReplicationInfo,MOTDLine2);
			DOREP(GameReplicationInfo,MOTDLine3);
			DOREP(GameReplicationInfo,MOTDLine4);
			DOREP(GameReplicationInfo,RemainingMinute);
			DOREP(GameReplicationInfo,NumPlayers);
			DOREP(GameReplicationInfo,NumSpectators);
			DOREP(GameReplicationInfo,bStopCountDown);
			DOREP(GameReplicationInfo,GameEndedComments);
			
			if ( bNetInitial )
			{
				DOREP(GameReplicationInfo,RemainingTime);
				DOREP(GameReplicationInfo,ElapsedTime);
				DOREP(GameReplicationInfo,bMeshAccurateHits);
				DOREP(GameReplicationInfo,bShowScores);
				DOREP(GameReplicationInfo,bPlayDeathSequence);
			}
		}
	}
	return Ptr;
}
INT* AInventory::GetOptimizedRepList( BYTE* Recent, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map )
{
	// Only inventory pickups should be like this.
	if ( bAlwaysRelevant && !bNetInitial )
	{
		DOREP(Actor,Owner);
		DOREP(Actor,bHidden);
		return Ptr;
	}
	Ptr = Super::GetOptimizedRepList(Recent,Retire,Ptr,Map);
	if( StaticClass()->ClassFlags & CLASS_NativeReplication )
	{
		if( Role==ROLE_Authority )
		{
			if( bNetOwner )
			{
				DOREP(Inventory,Charge);
				DOREP(Inventory,bActivatable);
				DOREP(Inventory,bActive);
				DOREP(Inventory,PlayerViewOffset);
				DOREP(Inventory,PlayerViewMesh);
				DOREP(Inventory,PlayerViewScale);
			}
			else if ( (RemoteRole == ROLE_SimulatedProxy) && AmbientSound )
				DOREP(Actor,Location);
			DOREP(Inventory,ThirdPersonMesh);
			DOREP(Inventory,ThirdPersonScale);
		}
	}
	return Ptr;
}
INT* ACarcass::GetOptimizedRepList( BYTE* Recent, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map )
{
	Ptr = Super::GetOptimizedRepList(Recent,Retire,Ptr,Map);
	if( StaticClass()->ClassFlags & CLASS_NativeReplication )
	{
		if( Role==ROLE_Authority )
		{
			DOREP(Actor,Location);
			DOREP(Carcass,ChunkDamageType);
			DOREP(Carcass,ChunkUpBlastLoc);
			DOREP(Carcass,bStopSuffering);
			DOREP(Carcass,DamageBone);
			DOREP(Carcass,bSearchable);
			DOREP(Carcass,AmmoClass);
		}
	}
	return Ptr;
}
UBOOL AInventory::ShouldDoScriptReplication()
{
	if ( Owner != NULL )
		return 1;
	else
		return bNetInitial;
}

/*-----------------------------------------------------------------------------
	AActor networking implementation.
-----------------------------------------------------------------------------*/

//
// Static variables for networking.
//
static FVector   SavedLocation;
static FRotator  SavedRotation;
static AActor*   SavedBase;
static DWORD     SavedCollision;
static FLOAT	 SavedRadius;
static FLOAT     SavedHeight;
static FPlane    SavedSimAnim;
static FPlane    net_SavedSimAnim[4];
static FVector	 SavedSimInterpolate;

//
// Skins.
//
UTexture* AActor::GetSkin( INT Index )
{
	return NULL;
}
UTexture* ARenderActor::GetSkin( INT Index )
{
	if( Index < ARRAY_COUNT(MultiSkins) )
		return MultiSkins[Index];
	return NULL;
}

//
// Net priority.
//
FLOAT AActor::GetNetPriority( AActor* Sent, FLOAT Time, FLOAT Lag )
{
	return NetPriority * Time;
}

//
// Always called immediately before properties are received from the remote.
//
void AActor::PreNetReceive()
{
	SavedLocation   = Location;
	SavedRotation   = Rotation;
	SavedBase       = Base;
	SavedCollision  = bCollideActors;
	SavedRadius		= CollisionRadius;
	SavedHeight     = CollisionHeight;
	SavedSimAnim    = SimAnim;

	if( IsA(AMover::StaticClass()) )
		SavedSimInterpolate = ((AMover*)this)->SimInterpolate;
	if( bCollideActors )
		GetLevel()->Hash->RemoveActor( this );
}

void ARenderActor::PreNetReceive()
{
	Super::PreNetReceive();

    if ( MeshInstance )
    {
        for ( INT i=0; i<4; i++ )
            net_SavedSimAnim[i] = net_SimAnim[i];
    }
}

UBOOL AActor::LineCheckTranslucency( FVector TraceEnd, FVector TraceStart )
{
		FCheckResult Hit(1.0);
		FVector TraceExtent(0,0,0);
		FVector OriginalTraceEnd=TraceEnd;

		if(TraceEnd==TraceStart) 
			return 0;

		GetLevel()->SingleLineCheck( Hit, this, TraceEnd, TraceStart, TRACE_VisBlocking, TraceExtent );

		FVector HitLocation = Hit.Location;
		FVector TraceDirection = ( TraceEnd - TraceStart );

		TraceDirection.Normalize();

		
		if( Hit.Actor != NULL && Hit.Actor->IsA( AMover::StaticClass() ) 
	    &&( ( AMover* )Hit.Actor )->bTranslucentMover )	
		{
			if( this->IsA( APawn::StaticClass() ) )
			{
				if( ( ( APawn* )this )->IsProbing(NAME_BlockedByMover) )
					( ( APawn* )this )->eventBlockedByMover();
			}
			FLOAT MoverThickness=((AMover*)Hit.Actor)->MoverThickness;
			if(MoverThickness<1.f) MoverThickness=1.f;

			// Return no hit if trace would result inside mover:
			if((TraceEnd-TraceStart).Size()<=MoverThickness)
				return 0;


			TraceStart=HitLocation + ( TraceDirection * MoverThickness );
			return GetLevel()->Model->FastLineCheck( TraceEnd, TraceStart );

			//return LineCheckTranslucency( TraceEnd, TraceStart ); 
		}
		else
		{
			return GetLevel()->Model->FastLineCheck( TraceEnd, TraceStart );
		}
		return 0;
}

//
// Always called immediately after properties are received from the remote.
//
void AActor::PostNetReceive()
{
	Exchange ( Location,        SavedLocation  );
	Exchange ( Rotation,        SavedRotation  );
	Exchange ( Base,            SavedBase      );
	ExchangeB( bCollideActors,  SavedCollision );
	Exchange ( CollisionRadius, SavedRadius    );
	Exchange ( CollisionHeight, SavedHeight    );
	if( bCollideActors )
		GetLevel()->Hash->AddActor( this );
	if( IsA(AMover::StaticClass()) )
	{
		AMover* Mover = Cast<AMover>( this );
		if( SavedSimInterpolate != Mover->SimInterpolate )
		{
			Mover->OldPos = Mover->SimOldPos;
			Mover->OldRot.Yaw = Mover->SimOldRotYaw;
			Mover->OldRot.Pitch = Mover->SimOldRotPitch;
			Mover->OldRot.Roll = Mover->SimOldRotRoll;
			Mover->PhysAlpha = Mover->SimInterpolate.X * 0.01;
			Mover->PhysRate = Mover->SimInterpolate.Y * 0.01;
			INT keynums = (INT) Mover->SimInterpolate.Z;
			Mover->KeyNum = keynums & 255;
			Mover->PrevKeyNum = keynums >> 8;
			Mover->setPhysics(PHYS_MovingBrush);
			Mover->bInterpolating   = true;
			/*FRotator ApproxRot = Mover->BaseRot + Mover->KeyRot[Mover->KeyNum];
			ApproxRot.Roll = ApproxRot.Roll & 65280;
			ApproxRot.Pitch = ApproxRot.Pitch & 65280;
			ApproxRot.Yaw = ApproxRot.Yaw & 65280;
			if ( ApproxRot == Mover->OldRot )
				Mover->OldRot = Mover->BaseRot + Mover->KeyRot[Mover->KeyNum];*/
		}
	}
    if( IsA(APawn::StaticClass()) )
    {
        APawn* Pawn = Cast<APawn>( this );
		// Don't use the ViewRotationInt for ourselves ( AutonomousProxy )
		if ( !Pawn->RotateToDesiredView && ( Pawn->Role != ROLE_AutonomousProxy ) )
		{
	        Pawn->ViewRotation.Pitch  = Pawn->ViewRotationInt/32768;
			Pawn->ViewRotation.Yaw    = 2 * (Pawn->ViewRotationInt - 32768 * Pawn->ViewRotation.Pitch);
			Pawn->ViewRotation.Pitch *= 2;
		}
    }
	if( IsA(APlayerPawn::StaticClass()) && GetLevel()->DemoRecDriver && GetLevel()->DemoRecDriver->ServerConnection )
	{
		APlayerPawn* PlayerPawn = Cast<APlayerPawn>( this );
		PlayerPawn->ViewRotation.Pitch = PlayerPawn->DemoViewPitch;
		PlayerPawn->ViewRotation.Yaw = PlayerPawn->DemoViewYaw;
	}
	if( SimAnim != SavedSimAnim ) // Base animation replication decoding
	{
		AnimFrame = SimAnim.X * 0.0001;
		AnimRate  = SimAnim.Y * 0.0002;
		TweenRate = SimAnim.Z * 0.001;
		AnimLast  = SimAnim.W * 0.0001;
		if( AnimLast < 0 )
		{
			AnimLast *= -1;
			bAnimLoop = 1;
			if( IsA(APawn::StaticClass()) && AnimMinRate<0.5 )
				AnimMinRate = 0.5;
		}
		else
        {
            bAnimLoop = 0;
        }
    }

    if( Location!=SavedLocation )
	{
		if( IsA(APawn::StaticClass()) && (Role == ROLE_SimulatedProxy) 
			&& !Velocity.IsNearlyZero() && ((Location - SavedLocation).SizeSquared() < 10000) )
		{
			// smooth out movement of other players to account for frame rate induced jitter
			// look at whether location is a reasonable approximation already (<100 error)
			// if so only partially correct
			
			FLOAT StartError = (Location - SavedLocation).SizeSquared();
			if ( StartError > 1600 )
			{
				// if error > 40 try moving smoothly closer
				moveSmooth(0.35 * (SavedLocation - Location));
				// if error not reduced enough, set to new loc
				if ( (Location - SavedLocation).SizeSquared() > 0.75 * StartError )
					GetLevel()->FarMoveActor( this, Location + 0.5 * (SavedLocation - Location), 0, 1 );
			}
			else
				GetLevel()->FarMoveActor( this, Location + 0.15 * (SavedLocation - Location), 0, 1 );
		}
		else
			GetLevel()->FarMoveActor( this, SavedLocation, 0, 1 );
	}
	if( Rotation!=SavedRotation )
	{
		FCheckResult Hit;
		GetLevel()->MoveActor( this, FVector(0,0,0), SavedRotation, Hit, 0, 0, 0, 1 );
	}
	if( CollisionRadius!=SavedRadius || CollisionHeight!=SavedHeight )
	{
		SetCollisionSize( SavedRadius, SavedHeight );
	}
	if( bCollideActors!=SavedCollision )
	{
		SetCollision( SavedCollision, bBlockActors, bBlockPlayers );
	}
	if( Base!=SavedBase )
	{
		// Base changed.
		eventBump( SavedBase );
		if( SavedBase )
			SavedBase->eventBump( this );
		SetBase( SavedBase );
	}
	bJustTeleported = 0;
	if (IsA(APlayerReplicationInfo::StaticClass()) && Level->NetMode == NM_Client)
	{
		APlayerReplicationInfo* PRI = Cast<APlayerReplicationInfo>( this );
		if( GetLevel()->NetDriver &&
			GetLevel()->Engine->Client->Viewports(0)->Actor &&
			GetLevel()->Engine->Client->Viewports(0)->Actor->PlayerReplicationInfo == this
		)
			PRI->Ping -= (INT) ((GetLevel()->NetDriver->ServerConnection->AverageFrameTime * 1000) / 2);
		if( PRI->Ping < 0 )
			PRI->Ping = 0;
	}
}

void ARenderActor::PostNetReceive()
{
	Super::PostNetReceive();

    // Build up the actor's animation channels from the received from the net animation arrays
    if ( MeshInstance && ( Role != ROLE_AutonomousProxy ) && ( Role != ROLE_Authority ) )
    {
        // We skip channel 0, so the net arrays represent animation channels 1-4
        for( INT i=1,j=0; j<4; i++,j++ )
        {
            FMeshChannel *Chan = &MeshInstance->MeshChannels[i];
            
            Chan->AnimSequence          = net_AnimSequence[j];
            Chan->SimAnim               = net_SimAnim[j];
            Chan->AnimMinRate           = net_AnimMinRate[j];
            Chan->bAnimNotify           = net_bAnimNotify[j];
            Chan->AnimBlend             = net_AnimBlend[j];
            Chan->bAnimBlendAdditive    = net_bAnimBlendAdditive[j];

            if ( net_SimAnim[j] != net_SavedSimAnim[j] )
            {
                Chan->AnimFrame    = net_SimAnim[j].X * 0.0001;
                Chan->AnimRate     = net_SimAnim[j].Y * 0.0002;
		        Chan->TweenRate    = net_SimAnim[j].Z * 0.001;
		        Chan->AnimLast     = net_SimAnim[j].W * 0.0001;
        
                if( Chan->AnimLast < 0 )
	            {
		            Chan->AnimLast  *= -1;
			        Chan->bAnimLoop  = 1;
			        
                    if( IsA(APawn::StaticClass()) && Chan->AnimMinRate<0.5)
				        Chan->AnimMinRate = 0.5;
		        }
		        else
                {
                    Chan->bAnimLoop = 0;
                }
            }
        }
    }
}

/*-----------------------------------------------------------------------------
	APlayerPawn implementation.
-----------------------------------------------------------------------------*/

//
// Set the player.
//
void APlayerPawn::SetPlayer( UPlayer* InPlayer )
{
	check(InPlayer!=NULL);

	// Detach old player.
	if( InPlayer->Actor )
	{
		InPlayer->Actor->Player = NULL;
		InPlayer->Actor = NULL;
	}

	// Set the viewport.
	Player = InPlayer;
	InPlayer->Actor = this;

	// Send possess message to script.
	eventPossess();

	// Debug message.
	//debugf( NAME_Log, TEXT("Possessed PlayerPawn: %s"), GetFullName() );
}

bool APlayerPawn::ClearScreen()
{
	return false;
}
bool APlayerPawn::RecomputeLighting()
{
	return false;
}
bool APlayerPawn::CanSee( const AActor* Actor )
{
	return false;
}
INT APlayerPawn::GetViewZone( INT iViewZone, const UModel* Model )
{
	return iViewZone;
}
bool APlayerPawn::IsZoneVisible( INT iZone )
{
	return true;
}
bool APlayerPawn::IsSurfVisible( const FBspNode* Node, INT iZone, const FBspSurf* Poly )
{
	return true;
}
bool APlayerPawn::IsActorVisible( const AActor* Actor )
{
	return true;
}

/*-----------------------------------------------------------------------------
	AZoneInfo.
-----------------------------------------------------------------------------*/

void AZoneInfo::PostEditChange()
{
	Super::PostEditChange();
	if( GIsEditor )
		GCache.Flush();
}

/*-----------------------------------------------------------------------------
	AActor.
-----------------------------------------------------------------------------*/

void AActor::Destroy()
{
	if( RenderInterface )
	{
		RenderInterface->RemoveFromRoot();
		RenderInterface->ConditionalDestroy();
		RenderInterface = NULL;
	}
	if (MeshInstance)
	{
		//MeshInstance->RemoveFromRoot();
		MeshInstance->ConditionalDestroy();
		delete MeshInstance;

		MeshInstance = NULL;
		
		extern INT mesh_InstanceCount;
		mesh_InstanceCount--;
	}

	// JEP ...
	if (LastMeshInstance)
	{
		LastMeshInstance->ConditionalDestroy();
		delete LastMeshInstance;
		LastMeshInstance = NULL;
		
		extern INT mesh_InstanceCount;
		mesh_InstanceCount--;
	}
	// ... JEP

	bDestroyed = true;
	UObject::Destroy();
}

void AActor::PostLoad()
{
	Super::PostLoad();
	if( GetClass()->ClassFlags & CLASS_Localized )
		LoadLocalized();
	if( Brush )
		Brush->SetFlags( RF_Transactional );
	if( Brush && Brush->Polys )
		Brush->Polys->SetFlags( RF_Transactional );
}

void AActor::ProcessEvent( UFunction* Function, void* Parms, void* Result )
{
	if( Level->bBegunPlay )
		Super::ProcessEvent( Function, Parms, Result );
}

void AActor::PostEditChange()
{
	Super::PostEditChange();
	if( GIsEditor )
		bLightChanged = 1;
}

//
// Set the actor's collision properties.
//
void AActor::SetCollision
(
	UBOOL NewCollideActors,
	UBOOL NewBlockActors,
	UBOOL NewBlockPlayers
)
{
	// Untouch this actor.
	if( bCollideActors && GetLevel()->Hash )
		GetLevel()->Hash->RemoveActor( this );

	// Set properties.
	bCollideActors = NewCollideActors;
	bBlockActors   = NewBlockActors;
	bBlockPlayers  = NewBlockPlayers;

	// Touch this actor.
	if( bCollideActors && GetLevel()->Hash )
		GetLevel()->Hash->AddActor( this );
}

//
// Set collision size.
//
void AActor::SetCollisionSize( FLOAT NewRadius, FLOAT NewHeight )
{

	// Untouch this actor.
	if( bCollideActors && GetLevel()->Hash )
		GetLevel()->Hash->RemoveActor( this );

	// Set properties.
	CollisionRadius = NewRadius;
	CollisionHeight = NewHeight;

	// Touch this actor.
	if( bCollideActors && GetLevel()->Hash )
		GetLevel()->Hash->AddActor( this );

}

//
// Return whether this actor overlaps another.
//
UBOOL AActor::IsOverlapping( const AActor* Other ) const
{
	//checkSlow(Other!=NULL);

	if( !IsBrush() && !Other->IsBrush() && Other!=Level )
	{
		// See if cylinder actors are overlapping.
	#if 1
		return
			Square(Location.X      - Other->Location.X)
		+	Square(Location.Y      - Other->Location.Y)
		<	Square(CollisionRadius + 2.0f + Other->CollisionRadius)			// JEP Added +2 to match math in MoveActor
		&&	Square(Location.Z      - Other->Location.Z)
		<	Square(CollisionHeight + 2.0f + Other->CollisionHeight);		// JEP Added +2 to match math in MoveActor
	#else
		return
			Square(Location.X      - Other->Location.X)
		+	Square(Location.Y      - Other->Location.Y)
		<	Square(CollisionRadius + Other->CollisionRadius)
		&&	Square(Location.Z      - Other->Location.Z)
		<	Square(CollisionHeight + Other->CollisionHeight);
	#endif
	}
	else
	{
		// We cannot detect whether these actors are overlapping so we say they aren't.
		return 0;
	}
}

/*-----------------------------------------------------------------------------
	Actor touch minions.
-----------------------------------------------------------------------------*/
static UBOOL __forceinline TouchTo( AActor* Actor, AActor* Other )
{
	// JP: If either actor is being destroyed, then don't touch each other
	//	It's probably also redundant to make other calls while an actor is being destroyed
	//	as well.  This one is especially critical since it make a reference to a
	//	"soon to be deleted" actor, which is bad...
	if (Actor->bDeleteMe || Other->bDeleteMe)	
		return 0;
	if (Actor->bDeleting || Other->bDeleting)	
		return 0;

	// Make sure we aren't already touching this actor.
	for ( INT j=0; j<Actor->Touching.Num(); j++ )
		if ( Actor->Touching(j) == Other )
			return 0;	// Potential performance increase

	// Make Actor touch TouchActor.
	Actor->Touching.AddItem(Other);
	Actor->eventTouch( Other );

	// See if first actor did something that caused an UnTouch.
	INT i = 0;
	return ( Actor->Touching.FindItem(Other,i) );
}

//
// Note that TouchActor has begun touching Actor.
//
// If an actor's touch list overflows, neither actor receives the
// touch messages, as if they are not touching.
//
// This routine is reflexive.
//
// Handles the case of the first-notified actor changing its touch status.
//
void __fastcall AActor::BeginTouch( AActor* Other )
{
	// Perform reflective touch.
	if( TouchTo( this, Other ) )
	{
		UBOOL	Ret = TouchTo( Other, this );

		if (!Ret)		// If first touched, and second failed, make sure both objects don't touch each other
		{
			EndTouch( Other, false );
			/*
			OLD CHECKS:
			BRANDON SAYS:
			JOHN, There is a case that this might fail.
			If the first TouchTo call deletes the Other actor, then the second TouchTo will return.
			Therefore, this check would fail.  Is it better to remove the actor?  Should script be called?
			I think the actor should be EndTouched.
			*/
			INT i = 0;
			check(!Touching.FindItem(Other, i));
			check(!Other->Touching.FindItem(this, i));
		}
	}
}

//
// Note that TouchActor is no longer touching Actor.
//
// If NoNotifyActor is specified, Actor is not notified but
// TouchActor is (this happens during actor destruction).
//
void __fastcall AActor::EndTouch( AActor* Other, UBOOL NoNotifySelf )
{
	INT i=0;
	if ( !NoNotifySelf && Touching.FindItem(Other,i) )
		eventUnTouch( Other );
	Touching.RemoveItem(Other);

	if ( Other->Touching.FindItem(this,i) )
	{
		Other->eventUnTouch( this );
		Other->Touching.RemoveItem(this);
	}
}

/*-----------------------------------------------------------------------------
	AActor member functions.
-----------------------------------------------------------------------------*/

//
// Destroy the actor.
//
#if 0
void AActor::Serialize( FArchive& Ar )
{
	Super::Serialize( Ar );
	/* NJS: If you want to have fun with properties:
	if(Ar.IsLoading())
	{
		if(AActor::GetClass()->ClassFlags&CLASS_Obsolete)
		{
			//DrawType=DT_Mesh;
			//Mesh=((AActor*)AActor::GetClass()->GetDefaultActor())->Mesh;
			//Mesh=(UMesh *)StaticLoadObject( UMesh::StaticClass(), NULL, TEXT("c_generic.BigError"), NULL, LOAD_NoWarn | (LOAD_Quiet), NULL );
			//((AActor*)AActor::GetClass()->GetDefaultActor())->Mesh=Mesh;

			DrawType=DT_Sprite;
			Texture=((AActor*)AActor::GetClass()->GetDefaultActor())->Texture;
			//Mesh=(UMesh *)StaticLoadObject( UMesh::StaticClass(), NULL, TEXT("c_generic.BigError"), NULL, LOAD_NoWarn | (LOAD_Quiet), NULL );
			bHidden=false;
			bHiddenEd=false;
			DrawScale=5.f;
 
			debugf(TEXT("*** Changing visual representation for obsolete item: %s %08x"),*Tag,Texture);
			//__asm int 3;

		}
			
	}
	*/
}
#endif

/*-----------------------------------------------------------------------------
	Relations.
-----------------------------------------------------------------------------*/

//
// Change the actor's owner.
//
void __fastcall AActor::SetOwner( AActor *NewOwner )
{
	// Sets this actor's parent to the specified actor.
	if( Owner != NULL )
		Owner->eventLostChild( this );

	Owner = NewOwner;

	if( Owner != NULL )
		Owner->eventGainedChild( this );
}

//
// Change the actor's base.
//
void __fastcall AActor::SetBase( AActor* NewBase, int bNotifyActor )
{
	//debugf("SetBase %s -> %s",GetName(),NewBase ? NewBase->GetName() : TEXT("NULL"));

	// Verify no recursion.
	for( AActor* Loop=NewBase; Loop!=NULL; Loop=Loop->Base )
		if ( Loop == this ) 
			return;

	if( NewBase != Base )
	{
		// Notify old base, unless it's the level.
		if( Base && Base!=Level )
		{
			Base->StandingCount--;
			Base->eventDetach( this );
		}

		// Set base.
		Base = NewBase;

		// Notify new base, unless it's the level.
		if( Base && Base!=Level )
		{
			Base->StandingCount++;
			Base->eventAttach( this );
		}

		// Notify this actor of his new floor.
		if ( bNotifyActor )
			eventBaseChange();
	}
}

/*-----------------------------------------------------------------------------
	Animation.
-----------------------------------------------------------------------------*/

// IsAnimating - Check if actor is animating on a given channel
// A channel of -1 means check all channels
UBOOL __fastcall AActor::IsAnimating(INT Channel)
{	
	UMeshInstance* MeshInst = NULL;
	if (Mesh)
		MeshInst = Mesh->GetInstance(this);
	if (!MeshInst || (Channel == 0))
	{
		if ((Channel == 0) || (Channel == -1))
			return((AnimSequence!=NAME_None) && (AnimFrame>=0 ? AnimRate!=0.0 : TweenRate!=0.0));
		return(0);
	}

	if (Channel != -1)
	{
		const FMeshChannel* Chan = &MeshInst->MeshChannels[Channel];
		return((Chan->AnimSequence!=NAME_None) && (Chan->AnimFrame>=0 ? Chan->AnimRate!=0.0 : Chan->TweenRate!=0.0));
	}
	for (INT i=0;i<16;i++)
	{
		const FMeshChannel* Chan = &MeshInst->MeshChannels[i];
		if ((Chan->AnimSequence!=NAME_None) && (Chan->AnimFrame>=0 ? Chan->AnimRate!=0.0 : Chan->TweenRate!=0.0))
			return(1);
	}
	return(0);
}

void AActor::UpdateNetAnimationChannels(UMeshInstance *minst)
{
}

void ARenderActor::UpdateNetAnimationChannels(UMeshInstance *minst)
{
    INT             i,j;
    if ( !minst )
        return;

    if ( GetLevel()->GetLevelInfo()->NetMode == NM_Standalone )
		return;

    if ( Role != ROLE_Authority )
        return;

    if ( !IsA( APawn::StaticClass() ) )
        return;

    // Update the net animation arrays from the server's version
    // Channel 0 is skipped, so we store anim channels 1-4 in the net arrays
    j=0;
    for ( i=1; i<=4; i++ )
    {
        net_bAnimFinished[j]         = minst->MeshChannels[i].bAnimFinished;
        net_bAnimLoop[j]             = minst->MeshChannels[i].bAnimLoop;
        net_bAnimNotify[j]           = minst->MeshChannels[i].bAnimNotify;
        net_bAnimBlendAdditive[j]    = minst->MeshChannels[i].bAnimBlendAdditive;
        net_AnimSequence[j]          = minst->MeshChannels[i].AnimSequence;
        net_AnimFrame[j]             = minst->MeshChannels[i].AnimFrame;
        net_AnimRate[j]              = minst->MeshChannels[i].AnimRate;
        net_AnimBlend[j]             = minst->MeshChannels[i].AnimBlend;
        net_TweenRate[j]             = minst->MeshChannels[i].TweenRate;
        net_AnimLast[j]              = minst->MeshChannels[i].AnimLast;
        net_AnimMinRate[j]           = minst->MeshChannels[i].AnimMinRate;
        net_OldAnimRate[j]           = minst->MeshChannels[i].OldAnimRate;
        net_SimAnim[j]               = minst->MeshChannels[i].SimAnim;
        j++;
    }
}

/*-----------------------------------------------------------------------------
 STY2PolyFlags is a backwards compatibility function to get an actor's poly 
 flags given it's STY_ and other legacy settings.
-----------------------------------------------------------------------------*/
void __fastcall AActor::STY2PolyFlags( FSceneNode *Frame, DWORD &PolyFlags, DWORD &PolyFlagsEx)
{
	// Initialize the polyflags:
	PolyFlags=PolyFlagsEx=0;

	// Translate the Style setting into PolyFlags and PolyFlagsEx:
	switch(Style)
	{
		case STY_None:												break;
		case STY_Masked:		  PolyFlags  |=PF_Masked;			break;
		case STY_Translucent:	  PolyFlags  |=PF_Translucent;		break;
		case STY_Modulated:       PolyFlags  |=PF_Modulated;		break;
		case STY_Translucent2:    PolyFlagsEx|=PFX_Translucent2;	break;
		case STY_LightenModulate: PolyFlagsEx|=PFX_LightenModulate;	break;
		case STY_DarkenModulate:  PolyFlagsEx|=PFX_DarkenModulate;  break;
		default:													break;	// No STY_xxx flag? eek!
	}

	
	// Translate a few misc booleans into additional polyflags:
	if( bNoSmooth     ) PolyFlags|=PF_NoSmooth;
	if( bSelected     ) PolyFlags|=PF_Selected;
	if( bMeshEnviroMap) PolyFlags|=PF_Environment;
	if(!bMeshCurvy    ) PolyFlags|=PF_Flat;

	// Check for additional unlit conditions:
	if( bUnlit 
	 || ( Region.ZoneNumber==0 )
	 || ( Frame && Frame->Viewport->Actor->RendMap!=REN_DynLight )
	 || ( Frame && Frame->Viewport->GetOuterUClient()->NoLighting ) ) 
		PolyFlags |= PF_Unlit;

	// Set up my Src and Dst blending, these override both styles and polyflags:
	check((SrcBlend>=BLEND_INVALID) && (SrcBlend<BLEND_MAX));
	check((DstBlend>=BLEND_INVALID) && (DstBlend<BLEND_MAX));

	// If the new blending style is true, strip off mutually exclusive old style poly flags:
	if((SrcBlend>BLEND_INVALID)&&(DstBlend>BLEND_INVALID))
	{
		PolyFlags&=~(PF_Masked|PF_Translucent|PF_Modulated);
		PolyFlagsEx&=~(PFX_Translucent2|PFX_LightenModulate|PFX_DarkenModulate);
	}

}

/*-----------------------------------------------------------------------------
	The end.
-----------------------------------------------------------------------------*/
