//=============================================================================
// dnCharacterFX_BurrowDN_Concrete.
//=============================================================================
class dnCharacterFX_BurrowDN_Concrete expands dnCharacterFX_BurrowSpawnDN;

defaultproperties
{
     DestroyWhenEmptyAfterSpawn=True
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnCharacterFX_BurrowDN_Concrete_Cloud')
     SpawnNumber=4
     SpawnPeriod=0.000000
     PrimeCount=10
     Lifetime=0.500000
     InitialVelocity=(Z=192.000000)
     MaxVelocityVariance=(X=256.000000,Y=256.000000)
     Textures(0)=Texture't_generic.concrtparticles.concrtpart1aRC'
     Textures(1)=Texture't_generic.concrtparticles.concrtpart1bRC'
     Textures(2)=Texture't_generic.concrtparticles.concrtpart1cRC'
     Textures(3)=Texture't_generic.concrtparticles.concrtpart1dRC'
     Textures(4)=Texture't_generic.concrtparticles.concrtpart1eRC'
     Textures(5)=Texture't_generic.concrtparticles.concrtpart1fRC'
     DrawScaleVariance=0.050000
     StartDrawScale=0.125000
     EndDrawScale=0.125000
     RotationVariance=65535.000000
     RotationVelocityMaxVariance=8.000000
     TriggerAfterSeconds=1.200000
     TriggerType=SPT_Disable
     PulseSeconds=0.000000
     Style=STY_Masked
}
