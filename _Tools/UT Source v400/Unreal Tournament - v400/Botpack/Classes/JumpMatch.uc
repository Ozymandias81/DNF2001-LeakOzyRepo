class JumpMatch expands Mutator;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	if ( Level.Game.IsA('DeathMatchPlus') )
		DeathMatchPlus(Level.Game).bJumpMatch = true;
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if ( Other.IsA('UT_JumpBoots') )
		return false;

	return true; 
}