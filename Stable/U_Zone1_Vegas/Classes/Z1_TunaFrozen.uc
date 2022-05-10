//=============================================================================
// Z1_TunaFrozen.
//=============================================================================
class Z1_TunaFrozen expands Zone1_Vegas;

// Keith Schuler 2/23/99

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx
// September 28th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     FragType(0)=Class'dnParticles.dnBloodFX'
     FragType(1)=Class'dnParticles.dnDebris_Ice1'
     FragType(2)=Class'dnParticles.dnDebris_Smoke'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Generic1'
     FragType(4)=Class'dnParticles.dnDebrisMesh_GenericTiny1'
     FragType(5)=Class'dnParticles.dnDebrisMesh_GenericTiny1a'
     FragType(6)=Class'dnParticles.dnDebrisMesh_GenericTiny1b'
     SpawnOnHit=Class'dnParticles.dnBloodFX'
     DestroyedSound=Sound'a_impact.wood.ImpactWood42'
     bLandLeft=True
     bLandRight=True
     LandFrontCollisionRadius=18.000000
     LandFrontCollisionHeight=6.000000
     LandSideCollisionRadius=18.000000
     LandSideCollisionHeight=6.000000
     bPushable=True
     Grabbable=True
     MeshFlameClass=Class'dnParticles.dnFlameThrowerFX_ObjectBurn_Small'
     PlayerViewOffset=(X=-0.500000,Y=-1.000000,Z=-1.000000)
     BobDamping=0.900000
     ItemName="Frozen Tuna"
     bFlammable=True
     CollisionRadius=18.000000
     CollisionHeight=8.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone1_vegas.tuna'
}
