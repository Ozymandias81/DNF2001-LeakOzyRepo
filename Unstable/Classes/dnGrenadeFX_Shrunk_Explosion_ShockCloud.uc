//=============================================================================
// dnGrenadeFX_Shrunk_Explosion_ShockCloud.				June 28th, 2001 - Charlie Wiederhold
//=============================================================================
class dnGrenadeFX_Shrunk_Explosion_ShockCloud expands dnGrenadeFX_Shrunk;

#exec OBJ LOAD FILE=..\Textures\t_firefx.dtx

defaultproperties
{
     Enabled=False
     DestroyWhenEmptyAfterSpawn=True
     SpawnNumber=0
     SpawnPeriod=0.000000
     PrimeCount=32
     MaximumParticles=32
     Lifetime=0.600000
     LifetimeVariance=0.200000
     SpawnAtRadius=True
     InitialVelocity=(Z=0.000000)
     InitialAcceleration=(Z=4.000000)
     MaxVelocityVariance=(X=8.000000,Y=8.000000,Z=8.000000)
     ApexInitialVelocity=128.000000
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_generic.Smoke.gensmoke1cRC'
     StartDrawScale=0.06250000
     EndDrawScale=0.250000
     RotationVariance=65535.000000
     RotationVelocityMaxVariance=2.000000
     UpdateWhenNotVisible=True
     TriggerType=SPT_None
     AlphaMid=0.750000
     AlphaEnd=0.000000
     AlphaRampMid=0.750000
     bUseAlphaRamp=True
     CollisionRadius=1.000000
     CollisionHeight=0.000000
     Style=STY_Translucent
     bUnlit=True
     bIgnoreBList=True
}
