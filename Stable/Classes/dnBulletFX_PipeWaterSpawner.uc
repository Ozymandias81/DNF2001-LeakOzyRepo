//=============================================================================
// dnBulletFX_PipeWaterSpawner.
//=============================================================================
class dnBulletFX_PipeWaterSpawner expands dnWallFX_Spawners;

defaultproperties
{
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnWallWater')
     CreationSound=None
     CreationSounds(0)=Sound'a_impact.metal.ImpactMtl49'
     CreationSounds(1)=Sound'a_impact.metal.ImpactMtl48'
}
