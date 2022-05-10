//=============================================================================
// dnRocketFX_Shrunk_Explosion_Glow. 							August 8th, 2001 - Charlie Wiederhold
//=============================================================================
class dnRocketFX_Shrunk_Explosion_Glow expands dnRocketFX_Shrunk;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
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
     StartDrawScale=0.875000
     EndDrawScale=0.875000
     RotationVariance=65535.000000
     UpdateWhenNotVisible=True
     SystemAlphaScale=0.000000
     SystemAlphaScaleVelocity=0.750000
     AlphaStart=0.375000
     AlphaMid=0.375000
     AlphaEnd=0.000000
     AlphaRampMid=0.850000
     bUseAlphaRamp=True
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     Style=STY_Translucent
     bUnlit=True
     bIgnoreBList=True
}
