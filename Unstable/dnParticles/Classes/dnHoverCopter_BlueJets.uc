//=============================================================================
// dnHoverCopter_BlueJets. 				   March 8th, 2001 - Charlie Wiederhold
//=============================================================================
class dnHoverCopter_BlueJets expands dnDropShip_BlueJets;

// Blue jets that spawn from the EDF hover copter

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx
#exec OBJ LOAD FILE=..\sounds\a_transport.dfx

defaultproperties
{
     Lifetime=0.625000
     Apex=(Z=80.000000)
     StartDrawScale=2.000000
     EndDrawScale=1.000000
     CollisionRadius=16.000000
     SoundRadius=128
     SoundVolume=64
}
