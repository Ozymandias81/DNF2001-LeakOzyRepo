//=============================================================================
// dnBulletFX_GravelSpawner.
//=============================================================================
class dnBulletFX_GravelSpawner expands dnWallFX_Spawners;

defaultproperties
{
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnWallGravel')
     CreationSound=None
     CreationSounds(0)=Sound'a_impact.Rock.RockBrk12'
     CreationSounds(1)=Sound'a_impact.Rock.RockBrk11'
}
