//=============================================================================
// EDFSapper.uc
//=============================================================================
class EDFSapper extends HumanNPC;

#exec OBJ LOAD FILE=..\Meshes\c_characters.dmx

var PipeBomb MyBomb;

enum eBombType
{
	BT_PipeBomb,
	BT_StickyBomb
};

enum EActionWhenBreached
{
	BA_NextTrap,
	BA_Fight
};

struct sMultiBombTrap
{
	var() bool					bNoThrowBomb		?("Go to the trap location first and place the bomb.");
	var() name					TrapPointTag		?("Tag of navigation point for bomb location.");
	var() name					DetFromPointTag		?("Tag of navigation point from which to detonate bomb.");
	var() bool					bSetOnSeeEnemy		?("I won't begin setting the trap until the enemy sees me.");
	var() eBombType				BombType			?("Type of multibomb to use for this trap.");
	var() NavigationPoint		DetFromPoint		?("Navigation point from which to detonate this pipebomb.");
	var() NavigationPoint		TrapPoint			?("Navigation point location for the bomb.");
	var() float					DetRadius			?("Radius from the bomb that the player must be in before detonation.");
	var() bool					bTargetMustSeeMe	?("Target must be able to see me before detonating my bomb.");
	var() bool					bTargetMustSeeBomb	?("Target must be able to see my bomb before I detonate it.");
	var() float					MinDetReactTime		?("Minimum time in seconds before I react and detonate my bomb.");
	var() float					MaxDetReactTime		?("Maximum time in seconds before I react and detonate my bomb.");
	var() name					DetTriggerEvent		?("Optional event to trigger when I detonate my bomb.");
	var() bool					bThrowWhenReached	?("I will only throw my pipebomb AFTER I reach my DetFromPoint.");
	var() EActionWhenBreached	ActionWhenBreached	?("What I need to do if player is too close and the trap is gone.");
	var() float					CrouchOdds			?("Odds that I'll crouch from my DetFromPoint location.");
};

//MultiBombTraps[ CurrentMultiBombTrap ].TrapPoint
//MultiBombTraps[ CurrentMultiBombTrap ].TrapPoint;
//MultiBombTraps[ CurrentMultiBombTrap ].DetFromPoint;
//MultiBombTraps[ CurrentMultiBombTrap ].DetFromPoint

var() sMultiBombTrap MultiBombTraps[ 16 ];
var float DetTime;
var float CurrentDetTime;

//var() NavigationPoint HideActors[ 4 ];
//var() NavigationPoint TrapActors[ 4 ];
//var() NavigationPoint DetActor[ 4 ];
var int CurrentMultiBombTrap;
var int CurrentDetActor;

function PostBeginPlay()
{
	SetupTraps();
	Super.PostBeginPlay();
}

function SetupTraps()
{
	local int i;
	local actor A;
	local NavigationPoint NP;

	for( i = 0; i <= 15; i++ )
	{
		if( MultiBombTraps[ i ].TrapPointTag != '' )
		{
			for( NP = Level.NavigationPointList; NP != None; NP = NP.NextNavigationPoint )
			{
				if( NP.Tag == MultiBombTraps[ i ].TrapPointTag )
				{
					MultiBombTraps[ i ].TrapPoint = NP;
					break;
				}
			}
		}
		if( MultiBombTraps[ i ].DetFromPointTag != '' )
		{
			for( NP = Level.NavigationPointList; NP != None; NP = NP.NextNavigationPoint )
			{
				if( NP.Tag == MultiBombTraps[ i ].DetFromPointTag )
				{
					MultiBombTraps[ i ].DetFromPoint = NP;
					break;
				}
			}
		}
		else
			break;
	}
	Super.PostBeginPlay();
}


function WhatToDoNext(name LikelyState, name LikelyLabel)
{
	if( MultiBombTraps[ 0 ].TrapPoint != None && !MultiBombTraps[ 0 ].bSetOnSeeEnemy )
	{
		Enemy = FindAPlayer();
		GotoState( 'Trapping' );
		return;
	}
	else
		Super.WhatToDoNext( LikelyState, LikelyLabel );
/*
	if( TrapActor != None )
	{
		Enemy = FindAPlayer();
		GotoState( 'Trapping' );
		return;
	}
	else
		Super.WhatToDoNext( LikelyState, LikelyLabel );
*/
}

function pawn FindAPlayer()
{
	local Pawn P;

	foreach allactors( class'Pawn', P )
	{
		if( PlayerPawn( P ) != None )
			return P;
	}
}

function bool CanDirectlyReach( actor ReachActor )
{
	local vector HitLocation,HitNormal;
	local actor HitActor;

	HitActor = Trace( HitLocation, HitNormal, ReachActor.Location + vect( 0, 0, -19 ), Location + vect( 0, 0, -19 ), true );
	
	if( HitActor == ReachActor && LineOfSightTo( ReachActor ) )
	{
		return true;
	}
	
	return false;
}

state Idling
{
	function SeePlayer( actor SeenPlayer )
	{
		if( SeenPlayer.IsA( 'PlayerPawn' ) && MultiBombTraps[ CurrentMultiBombTrap ].TrapPoint != None && MultiBombTraps[ CurrentMultiBombTrap ].bSetOnSeeEnemy )
		{
			Enemy = SeenPlayer;
			GotoState( 'Trapping' );
			return;
		}
		else
			Super.SeePlayer( SeenPlayer );
	}
}

state Trapping
{
	ignores SeePlayer;

	function BeginState()
	{
		//log( "--- Trapping state entered" );
	}

Begin:
	if( !MultiBombTraps[ CurrentMultiBombTrap ].bThrowWhenReached && CanSee( MultiBombTraps[ CurrentMultiBombTrap ].TrapPoint ) )
	{
		StopMoving();
		//log( "CurrentMultiBombTrap: "$CurrentMultiBombTrap );
		TurnToward( MultiBombTraps[ CurrentMultiBombTrap ].TrapPoint );
		PlayTopAnim( 'T_ThrowSmall',, 0.1, false );
		FirePipeBomb();
		FinishAnim( 1 );
		PlayToWaiting();
		Sleep( 0.25 );
		if( MultiBombTraps[ CurrentMultiBombTrap ].DetFromPoint != None )
			Goto( 'MoveToHidePoint' );
		else
			GotoState( 'WaitingToDetonate' );
	}
	if( MultiBombTraps[ CurrentMultiBombTrap ].bNoThrowBomb )
		Goto( 'Moving' );
	if( MultiBombTraps[ CurrentMultiBombTrap ].bThrowWhenReached )
		Goto( 'MoveToHidePoint' );

Moving:
	
	if( !CanDirectlyReach( MultiBombTraps[ CurrentMultiBombTrap ].TrapPoint ) )
	{
		if( !FindBestPathToward( MultiBombTraps[ CurrentMultiBombTrap ].TrapPoint, true ) )
		{
			PlayToWaiting();
			Sleep( 1.0 );
			GotoState( 'Attacking' );
		}
		else
		{
			PlayToRunning();
			MoveTo( Destination, GetRunSpeed() );
			if( VSize( Location - MultiBombTraps[ CurrentMultiBombTrap ].TrapPoint.Location ) < 96 && CanSee( MultiBombTraps[ CurrentMultiBombTrap ].TrapPoint ) )
			{
				Goto( 'TrapReached' );
			}
			else
				Goto( 'Moving' );
		}
	}
	else
	{
		PlayToRunning();
		Destination = Location - 64 * Normal( Location - MultiBombTraps[ CurrentMultiBombTrap ].TrapPoint.Location );
		MoveTo( Destination, GetRunSpeed() );
		if( VSize( Location - MultiBombTraps[ CurrentMultiBombTrap ].TrapPoint.Location ) < 128 && CanSee( MultiBombTraps[ CurrentMultiBombTrap ].TrapPoint ) )
			Goto( 'TrapReached' );
		else
			Goto( 'Moving' );
	}
TrapReached:
	PlayToWaiting();
	TurnToward( MultiBombTraps[ CurrentMultiBombTrap ].TrapPoint );
	//MyBomb = Spawn( class'PipeBomb',,, Location, Rotation );
	if( !MultiBombTraps[ CurrentMultiBombTrap ].bNoThrowBomb )
	{
		PlayTopAnim( 'T_ThrowSmall',, 0.1, false );
		FirePipeBomb();
		FinishAnim( 1 );
	}
	else
		MyBomb= Spawn( class'PipeBomb',,, Location, Rotation );

	PlayToWaiting();
MoveToHidePoint:
	//log( "MoveToHidePoint" );
	if( !CanDirectlyReach( MultiBombTraps[ CurrentMultiBombTrap ].DetFromPoint ) )
	{
		if( !FindBestPathToward( MultiBombTraps[ CurrentMultiBombTrap ].DetFromPoint, true ) )
		{
			GotoState( 'Waiting' );
		}
		else
		{
			PlayToRunning();
			MoveTo( Destination, GetRunSpeed() );
			if( VSize( Location - MultiBombTraps[ CurrentMultiBombTrap ].DetFromPoint.Location ) < 96 )
				Goto( 'HideActorReached' );
			else
				Goto( 'MoveToHidePoint' );
		}
	}
	else
	{
		PlayToRunning();
		Destination = Location - 64 * Normal( Location - MultiBombTraps[ CurrentMultiBombTrap ].DetFromPoint.Location );
		MoveTo( Destination, GetRunSpeed() );
		if( VSize( Location - MultiBombTraps[ CurrentMultiBombTrap ].DetFromPoint.Location ) < 128 && CanSee( MultiBombTraps[ CurrentMultiBombTrap ].DetFromPoint ) )
			Goto( 'HideActorReached' );
		else
			Goto( 'MoveToHidePoint' );
	}
HideActorReached:
	//log( "MultiBombTraps[ CurrentMultiBombTrap ].DetFromPointReached" );
	StopMoving();
	PlayToWaiting();
	if( MultiBombTraps[ CurrentMultiBombTrap ].bThrowWhenReached ) // && CanSee( MultiBombTraps[ CurrentMultiBombTrap ].TrapPoint ) )
	{
		TurnToward( MultiBombTraps[ CurrentMultiBombTrap ].TrapPoint );
		PlayTopAnim( 'T_ThrowSmall',, 0.1, false );
		FirePipeBomb();
		FinishAnim( 1 );
		PlayToWaiting();
	}
	//log( "PlayToWaiting" );
	TurnToward( MyBomb );
	if( MultiBombTraps[ CurrentMultiBombTrap ].CrouchOdds > 0.0 )
	{
		if( FRand() < MultiBombTraps[ CurrentMultiBombTrap ].CrouchOdds )
		{
			PlayAllAnim( 'A_CrchIdle',, 0.35, true );
//			FinishAnim( 2 );
		}
		else if( GetPostureState() == PS_Crouching )
		{
			PlaytoStanding();
			FinishAnim( 2 );
		}
	}
	else if( GetPostureState() == PS_Crouching )
	{
		PlayToStanding();
		FinishAnim( 2 );
	}
	if( GetSequence( 0 ) != 'A_CrchIdle' )
	{
		PlayAllAnim( 'A_IdleStandINactive',, 0.1, true );
	}
	else
		PlayAllAnim( 'A_CrchIdle',, 0.35, true );
	GotoState( 'WaitingToDetonate' );
}

state WaitingToDetonate
{
	ignores SeePlayer;

	function BeginState()
	{
		DetTime = RandRange( MultiBombTraps[ CurrentMultiBombTrap ].MinDetReactTime, MultiBombTraps[ CurrentMultiBombTrap ].MaxDetReactTime );
	}

	function Tick( float DeltaTime )
	{
		local bool bNoDet;

		if( MyBomb.Health <= 0 )
		{
			if( VSize( MultiBombTraps[ CurrentMultiBombTrap ].TrapPoint.Location - Enemy.Location ) < VSize( Enemy.Location - Location ) && FRand() < 0.22 )
			{
				GotoState( 'Trapping' );
			}
			else 
			{ 
				DoNextTrapAction();
			}
		}
		else if( VSize( MyBomb.Location - Enemy.Location ) < MultiBombTraps[ CurrentMultiBombTrap ].DetRadius ) //&& CanSee( Enemy ) )
		{
			if( MultiBombTraps[ CurrentMultiBombTrap ].bTargetMustSeeMe )
			{
				if( Enemy.IsA( 'DukePlayer' ) )
				{
					if( !PlayerCanSeeMe() )
					{
						bNoDet = true;
					}
				}
			}
			if( MultiBombTraps[ CurrentMultiBombTrap ].bTargetMustSeeBomb )
			{
				if( !Pawn( Enemy ).CanSee( MyBomb ) )
				{
					bNoDet = true;
				}
			}

			if( !bNoDet )
				CurrentDetTime += DeltaTime;

			if( CurrentDetTime >= DetTime )
			{
				if( !bNoDet )
				{
					MyBomb.Explode( MyBomb.Location+Vect(0,0,1)*16 );
					if( MultiBombTraps[ CurrentMultiBombTrap ].DetTriggerEvent != 'None' )
						TriggerDetonateEvent();
				}
				//GotoState( 'Trapping' );
				CurrentDetTime = 0;
				DoNextTrapAction();
			}
		}
		Super.Tick( DeltaTime );
	}
}

function TriggerDetonateEvent()
{
	local actor A;

	foreach allactors( class'Actor', A, MultiBombTraps[ CurrentMultiBombTrap ].DetTriggerEvent )
	{
		A.Trigger( self, self );
	}
}

function DoNextTrapAction()
{
	switch ( MultiBombTraps[ CurrentMultiBombTrap ].ActionWhenBreached )
	{
		Case BA_NextTrap:
			SetNextTrap();
			GotoState( 'Trapping' );
			break;	
		Default:
			SetNextTrap();
			GotoState( 'Trapping' );
			break;
	}			
}

function bool SetNextTrap()
{
	local int i;

	if( MultiBombTraps[ CurrentMultiBombTrap + 1 ].TrapPoint != None )
	{
		CurrentMultiBombTrap += 1;
		CurrentDetActor += 1;
		log( "Next Trap Set!" );
		return true;
	}
	else return false;
}


state Attacking
{
	function BeginState()
	{
		log( "New attacking state entered" );
		if( MultiBombTraps[ CurrentMultiBombTrap ].TrapPoint != None && MultiBombTraps[ CurrentMultiBombTrap ].DetFromPoint != None )
		{
			GotoState( 'Trapping' );
		}
	}

Begin:
	Sleep( FRand() );
	StopMoving();
	TurnToward( Enemy );
	if( CanSee( Enemy ) )
	{
		PlayTopAnim( 'T_ThrowSmall',, 0.1, false );
		FirePipeBomb();
		FinishAnim( 0 );
		PlayToWaiting();
		GotoState( 'Waiting' );
	}
	else
	{
		Sleep( 1.0 );
		Goto( 'Begin' );
	}

}

function rotator AdjustToss(float projSpeed, vector projStart, int aimerror, bool leadTarget, bool warnTarget)
{
	local rotator FireRotation;
	local vector FireSpot;
	local actor HitActor;
	local vector HitLocation, HitNormal, FireDir;
	local float TargetDist, TossSpeed, TossTime;
	local int realYaw;

	Skill = 3;
	if ( projSpeed == 0 )
		return AdjustAim(projSpeed, projStart, aimerror, leadTarget, warnTarget);
	log( "AdjustToss CurrentMultiBombTrap is "$CurrentMultiBombTrap );
	log( "Test: "$MultiBombTraps[ CurrentMultiBombTrap ].TrapPoint );
	if ( MultiBombTraps[ CurrentMultiBombTrap ].TrapPoint != None )
		Target = MultiBombTraps[ CurrentMultiBombTrap ].TrapPoint;
	if ( Target == None )
		return Rotation;
	log( "TARGET: "$Target );
	FireSpot = Target.Location;
	TargetDist = VSize(Target.Location - ProjStart);

	if ( !Target.bIsPawn )
	{
		if ( (Region.Zone.ZoneGravity.Z != Region.Zone.Default.ZoneGravity.Z) 
			|| (TargetDist > projSpeed) )
		{
			TossTime = TargetDist/projSpeed;
			FireSpot.Z -= ((0.25 * Region.Zone.ZoneGravity.Z * TossTime + 200) * TossTime + 60);	
		}
		viewRotation = Rotator(FireSpot - ProjStart);
		return viewRotation;
	}					
	aimerror = aimerror * (11 - 10 *  
		((Target.Location - Location)/TargetDist 
			Dot Normal((Target.Location + 1.2 * Target.Velocity) - (ProjStart + Velocity)))); 
	if ( bNovice )
	{
		if ( (Target != Enemy) || (Pawn( Enemy ).Weapon == None) || !Pawn( Enemy ).Weapon.bMeleeWeapon || (TargetDist > 650) )
			aimerror = aimerror * (2.1 - 0.2 * (skill + FRand()));
		else
			aimerror *= 0.75;
		if ( Level.TimeSeconds - LastPainTime < 0.15 )
			aimerror *= 1.3;
	}
	else
	{
		aimerror = aimerror * (1.5 - 0.35 * (skill + FRand()));
		if ( (Skill < 2) && (Level.TimeSeconds - LastPainTime < 0.15) )
			aimerror *= 1.2;
	}
	if ( (bNovice && (LastAcquireTime > Level.TimeSeconds - 5 + 0.6 * Skill))
		|| (LastAcquireTime > Level.TimeSeconds - 2.5 + Skill) )
	{
		LastAcquireTime = Level.TimeSeconds - 5;
		aimerror *= 1.75;
	}

	if ( !leadTarget || (accuracy < 0) )
		aimerror -= aimerror * accuracy;

	if ( leadTarget )
	{
		FireSpot += FMin(1, 0.7 + 0.6 * FRand()) * (Target.Velocity * TargetDist/projSpeed);
		if ( !FastTrace(FireSpot, ProjStart) )
			FireSpot = 0.5 * (FireSpot + Target.Location);
	}

	//try middle
	FireSpot.Z = Target.Location.Z;

	if ( (Target == Enemy) && !FastTrace(FireSpot, ProjStart) )
	{
		FireSpot = LastSeenPos;
	 	HitActor = Trace(HitLocation, HitNormal, FireSpot, ProjStart, false);
		if ( HitActor != None )
		{
			bFire = 0;
			bAltFire = 0;
			FireSpot += 2 * Target.CollisionHeight * HitNormal;
			SetTimer(TimeBetweenAttacks, false);
		}
	}

	// adjust for toss distance (assume 200 z velocity add & 60 init height)
	if ( FRand() < 0.75 )
	{
		TossSpeed = projSpeed + 0.4 * VSize(Velocity); 
		if ( (Region.Zone.ZoneGravity.Z != Region.Zone.Default.ZoneGravity.Z) 
			|| (TargetDist > TossSpeed) )
		{
			TossTime = TargetDist/TossSpeed;
			FireSpot.Z -= ((0.25 * Region.Zone.ZoneGravity.Z * TossTime + 200) * TossTime + 60);	
		}
	}

	FireRotation = Rotator(FireSpot - ProjStart);
	realYaw = FireRotation.Yaw;
	aimerror = Rand(2 * aimerror) - aimerror;

	FireRotation.Yaw = (FireRotation.Yaw + aimerror) & 65535;

	if ( (Abs(FireRotation.Yaw - (Rotation.Yaw & 65535)) > 8192)
		&& (Abs(FireRotation.Yaw - (Rotation.Yaw & 65535)) < 57343) )
	{
		if ( (FireRotation.Yaw > Rotation.Yaw + 32768) || 
			((FireRotation.Yaw < Rotation.Yaw) && (FireRotation.Yaw > Rotation.Yaw - 32768)) )
			FireRotation.Yaw = Rotation.Yaw - 8192;
		else
			FireRotation.Yaw = Rotation.Yaw + 8192;
	}
	FireDir = vector(FireRotation);
	// avoid shooting into wall
	HitActor = Trace(HitLocation, HitNormal, ProjStart + FMin(VSize(FireSpot-ProjStart), 400) * FireDir, ProjStart, false); 
	if ( (HitActor != None) && (HitNormal.Z < 0.7) )
	{
		FireRotation.Yaw = (realYaw - aimerror) & 65535;
		if ( (Abs(FireRotation.Yaw - (Rotation.Yaw & 65535)) > 8192)
			&& (Abs(FireRotation.Yaw - (Rotation.Yaw & 65535)) < 57343) )
		{
			if ( (FireRotation.Yaw > Rotation.Yaw + 32768) || 
				((FireRotation.Yaw < Rotation.Yaw) && (FireRotation.Yaw > Rotation.Yaw - 32768)) )
				FireRotation.Yaw = Rotation.Yaw - 8192;
			else
				FireRotation.Yaw = Rotation.Yaw + 8192;
		}
		FireDir = vector(FireRotation);
	}

	if ( warnTarget && (Pawn(Target) != None) ) 
		Pawn(Target).WarnTarget(self, projSpeed, FireDir); 

	viewRotation = FireRotation;			
	return FireRotation;
}

function FirePipebomb( optional actor DestActor )
{
	local vector X,Y,Z;
	local PipeBomb P;
	local vector Start;
	local rotator AdjustedAim;

	GetAxes( ViewRotation, X, Y, Z );
	Start = Location;// + Weapon.CalcDrawOffset();
	AdjustedAim = AdjustToss( 350, Start, 0.0, false, false );
	MyBomb = Spawn( class'PipeBomb', self,, Start + vector( Rotation ) * 32, AdjustedAim );
	MyBomb.Velocity = Vector(MyBomb.Rotation) * 350;     
	MyBomb.Velocity.z += 150; 
}

function NavigationPoint FindCoverSpot()
{
	local NavigationPoint P;

	for( P = Level.NavigationPointList; P != None; P = P.NextNavigationPoint )
	{
		if( EvaluateCoverPoint( P ) && CanSee( P ) && VSize( P.Location - Enemy.Location ) > 256 && VSize( P.Location - MyBomb.Location ) > 256 )
		{
			return P;
		}
	}
}

function bool EvaluateCoverPoint( NavigationPoint NP )
{
	local float CosAngle, MinCosAngle;
	local vector VectorFromNPCToNP, VectorFromNPCToEnemy;

	if( NP == None || Enemy == None )
		return false;
	VectorFromNPCToNP = NP.Location - Location;
	VectorFromNPCToEnemy = Enemy.Location - Location;
	CosAngle = Normal( Location ) dot Normal( VectorFromNPCToEnemy );
	MinCosAngle = 1.0;
	if( CosAngle < MinCosAngle )
		return true;
	return false;
}

function FearThisSpot( actor aspot, optional pawn instigator );


state Waiting
{
	ignores EnemyNotVisible, SeePlayer;

	function BeginState()
	{
		SetTimer( 1.0, true );
	}

	function Timer( optional int TimerNum )
	{
		local Pawn P;

		foreach MyBomb.radiusactors( class'Pawn', P, 200 )
		{
			if( P == Enemy && VSize( Location - MyBomb.Location ) > 256 )
			{
				MyBomb.Explode( MyBomb.Location+Vect(0,0,1)*16 );
				GotoState( 'Attacking' );
			}
		}
	}

Begin:
	PlayToWaiting();
	MyCoverPoint = FindCoverSpot();
	//broadcastmessage( "MyCoverPoint: "$MyCoverPoint );

	if( CanDirectlyReach( MyCoverPoint ) )
	{
		PlayToRunning();
		MoveToward( MyCoverPoint, GetRunSpeed() );
	}
	else if( !FindBestPathToward( MyCoverPoint, true ) )
	{
		Sleep( 1.0 );
		GotoState( 'Waiting', 'Begin' );
	}
	else
	{
		PlayToRunning();
		MoveTo( Destination, GetRunSpeed() );
	}
	if( VSize( MyCoverPoint.Location - Location ) > 72 )
		Goto( 'Begin' );
	else
	{
		TurnToward( MyBomb );
		PlayToWaiting();
	}
}

defaultproperties
{
     MultiBombTraps(0)=(DetRadius=128.000000,MinDetReactTime=0.110000,MaxDetReactTime=0.010000,bThrowWhenReached=True,ActionWhenBreached=BA_Fight)
     MultiBombTraps(1)=(DetRadius=128.000000,MinDetReactTime=0.110000,MaxDetReactTime=0.010000,bThrowWhenReached=True,ActionWhenBreached=BA_Fight)
     MultiBombTraps(2)=(DetRadius=128.000000,MinDetReactTime=0.110000,MaxDetReactTime=0.010000,bThrowWhenReached=True,ActionWhenBreached=BA_Fight)
     MultiBombTraps(3)=(DetRadius=128.000000,MinDetReactTime=0.110000,MaxDetReactTime=0.010000,bThrowWhenReached=True,ActionWhenBreached=BA_Fight)
     MultiBombTraps(4)=(DetRadius=128.000000,MinDetReactTime=0.110000,MaxDetReactTime=0.010000,bThrowWhenReached=True,ActionWhenBreached=BA_Fight)
     MultiBombTraps(5)=(DetRadius=128.000000,MinDetReactTime=0.110000,MaxDetReactTime=0.010000,bThrowWhenReached=True,ActionWhenBreached=BA_Fight)
     MultiBombTraps(6)=(DetRadius=128.000000,MinDetReactTime=0.110000,MaxDetReactTime=0.010000,bThrowWhenReached=True,ActionWhenBreached=BA_Fight)
     MultiBombTraps(7)=(DetRadius=128.000000,MinDetReactTime=0.110000,MaxDetReactTime=0.010000,bThrowWhenReached=True,ActionWhenBreached=BA_Fight)
     MultiBombTraps(8)=(DetRadius=128.000000,MinDetReactTime=0.110000,MaxDetReactTime=0.010000,bThrowWhenReached=True,ActionWhenBreached=BA_Fight)
     MultiBombTraps(9)=(DetRadius=128.000000,MinDetReactTime=0.110000,MaxDetReactTime=0.010000,bThrowWhenReached=True,ActionWhenBreached=BA_Fight)
     MultiBombTraps(10)=(DetRadius=128.000000,MinDetReactTime=0.110000,MaxDetReactTime=0.010000,bThrowWhenReached=True,ActionWhenBreached=BA_Fight)
     MultiBombTraps(11)=(DetRadius=128.000000,MinDetReactTime=0.110000,MaxDetReactTime=0.010000,bThrowWhenReached=True,ActionWhenBreached=BA_Fight)
     MultiBombTraps(12)=(DetRadius=128.000000,MinDetReactTime=0.110000,MaxDetReactTime=0.010000,bThrowWhenReached=True,ActionWhenBreached=BA_Fight)
     MultiBombTraps(13)=(DetRadius=128.000000,MinDetReactTime=0.110000,MaxDetReactTime=0.010000,bThrowWhenReached=True,ActionWhenBreached=BA_Fight)
     MultiBombTraps(14)=(DetRadius=128.000000,MinDetReactTime=0.110000,MaxDetReactTime=0.010000,bThrowWhenReached=True,ActionWhenBreached=BA_Fight)
     MultiBombTraps(15)=(DetRadius=128.000000,MinDetReactTime=0.110000,MaxDetReactTime=0.010000,bThrowWhenReached=True,ActionWhenBreached=BA_Fight)
     WeaponInfo(0)=(WeaponClass="dnGame.MultiBomb",PrimaryAmmoCount=500,AltAmmoCount=50)
     bAggressiveToPlayer=True
     EgoKillValue=8
     bIsHuman=True
     GroundSpeed=420.000000
     BaseEyeHeight=27.000000
     EyeHeight=27.000000
     Mesh=DukeMesh'c_characters.EDF_sappernogoggles'
     CollisionRadius=17.000000
     CollisionHeight=39.000000
     Health=50
}
