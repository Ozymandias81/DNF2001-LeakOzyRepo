//=============================================================================
// dnFlamethrowerFX_WallFlame_Impact. 		May 31st, 2001 - Charlie Wiederhold
//=============================================================================
class dnFlamethrowerFX_WallFlame_Impact expands dnFlamethrowerFX;

#exec OBJ LOAD FILE=..\Textures\t_firefx.dtx

defaultproperties
{
     bIgnoreBList=True
     Enabled=False
     DestroyWhenEmpty=True
     SpawnNumber=0
     SpawnPeriod=0.000000
     PrimeCount=5
     MaximumParticles=5
     Lifetime=0.750000
     LifetimeVariance=0.250000
     InitialVelocity=(Z=128.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000,Z=64.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_firefx.firespray.flamehotend2RC'
     Textures(1)=Texture't_firefx.firespray.flamehotend1RC'
     DrawScaleVariance=0.250000
     StartDrawScale=0.250000
     EndDrawScale=0.750000
     RotationVariance=65535.000000
     RotationVelocityMaxVariance=2.000000
     UpdateWhenNotVisible=True
     AlphaMid=1.000000
     AlphaEnd=0.000000
     AlphaRampMid=0.750000
     bUseAlphaRamp=True
     CollisionRadius=32.000000
     CollisionHeight=32.000000
     Style=STY_Translucent
     bUnlit=True
}
