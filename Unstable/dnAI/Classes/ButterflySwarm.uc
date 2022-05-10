/*=============================================================================
	ButterflySwarm
	Author: Jess Crable

=============================================================================*/
class ButterflySwarm extends AIFlockController;
#exec obj load file=..\textures\m_zone3_canyon.dtx

var()	byte	SwarmSize; 
var		byte	TotalButterflies;
var()	float	SwarmRadius;
var()	float	MaxAirSpeed;
var()	float	MinAirSpeed;
var()	float	ButterflyScale;

var()	byte	BlueCount;
var()	byte	BrownCount;
var()	byte	OrangeCount;
var()	byte	YellowCount;
var()	byte	BlackCount;

var	byte	CurrentBlueCount;
var	byte	CurrentRedCount;
var byte	CurrentOrangeCount;
var byte	CurrentBrownCount;
var byte	CurrentBlackCount;
var byte	CurrentYellowCount;

var()	bool	bRandomTypes;

function PreBeginPlay()
{
	TotalButterflies = SwarmSize;
	Super.PreBeginPlay();
}

function PostBeginPlay()
{
	if( !bRandomTypes )
	{
		SwarmSize = BlueCount + BrownCount + BlackCount + OrangeCount + YellowCount;
	}
	Super.PostBeginPlay();
}

function Texture ChooseSpecificSkin()
{
	if( CurrentBlueCount < BlueCount )
	{
		CurrentBlueCount++;
		return texture'ButterFBlueRC';
	}
	if( CurrentBrownCount < BrownCount )
	{
		CurrentBrownCount++;
		return texture'ButterFBrownRC';
	}
	if( CurrentYellowCount < YellowCount )
	{
		CurrentYellowCount++;
		return texture'ButterFYellowRC';
	}
	if( CurrentBlackCount < BlackCount )
	{
		CurrentBlackCount++;
		return texture'ButterFBlackRC';
	}
	if( CurrentOrangeCount < OrangeCount )
	{
		CurrentOrangeCount++;
		return texture'ButterFOrangeRC';
	}
}


singular function ZoneChange( ZoneInfo NewZone )
{
	if ( NewZone.bWaterZone )
	{
		SetLocation(OldLocation);
		Velocity = vect(0,0,0);
		Acceleration = vect(0,0,0);
		MoveTimer = -1.0;
		Enemy = None;
	}
}
	
function SpawnFlies()
{
	local Butterfly BFly;
	local int i;

	while (SwarmSize > 0)
	{
		SwarmSize--;
		BFly = Spawn(class 'Butterfly',self,'', Location + VRand() * CollisionRadius);
		BFly.AirSpeed = RandRange( MinAirSpeed, MaxAirSpeed );
		BFly.DrawScale = ButterflyScale;
		if( bRandomTypes )
		{
			i = rand( 5 );
			Switch ( i )
			{
				Case 0:
					BFly.MultiSkins[ 0 ] = texture'ButterFBlackRC';
					break;
				Case 1:
					BFly.MultiSkins[ 0 ] = texture'ButterFBlueRC';
					break;
				Case 2:
					BFly.MultiSkins[ 0 ] = texture'ButterFBrownRC';
					break;
				Case 3:
					BFly.MultiSkins[ 0 ] = texture'ButterFOrangeRC';
					break;
				Case 4:
					BFly.MultiSkins[ 0 ] = texture'ButterFYellowRC';
					break;
				Default:
					BFly.MultiSkins[ 0 ] = texture'ButterFBlueRC';
					break;
			}
		}
		else
			BFly.MultiSkins[ 0 ] = ChooseSpecificSkin();
	}
}

auto state stasis
{
	ignores EncroachedBy;

	//function SeePlayer(Actor SeenPlayer)
	//{
	//	enemy = Pawn(SeenPlayer);
//		SpawnFlies();
//		Gotostate('wandering');
//	}
	function BeginState()
	{
		if( !bWaitUntilTriggered )
		{
			Trigger( self, self );
		}
	}

	function Trigger( actor Other, Pawn EventInstigator )
	{
		SpawnFlies();
		GotoState( 'Wandering' );
	}

	Begin:
	//	SetPhysics(PHYS_None);
	}		
	
function PreSetMovement()
{
	bCanJump = true;
	bCanWalk = true;
	bCanSwim = false;
	bCanFly = true;
	MinHitWall = -0.6;
}

state wandering
{
	ignores EncroachedBy;
	
	/*function SeePlayer(Actor SeenPlayer)
	{
		local actor newfly;
		Enemy = Pawn(SeenPlayer);
		SpawnFlies();
		Disable('SeePlayer');
		Enable('EnemyNotVisible');
	}*/
/*
	function EnemyNotVisible()
	{
		Enemy = None;
		Disable('EnemyNotVisible');
	}
	*/
Begin:
	SetPhysics(PHYS_Flying);

Wander:
	//Destination = Location + VRand() * 1;
	//Destination.Z = 0.5 * (Destination.Z + Location.Z);
	Destination = Location + Vect( 0, 0, 42 );
	//	SwarmRadius *= 1.25;
	//MoveTo(Destination);
	Sleep( 0.2 );
	Goto('Wander');
}

defaultproperties
{
	bCanFly=true
	SwarmSize=16
    SwarmRadius=128.00
    GroundSpeed=200.00
    AirSpeed=500.00
    SightRadius=2.00
    PeripheralVision=-5.00
    bHidden=true
    AccelRate=300
	bCanStrafe=true
	ButterflyScale=2.500000
	MaxAirSpeed=300.000000
	MinAirSpeed=200.000000
    bRandomTypes=true
}
 
