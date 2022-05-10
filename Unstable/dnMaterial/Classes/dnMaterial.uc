//=============================================================================
// dnMaterial.
//=============================================================================
class dnMaterial expands Material;

#exec OBJ LOAD FILE=..\sounds\dnsMaterials.dfx PACKAGE=dnsMaterials

/*
// Enum to index reference:
TH_Bullet...................= 0
TH_LaserBurn................= 1
TH_Foot.....................= 2
TH_Chainsaw.................= 3
TH_Shrink...................= 4
TH_Freeze...................= 5
TH_NoMaterialEffectBullet...= 6
TH_Projectile...............= 7
TH_Decoration...............= 8
*/

defaultproperties
{
	Friction=1.000000
	
	DamageCategoryEffect(0)=(HitEffect=Class'dnParticles.dnBulletWallFX_WoodSpawner')
	DamageCategoryEffect(1)=(HitEffect=Class'dnParticles.dnLaserBurnWallFX_Generic')
	DamageCategoryEffect(2)=(HitEffect=class'dnParticles.dnCharacterFX_Dirt_FootHaze')
	DamageCategoryEffect(8)=(HitEffect=class'dnParticles.dnCharacterFX_Dirt_FootHaze')
}
