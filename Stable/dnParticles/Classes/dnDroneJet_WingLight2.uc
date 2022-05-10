//=============================================================================
// dnDroneJet_WingLight2.                          Charlie Wiederhold 4/18/2000
//=============================================================================
class dnDroneJet_WingLight2 expands dnLensFlares;

// White Lens Flare light for the Drone Jet
// Does NOT do damage. 

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Textures(0)=Texture't_generic.lensflares.lensflare7RC'
}
