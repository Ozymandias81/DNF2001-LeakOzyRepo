/*=============================================================================
	CreatureFactory
	Author: Jess Crable/Steven Polge

	Use these to spawn creatures at SpawnPoint locations.
=============================================================================*/
class CreatureFactory extends ThingFactory;

#exec OBJ LOAD FILE=..\Textures\DukeED_Gfx.dtx

//var name Orders;      // creatures from this factory will have these orders
var name OrderTag;
var pawn	enemy;
var Pawn OwnedCreatures[ 16 ];

var( AI ) name AlarmTag ?("Alarmtag given to creatures from this factory.");	// alarmtag given to creatures from this factory
//var() int  AddedCoopCapacity; // Extra creatures for coop mode
// NPC specific stuff.
var( AI ) bool	bHatePlayer						?("If this is true, the AIPawn will immediately begin hunting player.");
var( AI ) bool	bAlwaysUseTentacles				?("If true the AIPawn will use tentacle attacks instead of punch or kick.");
var( AI ) bool	bUseAlwaysUseTentacles			?("Toggles whether to use the bAlwaysUseTentacles flag.");
var( AI ) bool  bAggressiveToPlayer				?("When true with bUseAggressiveToPlayer this AIPawn will\nattack the player when seen.");
var( AI ) bool  bUseAggressiveToPlayer			?("Toggles whether or not to use bAggressiveToPlayer flag.");

var( AIHuman ) bool	bFixedEnemy					?("If this and bUseFixedEnemy are true, this AIPawn will focus on a\nnon-player enemy.");
var( AIHuman ) bool	bUseFixedEnemy				?("Toggles whether or not to use bFixedEnemy flag.");
var( AIHuman ) name	FixedEnemyTag				?("Tag to match for the fixed enemy.");
var( AIHuman ) bool	bUseEnemyClass				?("If true, and a FixedEnemyClass is defined, and no FixedEnemyTag\nis set, will go by class instead of tag.");
var( AIHuman ) class< Actor > FixedEnemyClass	?("Class type of FixedEnemy.");
var( AIHuman ) bool	bJumpCower;

var( AIHuman ) class<Weapon> NPCWeapons[ 9 ];
var( AIHuman ) int	   NPCPrimaryAmmo[ 9 ];
var( AIHuman ) int	   NPCAlternateAmmo[ 9 ];
var( AIHuman ) bool	bUseMyWeapons				?("If true, the NPCWeapons defined here will be used\ninstead of the default NPC weapons.");
var( AIHuman ) bool	bCanHaveCash				?("If this AIPawn can carry cash, set this to true.");
var( AIHuman ) bool bUseCanHaveCash				?("Toggles whether to use the bCanHaveCash flag.");
var( AIHuman ) EFacialExpression FacialExpression;
var( AIHuman ) bool	bUseFacialExpression;
var( AIHuman ) bool bMakeFaceDefault;
var( AIHuman ) float AggroSnatchDistance		?("Maximum distance enemy can be from a snatched non aggressive NPC before he aggros." );
var( AIHuman ) bool bVisiblySnatched			?("This pawn will show visible signs of being snatched." );
var( AIHuman ) bool	bIdleSeeFriendlyMonsters	?("This pawn will notice and look at friendly non players.");
var( AIHuman ) bool bIdleSeeFriendlyPlayer		?("This pawn will notce and look at a non-aggressive player.");

var( AIShieldUser ) int MaxShots;
var( AIShieldUser ) int MinShots;

var( AI ) bool	bUseCreatureTag					?("Determines whether to use the defined creature tag.");
var( AI ) name  CreatureTag						?("When bUseCreatureTag is true, this tag will be given to the creature.");
var( AI ) int	NewHealth						?("New health setting for this creature.");
var( AI ) bool	bUseHealth						?("Determines whether or not to use the new health setting.");
var( AI ) bool	bCoverOnAcquisition				?("When true, this NPC will seek cover immediately after acquiring an enemy.");
var( AI ) bool	bSnatchedCreature				?("Whether or not this AIPawn is snatched.");
var( AI ) bool	bPanicking;
var( AI ) name	ControlTag;
var( AI ) name	CoverTag;

var( AIFollow ) name	FollowEvent;
var( AIFollow ) bool	bFollowEventOnceOnly;

var( AISpecial ) bool bUseFlashlight			?("Special case variable to handle flashlight holding NPC.");

var() bool bSpawnWhenTriggered;
var() name FinishedEvent						?("This event will be called when the factory's children are all dead AND capacity is 0.");
var EDFSpeechCoordinator SpeechCoordinator;

var int TouchCount;

enum EOrderType
{
	ORDERS_Idle,
	ORDERS_Wander,
	ORDERS_Patrol,
	ORDERS_Defend,
	ORDERS_Follow
};

var( AIHuman ) EOrderType Orders;

enum ECreatureOrderType
{
	ORDERS_None,

	ORDERS_Idling,
	ORDERS_Roaming
};

var( AICreature ) ECreatureOrderType CreatureOrders;
// Facial expressions.
// This probably shouldn't be here.  Lights don't have facial expressions.  
// Prove it!


function PreBeginPlay()
{
	if ( Level.Game.bNoMonsters )
		Destroy();
	else
		Super.PreBeginPlay();
}

function PostBeginPlay()
{
	Super.PostBeginPlay();
}

function AddCreature( Pawn NewPawn )
{
	local int i;

	for( i = 0; i <= 15; i++ )
	{
		if( OwnedCreatures[ i ] == None )
		{
			OwnedCreatures[ i ] = NewPawn;
			break;
		}
	}
}

function RemoveCreature( Pawn NewPawn )
{
	local int i;

	for( i = 0; i <= 15; i++ )
	{
		if( OwnedCreatures[ i ] == NewPawn )
		{
			OwnedCreatures[ i ] = None;
			break;
		}
	}

	if( GetCreatureCount() <= 0 && Capacity <= 0 )
	{
		TriggerEmptyEvent();
	}
}

function TriggerEmptyEvent()
{
	local Actor A;

	if( FinishedEvent != '' )
	{
		foreach allactors( class'Actor', A, FinishedEvent )
		{
			A.Trigger( self, none );
		}
	}
}

function int GetCreatureCount()
{
	local int i, j;

	for( i = 0; i <= 15; i++ )
	{
		if( OwnedCreatures[ i ] != None )
			j++;
	}

	return j;
}


Auto State Waiting
{
	function Touch(Actor Other)
	{
		local pawn otherpawn;
	
		otherpawn = Pawn(Other);
		if ( (otherpawn != None) && (!bOnlyPlayerTouched || ( otherpawn.bIsPlayer && !otherPawn.IsA( 'AIPawn' ) ) ) )
		{
			enemy = otherpawn;
			Trigger(other, otherPawn);
		}		
	}
}	
		
state Spawning
{
	function BeginState()
	{
		local EDFSpeechCoordinator EDFSC;

		if( SpeechCoordinator == None )
		{
			foreach allactors( class'EDFSpeechCoordinator', EDFSC )
			{
				SpeechCoordinator = EDFSC;
			}
		}
		Super.BeginState();
	}

	Function StartBuilding()
	{
		local float nextTime;

		if( !bSpawnWhenTriggered )
		{
			if (timeDistribution == DIST_Constant)
				nextTime = interval;
			else if (timeDistribution == DIST_Uniform)
				nextTime = 2 * FRand() * interval;
			else //timeDistribution is gaussian
				nextTime = 0.5 * (FRand() + FRand() + FRand() + FRand()) * interval;
				
			if (capacity > 0)
				SetTimer(nextTime, false);
		}
		else
		{
			GotoState( 'Waiting' );
		}
	}

		function Timer( optional int TimerNum )
		{
			local int start;
	
			if (numitems < maxitems)
			{
				//pick a spawn point
				start = Rand(numspots);
				if ( !trySpawn(start, numspots) )
				{
					trySpawn(0, start);
				}
			}
			
			if (numitems < maxitems)
			{
				StartBuilding();
			}
		}

	function bool trySpawn(int start, int end)
	{
		local int i;
		local bool done;
		done = false;
		i = start;

		while (i < end)
		{
			if (spawnspot[i].Create())
			{
				done = true;
				i = end;
				capacity--;
				numitems++;
				if (capacity == 0)
				{
					GotoState('Finished');
				}
			}
			i++;
		}
		return done;
	}
}

state Finished
{
}	

defaultproperties
{
     Orders=Attacking
     capacity=1
     bCovert=True
	 AggroSnatchDistance=128
     Texture'DukeED_Gfx.CreatureFactory'
     bVisiblySnatched=true
}
