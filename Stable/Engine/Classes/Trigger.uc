/*-----------------------------------------------------------------------------
	Trigger

	Notes:
	Senses things happening in its proximity and generates 
	sends Trigger/UnTrigger to actors whose names match 'EventName'.
	NJS: We've extended this cl@ss quite a bit, look under the 
	'Trigger variables' section below for some basic documentation on the new
	additions. 
-----------------------------------------------------------------------------*/
class Trigger expands Triggers
	intrinsic;

#exec Texture Import File=Textures\Trigger.pcx Name=S_Trigger Mips=Off Flags=2

var () bool		bForceInstigator;
var () bool		bDebug;

var Pawn		DukeInstigator;				// Temp forced instigator

// Trigger type.
var() enum ETriggerType
{
	TT_PlayerProximity,			// Trigger is activated by player proximity.
	TT_PawnProximity,			// Trigger is activated by any pawn's proximity
	TT_ClassProximity,			// Trigger is activated by actor of that class only
	TT_AnyProximity,    		// Trigger is activated by any actor in proximity.
    TT_Shoot,           		// Trigger is activated by player shooting it.
    
    // NJS:
	TT_PlayerProximityAndUse,	 // Trigger is activated by player proximity and bUse 
	TT_PlayerProximityAndLookUse,// The center of the player's screen must be able to trace to this point.
								 // Make sure bProjTarget and bCollideActors are set for PlayerProximity and Look Use!
	
	TT_TagProximity,			// Trigger is activated by object with given tag proximity			
	TT_EventProximity,			// Trigger is activated by object with given event proximity		 
	TT_PlayerProximityAndLook,  // Activated when the player looks at this object
}							TriggerType;

var(Events) name			LookUseTags[16]			?("Tags of things that can be looked at.");
var(Events) name			LookUseEvents[16]		?("The corresponding events to the above.");
var			actor			LookUseTriggered[16];	// Whether or not the look use trigger is triggered currently.
var() localized string		Message					?("Human readable triggering message.");
var() bool					bTriggerOnceOnly		?("Only trigger once and then go dormant.");
var() bool					bUnTriggerOnceOnly		?("Only untrigger once and then go dormant.");
var bool					bTriggered, bUnTriggered;
var() bool					bInitiallyActive		?("For triggers that are activated/deactivated by other triggers.");
var() class<actor>			ClassProximityType;
var() class<actor>			ClassProximityType2;
var() name 					TagEventProximity		?("Tag or event name used by TT_TagProximity or TT_EventProximity.");
var() float					RepeatTriggerTime		?("If > 0, repeat trigger message at this interval is still touching other.");
var() float					ReTriggerDelay			?("Minimum time before trigger can be triggered again.");
var	  float					TriggerTime;
var() float					DamageThreshold			?("Minimum damage to trigger if TT_Shoot.");
var() name					UntriggerEvent			?("Event to be executed when trigger is untriggered.");
var() bool					bTriggerWhenCrouched	?("If TT_PlayerProximityAndUse and the player is crouched the trigger is still usable.");

// AI vars
var	actor					TriggerActor;		   // actor that triggers this trigger
var actor					TriggerActor2;

var bool					PlayerTriggered;

var int						Touches;

function PostBeginPlay()
{
	local actor			A;

	if ( !bInitiallyActive )
		FindTriggerActor();
	if ( TriggerType == TT_Shoot )
	{
		bHidden = false;
		bProjTarget = true;
		DrawType = DT_None;
	}
	Super.PostBeginPlay();		
	Disable('Tick'); 

	FindDuke();
}

function FindDuke()
{
	local PlayerPawn	Player;

	if (DukeInstigator != None)
		return;

	// Find Duke so we can use him as the forced instigator if need be
	foreach AllActors(class'PlayerPawn', Player)
	{
		DukeInstigator = Player;
		break;
	}
}

function FindTriggerActor()
{
	local Actor A;

	TriggerActor = None;
	TriggerActor2 = None;
	foreach AllActors(class 'Actor', A)
		if ( A.Event == Tag)
		{
			if ( Counter(A) != None )
				return; //FIXME - handle counters
			if ( TriggerActor == None )
				TriggerActor = A;
			else
			{
				TriggerActor2 = A;
				return;
			}
		}
}

function Actor SpecialHandling(Pawn Other)
{
	local int i;
	local actor A;

	if ( bTriggerOnceOnly && !bCollideActors )
		return None;

	if ( ((TriggerType == TT_PlayerProximityAndLook) || (TriggerType == TT_PlayerProximity )|| ( TriggerType == TT_PlayerProximityAndLookUse )) && !Other.bIsPlayer )
		return None;
	
	// JC
	if ( Other.IsA('AIPawn') )
		return None;

	if ( ((TriggerType == TT_PlayerProximityAndUse) ||
		  (TriggerType == TT_PlayerProximityAndLookUse) ||
		  (TriggerType == TT_PlayerProximityAndLook)) 
		&& (Other.bUse == 0) && Other.bIsPlayer ) 
		return None;
		
	if ( !bInitiallyActive )
	{
		if ( TriggerActor == None )
			FindTriggerActor();
		if ( TriggerActor == None )
			return None;
		if ( (TriggerActor2 != None) 
			&& (VSize(TriggerActor2.Location - Other.Location) < VSize(TriggerActor.Location - Other.Location)) )
			return TriggerActor2;
		else
			return TriggerActor;
	}

	// Is this a shootable trigger?
	if ( TriggerType == TT_Shoot )
	{
		if ( !Other.bCanDoSpecial || (Other.Weapon == None) )
			return None;

		Other.Target = self;
		Other.bShootSpecial = true;
		Other.FireWeapon();
		Other.bFire = 0;
		Other.bAltFire = 0;
		return Other;
	}

	// Can other trigger it right away?
	if ( IsRelevant(Other) )
	{
		foreach TouchingActors( class'Actor', A )
		{
			if ( A == Other )
				Touch( Other );
		}
		return self;
	}

	return self;
}

// When trigger gets turned on, check its touch list.
function CheckTouchList()
{
	local actor A;

	foreach TouchingActors( class'Actor', A )
	{
		if( A != None )
			Touch( A );
	}
}

/*-----------------------------------------------------------------------------
	States
-----------------------------------------------------------------------------*/

// Trigger is always active.
state() NormalTrigger
{
}

// Other trigger toggles this trigger's activity.
state() OtherTriggerToggles
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		bInitiallyActive = !bInitiallyActive;
		if ( bInitiallyActive )
			CheckTouchList();
	}
}

// Other trigger turns this on.
state() OtherTriggerTurnsOn
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		local bool bWasActive;

		bWasActive = bInitiallyActive;
		bInitiallyActive = true;
		if ( !bWasActive )
			CheckTouchList();
	}
}

// Other trigger turns this off.
state() OtherTriggerTurnsOff
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		bInitiallyActive = false;
	}
}

/*-----------------------------------------------------------------------------
	Trigger L0gic
-----------------------------------------------------------------------------*/

// See whether the other actor is relevant to this trigger.
function bool IsRelevant( actor Other )
{
	if ( !bInitiallyActive )
		return false;
	switch ( TriggerType )
	{
		case TT_PlayerProximityAndLookUse:
		case TT_PlayerProximityAndUse:
		case TT_PlayerProximityAndLook:
			// JC
			return (Pawn(Other)!=None) && Pawn(Other).bIsPlayer && !Pawn( Other ).IsA( 'AIPawn' );
		case TT_TagProximity:
			return (Other.tag==TagEventProximity);
		case TT_EventProximity:
			return (Other.Event==TagEventProximity);			
		case TT_PlayerProximity:
			// JC
			return Pawn(Other)!=None && Pawn(Other).bIsPlayer && !Pawn( Other ).IsA( 'AIPawn' );
		case TT_PawnProximity:
			return Pawn(Other)!=None && ( Pawn(Other).Intelligence > BRAINS_None );
		case TT_ClassProximity:
			return ClassIsChildOf(Other.Class, ClassProximityType) || ClassIsChildOf( Other.Class, ClassProximityType2 );
		case TT_AnyProximity:
			return true;
		case TT_Shoot:
			return ( (Projectile(Other) != None) && (Projectile(Other).Damage >= DamageThreshold) );
	}
}

// Trigger the given object 
function TriggerTarget( actor Other )
{
	local actor A;
	local int counter;

	if ( bTriggered )
		return;

	if ( ReTriggerDelay > 0 )
	{
		if ((Level.TimeSeconds > ReTriggerDelay) && (Level.TimeSeconds - TriggerTime < ReTriggerDelay))
			return;
		TriggerTime = Level.TimeSeconds;
	}
		
	//if (TriggerType == TT_AnyProximity)
	//	BroadcastMessage("Triggering:"@Other@", Event:"$Event);

	// Broadcast the Trigger message to all matching actors.
	if( Event != '' )
		foreach AllActors( class 'Actor', A, Event )
			A.Trigger( Other, Other.Instigator );

	if ( Other.bIsPawn && (Pawn(Other).SpecialGoal == self) )
		Pawn(Other).SpecialGoal = None;
			
	if (bDebug)
		BroadcastMessage("Triggering:"@Other@", Message:"$Message);
	
	// Send a string message to the toucher.
	if ( Message != "" )
		Other.Instigator.ClientMessage( Message );

	if ( bTriggerOnceOnly )
	{
		// Ignore future touches.
		bTriggered = true;
	} else if ( RepeatTriggerTime > 0 )
		SetTimer( RepeatTriggerTime, false );
}

function UntriggerTarget( actor Other )
{
	local actor A;
	local int i;
	
	if ( bUnTriggerOnceOnly && bUnTriggered )
		return;
	bUnTriggered = true;

	// Untrigger all matching actors.
	if ( Event != '' )
		foreach AllActors( class 'Actor', A, Event )
			A.UnTrigger( Other, Other.Instigator );

	// Fire the untrigger event:
	GlobalTrigger( UntriggerEvent, Other.Instigator );
}

// Called when something touches the trigger.
function Touch( actor Other )
{
	if ((Other.Instigator == None || Instigator == None) && bForceInstigator)
	{
		FindDuke();

		if (bDebug)
			BroadcastMessage("Forcing Instigator to Duke: "@DukeInstigator);

		Instigator = DukeInstigator;
		Other.Instigator = DukeInstigator;
	}

	if ( IsRelevant( Other ) )
	{
		// Turn on the extended touch detection:
		if ( (TriggerType == TT_PlayerProximityAndUse) ||
			 (TriggerType == TT_PlayerProximityAndLookUse) ||
			 (TriggerType == TT_PlayerProximityAndLook) )
		{
			Touches++;
			Enable('Tick');
			if ( Other.IsA('PlayerPawn') )
				PlayerPawn(Other).UseZone++;
		}
		// Otherwise, perform trigger actions.
		else 
			TriggerTarget(Other);		
	} 
}

// Returns look use tag hit, or -1 if none.
function int HitLookUseTag( PlayerPawn p )
{
	local int i;
	local actor a;
	local name aTag;
	
	// Make sure I've got a valid target.
	if ( p == none )
		return -1;
	
	a = p.TraceFromCrosshair( 2000 );
	if ( a == none )
		return -1;
	aTag = a.tag;
	if ( aTag == '' )
		return -1;
		
	for ( i=0; i<ArrayCount(LookUseTags); i++ )
	{
		if ( LookUseTags[i] != '' ) 
		{
			if ( LookUseTags[i] == aTag )
			{
				Event = LookUseEvents[i];
				return i;
			}
		}
	}
	return -1;
}

// Tick is used to watch the state of bUse:
function Tick( float DeltaSeconds )
{
	local int i, t, u, lookUseThisFrame;
	local bool ValidTouch;
	local PlayerPawn P;
	
	Super.Tick( DeltaSeconds );

	// Make sure this is the right type of trigger for this routine:
	if ( (TriggerType != TT_PlayerProximityAndUse) &&
		 (TriggerType != TT_PlayerProximityAndLookUse) &&
		 (TriggerType != TT_PlayerProximityAndLook) )
		return;
		
	foreach TouchingActors( class'PlayerPawn', P )
	{
		ValidTouch = true;
		u = -1;

		// Do I just have to look at this bastard to trigger it?
		if ( TriggerType==TT_PlayerProximityAndLook )
		{
			u = HitLookUseTag( P );
			if ( -1 != u )
			{
				if ( !bool(LookUseTriggered[u]) )			// Have I already not been triggered?
				{
					LookUseTriggered[u] = P;				// Make sure I don't trigger again this time.
					TriggerTarget( LookUseTriggered[u] );	// Trigger the player.
				}	
			} 
															
			// Untrigger look (no use) items.
			for ( t=0; t<ArrayCount(LookUseTriggered); t++ )
			{
				if ( (t != u) || (u == -1) )
					if ( P == LookUseTriggered[t] )
					{
						UntriggerTarget( LookUseTriggered[t] );
						LookUseTriggered[t] = none;
					}
			}
		} 
		else if ( (P.bUse != 0) && ((P.bDuck == 0) || bTriggerWhenCrouched) )
		{
			if ( (TriggerType != TT_PlayerProximityAndLookUse) ||
				 (-1 != HitLookUseTag(P)) )
			{
				if ( !PlayerTriggered )			// Have I already not been triggered?
				{
					PlayerTriggered = true;		// Make sure I don't trigger again this time.
					TriggerTarget(P);			// Trigger the player.
				}						
			} 
		} 
		else
		{
			// If this target hasn't been untriggered, untrigger it.
			if ( PlayerTriggered )
				UntriggerTarget( P );

			// Mark it as untriggered.
			PlayerTriggered = false;
		}
	}	

	if ( !ValidTouch )
		Disable('Tick');
}

function Timer( optional int TimerNum )
{
	local bool bKeepTiming;
	local int i, t;
	local actor A;

	bKeepTiming = false;
	foreach TouchingActors( class'Actor', A )
	{
		if( IsRelevant( A ) )
		{
			if( TriggerType == TT_PlayerProximityAndLook )
			{
				// See if I'm still triggering one of the look blocks:
				for( t = 0; t <= ArrayCount( LookUseTriggered ); t++ )
				{
					if( LookUseTriggered[ t ] == A )
						break;
					// If I'm triggering at least one
					if( t != ArrayCount( LookUseTriggered ) )
					{
						bKeepTiming = true;
						TriggerTarget( LookUseTriggered[ t ] );
					}
				}
			}
			else
			{
				bKeepTiming = true;
				TriggerTarget( A );
			}
		}
	}

	/*// Retrigger code:
	for (i=0;i<ArrayCount(Touching);i++)
		if ( (Touching[i] != None) && IsRelevant(Touching[i]) )
		{
			if(TriggerType==TT_PlayerProximityAndLook)
			{
				// See if I'm still triggering one of the look blocks:
				for(t=0;t<ArrayCount(LookUseTriggered);t++)
					if(LookUseTriggered[t]==Touching[i])
						break;
				
				// If I'm triggering at least one
				if(t!=ArrayCount(LookUseTriggered))
				{
					bKeepTiming = true;
					TriggerTarget(LookUseTriggered[t]);
				}
			} else
			{
				bKeepTiming = true;
				TriggerTarget(Touching[i]);
			} 
		}*/

	if ( bKeepTiming )
		SetTimer( RepeatTriggerTime, false );
}

function TakeDamage( int Damage, Pawn InstigatedBy, Vector HitLocation, Vector Momentum, class<DamageType> DamageType )
{
	local actor A;

	if ( bInitiallyActive && (TriggerType == TT_Shoot) && (Damage >= DamageThreshold) && (instigatedBy != None) )
	{
		if ( ReTriggerDelay > 0 )
		{
			if ( Level.TimeSeconds - TriggerTime < ReTriggerDelay )
				return;
			TriggerTime = Level.TimeSeconds;
		}
		// Broadcast the Trigger message to all matching actors.
		if ( Event != '' )
			foreach AllActors( class 'Actor', A, Event )
				A.Trigger( instigatedBy, instigatedBy );

		// Send a string message to the toucher.
		if ( Message != "" )
			instigatedBy.Instigator.ClientMessage( Message );

		// Ignore future touches.
		if ( bTriggerOnceOnly )
			SetCollision(False);
	}
}

//
// When something untouches the trigger.
//
function UnTouch( actor Other )
{
	local actor A;
	local int i, t;
	local bool Relevant;
	
	if ( Other == None )
		return;

	Relevant = IsRelevant(Other);
	if ( Relevant )
	{
		if (( TriggerType !=  TT_PlayerProximityAndUse ) && ( TriggerType != TT_PlayerProximityAndLookUse ) && (TriggerType != TT_PlayerProximityAndLook))
			UntriggerTarget(Other);
		else if (Other.bIsPawn && PlayerTriggered)
			UntriggerTarget(Other);
		else if (!Other.bIsPawn)
			UntriggerTarget(Other);
	}

	if ( TriggerType == TT_PlayerProximityAndLook )
	{
		for (t=0;t<ArrayCount(LookUseTriggered);t++)
		{
			if ( Other==LookUseTriggered[t] )
			{
				UntriggerTarget( LookUseTriggered[t] );
				LookUseTriggered[t] = none;
			}
		}
	}

	if ( (TriggerType == TT_PlayerProximityAndUse) || (TriggerType == TT_PlayerProximityAndLookUse) 
		 || (TriggerType==TT_PlayerProximityAndLook) )
	{
		if ( Other.IsA('PlayerPawn') )
			PlayerPawn(Other).UseZone--;
	}

	if ( Relevant && ((TriggerType == TT_PlayerProximityAndUse) ||
	 				  (TriggerType == TT_PlayerProximityAndLookUse) || 
					  (TriggerType == TT_PlayerProximityAndLook)) )
	{
		Touches--;
		if ( Touches <= 0 )
		{
			Touches = 0;
			Disable('Tick');
		}
	}
}

defaultproperties
{
     bInitiallyActive=True
     InitialState=NormalTrigger
     Texture=Texture'Engine.S_Trigger'
	 bTriggerWhenCrouched=true
}
