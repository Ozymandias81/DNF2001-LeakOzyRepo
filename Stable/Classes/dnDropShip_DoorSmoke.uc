//=============================================================================
// dnDropShip_DoorSmoke. 				October 18th, 2000 - Charlie Wiederhold
//=============================================================================
class dnDropShip_DoorSmoke expands dnVehicleFX;

// Smoke that spews out the back of the Drop Ship when the door opens

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=False
     SpawnPeriod=0.050000
     MaximumParticles=32
     Lifetime=1.500000
     InitialVelocity=(Z=-128.000000)
     MaxVelocityVariance=(X=48.000000,Y=48.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_generic.Smoke.gensmoke1dRC'
     StartDrawScale=0.500000
     EndDrawScale=1.250000
     AlphaEnd=0.000000
     RotationVariance=65535.000000
     UpdateWhenNotVisible=True
     TriggerType=SPT_Pulse
     PulseSeconds=2.000000
     Style=STY_Translucent
     bUnlit=True
     VisibilityRadius=65535.000000
     VisibilityHeight=4096.000000
     CollisionRadius=0.000000
     CollisionHeight=0.000000
}
