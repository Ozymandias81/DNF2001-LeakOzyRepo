//=============================================================================
// Ladder_Wood2.
//=============================================================================
class Ladder_Wood2 expands dnMaterial;

defaultproperties
{
     DamageCategoryEffect(0)=(HitEffect=Class'dnParticles.dnBulletWallFX_WoodSpawner')
     FootstepSounds(0)=Sound'dnsMaterials.Ladder_Wood2.BootPaWod130'
     FootstepSounds(1)=Sound'dnsMaterials.Ladder_Wood2.BootPaWod132'
     FootstepSounds(2)=Sound'dnsMaterials.Ladder_Wood2.BootPaWod133'
     FootstepSounds(3)=Sound'dnsMaterials.Ladder_Wood2.BootPaWod134'
     FootstepSoundsCount=4
     FootstepLandSound=Sound'dnsMaterials.Ladder_Wood2.BootPaWod132'
     bClimbable=True
     bPenetrable=True
}
