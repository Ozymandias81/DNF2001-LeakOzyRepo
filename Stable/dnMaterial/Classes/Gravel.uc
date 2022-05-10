//=============================================================================
// Gravel.
//=============================================================================
class Gravel expands dnMaterial;

defaultproperties
{
     DamageCategoryEffect(0)=(HitEffect=Class'dnParticles.dnBulletWallFX_GravelSpawner')
     FootstepSounds(0)=Sound'dnsMaterials.Gravel.FtStepGen0668'
     FootstepSounds(1)=Sound'dnsMaterials.Gravel.FtStepGen0660'
     FootstepSounds(2)=Sound'dnsMaterials.Gravel.FtStepGen0667'
     FootstepSounds(3)=Sound'dnsMaterials.Gravel.FtStepGen0680'
     FootstepSoundsCount=4
     FootstepLandSound=Sound'dnsMaterials.Dirt.LeatherDirt32'
     bBurrowableStone=True
}
