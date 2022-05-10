//=============================================================================
// dnBloodFX_BloodChunksSmall.			 January 4th, 2001 - Charlie Wiederhold
//=============================================================================
class dnBloodFX_BloodChunksSmall expands dnBloodFX_BloodChunks;

// Small gibs for blowing a limb off and such.

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     PrimeCount=16
     MaximumParticles=16
     Lifetime=0.325000
     LifetimeVariance=0.125000
     InitialVelocity=(Z=144.000000)
     MaxVelocityVariance=(X=128.000000,Y=128.000000,Z=128.000000)
     DrawScaleVariance=0.025000
     StartDrawScale=0.020000
     EndDrawScale=0.020000
     RotationVelocityMaxVariance=0.000000
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     TimeWarp=0.500000
}
