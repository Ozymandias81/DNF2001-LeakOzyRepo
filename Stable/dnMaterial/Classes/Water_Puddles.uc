//=============================================================================
// Water_Puddles.
//=============================================================================
class Water_Puddles expands dnMaterial;

defaultproperties
{
     DamageCategoryEffect(0)=(HitEffect=Class'dnParticles.dnBulletWallFX_WaterSplashSpawner')
     FootstepSounds(0)=Sound'dnsMaterials.Water_Puddles.LthrWetCem11'
     FootstepSounds(1)=Sound'dnsMaterials.Water_Puddles.LthrWetCem12'
     FootstepSounds(2)=Sound'dnsMaterials.Water_Puddles.LthrWetCem24'
     FootstepSounds(3)=Sound'dnsMaterials.Water_Puddles.LthrWetCem25'
     FootstepSoundsCount=4
     FootstepLandSound=Sound'dnsMaterials.Water_Puddles.LthrWetCem25'
     bBurrowableDirt=True
}
