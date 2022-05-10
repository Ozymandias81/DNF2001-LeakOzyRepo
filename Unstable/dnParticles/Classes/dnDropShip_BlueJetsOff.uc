//=============================================================================
// dnDropShip_BlueJetsOff. 				December 1st, 2000 - Charlie Wiederhold
//=============================================================================
class dnDropShip_BlueJetsOff expands dnDropShip_BlueJets;

// Blue jets that spawn from the Generic EDF drop ship (defaults off)

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx
#exec OBJ LOAD FILE=..\sounds\a_transport.dfx

defaultproperties
{
     Enabled=False
     DestroyWhenEmptyAfterSpawn=False
     TriggerType=SPT_Toggle
     SoundRadius=64
}
