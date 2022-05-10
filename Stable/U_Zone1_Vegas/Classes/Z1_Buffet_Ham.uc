//=============================================================================
// Z1_Buffet_Ham.						October 25th, 2000 - Charlie Wiederhold
//=============================================================================
class Z1_Buffet_Ham expands Zone1_Vegas;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Wood1'
     FragType(1)=Class'dnParticles.dnDebrisMesh_Generic1'
     FragType(2)=Class'dnParticles.dnDebris_Smoke'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Generic1a'
     SpawnOnHit=Class'dnParticles.dnBulletFX_WoodSpawner'
     bLandUpright=True
     bPushable=True
     Grabbable=True
     MeshFlameClass=Class'dnParticles.dnFlameThrowerFX_ObjectBurn_Small'
     PlayerViewOffset=(X=0.000000,Y=-1.000000,Z=0.750000)
     BobDamping=0.900000
     ItemName="Ham"
     bFlammable=True
     CollisionRadius=10.000000
     CollisionHeight=4.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone1_vegas.buffet_ham'
}
