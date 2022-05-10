//=============================================================================
// dnDroneJet_WingLight1.                          Charlie Wiederhold 4/18/2000
//=============================================================================
class dnDroneJet_WingLight1 expands dnLensFlares;

// Red Lens Flare light for the Drone Jet
// Does NOT do damage. 

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Textures(0)=Texture't_generic.lensflares.flare3sah'
}
