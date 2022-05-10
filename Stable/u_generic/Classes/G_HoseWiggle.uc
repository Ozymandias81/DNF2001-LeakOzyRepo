//=============================================================================
// G_HoseWiggle.	Keith Schuler Nov 13, 2000
//=============================================================================
class G_HoseWiggle expands Generic;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx

defaultproperties
{
     MountOnSpawn(0)=(ActorClass=Class'dnParticles.dnSmokeEffect_HoseSpray',MountType=MOUNT_MeshSurface,MountMeshItem=Smoke,AppendToTag=Smoke,TakeParentTag=True)
     DontDie=True
     TriggerRadius=6.000000
     TriggerHeight=30.500000
     TriggerType=TT_Shoot
     TriggerEvent=G_HoseWiggleSmoke
     bSequenceToggle=True
     ToggleOnSequences(0)=(PlaySequence=FallGround)
     ToggleOnSequences(1)=(PlaySequence=WiggleGround,loop=True)
     bTakeMomentum=False
     HealthPrefab=HEALTH_UseHealthVar
     Mesh=DukeMesh'c_generic.HoseA'
     bNotTargetable=True
     CollisionRadius=3.000000
     CollisionHeight=30.500000
     bCollideWorld=False
     bBlockActors=False
     bBlockPlayers=False
     bProjTarget=True
     Health=2
}
