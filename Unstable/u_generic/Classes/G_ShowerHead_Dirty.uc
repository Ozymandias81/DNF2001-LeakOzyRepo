//=============================================================================
// G_ShowerHead_Dirty. 					January 25th, 2001 - Charlie Wiederhold
//=============================================================================
class G_ShowerHead_Dirty expands G_ShowerHead;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx
#exec OBJ LOAD FILE=..\sounds\a_generic.dfx

defaultproperties
{
     Mesh=DukeMesh'c_generic.ShowerNozzle_dirty'
}
