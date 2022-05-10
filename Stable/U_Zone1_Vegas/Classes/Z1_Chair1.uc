//=============================================================================
// Z1_Chair1.                 Grabbable 5/26/99	Keith Schuler
//=============================================================================
class Z1_Chair1 expands Zone1_Vegas;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx
// September 27th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Fabric1'
     FragType(1)=Class'dnParticles.dnDebris_Metal1_Small'
     FragType(2)=Class'dnParticles.dnDebris_Sparks1_Small'
     FragType(3)=Class'dnParticles.dnDebris_Smoke'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Metal1'
     FragType(5)=Class'dnParticles.dnDebrisMesh_Metal1a'
     SpawnOnHit=Class'dnParticles.dnBulletFX_FabricSpawner'
     bLandBackwards=True
     bLandLeft=True
     bLandRight=True
     LandFrontCollisionRadius=28.000000
     LandFrontCollisionHeight=15.000000
     LandSideCollisionRadius=28.000000
     LandSideCollisionHeight=15.000000
     bPushable=True
     Grabbable=True
     PlayerViewOffset=(X=-0.250000,Y=0.750000,Z=0.750000)
     ItemName="Patio Chair"
     bFlammable=True
     CollisionRadius=22.000000
     CollisionHeight=22.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone1_vegas.poolchair1'
}
