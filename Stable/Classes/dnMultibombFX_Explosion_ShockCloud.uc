//=============================================================================
// dnMultibombFX_Explosion_ShockCloud.				June 28th, 2001 - Charlie Wiederhold
//=============================================================================
class dnMultibombFX_Explosion_ShockCloud expands dnMultibombFX;

#exec OBJ LOAD FILE=..\Textures\t_firefx.dtx

defaultproperties
{
     bIgnoreBList=True
     Enabled=False
     DestroyWhenEmptyAfterSpawn=True
     SpawnNumber=0
     SpawnPeriod=0.000000
     PrimeCount=32
     MaximumParticles=32
     Lifetime=0.600000
     LifetimeVariance=0.20000
     SpawnAtRadius=True
     RelativeLocation=True
     InitialVelocity=(Z=0.000000)
     InitialAcceleration=(Z=16.000000)
     MaxVelocityVariance=(X=32.000000,Y=32.000000,Z=16.000000)
     ApexInitialVelocity=320.000000
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_generic.Smoke.gensmoke1cRC'
     StartDrawScale=0.25000000
     EndDrawScale=1.00000
     RotationVariance=65535.000000
     RotationVelocityMaxVariance=2.000000
     UpdateWhenNotVisible=True
     TriggerType=SPT_None
     AlphaMid=0.750000
     AlphaEnd=0.000000
     AlphaRampMid=0.750000
     bUseAlphaRamp=True
     CollisionRadius=4.000000
     CollisionHeight=0.000000
     Style=STY_Translucent
     bUnlit=True
}
