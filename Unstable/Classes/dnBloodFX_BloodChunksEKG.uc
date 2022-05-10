//=============================================================================
// dnBloodFX_BloodChunksEKG.			 January 4th, 2001 - Charlie Wiederhold
//=============================================================================
class dnBloodFX_BloodChunksEKG expands dnBloodFX_BloodChunks;

// Gibby goodness, standard amount. EKG MODE!!!!!

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     PrimeCount=128
     MaximumParticles=128
     Lifetime=1.250000
     InitialVelocity=(Z=384.000000)
     MaxVelocityVariance=(X=768.000000,Y=768.000000,Z=384.000000)
     StartDrawScale=0.075000
     EndDrawScale=0.075000
}
