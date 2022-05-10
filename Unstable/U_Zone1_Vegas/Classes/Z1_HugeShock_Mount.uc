//=============================================================================
// Z1_HugeShock_Mount.					October 25th, 2000 - Charlie Wiederhold
//=============================================================================
class Z1_HugeShock_Mount expands Z1_HugeShock_Large;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     CollisionRadius=120.000000
     CollisionHeight=5.000000
     Mesh=DukeMesh'c_zone1_vegas.hugeshock_mount'
}
