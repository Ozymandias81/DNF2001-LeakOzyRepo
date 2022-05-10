//=============================================================================
// G_Trashcan2.
//=============================================================================
class G_Trashcan2 expands Generic;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx
// September 18th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold
//====================Created December 10th, 1998 Happy DOOM Day! - Stephen Cole

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Paper1'
     FragType(1)=Class'dnParticles.dnDebris_Metal1_Small'
     FragType(3)=Class'dnParticles.dnDebris_SmokeSubtle'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Metal1'
     FragType(5)=Class'dnParticles.dnDebrisMesh_Metal1a'
     FragBaseScale=0.400000
     SpawnOnHit=Class'dnParticles.dnBulletFX_FabricSpawner'
     MassPrefab=MASS_Light
     bLandForward=True
     bLandBackwards=True
     bLandLeft=True
     bLandRight=True
     LandFrontCollisionRadius=13.000000
     LandFrontCollisionHeight=11.500000
     LandSideCollisionRadius=20.000000
     LandSideCollisionHeight=7.500000
     bPushable=True
     Grabbable=True
     PlayerViewOffset=(X=-0.500000,Y=-0.500000,Z=-0.250000)
     BobDamping=0.900000
     ItemName="Trashcan"
     bFlammable=True
     CollisionRadius=13.000000
     CollisionHeight=12.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_generic.trashcan2'
}
