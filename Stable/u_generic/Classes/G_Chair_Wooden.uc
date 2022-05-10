//=============================================================================
// G_Chair_Wooden. 						January 22nd, 2001 - Charlie Wiederhold
//=============================================================================
class G_Chair_Wooden expands Generic;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Wood1'
     FragType(1)=Class'dnParticles.dnDebris_Smoke'
     FragType(2)=Class'dnParticles.dnDebrisMesh_Wood1'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Wood1a'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Wood1b'
     SpawnOnHit=Class'dnParticles.dnBulletFX_WoodSpawner'
     bLandBackwards=True
     bLandLeft=True
     bLandRight=True
     LandFrontCollisionRadius=34.000000
     LandFrontCollisionHeight=15.000000
     LandSideCollisionRadius=34.000000
     LandSideCollisionHeight=15.000000
     bPushable=True
     Grabbable=True
     PlayerViewOffset=(X=-0.625000,Y=0.750000,Z=1.000000)
     ItemName="Wooden Chair"
     bFlammable=True
     CollisionRadius=19.000000
     CollisionHeight=24.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_generic.wooden_chair1A'
}
