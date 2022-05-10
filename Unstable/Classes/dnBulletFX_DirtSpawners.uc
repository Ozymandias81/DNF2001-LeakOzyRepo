//=============================================================================
// dnBulletFX_DirtSpawners.
//=============================================================================
class dnBulletFX_DirtSpawners expands dnWallFX_Spawners;

defaultproperties
{
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnWallDirt')
     CreationSound=None
     CreationSounds(0)=Sound'a_impact.Dirt.ImpactDirtA'
     CreationSounds(1)=Sound'a_impact.Dirt.ImpactDirtB'
}
