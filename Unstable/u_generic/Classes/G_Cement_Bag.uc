//=============================================================================
// G_Cement_Bag.
//====================================Created Feb 24th, 1999 - Stephen Cole
class G_Cement_Bag expands Generic;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx
// September 18th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     DamageThreshold=50
     FragType(0)=Class'dnParticles.dnDebris_Cement1'
     FragType(1)=Class'dnParticles.dnDebrisMesh_Cement1'
     FragType(2)=Class'dnParticles.dnDebrisMesh_Cement1a'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Cement1b'
     SpawnOnHit=Class'dnParticles.dnBulletFX_CementSpawner'
     DestroyedSound=Sound'a_impact.Rock.RockBrk03'
     MassPrefab=MASS_Heavy
     HealthPrefab=HEALTH_Hard
     bLandUpright=True
     Grabbable=True
     PlayerViewOffset=(X=-1.500000,Y=-1.750000,Z=-1.500000)
     ItemName="Cement Bag"
     bFlammable=True
     CollisionRadius=26.000000
     CollisionHeight=7.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_generic.cement_bag1'
}
