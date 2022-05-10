//=============================================================================
// SteamPipe.
//=============================================================================
class SteamPipe expands dnMaterial;

defaultproperties
{
     DamageCategoryEffect(0)=(HitEffect=Class'dnParticles.dnBulletWallFX_PipeSteamSpawner')
     FootstepSounds(0)=Sound'dnsMaterials.Metal_1.LthrMtlDamp18'
     FootstepSounds(1)=Sound'dnsMaterials.Metal_1.LthrMtlDamp11'
     FootstepSounds(2)=Sound'dnsMaterials.Metal_1.LthrMtlDamp19'
     FootstepSounds(3)=Sound'dnsMaterials.Metal_1.LthrMtlDamp23'
     FootstepSoundsCount=4
     FootstepLandSound=Sound'dnsMaterials.Metal_1.LthrMtlDamp16'
     bPenetrable=True
}
