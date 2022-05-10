//=============================================================================
// PathWeightTrigger.uc
//
// This trigger will modify the extra cost setting of any Navigation Points
// with tags that match this trigger's event.
//=============================================================================
class PathWeightTrigger expands Triggers;

var() int ExtraCost ?("Extra cost to be applied to this pathnode.");

function Trigger( actor Other, pawn EventInstigator )
{	
	local NavigationPoint N;

	// Validate event:
	if( Event != '' )
	{
		// Trigger all actors with matching tags:
		for( N = Level.NavigationPointList; N != None; N = N.NextNavigationPoint )
		{
			if( N.Tag == Event )
			{
				N.ExtraCost = ExtraCost;
			}
		}
	}
}

defaultproperties
{
     Texture=Texture'Engine.S_Trigger'
     ExtraCost=10000000
}
