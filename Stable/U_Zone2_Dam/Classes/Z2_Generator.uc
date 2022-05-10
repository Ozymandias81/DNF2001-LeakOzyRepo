//=============================================================================
// Z2_Generator. 						November 7th, 2000 - Charlie Wiederhold
//=============================================================================
class Z2_Generator expands Zone2_Dam;

#exec OBJ LOAD FILE=..\Textures\m_zone2_dam.dtx
#exec OBJ LOAD FILE=..\Meshes\c_zone2_dam.dmx

defaultproperties
{
     DamageThreshold=50
     FragType(0)=Class'dnParticles.dnDebrisMesh_MetalMedium1'
     FragType(1)=Class'dnParticles.dnDebrisMesh_MetalMedium1a'
     FragType(2)=Class'dnParticles.dnDebris_Metal1'
     FragType(3)=Class'dnParticles.dnDebrisMesh_MetalMedium1c'
     FragType(4)=Class'dnParticles.dnDebrisMesh_MetalMedium1a'
     DestroyedSound=Sound'a_impact.metal.ImpactMtl07'
     SpawnOnDestroyed(0)=(SpawnClass=Class'dnParticles.dnExplosion1')
     SpawnOnDestroyed(1)=(SpawnClass=Class'U_Zone2_Dam.Z2_Generator_Broken')
     HealthPrefab=HEALTH_Hard
     ItemName="Generator"
     bNotTargetable=True
     bTakeMomentum=False
     CollisionRadius=70.000000
     CollisionHeight=140.000000
     WaterSplashClass=None
     Mesh=DukeMesh'c_zone2_dam.generator_dam'
}
