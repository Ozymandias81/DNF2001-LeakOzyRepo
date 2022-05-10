//=============================================================================
// Wood_Hard.
//=============================================================================
class Wood_Hard expands dnMaterial;

defaultproperties
{
     DamageCategoryEffect(0)=(HitEffect=Class'dnParticles.dnBulletWallFX_WoodSpawner')
     FootstepSounds(0)=Sound'dnsMaterials.Wood_Hard.BootHrdWod018'
     FootstepSounds(1)=Sound'dnsMaterials.Wood_Hard.BootHrdWod023'
     FootstepSounds(2)=Sound'dnsMaterials.Wood_Hard.BootHrdWod024'
     FootstepSounds(3)=Sound'dnsMaterials.Wood_Hard.BootHrdWod025'
     FootstepSoundsCount=4
     FootstepLandSound=Sound'dnsMaterials.Wood_Hard.BootHrdWod153'
     bPenetrable=True
     bBurrowableDirt=True
}
