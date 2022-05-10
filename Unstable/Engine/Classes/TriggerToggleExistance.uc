//=============================================================================
// TriggerToggleExistance.
//=============================================================================
class TriggerToggleExistance expands Triggers;

var () class<actor> NewClass;
var () name         NewTag;
var () bool			Hidden;
var actor			TheActor;

function SpawnIt()
{
	
	if(bool(NewClass))		// If the actor is real..
	{
		TheActor=Spawn(NewClass);	// Create an actor of this type with my rotation and location.	
		TheActor.tag=NewTag;
	}

	Hidden=false;
}

function PostBeginPlay()
{
	if(!hidden)
		SpawnIt();
}

function Trigger( actor Other, pawn EventInstigator )
{
	local actor a;
	
	if(Hidden) 	// Show the actor.
	{
		SpawnIt();	
	} else		// Hide the actor.
	{
		if(TheActor!=none) 
		{
			TheActor.Destroy();
			TheActor=none;
		}
		
		Hidden=true;
	}
}

defaultproperties
{
     Texture=Texture'Engine.S_TrigTogExistance'

}
