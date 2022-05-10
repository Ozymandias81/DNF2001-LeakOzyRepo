//=============================================================================
// G_TV2.							Keith Schuler 5/26/99
//=============================================================================
class G_TV2 expands Generic;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx
// September 18th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     HealthMarkers(0)=(Threshold=10,PlaySequence=TVFS_destroy1)
     HealthMarkerSpawnFrags(0)=10
     FragType(0)=Class'dnParticles.dnDebris_Glass1'
     FragType(1)=Class'dnParticles.dnDebris_Metal1'
     FragType(2)=Class'dnParticles.dnDebris_Sparks1_Large'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Glass1'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Glass1a'
     FragType(5)=Class'dnParticles.dnDebrisMesh_Glass1b'
     FragType(6)=Class'dnParticles.dnDebrisMesh_Glass1c'
     SpawnOnHit=Class'dnParticles.dnBulletFX_GlassSpawner'
     SpawnOnDestroyed(0)=(SpawnClass=Class'dnParticles.dnExplosion3_SmallElectronic')
     bHeated=True
     HeatIntensity=255.000000
     HeatRadius=16.000000
     HeatFalloff=128.000000
     ItemName="Flat Screen TV"
     bFlammable=True
     CollisionRadius=32.000000
     CollisionHeight=22.000000
     bCollideWorld=False
     bBlockActors=False
     bBlockPlayers=False
     bProjTarget=True
     Mesh=DukeMesh'c_generic.TV_flatscreen'
}
