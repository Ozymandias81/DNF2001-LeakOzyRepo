//=============================================================================
// Glass.
//=============================================================================
class Glass expands dnMaterial;

defaultproperties
{
     DamageCategoryEffect(0)=(HitEffect=Class'dnParticles.dnBulletWallFX_GlassSpawner')
     FootstepSounds(0)=Sound'dnsMaterials.Floor_Hard.FtStepGen0115'
     FootstepSounds(1)=Sound'dnsMaterials.Floor_Hard.FtStepGen0112'
     FootstepSounds(2)=Sound'dnsMaterials.Floor_Hard.FtStepGen0113'
     FootstepSounds(3)=Sound'dnsMaterials.Floor_Hard.FtStepGen0114'
     FootstepSoundsCount=4
     FootstepLandSound=Sound'dnsMaterials.Floor_Hard.FtStepGen0114'     
     bPenetrable=True
}
