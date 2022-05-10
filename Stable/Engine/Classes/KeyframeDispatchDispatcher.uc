//=============================================================================
// KeyframeDispatchDispatcher. (NJS)
//=============================================================================
class KeyframeDispatchDispatcher expands KeyframeDispatch;
 
#exec Texture Import File=Textures\KeyframeDispatch2.pcx Name=S_KeyframeDispatch2 Mips=Off Flags=2

struct KeyframeState
{
	var () bool     Valid;				// Whether to use this keyframe or not

	var () rotator	RotateTo;			// The absolute position to rotate to
	var () rotator  RelativeRotateTo;	// The relative position to rotate to
	var () bool		RelativeRotation;	// Whether to use absolute or relative rotation
	
	var () vector   MoveTo;
	var () vector   RelativeMoveTo;
	var () bool		RelativeMotion;	

	var () float    Seconds;
}; 

var () name			 Events[10];
var () KeyframeState KeyframeInfo[10];

var () int  CurrentKeyframe;
var () bool Loop;
var () bool Pong;

var name PendingEvent;

/* Initialize the pending event: */
function PreBeginPlay()
{
	local int i;
	
	super.PreBeginPlay();
	PendingEvent='';
}

// Trigger the given object 
function TriggerTarget( name Event )
{
	local actor A;
		
	// Broadcast the Trigger message to all matching actors.
	if( Event != '' )
		foreach AllActors( class 'Actor', A, Event )
			A.Trigger( self, self.Instigator );

}
function bool StartNextKeyframe()
{
	/* If an event is pending from the previous keyframe, perform it: */
	if(PendingEvent!='')
	{	
		TriggerTarget(PendingEvent);	
		PendingEvent='';	/* Clear out the event */
	}

	/* Make sure I'm not out of range: */
	if(CurrentKeyframe>=ArrayCount(KeyframeInfo))
		return false;
		
	/* Is this keyframe actually valid? */	
	if(KeyframeInfo[CurrentKeyframe].Valid)
	{		
		/* Determine if I'm using relative rotation: */
		RelativeRotation=KeyframeInfo[CurrentKeyframe].RelativeRotation;

		if(RelativeRotation)
			RotateTo=KeyframeInfo[CurrentKeyframe].RelativeRotateTo;
		else 
			RotateTo=KeyframeInfo[CurrentKeyframe].RotateTo;
	
		/* Determine if I'm using relative motion: */
		RelativeMotion=KeyframeInfo[CurrentKeyframe].RelativeMotion;
			
		if(RelativeMotion)		
			MoveTo=KeyframeInfo[CurrentKeyframe].RelativeMoveTo;
		else
			MoveTo=KeyframeInfo[CurrentKeyframe].MoveTo;

		/* Seconds to arrive at this poisition: */
		Seconds=KeyframeInfo[CurrentKeyframe].Seconds;		

		/* Start it */
		StartKeyframe();
		PendingEvent=Events[CurrentKeyframe];
		SetTimer(Seconds,false);
		
		/* Move on to the next keyframe: */
		CurrentKeyframe++;			
		
		/* Have I reached the end of the valid frame list? */
		if(!KeyframeInfo[CurrentKeyframe].Valid)	
			if(Loop)				
				CurrentKeyframe=0; /* Bump me back to the start. */ 
		
		/* If this is an instantaneous keyframe, then go to the next one immedietely */
		if((KeyframeInfo[CurrentKeyframe].Valid)&&(Seconds==0))
			return StartNextKeyframe();
		
		return true;
	} else
	{
		CurrentKeyframe=0;	 /* Reset the keyframe counter. */
		PendingEvent='';
	}

	return false;
}

function Timer(optional int TimerNum)
{
	StartNextKeyframe();
}

function Trigger( actor Other, pawn EventInstigator )
{
	/* I can only trigger a new keyframe sequence when one isn't already running: */
	if(TimerRate[0]!=0)
		return;
	
	/* Make sure I'm at the correct rotation: */
	if((DesiredRotation!=Rotation)&&bRotateToDesired)
		return;
		
	/* Make sure I'm at the correct location: */
	if((DesiredLocation!=Location)&&bMoveToDesired)
		return;

		StartNextKeyframe();	
}

defaultproperties
{
     Texture=Texture'Engine.S_KeyframeDispatch2'
}
