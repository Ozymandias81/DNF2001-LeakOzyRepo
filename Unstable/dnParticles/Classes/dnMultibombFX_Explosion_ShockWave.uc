//=============================================================================
// dnMultibombFX_Explosion_ShockWave. 							June 28th, 2001 - Charlie Wiederhold
//=============================================================================
class dnMultibombFX_Explosion_ShockWave expands dnMultibombFX;

#exec OBJ LOAD FILE=..\Textures\afbproship.dtx

defaultproperties
{
     bIgnoreBList=True
     Enabled=False
     DestroyWhenEmptyAfterSpawn=True
     SpawnNumber=0
     SpawnPeriod=0.000000
     PrimeCount=1
     MaximumParticles=1
     Lifetime=0.275000
     InitialVelocity=(Z=0.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture'afbproship.WMD.shockwavetw'
     StartDrawScale=0.000000
     EndDrawScale=6.000000
     RotationVariance=65535.000000
     UpdateWhenNotVisible=True
     AlphaStart=0.500000
     AlphaMid=0.500000
     AlphaEnd=0.000000
     AlphaRampMid=0.750000
     bUseAlphaRamp=True
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     Style=STY_Translucent
     bUnlit=True
}
