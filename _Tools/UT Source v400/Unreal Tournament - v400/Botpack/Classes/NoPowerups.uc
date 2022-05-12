//=============================================================================
// NoPowerups.
// removes all powerups
//=============================================================================

class NoPowerups expands Mutator;

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if ( Other.IsA('HealthPack') || Other.IsA('UT_Shieldbelt') 
		|| Other.IsA('UT_Invisibility') || Other.IsA('UDamage')
		|| Other.IsA('HealthVial') )
		return false;

	return true; 
}

defaultproperties
{
}