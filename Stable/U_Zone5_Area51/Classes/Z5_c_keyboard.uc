//=============================================================================
// Z5_c_keyboard.
//=============================================================================
//========================  MW
class Z5_c_keyboard expands Zone5_Area51;

#exec OBJ LOAD FILE=..\meshes\c_zone5_area51.dmx
#exec OBJ LOAD FILE=..\textures\m_zone5_area51.dtx
// October 3rd, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Metal1_Small'
     FragType(1)=Class'dnParticles.dnDebris_Smoke'
     FragType(2)=Class'dnParticles.dnDebris_Sparks1_Small'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Metal1'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Metal1a'
     bLandUpright=True
     bLandUpsideDown=True
     bPushable=True
     Grabbable=True
     MeshFlameClass=Class'dnParticles.dnFlameThrowerFX_ObjectBurn_Small'
     PlayerViewOffset=(X=-0.500000,Z=0.500000)
     Health=80
     ItemName="Keyboard"
     bFlammable=True
     CollisionRadius=20.000000
     CollisionHeight=1.500000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone5_area51.comp_keyboard'
}
