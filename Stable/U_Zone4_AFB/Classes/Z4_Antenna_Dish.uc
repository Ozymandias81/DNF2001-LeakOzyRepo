//=============================================================================
// Z4_Antenna_Dish. 					November 9th, 2000 - Charlie Wiederhold
//=============================================================================
class Z4_Antenna_Dish expands Z4_Antenna_Base;

#exec OBJ LOAD FILE=..\Textures\m_zone4_afb.dtx
#exec OBJ LOAD FILE=..\Meshes\c_zone4_afb.dmx

defaultproperties
{
     CollisionRadius=125.000000
     CollisionHeight=135.000000
     Mesh=DukeMesh'c_zone4_afb.BigDish1'
}
