//=============================================================================
// dnJetPackFX_HoverBurn. 					June 8th, 2001 - Charlie Wiederhold
//=============================================================================
class dnJetPackFX_HoverBurn expands dnJetPackFX;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=False
     SpawnPeriod=0.050000
     Lifetime=1.000000
     LifetimeVariance=0.100000
     RelativeSpawn=True
     InitialVelocity=(Z=64.000000)
     MaxVelocityVariance=(X=4.000000,Y=4.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_generic.Rain.genrain7RC'
     DrawScaleVariance=0.250000
     StartDrawScale=0.500000
     RotationVariance=65535.000000
     RotationVelocityMaxVariance=1.000000
     UpdateWhenNotVisible=True
     AlphaStart=0.000000
     AlphaMid=1.000000
     AlphaEnd=0.000000
     AlphaRampMid=0.750000
     bUseAlphaRamp=True
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     Style=STY_Translucent
     bUnlit=True
}
