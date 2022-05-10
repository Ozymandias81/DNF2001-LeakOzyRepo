//=============================================================================
// G_LavaLamp.
//=============================================================================
class G_LavaLamp expands Generic;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx
// September 18th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold
//== AllenB

defaultproperties
{
     FragType(1)=Class'dnParticles.dnDebris_Sparks1_Small'
     FragType(2)=Class'dnParticles.dnDebris_Smoke'
     FragType(3)=Class'dnParticles.dnDebris_Glass1'
     FragType(4)=Class'dnParticles.dnDebrisMesh_GenericTiny1'
     FragType(5)=Class'dnParticles.dnDebrisMesh_GenericTiny1a'
     FragType(6)=Class'dnParticles.dnDebrisMesh_GenericTiny1b'
     FragBaseScale=0.300000
     IdleAnimations(0)=LavaLamp
     SpawnOnHit=Class'dnParticles.dnBulletFX_GlassSpawner'
     DestroyedSound=Sound'a_impact.Glass.GlassBreak73'
     MassPrefab=MASS_Light
     HealthPrefab=HEALTH_Easy
     bLandForward=True
     bLandBackwards=True
     bLandLeft=True
     bLandRight=True
     LandFrontCollisionRadius=12.000000
     LandFrontCollisionHeight=2.500000
     LandSideCollisionRadius=12.000000
     LandSideCollisionHeight=2.500000
     bPushable=True
     Grabbable=True
     MeshFlameClass=Class'dnParticles.dnFlameThrowerFX_ObjectBurn_Small'
     PlayerViewOffset=(X=0.750000,Y=0.350000,Z=1.250000)
     BobDamping=0.920000
     bHeated=True
     HeatIntensity=128.000000
     HeatRadius=16.000000
     HeatFalloff=128.000000
     ItemName="Lava Lamp"
     bFlammable=True
     CollisionRadius=3.000000
     CollisionHeight=9.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_generic.lamp'
}
