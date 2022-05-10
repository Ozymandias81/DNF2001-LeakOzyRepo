//=============================================================================
// LightFixtureMaterial.	Keith Schuler	Sept 07, 2001
//=============================================================================
class LightFixtureMaterial expands dnMaterial;

defaultproperties
{
     DamageCategoryEffect(0)=(HitEffect=Class'dnParticles.dnBulletWallFX_LightFixtureSpawner')
     DamageCategoryEffect(1)=(HitEffect=Class'dnParticles.dnBulletWallFX_LightFixtureSpawner')
     DamageCategoryEffect(2)=(HitEffect=Class'dnParticles.dnBulletWallFX_LightFixtureSpawner')
     DamageCategoryEffect(8)=(HitEffect=Class'dnParticles.dnBulletWallFX_LightFixtureSpawner')
     FootstepSounds(0)=Sound'dnsMaterials.Mud_Squishy.LeatherMud14'
     FootstepSoundsCount=1
     FootstepLandSound=Sound'dnsMaterials.Mud_Squishy.LeatherMud79l'
}
