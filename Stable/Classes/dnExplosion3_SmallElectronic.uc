//=============================================================================
// dnExplosion3_SmallElectronic.      September 25th, 2000 - Charlie Wiederhold
//=============================================================================
class dnExplosion3_SmallElectronic expands SoftParticleSystem;

// Explosion effect spawner.
// Does do damage. 
// Small explosion for mostly electronic items that are destroyed
// Spawns the initial flash graphic.

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=False
     DestroyWhenEmpty=True
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnExplosion3_SElec_Fire')
     AdditionalSpawn(1)=(SpawnClass=Class'dnParticles.dnExplosion3_SElect_Smoke')
     CreationSound=Sound'a_impact.explosions.Expl118'
     CreationSoundRadius=16384.000000
     SpawnNumber=0
     PrimeCount=1
     PrimeTimeIncrement=0.000000
     Lifetime=0.250000
     InitialVelocity=(Z=0.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_generic.particle_efx.pflare2'
     StartDrawScale=6.000000
     EndDrawScale=0.100000
     UpdateWhenNotVisible=True
     TriggerType=SPT_None
     PulseSeconds=0.250000
     DamageAmount=8.000000
     DamageRadius=100.000000
     MomentumTransfer=5000.000000
     bBurning=True
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     Style=STY_Translucent
     bUnlit=True
}
