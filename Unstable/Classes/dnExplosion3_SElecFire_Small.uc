//=============================================================================
// dnExplosion3_SElecFire_Small.	  September 25th, 2000 - Charlie Wiederhold
//=============================================================================
class dnExplosion3_SElecFire_Small expands dnExplosion3_SElec_Fire;

// Explosion effect subclass spawned by other particle systems. 
// No damage.
// Fire effect.

#exec OBJ LOAD FILE=..\Textures\t_explosionFx.dtx

defaultproperties
{
     StartDrawScale=0.000100
     EndDrawScale=0.000400
     CollisionRadius=6.000000
     CollisionHeight=6.000000
}
