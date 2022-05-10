//=============================================================================
// Spawnpoint.
//Used by Creature Factories for spawning monsters
//=============================================================================
class SpawnPoint extends NavigationPoint;

#exec OBJ LOAD FILE=..\Textures\DukeED_Gfx.dtx

var ThingFactory factory;

var( AI ) float SafetyRadius ?("Do not spawn here if any pawns are within this radius (units).");		
var( AIHuman ) PatrolControl CurrentPatrolControl;
var( AIHuman ) name InitialCoverTag;
var( AI ) bool	bCoverOnAcquisition;
var( AI ) bool	UseCoverOnAcquisition;
var( AI ) name SpecialCoverTag;
var( AI ) name	HateTag;
var( AIHuman ) bool bRollLeftOnSpawn;
var( AIHuman ) bool bRollRightOnSpawn;
var( AIHuman ) float HeadCreeperOdds	?("Odds between 0.0 and 1.0 of a HeadCreeper infesting this human.");
var( AI ) name PatrolTag;
var( AI ) bool bPatrolIgnoreSeePlayer;
var( AIHuman ) bool bRetreatAtStartup;
var( AIHuman ) bool bSneakAttack;
var( AIHuman ) bool bKneelAtStartup;
var( AIHuman ) name RetreatTag;
var( AIHuman ) bool bStrafeRightOnSpawn;
var( AIHuman ) bool bStrafeLeftOnSpawn;
var( AIHuman ) float MaxCoverDistance	?( "Maximum distance (in units) a selectable coverpoint can be away from the Grunt." );
var( AIHuman ) bool	bUseMaxCoverDistance;
var( AI )	   class<Decoration> Accessories[6];
var( AI )      class<Inventory> SearchableItems[ 5 ];
var( AIHuman ) bool bPanicOnFire;
var( AI )	   int  NewHealth;
var( AIHuman ) bool bSleepAttack;
var( AIHuman ) float WakeRadius;

function SetPawnFlags( Pawn Creature, CreatureFactory PawnFactory )
{
	local int i;

	if( Accessories[ 0 ] != None )
	{
		for( i = 0; i <= 5; i++ )
			Creature.Accessories[ i ] = Accessories[ i ];
	}

	if( SearchableItems[ 0 ] != None )
	{
		for( i = 0; i <= 4; i++ )
			Creature.SearchableItems[ i ] = SearchableItems[ i ];
	}

	if( PawnFactory.bUseCreatureTag )
		Creature.Tag = PawnFactory.CreatureTag;
	else
		Creature.Tag = PawnFactory.Tag;

	if( PawnFactory.bSnatchedCreature )
		Creature.bSnatched = true;

	if( PawnFactory.bUseHealth )
		Creature.Health = PawnFactory.NewHealth;

	if( NewHealth > 0 )
		Creature.Health = NewHealth;

	if ( Creature.Physics == PHYS_Walking )
		Creature.SetPhysics( PHYS_Falling );
}

function SetHumanNPCFlags( HumanNPC Creature, CreatureFactory PawnFactory )
{
	Creature.WakeRadius = WakeRadius;
	Creature.bSleepAttack = bSleepAttack;

	Creature.HeadCreeperOdds = HeadCreeperOdds;

	Creature.bSneakAttack = bSneakAttack;

	if( PatrolTag != '' )
		Creature.NPCOrders = ORDERS_Patrol;

	Creature.bPanicOnFire = bPanicOnFire;

	if( PawnFactory.bUseCanHaveCash )
		Creature.bCanHaveCash = PawnFactory.bCanHaveCash;

	Creature.bPatrolIgnoreSeePlayer = bPatrolIgnoreSeePlayer;

	Creature.bVisiblySnatched = PawnFactory.bVisiblySnatched;
	log( "HumanNPCFlags set bVisiblySnatched to "$Creature.bVisiblySnatched$" for "$Creature );
	if( Creature.bShieldUser )
	{
		Creature.MaxShots = PawnFactory.MaxShots;
		Creature.MinShots = PawnFactory.MinShots;
	}
	Creature.bJumpCower = PawnFactory.bJumpCower;
	if( Creature.IsA( 'NPC' ) )
		NPC( Creature ).bUseFlashlight = PawnFactory.bUseFlashlight;

	Creature.bIdleSeeFriendlyPlayer = PawnFactory.bIdleSeeFriendlyPlayer;
	Creature.bIdleSeeFriendlyMonsters = PawnFactory.bIdleSeeFriendlyMonsters;
}

function SetAIPawnFlags( AIPawn Creature, CreatureFactory PawnFactory )
{
	Creature.bPanicking = PawnFactory.bPanicking;
	if( PatrolTag != '' )
		Creature.PatrolTag = PatrolTag;

	if( PawnFactory.ControlTag != '' )
	{
		Creature.ControlTag = PawnFactory.ControlTag;
		Creature.InitializeController();
	}
	if( PawnFactory.CoverTag != '' )
		Creature.CoverTag = PawnFactory.CoverTag;

	if( PawnFactory.bUseAlwaysUseTentacles )
		Creature.bAlwaysUseTentacles = PawnFactory.bAlwaysUseTentacles;

	Creature.AggroSnatchDistance = PawnFactory.AggroSnatchDistance;
	if( PawnFactory.FollowEvent != '' )
	{
		Creature.FollowEvent = PawnFactory.FollowEvent;
		Creature.bFollowEventOnceOnly = PawnFactory.bFollowEventOnceOnly;
	}

	if( PawnFactory.bUseAggressiveToPlayer )
		Creature.bAggressiveToPlayer = PawnFactory.bAggressiveToPlayer;

	if( HateTag != '' )
		Creature.HateTag = HateTag;
}

function SetGruntFlags( Grunt Creature, CreatureFactory PawnFactory )
{
	local int i;

	log( "bUseMyWeapons is "$PawnFactory.bUseMyWeapons );
	
	Creature.bRollLeftOnSpawn = bRollLeftOnSpawn;
	Creature.bRollRightOnSpawn = bRollRightOnSpawn;
	Creature.bStrafeLeftOnSpawn = bStrafeLeftOnSpawn;
	Creature.bStrafeRightOnSpawn = bStrafeRightOnSpawn;

	if( bUseMaxCoverDistance )
		Creature.MaxCoverDistance = MaxCoverDistance;

	if( bKneelAtStartup )
	{
		// log( "bKneelAtStartup setting.." );
		Creature.bKneelAtStartup = true;
	}

	if( bRetreatAtStartup )
	{
		Creature.bRetreatAtStartup = true;
		Creature.RetreatTag = RetreatTag;
	}

	if( SpecialCoverTag != '' )
		Creature.CoverTag = SpecialCoverTag; 

	if( bCoverOnAcquisition && UseCoverOnAcquisition )
		Creature.bCoverOnAcquisition = true;

	if( InitialCoverTag != '' )
	{
		Creature.InitialCoverTag = InitialCoverTag;
		Creature.bUseInitialCoverTag = true;
	}
	else if( PawnFactory.bCoverOnAcquisition )
		Creature.bCoverOnAcquisition = true;

	if( PawnFactory.bUseMyWeapons )
	{
		if( !Creature.bShieldUser && !Creature.bSniper ) //&& !Creature.bSteelSkin )
		{
			for( i = 0; i <= 8; i++ )
			{
				if( PawnFactory.NPCWeapons[ i ] != None )
					Creature.AddWeaponFromFactory( PawnFactory.NPCWeapons[ i ], PawnFactory.NPCPrimaryAmmo[ i ], PawnFactory.NPCAlternateAmmo[ i ] );
				else break;
			}
			//Creature.AddWeaponFromFactory( class'Pistol', 900, 900 );

		}
		else if( Creature.bSniper )
				Creature.AddWeaponFromFactory( class'm16', 500, 500 );
		else if( Creature.bShieldUser )
				Creature.AddWeaponFromFactory( class'Pistol', 900, 900 );
	}
}

function bool Create()
{
	local pawn newcreature;
	local CreatureFactory pawnFactory;
	local pawn creature;
	local actor temp, A;
	local rotator newRot;
	local pawn p;
	local int i;

	foreach radiusactors( class'Pawn', P, SafetyRadius )
	{
		if( P != None )
			return false;
	}

	if( Factory.bCovert && PlayerCanSeeMe() ) //make sure no player can see this
		return false;
	
	Temp = Spawn( Factory.Prototype, Factory );
	if( Temp == None )
		return false;

	NewRot = rot( 0, 0, 0 );
	NewRot.Yaw = Rotation.Yaw;
	Temp.SetRotation( NewRot );
	Temp.Event = Factory.Tag;
	Temp.Tag = Factory.ItemTag;
	NewCreature = Pawn( Temp );
	
	if( Event != '' )
		foreach AllActors( class 'Actor', A, Event )
			A.Trigger( Self, Instigator );
	if( Factory.bFalling )
		Temp.SetPhysics( PHYS_Falling );
	if( NewCreature == None )
		return true;
	PawnFactory = CreatureFactory( Factory );
	if( PawnFactory == None )
		return true;
	
	if( NewCreature != None )
	{
		PawnFactory.AddCreature( NewCreature );
		AIPawn( NewCreature ).MyFactory = PawnFactory;

		SetPawnFlags( NewCreature, PawnFactory );
		if( NewCreature.IsA( 'AIPawn' ) )
			SetAIPawnFlags( AIPawn( NewCreature ), PawnFactory );
		if( NewCreature.IsA( 'HumanNPC' ) )
			SetHumanNPCFlags( HumanNPC( NewCreature ), PawnFactory );
		if( NewCreature.IsA( 'Grunt' ) )
			SetGruntFlags( Grunt( NewCreature ), PawnFactory );
		
		if( PawnFactory.bHatePlayer )
		{
			if( NewCreature.IsA( 'AIPawn' ) )
				AIPawn( NewCreature ).bAggressiveToPlayer = true;

			NewCreature.Enemy = FindPlayerPawn();
			
			if( NewCreature.IsA( 'Grunt' ) )
				NewCreature.GotoState( 'DodgeRoll' );
			else if( NewCreature.IsA( 'HumanNPC' ) )
			{
				if( HumanNPC( NewCreature ).bSleepAttack )
					NewCreature.GotoState( 'SleepAttack' );
				else
					NewCreature.GotoState( 'Hunting' );
			}
			else if( NewCreature.IsA( 'Creature' ) && Snatcher( NewCreature ) != None )
				NewCreature.GotoState( 'Snatcher' );
			else if( NewCreature.IsA( 'Creature' ) )
				NewCreature.GotoState( 'Hunting' );
		}

		if( NewCreature.IsA( 'Creature' ) )
		{
			if( PawnFactory.CreatureOrders == 1 )
				NewCreature.GotoState( 'Idling' );
			else if( PawnFactory.CreatureOrders == 2 )
				NewCreature.GotoState( 'Roaming' );
		}
		else if( NewCreature.IsA( 'HumanNPC' ) )
		{
			if( !PawnFactory.bHatePlayer )
			{
				if( PawnFactory.Orders == 1 )
					NewCreature.GotoState( 'Wandering' );
				else if( PawnFactory.Orders == 2 )
				{
					HumanNPC( NewCreature ).CurrentPatrolControl = CurrentPatrolControl;
					NewCreature.GotoState( 'Patrolling' );
				}
				else if( PawnFactory.Orders == 3 )
					log( "***> Orders Defend for HumanNPCs spawned from a factory aren't currently supported." );	
				else if( PawnFactory.Orders == 4 )
					log( "***> Orders Follow for HumanNPCs spawned from a factory aren't currently supported." );	
			}
		}
	}
	else 
		NewCreature.Enemy = PawnFactory.Enemy;
	
	if( NewCreature.Enemy != None )
		NewCreature.LastSeenPos = NewCreature.Enemy.Location;

	NewCreature.SetMovementPhysics();
	if( PawnFactory.bFixedEnemy && PawnFactory.bUseFixedEnemy )
	{
		if( !PawnFactory.bUseEnemyClass )
		{
			if( NewCreature.IsA( 'HumanNPC' ) )
				SetNPCEnemy( HumanNPC( NewCreature ), PawnFactory.FixedEnemyTag );
			else
				SetCreatureEnemy( NewCreature, PawnFactory.FixedEnemyTag );
		}
		else
		{
			if( NewCreature.IsA( 'HumanNPC' ) )
				SetNPCEnemy( HumanNPC( NewCreature ),, PawnFactory.FixedEnemyClass );
			else
				SetCreatureEnemy( NewCreature,, PawnFactory.FixedEnemyClass );
		}
	}
	return true;
}

function SetNPCEnemy( HumanNPC NPC, optional name EnemyTag, optional class< Actor > EnemyClass )
{
	local actor A;

	if( EnemyTag != '' )
	{
		log( "ENEMY TAG FOR "$self$" IS "$EnemyTag );

		foreach allactors( class'Actor', A, EnemyTag )
		{
			NPC.bFixedEnemy = true;
			NPC.Enemy = A;
			NPC.PlayToWaiting();
			if( NPC.bSnatched )
			{
				NPC.NextState = 'Attacking';
				NPC.GotoState( 'SnatchedEffects' );
			}
			else NPC.GotoState( 'Attacking' );
			break;
		}
	}
	else if( EnemyClass != None )
	{
		foreach allactors( EnemyClass, A )
		{
			NPC.bFixedEnemy = true;
			NPC.Enemy = A;
			NPC.PlayToWaiting();
			if( NPC.bSnatched )
			{
				NPC.NextState = 'Attacking';
				NPC.GotoState( 'SnatchedEffects' );
			}
			else NPC.GotoState( 'Attacking' );
			break;
		}
	}
}

function SetCreatureEnemy( Pawn aCreature, optional name EnemyTag, optional class< Actor > EnemyClass )
{
	local actor A;

	if( EnemyTag != '' )
	{
		foreach allactors( class'Actor', A, EnemyTag )
		{
			aCreature.bFixedEnemy = true;
			aCreature.Enemy = A;
			if( aCreature.IsA( 'Snatcher' ) )
				aCreature.GotoState( 'Snatcher' );
			else
				aCreature.GotoState( 'Hunting' );
			break;
		}
	}
	else if( EnemyClass != None )
	{
		foreach allactors( EnemyClass, A )
		{
			aCreature.bFixedEnemy = true;
			aCreature.Enemy = A;
			if( aCreature.IsA( 'Snatcher' ) )
				aCreature.GotoState( 'Snatcher' );
			else
				aCreature.GotoState( 'Hunting' );	
			break;
		}
	}
}

function PlayerPawn FindPlayerPawn()
{
	local PlayerPawn P;

	foreach allactors( class'PlayerPawn', P )
	{
		return P;
	}
}

defaultproperties
{
     bDirectional=True
     SoundVolume=128
     SafetyRadius=128
     Texture=Texture'DukeED_Gfx.SpawnPoint'
}
