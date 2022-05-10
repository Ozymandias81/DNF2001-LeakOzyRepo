//=============================================================================
// dnSparkEffect_Spawner3.	Keith Schuler	Oct 25, 2000
// Same as dnDebris spark effect, but adds a flashing lens flare effect
//=============================================================================
class dnSparkEffect_Spawner3 expands dnSparkEffect;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnDebris_Sparks1_Small')
     StartDrawScale=2.000000
     CollisionRadius=1.000000
     CollisionHeight=1.000000
}
