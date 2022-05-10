//=============================================================================
// dnWeaponFX_NukeFire. 			   November 29th, 2000 - Charlie Wiederhold
//=============================================================================
class dnWeaponFX_NukeFire expands dnWeaponFX_RPGFire;

// This is the fire cone hanging out the back of the Nuke

#exec OBJ LOAD FILE=..\meshes\c_FX.dmx

defaultproperties
{
     Mesh=DukeMesh'c_FX.fire_jetblue'
     DrawScale=0.550000
}
