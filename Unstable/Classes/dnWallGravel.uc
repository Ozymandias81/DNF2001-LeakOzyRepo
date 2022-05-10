//=============================================================================
// dnWallGravel.                                                   created by AB
//=============================================================================
class dnWallGravel expands dnWallFX;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=False
     DestroyWhenEmpty=True
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnWallDust')
     SpawnNumber=0
     SpawnPeriod=0.000000
     PrimeCount=3
     PrimeTimeIncrement=0.000000
     MaximumParticles=3
     Lifetime=1.000000
     RelativeSpawn=True
     InitialVelocity=(X=192.000000,Z=0.000000)
     MaxVelocityVariance=(X=128.000000,Y=128.000000,Z=128.000000)
     BounceElasticity=0.250000
     LineStartColor=(R=232,G=142,B=113)
     LineEndColor=(R=255,G=253,B=176)
     Textures(0)=Texture't_generic.pebbles.pebble2aRC'
     Textures(1)=Texture't_generic.pebbles.pebble2bRC'
     Textures(2)=Texture't_generic.pebbles.pebble2cRC'
     Textures(3)=Texture't_generic.pebbles.pebble2dRC'
     Textures(4)=Texture't_generic.pebbles.pebble2eRC'
     Textures(5)=Texture't_generic.pebbles.pebble2fRC'
     Textures(6)=Texture't_generic.pebbles.pebble2gRC'
     Textures(7)=Texture't_generic.pebbles.pebble2hRC'
     Textures(8)=Texture't_generic.pebbles.pebble2iRC'
     DrawScaleVariance=0.040000
     StartDrawScale=0.050000
     EndDrawScale=0.050000
     RotationVariance=32768.000000
     TriggerType=SPT_None
     PulseSeconds=0.001000
     bHidden=True
     TimeWarp=0.500000
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     Style=STY_Masked
}
