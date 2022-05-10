//=============================================================================
// dnShrinkBeamFX_WrapUp. 				  April 24th, 2001 - Charlie Wiederhold
//=============================================================================
class dnShrinkBeamFX_WrapUp expands dnShrinkBeamFX;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     TesselationLevel=4
     MaxAmplitude=10.000000
     MaxFrequency=0.010000
     BeamColor=(R=255,G=255,B=255)
     BeamEndColor=(R=255,G=255,B=255)
     BeamStartWidth=1.500000
     BeamEndWidth=1.500000
     BeamTexture=Texture'm_dnWeapon.shrnklight10BC'
     TriggerType=BSTT_Reset
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     Style=STY_Translucent
     bUnlit=True
}
