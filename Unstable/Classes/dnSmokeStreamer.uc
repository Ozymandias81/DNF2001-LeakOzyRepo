//=============================================================================
// dnSmokeStreamer. Keith Schuler 4/19/2001
// Fire this system with velocity and it will leave a stream of smoke behind
// Designed primarily for use with large, showy explosions like the Lady
// Killer sign
//=============================================================================
class dnSmokeStreamer expands dnSmokeEffect;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=False
     AdditionalSpawn(0)=(TakeParentTag=True,Mount=True)
     SpawnPeriod=0.000000
     MaximumParticles=0
     Lifetime=2.000000
     LifetimeVariance=0.000000
     Textures(1)=None
     Textures(2)=None
     Textures(3)=None
     DrawScaleVariance=0.250000
     StartDrawScale=0.200000
     EndDrawScale=2.250000
     AlphaStart=1.000000
     AlphaEnd=0.750000
     SystemAlphaScaleVelocity=-0.500000
     TriggerOnSpawn=True
     PulseSeconds=0.650000
     CollisionRadius=1.000000
     CollisionHeight=1.000000
     bCollideWorld=True
     bMeshLowerByCollision=False
     Physics=PHYS_Falling
}
