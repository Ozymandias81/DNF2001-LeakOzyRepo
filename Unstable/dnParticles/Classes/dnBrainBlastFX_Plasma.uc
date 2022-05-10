//=============================================================================
// dnBrainBlastFX_Plasma. 				  April 18th, 2001 - Charlie Wiederhold
//=============================================================================
class dnBrainBlastFX_Plasma expands dnBrainBlastFX;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     DestroyWhenEmptyAfterSpawn=True
     SpawnNumber=2
     SpawnPeriod=0.050000
     MaximumParticles=50
     Lifetime=1.000000
     LifetimeVariance=0.200000
     RelativeLocation=True
     RelativeRotation=True
     InitialVelocity=(X=-60.000000,Z=0.000000)
     InitialAcceleration=(X=-80.000000)
     MaxVelocityVariance=(X=1.000000,Y=1.000000,Z=4.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_generic.plasma1aMW'
     Textures(1)=Texture't_generic.plasma1bMW'
     DrawScaleVariance=0.100000
     StartDrawScale=0.625000
     EndDrawScale=0.325000
     RotationVariance=65535.000000
     RotationVelocity=1.000000
     UpdateWhenNotVisible=True
     TriggerOnDismount=True
     TriggerType=SPT_Disable
     AlphaMid=0.500000
     AlphaEnd=0.000000
     AlphaRampMid=0.750000
     bUseAlphaRamp=True
     VisibilityRadius=6000.000000
     VisibilityHeight=6000.000000
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     Style=STY_Translucent
     bUnlit=True
}
