//=============================================================================
// dnBulletWallFX_LightFixtureSpawner.	Keith Schuler	Sept 7, 2001
//=============================================================================
class dnBulletWallFX_LightFixtureSpawner expands dnBulletFX_LightFixtureSpawner;

defaultproperties
{
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnWallGlass')
     AdditionalSpawn(1)=(SpawnClass=Class'dnParticles.dnWallSpark')
     CreationSound=Sound'a_impact.Bullet.ImpBGlass05'
}
