//=============================================================================
// InterpolationPoint. (NJS)
//
// An individual point on a path, 'Event' specifies the tag of the next point 
// (or potential points) on the path.
// See the description of each of the parameters under the 'Public Variables'
// section below.
//=============================================================================
class InterpolationStation expands Keypoint
	intrinsic;

#exec Texture Import File=Textures\IntrpPnt.pcx Name=S_Interp Mips=Off Flags=2

// Public Variables:
// Number in sequence sharing this tag.
/*
var() int   Position;		// Get rid of me (NJS: Obsolete, do not use)
var() float RateModifier;	// Speed modifier, or time if RateIsTime is set
var() bool  RateIsTime;		// Whether the above is a ratio or a count in seconds
var() name  TriggerEvent;	// The event to call when this point is started.
var() bool  Unwind;			// Normalize the angle on entry to this interpolation point.
var() const enum EMotionType
{
	MOTION_Linear,			// Interpolate linearly between interpolation points.
	MOTION_Spline,			// Interpolate on a spline path between interpolation points.
} MotionType;

// Other points in this interpolation path.
var InterpolationStation Prev, Next;

//
// At start of gameplay, link all matching interpolation points together.
//
function BeginPlay()
{
    local InterpolationStation I;
	Super.BeginPlay();

	// Try to find next: (Interpolation point whose tag matches my event)
        foreach AllActors( class 'InterpolationStation', I )
			if( I.Tag == Event )		// Is this the same as my event name?    
			{
				Next=I;					// This is my next point. 
				Next.Prev=Self;			// Set me up as the previous of my next. 
			}
}

function InterpolateBegin( actor Other ) 
{
        local InterpolationStation I;
        local InterpolationStation Destinations[16];
	local int NumberDestinations;
	
	super.InterpolateBegin(Other);

	NumberDestinations=0;	

	//if(Unwind) Other.SetRotation(rotator(vector(Other.Rotation)));
	
	// Try to find next: (Interpolation point whose tag matches my event)
        foreach AllActors( class 'InterpolationStation', I )
		if( I.Tag == Event )		// Is this the same as my event name? 
		{		
			Destinations[NumberDestinations]=I;
			NumberDestinations++;
			if(NumberDestinations>=ArrayCount(Destinations))
				break;
		}
	
	if(NumberDestinations!=0)
	{	
		Next=Destinations[Rand(NumberDestinations)];
		Next.Prev=self;
	} else // This is the end of the line:
	{
		Other.SetPhysics(PHYS_Falling);
	}
	
	if(TriggerEvent!='')
	{
		GlobalTrigger(TriggerEvent);
		GlobalUntrigger(TriggerEvent);
	}
}
*/
defaultproperties
{
}
