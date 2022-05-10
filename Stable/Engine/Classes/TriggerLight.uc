//=============================================================================
// TriggerLight.
// A lightsource which can be triggered on or off.
//=============================================================================
class TriggerLight extends Light
	native;

//-----------------------------------------------------------------------------
// Variables.

var() float ChangeTime;        // Time light takes to change from on to off.
var() bool  bInitiallyOn;      // Whether it's initially on.
var() bool  bDelayFullOn;      // Delay then go full-on.
var() float RemainOnTime;      // How long the TriggerPound effect lasts

var   float InitialBrightness; // Initial brightness.
var   float Alpha, Direction;
var   actor SavedTrigger;
var   float poundTime;

var() bool  bTurnOffOnSurfTrigger;	// Turn the light out regardless of state, if we are hit by a surface trigger.

var() float	ShadowBrightnessCuttoff;
var bool	bOldActorShadows;

//-----------------------------------------------------------------------------
// Engine functions.

// Called at start of gameplay.
simulated function BeginPlay()
{
	// Remember initial light type and set new one.
	Disable( 'Tick' );
	InitialBrightness = LightBrightness;

	bOldActorShadows = bActorShadows;

	if( bInitiallyOn )
	{
		Alpha     = 1.0;
		Direction = 1.0;
	}
	else
	{
		Alpha     = 0.0;
		Direction = -1.0;
	}
	DrawType = DT_None;
	
	CalcLighting();
}

function CalcLighting()
{
	if( !bDelayFullOn )
		LightBrightness = Alpha * InitialBrightness;
	else if( (Direction>0 && Alpha!=1) || Alpha==0 )
		LightBrightness = 0;
	else
		LightBrightness = InitialBrightness;

	if (ShadowBrightnessCuttoff >= 0)
	{
		if (LightBrightness <= ShadowBrightnessCuttoff*InitialBrightness)
			bActorShadows = false;
		else
			bActorShadows = bOldActorShadows;
	}
}

// Called whenever time passes.
function Tick( float DeltaTime )
{
	Alpha += Direction * DeltaTime / ChangeTime;
	if( Alpha > 1.0 )
	{
		Alpha = 1.0;
		Disable( 'Tick' );
		if ( SavedTrigger != None )
			SavedTrigger.EndEvent();
	}
	else if( Alpha < 0.0 )
	{
		Alpha = 0.0;
		Disable( 'Tick' );
		if ( SavedTrigger != None )
			SavedTrigger.EndEvent();
	}
	
	CalcLighting();
}

//-----------------------------------------------------------------------------
// Public states.

// Trigger turns the light on.
state() TriggerTurnsOn
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		if ( SavedTrigger != None )
			SavedTrigger.EndEvent();
		SavedTrigger = Other;
		if ( SavedTrigger != None )
			SavedTrigger.BeginEvent();
		if ( bTurnOffOnSurfTrigger && (Other == Level) )
			Direction = -1.0;
		else
			Direction = 1.0;
		Enable( 'Tick' );
	}
}

// Trigger turns the light off.
state() TriggerTurnsOff
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		if ( SavedTrigger != None )
			SavedTrigger.EndEvent();
		SavedTrigger = Other;
		if ( SavedTrigger != None )
			SavedTrigger.BeginEvent();
		if ( bTurnOffOnSurfTrigger && (Other == Level) )
			Direction = -1.0;
		else
			Direction = -1.0;
		Enable( 'Tick' );
	}
}

// Trigger toggles the light.
state() TriggerToggle
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		if ( SavedTrigger != None )
			SavedTrigger.EndEvent();
		SavedTrigger = Other;
		if ( SavedTrigger != None )
			SavedTrigger.BeginEvent();
		if ( bTurnOffOnSurfTrigger && (Other == Level) )
			Direction = -1.0;
		else
			Direction *= -1;
		Enable( 'Tick' );
	}
}

// Trigger controls the light.
state() TriggerControl
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		if ( SavedTrigger!=None )
			SavedTrigger.EndEvent();
		SavedTrigger = Other;
		if ( SavedTrigger != None )
			SavedTrigger.BeginEvent();
		if( bInitiallyOn ) Direction = -1.0;
		else               Direction = 1.0;
		Enable( 'Tick' );
	}
	function UnTrigger( actor Other, pawn EventInstigator )
	{
		if ( SavedTrigger != None )
			SavedTrigger.EndEvent();
		SavedTrigger = Other;
		if ( SavedTrigger != None )
			SavedTrigger.BeginEvent();
		if( bInitiallyOn ) Direction = 1.0;
		else               Direction = -1.0;
		Enable( 'Tick' );
	}
}

state() TriggerPound {

	function Timer (optional int TimerNum)
	{
		if ( poundTime >= RemainOnTime )
			Disable ('Timer');
		poundTime += ChangeTime;
		Direction *= -1;
		SetTimer (ChangeTime, false);
	}

	function Trigger( actor Other, pawn EventInstigator )
	{
		if ( SavedTrigger != None )
			SavedTrigger.EndEvent();
		SavedTrigger = Other;
		if ( SavedTrigger != None )
			SavedTrigger.BeginEvent();
		Direction = 1;
		poundTime = ChangeTime;			// how much time will pass till reversal
		SetTimer (ChangeTime, false);		// wake up when it's time to reverse
		Enable   ('Timer');
		Enable   ('Tick');
	}
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
	bHidden=false
	bStatic=false
	bMovable=true
	Texture=Texture'Engine.S_TrigTriggerLight'
	
	//ShadowBrightnessCuttoff=-1.0f
	ShadowBrightnessCuttoff=0.0f			// -1 == no cut off, >= 0 = percent of LightBrightness when to turn shadows off
}
