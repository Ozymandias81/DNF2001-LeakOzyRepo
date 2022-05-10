//=============================================================================
// G_SirenRed. 							 October 9th, 2000 - Charlie Wiederhold
//=============================================================================
class G_SirenRed expands Generic;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Glass1'
     FragType(1)=Class'dnParticles.dnDebris_Sparks1_Small'
     FragType(2)=Class'dnParticles.dnDebrisMesh_Glass1'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Glass1a'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Glass1b'
     FragType(5)=Class'dnParticles.dnDebrisMesh_Glass1c'
     FragType(6)=Class'dnParticles.dnDebrisMesh_Glass1d'
     SpawnOnHit=Class'dnParticles.dnBulletFX_GlassSpawner'
     DestroyedSound=Sound'a_impact.Glass.GlassBreak73'
     SpawnOnDestroyed(0)=(SpawnClass=Class'dnParticles.dnExplosion3_SElec_Spawner2')
     MeshFlameClass=Class'dnParticles.dnFlameThrowerFX_ObjectBurn_Small'
     ItemName="Siren"
     bTakeMomentum=False
     bFlammable=True
     CollisionRadius=6.000000
     CollisionHeight=6.000000
     Mesh=DukeMesh'c_generic.redsirenRC'
}
