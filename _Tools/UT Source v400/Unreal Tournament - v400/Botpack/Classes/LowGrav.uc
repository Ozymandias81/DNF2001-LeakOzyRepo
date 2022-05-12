//=============================================================================
// LowGrav.
// makes all zones low gravity
//=============================================================================

class LowGrav expands Mutator;

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if ( Other.IsA('UT_JumpBoots') )
		return false;

	if ( Other.IsA('ZoneInfo') )
	{
		ZoneInfo(Other).ZoneGravity = vect(0,0,-200); 
	}

	bSuperRelevant = 0;
	return true;
}

defaultproperties
{
}