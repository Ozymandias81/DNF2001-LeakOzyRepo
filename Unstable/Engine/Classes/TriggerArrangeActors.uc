//=============================================================================
// TriggerArrangeActors. (NJS)
//=============================================================================
class TriggerArrangeActors expands Triggers;

var () bool relative;
var () bool clearEtherial;
var () bool setPhysics;
var () EPhysics newPhysics;

var () struct EActorMove
{
	var () name ActorTag;
	var () vector NewPosition;
} ActorMove[16];
/*
function Timer(optional int TimerNum)
{
	local int i;
	local vector NewPosition;
	local actor a;
	for(i=0;i<arrayCount(ActorMove);i++)
	{
	
		if(ActorMove[i].ActorTag=='') continue;
		
		// Attach to my parent:
		foreach AllActors( class 'Actor', a, ActorMove[i].actorTag)
		{
			a.SetPhysics(NewPhysics);
			break;
		}
	}
	
}
*/
function Trigger( actor Other, pawn EventInstigator )
{
	local int i;
	local vector NewPosition;
	local actor a;
	
	// Move each actor in the list:
	for(i=0;i<ArrayCount(ActorMove);i++)
	{
		if(ActorMove[i].ActorTag=='') continue;
		
		// Attach to my parent:
		foreach AllActors( class 'Actor', a, ActorMove[i].actorTag)
		{
			if(relative) NewPosition=Location;
			else 		 NewPosition=vect(0,0,0);
		
			NewPosition+=ActorMove[i].NewPosition;

			a.SetLocation(NewPosition);
			a.Acceleration=vect(0,0,0);
			a.Velocity=vect(0,0,0);
	
			
			//if(clearEtherial)
			//{
				a.bblockActors=true;
				
				//a.SetCollision( true, true, true);
				a.bCollideWorld=true;
				a.bHidden=false;
			//}
			if(setPhysics) a.SetPhysics(newPhysics);
		
			break;					// Only Process first actor
		}
	}
	
	//SetTimer(5.0,false);
}

defaultproperties
{
}
