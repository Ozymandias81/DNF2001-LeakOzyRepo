//=============================================================================
// dnJetPackFX_HoverHaze. 					June 7th, 2001 - Charlie Wiederhold
//=============================================================================
class dnJetPackFX_HoverHaze expands dnJetPackFX;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=False
     RelativeLocation=True
     RelativeRotation=True
     InitialVelocity=(Z=16.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_generic.keypad.genkeylightgrn1'
     StartDrawScale=0.750000
     EndDrawScale=0.325000
     RotationVariance=65535.000000
     RotationVelocityMaxVariance=2.000000
     UpdateWhenNotVisible=True
     AlphaStart=0.150000
     AlphaMid=0.150000
     AlphaEnd=0.000000
     AlphaRampMid=0.750000
     bUseAlphaRamp=True
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     Style=STY_Translucent
     bUnlit=True
}
