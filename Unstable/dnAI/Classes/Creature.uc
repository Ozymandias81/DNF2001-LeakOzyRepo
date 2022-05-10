//=============================================================================
// Creature.uc
//=============================================================================
class Creature expands AIPawn
	abstract;

var( Pathing ) float	PathingCollisionHeight;		// Altered collision height to find paths.
var( Pathing ) float	PathingCollisionRadius;		// Altered collision raidus to find paths.
var( Pathing ) bool		bModifyCollisionToPath;		// If true, uses above modifications.

var( CreatureAI ) float	MeleeRange;

Enum ECreatureOrders
{
	ORDERS_None,
	ORDERS_Idling,
	ORDERS_Roaming
};

var() ECreatureOrders CreatureOrders;


function PlayRunning();

auto state StartUp
{
	function BeginState()
	{
//		SetMovementPhysics(); 
		SetPhysics(PHYS_Falling);
	}

Begin:
	WaitForLanding();
	PlayTopAnim( 'None' );
	PlayBottomAnim( 'None' );
	PlayToWaiting();
	WhatToDoNext('','');
}

function WhatToDoNext(name LikelyState, name LikelyLabel)
{
	switch( CreatureOrders )
	{
		Case ORDERS_Idling:
			GotoState( 'Idling' );
			break;
		Case ORDERS_Roaming:
			GotoState( 'Roaming' );
			break;
		Default:
			GotoState( 'Idling' );
			break;
	}
}

function float GetRunSpeed()
{
	return RunSpeed;
}

function Carcass SpawnCarcass( optional class<DamageType> DamageType, optional vector HitLocation, optional vector Momentum )
{
	local carcass carc;

	carc = Spawn(CarcassType);
	if ( carc == None )
		return None;
	carc.MeshDecalLink = MeshDecalLink;
	carc.Initfor(self);
	return carc;
}

/*-----------------------------------------------------------------------------
	NPC Controlled State.
-----------------------------------------------------------------------------*/
state ActivityControl
{
	function Bump( actor Other )
	{
		if( Other.IsA( 'dnDecoration' ) && MoveTimer > 0.0 )
		{
			Obstruction = Other;
			GotoState( 'ActivityControl', 'AdjustMovement' );
		}
		else 
			Super.Bump( Other );
	}
	
	function HitWall( vector HitNormal, actor HitWall )
	{
		if ( HitWall.IsA('DoorMover')  )
		{
			SpecialPause = 0.45;
			if ( SpecialPause > 0 )
			{
				StopMoving();
				NotifyMovementStateChange( MS_Waiting, MS_Walking );
			}
			PendingDoor = HitWall;
			GotoState('ActivityControl', 'SpecialNavig');
			return;
		}
		else
			Super.HitWall( HitNormal, HitWall );
	}
	
	function Initialize();

	function BeginState()
	{
//		log( "ActivityControl state entered by: "$self );
//		log( "MyAE: "$MyAE );
	}

	function Timer( optional int TimerNum )
	{
		local actor A;

		if( TimerNum == 1 )
		{
			foreach allactors( class'Actor', A, MyAE.SoundEvent )
			{	
				if( A.IsA( 'NPCActivityEvent' ) && ( NPCActivityEvent( A ).NPCTag == Tag || NPCActivityEvent( A ).Event == Tag ) )
					PendingTriggerActor = A;
				else
					A.Trigger( MyAE, self );
				//				log( "Going to exiting." );
				GotoState( 'ActivityControl', 'Exiting' );
				//A.Trigger( MyAE, self );
				break;
			}
		}
	} 

SpecialNavig:
	if( PendingDoor != None && PendingDoor.IsA( 'DoorMover' ) )
	{
		if ( SpecialPause > 0.0 )
		{
				StopMoving();
				TurnTo(PendingDoor.Location);
				PlayToWaiting();
			//}
			DoorMover( PendingDoor ).Trigger( self, self );			
			SpecialPause = 1;
		}
		else
		{
			Focus = Destination;
			if (PickWallAdjust())
				GotoState('ActivityControl', 'AdjustFromWall');
			else
				MoveTimer = -1.0;
		}
		Sleep(SpecialPause);
		
		DoorMover( PendingDoor ).bLocked = DoorMover( PendingDoor ).Default.bLocked;
		
		SpecialPause = 0.0;
		Goto( 'Moving' );
	}

AdjustMovement:
	if( Obstruction != None )
	{
		StopMoving();
		PlayAllAnim( 'A_Kick_Front',, 0.2, false );
		Obstruction.TakeDamage( 10000, self, Obstruction.Location, vect( 0, 0, 0 ), class'KungFuDamage' );
		FinishAnim( 0 );
		PlayToWaiting();
		TurnToward( AEDestination );
		Goto( 'Moving' );
	}

Begin:
//	PlayActivityAnim();
//	PlayToWaiting();
	Initialize();
//	log( "==================================" );
//	log( "ActivityControl State Begin Label" );
//	log( "MyAE: "$MyAE );

	if( MyAE.bStopMoving && MyAE.bUseStopMoving )
	{
		StopMoving();
	}

	if( MyAE.DefaultAllAnim != '' )
	{
		InitialIdlingAnim = MyAE.DefaultAllAnim;
	}

	if( MyAE.bWeaponDown )
	{
		log( MyAE$" putting weapon away." );
		//PlayTopAnim( 'T_Hypo_Arm',,, true );
		PlayTopAnim('T_WeaponChange1', 0.5, 0.2, false );
		FinishAnim( 1 );
		Weapon.ThirdPersonMesh = None;
//		Sleep( 5.0 );
	}
	else if( MyAE.bWeaponUp )
	{
		log( MyAE$" rearming weapon." );

		PlayTopAnim('T_WeaponChange2', 0.5, 0.2, false );
		FinishAnim( 1 );
		Weapon.ThirdPersonMesh = Weapon.Default.ThirdPersonMesh;
	}

	if( MyAE.FocusTag != '' || MyAE.bUseFocusTag )
	{
		log( MyAE$" setting focus to: "$MyAE.GetFocusActor() );
		HeadTrackingActor = MyAE.GetFocusActor();
		TurnToward(HeadTrackingActor);
	}
//	else 
//	{
//		log( MyAE$" resetting focus." );
//		HeadTrackingACtor = None;
//	}

	if( MyAE.AnimSeqAll != '' )
	{
		log( MyAE$" Playing All Animation: "$MyAE.AnimSeqAll );
		PlayAllAnim( MyAE.AnimSeqAll, MyAE.GetRate( 0 ), MyAE.GetTweenTime( 0 ), MyAE.bLoopAllAnim );
	}
	if( MyAE.AnimSeqTop != '' )
	{
		log( MyAE$" Playing Top Animation: "$MyAE.AnimSeqTop );
		PlayTopAnim( MyAE.AnimSeqTop, MyAE.GetRate( 1 ), MyAE.GetTweenTime( 1 ), MyAE.bLoopTopAnim );
	}
	if( MyAE.AnimSeqBottom != '' )
	{
		log( MyAE$" Playing All Animation: "$MyAE.AnimSeqBottom );
		PlayBottomAnim( MyAE.AnimSeqBottom, MyAE.GetRate( 2 ), MyAE.GetTweenTime( 2 ), MyAE.bLoopBottomAnim );
	}

	if( MyAE.SoundToPlay != None )
	{

		if( MyAE.PauseBeforeSound > 0.0 )
		{

			log( MyAE$" pausing "$MyAE.PauseBeforeSound$" before sound." );
			Sleep( MyAE.PauseBeforeSound );
		//	SetTimer( MyAE.PauseBeforeSound, false );
		}
//		else
//		{
//		Timer();
		//bLipSync = !MyAE.bNoLipSync;
		log( MyAE$" playing sound: "$MyAE.SoundToPlay );
		PlaySound( MyAE.SoundToPlay, SLOT_Talk, 200, false,,, true  );
		if( MyAE.SoundEvent != '' )
		{
			log( MyAE$" setting timer for event: "$MyAe.SoundEvent );
			Global.SetTimer( GetSoundDuration( MyAE.SoundToPlay ), false, 1 );

		}

//		}
	}
	if( MyAE.AnimSeqAll != '' )
	{
		if( !MyAE.bLoopAllAnim )
		{
			log( MyAE$" finishing AllAnim." );
			FinishAnim( 0 );
			if( MyAE.DefaultAllAnim != '' )
				PlayAllAnim( MyAE.DefaultAllAnim,, 0.5, true );
		}
		else if( MyAE.LoopTimeAll > 0.0 )
		{
			log( MyAE$" sleeping for AllAnim LoopTime: "$MyAE.LoopTimeAll );
			Sleep( MyAE.LoopTimeAll );
		}
//		PlayToWaiting();
		if( MyAE.EventAllAnim != '' )
		{
		//	Global.SetTimer( 0.25, false, 2 );
			log( MyAE$" triggering event for all animation." );
			MyAE.TriggerAllAnimEvents( self );	
		}
	}
	if( MyAE.AnimSeqTop != '' )
	{
		if( !MyAE.bLoopTopAnim )
		{	
			log( MyAE$" finishing top animation" );
			FinishAnim( 1 );
		}
		else if( MyAE.LoopTimeTop > 0.0 )
		{
			log( MyAE$" sleeping for TopAnim LoopTime: "$MyAE.LoopTimeTop );
			Sleep( MyAE.LoopTimeTop );
		}
		PlayTopAnim( 'None' );
		PlayToWaiting();
		if( MyAE.EventTopAnim != '' )
		{
			log( MyAE$" trigering event for top animation." );
			MyAE.TriggerEvent( MyAE.EventTopAnim, self );
		}
	}
	if( MyAE.AnimSeqBottom != '' )
	{
		if( !MyAE.bLoopBottomAnim )
		{
			log( MyAE$" finishing bottom animation" );
			FinishAnim( 2 );
		}
	}

	AEDestination = MyAE.GetActivityDestination();
	if( AEDestination != None )
	{
		log( MyAE$" found destination. Going to moving." );
		Goto( 'Moving' );
	}
	else if( MyAE.ItemClass != none )
	{
		MyGiveItem = Spawn( MyAE.ItemClass, self );
		if( MyGiveItem.IsA( 'Inventory' ) )
		{
			Inventory( MyGiveItem ).PickupNotifyPawn = self;
		}

		Inventory( MyGiveItem ).bDontPickupOnTouch = true;

		if( MyAE.bUseItemScale )
		{
			MyGiveItem.DrawScale = MyAE.ItemScale;
		}

		MyGiveItem.AttachActorToParent( self, false, false );
		if( MyAE.GiveItemTag != '' )
		{
			MyGiveItem.Tag = MyAE.GiveItemTag;
		}
		MyGiveItem.MountOrigin = MyAE.ItemMountOrigin;
		MyGiveItem.MountAngles = MyAE.ItemMountAngles;
		MyGiveItem.MountMeshItem = MyAE.MountPoint;
		//MyGiveItem.MountMeshItem = 'Hand_L';
		MyGiveItem.MountType = MOUNT_MeshBone;
		MyGiveItem.SetPhysics( PHYS_MovingBrush );
		GotoState( 'WaitingToGive' );
	}
	else
	{
		log( MyAE$" no new destination found. Going to Idling state." );
		if( MyAE.bUseHateTag )
		{
			TriggerHate();
		}
		else
			GotoState( 'Idling' );
	}

		
Moving:
	if( MyAE.bUsePhysics )
	{
		SetPhysics( MyAE.MovePhysics );
	}
	if( LineOfSightTo( AEDestination ) )
	{
		NotifyMovementStateChange( MS_Walking, MS_Waiting );
		if( !MyAE.bRunning )
		{
			NotifyMovementStateChange( MS_Walking, MS_Waiting );
			PlayToWalking();
			MoveToward( AEDestination, WalkingSpeed );
			StopMoving();
		//	AEDestination = None;
			PlayToWaiting();
		}
		else
		{
			NotifyMovementStateChange( MS_Running, MS_Waiting );
			PlayToRunning();
			MoveToward( AEDestination, GetRunSpeed() );
			StopMoving();
		//	AEDestination = None;
			PlayToWaiting();
		}
//		Global.SetTimer( 2.0, false, 2 );
		if( VSize( AEDestination.Location - Location ) < MyAE.DestinationOffset )
		{
			PlayToWaiting();
			AEDestination = None;
			MyAE.TriggerMovementEvent( self );
		}
		else
		{
			Goto( 'Moving' );
		}
//
//		log( "Moving 2" );
//		GotoState( NextState );
	}
	else if( !FindBestPathToward( AEDestination, true ) )
	{
		AEDestination = None;
		if( MyAE.bUseHateTag )
		{
			TriggerHate();
		}
		else
			GotoState( 'Idling' );
	}
	else
	{
		NotifyMovementStateChange( MS_Walking, MS_Waiting );
		if( !MyAE.bRunning )
		{
			PlayToWalking();
			MoveTo( Destination, WalkingSpeed );
		}
		else
		{
			PlayToRunning();
			MoveTo( Destination, GetRunSpeed() );
		}
		if( VSize( Location - AEDestination.Location ) < MyAE.DestinationOffset )
		{
			StopMoving();
			PlayToWaiting();
			AEDestination = None;
//			log( "Destination reached." );
			MyAE.TriggerMovementEvent( self );
			//Global.SetTimer( 2.0, false, 2 );
			//PlayToWaiting();
			if( MyAE.bUseHateTag )
			{
				TriggerHate();
			}
			else
				GotoState( NextState );
		}
		else
			Goto( 'Moving' );
	}


Exiting:
//	PlayStanding();
	if( PendingTriggerActor != None )
	{
//		log( "PendingTriggerActor: "$PendingTriggerActor );
		PendingTriggerActor.Trigger( MyAE, self );
	}
	if( MyAE.bUseHateTag )
	{
		TriggerHate();
	}

}


state Hunting
{
	function BeginState()
	{
		//log( self$" Pursuit state entered." );
	}

Begin:
	Disable( 'SeePlayer' );
	TurnToward( Enemy );
	if( LineOfSightTo( Enemy ) )
	{
		PlayRunning();
		if( VSize( Enemy.Location - Location ) > MeleeRange )
		{
			Destination = Enemy.Location + ( MeleeRange * 0.75 ) * normal( Location - Enemy.Location );
			if( Physics == PHYS_Flying )
			{
//				log( "Adjusting Z" );
				if( FRand() < 0.5 )
					Destination.Z += Rand( 128 );
				else
					Destination.Z -= Rand( 128 );
			}
			MoveTo(Destination, GetRunSpeed() );
		}
	}
	else
	if( !FindBestPathToward( Enemy, true ) )
	{
		GotoState( 'Roaming' );
	}
	else
	{
		PlayAllAnim( 'A_Run',1.2, 0.11, true );
		MoveTo( Destination, GetRunSpeed() );
	}

	if( VSize( Enemy.Location - Location ) < MeleeRange && LineOfSightTo( Enemy ) )
	{
		GotoState( 'MeleeCombat' );
	}
	else
		Goto( 'Begin' );
}

function bool FindBestPathToward(actor desired, bool bClearPaths)
{
	local Actor path;
	local bool success;
	
	if( bModifyCollisionToPath )
		SetCollisionSize( PathingCollisionRadius, PathingCollisionHeight );

	if ( specialGoal != None)
		desired = specialGoal;
	path = None;
	path = FindPathToward(desired,,bClearPaths); 
		
	success = (path != None);	
	if (success)
	{
		MoveTarget = path; 
		Destination = path.Location;
	}
	if( bModifyCollisionToPath )
		SetCollisionSize( Default.CollisionRadius, Default.CollisionHeight );
	return success;
}	

function PlayMeleeAttack();

function bool SetEnemy(Actor NewEnemy);

defaultproperties
{
     DrawType=DT_Mesh
}