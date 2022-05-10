//=============================================================================
// AggressionTrigger.
//=============================================================================
class AggressionTrigger expands Triggers;

var() name		MatchTag;
var() bool		bAggressiveToPlayer;

function Trigger( actor Other, pawn EventInstigator )
{
	local AIPawn NPC;

	if( MatchTag == '' && Event != '' )
	{
		MatchTag = Event;
	}

//	log( "* AggressionTrigger "$self$" called by "$Other );
	foreach allactors( class'AIPawn', NPC, MatchTag )
	{
//		log( self$" Found NPC: "$NPC );
		NPC.bAggressiveToPlayer = bAggressiveToPlayer;
		if( NPC.HateTag != '' )
			NPC.TriggerHate();
	}
}

defaultproperties
{
}
