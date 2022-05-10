//=============================================================================
// Carpet.
//=============================================================================
class Carpet expands dnMaterial;

defaultproperties
{
     DamageCategoryEffect(0)=(HitEffect=Class'dnParticles.dnBulletWallFX_FabricSpawner')
     FootstepSounds(0)=Sound'dnsMaterials.Carpet.LeathCarpet16'
     FootstepSounds(1)=Sound'dnsMaterials.Carpet.LeathCarpet17'
     FootstepSounds(2)=Sound'dnsMaterials.Carpet.LeathCarpet19'
     FootstepSounds(3)=Sound'dnsMaterials.Carpet.LeathCarpet20r'
     FootstepSoundsCount=4
     FootstepLandSound=Sound'dnsMaterials.Carpet.LeathCarpet58l'
     bPenetrable=True
     bBurrowableDirt=True
}
