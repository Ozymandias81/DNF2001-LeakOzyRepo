//=============================================================================
// dnDebris_Smoke. 				      September 20th, 2000 - Charlie Wiederhold
//=============================================================================
class dnDebris_Smoke expands dnDebris;

// Root of the smoke/dust debris spawner. Puff of white residual smoke.

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
     Textures(0)=Texture't_generic.Smoke.gensmoke1cRC'
     DrawScaleVariance=0.500000
     StartDrawScale=0.500000
     AlphaEnd=0.000000
     RotationVariance=65535.000000
     TriggerType=SPT_None
     Style=STY_Translucent
     bUnlit=True
     CollisionRadius=0.000000
     CollisionHeight=0.000000
}
