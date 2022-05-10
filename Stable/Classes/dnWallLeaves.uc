//=============================================================================
// dnWallLeaves.                                                   created by AB
//=============================================================================
class dnWallLeaves expands dnWallFX;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=False
     DestroyWhenEmpty=True
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnWallSmoke')
     SpawnNumber=0
     SpawnPeriod=0.000000
     PrimeCount=3
     PrimeTimeIncrement=0.000000
     MaximumParticles=3
     Lifetime=3.000000
     LifetimeVariance=1.000000
     RelativeSpawn=True
     InitialVelocity=(X=256.000000,Z=0.000000)
     MaxVelocityVariance=(X=256.000000,Y=128.000000,Z=128.000000)
     RealtimeAccelerationVariance=(X=2048.000000,Y=2048.000000,Z=512.000000)
     LocalFriction=945.000000
     BounceElasticity=0.100000
     UseZoneGravity=False
     UseZoneVelocity=False
     SineWaveFrequency=30.000000
     VelocityAmplitude=(X=1280.000000)
     LineStartColor=(R=232,G=142,B=113)
     LineEndColor=(R=255,G=253,B=176)
     Textures(0)=Texture't_generic.stuffing.stuffing4aRC'
     Textures(1)=Texture't_generic.stuffing.stuffing4bRC'
     Textures(2)=Texture't_generic.stuffing.stuffing4cRC'
     DrawScaleVariance=0.020000
     StartDrawScale=0.045000
     EndDrawScale=0.045000
     RotationVariance=32768.000000
     RotationVelocity=2.000000
     RotationVelocityMaxVariance=4.000000
     TriggerType=SPT_None
     PulseSeconds=0.000000
     PulseMagnitude=0.100000
     bHidden=True
     TimeWarp=0.750000
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     Style=STY_Masked
}
