//=============================================================================
// dnLaserRifleFX_Laser.			     April 17th, 20001 - Charlie Wiederhold
//=============================================================================
class dnLaserRifleFX_Laser expands dnLaserRifleFX;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     TesselationLevel=8
     BeamStartWidth=14.000000
     BeamEndWidth=14.000000
     BeamColor=(R=255,G=255,B=255)
     BeamEndColor=(R=255,G=255,B=255)
     MaxAmplitude=0.000000
     AmplitudeLimit=100.000000
     AmplitudeVelocity=30.000000
     MaxFrequency=0.000000
     FrequencyLimit=0.200000
     FrequencyVelocity=0.100000
     BeamTexture=Texture't_generic.beameffects.beamLaser1aMW'
     ScaleToWorld=True
     BeamType=BST_Straight
     TriggerType=BSTT_Reset
     SystemAlphaScale=0.000000
     SystemAlphaScaleVelocity=0.500000
     LifeSpan=0.200000
     Style=STY_Translucent
     bUnlit=True
}
