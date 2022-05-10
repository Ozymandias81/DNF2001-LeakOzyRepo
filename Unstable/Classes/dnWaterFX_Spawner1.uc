//=============================================================================
// dnWaterFX_Spawner1.	Keith Schuler	Sept 29, 2000
// Big water splash spawner. Used for splash effect in the penthouse pool
//=============================================================================
class dnWaterFX_Spawner1 expands dnWaterFX;

defaultproperties
{
     DestroyWhenEmpty=True
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnWaterFX_Effect1',Mount=True)
     AdditionalSpawn(1)=(SpawnClass=Class'dnParticles.dnWaterFX_Effect2',Mount=True,MountOrigin=(Z=10.000000))
     CreationSound=Sound'a_generic.Water.SplashIn01'
     PrimeCount=1
     Lifetime=1.750000
     InitialVelocity=(Z=800.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000)
     Textures(0)=Texture't_generic.WaterImpact.waterimpact3dRC'
     StartDrawScale=0.750000
     EndDrawScale=3.000000
     TriggerOnSpawn=True
     PulseSeconds=0.500000
     CollisionRadius=22.000000
}
