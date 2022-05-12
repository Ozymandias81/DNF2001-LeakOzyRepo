//=============================================================================
// BigBloodHit.
//=============================================================================
class UT_BigBloodHit extends UT_BloodBurst;

Auto State StartUp
{
	simulated function Tick(float DeltaTime)
	{
		local vector WallHit, WallNormal;
		local Actor WallActor;

		WallActor = Trace(WallHit, WallNormal, Location + 150 * vector(Rotation), Location, false);
		if ( WallActor != None )	
			spawn(class'UTBloodPool',,,WallHit, rotator(WallNormal));
		Disable('Tick');
	}
}

defaultproperties
{
}
