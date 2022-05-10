//=============================================================================
// Z1_StatueGriffon1.
//=============================================================================
class Z1_StatueGriffon1 expands Zone1_Vegas;

// KS AB 2/23/99

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx
// September 28th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     DamageThreshold=50
     FragType(0)=Class'dnParticles.dnDebris_Metal1'
     FragType(1)=Class'dnParticles.dnDebris_Sparks1_Large'
     FragType(2)=Class'dnParticles.dnDebris_Smoke'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Metal1'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Metal1a'
     FragType(5)=Class'dnParticles.dnDebrisMesh_Metal1b'
     FragType(6)=Class'dnParticles.dnDebrisMesh_Metal1c'
     DestroyedSound=Sound'a_impact.metal.ImpactMtl07'
     HealthPrefab=HEALTH_Hard
     Health=0
     ItemName="Griffon Statue"
     bTakeMomentum=False
     CollisionRadius=46.000000
     CollisionHeight=28.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone1_vegas.griffon1'
     DrawScale=1.250000
}
