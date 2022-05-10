//=============================================================================
// NPCActivityEvent.
//=============================================================================
class NPCActivityEvent expands Info;


var()		name	NPCTag;
var()		bool	bWeaponDown;
var()		bool	bWeaponUp;
//var()		bool	bUseEventEnabled;
var()		bool	bUseHateTag;
var()		bool	bIgnoreHeadLook;

var( AEFaceAnim )	EFacialExpression	AnimSeqFace;
var( AEFaceAnim )	bool				bMakeFaceDefault;
var( AEFaceAnim )	bool				bLoopFaceAnim;

// Top channel Animation controls
var( AETopAnim ) 	name	AnimSeqTop;			// Top animation sequence
var( AETopAnim )	bool	bUseRateTop;		// Should I use the animation rate defined here?
var( AETopAnim )	float	RateTop;			// Top animation play rate
var( AETopAnim )	bool	bUseTweenTimeTop;	// Should I use the animation tweentime defined here?
var( AETopAnim )	float	TweenTimeTop;		// Top animation TweenTime
var( AETopAnim )	bool	bLoopTopAnim;		// Should this animation be looped?
var( AETopAnim )	name	EventTopAnim;
var( AETopAnim )	name EventsTopAnim[ 16 ];
var( AETopAnim )	float	LoopTimeTop;
var( AETopAnim )	name	DefaultTopAnim;

// Bottom channel Animation controls
var( AEBottomAnim ) name	AnimSeqBottom;
var( AEBottomAnim )	bool	bUseRateBottom;
var( AEBottomAnim )	float	RateBottom;
var( AEBottomAnim )	bool	bUseTweenTimeBottom;
var( AEBottomAnim )	float	TweenTimeBottom;
var( AEBottomAnim )	bool	bLoopBottomAnim;
var( AEBottomAnim ) name	EventBottomAnim;
var( AEBottomAnim ) name EventsBottomAnim[ 16 ];

var( AEBottomAnim )	float	LoopTimeBottom;
var( AEBottomAnim ) name	DefaultBottomAnim;

// All channel Animation controls
var( AEAllAnim )	bool	bCanInterruptAll;
var( AEAllAnim ) 	name	AnimSeqAll;
var( AEAllAnim )	bool	bUseRateAll;
var( AEAllAnim )	float	RateAll;
var( AEAllAnim )	bool	bUseTweenTimeAll;
var( AEAllAnim )	float	TweenTimeAll;
var( AEAllAnim )	bool	bLoopAllAnim;
var( AEAllAnim )	name	EventAllAnim;
var( AEAllAnim )	name	EventAllAnim2;
var( AEAllAnim )	name EventsAllAnim[ 16 ];

var( AEAllAnim )	float	LoopTimeAll;
var( AEAllAnim )	name	DefaultAllAnim;

// Movement controls
var( AEMovement )	bool	bUsePhysics;
//var( AEMovement )	name	MoveTopAnim;
//var( AEMovement )	name	MoveBottomAnim;
//var( AEMovement )	name	MoveAllAnim;
var( AEMovement )	EPhysics	MovePhysics;	// Set physics to this prior to moving.
var( AEMovement )	bool	bStopMoving;
var( AEMovement )	bool	bUseStopMoving;
var( AEMovement )	name	MoveToTag;		// Tag of actor to move to.
var( AEMovement )	bool	bRunning;		// Doh.
var( AEMovement )	name	MovementEvent;	// Event to trigger when destination reached.
var( AEMovement )	float	DestinationOffset;	// Distance required to be near goal (default 32)
var( AEMovement )	bool	bWaitWhenBlocked;	// If a Pawn is blocking me, should I wait until they move?
var( AEMovement )	bool	bLowerLOS;

// Sound controls
var( AESound )		sound	SoundToPlay;		// Play this sound
var( AESound )		float	PauseBeforeSound;	// Duration (in seconds) to pause before playing this sound.
var( AESound )		bool	bNoLipSync;			// Is this sound speech?


var( AESound )		name	SoundEvent;
// Focus controls
var( AEFocus )		name	FocusTag;
var( AEFocus )		bool	bUseFocusTag;		// If true and focus tag is empty, will reset focus.
var( AEFocus )		bool	bWillNotTurn		?( "Will not turn body toward focus." );
var( AEFocus )		bool	bWillNotTorsoTrack  ?( "Will not turn torso toward focus." );
var( AEFocus )		bool	bWillNotHeadTrack	?( "Will not turn head toward focus." );

// Give controls
var( AEGiveItem )	class<Actor> ItemClass;		// Class of item given by NPC.
var( AEGiveItem )	name	GiveItemTag;
var( AEGiveItem )	name	TakeEvent;			// Event called when player takes item.
var( AEGiveItem )	name	MountPoint;			// Name of mount point for item while offered.
var( AEGiveItem )   rotator	ItemMountAngles;
var( AEGiveItem )	vector	ItemMountOrigin;
var( AEGiveItem )	float	ItemScale;
var( AEGiveItem )	bool	bUseItemScale;
var( AEGiveItem )	bool	bResetIdleAnim;

var( Snatchers )	name	TagToSnatch;

var Pawn MyNPC;
// 65000

var( AESound ) EFacialExpression SoundFacialExpression;

function TriggerAllAnimEvents( Pawn Instigator )
{
	local Actor A;
	local int i;

	for( i = 0; i <= 15; i++ )
	{
		if( EventsAllAnim[ i ] != '' )
		{
			foreach allactors( class'Actor', A, EventsAllAnim[ i ] )
			{
				A.Trigger( self, Instigator );
			}
		}
		else
			break;
	}
}

function TriggerTopAnimEvents( Pawn Instigator )
{
	local Actor A;
	local int i;

	for( i = 0; i <= 15; i++ )
	{
		if( EventsTopAnim[ i ] != '' )
		{
			foreach allactors( class'Actor', A, EventsAllAnim[ i ] )
			{
				A.Trigger( self, Instigator );
			}
		}
		else
			break;
	}
}

function TriggerBottomAnimEvents( Pawn Instigator )
{
	local Actor A;
	local int i;

	for( i = 0; i <= 15; i++ )
	{
		if( EventsBottomAnim[ i ] != '' )
		{
			foreach allactors( class'Actor', A, EventsAllAnim[ i ] )
			{
				A.Trigger( self, Instigator );
			}
		}
		else
			break;
	}
}


function TriggerEvent( name MatchTag, Pawn Instigator )
{
	local Actor A;
	log( "TriggerEvent for tag "$MatchTag$" called" );

	foreach allactors( class'Actor', A, MatchTag )
	{
		log( "Triggering "$A );
		A.Trigger( self, Instigator );
	}
}

function TriggerMovementEvent( pawn Instigator )
{
	local actor A;

	if( MovementEvent != '' )
	{
		foreach allactors( class'Actor', A, MovementEvent )
		{
			A.Trigger( self, Instigator );
		}
	}
}

function Trigger( actor Other, Pawn EventInstigator )
{
	GetMyNPC();
	//MyNPC.MyAE = self;
	//// log( "name$" Triggered. NPC was in state: "$MyNPC.GetStatename() );
	//MyNPC.NextState = MyNPC.GetStateName();	
	//if( MyNPC.NextState == 'ActivityControl' )
	//{
	//	MyNPC.NextState = 'Idling';
	//}
//
//	MyNPC.GotoState( 'ActivityControl' );
//	GotoState( 'ControllingNPC' );
}

function Actor GetActorWithTag( name MatchTag )
{
	//local Actor A;

	return FindActorTagged(class'Actor',MatchTag);
	//foreach allactors( class'Actor', A, )
	//{
	//	if( A.Tag == MatchTag )
	//	{
	//		return A;
	//	}
	//}
}

function Actor GetFocusActor()
{
	return GetActorWithTag( FocusTag );
}

function Actor GetActivityDestination()
{
	return GetActorWithTag( MoveToTag );
}
	
function GetMyNPC()
{
	local AIPawn NPC;
	
	// log( "self$" with tag "$tag$" triggered" );

	if( Event != '' && NPCTag == '' )
	{
		NPCTag = Event;
	}

	foreach allactors( class'AIPawn', NPC, NPCTag )
	{
		if( NPC.Tag == NPCTag )
		{
			NPC.MyAE = self;
			NPC.NextState = NPC.GetStateName();
//			NPC.bUseEventEnabled = bUseEventEnabled;
			// log( ""TRIGGERING: "$NPC );
			if( NPC.NextState == 'ActivityControl' )
			{
				NPC.NextState = 'Idling';
			}
			log( self$" SENDING "$NPC$" TO ACTIVITY CONTROL" );
			NPC.GotoState( 'ActivityControl' );
			break;
		}

			//return NPC;
	}
}


function float GetRate( int Channel )
{
	if( Channel == 1 )
	{
		if( bUseRateTop )
		{
			return RateTop;
		}
		else
			return 1.0;
	}
	else if( Channel == 2 )
	{
		if( bUseRateBottom )
		{
			return RateBottom;
		}
		else
			return 1.0;
	}
	else if( Channel == 0 )
	{
		if( bUseRateAll )
		{
			return RateAll;
		}
		else
			return 1.0;
	}
	return 1.0;
}


function float GetTweenTime( int Channel )
{
	if( Channel == 1 )
	{
		if( bUseTweenTimeTop )
		{
			return TweenTimeTop;
		}
		else
			return 0.1;
	}
	else if( Channel == 2 )
	{
		if( bUseTweenTimeBottom )
		{
			return TweenTimeBottom;
		}
		else
			return 0.1;
	}
	else if( Channel == 0 )
	{
		if( bUseTweenTimeAll )
		{
			return TweenTimeAll;
		}
		else
			return 0.1;
	}
	return 0.1;
}


defaultproperties
{
   // bUseEventEnabled=false
	DestinationOffset=32.000000
}

