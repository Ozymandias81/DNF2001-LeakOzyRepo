//=============================================================================
// G_Tire1.
//==========================Created Feb 24th, 1999 - Stephen Cole
class G_Tire1 expands Generic;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx
// September 18th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     DamageThreshold=50
     FragType(0)=Class'dnParticles.dnDebris_Fabric1'
     FragType(1)=Class'dnParticles.dnDebris_Metal1'
     FragType(2)=Class'dnParticles.dnDebris_Sparks1_Small'
     FragType(3)=Class'dnParticles.dnDebris_Smoke'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Metal1'
     FragType(5)=Class'dnParticles.dnDebrisMesh_Metal1a'
     FragType(6)=Class'dnParticles.dnDebrisMesh_Metal1b'
     DestroyedSound=Sound'a_impact.metal.ImpactMtl07'
     MassPrefab=MASS_Heavy
     HealthPrefab=HEALTH_Hard
     bLandUpright=True
     bPushable=True
     Grabbable=True
     PlayerViewOffset=(X=-1.000000,Y=-1.750000,Z=-0.500000)
     ItemName="Tire"
     bFlammable=True
     CollisionRadius=20.000000
     CollisionHeight=7.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_generic.tire1'
}
