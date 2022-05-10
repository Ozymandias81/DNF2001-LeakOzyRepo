//=============================================================================
// BigHead
// gives all players Big Heads
//=============================================================================
class BigHead expands Mutator;

function ModifyPlayer( Pawn Other )
{
	Other.BoneScales[3] = 1.5; // Index 3 is the head

	if ( NextMutator != None )
		NextMutator.ModifyPlayer( Other );
}


defaultproperties
{
}