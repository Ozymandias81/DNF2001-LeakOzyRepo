//=============================================================================
// dnFireworks3_red. (AHB3d)
//=============================================================================
class dnFireworks3_red expands dnFireworks3;

// Burst effect like in the X-box boxing ring
// does not damage
// calls dnFireworks3_red_spark, burst, flash

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnFireworks3_red_burst')
     AdditionalSpawn(1)=(SpawnClass=Class'dnParticles.dnFireworks3_red_flash')
     AdditionalSpawn(2)=(SpawnClass=Class'dnParticles.dnFireworks3_red_spark')
     AdditionalSpawn(3)=(SpawnClass=Class'dnParticles.dnFireworks3_red_smoke')
     LifeSpan=4.000000
}
