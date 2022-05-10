//=============================================================================
// dnSparkEffect_Effect1.							Keith Schuler April 13,2000
//=============================================================================
class dnSparkEffect_Effect1 expands dnSparkEffect;

// Spark effect
// Does NOT do damage. 
// Small explosive spray of sparks

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=False
     AdditionalSpawn(0)=(SpawnClass=None)
     SpawnNumber=4
     Lifetime=0.500000
     LifetimeVariance=1.500000
     InitialVelocity=(Y=100.000000)
     InitialAcceleration=(Z=400.000000)
     MaxVelocityVariance=(X=200.000000,Y=100.000000,Z=200.000000)
     UseZoneGravity=True
     UseLines=True
     ConstantLength=True
     LineStartColor=(R=255,G=255,B=255)
     LineEndColor=(R=255,G=255,B=255)
     LineStartWidth=6.000000
     LineEndWidth=6.000000
     Textures(0)=Texture't_generic.Sparks.spark3RC'
     DrawScaleVariance=2.000000
     StartDrawScale=15.000000
     EndDrawScale=25.000000
     TriggerOnSpawn=True
     TriggerType=SPT_Pulse
}
