//=============================================================================
// Z3_Pickaxe.							November 8th, 2000 - Charlie Wiederhold
//=============================================================================
class Z3_Pickaxe expands Zone3_Canyon;

#exec OBJ LOAD FILE=..\Textures\m_zone3_canyon.dtx
#exec OBJ LOAD FILE=..\Meshes\c_zone3_canyon.dmx

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Wood1'
     FragType(1)=Class'dnParticles.dnDebrisMesh_Wood1'
     FragType(2)=Class'dnParticles.dnDebrisMesh_Wood1a'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Wood1b'
     FragType(4)=Class'dnParticles.dnDebris_Smoke'
     FragType(5)=Class'dnParticles.dnDebris_Sparks1_Small'
     SpawnOnHit=Class'dnParticles.dnBulletFX_WoodSpawner'
     DestroyedSound=Sound'a_impact.wood.ImpactWood1A'
     bLandUpright=True
     bPushable=True
     Grabbable=True
     MeshFlameClass=Class'dnParticles.dnFlameThrowerFX_ObjectBurn_Small'
     PlayerViewOffset=(X=-3.500000,Y=-2.325000,Z=-2.000000)
     BobDamping=0.875000
     ItemName="Pick Axe"
     bFlammable=True
     CollisionRadius=30.000000
     CollisionHeight=2.000000
     bMeshLowerByCollision=False
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone3_canyon.pickaxe'
}
