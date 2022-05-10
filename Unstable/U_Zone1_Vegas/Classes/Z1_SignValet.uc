//=============================================================================
// Z1_SignValet.
//=============================================================================
class Z1_SignValet expands Zone1_Vegas;

// Keith Schuler 2/23/99

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx
// September 28th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Wood1'
     FragType(1)=Class'dnParticles.dnDebris_Smoke'
     FragType(2)=Class'dnParticles.dnDebris_Sparks1_Small'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Wood1'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Wood1a'
     FragType(5)=Class'dnParticles.dnDebrisMesh_Wood1b'
     SpawnOnHit=Class'dnParticles.dnBulletFX_WoodSpawner'
     DestroyedSound=Sound'a_impact.wood.ImpactWood1A'
     bLandForward=True
     bLandBackwards=True
     LandFrontCollisionRadius=48.000000
     LandFrontCollisionHeight=1.500000
     LandSideCollisionRadius=48.000000
     LandSideCollisionHeight=1.500000
     Grabbable=True
     PlayerViewOffset=(X=0.000000,Y=1.000000,Z=1.500000)
     BobDamping=0.900000
     ItemName="Valet Sign"
     bTakeMomentum=False
     CollisionRadius=11.000000
     CollisionHeight=26.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone1_vegas.vsign'
}
