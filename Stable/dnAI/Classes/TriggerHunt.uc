//=============================================================================
// TriggerHunt: 
// Used to tell NPCs staking out an area to begin hunting their enemy, if one
// exists.  Iterates through all HumanNPCs finding ones whose coverpoints
// have tags matching this trigger's event.
//=============================================================================
class TriggerHunt expands Triggers;

var bool bTriggered;

function Touch( actor Other )
{
	if( Other.IsA( 'PlayerPawn' ) && !bTriggered )
	{
		Trigger( Other, Pawn( Other ) );
		bTriggered = true;
	}
}

function Trigger( actor Other, Pawn EventInstigator )
{
	local HumanNPC NPC;

	foreach allactors( class'HumanNPC', NPC )
	{
		if( NPC.bAtCoverPoint || NPC.bAtDuckPoint )
		{
			if( NPC.MyCoverPoint.Tag == Event )
			{
				NPC.bAtCoverPoint = false;
				NPC.bAtDuckPoint = false;
				NPC.GotoState( 'Hunting' );
			}
		}
	}
}

defaultproperties
{
	bHidden=true
}
