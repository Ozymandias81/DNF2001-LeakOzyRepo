//=============================================================================
// G_Bottle2.
//=============================================================================
class G_Bottle2 expands Generic;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx
// September 14th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

//====================Created December 10th, 1998 Happy DOOM Day! - Stephen Cole

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Glass1'
     FragType(1)=Class'dnParticles.dnDebrisMesh_Glass1'
     FragType(2)=Class'dnParticles.dnDebrisMesh_Glass1a'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Glass1b'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Glass1c'
     FragType(5)=Class'dnParticles.dnDebrisMesh_Glass1d'
     FragType(6)=Class'dnParticles.dnDebris_Smoke_Small1'
     NumberFragPieces=24
     FragBaseScale=0.300000
     DamageOnHitWall=100
     SpawnOnHit=Class'dnParticles.dnBulletFX_GlassSpawner'
     DestroyedSound=Sound'a_impact.Glass.GlassBreak73'
     MassPrefab=MASS_Light
     HealthPrefab=HEALTH_Easy
     bLandForward=True
     bLandBackwards=True
     bLandLeft=True
     bLandRight=True
     LandFrontCollisionRadius=15.000000
     LandFrontCollisionHeight=2.750000
     LandSideCollisionRadius=15.000000
     LandSideCollisionHeight=2.750000
     bPushable=True
     Grabbable=True
     PlayerViewOffset=(X=1.500000,Y=0.600000,Z=2.000000)
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_generic.bottle2'
     ItemName="Rum"
     CollisionRadius=4.000000
     CollisionHeight=12.000000
     Health=1
}
