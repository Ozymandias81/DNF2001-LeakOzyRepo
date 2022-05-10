//=============================================================================
// Wood_Soft.
//=============================================================================
class Wood_Soft expands dnMaterial;

defaultproperties
{
     DamageCategoryEffect(0)=(HitEffect=Class'dnParticles.dnBulletWallFX_WoodSpawner')
     FootstepSounds(0)=Sound'dnsMaterials.Wood_Soft.BootSftWod019'
     FootstepSounds(1)=Sound'dnsMaterials.Wood_Soft.BootSftWod022'
     FootstepSounds(2)=Sound'dnsMaterials.Wood_Soft.BootSftWod023'
     FootstepSounds(3)=Sound'dnsMaterials.Wood_Soft.BootSftWod027'
     FootstepSoundsCount=4
     FootstepLandSound=Sound'dnsMaterials.Wood_Soft.BootSftWod147'
     bPenetrable=True
     bBurrowableDirt=True
}
