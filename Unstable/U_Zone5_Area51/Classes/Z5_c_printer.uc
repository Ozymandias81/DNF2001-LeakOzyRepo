//=============================================================================
// Z5_c_printer. 						October 26th, 2000 - Charlie Wiederhold
//=============================================================================
class Z5_c_printer expands Zone5_Area51;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Metal1'
     FragType(1)=Class'dnParticles.dnDebris_Sparks1_Small'
     FragType(2)=Class'dnParticles.dnDebrisMesh_Metal1'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Metal1a'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Metal1b'
     SpawnOnDestroyed(0)=(SpawnClass=Class'dnParticles.dnExplosion3_SElec_Spawner2')
     bLandBackwards=True
     bLandLeft=True
     bLandRight=True
     bLandUpright=True
     bLandUpsideDown=True
     LandFrontCollisionRadius=12.000000
     LandFrontCollisionHeight=10.000000
     LandSideCollisionRadius=12.000000
     LandSideCollisionHeight=9.000000
     bPushable=True
     Grabbable=True
     MeshFlameClass=Class'dnParticles.dnFlameThrowerFX_ObjectBurn_Small'
     PlayerViewOffset=(X=-0.625000,Y=-0.750000,Z=0.000000)
     BobDamping=0.925000
     ItemName="Printer"
     bFlammable=True
     CollisionRadius=14.000000
     CollisionHeight=7.500000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone1_vegas.LKlaserprinter'
}
