//=============================================================================
// Z5_lab_microscope.
//=============================================================================
class Z5_lab_microscope expands Zone5_Area51;

///========================================= March 18th, Matt Wood

#exec OBJ LOAD FILE=..\meshes\c_zone5_area51.dmx
#exec OBJ LOAD FILE=..\textures\m_zone5_area51.dtx
// October 3rd, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Metal1_Small'
     FragType(1)=Class'dnParticles.dnDebris_Sparks1_Small'
     FragType(2)=Class'dnParticles.dnDebrisMesh_Metal1'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Metal1a'
     FragType(4)=Class'dnParticles.dnDebris_Smoke'
     NumberFragPieces=8
     FragBaseScale=0.180000
     bLandLeft=True
     bLandRight=True
     LandFrontCollisionRadius=21.000000
     LandFrontCollisionHeight=8.000000
     LandSideCollisionRadius=21.000000
     LandSideCollisionHeight=8.000000
     bPushable=True
     Grabbable=True
     PlayerViewOffset=(X=-0.250000,Y=-0.250000,Z=1.000000)
     BobDamping=0.875000
     Health=40
     ItemName="Microscope"
     bFlammable=True
     CollisionRadius=17.000000
     CollisionHeight=15.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone5_area51.lab_microscope'
}
