//=============================================================================
// Z2_Column_256.						November 6th, 2000 - Charlie Wiederhold
//=============================================================================
class Z2_Column_256 expands Z2_Column_224;

#exec OBJ LOAD FILE=..\Textures\m_zone2_dam.dtx
#exec OBJ LOAD FILE=..\Meshes\c_zone2_dam.dmx

defaultproperties
{
     CollisionHeight=256.000000
     Mesh=DukeMesh'c_zone2_dam.column256'
}
