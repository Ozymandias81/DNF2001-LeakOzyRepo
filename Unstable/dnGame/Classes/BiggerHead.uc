//=============================================================================
// BiggerHead
// gives all players Big Heads
//=============================================================================
class BiggerHead expands Mutator;

function ModifyPlayer( Pawn Other )
{
	Other.BoneScales[3] = 2.0; // Index 3 is the head

	if ( NextMutator != None )
		NextMutator.ModifyPlayer( Other );
}


defaultproperties
{
}