//=============================================================================
// dnLaserRifleFX_ResidualSmoke. 		 April 17th, 20001 - Charlie Wiederhold
//=============================================================================
class dnLaserRifleFX_ResidualSmoke expands dnLaserRifleFX;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     TesselationLevel=7
     BeamStartWidth=8.000000
     BeamEndWidth=8.000000
     BeamColor=(R=235,G=186,B=187)
     BeamEndColor=(R=235,G=186,B=187)
     MaxAmplitude=9.000000
     AmplitudeVelocity=-8.800000
     MaxFrequency=0.060000
     FrequencyVelocity=-0.060000
     BeamTexture=Texture't_generic.beameffects.beam1RC'
     BeamType=BST_SineWave
     TriggerType=BSTT_Reset
     LifeSpan=0.750000
     Style=STY_Translucent
}
