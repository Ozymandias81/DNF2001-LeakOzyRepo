//=============================================================================
// dnCharacterFX_BurrowUP_Wood_Cloud.
//=============================================================================
class dnCharacterFX_BurrowUP_Wood_Cloud expands dnCharacterFX_BurrowSpawnUP;

defaultproperties
{
     DestroyWhenEmptyAfterSpawn=True
     CurrentSpawnNumber=10
     SpawnNumber=2
     PrimeCount=2
     MaximumParticles=9
     Lifetime=0.500000
     InitialVelocity=(Z=256.000000)
     MaxVelocityVariance=(X=256.000000,Y=256.000000)
     Textures(0)=Texture't_generic.dirtcloud.dirtcloud1aRC'
     Textures(1)=Texture't_generic.dirtcloud.dirtcloud1cRC'
     EndDrawScale=3.000000
     RotationVariance=65535.000000
     RotationVelocityMaxVariance=4.000000
     TriggerAfterSeconds=0.600000
     TriggerType=SPT_Disable
     PulseSeconds=0.000000
     AlphaEnd=0.000000
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     Style=STY_Translucent
}
