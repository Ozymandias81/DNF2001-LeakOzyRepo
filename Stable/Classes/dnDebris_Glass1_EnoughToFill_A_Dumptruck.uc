//=============================================================================
// dnDebris_Glass1_EnoughToFill_A_Dumptruck.	September 20th, 2000 - Charlie Wiederhold
//=============================================================================
class dnDebris_Glass1_EnoughToFill_A_Dumptruck expands dnDebris_Glass1;

// Enough Glass To Fill A Dumptruck... just for Telamon.

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     PrimeCount=1024
     MaximumParticles=1024
     Lifetime=2.500000
     InitialVelocity=(Z=256.000000)
     MaxVelocityVariance=(X=512.000000,Y=512.000000,Z=384.000000)
}
