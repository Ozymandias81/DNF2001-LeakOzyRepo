//=============================================================================
// Mud_Squishy.
//=============================================================================
class Mud_Squishy expands dnMaterial;

defaultproperties
{
     DamageCategoryEffect(0)=(HitEffect=Class'dnParticles.dnBulletWallFX_WaterSplashSpawner')
     FootstepSounds(0)=Sound'dnsMaterials.Mud_Squishy.LeatherMud14'
     FootstepSounds(1)=Sound'dnsMaterials.Mud_Squishy.LeatherMud19'
     FootstepSounds(2)=Sound'dnsMaterials.Mud_Squishy.LeatherMud23'
     FootstepSoundsCount=3
     FootstepLandSound=Sound'dnsMaterials.Mud_Squishy.LeatherMud79l'
     bBurrowableDirt=True
}
