//=============================================================================
// dnRocketFX_Shrunk_Explosion_SmokeCloud.							August 8th, 2001 - Charlie Wiederhold
//=============================================================================
class dnRocketFX_Shrunk_Explosion_SmokeCloud expands dnRocketFX_Shrunk;

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
     InitialVelocity=(X=0.000000,Y=0.000000,Z=4.000000)
     MaxVelocityVariance=(X=15.000000,Y=15.000000,Z=6.000000)
     Textures(0)=Texture't_generic.Smoke.gensmoke1dRC'
     StartDrawScale=0.250000
     EndDrawScale=0.62500000
     DrawScaleVariance=0.12500000
     AlphaEnd=0.000000
     RotationVariance=65535.000000
     RotationVelocityMaxVariance=0.750000
     CollisionRadius=12.000000
     CollisionHeight=8.000000
     UseZoneGravity=False
     UseZoneVelocity=False
     Style=STY_Translucent
     bUnlit=True
     bIgnoreBList=True
}
