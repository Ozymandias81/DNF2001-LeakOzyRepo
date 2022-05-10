//=============================================================================
// dnWaterFX_Effect1.	Keith Schuler	Sept 29, 2000
//=============================================================================
class dnWaterFX_Effect1 expands dnWaterFX_Spawner1;

defaultproperties
{
     AdditionalSpawn(0)=(SpawnClass=None,Mount=False)
     AdditionalSpawn(1)=(SpawnClass=None,Mount=False,MountOrigin=(Z=0.000000))
     SpawnNumber=0
     PrimeCount=40
     RelativeSpawn=True
     SpawnAtRadius=True
     InitialVelocity=(Z=450.000000)
     MaxVelocityVariance=(X=425.000000,Y=425.000000,Z=300.000000)
     Textures(0)=Texture't_generic.WaterImpact.waterimpact3cRC'
     StartDrawScale=0.500000
     AlphaStart=0.250000
     AlphaEnd=0.000000
     PulseSeconds=0.100000
}
