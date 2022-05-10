//=============================================================================
// dnDebris_Glass3.	Keith Schuler	March 28, 2001
// Same as the Glass1 class, but with bigger particles
// Used for breaking window in the penthouse bedroom
//=============================================================================
class dnDebris_Glass3 expands dnDebris_Glass1;

// The root class was changed so it may have broken this class.
// June 28th, 2001 - Charlie Wiederhold

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     PrimeCount=25
     MaximumParticles=25
     InitialVelocity=(Z=0.000000)
     LocalFriction=256.000000
     Bounce=False
     ParticlesCollideWithWorld=False
     DrawScaleVariance=0.200000
     StartDrawScale=0.250000
     EndDrawScale=0.250000
     TimeWarp=0.750000
}
