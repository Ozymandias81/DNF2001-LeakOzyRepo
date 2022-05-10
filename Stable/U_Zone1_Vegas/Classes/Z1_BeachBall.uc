//=============================================================================
// Z1_BeachBall.
//=============================================================================
class Z1_BeachBall expands Zone1_Vegas;

// Keith Schuler 2/23/99 Grabbable 5/26/99

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx
// September 27th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebrisMesh_Inflatable'
     FragType(1)=Class'dnParticles.dnDebrisMesh_InflatableA'
     FragType(2)=Class'dnParticles.dnDebrisMesh_InflatableB'
     FragType(3)=Class'dnParticles.dnDebris_SmokeSubtle'
     FragType(4)=Class'dnParticles.dnDebris_Fabric1'
     FragType(5)=Class'dnParticles.dnDebrisMesh_Inflatable'
     FragType(6)=Class'dnParticles.dnDebrisMesh_InflatableB'
     SpawnOnHit=None
     MassPrefab=MASS_Ultralight
     HealthPrefab=HEALTH_Easy
     bLandForward=True
     bLandBackwards=True
     bLandLeft=True
     bLandRight=True
     bLandUpright=True
     bLandUpsideDown=True
     LandFrontCollisionRadius=6.000000
     LandFrontCollisionHeight=6.000000
     LandSideCollisionRadius=6.000000
     LandSideCollisionHeight=6.000000
     bPushable=True
     Grabbable=True
     MeshFlameClass=Class'dnParticles.dnFlameThrowerFX_ObjectBurn_Small'
     PlayerViewOffset=(X=0.325000,Y=-0.500000,Z=0.750000)
     BobDamping=0.920000
     ItemName="Beach Ball"
     bFlammable=True
     CollisionRadius=6.000000
     CollisionHeight=6.000000
     Physics=PHYS_Falling
     Mass=1.000000
     Mesh=DukeMesh'c_zone1_vegas.beachball'
}
