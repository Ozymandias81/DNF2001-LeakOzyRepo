//=============================================================================
// dnDropShip_BlackSmoke.				October 12th, 2000 - Charlie Wiederhold
//=============================================================================
class dnDropShip_BlackSmoke expands dnVehicleFX;

// Blue jets that spawn from the EDF drop ship

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=False
     SpawnPeriod=0.050000
     MaximumParticles=36
     Lifetime=2.000000
     InitialVelocity=(X=48.000000,Y=256.000000,Z=256.000000)
     InitialAcceleration=(Y=128.000000)
     MaxVelocityVariance=(X=32.000000,Y=32.000000,Z=64.000000)
     MaxAccelerationVariance=(Z=128.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_generic.Smoke.gensmoke5aRC'
     DrawScaleVariance=4.000000
     StartDrawScale=0.250000
     EndDrawScale=2.000000
     RotationVariance=65535.000000
     RotationVelocity=0.500000
     UpdateWhenNotVisible=True
     Style=STY_Modulated
     bUnlit=True
     VisibilityRadius=65535.000000
     VisibilityHeight=4096.000000
     CollisionRadius=4.000000
     CollisionHeight=4.000000
}
