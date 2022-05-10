//=============================================================================
// dnRobotShockFX_SparkBeamA. 				Feb 16th, 2001 - Charlie Wiederhold
//=============================================================================
class dnRobotShockFX_SparkBeamA expands BeamSystem;

// Spark beam that the robot sends to their target

defaultproperties
{
     TesselationLevel=5
     MaxAmplitude=25.000000
     MaxFrequency=0.000010
     BeamColor=(G=128,B=255)
     BeamEndColor=(G=128,B=255)
     BeamStartWidth=6.000000
     BeamEndWidth=6.000000
     BeamTexture=Texture't_generic.beameffects.beam5bRC'
     TriggerType=BSTT_Reset
     Event=HitMe
     Style=STY_Translucent
     bUnlit=True
}
