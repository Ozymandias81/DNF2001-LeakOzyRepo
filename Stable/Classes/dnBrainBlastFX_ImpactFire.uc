//=============================================================================
// dnBrainBlastFX_ImpactFire. 			  April 19th, 2001 - Charlie Wiederhold
//=============================================================================
class dnBrainBlastFX_ImpactFire expands dnBrainBlastFX;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=False
     DestroyWhenEmpty=True
     SpawnNumber=0
     PrimeCount=8
     PrimeTimeIncrement=0.000000
     MaximumParticles=8
     Lifetime=0.750000
     LifetimeVariance=0.250000
     InitialVelocity=(Z=0.000000)
     MaxVelocityVariance=(X=192.000000,Y=192.000000,Z=192.000000)
     MaxAccelerationVariance=(X=8.000000,Y=8.000000,Z=8.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_generic.plasma1aMW'
     Textures(1)=Texture't_generic.plasma1bMW'
     DrawScaleVariance=0.500000
     StartDrawScale=2.500000
     EndDrawScale=0.000000
     RotationVariance=65535.000000
     RotationVelocityMaxVariance=2.000000
     UpdateWhenNotVisible=True
     TriggerType=SPT_None
     AlphaEnd=0.000000
     VisibilityRadius=6000.000000
     VisibilityHeight=6000.000000
     CollisionRadius=32.000000
     CollisionHeight=32.000000
     Style=STY_Translucent
     bUnlit=True
}
