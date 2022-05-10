//=============================================================================
// Z5_Screen1. 						November 10th, 2000 - Charlie Wiederhold
//=============================================================================
class Z5_Screen1 expands Zone5_Area51;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Glass1'
     FragType(1)=Class'dnParticles.dnDebris_Sparks1_Small'
     FragType(2)=Class'dnParticles.dnDebrisMesh_Metal1'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Metal1a'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Metal1b'
     SpawnOnHit=Class'dnParticles.dnBulletFX_GlassSpawner'
     DestroyedSound=Sound'a_impact.Glass.GlassBreak57a'
     SpawnOnDestroyed(0)=(SpawnClass=Class'dnParticles.dnExplosion3_SElec_Spawner2')
     ItemName="Display Screen"
     bTakeMomentum=False
     bFlammable=True
     CollisionRadius=12.000000
     CollisionHeight=15.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone5_area51.m_screen1'
}
