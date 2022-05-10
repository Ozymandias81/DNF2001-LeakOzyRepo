//=============================================================================
// dnEDFGameExplosion.
//=============================================================================
class dnEDFGameExplosion expands SoftParticleSystem;

defaultproperties
{
     Enabled=False
     DestroyWhenEmpty=True
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnEDFGExplosion_Effect1')
     SpawnNumber=0
     SpawnPeriod=0.000000
     PrimeCount=1
     Lifetime=0.250000
     InitialVelocity=(Z=0.000000)
     UseZoneGravity=False
     Textures(0)=Texture't_generic.particle_efx.pflare2'
     StartDrawScale=5.000000
     EndDrawScale=0.100000
     UpdateWhenNotVisible=True
     TriggerType=SPT_None
     PulseSeconds=0.250000
     bBurning=True
     Style=STY_Translucent
}
