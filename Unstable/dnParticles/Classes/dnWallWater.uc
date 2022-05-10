//=============================================================================
// dnWallWater.                                                   created by AB
//=============================================================================
class dnWallWater expands dnWallFX;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=False
     DestroyWhenEmpty=True
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnWallSmoke')
     AdditionalSpawn(1)=(SpawnClass=Class'dnParticles.dnWallSpark')
     SpawnPeriod=0.050000
     PrimeTime=0.100000
     Lifetime=1.000000
     LifetimeVariance=0.250000
     RelativeSpawn=True
     InitialVelocity=(X=16.000000,Z=64.000000)
     MaxVelocityVariance=(X=0.000000,Y=8.000000,Z=16.000000)
     RealtimeVelocityVariance=(Y=8.000000,Z=16.000000)
     BounceElasticity=0.250000
     DieOnBounce=True
     UseLines=True
     LineStartColor=(G=6,B=9)
     LineEndColor=(G=39,B=47)
     TriggerOnSpawn=True
     TriggerType=SPT_Pulse
     PulseSeconds=3.000000
     PulseSecondsVariance=6.000000
     bHidden=True
     TimeWarp=0.750000
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     Physics=PHYS_MovingBrush
     bFixedRotationDir=True
     RotationRate=(Pitch=-6000)
}
