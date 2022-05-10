//=============================================================================
// dnBulletFX_PipeOilSpawner.
//=============================================================================
class dnBulletFX_PipeOilSpawner expands dnWallFX_Spawners;

defaultproperties
{
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnWallOil')
     CreationSound=None
     CreationSounds(0)=Sound'a_impact.metal.ImpactMtl49'
     CreationSounds(1)=Sound'a_impact.metal.ImpactMtl48'
}
