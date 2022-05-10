//=============================================================================
// dnExplosion3_SElec_Fire.			  September 25th, 2000 - Charlie Wiederhold
//=============================================================================
class dnExplosion3_SElec_Fire expands dnExplosion3_SmallElectronic;

// Explosion effect subclass spawned by other particle systems. 
// No damage.
// Fire effect.

#exec OBJ LOAD FILE=..\Textures\t_explosionFx.dtx

defaultproperties
{
     AdditionalSpawn(0)=(SpawnClass=None)
     AdditionalSpawn(1)=(SpawnClass=None)
     CreationSound=None
     CreationSoundRadius=0.000000
     PrimeCount=2
     Lifetime=0.000000
     Textures(0)=Texture't_explosionFx.explosions.X_fi_001'
     DieOnLastFrame=True
     StartDrawScale=0.625000
     EndDrawScale=0.750000
     RotationVariance=65535.000000
     DamageAmount=0.000000
     DamageRadius=200.000000
     MomentumTransfer=100000.000000
     CollisionRadius=16.000000
     CollisionHeight=16.000000
}
