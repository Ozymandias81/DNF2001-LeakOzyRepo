//=============================================================================
// dnShrinkBeamFX_MainStream. 			  April 24th, 2001 - Charlie Wiederhold
//=============================================================================
class dnShrinkBeamFX_MainStream expands dnShrinkBeamFX;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     BeamColor=(R=255,G=255,B=255)
     BeamEndColor=(R=255,G=255,B=255)
     BeamStartWidth=8.000000
     BeamEndWidth=16.000000
     BeamTexture=Texture't_generic.beameffects.elect1aRC'
     BeamTextureScaleX=2.000000
     BeamTexturePanX=-0.500000
     ScaleToWorld=True
     BeamType=BST_Straight
     TriggerType=BSTT_Reset
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     Style=STY_Translucent
     bUnlit=True
}
