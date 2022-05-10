//=============================================================================
// G_Hammer.
//==============================================Created Feb 24th, 1999 - Stephen Cole
class G_Hammer expands Generic;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx
// September 18th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     FragType(1)=Class'dnParticles.dnDebris_Smoke_Small1'
     FragType(2)=Class'dnParticles.dnDebris_Sparks1_Small'
     FragType(4)=Class'dnParticles.dnDebrisMesh_GenericTiny1'
     FragType(5)=Class'dnParticles.dnDebrisMesh_GenericTiny1a'
     FragType(6)=Class'dnParticles.dnDebrisMesh_GenericTiny1b'
     DestroyedSound=Sound'a_impact.wood.ImpactWood1A'
     bLandForward=True
     bLandBackwards=True
     LandFrontCollisionRadius=20.000000
     LandFrontCollisionHeight=1.750000
     LandSideCollisionRadius=20.000000
     LandSideCollisionHeight=1.750000
     bPushable=True
     Grabbable=True
     MeshFlameClass=Class'dnParticles.dnFlameThrowerFX_ObjectBurn_Small'
     PlayerViewOffset=(X=0.750000,Y=-0.250000,Z=1.500000)
     ItemName="Hammer"
     bFlammable=True
     CollisionRadius=7.000000
     CollisionHeight=11.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_generic.hammer'
}
