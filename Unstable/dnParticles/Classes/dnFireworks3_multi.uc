//=============================================================================
// dnFireworks3_multi. (AHB3d)
//=============================================================================
class dnFireworks3_multi expands dnFireworks3;

// Burst effect like in the X-box boxing ring with multi colors
// does not damage
// calls dnFireworks3_red_spark, burst, flash, smoke
// If you want the cool Poping at the top,
// then you will have to put a dnFireworks3_multi_pop in your map.

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnFireworks3_multi_burst')
     AdditionalSpawn(1)=(SpawnClass=Class'dnParticles.dnFireworks3_multi_flash')
     AdditionalSpawn(2)=(SpawnClass=Class'dnParticles.dnFireworks3_multi_spark')
     AdditionalSpawn(3)=(SpawnClass=Class'dnParticles.dnFireworks3_multi_smoke')
     LifeSpan=4.000000
}
