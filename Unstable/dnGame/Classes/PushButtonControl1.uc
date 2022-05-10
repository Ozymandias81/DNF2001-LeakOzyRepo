//=============================================================================
// PushButtonControl1. Keith Schuler 9/4/2000
//=============================================================================
class PushButtonControl1 expands TriggerCrane;

defaultproperties
{
     DeactivatedSequence=Deactivate
     ActivateSequence=Activate
     IdleSequence=ud_idlea
     ForwardStartSequence=ud_upactivate
     ForwardIdleSequence=ud_uphold
     ForwardReleaseSequence=ud_uprelease
     BackwardStartSequence=ud_dwnactivate
     BackwardIdleSequence=ud_dwnhold
     BackwardReleaseSequence=ud_dwnrelease
     UpDownActivateSequence=lr_activate
     UpDownDeactivateSequence=lr_deactive
     UpStartSequence=lr_ractivate
     UpIdleSequence=lr_rhold
     UpReleaseSequence=lr_rrelease
     DownStartSequence=lr_lactivate
     DownIdleSequence=lr_lhold
     DownReleaseSequence=lr_lrelease
     StaticSequence=Static
     ForwardSound=Sound'crane.MoveLoops.CraneMoveLoop06'
     BackwardSound=Sound'crane.MoveLoops.CraneMoveLoop06'
     UpSound=Sound'crane.MoveLoops.CraneMoveLoop06'
     DownSound=Sound'crane.MoveLoops.CraneMoveLoop06'
     ItemName="Push Button Control"
     bHidden=False
     Physics=PHYS_MovingBrush
     bDirectional=True
     DrawType=DT_Mesh
     Mesh=DukeMesh'c_hands.keithcontrols'
     bMeshLowerByCollision=False
     CollisionRadius=10.000000
     CollisionHeight=13.000000
}
