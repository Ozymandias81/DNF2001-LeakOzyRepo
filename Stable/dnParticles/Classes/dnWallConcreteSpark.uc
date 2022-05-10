//=============================================================================
// dnWallConcreteSpark.
//=============================================================================
class dnWallConcreteSpark expands dnWallConcrete;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     AdditionalSpawn(1)=(SpawnClass=None)
     Lifetime=0.200000
     LifetimeVariance=1.000000
     InitialVelocity=(X=256.000000)
     MaxVelocityVariance=(X=64.000000)
     UseLines=True
     LineStartColor=(R=180,G=180,B=180)
     LineEndColor=(R=220,G=220,B=220)
     Style=STY_Normal
}
