//=============================================================================
// G_Coffeemug1.
//=============================================================================
class G_Coffeemug1 expands Generic;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx
// September 18th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

//====================Created December 10th, 1998 Happy DOOM Day! - Stephen Cole

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebrisMesh_Glass1'
     FragType(1)=Class'dnParticles.dnDebrisMesh_Glass1a'
     FragType(2)=Class'dnParticles.dnDebrisMesh_Glass1b'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Glass1c'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Glass1d'
     FragType(5)=Class'dnParticles.dnDebris_Glass1'
     FragType(7)=Class'dnParticles.dnDebris_Smoke_Small1'
     FragBaseScale=0.200000
     SpawnOnHit=Class'dnParticles.dnBulletFX_GlassSpawner'
     DestroyedSound=Sound'a_impact.Glass.GlassBreak73'
     MassPrefab=MASS_Light
     HealthPrefab=HEALTH_Easy
     bLandForward=True
     bLandBackwards=True
     bLandUpright=True
     bLandUpsideDown=True
     LandFrontCollisionRadius=5.000000
     LandFrontCollisionHeight=2.750000
     LandSideCollisionRadius=5.000000
     LandSideCollisionHeight=2.750000
     bPushable=True
     Grabbable=True
     PlayerViewOffset=(X=0.500000,Y=-0.550000,Z=1.000000)
     BobDamping=0.920000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_generic.coffeemug1'
     ItemName="Coffee Mug"
     CollisionRadius=3.500000
     CollisionHeight=3.500000
     Health=1
}
