//=============================================================================
// dnFreezeRayFX_IceNuke_Flash.				May 28th, 2001 - Charlie Wiederhold
//=============================================================================
class dnFreezeRayFX_IceNuke_Flash expands dnFreezeRayFX;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     DestroyWhenEmpty=True
     SpawnNumber=0
     PrimeCount=1
     MaximumParticles=1
     Lifetime=0.325000
     InitialVelocity=(Z=0.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_generic.particle_efx.pflare2'
     StartDrawScale=48.000000
     EndDrawScale=0.000000
     RotationVariance=65535.000000
     UpdateWhenNotVisible=True
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     Style=STY_Translucent
     bUnlit=True
}
