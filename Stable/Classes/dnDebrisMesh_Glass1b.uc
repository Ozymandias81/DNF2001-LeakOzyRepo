//=============================================================================
// dnDebrisMesh_Glass1b.  			  September 21st, 2000 - Charlie Wiederhold
//=============================================================================
class dnDebrisMesh_Glass1b expands dnDebrisMesh_Glass1;

// Sub piece of the glass mesh debris spawners. Normal sized chunks

#exec OBJ LOAD FILE=..\Meshes\c_FX.dmx

defaultproperties
{
     Mesh=DukeMesh'c_FX.Gib_GlassC'
}
