//=============================================================================
// Z5_LightTripod. 						November 10th, 2000 - Charlie Wiederhold
//=============================================================================
class Z5_LightTripod expands Zone5_Area51;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Metal1'
     FragType(1)=Class'dnParticles.dnDebris_Sparks1_Small'
     FragType(2)=Class'dnParticles.dnDebrisMesh_Metal1'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Metal1a'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Metal1b'
     FragType(5)=Class'dnParticles.dnDebris_Glass1'
     SpawnOnDestroyed(0)=(SpawnClass=Class'dnParticles.dnExplosion3_SElec_Spawner2')
     bLandForward=True
     bLandBackwards=True
     bLandLeft=True
     bLandRight=True
     LandFrontCollisionRadius=59.000000
     LandFrontCollisionHeight=12.000000
     LandSideCollisionRadius=59.000000
     LandSideCollisionHeight=12.000000
     PlayerViewOffset=(X=-0.500000,Y=4.000000,Z=1.000000)
     BobDamping=0.900000
     ItemName="Tripod Light"
     bTakeMomentum=False
     bFlammable=True
     CollisionRadius=15.000000
     CollisionHeight=36.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone5_area51.light_tripod'
}
