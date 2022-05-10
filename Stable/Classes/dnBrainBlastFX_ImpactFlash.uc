//=============================================================================
// dnBrainBlastFX_ImpactFlash. 			  April 18th, 2001 - Charlie Wiederhold
//=============================================================================
class dnBrainBlastFX_ImpactFlash expands dnBrainBlastFX;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=False
     DestroyWhenEmpty=True
     SpawnNumber=0
     PrimeCount=1
     PrimeTimeIncrement=0.000000
     MaximumParticles=1
     Lifetime=0.250000
     InitialVelocity=(Z=0.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_generic.particle_efx.pflare2'
     StartDrawScale=16.000000
     EndDrawScale=0.000000
     RotationVariance=65535.000000
     UpdateWhenNotVisible=True
     TriggerType=SPT_None
     VisibilityRadius=6000.000000
     VisibilityHeight=6000.000000
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     Style=STY_Translucent
}
