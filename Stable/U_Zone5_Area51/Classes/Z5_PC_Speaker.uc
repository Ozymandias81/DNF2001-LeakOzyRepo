//=============================================================================
// Z5_PC_Speaker. 						November 10th, 2000 - Charlie Wiederhold
//=============================================================================
class Z5_PC_Speaker expands Zone5_Area51;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebrisMesh_MetalMedium1'
     FragType(1)=Class'dnParticles.dnDebrisMesh_MetalMedium1a'
     FragType(2)=Class'dnParticles.dnDebrisMesh_MetalMedium1b'
     FragType(4)=Class'dnParticles.dnDebris_Sparks1_Large'
     FragType(5)=Class'dnParticles.dnDebris_Fabric1'
     FragType(6)=Class'dnParticles.dnDebris_Metal1'
     DestroyedSound=Sound'a_impact.metal.ImpactMtl07'
     SpawnOnDestroyed(0)=(SpawnClass=Class'dnParticles.dnExplosion3_SElec_Spawner2')
     HealthPrefab=HEALTH_SortaHard
     ItemName="PC Speaker"
     bTakeMomentum=False
     CollisionRadius=45.000000
     CollisionHeight=13.000000
     Mesh=DukeMesh'c_zone5_area51.PC_speaker'
}
