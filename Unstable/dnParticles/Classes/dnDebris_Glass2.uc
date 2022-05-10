//=============================================================================
// dnDebris_Glass2.	Keith Schuler	March 27, 2001
// Glass flying in the specified direction
// Pretty big chunks, used for shooting the window in Duke's penthouse
//=============================================================================
class dnDebris_Glass2 expands dnDebris_Glass1;

// The root class was changed so it may have broken this class.
// June 28th, 2001 - Charlie Wiederhold

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     PrimeCount=12
     MaximumParticles=12
     Lifetime=0.125000
     LifetimeVariance=0.062500
     RelativeLocation=True
     RelativeRotation=True
     InitialVelocity=(X=1500.000000,Z=0.000000)
     MaxVelocityVariance=(X=512.000000,Y=512.000000,Z=512.000000)
     Bounce=False
     ParticlesCollideWithWorld=False
     DrawScaleVariance=0.200000
     StartDrawScale=0.250000
     EndDrawScale=0.250000
}
