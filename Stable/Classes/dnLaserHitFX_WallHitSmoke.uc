//=============================================================================
// dnLaserHitFX_WallHitSmoke. 			  September 20th, 2000 - Charlie Wiederhold
//=============================================================================
class dnLaserHitFX_WallHitSmoke expands dnLaserHitFX;

// Large subtle puff of white smoke.

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=False
     DestroyWhenEmpty=True
     SpawnNumber=0
     PrimeCount=2
     MaximumParticles=2
     Lifetime=2.500000
     LifetimeVariance=1.000000
     InitialVelocity=(Z=24.000000)
     MaxVelocityVariance=(X=48.000000,Y=48.000000,Z=16.000000)
     UseZoneGravity=False
     Textures(0)=Texture't_generic.Smoke.gensmoke1dRC'
     DrawScaleVariance=0.500000
     StartDrawScale=0.500000
     RotationVariance=65535.000000
     UpdateWhenNotVisible=True
     TriggerType=SPT_None
     AlphaEnd=0.000000
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     Style=STY_Translucent
     bUnlit=True
     bIgnoreBList=True
}
