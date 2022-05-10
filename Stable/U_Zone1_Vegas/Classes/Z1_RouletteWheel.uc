//=============================================================================
// Z1_RouletteWheel.					October 26th, 2000 - Charlie Wiederhold
//=============================================================================
class Z1_RouletteWheel expands Zone1_Vegas;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebrisMesh_Generic1'
     FragType(1)=Class'dnParticles.dnDebrisMesh_Generic1a'
     FragType(2)=Class'dnParticles.dnDebris_Sparks1_Small'
     FragType(3)=Class'dnParticles.dnDebris_Wood1'
     FragType(4)=Class'dnParticles.dnDebris_Smoke'
     SpawnOnHit=Class'dnParticles.dnBulletFX_WoodSpawner'
     DestroyedSound=Sound'a_impact.wood.ImpactWood42'
     ItemName="Roulette Wheel"
     bTakeMomentum=False
     bFlammable=True
     CollisionRadius=15.000000
     CollisionHeight=8.000000
     Mesh=DukeMesh'c_zone1_vegas.rwheel'
}
