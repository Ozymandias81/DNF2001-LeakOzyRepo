//=============================================================================
// dnBlood_Spurt1.               created by Allen H. Blum III (c)April 12, 2000
//=============================================================================
class dnBlood_Spurt1 expands SoftParticleSystem;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=False
     DestroyWhenEmpty=True
     SpawnPeriod=0.000000
     PrimeTime=0.100000
     PrimeTimeIncrement=0.005000
     MaximumParticles=50
     Lifetime=2.000000
     LifetimeVariance=0.500000
     RelativeSpawn=True
     InitialVelocity=(X=100.000000,Z=0.000000)
     InitialAcceleration=(Z=400.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000)
     MaxAccelerationVariance=(X=50.000000,Y=50.000000,Z=50.000000)
     BounceElasticity=0.100000
     Bounce=True
     DieOnBounce=True
     ParticlesCollideWithWorld=True
     Textures(0)=Texture't_generic.blooddrops.blooddrop5aRC'
     Textures(1)=Texture't_generic.blooddrops.blooddrop5bRC'
     Textures(2)=Texture't_generic.blooddrops.blooddrop5cRC'
     Textures(3)=Texture't_generic.blooddrops.blooddrop5dRC'
     Textures(4)=Texture't_generic.blooddrops.blooddrop5eRC'
     Textures(5)=Texture't_generic.blooddrops.blooddrop5fRC'
     StartDrawScale=0.050000
     EndDrawScale=0.090000
     SpawnOnBounceChance=0.100000
     UpdateWhenNotVisible=True
     TriggerOnSpawn=True
     TriggerType=SPT_Pulse
     PulseSeconds=0.001000
     bHidden=True
     Physics=PHYS_MovingBrush
     Style=STY_Modulated
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     bFixedRotationDir=True
}
