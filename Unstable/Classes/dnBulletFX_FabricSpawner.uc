//=============================================================================
// dnBulletFX_FabricSpawner.
//=============================================================================
class dnBulletFX_FabricSpawner expands dnWallFX_Spawners;

defaultproperties
{
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnWallFabric')
     CreationSound=None
     CreationSounds(0)=Sound'a_impact.body.ImpactMelee2'
     CreationSounds(1)=Sound'a_impact.body.ImpactMelee1'
}
