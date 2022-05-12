//=============================================================================
// NoRedeemer.
// removes all redeemers
//=============================================================================

class NoRedeemer expands Mutator;

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if ( Other.IsA('WarHeadLauncher') )
		return false;

	return true;
}

defaultproperties
{
}