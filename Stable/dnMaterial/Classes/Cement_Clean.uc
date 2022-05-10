//=============================================================================
// Cement_Clean.
//=============================================================================
class Cement_Clean expands dnMaterial;

defaultproperties
{
     DamageCategoryEffect(0)=(HitEffect=Class'dnParticles.dnBulletWallFX_CementSpawner')
     FootstepSounds(0)=Sound'dnsMaterials.Cement_Clean.BootClnCem046'
     FootstepSounds(1)=Sound'dnsMaterials.Cement_Clean.BootClnCem048'
     FootstepSounds(2)=Sound'dnsMaterials.Cement_Clean.BootClnCem049'
     FootstepSoundsCount=3
     FootstepLandSound=Sound'dnsMaterials.Cement_Clean.BootClnCem128'
     bBurrowableStone=True
}
