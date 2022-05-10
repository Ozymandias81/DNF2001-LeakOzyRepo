//=============================================================================
// Z1_DukC_Boot1.
// Keith Schuler 3/18/99 ======================================================
class Z1_DukC_Boot1 expands Zone1_Vegas;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx
// September 27th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Fabric1'
     FragType(1)=Class'dnParticles.dnDebris_Smoke'
     FragType(2)=Class'dnParticles.dnDebrisMesh_GenericTiny1'
     FragType(3)=Class'dnParticles.dnDebrisMesh_GenericTiny1a'
     FragType(4)=Class'dnParticles.dnDebrisMesh_GenericTiny1b'
     SpawnOnHit=Class'dnParticles.dnBulletFX_FabricSpawner'
     DestroyedSound=Sound'a_impact.Debris.ImpactDeb008'
     bLandLeft=True
     bLandRight=True
     LandFrontCollisionRadius=12.000000
     LandFrontCollisionHeight=3.500000
     LandSideCollisionRadius=12.000000
     LandSideCollisionHeight=3.500000
     bPushable=True
     Grabbable=True
     MeshFlameClass=Class'dnParticles.dnFlameThrowerFX_ObjectBurn_Small'
     PlayerViewOffset=(X=0.250000,Y=-0.250000,Z=1.000000)
     Health=0
     ItemName="Boot"
     bFlammable=True
     CollisionRadius=8.000000
     CollisionHeight=8.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone1_vegas.DukC_boot1'
}
