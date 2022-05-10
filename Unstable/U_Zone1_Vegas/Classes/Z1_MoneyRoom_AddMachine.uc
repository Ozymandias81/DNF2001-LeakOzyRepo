//=============================================================================
// Z1_MoneyRoom_AddMachine. 			October 26th, 2000 - Charlie Wiederhold
//=============================================================================
class Z1_MoneyRoom_AddMachine expands Zone1_Vegas;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Smoke'
     FragType(1)=Class'dnParticles.dnDebris_Sparks1_Small'
     FragType(2)=Class'dnParticles.dnDebris_Metal1_Small'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Metal1'
     bLandUpright=True
     bLandUpsideDown=True
     bPushable=True
     Grabbable=True
     MeshFlameClass=Class'dnParticles.dnFlameThrowerFX_ObjectBurn_Small'
     PlayerViewOffset=(X=-0.250000,Y=-1.125000,Z=0.750000)
     BobDamping=0.900000
     ItemName="Adding Machine"
     bFlammable=True
     CollisionRadius=8.000000
     CollisionHeight=2.500000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone1_vegas.moneyr_addmachn'
}
