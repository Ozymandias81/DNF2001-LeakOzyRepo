//=============================================================================
// dnBulletFX_PipeSteamSpawner.
//=============================================================================
class dnBulletFX_PipeSteamSpawner expands dnWallFX_Spawners;

defaultproperties
{
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnWallSteam')
     AdditionalSpawn(1)=(SpawnClass=Class'dnParticles.dnBulletWallFX_SteamSound')
     CreationSound=None
     CreationSounds(0)=Sound'a_impact.metal.ImpactMtl49'
     CreationSounds(1)=Sound'a_impact.metal.ImpactMtl48'
}
