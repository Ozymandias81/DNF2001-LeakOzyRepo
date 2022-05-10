//=============================================================================
// dnBloodFX_BloodChunksBulletImpact. 		Feb 24th, 2001 - Charlie Wiederhold
//=============================================================================
class dnBloodFX_BloodChunksBulletImpact expands dnBloodFX_BloodChunks;

// Splash of bloody chunks when a person is shot

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     PrimeCount=8
     MaximumParticles=8
     RelativeSpawn=True
     InitialVelocity=(X=-128.000000,Z=96.000000)
     MaxVelocityVariance=(X=48.000000,Y=96.000000,Z=96.000000)
     DrawScaleVariance=0.012500
     StartDrawScale=0.012500
     EndDrawScale=0.012500
     RotationVelocityMaxVariance=0.000000
     SpawnOnBounceChance=0.000000
     SpawnOnBounce=None
     CollisionRadius=0.000000
     CollisionHeight=0.000000
}
