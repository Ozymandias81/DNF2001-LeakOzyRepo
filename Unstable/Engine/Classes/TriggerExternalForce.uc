//=============================================================================
// TriggerExternalForce.
//=============================================================================
class TriggerExternalForce expands Triggers;

var() vector NewExternalForce;
var() name   ObjectToApplyTo;
var() bool   TriggerOnTouch;

function ApplyForce(actor Other)
{
/*
	if(ObjectToApplyTo!='')
	{
		foreach AllActors( class 'Actor', Other, ObjectToApplyTo )		
		{
			Other.ExternalForce=ExternalForce;
		}
	} else
		Other.ExternalForce=NewExternalForce;
		*/
}

// Trigger passes on the event to my owner.
function Trigger( actor Other, pawn EventInstigator )
{
	ApplyForce(Other);	
}

function Touch( actor Other )
{
	if(TriggerOnTouch) ApplyForce(Other);
}

defaultproperties
{
}
