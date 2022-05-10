//=============================================================================
// dnDebrisMesh_Metal1b.  			  September 20th, 2000 - Charlie Wiederhold
//=============================================================================
class dnDebrisMesh_Metal1b expands dnDebrisMesh_Metal1;

// Sub piece of the metal mesh debris spawners. Normal sized chunks

#exec OBJ LOAD FILE=..\Meshes\c_FX.dmx

defaultproperties
{
     Mesh=DukeMesh'c_FX.Gib_MetalC'
}
