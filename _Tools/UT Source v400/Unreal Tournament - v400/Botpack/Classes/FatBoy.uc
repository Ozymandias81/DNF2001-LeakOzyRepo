//=============================================================================
// FatBoy
// makes all players fat
//=============================================================================

class FatBoy expands Mutator;

function ScoreKill(Pawn Killer, Pawn Other)
{
	if ((Killer != Other) && (Other != None) && (Killer != None))
	{
		// Normal kill.
		if (Killer.Fatness >= 240)
			Killer.Fatness = 255;
		else
			Killer.Fatness += 10;

		Other.Fatness -= 10;
		if (Other.Fatness < 60)
			Other.Fatness = 60;
	}
		
	if ( (Other != None) && ((Killer == None) || (Killer == Other)) )
	{
		// Suicide.
		Other.Fatness -= 10;
		if (Other.Fatness < 60)
			Other.Fatness = 60;
	}

	Super.ScoreKill(Killer, Other);
}
