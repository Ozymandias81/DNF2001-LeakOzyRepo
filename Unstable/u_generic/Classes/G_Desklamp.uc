//=============================================================================
// G_Desklamp.
//=============================================================================
class G_Desklamp expands Generic;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx
// September 18th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

//== AllenB

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebrisMesh_GenericTiny1'
     FragType(1)=Class'dnParticles.dnDebrisMesh_GenericTiny1a'
     FragType(2)=Class'dnParticles.dnDebris_Metal1_Small'
     FragType(3)=Class'dnParticles.dnDebris_Sparks1_Small'
     FragType(4)=Class'dnParticles.dnDebris_Smoke_Small1'
     FragType(5)=Class'dnParticles.dnDebrisMesh_GenericTiny1b'
     NumberFragPieces=6
     FragBaseScale=0.200000
     MassPrefab=MASS_Light
     HealthPrefab=HEALTH_Easy
     bLandLeft=True
     bLandRight=True
     LandFrontCollisionRadius=16.000000
     LandFrontCollisionHeight=6.000000
     LandSideCollisionRadius=16.000000
     LandSideCollisionHeight=6.000000
     bPushable=True
     Grabbable=True
     MeshFlameClass=Class'dnParticles.dnFlameThrowerFX_ObjectBurn_Small'
     PlayerViewOffset=(X=0.000000,Y=0.000000,Z=0.000000)
     bHeated=True
     HeatIntensity=128.000000
     HeatRadius=8.000000
     HeatFalloff=128.000000
     Health=2
     ItemName="Desk Lamp"
     bFlammable=True
     CollisionRadius=12.000000
     CollisionHeight=12.500000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_generic.desklamp2'
}
