//=============================================================================
// dnDropShip_FireJet.					October 12th, 2000 - Charlie Wiederhold
//=============================================================================
class dnDropShip_FireJet expands dnVehicleFX;

// Fire that spawns off the jets when they are destroyed.

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=False
     DestroyWhenEmptyAfterSpawn=True
     SpawnPeriod=0.075000
     MaximumParticles=10
     Lifetime=0.000000
     InitialVelocity=(Y=64.000000,Z=192.000000)
     InitialAcceleration=(Y=64.000000)
     MaxVelocityVariance=(X=64.000000,Y=64.000000,Z=64.000000)
     MaxAccelerationVariance=(Z=96.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_generic.fireflames.flame1aRC'
     DieOnLastFrame=True
     StartDrawScale=2.000000
     EndDrawScale=2.500000
     UpdateWhenNotVisible=True
     TriggerType=SPT_Pulse
     PulseSeconds=10.000000
     AlphaStart=0.500000
     AlphaEnd=0.000000
     VisibilityRadius=65535.000000
     VisibilityHeight=4096.000000
     bBurning=True
     CollisionRadius=64.000000
     CollisionHeight=0.000000
     DestroyOnDismount=True
     Style=STY_Translucent
     bUnlit=True
     DrawScale=2.000000
}
