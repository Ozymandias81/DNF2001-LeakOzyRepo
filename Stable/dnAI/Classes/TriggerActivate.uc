//=============================================================================
// TriggerActivate: 
// Used to wake sleeping stuff up.
//=============================================================================
class TriggerActivate expands Triggers;

var bool bTriggered;
var() name TargetTag ?( "Optional tag of new target/enemy." );

function Touch( actor Other )
{
	local Pawn P;

	if( Other.IsA( 'PlayerPawn' ) && !bTriggered )
	{
		for( P = Level.PawnList; P != None; P = P.NextPawn )
		{
			if( P.IsA( 'AIPawn' ) && P.Tag == Event )
			{
				if( TargetTag != 'None' )
				{
					AIPawn( P ).Activate( GetTarget() );
				}
				else
				{
					AIPawn( P ).Activate( Pawn( Other ) );
				}
			}
		}
	}
	if( Other.IsA( 'PlayerPawn' ) )
		bTriggered = true;
}

function Trigger( actor Other, Pawn EventInstigator )
{
	local Pawn P;

	for( P = Level.PawnList; P != None; P = P.NextPawn )
	{
		if( P.IsA( 'AIPawn' ) && P.Tag == Event )
		{
			if( TargetTag != 'None' )
				AIPawn( P ).Activate( GetTarget() );
			else
				AIPawn( P ).Activate( EventInstigator );
		}
	}
}

function Pawn GetTarget()
{
	local Pawn P;

	if( TargetTag == 'None' )
		return None;

	for( P = Level.PawnList; P != None; P = P.NextPawn )
	{
		if( P.Tag == TargetTag && TargetTag != 'None' ) 
		{
			return P;
		}
	}
	return None;
}

defaultproperties
{
	bHidden=true
}
