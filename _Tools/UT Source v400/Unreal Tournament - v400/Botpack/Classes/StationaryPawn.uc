//=============================================================================
// StationaryPawn.
//=============================================================================
class StationaryPawn extends Pawn
	abstract;

function SetTeam(int TeamNum);

simulated function AddVelocity( vector NewVelocity )
{
	Velocity = vect(0,0,0);
}

function bool SameTeamAs(int TeamNum)
{
	return false;
}

defaultproperties
{
     FovAngle=0
     Visibility=0
     SightRadius=-1000
     HearingThreshold=-1000
     AttitudeToPlayer=ATTITUDE_Ignore
     Intelligence=BRAINS_NONE
     MaxDesiredSpeed=0
     GroundSpeed=+00000.000000
     WaterSpeed=+00000.000000
     AccelRate=+00000.000000
     JumpZ=+00000.000000
     MaxStepHeight=+00000.000000
     bCanTeleport=False
	 bStasis=False
     RotationRate=(Pitch=0,Yaw=0,Roll=0)
    RemoteRole=ROLE_DumbProxy
	Health=500
    DrawType=DT_Mesh
}