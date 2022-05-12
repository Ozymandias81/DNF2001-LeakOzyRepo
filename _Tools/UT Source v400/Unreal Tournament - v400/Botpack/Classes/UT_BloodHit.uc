//=============================================================================
// BloodBurst.
//=============================================================================
class UT_BloodHit extends UT_BloodBurst;

simulated function SpawnCloud()
{
	local Actor A;

	if ( bGreenBlood )
		A= spawn(class'UT_GreenBloodPuff');
	else
		A = spawn(class'UT_BloodPuff');
	A.RemoteRole = ROLE_None;
}

Auto State StartUp
{
	simulated function Tick(float DeltaTime)
	{
		local vector WallHit, WallNormal;
		local Actor WallActor;

		WallActor = Trace(WallHit, WallNormal, Location + 300 * vector(Rotation), Location, false);
		if ( WallActor != None )	
			spawn(class'BloodSplat',,,WallHit + 20 * (WallNormal + VRand()), rotator(WallNormal));
		
		Disable('Tick');
	}
}

defaultproperties
{
}
