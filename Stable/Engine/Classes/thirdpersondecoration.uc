//=============================================================================
// Decoration.
//=============================================================================
class ThirdPersonDecoration expands Decoration;

defaultproperties
{
    MountType=MOUNT_MeshBone;
    MountMeshItem=Hand_R
    bOwnerSeeSpecial=true
    Physics=PHYS_MovingBrush
    bCollideWorld=false
    bCollideActors=false
    bBlockPlayers=false
    bBlockActors=false
    CollisionRadius=0
    CollisionHeight=0
    DrawType=DT_Mesh
    RemoteRole=ROLE_DumbProxy
}