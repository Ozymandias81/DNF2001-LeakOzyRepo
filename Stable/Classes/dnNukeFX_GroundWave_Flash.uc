//=============================================================================
// dnNukeFX_GroundWave_Flash.				June 5th, 2001 - Charlie Wiederhold
//=============================================================================
class dnNukeFX_GroundWave_Flash expands dnNukeFX;

#exec OBJ LOAD FILE=..\Textures\t_firefx.dtx

defaultproperties
{
     bIgnoreBList=True
     Enabled=False
     DestroyWhenEmptyAfterSpawn=True
     SpawnNumber=0
     SpawnPeriod=0.000000
     PrimeCount=64
     MaximumParticles=64
     Lifetime=1.500000
     LifetimeVariance=1.50000
     SpawnAtRadius=True
     RelativeLocation=True
     InitialVelocity=(Z=0.000000)
     InitialAcceleration=(Z=16.000000)
     MaxVelocityVariance=(X=128.000000,Y=128.000000,Z=16.000000)
     ApexInitialVelocity=768.000000
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_generic.Smoke.gensmoke1dRC'
     EndDrawScale=4.000000
     RotationVariance=65535.000000
     RotationVelocityMaxVariance=2.000000
     UpdateWhenNotVisible=True
     TriggerAfterSeconds=2.000000
     TriggerType=SPT_Disable
     PulseSeconds=0.750000
     AlphaMid=1.000000
     AlphaEnd=0.000000
     AlphaRampMid=0.750000
     bUseAlphaRamp=True
     CollisionRadius=16.000000
     CollisionHeight=0.000000
     Style=STY_Translucent
     bUnlit=True
}
