//=============================================================================
// Z1_StatueMermaid1.
//=============================================================================
class Z1_StatueMermaid1 expands Zone1_Vegas;

// Keith Schuler 2/23/99

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx
// September 28th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     DamageThreshold=50
     FragType(0)=Class'dnParticles.dnDebris_Metal1'
     FragType(1)=Class'dnParticles.dnDebris_Smoke'
     FragType(2)=Class'dnParticles.dnDebris_Sparks1_Large'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Metal1'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Metal1a'
     FragType(5)=Class'dnParticles.dnDebrisMesh_Metal1b'
     FragType(6)=Class'dnParticles.dnDebrisMesh_Metal1c'
     DestroyedSound=Sound'a_impact.metal.ImpactMtl07'
     HealthPrefab=HEALTH_Hard
     Health=0
     ItemName="Mermaid Statue"
     bTakeMomentum=False
     CollisionRadius=32.000000
     CollisionHeight=60.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone1_vegas.mermaid1'
}
