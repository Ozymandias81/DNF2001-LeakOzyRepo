//=============================================================================
// dnDebrisMesh_Cement1b.  			  September 21st, 2000 - Charlie Wiederhold
//=============================================================================
class dnDebrisMesh_Cement1b expands dnDebrisMesh_Cement1;

// Sub piece of the cement mesh debris spawners. Normal sized chunks

#exec OBJ LOAD FILE=..\Meshes\c_FX.dmx

defaultproperties
{
     Mesh=DukeMesh'c_FX.Gib_ConcreteC'
}
