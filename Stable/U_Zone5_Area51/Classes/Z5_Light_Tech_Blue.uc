//=============================================================================
// Z5_Light_Tech_Blue. 						November 10th, 2000 - Charlie Wiederhold
//=============================================================================
class Z5_Light_Tech_Blue expands Zone5_Area51;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Glass1'
     FragType(1)=Class'dnParticles.dnDebris_Sparks1_Small'
     FragType(2)=Class'dnParticles.dnDebrisMesh_Glass1'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Glass1a'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Glass1b'
     FragType(5)=Class'dnParticles.dnDebrisMesh_Glass1c'
     FragType(6)=Class'dnParticles.dnDebrisMesh_Glass1d'
     FragType(7)=Class'dnParticles.dnDebris_Metal1_Small'
     SpawnOnHit=Class'dnParticles.dnBulletFX_GlassSpawner'
     DestroyedSound=Sound'a_impact.Glass.GlassBreak73'
     SpawnOnDestroyed(0)=(SpawnClass=Class'dnParticles.dnExplosion3_SElec_Spawner2')
     ItemName="Wall Light"
     bNotTargetable=True
     bTakeMomentum=False
     bFlammable=True
     CollisionRadius=8.000000
     CollisionHeight=12.000000
     Mesh=DukeMesh'c_zone5_area51.techlite_blue'
}
