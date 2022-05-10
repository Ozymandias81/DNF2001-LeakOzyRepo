//=============================================================================
// dnCharacterFX_ASnatchDebris_Generic.
//=============================================================================
class dnCharacterFX_ASnatchDebris_Generic expands dnCharacterFX;

defaultproperties
{
     Enabled=False
     DestroyWhenEmpty=True
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnDebris_Cement1')
     AdditionalSpawn(1)=(SpawnClass=Class'dnParticles.dnDebrisMesh_Generic1')
     AdditionalSpawn(2)=(SpawnClass=Class'dnParticles.dnDebris_Sparks1_Small')
     SpawnNumber=0
     PrimeCount=3
     PrimeTimeIncrement=0.000000
     MaximumParticles=3
     Lifetime=3.200000
     LifetimeVariance=1.000000
     InitialVelocity=(Z=24.000000)
     MaxVelocityVariance=(X=48.000000,Y=48.000000,Z=16.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_generic.Smoke.gensmoke1cRC'
     DrawScaleVariance=0.400000
     EndDrawScale=2.800000
     RotationVariance=65535.000000
     TriggerType=SPT_None
     AlphaEnd=0.000000
     Style=STY_Translucent
}
