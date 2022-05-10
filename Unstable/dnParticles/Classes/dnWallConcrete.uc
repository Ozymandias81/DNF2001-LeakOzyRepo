//=============================================================================
// dnWallConcrete.                                                created by AB
//=============================================================================
class dnWallConcrete expands dnWallFX;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=False
     DestroyWhenEmpty=True
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnWallSmoke')
     AdditionalSpawn(1)=(SpawnClass=Class'dnParticles.dnWallConcreteSpark')
     SpawnNumber=0
     SpawnPeriod=0.000000
     PrimeCount=3
     PrimeTimeIncrement=0.000000
     MaximumParticles=3
     Lifetime=1.250000
     RelativeSpawn=True
     InitialVelocity=(X=192.000000,Z=0.000000)
     MaxVelocityVariance=(X=128.000000,Y=96.000000,Z=96.000000)
     BounceElasticity=0.250000
     LineStartColor=(R=166,G=166,B=166)
     LineEndColor=(R=232,G=232,B=232)
     Textures(0)=Texture't_generic.concrtparticles.concrtpart1aRC'
     Textures(1)=Texture't_generic.concrtparticles.concrtpart1bRC'
     Textures(2)=Texture't_generic.concrtparticles.concrtpart1cRC'
     Textures(3)=Texture't_generic.concrtparticles.concrtpart1dRC'
     Textures(4)=Texture't_generic.concrtparticles.concrtpart1eRC'
     Textures(5)=Texture't_generic.concrtparticles.concrtpart1fRC'
     DrawScaleVariance=0.100000
     StartDrawScale=0.050000
     EndDrawScale=0.050000
     TriggerType=SPT_None
     PulseSeconds=0.001000
     bHidden=True
     TimeWarp=0.500000
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     Style=STY_Masked
}
