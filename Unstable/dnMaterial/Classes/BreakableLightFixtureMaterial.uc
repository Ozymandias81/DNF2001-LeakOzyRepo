//=============================================================================
// BreakableLightFixtureMaterial.	Keith Schuler	Sept 7, 2001
//=============================================================================
class BreakableLightFixtureMaterial expands LightFixtureMaterial;

defaultproperties
{
     DamageCategoryEffect(0)=(HitEffect=Class'dnParticles.dnBulletWallFX_BreakableLightFixtureSpawner',HitSounds[0]=Sound'a_impact.Glass.GlassBreak57a')
     DamageCategoryEffect(1)=(HitEffect=Class'dnParticles.dnBulletWallFX_BreakableLightFixtureSpawner')
     DamageCategoryEffect(2)=(HitEffect=Class'dnParticles.dnBulletWallFX_BreakableLightFixtureSpawner')
     DamageCategoryEffect(8)=(HitEffect=Class'dnParticles.dnBulletWallFX_BreakableLightFixtureSpawner')
     TriggerSurfEventOnHit=True
}
