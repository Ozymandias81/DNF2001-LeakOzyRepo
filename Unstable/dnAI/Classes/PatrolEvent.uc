//=============================================================================
// PatrolEvent.uc
//=============================================================================
class PatrolEvent extends Info;

//#exec Texture Import File=Textures\Pathnode.pcx Name=S_Patrol Mips=Off Flags=2

var() float			PauseDuration;		// Time NPC pauses during this event (optional).
var() float			EventOdds;			// Odds that this event occurs.
var() bool			bToggleWalkMode;	// Toggle between walking and running.

var() bool			bToggleOnceOnly;	// Toggle this event only once, period.

// Head turning/look handling
var() Actor			FocusActor;				// Actor to focus on (look at).
var() bool			bResetFocusAfterEvent;	// Reinitialize the NPC's focus when patrol resumes.
var() bool			bFocusOnPlayer;			// Focus on the closest Playerpawn.
var() float			FocusTime	?( "Time to spend focusing on this target." );
var() Actor			NextEvent;				// Next event (if any) to cycle. If none, patrol resumes.
//var() bool			bSneaking;			// Temporary. And now disabled.
var() bool			PauseUntilTriggered;	// Not yet implemented.
var() name			NPCPatrolEvent;			// Extra tag used for triggering patrol events. When a patrol event
											// is triggered, only NPCs with a matching NPCPatrolEvent will be
											// triggered (find a better way to do this).

// Optional forced animations played at this event. If no PauseDuration is defined, NPC will finish the animation
// and resume patrol immediately after. No animations with a pause duration plays the normal idle animations.
var() Name			AllAnim;
var() Name			TopAnim;	
var() Name			BottomAnim;
var() name TurnToTag ?( "Turn to an actor with this tag." );

var bool			bWalkToggleable;		// Yuck.

var() name TriggerEvent;
var() EFacialExpression NewFacialExpression;

function PlayerPawn GetPlayer()
{
	local PlayerPawn P;

	foreach allactors( class'PlayerPawn', P )
	{
		return P;
	}
}


function Trigger( actor Other, Pawn Instigator )
{
	local HumanNPC B;
	local name MatchEvent;

	//log( "!! PatrolEvent "$self$" triggered!" );
	MatchEvent = NPCPatrolEvent;

	if( Other.IsA( 'HumanNPC' ) && Other.IsInState( 'Patrolling' ) )
	{
		if( ( NPCPatrolEvent != 'None' ) && HumanNPC( Other ).PatrolTag == NPCPatrolEvent )
		{
			HumanNPC( Other ).CurrentPatrolEvent = Self;
			HumanNPC( Other ).GotoState( 'Patrolling', 'HandlePatrolEvent' );
		}
	}

	foreach allactors( class'HumanNPC', B )
	{
		//log( "::: Found: "$B$" with tag of "$B.PatrolTag );
		//log( "::: MatchEvent is: "$MatchEvent );
		if( NewFacialExpression != FACE_NoChange )
			B.SetFacialExpression( NewFacialExpression );

		if( B.PatrolTag == MatchEvent )
		{
			//log( "::: Match! "$B$" with "$Self );
			if( B.NPCOrders == 1 && B.IsInState( 'Patrolling' ) )
			{
				//log( "::: Sending... "$B$" to Patrolling state." );
				B.CurrentPatrolEvent = Self;
				B.GotoState( 'Patrolling', 'HandlePatrolEvent' );
				//log( "::: Testing: "$B.GetStateName()$" ... CurrentPatrol: "$B.CurrentPatrolEvent );
			}
		}
	}
}


function UnTrigger( actor Other, Pawn EventInstigator )
{
/*	local bot B;
	local name MatchEvent;

	MatchEvent = Event;
	log( "::: "$self$" Untrigger called." );
	foreach allactors( class'Bot', B )
	{
		if( B.Tag == MatchEvent )
		{
			if( B.HumanNPCOrders == 1 && B.IsInState( 'Patrolling' ) )
			{
				B.CurrentPatrolEvent = none;
				B.HeadTrackingActor = None;
				B.GotoState( 'Patrolling' );
			}
		}
	}*/
}


simulated function bool Chance( float CurrentOdds )
{
/*
	local float RandVal, TotalOdds;
 
	RandVal = ( FRand() * CurrentOdds );
	TotalOdds = 1.0;
	TotalOdds += CurrentOdds;
	return ( TotalOdds >= RandVal );
*/
	return ( FRand() <= EventOdds );
}


defaultproperties
{
     EventOdds=1.000000
	 bDirectional=True
     SoundVolume=128
	 Texture=S_Patrol
	 bToggleOnceOnly=false
	 bWalkToggleable=true
}
