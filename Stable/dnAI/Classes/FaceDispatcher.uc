class FaceDispatcher extends Info;

var() EFacialExpression  FaceExpressions[16]; // Events to generate.
var() float OutDelays[16]; // Relative delays before generating events.

var int i;                // Internal counter.
var() name ResetTag;	  // If non none, then triggering this tag will reset this dispatcher
var TriggerSelfForward ResetTrigger;
var() bool bLoop;               // Loop the dispatcher automatically
var Pawn TargetPawn;

function Pawn GetTargetPawn()
{
	local Pawn P;

	foreach allactors( class'Pawn', P, Event )
	{
		return P;
	}
}

function Trigger( actor Other, pawn EventInstigator )
{
	if ( (Other == None) || (Other != ResetTrigger) )
	{
		TargetPawn = GetTargetPawn();
		GotoState('Dispatch');
	}
}

// Dispatch events.
//
state Dispatch
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		if ( ( ResetTag!='') && (Other==ResetTrigger) )
			GotoState( '' );
	}

Begin:
	broadcastmessage( "DISPATCH STATE" );
	if( TargetPawn == None )
		TargetPawn = GetTargetPawn();
	broadcastmessage( "TARGETPAWN: "$TargetPawn );
	if(ResetTag=='')
	{
		disable('Trigger');
	}
	for( i=0; i<ArrayCount(FaceExpressions); i++ )
	{
			if( bool( OutDelays[ i ] ) ) 
				Sleep( OutDelays[i] );	// NJS: Only sleep on non-zero
		if( FaceExpressions[ i ] != FACE_NoChange )
		{
			TargetPawn.SetFacialExpression( FaceExpressions[ i ], false, false );
		}
	}

    if (bLoop) // auto loop
    {
        GotoState( 'Dispatch' );
    }
    else
    {
    	enable('Trigger');
	    GotoState( '' );
    }
}
