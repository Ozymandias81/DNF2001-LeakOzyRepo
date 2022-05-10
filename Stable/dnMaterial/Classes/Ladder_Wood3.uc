//=============================================================================
// Ladder_Wood3.
//=============================================================================
class Ladder_Wood3 expands dnMaterial;

defaultproperties
{
     DamageCategoryEffect(0)=(HitEffect=Class'dnParticles.dnBulletWallFX_WoodSpawner')
     FootstepSounds(0)=Sound'dnsMaterials.Ladder_Wood3.BootSftWod108'
     FootstepSounds(1)=Sound'dnsMaterials.Ladder_Wood3.BootSftWod113'
     FootstepSounds(2)=Sound'dnsMaterials.Ladder_Wood3.BootSftWod114'
     FootstepSounds(3)=Sound'dnsMaterials.Ladder_Wood3.BootSftWod115'
     FootstepSoundsCount=4
     FootstepLandSound=Sound'dnsMaterials.Ladder_Wood3.BootSftWod108'
     bClimbable=True
     bPenetrable=True
}
