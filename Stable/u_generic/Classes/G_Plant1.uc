//=============================================================================
// G_Plant1.      AB
//=============================================================================
class G_Plant1 expands Generic;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx
// September 18th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     HealthMarkers(0)=(Threshold=40,PlaySequence=plntdamage1,SpawnActor=Class'dnParticles.dnLeaves')
     HealthMarkers(1)=(Threshold=30,PlaySequence=plntdamage2,SpawnActor=Class'dnParticles.dnLeaves')
     HealthMarkers(2)=(Threshold=20,PlaySequence=plntdamage3,SpawnActor=Class'dnParticles.dnLeaves')
     HealthMarkers(3)=(Threshold=10,PlaySequence=plntdamage4,SpawnActor=Class'dnParticles.dnLeaves')
     FragType(1)=Class'dnParticles.dnLeaves'
     FragType(2)=Class'dnParticles.dnLeaves'
     FragType(3)=Class'dnParticles.dnDebris_Dirt1'
     FragType(4)=Class'dnParticles.dnDebris_Smoke_Dirt1'
     FragType(5)=Class'dnParticles.dnDebrisMesh_Generic1'
     FragType(6)=Class'dnParticles.dnDebrisMesh_Generic1a'
     FragType(7)=Class'dnParticles.dnDebrisMesh_Generic1b'
     FragBaseScale=0.300000
     DamageOnPlayerTouch=10
     SpawnOnHit=Class'dnParticles.dnBulletFX_LeavesSpawner'
     DestroyedSound=Sound'a_impact.Foliage.ImpFoliage014'
     HealthPrefab=HEALTH_UseHealthVar
     bLandForward=True
     bLandBackwards=True
     bLandLeft=True
     bLandRight=True
     LandDirection=LAND_Upright
     LandFrontCollisionHeight=11.000000
     LandSideCollisionHeight=11.000000
     bPushable=True
     Grabbable=True
     PlayerViewOffset=(X=0.500000,Y=3.000000,Z=2.000000)
     BobDamping=0.800000
     Health=40
     ItemName="Plant"
     bFlammable=True
     bDirectional=True
     CollisionRadius=13.000000
     CollisionHeight=27.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_generic.plant1RC'
}
