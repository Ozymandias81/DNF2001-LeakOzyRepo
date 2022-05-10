//=============================================================================
// dnDebrisMisc_CeilingDust. 			  March 12th, 2001 - Charlie Wiederhold
//=============================================================================
class dnDebrisMisc_CeilingDust expands dnDebris;

// Root of the ceiling dust particles. Like when explosions happen, etc.

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     DestroyWhenEmptyAfterSpawn=True
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnDebrisMisc_CeilingChunks')
     SpawnPeriod=0.050000
     MaximumParticles=10
     Lifetime=0.750000
     LifetimeVariance=0.250000
     InitialVelocity=(Z=-192.000000)
     MaxVelocityVariance=(X=4.000000,Y=4.000000)
     LocalFriction=384.000000
     UseZoneGravity=False
     Textures(0)=Texture't_generic.dirtparticle.dirtparticle1dR'
     DrawScaleVariance=0.325000
     StartDrawScale=0.175000
     EndDrawScale=0.625000
     RotationVariance=65535.000000
     TriggerAfterSeconds=0.400000
     TriggerType=SPT_Disable
     PulseSeconds=2.500000
     AlphaVariance=0.250000
     AlphaStart=0.500000
     AlphaEnd=0.000000
     CollisionRadius=2.000000
     CollisionHeight=24.000000
     Style=STY_Translucent
}
