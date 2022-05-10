//=============================================================================
// dnBloodFX_BloodTrail. 						Feb. 15th 2001 - Charlie Wiederhold
//=============================================================================
class dnBloodFX_BloodTrail expands dnBloodFX;

// Trail of blood that flies off of Gibs

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=True
     DestroyWhenEmpty=False
     DestroyWhenEmptyAfterSpawn=True
     AdditionalSpawn(0)=(SpawnClass=None)
     SpawnNumber=1
     SpawnPeriod=0.032500
     PrimeCount=0
     MaximumParticles=0
     Lifetime=1.000000
     LifetimeVariance=0.250000
     InitialVelocity=(Z=-48.000000)
     MaxVelocityVariance=(X=32.000000,Y=32.000000,Z=24.000000)
     DrawScaleVariance=0.350000
     StartDrawScale=0.100000
     EndDrawScale=0.575000
     TriggerAfterSeconds=2.000000
     TriggerType=SPT_Disable
     SystemAlphaScaleVelocity=-0.500000
     AlphaStart=0.750000
     AlphaMid=0.750000
     bUseAlphaRamp=True
}
