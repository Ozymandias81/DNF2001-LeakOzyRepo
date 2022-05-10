//=============================================================================
// LeverControl1. Keith Schuler 9/4/2000
//=============================================================================
class LeverControl1 expands TriggerCrane;

defaultproperties
{
     DeactivatedSequence=Normal
     ActivateSequence=Activate
     IdleSequence=IdleA
     ForwardStartSequence=mainlever_forward
     ForwardIdleSequence=mainlever_forward_constant
     ForwardReleaseSequence=mainlever_forward_return
     BackwardStartSequence=mainlever_backward
     BackwardIdleSequence=mainlever_backward_constant
     BackwardReleaseSequence=mainlever_backward_return
     LeftStartSequence=mainlever_left
     LeftIdleSequence=mainlever_left_constant
     LeftReleaseSequence=mainlever_left_return
     RightStartSequence=mainlever_right
     RightIdleSequence=mainlever_right_constant
     RightReleaseSequence=mainlever_right_return
     UpDownActivateSequence=slidelever_grab
     UpDownDeactivateSequence=slidelever_release
     UpStartSequence=slidelever_forward
     UpIdleSequence=slidelever_forward_constant
     UpReleaseSequence=slidelever_forward_return
     DownStartSequence=slidelever_backward
     DownIdleSequence=slidelever_backward_constant
     DownReleaseSequence=slidelever_backward_return
     GrabReleaseSequence=press_button
     ItemName="Lever Control"
     bTickNotRelevant=False
     bHidden=False
     Physics=PHYS_MovingBrush
     DrawType=DT_Mesh
     Mesh=DukeMesh'c_hands.levers'
     bMeshLowerByCollision=False
     CollisionRadius=20.000000
     CollisionHeight=10.000000
     bCollideActors=False
     AnimRate=2.000000
}
