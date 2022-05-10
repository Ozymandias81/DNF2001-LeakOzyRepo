//=============================================================================
// Zone1_Vegas.
//=============================================================================
class Zone1_Vegas expands dnDecoration;

#exec OBJ LOAD FILE=..\Textures\m_Zone1_Vegas.dtx
#exec OBJ LOAD FILE=..\Meshes\c_Zone1_Vegas.dmx
#exec OBJ LOAD FILE=..\Sounds\a_impact.dfx

defaultproperties
{
     DestroyedSound=Sound'a_impact.Generic.ImpactGen001A'
}
