//=============================================================================
// InstantRockets.
// rocket launchers always instant fire
//=============================================================================

class InstantRockets expands Mutator;

function bool AlwaysKeep(Actor Other)
{
	if ( Other.IsA('UT_Eightball') )
		UT_Eightball(Other).bAlwaysInstant = true;
	if ( NextMutator != None )
		return ( NextMutator.AlwaysKeep(Other) );
	return false;
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if ( Other.IsA('UT_Eightball') )
		UT_Eightball(Other).bAlwaysInstant = true;
	return true; 
}

defaultproperties
{
}