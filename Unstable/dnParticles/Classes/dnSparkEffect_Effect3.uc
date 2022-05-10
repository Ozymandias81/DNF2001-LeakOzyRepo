//=============================================================================
// dnSparkEffect_Effect3. 							Keith Schuler April 13,2000
//=============================================================================
class dnSparkEffect_Effect3 expands dnSparkEffect;

// Spark effect
// Does NOT do damage. 
// Fire in a direction for a spark streamer

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=False
     AdditionalSpawn(0)=(SpawnClass=None)
     SpawnNumber=1
     Lifetime=0.500000
     RelativeSpawn=True
     InitialAcceleration=(Z=-50.000000)
     MaxAccelerationVariance=(Z=10.000000)
     LineStartColor=(R=128,G=128,B=128)
     LineEndColor=(R=128,G=128,B=128)
     LineStartWidth=4.000000
     LineEndWidth=4.000000
     Textures(0)=Texture't_generic.Sparks.comettrail4RC'
     StartDrawScale=0.125000
     EndDrawScale=0.250000
     AlphaRampMid=0.250000
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
