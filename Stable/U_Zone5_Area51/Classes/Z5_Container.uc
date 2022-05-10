//=============================================================================
// Z5_Container. 						November 10th, 2000 - Charlie Wiederhold
//=============================================================================
class Z5_Container expands Zone5_Area51;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Metal1_Small'
     FragType(1)=Class'dnParticles.dnDebris_Smoke'
     FragType(2)=Class'dnParticles.dnDebris_Sparks1_Small'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Generic1'
     FragType(4)=Class'dnParticles.dnDebrisMesh_GenericTiny1'
     FragType(5)=Class'dnParticles.dnDebrisMesh_GenericTiny1a'
     FragType(6)=Class'dnParticles.dnDebrisMesh_GenericTiny1b'
     DestroyedSound=Sound'a_impact.Ceramic.ImpactCer02'
     bLandForward=True
     bLandBackwards=True
     bLandLeft=True
     bLandRight=True
     LandFrontCollisionRadius=10.000000
     LandFrontCollisionHeight=3.500000
     LandSideCollisionRadius=10.000000
     LandSideCollisionHeight=3.500000
     bPushable=True
     Grabbable=True
     MeshFlameClass=Class'dnParticles.dnFlameThrowerFX_ObjectBurn_Small'
     PlayerViewOffset=(X=0.500000,Y=-0.750000,Z=2.000000)
     BobDamping=0.925000
     ItemName="DNA Container"
     bFlammable=True
     CollisionRadius=4.000000
     CollisionHeight=7.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone5_area51.s_container'
}
