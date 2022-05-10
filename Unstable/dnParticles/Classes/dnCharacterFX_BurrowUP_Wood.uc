//=============================================================================
// dnCharacterFX_BurrowUP_Wood.
//=============================================================================
class dnCharacterFX_BurrowUP_Wood expands dnCharacterFX_BurrowSpawnUP;

defaultproperties
{
     DestroyWhenEmptyAfterSpawn=True
     CurrentSpawnNumber=30
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnCharacterFX_BurrowUP_Wood_Cloud')
     SpawnNumber=10
     PrimeCount=4
     MaximumParticles=30
     Lifetime=0.500000
     InitialVelocity=(Z=192.000000)
     MaxVelocityVariance=(X=256.000000,Y=256.000000)
     Textures(0)=Texture't_generic.woodshards.woodshard4aRC'
     Textures(1)=Texture't_generic.woodshards.woodshard4bRC'
     Textures(2)=Texture't_generic.woodshards.woodshard4cRC'
     Textures(3)=Texture't_generic.woodshards.woodshard4dRC'
     Textures(4)=Texture't_generic.woodshards.woodshard4eRC'
     DrawScaleVariance=0.125000
     StartDrawScale=0.250000
     EndDrawScale=0.250000
     RotationVariance=65535.000000
     RotationVelocityMaxVariance=8.000000
     TriggerAfterSeconds=0.500000
     TriggerType=SPT_Disable
     PulseSeconds=0.000000
     Style=STY_Masked
}
