//=============================================================================
// Z1_Throne. 	Keith Schuler 	6/20/01
// Duke's Throne, goes in the penthouse study
//=============================================================================
class Z1_Throne expands Zone1_Vegas;

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Wood1'
     FragType(1)=Class'dnParticles.dnDebrisMesh_Generic1'
     FragType(2)=Class'dnParticles.dnDebrisMesh_Generic1a'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Generic1b'
     FragType(4)=Class'dnParticles.dnDebris_Smoke'
     FragType(5)=Class'dnParticles.dnDebris_Fabric1'
     SpawnOnHit=Class'dnParticles.dnBulletFX_WoodSpawner'
     DestroyedSound=Sound'a_impact.wood.ImpactWood1A'
     bTumble=False
     MassPrefab=MASS_Heavy
     HealthPrefab=HEALTH_Hard
     bFlammable=True
     CollisionRadius=22.000000
     CollisionHeight=27.000000
     Physics=PHYS_MovingBrush
     Mesh=DukeMesh'c_zone1_vegas.throne'
}
