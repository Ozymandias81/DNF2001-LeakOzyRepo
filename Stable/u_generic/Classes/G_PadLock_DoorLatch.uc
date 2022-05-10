//=============================================================================
// G_PadLock_DoorLatch. 				   July 20th, 2001 - Charlie Wiederhold
//=============================================================================
class G_PadLock_DoorLatch expands G_PadLock;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx

defaultproperties
{
     TriggerRadius=0.000000
     TriggerHeight=0.000000
     TriggerType=TT_Shoot
     TriggerMountToDecoration=False
     TriggeredSequence=Break
     TriggeredSound=None
     SpawnOnDestroyed(0)=(SpawnClass=None)
     SpawnOnDestroyed(1)=(SpawnClass=None)
     HealthPrefab=HEALTH_NeverBreak
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     bCollideActors=False
     bProjTarget=False
     Physics=PHYS_MovingBrush
     Mesh=DukeMesh'c_generic.LockLatch'
}
