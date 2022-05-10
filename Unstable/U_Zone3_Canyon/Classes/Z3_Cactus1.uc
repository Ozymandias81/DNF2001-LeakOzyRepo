//=============================================================================
// Z3_Cactus1. 							November 8th, 2000 - Charlie Wiederhold
//=============================================================================
class Z3_Cactus1 expands Zone3_Canyon;

#exec OBJ LOAD FILE=..\Textures\m_zone3_canyon.dtx
#exec OBJ LOAD FILE=..\Meshes\c_zone3_canyon.dmx

defaultproperties
{
     FragType(1)=Class'dnParticles.dnLeaves'
     FragType(2)=Class'dnParticles.dnDebrisMesh_GenericTiny1'
     FragType(3)=Class'dnParticles.dnDebrisMesh_GenericTiny1a'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Generic1'
     FragType(5)=Class'dnParticles.dnDebrisMesh_Generic1a'
     FragType(6)=Class'dnParticles.dnDebris_Smoke'
     FragType(7)=Class'dnParticles.dnDebris_Dirt1'
     SpawnOnHit=Class'dnParticles.dnBulletFX_LeavesSpawner'
     DestroyedSound=Sound'a_impact.Foliage.ImpFoliage014'
     bNotTargetable=True
     bTakeMomentum=False
     bFlammable=True
     CollisionRadius=33.000000
     CollisionHeight=24.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone3_canyon.Cactus2'
}
