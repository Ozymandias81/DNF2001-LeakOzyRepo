//=============================================================================
// Inpatcher. (NJS)
//
//	The inpatcher can receive events on any of the Tags[] specified and forward 
// them on to it's Event.
//=============================================================================
class Inpatcher expands Triggers;

#exec Texture Import File=Textures\Impatcher.pcx Name=S_Impatcher Mips=Off Flags=2

var () name Tags[16];

function PostBeginPlay()
{	
	Super.PostBeginPlay();

	Inpatch();
}

function Inpatch()
{
	local int i;
	local TriggerForward tr;

	// Create a TriggerForward for each valid tag, each pointing to me.
	for(i=0;i<ArrayCount(Tags);i++)
	{
		if(Tags[i]!='')
			tr=Spawn(class'TriggerForward',self,Tags[i]);
	}
}

// Trigger passes on the event to my targets. 
function Trigger( actor Other, pawn EventInstigator )
{
	GlobalTrigger(Event,EventInstigator);
}

defaultproperties
{
     Texture=Texture'Engine.S_Impatcher'
}
