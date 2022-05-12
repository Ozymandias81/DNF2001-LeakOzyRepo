//=============================================================================
// BioFear.
// Creatures will tend to back away when entering this spot
// To be effective, there should also not be any paths going through the area
//=============================================================================
class BioFear extends Triggers;

var() bool bInitiallyActive;

function Touch( actor Other )
{
	local Bot B;

	if ( Other.bIsPawn )
	{
		B = Bot(Other);
		if ( B == None )
			return;

		if ( B.bNovice )
		{
			if ( FRand() > 0.4 + 0.1 * B.Skill )
				return;
		}
		else if ( FRand() > 0.7 + 0.1 * B.Skill )
			return;
		B.FearThisSpot(self);
		if ( CollisionRadius < 120 )
			Destroy();
		else
			SetCollisionSize(CollisionRadius - 25, CollisionHeight);
	}
}

defaultproperties
{
	bStatic=false
	CollisionRadius=+200.000
	RemoteRole=ROLE_None
}