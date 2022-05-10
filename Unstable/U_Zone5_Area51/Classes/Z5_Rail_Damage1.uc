//=============================================================================
// Z5_Rail_Damage1. 						November 10th, 2000 - Charlie Wiederhold
//=============================================================================
class Z5_Rail_Damage1 expands Z5_Rail_Hub;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     CollisionRadius=26.000000
     CollisionHeight=24.000000
     Mesh=DukeMesh'c_zone5_area51.rail_damage1'
}
