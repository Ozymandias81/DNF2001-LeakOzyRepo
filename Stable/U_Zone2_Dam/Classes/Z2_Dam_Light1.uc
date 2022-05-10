//=============================================================================
// Z2_Dam_Light1.
//=============================================================================
// AllenB

#exec OBJ LOAD FILE=..\Textures\m_zone2_dam.dtx
#exec OBJ LOAD FILE=..\Meshes\c_zone2_dam.dmx

class Z2_Dam_Light1 expands Zone2_Dam;

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Glass1'
     FragType(1)=Class'dnParticles.dnDebris_Sparks1'
     FragType(2)=Class'dnParticles.dnDebrisMesh_Glass1'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Glass1a'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Glass1b'
     FragType(5)=Class'dnParticles.dnDebrisMesh_Glass1c'
     FragType(6)=Class'dnParticles.dnDebrisMesh_Glass1d'
     SpawnOnHit=Class'dnParticles.dnBulletFX_GlassSpawner'
     DestroyedSound=Sound'a_impact.Glass.GlassBreak57a'
     SpawnOnDestroyed(0)=(SpawnClass=Class'dnParticles.dnExplosion3_SElec_Spawner2')
     PlayerViewOffset=(X=0.000000,Y=0.000000,Z=0.000000)
     bHeated=True
     HeatIntensity=255.000000
     HeatRadius=16.000000
     HeatFalloff=128.000000
     ItemName="Wall Light"
     bTakeMomentum=False
     bFlammable=True
     CollisionRadius=10.000000
     CollisionHeight=16.000000
     bCollideWorld=False
     bBlockActors=False
     bBlockPlayers=False
     bProjTarget=True
     Mesh=DukeMesh'c_zone2_dam.dam_light1'
     DrawScale=1.110000
}
