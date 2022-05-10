//=============================================================================
//RouteRandomizer.
//=============================================================================
class RouteRandomizer extends NavigationPoint;

var()	float ToggledCost;

Auto State CostDisabled
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		GotoState('CostEnabled');
	}
}

state CostEnabled
{
	event int SpecialCost(Pawn Seeker)
	{
		if ( !Seeker.bIsPlayer )
			return 0;

		return ToggledCost;
	}

	function Trigger( actor Other, pawn EventInstigator )
	{
		GotoState('CostDisabled');
	}
}

defaultproperties
{
}
