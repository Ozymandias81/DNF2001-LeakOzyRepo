//=============================================================================
// dnRocketFX_Shrunk_Explosion_SparkStreamer.	Keith Schuler	4/19/2001
// Fire this in some direction with a TriggerSpawn actor
// Spawns a "hot spot" which flies through the air
// Also will spawn smoke and spark streamers behind it
// Used for large spectaculer explosions
//
// Modified for use by Charlie August 8th, 2001... Take that KEITH!! HAH!
// Oh... and McKenna McKenna McKenna. Hi Matt. Just cause I said so.
// MORE messages that have nothing to do with McKenna... so back off!
//=============================================================================
class dnRocketFX_Shrunk_Explosion_SparkStreamer expands dnRocketFX_Shrunk;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=False
     DestroyWhenEmptyAfterSpawn=True
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnRocketFX_Shrunk_Explosion_SparkStreamer_Trail',TakeParentTag=True,Mount=True)
     AdditionalSpawn(1)=(SpawnClass=Class'dnParticles.dnRocketFX_Shrunk_Explosion_SparkStreamer_Smoke',TakeParentTag=True,Mount=True)
     SpawnPeriod=0.0750000
     Lifetime=0.200000
     RelativeSpawn=True
     RelativeLocation=True
     RelativeRotation=True
     InitialVelocity=(Z=0.000000)
     InitialAcceleration=(Z=-2.500000)
     MaxVelocityVariance=(X=5.000000,Y=5.000000,Z=5.000000)
     UseZoneGravity=False
     Textures(0)=Texture'dnModulation.firebites1tw'
     Textures(1)=Texture'dnModulation.firebites2tw'
     StartDrawScale=0.02500000
     EndDrawScale=0.0812500000
     RotationVariance=32767.000000
     UpdateWhenNotVisible=True
     TriggerOnSpawn=True
     TriggerType=SPT_Pulse
     PulseSeconds=0.75000
     PulseSecondsVariance=0.5000
     bBurning=True
     CollisionRadius=1.000000
     CollisionHeight=1.000000
     bCollideWorld=True
     bMeshLowerByCollision=False
     Physics=PHYS_Falling
     Style=STY_Translucent
     bUnlit=True
     bIgnoreBList=True
     LifeSpan=0.50000
}
