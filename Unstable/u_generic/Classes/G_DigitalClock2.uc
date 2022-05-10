//=============================================================================
// G_DigitalClock2.
//=============================================================================
class G_DigitalClock2 expands Generic;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx
// September 18th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

// Keith Schuler 12/16/98 1:39am

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Smoke_Small1'
     FragType(1)=Class'dnParticles.dnDebris_Sparks1_Small'
     FragType(2)=Class'dnParticles.dnDebrisMesh_GenericTiny1'
     FragType(3)=Class'dnParticles.dnDebrisMesh_GenericTiny1a'
     FragType(4)=Class'dnParticles.dnDebrisMesh_GenericTiny1b'
     FragType(5)=Class'dnParticles.dnDebris_Metal1_Small'
     MassPrefab=MASS_Light
     HealthPrefab=HEALTH_Easy
     bLandForward=True
     bLandLeft=True
     bLandRight=True
     bLandUpright=True
     LandFrontCollisionRadius=5.500000
     LandFrontCollisionHeight=3.000000
     LandSideCollisionRadius=5.500000
     LandSideCollisionHeight=4.250000
     bPushable=True
     Grabbable=True
     MeshFlameClass=Class'dnParticles.dnFlameThrowerFX_ObjectBurn_Small'
     PlayerViewOffset=(X=0.500000,Y=-0.875000,Z=1.000000)
     BobDamping=0.920000
     ItemName="Digital Clock"
     bFlammable=True
     CollisionRadius=5.500000
     CollisionHeight=3.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_generic.digital_clock2'
}
