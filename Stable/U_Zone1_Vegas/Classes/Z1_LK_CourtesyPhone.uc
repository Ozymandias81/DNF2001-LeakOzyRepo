//=============================================================================
// Z1_LK_CourtesyPhone. 				October 26th, 2000 - Charlie Wiederhold
//=============================================================================
class Z1_LK_CourtesyPhone expands Zone1_Vegas;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Metal1_Small'
     FragType(1)=Class'dnParticles.dnDebris_Smoke'
     FragType(2)=Class'dnParticles.dnDebris_Sparks1_Small'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Generic1'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Generic1a'
     MeshFlameClass=Class'dnParticles.dnFlameThrowerFX_ObjectBurn_Small'
     ItemName="Phone"
     bTakeMomentum=False
     bFlammable=True
     CollisionRadius=5.000000
     CollisionHeight=12.000000
     Mesh=DukeMesh'c_zone1_vegas.LKcourtesyphone'
}
