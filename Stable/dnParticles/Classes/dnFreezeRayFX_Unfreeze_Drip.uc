//=============================================================================
// dnFreezeRayFX_Unfreeze_Drip. 		   June 11th, 2001 - Charlie Wiederhold
//=============================================================================
class dnFreezeRayFX_Unfreeze_Drip expands dnFreezeRayFX;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     SpawnPeriod=0.500000
     MaximumParticles=1
     Lifetime=0.250000
     LifetimeVariance=0.250000
     InitialVelocity=(Z=0.000000)
     MaxVelocityVariance=(X=8.000000,Y=8.000000)
     Textures(0)=Texture't_generic.Rain.genrain2RC'
     StartDrawScale=0.125000
     EndDrawScale=0.125000
     RotationAcceleration=0.025000
     UpdateWhenNotVisible=True
     TriggerType=SPT_Disable
     AlphaMid=1.000000
     AlphaEnd=0.000000
     AlphaRampMid=0.750000
     bUseAlphaRamp=True
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     Style=STY_Translucent
     bUnlit=True
}
