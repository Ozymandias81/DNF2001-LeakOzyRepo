//=============================================================================
// Zone5_Area51.
//=============================================================================
class Zone5_Area51 expands dnDecoration;

#exec OBJ LOAD FILE=..\Textures\m_zone5_area51.dtx
#exec OBJ LOAD FILE=..\Meshes\c_zone5_area51.dmx
#exec OBJ LOAD FILE=..\Textures\m_generic.dtx
#exec OBJ LOAD FILE=..\Meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\Sounds\a_impact.dfx

defaultproperties
{
     DestroyedSound=Sound'a_impact.Generic.ImpactGen001A'
}
