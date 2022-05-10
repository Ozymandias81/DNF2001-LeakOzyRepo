//=============================================================================
// dnSparkEffect_Streamer.	Keith Schuler	4/19/2001
// Fire this in some direction with a TriggerSpawn actor
// Spawns a "hot spot" which flies through the air
// Also will spawn smoke and spark streamers behind it
// Used for large spectaculer explosions
//=============================================================================
class dnSparkEffect_Streamer expands dnSparkEffect;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=False
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnSparkEffect_Effect3',TakeParentTag=True,Mount=True)
     AdditionalSpawn(1)=(SpawnClass=Class'dnParticles.dnSmokeStreamer',TakeParentTag=True,Mount=True)
     SpawnNumber=2
     Lifetime=0.100000
     RelativeSpawn=True
     InitialAcceleration=(Z=-10.000000)
     MaxVelocityVariance=(X=20.000000,Y=20.000000,Z=20.000000)
     Textures(0)=Texture't_generic.Sparks.cometspark1RC'
     StartDrawScale=0.700000
     EndDrawScale=0.010000
     RotationVariance=32767.000000
     TriggerOnSpawn=True
     TriggerType=SPT_Pulse
     PulseSeconds=0.650000
     CollisionRadius=16.000000
     CollisionHeight=16.000000
     bCollideWorld=True
     bMeshLowerByCollision=False
     Physics=PHYS_Falling
}
