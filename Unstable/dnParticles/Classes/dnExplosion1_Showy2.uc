//=============================================================================
// dnExplosion1_Showy2.
//=============================================================================
class dnExplosion1_Showy2 expands dnExplosion1;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx
#exec OBJ LOAD FILE=..\Textures\t_explosionFx.dtx

defaultproperties
{
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnExplosion1_Effect5')
     AdditionalSpawn(1)=(SpawnClass=Class'dnParticles.dnSparkEffect_Effect2_Small')
     AdditionalSpawn(2)=(SpawnClass=Class'dnParticles.dnSparkEffect_Streamer2',SpawnRotationVariance=(Pitch=8000,Yaw=8000,Roll=8000),SpawnSpeed=1000.000000,SpawnSpeedVariance=200.000000)
     AdditionalSpawn(3)=(SpawnClass=Class'dnParticles.dnSparkEffect_Streamer2',SpawnRotationVariance=(Pitch=8000,Yaw=8000,Roll=8000),SpawnSpeed=800.000000,SpawnSpeedVariance=200.000000)
     AdditionalSpawn(4)=(SpawnClass=None)
     CreationSound=None
     Textures(0)=Texture't_generic.LensFlares.subtle_flare6BC'
     StartDrawScale=3.000000
}
