//=============================================================================
// dnEMPShockFX_SparkBeamA. 				Feb 16th, 2001 - Charlie Wiederhold
//=============================================================================
class dnEMPShockFX_SparkBeamA expands BeamSystem;

// Spark beam that the robot sends to their target

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

function PostBeginPlay()
{
	Super.PostBeginPlay();

	Enable( 'Tick' );
}

function Tick( float Delta )
{
	if ( Physics != PHYS_MovingBrush )
	{
		SetPhysics( PHYS_MovingBrush );
		Disable( 'Tick' );
	}
}

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
     BeamTextureScaleX=4.000000
     TriggerType=BSTT_Reset
     Event=HitMe
     LifeSpan=1.100000
     Style=STY_Translucent
     bUnlit=True
}
