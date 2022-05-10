//=============================================================================
// Ladder_Metal1.
//=============================================================================
class Ladder_Metal1 expands dnMaterial;

defaultproperties
{
     DamageCategoryEffect(0)=(HitEffect=Class'dnParticles.dnBulletWallFX_MetalSpawners')
     FootstepSounds(0)=Sound'dnsMaterials.Ladder_Metal.LthrMtlDamp79'
     FootstepSounds(1)=Sound'dnsMaterials.Ladder_Metal.LthrMtlDamp80'
     FootstepSounds(2)=Sound'dnsMaterials.Ladder_Metal.LthrMtlDamp87'
     FootstepSounds(3)=Sound'dnsMaterials.Ladder_Metal.LthrMtlDamp88'
     FootstepSoundsCount=4
     FootstepLandSound=Sound'dnsMaterials.Metal_1.LthrMtlDamp23'
     bClimbable=True
     bPenetrable=True
}
