//=====================================================================
// LANGamesSC.uc  - necessary for setting clientclass to ULANGamesCW
//=====================================================================

class ULANGamesSC expands UWindowScrollingDialogClient;

function Created()
{
	ClientClass = class'ULANGamesCW';
	FixedAreaClass = None;
	Super.Created();
}

defaultproperties
{
}
