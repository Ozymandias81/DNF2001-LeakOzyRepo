class Shark expands Fish;

#exec obj load file=..\meshes\c_zone1_vegas.dmx

var vector OldSchoolDestination;

function ZoneChange( ZoneInfo NewZone )
{
	local rotator newRotation;

	if (!NewZone.bWaterZone)
	{
		StopMoving();
		SetPhysics(PHYS_Falling);
		GotoState( 'Flopping' );
		GotoState('Attacking');
	}
}

Auto State Swimming
{
	function PickDestination()
	{
		OldSchoolDestination = Location;
		Destination = OldSchoolDestination +  0.5 * 512 * ( Normal(Location - Location) + VRand());
	}

	function Touch(Actor Other)
	{
	//	if ( Pawn(Other) == School.Enemy )
	//		Other.TakeDamage(2, self, location, vect(0,0,0), 'bitten');
	}
			
	Begin:
		if (!Region.Zone.bWaterZone)
			GotoState('Flopping');
		SetPhysics(PHYS_Swimming);
	Swim:
		Enable('HitWall');
		PickDestination();
		TurnTo( Destination );
		MoveTo(Destination);
	School:
		if ( (FRand() < 0.75) && (Destination == Location) 
			&& (Enemy == None) )
		{
			StopMoving();
			Acceleration = vect(0,0,0);
			Sleep(3.3 * FRand());
			Goto('School');
		}
	Velocity = vect(0,0,0);
	Acceleration = vect(0,0,0);
	Sleep(0.7 * FRand());
	Goto('Swim');
}

function PreSetMovement()
{
	bCanJump = false;
	bCanWalk = false;
	bCanSwim = true;
	bCanFly = false;
	MinHitWall = -0.6;
	bCanOpenDoors = false;
	bCanDoSpecial = false;
}
	
function SetMovementPhysics()
{
	if (Region.Zone.bWaterZone)
	SetPhysics(PHYS_Swimming);
	else
	{
		SetPhysics(PHYS_Falling);
		MoveTimer = -1.0;
		GotoState('Flopping');
	} 
}

State Flopping
{
	ignores seeplayer, hearnoise, enemynotvisible, hitwall; 	

	function Timer( optional int TimerNum )
	{
		//AirTime += 1;
		//if ( AirTime > 25 + 15 * FRand() )
		//{
		//	Health = -1;
		//	Died(None, 'suffocated', Location);
		//	return;
		//}	
		SetPhysics(PHYS_Falling);
		Velocity = 200 * VRand();
		Velocity.Z = 170 + 200 * FRand();
		DesiredRotation.Pitch = Rand(8192) - 4096;
		DesiredRotation.Yaw = Rand(65535);
		TweenAnim('Flopping', 0.1);
	}
		
function ZoneChange( ZoneInfo NewZone )
{
	local rotator newRotation;
	if (NewZone.bWaterZone)
	{
		newRotation = Rotation;
		newRotation.Roll = 0;
		SetRotation(newRotation);
		SetPhysics(PHYS_Swimming);
		//AirTime = 0;
		GotoState('Attacking');
	}
	else
	SetPhysics(PHYS_Falling);
}

function Landed(vector HitNormal)
{
	local rotator newRotation;
	SetPhysics(PHYS_None);
//	SetTimer(0.3 + 0.3 * AirTime * FRand(), false);
	newRotation = Rotation;
	newRotation.Pitch = 0;
	newRotation.Roll = Rand(16384) - 8192;
	DesiredRotation.Pitch = 0;
	SetRotation(newRotation);
	PlaySound(land,SLOT_Interact,,,400);
	TweenAnim('Breathing', 0.3);
}
		
function AnimEnd()
{
	if (Physics == PHYS_None)
	{
		if (AnimSequence == 'Breathing')
		{
			PlayAnim('Breathing');
		}
		else 
		TweenAnim('Breathing', 0.2);
	}
	else
		PlayAnim('Flopping', 0.7);
	}
}

DefaultProperties
{
	Mesh=DukeMesh'c_zone1_vegas.great_white1'
	WaterSpeed=250
	UnderWaterTime=-1.000000
	bIsWalking=false
	buoyancy=60
	mass=60
	CollisionHeight=22.000000
	CollisionRadius=30.000000
}
