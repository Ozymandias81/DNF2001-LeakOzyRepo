//=============================================================================
// dnConcussion1. Keith Schuler June 14,2000
//=============================================================================
class dnConcussion1 expands dnExplosion1;

// A concussion effect that throws the player with minimal damage. No graphic
// effect. Could be used as an effect in conjunction with other explosions.

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx
#exec OBJ LOAD FILE=..\Textures\t_explosionFx.dtx

defaultproperties
{
     BSPOcclude=False
     AdditionalSpawn(3)=(SpawnClass=None)
     CreationSound=None
     SpawnNumber=1
     SpawnPeriod=0.100000
     UseLines=True
     DamageAmount=0.250000
     DamagePeriod=0.250000
}
