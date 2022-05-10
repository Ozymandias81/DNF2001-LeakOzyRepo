//=============================================================================
// TriggerMount. (NJS)
//
// When triggered attaches one or a group of objects to another object, or 
// detaches objects.
//
// See the description under 'Public Variables' for a description of the 
// various parameters that TriggerMount can take.
//=============================================================================
class TriggerMount expands Triggers;

#exec Texture Import File=Textures\TriggerMount.pcx Name=S_TriggerMount Mips=Off Flags=2


// Public Variables:
var() name 	   MountWhat;	   		    // What to attach
var() bool 	   MountOther;				// Attach the 'Other' trigger argument
var() bool     MountInstigator;			// Attach the Instigator trigger argument
var() name 	   MountToWhat;				// What to attach to. When empty just dismounts
var() bool	   MountToInstigator;		// Mount to the instigator.  Overrides MountToWhat.
var() bool     SetNewMounteePhysics;	// If true, set mountee physics using below:
var() EPhysics NewMounteePhysics;		// New physics to set mountee to, valid when above is true.
var() bool     SetDismountPhysics;		// If true, the following is valid.
var() EPhysics NewDismountPhysics;		// New dismount physics to set on objects being mounted.
var() bool     MatchParentLocation;		// Attach to the center of the parent
var() bool     MatchParentAngles;		// Attach using the parent's exact angles.
var() bool     ClearbBlockActors;		// Clear the bBlockActors flag of the mountee object

// Mount's the actor specified by Mountee to the object specified by 'ToWhat'.
function Mount( actor Mountee, name ToWhat )
{
	Mountee.MountParentTag=ToWhat;
	Mountee.AttachToParent(ToWhat,MatchParentLocation,MatchParentAngles); // Mount this object to it's parent.
	if(SetNewMounteePhysics)
		Mountee.SetPhysics(NewMounteePhysics);
	if(SetDismountPhysics)
		Mountee.DismountPhysics=NewDismountPhysics;
	if(ClearbBlockActors)
		Mountee.bBlockActors=false;
	if(Mountee.MountParent.IsA('DrawActorMount'))
		DrawActorMount(Mountee.MountParent).MountedActor( Mountee );
}

// Destroys all objects with tag equal to Event:
function Trigger( actor Other, pawn EventInstigator )
{
	local Actor A, B;
	 
	if(MountToInstigator) 
		MountToWhat=EventInstigator.Tag;

	if( MountWhat != '' ) 						// Is this a valid mount?
	{
		foreach AllActors( class 'Actor', A, MountWhat )	
		{		
			// Is this one of the objects I want to mount/dismount?
				if(MountToWhat=='') // Am I dismounting this object or mounting to other?
				{
					if(A.MountParent!=none) // I'm dismounting
					{
						A.MountParent=none;
						A.MountParentTag='';
						A.SetPhysics(A.DismountPhysics); // Reset the physics
					}
				}
				else 
					Mount(A,MountToWhat);
		}
	} else if(MountOther)
	{
		if(Other!=none)
			Mount(Other,MountToWhat);
		else
			Log("Other == none!");
	} else if(MountInstigator)
	{
		if(MountToWhat=='')
		{
			EventInstigator.MountParentTag='';
			EventInstigator.MountParent=none;
			EventInstigator.SetPhysics(b.DismountPhysics);
			EventInstigator.ClientRestart();				
		} else	
			Mount(EventInstigator,MountToWhat);
	} 
	else if(MountToWhat!='') 					// Request to unmount all children from the parent	
	{
		foreach Allactors(class 'Actor',A,MountToWhat)			// Find all actors matching mountToWhat
		{
				foreach Allactors(class 'Actor',B)	// Find all all children of a
				{
					if(b.MountParent==a)			// Found a child
					{
						b.MountParentTag='';		// Destroy the child!
						b.MountParent=none;			
						b.SetPhysics(b.DismountPhysics);
					}
				}
		}
	}
}

defaultproperties
{
     Texture=Texture'Engine.S_TriggerMount'
}
