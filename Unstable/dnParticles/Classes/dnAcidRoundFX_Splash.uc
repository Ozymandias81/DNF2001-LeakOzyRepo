//=============================================================================
// dnAcidRoundFX_Splash.            Created by Charlie Wiederhold June 19, 2000
//=============================================================================
class dnAcidRoundFX_Splash expands dnAcidRoundFX;

// Shotgun acid round effect.
// Does NOT do damage. 
// Spawns an individual acid round impact splash.

defaultproperties
{
	 AdditionalSpawn(0)=(SpawnClass=None)
     SpawnPeriod=0.100000
     MaximumParticles=2
     Lifetime=0.400000
     InitialVelocity=(X=0.000000,Z=0.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000,Z=0.000000)
     MaxAccelerationVariance=(Z=0.000000)
     LineStartColor=(R=32,G=64)
     LineEndColor=(R=32,G=64)
     Textures(0)=Texture't_generic.WaterImpact.waterimpact4cRC'
     StartDrawScale=0.000000
     EndDrawScale=0.500000
     TriggerOnSpawn=False
     TriggerType=SPT_None
     PulseSeconds=0.100000
}
