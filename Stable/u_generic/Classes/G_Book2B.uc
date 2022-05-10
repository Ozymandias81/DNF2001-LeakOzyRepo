//=============================================================================
// G_Book2B.
//======================================Created Feb 24th, 1999 - Stephen Cole
class G_Book2B expands Generic;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx
// September 14th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Paper1'
     FragType(1)=Class'dnParticles.dnDebris_Paper1'
     FragType(2)=Class'dnParticles.dnDebris_SmokeSubtle'
     FragType(3)=Class'dnParticles.dnDebrisMesh_GenericTiny1'
     FragType(4)=Class'dnParticles.dnDebrisMesh_GenericTiny1a'
     FragType(5)=Class'dnParticles.dnDebrisMesh_GenericTiny1b'
     SpawnOnHit=Class'dnParticles.dnBulletFX_FabricSpawner'
     DestroyedSound=Sound'a_impact.wood.ImpactWood42'
     bLandForward=True
     bLandBackwards=True
     bLandLeft=True
     bLandRight=True
     bLandUpright=True
     bLandUpsideDown=True
     LandFrontCollisionRadius=8.000000
     LandFrontCollisionHeight=4.000000
     LandSideCollisionRadius=7.000000
     LandSideCollisionHeight=5.300000
     bPushable=True
     Grabbable=True
     MeshFlameClass=Class'dnParticles.dnFlameThrowerFX_ObjectBurn_Small'
     PlayerViewOffset=(X=0.000000,Y=0.000000,Z=0.000000)
     ItemName="Books"
     bFlammable=True
     CollisionRadius=6.500000
     CollisionHeight=5.675000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_generic.book2b'
     AnimFrame=5.000000
     AnimRate=7.000000
}
