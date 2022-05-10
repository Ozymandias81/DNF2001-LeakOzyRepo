/*-----------------------------------------------------------------------------
	DoorHandle
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class DoorHandle extends Decoration;

var() vector HandleOffset;
var() rotator RotationOffset;
var() bool bAnimates;
var() name OpenSequence;
var() name LockedSequence;
var() bool bCentered;
var() bool bSideSpecific;

var mesh LeftMesh, RightMesh;

function SetSide(int Left)
{
	if (!bSideSpecific)
		return;

	if (Left == 1)
		Mesh = LeftMesh;
	else
		Mesh = RightMesh;
}

function PlayOpenDoor()
{
	if (!bAnimates)
		return;

	if (OpenSequence != '')
		PlayAnim(OpenSequence);
	else 
		PlayAnim('open');
}

function PlayLockedDoor()
{
	if (!bAnimates)
		return;

	if (LockedSequence !='')
		PlayAnim(LockedSequence);
	else
		PlayAnim('locked');
}

defaultproperties
{
     Physics=PHYS_MovingBrush
     LodMode=LOD_Disabled
     DrawType=DT_Mesh
     Texture=Texture'Engine.S_Actor'
}
