//=============================================================================
// dnBUDDBotFX_HoverHaze.				January 25th, 2001 - Charlie Wiederhold
//=============================================================================
class dnBUDDBotFX_HoverHaze expands dnBUDDBotFX;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     SpawnPeriod=0.075000
     Lifetime=0.325000
     RelativeLocation=True
     RelativeRotation=True
     InitialVelocity=(Z=32.000000)
     MaxVelocityVariance=(X=16.000000,Y=16.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_generic.LensFlares.blu_glow1'
     StartDrawScale=0.750000
     EndDrawScale=0.750000
     UpdateWhenNotVisible=True
     AlphaStart=0.500000
     AlphaEnd=0.000000
     bBurning=True
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     Style=STY_Translucent
}
