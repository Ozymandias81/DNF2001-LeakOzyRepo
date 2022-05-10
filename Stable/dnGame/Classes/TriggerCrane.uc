//=============================================================================
// TriggerCrane. (NJS)
//=============================================================================
class TriggerCrane expands RenderActor;

#exec OBJ LOAD FILE=..\Sounds\crane.dfx

// Input Events:
var (input) name PressedForwardTag;
var (input) name PressedBackwardTag;
var (input) name PressedLeftTag;
var (input) name PressedRightTag;

var (input) name PressedUpTag;
var (input) name PressedDownTag;
var (input) name PressedGrabReleaseTag;

var (input) name ReleasedForwardTag;
var (input) name ReleasedBackwardTag;
var (input) name ReleasedLeftTag;
var (input) name ReleasedRightTag;

var (input) name ReleasedUpTag;
var (input) name ReleasedDownTag;
var (input) name ReleasedGrabReleaseTag;

var (input) name ActivateTag;
var (input) name DeactivateTag;
var (input) name ResetTag;

var actor PressedForwardTrigger;
var actor PressedBackwardTrigger;
var actor PressedLeftTrigger;
var actor PressedRightTrigger;

var actor PressedUpTrigger;
var actor PressedDownTrigger;
var actor PressedGrabReleaseTrigger;

var actor ReleasedForwardTrigger;
var actor ReleasedBackwardTrigger;
var actor ReleasedLeftTrigger;
var actor ReleasedRightTrigger;

var actor ReleasedUpTrigger;
var actor ReleasedDownTrigger;
var actor ReleasedGrabReleaseTrigger;

var actor ActivateTrigger;
var actor DeactivateTrigger;
var actor ResetTrigger;

var pawn  LastInstigator;

// Output Events:
var (output) name ForwardEvent;
var (output) name BackwardEvent;
var (output) name LeftEvent;
var (output) name RightEvent;
var (output) name UpEvent;
var (output) name DownEvent;
var (output) name GrabReleaseEvent;

// Animation sequences:
var (animation) name DeactivatedSequence;
var (animation) name ActivateSequence;
var (animation) name IdleSequence;

var (animation) name ForwardStartSequence;
var (animation) name ForwardIdleSequence;
var (animation) name ForwardReleaseSequence;

var (animation) name BackwardStartSequence;
var (animation) name BackwardIdleSequence;
var (animation) name BackwardReleaseSequence;

var (animation) name LeftStartSequence;
var (animation) name LeftIdleSequence;
var (animation) name LeftReleaseSequence;

var (animation) name RightStartSequence;
var (animation) name RightIdleSequence;
var (animation) name RightReleaseSequence;

var (animation) name UpDownActivateSequence;
var (animation) name UpDownDeactivateSequence;

var (animation) name UpStartSequence;
var (animation) name UpIdleSequence;
var (animation) name UpReleaseSequence;

var (animation) name DownStartSequence;
var (animation) name DownIdleSequence;
var (animation) name DownReleaseSequence;

var (animation) name GrabReleaseSequence;

var (animation) name StaticSequence;

// Sound effects:
var (sounds)	sound ActivateSound;
var (sounds)	sound DeactivateSound;
var (sounds)	sound MainLeverActivate;
var (sounds)	sound MainLeverDeactivate;
var (sounds)	sound SecondaryLeverActivate;
var (sounds)	sound SecondaryLeverDeactivate;
var (sounds)	sound SecondaryLeverUp;
var (sounds)	sound SecondaryLeverDown;
var (sounds)	float GrabReleaseSoundDelay;
var (sounds)    sound GrabReleaseSound;

var (craneSound) name  craneTag;
var actor		       craneActor;

var (craneSound) sound ForwardSound;
var (craneSound) name  ForwardTag;
var actor			   ForwardActor;

var (craneSound) sound BackwardSound;
var (craneSound) name  BackwardTag;
var actor			   BackwardActor;

var (craneSound) sound LeftSound;
var (craneSound) name  LeftTag;
var actor			   LeftActor;

var (craneSound) sound RightSound;
var (craneSound) name  RightTag;
var actor			   RightActor;

var (craneSound) sound UpSound;
var (craneSound) name  UpTag;
var actor			   UpActor;

var (craneSound) sound DownSound;
var (craneSound) name  DownTag;
var actor			   DownActor;

// Internal Stuff
var () bool debug;
var bool buttonForward, 
         buttonBackward, 
         buttonLeft, 
         buttonRight, 
         buttonUp, 
         buttonDown, 
         buttonGrabRelease;

// Methods:
function PostBeginPlay()
{
	super.PostBeginPlay();
	
	craneActor=FindActorTagged(class'Actor', craneTag);
	if(craneActor==none) craneActor=self;

	forwardActor=FindActorTagged(class'Actor', forwardTag);
	if(forwardActor==none) forwardActor=self;

	backwardActor=FindActorTagged(class'Actor', backwardTag);
	if(backwardActor==none) backwardActor=self;
	
	leftActor=FindActorTagged(class'Actor', leftTag);
	if(leftActor==none) leftActor=self;

	rightActor=FindActorTagged(class'Actor', rightTag);
	if(rightActor==none) rightActor=self;

	upActor=FindActorTagged(class'Actor', upTag);
	if(upActor==none) upActor=self;

	downActor=FindActorTagged(class'Actor', downTag);
	if(downActor==none) downActor=self;

	PressedForwardTrigger     =Spawn(class'TriggerSelfForward',self,PressedForwardTag);
	PressedBackwardTrigger    =Spawn(class'TriggerSelfForward',self,PressedBackwardTag);
	PressedLeftTrigger        =Spawn(class'TriggerSelfForward',self,PressedLeftTag);
	PressedRightTrigger       =Spawn(class'TriggerSelfForward',self,PressedRightTag);
	PressedUpTrigger          =Spawn(class'TriggerSelfForward',self,PressedUpTag);
	PressedDownTrigger        =Spawn(class'TriggerSelfForward',self,PressedDownTag);
	PressedGrabReleaseTrigger =Spawn(class'TriggerSelfForward',self,PressedGrabReleaseTag);

	ReleasedForwardTrigger    =Spawn(class'TriggerSelfForward',self,ReleasedForwardTag);
	ReleasedBackwardTrigger   =Spawn(class'TriggerSelfForward',self,ReleasedBackwardTag);
	ReleasedLeftTrigger       =Spawn(class'TriggerSelfForward',self,ReleasedLeftTag);
	ReleasedRightTrigger      =Spawn(class'TriggerSelfForward',self,ReleasedRightTag);
	ReleasedUpTrigger         =Spawn(class'TriggerSelfForward',self,ReleasedUpTag);
	ReleasedDownTrigger       =Spawn(class'TriggerSelfForward',self,ReleasedDownTag);
	ReleasedGrabReleaseTrigger=Spawn(class'TriggerSelfForward',self,ReleasedGrabReleaseTag);

	ActivateTrigger           =Spawn(class'TriggerSelfForward',self,ActivateTag);
	DeactivateTrigger         =Spawn(class'TriggerSelfForward',self,DeactivateTag);
	ResetTrigger			  =Spawn(class'TriggerSelfForward',self,ResetTag);

	PlayAnim(StaticSequence);
	resetCrane();
}


function AnimEnd()	// Animatiions drive the state machine.
{

	if(AnimSequence==StaticSequence)
	{
	} 
	// Do nothing when deactivated:
	else if(AnimSequence==DeactivatedSequence)
	{
		PlayAnim(StaticSequence);
		if(LastInstigator!=none)
			PlayerPawn(LastInstigator).StopRemappingInput();
	} 
	
	// Handle going forward:
	else if(AnimSequence==ForwardStartSequence)
	{
		LoopAnim(ForwardIdleSequence);
	} else if(AnimSequence==ForwardIdleSequence)
	{	
	}

	// Handle going backward:
	else if(AnimSequence==BackwardStartSequence)
	{
		LoopAnim(BackwardIdleSequence);
	} else if(AnimSequence==BackwardIdleSequence)
	{
	}

	// Handle going left:
	else if(AnimSequence==LeftStartSequence)
	{
		LoopAnim(LeftIdleSequence);
	} else if(AnimSequence==LeftIdleSequence)
	{
	}

	// Handle going right:
	else if(AnimSequence==RightStartSequence)
	{
		LoopAnim(RightIdleSequence);
	} else if(AnimSequence==RightIdleSequence)
	{
	}
	
	// Handle up
 	else if(AnimSequence==UpStartSequence)
	{
		LoopAnim(UpIdleSequence);
	} else if(AnimSequence==UpIdleSequence)
	{		
		if(!buttonUp) { PlayAnim(UpReleaseSequence); PlaySound(SecondaryLeverUp); }
		else		  LoopAnim(UpIdleSequence);
	} 
	
	// Handle down
	else if(AnimSequence==DownStartSequence)
	{
		LoopAnim(DownIdleSequence);
	} else if(AnimSequence==DownIdleSequence)
	{		
		if(!buttonDown) { PlayAnim(DownReleaseSequence); PlaySound(SecondaryLeverDown); }
		else		    LoopAnim(DownIdleSequence);
	} 
	
	else if((AnimSequence==UpDownActivateSequence)
	      ||(AnimSequence==UpReleaseSequence)
	      ||(AnimSequence==DownReleaseSequence))
	{
		     if(buttonUp)   { PlayAnim(UpStartSequence); PlaySound(SecondaryLeverUp); }
		else if(buttonDown) { PlayAnim(DownStartSequence); PlaySound(SecondaryLeverDown); }
		else 				{ PlayAnim(UpDownDeactivateSequence); PlaySound(SecondaryLeverDeactivate); }
	}	
	
	// Default to idle:
	else
	{
		LoopAnim(IdleSequence);
	}
}

// Play the delayed sound after a certain number of seconds:
function Timer(optional int TimerNum)
{
	PlaySound(GrabReleaseSound);
}

// Possibly trigger output events for the current state:
function Tick(float deltaSeconds)
{
	// Handle forward:
	if(buttonForward&&(AnimSequence==IdleSequence))
	{	PlayAnim(ForwardStartSequence); 	PlaySound(MainLeverActivate); }
	else if(!buttonForward&&(AnimSequence==ForwardIdleSequence))
	{	PlayAnim(ForwardReleaseSequence);	PlaySound(MainLeverDeactivate); }
	// Handle backward:
	else if(buttonBackward&&(AnimSequence==IdleSequence))
	{	PlayAnim(BackwardStartSequence); PlaySound(MainLeverActivate); }
	else if(!buttonBackward&&(AnimSequence==BackwardIdleSequence))
	{	PlayAnim(BackwardReleaseSequence); PlaySound(MainLeverDeactivate); }
	// Handle left:
	else if(buttonLeft&&(AnimSequence==IdleSequence))
	{	PlayAnim(LeftStartSequence); PlaySound(MainLeverActivate); }
	else if(!buttonLeft&&(AnimSequence==LeftIdleSequence))
	{	PlayAnim(LeftReleaseSequence); PlaySound(MainLeverDeactivate); }
	// Handle right:
	else if(buttonRight&&(AnimSequence==IdleSequence))
	{	PlayAnim(RightStartSequence); PlaySound(MainLeverActivate); }
	else if(!buttonRight&&(AnimSequence==RightIdleSequence))
	{	PlayAnim(RightReleaseSequence); PlaySound(MainLeverDeactivate); }

	// Handle up/down:
	else if((buttonUp||buttonDown)&&(AnimSequence==IdleSequence))
	{
		PlayAnim(UpDownActivateSequence);
		PlaySound(SecondaryLeverActivate);
	}
	//else if(buttonUp&&(AnimSequence==IdleSequence))
	//	PlayAnim(UpStartSequence);
	//else if(!buttonUp&&(AnimSequence==UpIdleSequence))
	//	PlayAnim(UpReleaseSequence);

	// Handle grabrelease:
	else if(buttonGrabRelease&&(AnimSequence==IdleSequence))
	{
		PlayAnim(GrabReleaseSequence);
		if(GrabReleaseSoundDelay==0.0)	PlaySound(GrabReleaseSound);
		else							SetTimer(GrabReleaseSoundDelay,false);

		GlobalTrigger(GrabReleaseEvent);
		buttonGrabRelease=false;
	}
	
	// Control the actual movement:
		 if(AnimSequence==ForwardIdleSequence)  { GlobalTrigger(ForwardEvent); 	ForwardActor.AmbientSound=ForwardSound; }
	else if(AnimSequence==BackwardIdleSequence) { GlobalTrigger(BackwardEvent); 	BackwardActor.AmbientSound=BackwardSound; }
	else if(AnimSequence==LeftIdleSequence) 	{ GlobalTrigger(LeftEvent); 	LeftActor.AmbientSound=LeftSound; }
	else if(AnimSequence==RightIdleSequence) 	{ GlobalTrigger(RightEvent); 	RightActor.AmbientSound=RightSound; }
	else if(AnimSequence==UpIdleSequence)		{ GlobalTrigger(UpEvent); 		UpActor.AmbientSound=UpSound; }
	else if(AnimSequence==DownIdleSequence)		{ GlobalTrigger(DownEvent); 	DownActor.AmbientSound=DownSound; }
	else 										{ craneActor.AmbientSound=none; 
	                                              ForwardActor.AmbientSound=none; 
	                                              BackwardActor.AmbientSound=none;
	                                              LeftActor.AmbientSound=none;
	                                              RightActor.AmbientSound=none;
	                                              UpActor.AmbientSound=none;  
	                                              DownActor.AmbientSound=none;
	                                            }
	
	// Happy testo: 
	//	 if(buttonForward)    	 GlobalTrigger(ForwardEvent);
	//else if(buttonBackward)	 GlobalTrigger(BackwardEvent);
	//else if(buttonLeft)	  	 GlobalTrigger(LeftEvent);
	//else if(buttonRight)  	 GlobalTrigger(RightEvent);
	//else if(buttonUp)  	  	 GlobalTrigger(UpEvent);
	//else if(buttonDown)  	  	 GlobalTrigger(DownEvent);
	//else if(buttonGrabRelease) GlobalTrigger(GrabReleaseEvent);
	
}

function resetCrane()
{
	buttonForward=false;
	buttonBackward=false;
	buttonLeft=false;
	buttonRight=false;
	buttonUp=false;
	buttonDown=false;
	buttonGrabRelease=false;
}

function bool isKeyPressed()
{
	return buttonForward||buttonBackward||buttonLeft||buttonRight||buttonUp||buttonDown||buttonGrabRelease;
}

function Trigger( actor Other, pawn EventInstigator )
{
		 if(Other==DeactivateTrigger) 	{ LastInstigator=EventInstigator; resetCrane(); PlayAnim(DeactivatedSequence); PlaySound(DeactivateSound); }
	else if(Other==ActivateTrigger)		{ PlayAnim(ActivateSequence); PlaySound(ActivateSound); /*PlayerPawn(Instigator).bDontUnRemap=true;*/ }	
	else if(!isKeyPressed()) // If a key is not pressed check to see if I'm pressing one:
	{
			 if(Other==PressedForwardTrigger) 		buttonForward=true;
		else if(Other==PressedBackwardTrigger) 		buttonBackward=true; 	
		else if(Other==PressedLeftTrigger)			buttonLeft=true;
		else if(Other==PressedRightTrigger)    		buttonRight=true;
		else if(Other==PressedUpTrigger)	    	buttonUp=true;
		else if(Other==PressedDownTrigger)			buttonDown=true;
		else if(Other==PressedGrabReleaseTrigger)	buttonGrabRelease=true;
	} else	// If a key is pressed, check to see if I'm releasing one
	{
			 if(Other==ReleasedForwardTrigger) 		buttonForward=false;
		else if(Other==ReleasedBackwardTrigger) 	buttonBackward=false; 	
		else if(Other==ReleasedLeftTrigger)			buttonLeft=false;
		else if(Other==ReleasedRightTrigger)    	buttonRight=false;
		else if(Other==ReleasedUpTrigger)	    	buttonUp=false;
		else if(Other==ReleasedDownTrigger)			buttonDown=false;
		else if(Other==ReleasedGrabReleaseTrigger)	buttonGrabRelease=false;
	}
}

defaultproperties
{
	bHidden=True
	CollisionRadius=+00040.000000
	CollisionHeight=+00040.000000
	bCollideActors=True
	bProjTarget=true
	ItemName="Unnamed TriggerCrane"
}
