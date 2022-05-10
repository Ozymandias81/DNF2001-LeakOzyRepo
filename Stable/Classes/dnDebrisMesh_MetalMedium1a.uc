//=============================================================================
// dnDebrisMesh_MetalMedium1a. 		  September 22nd, 2000 - Charlie Wiederhold
//=============================================================================
class dnDebrisMesh_MetalMedium1a expands dnDebrisMesh_MetalMedium1;

// Subclass of the metal mesh debris spawners. Normal sized chunks

#exec OBJ LOAD FILE=..\Meshes\c_FX.dmx

defaultproperties
{
     Mesh=DukeMesh'c_FX.Gib_MetalB'
}
