//=============================================================================
// dnProtonMonitor_HoloBeamA. 			  March 22nd, 2001 - Charlie Wiederhold
//=============================================================================
class dnProtonMonitor_HoloBeamA expands BeamSystem;

// Beams drawing the holo Proton image

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     TesselationLevel=3
     MaxFrequency=0.000010
     BeamColor=(R=46,G=244,B=11)
     BeamEndColor=(R=46,G=244,B=11)
     BeamStartWidth=8.000000
     BeamEndWidth=8.000000
     BeamTexture=Texture't_generic.beameffects.beam5aRC'
     BeamBrokenIgnoreWorld=True
     TriggerType=BSTT_Reset
     BeamBrokenAction=BBA_TriggerEvent
     Physics=PHYS_MovingBrush
     bUnlit=True
}
