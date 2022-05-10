/*-----------------------------------------------------------------------------
	ActorFreeze
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class ActorFreeze extends ActorDamageEffect
	abstract;

// Ice interface.
function RemoveEffect()
{
	Super.RemoveEffect();

	// Remove cold dot.
//	if ( Owner.bIsPawn )
//		Pawn(Owner).RemoveDOT( DOT_Cold );
}

function AttachEffect( Actor Other )
{
	Super.AttachEffect( Other );

	// Add cold DOT if owner is a pawn.
//	if ( Owner.bIsPawn )
//		Pawn(Owner).AddDOT( DOT_Cold, Lifespan, 3.0, 3.0 );
}