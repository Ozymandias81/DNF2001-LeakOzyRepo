//=============================================================================
// Z1_TennisBall.						October 26th, 2000 - Charlie Wiederhold
//=============================================================================
class Z1_TennisBall expands Zone1_Vegas;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Smoke'
     FragType(1)=Class'dnParticles.dnDebris_Fabric1'
     FragType(2)=Class'dnParticles.dnDebrisMesh_GenericTiny1'
     FragType(3)=Class'dnParticles.dnDebrisMesh_GenericTiny1a'
     FragType(4)=Class'dnParticles.dnDebrisMesh_GenericTiny1b'
     SpawnOnHit=None
     MassPrefab=MASS_Rubber
     HealthPrefab=HEALTH_Easy
     bLandForward=True
     bLandBackwards=True
     bLandLeft=True
     bLandRight=True
     bLandUpright=True
     bLandUpsideDown=True
     LandFrontCollisionRadius=1.750000
     LandFrontCollisionHeight=1.750000
     LandSideCollisionRadius=1.750000
     LandSideCollisionHeight=1.750000
     bPushable=True
     Grabbable=True
     MeshFlameClass=Class'dnParticles.dnFlameThrowerFX_ObjectBurn_Small'
     PlayerViewOffset=(X=0.750000,Y=-1.325000,Z=2.000000)
     BobDamping=0.990000
     ItemName="Tennis Ball"
     bFlammable=True
     CollisionRadius=1.750000
     CollisionHeight=1.750000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone1_vegas.Tball'
}
