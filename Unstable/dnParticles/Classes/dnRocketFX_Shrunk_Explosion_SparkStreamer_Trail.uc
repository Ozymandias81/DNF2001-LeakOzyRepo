//=============================================================================
// dnRocketFX_Shrunk_Explosion_SparkStreamer_Trail. 							
// August 8th, 2001 - Charlie Wiederhold
//=============================================================================
class dnRocketFX_Shrunk_Explosion_SparkStreamer_Trail expands dnRocketFX_Shrunk;

// Spark effect
// Does NOT do damage. 
// Fire in a direction for a spark streamer

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     DestroyWhenEmptyAfterSpawn=True
     SpawnPeriod=0.0250000
     PrimeCount=1
     Lifetime=0.1250000
     RelativeSpawn=True
     InitialVelocity=(Z=0.000000)
     MaxVelocityVariance=(X=8.000000,Y=8.000000,Z=8.000000)
     UseZoneGravity=False
     Textures(0)=Texture't_generic.fireflames.flame1aRC'
     Textures(1)=Texture't_generic.fireflames.flame2aRC'
     Textures(2)=Texture't_generic.fireflames.flame3aRC'
     Textures(3)=Texture't_generic.fireflames.flame4aRC'
     StartDrawScale=0.150000
     EndDrawScale=0.100000
     RotationVariance=65535.000000
     RotationVelocityMaxVariance=1.000000
     UpdateWhenNotVisible=True
     TriggerAfterSeconds=0.50000
     TriggerOnDismount=True
     TriggerType=SPT_Disable
     PulseSeconds=0.000000
     AlphaRampMid=0.250000
     bBurning=True
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     bCollideWorld=True
     bMeshLowerByCollision=False
     Physics=PHYS_Falling
     Style=STY_Translucent
     bUnlit=True
     bIgnoreBList=True
}
