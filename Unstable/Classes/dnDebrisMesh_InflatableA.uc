//=============================================================================
// dnDebrisMesh_InflatableA.		  September 22nd, 2000 - Charlie Wiederhold
//=============================================================================
class dnDebrisMesh_InflatableA expands dnDebrisMesh_Inflatable;

// Subclass of the inflatable mesh debris spawners. Normal sized chunks

#exec OBJ LOAD FILE=..\Meshes\c_FX.dmx

defaultproperties
{
     Mesh=DukeMesh'c_FX.Gib_MetalB'
}
