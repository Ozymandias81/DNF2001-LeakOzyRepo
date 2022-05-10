//=============================================================================
// BlockedPath.
//=============================================================================
class BlockedPath extends NavigationPoint;

function Trigger( actor Other, pawn EventInstigator )
{
	ExtraCost = 0;
}

defaultproperties
{
	ExtraCost=100000000
}