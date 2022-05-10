//=============================================================================
// Z1_Vines.
//=============================================================================
// AllenB
class Z1_Vines expands Zone1_Vegas;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx
// September 28th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     FragType(1)=Class'dnParticles.dnLeaves'
     FragType(2)=Class'dnParticles.dnDebris_Dirt1'
     FragType(3)=Class'dnParticles.dnDebris_Smoke_Dirt1'
     IdleAnimations(0)=breeze
     IdleAnimations(1)=breeze
     IdleAnimations(2)=breeze
     IdleAnimations(3)=breeze
     TriggerRadius=16.000000
     TriggerHeight=32.000000
     TriggerType=TT_AnyProximity
     TriggerRetriggerDelay=1.000000
     SpawnOnHit=Class'dnParticles.dnBulletFX_LeavesSpawner'
     TouchedSequence=shot
     TriggeredSequence=shot
     DestroyedSound=Sound'a_impact.Foliage.ImpFoliage014'
     bNotTargetable=True
     bTakeMomentum=False
     bFlammable=True
     CollisionRadius=32.000000
     CollisionHeight=64.000000
     bBlockActors=False
     bBlockPlayers=False
     bProjTarget=True
     Style=STY_Masked
     Texture=Texture'm_generic.plant01'
     Mesh=DukeMesh'c_zone1_vegas.vines'
     bParticles=True
     DrawScale=0.100000
}
