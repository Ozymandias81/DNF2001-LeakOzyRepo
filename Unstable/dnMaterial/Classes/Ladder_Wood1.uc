//=============================================================================
// Ladder_Wood1.
//=============================================================================
class Ladder_Wood1 expands dnMaterial;

defaultproperties
{
     DamageCategoryEffect(0)=(HitEffect=Class'dnParticles.dnBulletWallFX_WoodSpawner')
     FootstepSounds(0)=Sound'dnsMaterials.Ladder_Wood1.BootClnCem090'
     FootstepSounds(1)=Sound'dnsMaterials.Ladder_Wood1.BootClnCem091'
     FootstepSounds(2)=Sound'dnsMaterials.Ladder_Wood1.BootClnCem108'
     FootstepSounds(3)=Sound'dnsMaterials.Ladder_Wood1.BootClnCem109'
     FootstepSoundsCount=4
     FootstepLandSound=Sound'dnsMaterials.Ladder_Wood1.BootClnCem109'
     bClimbable=True
     bPenetrable=True
}
