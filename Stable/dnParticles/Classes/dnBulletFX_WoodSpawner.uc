//=============================================================================
// dnBulletFX_WoodSpawner.
//=============================================================================
class dnBulletFX_WoodSpawner expands dnWallFX_Spawners;

defaultproperties
{
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnWallWood')
     CreationSound=None
     CreationSounds(0)=Sound'a_impact.wood.ImpactWood31'
     CreationSounds(1)=Sound'a_impact.wood.ImpactWood41'
}
