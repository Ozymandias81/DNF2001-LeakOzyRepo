//=============================================================================
// Z2_Holo_Slides. 						November 8th, 2000 - Charlie Wiederhold
//=============================================================================
class Z2_Holo_Slides expands Zone2_Dam;

#exec OBJ LOAD FILE=..\Textures\m_zone2_dam.dtx
#exec OBJ LOAD FILE=..\Meshes\c_zone2_dam.dmx

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Smoke'
     FragType(1)=Class'dnParticles.dnDebris_Metal1_Small'
     FragType(2)=Class'dnParticles.dnDebris_Sparks1_Small'
     FragType(3)=Class'dnParticles.dnDebrisMesh_GenericTiny1'
     FragType(4)=Class'dnParticles.dnDebrisMesh_GenericTiny1a'
     FragType(5)=Class'dnParticles.dnDebrisMesh_Metal1'
     bLandUpright=True
     bLandUpsideDown=True
     bPushable=True
     Grabbable=True
     MeshFlameClass=Class'dnParticles.dnFlameThrowerFX_ObjectBurn_Small'
     PlayerViewOffset=(X=0.000000,Y=-1.250000,Z=1.000000)
     BobDamping=0.925000
     ItemName="Holo Slides"
     bFlammable=True
     CollisionRadius=6.000000
     CollisionHeight=2.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone2_dam.Slides_sah'
}
