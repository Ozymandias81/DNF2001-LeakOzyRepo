//=============================================================================
// dnFireworks1a. ( AHB3d )
//=============================================================================
class dnFireworks1a expands dnFireworks1;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     UpdateEnabled=True
     AdditionalSpawn(0)=(SpawnClass=None,Mount=False)
     AdditionalSpawn(1)=(SpawnClass=None,Mount=False)
     SpawnNumber=2
     SpawnPeriod=0.000000
     PrimeTime=0.000000
     PrimeTimeIncrement=0.050000
     MaximumParticles=0
     Lifetime=1.250000
     LifetimeVariance=2.500000
     SpawnAtRadius=False
     SpawnAtHeight=False
     RelativeLocation=False
     RelativeRotation=False
     InitialVelocity=(X=-128.000000)
     InitialAcceleration=(Z=950.000000)
     BounceElasticity=0.000000
     UseZoneVelocity=False
     Textures(0)=Texture't_generic.lensflares.genwinflare2BC'
     StartDrawScale=1.500000
     EndDrawScale=0.010000
     PulseSeconds=0.100000
     LifeSpan=0.000000
     CollisionRadius=32.000000
}
