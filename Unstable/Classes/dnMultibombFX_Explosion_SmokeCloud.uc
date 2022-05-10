//=============================================================================
// dnMultibombFX_Explosion_SmokeCloud.							June 28th, 2001 - Charlie Wiederhold
//=============================================================================
class dnMultibombFX_Explosion_SmokeCloud expands dnMultibombFX;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx
#exec OBJ LOAD FILE=..\Textures\t_explosionFx.dtx

defaultproperties
{
     UpdateWhenNotVisible=True
     bIgnoreBList=True
     DestroyWhenEmpty=True
     SpawnNumber=0
     SpawnPeriod=0.000000
     PrimeCount=6
     Lifetime=6.000000
     LifetimeVariance=1.000000
     InitialVelocity=(X=0.000000,Y=0.000000,Z=16.000000)
     MaxVelocityVariance=(X=60.000000,Y=60.000000,Z=24.000000)
     Textures(0)=Texture't_generic.Smoke.gensmoke1dRC'
     StartDrawScale=1.000000
     EndDrawScale=2.500000
     DrawScaleVariance=0.500000
     AlphaEnd=0.000000
     RotationVariance=65535.000000
     RotationVelocityMaxVariance=0.750000
     CollisionRadius=48.000000
     CollisionHeight=32.000000
     UseZoneGravity=False
     UseZoneVelocity=False
     Style=STY_Translucent
     bUnlit=True
     bIgnoreBList=True
}
