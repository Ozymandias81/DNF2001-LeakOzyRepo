//=============================================================================
// dnGrenadeFX_Explosion_SparkStreamer_Smoke. 
// June 30th, 2001 - Charlie Wiederhold
//=============================================================================
class dnGrenadeFX_Explosion_SparkStreamer_Smoke expands dnGrenadeFX;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     DestroyWhenEmptyAfterSpawn=True
     AdditionalSpawn(0)=(TakeParentTag=True,Mount=True)
     SpawnPeriod=0.032500
     PrimeCount=1
     PrimeTimeIncrement=0.010000
     Lifetime=2.000000
     LifetimeVariance=0.500000
     RelativeSpawn=True
     SmoothSpawn=True
     InitialVelocity=(X=32.000000,Z=0.000000)
     InitialAcceleration=(Z=16.000000)
     MaxVelocityVariance=(X=16.000000,Y=16.000000,Z=16.000000)
     UseZoneGravity=False
     Textures(0)=Texture't_generic.Smoke.gensmoke1dRC'
     StartDrawScale=0.250000
     EndDrawScale=0.500000
     RotationVariance=65535.000000
     RotationVelocityMaxVariance=1.000000
     UpdateWhenNotVisible=True
     TriggerOnDismount=True
     TriggerAfterSeconds=0.750000
     TriggerType=SPT_Disable
     PulseSeconds=0.750000
     SystemAlphaScaleVelocity=-0.325000
     AlphaMid=1.000000
     AlphaEnd=0.000000
     AlphaRampMid=0.750000
     bUseAlphaRamp=True
     CollisionRadius=1.000000
     CollisionHeight=1.000000
     bCollideWorld=True
     bMeshLowerByCollision=False
     Physics=PHYS_Falling
     Style=STY_Modulated
     bUnlit=True
     bIgnoreBList=True
}
