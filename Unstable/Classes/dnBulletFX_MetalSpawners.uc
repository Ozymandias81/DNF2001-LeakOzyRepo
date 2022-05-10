//=============================================================================
// dnBulletFX_MetalSpawners.
//=============================================================================
class dnBulletFX_MetalSpawners expands dnWallFX_Spawners;

defaultproperties
{
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnWallSpark')
	 CreationSound=None
     CreationSounds(0)=Sound'a_impact.metal.ImpactMtl49'
     CreationSounds(1)=Sound'a_impact.metal.ImpactMtl48'
}
