//=============================================================================
// dnExplosion3_SElect_Smoke. 		  September 25th, 2000 - Charlie Wiederhold
//=============================================================================
class dnExplosion3_SElect_Smoke expands dnExplosion3_SmallElectronic;

// Explosion effect subclass spawned by other particle systems. 
// No damage.
// Smoke effect.

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     AdditionalSpawn(1)=(SpawnClass=None)
     CreationSound=None
     CreationSoundRadius=0.000000
     PrimeCount=3
     Lifetime=3.000000
     InitialVelocity=(Z=32.000000)
     MaxVelocityVariance=(X=48.000000,Y=48.000000,Z=16.000000)
     Textures(0)=Texture't_generic.Smoke.gensmoke1dRC'
     StartDrawScale=0.500000
     EndDrawScale=2.000000
     AlphaEnd=0.000000
     RotationVariance=65535.000000
     DamageAmount=0.000000
     DamageRadius=0.000000
     MomentumTransfer=0.000000
     CollisionRadius=24.000000
     CollisionHeight=24.000000
}
