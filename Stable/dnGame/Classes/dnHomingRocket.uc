//=============================================================================
// dnHomingRocket.
//=============================================================================
class dnHomingRocket expands dnRocket;

var () float TurnScaler;

function PostBeginPlay()
{
	Super.PostBeginPlay();

	SetTimer( 0.05, true );
}

function Tick( float DeltaSeconds )
{
	// Point in the direction it's going:
	SetRotation( rotator(Velocity) );
}

function Timer( optional int TimerNum )
{
	local vector SeekingDir, NewDir;
	local float MagnitudeVel,MagnitudeAccel;

	if ( Target != None && Target != Instigator )
	{
		SeekingDir = Normal(Target.Location+TargetOffset - Location);
		MagnitudeVel = VSize(Velocity);
		NewDir=Normal((SeekingDir * MagnitudeVel) + ( Velocity * TurnScaler));
		Velocity =  MagnitudeVel * NewDir;		
		
		MagnitudeAccel=VSize(Acceleration);
		Acceleration=MagnitudeAccel*NewDir;
	}
}

defaultproperties
{
     TurnScaler=7.000000
     AdditionalMountedActors(0)=(ActorClass=Class'dnGame.dnWeaponFX_HomingFire',MountOrigin=(Y=17.500000,Z=-39.000000))
     speed=450.000000
     MaxSpeed=800.000000
     DrawScale=3.000000
}
