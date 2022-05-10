//=============================================================================
// dnLeaves.
//=============================================================================
class dnLeaves expands dnDebris;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=False
     DestroyWhenEmpty=True
     SpawnNumber=0
     SpawnPeriod=0.000000
     PrimeCount=6
     MaximumParticles=6
     Lifetime=3.000000
     LifetimeVariance=1.000000
     SpawnAtRadius=True
     SpawnAtHeight=True
     InitialVelocity=(Z=256.000000)
     MaxVelocityVariance=(X=512.000000,Y=512.000000,Z=384.000000)
     RealtimeAccelerationVariance=(X=3084.000000,Y=3084.000000,Z=512.000000)
     LocalFriction=945.000000
     BounceElasticity=0.100000
     ParticlesCollideWithWorld=True
     LineStartColor=(R=232,G=142,B=113)
     LineEndColor=(R=255,G=253,B=176)
     Textures(0)=Texture't_generic.Leaves.leaf1a'
     Textures(1)=Texture't_generic.Leaves.leaf2a'
     Textures(2)=Texture't_generic.Leaves.leaf3a'
     DrawScaleVariance=0.062500
     StartDrawScale=0.125000
     EndDrawScale=0.125000
     RotationVariance=32768.000000
     RotationVelocity=2.000000
     RotationVelocityMaxVariance=4.000000
     TriggerType=SPT_None
     PulseSeconds=0.000000
     bHidden=True
     TimeWarp=0.750000
     CollisionRadius=8.000000
     CollisionHeight=18.000000
     Style=STY_Masked
     bUnlit=True
}
