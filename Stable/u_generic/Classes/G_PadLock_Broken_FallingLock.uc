//=============================================================================
// G_PadLock_Broken_FallingLock. 		   July 20th, 2001 - Charlie Wiederhold
//=============================================================================
class G_PadLock_Broken_FallingLock expands G_PadLock;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx

defaultproperties
{
     TriggerRadius=0.000000
     TriggerHeight=0.000000
     TriggerType=TT_PlayerProximityAndUse
     TriggeredSequence=None
     DestroyedSound=Sound'a_impact.Generic.ImpactGen001A'
     TriggeredSound=None
     SpawnOnDestroyed(0)=(SpawnClass=None,bTossDecoration=False,bUseAlternateMotion=False)
     SpawnOnDestroyed(1)=(SpawnClass=None)
     HealthPrefab=HEALTH_NeverBreak
     bLandForward=True
     bLandBackwards=True
     LandFrontCollisionRadius=3.000000
     LandFrontCollisionHeight=0.500000
     LandSideCollisionRadius=3.000000
     LandSideCollisionHeight=0.500000
     Grabbable=True
     PlayerViewOffset=(X=1.000000,Y=-0.750000,Z=1.500000)
     BobDamping=0.950000
     bTakeMomentum=True
     CollisionHeight=3.000000
     bCollideWorld=True
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_generic.LockPad'
}
