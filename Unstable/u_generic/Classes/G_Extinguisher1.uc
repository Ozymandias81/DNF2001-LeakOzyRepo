//=============================================================================
// G_Extinguisher1.
//=============================================================================
class G_Extinguisher1 expands Generic;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx
// September 18th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

//====================Created December 10th, 1998 Happy DOOM Day! - Stephen Cole

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Metal1'
     FragType(1)=Class'dnParticles.dnDebris_Sparks1_Large'
     FragType(2)=Class'dnParticles.dnDebrisMesh_Metal1'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Metal1a'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Metal1b'
     FragBaseScale=0.200000
     DestroyedSound=Sound'a_impact.metal.ImpactMtl07'
     SpawnOnDestroyed(0)=(SpawnClass=Class'dnParticles.dnExplosion1_Spawner1')
     HealthPrefab=HEALTH_Easy
     bLandForward=True
     bLandBackwards=True
     bLandLeft=True
     LandFrontCollisionRadius=16.000000
     LandFrontCollisionHeight=4.500000
     LandSideCollisionRadius=16.000000
     LandSideCollisionHeight=4.500000
     Grabbable=True
     PlayerViewOffset=(X=0.375000,Y=0.750000,Z=1.250000)
     BobDamping=0.850000
     Mesh=DukeMesh'c_generic.extinguisher1'
     ItemName="Fire Extinguisher"
     CollisionRadius=8.000000
     CollisionHeight=14.000000
     bTakeMomentum=False
}
