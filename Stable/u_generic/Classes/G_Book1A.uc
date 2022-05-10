//=============================================================================
// G_Book1A.
//============================================Created Feb 24th, 1999 - Stephen Cole
class G_Book1A expands Generic;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx
// September 14th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Paper1'
     FragType(1)=Class'dnParticles.dnDebris_SmokeSubtle'
     FragType(2)=Class'dnParticles.dnDebrisMesh_GenericTiny1'
     FragType(3)=Class'dnParticles.dnDebrisMesh_GenericTiny1a'
     FragType(4)=Class'dnParticles.dnDebrisMesh_GenericTiny1b'
     SpawnOnHit=Class'dnParticles.dnBulletFX_FabricSpawner'
     DestroyedSound=Sound'a_impact.wood.ImpactWood42'
     MassPrefab=MASS_Light
     HealthPrefab=HEALTH_Easy
     bLandLeft=True
     bLandRight=True
     LandFrontCollisionRadius=8.000000
     LandFrontCollisionHeight=1.350000
     LandSideCollisionRadius=8.000000
     LandSideCollisionHeight=1.350000
     bPushable=True
     Grabbable=True
     MeshFlameClass=Class'dnParticles.dnFlameThrowerFX_ObjectBurn_Small'
     PlayerViewOffset=(X=0.000000,Y=0.000000,Z=0.000000)
     ItemName="Book"
     bFlammable=True
     CollisionRadius=4.000000
     CollisionHeight=5.750000
     Physics=PHYS_Falling
     Mass=1.000000
     Mesh=DukeMesh'c_generic.book1a'
}
