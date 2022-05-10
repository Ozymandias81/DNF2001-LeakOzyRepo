//=============================================================================
// dnDebris_Sparks1_Large.            September 22nd, 2000 - Charlie Wiederhold

//=============================================================================
class dnDebris_Sparks1_Large expands dnDebris_Sparks1;

// Subclass of the spark debris spawner. Larger shower of the standard sparks.

defaultproperties
{
     PrimeCount=90
     MaximumParticles=90
     Lifetime=1.000000
     InitialVelocity=(Z=384.000000)
     MaxVelocityVariance=(X=950.000000,Y=950.000000,Z=512.000000)
     LineStartWidth=2.500000
     LineEndWidth=2.500000
     StartDrawScale=12.000000
     EndDrawScale=32.000000
}
