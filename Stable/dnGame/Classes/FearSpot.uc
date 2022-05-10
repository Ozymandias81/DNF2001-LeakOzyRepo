//=============================================================================
// FearSpot.
// Creatures will tend to back away when entering this spot
// To be effective, there should also not be any paths going through the area
//=============================================================================
class FearSpot extends Info;

var Pawn Instigator;

function PostBeginPlay()
{
	local Pawn P;

	//log( self$" spawned." );
	foreach radiusactors( class'Pawn', P, 256 )
	{
		Touch( P );
	}
}

function Touch( actor Other )
{
	if ( Other.IsA('HumanNPC') )
	{
		if( Owner != None )
			Pawn( Other ).FearThisSpot( self, Pawn( Owner ) );
		else
			Pawn( Other ).FearThisSpot( self );
	}
}


defaultproperties
{
     CollisionHeight=16.000000
     CollisionRadius=64.000000
	 bCollideActors=true
	 bCollideWorld=true
}