//=============================================================================
// Z3_ExplosiveBarrel.
//=============================================================================
class Z3_ExplosiveBarrel expands Zone3_Canyon
	obsolete;

defaultproperties
{
     SpawnOnDestroyed(0)=(SpawnClass=Class'dnParticles.dnExplosion1')
     SpawnOnDestroyed(1)=(SpawnClass=Class'dnParticles.dnWallWood')
     SpawnOnDestroyed(2)=(SpawnClass=Class'dnParticles.dnWallWood')
     SpawnOnDestroyed(3)=(SpawnClass=Class'dnParticles.dnWallSpark')
     SpawnOnDestroyed(4)=(SpawnClass=Class'dnParticles.dnWallSpark')
     SpawnOnDestroyed(5)=(SpawnClass=Class'dnParticles.dnExplosiveBarrelFire')
     Mesh=None
     CollisionRadius=17.000000
     CollisionHeight=22.000000
}
