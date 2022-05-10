//=============================================================================
// dnWallOilDrip.                                                 created by AB
//=============================================================================
class dnWallOilDrip expands dnWallOil;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     AdditionalSpawn(1)=(SpawnClass=None)
     spawnPeriod=0.200000
     Lifetime=2.000000
     InitialVelocity=(X=8.000000,Z=0.000000)
     InitialAcceleration=(Z=-700.000000)
     StartDrawScale=0.010000
     EndDrawScale=0.040000
}
