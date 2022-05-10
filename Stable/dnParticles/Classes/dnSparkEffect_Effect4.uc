//=============================================================================
// dnSparkEffect_Effect4.
//=============================================================================
class dnSparkEffect_Effect4 expands dnSparkEffect;


// Spark Shower
// Stephen Cole

defaultproperties
{
     Enabled=False
     AdditionalSpawn(0)=(SpawnClass=None)
     SpawnNumber=3
     Lifetime=1.500000
     LifetimeVariance=1.500000
     InitialVelocity=(X=220.000000,Y=220.000000,Z=-220.000000)
     InitialAcceleration=(Z=-1000.000000)
     MaxVelocityVariance=(X=1900.000000,Y=1900.000000,Z=4900.000000)
     UseZoneGravity=True
     UseLines=True
     LineStartColor=(R=255,G=249,B=215)
     LineEndColor=(R=255,G=255,B=255)
     StartDrawScale=0.250000
     TriggerOnSpawn=True
     TriggerType=SPT_Pulse
 	 UpdateWhenNotVisible=true
}
