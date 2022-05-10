//=============================================================================
// Z1_MGC_Wand. 						October 26th, 2000 - Charlie Wiederhold
//=============================================================================
class Z1_MGC_Wand expands Zone1_Vegas;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Sparks1_Small'
     FragType(1)=Class'dnParticles.dnDebris_Smoke'
     FragType(2)=Class'dnParticles.dnDebrisMesh_GenericTiny1'
     FragType(3)=Class'dnParticles.dnDebrisMesh_GenericTiny1a'
     SpawnOnHit=Class'dnParticles.dnBulletFX_WoodSpawner'
     DestroyedSound=Sound'a_impact.wood.ImpactWood1A'
     MassPrefab=MASS_Light
     HealthPrefab=HEALTH_Easy
     bLandUpright=True
     Grabbable=True
     MeshFlameClass=Class'dnParticles.dnFlameThrowerFX_ObjectBurn_Small'
     PlayerViewOffset=(X=0.000000,Y=-2.000000,Z=0.750000)
     BobDamping=0.900000
     ItemName="Magic Wand"
     bFlammable=True
     CollisionRadius=11.000000
     CollisionHeight=1.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone1_vegas.mgc_wand'
}
