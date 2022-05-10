//=============================================================================
// Water_Kneedeep.
//=============================================================================
class Water_Kneedeep expands dnMaterial;

defaultproperties
{
     DamageCategoryEffect(0)=(HitEffect=Class'dnParticles.dnBulletWallFX_WaterSplashSpawner')
     FootstepSounds(0)=Sound'dnsMaterials.Water_kneedeep.LthrWetCem038'
     FootstepSounds(1)=Sound'dnsMaterials.Water_kneedeep.LthrWetCem037'
     FootstepSoundsCount=2
     FootstepLandSound=Sound'dnsMaterials.Water_kneedeep.LthrWetCem038'
     bBurrowableDirt=True
}
