//=============================================================================
// dnExplosion3_SElec_Spawner3. 		November 3rd, 2000 - Charlie Wiederhold
//=============================================================================
class dnExplosion3_SElec_Spawner3 expands dnExplosion3_SElec_Spawner2;

// Explosion effect spawner.
// Does NOT do damage. 
// Smallest explosion for mostly electronic items that are destroyed
// Spawns the initial flash graphic.

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     DamageAmount=0.000000
     DamageRadius=0.000000
     MomentumTransfer=0.000000
}
