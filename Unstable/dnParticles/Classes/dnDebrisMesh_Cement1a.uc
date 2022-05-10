//=============================================================================
// dnDebrisMesh_Cement1a. 			  September 21st, 2000 - Charlie Wiederhold
//=============================================================================
class dnDebrisMesh_Cement1a expands dnDebrisMesh_Cement1;

// Sub piece of the cement mesh debris spawners. Normal sized chunks

#exec OBJ LOAD FILE=..\Meshes\c_FX.dmx

defaultproperties
{
     Mesh=DukeMesh'c_FX.Gib_ConcreteB'
}
