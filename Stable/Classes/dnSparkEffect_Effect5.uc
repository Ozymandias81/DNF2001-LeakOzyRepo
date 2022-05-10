//=============================================================================
// dnSparkEffect_Effect5.
//=============================================================================
class dnSparkEffect_Effect5 expands dnSparkEffect;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=False
     AdditionalSpawn(0)=(SpawnClass=None)
     SpawnNumber=1
     Lifetime=1.000000
     RelativeSpawn=True
     InitialAcceleration=(Z=-50.000000)
     MaxAccelerationVariance=(Z=10.000000)
     Textures(0)=Texture't_generic.Sparks.comettrail4RC'
     StartDrawScale=0.125000
     EndDrawScale=0.250000
     RotationVariance=32767.000000
     TriggerOnSpawn=True
     TriggerType=SPT_Pulse
     PulseSeconds=0.650000
     AlphaRampMid=0.250000
     CollisionRadius=16.000000
     CollisionHeight=16.000000
     bCollideWorld=True
     bMeshLowerByCollision=False
     Physics=PHYS_Falling
}
