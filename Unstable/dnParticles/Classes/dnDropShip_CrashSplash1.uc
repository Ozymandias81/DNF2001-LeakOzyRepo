//=============================================================================
// dnDropShip_CrashSplash1. 			October 19th, 2000 - Charlie Wiederhold
//=============================================================================
class dnDropShip_CrashSplash1 expands dnVehicleFX;

// Splash effect when the drop ship crashes into the water.

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=False
     SpawnNumber=8
     Lifetime=2.000000
     SpawnAtRadius=True
     InitialVelocity=(Y=2048.000000,Z=256.000000)
     MaxVelocityVariance=(X=128.000000,Y=128.000000,Z=256.000000)
     MaxAccelerationVariance=(Y=256.000000)
     Textures(0)=Texture't_generic.WaterImpact.waterimpact2bRC'
     DrawScaleVariance=8.000000
     StartDrawScale=4.000000
     EndDrawScale=6.000000
     AlphaStart=0.250000
     AlphaEnd=0.000000
     UpdateWhenNotVisible=True
     TriggerType=SPT_Pulse
     PulseSeconds=0.500000
     Style=STY_Translucent
     bUnlit=True
     VisibilityRadius=65535.000000
     VisibilityHeight=2048.000000
     CollisionRadius=256.000000
     CollisionHeight=0.000000
}
