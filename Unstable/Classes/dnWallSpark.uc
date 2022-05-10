//=============================================================================
// dnWallSpark.                                                   created by AB
//=============================================================================
class dnWallSpark expands dnWallFX;

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
     Lifetime=1.000000
     LifetimeVariance=1.000000
     RelativeSpawn=True
     InitialVelocity=(X=192.000000,Z=0.000000)
     MaxVelocityVariance=(X=128.000000,Y=96.000000,Z=96.000000)
     BounceElasticity=0.250000
     UseLines=True
     ConstantLength=True
     LineStartColor=(R=255,G=255,B=255)
     LineEndColor=(R=255,G=255,B=255)
     LineStartWidth=1.100000
     LineEndWidth=1.100000
     Textures(0)=Texture't_generic.Sparks.spark1RC'
     Textures(1)=Texture't_generic.Sparks.spark2RC'
     Textures(2)=Texture't_generic.Sparks.spark3RC'
     Textures(3)=Texture't_generic.Sparks.spark4RC'
     StartDrawScale=6.000000
     EndDrawScale=12.000000
     TriggerType=SPT_None
     PulseSeconds=0.001000
     bBurning=True
     bHidden=True
     TimeWarp=0.500000
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     Style=STY_Translucent
     bUnlit=True
}
