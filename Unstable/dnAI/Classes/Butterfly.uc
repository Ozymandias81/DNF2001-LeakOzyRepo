/*=============================================================================
	Butterfly
	Author: Jess Crable

=============================================================================*/
class Butterfly expands AIPawn;

#exec obj load file=..\meshes\c_zone3_canyon.dmx
#exec obj load file=..\textures\m_zone3_canyon.dtx

var float HeightMod;

function bool EncroachingOn( actor Other )
{
	if ( (Other.Brush != None) || (Brush(Other) != None) )
		return true;
		
	return false;
}

function EncroachedBy( actor Other )
{
}

function PlayTakeHit(float tweentime, vector HitLoc, int damage)
{
}

//function Died(pawn Killer, name damageType, vector HitLocation, optional vector Momentum )
//{
//	GotoState('Dying');
//}

auto state meander
{
	ignores seeplayer, enemynotvisible, footzonechange;
	
	function BeginState()
	{

	//	AirSpeed = RandRange( 50, 90 );
	}

	singular function ZoneChange( ZoneInfo NewZone )
	{
		if ( NewZone.bWaterZone )
		{
			SetLocation(OldLocation);
			Velocity = vect(0,0,0);
			Acceleration = vect(0,0,0);
			MoveTimer = -1.0;
		}
	}

		 		
begin:
	LoopAnim('ButrFlyFast');
	SetPhysics(PHYS_Flying);
wander:
	if ( Owner == None )
		Destroy();
//	if (!LineOfSightTo(Owner))
//		SetLocation(Owner.Location);

	bRotateToDesired=true;
	MoveTo(Owner.Location + ButterflySwarm(Owner).swarmradius * (VRand() +  vect(0,0,HeightMod)));

	if( VSize( Owner.Location - Location ) < ButterflySwarm(Owner).swarmradius * 0.25 )
		HeightMod += 5.5;
	else HeightMod =0;

	if ( Owner == None )
		Destroy();
	else
		Goto('Wander');
}

State Dying
{
	ignores seeplayer, enemynotvisible, footzonechange;

	function Landed(vector HitNormal)
	{
		SetPhysics(PHYS_None);
	}	

Begin:
	if ( Owner != None )
	{
		ButterflySwarm(Owner).TotalButterflies--;
		if ( ButterflySwarm(Owner).TotalButterflies <= 0 )
			Owner.Destroy();
	}	
	SetPhysics(PHYS_Falling);
	RemoteRole = ROLE_DumbProxy;
	Sleep(15);
	Destroy();
}			


DefaultProperties
{
	RotationRate=(Pitch=3072,Yaw=10000,Roll=3072)
	bRotateToDesired=true
	Mesh=DukeMesh'c_zone3_canyon.butterfly'
    AirSpeed=250.00
	DrawScale=2.5
    Land=None
    DrawType=DT_Mesh
    CollisionRadius=0.00
    CollisionHeight=0.00
    bCollideActors=False
    bBlockActors=False
    bBlockPlayers=False
    bProjTarget=False
}
