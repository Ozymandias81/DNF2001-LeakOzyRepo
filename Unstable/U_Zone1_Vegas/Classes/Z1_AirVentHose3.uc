//=============================================================================
// Z1_AirVentHose3.						 October 9th, 2000 - Charlie Wiederhold
//=============================================================================
class Z1_AirVentHose3 expands Z1_AirVentHose2;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     CollisionRadius=20.000000
     CollisionHeight=21.000000
     Mesh=DukeMesh'c_zone1_vegas.air_vent_hose3'
}
