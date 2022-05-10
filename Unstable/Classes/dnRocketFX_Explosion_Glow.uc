//=============================================================================
// dnRocketFX_Explosion_Glow. 							June 28th, 2001 - Charlie Wiederhold
//=============================================================================
class dnRocketFX_Explosion_Glow expands dnRocketFX;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     UpdateWhenNotVisible=True
     bIgnoreBList=True
     Enabled=False
     DestroyWhenEmptyAfterSpawn=True
     SpawnNumber=0
     SpawnPeriod=0.000000
     PrimeCount=1
     MaximumParticles=1
     Lifetime=1.750000
     InitialVelocity=(Z=0.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_generic.LensFlares.subtle_flare6BC'
     StartDrawScale=3.500000
     EndDrawScale=3.500000
     RotationVariance=65535.000000
     SystemAlphaScale=0.000000
     SystemAlphaScaleVelocity=0.750000
     AlphaStart=0.3750000
     AlphaMid=0.3750000
     AlphaEnd=0.000000
     AlphaRampMid=0.850000
     bUseAlphaRamp=True
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     Style=STY_Translucent
     bUnlit=True
}
