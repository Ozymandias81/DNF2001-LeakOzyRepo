//=============================================================================
// Z1_Hanginglight.
//=============================================================================
// AllenB
class Z1_Hanginglight expands Zone1_Vegas;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx
// September 27th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Glass1'
     FragType(1)=Class'dnParticles.dnDebris_Sparks1_Small'
     FragType(2)=Class'dnParticles.dnDebrisMesh_Glass1'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Glass1a'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Glass1b'
     FragType(5)=Class'dnParticles.dnDebrisMesh_Glass1c'
     FragType(6)=Class'dnParticles.dnDebrisMesh_Glass1d'
     IdleAnimations(0)=hanglight_subtle
     TriggerRadius=12.000000
     TriggerHeight=24.000000
     TriggerType=TT_AnyProximity
     TriggerRetriggerDelay=1.000000
     SpawnOnHit=Class'dnParticles.dnBulletFX_GlassSpawner'
     DamageSequence=hanglight_hit
     TriggeredSequence=hanglight_hit
     DestroyedSound=Sound'a_impact.Glass.GlassBreak73'
     SpawnOnDestroyed(0)=(SpawnClass=Class'dnParticles.dnExplosion3_SElec_Spawner2')
     ItemName="Hanging Light"
     bTakeMomentum=False
     CollisionRadius=8.000000
     CollisionHeight=16.000000
     Mesh=DukeMesh'c_generic.hanginglight'
}
