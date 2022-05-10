//=============================================================================
// Snow.
//=============================================================================
class Snow expands dnMaterial;

defaultproperties
{
     DamageCategoryEffect(0)=(HitEffect=Class'dnParticles.dnBulletWallFX_IceSpawner')
     FootstepSounds(0)=Sound'dnsMaterials.Snow.FtStepGen0545'
     FootstepSounds(1)=Sound'dnsMaterials.Snow.FtStepGen0543'
     FootstepSounds(2)=Sound'dnsMaterials.Snow.FtStepGen0544'
     FootstepSounds(3)=Sound'dnsMaterials.Snow.FtStepGen0546'
     FootstepSoundsCount=4
     FootstepLandSound=Sound'dnsMaterials.Snow.LeatherSnow14'
     bPenetrable=True
     AppliedForce=(X=1.000000,Y=1.000000,Z=1.000000)
     bBurrowableDirt=True
}
