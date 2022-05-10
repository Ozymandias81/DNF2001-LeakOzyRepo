//=============================================================================
// Z5_CialiticLight2. 						November 10th, 2000 - Charlie Wiederhold
//=============================================================================
class Z5_CialiticLight2 expands Zone5_Area51;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Metal1_Small'
     FragType(1)=Class'dnParticles.dnDebris_Sparks1'
     FragType(2)=Class'dnParticles.dnDebrisMesh_Metal1'
     FragType(3)=Class'dnParticles.dnDebrisMesh_GenericTiny1'
     FragType(4)=Class'dnParticles.dnDebrisMesh_GenericTiny1a'
     FragType(5)=Class'dnParticles.dnDebrisMesh_GenericTiny1b'
     FragType(6)=Class'dnParticles.dnDebrisMesh_Metal1a'
     FragType(7)=Class'dnParticles.dnDebrisMesh_Metal1b'
     DestroyedSound=Sound'a_impact.metal.ImpactMtl07'
     SpawnOnDestroyed(0)=(SpawnClass=Class'dnParticles.dnExplosion3_SElec_Spawner2')
     ItemName="Cialitic Lamp"
     bTakeMomentum=False
     CollisionRadius=19.000000
     Mesh=DukeMesh'c_zone5_area51.cialiticlight2'
}
