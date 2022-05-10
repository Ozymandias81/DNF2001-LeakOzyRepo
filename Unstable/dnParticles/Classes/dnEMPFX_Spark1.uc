//=============================================================================
// dnEMPFX_Spark1. 						October 10th, 2000 - Charlie Wiederhold
//=============================================================================
class dnEMPFX_Spark1 expands dnEMPFX;

// EMP Spark Effect
// Does NOT do damage. 
// Spawns the Constant shower of sparks from an EMP disabled object

defaultproperties
{
     Enabled=True
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnEMPFX')
     AdditionalSpawn(1)=(SpawnClass=Class'dnParticles.dnDebris_SmokeSubtle')
     SpawnNumber=8
     SpawnPeriod=0.500000
     MaximumParticles=16
     Lifetime=1.000000
     InitialVelocity=(Z=192.000000)
     InitialAcceleration=(Z=450.000000)
     MaxVelocityVariance=(X=384.000000,Y=384.000000,Z=160.000000)
     UseZoneGravity=True
     UseZoneVelocity=True
     UseLines=True
     LineStartColor=(R=238,G=233,B=134)
     LineEndColor=(R=255,G=254,B=193)
     Textures(0)=None
     StartDrawScale=1.500000
     EndDrawScale=0.500000
     TriggerAfterSeconds=10.000000
     TriggerType=SPT_Disable
     AlphaEnd=1.000000
     bBurning=True
     Physics=PHYS_MovingBrush
     Style=STY_Normal
}
