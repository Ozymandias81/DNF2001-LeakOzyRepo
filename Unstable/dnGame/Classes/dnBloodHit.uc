/*-----------------------------------------------------------------------------
	dnBloodHit
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class dnBloodHit extends Effects;

auto state StartUp
{
	simulated function Tick(float DeltaTime)
	{
		local vector WallHit, WallNormal;
		local Actor WallActor;
		local dnBloodSplat splat;

		if ( Level.NetMode != NM_DedicatedServer )
		{
			WallActor = Trace(WallHit, WallNormal, Location + 100 * vector(Rotation), Location, false);
			//BroadcastMessage(AngleTo(Location, WallHit + WallNormal));
			if ( WallActor != None )
			{
				splat = spawn(class'dnBloodSplat',,,WallHit + 20 * WallNormal, rotator(WallNormal));
				splat.DrawScale = splat.default.DrawScale * (DrawScale / default.DrawScale);
				splat.Initialize();
			}
		}
		
		Destroy();
	}
}
