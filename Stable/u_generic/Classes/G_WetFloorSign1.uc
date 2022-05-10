//=============================================================================
// G_WetFloorSign1.
//=============================================================================
class G_WetFloorSign1 expands Generic;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx
// September 18th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

//======================Created December 16th, 1998 - Stephen Cole

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Sparks1_Small'
     FragType(1)=Class'dnParticles.dnDebris_Smoke_Dirt1'
     FragType(2)=Class'dnParticles.dnDebris_Wood1'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Wood1'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Wood1a'
     FragType(5)=Class'dnParticles.dnDebrisMesh_Wood1b'
     FragBaseScale=0.400000
     SpawnOnHit=Class'dnParticles.dnBulletFX_WoodSpawner'
     DestroyedSound=Sound'a_impact.wood.ImpactWood1A'
     bLandLeft=True
     bLandRight=True
     LandFrontCollisionRadius=22.000000
     LandFrontCollisionHeight=8.000000
     LandSideCollisionRadius=22.000000
     LandSideCollisionHeight=8.000000
     bPushable=True
     Grabbable=True
     PlayerViewOffset=(X=-0.250000,Y=1.000000,Z=0.000000)
     BobDamping=0.900000
     ItemName="Wet Floor Sign"
     bFlammable=True
     CollisionRadius=14.000000
     CollisionHeight=17.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_generic.wetfloorsign1'
}
