//=============================================================================
// dnExplosion1_PostSmoke. 				January 25th, 2001 - Charlie Wiederhold
//=============================================================================
class dnExplosion1_PostSmoke expands dnExplosion1;

// Smoke effect class.
// Does not do damage. 
// Smoke plume that shows up after an explosion.

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx
#exec OBJ LOAD FILE=..\Textures\t_explosionFx.dtx
#exec OBJ LOAD FILE=..\sounds\a_impact.dfx

defaultproperties
{
     Enabled=True
     DestroyWhenEmpty=False
     DestroyWhenEmptyAfterSpawn=True
     AdditionalSpawn(0)=(SpawnClass=None)
     AdditionalSpawn(1)=(SpawnClass=None)
     AdditionalSpawn(2)=(SpawnClass=None)
     AdditionalSpawn(3)=(SpawnClass=None)
     AdditionalSpawn(4)=(SpawnClass=None)
     AdditionalSpawnTakesOwner=False
     CreationSound=None
     SpawnNumber=1
     SpawnPeriod=0.100000
     PrimeCount=0
     PrimeTimeIncrement=0.000000
     MaximumParticles=16
     Lifetime=2.000000
     LifetimeVariance=1.000000
     InitialVelocity=(Z=128.000000)
     MaxVelocityVariance=(X=64.000000,Y=64.000000,Z=32.000000)
     Textures(0)=Texture't_generic.Smoke.gensmoke1dRC'
     Textures(1)=Texture't_generic.Smoke.gensmoke1cRC'
     DrawScaleVariance=0.500000
     StartDrawScale=0.250000
     EndDrawScale=1.500000
     AlphaEnd=0.000000
     RotationVariance=65534.000000
     SystemAlphaScaleVelocity=-0.250000
     TriggerAfterSeconds=4.000000
     TriggerType=SPT_Disable
     PulseSeconds=0.000000
     DamageRadius=0.000000
     MomentumTransfer=0.000000
}
