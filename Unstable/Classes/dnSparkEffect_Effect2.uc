//=============================================================================
// dnSparkEffect_Effect2. 							Keith Schuler April 13,2000
//=============================================================================
class dnSparkEffect_Effect2 expands dnSparkEffect;

// Spark effect
// Does NOT do damage. 
// Large explosive spray of sparks

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=False
     AdditionalSpawn(0)=(SpawnClass=None)
     PrimeCount=25
     Lifetime=1.000000
     LifetimeVariance=1.000000
     InitialAcceleration=(Z=-100.000000)
     MaxVelocityVariance=(X=390.000000,Y=390.000000,Z=390.000000)
     LineStartColor=(R=255,G=198,B=140)
     LineEndColor=(R=255,G=255,B=255)
     LineStartWidth=10.000000
     LineEndWidth=10.000000
     Textures(0)=Texture't_generic.Sparks.comettrail4RC'
     StartDrawScale=0.010000
     EndDrawScale=0.750000
     RotationVariance=32767.000000
     TriggerOnSpawn=True
     TriggerType=SPT_Pulse
     PulseSeconds=0.000000
}
