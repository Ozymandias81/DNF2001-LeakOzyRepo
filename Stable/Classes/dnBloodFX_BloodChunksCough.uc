//=============================================================================
// dnBloodFX_BloodChunksCough. 			January 16th, 2001 - Charlie Wiederhold
//=============================================================================
class dnBloodFX_BloodChunksCough expands dnBloodFX_BloodChunks;

// Gibby goodness. Dude, he's coughing up blood. Cool!

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=True
     DestroyWhenEmpty=False
     DestroyWhenEmptyAfterSpawn=True
     SpawnNumber=6
     SpawnPeriod=0.010000
     PrimeCount=0
     MaximumParticles=12
     RelativeSpawn=True
     InitialVelocity=(X=72.000000,Z=24.000000)
     MaxVelocityVariance=(X=48.000000,Y=64.000000,Z=64.000000)
     DrawScaleVariance=0.010000
     StartDrawScale=0.010000
     EndDrawScale=0.010000
     SpawnOnBounceChance=0.150000
     TriggerAfterSeconds=0.020000
     TriggerType=SPT_Disable
     PulseSeconds=0.020000
     CollisionRadius=0.000000
     CollisionHeight=0.000000
}
