//=============================================================================
// dnDebrisMisc_CeilingChunks. 			  March 13th, 2001 - Charlie Wiederhold
//=============================================================================
class dnDebrisMisc_CeilingChunks expands dnDebris;

// Root of the ceiling chunk particles. Like when explosions happen, etc.

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=False
     DestroyWhenEmpty=True
     SpawnPeriod=0.050000
     PrimeCount=2
     MaximumParticles=12
     Lifetime=1.000000
     LifetimeVariance=0.325000
     InitialVelocity=(Z=0.000000)
     MaxVelocityVariance=(X=4.000000,Y=4.000000,Z=64.000000)
     LocalFriction=128.000000
     BounceElasticity=0.250000
     Textures(0)=Texture't_generic.concrtparticles.concrtpart1aRC'
     Textures(1)=Texture't_generic.concrtparticles.concrtpart1bRC'
     Textures(2)=Texture't_generic.concrtparticles.concrtpart1cRC'
     Textures(3)=Texture't_generic.concrtparticles.concrtpart1eRC'
     Textures(4)=Texture't_generic.concrtparticles.concrtpart1dRC'
     Textures(5)=Texture't_generic.concrtparticles.concrtpart1fRC'
     DrawScaleVariance=0.075000
     StartDrawScale=0.100000
     EndDrawScale=0.100000
     RotationVariance=65535.000000
     TriggerOnSpawn=True
     TriggerType=SPT_Pulse
     PulseSeconds=0.300000
     PulseSecondsVariance=0.150000
     TimeWarp=0.750000
     CollisionRadius=4.000000
     CollisionHeight=4.000000
     Style=STY_Masked
}
