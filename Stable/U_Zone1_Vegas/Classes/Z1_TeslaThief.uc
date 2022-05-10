//=============================================================================
// Z1_TeslaThief. 						October 26th, 2000 - Charlie Wiederhold
//=============================================================================
class Z1_TeslaThief expands Zone1_Vegas;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Sparks1'
     FragType(1)=Class'dnParticles.dnDebris_Metal1'
     FragType(2)=Class'dnParticles.dnDebrisMesh_Metal1'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Metal1a'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Metal1b'
     FragType(5)=Class'dnParticles.dnDebrisMesh_Metal1'
     FragType(6)=Class'dnParticles.dnDebrisMesh_Metal1a'
     DestroyedSound=Sound'a_impact.metal.ImpactMtl07'
     SpawnOnDestroyed(0)=(SpawnClass=Class'dnParticles.dnExplosion3_SElec_Spawner2')
     MeshFlameClass=Class'dnParticles.dnFlameThrowerFX_ObjectBurn_Large_30x30'
     PlayerViewOffset=(X=0.000000,Y=0.000000,Z=0.000000)
     BobDamping=0.900000
     ItemName="I Have No Idea What This Damn Thing Is"
     bTakeMomentum=False
     bFlammable=True
     CollisionRadius=54.000000
     CollisionHeight=36.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone1_vegas.teslathief'
}
