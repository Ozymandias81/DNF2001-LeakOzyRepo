//=============================================================================
// dnRocketFX_Shrunk_Explosion_SparkStreamer_Smoke. 
// August 8th, 2001 - Charlie Wiederhold
//=============================================================================
class dnRocketFX_Shrunk_Explosion_SparkStreamer_Smoke expands dnRocketFX_Shrunk;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     DestroyWhenEmptyAfterSpawn=True
     AdditionalSpawn(0)=(TakeParentTag=True,Mount=True)
     SpawnPeriod=0.032500
     PrimeCount=1
     PrimeTimeIncrement=0.010000
     Lifetime=2.00000
     LifetimeVariance=0.500000
     RelativeSpawn=True
     InitialVelocity=(X=8.000000,Z=0.000000)
     InitialAcceleration=(Z=4.000000)
     MaxVelocityVariance=(X=4.000000,Y=4.000000,Z=4.000000)
     UseZoneGravity=False
     Textures(0)=Texture't_generic.Smoke.gensmoke1dRC'
     StartDrawScale=0.0750000
     EndDrawScale=0.150000
     RotationVariance=65535.000000
     RotationVelocityMaxVariance=1.000000
     UpdateWhenNotVisible=True
     TriggerAfterSeconds=0.750000
     TriggerOnDismount=True
     TriggerType=SPT_Disable
     PulseSeconds=0.750000
     SystemAlphaScaleVelocity=-0.32500000
     AlphaMid=1.000000
     AlphaEnd=0.000000
     AlphaRampMid=0.750000
     bUseAlphaRamp=True
     CollisionRadius=0.25000000
     CollisionHeight=0.25000000
     bCollideWorld=True
     bMeshLowerByCollision=False
     Physics=PHYS_Falling
     Style=STY_Modulated
     bUnlit=True
     bIgnoreBList=True
}
