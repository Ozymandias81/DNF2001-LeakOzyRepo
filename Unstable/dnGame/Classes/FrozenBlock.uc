/*-----------------------------------------------------------------------------
	FrozenBlock
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class FrozenBlock extends Item
	abstract;

// c_fx.frozen_abdomen, frozen_arm, frozen_legs

defaultproperties
{
	DrawType=DT_Mesh
	DrawScale=1.0
	Physics=PHYS_MovingBrush
	MountType=MOUNT_MeshBone
}