//=============================================================================
// Z3_Cactus2. 							November 9th, 2000 - Charlie Wiederhold
//=============================================================================
class Z3_Cactus2 expands Z3_Cactus1;

#exec OBJ LOAD FILE=..\Textures\m_zone3_canyon.dtx
#exec OBJ LOAD FILE=..\Meshes\c_zone3_canyon.dmx

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebrisMesh_Generic1'
     FragType(1)=Class'dnParticles.dnDebrisMesh_Generic1b'
     FragType(2)=Class'dnParticles.dnDebrisMesh_Generic1a'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Generic1b'
     SpawnOnDestroyed(0)=(SpawnClass=Class'dnParticles.dnLeaves')
     SpawnOnDestroyed(1)=(SpawnClass=Class'dnParticles.dnLeaves')
     SpawnOnDestroyed(2)=(SpawnClass=Class'dnParticles.dnLeaves')
     CollisionRadius=18.000000
     CollisionHeight=70.000000
     Mesh=DukeMesh'c_zone3_canyon.cactus6'
}
