//=============================================================================
// Wood_Parquet.
//=============================================================================
class Wood_Parquet expands dnMaterial;

defaultproperties
{
     DamageCategoryEffect(0)=(HitEffect=Class'dnParticles.dnBulletWallFX_WoodSpawner')
     FootstepSounds(0)=Sound'dnsMaterials.Wood_Parquet.BootParWod030'
     FootstepSounds(1)=Sound'dnsMaterials.Wood_Parquet.BootParWod031'
     FootstepSounds(2)=Sound'dnsMaterials.Wood_Parquet.BootParWod032'
     FootstepSounds(3)=Sound'dnsMaterials.Wood_Parquet.BootParWod033'
     FootstepSoundsCount=4
     FootstepLandSound=Sound'dnsMaterials.Wood_Parquet.BootParWod151'
     bPenetrable=True
     bBurrowableDirt=True
}
