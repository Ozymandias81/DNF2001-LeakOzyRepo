//=============================================================================
// G_Table1.
//======================Created Feb 24th, 1999 - Stephen Cole
class G_Table1 expands Generic;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx
// September 18th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     DamageThreshold=50
     FragType(0)=Class'dnParticles.dnDebris_Cement1'
     FragType(1)=Class'dnParticles.dnDebris_Cement1'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Cement1'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Cement1a'
     FragType(5)=Class'dnParticles.dnDebrisMesh_Cement1b'
     FragType(6)=Class'dnParticles.dnDebris_Smoke'
     SpawnOnHit=Class'dnParticles.dnBulletFX_CementSpawner'
     DestroyedSound=Sound'a_impact.Rock.RockBrk03'
     MassPrefab=MASS_Heavy
     HealthPrefab=HEALTH_Hard
     Health=0
     ItemName="Table"
     CollisionRadius=29.000000
     CollisionHeight=19.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_generic.umbrellatable1'
}
