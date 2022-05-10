//=============================================================================
// G_BasketBall.
//=============================================================================
class G_BasketBall expands Generic;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx
// September 14th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

// AllenB

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebrisMesh_Inflatable'
     FragType(1)=Class'dnParticles.dnDebrisMesh_InflatableA'
     FragType(2)=Class'dnParticles.dnDebrisMesh_InflatableB'
     FragType(3)=Class'dnParticles.dnDebris_SmokeSubtle'
     FragType(4)=Class'dnParticles.dnDebris_Fabric1'
     FragType(5)=Class'dnParticles.dnDebrisMesh_Inflatable'
     FragType(6)=Class'dnParticles.dnDebrisMesh_InflatableB'
     FragBaseScale=0.300000
     SpawnOnHit=None
     MassPrefab=MASS_Rubber
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
     PlayerViewOffset=(X=0.325000,Y=-0.500000,Z=1.000000)
     BobDamping=0.900000
     LodMode=LOD_Disabled
     ItemName="Basketball"
     bFlammable=True
     CollisionRadius=6.000000
     CollisionHeight=6.500000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_generic.BB'
	MeshFlameClass=Class'dnParticles.dnFlameThrowerFX_ObjectBurn_Small'
}
