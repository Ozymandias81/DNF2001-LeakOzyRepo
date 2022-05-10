//=============================================================================
// G_Light_Halogen.
//=====================================Created Feb 24th, 1999 - Stephen Cole
class G_Light_Halogen expands Generic;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx
// September 18th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     DamageThreshold=50
     FragType(0)=Class'dnParticles.dnDebris_Sparks1'
     FragType(1)=Class'dnParticles.dnDebrisMesh_Metal1'
     FragType(2)=Class'dnParticles.dnDebrisMesh_Metal1a'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Metal1b'
     FragType(4)=Class'dnParticles.dnDebris_Metal1'
     FragType(5)=Class'dnParticles.dnDebris_Glass1'
     DamageOnHitWall=100
     DamageOnHitWater=100
     DestroyedSound=Sound'a_impact.metal.ImpactMtl07'
     SpawnOnDestroyed(0)=(SpawnClass=Class'dnParticles.dnExplosion3_SmallElectronic')
     HealthPrefab=HEALTH_Hard
     bHeated=True
     HeatIntensity=128.000000
     HeatRadius=16.000000
     HeatFalloff=128.000000
     ItemName="Halogen Lamp"
     bTakeMomentum=False
     CollisionRadius=12.000000
     CollisionHeight=14.000000
     Mesh=DukeMesh'c_generic.light_halogen'
}
