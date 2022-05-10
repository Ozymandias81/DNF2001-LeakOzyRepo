//=============================================================================
// Z1_Glass_Lager.						October 25th, 2000 - Charlie Wiederhold
//=============================================================================
class Z1_Glass_Lager expands Z1_Glass_BeerMug;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     ItemName="Lager"
     Mesh=DukeMesh'c_zone1_vegas.gls_lager'
}
