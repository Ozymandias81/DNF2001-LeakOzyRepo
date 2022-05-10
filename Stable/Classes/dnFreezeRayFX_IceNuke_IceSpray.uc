//=============================================================================
// dnFreezeRayFX_IceNuke_IceSpray. 			May 28th, 2001 - Charlie Wiederhold
//=============================================================================
class dnFreezeRayFX_IceNuke_IceSpray expands dnFreezeRayFX;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     DestroyWhenEmptyAfterSpawn=True
     SpawnNumber=0
     SpawnPeriod=0.000000
     PrimeCount=8
     MaximumParticles=8
     Lifetime=0.750000
     InitialVelocity=(Z=0.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_explosionFx.explosions.iceblast_000'
     DrawScaleVariance=1.000000
     StartDrawScale=1.500000
     EndDrawScale=2.000000
     RotationVariance=65535.000000
     UpdateWhenNotVisible=True
     AlphaMid=1.000000
     AlphaEnd=0.000000
     AlphaRampMid=0.800000
     bUseAlphaRamp=True
     CollisionRadius=64.000000
     CollisionHeight=64.000000
     Style=STY_Translucent
     bUnlit=True
}
