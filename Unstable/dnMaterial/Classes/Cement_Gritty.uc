//=============================================================================
// Cement_Gritty.
//=============================================================================
class Cement_Gritty expands dnMaterial;

defaultproperties
{
     DamageCategoryEffect(0)=(HitEffect=Class'dnParticles.dnBulletWallFX_CementSpawner',HitSpawn=Class'U_Generic.BulletHole_Concrt')
     FootstepSounds(0)=Sound'dnsMaterials.Cement_Gritty.BootGrtCem037'
     FootstepSounds(1)=Sound'dnsMaterials.Cement_Gritty.BootGrtCem036'
     FootstepSounds(2)=Sound'dnsMaterials.Cement_Gritty.BootGrtCem031'
     FootstepSounds(3)=Sound'dnsMaterials.Cement_Gritty.BootGrtCem038'
     FootstepSoundsCount=4
     FootstepLandSound=Sound'dnsMaterials.Cement_Gritty.BootGrtCem098'
     bBurrowableStone=True
}
