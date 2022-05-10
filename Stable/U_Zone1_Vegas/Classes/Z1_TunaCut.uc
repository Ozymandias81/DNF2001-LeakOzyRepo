//=============================================================================
// Z1_TunaCut.
//=============================================================================
class Z1_TunaCut expands Zone1_Vegas;

// Keith Schuler 2/23/99

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx
// September 28th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     FragType(0)=Class'dnParticles.dnBloodFX'
     FragType(1)=Class'dnParticles.dnDebris_Ice1'
     FragType(2)=Class'dnParticles.dnDebris_Smoke'
     FragType(3)=Class'dnParticles.dnDebrisMesh_GenericTiny1'
     FragType(4)=Class'dnParticles.dnDebrisMesh_GenericTiny1a'
     FragType(5)=Class'dnParticles.dnDebrisMesh_GenericTiny1b'
     FragType(6)=Class'dnParticles.dnDebrisMesh_Generic1'
     SpawnOnHit=Class'dnParticles.dnBloodFX'
     DestroyedSound=Sound'a_impact.wood.ImpactWood42'
     bLandUpright=True
     MeshFlameClass=Class'dnParticles.dnFlameThrowerFX_ObjectBurn_Small'
     PlayerViewOffset=(X=-1.500000,Y=-2.000000,Z=-2.000000)
     ItemName="Cut Tuna"
     bFlammable=True
     CollisionRadius=26.000000
     CollisionHeight=5.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone1_vegas.tuna_cut'
}
