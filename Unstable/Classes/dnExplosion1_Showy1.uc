//=============================================================================
// dnExplosion1_Showy1.	Keith Schuler
// Class for cinematic, spectacular explosions
// This is the one you spawn, it takes care of the rest.
//=============================================================================
class dnExplosion1_Showy1 expands dnExplosion1;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx
#exec OBJ LOAD FILE=..\Textures\t_explosionFx.dtx

defaultproperties
{
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnExplosion1_ShowyEffect1')
     AdditionalSpawn(2)=(SpawnClass=Class'dnParticles.dnSparkEffect_Effect2')
     AdditionalSpawn(5)=(SpawnClass=Class'dnParticles.dnSparkEffect_Streamer',SpawnRotationVariance=(Pitch=16834,Yaw=16834,Roll=16834),SpawnSpeed=800.000000,SpawnSpeedVariance=200.000000)
     AdditionalSpawn(6)=(SpawnClass=Class'dnParticles.dnSparkEffect_Streamer',SpawnRotationVariance=(Pitch=-16384,Yaw=-16384,Roll=-16384),SpawnSpeed=800.000000,SpawnSpeedVariance=200.000000)
     AdditionalSpawn(7)=(SpawnClass=Class'dnParticles.dnSparkEffect_Streamer',SpawnRotationVariance=(Pitch=65535,Yaw=65535,Roll=65535),SpawnSpeed=800.000000,SpawnSpeedVariance=200.000000)
}
