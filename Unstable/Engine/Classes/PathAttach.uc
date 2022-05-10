//=============================================================================
// PathAttach. (NJS)
//
// 	Path attach attaches a given object to a given path of InterpolationPoints 
// specified by 'Event'.
//
// 	See the 'Public Variables' section below for a list of all the option 
// parameters and their functions.
//=============================================================================
class PathAttach expands Triggers;

#exec Texture Import File=Textures\PathAttach.pcx Name=S_PathAttach Mips=Off Flags=2

// Public Variables:
var () name WhoToAttach;	// The tag of the object(s) to attach 
							// Event is the tag of the InterpolationPoint to attach to
							// when PathAttach is triggered.  If 'WhoToAttach' is empty
							// then the Instigator will be attached.
							 
var () bool AttachOnTouch;  // Whether I should attach any object that touches me to 
							// InterpolationPoint specified by Event.


function Touch( actor Other )
{
	if( Other!=None && AttachOnTouch )
	{
		Other.AttachToPath(Event);
		Other.AmbientSound = AmbientSound;
	}
}

function Trigger( actor Other, pawn EventInstigator )
{
	local actor a;
	
	// Make sure event is set: 
	if(Event=='') 
		return;
	
	// If WhoToAttach isn't set, then attach the instigator by default
	if(WhoToAttach=='')
	{
		if(EventInstigator!=None)
			EventInstigator.AttachToPath(Event,true);				
	} else
	{
		// Attach all actors whose tag matches WhoToAttach to the path node of the given name
		foreach AllActors( class 'actor', a )
		{
			if(a.tag==WhoToAttach)
				a.AttachToPath(Event,true);
		}
	}
	
}


defaultproperties
{
     bHidden=True
     Texture=Texture'Engine.S_PathAttach'
     bCollideActors=True
}
