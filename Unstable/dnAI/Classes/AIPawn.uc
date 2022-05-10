/*=============================================================================
	AIPawn
	Author: Jess Crable

	Base actor of DNF AI.
=============================================================================*/
class AIPawn expands Pawn
	abstract;

/*-----------------------------------------------------------------------------
	Control State related variables
-----------------------------------------------------------------------------*/
var( AIStartup )	bool			bAlwaysUseTentacles		?("If true, this AIPawn will always use tentacle attacks instead\nof punches and kicks.");
var( AIStartup )	name			InitialIdlingAnim		?("Optional override for waiting animation in the Idling state.");		// Optional override for waiting anim in Idle state.
var( AIStartup )	name			InitialTopIdlingAnim	?("Optional top override for waiting animation in the Idling state.");
var( AIStartup )	bool			bCanHaveCash			?("This pawn can carry cash.");			
var( AIStartup )	bool			bAggressiveToPlayer		?("Set to true if this Pawn should attack the player on sight.");	// NPC is aggressive to playerpawns.
var( AIStartup )	float			RunSpeed;
var( AIStartup )	name			HateTag;
var( AIStartup )	class<Carcass>	CarcassType				?("Type of carcass for this AIPawn. Robots and other creatures have\ndifferent carcasses.");
var( AIStartup )	bool			bVisiblySnatched		?("Determines whether or not this pawn is visibly snatched at startup." );
var( AIStartup )	float			AggroSnatchDistance		?("Maximum distance snatch victim should be before going aggressive.");
var( AIStartup )	PatrolControl	CurrentPatrolControl;
var( AIStartup )	Name			PatrolTag;
var bool bPatrolled;
var( AIFollow )		name			FollowEvent;
var( AIFollow )		bool			bFollowEventOnceOnly;
var( AI ) float		AIMeleeRange;
var( AI ) bool		bHateWhenSnatched						?("This NPC will immediately hate the player if snatched in-game."); 
var( AI ) name		ControlTag;
var( AI ) name		CoverTag;
//var( AI ) bool		bPanicking;
var bool bForcedAttack;

var( AI ) bool		bShielded;
var bool				bCamping;
var	name				PendingTopAnimation;
var	name				PendingBottomAnimation;
var	name				PendingAllAnimation;
var	sound				PendingSound;
var	name				PendingFocusTag;
var	bool				bFocusOnPlayer;
var	bool				bCanBeUsed;
var	actor				MyGiveItem;
var	NPCActivityEvent	MyAE;
var	actor				AEDestination;
var	actor				PendingTriggerActor;
var	bool				bDisableUseTrigEvent;
var	actor				Obstruction;
var	float				WalkingSpeed;
var	actor				PendingDoor;
var	bool				bFollowEventDisabled;
var bool				bSnatchedAtStartup;
var bool				bSleeping;
var bool				bEyeless;
var bool				bLegless;
var bool				bCanHeadTrack;
var bool				bCanTorsoTrack;
var	bool				bReadyToAttack;	
var bool				bSawEnemy;
var actor				OrderObject;			
var NavigationPoint		CurrentPatrolPoint;
var PatrolEvent			CurrentPatrolEvent;
var NPCActivityEvent	CurrentActivityEvent;
var CreatureFactory		MyFactory;

// Handling of frame based animation events
struct SNPCAnimEvent
{
	var()	sound	EventSound;
	var()	bool	bEnabled;
	var()	name	TriggerEvent;
	var()   float   SoundVolume;
};
var( AI ) SNPCAnimEvent NPCAnimEvent[ 15 ];

var Effects				Shield;
var	Actor				SuspiciousActor;
var SnatchActor			MySnatcher;
var bool				bEMPed;
//var AIFocusController 	MyFocusController;
var AICombatController	MyCombatController;
var vector				WanderDir;

function Activate( optional actor NewTarget );

final function SetAlertness(float NewAlertness)
{
	if ( Alertness != NewAlertness )
	{
		PeripheralVision += 0.707 * (Alertness - NewAlertness); //Used by engine for SeePlayer()
		HearingThreshold += 0.5 * (Alertness - NewAlertness); //Used by engine for HearNoise()
		Alertness = NewAlertness;
	}
}

function Panic()
{
	bPanicking = true;
	GotoState( 'Wandering' );
}

function PostBeginPlay()
{
	Disable( 'SeeFocalPoint' );
	Disable( 'FocalPointNotVisible' );
	Super.PostBeginPlay();
}

//----------------------------------------------------------------------------
// Returns the current PatrolControl actor.
function PatrolControl GetPatrolControl()
{
	local PatrolControl CurrentPatrolControl;
	local name MatchTag;
	local name MatchTag2;

	MatchTag = Tag;
	MatchTag2 = PatrolTag;
	
	foreach allactors( class'PatrolControl', CurrentPatrolControl )
	{
		if( CurrentPatrolControl.Tag == MatchTag || CurrentPatrolControl.Tag == MatchTag2 )
		{
			return CurrentPatrolControl;
		}
	}
}


function PlayNPCAnimEvent( int EventNum )
{
	local actor anActor;

	if( NPCAnimEvent[ EventNum ].bEnabled )
	{
		if( NPCAnimEvent[ EventNum ].EventSound != None )
		{
			//	PlaySound( NPCAnimEvent[ EventNum ].EventSound,, SoundDampening * 0.5 );
			if( SoundVolume > 0 )
			{
//				PlayOwnedSound( NPCAnimEvent[ EventNum ].EventSound,,,,NPCAnimEvent[ EventNum ].SoundRadius);
				PlaySound( NPCAnimEvent[ EventNum ].EventSound,, SoundDampening * NPCAnimEvent[ EventNum ].SoundVolume );
			}
			else
				PlaySound( NPCAnimEvent[ EventNum ].EventSound );
		}
		if( NPCAnimEvent[ EventNum ].TriggerEvent != '' )
		{
			foreach allactors( class'Actor', anActor, NPCAnimEvent[ EventNum ].TriggerEvent )
			{
				anActor.Trigger( self, self );
			}
		}
	}
}

function TriggerHate() {}
function float GetRunSpeed() { return RunSpeed; }
function float GetWalkingSpeed() { return WalkingSpeed; }

function StopMoving()
{
	Acceleration = vect(0,0,0);
	Velocity = vect(0,0,0);
	MoveTimer = -1.0;
}

// Implement in subclass
event SeeFocalPoint( actor PointSeen );

function InitializeController()
{
	local AICombatController C;
	
	foreach allactors( class'AICombatController', C )
	{
		if( C.Tag == ControlTag )
		{
			if( C.AddPawn( self ) )
				MyCombatController = C;
			else
				log( "AddPawn failed for "$self$"!" );
		}
	}
}

function StopFiring()
{
	bFire = 0;
	bAltFire = 0;
}

function NPCAnimEvent0()
{
	PlayNPCAnimEvent( 0 );
}

function NPCAnimEvent1()
{
	PlayNPCAnimEvent( 1 );
}

function NPCAnimEvent2()
{
	PlayNPCAnimEvent( 2 );
}

function NPCAnimEvent3()
{
	PlayNPCAnimEvent( 3 );
}

function NPCAnimEvent4()
{
	PlayNPCAnimEvent( 4 );
}

function NPCAnimEvent5()
{
	PlayNPCAnimEvent( 5 );
}

function NPCAnimEvent6()
{
	PlayNPCAnimEvent( 6 );
}

function NPCAnimEvent7()
{
	PlayNPCAnimEvent( 7 );
}

function NPCAnimEvent8()
{
	PlayNPCAnimEvent( 8 );
}

function NPCAnimEvent9()
{
	PlayNPCAnimEvent( 9 );
}

function NPCAnimEvent10()
{
	PlayNPCAnimEvent( 10 );
}

function NPCAnimEvent11()
{
	PlayNPCAnimEvent( 11 );
}

function NPCAnimEvent12()
{
	PlayNPCAnimEvent( 12 );
}

function NPCAnimEvent13()
{
	PlayNPCAnimEvent( 13 );
}

function NPCAnimEvent14()
{
	PlayNPCAnimEvent( 14 );
}

function NPCAnimEvent15()
{
	PlayNPCAnimEvent( 15 );
}

function bool NeedToTurn(vector targ)
{
	local int YawErr;

	DesiredRotation = Rotator(targ - location);
	DesiredRotation.Pitch = 0;
	DesiredRotation.Yaw = DesiredRotation.Yaw & 65535;
	
	YawErr = (DesiredRotation.Yaw - (Rotation.Yaw & 65535)) & 65535;
	if ( (YawErr < 4000) || (YawErr > 61535) )
		return false;

	return true;
}

function Died( pawn Killer, class<DamageType> DamageType, vector HitLocation, optional vector Momentum )
{
	local StickyBomb Sticky;

	// Blow up all the stickybombs attached to me.
	class'StickyBomb'.static.BlowUpStickies( Sticky, Self );
	if( MyFactory != None )
		MyFactory.RemoveCreature( self );

	Super.Died( Killer, DamageType, HitLocation );
}

function bool CanSeeEnemyFrom( vector aLocation, optional float NewEyeHeight, optional bool bUseNewEyeHeight )
{
	local actor HitActor;
	local vector HitNormal, HitLocation, HeightAdjust;

	if( bUseNewEyeHeight )
	{
		HeightAdjust.Z = NewEyeHeight;
	}
	else
		HeightAdjust.Z = BaseEyeHeight;
	HitActor = Trace( HitLocation, HitNormal, Enemy.Location, aLocation + HeightAdjust, true );
	if( HitActor == Enemy )
	{
		return true;
	}
	return false;
}


function HandlePickup( Inventory Pick )
{
	Super.HandlePickup( Pick );

	// Perform AI update.
	if ( MoveTarget == Pick )
		MoveTimer = -1.0;		
}

defaultproperties
{
    GibbySound(0)=sound'a_impact.body.ImpactBody15a'
    GibbySound(1)=sound'a_impact.body.ImpactBody18a'
    GibbySound(2)=sound'a_impact.body.ImpactBody19a'
    HitPackageClass=class'HitPackage_Flesh'
    HitPackageLevelClass=class'HitPackage_DukeLevel'
    PuddleSplashStepEffect=class'dnCharacterFX_Water_FootSplashPuddle'
    SplashStepEffect=class'dnCharacterFX_Water_FootSplash'
    FireStepEffect=class'dnFlameThrowerFX_PersonBurn_Footstep'
    FireStepEffectShrunk=class'dnFlameThrowerFX_Shrunk_PersonBurn_Footstep'
	bTakesDOT=true
    bFlammable=true
    bFreezable=true
	bShrinkable=true
    bShadowCast=true
	bShadowReceive=true
}