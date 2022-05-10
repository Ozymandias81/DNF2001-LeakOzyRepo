//=============================================================================
// Z3_Trailmaker.						November 8th, 2000 - Charlie Wiederhold
//=============================================================================
class Z3_Trailmaker expands Zone3_Canyon;

#exec OBJ LOAD FILE=..\Textures\m_zone3_canyon.dtx
#exec OBJ LOAD FILE=..\Meshes\c_zone3_canyon.dmx

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Wood1'
     FragType(1)=Class'dnParticles.dnDebrisMesh_Wood1'
     FragType(2)=Class'dnParticles.dnDebrisMesh_Wood1a'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Wood1b'
     FragType(4)=Class'dnParticles.dnDebris_Smoke'
     FragType(5)=Class'dnParticles.dnDebris_Wood1'
     SpawnOnHit=Class'dnParticles.dnBulletFX_WoodSpawner'
     DestroyedSound=Sound'a_impact.wood.ImpactWood42'
     bNotTargetable=True
     bTakeMomentum=False
     bFlammable=True
     CollisionRadius=5.500000
     CollisionHeight=16.750000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone3_canyon.trailmarker1'
}
