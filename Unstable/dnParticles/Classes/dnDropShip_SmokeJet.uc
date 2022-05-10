//=============================================================================
// dnDropShip_SmokeJet.					October 12th, 2000 - Charlie Wiederhold
//=============================================================================
class dnDropShip_SmokeJet expands dnVehicleFX;

// Smoke that spawns off the jets when they are destroyed.

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=False
     SpawnPeriod=0.050000
     MaximumParticles=36
     Lifetime=2.000000
     InitialVelocity=(Y=256.000000,Z=256.000000)
     InitialAcceleration=(Y=128.000000)
     MaxVelocityVariance=(X=32.000000,Y=32.000000,Z=64.000000)
     MaxAccelerationVariance=(Z=128.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_generic.Smoke.gensmoke1dRC'
     DrawScaleVariance=3.000000
     StartDrawScale=0.250000
     EndDrawScale=2.000000
     AlphaEnd=0.000000
     RotationVariance=65535.000000
     UpdateWhenNotVisible=True
     TriggerType=SPT_Enable
     PulseSeconds=10.000000
     Style=STY_Translucent
     bUnlit=True
     VisibilityRadius=65535.000000
     VisibilityHeight=4096.000000
     CollisionRadius=4.000000
     CollisionHeight=4.000000
     DestroyOnDismount=True
}
