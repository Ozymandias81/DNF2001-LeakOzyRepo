//=============================================================================
// Z1_HotelTable2.							Keith Schuler 5/21/99
//=============================================================================
class Z1_HotelTable2 expands Zone1_Vegas;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx
// September 28th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Glass1'
     FragType(1)=Class'dnParticles.dnDebris_Wood1'
     FragType(2)=Class'dnParticles.dnDebris_Sparks1'
     FragType(3)=Class'dnParticles.dnDebris_Smoke'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Wood1'
     FragType(5)=Class'dnParticles.dnDebrisMesh_Wood1a'
     FragType(6)=Class'dnParticles.dnDebrisMesh_Wood1b'
     SpawnOnHit=Class'dnParticles.dnBulletFX_GlassSpawner'
     DestroyedSound=Sound'a_impact.Glass.GlassBreak57a'
     ItemName="Fancy Table"
     bFlammable=True
     CollisionRadius=47.000000
     CollisionHeight=9.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone1_vegas.hotel_table2'
}
