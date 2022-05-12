//=============================================================================
// DistanceViewTrigger: When triggered, triggers all pawns within its collision radius
//=============================================================================
class DistanceViewTrigger extends Triggers;

function Trigger( actor Other, pawn EventInstigator )
{
	local Pawn P;

	for ( P=Level.PawnList; P!=None; P=P.NextPawn )
		if ( (abs(Location.Z - P.Location.Z) < CollisionHeight + P.CollisionHeight)
			&& (VSize(Location - P.Location) < CollisionRadius) )
			P.Trigger(Other, EventInstigator);
}

defaultproperties
{
}