//=============================================================================
// Z1_HotelTable3.							Keith Schuler 5/21/99
//=============================================================================
class Z1_HotelTable3 expands Zone1_Vegas;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx
// September 28th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Wood1'
     FragType(1)=Class'dnParticles.dnDebris_Smoke'
     FragType(2)=Class'dnParticles.dnDebrisMesh_Wood1'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Wood1a'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Wood1b'
     SpawnOnHit=Class'dnParticles.dnBulletFX_WoodSpawner'
     DestroyedSound=Sound'a_impact.wood.ImpactWood42'
     bLandForward=True
     bLandBackwards=True
     LandFrontCollisionRadius=28.000000
     LandFrontCollisionHeight=10.000000
     LandSideCollisionRadius=28.000000
     LandSideCollisionHeight=10.000000
     bPushable=True
     Grabbable=True
     PlayerViewOffset=(X=0.000000,Y=-0.250000,Z=0.000000)
     ItemName="End Table"
     bFlammable=True
     CollisionRadius=20.000000
     CollisionHeight=16.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone1_vegas.hotel_table3'
}
