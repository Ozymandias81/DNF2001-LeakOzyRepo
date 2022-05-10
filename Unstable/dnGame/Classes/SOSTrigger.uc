/*-----------------------------------------------------------------------------
	SOSTrigger
	Author: John Pollard
-----------------------------------------------------------------------------*/
class SOSTrigger extends Triggers;

#exec OBJ LOAD FILE=..\textures\dukeed_gfx.dtx

// This structure holds the info needed about a specific SOS event that the SOS sequence will do
struct SOSEventInfo
{
	// Event to trigger
	var() name			Event				?("Event to trigger.");
	// Animation info
	var() name			AnimTag				?("Tag to look for when playing animation");
	var() name			AnimSequence		?("The animation sequence to play.");
	var() float			AnimRate			?("The speed the animation plays (0.0-1.0).");
	var() bool			bLoopAnim			?("If true, animation will loop.");
	// Sound to play
	var() sound			Sound				?("Sound to play.");
	var() float			SoundVolume			?("Volume of sound (1-255).");
	var() bool			bNoLipSynch			?("If true, the actor will not try to lip synch to the sound.");
	var() bool			bIgnoreSoundDelay	?("If true, the sound delay will be ignored.");
	// Aditional delay
	var() float			Delay				?("Delay till next event (if bIgnoreSoundDelay is not true, sound delay is also used.");

	var actor			AnimActor;			// Cached out animactor
};

var() SOSEventInfo		SOSEvents[16];
var() name 				SOSEndEvent 		?("Event to call when the SOS finishes execution");
var() string			Freq				?("Radio frequency");
var() int				FOV					?("FOV to set the camera at during sequence.");
var   int				OldFOV;			// FOV before you entered the SOS trigger
//var() name			ResetTag			?("If not none, then triggering this tag will reset the sequence.");
//var() bool			bLoop				?("Loop the SOS sequence automatically (you will need to manually stop it)");
var name				ResetTag;
var bool				bLoop;

enum ESOSType
{
	SOS_Interrupt,
	SOS_IncomingCall,
	SOS_EventsOnly,
};

var() ESOSType			SOSType;

// Non exposed work variables
var TriggerSelfForward	ResetTrigger;
var DukePlayer			Duke;				// The main Duke pawn in the level
var actor				WarpActor;
var vector				OldLocation;
var rotator				OldRotation;
var bool				bEventsStarted;		// == True if events currently playing

var int					i;
var float				DelayToUse;

//================================================================================
//	PostBeginPlay
//================================================================================
function PostBeginPlay()
{
	super.PostBeginPlay();

	if (ResetTag!='')
	{
		ResetTrigger = Spawn(class'Engine.TriggerSelfForward',self);
		ResetTrigger.tag=ResetTag;
		ResetTrigger.event=Tag;
	}

	// Find duke (so we can update him about whats going on, and warp him around...)
	Duke = None;
	FindDuke();

	WarpActor = None;

	// Find the warp actor (this is where we will put duke while playing the event sequences)
	if (Event != '')
	{
		foreach AllActors(class 'Actor', Target, Event)
		{
			WarpActor = Target;
			break;
		}
	}

	// No events going on yet
	bEventsStarted = false;

	// Disable tick by default
	disable('Tick');

	CacheAnimActors();
}

//================================================================================
//	CacheAnimActors
//================================================================================
function CacheAnimActors()
{
	local int		i;

	for (i=0; i< ArrayCount(SOSEvents); i++ )
	{
		SOSEvents[i].AnimActor = None;			// Default to none

		// Trigger all the actors that match this event tag
		if (SOSEvents[i].AnimTag == '')
			continue;

		//if (SOSEvents[i].AnimSequence == '')
		//	continue;

		foreach AllActors(class 'Actor', Target, SOSEvents[i].AnimTag)
		{
			SOSEvents[i].AnimActor = Target;
			break;		// Found it
		}

		if (SOSEvents[i].AnimRate == 0)
			SOSEvents[i].AnimRate = 1.0;
	}
}

//================================================================================
//	Trigger
//================================================================================
function Trigger(actor Other, pawn EventInstigator)
{
	if ((Other == None) || (Other != ResetTrigger) )
	{
		Instigator = EventInstigator;
		StartEvents();
	}
	else if ((ResetTag != '') && (Other==ResetTrigger))
	{
		StopEvents();
	}
}

//================================================================================
//	FindDuke
//================================================================================
function FindDuke()
{
	local DukePlayer	D;

	if (Duke != None)
		return;
	
	foreach AllActors(class 'DukePlayer', D)
	{
		Duke = D;		// There will only be one in single player
		break;
	}
	// TODO: Log when a Duke is not found
}

//================================================================================
//	StartEvents
//================================================================================
function StartEvents(optional bool bForce)
{
	if (bEventsStarted)
		return;			// Events already started

	if (Duke == None)
		FindDuke();		// Make sure we got a duke

	if (SOSType == SOS_IncomingCall && !bForce)
	{
		// Make duke answer the call first
		Duke.SetupIncomingSOSCall(self, Freq);
		return;
	}

	if (SOSType != SOS_EventsOnly)
	{
		if (WarpActor != None)
		{
			OldLocation = Duke.Location;
			OldRotation = Duke.Rotation;
			
			Duke.SetLocation(WarpActor.Location);
			Duke.SetRotation(WarpActor.Rotation);

			OldFOV = Duke.DesiredFOV;
			
			Duke.DesiredFOV = FOV;
			Duke.FOVAngle = FOV;

			Duke.SetPhysics(PHYS_MovingBrush);
			Duke.SetCollision(false,false,false);
			Duke.bCollideWorld=false;
			Duke.AttachToParent(WarpActor.Tag);
	
//			Duke.WeaponDown( false, true, false, true );
			//Duke.bWeaponsActive = false;
			
			// The viewmapper will put duke's eys at the warpactor location
			Duke.ViewMapper = Self;
			Duke.InputHookActor=Self;
		}
	}

	// Start doing events
	GotoState('DoSOSEvents');
	
	bEventsStarted = true;
}

//================================================================================
//	StopEvents
//================================================================================
function StopEvents(optional bool bForce)
{
	if (!bEventsStarted)
		return;

	GotoState('');

	if (SOSType == SOS_IncomingCall && !bForce)
	{
		// Tell Duke the call has ended (NOTE: Duke will call this function again with bForce as True)
		Duke.EndSOSCall(self);
		return;
	}

	if (SOSType != SOS_EventsOnly)
	{
		if (WarpActor != None)
		{
			Duke.SetPhysics(PHYS_Falling);
			Duke.bCollideWorld=true;
			Duke.SetCollision(true,true,true);
			Duke.MountParent=none;

			Duke.DesiredFOV = OldFOV;
			Duke.FOVAngle = OldFOV;
		
			Duke.SetLocation(OldLocation);
			Duke.SetRotation(OldRotation);

			// Bring the weapon up.
//			Duke.WeaponUp( true, false, true );
		
			Duke.ViewMapper = None;
			Duke.InputHookActor = None;
		}
	}

	bEventsStarted = false;

	GlobalTrigger (SOSEndEvent);

}

//=============================================================================
//	InputHook
//=============================================================================
function InputHook(out float aForward,out float aLookUp,out float aTurn,out float aStrafe,optional float DeltaTime)
{
	// Zero out movement
	aForward	= 0;
	aLookUp		= 0;
	aTurn		= 0;
	aStrafe		= 0;
}

//=============================================================================
//	CalcView
//=============================================================================
function CalcView(out vector CameraLocation, out rotator CameraRotation)
{
	if (WarpActor != None)
	{
		CameraLocation = WarpActor.Location;
		CameraRotation = WarpActor.Rotation;
		Duke.ViewRotation = WarpActor.Rotation;
	}
}

//=============================================================================
//	state DoSOSEvents
//=============================================================================
state DoSOSEvents
{
Begin:
	for (i=0; i< ArrayCount(SOSEvents); i++ )
	{
		// Play sound if it exists for this event
		if (SOSEvents[i].Sound != None)
		{
			if (SOSEvents[i].SoundVolume == 0)
				SOSEvents[i].SoundVolume = 255;

			// If we have an animation actor, play the sound using this actor (so lip synching will work properly)
			if (SOSEvents[i].AnimActor != None)
				SOSEvents[i].AnimActor.PlaySound(SOSEvents[i].Sound, SLOT_Talk, SOSEvents[i].SoundVolume,,,,!SOSEvents[i].bNoLipSynch);
			else
				PlaySound(SOSEvents[i].Sound, SLOT_Talk, SOSEvents[i].SoundVolume);
		}

		// Play animation if there is one
		if (SOSEvents[i].AnimActor != None && SOSEvents[i].AnimSequence != '')
		{
			if (SOSEvents[i].bLoopAnim)
				SOSEvents[i].AnimActor.LoopAnim(SOSEvents[i].AnimSequence, SOSEvents[i].AnimRate);
			else
				SOSEvents[i].AnimActor.PlayAnim(SOSEvents[i].AnimSequence, SOSEvents[i].AnimRate);
		}
	
		// Trigger all the actors that match this event tag
		if (SOSEvents[i].Event != '')
		{
			foreach AllActors( class 'Actor', Target, SOSEvents[i].Event)
				Target.Trigger(Self, Instigator);
		}

		// Take care of delay
		DelayToUse = SOSEvents[i].Delay;

		if (SOSEvents[i].Sound != None && !SOSEvents[i].bIgnoreSoundDelay)
			DelayToUse += GetSoundDuration(SOSEvents[i].Sound);

		if (DelayToUse >  0.0)
			Sleep(DelayToUse);
	}

    if (!bLoop) 
		StopEvents();
}

//================================================================================
//	defaultproperties
//================================================================================

defaultproperties
{
	 ResetTag='
     Freq="105.30"
     Texture=Texture'DukeED_Gfx.TrigSOS'
}
