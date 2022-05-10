//=============================================================================
// dnParachuteBombExplosion.
//=============================================================================
class dnParachuteBombExplosion expands SoftParticleSystem;



// Consists of an explosion, flash, sparks, fire, and unique blastmark.
// PBomb_effect1 is the explosion
// SparkEffect_Effect4 is the spark shower
// PBomb_effect3 is the fire. Scaled up 2x. Relative spawns at -50 relative apex
// to compensate for size.
// Fire pulses for 4 seconds and dies.
// Flash spawned at parent
// Blastmark spawned at projectile 
// Stephen Cole

defaultproperties
{
     Enabled=False
     DestroyWhenEmpty=True
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnPBomb_Effect1')
     SpawnNumber=0
     SpawnPeriod=0.000000
     PrimeCount=1
     Lifetime=0.250000
     UseZoneGravity=False
     Textures(0)=Texture't_generic.particle_efx.pflare2'
     StartDrawScale=30.000000
     EndDrawScale=0.100000
     UpdateWhenNotVisible=True
     TriggerType=SPT_None
     PulseSeconds=0.250000
     VisibilityRadius=8000.000000
     VisibilityHeight=8000.000000
     bHidden=True
     Style=STY_Translucent
     bUnlit=True
}
