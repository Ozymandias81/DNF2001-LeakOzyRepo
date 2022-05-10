//=============================================================================
// Z1_LK_DeskPenSet. 					October 26th, 2000 - Charlie Wiederhold
//=============================================================================
class Z1_LK_DeskPenSet expands Zone1_Vegas;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Wood1'
     FragType(1)=Class'dnParticles.dnDebris_Sparks1_Small'
     FragType(2)=Class'dnParticles.dnDebris_Smoke'
     FragType(3)=Class'dnParticles.dnDebrisMesh_GenericTiny1'
     FragType(4)=Class'dnParticles.dnDebrisMesh_GenericTiny1a'
     FragType(5)=Class'dnParticles.dnDebrisMesh_GenericTiny1b'
     SpawnOnHit=Class'dnParticles.dnBulletFX_WoodSpawner'
     DestroyedSound=Sound'a_impact.Debris.ImpactDeb008'
     MeshFlameClass=Class'dnParticles.dnFlameThrowerFX_ObjectBurn_Small'
     ItemName="Desk Pens"
     bTakeMomentum=False
     bFlammable=True
     CollisionRadius=9.000000
     CollisionHeight=5.000000
     Mesh=DukeMesh'c_zone1_vegas.LKdeskpenset'
}
