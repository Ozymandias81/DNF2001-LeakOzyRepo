//=============================================================================
// dnEMPFX_Spawner1.					October 10th, 2000 - Charlie Wiederhold
//=============================================================================
class dnEMPFX_Spawner1 expands dnEMPFX;

// EMP Flash Effect
// Does NOT do damage. 
// Spawns the quick flash when an object is disabled by an EMP

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnDebris_SmokeSubtle')
     Textures(0)=Texture't_generic.particle_efx.pflare3'
     StartDrawScale=10.000000
     EndDrawScale=0.100000
     RotationVariance=0.000000
}
