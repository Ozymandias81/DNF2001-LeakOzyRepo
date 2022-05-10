//=============================================================================
// BBall_Court.
//=============================================================================
class BBall_Court expands dnMaterial;

defaultproperties
{
     DamageCategoryEffect(0)=(HitEffect=Class'dnParticles.dnBulletWallFX_WoodSpawner')
     FootstepSounds(0)=Sound'dnsMaterials.Mud_Squishy.LeatherMud14'
     FootstepSoundsCount=1
     FootstepLandSound=Sound'dnsMaterials.Mud_Squishy.LeatherMud79l'
     bBurrowableDirt=True
}
