/*-----------------------------------------------------------------------------
	PlayerPawn
-----------------------------------------------------------------------------*/
class PlayerPawn expands Pawn
	config(user)
	native
	nativereplication;

#exec Texture IMPORT File="Textures\dnflogo.pcx" Name=S_DNFLogo Mips=Off Flags=2



/*-----------------------------------------------------------------------------
	Critical
-----------------------------------------------------------------------------*/

var	const player				Player;



/*-----------------------------------------------------------------------------
	Camera & View
-----------------------------------------------------------------------------*/

var enum EPlayerCameraStyle
{
	PCS_Normal,					// Normal camera.
	PCS_HeatVision,				// Heat-based pseudo-infrared camera.
	PCS_NightVision,			// Night vision camera.
	PCS_ZoomMode				// Zoom camera.
}								CameraStyle;

var			actor				ViewTarget;
var			vector				FlashScale, FlashFog;
var	globalconfig float			Bob;
var			float				LandBob, AppliedBob;
var			float				BobTime;
var			float				DesiredFlashScale, ConstantGlowScale, InstantFlash;
var			vector				DesiredFlashFog, ConstantGlowFog, InstantFog;
var			float				WeapShakeOffset;
var			float				ShakeTimer;				// Player uses this for shaking view.
var			int					ShakeMag;				// Max magnitude in degrees of shaking.
var			float				ShakeVert;				// Max vertical shake magnitude.
var			bool				bShakeDir;			
var			float				MaxShake;
var			float				VertTimer;
var			bool				bFixedCamera;
var			bool				bCenterView;
var         bool                bCameraLook;            // If true, player's rotation will not update
var			float				EyeSmoothScale;			// NJS: Amount to scale eye smoothing
var			int					ZoomLevel;
var			float				ZoomChangeTime;
var			sound				ZoomInSound;
var			sound				ZoomOutSound;
var			color				SavedFogColor, HeatFogColor, NightFogColor;
var			bool				bNoTracking;

// Remote pawn view targets.
var			rotator				TargetViewRotation; 
var			float				TargetEyeHeight;
var			vector				TargetWeaponViewOffset;
var unbound bool				DontUpdateEyeHeight;

// FOV stuff.
var			float				DesiredFOV;
var			float				DefaultFOV;
var			bool				bLockFOV;
var			float				FOVLockTo;
var			float				OriginalFOV;
var			float				FOVTimeScale;

// Render level stuff.
var			int					ShowFlags;
var			int					RendMap;
var			int					Misc1;
var			int					Misc2;

// Ropes
var         bool                bMoveToRope;     // If true, we should move smoothly to the currentBone in the physics
var         BoneRope            currentRope;     // Rope we are hanging on
var         int                 boneRopeHandle;  // Current bone index we are attached to on the rope
var         float               ropeOffset;      // Our current offset from the bone attachment point
var unbound float               lastRopeTime;    // To keep track of last time we were on a rope
var unbound BoneRope            lastRope;        // last rope we were on
var unbound Rotator             baseRotation;    // Our base Rotation before a rope swing affects us
var unbound bool                bCheckUseRopes;  // Check for rope grabs
var         float               onRopeSpeed;     // Desired speed to get on the rope (to avoid the snap)

// Death stuff.
var			Carcass				PendingDeathCarcass, DeathCarcass;
var			float				BloodFlashTime;

// View mapper.
var			Actor				ViewMapper;
var			Actor				OverlayActor;


/*-----------------------------------------------------------------------------
	HUD & Scoreboard
-----------------------------------------------------------------------------*/

var			HUD					MyHUD;
var			Scoreboard			Scoreboard;
var			class<HUD>			HUDType;
var			class<Scoreboard>	ScoreboardType;
var globalconfig unbound bool	bHelperMessages;
var			bool				bBadConnectionAlert;	// If true, draw the bad connection alert.
var unbound bool				ShowLogo;
var			bool				bShowScores;
var			bool				bIsTyping;
var	unbound	bool				bFirstDraw;

// UT style progress stuff.
var			string				ProgressMessage[8];
var			color				ProgressColor[8];
var			float				ProgressTimeOut;

// Various messages.
var localized string			QuickSaveString;
var localized string			NoPauseMessage;
var localized string			ViewingFrom;
var localized string			OwnCamera;
var localized string			FailedView;
var	localized string			JoinSpectatorText;
var	localized string			LeaveSpectatorText;

// Other configuration.
var globalconfig bool bNoFlash;
var globalconfig bool bNoVoices;
var globalconfig bool bMessageBeep;

// Delayed command stuff.
var			bool				bDelayedCommand;
var			string				DelayedCommand;


/*-----------------------------------------------------------------------------
	Music / Audio
-----------------------------------------------------------------------------*/

var			Music				Song;
var			byte				SongSection;
var			byte				CdTrack;
var			EMusicTransition	Transition;

var			float				LastPlaySound;
var			DukeVoice			DukeVoice;



/*-----------------------------------------------------------------------------
	Input
-----------------------------------------------------------------------------*/

var	  input float				aBaseX, aBaseY, aBaseZ,
								aMouseX, aMouseY,
								aForward, aTurn, aStrafe, aUp, 
								aLookUp, aExtra4, aExtra3, aExtra2,
								aExtra1, aExtra0;
var unbound float				LastLookUp, LastTurn;
var globalconfig float			MouseSensitivity;
var globalconfig bool			bMaxMouseSmoothing;
var			bool				bMouseZeroed;
var globalconfig bool			bLookUpStairs;
var globalconfig bool			bSnapToLevel;
var globalconfig bool			bAlwaysMouseLook;
var globalconfig bool			bKeyboardLook;
var globalconfig bool			bInvertMouse;
var globalconfig float			MouseSmoothThreshold;
var bool						bEatInput;
var			float				MouseZeroTime;
var			int					UseZone;
var			bool				bUseItem;
var			bool				bBunnyHop;

// Shield Control Mode
var globalconfig enum EShieldMode
{
	SM_Hold,					// Holding use brings out the shield.
	SM_Toggle					// Pressing use toggles the shield.
}								ShieldMode;

var int							VehicleRoll, VehiclePitch;



/*-----------------------------------------------------------------------------
	Item Manipulation / Inventory / Interactivity
-----------------------------------------------------------------------------*/

// Corpse.
var			class<Carcass>		CarcassType;

// Inventory Dip
var unbound float				InventoryDipStartTime;	// Started time, or 0 if none.
var unbound float				InventoryDipLength;		// Time to dip. 
var unbound float				InventoryDipMagnitude;	// Max amount to dip.
var unbound float				InventoryDipScaler;		// How much to scale inventory dip.
var unbound vector				InventoryDipDirection;	// Direction to dip inventory (Normalized vector)

// Examine
var			RenderActor			ExamineActor;
var			float				ExamineTime, PreExamineFOV;
var			bool				bExamining;

// Weapon
var travel globalconfig float	MyAutoAim;
var travel globalconfig float	Handedness;
var globalconfig name			WeaponPriority[20];
var globalconfig bool			bNeverAutoSwitch;	// If true, don't automatically switch to picked up weapon
var			bool				bJustFired;
var			bool				bJustAltFired;
var         bool                bInfiniteAmmo;
var unbound bool				bDukeHandUp;
var travel	rotator				TravelViewRotation;
var travel  bool				TeleportTravel;

// SOS
var unbound sound				SOSPowerOffSound;
var unbound sound				SOSPowerOnSound;
var			sound				QMenuUse;

// Threat Indicators
struct native Threat
{
    var float Distance;
    var Actor Actor;
    var float Alpha;
};

var         Threat              leftThreats[6];
var         Threat              rightThreats[6];

var unbound Decoration			NotifyUnUsed;
var unbound Decoration			ClientNotifyUnUsed;

var unbound bool				bFireUse;

// Piss
var unbound bool				bHasToPiss;
var unbound float				CantPissTime;
var	unbound	bool				bPissing;

// Torso/Head rotation stuff
var float                       HeadYawLimit, AbdomenYawLimit;
var int                         HeadYaw, AbdomenYaw;

// Recent items picked up.
// These are implemented as a replicated queued array.
// This seems to be a more network friendly approach than a replicated function.
var class<Inventory>			RecentPickups[6];
var int							RecentPickupsIndex;

var ThirdPersonDecoration       ThirdPersonDecoration;

// Look Hit Actor (Actor that is UseDistance away from me.)
var RenderActor					LookHitActor;

// Jetpack.
var bool						bActiveJetpack, bJetpacking;
var float						JetpackForce, JetpackAirControl;
var float						MinRespawnTime, MaxRespawnTime;


/*-----------------------------------------------------------------------------
	Movement
-----------------------------------------------------------------------------*/

var			bool				bWasForward;	// Used for dodge move.
var			bool				bWasBack;
var			bool				bWasLeft;
var			bool				bWasRight;
var			bool				bWasTurnLeft;	// NJS
var			bool				bWasTurnRight;	// NJS
var			bool				bEdgeTurnLeft;	// NJS
var			bool			    bEdgeTurnRight;	// NJS
var			bool				bEdgeForward;
var			bool				bEdgeBack;
var			bool				bEdgeLeft;
var			bool				bEdgeRight;
var         bool		        bIsDucking;
var			bool				bAnimTransition;
var			bool				bIsTurning;
var			bool				bPressedJump;
var			bool				bUpdatePosition;
var			bool				bRising;
var			bool				bJumpStatus;
var			bool				bUpdating;

var			SavedMove			SavedMoves;
var			SavedMove			FreeMoves;
var			SavedMove			PendingMove;
var			float				CurrentTimeStamp,LastUpdateTime,ServerTimeStamp,TimeMargin, ClientUpdateTime;
var globalconfig float			MaxTimeMargin;
var			float				LastMoveDirection;

var unbound travel bool			Autoduck;
var			travel float		DuckCollisionHeight;
var			travel float		OriginalCollisionHeight;
var			travel float		DestinationCollisionHeight;
var			travel float		CollisionHeightTime;
var			travel float		CollisionHeightStartTime;		

var unbound travel bool			ForceDuck;		// Duck has been forced.
var unbound travel int			DuckCount;		// TotalDuckCount
var unbound bool				PreLandedCalled;// Pre landed was called, but not landed

// Demo recording stuff.
var			int					DemoViewPitch;
var			int					DemoViewYaw;

// Special smooth rotation.
var unbound rotator				SmoothRotation;
var         float               StartSmoothRotationTime;

// Ladder Movement
var			bool				bOnGround;
var         float               ladderJumpTime;
var         float               ladderSpeedFactor;

// Screen shaking.
var			float				ShakeStrength;
var			float				ShakeDamping;
var			float				ShakeRotStrength;
var			Vector				ShakeVector;
var			int					ShakeYaw, ShakePitch, ShakeRoll;

// Jetpack stuff.
var			float				LastATurn, LastAForward;

// Pain stuff
var         float               PainDebounceTime;
var         float               PainDelay;

// View rotation.
var rotator						DesiredViewRotation, ViewRotationRate;
var name						RotateViewCallback;

// View vibrate.
var vector						VibrationVector;
var vector						VibrationIntensity;
var float						VibrationTime;
var float						VibrationElasticity;
var float						VibrationPeriod;



/*-----------------------------------------------------------------------------
	Networking
-----------------------------------------------------------------------------*/

var			bool				bAdmin;
var GameReplicationInfo			GameReplicationInfo;
var	globalconfig string			Password;
var			bool				bSinglePlayer;  // This class allowed in single player.
var			bool				bReadyToPlay;



/*-----------------------------------------------------------------------------
	Control Remapping
-----------------------------------------------------------------------------*/

var			name				TurnLeftEvent, TurnRightEvent, StrafeLeftEvent, StrafeRightEvent; 
var			name				MoveForwardEvent, MoveBackwardEvent;
var			name				AltFireEvent, FireEvent, JumpEvent, DuckEvent;
var			name				RelinquishControlEvent;

var			bool				bTurnLeftContinuous, bTurnRightContinuous, bStrafeLeftContinuous, bStrafeRightContinuous;
var			bool				bMoveForwardContinuous, bMoveBackwardContinuous;
var			bool				bAltFireContinuous, bFireContinuous, bJumpContinuous, bDuckContinuous; 
var			byte				bAltFireDown, bFireDown;

var			name				TurnLeftEventEnd, TurnRightEventEnd, StrafeLeftEventEnd, StrafeRightEventEnd;
var			name				MoveForwardEventEnd, MoveBackwardEventEnd;
var			name				AltFireEventEnd, FireEventEnd, JumpEventEnd, DuckEventEnd;

var			bool				bControlPanelHideWeapon;
var unbound bool				bOneKeyAtATime;

var			bool				bUseRemappedEvents;
var			bool				bDontUnRemap;
var			Actor				InputHookActor;
var			Actor				KeyEventHookActor;

var			bool				bLockRotation;
var			rotator				RotationLockDirection;

var			travel int			DuckPressedCount;
var			travel int			JumpPressedCount;
var         bool                bAllowRestart;



/*-----------------------------------------------------------------------------
	Debugging & Temporary
-----------------------------------------------------------------------------*/

var			Actor				MyDebugView;
var			bool				bCheatsEnabled;

// Watch Debug Stuff
const                           mObjMax=64;
var actor                       maObjList[64];
var string                      maPropList[64];
var int                         mabShowState[64];
var int                         mObjCnt;
var bool                        mbWatchEnabled;
var color                       mDrawColor;

// Spectator stuff
var bool						bChaseCam;

// Class based stuff
var bool						bChangeClass;
var bool						bQuickChangeClass;
var string						newPawnClass;
var int							maxHealth;
var bool						bCanPlantBomb;

replication
{
	// Things the server should send to the client.
	reliable if( bNetOwner && Role==ROLE_Authority )
		ViewTarget, ScoreboardType, HUDType, GameReplicationInfo, 
		bFixedCamera, bCheatsEnabled, RecentPickups, RecentPickupsIndex,
		bCanPlantBomb;
	
	reliable if( !bNetOwner && Role==ROLE_Authority )
		currentRope, boneRopeHandle, ropeOffset, bNoTracking;
	
	unreliable if ( bNetOwner && Role==ROLE_Authority )
		TargetViewRotation, TargetEyeHeight, TargetWeaponViewOffset;
	
	reliable if( bDemoRecording && Role==ROLE_Authority )
		DemoViewPitch, DemoViewYaw;

    // Things the client should send to the server
	reliable if ( Role<ROLE_Authority )
		Password, bReadyToPlay, VehicleRoll, VehiclePitch;

	// Functions client can call.
	reliable if( Role<ROLE_Authority )
		ShowPath, RememberSpot, Say, Tell, TeamSay, RestartLevel, Pause, SetPause, ShowInventory, /*ServerSetWeaponPriority,*/
		ChangeName, ChangeTeam, God, Suicide, ViewClass, ViewPlayerNum, ViewSelf, ViewPlayer, 
		ServerSetSloMo, ServerAddBots, PlayersOnly, ThrowWeapon, ServerRestartPlayer, NeverSwitchOnPickup, 
		BehindView, ServerNeverSwitchOnPickup, /*GetWeapon,*/ ServerReStartGame, /*ServerUpdateWeapons,*/ 
		ServerTaunt, ServerChangeSkin, SwitchLevel, SwitchCoopLevel, Kick, KickBan, KillAll, Summon, 
		Admin, AdminLogin, AdminLogout, Typing, Mutate,	SetEnergyDrain, ServerUseDown, ServerUseUp, 
		ServerShieldPutDown, ServerShieldBringUp, ServerDestroyShield, ServerInventoryActivate, 
		ServerChangeMesh, ServerChangeVoice, JoinSpectator, LeaveSpectator, ServerChangeClass;

	unreliable if( Role<ROLE_Authority )
		ServerMove, Fly, Walk, Ghost;

	// Functions server can call.
	reliable if( Role==ROLE_Authority && !bDemoRecording )
		ClientTravel;
	
	reliable if( Role==ROLE_Authority )
		ClientPossess, ClientReliablePlaySound, ClientReplicateSkins, ClientAdjustGlow, ClientChangeTeam, ClientSetMusic, 
		SetDesiredFOV, ClearProgressMessages, SetProgressColor, SetProgressMessage, SetProgressTime, 
        ClientActivateShield, ClientShieldDestroyed, ClientOnRope, ClientRemoveViewMapper,
		ClientStartDefuseBomb, ClientStopDefuseBomb;
	
	reliable if ( (!bDemoRecording || (bClientDemoRecording && bClientDemoNetFunc)) && Role == ROLE_Authority )
		ClientVoiceMessage;
	
	unreliable if( Role==ROLE_Authority )
		SetFOVAngle, ClientShake, ClientFlash, ClientInstantFlash;
	
	unreliable if( Role==ROLE_Authority && !bDemoRecording )
		ClientPlaySound, ClientPlayPainSound;
	
	unreliable if( RemoteRole==ROLE_AutonomousProxy )
		ClientAdjustPosition, ClientAdjustRopePosition;
}

function DoMessage( string str )
{
    if ( Role == Role_Authority )
        ClientMessage( "Server:"@str );
    else
        ClientMessage( "Client:"@str );
}

/*-----------------------------------------------------------------------------
	Object / Initialization
-----------------------------------------------------------------------------*/

// Called by the engine right after the object is spawned or loaded from the level file.
simulated event PreBeginPlay()
{
	bIsPlayer = true;

	Super.PreBeginPlay();
}

// Called by the engine after BeginPlay.
simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

	if ( Level.NetMode != NM_Client )
	{
		HUDType				= Level.Game.HUDType;
		ScoreboardType		= Level.Game.ScoreboardType;			
		MyAutoAim			= FMax(MyAutoAim, Level.Game.AutoAim);			

		// Duke's voice.
		if ( DukeVoice == None )
			DukeVoice = spawn(class'DukeVoice', Self);
	}

	bIsPlayer   = true;
	DesiredFOV  = DefaultFOV;
	EyeHeight   = BaseEyeHeight;

	if ( (Level.Game != None) && Level.Game.IsA('dnSinglePlayer') && (Level.NetMode == NM_Standalone) )
		FlashScale = vect(0.1,0.1,0.1);
	else
		FlashScale = vect(1,1,1);

	SetTimer(3.0, true, 3);

	// Test tracking.
	EnableHeadTracking(true);
//	EnableEyeTracking(true);
    InitializeThirdPersonDecoration();
	SaveFog( Region.Zone.FogColor );
//	StartWalk();		// JEP
}

// Sets up the player replication info.
// Player replication info is a subset of player information that is always relevant
// to all clients in a network game.  (Since playerpawns are not always relevant.)
function InitPlayerReplicationInfo()
{
	Super.InitPlayerReplicationInfo();
	PlayerReplicationInfo.bAdmin = bAdmin;
}

// Called by the engine when the object is destroyed.
simulated event Destroyed()
{
	Super.Destroyed();

	// Detach from ViewMapper
	if ( (ViewMapper != None) && (Role == ROLE_Authority) )
	{
		if (RenderActor(ViewMapper) != None)
			RenderActor(ViewMapper).bDeletedOwner = true;
		ViewMapper.Used( Self, Self );
	}

	// Remove our HUD.
    if ( MyHUD != None )
		MyHUD.Destroy();

	// Remove our debug view.
    if ( MyDebugView != None )
        MyDebugView.Destroy();

	// Remove our scoreboard.
    if ( Scoreboard != None )
		Scoreboard.Destroy();

	// Remove any remaining free moves.
	while ( FreeMoves != None )
	{
		FreeMoves.Destroy();
		FreeMoves = FreeMoves.NextMove;
	}

	// Remove any remaining saved moves.
	while ( SavedMoves != None )
	{
		SavedMoves.Destroy();
		SavedMoves = SavedMoves.NextMove;
	}
}

native final function DoClientPossess();

simulated function ClientPossess()
{
	// Only clients need to repossess the new pawn
	if ( Level.NetMode != NM_Client )
		return;

	// This function will transfer the viewport over to this pawn
	DoClientPossess();
}

// Called by the engine when a player is attached to the playerpawn.
native final function bool SaveLoadActive();

event Possess()
{
	bIsPlayer = true;
	EyeHeight = BaseEyeHeight;

	// This pawn was possessed by a player.
	if ( IsSpectating() )
	{		
		NetPriority = 2;
		Weapon		= None;
		Inventory	= None;
		Fly();
	}
	else
	{
		if ( Level.Netmode == NM_Client )
		{
			// Replicate client weapon preferences to server.
			ServerNeverSwitchOnPickup( bNeverAutoSwitch );
//			UpdateWeaponPriorities();
		}
//		ServerUpdateWeapons();
		NetPriority = 3;
		
		if ( !SaveLoadActive() )
			StartWalk();		// JEP: Moved to PostBeginPlay
	}
}

// Called when we are detached from a player.
event UnPossess()
{
	// Destroy our HUD.
	if ( MyHUD != None )
		MyHUD.Destroy();

	// We are no longer a player.
	bIsPlayer = false;
	EyeHeight = 0.8 * CollisionHeight;
}

//----- these funcs should be categorized:
function checkWeaponOnRope();

function checkOnGround()
{
    local vector StartTrace, EndTrace, HitLocation, HitNormal;
	local actor HitActor;

    // See if we're on the ground
    bOnGround  = false;
    StartTrace = Location;
    EndTrace   = StartTrace - ( vect(0,0,1) * ( CollisionHeight + 5 ) ); 
    HitActor   = Trace( HitLocation, HitNormal, EndTrace, StartTrace, true );
    
	if ( HitActor == Level )
    {
        bOnGround = true;
    }
}

function UpdateShake()
{
    local rotator ShakeRotation;

    // Update rotation shaking.
    if (ShakeStrength > 1.0)
    {
	    ShakeStrength *= ShakeDamping;
	    ShakeYaw   *= ShakeDamping;
	    ShakePitch *= ShakeDamping;
	    ShakeRoll  *= ShakeDamping;
	    
	    ShakeRotation.Yaw   = ShakeYaw;
	    ShakeRotation.Pitch = ShakePitch;
	    ShakeRotation.Roll  = ShakeRoll;
	    
	    ViewRotation += ShakeRotation;
    }
}



// Return true if controlled by local (not network) player.
simulated function bool IsLocallyControlled()
{
	if ( Level.NetMode == NM_Standalone )
		return true;

	if ( Viewport(Player) != None )
		return true;

	return false;
}



/*-----------------------------------------------------------------------------
	Mutator Hooks
-----------------------------------------------------------------------------*/

// Exec function for activating mutators.
exec function Mutate( string MutateString )
{
	if( Level.NetMode == NM_Client )
		return;
	Level.Game.BaseMutator.Mutate(MutateString, Self);
}

/*-----------------------------------------------------------------------------
	Timing
-----------------------------------------------------------------------------*/

simulated exec function TestVibrate()
{
	VibrationIntensity.X = 30 * FRand();
	VibrationIntensity.Z = 30 - VibrationIntensity.X;
	VibrationTime = Level.TimeSeconds;
	VibrationElasticity = 0.99;
	VibrationPeriod = 0.006;
}

simulated function AddVibration( float Intensity, float Duration, float Elasticity, float Period )
{
	VibrationIntensity.X = Intensity * FRand();
	VibrationIntensity.Z = Intensity - VibrationIntensity.X;
	VibrationTime = Level.TimeSeconds;
	VibrationElasticity = Elasticity;
	VibrationPeriod = Period;
}

simulated event TickVibration( float DeltaTime )
{
	local vector X, Y, Z;

	GetAxes( ViewRotation, X, Y, Z );

	if ( ((VibrationIntensity.X != 0.0) || (VibrationIntensity.Z != 0.0)) && (VibrationTime + VibrationPeriod < Level.TimeSeconds) )
	{
//		BroadcastMessage(DeltaTime);
//		if ( DeltaTime > 0.03 )
//			DeltaTime = 0.03;
		VibrationIntensity.X *= -VibrationElasticity;
		VibrationIntensity.Z *= -VibrationElasticity;
		VibrationTime = Level.TimeSeconds;
		if ( abs(VibrationIntensity.X) < 0.3 )
			VibrationIntensity.X = 0.0;
		if ( abs(VibrationIntensity.Z) < 0.3 )
			VibrationIntensity.Z = 0.0;
	}
	VibrationVector = VibrationIntensity.X*Y + VibrationIntensity.Z*Z;
}

// Simulated proxy Tick. - This only gets called on clients simulating a player
simulated event Tick( float DeltaTime )
{
	// Shrinking tick.
	TickShrinking( DeltaTime );

    // Do torso rotation on client
	TickTracking( DeltaTime );

	// Tick vibration.
	TickVibration( DeltaTime );

	// Update smooth rotation if we are turning.
    if ( bIsTurning )
        UpdateSmoothRotation();
}

// Called when ( RemoteRole == ROLE_AutonomousProxy )  && ( Role == ROLE_Authority )
event ServerTick( float DeltaTime ) 
{
    local vector DrawOffset, StartTrace;

    // Check for player on ground
    checkOnGround();

    // Watchdog function for the Carried Decoration (I'd like to be able to remove this)
    if ( ( CarriedDecoration == None ) && ( ThirdPersonDecoration != None ) )
	{
        ThirdPersonDecoration.bHidden = true;
	}

    // Do rope stuff
    TouchRopes();

    if ( !bOnRope && bCheckUseRopes )
    {
		DrawOffset = BaseEyeHeight * vect(0,0,1);
	    StartTrace = Location + DrawOffset;
        checkUseRopes( StartTrace, vector( ViewRotation ) );
    }

	// Shrinking tick.
	TickShrinking( DeltaTime );

	// Tick vibration.
	TickVibration( DeltaTime );

	// Server determines whether or not to do TickTracking, 
	// this is replicated to other clients as well

	bNoTracking = ( ( GetControlState()  == CS_Stasis )   ||
				    ( GetControlState()  == CS_Frozen )   ||
				    ( GetMovementState() != MS_Waiting )  || 
				    ( GetPostureState()  != PS_Standing ) || 
				    ( bCameraLook ) );

	// Update tracking.
	TickTracking( DeltaTime );

    // This is used to update to the proper rotation if we need a smooth update    
    if ( bIsTurning )
        UpdateSmoothRotation();

	// Do the proper animations for jetpacking
	if ( GetPostureState() == PS_Jetpack )
		PlayJetpacking();
}

// Called when ( Role >= ROLE_SimulatedProxy ) && !ServerTick 
event PlayerTick( float DeltaTime ) 
{
    // Do screen shaking
    UpdateShake();

	// Update view rotation control.
	UpdateDesiredViewRotation( DeltaTime );

    // Update animation.
	AnimTick( DeltaTime );

    // Common stuff a server and client do
    ServerTick( DeltaTime );
    
	// Physics tick.
	if ( GetControlState() == CS_Normal )
	{
		PlayerTick_Walking( DeltaTime );
	}
    else
    {
		// Received an adjustment from the server, so move us to the new position
	    if ( bUpdatePosition )
		    ClientUpdatePosition();		

		// Do regular move
        PlayerMove(DeltaTime);
	}

	// Move our voice.
	if ( DukeVoice != None )
		DukeVoice.SetLocation( Location );
}

// Called by PlayerTick if we are in the walking control state.
function PlayerTick_Walking( float DeltaTime )
{
	local vector	v, StartTrace, EndTrace, HitLocation, HitNormal;
	local bool		hitSomething;
	local float		TraceRadius;
	local bool		StopExamine;
	local vector	Dir;
	local float		Len;
	local Actor		HitActor;

	// Received an adjustment from the server, so move us to the new position
	if ( bUpdatePosition )
		ClientUpdatePosition();

	// Do the regular move
	PlayerMove( DeltaTime );

	// Turn off a close examination if the player looks away.
	LookHitActor = RenderActor( TraceFromCrosshair( UseDistance ) );
	
	StopExamine = false;

	if ( ExamineActor != None )
	{
		if ( !ExamineActor.bExamineRadiusCheck )
		{
			if ( (LookHitActor == None) || (LookHitActor != ExamineActor) )
				StopExamine = true;
		}
		else
		{
			Dir = ExamineActor.Location - Location;		// Make a vector from us to the examined actor
			Len = VSize(Dir);
			
			if ( Len > ExamineActor.ExamineRadius )
				StopExamine = true;
			else
			{
				Dir /= Len;

				if ( Dir dot vector(ViewRotation) < 0.15 )
					StopExamine = true;
			}
		}
	}

	if ( StopExamine )
	{
		if ( ExamineActor != None )
			ExamineActor.UnExamine( Self );
		ExamineActor = None;
		HeadTrackingActor = None;
		HeadTrackingLocation = Location;
		if ( bExamining )
			DesiredFOV = PreExamineFOV;
		bExamining = false;
		ExamineTime = 0.0;
	}

	if ( bFullyShrunk )
		return;

	// Perform auto ducking.
	v = vect(0,0,0);
	v.Z = Default.CollisionHeight + (Default.CollisionHeight - CollisionHeight);
	v.Z += 5;
	hitSomething = false;
	StartTrace = Location;
	EndTrace   = StartTrace + v;
	HitActor = Trace( HitLocation, HitNormal, EndTrace, StartTrace, true );
	if ( HitActor == Level )
		hitSomething = true;
	else
	{
		TraceRadius = CollisionRadius * 0.9;

		// Try tracing east:
		StartTrace = Location;
		StartTrace.X += TraceRadius;
		EndTrace   = StartTrace + v;
		
		HitActor = Trace( HitLocation, HitNormal, EndTrace, StartTrace, true );
		if ( HitActor == Level )
			hitSomething = true;
		else
		{
			// Try tracing west:
			StartTrace = Location;
			StartTrace.X -= TraceRadius;
			EndTrace   = StartTrace + v;
			
			HitActor = Trace( HitLocation, HitNormal, EndTrace, StartTrace, true );
			if ( HitActor == Level )
				hitSomething = true;
			else
			{
				// Try tracing north:
				StartTrace = Location;
				StartTrace.Y += TraceRadius;
				EndTrace   = StartTrace + v;
			
				HitActor = Trace( HitLocation, HitNormal, EndTrace, StartTrace, true );
				if ( HitActor == Level )
					hitSomething = true;
				else
				{
					// Try tracing south:
					StartTrace = Location;
					StartTrace.X -= TraceRadius;
					EndTrace   = StartTrace + v;
			
					HitActor = Trace( HitLocation, HitNormal, EndTrace, StartTrace, true );
					if ( HitActor == Level )
						hitSomething = true;

				}
			}
		}
	}

	if ( hitSomething )
	{
		if ( !ForceDuck && Autoduck )
		{
			ForceDuck = true;
			DuckDown();
		}
	} else if ( ForceDuck )
	{
		ForceDuck = false;
		DuckUp();
	}
}



/*-----------------------------------------------------------------------------
	Timers

	1 EMP
	2 DeathSequence
	3 HealthDecay
-----------------------------------------------------------------------------*/

// Timer
function Timer( optional int TimerNum )
{
	// UnEMP timer.
	if ( TimerNum == 1 )
		UnEMP();

	// Timer for death sequence.
	if ( (GetControlState() == CS_Dead) && (TimerNum == 2) )
	{
		if ( Level.NetMode == NM_Standalone )
			Level.Game.SetGameSpeed( 1.0 );
		ShowDeathSequence();
	}

	// Health decay timer.
	if ( TimerNum == 3 )
	{
		if ( Health > MaxHealth )
			Health--;
	}    
}

// Called to update special per-frame timers.
event UpdateTimers( float DeltaSeconds )
{
	Super.UpdateTimers( DeltaSeconds );

	// Do underwater breathing.
	if ( WaterAmbientTime > 0.0 )
	{
		WaterAmbientTime -= DeltaSeconds;
		if ( WaterAmbientTime < 0.0 )
		{
			WaterAmbientTime = 0.0;
			if ( HeadRegion.Zone.bWaterZone )
			{
				PlaySound(WaterAmbience, SLOT_Interact, 16, , 1000, 0.9 + FRand()*0.2);
				WaterAmbientTime = Rand(5) + 5;
			}
			else if ( GetPostureState() == PS_Swimming )
			{
				PlaySound(LittleSplash[Rand(2)], SLOT_Interact, 16, , 1000, 0.9 + FRand()*0.2);
				WaterAmbientTime = Rand(2) + 2;
			}
		}
	}

	// Update special inventory.
	if ( UsedItem != None )
		UsedItem.UpdateTimers( DeltaSeconds );

	// Update energy drain.
	if ( Role == ROLE_Authority )
	{
		if ( EnergyDrain > 0.0 )
			Energy -= EnergyDrain * DeltaSeconds;
		if ( (EnergyDrain > 0.0) && (Energy < 0.0) )
            KillSOSPowers();
	}
	
	// Count down until we can piss again.
	if ( CantPissTime > 0.0 )
	{
		CantPissTime -= DeltaSeconds;
		if ( CantPissTime <= 0.0 )
		{
			CantPissTime = 0.0;
			bHasToPiss = true;
		}
	}

	// Shake it baby.
	if ( WeapShakeOffset > 0.0 )
	{
		WeapShakeOffset -= DeltaSeconds*30;
		if ( WeapShakeOffset < 0.0 )
			WeapShakeOffset = 0.0;
	}

	// Screen blood flash.
	if ( BloodFlashTime > 0.0 )
	{
		BloodFlashTime -= DeltaSeconds;
		if ( BloodFlashTime < 0.0 )
			BloodFlashTime = 0.0;
		if ( BloodFlashTime <= 1.0 )
		{
			if ( FlashScale.X > 0.0 )
			{
				FlashScale.X -= DeltaSeconds;
				FlashScale.Y -= DeltaSeconds;
				FlashScale.Z -= DeltaSeconds;
			}
		}
	}

	// Auto-recharge.
	// Currently we decided against this slight auto recharge in favor of stackable energy cell items.
	// if ((EnergyDrain == 0.0) && (Energy < 25))
	//   Energy += DeltaSeconds;
}



/*-----------------------------------------------------------------------------
	Bones / Tracking
	Assumes Human skeleton is standard.
-----------------------------------------------------------------------------*/

// Called by the engine to perform script bone manipulation.
simulated event bool OnEvalBones( int Channel )
{
    if ( Channel == 3 )
    {
        // If we see a model on the client and it's in the waiting/standing state, then do the GentleRotation.
        if ( ( MovementState == MS_Waiting ) && ( PostureState == PS_Standing ) )
            EvalGentleRotation(true);
    }
	return Super.OnEvalBones(Channel);
}

// Bone evaluation for gentle abdomen and head rotation.
simulated function bool EvalGentleRotation( bool rotateBones )
{
	local MeshInstance  minst;

    if ( rotateBones )
    {
        minst = GetMeshInstance();

        if ( minst != None )
            DoBoneRotation( HeadYaw, AbdomenYaw, minst );
    }
	return true;
}

// Rotates the body given a certain amount of yaw.
simulated function DoBoneRotation( float HYaw, float AYaw, MeshInstance minst )
{
	local int bone;
	local rotator r;

    if ( minst == None )
        return;

    bone    = minst.BoneFindNamed( 'Head' );
    if ( bone != 0 )
	{
		r = minst.BoneGetRotate( bone, true, false );
		r = rot(0, 0, HYaw);
		minst.BoneSetRotate( bone, r, false, true );
    }

    bone = minst.BoneFindNamed( 'Abdomen' );
	if ( bone != 0 )
	{
		r = minst.BoneGetRotate( bone, true, false );
		r = rot( 0, 0, AYaw );
		minst.BoneSetRotate( bone, r, false, true );
	}
}

// Per-frame update for head and abdomen tracking.
simulated function TickTracking( float deltaTime )
{
    local rotator       r;

    Super.TickTracking( deltaTime );

    if ( bNoTracking )
        return;

    r = Rotation - ViewRotation;
    r = Normalize( r );

	HeadYaw     = Clamp( r.Yaw, -HeadYawLimit,    HeadYawLimit );
    AbdomenYaw  = Clamp( r.Yaw, -AbdomenYawLimit, AbdomenYawLimit );

    if ( !bIsTurning && ( ( AbdomenYaw >= AbdomenYawLimit-5 ) || ( AbdomenYaw <= -AbdomenYawLimit+5 ) ) )
        StartSmoothRotation( AbdomenYaw );
}

// Sets variables for initiating smooth rotation of the abdomen and head.
function StartSmoothRotation( int Yaw )
{
    PlayUpdateRotation( Yaw );
    bIsTurning				= true;
    StartSmoothRotationTime = Level.TimeSeconds;
}

// Called by tick to update our rotation values.
function UpdateSmoothRotation()  
{
    local float alpha;
    local rotator r;
    
    // This is called when the torso exceeds the current limit on Yaw and will slerp the legs to the new rotation.
    alpha = ( Level.TimeSeconds - StartSmoothRotationTime ) / 0.5;

    if ( alpha >= 1.0 )
    {
        alpha = 1.0;
        bIsTurning = false;
    }

    r = Slerp( alpha, Rotation, SmoothRotation );
    setRotation( r );
}



/*-----------------------------------------------------------------------------
	State Management
-----------------------------------------------------------------------------*/

// Called when our head enters a waterzone.
function HeadEnteredWater()
{
	// Change us to the crouching collision size.
    ChangeCollisionHeightToCrouching();

	// Call parent.
	Super.HeadEnteredWater();
}

// Called when our head exits a waterzone.
function HeadExitedWater()
{
	// Change us to the standing collision size.
    ChangeCollisionHeightToStanding();

	// Call parent.
	Super.HeadExitedWater();
}

// Called when we enter the normal control state.
function EnterControlState_Normal()
{
	if ( Physics != PHYS_Falling ) 
	{
		SetPhysics( PHYS_Walking );
	}

	/*
	if ( !IsAnimating() )
	{
		PlayWaiting();
	}
	*/

	/*
	if ( Mesh == None )
		Mesh = Default.Mesh;

    WalkBob         = vect(0,0,0);
	bIsTurning      = false;	
	bPressedJump    = false;
	*/
}

// Called when we leave the normal control state.
function ExitControlState_Normal()
{
	WalkBob = vect(0,0,0);
	SetPostureState( PS_Standing, true );
	SetMovementState( MS_Waiting, true );
}

// Called when we enter the jetpack control state.
function EnterControlState_Jetpack()
{
	SetPostureState( PS_Jetpack );
	SetMovementState( MS_Jetpack );
	JetpackState = JS_None;
	bCanFly=true;
}

// Called when we exit the jetpack control state.
function ExitControlState_Jetpack()
{
	bCanFly=false;
	if( !bOnGround )
		SetPostureState( PS_Jumping, true );
	else
		SetPostureState( PS_Standing );

	SetMovementState( MS_Waiting, true );
	PlayAnim( 'None', , , 2 );
	PlayAnim( 'None', , , 3 );

	if ( !bOnGround )
		PlayInAir();
	else
		PlayWaiting();
}

// Called when we enter the swimming control state.
function EnterControlState_Swimming()
{
    ChangeCollisionHeightToCrouching();	
    if ( !IsAnimating() )
		TweenToWaiting(0.3);
}

// Called when we exit the swimming control state.
function ExitControlState_Swimming()
{
    ChangeCollisionHeightToStanding();
}

// Called when we enter the flying control state.
function EnterControlState_Flying()
{
	EyeHeight = BaseEyeHeight;
	SetPhysics( PHYS_Flying );
}

// Called when we enter the dead control state.
function EnterControlState_Dead()
{
	// Adjust the player's view.
	BaseEyeheight   = default.BaseEyeHeight;
	EyeHeight       = BaseEyeHeight;
	bPressedJump    = false;
	bJustFired      = false;
	bJustAltFired   = false;
    bShowScores     = GameReplicationInfo.bShowScores;
	Acceleration    = vect( 0,0,0 );
	Velocity        = vect( 0,0,0 );

	FindGoodView();	

	if ( bShowScores )
		Player.Console.ShowScoreboard();

    // Clean out saved moves.
	while ( SavedMoves != None )
	{
		SavedMoves.Destroy();
		SavedMoves = SavedMoves.NextMove;
	}

	if ( PendingMove != None )
	{
		PendingMove.Destroy();
		PendingMove = None;
	}
	
    // Notify the HUD we died.    
    if ( MyHUD != None )
        MyHUD.OwnerDied();

    if ( bOnRope )
        OffRope();

    // Ask if we should start a timer for the end game.
	if ( GameReplicationInfo.bPlayDeathSequence )
    {
		SetTimer(3.0, false, 2);
    }
    else // Set a timer to allow player restart
    {
        SetCallbackTimer( MinRespawnTime, false, 'AllowRespawn' );
		SetCallbackTimer( MaxRespawnTime, false, 'ForceRespawn' );
    }

	// SLOOOO DOOOWN....
	if ( Level.NetMode == NM_Standalone )
	{
		Level.Game.SetGameSpeed( 0.5 );
		BloodFlashTime = 3.0;
		FlashScale = vect(1.0, 1.0, 1.0);
		FlashFog   = vect(0.8, 0.0, 0.0);
	}

    // Punt to Pawn to spawn carcass.
	Super.EnterControlState_Dead();
}

function AllowRespawn()
{
	if ( GetControlState() == CS_Dead ) 
	{
		bAllowRestart = true;
		EndCallbackTimer( 'ForceRespawn' );
	}
	else
	{
		Log( "Invalid ControlState in PlayerPawn::Timer.  Cannot set bAllowRestart to true" );
	}
}

function bool DoRespawn()
{
	if ( GetControlState() == CS_Dead && bAllowRestart )
	{
		Fire();
		return true;
	}

	return false;
}

function ForceRespawn()
{
	bAllowRestart = true;
	Fire();
}

// Called when we exit the dead control state.
function ExitControlState_Dead()
{
	// Adjust the player's view.
	Velocity        = vect(0,0,0);
	Acceleration    = vect(0,0,0);
	bBehindView     = false;
	bShowScores     = false;
	bJustFired      = false;
	bJustAltFired   = false;
	bPressedJump    = false;
	bBunnyHop		= false;
	
	ViewTarget      = None;

	// Clean out saved moves.
	while ( SavedMoves != None )
	{
		SavedMoves.Destroy();
		SavedMoves = SavedMoves.NextMove;
	}
	if ( PendingMove != None )
	{
		PendingMove.Destroy();
		PendingMove = None;
	}

	if ( Player.Console != None )
		Player.Console.HideScoreboard();

}

// Called when we enter the stasis control state.
function EnterControlState_Stasis()
{
	AnimRate	= 0.0;
	SimAnim.Y	= 0;
	bFire		= 0;
	bAltFire	= 0;	
	bShowScores = true;

	SetCollision( false,false,false );

	if ( !bFixedCamera )
	{
		FindGoodView();
		bBehindView = true;
	}
	SetPhysics( PHYS_None );
}

// Called when we enter the rope control state.
function EnterControlState_Rope()
{
}

// Called when we enter the ladder control state.
function EnterControlState_Ladder()
{
    SetPostureState( PS_Ladder );
    SetMovementState( MS_LadderIdle );
}

// Called when we enter the frozen control state.
function EnterControlState_Frozen()
{
	AnimRate				= 0.0;
	AnimBlend				= 1.0;
	DesiredTopAnimBlend		= 1.0;
	TopAnimBlend			= 0.0;
	TopAnimBlendRate		= 5.0; 
	DesiredBottomAnimBlend	= 1.0;
	BottomAnimBlend			= 0.0;
	BottomAnimBlendRate		= 5.0;

//	SimAnim.Y	= 0;
	bFire		= 0;
	bAltFire	= 0;

	Super.EnterControlState_Frozen();
}



/*-----------------------------------------------------------------------------
	Debugging
-----------------------------------------------------------------------------*/

exec function KillSound()
{
	StopSound( SLOT_Talk );
}

exec function ToggleDebugAnim()
{
    if ( MyDebugView != None )
    {
        if ( DebugAnimView( MyDebugView ) != None ) // check for anim view
        {
            if ( MyDebugView.bHidden )
                MyDebugView.bHidden = false;
            else
                MyDebugView.bHidden = true;
        }
        else
        {
            MyDebugView.Destroy(); 
            MyDebugView = None;
        }
    }

    if ( MyDebugView == None ) 
    {
        MyDebugView = spawn(class'DebugAnimView');
        MyDebugView.bHidden = false;
        MyDebugView.SetOwner(self);
    }
}

exec function ToggleDebug()
{
    if (MyDebugView != None)
    {
        if (MyDebugView.bHidden)
            MyDebugView.bHidden = false;
        else
            MyDebugView.bHidden = true;
    }
    else
    {
        MyDebugView = spawn(class'DebugView');
        MyDebugView.bHidden = false;
        MyDebugView.SetOwner(self);
    }
}

exec function DebugAnim( string DebugCmd )
{
    if (MyDebugView == None)
    {
        ToggleDebugAnim();
        ToggleDebugAnim();
    }

    if ((MyDebugView != None) && (DebugAnimView(MyDebugView) != None))
        DebugAnimView(MyDebugView).ConsoleCommand(DebugCmd, true);
}

exec function Debug(string DebugCmd)
{
    if (MyDebugView == None)
    {
        ToggleDebug();
        ToggleDebug();
    }

    if ((MyDebugView != None) && (DebugView(MyDebugView) != None))
        DebugView(MyDebugView).ConsoleCommand(DebugCmd, true);
}

exec function StackTrace()
{
	LogStackTrace();
}



/*-----------------------------------------------------------------------------
	Client Travel / Level Control
-----------------------------------------------------------------------------*/

event PreClientTravel()
{
}

native event ClientTravel( string URL, ETravelType TravelType, bool bItems );

native(546) final function UpdateURL(string NewOption, string NewValue, bool bSaveDefault);

native final function string GetDefaultURL(string Option);

native final function LevelInfo GetEntryLevel();

exec function RestartLevel()
{
	if ( bAdmin || Level.Netmode==NM_Standalone && !PlayerReplicationInfo.bIsSpectator )
		ClientTravel( "?restart", TRAVEL_Relative, false );
}

exec function LocalTravel( string URL )
{
	if( bAdmin || Level.Netmode==NM_Standalone )
		ClientTravel( URL, TRAVEL_Relative, true );
}

event TravelPostAccept()
{
	if ( Health <= 0 )
		Health = Default.Health;
}

function ServerReStartGame()
{
	Level.Game.RestartGame();
}

exec function SwitchLevel( string URL )
{
	if( bAdmin || Level.NetMode==NM_Standalone || Level.netMode==NM_ListenServer )
		Level.ServerTravel( URL, false );
}

exec function SwitchCoopLevel( string URL )
{
	if( bAdmin || Level.NetMode==NM_Standalone || Level.netMode==NM_ListenServer )
		Level.ServerTravel( URL, true );
}




/*-----------------------------------------------------------------------------
	Console / Clipboard
-----------------------------------------------------------------------------*/

native function string ConsoleCommand( string Command, optional bool bAllowExecFuncs, optional bool bExecsOnly );

native function CopyToClipboard( string Text );

native function string PasteFromClipboard();

function Typing( bool bTyping )
{
	bIsTyping = bTyping;
	if (bTyping)
		PlayChatting();
}




/*-----------------------------------------------------------------------------
	Render / Overlays
-----------------------------------------------------------------------------*/

exec function AIHUD()
{
	local name ClassName;
	local class<HUD> NewHUD;

	if( HUDType == Level.Game.HUDType )
	{
		NewHUD = class<HUD>( DynamicLoadObject( "dnAI.AIDebugHUD", class'Class' ) );
		HUDType = NewHUD;
		MyHUD.Destroy();
		MyHUD = Spawn( NewHUD, self );
	}
	else
	{
		MyHUD.Destroy();
		HUDType = Level.Game.HUDType;
		SpawnHUD();
	}
}

function SpawnHUD()
{
    MyHUD = spawn(HUDType, self);
    Log( "Attaching HUD:"$HUDType );
}

function SpawnScoreboard( Canvas C )
{
    scoreboard = spawn(ScoreboardType, self);
	scoreboard.CreateScoreboardWindow( C );
    Log( "Attaching Scoreboard:"$ScoreboardType );
}

event PreRender( canvas Canvas )
{
	if ( MyHUD != None )
        MyHUD.PreRender(Canvas);
	else if ( (Viewport(Player) != None) && (HUDType != None) )
        SpawnHUD();

	if ( Scoreboard != None )
        Scoreboard.PreRender(Canvas);
	else if ( (Viewport(Player) != None) && (ScoreboardType != None) )
        SpawnScoreboard( Canvas );
}

event PostRender( canvas Canvas )
{
	local Texture t;
	local actor a;
	local projectile pr;
	local TriggerPortal tp;
	local int y;
	local SoftParticleSystem p;
	local int i,j,k;
	local float XL, YL;
	local MeshInstance minst;

	if ( bFirstDraw )
		bFirstDraw = false;
	
	// Draw trigger portals.
	for ( tp=Level.TriggerPortals; tp!=none; tp=tp.NextTriggerPortal )
		tp.DrawTriggerPortal( Canvas );

	// Draw particle systems.
	for ( p=Level.ParticleSystems; p!=none; p=p.NextSystem )
		if ( !p.BSPOcclude )
			p.DrawParticles( Canvas );

	// Draw the logo.
	if ( ShowLogo )
	{
		t = Texture'S_DNFLogo';
		Canvas.SetPos( Canvas.ClipX-t.USize, (Canvas.ClipY-t.VSize)+(128-110) );
		Canvas.DrawIcon( t, 1 );
	}

	// Draw the HUD.
	if ( MyHUD != None )
		MyHUD.PostRender( Canvas );
	else if ( (Viewport(Player) != None) && (HUDType != None) )
		SpawnHUD();
	
	// Spawn Scoreboard
	if ( Scoreboard != None )
		Scoreboard.PostRender( Canvas );
	else if ( (Viewport(Player) != None) && (ScoreboardType != None) )
		SpawnScoreboard( Canvas );

	// Render debug view.
    if ( (MyDebugView != None) && (DebugView(MyDebugView) != None) && (!MyDebugView.bHidden) )
        DebugView(MyDebugView).PostRender( Canvas );

    DebugPostRender( Canvas );
}

simulated event RenderOverlays( canvas C )
{
	if ( CameraStyle != PCS_ZoomMode )
	{
        if ( Weapon != None )
			Weapon.RenderOverlays(C);

		if ( MyHUD != None )
			MyHUD.RenderOverlays(C);

		if ( UsedItem != None )
			UsedItem.RenderOverlays(C);

		if ( ShieldItem != None )
			ShieldItem.RenderOverlays(C);
	}
}

function ShowDeathSequence()
{
}



/*-----------------------------------------------------------------------------
	Networking / Administration
-----------------------------------------------------------------------------*/

native final function string GetPlayerNetworkAddress();

exec function Admin( string CommandLine )
{
	local string Result;
	if( bAdmin )
		Result = ConsoleCommand( CommandLine );
	if( Result!="" )
		ClientMessage( Result );
}

exec function AdminLogin( string Password )
{
	Level.Game.AdminLogin( Self, Password );
}

exec function AdminLogout()
{
	Level.Game.AdminLogout( Self );
}

exec function Kick( string S ) 
{
	local Pawn aPawn;
	if( !bAdmin )
		return;
	for( aPawn=Level.PawnList; aPawn!=None; aPawn=aPawn.NextPawn )
		if
		(	aPawn.bIsPlayer
			&&	aPawn.PlayerReplicationInfo.PlayerName~=S 
			&&	(PlayerPawn(aPawn)==None || NetConnection(PlayerPawn(aPawn).Player)!=None ) )
		{
			aPawn.Destroy();
			return;
		}
}

exec function KickBan( string S ) 
{
	local Pawn aPawn;
	local string IP;
	local int j;
	if( !bAdmin )
		return;
	for( aPawn=Level.PawnList; aPawn!=None; aPawn=aPawn.NextPawn )
		if
		(	aPawn.bIsPlayer
			&&	aPawn.PlayerReplicationInfo.PlayerName~=S 
			&&	(PlayerPawn(aPawn)==None || NetConnection(PlayerPawn(aPawn).Player)!=None ) )
		{
			IP = PlayerPawn(aPawn).GetPlayerNetworkAddress();
			if(Level.Game.CheckIPPolicy(IP))
			{
				IP = Left(IP, InStr(IP, ":"));
				Log("Adding IP Ban for: "$IP);
				for(j=0;j<50;j++)
					if(Level.Game.IPPolicies[j] == "")
						break;
				if(j < 50)
					Level.Game.IPPolicies[j] = "DENY,"$IP;
				Level.Game.SaveConfig();
			}
			aPawn.Destroy();
			return;
		}
}

exec function Ping()
{
	ClientMessage("Current ping is"@PlayerReplicationInfo.Ping);
}

exec function PlayerList()
{
	local PlayerReplicationInfo PRI;

	log("Player List:");
	ForEach AllActors(class'PlayerReplicationInfo', PRI)
		log(PRI.PlayerName@"( ping"@PRI.Ping$")");
}

final function ReplaceText(out string Text, string Replace, string With)
{
	local int i;
	local string Input;
		
	Input = Text;
	Text = "";
	i = InStr(Input, Replace);
	while(i != -1)
	{	
		Text = Text $ Left(Input, i) $ With;
		Input = Mid(Input, i + Len(Replace));	
		i = InStr(Input, Replace);
	}
	Text = Text $ Input;
}

exec function SetName( coerce string S )
{
	if ( Len(S) > 28 )
		S = left(S,28);
	ChangeName(S);
	UpdateURL("Name", S, true);
	SaveConfig();
}

exec function Name( coerce string S )
{
	SetName(S);
}

function ChangeName( coerce string S )
{
	if ( Len(S) > 28 )
		S = left(S,28);

	Level.Game.ChangeName( self, S, false );
}

function ChangeTeam( int N )
{
	local int OldTeam;
	local string NewClass;

	if ( PlayerReplicationInfo.bIsSpectator ) // Spectator
	{
		Level.Game.ChangeTeam( self, N );
	}
	else
	{
		OldTeam = PlayerReplicationInfo.Team;
		
		Level.Game.ChangeTeam(self, N);

		if ( Level.Game.bTeamGame && ( PlayerReplicationInfo.Team != OldTeam ) && !IsSpectating() )
		{			
			// Check to see if we should do a class change when we change teams
			if ( Level.Game.bOverridePlayerClass )
			{
				NewClass = Level.Game.GetOverridePlayerClassName( PlayerReplicationInfo.Team );
				
				if ( NewClass != "" )
				{
					ServerChangeClass( NewClass, true );
					return;
				}
			}

			// Kill us if we're still alive so we can respawn on the other team
			Died( None, class'CrushingDamage', Location );
		}
	}
}

function ClientChangeTeam( int N )
{
	local Pawn P;
		
	if ( PlayerReplicationInfo != None )
		PlayerReplicationInfo.Team = N;

	// If listen server, this may be called for non-local players that are logging in.
	// If so, don't update URL.
	if ( (Level.NetMode == NM_ListenServer) && (Player == None) )
	{
		// check if any other players exist
		for ( P=Level.PawnList; P!=None; P=P.NextPawn )
			if ( P.IsA('PlayerPawn') && (ViewPort(PlayerPawn(P).Player) != None) )
				return;
	}
		
	UpdateURL( "Team",string(N), true );	
}

function ServerRestartPlayer( optional bool force )
{
    // Put any stuff that needs to happen to player when they get restarted here:
    KillSOSPowers();

	// Tell clients to remove decals
	ClientDestroyDecals();

	if ( Level.NetMode == NM_Standalone )
		Level.Game.SetGameSpeed( 1.0 );

	if ( GetControlState() == CS_Dead || force )
	{        
		if ( Level.NetMode == NM_Client )
			return;

		if ( Level.Game.RestartPlayer(Self) )
		{
			ServerTimeStamp     = 0;
			TimeMargin          = 0;
			Enemy               = None;
			RotateToDesiredView = false;

			// Undo the effects of shrinking.
			UnShrink();

            if ( DeathCarcass != None )
            {
                DeathCarcass.bOwnerGetFrameOnly = false;
                DeathCarcass                    = None;
            }

			Level.Game.StartPlayer( Self );

            if ( Mesh != None )
				PlayWaiting();
			
            ClientRestart();
		}
        else
        {
            Log( "Level.Game.RestartPlayer() in PlayerPawn::ServerRestartPlayer returned false" );
        }
	}
    else
    {
        Log( "Tried to restart player that was not in CS_Dead state.  Current State is:"$GetControlStateString() );
    }
}

// NJS: A quick little hack to allow programmers to communicate with dukenet directly.
exec function DukeNet( string CommandString )
{
	local DukeNet d;
	
	ForEach AllActors(class'Dukenet', d)
		d.dncCommand(CommandString);

	d=none;
}

function bool KeyType( EInputKey Key )
{
	if (KeyEventHookActor != None)
		return KeyEventHookActor.KeyType(Key);

	return false;
}

function bool KeyEvent( EInputKey Key, EInputAction Action, FLOAT Delta )
{
	// give the KeyEventHookActor a chance to intercept the keyboard
	if (KeyEventHookActor != None)
		return KeyEventHookActor.KeyEvent(Key, Action, Delta);
		
	return false;		// Don't handle by default, let the console get it
}

/*-----------------------------------------------------------------------------
	Input
-----------------------------------------------------------------------------*/

native(544) final function ResetKeyboard();

event PlayerInput( float DeltaTime )
{
	local float SmoothTime, FOVScale, MouseScale, SmoothMouseX, SmoothMouseY;

    // CDH...
//    if (Weapon != None)
  //      Weapon.HandlePlayerInput(DeltaTime);
    // ...CDH

	if ( bEatInput )
	{
		aForward = 0;
		aTurn	 = 0.0;
		aStrafe  = 0;
		aLookup  = 0.0;
		return;
	}

	if ( bDelayedCommand )
	{
		bDelayedCommand = false;
		ConsoleCommand(DelayedCommand);
	}
				
	// Check for Dodge move
	// flag transitions
	bEdgeForward = (bWasForward ^^ (aBaseY > 0));
	bEdgeBack = (bWasBack ^^ (aBaseY < 0));
	bEdgeLeft = (bWasLeft ^^ (aStrafe > 0));
	bEdgeRight = (bWasRight ^^ (aStrafe < 0));
	bWasForward = (aBaseY > 0);
	bWasBack = (aBaseY < 0);
	bWasLeft = (aStrafe > 0);
	bWasRight = (aStrafe < 0);
	
	bEdgeTurnLeft = (bWasTurnLeft ^^ (aBaseX > 0));
	bEdgeTurnRight = (bWasTurnRight ^^ (aBaseX < 0));
	
	bWasTurnLeft = (aBaseX > 0);   // NJS
	bWasTurnRight= (aBaseX < 0);   // NJS

	// Smooth and amplify mouse movement
	FOVScale = DesiredFOV * 0.01111; 
	MouseScale = MouseSensitivity * FOVScale * 5;
	SmoothMouseX = aMouseX * MouseScale * 0.005;
	SmoothMouseY = aMouseY * MouseScale * 0.005;
	aMouseX = 0;
	aMouseY = 0;

	// adjust keyboard and joystick movements
	aLookUp *= FOVScale;
	aTurn   *= FOVScale;

	// Remap raw x-axis movement.
	if( bStrafe!=0 )
	{
		// Strafe.
		aStrafe += aBaseX + SmoothMouseX;
		aBaseX   = 0;
	}
	else
	{
		// Forward.
		aTurn  += aBaseX * FOVScale + SmoothMouseX;
		aBaseX  = 0;
	}

	// Remap mouse y-axis movement.
	if( (bStrafe == 0) && (bAlwaysMouseLook || (bLook!=0)) )
	{
		// Look up/down.
		if ( bInvertMouse )
			aLookUp -= SmoothMouseY;
		else
			aLookUp += SmoothMouseY;
	}
	else
	{
		// Move forward/backward.
		aForward += SmoothMouseY;
	}

	if ( bSnapLevel != 0 )
	{
		bCenterView = true;
		bKeyboardLook = false;
	}
	else if (aLookUp != 0)
	{
		bCenterView = false;
		bKeyboardLook = true;
	}
	else if ( bSnapToLevel && !bAlwaysMouseLook )
	{
		bCenterView = true;
		bKeyboardLook = false;
	}

	// Remap other y-axis movement.
	if ( bFreeLook != 0 )
	{
		bKeyboardLook = true;
		aLookUp += 0.5 * aBaseY * FOVScale;
	}
	else
		aForward += aBaseY;

	aBaseY = 0;

	LastLookUp = aLookUp;
	LastTurn = aTurn;

	// If I have an input hook actor, send my input down the pipe:
	if ( InputHookActor != none )
		InputHookActor.InputHook( aForward, aLookUp, aTurn, aStrafe, DeltaTime );
	else if ( ViewMapper != none )
		ViewMapper.InputHook( aForward, aLookUp, aTurn, aStrafe, DeltaTime );

	// NJS: Handle control remapping:
	if(bUseRemappedEvents)
	{
		// Handle the forward event:
		if(MoveForwardEvent!=''||MoveForwardEventEnd!='')
		{
			if(bMoveForwardContinuous)
			{
				if(bEdgeForward)
				{
					if(!bWasForward)
						GlobalTrigger(MoveForwardEventEnd);
				} else if(bWasForward)
					GlobalTrigger(MoveForwardEvent);
			} else 
			{
				if(bEdgeForward)
				{
					if(bWasForward) GlobalTrigger(MoveForwardEvent);
					else 			 
					{
						GlobalUntrigger(MoveForwardEvent);
						GlobalTrigger(MoveForwardEventEnd);
					}
				}
			}
		} 
		
		// Handle backward event:
		if(MoveBackwardEvent!=''||MoveBackwardEventEnd!='')
		{
			if(bMoveBackwardContinuous)
			{
				if(bEdgeBack)
				{
					if(!bWasBack)
						GlobalTrigger(MoveBackwardEventEnd);
				} else if(bWasBack)
					GlobalTrigger(MoveBackwardEvent);
			} else
			{
				if(bEdgeBack)
				{
					if(bWasBack) GlobalTrigger(MoveBackwardEvent);
					else 		  
					{
						GlobalUntrigger(MoveBackwardEvent);
						GlobalTrigger(MoveBackwardEventEnd);
					}
				}
			}
		}
		
		// Handle strafe left event:
		if(StrafeLeftEvent!=''||StrafeLeftEventEnd!='')
		{
			if(bStrafeLeftContinuous)
			{
				if(bEdgeLeft)
				{
					if(!bWasLeft)
						GlobalTrigger(StrafeLeftEventEnd);
				} else if(bWasLeft)
					GlobalTrigger(StrafeLeftEvent);
			} else
			{
				if(bEdgeLeft)
				{
					if(bWasLeft) GlobalTrigger(StrafeLeftEvent);
					else 		  
					{
						GlobalUntrigger(StrafeLeftEvent);
						GlobalTrigger(StrafeLeftEventEnd);
					}
				}
			}
		}

		// Handle strafe right event:
		if(StrafeRightEvent!=''||StrafeRightEventEnd!='')
		{
			if(bStrafeRightContinuous)
			{
				if(bEdgeRight)
				{
					if(!bWasRight)
						GlobalTrigger(StrafeRightEventEnd);
				} else if(bWasRight)
					GlobalTrigger(StrafeRightEvent);
			} else
			{
				if(bEdgeRight)
				{
					if(bWasRight) GlobalTrigger(StrafeRightEvent);
					else 		   
					{
						GlobalUntrigger(StrafeRightEvent);
						GlobalTrigger(StrafeRightEventEnd);
					}
				}
			}
		}
		
		// Handle turning left:
		if(TurnLeftEvent!=''||TurnLeftEventEnd!='')
		{
			if(bTurnLeftContinuous)
			{
				if(bEdgeTurnLeft)
				{
					if(!bWasTurnLeft)
						GlobalTrigger(TurnLeftEventEnd);
				} else if(bWasTurnLeft)
					GlobalTrigger(TurnLeftEvent);				
			} else
			{
				if(bEdgeTurnLeft)
				{
					if(bWasTurnLeft) GlobalTrigger(TurnLeftEvent);
					else
					{
						GlobalUntrigger(TurnLeftEvent);
						GlobalTrigger(TurnLeftEventEnd);
					}
				}
			}
		}

		// Handle turning right:
		if(TurnRightEvent!=''||TurnRightEventEnd!='')
		{
			if(bTurnRightContinuous)
			{
				if(bEdgeTurnRight)
				{
					if(!bWasTurnRight)
						GlobalTrigger(TurnRightEventEnd);
						
				} else if(bWasTurnRight)
					GlobalTrigger(TurnRightEvent);
			} else
			{
				if(bEdgeTurnRight)
				{
					if(bWasTurnRight) GlobalTrigger(TurnRightEvent);
					else			   
					{
						GlobalUntrigger(TurnRightEvent);
						GlobalTrigger(TurnRightEventEnd);
					}
				}
			}
		}
		
		// Handle continuous firing:
		if((FireEvent!='')&&bFireContinuous&&bool(bFireDown))
			GlobalTrigger(FireEvent);

		// Handle continuous alt firing:
		if((AltFireEvent!='')&&bAltFireContinuous&&bool(bAltFireDown))
			GlobalTrigger(AltFireEvent);

		// Possibly lock the view to a certain direction:
		if(bLockRotation)
		{
			//ClientSetRotation(RotationLockDirection);
			SetRotation(RotationLockDirection);
			ViewRotation=RotationLockDirection;
			aForward=0;
			aLookUp=0;
			aTurn=0;
			aStrafe=0;
		}

		// Ignore movement computations:
		aStrafe=0;
		aForward=0;
		return;
	}
	// ... NJS

	// Twist the camera for lateral motion:
	ViewRotation.Roll+=(aStrafe*DeltaTime);	// NJS: Rolly Polly!
											// BR: God dammit Nick, stop putting gay comments in the code. ;)

	// Handle walking.
	HandleWalking();
}

// NJS: Disable mouse when player is using inventory.
function InputHook(out float aForward,out float aLookUp,out float aTurn,out float aStrafe,optional float DeltaTime)
{
	if(Player.console.MouseCapture)
	{
		aLookUp=0;
		aTurn=0;
	}
}

exec function AlwaysMouseLook( Bool B )
{
	ChangeAlwaysMouseLook(B);
	SaveConfig();
}

function ChangeAlwaysMouseLook(Bool B)
{
	bAlwaysMouseLook = B;
	if ( bAlwaysMouseLook )
		bLookUpStairs = false;
}
	
exec function SetMouseSmoothThreshold( float F )
{
	MouseSmoothThreshold = FClamp(F, 0, 0.1);
	SaveConfig();
}

exec function SetMaxMouseSmoothing( bool B )
{
	bMaxMouseSmoothing = B;
	SaveConfig();
}

exec function InvertMouse( bool B )
{
	bInvertMouse = B;
	SaveConfig();
}

exec function SetSensitivity(float F)
{
	UpdateSensitivity(F);
	SaveConfig();
}

function UpdateSensitivity(float F)
{
	MouseSensitivity = FMax(0,F);
}

exec function SetAutoAim( float F )
{
	ChangeAutoAim(F);
	SaveConfig();
}

function ChangeAutoAim( float F )
{
	MyAutoAim = FMax(Level.Game.AutoAim, F);
}

function rotator AdjustAim(float projSpeed, vector projStart, int aimerror, bool bLeadTarget, bool bWarnTarget)
{
	local vector FireDir, AimSpot, HitNormal, HitLocation;
	local actor BestTarget;
	local float bestAim, bestDist;
	local actor HitActor;
	
	FireDir = vector(ViewRotation);
	HitActor = Trace(HitLocation, HitNormal, projStart + 4000 * FireDir, projStart, true);
	if ( (HitActor != None) && HitActor.bProjTarget )
	{
		if ( bWarnTarget && HitActor.bIsPawn )
			Pawn(HitActor).WarnTarget(self, projSpeed, FireDir);
		return ViewRotation;
	}

	bestAim = FMin(0.93, MyAutoAim);
	BestTarget = PickTarget(bestAim, bestDist, FireDir, projStart);

	if ( bWarnTarget && (Pawn(BestTarget) != None) )
		Pawn(BestTarget).WarnTarget(self, projSpeed, FireDir);	

	if ( (Level.NetMode != NM_Standalone) || (Level.Game.Difficulty > 2) 
		|| bAlwaysMouseLook || ((BestTarget != None) && (bestAim < MyAutoAim)) || (MyAutoAim >= 1) )
		return ViewRotation;
	
	if ( BestTarget == None )
	{
		bestAim = MyAutoAim;
		BestTarget = PickAnyTarget(bestAim, bestDist, FireDir, projStart);
		if ( BestTarget == None )
			return ViewRotation;
	}

	AimSpot = projStart + FireDir * bestDist;
	AimSpot.Z = BestTarget.Location.Z + 0.3 * BestTarget.CollisionHeight;

	return rotator(AimSpot - projStart);
}




/*-----------------------------------------------------------------------------
	Camera
-----------------------------------------------------------------------------*/

exec function FOV(float F)
{
	SetDesiredFOV(F);
}

exec function FOVScale(float F)
{
	FOVTimeScale = F;
}
	
exec function SetDesiredFOV(float F)
{
	if( (F >= 80.0) || Level.bAllowFOV || bAdmin || (Level.Netmode==NM_Standalone) )
	{
		DefaultFOV = FClamp(F, 1, 170);
		DesiredFOV = DefaultFOV;
		SaveConfig();
	}
}

function SetFOVAngle(float newFOV)
{
	FOVAngle = newFOV;
}
	 
function ClientFlash( float scale, vector fog )
{
	DesiredFlashScale = scale;
	DesiredFlashFog = 0.001 * fog;
}

function ClientInstantFlash( float scale, vector fog )
{
	InstantFlash = scale;
	InstantFog = 0.001 * fog;
}


function ClientAdjustGlow( float scale, vector fog )
{
	ConstantGlowScale += scale;
	ConstantGlowFog += 0.001 * fog;
}

function ClientShake(vector shake)
{
	if ( (shakemag < shake.X) || (shaketimer <= 0.01 * shake.Y) )
	{
		shakemag = shake.X;
		shaketimer = 0.01 * shake.Y;	
		maxshake = 0.01 * shake.Z;
		verttimer = 0;
		ShakeVert = -1.1 * maxshake;
	}
}

function ShakeView( float shaketime, float RollMag, float vertmag)
{
	local vector shake;

	shake.X = RollMag;
	shake.Y = 100 * shaketime;
	shake.Z = 100 * vertmag;
	ClientShake(shake);
}

simulated function WeaponShake()
{
	WeapShakeOffset = 4;
}

exec function SetViewFlash(bool B)
{
	bNoFlash = !B;
}

function ViewFlash(float DeltaTime)
{
	local vector goalFog;
	local float goalscale, delta;
	local vector headFog;
	local float HeadScale;

	if ( bNoFlash )
	{
		InstantFlash = 0;
		InstantFog = vect(0,0,0);
	}

	// If we are viewing somebody, don't do any fog
	if ( PlayerPawn( ViewTarget ) != None && GetControlState() == CS_Stasis )
	{
		headFog    = vect(0,0,0);
		headScale  = 0;
	}
	else
	{
		headFog    = HeadRegion.Zone.ViewFog;
		headScale  = HeadRegion.Zone.ViewFlash.X;
	}

	delta = FMin(0.1, DeltaTime);
	goalScale			= 1 + DesiredFlashScale + ConstantGlowScale + headScale; 
	goalFog				= DesiredFlashFog + ConstantGlowFog + headFog;

	DesiredFlashScale	-= DesiredFlashScale * 2 * delta;  
	DesiredFlashFog		-= DesiredFlashFog * 2 * delta;

	FlashScale.X		+= (goalScale - FlashScale.X + InstantFlash) * 10 * delta;
	FlashFog			+= (goalFog - FlashFog + InstantFog) * 10 * delta;
	
	InstantFlash		= 0;
	InstantFog			= vect(0,0,0);

	if ( FlashScale.X > 0.981 )
		FlashScale.X = 1;

	FlashScale = FlashScale.X * vect(1,1,1);

	if ( FlashFog.X < 0.019 )
		FlashFog.X = 0;
	if ( FlashFog.Y < 0.019 )
		FlashFog.Y = 0;
	if ( FlashFog.Z < 0.019 )
		FlashFog.Z = 0;	
}

function ViewShake(float DeltaTime)
{
	if (shaketimer > 0.0) //shake view
	{
		shaketimer -= DeltaTime;
		if ( verttimer == 0 )
		{
			verttimer = 0.1;
			ShakeVert = -1.1 * maxshake;
		}
		else
		{
			verttimer -= DeltaTime;
			if ( verttimer < 0 )
			{
				verttimer = 0.2 * FRand();
				shakeVert = (2 * FRand() - 1) * maxshake;  
			}
		}
		ViewRotation.Roll = ViewRotation.Roll & 65535;
		if (bShakeDir)
		{
			ViewRotation.Roll += int( 10 * shakemag * FMin(0.1, DeltaTime));
			bShakeDir = (ViewRotation.Roll > 32768) || (ViewRotation.Roll < (0.5 + FRand()) * shakemag);
			if ( (ViewRotation.Roll < 32768) && (ViewRotation.Roll > 1.3 * shakemag) )
			{
				ViewRotation.Roll = 1.3 * shakemag;
				bShakeDir = false;
			}
			else if (FRand() < 3 * DeltaTime)
				bShakeDir = !bShakeDir;
		}
		else
		{
			ViewRotation.Roll -= int( 10 * shakemag * FMin(0.1, DeltaTime));
			bShakeDir = (ViewRotation.Roll > 32768) && (ViewRotation.Roll < 65535 - (0.5 + FRand()) * shakemag);
			if ( (ViewRotation.Roll > 32768) && (ViewRotation.Roll < 65535 - 1.3 * shakemag) )
			{
				ViewRotation.Roll = 65535 - 1.3 * shakemag;
				bShakeDir = true;
			}
			else if (FRand() < 3 * DeltaTime)
				bShakeDir = !bShakeDir;
		}
		ViewRotation.Roll = ViewRotation.Roll & 65535;
		if (ViewRotation.Roll < 32768)
		{
			if ( ViewRotation.Roll > 0 )
				ViewRotation.Roll = Max(0, ViewRotation.Roll - (Max(ViewRotation.Roll,500) * 10 * FMin(0.1,DeltaTime)));
		}
		else
		{
			ViewRotation.Roll += ((65536 - Max(500,ViewRotation.Roll)) * 10 * FMin(0.1,DeltaTime));
			if ( ViewRotation.Roll > 65534 )
				ViewRotation.Roll = 0;
		}
	}
	else
	{
		ShakeVert = 0;
		ViewRotation.Roll = ViewRotation.Roll & 65535;
		if (ViewRotation.Roll < 32768)
		{
			if ( ViewRotation.Roll > 0 )
				ViewRotation.Roll = Max(0, ViewRotation.Roll - (Max(ViewRotation.Roll,500) * 10 * FMin(0.1,DeltaTime)));
		}
		else
		{
			ViewRotation.Roll += ((65536 - Max(500,ViewRotation.Roll)) * 10 * FMin(0.1,DeltaTime));
			if ( ViewRotation.Roll > 65534 )
				ViewRotation.Roll = 0;
		}
	} 
}

exec function ViewPlayer( string S )
{
	local pawn P;

	for ( P=Level.pawnList; P!=None; P= P.NextPawn )
		if ( P.bIsPlayer && (P.PlayerReplicationInfo.PlayerName ~= S) )
			break;

	if ( (P != None) && Level.Game.CanSpectate(self, P) )
	{
		ClientMessage(ViewingFrom@P.PlayerReplicationInfo.PlayerName, 'Event', true);
		if ( P == self)
			ViewTarget = None;
		else
			ViewTarget = P;
	}
	else
		ClientMessage(FailedView);

	bBehindView = ( ViewTarget != None );
	if ( bBehindView )
		ViewTarget.BecomeViewTarget();
}

exec function CheatView( class<actor> aClass )
{
	local actor other, first;
	local bool bFound;

	if( !bCheatsEnabled )
		return;

	if( !bAdmin && Level.NetMode!=NM_Standalone )
		return;

	first = None;
	ForEach AllActors( aClass, other )
	{
		if ( (first == None) && (other != self) )
		{
			first = other;
			bFound = true;
		}
		if ( other == ViewTarget ) 
			first = None;
	}  

	if ( first != None )
	{
		if ( first.bIsPawn && Pawn(first).bIsPlayer && (Pawn(first).PlayerReplicationInfo.PlayerName != "") )
			ClientMessage(ViewingFrom@Pawn(first).PlayerReplicationInfo.PlayerName, 'Event', true);
		else
			ClientMessage(ViewingFrom@first, 'Event', true);
		ViewTarget = first;
	}
	else
	{
		if ( bFound )
			ClientMessage(ViewingFrom@OwnCamera, 'Event', true);
		else
			ClientMessage(FailedView, 'Event', true);
		ViewTarget = None;
	}

	bBehindView = ( ViewTarget != None );
	if ( bBehindView )
		ViewTarget.BecomeViewTarget();
}

exec function ViewSelf()
{
	bBehindView = false;
	Viewtarget = None;
	ClientMessage(ViewingFrom@OwnCamera, 'Event', true);
}

exec function ViewClass( class<actor> aClass, optional bool bQuiet )
{
	local actor other, first;
	local bool bFound;

	if( GetControlState() == CS_Stasis )
		return;
	if ( (Level.Game != None) && !Level.Game.bCanViewOthers )
		return;

	first = None;
	ForEach AllActors( aClass, other )
	{
		if ( (first == None) && (other != self)
			 && ( (bAdmin && Level.Game==None) || Level.Game.CanSpectate(self, other) ) )
		{
			first = other;
			bFound = true;
		}
		if ( other == ViewTarget ) 
			first = None;
	}  

	if ( first != None )
	{
		if ( !bQuiet )
		{
			if ( first.bIsPawn && Pawn(first).bIsPlayer && (Pawn(first).PlayerReplicationInfo.PlayerName != "") )
				ClientMessage(ViewingFrom@Pawn(first).PlayerReplicationInfo.PlayerName, 'Event', true);
			else
				ClientMessage(ViewingFrom@first, 'Event', true);
		}
		ViewTarget = first;
	}
	else
	{
		if ( !bQuiet )
		{
			if ( bFound )
				ClientMessage(ViewingFrom@OwnCamera, 'Event', true);
			else
				ClientMessage(FailedView, 'Event', true);
		}
		ViewTarget = None;
	}

	bBehindView = ( ViewTarget != None );
	if ( bBehindView )
		ViewTarget.BecomeViewTarget();
}

exec function BehindView()
{
	if ( IsSpectating() ) // Spectator
	{
		bBehindView = !bBehindView;	
		bChaseCam = bBehindView;

		if ( ViewTarget == None )
			bBehindView = false;
	}
	else
	{
		bBehindView = !bBehindView;
	}
}

function CalcBehindView(out vector CameraLocation, out rotator CameraRotation, float Dist)
{
	local vector View,HitLocation,HitNormal;
	local float ViewDist;

	CameraRotation = ViewRotation;
    //CameraRotation = Normalize(CameraRotation + rot(0,int(Level.TimeSeconds*16384.0) & 65535,0)); // CDH TEMP
	View = vect(1,0,0) >> CameraRotation;
	if( Trace( HitLocation, HitNormal, CameraLocation - (Dist + 30) * vector(CameraRotation), CameraLocation ) != None )
		ViewDist = FMin( (CameraLocation - HitLocation) Dot View, Dist );
	else
		ViewDist = Dist;
	CameraLocation -= (ViewDist - 30) * View; 
}

event PlayerCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
{
	local vector X, Y, Z;
	local Pawn PTarget;

	if ( GetControlState() == CS_Dead )
	{
		CalcDeadView( ViewActor, CameraLocation, CameraRotation );
		return;
	}

	if ( ViewMapper != None )
	{
		ViewActor = Self;
		ViewMapper.CalcView( CameraLocation, CameraRotation );
		return;
	}

	if ( ViewTarget != None )
	{
		ViewActor		= ViewTarget;
		CameraLocation	= ViewTarget.Location;
		CameraRotation	= ViewTarget.Rotation;		

		PTarget			= Pawn( ViewTarget );

		if ( PTarget != None )
		{
			if ( Level.NetMode == NM_Client )
			{
				if ( PTarget.bIsPlayer )
					PTarget.ViewRotation = TargetViewRotation;

				PTarget.EyeHeight = TargetEyeHeight;

				if ( PTarget.Weapon != None )
					PTarget.Weapon.PlayerViewOffset = TargetWeaponViewOffset;
			}
			
			if ( PTarget.bIsPlayer )
				CameraRotation = PTarget.ViewRotation;

			if ( !bBehindView )
				CameraLocation.Z += PTarget.EyeHeight;
		}

		if ( bBehindView )
			CalcBehindView( CameraLocation, CameraRotation, 180 );

		return;	
	}

	ViewActor      = Self;
	CameraLocation = Location+VibrationVector;

	if ( bBehindView ) //up and behind
	{
		CalcBehindView( CameraLocation, CameraRotation, 150 );
	}
	else
	{
		// First-person view.
		GetAxes( ViewRotation, X, Y, Z );
		CameraRotation		= ViewRotation;
		CameraLocation.Z	+= EyeHeight;
		CameraLocation		+= WalkBob;
		CameraLocation		-= X * WeapShakeOffset;
	}
}

function CalcDeadView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
{
	local int			bone;
	local vector		v;
	local MeshInstance	m;
	
	if ( Level.NetMode != NM_Standalone ) // 3rd person camera when dying for multiplayer
	{
		CameraRotation	= ViewRotation;
		DesiredFOV		= DefaultFOV;
		ViewActor		= self;

		if ( ViewTarget != None )
		{
			ViewActor		= ViewTarget;
			CameraLocation	= ViewTarget.Location;
			CameraRotation	= ViewTarget.Rotation;
			CalcBehindView( CameraLocation, CameraRotation, 180 );
		}
		else
		{
			CalcBehindView( CameraLocation, CameraRotation, 180 );
		}

		return;	
	}

	// First-person death view in Single Player
	if ( DeathCarcass != None )
	{
		if ( DeathCarcass.IsChunk() )
		{
			CameraLocation = DeathCarcass.Location;
			CameraRotation = DeathCarcass.Rotation;
			return;
		}
		m = DeathCarcass.GetMeshInstance();
        if ( m == None )
			return;
		bone = m.BoneFindNamed( 'head' );

		v = m.BoneGetScale( bone, true, false );
		if ( v == vect(0,0,0) )
		{
			DeathCarcass = DeathCarcass.GetChunk();
			CameraLocation = DeathCarcass.Location;
			CameraRotation = DeathCarcass.Rotation;
			return;
		}

		CameraRotation = m.BoneGetRotate( bone, true, false );
		CameraRotation = m.MeshToWorldRotation( CameraRotation );
		CameraLocation = m.BoneGetTranslate( bone, true, false );
		CameraLocation = m.MeshToWorldLocation( CameraLocation );
	}
	if ( PendingDeathCarcass != None )
	{
		DeathCarcass = PendingDeathCarcass;
		PendingDeathCarcass = None;
	}
}

function FindGoodView()
{
	local vector cameraLoc;
	local rotator cameraRot;
	local int tries, besttry;
	local float bestdist, newdist;
	local int startYaw;
	local actor ViewActor;
		
	if (GetControlState() != CS_Dead)
		return;

	//fixme - try to pick view with killer visible
	//fixme - also try varying starting pitch
	////log("Find good death scene view");
	ViewRotation.Pitch = 56000;
	tries = 0;
	besttry = 0;
	bestdist = 0.0;
	startYaw = ViewRotation.Yaw;
		
	for (tries=0; tries<16; tries++)
	{
		cameraLoc = Location;
		PlayerCalcView(ViewActor, cameraLoc, cameraRot);
		newdist = VSize(cameraLoc - Location);
		if (newdist > bestdist)
		{
			bestdist = newdist;	
			besttry = tries;
		}
		ViewRotation.Yaw += 4096;
	}
			
	ViewRotation.Yaw = startYaw + besttry * 4096;
}
	
function InterpolateCollisionHeight()
{
    local vector LocationAdjust;
    local float StartHeight, EndHeight, HeightChange;

	if (CollisionHeightStartTime > 0)
	{
		CollisionHeightTime = 0.25/3*2;

		if ( Level.TimeSeconds - CollisionHeightStartTime >= CollisionHeightTime )
		{
			// We have interpolated the full time.
			SetCollisionSize( CollisionRadius, DestinationCollisionHeight );
			CollisionHeightStartTime = 0;
		} 
        else
        {
			// We need to interpolate.
			StartHeight = CollisionHeight;
			SetCollisionSize( CollisionRadius,
				Lerp( (Level.TimeSeconds - CollisionHeightStartTime) / CollisionHeightTime,
				OriginalCollisionHeight, DestinationCollisionHeight )
			);
			
            EndHeight = CollisionHeight;
			HeightChange = EndHeight - StartHeight;

			if (GetPostureState() != PS_Jumping)
			{
				LocationAdjust = Location;
				LocationAdjust.Z += HeightChange;
				SetLocation(LocationAdjust);
			}
		}
	}
}

event UpdateEyeHeight(float DeltaTime)
{
	local float smooth, bound;	

	if (GetControlState() == CS_Swimming)
	{
		// Smooth up/down stairs
		if( !bJustLanded )
		{
			smooth = FMin(1.0, 10.0 * DeltaTime/Level.TimeDilation);
			EyeHeight = (EyeHeight - Location.Z + OldLocation.Z) * (1 - smooth) + ( ShakeVert + BaseEyeHeight) * smooth;
			bound = -0.5 * default.CollisionHeight;
			if (EyeHeight < bound)
            {
				EyeHeight = bound;
            }
			else
			{
				bound = default.CollisionHeight + FClamp((OldLocation.Z - Location.Z), 0.0, MaxStepHeight); 
				 if ( EyeHeight > bound )
					EyeHeight = bound;
			}
		}
		else
		{
			smooth = FClamp(10.0 * DeltaTime/Level.TimeDilation, 0.35, 1.0);
			bJustLanded = false;
			EyeHeight = EyeHeight * ( 1 - smooth) + (BaseEyeHeight + ShakeVert) * smooth;
		}

        InterpolateCollisionHeight();
	} 
    else
    {
		if (DontUpdateEyeHeight) 
			return;

		smooth = FMin(1.0, 13.0 * DeltaTime/Level.TimeDilation);
		smooth *= EyeSmoothScale;

        InterpolateCollisionHeight();

		// Smooth up/down stairs.
		if ( (Physics==PHYS_Walking) && !bJustLanded )
		{
			EyeHeight = (EyeHeight - Location.Z + OldLocation.Z) * (1 - smooth) + (ShakeVert + BaseEyeHeight) * smooth;
		
			bound = -0.5 * default.CollisionHeight;
			if (EyeHeight < bound)
            {
				EyeHeight = bound;
            }
			else
			{
				bound = default.CollisionHeight + FMin(FMax(0.0,(OldLocation.Z - Location.Z)), MaxStepHeight); 
				 if ( EyeHeight > bound )
					EyeHeight = bound;
			}
		} 
        else
        {
			smooth = FMax(smooth, 0.35); 		
			bJustLanded = false;
			EyeHeight = EyeHeight * ( 1 - smooth) + (BaseEyeHeight + ShakeVert) * smooth;
		}
	}

	// Teleporters affect your FOV, so adjust it back down.
	if ( FOVAngle != DesiredFOV )
	{
		if ( FOVAngle > DesiredFOV )
			FOVAngle = FOVAngle - FMax(7, 0.002 * DeltaTime * (FOVAngle - DesiredFOV) * FOVTimeScale); 
		else 
			FOVAngle = FOVAngle - FMin(-7, 0.002 * DeltaTime * (FOVAngle - DesiredFOV)  * FOVTimeScale);
		if ( Abs(FOVAngle - DesiredFOV) <= 10 )
			FOVAngle = DesiredFOV;
	}
}

exec function SetBob(float F)
{
	UpdateBob(F);
	SaveConfig();
}

function UpdateBob(float F)
{
	Bob = FClamp(F,0,0.032);
}

exec function SnapView( bool B )
{
	ChangeSnapView(B);
	SaveConfig();
}

function ChangeSnapView( bool B )
{
	bSnapToLevel = B;
}

exec function StairLook( bool B )
{
	ChangeStairLook(B);
	SaveConfig();
}

function ChangeStairLook( bool B )
{
	bLookUpStairs = B;
	if ( bLookUpStairs )
		bAlwaysMouseLook = false;
}

exec function ViewPlayerNum(optional int num)
{
	local Pawn P;

	if( GetControlState() == CS_Stasis )
		return;

	if ( !IsSpectating() && !Level.Game.bTeamGame )
		return;

	if ( num >= 0 )
	{
		P = Pawn(ViewTarget);
		if ( (P != None) && P.bIsPlayer && (P.PlayerReplicationInfo.TeamID == num) )
		{
			ViewTarget = None;
			bBehindView = false;
			return;
		}
		for ( P=Level.PawnList; P!=None; P=P.NextPawn )
			if ( P.bIsPlayer && (P.PlayerReplicationInfo.Team == PlayerReplicationInfo.Team)
				&& !P.PlayerReplicationInfo.bIsSpectator
				&& (P.PlayerReplicationInfo.TeamID == num) )
			{
				if ( P != self )
				{
					ViewTarget = P;
					bBehindView = true;
				}
				return;
			}
		return;
	}
	if ( Role == ROLE_Authority )
	{
		ViewClass( class'Pawn', true );
		While ( (ViewTarget != None) 
				&& (!Pawn(ViewTarget).bIsPlayer || Pawn(ViewTarget).PlayerReplicationInfo.bIsSpectator) )
			ViewClass(class'Pawn', true);

		if ( ViewTarget != None )
			ClientMessage(ViewingFrom@Pawn(ViewTarget).PlayerReplicationInfo.PlayerName, 'Event', true);
		else
			ClientMessage(ViewingFrom@OwnCamera, 'Event', true);
	}
}




/*-----------------------------------------------------------------------------
	Audio
-----------------------------------------------------------------------------*/

simulated function ClientPlaySound(sound ASound, optional bool bInterrupt, optional bool bVolumeControl )
{		
	local actor SoundPlayer;

	LastPlaySound = Level.TimeSeconds;	// so voice messages won't overlap
	if ( ViewTarget != None )
		SoundPlayer = ViewTarget;
	else
		SoundPlayer = self;

	SoundPlayer.PlaySound(ASound, SLOT_None, 16.0, bInterrupt);
	SoundPlayer.PlaySound(ASound, SLOT_Interface, 16.0, bInterrupt);
	SoundPlayer.PlaySound(ASound, SLOT_Misc, 16.0, bInterrupt);
	SoundPlayer.PlaySound(ASound, SLOT_Talk, 16.0, bInterrupt);
}

function ClientPlayPainSound( class<DamageType> DamageType )
{
}

simulated function ClientReliablePlaySound(sound ASound, optional bool bInterrupt, optional bool bVolumeControl )
{
	ClientPlaySound(ASound, bInterrupt, bVolumeControl);
}

function ClientSetMusic( music NewSong, byte NewSection, byte NewCdTrack, EMusicTransition NewTransition )
{
	Song        = NewSong;
	SongSection = NewSection;
	CdTrack     = NewCdTrack;
	Transition  = NewTransition;
}

simulated function PlayBeepSound();

exec function Speak(string Stuff)
{
	SpeakText(Stuff);
}




/*-----------------------------------------------------------------------------
	Game Control
-----------------------------------------------------------------------------*/

exec function QuickSave()
{
	local texture		SCTexture;

	if ( (Health > 0) 
		&& (Level.NetMode == NM_Standalone)
		&& !Level.Game.bDeathMatch )
	{
		//ClientMessage(QuickSaveString);
		//ConsoleCommand("SaveGame 9");
		SCTexture = Screenshot(true);
		SaveGame(SAVE_Quick, -1, Level.LocationName, SCTexture);
	}
}

/*	// Implemented in DukeConsole now
exec function QuickLoad()
{
	if ( (Level.NetMode == NM_Standalone) && !Level.Game.bDeathMatch )
	{
		LoadGame(SAVE_Quick, -1);			// the -1 means load the last saved of this type
		//ClientTravel( "?load=9", TRAVEL_Absolute, false);
	}
}
*/

function bool SetPause( BOOL bPause )
{
	return Level.Game.SetPause(bPause, self);
}

exec function Pause()
{
	if( !SetPause(Level.Pauser=="") )
		ClientMessage(NoPauseMessage);
}

/*-----------------------------------------------------------------------------
	Skin, Mesh, and Sounds
-----------------------------------------------------------------------------*/
function ServerChangeMesh( string MeshName )
{
    local Mesh NewMesh;

    if ( MeshName == "" )
        return;

    NewMesh = Mesh( DynamicLoadObject( MeshName, class'DukeMesh' ) );
	
    if( NewMesh != None )
    {
        Mesh = NewMesh;
        ClearAnimationChannels();
        PlayWaiting();
    }   
    else
    {
        ClientMessage( "Couldn't Change Mesh to"@MeshName );
    }
}

function ServerChangeVoice( class<VoicePack> VoiceType )
{
	PlayerReplicationInfo.VoiceType = VoiceType;
}

exec function SetMesh( string MeshName )
{
    ServerChangeMesh( MeshName );
}

function bool IsValidSkin( string SkinName, string Category )
{
	local string ParentNames[4];
	local string SkinNames[32];
	local string SkinDescs[32];
	local int	 i;

	ParentNames[0] = string( Mesh );
	GetSkinList( Category, ParentNames, SkinNames, SkinDescs );

	for ( i=0; i<32; i++ )
	{
		if ( SkinNames[i] == SkinName )
		{
			return true;
		}
	}

	// No skin match made
	return false;
}

function DoChangeSkin( string SkinName, int index, optional string Category )
{
    local Texture NewSkin;

	if ( SkinName == "" || SkinName == "Default" )
	{
		MultiSkins[index] = None;
		return;
	}

	if ( Level.Game.bValidateSkins && !IsValidSkin( SkinName, Category ) )
	{
		MultiSkins[index] = None;
		return;
	}

	NewSkin = texture( DynamicLoadObject( SkinName, class'Texture' ) );

    if ( NewSkin == None )
    {
        ClientMessage( "Couldn't Load Skin" @ SkinName );
		MultiSkins[index] = None;
    }
    else
    {
        MultiSkins[index] = NewSkin;
    }
}

function ServerChangeSkin
( 
	coerce string FaceName, 
	coerce string TorsoName, 
	coerce string ArmsName, 
	coerce string LegsName,
	coerce string IconName
)
{
//  FIXME: Do I need this?
//	if ( PlayerReplicationInfo.bIsSpectator ) // Spectator
//		return;

    DoChangeSkin( FaceName,  0, "Face" );
    DoChangeSkin( TorsoName, 1, "Torso" );
    DoChangeSkin( LegsName,  2, "Legs" );
    DoChangeSkin( ArmsName,  3, "Arms" );
	
	if ( IconName != "" )
	{
		PlayerReplicationInfo.Icon = Texture( DynamicLoadObject( IconName, class'Texture' ) );
	}
	else
	{
		PlayerReplicationInfo.Icon = None;
	}
}

function ClientReplicateSkins(texture Skin1, optional texture Skin2, optional texture Skin3, optional texture Skin4)
{
	// Do nothing (just loading other player skins onto client)
	log("Getting "$Skin1$", "$Skin2$", "$Skin3$", "$Skin4);
	return;
}

/*-----------------------------------------------------------------------------
	Messaging
-----------------------------------------------------------------------------*/

event ReceiveLocalizedMessage
	(
	class<LocalMessage> Message,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject,
	optional class<Actor> OptionalClass
	)
{	
	Message.static.ClientReceive( Self, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject, OptionalClass );
}

event ClientMessage( coerce string S, optional Name Type, optional bool bBeep )
{
	if (Player == None)
		return;

	if (Type == '')
		Type = 'Event';

	if (Player.Console != None)
		Player.Console.Message( PlayerReplicationInfo, S, Type );
	if (bBeep && bMessageBeep)
		PlayBeepSound();
	if ( MyHUD != None )
		MyHUD.Message( PlayerReplicationInfo, S, Type );
}

event TeamMessage( PlayerReplicationInfo PRI, coerce string S, name Type, optional bool bBeep  )
{
	if ( Player.Console != None )
		Player.Console.Message ( PRI, S, Type );

	if ( bBeep && bMessageBeep )
		PlayBeepSound();

	if ( MyHUD != None )
		MyHUD.Message( PRI, S, Type );
}

function ClientVoiceMessage(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageID)
{
	local VoicePack V;

	if ( ( Sender.voicetype == None ) || ( Player.Console == None ) || Sender.bSquelch )
		return;
		
	V = Spawn( Sender.voicetype, self );
	
	if ( V != None )
		V.ClientInitialize( Sender, Recipient, messagetype, messageID );
}

exec function ClearProgressMessages()
{
	local int i;

	for (i=0; i<8; i++)
	{
		ProgressMessage[i] = "";
		ProgressColor[i].R = 255;
		ProgressColor[i].G = 255;
		ProgressColor[i].B = 255;
	}
}

exec function SetProgressMessage( string S, int Index )
{
	if (Index < 8)
		ProgressMessage[Index] = S;
}

exec function SetProgressColor( color C, int Index )
{
	if (Index < 8)
		ProgressColor[Index] = C;
}

exec function SetProgressTime( float T )
{
	ProgressTimeOut = T + Level.TimeSeconds;
}

exec function Taunt( name Sequence )
{
	if ( ( (GetControlState() == CS_Stasis) && (Health == 0) ) || PlayerReplicationInfo.bIsSpectator )
		return;

	if ( GetAnimGroup(Sequence) == 'Gesture' ) 
	{
		ServerTaunt(Sequence);
		//PlayAnim(Sequence, 0.7, 0.2);
	}
}

function ServerTaunt(name Sequence )
{
	//PlayAnim(Sequence, 0.7, 0.2);
}

exec function Say( string Msg )
{
	local Pawn P;

	if ( PlayerReplicationInfo.bIsSpectator )
	{
		if ( Len(Msg) > 63 )
			Msg = Left( Msg,63 );

		if ( !Level.Game.bMuteSpectators )
			BroadcastMessage( PlayerReplicationInfo.PlayerName$":"$Msg, true );
	}
	else
	{
		if ( Level.Game.AllowsBroadcast(self, Len(Msg)) )
		{
			for( P=Level.PawnList; P!=None; P=P.nextPawn )
			{
				if( P.bIsPlayer )
				{
					P.TeamMessage( PlayerReplicationInfo, Msg, 'Say', true );
				}
			}
		}
	}
}

exec function Tell( int PlayerID, string Msg )
{
	local Pawn P;

	if ( PlayerReplicationInfo.bIsSpectator )
	{
		return;
	}
	else
	{
		if ( Level.Game.AllowsPrivateMessage( self, Len( Msg ) ) )
		{
			for( P=Level.PawnList; P!=None; P=P.nextPawn )
			{
				if( P.bIsPlayer && P.PlayerReplicationInfo.PlayerID == PlayerID )
				{
					P.TeamMessage( PlayerReplicationInfo, Msg, 'Private', true );
				}
			}
		}
	}
}

exec function TeamSay( string Msg )
{
	local Pawn P;

	if ( !Level.Game.bTeamGame )
	{
		Say(Msg);
		return;
	}

	if ( Msg ~= "Help" )
	{
		CallForHelp();
		return;
	}
			
	if ( Level.Game.AllowsBroadcast(self, Len(Msg)) )
		for( P=Level.PawnList; P!=None; P=P.nextPawn )
			if( P.bIsPlayer && (P.PlayerReplicationInfo.Team == PlayerReplicationInfo.Team) )
			{
				if ( P.IsA('PlayerPawn') )
					P.TeamMessage( PlayerReplicationInfo, Msg, 'TeamSay', true );
			}
}




/*-----------------------------------------------------------------------------
	AI
-----------------------------------------------------------------------------*/

exec function AddBots(int N)
{
	ServerAddBots(N);
}

function ServerAddBots(int N)
{
	local int i;

	if ( !bAdmin && (Level.Netmode != NM_Standalone) )
		return;

	if ( !Level.Game.bDeathMatch )
		return;

	for ( i=0; i<N; i++ )
		Level.Game.ForceAddBot();
}

// Dump AI profile stats.
exec function Profile()
{
	//TEMP for performance measurement

	log("Average AI Time"@Level.AvgAITime);
	log(" < 5% "$Level.AIProfile[0]);
	log(" < 10% "$Level.AIProfile[1]);
	log(" < 15% "$Level.AIProfile[2]);
	log(" < 20% "$Level.AIProfile[3]);
	log(" < 25% "$Level.AIProfile[4]);
	log(" < 30% "$Level.AIProfile[5]);
	log(" < 35% "$Level.AIProfile[6]);
	log(" > 35% "$Level.AIProfile[7]);
}

function damageAttitudeTo(pawn Other)
{
	if ( Other != Self )
		Enemy = Other;
}

function eAttitude AttitudeTo(Pawn Other)
{
	if (Other.bIsPlayer)
		return AttitudeToPlayer;
	else 
		return Other.AttitudeToPlayer;
}

exec function ShowPath()
{
	//find next path to remembered spot
	local Actor node;
	node = FindPathTo(Destination);
	if (node != None)
	{
		log("found path");
		Spawn(class 'WayBeacon', self, '', node.location);
	}
	else
		log("didn't find path");
}

exec function RememberSpot()
{
	//remember spot
	Destination = Location;
}
exec function CallForHelp()
{
	local Pawn P;

	if ( 
		 ( PlayerReplicationInfo.bIsSpectator ) || 
		 ( !Level.Game.bTeamGame ) || 
		 ( Enemy == None ) || 
		 ( ( RenderActor( Enemy ) != None ) && ( RenderActor( Enemy ).Health <= 0 ) )
	   )
	{
		return;
	}

	for ( P=Level.PawnList; P!=None; P=P.NextPawn )
		if ( P.IsA('BotPawn') && (P.PlayerReplicationInfo.Team == PlayerReplicationInfo.Team) )
			BotPawn(P).HandleHelpMessageFrom(self);
}



/*-----------------------------------------------------------------------------
	Input Remapping Helper Functions
-----------------------------------------------------------------------------*/

function StopRemappingInput()
{
	if ( bUseRemappedEvents )
	{
		// Clear out all my hooks:
		InputHookActor		= none;

		MoveForwardEvent	= '';
		MoveBackwardEvent	= '';
		StrafeLeftEvent		= '';
		StrafeRightEvent	= '';
		TurnLeftEvent		= '';
		TurnRightEvent		= '';
		FireEvent			= '';
		AltFireEvent		= '';

		// Event end hooks:
		TurnLeftEventEnd	= '';
		TurnRightEventEnd	= ''; 
		StrafeLeftEventEnd  = ''; 
		StrafeRightEventEnd = '';
		MoveForwardEventEnd = '';
		MoveBackwardEventEnd= '';
		AltFireEventEnd		= ''; 
		FireEventEnd		= '';

		bUse = 0;
		bUseRemappedEvents  = false;
		RelinquishControlEvent = '';
		
		// Unlock everything:
		bLockRotation = false;
		if ( bLockFOV )
		{
			bLockFOV = false;
			SetDesiredFOV( OriginalFOV );
		}

		if ( bControlPanelHideWeapon )
			WeaponUp();
	}
}

/*-----------------------------------------------------------------------------
	Ladders
-----------------------------------------------------------------------------*/

simulated function LadderClimb() // Event from animation
{
    // Play ladder climb sound
}

// Called from script physics code
event OnLadder()
{
    SetControlState( CS_Ladder );
}

// Called from script physics code
event OffLadder()
{    
    SetControlState( CS_Normal );
    SetPostureState( PS_Standing );
    SetMovementState( MS_Waiting );
}

event JumpOffLadder()
{
    SetControlState( CS_Normal );
    SetPostureState( PS_Jumping );
    SetMovementState( MS_Waiting );
    bOnLadder = false;
}

event Falling()
{
	SetPostureState( PS_Jumping, true );
	PlayInAir();
}

/*-----------------------------------------------------------------------------
	Ropes
-----------------------------------------------------------------------------*/

simulated function RopeClimb() // Event from animation
{
    if ( currentRope != None )
    {
        currentRope.ClimbSound();
    }
}

function CommonOnRope( BoneRope R, int bonehandle )
{
    ropeOffset              = 0;
    bOnRope                 = true;
    bMoveToRope             = true;
    currentRope             = R;
    boneRopeHandle          = boneHandle;
    currentRope.m_Rider     = self;
    tickBefore              = R;

    currentRope.SetOwner( self );
    PlayOwnedSound( currentRope.m_onOffRopeSound, SLOT_None );
    
    SetControlState(CS_Rope);    
    SetPostureState( PS_Rope );
    SetMovementState( MS_RopeIdle );
    SetPhysics( PHYS_Rope );

    currentRope.OnRope();
}

function ServerOnRope( BoneRope R, int boneHandle )
{
    if ( ( lastRope == R ) && ( lastRopeTime + 1 > level.TimeSeconds ) )
    {
        return;
    }

    CommonOnRope( R, boneHandle );
    ClientOnRope( R, boneHandle );
}

function ClientOnRope( BoneRope R, int boneHandle )
{
    CommonOnRope(R, boneHandle );
}

function OffRope()
{
	// This may be called through client side prediction (replaying of saved moves), 
	// and the client player may have already gotten off the rope, so check the bOnRope
    if ( !bOnRope )
        return;

    PlaySound( currentRope.m_onOffRopeSound, SLOT_Misc );

    currentRope.SetOwner( None );
    currentRope.m_Rider = none;
    ropeOffset              = 0;    
    tickBefore              = none;
    bOnRope                 = false;
    lastRope                = currentRope;
    currentRope             = none;
    boneRopeHandle          = -1;
    lastRopeTime            = level.TimeSeconds;        
}

/*-----------------------------------------------------------------------------
	Grab / Use
-----------------------------------------------------------------------------*/

function TouchRopes()
{
    local BoneRope R;

    if ( Role != ROLE_Authority )
        return;

    bCheckUseRopes = false;

    if ( !bCollideActors )
        return;

    // See if we touch any ropes
	for( R=Level.RopeList; R!=None; R=R.m_nextRope )
    {
		if ( R.CheckTouchRope( self ) && ( R.m_rider == None )  )
        {
            bCheckUseRopes = true;
            return;
        }
    }
}

function CheckUseRopes( vector StartTrace, vector Dir )
{    
    local BoneRope R;
    local int boneHandle;

    if ( Role != ROLE_Authority ) 
        return;

    for( R=Level.RopeList; R!=None; R=R.m_nextRope )
    {
        boneHandle = R.CheckCollision( StartTrace, Dir, 50 );

        if ( boneHandle != 0 )
        {
            ServerOnRope( R, boneHandle );
            return;
        }
    }    
}

exec function UseDown()
{
	local Actor HitActorBase;

	if ( GetControlState() == CS_Dead || GetControlState() == CS_Stasis || IsSpectating() )
		return;

	// Special handler here for the toggle shield mode.
	if ( (ShieldMode == SM_Toggle) && (ShieldItem != None) && ShieldItem.IsA('RiotShield') && (ShieldItem.GetStateName() == 'ShieldUp') )
	{
		ShieldPutDown();
		return;
	}

	// See if there is a usable hitactor.
	HitActorBase = TraceFromCrosshair( UseDistance );
	LookHitActor = RenderActor( HitActorBase );

	// Always use the vehicle we are in.
	if ( RenderActor(ViewMapper) != None )
		LookHitActor = RenderActor(ViewMapper);		// JEP Is this ok?

	// Evaluate whether we should use the shield.
	if ( (ShieldItem != None) && ShieldItem.CapturesUse() && (UseZone == 0) && (LookHitActor == None) )
	{
		// We aren't in a use zone and there is no usable actor.  Use the shield.
		ShieldBringUp();
		return;
	}

	// Is the item "client usable."
	if ( (LookHitActor != None) && LookHitActor.bClientUse && LookHitActor.bUseTriggered )
	{
		LookHitActor.ClientUsed( Self, Self );

		if ( LookHitActor.IsA('Decoration') && Decoration(LookHitActor).bClientNotifyUnUsed )
			ClientNotifyUnUsed = Decoration(LookHitActor);
	}

	// Punt to the server.
	ServerUseDown();
}

function ServerUseDown()
{
	local Actor HitActorBase;

	// When player hits use, then terminate the control:
	if ( bUseRemappedEvents )
	{
		GlobalTrigger( RelinquishControlEvent );

		if ( !bDontUnRemap )
			StopRemappingInput();
	} 
	else
	{
		bUse++;

		HitActorBase = TraceFromCrosshair( UseDistance );
		LookHitActor = RenderActor( HitActorBase );

		// Always use the vehicle we are in.
		if ( RenderActor(ViewMapper) != None )
			LookHitActor = RenderActor(ViewMapper);

		// Examine the actor if it is interesting.
		if ( (LookHitActor != None) && (LookHitActor.bExaminable) && (ExamineActor != LookHitActor) )
		{
			bExamining = true;
			ExamineActor = LookHitActor;
			HeadTrackingActor = LookHitActor;
			HeadTrackingLocation = LookHitActor.Location;
			ExamineActor.Examine(Self);
			PreExamineFOV = Default.DefaultFOV;
			if (!LookHitActor.bNoFOVOnExamine)
				DesiredFOV = LookHitActor.ExamineFOV;
			return;
		}

		if ( LookHitActor != None )
		{
			if ( LookHitActor.IsA('Decoration') && Decoration(LookHitActor).bNotifyUnUsed )
				NotifyUnUsed = Decoration(LookHitActor);
			if ( (LookHitActor != Level) && LookHitActor.bUseTriggered )
			{
				// Tell this actor we are using it.
				LookHitActor.Used( Self, Self );
			}
			else if ( (LookHitActor != Level) && 
				      (LookHitActor.IsA('Decoration') || LookHitActor.GrabTrigger) )
			{
				// Try to grab the actor.
				GrabDecoration( LookHitActor );
			}
			else
			{
				// Check for a mirror and say something witty.
				CheckMirror();
			}
		}
	}
}

exec function UseUp()
{
	if ( GetControlState() == CS_Dead )
		return;

	// If we are using the shield, let it go.
	if ( (ShieldMode == SM_Hold) && (ShieldItem != None) && ShieldItem.CapturesUse() && bUseItem )
	{
		ShieldPutDown();
		return;
	}

	if ( ClientNotifyUnUsed != None )
	{
		ClientNotifyUnUsed.ClientUnUsed( self, self );
		ClientNotifyUnUsed = None;
	}	

	// Punt to the server.
	ServerUseUp();
}

function ServerUseUp()
{
	if ( bUse > 0 )
		bUse--;
	else 
		bUse = 0;

	if (NotifyUnUsed != None)
	{
		NotifyUnUsed.UnUsed( Self, Self );
		NotifyUnUsed = None;
	}
}

function ServerShieldBringUp()
{
	ShieldProtection = true;
}

function ServerShieldPutDown()
{
	ShieldProtection = false;
}

function ServerDestroyShield()
{
	if (ShieldItem != None)
	{
		ShieldItem.Destroy();
		ShieldItem = None;
	}
}

function ClientShieldBringUp() {}
function ClientShieldPutDown() {}


function ClientActivateShield( Inventory Shield )
{
	if ( Shield != None )
		Shield.GotoState('Activated');
}

function ClientShieldDestroyed()
{
	if ( ShieldItem != None )
		ShieldItem.GotoState('ShieldDestroyed');
}

simulated function ShieldPutDown()
{
	bUseItem = false;
	ShieldProtection = false;
	ShieldItem.UseDown();
	ServerShieldPutDown();
    ClientShieldPutDown();
}

simulated function ShieldBringUp()
{
	bUseItem = true;
	ShieldProtection = true;
	ShieldItem.UseDown();
	ServerShieldBringUp();
    ClientShieldBringUp();
}

simulated function CheckMirror()
{}



/*-----------------------------------------------------------------------------
    Threat HUD Management.
-----------------------------------------------------------------------------*/
function ClearThreat( Actor A )
{
    local int i;

    // Remove actor from the threat arrays
    for( i=0; i<=6; i++ )
    {
        if ( A == rightThreats[i].Actor )
        {
            rightThreats[i].Actor    = None;
            rightThreats[i].Distance = 0;
        }

        if ( A == leftThreats[i].Actor )
        {
            leftThreats[i].Actor    = None;
            leftThreats[i].Distance = 0;
        }
    }
}


function AddThreat( Actor A )
{
    local vector X,Y,Z, DeltaVec, DeltaVec2D;
	local float dotp,distance;
    local int i;
    local float alpha;

    // This actor is a threat, check to see where it should be displayed on the HUD

    // First clear out the actor from the current threat and zero out the distance
    ClearThreat( A );
    
    // Determine position (Left or Right)
	GetAxes(ViewRotation,X,Y,Z);
	X.Z          = 0;
	DeltaVec     = A.Location - Location;	
    distance     = VSize(DeltaVec);    
    DeltaVec     = Normal(DeltaVec);
    DeltaVec2D   = DeltaVec;
	DeltaVec2D.Z = 0;
	dotp         = DeltaVec2D dot Y;	
    alpha        = fmin( abs( dotp ), 0.8 ) / 0.8; 

    if ( dotp < 0 )
    {
        for( i=0; i<6; i++ )
        {
            if ( leftThreats[i].Actor == None )
            {
                break;
            }
        }

        if ( i!=6 )
        {
            leftThreats[i].Actor    = A;
            leftThreats[i].Distance = distance;
            leftThreats[i].Alpha    = alpha;
        }
    }
    else
    {
        for( i=0; i<6; i++ )
        {
            if ( rightThreats[i].Actor == None )
            {
                break;
            }
        }

        if ( i!=6 )
        {
            rightThreats[i].Actor    = A;
            rightThreats[i].Distance = distance;
            rightThreats[i].Alpha    = alpha;
        }
    }
}


/*-----------------------------------------------------------------------------
	Inventory
-----------------------------------------------------------------------------*/

function bool DropDecoration(optional float Force, optional bool bForceDrop, optional bool bNoWeapon)
{
	local bool SuperDrop;

    SuperDrop = Super.DropDecoration( Force, bForceDrop, bNoWeapon );

	if ( SuperDrop )
    {
		LastWeaponClass = None;
        ThirdPersonDecoration.bHidden = true;
        SetUpperBodyState( UB_Alert );
    }

	return SuperDrop;
}

function GrabDecoration(Actor HitActor)
{
    Super.GrabDecoration( HitActor );

    // Grabbed a Decoration, so set up a 3rd person decoration on the player so others can see you carrying it
    if ( CarriedDecoration != None )
    {
        ThirdPersonDecoration.Mesh          = CarriedDecoration.Mesh;
        ThirdPersonDecoration.Texture       = CarriedDecoration.Texture;
        ThirdPersonDecoration.DrawType      = CarriedDecoration.DrawType;
        ThirdPersonDecoration.MountOrigin   = CarriedDecoration.ThirdPersonInfo.MountOrigin;
        ThirdPersonDecoration.MountAngles   = CarriedDecoration.ThirdPersonInfo.MountAngles;
        ThirdPersonDecoration.bHidden       = false;
        
        if ( CarriedDecoration.ThirdPersonInfo.Hand == OneHanded )
            SetUpperBodyState( UB_HoldOneHanded );
        else if ( CarriedDecoration.ThirdPersonInfo.Hand == TwoHanded )
            SetUpperBodyState( UB_HoldTwoHanded );
    }
}

function InitializeThirdPersonDecoration()
{
	if ( ThirdPersonDecoration != None )
		return;
    ThirdPersonDecoration = spawn( class'ThirdPersonDecoration', self );
    ThirdPersonDecoration.AttachActorToParent( self, false, false );
    ThirdPersonDecoration.bHidden = true;
}

exec function SetDecoAngles( int pitch, int yaw, int roll )
{
    ThirdPersonDecoration.MountAngles.Pitch = pitch;
    ThirdPersonDecoration.MountAngles.Yaw   = yaw;
    ThirdPersonDecoration.MountAngles.Roll  = roll;
}

function ActivateInventoryItem( class<Inventory> InvItem )
{
	local Inventory Inv;

	Inv = FindInventoryType(InvItem);
	if ( Inv != None && Level.NetMode == NM_Client )
		Inv.Activate();

	ServerInventoryActivate( InvItem );
}

simulated function inventory InventorySelectFirstItem(int Category, optional int AtLeastPriority)
{
	local inventory Inv, InvBucket[7];
	local int i;

	// Sort the inventory of the given category into a bucket.
	for ( Inv=Inventory; Inv!=None; Inv=Inv.Inventory )
	{
		if ( (Inv.dnInventoryCategory == Category) && (Inv.bActivatable) )
			InvBucket[Inv.dnCategoryPriority] = Inv;
	}

	// Search for the best first item.
	for ( i=AtLeastPriority; i<7; i++ )
	{
		if (InvBucket[i] != None)
		{
			if (!InvBucket[i].IsA('Weapon') || !Weapon(InvBucket[i]).OutOfAmmo())
			{
				SelectedItem = InvBucket[i];
				return InvBucket[i];
			}
		}
	}

	return none;
}

simulated function inventory InventorySelectLastItem(int Category, optional int AtMostPriority)
{
	local inventory Inv, InvBucket[7];
	local int i;

	// Sort the inventory of the given category into a bucket.
	for ( Inv=Inventory; Inv!=None; Inv=Inv.Inventory )
	{
		if ( (Inv.dnInventoryCategory == Category) && (Inv.bActivatable) )
			InvBucket[Inv.dnCategoryPriority] = Inv;
	}
	
	// Search for the best last item.
	for ( i=AtMostPriority; i>=0; i-- )
	{
		if (InvBucket[i] != None)
		{
			if (!InvBucket[i].IsA('Weapon') || !Weapon(InvBucket[i]).OutOfAmmo())
			{
				SelectedItem = InvBucket[i];
				return InvBucket[i];
			}
		}
	}

	return none;
}

simulated function ActivateItem()
{
	if ( Level.Pauser != "" )
		return;
	if ( SelectedItem != None ) 
		SelectedItem.Activate();
}

// Client side inventory activation.
exec function InventoryActivate( optional float GoAwayDelay )
{
	// If we have the objectives screen open, close it.
	if ( MyHUD.bDrawObjectives )
	{
		MyHUD.HideObjectives();
		return;
	}

	// Check for a special click area.
	if ( MyHUD.MouseClick() )
		return;

	// Close the inventory screen.
	Player.console.MouseCapture = false;
	Player.console.MouseLineMode = false;
	InputHookActor = None;
	if ( GoAwayDelay != 0.0 )
		MyHUD.InventoryGoAwayDelay =GoAwayDelay;
	else
		MyHUD.CloseInventory();

	// Early out if we didn't select anything.
	if ( SelectedItem == None )
		return;

	// If the hand is up, just close inventory.
	if ( bDukeHandUp && !SelectedItem.bCanActivateWhileHandUp )
	{
		if ( Weapon(SelectedItem) != None )
		{
			SelectedItem.PlayInventoryActivate( Self );
			LastWeaponClass = Weapon(SelectedItem).Class;
		}
		MyHUD.CloseInventory();
		return;
	}

	// Can't select some things if a view mapper is set.
	if ( ViewMapper != None )
	{
		if ( SelectedItem.IsA('Weapon') || SelectedItem.IsA('QuestItem') )
			return;
	}

	// Switch to the selected weapon or item.
	if ( SelectedItem.IsA('Weapon') )
	{
		ChangeToWeapon( Weapon(SelectedItem) );
	}
	else if ( Level.NetMode == NM_Client )
		ActivateItem();

	// Punt to the server.
	ServerInventoryActivate( SelectedItem.Class );

	// Wheet!
	SelectedItem.PlayInventoryActivate( Self );
}

// Server side inventory activation.
// Doesn't do anything if the item is a weapon, since ChangeToWeapon handles that.
function ServerInventoryActivate( class<Inventory> ClientItemClass )
{
	local Inventory ClientItem;

	// Get the item reference.
	ClientItem = FindInventoryType( ClientItemClass );
	if ( ClientItem == None )
		return;

    SelectedItem = ClientItem;

	// Drop a decoration we might be carrying.
	OldUsedItem = None;
	if ( (CarriedDecoration != None) && ((Weapon(ClientItem) != None) || (QuestItem(ClientItem) != None)) )
		DropDecoration(-1.0, false, true);

	// Put down a quest item if we have one and we aren't switching to a quest item.
	if ( (QuestItem(UsedItem) != None) && (ClientItem != UsedItem) && (QuestItem(ClientItem) == None) )
		QuestItem(UsedItem).Activate();

	// If we are selecting a quest item we aren't using, reset it...
	if ( (QuestItem(ClientItem) != None) && (ClientItem != UsedItem) )
		QuestItem(ClientItem).GotoState('');

	// Activate the selected item.
	if ( !ClientItem.IsA('Weapon') )
		ActivateItem();
}

exec function ShowInventory()
{
	local Inventory Inv;
	
	if( Weapon!=None )
		ClientMessage( "   Weapon: " $ Weapon.Class );
	for( Inv=Inventory; Inv!=None; Inv=Inv.Inventory ) 
		ClientMessage( "Inv: "$Inv $ " state "$Inv.GetStateName());
	if ( SelectedItem != None )
		ClientMessage( "Selected Item"@SelectedItem@"Charge"@SelectedItem.Charge );
}

exec function OpenClassBrowser()
{
	if ( bUseRemappedEvents )
		return;
	if ( MyHUD == None )
		return;

	Player.console.MouseCapture = true;
	InputHookActor = self;

}

exec function MouseInventoryAction()
{
	if ( bUseRemappedEvents )
		return;
	if ( MyHUD == None )
		return;

	if ( MyHUD.currentInventoryCategory < 0 )
	{
		MyHUD.HideObjectives();
		SelectedItem = None;
		MyHUD.currentInventoryCategory = 0;
		MyHUD.visibleCategories = 7;
		Player.console.MouseCapture = true;
		InputHookActor = self;
	}
	else
	{
		MyHUD.CloseInventory();
	}

	MyHUD.InventoryGoAwayDelay = 0;
}

exec function InventoryAction(optional int Category)
{
	local Inventory Inv;

	if ( Player.console.MouseCapture )
		return;
	if ( MyHUD == none )
		return;

	MyHUD.HideObjectives();
	MyHUD.InventoryGoAwayDelay = 2.5;
	MyHUD.visibleCategories = 7;

	// If this is a new category, start over.
	if (MyHUD.currentInventoryCategory != Category)
		InventorySelectFirstItem(Category);
	else
	{
		Inv = InventorySelectFirstItem(Category, SelectedItem.dnCategoryPriority+1);
		if (Inv == None)
			InventorySelectFirstItem(Category);
	}

	MyHUD.currentInventoryCategory = Category;
}

exec function NextWeaponAction()
{
	local int CurrentCategory, DropOut, MatchPriority, MatchMax;
	local inventory Inv;

	if ( Player.console.MouseCapture )
		return;

	MyHUD.HideObjectives();
	MyHUD.InventoryGoAwayDelay = 2.5;
	MyHUD.visibleCategories = 4;

	if ( MyHUD.currentInventoryCategory == -1 )
	{
		// If this is our first select, pick our weapon.
		if ( Weapon != None )
			SelectedItem = Weapon;
		else if ( LastWeaponClass != None )
			SelectedItem = FindInventoryType( LastWeaponClass );

		if ( SelectedItem != None )
			MyHUD.currentInventoryCategory = SelectedItem.dnInventoryCategory;
		else
			MyHUD.currentInventoryCategory = 0;
		return;
	}

	if ( SelectedItem != None )
		CurrentCategory = SelectedItem.dnInventoryCategory;
	else
		CurrentCategory = 0;
	MyHUD.currentInventoryCategory = CurrentCategory;

	if ( SelectedItem != None )
		MatchPriority = SelectedItem.dnCategoryPriority;

	// Otherwise, pick the next item.
	Inv = InventorySelectFirstItem( CurrentCategory, SelectedItem.dnCategoryPriority+1 );
	DropOut = 0;
	while ( (Inv == None) && (DropOut < 30) )
	{
		// Whoops, everything else is empty...next line.
		CurrentCategory++;
		if (CurrentCategory > 3)
			CurrentCategory = 0;
		Inv = InventorySelectFirstItem( CurrentCategory );
		MyHUD.currentInventoryCategory = CurrentCategory;
		DropOut++;
	}
}

exec function PrevWeaponAction()
{
	local int CurrentCategory, DropOut, MatchPriority;
	local inventory Inv, lastItem;

	if ( Player.console.MouseCapture )
		return;

	MyHUD.HideObjectives();
	MyHUD.InventoryGoAwayDelay = 2.5;
	MyHUD.visibleCategories = 4;

	if ( MyHUD.currentInventoryCategory == -1 )
	{
		// If this is our first select, pick our weapon.
		if ( Weapon != None )
			SelectedItem = Weapon;
		else if ( LastWeaponClass != None )
			SelectedItem = FindInventoryType( LastWeaponClass );

		if ( SelectedItem != None )
			MyHUD.currentInventoryCategory = SelectedItem.dnInventoryCategory;
		else
			MyHUD.currentInventoryCategory = 0;
		return;
	}

	if ( SelectedItem != None )
		CurrentCategory = SelectedItem.dnInventoryCategory;
	else
		CurrentCategory = 0;
	MyHUD.currentInventoryCategory = CurrentCategory;

	if ( SelectedItem != None )
		MatchPriority = SelectedItem.dnCategoryPriority;
	if ( MatchPriority == 0 )
	{
		// If we are at the start, go to the prev category.
		CurrentCategory--;
		if (CurrentCategory < 0)
			CurrentCategory = 3;
		Inv = InventorySelectLastItem(CurrentCategory, 6);
		while ( (Inv == None) && (DropOut < 30) )
		{
			// Whoops, everything else is empty...next line.
			CurrentCategory--;
			if (CurrentCategory < 0)
				CurrentCategory = 3;
			Inv = InventorySelectLastItem(CurrentCategory, 6);
			MyHUD.currentInventoryCategory = CurrentCategory;
			DropOut++;
		}
		MyHUD.currentInventoryCategory = CurrentCategory;
		return;
	}

	// Otherwise, pick the prev item.
	Inv = InventorySelectLastItem(CurrentCategory, MatchPriority-1);
	DropOut = 0;
	while ( (Inv == None) && (DropOut < 30) )
	{
		// Whoops, everything else is empty...next line.
		CurrentCategory--;
		if ( CurrentCategory < 0 )
			CurrentCategory = 3;
		Inv = InventorySelectLastItem( CurrentCategory, 6 );
		MyHUD.currentInventoryCategory = CurrentCategory;
		DropOut++;
	}
}

function bool InventoryEscape()
{
	if ((MyHUD.InventoryGoAwayDelay > 0) || (Player.console.MouseCapture))
	{
		if ( MyHUD.bDrawObjectives )
			MyHUD.HideObjectives();
		MyHUD.CloseInventory();
		return true;
	} else
		return false;
}

simulated function ChangeToWeapon( Weapon NewWeapon )
{
	if ( (ViewMapper != None) && (NewWeapon != None) )
		return;

	Super.ChangeToWeapon( NewWeapon );
}

function SetEnergyDrain( float NewDrain )
{
	EnergyDrain = NewDrain;
}

exec function KillSOSPowers()
{
	if (Weapon != None)
		Weapon.SOSPowerOff();
	else
		DesiredFOV = 90;
	RendMap = 5;
	CameraStyle = PCS_Normal;

	RestoreFog();

	SetEnergyDrain(0.0);
}

simulated function SOSPowerOff()
{
	PlayOwnedSound(SOSPowerOffSound, SLOT_Interface);
	if (Weapon != None)
		Weapon.SOSPowerOff();
	else
		DesiredFOV = 90;
	RendMap = 5;
	CameraStyle = PCS_Normal;

	RestoreFog();

	SetEnergyDrain(0.0);
}

simulated function SOSPowerOn()
{
	PlayOwnedSound(SOSPowerOnSound, SLOT_Interface);
}

function HeatVision()
{
	if (bEMPulsed) 
		return;

	if (CameraStyle == PCS_HeatVision)
	{
		if (ZoomLevel > 0)
		{
			RendMap = 5;
			RestoreFog();			
			CameraStyle = PCS_ZoomMode;
		} 
		else
		{
			SOSPowerOff();
		}
	} 
	else 
	{
		SOSPowerOn();
		RendMap = 2;
		CameraStyle = PCS_HeatVision;
		Region.Zone.FogColor = HeatFogColor;
		SetEnergyDrain(1.0);
	}
}

function NightVision()
{
	if (bEMPulsed) 
		return;

	if (CameraStyle == PCS_NightVision)
	{
		if (ZoomLevel > 0)
		{
			RendMap = 5;
			RestoreFog();
			CameraStyle = PCS_ZoomMode;
		} 
		else
		{
			SOSPowerOff();
		}
	} 
	else 
	{
		SOSPowerOn();
		RendMap = 2;
		CameraStyle = PCS_NightVision;
		Region.Zone.FogColor = NightFogColor;
		SetEnergyDrain(2.0);
	}
}

function ZoomDown()
{
	if ( bEMPulsed )
		return;

	if ( (Weapon != None) && !Weapon.AllowZoom() )
		return;

	ZoomChangeTime = Level.TimeSeconds;
	ZoomLevel++;
	
	if ( ZoomLevel == 3 )
		ZoomLevel = 0;

	if ( ZoomLevel == 0 )
	{
		if ( ZoomOutSound == None )
			ZoomOutSound = sound( DynamicLoadObject("a_inventory.SOS.SOSZoom06", class'sound') );
		
		PlaySound( ZoomOutSound );
		ZoomOff();
	} 
	else 
	{
		if ( ZoomInSound == None )
			ZoomInSound = sound( DynamicLoadObject("a_inventory.SOS.SOSZoom05", class'sound') );
		
		PlaySound( ZoomInSound );
		
		if ( CameraStyle == PCS_Normal )
		{
			RendMap = 5;
			RestoreFog();
			CameraStyle = PCS_ZoomMode;
		}

		switch ( ZoomLevel )
		{
		case 1:
			DesiredFOV = 50;
			FOVAngle = 50;
			break;
		case 2:
			DesiredFOV = 10;
			FOVAngle = 10;
			break;
		}
	}
}

function ZoomUp()
{
}

function ZoomOff()
{
	if (bEMPulsed) 
		return;

	ZoomLevel = 0;
	DesiredFOV = 90;
	FOVAngle = 90;
	
	if (CameraStyle == PCS_ZoomMode)
	{
		RendMap = 5;
		CameraStyle = PCS_Normal;
		RestoreFog();
		SetEnergyDrain(0.0);
	}
}


/*-----------------------------------------------------------------------------
	Weapons
-----------------------------------------------------------------------------*/

simulated function Fire()
{	
	if ( PlayerReplicationInfo == None )
		return;

	if ( PlayerReplicationInfo.bWaitingPlayer )
	{
		bReadyToPlay = true;
		return;
	}

	if ( PlayerReplicationInfo.bIsSpectator )
	{
		ViewPlayerNum( -1 );
	
		bBehindView = bChaseCam;

		if ( ViewTarget == None )
			bBehindView = false;
		return;
	}

	if ( GetControlState() == CS_Dead )
	{
        if ( !bAllowRestart )
            return;

        bAllowRestart = false;

		EndCallbackTimer( 'AllowRespawn' );
		EndCallbackTimer( 'ForceRespawn' );

        ServerRestartPlayer();
		return;
	}

	if ( GetControlState() == CS_Stasis )
	{
		if ( Role < ROLE_Authority)
			return;
		ServerReStartGame();
		return;
	}

	if ( GetControlState() == CS_Frozen )
		return;

	// If we are on a viewmapper, the code will get to this point on the server.
	if ( ViewMapper != None )
	{
		bFire++;
		return;
	}

	bJustFired = true;

	// Unpause if we are the pauser.
	if ( Level.Pauser != "" )
	{
		if ( (Level.Pauser == PlayerReplicationInfo.PlayerName) )
			SetPause( false );
		return;
	}

	if ( (Weapon != None) && Weapon.bDontAllowFire )
		return;

	// Client version.
	if ( Role < ROLE_Authority )
	{
		if ( Weapon != None )
			bJustFired = Weapon.ClientFire();
		if ( bJustFired )
			bFire++;
		return;
	}

	// Server version.
	if ( Weapon != None )
	{
		bFire++;
		PlayFiring();
		Weapon.Fire();
	}
}

simulated function AltFire()
{
	if ( PlayerReplicationInfo == None )
		return;

	if ( PlayerReplicationInfo.bWaitingPlayer )
		return;

	if ( PlayerReplicationInfo.bIsSpectator )
	{
		bBehindView = false;
		Viewtarget	= None;
		ClientMessage( ViewingFrom@OwnCamera, 'Event', true );
		return;
	}

	if ( (GetControlState() == CS_Dead) ||
		 (GetControlState() == CS_Stasis) ||
		 (GetControlState() == CS_Frozen) )
	{
		Fire();
		return;
	}

	// If we are on a viewmapper, the code will get to this point on the server.
	if ( ViewMapper != None )
	{
		bAltFire++;
		return;
	}

	if ( (Weapon != None) && Weapon.bDontAllowFire )
		return;

	bJustAltFired = true;
	if ( (Level.Pauser!="") || (Role < ROLE_Authority) )
	{
		if ( (Role < ROLE_Authority) && (Weapon != None) )
			bJustAltFired = Weapon.ClientAltFire();
		if (bJustAltFired)
			bAltFire++;
		if ( Level.Pauser == PlayerReplicationInfo.PlayerName )
			SetPause( false );
		return;
	}

	if ( Weapon != None )
	{
		bAltFire++;
		PlayFiring();
		Weapon.AltFire();
	}
}

// Called when the player pressed the key bound to FireDown.
exec function FireDown()
{
	local float DropForce;
	
	if ( (MyHUD != none) && (MyHUD.currentInventoryCategory >= 0) )
	{
		// Handle inventory mouse click when the Q Menu is open.
		InventoryActivate();
	}
	else if ( (MyHUD != none) && (MyHUD.bDrawObjectives) )
	{
		// Close the objectives screen if it is open.
		MyHUD.HideObjectives();
	}
	else if ( QuestItem(UsedItem) != none )
	{
		// If we are holding a quest item, try to use it.
		bFireUse = true;
		UseDown();
	}
	else if ( CarriedDecoration != none )
	{
		// If carrying something, fire button causes a throw with max force.
		DropDecoration(600.0);
	}
	else if ( ViewMapper != None )
	{
		// Toggle fire state, but not weapon fire.
		bJustFired = ViewMapper.CanSendFire();
		if ( bJustFired )
			bFire++;
	}
	else if ( bUseRemappedEvents || FireEvent != '' )
	{
		// If we are using remapped events, call the fire event.
		bFireDown++;
		GlobalTrigger(FireEvent);
	} 
	else
	{
		// Call the weapon fire function.
		Fire();
	}
} 

// Called when the player releases the fire button.
exec function FireUp()
{
	if ( bFireUse )
	{
		UseUp();
		bFireUse = false;
	}

	if ( (Weapon != None) && (bFire>0) )
	{
		if ( Role == ROLE_Authority )
			Weapon.UnFire();
		else
			Weapon.ClientUnFire();
	}

	if ( bFire > 0 ) bFire--;
	else bFire=0;

	if ( bFireDown > 0 ) bFireDown--;
	else bFireDown=0;

	if ( (bUseRemappedEvents || FireEvent!='') && (bFireDown == 0) && (FireEventEnd != '') )
		GlobalTrigger( FireEventEnd, Self );
}


// Handle Alt-firing event:
exec function AltFireDown()
{
	if ( (MyHUD != none) && (MyHUD.bDrawObjectives) )
	{
		// Close the objectives screen if it is open.
		MyHUD.HideObjectives();
	}
	else if ( CarriedDecoration != none )
	{
		// Drop a decoration at our feet if we have one.
		DropDecoration(-1.0);
	}
	else if ( ViewMapper != None )
	{
		bJustAltFired = ViewMapper.CanSendAltFire();
		if ( bJustAltFired )
			bAltFire++;
	}
	else if( bUseRemappedEvents || (AltFireEvent != '') )
	{
		// Pass it to the remap event.
		bAltFireDown++;
		GlobalTrigger(AltFireEvent);
	}
	else
	{
		// Call the altfire function.
		AltFire();
	}
}

exec function AltFireUp()
{
	if ( (Weapon != None) && (bAltFire>0) )
	{
		if ( Role == ROLE_Authority )
			Weapon.UnAltFire();
		else
			Weapon.ClientUnAltFire();
	}

	if(bAltFire>0) bAltFire--;
	else bAltFire=0;
	
	if(bAltFireDown>0) bAltFireDown--;
	else bAltFireDown=0;

	if((bUseRemappedEvents||(AltFireEvent!=''))&&(bAltFireDown==0)&&(AltFireEventEnd!=''))
		GlobalTrigger(AltFireEventEnd,self);
}

exec function Reload()
{
	if (Weapon != None)
	{
		if (Level.NetMode == NM_Client)
			Weapon.ClientReload();
		else
			ServerReload();
	}
}

function ServerReload()
{
	if (Weapon != None)
		Weapon.Reload();
}

exec function ThrowWeapon()
{
	if ( IsSpectating() )
		return;
	if( GetControlState() == CS_Stasis )
		return;
	if( GetControlState() == CS_Frozen )
		return;
	if( Level.NetMode == NM_Client )
		return;
	if( Weapon==None || (Weapon.Class==Level.Game.BaseMutator.MutatedDefaultWeapon()) || !Weapon.bCanThrow )
		return;
	TossWeapon();
	if ( Weapon == None )
		SwitchToBestWeapon();
}

exec function NeverSwitchOnPickup( bool B )
{
	bNeverAutoSwitch = B;
	bNeverSwitchOnPickup = B;
	ServerNeverSwitchOnPickup(B);
	SaveConfig();
}
	
function ServerNeverSwitchOnPickup( bool B )
{
	bNeverSwitchOnPickup = B;
}	

exec function SetWeaponStay( bool B )
{
	local Weapon W;

	if ( !bAdmin && (Level.Netmode != NM_Standalone) )
		return;

	Level.Game.bCoopWeaponMode = B;
	ForEach AllActors(class'Weapon', W)
	{
		W.bWeaponStay = false;
		W.SetWeaponStay();
	}
}

/*
exec function GetWeapon(class<Weapon> NewWeaponClass )
{
	local Inventory Inv;

	if ( (Inventory == None) || (NewWeaponClass == None)
		|| ((Weapon != None) && (Weapon.Class == NewWeaponClass)) )
		return;

	for ( Inv=Inventory; Inv!=None; Inv=Inv.Inventory )
		if ( Inv.Class == NewWeaponClass )
		{
			PendingWeapon = Weapon(Inv);
			if ( PendingWeapon.OutOfAmmo() )
			{
				Pawn(Owner).ClientMessage( PendingWeapon.ItemName$PendingWeapon.MessageNoAmmo );
				PendingWeapon = None;
				return;
			}
			Weapon.PutDown();
			return;
		}
}
*/

/*
function UpdateWeaponPriorities()
{
	local byte i;

	// send new priorities to server
	if ( Level.Netmode == NM_Client )
		for ( i=0; i<ArrayCount(WeaponPriority); i++ )
			ServerSetWeaponPriority(i, WeaponPriority[i]);
}

function ServerSetWeaponPriority(byte i, name WeaponName )
{
	local inventory inv;

	WeaponPriority[i] = WeaponName;

	for ( inv=Inventory; inv!=None; inv=inv.inventory )
		if ( inv.class.name == WeaponName )
			Weapon(inv).SetSwitchPriority(self);
}

function ServerUpdateWeapons()
{
	local inventory Inv;

	for ( Inv=Inventory; Inv!=None; Inv=Inv.Inventory )
		if ( Inv.IsA('Weapon') )
			Weapon(Inv).SetSwitchPriority( self ); 
}
*/

exec function QuickKick( optional bool bNoTraceHit, optional bool bForceKick )
{
}


/*-----------------------------------------------------------------------------
	Death & Damage
-----------------------------------------------------------------------------*/

exec function TestEMP()
{
	EMPBlast( 10.0, Self );
}

function EMPBlast( float EMPtime, optional Pawn Instigator )
{
	Super.EMPBlast( EMPtime, Instigator );

	// Toggle EMP status.
	bEMPulsed = true;
//	Energy -= 25;
//	if (Energy < 0) Energy = 0;
	KillSOSPowers();

    // Set a Timer for unEMP event
    SetTimer( 10.0, false, 1 );
}

function UnEMP()
{
	bEMPulsed = false;
}

function TakeDamage( int Damage, Pawn InstigatedBy, Vector HitLocation, Vector Momentum, class<DamageType> DamageType )
{
	local EPawnBodyPart BodyPart;
	local float WhipShakeStrength, rnd;

	if ( IsSpectating() )
		return;

	if ( 
         (bTakeDamage) && 
         ((GetControlState() != CS_Dead) || ((GetControlState() == CS_Dead) && (!bHidden)))
       )
	{
		// Normal damage.
		Super.TakeDamage( Damage, InstigatedBy, Hitlocation, Momentum, DamageType );
		BodyPart = GetPartForBone(DamageBone);
		PlayPain(BodyPart, true, hitlocation );

		if ( ClassIsChildOf(DamageType, class'BulletDamage') )
			AddRotationShake( 0.012 );

		if ( ClassIsChildOf(DamageType, class'TentacleDamage') )
		{
			if ( InstigatedBy.IsA('Snatcher') || InstigatedBy.IsA('SnatcherFace') || InstigatedBy.IsA('HeadCreeper') )				WhipShakeStrength = FRand()*0.12 + 0.1;
			else
				WhipShakeStrength = FRand()*0.5 + 0.25;
		}
		// Do rotation shaking for different types of hit.
		if ( DamageType == class'WhippedDownDamage' )
			AddRotationShake( WhipShakeStrength, 'Down' );
		else if ( DamageType == class'WhippedLeftDamage' )
			AddRotationShake( WhipShakeStrength, 'Left' );
		else if ( DamageType == class'WhippedRightDamage' )
			AddRotationShake( WhipShakeStrength, 'Right' );
		else if ( ClassIsChildOf(DamageType, class'KungFuDamage') )
			AddRotationShake( FRand()*0.25 );

		// Screen flash, hit notify, pain sound
		if ( Damage > 1 )
		{
			rnd = FClamp( Damage, 20, 60 );
			ClientFlash( DamageType.default.FlashScale*rnd, DamageType.default.FlashFog*rnd );
			
			if ( PlayerPawn( InstigatedBy ) != None )
				PlayerPawn( InstigatedBy ).ScoreHit();			
			
			if ( Level.TimeSeconds > PainDebounceTime )
			{
				ClientPlayPainSound( DamageType );
				PainDebounceTime = Level.TimeSeconds + PainDelay;
			}
		}
	}
}

function ScoreHit();

function AddRotationShake( float Strength, optional name DirName )
{
	ShakeStrength = 100;
	if ( (DirName == 'Left') || ( (DirName != 'Right') && (FRand() > 0.5) ) )
		ShakeYaw = ShakeRotStrength * Strength;
	else
		ShakeYaw = ShakeRotStrength * Strength * -1;

	if ( (DirName != 'Down') && (FRand() > 0.5) || (DirName == 'Up') )
		ShakePitch = ShakeRotStrength * Strength;
	else
		ShakePitch = ShakeRotStrength * Strength * -1;

	if (FRand() > 0.5)
		ShakeRoll = ShakeRotStrength * Strength;
	else
		ShakeRoll = ShakeRotStrength * Strength * -1;
}

function Carcass DoSpawnCarcass( optional class<DamageType> DT )
{
	local Carcass c;

	c = Spawn( CarcassType );

	if ( c == None )
	{
		// FIXME: Need to add something here, maybe a gib splash?
		return None;
	}

	c.ChunkDamageType = DT;

	c.SetOwner( self );
	c.InitFor( self );

	// In single player, don't render the carcass, but DO update the animation
	if ( Level.NetMode == NM_Standalone )
	{
		c.bOwnerGetFrameOnly=true;
	}
	else
	{
		ViewTarget  = c;
		bBehindView = true;
	}

	return c;
}

function Carcass SpawnCarcass( optional class<DamageType> DT, optional vector HitLocation, optional vector Momentum )
{
	// Spawn a carcass.
	PendingDeathCarcass = DoSpawnCarcass( DT );

	PendingDeathCarcass.ChunkDamageType = DT;
	PendingDeathCarcass.ChunkUpBlastLoc = HitLocation;
	PendingDeathCarcass.BlastVelocity   = Momentum;

	if ( DT.default.bFlyCarcass )
	{
		PendingDeathCarcass.FlyCarcass();
	}

	return PendingDeathCarcass;
}

function SpawnGibbedCarcass( optional class<DamageType> DT, optional vector HitLocation, optional vector Momentum )
{
	local carcass carc;

	// Spawn a carcass.
	carc = DoSpawnCarcass( DT );

	if ( carc != None )
	{
		// Set this corpse to blow up on the client.
		carc.ChunkDamageType = DT;
		carc.ChunkUpBlastLoc = HitLocation;
		carc.BlastVelocity   = Momentum;
		
		// Chunk carcass will fly the carcass
		carc.ChunkCarcass();

		PendingDeathCarcass  = carc.GetChunk();

	}
}

function Died( pawn Killer, class<DamageType> DamageType, vector HitLocation, optional Vector Momentum )
{
	Super.Died( Killer, DamageType, HitLocation, Momentum );

	// Play the stinger hit.
	if ( Level.Game.bPlayStinger )
	{
		MusicPlay( Level.Mp3, true, 0.5, true );
		MusicPlay( "stinger" /*Level.Mp3*/, true, 0.5, true );
	}

	if ( NotifyUnUsed != None )
	{
		NotifyUnUsed.UnUsed( Self, Self );
		NotifyUnUsed = None;
	}
}

function bool ShouldBeGibbed( class<DamageType> dt )
{
	if ( dt.default.bGibDamage )
	{		
		return( FRand() < dt.default.gibChance );
	}
}

function int AddEgo( int AddedEgo, optional bool Limit )
{
	local int SuperEgo; // Hehe, another great joke from your pal and mine, TV's Brandon Reinhart. :P

	SuperEgo = Super.AddEgo( AddedEgo, Limit );
}

function int AddEnergy( int AddedEnergy )
{
	local int EDiff;

	EDiff = AddedEnergy;
	if (Energy+AddedEnergy >= 100)
		EDiff = AddedEnergy - (Energy+AddedEnergy-100);
	Energy += EDiff;

	MyHUD.HUDAddEnergy( EDiff );

	return EDiff;
}

exec function AddCash(int Amount)
{
	Super.AddCash(Amount);
	MyHUD.FlashCash();
}

exec function Suicide()
{
	if ( IsSpectating() )
		return;

	if ( GetControlState() == CS_Dead )
		return;

	Health = -1000;
	Died( self, class'SuicideDamage', Location );
}

function KilledBy( pawn EventInstigator )
{
	Health = -1000;
	Died( EventInstigator, class'CrushingDamage', Location );
}

simulated function ClientRemoveViewMapper()
{
	if ( ViewMapper != None )
	{
		ViewMapper.Relinquish();
		ViewMapper = None;
	}
}

function ClientGameEnded()
{
	ClientRemoveViewMapper();
	Super.ClientGameEnded();
}

/*-----------------------------------------------------------------------------
	Animations
    - When animations on channel 0 end, this function is called.  Based on
    the player's state, a new animation will be chosen.
-----------------------------------------------------------------------------*/

function AnimEnd()
{
    /*
    local string cs,ps,ms;
    cs = GetControlStateString();
    ps = GetPostureStateString();
    ms = GetMovementStateString();
    */

	if ( GetControlState() == CS_Normal )
	{
		if ( GetPostureState() == PS_Standing )
		{
			if ( GetMovementState() == MS_Waiting )
			{
				PlayWaiting();
			} 
            else if ( GetMovementState() == MS_Walking )
            {
				PlayWalking();
            }
			else if ( GetMovementState() == MS_Running )
            {
				PlayRunning();
            }
		}
		else if ( GetPostureState() == PS_Crouching )
		{
			if ( GetMovementState() == MS_Waiting )
            {
				PlayCrouching();
            }
			else
            {
				PlayCrawling();
            }
		}
		else if ( GetPostureState() == PS_Jumping )
		{
			PlayInAir();
		}
		else if ( GetPostureState() == PS_Swimming )
		{
			PlaySwimming();
		}
	}
    else if ( GetControlState() == CS_Rope )
    {
        if ( GetMovementState() == MS_RopeIdle )
        {
            PlayRopeIdle();
        }
        else if ( GetMovementState() == MS_RopeClimbUp )
        {
            PlayRopeClimbUp();
        }
        else if ( GetMovementState() == MS_RopeClimbDown )
        {
            PlayRopeClimbDown();
        }
    }
    else if ( GetControlState() == CS_Ladder )
    {
        if ( GetMovementState() == MS_LadderIdle )
        {
            PlayLadderIdle();
        }
        else if ( GetMovementState() == MS_LadderClimbUp )
        {
            PlayLadderClimbUp();
        }
        else if ( GetMovementState() == MS_LadderClimbDown )
        {
            PlayLadderClimbDown();
        }
    }
	else if ( GetControlState() == CS_Swimming )
	{
        // This is here because we don't play different channel firing anims when swimming, so when we are done firing,
        // set us back to alert.
        if ( GetUpperBodyState() == UB_Firing )
        {
            SetUpperBodyState( UB_Alert );
        }

		PlaySwimming();
	}
	else if ( GetControlState() == CS_Flying )
	{
		if ( GetMovementState() == MS_Flying )
		{
			PlayFlying();
		}
		else if ( GetMovementState() == MS_Waiting )
		{
			PlayWaiting();
		}
	}
}

function AnimEndEx( int Channel )
{    
	if ( Channel == 1 )
    {        
		if ( GetUpperBodyState() == UB_WeaponUp )
        {
            SetUpperBodyState( UB_Alert );
        }
		else if ( GetUpperBodyState() == UB_Firing )
        {
			SetUpperBodyState( UB_Alert );					
        }
		else if ( GetUpperBodyState() == UB_ReloadFinished )
        {
            SetUpperBodyState( UB_Alert );
        }
        else if ( GetUpperBodyState() == UB_ShieldDown ) // Player is bringing shield up from the down position
        {
            SetUpperBodyState( UB_ShieldUp );
        }
        else if ( GetUpperBodyState() == UB_ShieldUp ) // Player is done bringing shield up from the down position
        {
            if ( ShieldProtection )
            {
                SetUpperBodyState( UB_ShieldAlert );
            }
            else
            {
                SetUpperBodyState( UB_Alert );
            }
        }
	}
    else if ( Channel == 2 )    
    {
		// Don't clear out channel 2 if we are swimming or jetpacking
		if (
		   ( GetPostureState() != PS_Swimming ) && ( GetPostureState() != PS_Jetpack ) 
		   )
        {			
            PlayBottomAnim( 'None',,,,true );
        }
    }
    else if ( Channel == 3 )
    {
		// Don't clear out channel 2 if we are jetpacking
		if (
			( GetPostureState() != PS_Swimming ) &&	( GetPostureState() != PS_Jetpack ) 
		   )
		{
			PlaySpecialAnim( 'None',1.0,,,true );
		}
    }
}

function ChangeCollisionHeightToStanding()
{
	if ( bFullyShrunk )
		return;

	DestinationCollisionHeight  = default.CollisionHeight;
	OriginalCollisionHeight     = CollisionHeight;
	CollisionHeightStartTime    = Level.TimeSeconds;
}

function ChangeCollisionHeightToCrouching()
{
	if ( bFullyShrunk )
		return;

	OriginalCollisionHeight     = CollisionHeight;				
	DestinationCollisionHeight  = DuckCollisionHeight;
	CollisionHeightStartTime    = Level.TimeSeconds;
}

function ChangeCollisionToShrunken()
{
	OriginalCollisionHeight     = CollisionHeight;
	DestinationCollisionHeight  = FMax( default.CollisionHeight*0.25, 12.6 );
	CollisionHeightStartTime    = Level.TimeSeconds;

	// Adjust radius now
	SetCollisionSize( default.CollisionRadius*0.35, CollisionHeight );
}

function PostureStateChange_Standing(EPostureState OldState) 
{	        
	if ( !bFullyShrunk )
	{
	    BaseEyeHeight = default.BaseEyeHeight;
	}
	// If we moved to this state from crouching, rise.
    if (OldState == PS_Crouching)
		PlayRise();
    else if (OldState == PS_Swimming)
        PlayRise();
}

function PostureStateChange_Climbing(EPostureState OldState) 
{	        
}

function PostureStateChange_Crouching(EPostureState OldState) 
{			
    // If we moved to this state from standing, duck.
    if ( OldState == PS_Standing )
    {
		if ( !bFullyShrunk )
		{
			BaseEyeHeight = 0;
		}

		if ( GetMovementState() == MS_Waiting )
			PlayDuck();
		else
			PlayToCrawling();
    }
}

function PostureStateChange_Jetpack(EPostureState OldState) 
{	
    PlayJetpacking();
}

function PostureStateChange_Jumping(EPostureState OldState) 
{
    PlayJump();
}

function PostureStateChange_Swimming(EPostureState OldState) 
{
	// Where we've come from, we need to swim.
	PlaySwimming();
}

function PostureStateChange_Turret(EPostureState OldState) 
{	        
    BaseEyeHeight = default.BaseEyeHeight;
}

function MovementStateChange_Waiting(EMovementState OldState) 
{
	if (GetPostureState() == PS_Crouching)
		PlayDuck();
	else if (GetPostureState() != PS_Jumping)
		PlayToWaiting( 0.2f );
}

function MovementStateChange_Walking(EMovementState OldState) 
{
	if (GetPostureState() == PS_Crouching)
		PlayToCrawling();
	else if (GetPostureState() != PS_Jumping)
		PlayToWalking();
}

function MovementStateChange_Running(EMovementState OldState) 
{
	if (GetPostureState() == PS_Crouching)
		PlayToCrawling();
	else if (GetPostureState() != PS_Jumping)
		PlayToRunning();
}

function MovementStateChange_RopeIdle(EMovementState OldState) 
{
	PlayRopeIdle();
}

function MovementStateChange_RopeClimbUp(EMovementState OldState) 
{
	PlayRopeClimbUp();
}

function MovementStateChange_RopeClimbDown(EMovementState OldState) 
{
	PlayRopeClimbDown();
}

function MovementStateChange_LadderIdle(EMovementState OldState) 
{
	PlayLadderIdle();
}

function MovementStateChange_LadderClimbUp(EMovementState OldState) 
{
	PlayLadderClimbUp();
}

function MovementStateChange_LadderClimbDown(EMovementState OldState) 
{
	PlayLadderClimbDown();
}

function MovementStateChange_Jetpack(EMovementState OldState) 
{
}

function MovementStateChange_Flying(EMovementState OldState) 
{
	PlayFlying();
}

function UpperBodyStateChange_Relaxed(EUpperBodyState OldState) 
{
	// We are relaxed, let down our guard.
	PlayTopRelaxedIdle();
}

function UpperBodyStateChange_Alert(EUpperBodyState OldState) 
{
	// We are alert, change our weapon pose.
	PlayTopAlertIdle();
	Super.UpperBodyStateChange_Alert(OldState);
}

function UpperBodyStateChange_ShieldUp(EUpperBodyState OldState) 
{
	ShieldPlayUp();
	Super.UpperBodyStateChange_ShieldUp(OldState);
}

function UpperBodyStateChange_ShieldDown(EUpperBodyState OldState) 
{
    ShieldPlayDown();
	Super.UpperBodyStateChange_ShieldDown(OldState);
}

function UpperBodyStateChange_ShieldAlert(EUpperBodyState OldState) 
{
	ShieldPlayIdle();
	Super.UpperBodyStateChange_ShieldAlert(OldState);
}

function UpperBodyStateChange_HoldOneHanded(EUpperBodyState OldState) 
{
	PlayHoldOneHanded();
	Super.UpperBodyStateChange_HoldOneHanded(OldState);
}

function UpperBodyStateChange_HoldTwoHanded(EUpperBodyState OldState) 
{
	PlayHoldTwoHanded();
	Super.UpperBodyStateChange_HoldTwoHanded(OldState);
}

function UpperBodyStateChange_WeaponDown(EUpperBodyState OldState) 
{
}

function UpperBodyStateChange_WeaponUp(EUpperBodyState OldState) 
{
}

function UpperBodyStateChange_Firing(EUpperBodyState OldState) 
{
}

function UpperBodyStateChange_Reloading(EUpperBodyState OldState) 
{
}

function LadderStateChange_Forward( ELadderState OldState )
{
    switch( GetMovementState() )
    {
    case MS_LadderIdle:
        PlayLadderIdle();
        break;
    case MS_LadderClimbUp:
        PlayLadderClimbUp();
        break;
    case MS_LadderClimbDown:
        PlayLadderClimbDown();
        break;
    default:
        break;       
    }
}

function LadderStateChange_Other( ELadderState OldState )
{
    switch( GetMovementState() )
    {
    case MS_LadderIdle:
        PlayWaiting();
        break;
    case MS_LadderClimbUp:
        PlayWalking();
        break;
    case MS_LadderClimbDown:
        PlayWalking();
        break;
    default:
        break;       
    }
}

function RopeClimbStateChange_ClimbUp( ERopeClimbState OldState )
{
    PlayRopeClimbUp();
}

function RopeClimbStateChange_ClimbDown( ERopeClimbState OldState )
{
    PlayRopeClimbDown();
}

function RopeClimbStateChange_ClimbNone( ERopeClimbState OldState )
{
    PlayRopeIdle();
}

function PlayHit( float Damage, vector HitLocation, class<DamageType> DamageType, vector Momentum )
{
}

function PlayChatting();




/*-----------------------------------------------------------------------------
	Movement
	NOTES:
		* ControlStates dictate movement physics.
		* ControlStates should not directly dictate animation.
		* Need to collapse the PlayerMove functions for simplification.
-----------------------------------------------------------------------------*/

function PlayerMove( float DeltaTime )
{
	switch (GetControlState())
	{
		case CS_Normal:
			PlayerMove_Normal(DeltaTime);
			break;
		case CS_Swimming:
			PlayerMove_Swimming(DeltaTime);
			break;
		case CS_Flying:
			PlayerMove_Flying(DeltaTime);
			break;
		case CS_Dead:
			PlayerMove_Dead(DeltaTime);
			break;
		case CS_Stasis:
			PlayerMove_Stasis(DeltaTime);
			break;
		case CS_Frozen:
			PlayerMove_Frozen(DeltaTime);
			break;
        case CS_Rope:
            PlayerMove_Rope(DeltaTime);
            break;
        case CS_Ladder:
            PlayerMove_Ladder(DeltaTime);
            break;
		case CS_Jetpack:
			PlayerMove_Jetpack(DeltaTime);
			break;
	}

    if ( GetControlState() != CS_ROPE )
        baseRotation = viewRotation;
}

function PlayerMove_Normal( float DeltaTime )
{
	local vector X,Y,Z, NewAccel;
	local rotator OldRotation;
	local float Speed2D;
	local float Roll;
	local bool bNoMove;

    // Update rotation.
	OldRotation = Rotation;
	aForward *= 0.4;
	aStrafe  *= 0.4;
	aLookup  *= 0.24;
	aTurn    *= 0.24;
	UpdateRotation(DeltaTime);

	GetAxes(Rotation,X,Y,Z);

	if (bOnWire)
	{	
		if (OnWireAlpha >= 1.0) 
			bOnWire = false;
		NewAccel = aForward * Normal(OnWireForwardsActor.Location - OnWireBackwardsActor.Location);
	} else
	{
		// Update acceleration.
		NewAccel = aForward*X + aStrafe*Y; 
		NewAccel.Z = 0;
	}

	if (Physics == PHYS_Walking)
	{
		// If walking, look up/down stairs - unless player is rotating view.
		if ( !bKeyboardLook && (bLook == 0) && !RotateToDesiredView )
		{
			if ( bLookUpStairs )
				ViewRotation.Pitch = FindStairRotation(deltaTime);
			else if ( bCenterView )
			{
				ViewRotation.Pitch = ViewRotation.Pitch & 65535;
				if (ViewRotation.Pitch > 32768)
					ViewRotation.Pitch -= 65536;
				ViewRotation.Pitch = ViewRotation.Pitch * (1 - 12 * FMin(0.0833, deltaTime));
				if ( Abs(ViewRotation.Pitch) < 1000 )
					ViewRotation.Pitch = 0;	
			}
		}

		Speed2D = Sqrt(Velocity.X * Velocity.X + Velocity.Y * Velocity.Y);

		// Add bobbing when walking.
		CheckBob(DeltaTime, Speed2D, Y);
	}	
	else
	{ 
		BobTime = 0;
		WalkBob = WalkBob * (1 - FMin(1, 8 * deltatime));
	}

	if ( Role < ROLE_Authority ) // Then save this move and replicate it.
		ReplicateMove(DeltaTime, NewAccel, OldRotation - Rotation);
	else
		ProcessMove(DeltaTime, NewAccel, OldRotation - Rotation);	

	if ( GetControlState() != CS_Jetpack )
	{
		bPressedJump = bBunnyHop;
		bBunnyHop = false;
	}
}

function PlayerMove_Jetpack( float DeltaTime )
{
	local vector	X,Y,Z, NewAccel;
	local rotator	OldRotation;
	local float		Roll;
	local bool		bNoMove;

    // Update rotation.
	Roll=ViewRotation.Roll;
	ViewRotation.Roll=0;
	GetAxes(ViewRotation,X,Y,Z);
	ViewRotation.Roll=Roll;
	aForward *= 0.1;
	aStrafe  *= 0.1;
	aLookup  *= 0.24;
	aTurn    *= 0.24;
	aUp		 *= 0.1;

	GetAxes(Rotation,X,Y,Z);

	// Update acceleration.
	NewAccel = aForward*X + aStrafe*Y; 
	NewAccel.Z = 0;

	// Apply upward thrust.
	bNoMove = true;
	Acceleration = vect(0,0,0);
	if ( bPressedJump )
	{
		Acceleration.Z += JetpackForce;
		JetpackForce   += 3000 * DeltaTime;
		if ( JetpackForce > 4000 )
			JetpackForce = 4000;
		bNoMove = false;
	}

	if ( bDuck != 0 )
	{
		Acceleration.Z -= JetpackForce;
		JetpackForce += 3000 * DeltaTime;
		if ( JetpackForce > 4000 )
			JetpackForce = 4000;
		bNoMove = false;
	}

	// Apply forward thrust.
	if ( bool(aForward) || bool(aStrafe) )
	{
		Acceleration += aForward*X*8 + aStrafe*Y*8;
		bNoMove		 = false;
	}

	HandleJetpacking();

	// Push camera down for forward motion.
	if ( bool(aForward) && (Normalize(ViewRotation).Pitch > -4800) )
		ViewRotation.Pitch -= aForward*DeltaTime;

	// Roll the camera with lateral motion.
	ViewRotation.Roll += (aStrafe*DeltaTime)*5.0;
	ViewRotation.Roll += (aTurn*DeltaTime)*5.0;

	if ( Level.NetMode == NM_Standalone && bNoMove )
	{
		// Hover in place.
		Acceleration.Z+=(sin((Level.timeSeconds*3.2))*10000)*DeltaTime;
		Acceleration.Z+=(cos((Level.timeSeconds/2))*3000)*DeltaTime;
	}

	NewAccel = Acceleration;
	UpdateRotation(DeltaTime);

	if ( Role < ROLE_Authority ) // Then save this move and replicate it.
		ReplicateMove(DeltaTime, NewAccel, OldRotation - Rotation);
	else
		ProcessMove(DeltaTime, NewAccel, OldRotation - Rotation);	


	// Normally we would set bPressedJump to false here,
	// but we want players to be able to hold down jump when
	// in a jetpack
	//bPressedJump = false;
}

function HandleJetpacking()
{
	if ( !bJetpacking && ( bWasForward || bWasBack || bWasLeft || bWasRight || bool(bDuck) || bPressedJump ) )
		JetpackDown();
	else if ( bJetpacking && ( !bWasForward && !bWasBack && !bWasLeft && !bWasRight && !bool(bDuck) ) && !bPressedJump )
		JetpackUp();
}

function PlayerMove_Swimming(float DeltaTime)
{
	local rotator oldRotation;
	local vector X,Y,Z, NewAccel;
	local float Speed2D;
	
	GetAxes(ViewRotation,X,Y,Z);

	aForward *= 0.2;
	aStrafe  *= 0.1;
	aLookup  *= 0.24;
	aTurn    *= 0.24;
	aUp		 *= 0.1;  
		
	NewAccel = aForward*X + aStrafe*Y + aUp*vect(0,0,1); 
	
	// Add bobbing when swimming.
	Speed2D = Sqrt(Velocity.X * Velocity.X + Velocity.Y * Velocity.Y);
	WalkBob = Y * Bob *  0.5 * Speed2D * sin(4.0 * Level.TimeSeconds);
	WalkBob.Z = Bob * 1.5 * Speed2D * sin(8.0 * Level.TimeSeconds);

	// Update rotation.
	oldRotation = Rotation;
	UpdateRotation(DeltaTime);

	if ( Role < ROLE_Authority ) // Then save this move and replicate it.
		ReplicateMove(DeltaTime, NewAccel, OldRotation - Rotation);
	else
		ProcessMove(DeltaTime, NewAccel, OldRotation - Rotation);
	
	bPressedJump = false;
}

function PlayerMove_Flying(float DeltaTime)
{
	local rotator newRotation;
	local vector X,Y,Z;

	GetAxes(ViewRotation,X,Y,Z);

	aForward *= 0.4;
	aStrafe  *= 0.4;
	aLookup  *= 0.24;
	aTurn    *= 0.24;
	
	Acceleration = aForward*X + aStrafe*Y + aUp*vect(0,0,1);  

	UpdateRotation(DeltaTime);

	if ( Role < ROLE_Authority ) // then save this move and replicate it
		ReplicateMove(DeltaTime, Acceleration, rot(0,0,0));
	else
		ProcessMove(DeltaTime, Acceleration, rot(0,0,0));
}

function PlayerMove_Rope(float DeltaTime)
{
	local rotator newRotation;
	local vector X,Y,Z;

	GetAxes(ViewRotation,X,Y,Z);

	aForward *= 0.1;
	aStrafe  *= 0.1;
	aLookup  *= 0.24;
	aTurn    *= 0.24;
	aUp		 *= 0.1;
	
	Acceleration = aForward*X + aStrafe*Y + aUp*vect(0,0,1);  
	

    ViewRotation = baseRotation;
    UpdateRotation(DeltaTime);
    baseRotation = ViewRotation;

    ViewRotation.Roll+=(aTurn*DeltaTime)*(15);

	if ( Role < ROLE_Authority ) // then save this move and replicate it
		ReplicateMove(DeltaTime, Acceleration, rot(0,0,0));
	else
		ProcessMove(DeltaTime, Acceleration, rot(0,0,0));
   
    ViewRotation.Pitch = ViewRotation.Pitch & 65535;
	if ((ViewRotation.Pitch > 18000) && (ViewRotation.Pitch < 49152))
    {
		ViewRotation.Pitch = 49152;
	}
}

function PlayerMove_Ladder(float DeltaTime)
{
    PlayerMove_Flying(DeltaTime);
}

function PlayerMove_Dead(float DeltaTime)
{
	local vector X,Y,Z;

	if ( bPressedJump )
	{
		Fire();
		bPressedJump = false;

	}
	GetAxes(ViewRotation,X,Y,Z);

	// Update view rotation.
	aLookup				*= 0.24;
	aTurn				*= 0.24;
	ViewRotation.Yaw	+= 32.0 * DeltaTime * aTurn;
	ViewRotation.Pitch	+= 32.0 * DeltaTime * aLookUp;
	ViewRotation.Pitch	= ViewRotation.Pitch & 65535;

	if ((ViewRotation.Pitch > 18000) && (ViewRotation.Pitch < 49152))
	{
		if (aLookUp > 0) 
			ViewRotation.Pitch = 18000;
		else
			ViewRotation.Pitch = 49152;
	}
	if ( Role < ROLE_Authority ) // Then save this move and replicate it
		ReplicateMove(DeltaTime, vect(0,0,0), rot(0,0,0));

	UpdateRotation(DeltaTime);

	ViewShake(DeltaTime);
	ViewFlash(DeltaTime);
}

function PlayerMove_Stasis(float DeltaTime)
{
	local vector X,Y,Z;
		
	GetAxes( ViewRotation,X,Y,Z );

	aLookup  *= 0.24;
	aTurn    *= 0.24;

	if ( !bFixedCamera )
		UpdateRotation(DeltaTime);

	/*
	// Update view rotation.
	if ( !bFixedCamera )
	{
		aLookup  *= 0.24;
		aTurn    *= 0.24;
		ViewRotation.Yaw += 32.0 * DeltaTime * aTurn;
		ViewRotation.Pitch += 32.0 * DeltaTime * aLookUp;
		ViewRotation.Pitch = ViewRotation.Pitch & 65535;
		if ((ViewRotation.Pitch > 18000) && (ViewRotation.Pitch < 49152))
		{
			if (aLookUp > 0) 
				ViewRotation.Pitch = 18000;
			else
				ViewRotation.Pitch = 49152;
		}
	}
	else if ( ViewTarget != None )
	{
		ViewRotation = ViewTarget.Rotation;
	}
	*/

	ViewShake(DeltaTime);
	ViewFlash(DeltaTime);

	if ( Role < ROLE_Authority ) // Then save this move and replicate it.
		ReplicateMove(DeltaTime, vect(0,0,0), rot(0,0,0));
	else
		ProcessMove(DeltaTime, vect(0,0,0), rot(0,0,0));
	
	bPressedJump = false;
}

function PlayerMove_Frozen(float DeltaTime)
{
	UpdateRotation(DeltaTime);
	ViewShake(DeltaTime);
	ViewFlash(DeltaTime);

	if ( Role < ROLE_Authority ) // Then save this move and replicate it.
		ReplicateMove( DeltaTime, vect(0,0,0), rot(0,0,0) );
	else
		ProcessMove( DeltaTime, vect(0,0,0), rot(0,0,0) );
	
	bPressedJump = false;
}

function CheckBob(float DeltaTime, float Speed2D, vector Y)
{
	local float OldBobTime;

	OldBobTime = BobTime;
	if ( Speed2D < 10 )
		BobTime += 0.2 * DeltaTime;
	else
		BobTime += DeltaTime * (0.3 + 0.7 * Speed2D/GroundSpeed);
	WalkBob = Y * 0.65 * Bob * Speed2D * sin(6 * BobTime);
	AppliedBob = AppliedBob * (1 - FMin(1, 16 * deltatime));
	if ( LandBob > 0.01 )
	{
		AppliedBob += FMin(1, 16 * deltatime) * LandBob;
		LandBob *= (1 - 8*Deltatime);
	}
	if ( Speed2D < 10 )
		WalkBob.Z = AppliedBob + Bob * 30 * sin(12 * BobTime);
	else
		WalkBob.Z = AppliedBob + Bob * Speed2D * sin(12 * BobTime);
}

function ServerMove
(
	float TimeStamp, 
	vector InAccel, 
	vector ClientLoc,
	bool NewbRun,
	bool NewbDuck,
	bool NewbJumpStatus, 
	bool bFired,
	bool bAltFired,
    byte moveButtons,
	byte ClientRoll, 
	int View,
	optional byte OldTimeDelta,
	optional int OldAccel
)
{
	local float DeltaTime, clientErr, OldTimeStamp;
	local rotator DeltaRot, Rot;
	local vector Accel, LocDiff;
	local int maxPitch, ViewPitch, ViewYaw;
	local actor OldBase;
	local bool NewbPressedJump, OldbRun, OldbDuck;

	if ( GetControlState() == CS_Stasis )
	{
		View = (32767 & (ViewRotation.Pitch/2)) * 32768 + (32767 & (ViewRotation.Yaw/2));	
	}

	// If this move is outdated, discard it.
	if ( CurrentTimeStamp >= TimeStamp )
		return;

	// if OldTimeDelta corresponds to a lost packet, process it first
	if (  OldTimeDelta != 0 )
	{
		OldTimeStamp = TimeStamp - float(OldTimeDelta)/500 - 0.001;
		if ( CurrentTimeStamp < OldTimeStamp - 0.001 )
		{
			// split out components of lost move (approx)
			Accel.X = OldAccel >>> 23;
			if ( Accel.X > 127 )
				Accel.X = -1 * (Accel.X - 128);
			Accel.Y = (OldAccel >>> 15) & 255;
			if ( Accel.Y > 127 )
				Accel.Y = -1 * (Accel.Y - 128);
			Accel.Z = (OldAccel >>> 7) & 255;
			if ( Accel.Z > 127 )
				Accel.Z = -1 * (Accel.Z - 128);
			Accel *= 20;
			
			OldbRun = ( (OldAccel & 64) != 0 );
			OldbDuck = ( (OldAccel & 32) != 0 );
			NewbPressedJump = ( (OldAccel & 16) != 0 );
			if ( NewbPressedJump )
			{
				bJumpStatus = NewbJumpStatus;
			}

			MoveAutonomous(OldTimeStamp - CurrentTimeStamp, OldbRun, OldbDuck, NewbPressedJump, Accel, rot(0,0,0));
			CurrentTimeStamp = OldTimeStamp;
		}
	}		

	// View components
	ViewPitch        = View/32768;
	ViewYaw          = 2 * (View - 32768 * ViewPitch);
	ViewPitch       *= 2;

    ViewRotationInt  = View;

	// Make acceleration.
	Accel = InAccel/10;

	NewbPressedJump = (bJumpStatus != NewbJumpStatus);	
	bJumpStatus = NewbJumpStatus;

    // Forward, back, left and right statuses
    bWasForward = bool(moveButtons & 0x01);
    bWasBack    = bool(moveButtons & 0x02);
    bWasLeft    = bool(moveButtons & 0x04);
    bWasRight   = bool(moveButtons & 0x08);

	// Handle firing and alt-firing.
	if ( bFired )
	{
		// If we received a fire message from the server, fire.
		if ( bFire == 0 )
			Fire();
	}
	else
	{
		if ( (bFire == 1) && (Weapon != None) )
			Weapon.UnFire();
		bFire = 0;
	}

	if ( bAltFired )
	{
		if ( bAltFire == 0 )
			AltFire();
	}
	else
	{
		if ( (bAltFire == 1) && (Weapon != None) )
			Weapon.UnAltFire();
		bAltFire = 0;
	}

	// Save move parameters.
	DeltaTime = TimeStamp - CurrentTimeStamp;
	if ( ServerTimeStamp > 0 )
	{
		// allow 1% error
		TimeMargin += DeltaTime - 1.01 * (Level.TimeSeconds - ServerTimeStamp);
		if ( TimeMargin > MaxTimeMargin )
		{
			// player is too far ahead
			TimeMargin -= DeltaTime;
			if ( TimeMargin < 0.5 )
				MaxTimeMargin = Default.MaxTimeMargin;
			else
				MaxTimeMargin = 0.5;
			DeltaTime = 0;
		}
	}

	CurrentTimeStamp = TimeStamp;
	ServerTimeStamp = Level.TimeSeconds;
	Rot.Roll = 256 * ClientRoll;
	Rot.Yaw = ViewYaw;
	/*
	if ( (Physics == PHYS_Swimming) || (Physics == PHYS_Flying) )
		maxPitch = 2;
	else
		maxPitch = 1;
	If ( (ViewPitch > maxPitch * RotationRate.Pitch) && (ViewPitch < 65536 - maxPitch * RotationRate.Pitch) )
	{
		If (ViewPitch < 32768) 
			Rot.Pitch = maxPitch * RotationRate.Pitch;
		else
			Rot.Pitch = 65536 - maxPitch * RotationRate.Pitch;
	}
	else
		Rot.Pitch = ViewPitch;
	*/

    // Set the viewrotation
    ViewRotation.Pitch  = ViewPitch;
	ViewRotation.Yaw    = ViewYaw;
	ViewRotation.Roll   = 0;

    if ( GetMovementState() != MS_Waiting )
    {
    	DeltaRot            = (Rotation - Rot);
	    bIsTurning = false;
        SetRotation(Rot);
    }
    else
    {        
        SmoothRotation = Rot;
    }

	OldBase = Base;

	// Perform actual movement.
	if ( (Level.Pauser == "") && (DeltaTime > 0) )
    {
		MoveAutonomous(DeltaTime, NewbRun, NewbDuck, NewbPressedJump, Accel, DeltaRot);
    }

	// Accumulate movement error.
	if ( Level.TimeSeconds - LastUpdateTime > 500.0/Player.CurrentNetSpeed )
    {
		ClientErr = 10000;
    }
	else if ( Level.TimeSeconds - LastUpdateTime > 180.0/Player.CurrentNetSpeed )
	{
		LocDiff = Location - ClientLoc;
		ClientErr = LocDiff Dot LocDiff;
	}

	// If client has accumulated a noticeable positional error, correct him.
	if ( ClientErr > 3 )
	{
		if ( Mover(Base) != None )
			ClientLoc = Location - Base.Location;
		else
			ClientLoc = Location;
		//log("Client Error at "$TimeStamp$" is "$ClientErr$" with acceleration "$Accel$" LocDiff "$LocDiff$" Physics "$Physics);
		LastUpdateTime = Level.TimeSeconds;
		
        if ( CurrentRope != None )
        {
            ClientAdjustRopePosition
	    	(
                CurrentRope.m_AngularDisplacement.X,
                CurrentRope.m_AngularDisplacement.Y,
                CurrentRope.m_AngularVelocity.X,
                CurrentRope.m_AngularVelocity.Y
		    );
        }

        ClientAdjustPosition
	    (
		    TimeStamp, 
			GetControlState(),
			Physics, 
			ClientLoc.X, 
			ClientLoc.Y, 
			ClientLoc.Z, 
			Velocity.X, 
			Velocity.Y, 
			Velocity.Z,
			Base
		);
	}
	//log("Server "$Role$" moved "$self$" stamp "$TimeStamp$" location "$Location$" Acceleration "$Acceleration$" Velocity "$Velocity);
}	

function ChangedMoveDirection()
{
	PlayToRunning();
}

function ProcessMove( float DeltaTime, vector newAccel, rotator DeltaRot )
{
	local vector OldAccel;
	local vector X,Y,Z,Temp,Dir;
	local float MoveDirection;

	if ( GetControlState() == CS_Normal )
	{
		OldAccel = Acceleration;
		Acceleration = NewAccel;

		GetAxes(Rotation, X,Y,Z);
		Dir = Normal(Acceleration);
		bWasBackPedaling = bBackPedaling;
		
        if ( bPressedJump )
		{
			DoJump();
		}

        // Adjust collision size for ducking or not
        if ( !IsSpectating() )
		{
			if ( !bIsDucking )
		    {
			    if ( bDuck != 0 ) // starting to duck
				{
					bIsDucking = true;
					if ( GetControlState() != CS_Jetpack )
						ChangeCollisionHeightToCrouching();
				}
			}
			else
			{
				if ( bDuck == 0 ) // no longer ducking
				{
					bIsDucking = false;
					ChangeCollisionHeightToStanding();
				}
			}
		}

        if ( Dir Dot X < -0.25 )
			bBackPedaling = true;
		else
			bBackPedaling = false;


		// Check to see if we had a change in our posture.
		if ( GetPostureState() == PS_Standing )
		{
			// If we just started to duck, switch to a crouched position.
			if ( bDuck != 0 )
            {
                //Log( "Changing from PS_Standing to PS_Crouching" );
				//BroadcastMessage("Changing from PS_Standing to PS_Crouching");
				SetPostureState( PS_Crouching );
            }

			if ( bPressedJump )
            {
				//Log( "Changing from PS_Standing to PS_Jumping" );
				SetPostureState( PS_Jumping );
			}
		}
		else if ( GetPostureState() == PS_Crouching )
		{
			// If we just started to stand, switch to a standing position.
			if ( bDuck == 0 )
            {
                //Log( "Changing from PS_Crouching to PS_Standing" );
				SetPostureState( PS_Standing );
            }

			if ( bPressedJump )
            {
				//Log( "Changing from PS_Crouching to PS_Jumping" );
				SetPostureState( PS_Jumping );
            }
		}
		else if ( GetPostureState() == PS_Jumping )
		{		
            if ( Physics == PHYS_Walking ) 
            {
                // If we just landed, switch to a standing/crouching position.
                //Log( "Changing from PS_Jumping to PS_Standing" );
				SetPostureState( PS_Standing );
            }
		}
		else if ( GetPostureState() == PS_Swimming )
		{
			// We shouldn't be swimming now, so let's stand.
			SetPostureState( PS_Standing );
		}

		// Check to see if we had a change in our movement state.
		if ( GetMovementState() == MS_Waiting )
		{
			// If we started moving, walk or run.
			if ( Acceleration != vect(0,0,0) )
			{
				if ( bIsWalking )
					SetMovementState( MS_Walking );
				else
					SetMovementState( MS_Running );
			}
		}
		else if ( GetMovementState() == MS_Walking )
		{
			if ( Acceleration == vect(0,0,0) )
				SetMovementState( MS_Waiting );
			else if ( !bIsWalking )
				SetMovementState( MS_Running );
			else if ( ( bBackPedaling != bWasBackPedaling ) && !bIsTurning )
				SetMovementState( MS_Walking );
		}
		else if ( GetMovementState() == MS_Running )
		{
			// Check to see if we changed direction while running.
			// Used by the animation system to interrupt backpedaling with forward movement.
			GetAxes( Rotation, X,Y,Z );
			Temp = Normal( Acceleration );
			MoveDirection = Temp dot X;
			if ( MoveDirection / MoveDirection != LastMoveDirection )
			{
				ChangedMoveDirection();
				LastMoveDirection = MoveDirection / MoveDirection;
			}
			if ( Acceleration == vect(0,0,0) )
				SetMovementState( MS_Waiting );
			else if ( bIsWalking )
				SetMovementState( MS_Walking );
			else if ( ( bBackPedaling != bWasBackPedaling ) && !bIsTurning )
				SetMovementState( MS_Running );
		}
	} 
    else if ( GetControlState() == CS_Ladder )
    {
        if ( bPressedJump )
        {
            DoJump();
            JumpOffLadder();
            Goto 'Out';
        }

        if ( !bUpdating && bOnLadder && ( GetPostureState() != PS_Ladder ) )
        {
            SetPostureState( PS_Ladder );
        }

        // Check to see if there are changes in Movement              
        if ( GetMovementState() == MS_LadderIdle )
        {
            if ( Velocity.Z > 0 )
				SetMovementState( MS_LadderClimbUp );
            else if ( Velocity.Z < 0 )
                SetMovementState( MS_LadderClimbDown );
        } 
        else  if ( GetMovementState() == MS_LadderClimbUp )
        {
            if ( Velocity.Z == 0 )
                SetMovementState( MS_LadderIdle );
            else if ( Velocity.Z < 0 )
                SetMovementState( MS_LadderClimbDown );
        }
        else if ( GetMovementState() == MS_LadderClimbDown )
        {
            if ( Velocity.Z == 0 )
                SetMovementState( MS_LadderIdle );
            else if ( Velocity.Z > 0 )
                SetMovementState( MS_LadderClimbUp );
        }
        else // unknown movement state, so figure out where we are supposed to be exactly
        {
            if ( Velocity.Z == 0 )
                SetMovementState( MS_LadderIdle );
            else if ( Velocity.Z > 0 )
			    SetMovementState( MS_LadderClimbUp );
            else if ( Velocity.Z < 0 )
                SetMovementState( MS_LadderClimbDown );
        }
    }
    else if ( GetControlState() == CS_Rope )
    {
        if ( bPressedJump )
        {
            DoJump();
            Goto 'Out';
        }

        if ( !bUpdating && bOnRope && ( GetPostureState() != PS_Rope ) )
        {
            SetPostureState(PS_Rope);
        }
    
        // Check to see if there are changes in Movement              
        if ( GetMovementState() == MS_RopeIdle ) // Idle to moving
        {
            if ( RopeClimbState == RS_ClimbUp )
				SetMovementState( MS_RopeClimbUp );
            else if ( RopeClimbState == RS_ClimbDown )
                SetMovementState( MS_RopeClimbDown );
        } 
        else  if ( GetMovementState() == MS_RopeClimbUp )
        {
            if ( RopeClimbState == RS_ClimbNone )
                SetMovementState( MS_RopeIdle );
            else if ( RopeClimbState == RS_ClimbDown )
                SetMovementState( MS_RopeClimbDown );
        }
        else if ( GetMovementState() == MS_RopeClimbDown )
        {
            if ( RopeClimbState == RS_ClimbNone )
                SetMovementState( MS_RopeIdle );
            else if ( RopeClimbState == RS_ClimbUp )
                SetMovementState( MS_RopeClimbUp );
        }
        else // unknown movement state, so figure out where we are supposed to be exactly
        {
            /* This breaks stuff for client side prediction, so leave it out
            if ( RopeClimbState == RS_ClimbNone )
                SetMovementState( MS_RopeIdle );
            else if ( RopeClimbState == RS_ClimbUp )
			    SetMovementState( MS_RopeClimbUp );
            else if ( RopeClimbState == RS_ClimbDown )
                SetMovementState( MS_RopeClimbDown );
                */
        }
    }
	else if ( GetControlState() == CS_Swimming ) 
	{
		// If we aren't swimming, then we should be!
		if ( !bUpdating && GetPostureState() != PS_Swimming )
			SetPostureState( PS_Swimming );

		GetAxes( ViewRotation,X,Y,Z );
		Acceleration = NewAccel;
		bUpAndOut = ( ( X Dot Acceleration ) > 0 ) && ( ( Acceleration.Z > 0) || ( ViewRotation.Pitch > 2048 ) );
		if ( bUpAndOut && !Region.Zone.bWaterZone && CheckWaterJump( Temp ) )
			DoWaterJump();
	}
	else if ( GetControlState() == CS_Flying )
	{
		Acceleration	= Normal( NewAccel );
		Velocity		= Normal( NewAccel ) * GroundSpeed;
		AutonomousPhysics( DeltaTime );

		if ( GetMovementState() == MS_Waiting )
		{
			// If we started moving, walk or run.
			if ( Acceleration != vect(0,0,0) )
			{
				SetMovementState( MS_Flying );
			}
		}
		else if ( GetMovementState() == MS_Flying )
		{
			// Check to see if we changed direction while running.
			// Used by the animation system to interrupt backpedaling with forward movement.
			if ( Acceleration == vect(0,0,0) )
				SetMovementState( MS_Waiting );
		}

		return;
	}
	else if ( GetControlState() == CS_Jetpack )
	{
		Acceleration = NewAccel;

        if ( !bUpdating && GetPostureState() != PS_Jetpack )
        {
            SetPostureState( PS_Jetpack );
        }
	}

Out:
	Acceleration = newAccel;
}

final function MoveAutonomous
(	
	float	DeltaTime, 	
	bool	NewbRun,
	bool	NewbDuck,
	bool	NewbPressedJump, 
	vector	newAccel, 
	rotator DeltaRot
)
{
	if ( NewbRun )
		bRun = 1;
	else
		bRun = 0;

	if ( NewbDuck )
		bDuck = 1;
	else
		bDuck = 0;
	
	bPressedJump = NewbPressedJump;

	HandleWalking();
	
	if ( GetControlState() == CS_Jetpack )
		HandleJetpacking();

	ProcessMove(DeltaTime, newAccel, DeltaRot);	
	AutonomousPhysics(DeltaTime);
}


// ClientAdjustPosition - Pass disp and vel in components so they don't get Rounded.
function ClientAdjustRopePosition
    (
    float RopeAngularDisplacementX,
    float RopeAngularDisplacementY,
    float RopeAngularVelocityX,
    float RopeAngularVelocityY
    )
{
    if ( bOnRope && CurrentRope != None )
    {
        // We're on a rope, so set the angular displacement back to what the server says
        CurrentRope.m_angularDisplacement.X = RopeAngularDisplacementX;
        CurrentRope.m_angularDisplacement.Y = RopeAngularDisplacementY;
        CurrentRope.m_angularVelocity.X     = RopeAngularVelocityX;
        CurrentRope.m_angularVelocity.Y     = RopeAngularVelocityY;
    }
}

// ClientAdjustPosition - Pass newloc and newvel in components so they don't get Rounded.
function ClientAdjustPosition
(
	float			TimeStamp, 
	EControlState	newState,
	EPhysics		newPhysics,
	float			NewLocX, 
	float			NewLocY, 
	float			NewLocZ, 
	float			NewVelX, 
	float			NewVelY, 
	float			NewVelZ,
	Actor			NewBase
)
{
	local Decoration Carried;
	local vector	 OldLoc;
	local vector     NewLocation;
	
	// If this is an older adjustment, then just return
	if ( CurrentTimeStamp > TimeStamp )
		return;

	CurrentTimeStamp = TimeStamp;

	// Set new location and new velocity
	NewLocation.X	= NewLocX;
	NewLocation.Y	= NewLocY;
	NewLocation.Z	= NewLocZ;
	Velocity.X		= NewVelX;
	Velocity.Y		= NewVelY;
	Velocity.Z		= NewVelZ;

	SetBase(NewBase);
	if ( Mover(NewBase) != None )
		NewLocation += NewBase.Location;

	//log("Client "$Role$" adjust "$self$" stamp "$TimeStamp$" location "$Location);
	Carried			= CarriedDecoration;
	OldLoc			= Location;
	bCanTeleport	= false;
	SetLocation(NewLocation);
	bCanTeleport	= true;
	
    if ( Carried != None )
	{
		CarriedDecoration = Carried;
		CarriedDecoration.SetLocation(NewLocation + CarriedDecoration.Location - OldLoc);
		CarriedDecoration.SetPhysics(PHYS_None);
		CarriedDecoration.SetBase(self);
	}
    	
	SetPhysics(newPhysics);

	if ( GetControlState() != newState )
    {
        // Don't switch out of CS_Dead
		//Log( "Client Update Position: StateChange:" @ GetControlStateString( newState ) );
		SetControlState(newState);
    }

	bUpdatePosition = true;	
}


function ClientUpdatePosition()
{
	local SavedMove		CurrentMove;
	local int			realbRun, realbDuck;
	local bool			bRealJump;
	local float			AdjPCol, SavedRadius, TotalTime;
	local Pawn			SavedPawn, P;
	local Vector		Dist;

	bUpdatePosition = false;	

	// Save off previous state before running through the saved moves
	realbRun		= bRun;
	realbDuck		= bDuck;
	bRealJump		= bPressedJump;
	CurrentMove		= SavedMoves;
	
	// Set global bool to allow for alternate logic when running a simulation
	bUpdating		= true;

	while ( CurrentMove != None )
	{
		// Check to see if the move is no longer valid (i.e. older than the current time stamp)
		// and remove it.
		if ( CurrentMove.TimeStamp <= CurrentTimeStamp )
		{
			SavedMoves			 = CurrentMove.NextMove;			
			CurrentMove.NextMove = FreeMoves;
			
			FreeMoves			 = CurrentMove;
			FreeMoves.Clear();
			
			CurrentMove			 = SavedMoves;
		}
		else
		{
			// Adjust radius of nearby players with uncertain location.
			if ( TotalTime > 0 )
			{
				for ( P=Level.PawnList; P!=None; P=P.nextPawn )
					if ( (P != self) && (P.Velocity != vect(0,0,0)) && P.bBlockPlayers )
					{
						Dist = P.Location - Location;
						AdjPCol = 0.0004 * PlayerReplicationInfo.Ping * ((P.Velocity - Velocity) Dot Normal(Dist));
						if ( VSize(Dist) < AdjPCol + P.CollisionRadius + CollisionRadius + CurrentMove.Delta * GroundSpeed * (Normal(Velocity) Dot Normal(Dist)) )
						{
							SavedPawn = P;
							SavedRadius = P.CollisionRadius;
							Dist.Z = 0;
							P.SetCollisionSize(FClamp(AdjPCol + P.CollisionRadius, 0.5 * P.CollisionRadius, VSize(Dist) - CollisionRadius - P.CollisionRadius), P.CollisionHeight);
							break;
						}
					} 
			}

			// Accumulate time
			TotalTime += CurrentMove.Delta;
					
			MoveAutonomous( CurrentMove.Delta, 
				            CurrentMove.bRun,
							CurrentMove.bDuck,
							CurrentMove.bPressedJump,
							CurrentMove.Acceleration,
							rot(0,0,0)
						  );

			// Advance to the next move
			CurrentMove = CurrentMove.NextMove;
			
			if ( SavedPawn != None )
			{
				SavedPawn.SetCollisionSize(SavedRadius, P.CollisionHeight);
				SavedPawn = None;
			}
		}
	}

	// Restore the state
	bUpdating		= false;
	bDuck			= realbDuck;
	bRun			= realbRun;
	bPressedJump	= bRealJump;
}

final function SavedMove GetFreeMove()
{
	local SavedMove s;

	if ( FreeMoves == None )
		return Spawn(class'SavedMove');
	else
	{
		s = FreeMoves;
		FreeMoves = FreeMoves.NextMove;
		s.NextMove = None;
		return s;
	}	
}

function int CompressAccel(int C)
{
	if ( C >= 0 )
		C = Min(C, 127);
	else
		C = Min(abs(C), 127) + 128;
	return C;
}

// Replicate this client's desired movement to the server.
function ReplicateMove
(
	float	DeltaTime, 
	vector	NewAccel, 
	rotator DeltaRot
)
{
	local SavedMove NewMove, OldMove, LastMove;
	local byte ClientRoll;
	local int i;
	local float OldTimeDelta, TotalTime, NetMoveDelta;
	local int OldAccel;
	local vector BuildAccel, AccelNorm;

	local float AdjPCol, SavedRadius;
	local pawn SavedPawn, P;
	local vector Dist;

	local bool bCantSendFire;

	// Get a SavedMove actor to store the movement in.
	if ( PendingMove != None )
	{
		//add this move to the pending move
		PendingMove.TimeStamp = Level.TimeSeconds; 
		if ( VSize(NewAccel) > 3072 )
			NewAccel = 3072 * Normal(NewAccel);
		TotalTime = PendingMove.Delta + DeltaTime;
		PendingMove.Acceleration = (DeltaTime * NewAccel + PendingMove.Delta * PendingMove.Acceleration)/TotalTime;

		// Set this move's data.
		PendingMove.bRun            = (bRun > 0);
		PendingMove.bDuck           = (bDuck > 0);
		PendingMove.bPressedJump    = bPressedJump || PendingMove.bPressedJump;
		PendingMove.bFire           = PendingMove.bFire || bJustFired || (bFire != 0);
		PendingMove.bAltFire        = PendingMove.bAltFire || bJustAltFired || (bAltFire != 0);
		PendingMove.Delta           = TotalTime;
        PendingMove.moveButtons     = int(bWasForward) | (int(bWasBack)<<1) | (int(bWasLeft)<<2) | (int(bWasRight)<<3);
	}
	if ( SavedMoves != None )
	{
		NewMove = SavedMoves;
		AccelNorm = Normal(NewAccel);
		while ( NewMove.NextMove != None )
		{
			// find most recent interesting move to send redundantly
			if ( NewMove.bPressedJump
				|| ((NewMove.Acceleration != NewAccel) && ((normal(NewMove.Acceleration) Dot AccelNorm) < 0.95)) )
				OldMove = NewMove;
			NewMove = NewMove.NextMove;
		}
		if ( NewMove.bPressedJump
			|| ((NewMove.Acceleration != NewAccel) && ((normal(NewMove.Acceleration) Dot AccelNorm) < 0.95)) )
			OldMove = NewMove;
	}

	LastMove = NewMove;
	NewMove = GetFreeMove();
	NewMove.Delta = DeltaTime;
	if ( VSize(NewAccel) > 3072 )
		NewAccel = 3072 * Normal(NewAccel);
	NewMove.Acceleration = NewAccel;

	if ( Weapon != None )
		bCantSendFire = Weapon.bCantSendFire;

	// Set this move's data.
	NewMove.TimeStamp		= Level.TimeSeconds;
	NewMove.bRun            = (bRun > 0);
	NewMove.bDuck           = (bDuck > 0);
	NewMove.bPressedJump    = bPressedJump;
	NewMove.bFire           = (bJustFired || (bFire != 0)) && !bCantSendFire;
	NewMove.bAltFire        = (bJustAltFired || (bAltFire != 0));
    NewMove.moveButtons     = int(bWasForward) | (int(bWasBack)<<1) | (int(bWasLeft)<<2) | (int(bWasRight)<<3);

	bJustFired = false;
	bJustAltFired = false;
	
	// Adjust radius of nearby players with uncertain location.
	for ( P = Level.PawnList; P != None; P=P.nextPawn )
		if ( (P != self) && (P.Velocity != vect(0,0,0)) && P.bBlockPlayers )
		{
			Dist = P.Location - Location;
			AdjPCol = 0.0004 * PlayerReplicationInfo.Ping * ((P.Velocity - Velocity) Dot Normal(Dist));
			if ( VSize(Dist) < AdjPCol + P.CollisionRadius + CollisionRadius + NewMove.Delta * GroundSpeed * (Normal(Velocity) Dot Normal(Dist)) )
			{
				SavedPawn = P;
				SavedRadius = P.CollisionRadius;
				Dist.Z = 0;
				P.SetCollisionSize(FClamp(AdjPCol + P.CollisionRadius, 0.5 * P.CollisionRadius, VSize(Dist) - CollisionRadius - P.CollisionRadius), P.CollisionHeight);
				break;
			}
		} 
	// Simulate the movement locally.
	ProcessMove(NewMove.Delta, NewMove.Acceleration, DeltaRot);
	AutonomousPhysics(NewMove.Delta);
	if ( SavedPawn != None )
		SavedPawn.SetCollisionSize(SavedRadius, P.CollisionHeight);

	//log("Role "$Role$" repmove at "$Level.TimeSeconds$" Move time "$100 * DeltaTime$" ("$Level.TimeDilation$")");

	// Decide whether to hold off on move
	// send if dodge, jump, or fire unless really too soon, or if newmove.delta big enough
	// on client side, save extra buffered time in LastUpdateTime
	if ( PendingMove == None )
		PendingMove = NewMove;
	else
	{
		NewMove.NextMove = FreeMoves;
		FreeMoves = NewMove;
		FreeMoves.Clear();
		NewMove = PendingMove;
	}
	NetMoveDelta = FMax(64.0/Player.CurrentNetSpeed, 0.011);
	
	if ( /*!PendingMove.bForceFire && !PendingMove.bForceAltFire &&*/ !PendingMove.bPressedJump
		&& (PendingMove.Delta < NetMoveDelta - ClientUpdateTime) )
	{
		// save as pending move
		return;
	}
	else if ( (ClientUpdateTime < 0) && (PendingMove.Delta < NetMoveDelta - ClientUpdateTime) )
		return;
	else
	{
		ClientUpdateTime = PendingMove.Delta - NetMoveDelta;
		if ( SavedMoves == None )
			SavedMoves = PendingMove;
		else
			LastMove.NextMove = PendingMove;
		PendingMove = None;
	}

	// check if need to redundantly send previous move
	if ( OldMove != None )
	{
		// log("Redundant send timestamp "$OldMove.TimeStamp$" accel "$OldMove.Acceleration$" at "$Level.Timeseconds$" New accel "$NewAccel);
		// old move important to replicate redundantly
		OldTimeDelta = FMin(255, (Level.TimeSeconds - OldMove.TimeStamp) * 500);
		BuildAccel = 0.05 * OldMove.Acceleration + vect(0.5, 0.5, 0.5);
		OldAccel = (CompressAccel(BuildAccel.X) << 23) 
					+ (CompressAccel(BuildAccel.Y) << 15) 
					+ (CompressAccel(BuildAccel.Z) << 7);
		if ( OldMove.bRun )
			OldAccel += 64;
		if ( OldMove.bDuck )
			OldAccel += 32;
		if ( OldMove.bPressedJump )
			OldAccel += 16;
	}
	//else
	//	log("No redundant timestamp at "$Level.TimeSeconds$" with accel "$NewAccel);

	// Send to the server
	ClientRoll = (Rotation.Roll >> 8) & 255;
	if ( NewMove.bPressedJump )
		bJumpStatus = !bJumpStatus;
	
    ServerMove
	(
		NewMove.TimeStamp, 
		NewMove.Acceleration * 10, 
		Location, 
		NewMove.bRun,
		NewMove.bDuck,
		bJumpStatus, 
		NewMove.bFire,
		NewMove.bAltFire,
        NewMove.moveButtons,
		ClientRoll,
		(32767 & (ViewRotation.Pitch/2)) * 32768 + (32767 & (ViewRotation.Yaw/2)),
		OldTimeDelta,
		OldAccel        
	);
}

function HandleWalking()
{
	bIsWalking = (bRun != 0) || (bDuck != 0);
}

exec function JumpDown()
{
	JumpPressedCount++;
	
	if ( bUseRemappedEvents )
	{
		GlobalTrigger( JumpEvent );
		return;
	}

	if ( ForceDuck ) 
        return;

	bPressedJump = true;
}

exec function JumpUp()
{
	if ( JumpPressedCount>0 ) 
		JumpPressedCount--;

	if( bUseRemappedEvents )
	{
		GlobalTrigger( JumpEventEnd );
		return;
	}

	if ( bActiveJetpack )
		JetpackUp();
}

// Hooks to pass jetpack inputs up to dngame.
function bool JetpackReady()
{
	return true;
}

function JetpackDown()
{
	bJetpacking = true;
}

function JetpackUp()
{
	bJetpacking	 = false;
	JetpackForce = 0;
	bPressedJump = false;
}

function JetpackOn()
{
	SetControlState( CS_Jetpack );
	SetPhysics( PHYS_Jetpack );
	Velocity.Z = JumpZ;
}

function JetpackOff()
{
	bJetpacking  = false;	
	JetpackForce = 0;
	bPressedJump = false;
	AirControl   = default.AirControl;

	if ( GetControlState() == CS_Jetpack )
	{
		SetControlState( CS_Normal );
		SetMovementState( MS_Waiting );
		SetPostureState( PS_Jumping, true );
		SetPhysics( PHYS_Falling );
		PlayInAir();
	}
}

exec function Jetpack()
{
	local class<Inventory> InvClass;
 
	InvClass = class<Inventory>( DynamicLoadObject( "dnGame.Jetpack", class'Class' ) );	
	ActivateInventoryItem( InvClass );	
}

event bool DuckHeld()
{
    return ( DuckPressedCount != 0 );
}

exec function DuckDown()
{
	//BroadcastMessage("DuckDown: "@DuckPressedCount@","@Autoduck@","@DuckCount@","@bDuck@","@bIsDucking);

	if (!Autoduck) 
		return;

	DuckPressedCount++;
	
    if (bOnLadder || bOnRope || bPissing)
		return;

	if (bUseRemappedEvents)
	{
		GlobalTrigger(DuckEvent);
		return;
	}

	if (DuckCount == 0) 
	{
		// Don't change collision height while swimming/jetpacking/spectator/dead mode
        if ( 
			 GetControlState() != CS_Swimming    &&
			 GetControlState() != CS_Jetpack     &&
			 GetControlState() != CS_Dead     &&
			 !IsSpectating()
		   )
		{
            //BroadcastMessage("Crouching 2: "@DuckPressedCount);
			ChangeCollisionHeightToCrouching(); 
		}
		bDuck=1;
    }
	DuckCount++;
}

exec function DuckUp()
{
	local vector newLoc;

	//BroadcastMessage("DuckUp: "@DuckPressedCount@","@Autoduck@","@DuckCount@","@bDuck@","@bIsDucking);

	if (!Autoduck) 
		return;

	if (DuckPressedCount>0) 
		DuckPressedCount--;

	if (bUseRemappedEvents)
	{
		GlobalTrigger(DuckEventEnd);
		return;
	}

	if (DuckCount != 0)
	{
		DuckCount--;
		
		if (DuckCount == 0)
		{
		    if ( GetControlState() != CS_Swimming ||
				 GetControlState() != CS_Jetpack ) 
			{
                ChangeCollisionHeightToStanding();
			}
		bDuck=0;
		}
	}
}

exec function Jump( optional float F )
{
	if (Level.Pauser == PlayerReplicationInfo.PlayerName)
		SetPause(false);
	else
		bPressedJump = true;
}

event bool JumpHeld()
{
    return ( JumpPressedCount != 0 );
}

// Can be called by the server and client
function DoJetpack()
{	
	SetPhysics( PHYS_Jetpack );
	SetPostureState( PS_Jetpack );
	SetMovementState( MS_Jetpack );
	SetControlState( CS_Jetpack );
}

function DoJump( optional float F )
{
    local Rotator dir;

	if ( (Physics == PHYS_Walking) || bOnLadder || ( GetControlState() == CS_Rope ) )
	{
		// Jump sound
		if ( !bUpdating )
			PlayOwnedSound(JumpSound, SLOT_Talk, 1.5, true, 1200, 1.0 );

		// AI Noise
		if ( (Level.Game != None) && (Level.Game.Difficulty > 0) )
			MakeNoise(0.1 * Level.Game.Difficulty);

		if ( bCountJumps && (Role == ROLE_Authority) && (Inventory != None) )
			Inventory.OwnerJumped();

        if ( bOnLadder ) // Jump off ladder takes priority
        {
            dir            = ViewRotation;
            dir.Pitch      = 0;
            Velocity	   = Vector( dir ) * -75 + vect(0,0,1) * JumpZ;
            ladderJumpTime = Level.TimeSeconds;            
        }
        else if ( GetControlState() == CS_Rope ) // Jump off rope is next
        {	   
            dir = ViewRotation;
            dir.Pitch = 0;
            dir.Roll  = 0;

            Velocity  = Vector( dir ) * currentRope.m_jumpOffSpeedHorizontal + 
                          vect(0,0,1) * currentRope.m_jumpOffSpeedVertical;
            Velocity.X += currentRope.m_angularVelocity.X * currentRope.m_jumpOffSpeedAngular * currentRope.GetPlayerPositionFactor();;
		    Velocity.Y += currentRope.m_angularVelocity.Y * currentRope.m_jumpOffSpeedAngular * currentRope.GetPlayerPositionFactor();;
            
            OffRope();
            SetControlState( CS_Normal );
            SetPostureState( PS_Jumping );        
            SetMovementState( MS_Waiting );
        }
        else // Normal jumping, give me some velocity
        {
    		Velocity.Z = JumpZ;
        }

		// Do the animation
        PlayJump();

		if ( CarriedDecoration != None )
			Velocity.Z *= CarriedDecoration.GetJumpZScale();
		if ( ( Base != Level) && (Base != None ) )    
            Velocity.Z += Base.Velocity.Z; 

		//if ( bActiveJetpack && JetpackReady()  ) // If we're using a jetpack, then go Jetpacking
		//{
		//	DoJetpack();
		//}
		//else
		//{
			SetPhysics( PHYS_Falling );
		//}
	}
}

function DoWaterJump()
{
	Velocity.Z = 400 + 2 * CollisionRadius;
	//Velocity.Z = 330 + 2 * CollisionRadius;
	PlayJump();
	SetControlState(CS_Normal);
    SetPostureState(PS_Jumping);	
}

function bool PreLanded(vector HitNormal)
{
	if ( !preLandedCalled )
	{
		PreLandedCalled=true;
		return false;
	}
	return true;
}

function PlayFallingMajorPainSound()
{
	PlayOwnedSound( PlayerReplicationInfo.VoiceType.default.Falling_MajorPainSounds[rand( PlayerReplicationInfo.VoiceType.default.NumFallingMajorPainSounds )], , 1.0, false, 1000, , true );
}

function PlayFallingPainSound()
{
	PlayOwnedSound( PlayerReplicationInfo.VoiceType.default.Falling_PainSounds[rand( PlayerReplicationInfo.VoiceType.default.NumFallingPainSounds )], , 1.0, false, 1000, , true );
}

function event Landed( vector HitNormal )
{
	local int i;
	local float FallingDamage;
	local vector	HitLocation, HitNormal2, EndTrace, StartTrace;
	local actor		HitActor;

	if ( GetControlState() == CS_Jetpack )
	{
		return;
		//JetpackOff();
	}

	if ( GetControlState() == CS_Swimming )
	{
		if ( !bUpdating )
		{
			PlayLanded( Velocity.Z );
			bJustLanded = true;
		}
		if ( Region.Zone.bWaterZone )
		{
			SetPhysics( PHYS_Swimming );
		}
		else
		{
			SetControlState( CS_Normal );
			AnimEndEx( 2 );
		}
		return;
	}

	PreLandedCalled = false;

	// Note - Physics changes type to PHYS_Walking by default for landed pawns.
	if ( bUpdating )
		return;

	PlayLanded(Velocity.Z);
	LandBob = FMin(50, 0.055 * Velocity.Z);
	LandBob /= 10;

	// JEP... (A better way to do this would be to pass the HitActor as a parameter in eventLanded, would save a trace)
	// Trace out to see what we hit.
	if (Velocity.Z <= -200)
	{
		StartTrace = Location;
		EndTrace = StartTrace + vect(0,0,-400);
		HitActor = Trace(HitLocation, HitNormal2, EndTrace, StartTrace);

		// From now on, break glass using a network friendly actor.
		if ( HitActor.IsA('BreakableGlass') )
			BreakableGlass(HitActor).ReplicateBreakGlass( Location, true, 30.f );
	}
	// ...JEP

	if ( Role < ROLE_Authority )
	{
		if ( InventoryDipStartTime==0.0 )
		{
			InventoryDipStartTime	= Level.TimeSeconds;
			InventoryDipScaler		= abs( Velocity.Z / JumpZ ); // How much to scale inventory dip.
			
			if ( InventoryDipScaler >= 16.0 ) 
				InventoryDipScaler=16.0;

			InventoryDipDirection	= Velocity;
			InventoryDipDirection	= Normal( InventoryDipDirection ); // Direction to dip inventory (Normalized vector)
		}
	}

	if ( Role == ROLE_Authority )
	{
		// Falling damage calculations
		if (Velocity.Z <= -1200 )
		{
			// Fatal impact.
			TakeDamage( 1000, None, Location, vect(0,0,0), class'FallingDamage' );			

		} 
		else if ( Velocity.Z < -1000 ) // Is this Really Painful?
		{
			PlayFallingMajorPainSound();
			
			if ( Role == ROLE_Authority )
			{
				FallingDamage  = 30 + Rand(20);
				FallingDamage *= Level.Game.FallingDamageScale;

				TakeDamage( FallingDamage, None, Location, vect(0,0,0), class'FallingDamage' );
			}
		} 
		else if ( Velocity.Z < -700 ) // Does this even hurt?
		{
			PlayFallingPainSound();

			if ( Role == ROLE_Authority )
			{
				FallingDamage = 5 + Rand(5);
				FallingDamage *= Level.Game.FallingDamageScale;

				TakeDamage( FallingDamage, None, Location, vect(0,0,0), class'FallingDamage' );
				if ( Velocity.Z < -850 )
				{
					FallingDamage = 10 + Rand(5);
					TakeDamage( FallingDamage, None, Location, vect(0,0,0), class'FallingDamage' );
				}
			}
		} 
	}

	bJustLanded = true;
	
	// This should only be updated on the client (so, no need to special case for server code)
	if ( JumpPressedCount > 0 )  
	{
		bBunnyHop		 = true;
		JumpPressedCount = 0;
	}
}

function JumpOffPawn()
{
	Velocity += 60 * VRand();
	Velocity.Z = 120;
	SetPhysics(PHYS_Falling);
}

function UpdateRotation(float DeltaTime) // This is a client side function, server uses ServerMove to set the new Rotation
{
	local rotator newRotation;
	
	DesiredRotation    = ViewRotation; //save old rotation
	
	if ( !RotateToDesiredView )
	{
		ViewRotation.Pitch += 32.0 * DeltaTime * aLookUp;	
		ViewRotation.Pitch = ViewRotation.Pitch & 65535;

		if ( ( ViewRotation.Pitch > 18000 ) && ( ViewRotation.Pitch < 49152 ) )
		{
			if ( aLookUp > 0 )
				ViewRotation.Pitch = 18000;
			else
				ViewRotation.Pitch = 49152;
		}
		
		ViewRotation.Yaw += 32.0 * DeltaTime * aTurn;
	}

    // Save viewrotation off as an integer
    ViewRotationInt = (32767 & (ViewRotation.Pitch/2)) * 32768 + (32767 & (ViewRotation.Yaw/2));

	ViewShake(deltaTime);
	ViewFlash(deltaTime);
		
    if ( bCameraLook )
    {
        return;
    }

	newRotation     = Rotation;
	newRotation.Yaw = ViewRotation.Yaw;

	if ( ( GetMovementState() == MS_Waiting ) && ( GetPostureState() == PS_Standing ) )
    {
        // If we are in a waiting/standing state, then we will update the rotation smoothly by moving the torso and
        // then shuffling the legs around.
        SmoothRotation = newRotation;
    }
	else
    {   
        // No more turning, just set the rotation absolutely
        bIsTurning = false;
        setRotation(newRotation);
    }
}

exec function CameraLookDown()
{
    bCameraLook = true;
}

exec function CameraLookUp()
{
    bCameraLook = false;
}

exec function SetJumpZ( float F )
{
	if( !bCheatsEnabled )
		return;
	if ( !bAdmin && (Level.Netmode != NM_Standalone) )
		return;
	JumpZ = F;
}

exec function SetFriction( float F )
{
	local ZoneInfo Z;
	if ( !bAdmin && (Level.Netmode != NM_Standalone) )
		return;
	ForEach AllActors(class'ZoneInfo', Z)
		Z.ZoneGroundFriction = F;
}

function StartWalk()
{
	UnderWaterTime = Default.UnderWaterTime;
	SetCollision( true, true, true );
	SetPhysics( PHYS_Walking );
	bCollideWorld = true;
	ClientRestart();	
}

function SetPlayerSpeed(float F)
{
	if ( !bAdmin && (Level.Netmode != NM_Standalone) )
		return;
	GroundSpeed = Default.GroundSpeed * f;
	WaterSpeed = Default.WaterSpeed * f;

}

exec function SetSpeed( float F )
{
	SetPlayerSpeed(F);
}

event ZoneChange( ZoneInfo NewZone )
{
	local actor HitActor;
	local vector HitLocation, HitNormal, CheckPoint;

	// Update fog color.
	if (CameraStyle == PCS_NightVision)
	{
		RestoreFog();
		SaveFog( NewZone.FogColor );
		NewZone.FogColor = NightFogColor;
	} 
	else if (CameraStyle == PCS_HeatVision) 
	{
		RestoreFog();
		SaveFog( NewZone.FogColor );
		NewZone.FogColor = HeatFogColor;
	} 
	else
	{
		SaveFog( NewZone.FogColor );
	}

	if (GetControlState() == CS_Normal)
	{
		if (NewZone.bWaterZone)
		{
			setPhysics(PHYS_Swimming);
			SetControlState(CS_Swimming);
		}
	}
	else if (GetControlState() == CS_Swimming)
	{
		if (!NewZone.bWaterZone)
		{
			SetPhysics(PHYS_Falling);
			if (bUpAndOut && CheckWaterJump(HitNormal)) // Check for waterjump.
			{
				DoWaterJump();
			}				
			else if (!FootRegion.Zone.bWaterZone || (Velocity.Z > 160) )
			{
				SetControlState(CS_Normal);
				AnimEndEx(1);
				AnimEndEx(2);
			}
			else // Check if in deep water.
			{
				CheckPoint = Location;
				CheckPoint.Z -= (CollisionHeight + 6.0);
				HitActor = Trace(HitLocation, HitNormal, checkpoint, Location, false);
				if (HitActor != None)
				{
					SetControlState(CS_Normal);
					AnimEndEx(1);
					AnimEndEx(2);
				}
				else
				{
					SetTimer(0.7,false);
				}
			}
		}
		else
		{
			SetPhysics(PHYS_Swimming);
		}
	}
	Super.ZoneChange(NewZone);
}

// Rotates the player's view to a given rotation.
simulated function RotateViewTo( rotator NewViewRotation, float Seconds )
{
	local rotator NormViewRot, NormDesViewRot;

	DesiredViewRotation = NewViewRotation;
	RotateToDesiredView = true;

	NormViewRot = normalize(ViewRotation);
	NormViewRot.Roll = 0;
	NormDesViewRot = normalize(DesiredViewRotation);
	NormDesViewRot.Roll = 0;
	if ( NormDesViewRot != NormViewRot )
	{
		ViewRotationRate.Yaw   = Abs(RotationDistance(ViewRotation.Yaw,   DesiredViewRotation.yaw)) / Seconds;
		ViewRotationRate.Pitch = Abs(RotationDistance(ViewRotation.Pitch, DesiredViewRotation.pitch)) / Seconds;
	}
}

simulated function UpdateDesiredViewRotation( float Delta )
{
	local rotator NormViewRot, NormDesViewRot;

	if ( RotateToDesiredView )
	{
		NormViewRot = normalize(ViewRotation);
		NormViewRot.Roll = 0;
		NormDesViewRot = normalize(DesiredViewRotation);
		NormDesViewRot.Roll = 0;
		if ( NormViewRot != NormDesViewRot )
		{
			ViewRotation.Pitch = FixedTurn( ViewRotation.Pitch, DesiredViewRotation.Pitch, ViewRotationRate.Pitch * Delta );
			ViewRotation.Yaw = FixedTurn( ViewRotation.Yaw, DesiredViewRotation.Yaw, ViewRotationRate.Yaw * Delta );
		}
		else
		{
			RotateToDesiredView = false;
			if ( RotateViewCallback != '' )
			{
				CallFunctionByName( RotateViewCallback );
				RotateViewCallback = '';
			}
		}
	}
}



/*-----------------------------------------------------------------------------
	Cheat Codes
-----------------------------------------------------------------------------*/

exec function Ghost()
{
	if ( !bCheatsEnabled )
		return;

	if ( !bAdmin && (Level.Netmode != NM_Standalone) )
		return;

	// Toggle ghost mode
	if ( !bCollideWorld )
	{
		ClientMessage( "Cheat Disabled: Ghost Mode" );
		StartWalk();		
	}
	else
	{
		ClientMessage( "Cheat Enabled: Ghost Mode" );
		SetCollision( false, false, false );
		bCollideWorld = false;
		SetControlState( CS_Flying );
	}
}

exec function Amphibious()
{
	if ( !bCheatsEnabled )
		return;

	if ( !bAdmin && (Level.Netmode != NM_Standalone) )
		return;

	ClientMessage( "Cheat Enabled: Underwater breathe time increased by 999999 seconds." );
	UnderWaterTime = +999999.0;
}

exec function Fly()
{
	if ( IsSpectating() ) 
	{
		SetCollision( false, false, false );
		bCollideWorld  = true;
		SetControlState( CS_Flying );
		ClientRestart();
		return;
	}

	if ( !bCheatsEnabled )
		return;

	if ( !bAdmin && (Level.Netmode != NM_Standalone) )
		return;

		
	if ( GetControlState() == CS_Flying )
	{	
		ClientMessage( "Cheat Disabled: Flying" );
		StartWalk();
	}
	else
	{
		ClientMessage( "Cheat Enabled: Flying" );
		SetCollision( true, true, true );
		bCollideWorld = true;
		SetControlState( CS_Flying );
	}
}

exec function Walk()
{	
	if ( !bAdmin && (Level.Netmode != NM_Standalone) || !IsSpectating() )
		return;

	StartWalk();
}

exec function Invisible(bool B)
{
	if( !bCheatsEnabled )
		return;

	if ( !bAdmin && (Level.Netmode != NM_Standalone) )
		return;

	if (B)
	{
		bHidden = true;
		Visibility = 0;
	}
	else
	{
		bHidden = false;
		Visibility = Default.Visibility;
	}	
}
	
exec function God()
{
	if( !bCheatsEnabled )
		return;

	if ( !bAdmin && (Level.Netmode != NM_Standalone) )
		return;

	if ( bGodMode )
	{
		bGodMode = false;
		ClientMessage("Cheat Disabled: God Mode");
		return;
	}
	else
	{
		bGodMode = true;
		ClientMessage("Cheat Enabled: God Mode");
	}
}


exec function SloMo( float T )
{
	ServerSetSloMo(T);
}

function ServerSetSloMo(float T)
{
	if ( bAdmin || (Level.Netmode == NM_Standalone) )
	{
		Level.Game.SetGameSpeed(T);
		Level.Game.SaveConfig(); 
//		Level.Game.GameReplicationInfo.SaveConfig();
	}
}

exec function KillAll(class<actor> aClass)
{
	local Actor A;

	if( !bCheatsEnabled )
		return;
	if ( !bAdmin && (Level.Netmode != NM_Standalone) )
		return;
	ForEach AllActors(class 'Actor', A)
		if ( ClassIsChildOf(A.class, aClass) )
			A.Destroy();
}

exec function KillPawns()
{
	local Pawn P;
	
	if( !bCheatsEnabled )
		return;
	if ( !bAdmin && (Level.Netmode != NM_Standalone) )
		return;
//	ForEach AllActors(class 'Pawn', P)
	for ( P=Level.PawnList; P!=None; P=P.NextPawn );
		if (PlayerPawn(P) == None)
			P.Destroy();
}

exec function Summon( string ClassName )
{	
    local class<actor> NewClass;
    local vector EndPos;
    local actor a;

	if( !bCheatsEnabled )
		return;
	if( !bAdmin && (Level.Netmode != NM_Standalone) )
		return;
	NewClass = class<actor>( DynamicLoadObject( ClassName, class'Class' ) );
	if( NewClass!=None )
    {
        a = Trace(EndPos,,Location+vect(0,0,EyeHeight) + 96 * Vector(ViewRotation));
        if (a==none)
            Spawn( NewClass,,,Location+vect(0,0,EyeHeight) + 96 * Vector(ViewRotation) );
        else
            Spawn( NewClass,,,EndPos );
    }
}

exec function SummonN( int n, string ClassName )
{
	local int i;

	for(i=0;i<n;i++)
		Summon(ClassName);
}

exec function Pain(optional int p)
{
	local vector v;
	TakeDamage( p, self, v, v, class'CrushingDamage' );
}

exec function CauseEvent( name N )
{
	local actor A;
	if( !bCheatsEnabled )
		return;
	if( (bAdmin || (Level.Netmode == NM_Standalone)) && (N != '') )
		foreach AllActors( class 'Actor', A, N )
			A.Trigger( Self, Self );
}

exec function PlayersOnly()
{
	if ( Level.Netmode != NM_Standalone )
		return;

	Level.bPlayersOnly = !Level.bPlayersOnly;
}

exec function SShot()
{
	local float b;
	b = float(ConsoleCommand("get ini:Engine.Engine.ViewportManager Brightness"));
	ConsoleCommand("set ini:Engine.Engine.ViewportManager Brightness 1");
	ConsoleCommand("flush");
	ConsoleCommand("shot");
	ConsoleCommand("set ini:Engine.Engine.ViewportManager Brightness "$string(B));
	ConsoleCommand("flush");
}

exec function Logo()
{
	ShowLogo=!ShowLogo;
}


/*==============================================================================

The following exec functions are defined to help debug:
  
GetN <package>.<class>
GetN <class>
    Gets the names of all the objects of the specified class. 
        Example: getn engine.pawn
    If you know the most derived class, you can leave out the package.
        Example: getn buzzkill

GetP <objname> <property>
    Gets the property of the object.
        Example: getp buzzkill0 location
    You can also specify the object through other objects.
        Example: getp buzzkill0.weapon name

GetS <objname>
    Gets the state of the object.
        Example: gets buzzkill0 
    You can also specify the object through other objects.
        Example: gets buzzkill0.weapon 

Watch <objname> <property>
    Watch the property of the object.
        Example: watch buzzkill0 location
    You can also specify the object through other objects.
        Example: watch buzzkill0.weapon name
    Note: The special property State (not actually a property) 
          will show the object state

UnWatch <index>
    Unwatch the object property with index <index> (shown on HUD).
        Example: unwatch 5
    You can also unwatch all.
        Example: unwatch -1

WatchOn
    Turn watching on. On by default when there is something to watch.

WatchOff
    Turn watching off. Off when there is nothing to watch.
==============================================================================*/

function DebugPostRender( canvas Canvas )
{
    local int i;
	local float OldClipX, OldClipY, OldOrgX, OldOrgY;
    local color OldColor;
    local font  OldFont;

    if (mbWatchEnabled)
    {
        OldClipX = Canvas.ClipX;
        OldClipY = Canvas.ClipY;
        OldOrgX  = Canvas.OrgX;
        OldOrgY  = Canvas.OrgY;
        OldColor = Canvas.DrawColor;
        OldFont  = Canvas.Font;
        
        Canvas.DrawColor = mDrawColor;
        Canvas.Font = Canvas.SmallFont;
        Canvas.SetOrigin(0, 0);
        Canvas.SetClip(760, Canvas.ClipY);
        Canvas.SetPos(0, 20);

        for (i=0; i<mObjMax; i++)
        {
            if (maObjList[i] != None)
            {
                Canvas.SetPos(0, Canvas.CurY);
                if (mabShowState[i] == 1)
                    Canvas.Drawtext(i$") "$maObjList[i].name$".State="$maObjList[i].GetStateName(), false);
                else
                    Canvas.Drawtext(i$") "$maObjList[i].name$"."$maPropList[i]$"="$maObjList[i].GetPropertyText(maPropList[i]), false);
            }
        }

        Canvas.SetOrigin(OldOrgX, OldOrgY);
        Canvas.SetClip(OldClipX, OldClipY);
        Canvas.DrawColor = OldColor;
        Canvas.Font = OldFont;
    }
}

exec function SetColor(color c)
{
    mDrawColor = c;
}

exec function GetS(string s)
{
    local actor a;

    if (s == "")
    {
        // Too few args
        ClientMessage("Usage: GetS <instance_name>");
        return;
    }

    // Get the object
    a = GetObjectByName(s);

    if (a == None)
    {
        // Object not found
        ClientMessage("Object "$s$" not found.");
        return;
    }

    // Success
    ClientMessage(s$" State="$a.GetStateName());
}

exec function GetN(string s)
{
    local Actor A;
    local int i;
    local string cName;
    local bool found;
    local class<Actor> cType;


    // Check input string 
    if (s == "")
    {
        // Too few args
        ClientMessage("Usage: GetN [<package>.]<class>");
        return;
    }

    cName = s;
    cType = class<Actor>(DynamicLoadObject(cName, class'Class'));

    foreach AllActors( cType, A )
    {
        // Strip off the package name
        s = string(A.class);
        i = InStr(s, ".");
        if (i != -1)
            s = Mid(s, i+1);

        if (Caps(s) == Caps(cName) || A.ClassIsChildOf( A.class, cType ))
        {
            ClientMessage("Found:"@string(A.name));
            found = true;
        }
    }

    // Actor not found
    if (!found)
        ClientMessage("Objects of class "$cName$" not found.");
}

exec function GetP(string s)
{
    local actor a;
    local int i;
    local string oName;
    local string pName;

    // The input string s is of the form:
    // object_name object_property
    i = InStr(s, " ");
    if (i != -1)
    {
        // Get the first arg (object)
        oName = Left(s, i);

        // Get the second arg (property)
        pName = Mid(s, i+1);
    }
    else
    {
        // Too few args
        ClientMessage("Usage: getp <instance_name> <property>");
        return;
    }

    // Get the object
    a = GetObjectByName(oName);

    if (a == None)
    {
        // Object not found
        ClientMessage("Object "$oName$" not found.");
        return;
    }

    s = "";
    s = a.GetPropertyText(pName);

    if (s == "")
    {
        // Property not found
        ClientMessage("Property "$pName$" not found.");
        return;
    }

    // Success
    ClientMessage(oName$"."$pName$"="$s);
}

exec function SetP(string s)
{
    local actor a;
    local int i;
    local string oName;
    local string pName;
    local string vName;

    // The input string s is of the form:
    // object_name object_property value
    i = InStr(s, " ");
    if (i != -1)
    {
        // Get the first arg (object)
        oName = Left(s, i);

        // Get the rest
        s = Mid(s, i+1);

        i = InStr(s, " ");
        if (i != -1)
        {
            // Get the second arg (property)
            pName = Left(s, i);

            // Get the third arg (value)
            vName = Mid(s, i+1);
        }
        else
        {
            // Too few args
            ClientMessage("Usage: setp <instance_name> <property> <value>");
            return;
        }
    }
    else
    {
        // Too few args
        ClientMessage("Usage: setp <instance_name> <property> <value>");
        return;
    }

    // Get the object
    a = GetObjectByName(oName);

    if (a == None)
    {
        // Object not found
        ClientMessage("Object "$oName$" not found.");
        return;
    }

    a.SetPropertyText(pName, vName);
    /*
    if (a.SetPropertyText(pName, vName) == false)
    {
        // Property not found
        ClientMessage("Property "$pName$" could not be set to "$vName);
        return;
    }
    */

    // Success
    ClientMessage(oName$"."$pName$"="$vName);
}

exec function Watch(string s)
{
    local actor a;
    local int i;
    local string oName;
    local string pName;

    // The input string s is of the form:
    // object_name object_property
    i = InStr(s, " ");
    if (i != -1)
    {
        // Get the first arg (object)
        oName = Left(s, i);

        // Get the second arg (property)
        pName = Mid(s, i+1);
    }
    else
    {
        // Too few args
        ClientMessage("Usage: watch <instance_name> <property>");
        return;
    }

    // Get the object
    a = GetObjectByName(oName);

    if (a == None)
    {
        // Object not found
        ClientMessage("Object "$oName$" not found.");
        return;
    }

    s = "";
    pName = Caps(pName);
    if (pName == "STATE")
    {
        WatchState(a, oName);
        return;
    }

    s = a.GetPropertyText(pName);

    if (s == "")
    {
        // Property not found
        ClientMessage("Property "$pName$" not found.");
        return;
    }

    // Success
    if (mObjCnt < mObjMax)
    {
        for(i=0; i<mObjMax; i++)
        {
            if (maObjList[i] == None)
            {
                maObjList[i] = a;
                maPropList[i] = pName;
                mObjCnt++;
                //ClientMessage(oName$"."$pName$" added to watch list.");
                if (mObjCnt == 1)
                    WatchOn();
                break;
            }
        }
    }
    else
        ClientMessage("Watch list is full.");
}

function WatchState(Actor A, string oName)
{
    local int i;

    // Success
    if (mObjCnt < mObjMax)
    {
        for(i=0; i<mObjMax; i++)
        {
            if (maObjList[i] == None)
            {
                maObjList[i] = a;
                mabShowState[i] = 1;
                mObjCnt++;
                ClientMessage(oName$".State added to watch list.");
                if (mObjCnt == 1)
                    WatchOn();
                break;
            }
        }
    }
    else
        ClientMessage("Watch list is full.");
}

exec function UnWatch(int i)
{
    if (i>=0 && i<mObjMax && maObjList[i] != None)
    {
        ClientMessage(maObjList[i]$"."$maPropList[i]$" removed from watch list.");
        maObjList[i] = None;
        maPropList[i] = "";
        mabShowState[i] = 0;
        mObjCnt--;
        if (mObjCnt == 0)
            WatchOff();
    }
    else if (i == -1)
    {
        // UnWatch all
        for(i=0; i<mObjMax; i++)
        {
            if (maObjList[i] != None)
            {
                maObjList[i] = None;
                maPropList[i] = "";
                mabShowState[i] = 0;
                mObjCnt--;
                if (mObjCnt == 0)
                    WatchOff();
            }
        }
        ClientMessage("Watch list cleared.");
    }
    else
        ClientMessage(i$" not in range.");
}

exec function WatchOn()
{
    if (mObjCnt > 0)
    {
        mbWatchEnabled = true;
        //ClientMessage("Watch On");
    }
    else
    {
        mbWatchEnabled = false;
        ClientMessage("No objects in watch list.");
    }
}

exec function WatchOff()
{
    mbWatchEnabled = false;
    ClientMessage("Watch Off");
}

function actor GetObjectByName(string oName)
{    
    local Actor a;
    local int i;
    local string s;
    local string pName;
    local string pName2;

    // Parse next object if any
    i = InStr(oName, ".");
    if (i != -1)
    {
        pName = Mid(oName, i+1);
        oName = Left(oName, i);

        i = InStr(pName, ".");
        if (i != -1)
        {
            pName2 = Mid(pName, i+1);
            pName = Left(pName, i);
        }
    }

    foreach AllActors( class'Actor', a )
    {
        s = string(a.name);

        if (Caps(s) == Caps(oName))
        {
            if (pName == "" && pName2 == "")
                return a;

            s = "";
            s = a.GetPropertyText(pName);

            if (s == "")
                return None;

            i = InStr(s, ".");
            if (i != -1)
            {
                s = Mid(s, i+1);

                i = InStr(s, "'");
                if (i != -1)
                    s = Left(s, i);
            }

            if (pName2 != "")
                s = s $ "." $ pName2;

            return GetObjectByName(s);
        }
    }

    // Actor not found
    return None;
}

/*-----------------------------------------------------------------------------------------
 Mesh and Skin Control
-----------------------------------------------------------------------------------------*/

function ClearAnimationChannels()
{
    local int i;

    GetMeshInstance();

    AnimSequence = 'None';
    AnimEnd();

    if ( MeshInstance != None )
    {
        for ( i=0; i<16; i++ )
        {
            MeshInstance.MeshChannels[i].AnimSequence = 'None';
            AnimEndEx( i );
        }
    }
}

//------------------------------------------------------------------------------------------
// Voice
//------------------------------------------------------------------------------------------

// Send a voice message of a certain type to a certain player.
exec function Speech( int Type, int Index, int Callsign )
{
	local VoicePack V;

	V = Spawn( PlayerReplicationInfo.VoiceType, Self );
	
	if ( V != None )
		V.PlayerSpeech( Type, Index, Callsign );
}

//------------------------------------------------------------------------------------------
// Spectator
//------------------------------------------------------------------------------------------
exec function JoinSpectator() 
{
	if ( !PlayerReplicationInfo.bIsSpectator )
	{
		BroadcastMessage( PlayerReplicationInfo.PlayerName @ JoinSpectatorText );

		PlayerReplicationInfo.bIsSpectator = true;
	
		Level.Game.NumPlayers--;
		Level.Game.NumSpectators++;

		SetCollision( false, false, false );
		bHidden				= true;
		bChaseCam			= true;
		bCollideWorld		= false;
		bProjTarget			= false;
		AirSpeed			= 400.0;
		Visibility			= 0;
		AttitudeToPlayer	= ATTITUDE_Friendly;
		
		Possess();
	}
}

function EnterWaiting()
{	
	SetCollision( false, false, false );		
	PlayerReplicationInfo.bWaitingPlayer	= true;
	bHidden									= true;
	bChaseCam								= true;
	bProjTarget								= false;
	AirSpeed								= 400.0;
	Visibility								= 0;
	AttitudeToPlayer						= ATTITUDE_Friendly;

	// New Stuff
	bCollideWorld							= true;
	SetControlState( CS_Flying );

	Level.Game.DiscardInventory ( Self );
}											

exec function LeaveSpectator() // Called on server
{
	if ( PlayerReplicationInfo.bIsSpectator )
	{
		// Match has started, so player can leave spectator mode
		BroadcastMessage( PlayerReplicationInfo.PlayerName @ LeaveSpectatorText );

		Level.Game.NumPlayers++;
		Level.Game.NumSpectators--;
		
		PlayerReplicationInfo.bIsSpectator = false;
		PlayerReplicationInfo.Score        = 0;
		
		if ( Level.Game.bStartMatch )
		{
			ServerRestartPlayer( true );			
		}
		else
		{
			EnterWaiting();
		}
	}
}

// These functions below require special code for spectators

event FootZoneChange(ZoneInfo newFootZone)
{
	if ( !IsSpectating() )
		Super.FootZoneChange( newFootZone );
}

event HeadZoneChange(ZoneInfo newFootZone)
{
	if ( !IsSpectating() )
		Super.HeadZoneChange( newFootZone );
}

simulated function ClientRestart()
{
	Super.ClientRestart();
	
	// Reset bunny hopping and jump key state.
	bPressedJump = false;
	bBunnyHop    = false;

	// Undo firing if they were holding the key down when they died.
	if ( bFire > 0 )
		FireUp();

	// Undo crouching if they were holding the key down when they died.
	if ( DuckPressedCount > 0 )
		DuckUp();

	// Put down the shield if it is up.
	if ( ShieldProtection )
		ShieldPutDown();

	// If they are a spectator, start to fly.
	if ( IsSpectating() )
		SetControlState( CS_Flying );
}

function RestoreFog()
{
	Region.Zone.FogColor = SavedFogColor;
}

function SaveFog( color fog )
{
	SavedFogColor	= fog;
}

event PostNetInitial()
{
	// This is here because in MP, when you start off in a level it saves 
	// off the fog color from the goddam entry map.  Not sure how to fix this problem,
	// but this workaround seems to work ok.
	SaveFog( Region.Zone.FogColor ); 
}

native final function PlayerPawn DoChangeClass( string newClassName );

event ProcessChangeClass()
{
	local PlayerPawn newPawn;

	if ( newPawnClass == "" )
	{
		return;
	}

	// Make the new pawn and change to it
	newPawn = DoChangeClass( newPawnClass );
	
	if ( newPawn != None )
	{
		newPawn.PlayerReplicationInfo.bHasBomb = false;

		// Check and drop the bomb if we have it.
		CheckDropBomb();

		if ( !bQuickChangeClass )
		{		
			// Give me stuff
			Level.Game.AddDefaultInventory( newPawn );
		}

		// Tell the client to possess this pawn
		newPawn.ClientPossess();
		
		if ( bQuickChangeClass )
		{
			newPawn.SetLocation( self.Location );
			newPawn.SetRotation( self.ViewRotation );
		}

		// Destroy the old pawn
		self.Destroy();
	}
	else
	{
		// FIXME: May need to do a set player here if the DoChangeClass messed us up.
		
		Log( "Couldn't change class to" @ newPawnClass );
		return;
	}

	// Clear the class name, and flags
	newPawnClass      = "";
	bQuickChangeClass = false;
	bChangeClass      = false;
}

function ServerChangeClass( string newClassName, optional bool bForce, optional bool bQuick )
{
	local int Reason;

	if ( newClassName == "" )
		return;

	newPawnClass = Level.Game.GetClassNameForString( newClassName );

	Log( "PlayerPawn::ServerChangeClass: Setting newPawnClass To:" @ newPawnClass );

	if ( bForce )
	{
		bChangeClass      = true;
		bQuickChangeClass = bQuick;
	}
	else if ( Level.Game.CanChangeClass( self, newClassName ) )
	{					
		bChangeClass      = true;
		bQuickChangeClass = bQuick;
	}
}

exec function ChangeClass( string newClassName )
{
	// Call this on the server
	ServerChangeClass( newClassName );
}

function CheckDropBomb()
{
}

function DropBomb()
{
}

function PlantBomb()
{
}

function ClientStartDefuseBomb( Actor TheBomb )
{
}

function ClientStopDefuseBomb( Actor TheBomb )
{
}

function ResetInventory()
{
	Level.Game.DiscardInventory( self );
	Level.Game.AddDefaultInventory( self );
}

exec function SetBlend( int channel, float blend )
{		
	GetMeshInstance();
	bLaissezFaireBlending = true;
	if ( Channel == 0 )
		AnimBlend = blend;
	else
		MeshInstance.MeshChannels[channel].AnimBlend = blend;
}

defaultproperties
{
	Bob=0.028000
	DesiredFOV=90.000000
	DefaultFOV=90.000000
	CdTrack=255
	MyAutoAim=1.000000
	Handedness=-1.000000
	bAlwaysMouseLook=true
	bKeyboardLook=true
	bMaxMouseSmoothing=true
	bNoFlash=True
	bMessageBeep=true
	MouseSensitivity=5.0
	MouseSmoothThreshold=0.070000
	MaxTimeMargin=3.000000
	QuickSaveString="Quick Saving"
	NoPauseMessage="Game is not pauseable"
	ViewingFrom="Now viewing from"
	OwnCamera="own camera"
	FailedView="Failed to change view."
	bIsPlayer=true
	bCanJump=true
	bViewTarget=true
	DesiredSpeed=0.300000
	SightRadius=4100.000000
	bTravel=true
	bStasis=false
	NetPriority=3.000000
	EyeSmoothScale=1.0000
	bAvoidLedges=false
	bAllowRestart=false
	bCheatsEnabled=true
	Autoduck=true
	DuckCollisionHeight=21.5
	HeatFogColor=(R=0,G=0,B=32)
	NightFogColor=(R=0,G=64,B=0)
	bHelperMessages=true
	bHumanSkeleton=true
	bWeaponsActive=true
	bCheckUseRopes=false
	onRopeSpeed=500
	bHasToPiss=true
	bCollideWorld=false
	boneRopeHandle=-1
	bIgnoreBList=true
	ShakeDamping=0.8
	ShakeRotStrength=4096
	MaxTimers=5
	bAutoActivate=true
	HeadYawLimit=4550//(25/360)*65535
	AbdomenYawLimit=8192//(45/360)*65535
	ladderSpeedFactor=0.80000
	bHeated=true
	HeatIntensity=255.000000
	HeatRadius=15.000000
	mDrawColor=(R=255,G=255,B=255,A=0)
	FOVTimeScale=1.0
	JetpackAirControl=0.7
	JoinSpectatorText="is now a spectator."
	LeaveSpectatorText="is no longer a spectator."
	bIsPlayerPawn=true
	PainDelay=0.7;
	MaxHealth=100
	MinRespawnTime=3
	MaxRespawnTime=20
}
