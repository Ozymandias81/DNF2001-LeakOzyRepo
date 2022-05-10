//=============================================================================
// dnWallSteam.                                                   created by AB
//=============================================================================
class dnWallSteam expands dnWallFX;

// Steam Line Smoke

// NOTE - to turn on...
// Set TriggerOnSpawn to True when we have line alpha..
// Set UseLines to True

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=False
     DestroyWhenEmpty=True
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnWallSteam2',Mount=True,MountOrigin=(X=4.000000))
     AdditionalSpawn(1)=(SpawnClass=Class'dnParticles.dnWallSpark')
     SpawnNumber=3
     SpawnPeriod=0.050000
     PrimeTime=0.100000
     Lifetime=0.075000
     LifetimeVariance=0.050000
     RelativeSpawn=True
     InitialVelocity=(X=64.000000,Z=0.000000)
     InitialAcceleration=(X=-64.000000)
     MaxVelocityVariance=(X=16.000000,Y=32.000000,Z=32.000000)
     BounceElasticity=0.250000
     UseZoneGravity=False
     UseLines=True
     LineStartColor=(R=8,G=8,B=8)
     LineEndColor=(R=24,G=24,B=24)
     TriggerOnSpawn=True
     TriggerType=SPT_Pulse
     PulseSeconds=4.000000
     bHidden=True
     CollisionRadius=1.000000
     CollisionHeight=1.000000
}
