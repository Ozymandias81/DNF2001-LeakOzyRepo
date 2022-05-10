//=============================================================================
// dnBellagioEFX_Water1_1. ( AHB3d )
//=============================================================================
class dnBellagioEFX_Water1_1 expands dnBellagioEFX_Water1;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

// Bellagio Water Fountain effect
// Streight up. surface water

defaultproperties
{
     AdditionalSpawn(0)=(SpawnClass=None)
     SpawnPeriod=0.050000
     Lifetime=1.000000
     InitialVelocity=(X=300.000000)
     InitialAcceleration=(X=25.000000,Z=200.000000)
     MaxVelocityVariance=(X=400.000000)
     AlphaStart=0.500000
     bUnlit=True
}
