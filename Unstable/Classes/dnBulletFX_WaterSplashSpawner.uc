//=============================================================================
// dnBulletFX_WaterSplashSpawner.
//=============================================================================
class dnBulletFX_WaterSplashSpawner expands dnWallFX_Spawners;

defaultproperties
{
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnWallWaterSplash')
     CreationSound=None
     CreationSounds(0)=Sound'a_impact.Bullet.ImpBWater01'
     CreationSounds(1)=Sound'a_impact.Bullet.ImpBWater03'
}
