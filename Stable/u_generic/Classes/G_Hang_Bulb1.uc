//=============================================================================
// G_Hang_Bulb1.
//==========================================Created Feb 24th, 1999 - Stephen Cole
class G_Hang_Bulb1 expands Generic;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx
// September 18th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Glass1'
     FragType(1)=Class'dnParticles.dnDebris_Sparks1_Small'
     FragType(2)=Class'dnParticles.dnDebrisMesh_GenericTiny1'
     FragType(3)=Class'dnParticles.dnDebrisMesh_GenericTiny1a'
     FragType(4)=Class'dnParticles.dnDebrisMesh_GenericTiny1b'
     SpawnOnHit=Class'dnParticles.dnBulletFX_GlassSpawner'
     DestroyedSound=Sound'a_impact.Glass.GlassBreak73'
     SpawnOnDestroyed(0)=(SpawnClass=Class'dnParticles.dnExplosion3_SElec_Spawner2')
     MassPrefab=MASS_Light
     HealthPrefab=HEALTH_Easy
     bHeated=True
     HeatIntensity=128.000000
     HeatRadius=16.000000
     HeatFalloff=128.000000
     ItemName="Hanging Bulb"
     bTakeMomentum=False
     CollisionRadius=2.000000
     CollisionHeight=12.000000
     Mesh=DukeMesh'c_generic.hangbulb1'
     bUnlit=True
}
