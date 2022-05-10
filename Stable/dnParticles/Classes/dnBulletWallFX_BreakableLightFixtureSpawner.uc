//=============================================================================
// dnBulletWallFX_BreakableLightFixtureSpawner.	Keith Schuler	Sept 7, 2001
//=============================================================================
class dnBulletWallFX_BreakableLightFixtureSpawner expands dnBulletWallFX_LightFixtureSpawner;

defaultproperties
{
     AdditionalSpawn(1)=(SpawnClass=Class'dnParticles.dnDebris_Glass1')
     AdditionalSpawn(2)=(SpawnClass=Class'dnParticles.dnWallSpark')
     AdditionalSpawn(3)=(SpawnClass=Class'dnParticles.dnDebris_Sparks1')
     AdditionalSpawn(4)=(SpawnClass=Class'dnParticles.dnDebrisMesh_Glass1')
     AdditionalSpawn(5)=(SpawnClass=Class'dnParticles.dnDebrisMesh_Glass1b')
     AdditionalSpawn(6)=(SpawnClass=Class'dnParticles.dnDebrisMesh_Glass1c')
     AdditionalSpawn(7)=(SpawnClass=Class'dnParticles.dnExplosion3_SElec_Spawner2')
}
