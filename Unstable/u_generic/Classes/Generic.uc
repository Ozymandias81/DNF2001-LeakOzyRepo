//=============================================================================
// Generic.
//=============================================================================
class Generic expands dnDecoration;

#exec OBJ LOAD FILE=..\Textures\m_generic.dtx
#exec OBJ LOAD FILE=..\Meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\Sounds\a_impact.dfx
#exec OBJ LOAD FILE=..\Textures\m_zone1_vegas.dtx
#exec OBJ LOAD FILE=..\Meshes\c_zone1_vegas.dmx

defaultproperties
{
     DestroyedSound=Sound'a_impact.Generic.ImpactGen001A'
}
