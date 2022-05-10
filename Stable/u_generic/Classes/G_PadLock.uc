//=============================================================================
// G_PadLock. 							   July 20th, 2001 - Charlie Wiederhold
//=============================================================================
class G_PadLock expands Generic;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx
#exec OBJ LOAD FILE=..\sounds\a_doors.dfx

defaultproperties
{
     IdleAnimations(0)=Idle
     TriggerRadius=32.000000
     TriggerHeight=32.000000
     TriggerType=TT_PlayerProximityAndLookUse
     DamageSequence=jiggle
     TriggeredSequence=jiggle
     DestroyedSound=Sound'a_impact.metal.MetalGibExpl01'
     TriggeredSound=Sound'a_doors.metal.DoorJiggle02'
     SpawnOnDestroyed(0)=(SpawnClass=Class'U_Generic.G_PadLock_Broken_FallingLock',bTossDecoration=True,bUseAlternateMotion=True,AlternateMotion=(SpawnRotationVariance=(Pitch=6144,Yaw=6144,Roll=6144),SpawnSpeed=48.000000,SpawnSpeedVariance=64.000000))
     SpawnOnDestroyed(1)=(SpawnClass=Class'U_Generic.G_PadLock_Broken_WallPiece')
     LandFrontCollisionRadius=6.000000
     LandFrontCollisionHeight=6.000000
     LandSideCollisionRadius=6.000000
     LandSideCollisionHeight=6.000000
     bTakeMomentum=False
     CollisionRadius=3.000000
     CollisionHeight=8.000000
     bCollideWorld=False
     bBlockActors=False
     bBlockPlayers=False
     bProjTarget=True
     bMeshLowerByCollision=False
     Mesh=DukeMesh'c_generic.LockDoor'
}
