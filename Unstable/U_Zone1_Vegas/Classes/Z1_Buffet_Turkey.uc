//=============================================================================
// Z1_Buffet_Turkey.					October 25th, 2000 - Charlie Wiederhold
//=============================================================================
class Z1_Buffet_Turkey expands Zone1_Vegas;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Wood1'
     FragType(1)=Class'dnParticles.dnDebris_Smoke'
     FragType(2)=Class'dnParticles.dnDebrisMesh_Generic1'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Generic1a'
     SpawnOnHit=Class'dnParticles.dnBulletFX_WoodSpawner'
     bLandUpright=True
     bLandUpsideDown=True
     bPushable=True
     Grabbable=True
     MeshFlameClass=Class'dnParticles.dnFlameThrowerFX_ObjectBurn_Small'
     PlayerViewOffset=(X=0.000000,Y=-2.000000,Z=1.000000)
     BobDamping=0.900000
     ItemName="Turkey"
     bFlammable=True
     CollisionRadius=16.000000
     CollisionHeight=6.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone1_vegas.buffet_turkey'
}
