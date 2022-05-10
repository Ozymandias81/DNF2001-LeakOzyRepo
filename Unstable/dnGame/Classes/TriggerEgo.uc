//=============================================================================
// TriggerEgo. 						   December 12th, 2000 - Charlie Wiederhold
// When triggered, *HEALS* the pawn.
//=============================================================================
class TriggerEgo expands Triggers;

var () int  EgoAmount; 		// Amount to heal the pawn. 
var () bool LimitEgo;		// Not go over ego limit?
var () enum EEgoAction		// How the trigger acts
{
	ADD_EgoOnce,
	ADD_EgoRepeat,
	SUB_EgoOnce,
	SUB_EgoRepeat,
} EgoAction;


// Heal all pawns with tag equal to Event:
function Trigger( actor Other, pawn EventInstigator )
{
	local Pawn A;

	if (((EgoAction == ADD_EgoOnce) || (EgoAction == SUB_EgoOnce)) && (!bCollideActors))
		return;
		
	// Validate Event.
	if( Event != '' ) 
		// Heal all pawns with matching triggers 
		foreach AllActors( class 'Pawn', A, Event )	
		{		
			if ((EgoAction == ADD_EgoOnce) || (EgoAction == ADD_EgoRepeat)) {
				A.AddEgo (EgoAmount,LimitEgo);
			} else
			{
				A.SubtractEgo (EgoAmount*-1);
			}
		}

	if ((EgoAction == ADD_EgoOnce) || (EgoAction == SUB_EgoOnce)) {
		// Ignore future touches/triggers.
		SetCollision (False);
	}
}

defaultproperties
{
     Texture=Texture'Engine.S_Trigger'
}
