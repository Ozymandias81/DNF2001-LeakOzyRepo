//=============================================================================
// dnSmokeStackEffect. 					October 20th, 2000 - Charlie Wiederhold
//=============================================================================
class dnSmokeStackEffect expands dnLakeMeadFX;

// Smoke stack effect

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     SpawnNumber=2
     SpawnPeriod=0.200000
     MaximumParticles=32
     Lifetime=3.000000
     InitialVelocity=(X=-256.000000,Y=64.000000,Z=128.000000)
     InitialAcceleration=(Z=64.000000)
     MaxVelocityVariance=(X=128.000000,Y=128.000000,Z=128.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_generic.Smoke.gensmoke1dRC'
     DrawScaleVariance=2.000000
     EndDrawScale=6.000000
     AlphaStart=0.750000
     AlphaEnd=0.000000
     RotationVelocityMaxVariance=0.500000
     UpdateWhenNotVisible=True
     TriggerType=SPT_None
     Style=STY_Translucent
     bUnlit=True
     VisibilityRadius=32768.000000
     VisibilityHeight=4096.000000
     CollisionRadius=64.000000
}
