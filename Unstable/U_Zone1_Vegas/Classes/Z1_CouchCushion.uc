//=============================================================================
// Z1_CouchCushion.	Keith Schuler Nov 14, 2000
//=============================================================================
class Z1_CouchCushion expands Zone1_Vegas;

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Fabric1'
     FragType(1)=Class'dnParticles.dnDebris_Fabric1'
     FragType(2)=Class'dnParticles.dnDebrisMesh_Metal1a'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Metal1b'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Metal1c'
     SpawnOnHit=Class'dnParticles.dnBulletFX_FabricSpawner'
     DestroyedSound=Sound'a_impact.wood.ImpactWood42'
     bLandUpright=True
     bLandUpsideDown=True
     Grabbable=True
     PlayerViewOffset=(X=-0.500000,Z=1.000000)
     ItemName="Cushion"
     bFlammable=True
     CollisionRadius=20.000000
     CollisionHeight=6.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone1_vegas.CouchCushion'
}
