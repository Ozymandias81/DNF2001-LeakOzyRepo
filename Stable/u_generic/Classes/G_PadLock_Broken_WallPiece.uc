//=============================================================================
// G_PadLock_Broken_WallPiece. 			   July 20th, 2001 - Charlie Wiederhold
//=============================================================================
class G_PadLock_Broken_WallPiece expands G_PadLock;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx

defaultproperties
{
     IdleAnimations(0)=idleopen
     TriggerRadius=0.000000
     TriggerHeight=0.000000
     TriggerType=TT_PlayerProximityAndUse
     DestroyedEvent=None
     DamageSequence=None
     TriggeredSequence=None
     DestroyedSound=Sound'a_impact.Generic.ImpactGen001A'
     TriggeredSound=None
     SpawnOnDestroyed(0)=(SpawnClass=None,bTossDecoration=False,bUseAlternateMotion=False,SpawnRotationVariance=(Pitch=0,Yaw=0,Roll=0),SpawnSpeed=0.000000,SpawnSpeedVariance=0.000000)
     SpawnOnDestroyed(1)=(SpawnClass=None)
     HealthPrefab=HEALTH_NeverBreak
     bCollideActors=False
}
