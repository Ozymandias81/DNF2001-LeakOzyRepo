//=============================================================================
// dnBrainBlastFX_ShrinkBlast_CenterGlow. 			  April 18th, 2001 - Charlie Wiederhold
//=============================================================================
class dnBrainBlastFX_ShrinkBlast_CenterGlow expands dnBrainBlastFX;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnBrainBlastFX_Plasma',Mount=True,MountOrigin=(X=-24.000000))
     SpawnPeriod=0.200000
     PrimeCount=1
     PrimeTimeIncrement=0.000000
     Lifetime=0.400000
     RelativeLocation=True
     RelativeRotation=True
     InitialVelocity=(Z=0.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture'dnModulation.cappey1tw'
     StartDrawScale=0.300000
     EndDrawScale=0.300000
     RotationVariance=65535.000000
     RotationVelocityMaxVariance=1.000000
     UpdateWhenNotVisible=True
     TriggerType=SPT_None
     AlphaStart=0.000000
     AlphaMid=1.000000
     AlphaEnd=0.000000
     bUseAlphaRamp=True
     VisibilityRadius=6000.000000
     VisibilityHeight=6000.000000
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     Style=STY_Translucent
     bUnlit=True
}
