//=============================================================================
// Z1_Glass_LagerFull. October 26th, 2000 - Charlie Wiederhold
//=============================================================================
class Z1_Glass_LagerFull expands Z1_Glass_BeerMug;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     ItemName="Lager"
     Mesh=DukeMesh'c_zone1_vegas.gls_lagerfull'
}
