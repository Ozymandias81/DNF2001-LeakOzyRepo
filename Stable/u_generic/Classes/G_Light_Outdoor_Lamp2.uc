//=============================================================================
// G_Light_Outdoor_Lamp2.
//============================================Created Feb 24th, 1999 - Stephen Cole
class G_Light_Outdoor_Lamp2 expands Generic;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx
// September 18th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebrisMesh_GenericTiny1'
     FragType(1)=Class'dnParticles.dnDebrisMesh_GenericTiny1a'
     FragType(2)=Class'dnParticles.dnDebrisMesh_GenericTiny1b'
     FragType(3)=Class'dnParticles.dnDebris_Sparks1'
     FragType(4)=Class'dnParticles.dnDebris_Glass1'
     DestroyedSound=Sound'a_impact.metal.ImpactMtl07'
     SpawnOnDestroyed(0)=(SpawnClass=Class'dnParticles.dnExplosion3_SElec_Spawner2')
     HealthPrefab=HEALTH_Easy
     bHeated=True
     HeatIntensity=255.000000
     HeatRadius=16.000000
     HeatFalloff=128.000000
     ItemName="Outdoor Lamp"
     bTakeMomentum=False
     CollisionRadius=8.000000
     CollisionHeight=3.000000
     Mesh=DukeMesh'c_generic.outdoorlamp2'
}
