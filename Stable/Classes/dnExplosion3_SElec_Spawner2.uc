//=============================================================================
// dnExplosion3_SElec_Spawner2. 	  September 26th, 2000 - Charlie Wiederhold
//=============================================================================
class dnExplosion3_SElec_Spawner2 expands dnExplosion3_SmallElectronic;

// Explosion effect spawner.
// Does do damage. 
// Smallest explosion for mostly electronic items that are destroyed
// Spawns the initial flash graphic.

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnExplosion3_SElecFire_Small')
     CreationSound=Sound'a_impact.Electric.LFBreak'
     DamageAmount=0.000000
}
