//=============================================================================
// Z1_MGC_TopHat. 						October 26th, 2000 - Charlie Wiederhold
//=============================================================================
class Z1_MGC_TopHat expands Zone1_Vegas;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Fabric1'
     FragType(1)=Class'dnParticles.dnDebris_Smoke'
     FragType(2)=Class'dnParticles.dnDebrisMesh_Inflatable'
     FragType(3)=Class'dnParticles.dnDebrisMesh_InflatableA'
     FragType(4)=Class'dnParticles.dnDebrisMesh_InflatableB'
     SpawnOnHit=Class'dnParticles.dnBulletFX_FabricSpawner'
     MassPrefab=MASS_Light
     bLandForward=True
     bLandBackwards=True
     bLandLeft=True
     bLandRight=True
     bLandUpright=True
     bLandUpsideDown=True
     LandFrontCollisionRadius=10.000000
     LandFrontCollisionHeight=8.000000
     LandSideCollisionRadius=10.000000
     LandSideCollisionHeight=8.000000
     bPushable=True
     Grabbable=True
     MeshFlameClass=Class'dnParticles.dnFlameThrowerFX_ObjectBurn_Small'
     PlayerViewOffset=(X=-1.275000,Y=4.500000,Z=-0.500000)
     BobDamping=0.990000
     ItemName="Magic Hat"
     bFlammable=True
     CollisionRadius=9.000000
     CollisionHeight=7.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone1_vegas.mgc_tophat'
}
