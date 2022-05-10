//=============================================================================
// G_Traffic_Cone1.
//======================================Created Feb 24th, 1999 - Stephen Cole
class G_Traffic_Cone1 expands Generic;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx
// September 18th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebrisMesh_Metal1'
     FragType(1)=Class'dnParticles.dnDebrisMesh_Metal1a'
     FragType(2)=Class'dnParticles.dnDebris_Fabric1'
     FragType(3)=Class'dnParticles.dnDebris_Smoke'
     SpawnOnHit=Class'dnParticles.dnBulletFX_DirtSpawners'
     DestroyedSound=Sound'a_impact.Debris.ImpactDeb008'
     MassPrefab=MASS_Light
     bLandForward=True
     bLandBackwards=True
     bLandLeft=True
     bLandRight=True
     LandFrontCollisionRadius=20.000000
     LandFrontCollisionHeight=8.500000
     LandSideCollisionRadius=20.000000
     LandSideCollisionHeight=8.500000
     bPushable=True
     Grabbable=True
     PlayerViewOffset=(X=0.500000,Y=0.750000,Z=1.500000)
     BobDamping=0.900000
     ItemName="Traffic Cone"
     bFlammable=True
     CollisionRadius=9.000000
     CollisionHeight=16.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_generic.traffic_cone1'
}
