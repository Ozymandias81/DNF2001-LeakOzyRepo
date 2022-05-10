//=============================================================================
// InterpolationPoint.
//=============================================================================
class InterpolationPoint extends Keypoint
	native;

// Sprite.
#exec Texture Import File=Textures\IntrpPnt.pcx Name=S_Interp Mips=Off Flags=2

// Number in sequence sharing this tag.
var() float  RateModifier;
var() bool   RateIsTime;		// Whether the above is a ratio or a count in seconds
var() bool   RateIsSpeed;		// If rate is a speed instead of a time or normal modifier.
var() float  GameSpeedModifier;	// Can interpolate slomo using this
var() float  FovModifier;		// Easy enough
var() bool   bSkipNextPath;
var() float  ScreenFlashScale;
var() vector ScreenFlashFog;
var() name   TriggerEvent;			// NJS: The event to call when this point is started.
var() bool   InterpolateRotation;	// NJS: If I should interpolate rotation

var() const enum EMotionType
{
	MOTION_Linear,			// Interpolate linearly between interpolation points.
	MOTION_Spline,			// Interpolate on a spline path between interpolation points.
} MotionType;

// Other points in this interpolation path.
var InterpolationPoint Prev, Next;

//
// At start of gameplay, link all matching interpolation points together.
//
function BeginPlay()
{

	local InterpolationPoint I;
	Super.BeginPlay();

	// Try to find next: (Interpolation point whose tag matches my event)
    foreach AllActors( class 'InterpolationPoint', I )
		if( I.Tag == Event )		// Is this the same as my event name?    
		{
			Next=I;					// This is my next point. 
			Next.Prev=Self;			// Set me up as the previous of my next. 
		}
}

function InterpolateBegin( actor Other ) 
{
    //local InterpolationPoint I;
    //local InterpolationPoint Destinations[32];
	//local int NumberDestinations;
	
	super.InterpolateBegin(Other);

	//NumberDestinations=0;	

	//if(Unwind) Other.SetRotation(rotator(vector(Other.Rotation)));
	
	// Try to find next: (Interpolation point whose tag matches my event)
    //foreach AllActors( class 'InterpolationPoint', I )
	//	if( I.Tag == Event )		// Is this the same as my event name? 
	//	{		
	//		Destinations[NumberDestinations]=I;
	//		NumberDestinations++;
	//		if(NumberDestinations>=ArrayCount(Destinations))
	//			break;
	//	}
	
	//if(NumberDestinations!=0)
	//{	
	//	Next=Destinations[Rand(NumberDestinations)];
	//	Next.Prev=self;
	//} else // This is the end of the line:
	//{
	//	InterpolateEnd(Other);
	//}
	
	/* Trigger TriggerEvent: */
	//if(TriggerEvent!='')
	//{
	//	log("Trigger Event Called");
	//	GlobalTrigger(TriggerEvent);
	//	GlobalUntrigger(TriggerEvent);
	//}
}

//
// When reach an interpolation point.
//
function InterpolateEnd( actor Other )
{
	local InterpolationPoint I;
    local InterpolationPoint Destinations[32];
	local int NumberDestinations;
	
	NumberDestinations=0;	

	//if(Unwind) Other.SetRotation(rotator(vector(Other.Rotation)));
	
	// Try to find next: (Interpolation point whose tag matches my event)
     foreach AllActors( class 'InterpolationPoint', I )
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
	} //else // This is the end of the line:
	//{
		//InterpolateEnd(Other);
		//Other.SetPhysics(PHYS_Falling);
	//}

	/* Trigger TriggerEvent: */
	if(TriggerEvent!='')
	{
//		log("Trigger Event Called");
		GlobalTrigger(TriggerEvent);
		GlobalUntrigger(TriggerEvent);
	}

	if( Next==None )	// Am I at the end of the path?	
	{
		//Other.bCollideWorld = Other.default.bCollideWorld; // True
		Other.bInterpolating = false;
		//Other.SetCollision(true,true,true);
		//Other.SetPhysics(PHYS_Falling);

		// If I'm a player, then correctly detach myself from the path:
		if( Pawn(Other)!=None && Pawn(Other).bIsPlayer )
		{
			Other.AmbientSound = None;
			if ( Other.IsA('PlayerPawn') )
				PlayerPawn(Other).SetControlState(CS_Normal);
		}
	} else if(Event!='')
	{
		NumberDestinations=0;	

		//if(Unwind) Other.SetRotation(rotator(vector(Other.Rotation)));
	
		// Try to find next: (Interpolation point whose tag matches my event)
		foreach AllActors( class 'InterpolationPoint', I, Event )
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
		} 
		//else // This is the end of the line:
		//{
		//	InterpolateEnd(Other);
		//	//Other.SetPhysics(PHYS_Falling);
		//}
	}
}

defaultproperties
{
     RateModifier=1.000000
     GameSpeedModifier=1.000000
     FovModifier=1.000000
     ScreenFlashScale=1.000000
     bStatic=False
     bDirectional=True
     Texture=Texture'Engine.S_Interp'
	 InterpolateRotation=true
}
