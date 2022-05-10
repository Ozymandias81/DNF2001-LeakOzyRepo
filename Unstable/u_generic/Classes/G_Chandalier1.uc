//=============================================================================
// G_Chandalier1.
//==========================================Created Feb 24th, 1999 - Stephen Cole
class G_Chandalier1 expands Generic;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx
// September 18th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     DontDie=True
     HealthMarkers(0)=(Threshold=35,PlaySequence=Damage1,SpawnActor=Class'dnParticles.dnDebris_Glass_Chandalier')
     HealthMarkers(1)=(Threshold=25,PlaySequence=Damage2,SpawnActor=Class'dnParticles.dnDebris_Glass_Chandalier')
     HealthMarkers(2)=(Threshold=15,PlaySequence=damage3,SpawnActor=Class'dnParticles.dnDebris_Glass_Chandalier')
     HealthMarkers(3)=(Threshold=5,PlaySequence=Damage4,SpawnActor=Class'dnParticles.dnExplosion3_SmallElectronic')
     bUseLastMarkerAnim=True
     FragType(0)=Class'dnParticles.dnDebrisMesh_Glass1'
     FragType(1)=Class'dnParticles.dnDebrisMesh_Glass1a'
     FragType(2)=Class'dnParticles.dnDebrisMesh_Glass1b'
     FragType(3)=Class'dnParticles.dnDebris_Sparks1_Large'
     FragType(4)=Class'dnParticles.dnDebris_Glass_Chandalier'
     FragType(5)=Class'dnParticles.dnDebris_Smoke'
     SpawnOnHit=Class'dnParticles.dnWallSpark'
     DestroyedSound=Sound'a_impact.Glass.GlassBreak57a'
     bTumble=False
     MassPrefab=MASS_Heavy
     HealthPrefab=HEALTH_SortaHard
     MeshFlameClass=Class'dnParticles.dnFlameThrowerFX_ObjectBurn_Large_30x30'
     ItemName="Chandalier"
     bTakeMomentum=False
     bFlammable=True
     CollisionRadius=33.000000
     CollisionHeight=40.000000
     Mesh=DukeMesh'c_zone1_vegas.chandalier1RC'
}
