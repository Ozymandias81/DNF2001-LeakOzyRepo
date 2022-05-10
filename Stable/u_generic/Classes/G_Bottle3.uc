//=============================================================================
// G_Bottle3.
//=============================================================================
class G_Bottle3 expands Generic;

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
     LandFrontCollisionHeight=3.500000
     LandSideCollisionRadius=15.000000
     LandSideCollisionHeight=3.500000
     bPushable=True
     Grabbable=True
     PlayerViewOffset=(X=1.000000,Y=0.400000,Z=1.500000)
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_generic.bottle3'
     ItemName="Vodka"
     CollisionRadius=5.000000
     CollisionHeight=10.000000
     Health=1
}
