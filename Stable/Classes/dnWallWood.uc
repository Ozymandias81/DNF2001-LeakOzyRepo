//=============================================================================
// dnWallWood.                                                    created by AB
//=============================================================================
class dnWallWood expands dnWallFX;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=False
     DestroyWhenEmpty=True
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnWallSmoke')
     SpawnNumber=0
     SpawnPeriod=0.000000
     PrimeCount=3
     PrimeTime=0.001000
     PrimeTimeIncrement=0.001000
     MaximumParticles=3
     Lifetime=0.600000
     RelativeSpawn=True
     InitialVelocity=(X=192.000000,Z=0.000000)
     MaxVelocityVariance=(X=128.000000,Y=128.000000,Z=128.000000)
     BounceElasticity=0.250000
     LineStartColor=(R=232,G=142,B=113)
     LineEndColor=(R=255,G=253,B=176)
     Textures(0)=Texture't_generic.woodshards.woodshard4aRC'
     Textures(1)=Texture't_generic.woodshards.woodshard4bRC'
     Textures(2)=Texture't_generic.woodshards.woodshard4cRC'
     Textures(3)=Texture't_generic.woodshards.woodshard4dRC'
     Textures(4)=Texture't_generic.woodshards.woodshard4eRC'
     DrawScaleVariance=0.100000
     StartDrawScale=0.100000
     EndDrawScale=0.100000
     RotationVariance=32768.000000
     TriggerType=SPT_None
     PulseSeconds=0.000000
     bHidden=True
     TimeWarp=0.500000
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     Style=STY_Masked
}
