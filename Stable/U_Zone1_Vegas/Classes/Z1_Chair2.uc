//=============================================================================
// Z1_Chair2.
//=============================================================================
class Z1_Chair2 expands Zone1_Vegas;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx
// September 27th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Fabric1'
     FragType(1)=Class'dnParticles.dnDebris_Metal1_Small'
     FragType(2)=Class'dnParticles.dnDebris_Smoke'
     FragType(3)=Class'dnParticles.dnDebris_Sparks1_Small'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Metal1'
     FragType(5)=Class'dnParticles.dnDebrisMesh_Metal1a'
     SpawnOnHit=Class'dnParticles.dnBulletFX_FabricSpawner'
     bLandLeft=True
     bLandRight=True
     bLandUpright=True
     LandFrontCollisionRadius=46.000000
     LandFrontCollisionHeight=15.000000
     LandSideCollisionRadius=46.000000
     LandSideCollisionHeight=15.000000
     Grabbable=True
     MeshFlameClass=Class'dnParticles.dnFlameThrowerFX_ObjectBurn_Large_30x30'
     PlayerViewOffset=(X=-2.500000,Y=0.000000,Z=-4.000000)
     ItemName="Long Patio Chair"
     bFlammable=True
     CollisionRadius=46.000000
     CollisionHeight=18.000000
     bBlockActors=False
     bBlockPlayers=False
     bProjTarget=True
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone1_vegas.poolchair2'
}
