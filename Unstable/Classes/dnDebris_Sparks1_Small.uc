//=============================================================================
// dnDebris_Sparks1_Small.	Keith Schuler Oct 25, 2000
// Smaller spark spray. The regular one was too big for my purposes.
// Used by dnSparkEffect_Spawner3
//=============================================================================
class dnDebris_Sparks1_Small expands dnDebris_Sparks1;

defaultproperties
{
     PrimeCount=20
     MaximumParticles=20
     InitialVelocity=(Z=192.000000)
     MaxVelocityVariance=(X=450.000000,Y=450.000000,Z=192.000000)
     LineStartWidth=1.100000
     LineEndWidth=1.100000
     StartDrawScale=4.000000
     EndDrawScale=8.000000
     CollisionRadius=8.000000
     CollisionHeight=8.000000
}
