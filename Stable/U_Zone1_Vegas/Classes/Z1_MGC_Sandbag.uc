//=============================================================================
// Z1_MGC_Sandbag. 						October 26th, 2000 - Charlie Wiederhold
//=============================================================================
class Z1_MGC_Sandbag expands Zone1_Vegas;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Smoke_Dirt1'
     FragType(1)=Class'dnParticles.dnDebris_Dirt1'
     FragType(2)=Class'dnParticles.dnDebris_Dirt1'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Generic1'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Generic1a'
     SpawnOnHit=Class'dnParticles.dnBulletFX_DirtSpawners'
     DestroyedSound=Sound'a_impact.wood.ImpactWood42'
     MassPrefab=MASS_Heavy
     HealthPrefab=HEALTH_Hard
     bLandForward=True
     LandFrontCollisionRadius=15.000000
     LandFrontCollisionHeight=6.500000
     LandSideCollisionRadius=15.000000
     LandSideCollisionHeight=6.500000
     bPushable=True
     Grabbable=True
     PlayerViewOffset=(X=0.000000,Y=0.750000,Z=1.000000)
     ItemName="Sandbag"
     bFlammable=True
     CollisionRadius=7.000000
     CollisionHeight=13.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone1_vegas.mgc_sandbag'
}
