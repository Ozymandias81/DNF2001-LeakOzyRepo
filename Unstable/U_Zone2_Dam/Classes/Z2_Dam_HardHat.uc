//=============================================================================
// Z2_Dam_HardHat.
//=============================================================================
class Z2_Dam_HardHat expands Zone2_Dam;

// AllenB

#exec OBJ LOAD FILE=..\meshes\c_zone5_area51.dmx
#exec OBJ LOAD FILE=..\textures\m_zone5_area51.dtx
// October 3rd, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Smoke_Small1'
     FragType(1)=Class'dnParticles.dnDebris_Metal1_Small'
     FragType(2)=Class'dnParticles.dnDebris_Fabric1'
     FragType(3)=Class'dnParticles.dnDebrisMesh_GenericTiny1'
     FragType(4)=Class'dnParticles.dnDebrisMesh_GenericTiny1a'
     FragType(5)=Class'dnParticles.dnDebrisMesh_Metal1'
     DestroyedSound=Sound'a_impact.wood.ImpactWood1A'
     bLandUpright=True
     bLandUpsideDown=True
     bPushable=True
     Grabbable=True
     MeshFlameClass=Class'dnParticles.dnFlameThrowerFX_ObjectBurn_Small'
     PlayerViewOffset=(X=-1.075000,Y=2.000000,Z=-1.500000)
     BobDamping=0.982500
     LodMode=LOD_StopMinimum
     LodOffset=100.000000
     Health=0
     ItemName="Hard Hat"
     bFlammable=True
     CollisionRadius=8.000000
     CollisionHeight=5.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone2_dam.hardhat'
}
