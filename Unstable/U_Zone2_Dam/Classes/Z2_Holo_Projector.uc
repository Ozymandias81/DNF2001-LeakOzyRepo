//=============================================================================
// Z2_Holo_Projector. 					November 7th, 2000 - Charlie Wiederhold
//=============================================================================
class Z2_Holo_Projector expands Zone2_Dam;

#exec OBJ LOAD FILE=..\Textures\m_zone2_dam.dtx
#exec OBJ LOAD FILE=..\Meshes\c_zone2_dam.dmx

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Metal1'
     FragType(1)=Class'dnParticles.dnDebris_Sparks1_Small'
     FragType(2)=Class'dnParticles.dnDebrisMesh_Metal1'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Metal1a'
     SpawnOnDestroyed(0)=(SpawnClass=Class'dnParticles.dnExplosion3_SElec_Spawner2')
     ItemName="Holo Projector"
     bFlammable=True
     CollisionRadius=30.000000
     CollisionHeight=7.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone2_dam.holoprojector'
}
