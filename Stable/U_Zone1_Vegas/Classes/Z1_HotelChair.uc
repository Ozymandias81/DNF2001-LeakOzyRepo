//=============================================================================
// Z1_HotelChair.							Keith Schuler 5/21/99
//=============================================================================
class Z1_HotelChair expands Zone1_Vegas;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx
// September 28th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Fabric1'
     FragType(1)=Class'dnParticles.dnDebris_Wood1'
     FragType(2)=Class'dnParticles.dnDebrisMesh_Generic1'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Generic1a'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Generic1b'
     FragType(5)=Class'dnParticles.dnDebris_Smoke'
     FragType(6)=Class'dnParticles.dnDebris_Fabric1'
     SpawnOnHit=Class'dnParticles.dnBulletFX_FabricSpawner'
     bLandBackwards=True
     bLandLeft=True
     bLandRight=True
     LandFrontCollisionRadius=36.000000
     LandFrontCollisionHeight=17.000000
     LandSideCollisionRadius=36.000000
     LandSideCollisionHeight=16.000000
     bPushable=True
     Grabbable=True
     PlayerViewOffset=(X=-0.625000,Y=1.000000,Z=0.750000)
     ItemName="Chair"
     bFlammable=True
     CollisionRadius=22.000000
     CollisionHeight=27.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone1_vegas.hotel_chair'
}
