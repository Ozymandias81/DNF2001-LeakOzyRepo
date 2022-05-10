//=============================================================================
// LookAtDispatch.
// Event is what to look at.
//=============================================================================
class LookAtDispatch expands Triggers;

#exec Texture Import File=Textures\TriggerLook.pcx Name=S_LookAtDispatch Mips=Off Flags=2

enum LookType
{
	LOOK_NearestClass,	// Look at the nearest class.
	LOOK_NearestEvent,	// Look at the nearest event.
	LOOK_Instigator		// Look at the last instigator.
};

var () LookType Type;			           // Type of LookAtDispatch that this is.
var () class<actor> LookAtClass;           // Class to look at
var () name		ObserverTags;	           // Tags of the things that will be looking at event.
var () bool		PreComputeObservers;	   // Whether the looker should be precomputed or determined each time something is looked at
var    actor    PreComputedObservers[16];  // The precomputed observer.
var () bool     PreComputeFocus;		   // Whether a single focus actor should be precomputed
var    actor    PreComputedFocus;		   // The precomputed focus actor.

var () rotator  MaxTurnRate;				// Maximum rate at which the looker can turn. (Not yet done)
var () rotator  MinTurnPosition;			// Minimum rotation coordinates to contrain rotation to.
var () rotator  MaxTurnPosition;			// Maximum rotation coordinates to contrain rotation to.
var () bool		ConfineYaw;					// Whether or not to constrain yaw.
var () bool     ConfinePitch;				// Whether to constrain pitch.
var () bool     ConfineRoll;				// Whether to constrain roll.
var () bool     Constant;					// Constantly look, not just when triggered.
var () bool     ConstantEnabledByTouch;		// If constant looking atting is enabled by touch or not.
var () float    MaxRadius;					// Maximum radius from the observer the focus actor can be
var () float    MinRadius;				    // Minimum radius from the observer the focus actor can be
var () name     EventOnAlign;				// Event to be fired off when this guy is lined up with it's target.
var () rotator  AlignmentTolerance;         // +/- this number of degrees on each axis.
var () bool     LeadTarget;					// Whether or not to lead the target.
var () float    EventDelay;					// Delay till this event can be fired again
var () float    EventDelayVariance;			// Maximum variation in seconds.
var    float    NextEventCountdown;			// Countdown till the next event.

// Private interface:

final function actor LookAtWho(actor Observer)
{
	local actor ClosestActor,    E;
	local float ClosestDistance, CurrentDistance;
	
	// Has the focus actor already been computed?
	if(PreComputeFocus)
	{
		CurrentDistance=VSize(Observer.Location-PreComputedFocus.Location);
		
		// Am I within the maximum radius?
		if((CurrentDistance>=MinRadius)&&(CurrentDistance<=MaxRadius))
			return PreComputedFocus;

		// Get outta here.
		return none;
	}

	// Determine who I should look at (My closest actor with tag event: 
	ClosestActor=none;
	ClosestDistance=MaxRadius+0.01;		// Set the closest distnace to just outside my range

	// Find the closest actor:
	if(Type==LOOK_NearestClass)
	{
		if(LookAtClass!=none)
			foreach AllActors( LookAtClass, E )		
			{
				CurrentDistance=VSize(Observer.Location-E.Location);	// Determine distance	
		
				// Is this the closest actor I've found so far?
				if((CurrentDistance<ClosestDistance)&&(CurrentDistance>=MinRadius))
				{
					ClosestActor=E;
					ClosestDistance=CurrentDistance;
				}	
			}

	} else if(Type==LOOK_NearestEvent)
	{
		foreach AllActors( class 'Actor', E, Event )		
		{
			CurrentDistance=VSize(Observer.Location-E.Location);	// Determine distance	
		
			// Is this the closest actor I've found so far?
			if(CurrentDistance<ClosestDistance)
			{
				ClosestActor=E;
				ClosestDistance=CurrentDistance;
			}	
		}
	} else if(Type==LOOK_Instigator)
	{	
		// Make sure we have an instigator, and he's close enough.		
		if(bool(Instigator))
		{
			ClosestDistance=VSize(Observer.Location-Instigator.Location);
			if((ClosestDistance<=MaxRadius)&&(ClosestDistance>=MinRadius))
				return Instigator;
		}	
		return none;
		
	} else
	{
		Log("Unknown look type!");
	}
	
	// Return the closest actor or none:
	return ClosestActor;
}

// Causes Observer to look at Focus:
final function SingleLookAt(actor Observer )
{
	local actor Focus;
	local rotator newRotation, tempRotator;
	local int i;
	
	Focus=LookAtWho(Observer);		// Who should I look at?
	if(Focus==none) return;			// No-one found to look at.

	NewRotation=AngleTo(Observer.Location,Focus.Location);
	

	// Lock out various rotation axes:
	if(!bool(MaxTurnRate.Yaw)) 	 NewRotation.Yaw  =Observer.Rotation.Yaw;
	if(!bool(MaxTurnRate.Pitch)) NewRotation.Pitch=Observer.Rotation.Pitch;
	if(!bool(MaxTurnRate.Roll))  NewRotation.Roll =Observer.Rotation.Roll;

	// Constrain my rotation:
	if(ConfineYaw)
		NewRotation.Yaw=AddAngleConfined(Rotation.Yaw, RotationDistance(Rotation.Yaw,NewRotation.Yaw), MinTurnPosition.Yaw, MaxTurnPosition.Yaw );	

	if(ConfinePitch)
		NewRotation.Pitch=AddAngleConfined(Rotation.Pitch, RotationDistance(Rotation.Pitch,NewRotation.Pitch), MinTurnPosition.Pitch, MaxTurnPosition.Pitch );	

	if(ConfineRoll)
		NewRotation.Roll=AddAngleConfined(Rotation.Roll, RotationDistance(Rotation.Roll,NewRotation.Roll), MinTurnPosition.Roll, MaxTurnPosition.Roll );	
	
	if(NewRotation!=Observer.Rotation)
	{
		Observer.DesiredRotation=NewRotation;
		Observer.RotationRate=MaxTurnRate;	
		Observer.bRotateToDesired=true; 	// Make DesiredRotation valid. 
		Observer.bFixedRotationDir=false;	// Fix rotation direction.			
	} 

	// Check to see if I'm aligned with my target:
	if(EventOnAlign!=''&&NextEventCountdown<=0)
	{
		// Check to see if we line up:
		tempRotator=AngleTo(Observer.Location,Focus.Location);

		// See if I'm aligned within tolerance:
		if(abs(RotationDistance(Observer.Rotation.yaw,tempRotator.yaw))<=AlignmentTolerance.yaw)
		if(abs(RotationDistance(Observer.Rotation.pitch,tempRotator.pitch))<=AlignmentTolerance.pitch)
		if(abs(RotationDistance(Observer.Rotation.roll,tempRotator.roll))<=AlignmentTolerance.roll)
		{		
			GlobalTrigger(EventOnAlign,Instigator);
			NextEventCountdown=EventDelay+(Frand()*EventDelayVariance);
		}
	}	
}

// The main function that performs the looking:
final function AllLookAt()
{
	local int i;
	local actor Observer;

	// Have the observers been precomputed for me?
	if(PreComputeObservers)
	{
		for(i=0;i<ArrayCount(PreComputedObservers);i++)
			if(PreComputedObservers[i]!=none)
				SingleLookAt(PreComputedObservers[i]);
	} else
	{
		// Generate the observers on the fly:
		foreach AllActors( class 'Actor', Observer, ObserverTags )		
		{
			SingleLookAt(Observer);
		}
	}
}

// Events:
function PostBeginPlay()
{
	local actor O;
	local int i;

	super.postBeginPlay();

	// Should I precompute the observers?
	if(PreComputeObservers)
	{
		i=0;	// Current Precomputed observer index.
		foreach AllActors( class 'Actor', O, ObserverTags )		
		{
			PreComputedObservers[i]=O;	// Set up this observer 
			i++;						// Move to the next one.

			// Have we exceeded the observer limit?
			if(i>=ArrayCount(PreComputedObservers)) break;
		}
	}

	// Should I precompute the focus?
	if(PreComputeFocus)
	{
		if(Type==LOOK_NearestClass) 		// Am I looking at a class?
		{
			if(LookAtClass!=none)
				foreach AllActors( LookAtClass, O )		
				{
					PreComputedFocus=O; 			
					break;
				}

		} else if(Type==LOOK_NearestEvent)	// Looking for nearest tag that matches event
		{
			// Scan through the actor list looking for matching foci:
			foreach AllActors( class 'Actor', O, Event )		
			{
				PreComputedFocus=O; 			
				break;
			}
		} else if(Type==LOOK_Instigator)
		{
			Log("Instigator can't be precomputed!");
		} else
		{
			Log("Unknown look type.");
		}
	}
	
	if(Constant||bool(EventOnAlign)) Enable('Tick');
	else Disable('Tick');
}

// For constant looking:
function Tick( float DeltaTime )
{
	NextEventCountdown-=DeltaTime;	// Countdown to next event.
	if(Constant) AllLookAt(); 		// Make everyone look at everything.	
}

// When triggered:
function Trigger( actor Other, pawn EventInstigator )
{
	Instigator=EventInstigator; 	// Initialize the instigator.
	AllLookAt();
}

function Touch( actor Other )
{
	// Are these the droids we're looking for?
}

function Untouch( actor Other )
{
	// Move Along...
}

defaultproperties
{
     MaxRadius=1000.000000
     bHidden=True
     Texture=Texture'Engine.S_LookAtDispatch'
	 PreComputeObservers=True
	 PreComputeFocus=True
}
