//=============================================================================
// dnExplosion1_Spawner4.	Keith Schuler September 16,2000
// Big explosion for outside the Lady Killer. Spawns big fire.
//=============================================================================
class dnExplosion1_Spawner4 expands dnExplosion1;

defaultproperties
{
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnExplosion1_Effect4')
     AdditionalSpawn(2)=(SpawnClass=Class'dnParticles.dnFireEffect2')
     AdditionalSpawn(3)=(SpawnClass=Class'dnParticles.dnDebris_Sparks1')
     AdditionalSpawn(4)=(SpawnClass=Class'dnParticles.dnSmokeEffect2')
     CreationSoundRadius=8192.000000
     StartDrawScale=24.000000
     bBurning=True
     CollisionRadius=22.000000
     CollisionHeight=22.000000
}
