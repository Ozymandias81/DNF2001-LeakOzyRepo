//=============================================================================
// Pawn, the base class of all actors that can be controlled by players or AI.
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class Pawn extends RenderActor
	abstract
	native
	nativereplication;

#exec Texture Import File=Textures\Pawn.pcx Name=S_Pawn Mips=Off Flags=2



/*-----------------------------------------------------------------------------
	Enumerations
-----------------------------------------------------------------------------*/

// Regions of a creature body, used as possible animation and damage regions.
enum EPawnBodyPart
{
	BODYPART_Default,
	BODYPART_Head,
	BODYPART_Chest, 
	BODYPART_Stomach,
	BODYPART_Crotch,
	BODYPART_ShoulderLeft,
	BODYPART_ShoulderRight,
	BODYPART_HandLeft,
	BODYPART_HandRight,
	BODYPART_KneeLeft,
	BODYPART_KneeRight,
	BODYPART_FootLeft,
	BODYPART_FootRight,
};

// Types of state changes.
enum EStateChange
{
	SC_Enter,
	SC_Exit,
};

// Control/Behavioral states.
enum EControlState
{
	CS_None,
	CS_Normal,
	CS_Flying,
	CS_Swimming,
	CS_Dead,
	CS_Spectating,
	CS_Stasis,
    CS_Rope,
    CS_Ladder,
	CS_Jetpack,
	CS_Frozen
};

// Posture states.
enum EPostureState
{
	PS_None,
	PS_Standing,
	PS_Crouching,
	PS_Jumping,
	PS_Swimming,
    PS_Ladder,
    PS_Rope,
	PS_Turret,
	PS_Jetpack,
	PS_Flying,
};

// Movement states.
enum EMovementState
{
	MS_None,
	MS_Waiting,
	MS_Walking,
	MS_Running,
    MS_RopeIdle,
    MS_RopeClimbUp,
    MS_RopeClimbDown,
    MS_LadderIdle,
    MS_LadderClimbUp,
    MS_LadderClimbDown,
	MS_Jetpack,
	MS_Flying,
};

// Upper body states.
enum EUpperBodyState
{
	UB_Relaxed,
	UB_Alert,
	UB_WeaponDown,
	UB_WeaponUp,
	UB_Firing,
	UB_Reloading,
	UB_ReloadFinished,
    UB_ShieldDown,
    UB_ShieldUp,
    UB_ShieldAlert,
    UB_HoldOneHanded,
    UB_HoldTwoHanded,
	UB_Turret,
};

// Used by the physics code to tell us what the player is doing on the rope
enum ERopeClimbState
{
    RS_ClimbNone,
    RS_ClimbUp,
    RS_ClimbDown,
};

// Ladder direction, location where the ladder is to me
enum ELadderState
{
    LADDER_None,
    LADDER_Forward,
    LADDER_Forward_Right,
    LADDER_Right,
    LADDER_Backward_Right,
    LADDER_Backward,
    LADDER_Backward_Left,
    LADDER_Left,
    LADDER_Forward_Left,
    LADDER_Num_Directions
};

// Jetpack direction state
enum EJetpackState
{
	JS_None,
	JS_Idle,
	JS_Forward,
	JS_Backward,
	JS_Left,
	JS_Right,
};

enum ESwimDepth
{
    Swim_None,
    Swim_Shallow,
    Swim_Deep
};

// State Management
var	travel EControlState	  ControlState;
var	travel EPostureState	  PostureState;
var	travel EMovementState	  MovementState;
var travel EUpperBodyState    UpperBodyState;
var travel ERopeClimbState    RopeClimbState;
var travel ELadderState       LadderState;
var travel EJetpackState      JetpackState;

// Pawn List
var const	Pawn		nextPawn;



/*-----------------------------------------------------------------------------
	AI
-----------------------------------------------------------------------------*/

// Combat
var(AI)		float		Skill;					// Skill, scaled by game difficulty (add difficulty to this value)	
var(AI)		bool		bSnatched;				
var			Actor		Enemy;
var	unbound	bool		bFixedEnemy;
var			bool		bRotateToEnemy;			// Update rotation to face Enemy actor *while* moving.
var 		bool 		bFromWall;
var			bool		bHunting;				// Tells navigation code that pawn is hunting another pawn, so fall back to
var			bool		bJumpOffPawn;		
var			bool		bShootSpecial;
var			bool		bAdvancedTactics;		// Used during movement between pathnodes. Finding a path to a visible pathnode if none are reachable.
var(Combat) float		MeleeRange;				// Max range for melee attack (not including collision radii)
var	unbound	vector		LastSeenPos;			// Enemy position when I last saw enemy (auto updated if EnemyNotVisible() enabled)
var	unbound vector		LastSeeingPos;			// Position where I last saw enemy (auto updated if EnemyNotVisible enabled)
var	unbound float		LastSeenTime;
var(Combat) unbound float CombatStyle;			// -1 to 1 = low means tends to stay off and snipe, high means tends to charge and melee.
var			bool		bPlayerCanSeeMe;		// Flag for AI, on if the player can see it.
// States & Stock AI
var	unbound float		Alertness;				// -1 to 1, used within specific states for varying reaction to stimuli
var unbound name		NextState;				// For queueing states
var unbound name		NextLabel;				// For queueing states
var unbound EControlState PlayerRestartState;
var()		bool		bMuffledHearing;		// This pawn can hear through walls.
var()		float		HearThroughWallDist;	// Max distance at which this pawn can hear through walls.
var()		bool		bNoHeightMod;

var(AI) unbound enum EAttitude					// Important - order in decreasing importance.
{
	ATTITUDE_Fear,								// Will try to run away.
	ATTITUDE_Hate,								// Will attack enemy.
	ATTITUDE_Frenzy,							// Will attack anything, indiscriminately.
	ATTITUDE_Threaten,							// Animations, but no attack.
	ATTITUDE_Ignore,
	ATTITUDE_Friendly,
	ATTITUDE_Follow								// Accepts player as leader.
} AttitudeToPlayer;								// Determines how creature will react on seeing player (if in human form).
var(AI) unbound enum EIntelligence				// Important - order in increasing intelligence.
{
	BRAINS_NONE,								// Only reacts to immediate stimulus.
	BRAINS_REPTILE,								// Follows to last seen position.
	BRAINS_MAMMAL,								// Simple navigation (limited path length).
	BRAINS_HUMAN								// Complex navigation, team coordination, use environment stuff (triggers, etc.)
} Intelligence;
												
// Hearing & Sound
var(AI)		float		HearingThreshold;		// Minimum noise loudness for hearing
var const 	vector 		noise1spot;				// internal use
var const 	float 		noise1time;				// internal use
var const	float		noise1loudness;			// internal use
var const 	vector 		noise2spot;				// internal use
var const 	float 		noise2time;				// internal use
var const	float		noise2loudness;			// internal use

// Sight & Visibility
var()		byte		Visibility;				// How visible is the pawn? 0=invisible, 128=normal, 255=highly visible
var(AI)		float		SightRadius;			// Maximum seeing distance.
var(AI)		float		PeripheralVision;		// Cosine of limits of peripheral vision.
var			float		SightCounter;			// Used to keep track of when to check player visibility
var			bool		bNoRotConstraint;
// Movement
var(Combat) bool		bCanStrafe;
var			bool		bCanJump;
var			bool 		bCanWalk;
var			bool		bCanSwim;
var			bool		bCanFly;
var			bool		bCanOpenDoors;
var			bool		bCanDoSpecial;
var(AI)		bool		bPanicking;
// Kill value
var(AI) unbound int		EgoKillValue;
var			bool		bWeaponNoAnimSound;

// Misc
var(AI)		bool		bFlyingVehicle;
var() unbound string	CharacterName;



/*-----------------------------------------------------------------------------
	Stats
-----------------------------------------------------------------------------*/

var() travel float		Energy;					// BR: Energy: 100 = normal maximum
var() travel float		EnergyDrain;			// BR: Rate of energy drain.
var() travel int		Cash;					// Cash on hand.
var          int        Spree;					// Kills in a row
var			 bool		bIsHuman;
var			 bool		bIsPlayer;
var			 bool		bIsFemale;
var()		 bool		bTakeDamage;			// Pawn takes damage



/*-----------------------------------------------------------------------------
	Inventory
-----------------------------------------------------------------------------*/

var() class<Inventory> SearchableItems[ 5 ];
var travel	Weapon		Weapon;					// The pawn's current weapon
var travel	Inventory	SelectedItem;			// Currently selected inventory item
var travel  Inventory	UsedItem;				// Item currently in use (Rebreather, etc)
var travel  Inventory	ShieldItem;				// Shield
var travel  Inventory	OldUsedItem;
var	travel	Decoration	CarriedDecoration;
var bool bGodMode;
var() unbound class<inventory> DropWhenKilled;	// Inventory to drop when killed (for creatures)
var			float		UseDistance;
var unbound globalconfig bool bNeverSwitchOnPickup; // If true, don't automatically switch to picked up weapon.
var	unbound bool		bAutoActivate;			// If true, pawn activates what it picks up.
var unbound float		MeleeDamageMultiplier;

var unbound sound		GrabSound;
var unbound sound		TossSound;

var unbound travel Decoration MountedDecorations[6]; // All pawns can have up to 6 mounted decorations.
var() unbound class<Decoration> Accessories[6];

// Shield Damage
var			bool				ShieldProtection;

// Last Weapon
var         bool                bWeaponsActive;
var unbound class<Weapon>		LastWeaponClass;



/*-----------------------------------------------------------------------------
	General Combat
-----------------------------------------------------------------------------*/

var Weapon				PendingWeapon;			// Will become weapon once current weapon is put down.
var	float				RemainingAir;			// Used for getting Drowning() message.
var	float				LastPainSound;
var float				DamageScaling;
var name				DamageBone;				// Used by SetDamageBone which may be called before TakeDamage.
var int					CurrentAmmoMode;		// Current Ammo mode used for whatever weapon is wielded.
var() bool				NoDecorationPain;
var vector				DamageLocation;

// Blood FX
var string				BloodHitDecalName;
var class<Actor>		BloodHitDecal;
var string				BloodPuffName;
var class<Actor>		BloodPuff;

// Damage Over Time (DOT)
var DOTAffector			DOTAffectorList;
var bool				bTakesDOT;

// Gas cloud detection.
var int					ExplosiveArea;			// If nonzero this pawn is standing in an explosive area.



/*-----------------------------------------------------------------------------
	Animation
-----------------------------------------------------------------------------*/

// For human behavior.
var unbound	bool		bHumanSkeleton;
var unbound bool		bForcePeriphery;
var unbound bool		bForceHitWall;

// Animation Blending
var unbound	float 		TopAnimBlend;
var unbound	float 		DesiredTopAnimBlend;
var unbound	float 		TopAnimBlendRate;
var unbound	float 		BottomAnimBlend;
var unbound	float 		DesiredBottomAnimBlend;
var unbound	float 		BottomAnimBlendRate;
var	unbound	float		SpecialAnimBlend;
var	unbound	float		DesiredSpecialAnimBlend;
var	unbound	float		SpecialAnimBlendRate;
var unbound float		FaceAnimBlend;
var unbound float		DesiredFaceAnimBlend;
var unbound float		FaceAnimBlendRate;
var			bool		bLaissezFaireBlending;			// This disables forced blending across channels 1,2, and 3.

// Blinking
var   transient bool bBlinked;
var	  float		LastBlinkTime;
var	  float		BlinkTimer;
var	  float		CurrentBlinkAlpha;
var() float		BlinkRateBase			?("Base rate of eye blinking.\nFinal rate is randomly chosen between BlinkRateBase and BlinkRateBase+BlinkRateRandom");
var() float		BlinkRateRandom			?("Random blink rate adjustment above base.\nFinal rate is random chosen between BlinkRateBase and BlinkRateBase+BlinkRateRandom");
var() float		BlinkDurationBase		?("Base duration of eye blinking.\nFinal duration is randomly chosen between BlinkDurationBase and BlinkDurationBase+BlinkDurationRandom");
var() float		BlinkDurationRandom		?("Random blink duration adjustment above base.\nFinal duration is randomly chosen between BlinkDurationBase and BlinkDurationBase+BlinkDurationRandom");
var() vector	BlinkEyelidPosition		?("Position eyelid is adjusted by at full blink.\nValues are relative to eyelid bone axes");
var() float		BlinkChangeTime			?("Time in seconds it takes to go between a fully non-blinked and a fully blinked state");

// Lip syncing
var()		float		SoundSyncScale_Jaw;
var()		float		SoundSyncScale_MouthCorner;
var()		float		SoundSyncScale_Lip_U;
var()		float		SoundSyncScale_Lip_L;

// Tracking
var PawnTrackingInfo	EyeTracking;
var PawnTrackingInfo	HeadTracking;
var transient vector	HeadTrackingLocation;	// !! TEST
var transient actor		HeadTrackingActor;		// !! TEST

// Torso/Pelvis rotation.
var unbound PawnTrackingInfo TorsoTracking;
var unbound rotator		     LastRotDirection;
var unbound bool		     TorsoSlerping;
var int                      MaxAbdomenViewPitchUp,MaxAbdomenViewPitchDown,MaxAbdomenPitchUp,MaxAbdomenPitchDown;

var transient int			AbdomenBone;
var transient int			PelvisBone;
var transient int			ChestBone;
var float					AbdomenRotationScale;
var float					PelvisRotationScale;
var float					ChestRotationScale;

// Bone scales for various effects
var float               BoneScales[6];

// Alert
var unbound float		AlertTimer;

// Facial expressions.
var unbound EFacialExpression FacialExpression;

// JEP... (Extended facial expression code)
// Facial expression and lip sync info
struct native SFacialExpressionFrame
{
	var() name				AnimName;			// Anim name for this facial expression frame
	var() float				JawScale;			// User set scale of the jawbone (0 will default to 1)
	var() float				Delay;				// Delay till blending to the next expression starts
	var() float				BlendTime;			// How long (in seconds) it takes to blend to the next expression (after delay has been met)
};

struct native SFacialExpression
{
	var() SFacialExpressionFrame	FacialFrame[16];	// Expressions have up to 16 frames
	var() bool						bNoLoop;
};

var() SFacialExpression		FacialExpressions[16];		// Up to 16 expressions on a pawn

var() float					TargetLipBlendPercent;
var() float					TargetLipBlendRate;
var() float					LipRampSpeed;
var() float					LipScale;

var float					CurSoundLevel;
var float					CurLipBlendPercent;

struct native FacialTrackInfo
{
	var int		Channel1;
	var int		Channel2;

	var int		CurIndex;				// Index into the FacialExpressions array
	var int		Frame1;					// 
	var int		Frame2;

	var float	CurTrackBlend;
	var int		CurTrackBlendDir;

	var float	CurFrameDelay;			// Delay before blend to next frame
	var float	CurFrameBlend;			// Current blend percent between the current 2 frames

	var float	CurJawScale;
};

// 2 Tracks for playing facial animation sequences.  The first track is just a temp for 
//	sequences fading out, while the 2nd track is where most of the animation occurs, and where fading in occurs
var FacialTrackInfo		FacialTrack[2];

// Facial noise test values
var() bool				bFacialNoise;

enum EFaceNoiseType
{
	FNOISE_TranslateX,
	FNOISE_TranslateY,
	FNOISE_TranslateZ,
	FNOISE_RotatePitch,
	FNOISE_RotateYaw,
	FNOISE_RotateRoll
};

struct native FacialNoiseInfo
{
	var() name				BoneName			?("Name of bone to apply noise to.");
	var() EFaceNoiseType	Type				?("Type of noise to apply.");
	var() float				Rate				?("Rate at which bone moves.");
	var() float				Limit				?("Limit bone is amount to move.");
	var() float				PercentStop			?("Percent chance bone has to stop moving.");
	var() float				PercentStart		?("Percent chance bone has a chance to start moving if stopped.");
	var() float				PercentSameDir		?("Once started moving, percent chance to move same dir it was before stopped.");
	
	// Internal work var
	var float				Noise;
	var int					Dir;
};

var() FacialNoiseInfo	FacialNoise[8];
// ...JEP

// Expand effect.
var name				ExpandedBones[6];
var float				ExpandedScales[6];
var bool				bExpandedCollision, bExpanding;
var float				ExpandTimeRemaining, ExpandTimeEnd;
var float				ExpandCounter;

// Shrink effect.
var float				ShrinkTime;
var float				ShrinkCounter;			// Shrunken status, 0.0 is normal, 1.0 is fully shrunk, in between is transitioning.
var float				ShrinkCounterDestination;
var float				ShrinkRate;
var float				PreShrinkDrawScale;
var bool				bRestoringShrink;
var bool				bNotShrunkAtAll;		// A watch variable to prevent shrinkcounter delays on clients that aren't relevant when someone else gets restored.
var bool				bFullyShrunk;
var bool				bPartiallyShrunk;

// Step effects.
var bool						bPuddleArea;
var class<SoftParticleSystem>	PuddleSplashStepEffect;
var class<SoftParticleSystem>	SplashStepEffect;
var class<SoftParticleSystem>	FireStepEffect;
var class<SoftParticleSystem>	FireStepEffectShrunk;



/*-----------------------------------------------------------------------------
	Input
-----------------------------------------------------------------------------*/

// Input buttons.
var input byte
	bUse, bZoom, bRun, bLook, bSnapLevel,
	bStrafe, bFire, bAltFire, bFreeLook, 
	bExtra0, bExtra1, bExtra2, bExtra3;

var travel byte		bDuck;	// JEP Removed input modifier, as it was screwing up ducking for saved games



/*-----------------------------------------------------------------------------
	Movement & Navigation
-----------------------------------------------------------------------------*/

// General Speed and Control
var(Movement) travel float	GroundSpeed;		// The maximum ground speed.
var(Movement) travel float	AirSpeed;			// The maximum flying speed.
var(Movement) float		AccelRate;			// max acceleration rate
var(Movement) travel float	JumpZ;				// vertical acceleration w/ jump
var(Movement) float		MaxStepHeight;		// Maximum size of upward/downward step.
var(Movement) float		AirControl;			// amount of AirControl available to the pawn
var 		float		MoveTimer;
var 		Actor		MoveTarget;			// set by movement natives
var			Actor		FaceTarget;			// set by strafefacing native
var			vector 		Destination;		// set by Movement natives
var	 		vector		Focus;				// set by Movement natives
var			float		SpecialHeight;
var			float		DesiredSpeed;
var			float		MaxDesiredSpeed;
var			actor		SpecialGoal;		// used by navigation AI
var			float		SpecialPause;
var			NavigationPoint	RouteCache[16]; // Route Cache for Navigation
var			PointRegion	FootRegion;
var			PointRegion	HeadRegion;
var unbound bool		bBackPedaling, bWasBackPedaling;
var class<material>		LastWalkMaterial;
var			 bool		bIsWalking;
var			 bool		bAvoidLedges;		// Don't get too close to ledges.
var			 bool		bStopAtLedges;		// If bAvoidLedges and bStopAtLedges, Pawn doesn't try to walk along the edge at all
var const	 bool		bReducedSpeed;		// Used by movement natives.
var const	 bool		bHitSlopedWall;		// Used by physics.
var unbound bool		bJustLanded;		// Used by eyeheight adjustment.
var unbound bool		bWarping;			// Set when travelling through warpzone (so shouldn't telefrag)
var	unbound bool		bIsMultiSkinned;
var	unbound bool		bCountJumps;
var			bool		bUseZoneVelSwim;	// Pawn (rather than just players) will be affected by Zone Velocity when swimming.
// Wire crawling.
var unbound bool		bOnWire;
var unbound actor		OnWireBackwardsActor;
var unbound actor		OnWireForwardsActor;
var unbound float		OnWireAlpha;

// Swimming
var(Movement) float		WaterSpeed;			// The maximum swimming speed.
var unbound bool		bUpAndOut;
var	unbound bool		bDrowning;
var(Movement) unbound float	UnderWaterTime; // How much time pawn can go without air (in seconds).

// View rotation.
var bool				RotateToDesiredView;


/*-----------------------------------------------------------------------------
	Physics
-----------------------------------------------------------------------------*/

var	const	vector		Floor;				// Normal of floor pawn is standing on (only used by PHYS_Spider)
var const	float		AvgPhysicsTime;		// Physics updating time monitoring (for AI monitoring reaching destinations)
var	 		float		MinHitWall;			// Minimum HitNormal dot Velocity.Normal to get a HitWall from the physics
var			bool		bOnLadder;
var         bool        bOnRope;       
var         bool        bOnTurret;

/*-----------------------------------------------------------------------------
	Networking & Identification
-----------------------------------------------------------------------------*/

var			PlayerReplicationInfo PlayerReplicationInfo;
var() unbound class<PlayerReplicationInfo> PlayerReplicationInfoClass;
var() unbound localized string MenuName;	// Name used for this pawn type in menus (e.g. player selection) 
var() unbound localized string NameArticle; // Article used in conjunction with this class (e.g. "a", "an")
var unbound float		OldMessageTime;		// To limit frequency of voice messages.



/*-----------------------------------------------------------------------------
	Sounds
-----------------------------------------------------------------------------*/

var unbound float			SoundDampening;
var() unbound string		VoiceType;
var(Sounds)	unbound sound   HitSound1;
var(Sounds)	unbound sound   HitSound2;
var(Sounds)	unbound sound   Land;
var(Sounds)	unbound sound   Die;
var(Sounds) sound			JumpSound;

// Water
var(Sounds) unbound sound	ExitSplash;
var(Sounds) unbound sound	BigSplash;
var(Sounds) unbound sound	LittleSplash[2];
var(Sounds) unbound sound	WaterAmbience;
var unbound float			WaterAmbientTime;
var unbound float			SplashTime;

var unbound sound			GibbySound[3];



/*-----------------------------------------------------------------------------
	Viewing & Camera
-----------------------------------------------------------------------------*/

var			 bool		bBehindView;		// Outside-the-player view.
var			 rotator	ViewRotation;		// View rotation.
var          int        ViewRotationInt;    // View rotation as an integer
var			 float		OrthoZoom;			// Orthogonal/map view zoom factor.
var()		 travel float	FovAngle;			// X field of view angle in degrees, usually 90.
var()		 travel float	BaseEyeHeight;		// Base eye height above collision center.
var			 travel float	EyeHeight;			// Current eye height, adjusted for bobbing and stairs.
var			 Decal		Shadow;
var unbound  bool		bUpdatingDisplay;	// To avoid infinite recursion through inventory setdisplay.
var			 bool		bViewTarget;
var unbound  vector		WalkBob;


/*-----------------------------------------------------------------------------
	Class based stuff
-----------------------------------------------------------------------------*/
var			bool		bNoLogout;			// Set to true when we don't want a player to logout when getting deleted (for class based game)


/*-----------------------------------------------------------------------------
	Replication
-----------------------------------------------------------------------------*/

replication
{
	// Variables the server should send to the client.
	reliable if( Role==ROLE_Authority )
		Weapon, PlayerReplicationInfo, bCanFly, UsedItem, ShieldItem, BoneScales,
		ShrinkCounterDestination, bNotShrunkAtAll, bFullyShrunk, DOTAffectorList, ShieldProtection;
	reliable if( bNetOwner && Role==ROLE_Authority )
        bIsPlayer, CarriedDecoration, SelectedItem,
        GroundSpeed, WaterSpeed, AirSpeed, AccelRate, JumpZ, AirControl,
        bBehindView, PlayerRestartState, RemainingAir, Energy, Cash;       
    unreliable if( (bNetOwner && bIsPlayer && bNetInitial && Role==ROLE_Authority) || (bDemoRecording) )
        ViewRotation;    
	unreliable if( bNetOwner && Role==ROLE_Authority )
        MoveTarget;
    unreliable if ( !bNetOwner && Role==ROLE_Authority )
        bOnTurret, bOnLadder, bOnRope, ViewRotationInt, PostureState;
	reliable if( bDemoRecording )
		EyeHeight;

	// Functions the server calls on the client side.
	reliable if( RemoteRole==ROLE_AutonomousProxy ) 
		ClientDying, ClientRestart, ClientGameEnded, ClientSetRotation, ClientSetLocation, 
		KillSOSPowers, ClientSetBaseEyeHeight;
	unreliable if( (!bDemoRecording || bClientDemoRecording && bClientDemoNetFunc) && Role==ROLE_Authority )
		ClientHearSound;
	reliable if ( (!bDemoRecording || (bClientDemoRecording && bClientDemoNetFunc) || (Level.NetMode==NM_Standalone && IsA('PlayerPawn'))) && Role == ROLE_Authority )
		ClientMessage, TeamMessage, ReceiveLocalizedMessage;
	reliable if ( Role==ROLE_Authority )
		BringUpLastWeapon, WeaponDown, WeaponUp, ChangeToWeapon;
	reliable toall if ( !bNetOwner && Role==ROLE_Authority)
		ClientDestroyDecals;

	// Functions the client calls on the server.
	unreliable if( Role<ROLE_Authority )
		SendVoiceMessage, ServerSetLoadCount, ServerWeaponAction, DropDecoration;

	reliable if( Role<ROLE_Authority )
		ServerChangeToWeapon;
}



/*-----------------------------------------------------------------------------
	Object / Initialization
-----------------------------------------------------------------------------*/

// Called by the engine right after the object is spawned or loaded from the level file.
simulated event PreBeginPlay()
{
	// Chunk of things to do if we aren't a client side pawn.
	if ( Level.NetMode != NM_Client )
	{
		// Add us to the global pawn list.
		AddPawn();

		// Call super.
		Super.PreBeginPlay();

		// If we were destroyed by the above process, don't do anything else.
		if ( bDeleteMe )
			return;

		// Init some values.
		Instigator = Self;
		DesiredRotation = Rotation;
		SightCounter = 0.2 * FRand();  //offset randomly 
		if ( Level.Game != None )
			Skill += Level.Game.Difficulty; 
		Skill = FClamp(Skill, 0, 3);
		PreSetMovement();

		// Modify our collision and health given our drawscale.
		if ( DrawScale != Default.Drawscale )
		{
			SetCollisionSize(CollisionRadius*DrawScale/Default.DrawScale, CollisionHeight*DrawScale/Default.DrawScale);
			Health = Health * DrawScale/Default.DrawScale;
		}

		// If we are a "player" we need a replication info.
		// "Player" includes bots.
		if ( bIsPlayer )
		{
			if ( PlayerReplicationInfoClass != None )
			{
				PlayerReplicationInfo = Spawn( PlayerReplicationInfoClass, Self,,vect(0,0,0),rot(0,0,0) );
			}
			else
			{
				PlayerReplicationInfo = Spawn( class'PlayerReplicationInfo', Self,,vect(0,0,0),rot(0,0,0) );
			}
			
			InitPlayerReplicationInfo();
		}

		// Stuff to do if we aren't a player.
		if ( !bIsPlayer )
		{
			if ( BaseEyeHeight == 0 )
				BaseEyeHeight = 0.8 * CollisionHeight;
			EyeHeight = BaseEyeHeight;
			if ( Fatness == 0 ) // Vary monster fatness slightly if at default.
				Fatness = 120 + Rand(8) + Rand(8);
		}
	}

	// Prepare the pawn for tracking.
	HeadTracking    = spawn(class'PawnTrackingInfo', self);
	EyeTracking     = spawn(class'PawnTrackingInfo', self);
	TorsoTracking   = spawn(class'PawnTrackingInfo', self);
	
	TorsoTracking.DesiredWeight = 1.0;
	TorsoTracking.WeightRate	= 2.0;

	//Log("PRE BEGIN PLAY ROLE:"@Role@"RemoteRole:"@RemoteRole);
}

simulated function PostBeginPlay()
{
	local int i;

	Super.PostBeginPlay();

	// Add accessories
	AddAccessories();
	SplashTime = 0;

	Enable('Tick');
	
	// JEP... (Facial expression test)
	/*
	bFacialNoise = true;
	FacialNoise[0].BoneName = 'Head';
	FacialNoise[0].Type = FNOISE_RotatePitch;
	FacialNoise[0].Rate = 0.3f;
	FacialNoise[0].Limit = 0.2f;
	FacialNoise[0].PercentStop = 0.04f;
	FacialNoise[0].PercentStart = 0.15f;
	FacialNoise[0].PercentSameDir = 0.90f;

	FacialNoise[1].BoneName = 'Head';
	FacialNoise[1].Type = FNOISE_RotateYaw;
	FacialNoise[1].Rate = 0.3f;
	FacialNoise[1].Limit = 0.2f;
	FacialNoise[1].PercentStop = 0.04f;
	FacialNoise[1].PercentStart = 0.15f;
	FacialNoise[1].PercentSameDir = 0.90f;

	FacialNoise[2].BoneName = 'Head';
	FacialNoise[2].Type = FNOISE_RotateRoll;
	FacialNoise[2].Rate = 0.3f;
	FacialNoise[2].Limit = 0.2f;
	FacialNoise[2].PercentStop = 0.04f;
	FacialNoise[2].PercentStart = 0.15f;
	FacialNoise[2].PercentSameDir = 0.90f;

	FacialNoise[3].BoneName = 'Brow';
	FacialNoise[3].Type = FNOISE_TranslateX;
	FacialNoise[3].Rate = 0.45f;
	FacialNoise[3].Limit = 0.15f;
	FacialNoise[3].PercentStop = 0.26f;
	FacialNoise[3].PercentStart = 0.65f;
	FacialNoise[3].PercentSameDir = 0.50f;
	*/
	// ...JEP
}

simulated function PostNetInitial()
{
	// To prevent smooth shrinking when somebody becomes relevant.
	ShrinkCounter = ShrinkCounterDestination;
}

function InitPlayerReplicationInfo()
{
	if (PlayerReplicationInfo.PlayerName == "")
		PlayerReplicationInfo.PlayerName = class'GameInfo'.Default.DefaultPlayerName;
}

simulated function Destroyed()
{
	local Inventory Inv;
	local Pawn OtherPawn;
	local int i;

	if ( Shadow != None )
		Shadow.Destroy();
	if ( Role < ROLE_Authority )
		return;

	RemovePawn();

	for( Inv=Inventory; Inv!=None; Inv=Inv.Inventory )   
		Inv.Destroy();
	Weapon = None;
	Inventory = None;
	if ( bIsPlayer && (Level.Game != None) && !bNoLogout )
		Level.Game.logout(self);
	if ( PlayerReplicationInfo != None )
		PlayerReplicationInfo.Destroy();
	for ( OtherPawn=Level.PawnList; OtherPawn!=None; OtherPawn=OtherPawn.nextPawn )
		OtherPawn.Killed( None, self, class'ExplosionDamage' );

	// Destroy tracking utilities.
	if ( HeadTracking != None )
		HeadTracking.Destroy();
	if ( EyeTracking != None )
		EyeTracking.Destroy();
	if ( TorsoTracking != None )
		TorsoTracking.Destroy();

	// Destroy accessories.
	for (i=0; i<6; i++)
	{
		if ( MountedDecorations[i] != None )
			MountedDecorations[i].Destroy();
	}

	Super.Destroyed();
}

simulated function AddAccessories()
{
    local vector EndPos;
	local int i;
	local Actor a;
	local Decoration d;
	local bool b;

	for ( i=0; i<6; i++ )
	{
		if ( Accessories[i] != none )
		{
			a = Trace( EndPos,,Location+vect( 0,0,EyeHeight ) + 72 * Vector( ViewRotation ) );
			if ( a==none )
				d = Spawn( Accessories[i],Self,,Location+vect( 0,0,EyeHeight ) + 72 * Vector( ViewRotation ) );
			else
				d = Spawn( Accessories[i],Self,,EndPos );
			b = AddMountable( d, true, true );
			if ( !b ) d.Destroy();
		}
	}
}

// Add pawn to level pawn list (linked using nextPawn).
native(529) final function AddPawn();

// Remove pawn from level pawn list.
native(530) final function RemovePawn();

function NotifyDodge( optional vector TestVector );

// Return true if controlled by local (not network) player.
simulated function bool IsLocallyControlled()
{
	return true;
}



/*-----------------------------------------------------------------------------
	State Management
	NOTE: Only change states through these functions.
-----------------------------------------------------------------------------*/

function SetControlState( EControlState NewState )
{
	NotifyControlStateChange(SC_Exit);
	ControlState = NewState;
	NotifyControlStateChange(SC_Enter);
}

simulated function EControlState GetControlState()
{
	return ControlState;
}

function NotifyControlStateChange( EStateChange Change )
{
	//Log( "Control State Change" @ GetControlStateString( ControlState ) @ "To" @ Change );

	switch ( ControlState )
	{
		case CS_None:
			break;
		case CS_Normal:
			ControlStateChange_Normal( Change );
			break;
		case CS_Flying:
			ControlStateChange_Flying( Change );
			break;
		case CS_Swimming:
			ControlStateChange_Swimming( Change );
			break;
		case CS_Dead:
			ControlStateChange_Dead( Change );
			break;
		case CS_Spectating:
			ControlStateChange_Spectating( Change );
			break;
		case CS_Stasis:
			ControlStateChange_Stasis( Change );
			break;
		case CS_Rope:
			ControlStateChange_Rope( Change );
			break;
		case CS_Ladder:
			ControlStateChange_Ladder( Change );
			break;
		case CS_Jetpack:
			ControlStateChange_Jetpack( Change );
			break;
		case CS_Frozen:
			ControlStateChange_Frozen( Change );
			break;
		default:
			Log( "NotifyControlStateChange with invalid state:"@ControlState );
			break;
	}
}

function ControlStateChange_Normal( EStateChange Change )
{
	switch ( Change )
	{
		case SC_Enter:
			EnterControlState_Normal();
			break;
		case SC_Exit:
			ExitControlState_Normal();
			break;
	}
}
function EnterControlState_Normal() {}
function ExitControlState_Normal() {}

function ControlStateChange_Flying(EStateChange Change)
{
	switch (Change)
	{
		case SC_Enter:
			EnterControlState_Flying();
			break;
		case SC_Exit:
			ExitControlState_Flying();
			break;
	}
}
function EnterControlState_Flying() {}
function ExitControlState_Flying() {}

function ControlStateChange_Swimming(EStateChange Change)
{
	switch (Change)
	{
		case SC_Enter:
			EnterControlState_Swimming();
			break;
		case SC_Exit:
			ExitControlState_Swimming();
			break;
	}
}
function EnterControlState_Swimming() {}
function ExitControlState_Swimming() {}

function ControlStateChange_Spectating(EStateChange Change)
{
	switch (Change)
	{
		case SC_Enter:
			EnterControlState_Spectating();
			break;
		case SC_Exit:
			ExitControlState_Spectating();
			break;
	}
}
function EnterControlState_Spectating() {}
function ExitControlState_Spectating() {}

function ControlStateChange_Dead(EStateChange Change) 
{
	switch (Change)
	{
		case SC_Enter:
			EnterControlState_Dead();
			break;
		case SC_Exit:
			ExitControlState_Dead();
			break;
	}
}
function EnterControlState_Dead()
{
	bHidden = true;
	if ( bIsPlayer )
		HidePlayer();
	else
		Destroy();
}
function ExitControlState_Dead() {}

function ControlStateChange_Stasis(EStateChange Change) 
{
	switch (Change)
	{
		case SC_Enter:
			EnterControlState_Stasis();
			break;
		case SC_Exit:
			ExitControlState_Stasis();
			break;
	}
}
function EnterControlState_Stasis()
{
	SetPhysics(PHYS_None);
	HidePlayer();
}
function ExitControlState_Stasis() {}


function EnterControlState_Rope() {}
function ExitControlState_Rope() {}

function ControlStateChange_Rope(EStateChange Change)
{
	switch (Change)
	{
		case SC_Enter:
			EnterControlState_Rope();
			break;
		case SC_Exit:
			ExitControlState_Rope();
			break;
	}
}

function EnterControlState_Ladder() {}
function ExitControlState_Ladder() {}

function ControlStateChange_Ladder(EStateChange Change)
{
	switch (Change)
	{
		case SC_Enter:
			EnterControlState_Ladder();
			break;
		case SC_Exit:
			ExitControlState_Ladder();
			break;
	}
}

function ControlStateChange_Jetpack(EStateChange Change) 
{
	switch (Change)
	{
		case SC_Enter:
			EnterControlState_Jetpack();
			break;
		case SC_Exit:
			ExitControlState_Jetpack();
			break;
	}
}

function EnterControlState_Jetpack() {}
function ExitControlState_Jetpack() {}

function ControlStateChange_Frozen( EStateChange Change )
{
	switch ( Change )
	{
		case SC_Enter:
			EnterControlState_Frozen();
			break;
		case SC_Exit:
			ExitControlState_Frozen();
			break;
	}
}
function EnterControlState_Frozen()
{
//	SetPhysics( PHYS_None );
}
function ExitControlState_Frozen() {}

/*-----------------------------------------------------------------------------
    Ladder State
-----------------------------------------------------------------------------*/
event SetLadderState( ELadderState NewState )
{
	NotifyLadderStateChange(NewState, LadderState);
	LadderState = NewState;
}

function NotifyLadderStateChange(ELadderState NewState, ELadderState OldState)
{
    if ( OldState == NewState )
        return;

	switch (NewState)
	{
		case LADDER_Forward:
			LadderStateChange_Forward(OldState);
			break;
        default:
            LadderStateChange_Other(OldState);
            break;
	}
}

function LadderStateChange_Forward(ELadderState OldState) {}
function LadderStateChange_Other(ELadderState OldState) {}

/*-----------------------------------------------------------------------------
    Rope State
-----------------------------------------------------------------------------*/
event SetRopeClimbState( ERopeClimbState NewState )
{
	NotifyRopeClimbStateChange(NewState, RopeClimbState);
	RopeClimbState = NewState;
}

function NotifyRopeClimbStateChange(ERopeClimbState NewState, ERopeClimbState OldState)
{
    if ( OldState == NewState )
        return;

	switch (NewState)
	{
		case RS_ClimbDown:
			RopeClimbStateChange_ClimbDown(OldState);
			break;
        case RS_ClimbUp:
            RopeClimbStateChange_ClimbUp(OldState);
            break;
        case RS_ClimbNone:
            RopeClimbStateChange_ClimbNone(OldState);
            break;
        default:
            break;
	}
}

function RopeClimbStateChange_ClimbUp(ERopeClimbState OldState) {}
function RopeClimbStateChange_ClimbDown(ERopeClimbState OldState) {}
function RopeClimbStateChange_ClimbNone(ERopeClimbState OldState) {}

/*-----------------------------------------------------------------------------
	Animation Support
-----------------------------------------------------------------------------*/
function name GetSequence(int channel)
{
	local MeshInstance m;

	m=GetMeshInstance();
	if(m==none) 
	{
		//BroadcastMessage("GetSequence: MeshInstance is None");
		return '';
	}
	return m.MeshChannels[channel].AnimSequence;
}

// Default is humanoid.
simulated function EPawnBodyPart GetPartForBone(name BoneName)
{
	if (
		(BoneName=='Root') ||
		(BoneName=='Abdomen')
		)
		return(BODYPART_Stomach);
	else if (
		(BoneName=='Chest')
		)
		return(BODYPART_Chest);

	else if (
		(BoneName=='Head') ||
		(BoneName=='Neck') ||
		(BoneName=='Brow') ||
		(BoneName=='Jaw') ||
		(BoneName=='Lip_L') ||
		(BoneName=='Lip_U') ||
		(BoneName=='MouthCorner') ||
		(BoneName=='Pupil_L') ||
		(BoneName=='Pupil_R') ||
		(BoneName=='Eyelid_L') ||
		(BoneName=='Eyelid_R')
		)
		return(BODYPART_Head);

	else if (
		(BoneName=='Pelvis')
		)
		return(BODYPART_Crotch);

	else if (
		(BoneName=='Bicep_L')
		)
		return(BODYPART_ShoulderLeft);
	else if (
		(BoneName=='Bicep_R')
		)
		return(BODYPART_ShoulderRight);

	else if (
		(BoneName=='Thigh_L') ||
		(BoneName=='Shin_L')
		)
		return(BODYPART_KneeLeft);
	else if (
		(BoneName=='Thigh_R') ||
		(BoneName=='Shin_R')
		)
		return(BODYPART_KneeRight);

	else if (
		(BoneName=='Foot_L')
		)
		return(BODYPART_FootLeft);
	else if (
		(BoneName=='Foot_R')
		)
		return(BODYPART_FootRight);

	else if (
		(BoneName=='Forearm_L') ||
		(BoneName=='Hand_L') ||
		(BoneName=='Thumb_L') ||
		(BoneName=='Thumbtip_L') ||
		(BoneName=='Forefing_L') ||
		(BoneName=='Forefingtip_L') ||
		(BoneName=='Midfing_L') ||
		(BoneName=='Midfingtip_L') ||
		(BoneName=='Ringfing_L') ||
		(BoneName=='Ringfingtip_L') ||
		(BoneName=='Pinky_L') ||
		(BoneName=='Pinkytip_L')
		)
		return(BODYPART_HandLeft);
	else if (
		(BoneName=='Forearm_R') ||
		(BoneName=='Hand_R') ||
		(BoneName=='Thumb_R') ||
		(BoneName=='Thumbtip_R') ||
		(BoneName=='Forefing_R') ||
		(BoneName=='Forefingtip_R') ||
		(BoneName=='Midfing_R') ||
		(BoneName=='Midfingtip_R') ||
		(BoneName=='Ringfing_R') ||
		(BoneName=='Ringfingtip_R') ||
		(BoneName=='Pinky_R') ||
		(BoneName=='Pinkytip_R')
		)
		return(BODYPART_HandRight);
	
	else
		return(BODYPART_Default);
}

function PlayAllAnim(name Sequence, optional float Rate, optional float TweenTime, optional bool bLooping)
{
	//if (Self.Name == 'NPCMale1')
	//	BroadcastMessage(self.Name@": AllAnim:"@Sequence);

	GetMeshInstance();
	if (MeshInstance==None)
		return;

	if ((MeshInstance.MeshChannels[0].AnimSequence == Sequence)
	 && ((Sequence=='None') || (IsAnimating(0))))
		return; // already playing
	
	if ( !bLaissezFaireBlending )
		AnimBlend = 0.0;

	if (Rate == 0.0) 
		Rate = 1.0; // default

	if (TweenTime == 0.0) 
		TweenTime = -1.0; // default

	if (bLooping)
		LoopAnim(Sequence, Rate, TweenTime);
	else
		PlayAnim(Sequence, Rate, TweenTime);
}

function PlayBottomAnim(name Sequence, optional float Rate, optional float TweenTime, optional bool bLooping, optional bool bNoCallAnimEx )
{
	//if (Self.Name == 'NPCMale1')
	//	BroadcastMessage(self.Name@": BottomAnim:"@Sequence);

	GetMeshInstance();

	if (MeshInstance==None)
		return;
	if ((MeshInstance.MeshChannels[2].AnimSequence == Sequence)
	 && ((Sequence=='None') || (IsAnimating(2))))
		return; // already playing

	if (Sequence=='None')
	{
		DesiredBottomAnimBlend = 1.0;
		BottomAnimBlend = 0.0;
		if (TweenTime == 0.0)
			BottomAnimBlendRate = 5.0;
		else
			BottomAnimBlendRate = 0.5 / TweenTime;
		        
        /* Don't use
        if ( !bNoCallAnimEx )
            AnimEndEx( 2 );
        */

		return; // don't actually play the none anim, we want to shut off the channel gradually, the ticking will set it to none later
	}
	else if (MeshInstance.MeshChannels[2].AnimSequence=='None')
	{
		if ( bLaissezFaireBlending )
		{
			MeshInstance.MeshChannels[1].AnimSequence	= 'None';
			//MeshInstance.MeshChannels[1].AnimBlend		= 0;

		}
		else 
		{
			DesiredBottomAnimBlend = 0.0;
			BottomAnimBlend = 1.0;
			if (TweenTime == 0.0)
				BottomAnimBlendRate = 5.0;
			else
				BottomAnimBlendRate = 0.5 / TweenTime;
		}
	}
	else
	{
		BottomAnimBlend = 0.0;
		DesiredBottomAnimBlend = 0.0;
		BottomAnimBlendRate = 1.0;
	}
	
	if (Rate == 0.0) Rate = 1.0; // default
	if (TweenTime == 0.0) TweenTime = -1.0; // default

	if (bLooping)
		LoopAnim(Sequence, Rate, TweenTime, , 2);
	else
		PlayAnim(Sequence, Rate, TweenTime, 2);
}

function PlayTopAnim(name Sequence, optional float Rate, optional float TweenTime, optional bool bLooping, optional bool bNoCallAnimEx, optional bool bCanInterrupt )
{
	//if (Self.Name == 'NPCMale1')
	//	BroadcastMessage(self.Name@": TopAnim:"@Sequence);

	GetMeshInstance();
	if (MeshInstance==None)
		return;
	
	if ((MeshInstance.MeshChannels[2].AnimSequence == Sequence)
	 && ((Sequence=='None') || (IsAnimating(2))))

	if ((MeshInstance.MeshChannels[ 1 ].AnimSequence == Sequence) && ((Sequence == 'None') || (IsAnimating( 1 ))) && !bCanInterrupt)
		return; // already playing
	
	if (Sequence=='None')
	{
		if ( bLaissezFaireBlending )
		{
			MeshInstance.MeshChannels[1].AnimSequence	= 'None';
			//MeshInstance.MeshChannels[1].AnimBlend		= 0;

		}
		else
		{
			DesiredTopAnimBlend = 1.0;
			TopAnimBlend = 0.0;
			if (TweenTime == 0.0)
				TopAnimBlendRate = 5.0;
			else
				TopAnimBlendRate = 0.5 / TweenTime;
        
			/* Don't use
			if ( !bNoCallAnimEx )
	            AnimEndEx( 1 );
		    */
		}
		return; // don't actually play the none anim, we want to shut off the channel gradually, the ticking will set it to none later
	}
	else if (MeshInstance.MeshChannels[1].AnimSequence=='None')
	{
		DesiredTopAnimBlend = 0.0;
		TopAnimBlend = 1.0;
		if (TweenTime == 0.0)
			TopAnimBlendRate = 5.0;
		else
			TopAnimBlendRate = 0.5 / TweenTime;
	}
	else
	{
		TopAnimBlend = 0.0;
		DesiredTopAnimBlend = 0.0;
		TopAnimBlendRate = 1.0;
	}

	if (Rate == 0.0) Rate = 1.0; // default
	if (TweenTime == 0.0) TweenTime = -1.0; // default

	if (bLooping)
		LoopAnim(Sequence, Rate, TweenTime, , 1);
	else
		PlayAnim(Sequence, Rate, TweenTime, 1);
}

function PlayFaceAnim( name Sequence, optional float Rate, optional float TweenTime, optional bool bLooping )
{
	return;		// JEP

	GetMeshInstance();
	if (MeshInstance==None)
		return;
	if ((MeshInstance.MeshChannels[5].AnimSequence == Sequence)
	 && ((Sequence=='None') || (IsAnimating(5))))
		return; // already playing

	if (Sequence=='None')
	{
		DesiredFaceAnimBlend = 1.0;
		FaceAnimBlend = 0.0;
		if (TweenTime == 0.0)
			FaceAnimBlendRate = 5.0;
		else
			FaceAnimBlendRate = 0.5 / TweenTime;
		return; // don't actually play the none anim, we want to shut off the channel gradually, the ticking will set it to none later
	}
	else if (MeshInstance.MeshChannels[5].AnimSequence=='None')
	{
		DesiredFaceAnimBlend = 0.0;
		FaceAnimBlend = 1.0;
		if (TweenTime == 0.0)
			FaceAnimBlendRate = 5.0;
		else
			FaceAnimBlendRate = 0.5 / TweenTime;
	}
	else
	{
		FaceAnimBlend = 0.0;
		DesiredFaceAnimBlend = 0.0;
		FaceAnimBlendRate = 1.0;
	}
	
	if (Rate == 0.0) Rate = 1.0; // default
	if (TweenTime == 0.0) TweenTime = -1.0; // default

	if (bLooping)
		LoopAnim(Sequence, Rate, TweenTime,, 5);
	else
		PlayAnim(Sequence, Rate, TweenTime, 5);
}

// Special anim is currently channel 4; only used right now by AI for special pain anims while crouching.
function PlaySpecialAnim(name Sequence, optional float Rate, optional float TweenTime, optional bool bLooping, optional bool bNoCallAnimEx )
{
	GetMeshInstance();
	if (MeshInstance==None)
		return;
	if ((MeshInstance.MeshChannels[3].AnimSequence == Sequence)
	 && ((Sequence=='None') || (IsAnimating(3))))
		return; // already playing

	if (Sequence=='None')
	{
		DesiredSpecialAnimBlend = 1.0;
		SpecialAnimBlend = 0.0;
		if (TweenTime == 0.0)
			SpecialAnimBlendRate = 5.0;
		else
			SpecialAnimBlendRate = 0.5 / TweenTime;

        /* Don't Use
        if ( !bNoCallAnimEx )      
            AnimEndEx( 3 );
        */

		return; // don't actually play the none anim, we want to shut off the channel gradually, the ticking will set it to none later
	}
	else if (MeshInstance.MeshChannels[3].AnimSequence=='None')
	{
		DesiredSpecialAnimBlend = 0.0;
		SpecialAnimBlend = 1.0;
		if (TweenTime == 0.0)
			SpecialAnimBlendRate = 5.0;
		else
			SpecialAnimBlendRate = 0.5 / TweenTime;
	}
	else
	{
		SpecialAnimBlend = 0.0;
		DesiredSpecialAnimBlend = 0.0;
		SpecialAnimBlendRate = 1.0;
	}
	
	if (Rate == 0.0) Rate = 1.0; // default
	if (TweenTime == 0.0) TweenTime = -1.0; // default

	if (bLooping)
		LoopAnim(Sequence, Rate, TweenTime,, 3);
	else
		PlayAnim(Sequence, Rate, TweenTime, 3);
}

function SetFacialExpression( EFacialExpression Expression, optional bool bUseAsDefault, optional bool bNoLoop )
{
	return;			// JEP

	switch ( Expression )
	{
		Case FACE_Normal:
			PlayFaceAnim( 'None',, 0.52, true );
			break;
		Case FACE_Breathe1:
			PlayFaceAnim( 'F_Breathe1',, 0.1, !bNoLoop );
			break;
		Case FACE_Breathe2:
			PlayFaceAnim( 'F_Breathe2',, 0.1, !bNoLoop );
			break;
		Case FACE_Clenched:
			PlayFaceAnim( 'F_Clench1',, 0.1, !bNoLoop );
			break;
		Case FACE_Frown:
			PlayFaceAnim( 'F_Frown1',, 0.1, !bNoLoop );
			break;
		Case FACE_Pain1:
			PlayFaceAnim( 'F_Pain1',, 0.1, !bNoLoop );
			break;
		Case FACE_Pain2:
			PlayFaceAnim( 'F_Pain2',, 0.1, !bNoLoop );
			break;
		Case FACE_Roar:
			PlayFaceAnim( 'F_Roar1',, 0.1, !bNoLoop );
			break;
		Case FACE_AngrySmile:
			PlayFaceAnim( 'F_SmileA1',, 0.1, !bNoLoop );
			break;
		Case FACE_HappySmile:
			PlayFaceAnim( 'F_SmileH1',, 0.1, !bNoLoop );
			break;
		Case FACE_Sneer:
			PlayFaceAnim( 'None' );
			PlayFaceAnim( 'F_Sneer1',, 0.1, !bNoLoop );
			break;
		Case FACE_Surprise:
			PlayFaceAnim( 'F_Surprise1',, 0.1, !bNoLoop );
			break;
		Case FACE_Scared1:
			PlayFaceAnim( 'F_Scared1',, 0.1, !bNoLoop );
			break;
//		Default:
//			PlayFaceAnim( 'None' );
	}
	if( bUseAsDefault )
	{
		FacialExpression = Expression;
	}
}

// JEP...
//================================================================================
//	SetupTrackChannels
//================================================================================
function SetupTrackChannels()
{
	FacialTrack[0].Channel1 = 6;
	FacialTrack[0].Channel2 = 7;
	FacialTrack[1].Channel1 = 8;
	FacialTrack[1].Channel2 = 9;
}

//================================================================================
//	BlendOutTrack
//================================================================================
function BlendOutTrack(int TrackIndex)
{
	//BroadcastMessage("BlendOutTrack:"@TrackIndex);

	//FacialTrack[TrackIndex].CurTrackBlendDir = -1;
	//return;

	if (TrackIndex == 1)
	{
		// Copy track 1 to track 0 (where the fade out will occur)
		FacialTrack[0] = FacialTrack[1];
		SetupTrackChannels();
		// Stop track 1
		StopTrack(1);
		// Play the copied animation info on track 0 instead
		PlayTrackAnim(0);
	}
	
	// Fade out always occurs on track 0 (track 1 is for fading in)
	// Set the fade dir
	FacialTrack[0].CurTrackBlendDir = -1;
}

//================================================================================
//	StopTrack
//================================================================================
function StopTrack(int TrackIndex)
{
	local int			c1, c2;
    local MeshInstance	Inst;

	//BroadcastMessage("StopTrack:"@TrackIndex);

	if (FacialTrack[TrackIndex].CurIndex == -1)
		return;		// Already been stopped

	Inst = GetMeshInstance();

	if (Inst == None)
		return;

	SetupTrackChannels();

	c1 = FacialTrack[TrackIndex].Channel1;
	c2 = FacialTrack[TrackIndex].Channel2;

	FacialTrack[TrackIndex].CurIndex = -1;
	
	Inst.MeshChannels[c1].AnimSequence = 'None';
	Inst.MeshChannels[c2].AnimSequence = 'None';
}

//================================================================================
//	PlayTrackAnim
//================================================================================
function PlayTrackAnim(int TrackIndex)
{
	local int		CurIndex, Frame1, Frame2;
	local int		c1, c2;

	//BroadcastMessage("PlayTrackAnim:"@TrackIndex);

	CurIndex = FacialTrack[TrackIndex].CurIndex;

	if (CurIndex == -1)
		return;

	SetupTrackChannels();

	c1 = FacialTrack[TrackIndex].Channel1;
	c2 = FacialTrack[TrackIndex].Channel2;

	Frame1 = FacialTrack[TrackIndex].Frame1;
	Frame2 = FacialTrack[TrackIndex].Frame2;

	if ((Frame1 == -1) || (Frame2 == -1))
		return;

	//LoopAnim(FacialExpressions[CurIndex].FacialFrame[Frame1].AnimName,,0.5f,0.5f,c1);
	//LoopAnim(FacialExpressions[CurIndex].FacialFrame[Frame2].AnimName,,0.5f,0.5f,c2);
	LoopAnim(FacialExpressions[CurIndex].FacialFrame[Frame1].AnimName,,,,c1);
	LoopAnim(FacialExpressions[CurIndex].FacialFrame[Frame2].AnimName,,,,c2);
	
	SetUpFacialBlending(TrackIndex);
}

//================================================================================
//	NextFacialExpressionFrame
//================================================================================
function bool NextFacialExpressionFrame(int TrackIndex)
{
	local int		c1, c2;
	local int		Frame1, Frame2, CurIndex;
	
	//BroadcastMessage("NextFacialExpressionFrame:"@TrackIndex);

	SetupTrackChannels();

	c1 = FacialTrack[TrackIndex].Channel1;
	c2 = FacialTrack[TrackIndex].Channel2;

	CurIndex = FacialTrack[TrackIndex].CurIndex;

	Frame2 = FacialTrack[TrackIndex].Frame2;
	if (Frame2 == -1)		// Must be just starting out, default to 0
		Frame2 = 0;
	// Set frame 1 to frame 2
	Frame1 = Frame2;
	
	// Advance frame 2
	Frame2++;
	
	// If we passed up the end if the frame sequence, or the next frame is none, then loop it
	if (Frame2 > 15 || FacialExpressions[CurIndex].FacialFrame[Frame2].AnimName == '')
	{
		if (FacialExpressions[CurIndex].bNoLoop)
		{
			// No looping, start blending out the track now
			BlendOutTrack(TrackIndex);		// We are done, start fading out this track

			if (Frame2 > 0)
				Frame2--;		// Undo increment
		}
		else
			Frame2 = 0;

		if (FacialExpressions[CurIndex].FacialFrame[Frame2].AnimName == '')
		{
			// Still invalid
			StopTrack(TrackIndex);
			return false;
		}
	}
	
	FacialTrack[TrackIndex].Frame1 = Frame1;		// Since we modified frame (in a copy), copy it back
	FacialTrack[TrackIndex].Frame2 = Frame2;		// Since we modified frame (in a copy), copy it back
	
	FacialTrack[TrackIndex].CurFrameDelay = FacialExpressions[CurIndex].FacialFrame[Frame1].Delay;
	FacialTrack[TrackIndex].CurFrameBlend = 0.0f;

	// Play the anims on this track
	PlayTrackAnim(TrackIndex);

	return true;
}

//================================================================================
//	SetupFacialBlending
//================================================================================
function SetupFacialBlending(int TrackIndex)
{
    local MeshInstance	Inst;
	local int			Frame1, Frame2, CurIndex;
	local int			c1, c2;
	local float			TrackBlend, FrameBlend, s1, s2;

	Inst = GetMeshInstance();

	if (Inst == None)
		return;

	SetupTrackChannels();

	c1 = FacialTrack[TrackIndex].Channel1;
	c2 = FacialTrack[TrackIndex].Channel2;

	CurIndex = FacialTrack[TrackIndex].CurIndex;
	Frame1 = FacialTrack[TrackIndex].Frame1;
	Frame2 = FacialTrack[TrackIndex].Frame2;

	TrackBlend = 1.0f-FacialTrack[TrackIndex].CurTrackBlend;
	FrameBlend = FacialTrack[TrackIndex].CurFrameBlend;
	FrameBlend = (Cos(FrameBlend*3.14159)+1.0f)*0.5f;	// Smooth Cos curve blend

	Inst.MeshChannels[c1].AnimBlend = TrackBlend;
	Inst.MeshChannels[c2].AnimBlend = 1.0f+(TrackBlend-1.0f)*(1.0f-FrameBlend);

	//Inst.MeshChannels[c1].AnimBlend = 0.0f;
	//Inst.MeshChannels[c2].AnimBlend = s2;

	// Force animation to frame 0 for both channels (animations should only have one frame anyhow, but just in case...)
	Inst.MeshChannels[c1].AnimFrame = 0.0f;
	Inst.MeshChannels[c2].AnimFrame = 0.0f;

	// Setup the current JawScale
	s1 = FacialExpressions[CurIndex].FacialFrame[Frame1].JawScale;
	s2 = FacialExpressions[CurIndex].FacialFrame[Frame2].JawScale;

	if (s1 == 0.0f)
		s1 = 1.0f;
	if (s2 == 0.0f)
		s2 = 1.0f;

	FacialTrack[TrackIndex].CurJawScale = s1 + (s2-s1)*(1.0f-FrameBlend);
}

//================================================================================
//	DriveFacialTrack
//================================================================================
function DriveFacialTrack(int TrackIndex, float DeltaSeconds)
{
    local MeshInstance	Inst;
	local int			Frame1, Frame2, CurIndex;
	
	if (FacialTrack[TrackIndex].CurIndex == -1)
		return;		// This track not doing anything

	//BroadcastMessage(self@": DriveFacialTrack:"@TrackIndex);

	Inst = GetMeshInstance();

	if (Inst == None)
		return;

	CurIndex = FacialTrack[TrackIndex].CurIndex;
	Frame1 = FacialTrack[TrackIndex].Frame1;
	Frame2 = FacialTrack[TrackIndex].Frame2;

	if (FacialTrack[TrackIndex].CurFrameDelay >= 0.0f)
	{
		// First, let the delay elapse
		FacialTrack[TrackIndex].CurFrameDelay -= DeltaSeconds;
		FacialTrack[TrackIndex].CurFrameBlend = 0.0f;
	}
	else 
	{
		// Once the delay has elapsed, start blending to the next frame in the sequence
		FacialTrack[TrackIndex].CurFrameBlend += DeltaSeconds/FacialExpressions[CurIndex].FacialFrame[Frame1].BlendTime;
	}
	
	//BroadcastMessage("DriveFacialTrack: "@TrackIndex@","@FacialTrack[TrackIndex].CurFrameDelay);

	if (FacialTrack[TrackIndex].CurFrameBlend >= 1.0f)
	{
		if (!NextFacialExpressionFrame(TrackIndex))		// Done blending, go to the next
			return;
	}

	if (FacialTrack[TrackIndex].CurTrackBlendDir > 0)
	{
		// Track fading in
		if (FacialTrack[TrackIndex].CurTrackBlend < 1.0f)
			FacialTrack[TrackIndex].CurTrackBlend += DeltaSeconds*2.0f;
		
		if (FacialTrack[TrackIndex].CurTrackBlend >= 1.0f)
		{
			FacialTrack[TrackIndex].CurTrackBlendDir = 0;
			FacialTrack[TrackIndex].CurTrackBlend = 1.0f;
		}
	}
	else if (FacialTrack[TrackIndex].CurTrackBlendDir < 0)
	{
		// Track fading out
		if (FacialTrack[TrackIndex].CurTrackBlend > 0.0f)
			FacialTrack[TrackIndex].CurTrackBlend -= DeltaSeconds*2.0f;
		if (FacialTrack[TrackIndex].CurTrackBlend <= 0.0f)
		{
			FacialTrack[TrackIndex].CurTrackBlendDir = 0;
			FacialTrack[TrackIndex].CurTrackBlend = 0.0f;
			// Track faded all the way out, stop it
			StopTrack(TrackIndex);
			return;
		}
	}

	// Blend between the 2 channels
	SetUpFacialBlending(TrackIndex);
}

//================================================================================
//	DriveFacialTracks
//================================================================================
function DriveFacialTracks(float DeltaSeconds)
{
	local int		i;

	for (i=0; i<2; i++)
		DriveFacialTrack(i, DeltaSeconds);
	
	TickFacialNoise(DeltaSeconds);
}

//================================================================================
//	StartTrack
//================================================================================
function StartTrack(int TrackIndex, int Index)
{
	//BroadcastMessage("StartTrack:"@TrackIndex@","@Index);

	FacialTrack[TrackIndex].CurIndex = Index;
	FacialTrack[TrackIndex].Frame1 = -1;
	FacialTrack[TrackIndex].Frame2 = -1;

	FacialTrack[TrackIndex].CurTrackBlend = 0.0f;
	FacialTrack[TrackIndex].CurTrackBlendDir = 1;	// Blend in the track
	
	FacialTrack[TrackIndex].CurFrameBlend = 2.0f;	// Force an update on the first frame to get it started
	FacialTrack[TrackIndex].CurFrameDelay = -1.0f;	// Ditto

	SetupTrackChannels();
}

//================================================================================
//	SetFacialExpressionIndex
//	-1 turns off facial expression animations
//================================================================================
function SetFacialExpressionIndex(int Index)
{
	//BroadcastMessage("SetFacialExpressionIndex:"@Index);
	
	SetupTrackChannels();
	
	if (FacialTrack[1].CurIndex != -1)
		BlendOutTrack(1);		// If something is playing on track 1, blend it out (it will switch to track 0)

	if (Index != -1)
		StartTrack(1, Index);	// Fire up this facial sequence on track 1

	CurSoundLevel = 0.0f;
	CurLipBlendPercent = 0.0f;
}

//=============================================================================
//	SetBoneScaling
//=============================================================================
function SetBoneScaling(MeshInstance Inst, name BoneName, float Scale)
{
    local vector	s;
	local int		Bone;

	Bone = Inst.BoneFindNamed(BoneName);
			
	if (Bone==0)
		return;

	s.x = Scale; s.y = Scale; s.z = Scale;
	Inst.BoneSetScale(Bone, s, true);
}

//=============================================================================
//	TickFacialNoise
//=============================================================================
function TickFacialNoise(float DeltaSeconds)
{
	local int		i, Val;
	local float		Rate, Limit, Percent;
	local float		p1, p2, p3;

	if (!Level.bPawnFacialNoise)
		return;

	if (!bFacialNoise)
		return;

	for (i=0; i<ArrayCount(FacialNoise); i++)
	{
		if (FacialNoise[i].BoneName == '')
			break;

		Rate = FacialNoise[i].Rate;
		Limit = FacialNoise[i].Limit;
		p1 = FacialNoise[i].PercentStop;
		p2 = FacialNoise[i].PercentStart;
		p3 = FacialNoise[i].PercentSameDir;

		if (FacialNoise[i].Dir == 1)
			FacialNoise[i].Noise += DeltaSeconds*Rate;
		else if (FacialNoise[i].Dir == -1)
			FacialNoise[i].Noise -= DeltaSeconds*Rate;

		if (FacialNoise[i].Noise > Limit)
			FacialNoise[i].Dir = -1;
		else if (FacialNoise[i].Noise < -Limit)
			FacialNoise[i].Dir = 1;
		else
		{
			Val = Rand(1000);

			Percent = float(Val)/1000.0f;

			if (FacialNoise[i].Dir == -1 || FacialNoise[i].Dir == 1)
			{
				if (Percent < p1)		// % chance to stop
				{
					// Remember dir
					if (FacialNoise[i].Dir == -1)
						FacialNoise[i].Dir = -2;
					else if (FacialNoise[i].Dir == 1)
						FacialNoise[i].Dir = 2;
				}
			}
			else if (Percent < p2)
			{
				Percent = Percent / p2;

				if ((FacialNoise[i].Dir == -2 || FacialNoise[i].Dir == 2) && Percent < p3)
				{
					// 80% chance to go in last dir it was going before
					if (FacialNoise[i].Dir == -2)
						FacialNoise[i].Dir = -1;
					else if (FacialNoise[i].Dir == 2)
						FacialNoise[i].Dir = 1;
				}
				else
				{
					if (Percent > 0.5f)
						FacialNoise[i].Dir = 1;
					else
						FacialNoise[i].Dir = -1;
				}
			}
		}
	}
}

//=============================================================================
//	EvalFacialNoise
//=============================================================================
function EvalFacialNoise()
{
    local MeshInstance	Inst;
    local vector		t1;
	local rotator		r;
	local int			i, Bone;
	local float			Val;

	if (!Level.bPawnFacialNoise)
		return;

	if (!bFacialNoise)
		return;

	Inst = GetMeshInstance();

    if (Inst==None)
        return;

	for (i=0; i<ArrayCount(FacialNoise); i++)
	{
		if (FacialNoise[i].BoneName == '')
			break;
		
		Bone = Inst.BoneFindNamed(FacialNoise[i].BoneName);

		if (Bone == 0)
			continue;
			
		if (FacialNoise[i].Type >= FNOISE_TranslateX && FacialNoise[i].Type <= FNOISE_TranslateZ)
		{
			t1 = Inst.BoneGetTranslate(Bone, false, false);

			if (FacialNoise[i].Type == FNOISE_TranslateX)
				t1.x += FacialNoise[i].Noise;
			else if (FacialNoise[i].Type == FNOISE_TranslateY)
				t1.y += FacialNoise[i].Noise;
			else if (FacialNoise[i].Type == FNOISE_TranslateZ)
				t1.z += FacialNoise[i].Noise;

			Inst.BoneSetTranslate(Bone, t1, false);
		}
		else if (FacialNoise[i].Type >= FNOISE_RotatePitch && FacialNoise[i].Type <= FNOISE_RotateRoll)
		{
			r = Inst.BoneGetRotate(Bone, false, false);

			Val = FacialNoise[i].Noise/360.0f*65535;
			//Val = FacialNoise[i].Noise*3000.0f;

			if (FacialNoise[i].Type == FNOISE_RotatePitch)
				r.Pitch += Val;
			else if (FacialNoise[i].Type == FNOISE_RotateYaw)
				r.Yaw += Val;
			else if (FacialNoise[i].Type == FNOISE_RotateRoll)
				r.Roll += Val;

			Inst.BoneSetRotate(Bone, r, false);
		}
	}
}

//=============================================================================
//	EvalLipSync2
//=============================================================================
simulated function bool EvalLipSync2()
{
    local MeshInstance	Inst;
	local rotator		r, r1, r2;
    local vector		s, t, t1, t2;
	local float			f;
	local int			Bone, LastFrame;
	local float			CurJawScale, s1, s2;

	Inst = GetMeshInstance();

    if (Inst==None)
        return false;

	// Set jawbone scaling based on current facial expression
	if (FacialTrack[0].CurIndex == -1 && FacialTrack[1].CurIndex == -1)
	{
		// No tracks playing, just set jawscale to 1
		CurJawScale = 1.0f;
	}
	else
	{
		// Do special blending if either (or both) tracks playing
		if (FacialTrack[0].CurIndex != -1)
			CurJawScale = 1.0f + (FacialTrack[0].CurJawScale-1.0f)*FacialTrack[0].CurTrackBlend;
		else
			CurJawScale = 1.0f;

		if (FacialTrack[1].CurIndex != -1)
			CurJawScale = CurJawScale + (FacialTrack[1].CurJawScale - CurJawScale)*FacialTrack[1].CurTrackBlend;
	}

	// Smooth blend CurSoundLevel towards the real MonitorSoundLevel (we don't want to just set it to it, because it won't be smooth)
	CurSoundLevel += (MonitorSoundLevel - CurSoundLevel)*LipRampSpeed*Level.TimeDeltaSeconds;
	//CurSoundLevel = MonitorSoundLevel;

	if (CurSoundLevel < 0.01f)
	{
		// Blend out of talking
		if (CurLipBlendPercent > 0.0f)
			CurLipBlendPercent -= Level.TimeDeltaSeconds/TargetLipBlendRate;

		if (CurLipBlendPercent <= 0.0f)
		{
			// Set scaling now, since we are bailing out
			CurLipBlendPercent = 0.0f;
			SetBoneScaling(Inst, 'MouthCorner', (1.0 - 2.0 * CurSoundLevel * LipScale * SoundSyncScale_MouthCorner) * CurJawScale);
			return false;
		}
	}
	else
	{
		// Blend into talking
		if (CurLipBlendPercent < TargetLipBlendPercent)
			CurLipBlendPercent += Level.TimeDeltaSeconds/TargetLipBlendRate;

		if (CurLipBlendPercent > TargetLipBlendPercent)
			CurLipBlendPercent = TargetLipBlendPercent;
	}

	//BroadcastMessage("CurSoundLevel: "@MonitorSoundLevel@","@CurSoundLevel);

	// Rotate the jaw downward
	Bone = Inst.BoneFindNamed('Jaw');
	
	if (Bone!=0)
	{
		r1 = Inst.BoneGetRotate(Bone, false, false);
		r2 = Inst.BoneGetRotate(Bone, false, true);

		r2.Pitch += CurSoundLevel * -2048.0 * LipScale * SoundSyncScale_Jaw;
		
		r = r1 + (r2-r1)*CurLipBlendPercent;
		
		Inst.BoneSetRotate(Bone, r, false);
	}

	// Scale in the mouth corner a bit
	SetBoneScaling(Inst, 'MouthCorner', (1.0 - 2.0 * CurSoundLevel * LipScale * SoundSyncScale_MouthCorner) * CurJawScale);

	// Move the upper lip up a little
    Bone = Inst.BoneFindNamed('Lip_U');
    if (Bone!=0)
	{
	    t1 = Inst.BoneGetTranslate(Bone, false, false);
	    t2 = Inst.BoneGetTranslate(Bone, false, true);
		t2.x += 0.25 * LipScale * CurSoundLevel * SoundSyncScale_Lip_U;
		t = t1+(t2-t1)*CurLipBlendPercent;
		Inst.BoneSetTranslate(Bone, t, false);
	}

	// Same with the lower lip
    Bone = Inst.BoneFindNamed('Lip_L');
    if (Bone!=0)
	{
	    t1 = Inst.BoneGetTranslate(Bone, false, false);
	    t2 = Inst.BoneGetTranslate(Bone, false, true);
		t2.x += -0.5*LipScale * CurSoundLevel * SoundSyncScale_Lip_L;
		t = t1+(t2-t1)*CurLipBlendPercent;
		Inst.BoneSetTranslate(Bone, t, false);
	}

	return(true);
}
// ...JEP

/*-----------------------------------------------------------------------------
	Animation State Management
	NOTE: Only change states through these functions.
-----------------------------------------------------------------------------*/

function SetPostureState( EPostureState NewState, optional bool DontNotify )
{
	//BroadcastMessage("SetPostureState:"@NewState@","@DontNotify);

	if (!DontNotify)
		NotifyPostureStateChange(NewState, PostureState);
	PostureState = NewState;
}

simulated function EPostureState GetPostureState()
{
	return PostureState;
}

function NotifyPostureStateChange(EPostureState NewState, EPostureState OldState)
{
	switch (NewState)
	{
		case PS_Standing:
			PostureStateChange_Standing(OldState);
			break;
		case PS_Crouching:
			PostureStateChange_Crouching(OldState);
			break;
		case PS_Jumping:
			PostureStateChange_Jumping(OldState);
			break;
		case PS_Swimming:
			PostureStateChange_Swimming(OldState);
			break;
		case PS_Ladder:
			PostureStateChange_Ladder(OldState);
			break;
		case PS_Rope:
			PostureStateChange_Rope(OldState);
			break;
		case PS_Turret:
			PostureStateChange_Turret(OldState);
			break;
		case PS_Jetpack:
			PostureStateChange_Jetpack(OldState);
			break;
		case PS_Flying:
			PostureStateChange_Flying(OldState);
			break;
	}
}

function PostureStateChange_Standing(EPostureState OldState) {}
function PostureStateChange_Crouching(EPostureState OldState) {}
function PostureStateChange_Jumping(EPostureState OldState) {}
function PostureStateChange_Swimming(EPostureState OldState) {}
function PostureStateChange_Ladder(EPostureState OldState) {}
function PostureStateChange_Rope(EPostureState OldState) {}
function PostureStateChange_Turret(EPostureState OldState) {}
function PostureStateChange_Jetpack(EPostureState OldState) {}
function PostureStateChange_Flying(EPostureState OldState) {}

function SetMovementState( EMovementState NewState, optional bool DontNotify )
{
	if (!DontNotify)
		NotifyMovementStateChange(NewState, MovementState);
    MovementState = NewState;
}

simulated function EMovementState GetMovementState()
{
	return MovementState;
}

function NotifyMovementStateChange(EMovementState NewState, EMovementState OldState)
{
	switch (NewState)
	{
		case MS_Waiting:
			MovementStateChange_Waiting(OldState);
			break;
		case MS_Walking:
			MovementStateChange_Walking(OldState);
			break;
		case MS_Running:
			MovementStateChange_Running(OldState);
			break;
		case MS_RopeIdle:
			MovementStateChange_RopeIdle(OldState);
			break;
		case MS_RopeClimbUp:
			MovementStateChange_RopeClimbUp(OldState);
			break;
		case MS_RopeClimbDown:
			MovementStateChange_RopeClimbDown(OldState);
			break;
		case MS_LadderIdle:
			MovementStateChange_LadderIdle(OldState);
			break;
		case MS_LadderClimbUp:
			MovementStateChange_LadderClimbUp(OldState);
			break;
		case MS_LadderClimbDown:
			MovementStateChange_LadderClimbDown(OldState);
			break;
		case MS_Jetpack:
			MovementStateChange_Jetpack(OldState);
			break;
		case MS_Flying:
			MovementStateChange_Flying(OldState);
			break;
	}
}

function MovementStateChange_Waiting(EMovementState OldState) {}
function MovementStateChange_Walking(EMovementState OldState) {}
function MovementStateChange_Running(EMovementState OldState) {}
function MovementStateChange_RopeIdle(EMovementState OldState) {}
function MovementStateChange_RopeClimbUp(EMovementState OldState) {}
function MovementStateChange_RopeClimbDown(EMovementState OldState) {}
function MovementStateChange_LadderIdle(EMovementState OldState) {}
function MovementStateChange_LadderClimbUp(EMovementState OldState) {}
function MovementStateChange_LadderClimbDown(EMovementState OldState) {}
function MovementStateChange_Jetpack(EMovementState OldState) {}
function MovementStateChange_Flying(EMovementState OldState) {}

function SetUpperBodyState( EUpperBodyState NewState, optional bool DontNotify )
{
	if (!DontNotify)
		NotifyUpperBodyStateChange(NewState, UpperBodyState);
	UpperBodyState = NewState;
}

simulated function EUpperBodyState GetUpperBodyState()
{
	return UpperBodyState;
}

function NotifyUpperBodyStateChange(EUpperBodyState NewState, EUpperBodyState OldState)
{
	switch (NewState)
	{
		case UB_Relaxed:
			UpperBodyStateChange_Relaxed(OldState);
			break;
		case UB_Alert:
			UpperBodyStateChange_Alert(OldState);
			break;
		case UB_WeaponDown:
			UpperBodyStateChange_WeaponDown(OldState);
			break;
		case UB_WeaponUp:
			UpperBodyStateChange_WeaponUp(OldState);
			break;
		case UB_Firing:
			UpperBodyStateChange_Firing(OldState);
			break;
		case UB_Reloading:
			UpperBodyStateChange_Reloading(OldState);
			break;
		case UB_ReloadFinished:
			UpperBodyStateChange_ReloadFinished(OldState);
			break;
        case UB_ShieldUp:
			UpperBodyStateChange_ShieldUp(OldState);
			break;
        case UB_ShieldDown:
			UpperBodyStateChange_ShieldDown(OldState);
			break;
        case UB_ShieldAlert:
			UpperBodyStateChange_ShieldAlert(OldState);
			break;
        case UB_HoldOneHanded:
			UpperBodyStateChange_HoldOneHanded(OldState);
			break;
        case UB_HoldTwoHanded:
			UpperBodyStateChange_HoldTwoHanded(OldState);
			break;
		case UB_Turret:
			UpperBodyStateChange_Turret(OldState);
			break;
	}
}

function UpperBodyStateChange_Relaxed(EUpperBodyState OldState) {}
function UpperBodyStateChange_Alert(EUpperBodyState OldState) 
{
	AlertTimer = 5.0;
}
function UpperBodyStateChange_WeaponDown(EUpperBodyState OldState) {}
function UpperBodyStateChange_WeaponUp(EUpperBodyState OldState) {}
function UpperBodyStateChange_Firing(EUpperBodyState OldState) {}
function UpperBodyStateChange_Reloading(EUpperBodyState OldState) {}
function UpperBodyStateChange_ReloadFinished(EUpperBodyState OldState) {}
function UpperBodyStateChange_ShieldUp(EUpperBodyState OldState) {}
function UpperBodyStateChange_ShieldDown(EUpperBodyState OldState) {}
function UpperBodyStateChange_ShieldAlert(EUpperBodyState OldState) {}
function UpperBodyStateChange_HoldOneHanded(EUpperBodyState OldState) {}
function UpperBodyStateChange_HoldTwoHanded(EUpperBodyState OldState) {}
function UpperBodyStateChange_Turret(EUpperBodyState OldState) { PlayTopAnim('none'); }



/*-----------------------------------------------------------------------------
	Damage Over Time
-----------------------------------------------------------------------------*/

function AddDOT( EDamageOverTime Type, float Duration, float Time, float Damage, Pawn DOTInstigator, optional Actor TouchingActor )
{
	local int iType;
	local DOTAffector CurrentDOT, LastDOT, NewDOT;

	if ( Health <= 0 )
		return;
	if ( PlayerReplicationInfo == None )
		return;
	if ( PlayerReplicationInfo.bIsSpectator || PlayerReplicationInfo.bWaitingPlayer )
		return;
	if ( !bTakesDOT )
		return;

	RemoveDOT( Type );

	iType = int(Type);

	// Set up a new DOT object.
	NewDOT = spawn( class'DOTAffector', Self );
	NewDOT.Type = iType;
	NewDOT.Time = Time;
	NewDOT.Duration = Duration;
	NewDOT.Damage = Damage;
	NewDOT.AffectedPawn = Self;
	NewDOT.DOTInstigator = DOTInstigator;
	NewDOT.Counter = 0;
	if ( TouchingActor != None )
	{
		NewDOT.bNoTimeoutWhileTouching = true;
		NewDOT.TouchingActor = TouchingActor;
	}
	NewDOT.StartTimer();

	// Find the last DOT in the linked list.
	for ( CurrentDOT = DOTAffectorList; CurrentDOT != None; CurrentDOT = CurrentDOT.NextAffector )
	{
		LastDOT = CurrentDOT;
	}
	if ( LastDOT == None )
		DOTAffectorList = NewDOT;
	else
	{
		if ( LastDOT.NextAffector != None )
			BroadcastMessage("Error: Added DOT when LastDOT NextAffect was not none!");
		LastDOT.NextAffector = NewDOT;
	}
}

function RemoveDOT( EDamageOverTime Type )
{
	local DOTAffector PrevDOT, CurrentDOT;

	for ( CurrentDOT = DOTAffectorList; CurrentDOT != None; CurrentDOT = CurrentDOT.NextAffector )
	{
		if ( CurrentDOT.Type == int(Type) )
		{
			if ( PrevDOT == None )
				DOTAffectorList = CurrentDOT.NextAffector;
			else
				PrevDOT.NextAffector = CurrentDOT.NextAffector;
			CurrentDOT.Destroy();
		}
		PrevDOT = CurrentDOT;
	}
}

function WipeDOTList()
{
	local DOTAffector CurrentDOT;

	for ( CurrentDOT = DOTAffectorList; CurrentDOT != None; CurrentDOT = CurrentDOT.NextAffector )
	{
		CurrentDOT.Destroy();
	}
	DOTAffectorList = None;
}

function bool CanBeGassed()
{
	return true;
}


/*-----------------------------------------------------------------------------
	Timers
-----------------------------------------------------------------------------*/

simulated function TickShrinking( float DeltaTime )
{
	DriveFacialTracks(DeltaTime);				// JEP

	// Update the shrinkcounter.
	if ( ShrinkCounter != ShrinkCounterDestination )
	{
		// If we aren't shrunk, snap to not being shrunk.
		// This way if a relevant shrunken guy respawns to a relevant location,
		// he won't expand back up in our view.
//		if ( bNotShrunkAtAll )
//			ShrinkCounter = ShrinkCounterDestination;

		// Otherwise, move towards our destination.
		if ( ShrinkCounter < ShrinkCounterDestination )
		{
			ShrinkCounter += ShrinkRate * DeltaTime;
			if ( ShrinkCounter > ShrinkCounterDestination )
			{
				ShrinkCounter = ShrinkCounterDestination;
				CheckShrink();
			}
			else
			{
				BaseEyeHeight = default.BaseEyeHeight * (1.0 - (ShrinkCounter/ShrinkTime));
			}
		}
		else if ( ShrinkCounter > ShrinkCounterDestination )
		{
			ShrinkCounter -= ShrinkRate * DeltaTime;
			if ( ShrinkCounter < ShrinkCounterDestination )
				ShrinkCounter = ShrinkCounterDestination;
		}
	}

	// Update weapon size.
	if ( Weapon != None )
		Weapon.ThirdPersonScale = FMax( 1.0 - (ShrinkCounter/ShrinkTime), 0.25 );
}

function Timer( optional int TimerNum )
{
}

event UpdateTimers( float DeltaSeconds ) 
{
	// Take damage from water pain time sources.
    if ( (RemainingAir > 0.0) && HeadRegion.Zone.bWaterZone )
	{
		RemainingAir -= DeltaSeconds;
		if ( RemainingAir <= 0.0 )
		{
			RemainingAir = 0.0;
			Drowning();
		}
	}
}

// Player is drowning.
function Drowning()
{
	local float Depth;

	if ( (Health < 0) || (Level.NetMode == NM_Client) )
	{
		EndCallbackTimer( 'Drowning' );
		return;
	}
		
	if ( HeadRegion.Zone.bWaterZone )
	{
		TakeDamage( 10, None, Location + CollisionHeight * vect(0,0,0.5), vect(0,0,0), class'DrowningDamage' );
		if ( Health > 0 )
			SetCallbackTimer( 2.0, true, 'Drowning' );
		else
			EndCallbackTimer( 'Drowning' );
	} else
		EndCallbackTimer( 'Drowning' );
}		




/*-----------------------------------------------------------------------------
	Messaging
-----------------------------------------------------------------------------*/

event ClientMessage(coerce string S, optional name Type, optional bool bBeep);

event TeamMessage(PlayerReplicationInfo PRI, coerce string S, name Type, optional bool bBeep);

event ReceiveLocalizedMessage
	(
	class<LocalMessage> Message,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject,
	optional class<Actor> OptionalClass
	);

function SendVoiceMessage(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageID, name broadcasttype)
{
	local Pawn P;
	local bool bNoSpeak;

	if ( Level.TimeSeconds - OldMessageTime < 2.5 )
		bNoSpeak = true;
	else
		OldMessageTime = Level.TimeSeconds;

	for ( P=Level.PawnList; P!=None; P=P.NextPawn )
	{
		if ( P.IsA('PlayerPawn') )
		{  
			if ( !bNoSpeak )
			{
				if ( ( broadcasttype == 'INDIV' ) && 
					 ( Sender == P.PlayerReplicationInfo ) || ( Recipient == P.PlayerReplicationInfo ) )
				{		
					PlayerPawn(P).ClientVoiceMessage(Sender, Recipient, messagetype, messageID);
				}
				else if ( broadcasttype == 'GLOBAL' ) 
				{					
					if ( !Level.Game.bTeamGame )
						PlayerPawn(P).ClientVoiceMessage(Sender, Recipient, messagetype, messageID);
					else if ( Sender.Team == P.PlayerReplicationInfo.Team )					
						PlayerPawn(P).ClientVoiceMessage(Sender, Recipient, messagetype, messageID);
				}
			}
		}
		else if ( P.IsA('BotPawn') )
		{
			if ( (P.PlayerReplicationInfo == Recipient) || ((messagetype == 'ORDER') && (Recipient == None)) )
				BotPawn(P).BotVoiceMessage(messagetype, messageID, self);
		}
	}
}

function SendGlobalMessage(PlayerReplicationInfo Recipient, name MessageType, byte MessageID, float Wait)
{
	SendVoiceMessage(PlayerReplicationInfo, Recipient, MessageType, MessageID, 'GLOBAL');
}

function SendTeamMessage(PlayerReplicationInfo Recipient, name MessageType, byte MessageID, float Wait)
{
	SendVoiceMessage(PlayerReplicationInfo, Recipient, MessageType, MessageID, 'TEAM');
}




/*-----------------------------------------------------------------------------
	Mountables (Customization)
-----------------------------------------------------------------------------*/

function bool AddMountable( Decoration NewMountable, optional bool MatchLoc, optional bool MatchRot )
{
	local int i;

	for ( i=0; i<6; i++ )
	{
		if ( MountedDecorations[i] == None )
		{
			MountedDecorations[i] = NewMountable;
			NewMountable.AttachActorToParent( self, MatchLoc, MatchRot );
			return true;
		}
	}
	return false;
}

function RemoveMountable( Decoration OldMountable )
{
	local int i;

	for (i=0; i<6; i++)
	{
		if (MountedDecorations[i] == OldMountable)
			MountedDecorations[i] = None;
	}
}

function bool HasMountedDecorations()
{
	local int i;

	for (i=0; i<6; i++)
	{
		if (MountedDecorations[i] != None)
			return true;
	}
	return false;
}




/*-----------------------------------------------------------------------------
	Trace
-----------------------------------------------------------------------------*/

function rotator AdjustAim(float projSpeed, vector projStart, int aimerror, bool bLeadTarget, bool bWarnTarget)
{
	return ViewRotation;
}

simulated function bool AdjustHitLocation(out vector HitLocation, vector TraceDir)
{
	return true;
}

simulated final function actor TraceVector( vector direction )
{
	local vector StartTrace, EndTrace, HitLocation, HitNormal;
	local vector DrawOffset;

	DrawOffset = BaseEyeHeight * vect(0,0,1);

	StartTrace = Location;
	EndTrace   = StartTrace + direction;

	return Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);
}

simulated final function actor TraceFromCrosshair( float MaxDistance )
{
	local vector X,Y,Z, StartTrace, EndTrace, HitLocation, HitNormal;
	local vector DrawOffset;

	DrawOffset = BaseEyeHeight * vect(0,0,1);

	StartTrace = Location + DrawOffset;
	EndTrace   = StartTrace + (vector(ViewRotation)*MaxDistance);

	return Trace( HitLocation, HitNormal, EndTrace, StartTrace, true );
}

simulated final function actor TraceFromCrosshairMesh( 
	float MaxDistance, optional out vector HitLocation, optional out vector HitNormal,
	optional out int HitMeshTri, optional out vector HitMeshBarys,
	optional out name HitMeshBone, optional out texture HitMeshTexture, optional out vector HitUV )
{
	local vector X,Y,Z, StartTrace, EndTrace;
	local vector DrawOffset;

	DrawOffset = BaseEyeHeight * vect(0,0,1);

	StartTrace = Location + DrawOffset;
	EndTrace   = StartTrace + (vector(ViewRotation)*MaxDistance);

	return Trace( HitLocation, HitNormal, EndTrace, StartTrace, true, , true, HitMeshTri, HitMeshBarys, HitMeshBone, HitMeshTexture, HitUV );
}

simulated final function class<Material> TraceMaterialFromCrosshair( float MaxDistance )
{
	local vector X,Y,Z, StartTrace, EndTrace, HitLocation, HitNormal;
	local vector DrawOffset;
	local int SurfaceIndex;

	DrawOffset = BaseEyeHeight * vect(0,0,1);

	StartTrace = Location + DrawOffset;
	EndTrace   = StartTrace + (vector(ViewRotation)*MaxDistance);

	return TraceMaterial( EndTrace, StartTrace, SurfaceIndex );
}


/*-----------------------------------------------------------------------------
	Camera
-----------------------------------------------------------------------------*/

event UpdateEyeHeight(float DeltaTime);

function ClientSetBaseEyeHeight( float NewEyeHeight )
{
	BaseEyeHeight = NewEyeHeight;
}

function BecomeViewTarget()
{
	bViewTarget = true;
}

function SetDisplayProperties(ERenderStyle NewStyle, texture NewTexture, bool bLighting, bool bEnviroMap )
{
	Style = NewStyle;
	texture = NewTexture;
	bUnlit = bLighting;
	bMeshEnviromap = bEnviromap;
	if ( Weapon != None )
		Weapon.SetDisplayProperties(Style, Texture, bUnlit, bMeshEnviromap);

	if ( !bUpdatingDisplay && (Inventory != None) )
	{
		bUpdatingDisplay = true;
		Inventory.SetOwnerDisplay();
	}
	bUpdatingDisplay = false;
}

function SetDefaultDisplayProperties()
{
	Style = Default.Style;
	texture = Default.Texture;
	bUnlit = Default.bUnlit;
	bMeshEnviromap = Default.bMeshEnviromap;
	if ( Weapon != None )
		Weapon.SetDisplayProperties(Weapon.Default.Style, Weapon.Default.Texture, Weapon.Default.bUnlit, Weapon.Default.bMeshEnviromap);

	if ( !bUpdatingDisplay && (Inventory != None) )
	{
		bUpdatingDisplay = true;
		Inventory.SetOwnerDisplay();
	}
	bUpdatingDisplay = false;
}

function ShakeView( float shaketime, float RollMag, float vertmag);




/*-----------------------------------------------------------------------------
	Render
-----------------------------------------------------------------------------*/

simulated event RenderOverlays( canvas C );

function HidePlayer()
{
	SetCollision(false, false, false);
	TweenToFighter(0.01);
	bHidden = true;
}


/*-----------------------------------------------------------------------------
	Game Control / Networking
-----------------------------------------------------------------------------*/

function RestartPlayer();


function ClientRestart()
{
	Velocity		= vect(0,0,0);
	Acceleration	= vect(0,0,0);
	BaseEyeHeight	= Default.BaseEyeHeight;		
	EyeHeight		= BaseEyeHeight;
	
	PlayWaiting();

	// JEP: NOTEZ: This code is now commented out.  I added it before, because when you loaded a saved game,
	//	it would call this function, and cause bad things.  But instead, I changed it so that this code is only
	//	called during PostBeginPlay for the Pawn.
	/*
	// JEP ...
	if (GetPostureState() == PS_Crouching)
	{
		BaseEyeHeight	= 0;
		EyeHeight		= BaseEyeHeight;
	}
	// ... JEP
	*/

	if ( Region.Zone.bWaterZone && (PlayerRestartState == CS_Normal) )
	{
		if ( HeadRegion.Zone.bWaterZone )
		{
			HeadEnteredWater();
		}

		setPhysics( PHYS_Swimming );
		SetControlState( CS_Swimming );
	}
	else
	{
		SetControlState( PlayerRestartState );
	}

	DestroyDecals();

	// JEP: NOTEZ: This code is now commented out.  I added it before, because when you loaded a saved game,
	//	it would call this function, and cause bad things.  But instead, I changed it so that this code is only
	//	called during PostBeginPlay for the Pawn.
	/*
	if (bOnRope)
	{
		
		//if (PlayerPawn(self) != None)
		//	PlayerPawn(self).OffRope();
		//else
		//	bOnRope = false;
		
		SetControlState(CS_Rope);    
		SetPostureState( PS_Rope );
		SetMovementState( MS_RopeIdle );
		SetPhysics( PHYS_Rope );
	}
	*/
}

function ClientGameEnded()
{
	SetControlState(CS_Stasis);
}

event PlayerTimeOut()
{
	if ( Health > 0 )
		Died( None, class'CrushingDamage', Location );
}




/*-----------------------------------------------------------------------------
	Movement
-----------------------------------------------------------------------------*/

native(500) final latent function MoveTo( vector NewDestination, optional float speed); // Sets Destination

native(502) final latent function MoveToward(actor NewTarget, optional float speed);	// Sets Destination and MoveTarget

native(504) final latent function StrafeTo(vector NewDestination, vector NewFocus, optional float speed);

native(506) final latent function StrafeFacing(vector NewDestination, actor NewTarget, optional float speed);

native(508) final latent function TurnTo(vector NewFocus);

native(510) final latent function TurnToward(actor NewTarget);

native(523) final function vector EAdjustJump();

event bool EncroachingOn(actor Other)
{
	if ( (Other.Brush != None) || (Brush(Other) != None) )
		return true;
		
	if ( (!bIsPlayer || bWarping) && (Pawn(Other) != None))
		return true;
		
	return false;
}
event EncroachedBy(actor Other)
{
	if ( Pawn(Other) != None )
		GibbedBy(Other);		
}

event MayFall();

event LongFall();

event FellOutOfWorld()
{
	Health = -1;
	SetPhysics(PHYS_None);
	Weapon = None;
	Died( None, class'FallingDamage', Location );
}

event Landed(vector HitNormal)
{
	if (GetControlState() == CS_Dead)
	{
		SetPhysics(PHYS_None);
		return;
	}

	SetMovementPhysics();
	if ( !IsAnimating() )
		PlayLanded(Velocity.Z);
	if (Velocity.Z < -1.4 * JumpZ)
		MakeNoise(-0.5 * Velocity.Z/(FMax(JumpZ, 150.0)));
	bJustLanded = true;
}

singular event BaseChange()
{
	local float decorMass;

	if ( (base == None) && (Physics == PHYS_None) )
	{
		// We aren't standing on anything! Fall!
		SetPhysics(PHYS_Falling);
	}
	else if ( (Pawn(Base) != None) && !Pawn(Base).IsA('BuddBot') )
	{
		// If we fall onto a snatcher, crush it.
		if ( Base.IsA('Snatcher') && !Self.IsA('Snatcher') && Base.AnimSequence == 'FlipBack' )
			Base.TakeDamage( 500, Self, vect( 0, 0, 0 ), vect( 0, 0, 0 ), class'KungFuDamage' );
		else if ( Base.IsA('HumanNPC') && !Pawn(Base).bFullyShrunk )
			JumpOffPawn();
		else if ( Base.bIsPawn && Pawn(Base).bFullyShrunk )
			Pawn(Base).Died( Self, class'BootSmashDamage', Base.Location );
		else if ( Base.IsA('AIPawn') )
			JumpOffPawn();
		// old:
		// If we fall onto something else, just move us off.
//			JumpOffPawn();
	}
	else if ( (Decoration(Base) != None) )
	{
		if ( Decoration(Base).IsWaterLogged() )
		{
			// If the decoration is waterlogged, push it out of the way and have us fall into the water.
			Decoration(Base).WaterPush();
			SetBase(none);
		}
		else if ( Decoration(Base.Base) != None )
		{
			// If the decoration is standing on another decoration, destroy the decoration with the smallest mass.
			if ( Decoration(Base.Base).Mass < Decoration(Base).Mass )
				Decoration(Base.Base).TakeDamage( 1000, Self, vect(0,0,0), vect(0,0,0), class'ExplosionDamage' );
			else
				Decoration(Base).TakeDamage( 1000, Self, vect(0,0,0), vect(0,0,0), class'ExplosionDamage' );
			Base.SetBase(None);
		}
	}
}

event FootZoneChange(ZoneInfo newFootZone)
{
	local actor HitActor;
	local vector HitNormal, HitLocation;
	local float splashSize;
	local actor splash;
	
	if ( Level.NetMode == NM_Client )
		return;

	if ( Level.TimeSeconds - SplashTime > 0.25 ) 
	{
		SplashTime = Level.TimeSeconds;
		
		if (Physics == PHYS_Falling) 
			MakeNoise(1.0);
		else
			MakeNoise(0.3);

		if ( FootRegion.Zone.bWaterZone )
		{
			if ( !newFootZone.bWaterZone && (Role==ROLE_Authority) )
			{
				PlaySound(None, SLOT_Interact);
				WaterAmbientTime = 0;

				if (Velocity.Z > 200)
					PlaySound(ExitSplash, SLOT_None, 16, , 2000, 0.9 + FRand()*0.2);

				if ( FootRegion.Zone.ExitActor != None )
					Spawn(FootRegion.Zone.ExitActor,,,Location - CollisionHeight * vect(0,0,1));
			}
		}
		else if ( newFootZone.bWaterZone && (Role==ROLE_Authority) )
		{
			WaterAmbientTime = Rand(2)+1;
			if (Velocity.Z < -300)
			{
				PlaySound( BigSplash, SLOT_None, 16, , 2000, 0.9 + FRand()*0.2 );
			}
			else 
			{
				// LittleSplash
				PlaySound( LittleSplash[Rand(2)], SLOT_None, 2, , 2000, 0.9 + FRand()*0.2 );
			}

			if( newFootZone.EntryActor != None )
			{
				splash = Spawn(newFootZone.EntryActor,,,Location - CollisionHeight * vect(0,0,1));
				if ( splash != None )
					splash.DrawScale = splashSize;
			}
		}
	}
}

simulated event HeadZoneChange( ZoneInfo newHeadZone )
{
	if ( Level.NetMode == NM_Client )
		return;

	if ( IsSpectating() )
		return;

	if ( HeadRegion.Zone.bWaterZone && !newHeadZone.bWaterZone )
		HeadExitedWater();
	else if ( !HeadRegion.Zone.bWaterZone && newHeadZone.bWaterZone )
		HeadEnteredWater();
}

simulated function HeadEnteredWater()
{
	RemainingAir = UnderWaterTime;
}

simulated function HeadExitedWater()
{
	StopSound( SLOT_Interact );
	WaterAmbientTime = 0.5;
	if ( bIsPlayer && (RemainingAir > 0) && (RemainingAir < 8) )
		PlayGaspSound();
	bDrowning = false;
}

// Pawn interface called while PHYS_Walking and PHYS_Swimming to update the pawn with 
// the latest information about the walk surface
event WalkTexture(texture Texture, vector StepLocation, vector StepNormal);
/*
{
	// Keep track of the last material I touched..
	if(Texture!=none)
		LastWalkMaterial=Texture.GetMaterial();
	else
		LastWalkMaterial=none;
}
*/
// NJS: Called by the animation sequence to indicate that a footfall has landed.
simulated function FootStep()
{
	local sound step;
	local int SurfaceIndex;

	if ( FootRegion.Zone.bWaterZone )
	{
		return;
	}
    
    if ( Role == ROLE_SimulatedProxy )
    {
        // If this is a simulated proxy, we need to find out what type of surface they are walking on
        // in order to play a footstep
        LastWalkMaterial = TraceMaterial( Location - vect(0,0,200), Location, SurfaceIndex );
    }

	if ( (LastWalkMaterial != none) && (LastWalkMaterial.default.FootstepSoundsCount > 0) )
		step = LastWalkMaterial.default.FootstepSounds[Rand(LastWalkMaterial.default.FootstepSoundsCount)];

    // FIXME: If we want to change this to a PlayOwnedSound, it would cause a RPC for every footstep (Might be slow?)
	if ( step != none )
	{
		PlaySound( step, SLOT_Interact, 2.2, false, 1000.0, 1.0 );
		if ( FootRegion.Zone.bWetZone )
		{
			if ( bPuddleArea )
				SpawnStepEffect( PuddleSplashStepEffect );
			else
				SpawnStepEffect( SplashStepEffect );
		}
		if ( (ImmolationActor != None) && !ImmolationActor.bDeleteMe )
		{
			if ( bFullyShrunk )
				SpawnStepEffect( FireStepEffectShrunk );
			else
				SpawnStepEffect( FireStepEffect );
		}
	}
}

simulated function SpawnStepEffect( class<SoftParticleSystem> StepEffect )
{
	local vector footlv, footrv, effectv;

	GetMeshInstance();
	if ( MeshInstance == none )
		return;

	footlv = MeshInstance.BoneGetTranslate( MeshInstance.BoneFindNamed( 'Foot_L' ), true, false );
	footlv = MeshInstance.MeshToWorldLocation( footlv );
	footrv = MeshInstance.BoneGetTranslate( MeshInstance.BoneFindNamed( 'Foot_R' ), true, false );
	footrv = MeshInstance.MeshToWorldLocation( footrv );

	if ( footlv.Z < footrv.Z )
		effectv = footlv;
	else
		effectv = footrv;

	spawn( StepEffect, Self, , effectv );
}


function Falling()
{
	PlayInAir();
}

function PreSetMovement()
{
	if (JumpZ > 0)
		bCanJump = true;
	bCanWalk = true;
	bCanSwim = false;
	bCanFly = false;
	MinHitWall = -0.6;
	if (Intelligence > BRAINS_Reptile)
		bCanOpenDoors = true;
	if (Intelligence == BRAINS_Human)
		bCanDoSpecial = true;
}

function SetMovementPhysics();

function FearThisSpot(Actor aSpot, optional Pawn Instigator);

function AddVelocity( vector NewVelocity)
{
	if (Physics == PHYS_Walking)
		SetPhysics(PHYS_Falling);
	if ( (Velocity.Z > 380) && (NewVelocity.Z > 0) )
		NewVelocity.Z *= 0.5;
	Velocity += NewVelocity;
}

function ClientSetLocation( vector NewLocation, rotator NewRotation )
{
	local Pawn P;

	ViewRotation  = NewRotation;
	if ( (ViewRotation.Pitch > RotationRate.Pitch) && (ViewRotation.Pitch < 65536 - RotationRate.Pitch) )
	{
		if (ViewRotation.Pitch < 32768) 
			NewRotation.Pitch = RotationRate.Pitch;
		else
			NewRotation.Pitch = 65536 - RotationRate.Pitch;
	}

	NewRotation.Roll  = 0;
	SetRotation( NewRotation );
	SetLocation( NewLocation );
}

function ClientSetRotation( rotator NewRotation )
{
	local Pawn P;

	ViewRotation  = NewRotation;
	NewRotation.Pitch = 0;
	NewRotation.Roll  = 0;
	SetRotation( NewRotation );
}

function JumpOffPawn()
{
	Velocity += 60 * VRand();
	Velocity.Z = 180;
	SetPhysics(PHYS_Falling);
}

function UnderLift(Mover M);

function bool CheckWaterJump(out vector WallNormal)
{
	local actor HitActor;
	local vector HitLocation, HitNormal, checkpoint, start, checkNorm, Extent;

	checkpoint = vector(ViewRotation);
	checkpoint.Z = 0.0;
	checkNorm = Normal( checkpoint );
	checkPoint = Location + CollisionRadius * checkNorm;
	Extent = CollisionRadius * vect(1,1,0);
	Extent.Z = CollisionHeight;
	HitActor = Trace(HitLocation, HitNormal, checkpoint, Location, true, Extent);
	if ( (HitActor != None) && (Pawn(HitActor) == None) )
	{
		WallNormal = -1 * HitNormal;
		start = Location;
		start.Z += 1.1 * MaxStepHeight;
		checkPoint = start + 2 * CollisionRadius * checkNorm;
		HitActor = Trace(HitLocation, HitNormal, checkpoint, start, true);
		if (HitActor == None)
			return true;
	}

	return false;
}




/*-----------------------------------------------------------------------------
	Pathing
-----------------------------------------------------------------------------*/

native(514) final function bool LineOfSightTo(actor Other); // returns true if any of several points of Other is visible (origin, top, bottom)

native(533) final function bool CanSee(actor Other); // similar to line of sight, take's peripheral vision into account

native(518) final function Actor FindPathTo(vector aPoint, optional bool bSinglePath, optional bool bClearPaths);

native(517) final function Actor FindPathToward(actor anActor, optional bool bSinglePath, optional bool bClearPaths);

native(525) final function NavigationPoint FindRandomDest(optional bool bClearPaths);

native(522) final function ClearPaths();

native(521) final function bool pointReachable(vector aPoint); // returns whether point is reachable using current locomotion method

native(520) final function bool actorReachable(actor anActor);

native(540) final function actor FindBestInventoryPath(out float MinWeight, bool bPredictRespawns);

/* FindBestPathToward() assumes the desired destination is not directly reachable, 
given the creature's intelligence, it tries to set Destination to the location of the 
best waypoint, and returns true if successful
*/
function bool FindBestPathToward(actor desired, bool bClearPaths)
{
	local Actor path;
	local bool success;
	
	if ( specialGoal != None)
		desired = specialGoal;
	path = None;
	path = FindPathToward(desired,,bClearPaths); 
		
	success = (path != None);	
	if (success)
	{
		MoveTarget = path; 
		Destination = path.Location;
	}
	return success;
}



/*-----------------------------------------------------------------------------
	AI
-----------------------------------------------------------------------------*/

native(524) final function int FindStairRotation(float DeltaTime);

native(527) final latent function WaitForLanding();

native(526) final function bool PickWallAdjust(); // check if could jump over obstruction (only if there is a knee height obstruction)
												  // If so, start jump, and return current destination, else try to step around and return
												  // a destination 90 degrees right or left depending on traces out and floor checks

native(531) final function pawn PickTarget(out float bestAim, out float bestDist, vector FireDir, vector projStart); // Pick best pawn target.

native(534) final function actor PickAnyTarget(out float bestAim, out float bestDist, vector FireDir, vector projStart);

native function StopWaiting(); // force end to sleep

native simulated event ClientHearSound(actor Actor, int Id, sound S, vector SoundLocation, vector Parameters);

event HearNoise(float Loudness, Actor NoiseMaker);

event SeePlayer(actor Seen);

event SeeFocalPoint(actor Seen);

event FocalPointNotVisible();

event SeeMonster(actor Seen);

event EnemyNotVisible();

event EnemyIsVisible() // CDH: replaces internal reference to LastSeenTime
{
	LastSeenTime = Level.TimeSeconds;
}

function NotifyInterest( actor AnInterestActor );

function NotifyPickup( actor Other, Pawn EventInstigator );

event SawEnemy() // CDH: replaces internal references to LastSeeingPos and LastSeenPos
{
	LastSeeingPos = Location;
	LastSeenPos = Enemy.Location;
}

event BlockedByMover();

event AlterDestination(); // Called when using movetoward with bAdvancedTactics true to temporarily modify destination

event UpdateTactics(float DeltaTime); // For advanced tactics.

function WarnTarget(Pawn shooter, float projSpeed, vector FireDir)
{
	// AI controlled creatures may duck
	// if not falling, and projectile time is long enough
	// often pick opposite to current direction (relative to shooter axis)
}



/*-----------------------------------------------------------------------------
	Audio
-----------------------------------------------------------------------------*/

function PlayGaspSound();





/*-----------------------------------------------------------------------------
	Damage / Death
-----------------------------------------------------------------------------*/

function int AddEgo( int AddedEgo, optional bool Limit )
{
	local int EgoDiff;

	if (Limit && (Health >= 100))
		return 0;

	if (Health >= 200)
		return 0;

	EgoDiff = AddedEgo;
	if (Limit && (Health+AddedEgo >= 100))
		EgoDiff = AddedEgo - (Health+AddedEgo-100);
	else if (Health+AddedEgo >= 200)
		EgoDiff = AddedEgo - (Health+AddedEgo-200);
	Health += EgoDiff;

	return EgoDiff;
}

function SubtractEgo( int SubtractedEgo )
{
	if(Health <= 1 )
		return;

	Health += SubtractedEgo;
	if( Health <= 0 )
		Health = 1;
}

function TakeDamage( int Damage, Pawn InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType )
{
	local int actualDamage;
	local bool bAlreadyDead;

	// E3 HEAD SPLASH HACK
	if ( InstigatedBy != None )
		DamageLocation = HitLocation - InstigatedBy.Location;
 
    if ( !bTakeDamage ) 
    {
        return; // Actor takes no damage
    }

	if ( GetControlState() == CS_Dead )
	{
		if ( bDeleteMe )
			return;

		Health = Health - Damage;
		Momentum = Momentum/Mass;
        
//		if ( bTakeMomentum )
//			AddVelocity( momentum ); 

		if ( !bHidden && ShouldBeGibbed(DamageType) )
		{
			bHidden = true;
			SpawnGibbedCarcass( DamageType, HitLocation );
			if ( bIsPlayer )
				HidePlayer();
			else
				Destroy();
		}
		return;
	}

	if ( Role < ROLE_Authority )
	{
		log(self$" client damage type "$damageType$" by "$instigatedBy);
		return;
	}

	if ( DamageBone == '' )
	{
		if ( FRand() > 0.5 )
			DamageBone = 'Chest';
		else
			DamageBone = 'Pelvis';
	}

	bAlreadyDead = (Health <= 0);

    if ( bTakeMomentum )
    {
	    // Perform the damage physics...
	    if ( Physics == PHYS_None )
		    SetMovementPhysics();
	    if ( Physics == PHYS_Walking )
		    Momentum.Z = FMax(Momentum.Z, 0.4 * VSize(momentum));
	    if ( InstigatedBy == Self )
		    Momentum *= 0.6;
		Momentum = Momentum/Mass;
		if ( !ClassIsChildOf(DamageType, class'BulletDamage') )
			AddVelocity( Momentum ); 
    }

	// Find the actual amount of damage after the level deals with it...
	ActualDamage = Level.Game.ReduceDamage( Damage, DamageType, Self, InstigatedBy );

	// If we are a player, check for damage reduction.
	if ( bIsPlayer )
	{
		if ( bGodMode )
			ActualDamage = 0;
		else
			ActualDamage = Damage;
	}
	
	// Allow the damage mutator to modify damage.
	if ( Level.Game.DamageMutator != None )
		Level.Game.DamageMutator.MutatorTakeDamage( ActualDamage, Self, InstigatedBy, HitLocation, Momentum, DamageType );

	// If the damage is a fire damage and we aren't on fire, set us on fire!
	if ( CanBurn( DamageType ) )
	{
		ImmolationActor = spawn( class<ActorDamageEffect>(DynamicLoadObject( ImmolationClass, class'Class' )), Self );
		ImmolationActor.Instigator = InstigatedBy;
		ImmolationActor.Initialize();
	}

	// If the damage is cold damage we might freeze.
	if ( CanFreeze( DamageType ) )
	{
		FreezeActor = spawn( class<ActorDamageEffect>(DynamicLoadObject( FreezeClass, class'Class' )), Self );
		FreezeActor.Instigator = InstigatedBy;
		FreezeActor.Initialize();
	}

	// If the damage is shrinker damage we might shrink.
	if ( ClassIsChildOf( DamageType, class'ShrinkerDamage' ) )
	{
		if ( !bRestoringShrink && ((CanShrink( DamageType ) && !bFullyShrunk) || bPartiallyShrunk) )
		{
			if ( (ShrinkActor == None) || ShrinkActor.bDeleteMe )
			{
				ShrinkActor = spawn( class<ActorDamageEffect>(DynamicLoadObject( ShrinkClass, class'Class' )), Self );
				ShrinkActor.Instigator = InstigatedBy;
				ShrinkActor.Initialize();
			}
			if ( (Damage > 80) || bPartiallyShrunk )
				StartFullShrink();
			else
				StartPartialShrink();
		}
		ActualDamage = 0;
	}

	// Reduce our health.
	Health -= ActualDamage;
	if ( HitLocation == vect(0,0,0) )
		HitLocation = Location;
	if ( Health > 0 )
	{
		// Set the player's enemy for call for help.
		if ( (InstigatedBy != None) && (InstigatedBy != Self) )
			DamageAttitudeTo(InstigatedBy);
	}
	else if ( !bAlreadyDead )
	{
		NextState = '';

		if ( ActualDamage > Mass )
			Health = -1 * ActualDamage;

		// Set the player's enemy for call for help.
		if ( (InstigatedBy != None) && (InstigatedBy != Self) )
			DamageAttitudeTo(InstigatedBy);

		// Doh!
		Died( InstigatedBy, DamageType, HitLocation, Momentum );
	}
	else
	{
		if ( bIsPlayer )
		{
			HidePlayer();
			SetControlState(CS_Dead);
		}
		else
			Destroy();
	}

	// Make a noise!!
	MakeNoise(1.0); 

	// JC: DamageBone was being set to none too early for HumanNPCs.
	if( !self.IsA( 'HumanNPC' ) )
		DamageBone = '';
}

// Spawns a client side hit effect.  Everything spawned here should have no remote role.
simulated function HitEffect( vector HitLocation, class<DamageType> DamageType, vector Momentum, bool bNoCreationSounds )
{
//	local Bubble1 bub;
	local class<DamageType> DamageClass;
	local vector BloodOffset, Mo;
	local rotator HitRotation;

	if ( bGodMode || (DamageType == None) )
		return;

	if ( ClassIsChildOf(DamageType, class'DrowningDamage') )
	{
		// Spawn bubbles from our mouth if we die under water.
		/*
		bub = spawn(class 'Bubble1',,, Location 
			+ 0.7 * CollisionRadius * vector(ViewRotation) + 0.3 * EyeHeight * vect(0,0,1));
		if (bub != None)
			bub.DrawScale = FRand()*0.06+0.04; 
		*/
	}
	else if ( DamageType.default.bBloodEffect )
		BloodEffect( HitLocation, DamageType, Momentum, bNoCreationSounds );

//	ShakeView(0.15 + 0.005 * Damage, Damage * 30, 0.3 * Damage); 
}

// Spawns a client side blood splash.  Everything spawned here should have no remote role.
simulated function BloodEffect( vector HitLocation, class<DamageType> DamageType, vector Momentum, bool bNoCreationSounds )
{
	local vector BloodOffset, Mo;
	local sound GibSound;

	// Blood decal on wall.
	BloodOffset   = 0.2 * CollisionRadius * Normal(HitLocation - Location);
	BloodOffset.Z = BloodOffset.Z * 0.5;		
//	Mo = Momentum;
//	if ( Mo.Z > 0 )
//		Mo.Z *= 0.5;
	if ( BloodHitDecal == None )
		BloodHitDecal = class<Actor>( DynamicLoadObject(BloodHitDecalName, class'Class') );
	Spawn( BloodHitDecal, Self,, HitLocation + BloodOffset/*, rotator(Mo)*/ );

	// Blood puff.
	if ( BloodPuff == None )
		BloodPuff = class<Actor>( DynamicLoadObject(BloodPuffName, class'Class') );
	Spawn( BloodPuff,,, HitLocation, rotator(Mo) );

	// Play a gibby impact sound.
	GibSound = GibbySound[Rand(3)];
	if ( !bNoCreationSounds && (GibSound != None) )
		PlayOwnedSound( GibSound, SLOT_Interact, 1.0, false, 800, 0.9+FRand()*0.2 );
}

function TakeFallingDamage()
{
	local float FallingDamage;

	if (Velocity.Z < -1.4 * JumpZ)
	{
		MakeNoise(-0.5 * Velocity.Z/(FMax(JumpZ, 150.0)));
		if (Velocity.Z <= -750 - JumpZ)
		{
			if ( (Velocity.Z < -1650 - JumpZ) && !bGodMode )
			{
				TakeDamage( 1000, None, Location, vect(0,0,0), class'FallingDamage' );
			}
			else if ( Role == ROLE_Authority )
			{
				FallingDamage = -0.15 * (Velocity.Z + 700 + JumpZ);
				FallingDamage *= Level.Game.FallingDamageScale;
				TakeDamage( FallingDamage, None, Location, vect(0,0,0), class'FallingDamage' );
			}
			ShakeView(0.175 - 0.00007 * Velocity.Z, -0.85 * Velocity.Z, -0.002 * Velocity.Z);
		}
	}
	else if ( Velocity.Z > 0.5 * Default.JumpZ )
		MakeNoise(0.35);				
}

function DamageAttitudeTo( Pawn Other );

function AlertNPC( Actor WarningActor, optional name WarningType );

function bool ShouldBeGibbed( class<DamageType> DamageType) { return DamageType.default.bGibDamage; }

function SpawnGibbedCarcass(optional class<DamageType> DamageType, optional vector HitLocation, optional vector Momentum );

function Carcass SpawnCarcass(optional class<DamageType> DamageType, optional vector HitLocation, optional vector Momentum )
{
	log(self$" should never call base SpawnCarcass!");
	return None;
}

function Died( Pawn Killer, class<DamageType> DamageType, vector HitLocation, optional Vector Momentum )
{
	local pawn OtherPawn;
	local actor A;
	local EPawnBodyPart BodyPart;

	if ( bDeleteMe )
		return; // Already destroyed...

	// No DOT.
	WipeDOTList();

	// Set our health to zero...unless we're already negative...
	Health = Min(0, Health);

	// Send a killed notification!
	for ( OtherPawn=Level.PawnList; OtherPawn!=None; OtherPawn=OtherPawn.nextPawn )
		OtherPawn.Killed( Killer, Self, DamageType );

	// Notify the game that a player was killed
	Level.Game.Killed( Killer, Self, DamageType );

	// Drop anything we might be carrying.
	if ( CarriedDecoration != None )
	{
		DropDecoration(,true);
		CarriedDecoration = None; 
	}

	// Trigger any death events.
	if( Event != '' )
		foreach AllActors( class 'Actor', A, Event )
			A.Trigger( Self, Killer );

	// Play the dying animation and effects...
	PlayDying( DamageType, HitLocation );

	// If the game is over, that's it.
	if ( Level.Game.bGameEnded )
	{
		Weapon = None;
		Level.Game.DiscardInventory(Self);
		HidePlayer();
		return;
	}

	// Otherwise, notify the client.
	if ( RemoteRole == ROLE_AutonomousProxy )
	{
		ClientDying( DamageType, HitLocation );
	}

	// Move us to the dead state.
	SetControlState( CS_Dead );

	// Destroy us if we should be gibbed.
	if ( ShouldBeGibbed( DamageType ) )
		SpawnGibbedCarcass( DamageType, HitLocation, Momentum );
	else
		SpawnCarcass( DamageType, HitLocation, Momentum );

	// Remove effects actors.
	RemoveEffects();

	// Remove our weapon reference.
	Weapon = None;

	// Destroy the inventory;
	Level.Game.DiscardInventory(Self);
}


function GibbedBy(actor Other)
{
	local pawn InstigatedBy;
	InstigatedBy = Pawn(Other);
	if ( InstigatedBy == None )
		InstigatedBy = Other.Instigator;
	Health = -1000; //make sure gibs
	Died( InstigatedBy, class'ExplosionDamage', Location );
}

function Killed( pawn Killer, pawn Other, class<DamageType> DamageType )
{
	if ( Pawn( Enemy ) == Other )
		Enemy = None;
}

simulated function ClientDying( class<DamageType> DamageType, vector HitLocation )
{
	PlayDying( DamageType, HitLocation );
	SetControlState( CS_Dead );
}

simulated function DestroyDecals()
{
	local MeshDecal Decal;
	
	// Destroy any decals on me
	for ( Decal = MeshDecalLink; Decal != None; Decal = Decal.MeshDecalLink )
	{
		Decal.Destroy();
	}
}

simulated function ClientDestroyDecals()
{
	DestroyDecals();
}

/*-----------------------------------------------------------------------------
	Weapon
-----------------------------------------------------------------------------*/

// Switches to a specific weapon.
// This function is called on the client or single player by the new Weapon's ChangeToWeapon function.
simulated function ChangeToWeapon( Weapon NewWeapon )
{
	// Can't switch if we are in stasis.
	if ( GetControlState() == CS_Stasis )
		return;

	// Can't switch if weapons are inactive.
	if ( !bWeaponsActive && (NewWeapon != None) && !NewWeapon.bUseAnytime )
		return;

	// We can't switch to the current weapon.
	if ( NewWeapon == Weapon )
		return;

	// We can't change to the weapon if ammotype or owner replication hasn't arrived.
	if ( (NewWeapon != None) && ((NewWeapon.Instigator == None) || (NewWeapon.AmmoType == None)) )
	{
		// Wait for the replication data to arrive.  This usually is the next frame.
		NewWeapon.GotoState('WaitingForReplication');
		return;
	}

	// Keep track of the weapon we are switching to.
	// This is the only place PendingWeapon should ever be set on client.
	PendingWeapon = NewWeapon;

	if ( (Weapon == None) || (Weapon.GetStateName() == 'DownWeapon') || (Weapon.GetStateName() == 'Waiting') )
	{
		// In this case, just switch.
		if ( Level.NetMode == NM_Client )
			FinishWeaponChange();

		// Tell the server.
		if ( Level.NetMode != NM_Client )
			ServerChangeToWeapon( NewWeapon );
	}
	else if ( Level.NetMode == NM_Client )
	{
		// Put down the current weapon.
		Weapon.PutDown();
	}
	else
	{
		// Do a server side or singleplayer change.
		ServerChangeToWeapon( NewWeapon );
	}

	// If we are a client, delay telling server until change is finished.
	// Otherwise, the weapon variable might be repliated before the animation and state change is finished.
}

// Brings up the next weapon after the old weapon goes down.
simulated function FinishWeaponChange()
{
	// Set the new weapon.
	Weapon = PendingWeapon;
	PendingWeapon = None;

	// If we are a client, tell the server about the change.
	if ( Level.NetMode == NM_Client )
		ServerChangeToWeapon( Weapon );

	// Return if we swtiched to none.
	if ( Weapon == None )
		return;

	// Otherwise, bring it up.
	Weapon.BringUp();
}

// Tells the server to change weapons.
function ServerChangeToWeapon( Weapon NewWeapon )
{
	// Drop a deco if we've got one.
	if ( (NewWeapon != None) && (CarriedDecoration != None) )
		DropDecoration(,true);

	// Keep track of the weapon we are switching to.
	// This is the only place PendingWeapon should ever be set on server.
	PendingWeapon = NewWeapon;

	if ( (Weapon == None) || (Weapon.GetStateName() == 'DownWeapon') || (Weapon.GetStateName() == 'Waiting') )
	{
		// In this case, just switch.
		FinishWeaponChange();
	} 
	else if ( Weapon != None )
	{
		// Reset the old weapon's display properties.
		Weapon.SetDefaultDisplayProperties();

		// Put down the old weapon.
		Weapon.PutDown();
	}
}

// Changes the player's weapon to the best weapon.
exec function bool SwitchToBestWeapon()
{
	local float Rating;
	local int UseAlt;

	if ( Inventory == None )
		return false;

	ChangeToWeapon( Inventory.RecommendWeapon( Rating, UseAlt ) );

	return (UseAlt > 0);
}

// Brings up the weapon of type LastWeaponClass if it exists in the inventory.
simulated function BringUpLastWeapon(
		optional bool bFastAnim,
		optional bool bClientSideOnly )
{
	local Weapon SwitchToWeapon;

	if ( OldUsedItem == None )
	{
		Weapon = None;
		SwitchToWeapon = Weapon(FindInventoryType(LastWeaponClass));
		if ( SwitchToWeapon != None )
		{
			if ( bFastAnim && (SwitchToWeapon != None) )
			{
				SwitchToWeapon.bFastActivate = true;
				SwitchToWeapon.bNoAnimSound = true;
				SwitchToWeapon.bDontPlayOwnerAnimation = true;
			}
			SwitchToWeapon.bHideWeapon = false;
			if ( bClientSideOnly )
			{
				Weapon = SwitchToWeapon;
				Weapon.GotoState('Active');
			} else
				ChangeToWeapon( SwitchToWeapon );
		}
	}
	else
	{
		OldUsedItem.Activate();
		OldUsedItem = None;
	}
}


// General interface to server-side weapon down.
simulated function WeaponDown(
		optional bool bDisableWeaps,
		optional bool bNoAnim,
		optional bool bDownAndHide,
		optional bool bClientSideOnly )
{
	if ( Weapon != None )
	{
		// Save the current weapon class so we can return to it later.
		LastWeaponClass = Weapon.Class;

		// If bNoAnim, don't play owner anim.
		if ( bNoAnim )
			Weapon.bDontPlayOwnerAnimation = true;

		// If down and hide, make the weapon invisible.  Otherwise, just down the weapon.
		if ( bDownAndHide )
			Weapon.bHideWeapon = true;
		if ( bClientSideOnly )
		{
			Weapon.bClientDown = true;
			Weapon.GotoState('DownWeapon');
		} else
			ChangeToWeapon( None );

		// If disble weaps...disable 'em.
		if ( bDisableWeaps )
			bWeaponsActive = false;
	}
}

// General interface to server-side weapon up.
simulated function WeaponUp(
		optional bool bEnableWeaps,
		optional bool bFastAnim,
		optional bool bClientSideOnly )
{
	// If enable weaps, turn 'em on!
	if ( bEnableWeaps )
	    bWeaponsActive = true;
	else if ( !bWeaponsActive )
		return;

	// If we aren't carrying a weapon or a quest item, bring up our last weapon.
	if ( (CarriedDecoration == None) && (QuestItem(UsedItem) == None) )
		BringUpLastWeapon( bFastAnim, bClientSideOnly );
}

// Toss out the weapon currently held.
function TossWeapon()
{
	local vector X,Y,Z;
	if ( Weapon == None )
		return;
	GetAxes(ViewRotation,X,Y,Z);
	Weapon.DropFrom(Location + 0.8 * CollisionRadius * X + 0.5 * CollisionRadius * Y); 
}

function ServerSetLoadCount( int NewLoadCount )
{
	if ( Weapon != None )
		Weapon.AmmoLoaded = NewLoadCount;
}

// This function is used to send special weapon action requests to the server.
function ServerWeaponAction( int ActionCode, rotator ClientViewRotation )
{
	if ( Weapon != None )
		Weapon.WeaponAction( ActionCode, ClientViewRotation );
}

function FireWeapon();

function StopFiring();



/*-----------------------------------------------------------------------------
	Inventory
-----------------------------------------------------------------------------*/

function HandlePickup( Inventory Pick )
{
	// Notify nearby creatures we grabbed something.
	MakeNoise( 0.2 );
}

// Returns the inventory item of the requested class if it exists in 
// this pawn's inventory.
function Inventory FindInventoryType( class DesiredClass )
{
	local Inventory Inv;

	for( Inv=Inventory; Inv!=None; Inv=Inv.Inventory )   
		if ( Inv.class == DesiredClass )
			return Inv;
	return None;
} 

// Add Item to this pawn's inventory. 
// Returns true if successfully added, false if not.
function bool AddInventory( inventory NewItem )
{
	// Skip if already in the inventory.
	local inventory Inv;
	
	// The item should not have been destroyed if we get here.
	if (NewItem ==None )
		log("tried to add none inventory to "$self);

	for( Inv=Inventory; Inv!=None; Inv=Inv.Inventory )
		if( Inv == NewItem )
			return false;

	// Add to front of inventory chain.
	NewItem.SetOwner(Self);
	NewItem.Inventory = Inventory;
	Inventory = NewItem;

	return true;
}

// Remove Item from this pawn's inventory, if it exists.
// Returns true if it existed and was deleted, false if it did not exist.
function bool DeleteInventory( inventory Item )
{
	// If this item is in our inventory chain, unlink it.
	local actor Link;

	if ( Item == Weapon )
		Weapon = None;
	if ( Item == SelectedItem )
		SelectedItem = None;
	for( Link = Self; Link!=None; Link=Link.Inventory )
	{
		if( Link.Inventory == Item )
		{
			Link.Inventory = Item.Inventory;
			break;
		}
	}
	Item.SetOwner( None );
}

function rotator AdjustToss(float projSpeed, vector projStart, int aimerror, bool bLeadTarget, bool bWarnTarget)
{
	return ViewRotation;
}

function bool DropDecoration(optional float Force, optional bool bForceDrop, optional bool bNoWeapon)
{
	local PlayerPawn P;
	local float ForceScale, ZForce;
	local rotator AdjustedAim, TossRotation;
	local Actor HitActor;
	local vector X,Y,Z, StartTrace, EndTrace, HitLocation, HitNormal, NewLoc;
	local rotator OldViewRotation;
	local bool SavedRotation;

	P = PlayerPawn( self );
	if ( CarriedDecoration != None )
	{
		if ( (ViewRotation.Pitch < 0) || (ViewRotation.Pitch > 25000) )
		{
			OldViewRotation = ViewRotation;
			ViewRotation = rot( 2048, ViewRotation.Yaw, ViewRotation.Roll );
			SavedRotation = true;
		}

		PositionDecoration( true );

		// Check to see if there is room to drop.
		if ( !bForceDrop )
		{
			if ( TraceVector(CarriedDecoration.Location - Location) != none )
			{
				ClientMessage( "No room to drop it here." );
				if ( SavedRotation )
					ViewRotation = OldViewRotation;
				return false;
			}

			// Correct the decoration's location if it is too close to the ground.
			StartTrace = CarriedDecoration.Location;
			EndTrace = StartTrace;
			EndTrace.Z -= CarriedDecoration.default.CollisionHeight + 2;
			HitActor = Trace( HitLocation, HitNormal, EndTrace, StartTrace, true );
			if ( HitActor != None )
			{
				NewLoc = CarriedDecoration.Location;
				NewLoc.Z += HitLocation.Z - EndTrace.Z;
				CarriedDecoration.SetLocation(NewLoc);
			}
		}

		if ( Force > 0 )
		{
			CarriedDecoration.Tossed();
			CarriedDecoration.Velocity = 10 * VRand();
			ZForce = 200;
		} 
		else if ( Force < 0 )
		{
			CarriedDecoration.Tossed(true);
			Force = 50;
			ZForce = 100;
		}
		CarriedDecoration.Instigator = self;
		CarriedDecoration.DrawScale *= 10;
		if ( CarriedDecoration.ImmolationActor != None )
			CarriedDecoration.ImmolationActor.ScaleDrawScale( 10.0 );
        CarriedDecoration.RemoteRole = ROLE_DumbProxy;
		CarriedDecoration.CarriedBy = None;
		AdjustedAim = AdjustAim(1000000, CarriedDecoration.Location, 0, false, false);	
		CarriedDecoration.Velocity += Normal(vector(AdjustedAim)) * Force * CarriedDecoration.GetForceScale();
		CarriedDecoration.Velocity.Z += ZForce * (1.0 - abs(Normal(vector(AdjustedAim)).Z));
		CarriedDecoration.LodMode = CarriedDecoration.default.LodMode;
        CarriedDecoration.SetOwner( None );
		CarriedDecoration.bShadowReceive = CarriedDecoration.bOldShadowReceive;

		CarriedDecoration = None;
		if ( (P != none) && !bNoWeapon )
			P.WeaponUp( false, true );
		if ( QuestItem(OldUsedItem) != None )
		{
			UsedItem = OldUsedItem;
			OldUsedItem = None;
		}

		PlayerPawn(self).SetPlayerSpeed(1.0);

		if (SavedRotation)
			ViewRotation = OldViewRotation;

		PlaySound( TossSound, SLOT_Interact );
	}
	return true;
}

function GrabDecoration(Actor HitActor)
{
	local vector lookDir, HitLocation, HitNormal, T1, T2, extent;
	local float NewSpeed;
	local Actor D;

	if ( CarriedDecoration == None )
	{
		if ( (HitActor == None) || (HitActor == Level) )
			return;

		if ( HitActor.GrabTrigger )
			HitActor.Trigger( HitActor,self );
		else if ( (Decoration(HitActor) != None) )
		{
			// If we can't pick it up.  Ignore it.
			if ( !Decoration(HitActor).Grabbable || (Decoration(HitActor).Base == self) )
				return;

			if ( Base == HitActor )
				SetBase( None );

			// Put down the quest item if we are carrying one.
			if ( QuestItem(UsedItem) != None )
				PutDownQuestItem( true );

			// Put down our weapon.
			if ( Level.NetMode == NM_Standalone )
				WeaponDown( false, true, true, true );
			else
				WeaponDown( false, true, true );

			// Grab it!
			CarriedDecoration = Decoration(HitActor);
            CarriedDecoration.RemoteRole = ROLE_SimulatedProxy;
			CarriedDecoration.bCollideWorld = false;
			CarriedDecoration.SetCollision( false, false, false );
			CarriedDecoration.SetCollisionSize( 0, 0 );
			CarriedDecoration.SetPhysics( PHYS_None );
			CarriedDecoration.LodMode = LOD_Disabled;
			CarriedDecoration.SetBase( Self );
			CarriedDecoration.bHidden = true;
			CarriedDecoration.bNeverTravel = false;
			CarriedDecoration.SetTimer(0.1, true);
			CarriedDecoration.DrawScale /= 10;
			CarriedDecoration.bOldShadowReceive = CarriedDecoration.bShadowReceive;
			CarriedDecoration.bShadowReceive = false;
			if ( CarriedDecoration.ImmolationActor != None )
				CarriedDecoration.ImmolationActor.ScaleDrawScale( 0.1 );
			CarriedDecoration.CarriedBy = Self;
            CarriedDecoration.SetOwner( Self );

			foreach AllActors( class'Actor', D )
			{
				if (D.IsA('Decoration') && (D.base == CarriedDecoration) && (D != CarriedDecoration))
				{
					D.SetBase(None);
					D.SetPhysics(PHYS_Falling);
				}
				else if (D.IsA('Inventory') && (D.base == CarriedDecoration) && (!Inventory(D).bCarriedItem))
				{
					D.SetBase(None);
					D.SetPhysics(PHYS_Falling);
				}
			}

			NewSpeed = 1.0;
			if (CarriedDecoration.Mass >= 100)
			{
				if (CarriedDecoration.Mass >= 800)
					NewSpeed = 0;
				else
					NewSpeed = 1.0 - ((CarriedDecoration.Mass - 100) / 800.0);
			}

			PlayerPawn(self).SetPlayerSpeed( NewSpeed );

			PlaySound( GrabSound, SLOT_Interact );
		}
	}
}

simulated function PositionDecoration(optional bool ForThrow)
{
	local vector DecoEyeHeight, usePullback, temp, extent, newLocation;
	local vector x, y, z;
	local float sizeFactor;

	if (!ForThrow)
		sizeFactor = 10;
	else
		sizeFactor = 1;

	if ( CarriedDecoration != none )
	{
		DecoEyeHeight = vect(0,0,0);
		DecoEyeHeight.z = WalkBob.z * CarriedDecoration.BobDamping + EyeHeight;
		DecoEyeHeight.x = WalkBob.x * CarriedDecoration.BobDamping;
		DecoEyeHeight.y = WalkBob.y * CarriedDecoration.BobDamping;

		GetAxes( ViewRotation, x, y, z );

		newLocation = Location + DecoEyeHeight
				+ (y * CarriedDecoration.Default.CollisionRadius * 1.4)/sizeFactor
				- (z * CarriedDecoration.Default.CollisionHeight * 3)/sizeFactor
				+ (y * CarriedDecoration.PlayerViewOffset.x)
				+ (z * CarriedDecoration.PlayerViewOffset.y)
				+ (x * CarriedDecoration.PlayerViewOffset.z)
				+ (Normal(vector(ViewRotation)) * (CarriedDecoration.Default.CollisionRadius * 2.0))/sizeFactor;

		CarriedDecoration.MoveSmooth(newLocation - CarriedDecoration.Location);
		CarriedDecoration.SetRotation(ViewRotation);
    }
}

function PutDownQuestItem( optional bool bFastDown )
{
	OldUsedItem = UsedItem;
	if ( bFastDown )
		UsedItem = None;
	else
		QuestItem(UsedItem).Activate();
}

exec function AddCash(int Amount)
{
	Cash += Amount;
}

exec function KillSOSPowers()
{
}




/*-----------------------------------------------------------------------------
	Bones / Tracking
	Assumes Human skeleton is standard.
-----------------------------------------------------------------------------*/

function SetSpecialAnimBlend( float blend, float rate )
{
    DesiredSpecialAnimBlend = blend;
	SpecialAnimBlend        = 1.0;
	SpecialAnimBlendRate    = 0.5;
}

event AnimTick( float DeltaTime )
{
	local int i;

	//DriveFacialTracks(DeltaTime);				// JEP
	//UpdateFacialExpressions(DeltaTime);		// JEP

	if ( bLaissezFaireBlending )
		return;

	// Update all the blending.
	TopAnimBlend     = UpdateRampingFloat( TopAnimBlend,     DesiredTopAnimBlend,     TopAnimBlendRate*DeltaTime );
	BottomAnimBlend  = UpdateRampingFloat( BottomAnimBlend,  DesiredBottomAnimBlend,  BottomAnimBlendRate*DeltaTime );
	SpecialAnimBlend = UpdateRampingFloat( SpecialAnimBlend, DesiredSpecialAnimBlend, SpecialAnimBlendRate*DeltaTime );
	FaceAnimBlend    = UpdateRampingFloat( FaceAnimBlend,    DesiredFaceAnimBlend,    FaceAnimBlendRate*DeltaTime );

	GetMeshInstance();

	if ( MeshInstance != None )
	{
		MeshInstance.MeshChannels[1].AnimBlend = TopAnimBlend;
		MeshInstance.MeshChannels[2].AnimBlend = BottomAnimBlend;
		MeshInstance.MeshChannels[3].AnimBlend = SpecialAnimBlend;
		MeshInstance.MeshChannels[5].AnimBlend = FaceAnimBlend;

        // If we have reached a blending >= 1.0 then set the animsequence to 'None'
		if ( DesiredTopAnimBlend>=1.0 && TopAnimBlend>=1.0 )
        {
            MeshInstance.MeshChannels[1].AnimSequence = 'None';
        }
		if ( DesiredBottomAnimBlend>=1.0 && BottomAnimBlend>=1.0 )
        {
            MeshInstance.MeshChannels[2].AnimSequence = 'None';
        }
		if ( DesiredSpecialAnimBlend>=1.0 && SpecialAnimBlend>=1.0 )
        {
            MeshInstance.MeshChannels[3].AnimSequence = 'None';
        }
		/*		// JEP
		if ( DesiredFaceAnimBlend>=1.0 && FaceAnimBlend>=1.0 )
		{
			MeshInstance.MeshChannels[5].AnimSequence = 'None';
		}
		*/
	}

	// Update alert status.
	if ( (AlertTimer > 0.0) && (GetUpperBodyState() == UB_Alert) && (Weapon != None) && (!Weapon.StayAlert) )
	{
		AlertTimer -= DeltaTime;
		if ( AlertTimer < 0.0 )
		{
			AlertTimer = 0.0;
			SetUpperBodyState( UB_Relaxed );
		}
	}
}

function SetDamageBone( name BoneName )
{
    if ( BoneName=='None' )
		return;
	DamageBone = BoneName;
}

simulated event bool OnEvalBones(int Channel)
{
	local EPostureState PS;	

	//Log("ON EVAL BONES ROLE:"@Role@"RemoteRole:"@RemoteRole);

	if ( !bHumanSkeleton )
		return false;

    if ( Channel == 10 )		// JEP Changed lip sync, blinking, etc to use channel 10 (needed channels 6,7,8,9 for lip facial expression stuff)
	{
		// Update head.
		EvalBlinking();
		
		// JEP Commented out
		//if ( MonitorSoundLevel > 0.0 )
		//	EvalLipSync();

		EvalLipSync2();		// JEP
		EvalFacialNoise();	// JEP

		EvalHeadLook();
		
		// Expanding/Shrinking bones
		/*
		if ( bExpanding )
		{
			if ( ExpandTimeRemaining > 0.f )
				EvalExpandedBones();
			else
				EvalExpandedRestore();
		}
		*/
		if ( ShrinkCounter > 0.0 )
			EvalShrinkRay();

		EvalBoneScales();

		PS = GetPostureState();

		if ( ( PS != PS_None      ) &&
			 ( PS != PS_Swimming  ) &&
			 ( PS != PS_Crouching ) &&
             ( PS != PS_Rope      ) &&
             ( PS != PS_Ladder    ) &&
			 ( PS != PS_Turret    ) &&
			 ( GetControlState() != CS_Stasis )
			
		   ) 
		{
			EvalPelvis();		
		}		
	}

	return Super.OnEvalBones(Channel);
}

simulated function EvalBoneScales()
{
    local int			bone,i;
    local MeshInstance	minst;
	local vector        s;

	minst = GetMeshInstance();
    
	if ( minst==None )
        return;

	for ( i=0; i<6; i++ )
	{
		if ( BoneScales[i] != 0 )
		{
			bone = minst.BoneFindNamed( ExpandedBones[i] );
			if ( bone != 0 )
			{
				s = minst.BoneGetScale( bone, false, true );
				s *= BoneScales[i];
				minst.BoneSetScale( bone, s, false );
			}
		}
	}
}

simulated function bool EvalBlinking()
{
    local int bone;
    local MeshInstance minst;
    local vector t;
	local float deltaTime;
    
	minst = GetMeshInstance();
    if (minst==None)
        return(false);

	if (BlinkDurationBase <= 0.0)
		return(false);

	deltaTime = Level.TimeSeconds - LastBlinkTime;
	LastBlinkTime = Level.TimeSeconds;

	BlinkTimer -= deltaTime;
	if (BlinkTimer <= 0.0)
	{
		if (!bBlinked)
		{
			bBlinked = true;
			BlinkTimer = BlinkDurationBase + FRand()*BlinkDurationRandom;
		}
		else
		{
			bBlinked = false;
			BlinkTimer = BlinkRateBase + FRand()*BlinkRateRandom;
		}
	}

	if (BlinkChangeTime <= 0.0)
	{
		if (bBlinked)
			CurrentBlinkAlpha = 1.0;
		else
			CurrentBlinkAlpha = 0.0;
	}
	else
	{
		if (bBlinked)
		{
			CurrentBlinkAlpha += deltaTime/BlinkChangeTime;
			if (CurrentBlinkAlpha > 1.0)
				CurrentBlinkAlpha = 1.0;
		}
		else
		{
			CurrentBlinkAlpha -= deltaTime/BlinkChangeTime;
			if (CurrentBlinkAlpha < 0.0)
				CurrentBlinkAlpha = 0.0;
		}
	}

	// blink the left eye
	bone = minst.BoneFindNamed('Eyelid_L');
	if (bone!=0)
	{
		t = minst.BoneGetTranslate(bone, false, true);
		t -= BlinkEyelidPosition*CurrentBlinkAlpha;
		minst.BoneSetTranslate(bone, t, false);
	}

	// blink the right eye
	bone = minst.BoneFindNamed('Eyelid_R');
	if (bone!=0)
	{
		t = minst.BoneGetTranslate(bone, false, true);
		t -= BlinkEyelidPosition*CurrentBlinkAlpha;
		minst.BoneSetTranslate(bone, t, false);
	}

	return(true);
}

simulated function bool EvalLipSync()
{
    local int bone;
    local MeshInstance minst;
	local rotator r;
    local vector s, t;
	local float f;
	local float scale;
    
	minst = GetMeshInstance();
    if (minst==None)
        return(false);

    // rotate the jaw downward
	bone = minst.BoneFindNamed('Jaw');
	if (bone!=0)
	{
		scale=SoundSyncScale_Jaw;
		if(scale==0) scale=1.0;
		
		r = minst.BoneGetRotate(bone, false);
		r.Pitch = MonitorSoundLevel * -2048.0 * Scale;
		minst.BoneSetRotate(bone, r, false);
	}

	// scale in the mouth corner a bit
    bone = minst.BoneFindNamed('MouthCorner');
	if (bone!=0)
	{
		scale=SoundSyncScale_MouthCorner;
		if(scale==0) scale=1.0;

		f = 1.0 - MonitorSoundLevel * 2.0 * Scale;
		s.x = f; s.y = f; s.z = f;
		minst.BoneSetScale(bone, s, true);
	}

	// move the upper lip up a little
    bone = minst.BoneFindNamed('Lip_U');
    if (bone!=0)
	{
		scale=SoundSyncScale_Lip_U;
		if(scale==0) scale=1.0;

	    t = minst.BoneGetTranslate(bone, false, true);
		t.x += 0.25 * Scale * MonitorSoundLevel;
		minst.BoneSetTranslate(bone, t, false);
	}

	// same with the lower lip
    bone = minst.BoneFindNamed('Lip_L');
    if (bone!=0)
	{
		scale=SoundSyncScale_Lip_L;
		if(scale==0) scale=1.0;

		t = minst.BoneGetTranslate(bone, false, true);
		t.x += -0.5 *Scale  * MonitorSoundLevel;
		minst.BoneSetTranslate(bone, t, false);
	}
	return(true);
}

// Follow Item TEST
simulated function bool EvalHeadLook()
{
	/*
    local int bone;
    local MeshInstance minst;
	local rotator r;
	local float f;
	local vector t;
	
	local rotator EyeLook, HeadLook, BodyLook;
	local rotator LookRotation;
	local float HeadFactor, ChestFactor, AbdomenFactor;
	local float PitchCompensation;
    
	minst = GetMeshInstance();
    if (minst==None)
        return false;

	// Move the head to follow an item of interest.
	HeadLook = HeadTracking.Rotation - Rotation;
	HeadLook = Normalize(HeadLook);
	HeadLook = Slerp(HeadTracking.Weight, rot(0,0,0), HeadLook);
	r = Normalize(ClampHeadRotation(HeadTracking.DesiredRotation) - Rotation);
	LookRotation = HeadLook;
	bone = minst.BoneFindNamed('Head');
	if (bone!=0)
	{
		r = DesiredRotation;
		r = rot(r.Pitch,0,-r.Yaw);
		minst.BoneSetRotate(bone, r, true, true);
	}

	// Move the eyes to follow an item of interest.
	EyeLook = EyeTracking.Rotation - Rotation;
	EyeLook = Normalize(EyeLook - HeadLook);
	EyeLook.Yaw *= 0.125; // Minimal eye movements cover large ground, so scale back rotation.
	EyeLook = Slerp(EyeTracking.Weight, rot(0,0,0), EyeLook);
	LookRotation = EyeLook;
	bone = minst.BoneFindNamed('Pupil_L');
	if (bone!=0)
	{			
		r = LookRotation;
		r = rot(r.Pitch,0,-r.Yaw);
		minst.BoneSetRotate(bone, r, true, true);
	}
	bone = minst.BoneFindNamed('Pupil_R');
	if (bone!=0)
	{
		r = LookRotation;
		r = rot(r.Pitch,0,-r.Yaw);
		minst.BoneSetRotate(bone, r, true, true);
	}

  */
	return true;
}

simulated function bool Shrunken()
{
	if ( ShrinkCounter > 0.0 )
		return true;
	else
		return false;
}

simulated function bool EvalShrinkRay()
{
    local MeshInstance minst;
	local int bone, footbone, rootbone, pelvisbone;
	local vector s, footboneloc, pelvisboneloc, newboneloc, rootloc, ResizeLoc, pelvisbonedelta;
	local float ShrinkAmount, ArmScale, HeadScale, LegScale, ChestScale, RootScale, footdelta, SegmentTime;

	if ( Shrunken() && (DrawScale == 0.25) )
		return true;

	// Do nothing if unshrunken.
	if ( ShrinkCounter == 0.f )
		return true;

    minst = GetMeshInstance();
    if ( minst == None )
        return false;

	// 4 segments: Arms, head, root, legs.
	SegmentTime = default.ShrinkTime / 4;

	// Get the foot location before shrinking.
	if ( ShrinkCounter > SegmentTime*2 )
	{
		footbone = minst.BoneFindNamed( 'foot_l' );
		footboneloc = minst.BoneGetTranslate( footbone, true, false );
		footboneloc = minst.MeshToWorldLocation( footboneloc );
	}

	// Get the head location before shrinking.
	if ( ShrinkCounter > SegmentTime*2 )
	{
		pelvisbone = minst.BoneFindNamed( 'pelvis' );
		pelvisboneloc = minst.BoneGetTranslate( pelvisbone, true, false );
		pelvisboneloc = minst.MeshToWorldLocation( pelvisboneloc );
	}

	ShrinkAmount = ShrinkCounter;
	if ( ShrinkCounter < SegmentTime )
		HeadScale = 1.0 - ((ShrinkAmount/SegmentTime) * 0.75);
	else
		HeadScale = 0.25;

	ShrinkAmount -= SegmentTime;
	if ( (ShrinkCounter < SegmentTime*2) && (ShrinkCounter > SegmentTime) )
		ArmScale = 1.0 - ((ShrinkAmount/SegmentTime) * 0.75);
	else if ( ShrinkCounter >= SegmentTime*2 )
		ArmScale = 0.25;
	else
		ArmScale = 1.0;

	ShrinkAmount -= SegmentTime;
	if ( (ShrinkCounter < SegmentTime*3) && (ShrinkCounter > SegmentTime*2) )
		RootScale = 1.0 - ((ShrinkAmount/SegmentTime) * 0.75);
	else if ( ShrinkCounter >= SegmentTime*3 )
		RootScale = 0.25;
	else
		RootScale = 1.0;
	ArmScale  *= 1.0 / RootScale;
	HeadScale *= 1.0 / RootScale;

	ShrinkAmount -= SegmentTime;
	if ( (ShrinkCounter < SegmentTime*4) && (ShrinkCounter > SegmentTime*3) )
		LegScale = 1.0 - ((ShrinkAmount/SegmentTime) * 0.75);
	else if ( ShrinkCounter >= SegmentTime*4 )
		LegScale = 0.25;
	else
		LegScale = 1.0;
	LegScale *= 1.0 / RootScale;

	// Shrink Head
	bone = minst.BoneFindNamed('Head');
	if ( bone != 0 )
	{
		s = minst.BoneGetScale( bone, false, true );
		s *= HeadScale;
		minst.BoneSetScale( bone, s, false );
	}

	// Shrink Arms
	bone = minst.BoneFindNamed('Bicep_L');
	if ( bone != 0 )
	{
		s = minst.BoneGetScale( bone, false, true );
		s *= ArmScale;
		minst.BoneSetScale( bone, s, false );
	}
	bone = minst.BoneFindNamed('Bicep_R');
	if ( bone != 0 )
	{
		s = minst.BoneGetScale( bone, false, true );
		s *= ArmScale;
		minst.BoneSetScale( bone, s, false );
	}

	// Shrink Root
	bone = minst.BoneFindNamed('Root');
	if ( bone != 0 )
	{
		s = minst.BoneGetScale( bone, false, true );
		s *= RootScale;
		minst.BoneSetScale( bone, s, false );

	}

	// Shrink Leg
	bone = minst.BoneFindNamed('Thigh_L');
	if ( bone != 0 )
	{
		s = minst.BoneGetScale( bone, false, true );
		s *= LegScale;
		minst.BoneSetScale( bone, s, false );
	}
	bone = minst.BoneFindNamed('Thigh_R');
	if ( bone != 0 )
	{
		s = minst.BoneGetScale( bone, false, true );
		s *= LegScale;
		minst.BoneSetScale( bone, s, false );
	}

	// If we changed the root, the mesh will drift.
	// This isn't perfect, you have to set the drawscale to 0.25 at the end
	// otherwise you see the problems given the current leg animation.
	if ( ShrinkCounter > SegmentTime*2 )
	{
		// Get pelvis difference without z and modify prepivot.
		// This corrects non-z drift.
		newboneloc = minst.BoneGetTranslate( pelvisbone, true, false );
		newboneloc = minst.MeshToWorldLocation( newboneloc );
		pelvisbonedelta = newboneloc - pelvisboneloc;
		pelvisbonedelta.z = 0;
		PrePivot = -pelvisbonedelta;

		// Adjust prepivot a bit more to account for change in distance from shoe bottom to foot bone.
		// This just looks nicer.
		PrePivot.z -= 5.0 * (1.0 - (((LegScale*RootScale) - 0.25) / 0.75));

		// Get current foot location change in z.
		// This will correct from drift due to shrunken legs that shrink towards the root.
		newboneloc = minst.BoneGetTranslate( footbone, true, false );
		newboneloc = minst.MeshToWorldLocation( newboneloc );
		footdelta = newboneloc.z - footboneloc.z;

		// Get root bone location.
		rootbone = minst.BoneFindNamed( 'root' );
		rootloc = minst.BoneGetTranslate( rootbone, true, false );

		// Apply the mods and set the new location.
		rootloc.z -= footdelta;
		minst.BoneSetTranslate( rootbone, rootloc, true );

	}

	if ( Weapon != None )
		Weapon.ThirdPersonScale = FMax( 1.0 - (ShrinkCounter/ShrinkTime), 0.25 );

	return true;
}

function CheckShrink()
{
	if ( (ShrinkCounter >= ShrinkTime) && !bFullyShrunk )
	{
		// Finished a full shrink.
		FullyShrunken();
	}
	else if ( (ShrinkCounter >= ShrinkTime / 2) && bPartiallyShrunk )
	{
		// Finished a partial shrink.
		PartiallyShrunken();
	}
}

function StartFullShrink()
{
	// Full shrink.
	ShrinkCounterDestination = ShrinkTime;
	/*
	if ( bPartiallyShrunk )
		Health		= Max( Health - 20, 1 );
	else
		Health		= Max( Health - 40, 1 );
	*/
	bPartiallyShrunk = false;
}

function StartPartialShrink()
{
	// Partial shrink.
	bPartiallyShrunk = true;
	ShrinkCounterDestination = ShrinkTime / 2;
//	Health			= Max( Health - 20, 1 );
}

function ChangeCollisionToShrunken() // Player Pawn overrides this
{
	SetCollisionSize( default.CollisionRadius*0.35, FMax( default.CollisionHeight*0.25, 12.6 ) );
}

// Called when the pawn becomes fully shrunken.
// Bone evaluation stops and the drawscale is set to 0.25.
// The collision cylinder is also cut down, but the radius is slightly larger.
// This is so the person doesn't clip into the wall.
function FullyShrunken()
{
	local vector ResizeLoc;

	ChangeCollisionToShrunken();
	ResizeLoc		= Location;
	ResizeLoc.Z		-= default.CollisionHeight - default.CollisionHeight*0.25;
	SetLocation( ResizeLoc );

	PreShrinkDrawScale = DrawScale;
	DrawScale = 0.25;
	PrePivot = vect(0,0,0);

	if ( ShrinkActor != None )
		ShrinkActor.Destroy();

	MeleeDamageMultiplier = 0.15;
	BaseEyeHeight	= 0;
	ClientSetBaseEyeHeight( BaseEyeHeight );
	GroundSpeed		= 100;
	WaterSpeed		= 50;
	JumpZ			= 240;
	bFullyShrunk	= true;
	bPartiallyShrunk = false;
	bNotShrunkAtAll = false;
	SetCallbackTimer( 20.f, false, 'RestoreShrink' );
}

// Called when done with a partial shrink.
function PartiallyShrunken()
{
	// Set eye height at half.
	bNotShrunkAtAll = false;
	BaseEyeHeight = default.BaseEyeHeight / 2;
	ClientSetBaseEyeHeight( BaseEyeHeight );

	// Get rid of the shrink actor.
	if ( ShrinkActor != None )
		ShrinkActor.Destroy();

	SetCallbackTimer( 20.f, false, 'RestoreShrink' );
}

// A timer callback function that restores the player's size over time.
function RestoreShrink()
{
	local float RestoreTimePerTick, RestoreTicks, ShrinkScale;
	local float RadiusLerp, HeightLerp;
	local float NewHeight;

	RestoreTimePerTick = 0.03f;
	if ( !bRestoringShrink )
	{
		SetCallbackTimer( RestoreTimePerTick, true, 'RestoreShrink' );
		bRestoringShrink = true;
	}

	RestoreTicks = 1.0f / RestoreTimePerTick;
	ShrinkCounterDestination -= ShrinkTime / RestoreTicks;
	ShrinkCounter = ShrinkCounterDestination;
	if ( PreShrinkDrawScale > 0.f )
	{
		DrawScale = PreShrinkDrawScale;
		PreShrinkDrawScale = 0.f;
	}

	if ( ShrinkCounterDestination <= 0.f )
	{
//		if ( bFullyShrunk )
//			Health = FClamp( Health+90.f, 0.f, 100.f );
		UnShrink();
		return;
	}

	if ( bFullyShrunk )
	{
		if ( PlayerPawn( self ) != None && PlayerPawn( self ).bIsDucking )
		{
			NewHeight = PlayerPawn( self ).default.DuckCollisionHeight;
		}
	    else
		{
			NewHeight = default.CollisionHeight;
		}

		ShrinkScale = (ShrinkTime - ShrinkCounterDestination) / ShrinkTime;
		RadiusLerp = Lerp( ShrinkScale, default.CollisionRadius*0.35, default.CollisionRadius*ShrinkScale );
		HeightLerp = Lerp( ShrinkScale, default.CollisionHeight*0.25, NewHeight*ShrinkScale );
		SetCollisionSize( RadiusLerp, HeightLerp );
	}

	// Test to see if we fit.
	if ( !SetLocation( Location ) )
	{
		Died( None, class'CrushingDamage', Location );
		UnShrink();
	}
}

// Called to end shrinking and set everything back to normal.
function UnShrink()
{
	GroundSpeed     = default.GroundSpeed;
	WaterSpeed      = default.WaterSpeed;
	JumpZ			= default.JumpZ;
	BaseEyeHeight   = default.BaseEyeHeight;
	ClientSetBaseEyeHeight( BaseEyeHeight );
	bRestoringShrink= false;
	bFullyShrunk	= false;
	bPartiallyShrunk= false;
	MeleeDamageMultiplier = 1.0;
	
	if ( Weapon != None )
		Weapon.ThirdPersonScale = 1.0;

	if ( PreShrinkDrawScale > 0.f )
	{
		DrawScale = PreShrinkDrawScale;
		PreShrinkDrawScale = 0.f;
	}

	// Check for player ducking... and restoring properly to that.
	if ( PlayerPawn( self ) != None && PlayerPawn( self ).bIsDucking )
	{
		SetCollisionSize( default.CollisionRadius, PlayerPawn( self ).default.DuckCollisionHeight );
	}
	else
	{
		SetCollisionSize( default.CollisionRadius, default.CollisionHeight );
	}

	ShrinkCounterDestination	= 0.f;
	ShrinkCounter				= 0.f;
	bNotShrunkAtAll				= true;
	EndCallbackTimer( 'RestoreShrink' );
}

// Called prior to getting stomped.
// Can be used by AI to turn the guy around and so forth.
function PrepareForStomp( Pawn StompInstigator )
{
}

simulated function DoAbdomenPitch(out int Pitch)
{        
    if ( Pitch > 32768 )
    {
        Pitch -= 65535;
    }

    Pitch *= 0.8;
    if ( Pitch <= MaxAbdomenPitchDown )
    {
        Pitch = MaxAbdomenPitchDown;
        return;
    }
    else if ( Pitch >= MaxAbdomenPitchUp )
    {
        Pitch = MaxAbdomenPitchUp;
        return;
    }
/* old way
    if ( Pitch < 0 ) // Looking down
    {
        Pitch = int(( float(Pitch) / float(MaxAbdomenViewPitchDown) ) * MaxAbdomenPitchDown);
    }
    else if ( Pitch >= 0 ) // Looking up
    {
        Pitch = int(( float(Pitch) / float(MaxAbdomenViewPitchUp) ) * MaxAbdomenPitchUp);
    }
*/
}   

simulated function bool EvalPelvis()
{
    local int			bone;
    local MeshInstance	minst;
	local rotator		r, bonerot;
	local vector		Direction,Target,X,Y,Z;
    local rotator		RotDirection;
	local Vector		V;

	minst = GetMeshInstance();
    
    if ( minst==None )
        return false;

	// Determine the direction to rotate to.
	V   = Velocity;
	V.Z = 0;

	GetAxes( ViewRotation,X,Y,Z );
	Direction.X         = V dot X;
	Direction.Y         = V dot Y;

	//RotDirection.Yaw    = Normalize( Rotator( Direction ) ).Yaw;	// old way
    RotDirection.Pitch  = ViewRotation.Pitch;
    RotDirection.Roll   = ViewRotation.Roll;
	
	Direction = Normal( Direction );
	
    // If we're not on a rope/ladder, then pitch the abdomen, and clamp it
    if ( !bOnRope && !bOnLadder )
	{
        DoAbdomenPitch( RotDirection.Pitch );
	}
    else
	{
        RotDirection.Pitch = 0;
	}

	// We only allow eight degrees of freedom.
	// Allowing complete freedom caused very weird behavior because Velocity includes angular momentum.
	if ( bBackPedaling )
	{
		if ( Direction.Y < 0.1 && Direction.Y > -0.1 )
			RotDirection.Yaw = 0;
		else if ( Direction.Y > 0.8  )
			RotDirection.Yaw = -12228;
		else if ( Direction.Y > 0.1 )
			RotDirection.Yaw = -8192;
		else if ( Direction.Y < -0.8 )
			RotDirection.Yaw = 12228;
		else if ( Direction.Y < -0.1  )
			RotDirection.Yaw = 8192;
	}
	else
	{
		if ( Direction.Y < 0.1 && Direction.Y > -0.1 )
			RotDirection.Yaw = 0;
		else if ( Direction.Y > 0.8  )
			RotDirection.Yaw = 12228;
		else if ( Direction.Y > 0.1 )
			RotDirection.Yaw = 8192;
		else if ( Direction.Y < -0.8 )
			RotDirection.Yaw = -12228;
		else if ( Direction.Y < -0.1  )
			RotDirection.Yaw = -8192;
	}

	// If this direction is different than our current direction and we are slerping, update the baseline.
	// Positive RotDirection.Yaw is "right"
	// Negative RotDirection.Yaw is "left"
	if ( ( TorsoTracking.DesiredRotation.Roll != RotDirection.Yaw ) && TorsoSlerping )
	{
		if ( ( ( TorsoTracking.DesiredRotation.Roll > TorsoTracking.Rotation.Roll ) &&
			 ( RotDirection.Yaw < TorsoTracking.Rotation.Roll ) ) ||
			( ( TorsoTracking.DesiredRotation.Roll < TorsoTracking.Rotation.Roll ) &&
			 ( RotDirection.Yaw > TorsoTracking.Rotation.Roll ) ) )
		{
			TorsoTracking.BaseRotation = TorsoTracking.Rotation;
			TorsoTracking.Weight = 0.0;
		}
	}
	
	// Save the new desired rotation.
	TorsoTracking.DesiredRotation.Pitch = 0;
	TorsoTracking.DesiredRotation.Yaw	= 0;
	TorsoTracking.DesiredRotation.Roll	= RotDirection.Yaw; // The roll of the torso bone is the yaw of the direction we are headed.

	// If our direction changed and we weren't slerping, reset our weight and begin slerping.
	if ( ( RotDirection.Yaw != LastRotDirection.Yaw ) && !TorsoSlerping )
	{
		TorsoTracking.Weight = 0.0;
		TorsoSlerping		 = true;
	}

	LastRotDirection.Yaw = RotDirection.Yaw;

	// If we are slerping, interpolate between base rotation and desired rotation.
	if ( TorsoSlerping )
	{
		TorsoTracking.Rotation = Slerp( TorsoTracking.Weight, 
			                            TorsoTracking.BaseRotation, 
										TorsoTracking.DesiredRotation );

		// If we are at max weight, end slerping.
		if ( TorsoTracking.Weight == TorsoTracking.DesiredWeight )
		{
			TorsoSlerping				= false;
			TorsoTracking.BaseRotation	= TorsoTracking.DesiredRotation;
		}

		RotDirection.Yaw = TorsoTracking.Rotation.Roll;
	}
	else
	{
		RotDirection.Yaw = TorsoTracking.Rotation.Roll;
	}

	if ( PelvisBone == 0 )
		PelvisBone = minst.BoneFindNamed( 'Pelvis' );

	if ( PelvisBone != 0)
	{
		r.Roll    = -RotDirection.Yaw * PelvisRotationScale;
		minst.BoneSetRotate( PelvisBone, r, false, true );
	}

	if ( AbdomenBone == 0 )
		AbdomenBone = minst.BoneFindNamed( 'Abdomen' );

	if ( AbdomenBone != 0 )
	{
		r.Roll    = -RotDirection.Yaw * AbdomenRotationScale;
        r.Pitch   = RotDirection.Pitch;
		minst.BoneSetRotate( AbdomenBone, r, false, true );
	}

	if ( ChestBone == 0 )
	    ChestBone = minst.BoneFindNamed( 'Chest' );

	if ( ChestBone != 0 )
	{
		r.Roll = RotDirection.Yaw * ChestRotationScale;
		minst.BoneSetRotate( ChestBone, r, false, true );
	}
}

simulated function rotator ClampEyeRotation(rotator r)
{
	local rotator adj;
	adj = Slerp(HeadTracking.Weight, Rotation, HeadTracking.Rotation);
	r = Normalize(r - adj);
	r.Pitch = Clamp(r.Pitch, -EyeTracking.RotationConstraints.Pitch, EyeTracking.RotationConstraints.Pitch);
	r.Yaw = Clamp(r.Yaw, -EyeTracking.RotationConstraints.Yaw, EyeTracking.RotationConstraints.Yaw);
	r.Roll = Clamp(r.Roll, -EyeTracking.RotationConstraints.Roll, EyeTracking.RotationConstraints.Roll);
	r = Normalize(r + adj);
	return r;
}

simulated function rotator ClampHeadRotation(rotator r)
{
	local rotator adj;
	adj = Rotation;
	r = Normalize(r - adj);
	r.Pitch = Clamp(r.Pitch, -HeadTracking.RotationConstraints.Pitch, HeadTracking.RotationConstraints.Pitch);
	r.Yaw = Clamp(r.Yaw, -HeadTracking.RotationConstraints.Yaw, HeadTracking.RotationConstraints.Yaw);
	r.Roll = Clamp(r.Roll, -HeadTracking.RotationConstraints.Roll, HeadTracking.RotationConstraints.Roll);
	r = Normalize(r + adj);
	return r;
}

simulated function EnableHeadTracking(bool bEnable)
{
	if (bEnable)
	{
		HeadTracking.DesiredWeight = 1.0;
		HeadTracking.WeightRate = 1.0;
	} else {
		HeadTracking.DesiredWeight = 0.0;
		HeadTracking.WeightRate = 2.0;
	}
}

simulated function EnableEyeTracking(bool bEnable)
{
	if (bEnable)
	{
		EyeTracking.DesiredWeight = 1.0;
		EyeTracking.WeightRate = 1.0;
	} else {
		EyeTracking.DesiredWeight = 0.0;
		EyeTracking.WeightRate = 2.0;
	}
}

simulated function TickTracking( float DeltaTime )
{
	local rotator r;

	// Tracking update.
	TorsoTracking.Weight = UpdateRampingFloat(TorsoTracking.Weight, TorsoTracking.DesiredWeight, TorsoTracking.WeightRate*DeltaTime);
}

simulated function bool EvalExpandedBones()
{
	local int i, bone, footbone, rootbone;
    local MeshInstance minst;
	local vector bonescale, newloc, boneloc, newboneloc, rootloc;
	local bool bSomethingExpanded;
	local float footdelta;

	minst = GetMeshInstance();
    if (minst==None)
        return false;

	for ( i=0; i<6; i++ )
	{
		if ( ExpandedScales[i] > 0.0 )
		{
			// Get the un expando scaled foot location.
			if ( i == 0 )
			{
				footbone = minst.BoneFindNamed( 'foot_l' );
				boneloc = minst.BoneGetTranslate( footbone, true, false );
				boneloc = minst.MeshToWorldLocation( boneloc );
			}

			// Apply the new scale.
			bone = minst.BoneFindNamed( ExpandedBones[i] );
			bonescale = minst.BoneGetScale( bone, false, false );

			if ( (i != 0) && (ExpandedScales[i] == 0.3) )
				bonescale *= 1.0 + ExpandedScales[i] + sin(Level.TimeSeconds*4)/10;
			else
				bonescale *= 1.0 + ExpandedScales[i];
			
			minst.BoneSetScale( bone, bonescale, false );
			
			if ( i != 0 )
				EvalExpandedChildren( minst, bone );

			// If we changed the pelvis, the foot position will have changed.
			if ( i == 0 )
			{
				if ( ((ExpandedScales[i] > 0.0) && (ExpandedScales[i] < 0.3)) || 
					 ((ExpandedScales[i] > 0.3) && (ExpandedScales[i] < 2.0)) )
				{
					// We are expanding, accumulate change.
					boneloc.z += ExpandCounter;
					newboneloc = minst.BoneGetTranslate( footbone, true, false );
					newboneloc = minst.MeshToWorldLocation( newboneloc );
					footdelta = newboneloc.z - boneloc.z;

					rootbone = minst.BoneFindNamed( 'root' );
					rootloc = minst.BoneGetTranslate( rootbone, true, false );
					rootloc.z -= ExpandCounter;
					minst.BoneSetTranslate( rootbone, rootloc, true );

					ExpandCounter += footdelta;
				}
				else
				{
					// Maintain the current translation change.
					rootbone = minst.BoneFindNamed( 'root' );
					rootloc = minst.BoneGetTranslate( rootbone, true, false );
					rootloc.z -= ExpandCounter;
					minst.BoneSetTranslate( rootbone, rootloc, true );
				}
			}

			bSomethingExpanded = true;
		}
	}

	// A hack to adjust the collision cylinder.  We'll see how this goes.
	if ( bSomethingExpanded && !bExpandedCollision )
	{
		bExpandedCollision = true;
		newloc = Location;
		newloc.Z += (CollisionHeight*1.3 - CollisionHeight) * 2;
		SetLocation( newloc );
		SetCollisionSize( CollisionRadius*1.3, CollisionHeight*1.3 );
		MeshLowerHeight *= 1.3;
	}
}

simulated function bool EvalExpandedChildren( MeshInstance minst, int bone )
{
	local int children, j, child, childdir;
	local vector childscale;
	local name childname;

	children = minst.BoneGetChildCount( bone );
	for ( j=0; j<children; j++ )
	{
		child = minst.BoneGetChild( bone, j );
		childname = minst.BoneGetName( child );
		if ( (childname == 'eyelid_l') || (childname == 'eyelid_r') ||
			 (childname == 'pupil_l')  || (childname == 'pupil_r') )
			continue;
		if ( j%2 == 0 )
			childdir = 1;
		else
			childdir = -1;
		childscale = minst.BoneGetScale( child, false, false );
		childscale *= 1.0 - (sin((Level.TimeSeconds*4)+(j*(PI/4)))/5 * childdir);
		minst.BoneSetScale( child, childscale, false );

		EvalExpandedChildren( minst, child );
	}
}

simulated function bool EvalExpandedRestore()
{
	local int bone, i, footbone, rootbone;
	local float expandfactor, alpha, footdelta;
	local vector bonescale, boneloc, rootloc, newboneloc;
	local MeshInstance minst;

	minst = GetMeshInstance();
    if (minst==None)
        return false;

	for ( i=0; i<6; i++ )
	{
		if ( ExpandedScales[i] > 0.0 )
		{
			// Get the unexpando scaled foot location.
			if ( i == 0 )
			{
				footbone = minst.BoneFindNamed( 'foot_l' );
				boneloc = minst.BoneGetTranslate( footbone, true, false );
				boneloc = minst.MeshToWorldLocation( boneloc );
			}

			// Get the bone.
			bone = minst.BoneFindNamed( ExpandedBones[i] );

			// Get the current scale.
			bonescale = minst.BoneGetScale( bone, false, false );

			// Find and set the alpha to restore.
			if ( ExpandedScales[i] == 0.3 )
				expandfactor = ExpandedScales[i] + sin(ExpandTimeEnd*4)/10;
			else
				expandfactor = ExpandedScales[i];
			alpha = FClamp( (Level.TimeSeconds - ExpandTimeEnd) / 2.0, 0.0, 1.0 );
			expandfactor = Lerp( alpha, expandfactor, 0.0 );
			bonescale *= 1.0 + expandfactor;
			minst.BoneSetScale( bone, bonescale, false );

			// Restore warped children.
			if ( i != 0 )
				EvalExpandedChildrenRestore( minst, bone, alpha );

			if ( alpha == 1.f )
				bExpanding = false;

			// If we changed the pelvis, the foot position will have changed.
			if ( i == 0 )
			{
				// We are expanding, accumulate change.
				boneloc.z += ExpandCounter;
				newboneloc = minst.BoneGetTranslate( footbone, true, false );
				newboneloc = minst.MeshToWorldLocation( newboneloc );
				footdelta = newboneloc.z - boneloc.z;

				rootbone = minst.BoneFindNamed( 'root' );
				rootloc = minst.BoneGetTranslate( rootbone, true, false );
				rootloc.z -= ExpandCounter;
				minst.BoneSetTranslate( rootbone, rootloc, true );

				ExpandCounter += footdelta;
			}

		}
	}

	if ( alpha == 1.f )
	{
		for (i=0; i<6; i++)
			ExpandedScales[i] = 0.0;
	}
}

simulated function bool EvalExpandedChildrenRestore( MeshInstance minst, int bone, float alpha )
{
	local int children, j, child, childdir;
	local vector childscale;
	local name childname;
	local float expandfactor;

	children = minst.BoneGetChildCount( bone );
	for ( j=0; j<children; j++ )
	{
		child = minst.BoneGetChild( bone, j );
		childname = minst.BoneGetName( child );
		if ( (childname == 'eyelid_l') || (childname == 'eyelid_r') ||
			 (childname == 'pupil_l')  || (childname == 'pupil_r') )
			continue;
		if ( j%2 == 0 )
			childdir = 1;
		else
			childdir = -1;
		childscale = minst.BoneGetScale( child, false, false );
		expandfactor = (sin((ExpandTimeEnd*4)+(j*(PI/4)))/5 * childdir);
		expandfactor = Lerp( alpha, expandfactor, 0.0 );
		childscale *= 1.0 - expandfactor;
		minst.BoneSetScale( child, childscale, false );

		EvalExpandedChildrenRestore( minst, child, alpha );
	}
}

function ExpandBone( int BoneIndex )
{
	bExpanding = true;
	SetDamageBone( ExpandedBones[BoneIndex] );
	ExpandedScales[BoneIndex] += 0.001f;
	ExpandTimeRemaining = 6.f;
}


/*-----------------------------------------------------------------------------
	Animation
-----------------------------------------------------------------------------*/

function float UpdateRampingFloat(float inCurrent, float inDesired, float inMaxChange)
{
	if (inCurrent < inDesired)
	{
		inCurrent += inMaxChange;
		if (inCurrent > inDesired)
			inCurrent = inDesired;
	}
	else
	{
		inCurrent -= inMaxChange;
		if (inCurrent < inDesired)
			inCurrent = inDesired;
	}
	return(inCurrent);
}

// Tween	
function TweenToFalling();
function TweenToFighter(float tweentime);
function TweenToRunning(float tweentime) { TweenToFighter(0.1); }
function TweenToWalking(float tweentime) { TweenToRunning(tweentime); }
function TweenToPatrolStop(float tweentime) { TweenToFighter(tweentime); }
function TweenToWaiting(float tweentime) { TweenToFighter(tweentime); }
function TweenToSwimming(float tweentime);

function PlayMovingAttack() { PlayRunning(); } //Note - must restart attack timer when done with moving attack
function PlayPatrolStop() { PlayWaiting(); }

function PlayGutHit(float tweentime) { /*log("Error - play gut hit must be implemented in subclass of"@class);*/ }
function PlayHeadHit(float tweentime) { PlayGutHit(tweentime); }
function PlayLeftHit(float tweentime) { PlayGutHit(tweentime); }
function PlayRightHit(float tweentime) { PlayGutHit(tweentime); }

function PlayBigDeath( class<DamageType> DamageType );
function PlayHeadDeath( class<DamageType> DamageType );
function PlayLeftDeath( class<DamageType> DamageType );
function PlayRightDeath( class<DamageType> DamageType );
function PlayGutDeath( class<DamageType> DamageType );

function PlayVictoryDance() { TweenToFighter(0.1); }
function PlayOutOfWater() { TweenToFalling(); }
function PlayDive();

/**/
function PlayUpdateRotation(int Yaw);
function PlayCrawling();
function PlayCrouching();
function PlayWaiting();
function PlayWalking();
function PlayRunning();
function PlaySwimming(optional ESwimDepth sd);
function PlayFlying();
function PlayTurning(float Yaw);
function PlayJetpacking();
function PlayRopeIdle();
function PlayRopeClimbUp();
function PlayRopeClimbDown();
function PlayLadderIdle();
function PlayLadderClimbUp();
function PlayLadderClimbDown();
function LeftEyeDamageEvent();
function RightEyeDamageEvent();

function PlayToCrawling();
function PlayToWaiting( optional float TweenTime );
function PlayToWalking();
function PlayToRunning();

function PlayRise();
function PlayDuck();

function PlayJump();
function PlayInAir();
function PlayLanded(float impactVel)
{
	local float landVol;
	local int SurfaceIndex;

	// Find the material I just landed on:
	LastWalkMaterial = TraceMaterial( Location-vect(0,0,200), Location, SurfaceIndex );
	
	if((LastWalkMaterial!=none)&&(LastWalkMaterial.default.FootstepLandSound!=none))
		Land=LastWalkMaterial.default.FootstepLandSound;
	else
		Land=default.Land;

	landVol = impactVel/JumpZ;
	PlayOwnedSound(Land, SLOT_Interact, FMin(20, 0.005 * Mass * landVol * landVol));
}

function PlayTopAlertIdle();
function PlayTopRelaxedIdle();

function WpnPlayAuxAnim();
function WpnPlayActivate();
function WpnPlayDeactivated();
function WpnPlayThrow();
function WpnPlayFireStart();
function WpnPlayFire();
function WpnPlayFireStop();
function WpnPlayFireJam();
function WpnPlayAltFireStart();
function WpnPlayAltFire();
function WpnPlayAltFireStop();
function WpnPlayAltFireJam();
function WpnPlayReloadStart();
function WpnPlayReload();
function WpnPlayReloadStop();
function WpnPlayRecoil(float FiringSpeed);
function WpnAuxPlayFire( Weapon AuxWeapon );
function ShieldPlayIdle();
function ShieldPlayUp();
function ShieldPlayDown();
function PlayHoldOneHanded();
function PlayHoldTwoHanded();

function PlayPain(EPawnBodyPart BodyPart, optional bool bShortAnim, optional vector hitLocation );
/**/

function PlayFiring();
function PlayWeaponSwitch(Weapon NewWeapon);

function PlayTakeHit(float tweentime, vector HitLoc, int damage)
{
	local vector X,Y,Z, HitVec, HitVec2D;
	local float dotp;
	
	GetAxes(Rotation,X,Y,Z);
	X.Z = 0;
	HitVec = Normal(HitLoc - Location);
	HitVec2D= HitVec;
	HitVec2D.Z = 0;
	dotp = HitVec2D dot X;

	//first check for head hit
	if ( HitLoc.Z - Location.Z > 0.5 * CollisionHeight )
	{
		if (dotp > 0)
			PlayHeadHit(tweentime);
		else
			PlayGutHit(tweentime);
		return;
	}
	
	if (dotp > 0.71) //then hit in front
		PlayGutHit( tweentime);
	else if (dotp < -0.71) // then hit in back
		PlayHeadHit(tweentime);
	else
	{
		dotp = HitVec dot Y;
		if (dotp > 0.0)
			PlayLeftHit(tweentime);
		else
			PlayRightHit(tweentime);
	}
}

function ReactToJump();

function PlayDying( class<DamageType> DamageType, vector HitLoc )
{
	local vector X,Y,Z, HitVec, HitVec2D;
	local float dotp;

	if ( Velocity.Z > 250 )
	{
		PlayBigDeath( DamageType );
		return;
	}
	
	if ( ClassIsChildOf( DamageType, class'DecapitationDamage' ) )
	{
		PlayHeadDeath(DamageType);
		return;
	}
			
	GetAxes(Rotation,X,Y,Z);
	X.Z = 0;
	HitVec = Normal(HitLoc - Location);
	HitVec2D= HitVec;
	HitVec2D.Z = 0;
	dotp = HitVec2D dot X;

	//first check for head hit
	if ( HitLoc.Z - Location.Z > 0.5 * CollisionHeight )
	{
		if (dotp > 0)
			PlayHeadDeath(DamageType);
		else
			PlayGutDeath(DamageType);
		return;
	}
	
	if (dotp > 0.71) //then hit in front
		PlayGutDeath(DamageType);
	else
	{
		dotp = HitVec dot Y;
		if (dotp > 0.0)
			PlayLeftDeath(DamageType);
		else
			PlayRightDeath(DamageType);
	}
}



/*-----------------------------------------------------------------------------
	String Identifiers
-----------------------------------------------------------------------------*/

// Returns string identifier for the physics enum.
simulated function string GetPhysicsString()
{
    switch( Physics )
    {
    case PHYS_None:
        return "PHYS_None";
        break;
    case PHYS_Walking:
        return "PHYS_Walking";
        break;
    case PHYS_Falling:
        return "PHYS_Falling";
        break;
    case PHYS_Swimming:
        return "PHYS_Swimming";
        break;
    case PHYS_Flying:
        return "PHYS_Flying";
        break;
    case PHYS_Rotating:
        return "PHYS_Rotating";
        break;
    case PHYS_Projectile:
        return "PHYS_Projectile";
        break;
    case PHYS_Rolling:
        return "PHYS_Rolling";
        break;
    case PHYS_Interpolating:
        return "PHYS_Interpolating";
        break;
    case PHYS_MovingBrush:
        return "PHYS_MovingBrush";
        break;
    case PHYS_Spider:
        return "PHYS_Spider";
        break;
    case PHYS_Trailer:
        return "PHYS_Trailer";
        break;
    case PHYS_Rope:
        return "PHYS_Rope";
        break;
    case PHYS_WheeledVehicle:
        return "PHYS_WheeledVehicle";
        break;
	case PHYS_Jetpack:
		return "PHYS_Jetpack";
		break;
    default:
        return "Unknown Physics";
        break;
    }
}

// Returns string identifier for the control state enum.
simulated function string GetControlStateString( optional EControlState StateParm )
{
	local EControlState localState;
	
	if ( StateParm != 0 )
		localState = StateParm;
	else
		localState = ControlState;

	switch ( localState )
	{
	case CS_Normal:
		return "CS_Normal";
		break;
	case CS_Flying:
		return "CS_Flying";
		break;
	case CS_Swimming:
		return "CS_Swimming";
		break;
	case CS_Dead:
		return "CS_Dead";
		break;
	case CS_Spectating:
		return "CS_Spectating";
		break;
	case CS_Stasis:
		return "CS_Stasis";
		break;
	case CS_Rope:
		return "CS_Rope";
		break;
	case CS_Ladder:
		return "CS_Ladder";
		break;
	case CS_Jetpack:
		return "CS_Jetpack";
		break;
	case CS_Frozen:
		return "CS_Frozen";
		break;
    default:
        return "Unknown CS:" @ localState;
        break;
	}
}

// Returns string identifier for the posture state enum.
simulated function string GetPostureStateString()
{
	switch ( PostureState )
	{
	case PS_Standing:
		return "PS_Standing";
		break;
	case PS_Crouching:
		return "PS_Crouching";
		break;
	case PS_Jumping:
		return "PS_Jumping";
		break;
	case PS_Swimming:
		return "PS_Swimming";
		break;
	case PS_Ladder:
		return "PS_Ladder";
		break;
	case PS_Rope:
		return "PS_Rope";
		break;
	case PS_Turret:
		return "PS_Turret";
		break;
	case PS_Jetpack:
		return "PS_Jetpack";
		break;
	case PS_Flying:
		return "PS_Flying";
		break;
    default:
        return "Unknown PS";
        break;
	}
}

// Returns string identifier for the movement state enum.
simulated function string GetMovementStateString()
{
	switch ( MovementState )
	{
	case MS_Waiting:
		return "MS_Waiting";
		break;
	case MS_Walking:
		return "MS_Walking";
		break;
	case MS_Running:
		return "MS_Running";
		break;
	case MS_RopeIdle:
		return "MS_RopeIdle";
		break;
	case MS_RopeClimbUp:
		return "MS_RopeClimbUp";
		break;
	case MS_RopeClimbDown:
		return "MS_RopeClimbDown";
		break;
	case MS_LadderIdle:
		return "MS_LadderIdle";
		break;
	case MS_LadderClimbUp:
		return "MS_LadderClimbUp";
		break;
	case MS_LadderClimbDown:
		return "MS_LadderClimbDown";
		break;
	case MS_Jetpack:
		return "MS_Jetpack";
		break;
	case MS_Flying:
		return "MS_Flying";
		break;
    default:
        return "Unknown MS";
        break;
	}
}

// Returns string identifier for the upper body state enum.
simulated function string GetUpperBodyStateString( optional EUpperBodyState StateParm )
{
	local EUpperBodyState localState;
	
	if ( StateParm != 0 )
		localState = StateParm;
	else
		localState = UpperBodyState;

	switch ( localState )
	{
	case UB_Relaxed:
		return "UB_Relaxed";
		break;
	case UB_Alert:
		return "UB_Alert";
		break;
	case UB_WeaponDown:
		return "UB_WeaponDown";
		break;
	case UB_WeaponUp:
		return "UB_WeaponUp";
		break;
	case UB_Firing:
		return "UB_Firing";
		break;
	case UB_Reloading:
		return "UB_Reloading";
		break;
	case UB_ReloadFinished:
		return "UB_ReloadFinished";
		break;
	case UB_ShieldUp:
		return "UB_ShieldUp";
		break;
	case UB_ShieldDown:
		return "UB_ShieldDown";
		break;
	case UB_ShieldAlert:
		return "UB_ShieldAlert";
		break;
	case UB_Turret:
		return "UB_Turret";
		break;
    case UB_HoldOneHanded:
        return "HoldOneHanded";
        break;
    case UB_HoldTwoHanded:
        return "HoldTwoHanded";
        break;
    default:
        return "Unknown UB State";
        break;
	}
}

// Returns string identifier for the jetpack state enum.
simulated function string GetJetpackStateString()
{
	switch ( JetpackState )
	{
	case JS_None:
		return "JS_None";
		break;
	case JS_Idle:
		return "JS_Idle";
		break;
	case JS_Forward:
		return "JS_Forward";
		break;
	case JS_Backward:
		return "JS_Backward";
		break;
	case JS_Left:
		return "JS_Left";
		break;
	case JS_Right:
		return "JS_Right";
		break;
    default:
        return "Unknown JS State";
        break;
	}
}



/*-----------------------------------------------------------------------------
	Combat
-----------------------------------------------------------------------------*/

simulated function EnterExplosiveArea()
{
	ExplosiveArea++;
}

simulated function ExitExplosiveArea()
{
	ExplosiveArea--;
	if ( ExplosiveArea < 0 )
	{
		ExplosiveArea = 0;
	}
}



/*-----------------------------------------------------------------------------
	AI Stub States
-----------------------------------------------------------------------------*/

function StopMoving();

state Frozen
{
	ignores SeePlayer, TakeDamage, SawEnemy, Bump, HitWall;
 
//	function bool EvalHeadLook() { return true; }
 
//	function bool EvalBlinking() { return true; }
 
	function BeginState()
	{
		AnimRate = 0.0;
		AnimBlend = 1.0;
		DesiredTopAnimBlend = 1.0;
		TopAnimBlend = 0.0;
		TopAnimBlendRate = 5.0; 
		DesiredBottomAnimBlend = 1.0;
		BottomAnimBlend = 0.0;
		BottomAnimBlendRate = 5.0;
	}
 
Begin:
	StopMoving();
}

function bool IsSpectating()
{
	if ( PlayerReplicationInfo == None )
	{
		// Assume we are a spectator for now, since we haven't received out PlayerRep yet
		return true;
	}
	else
	{
		return ( PlayerReplicationInfo.bIsSpectator || PlayerReplicationInfo.bWaitingPlayer );
	}
}

function AddDefaultInventory()
{
}

defaultproperties
{
	PostureState=PS_Standing
	MovementState=MS_Waiting
	ControlState=CS_Normal
	UpperBodyState=UB_Relaxed
	PlayerRestartState=CS_Normal
	AvgPhysicsTime=0.100000
	MaxDesiredSpeed=1.000000
	GroundSpeed=320.000000
	WaterSpeed=200.000000
	AccelRate=500.000000
	JumpZ=385.000000
	MaxStepHeight=25.000000
	AirControl=0.050000
	Visibility=128
	SightRadius=2500.000000
	HearingThreshold=1.000000
	OrthoZoom=40000.000000
	FovAngle=90.000000
	Health=100
	Energy=100
	AttitudeToPlayer=ATTITUDE_Hate
	Intelligence=BRAINS_MAMMAL
	noise1time=-10.000000
	noise2time=-10.000000
	SoundDampening=1.000000
	DamageScaling=1.000000
	NameArticle=" a "
	PlayerReplicationInfoClass=Class'Engine.PlayerReplicationInfo'
	Cash=100.000000
	bCanTeleport=True
	bStasis=True
	bIsPawn=True
	RemoteRole=ROLE_SimulatedProxy
	AnimSequence=Fighter
	bDirectional=True
	Texture=Texture'Engine.S_Pawn'
	SoundRadius=9
	SoundVolume=240
	TransientSoundVolume=2.000000
	bCollideActors=True
	bCollideWorld=True
	bBlockActors=True
	bBlockPlayers=True
	bProjTarget=True
	bRotateToDesired=True
	RotationRate=(Pitch=4096,Yaw=50000,Roll=3072)
	NetPriority=2.000000
	UseDistance=100
	EyeTracking=(RotationRate=(Pitch=0,Yaw=55000,Roll=0),RotationConstraints=(Pitch=0,Yaw=9600,Roll=0))
	HeadTracking=(RotationRate=(Pitch=20000,Yaw=45000,Roll=0),RotationConstraints=(Pitch=8000,Yaw=16000,Roll=0))
	BlinkRateBase=0.6
	BlinkRateRandom=5.0
	BlinkDurationBase=0.150000		// JEP Changed from 0.30 (Matt request)
	BlinkDurationRandom=0.100000	// JEP Changed from 0.05
	BlinkEyelidPosition=(X=1.000000,Y=-0.100000,Z=0.000000)
	BlinkChangeTime=0.150000		// JEP Changed from 0.20
	MeleeDamageMultiplier=1.0

	// Abdomen Pitching
	MaxAbdomenViewPitchUp=4000
	MaxAbdomenViewPitchDown=-5000
	MaxAbdomenPitchUp=4000
	MaxAbdomenPitchDown=-5000

	bTakeDamage=True

	ExpandedBones(0)=pelvis
	ExpandedBones(1)=chest
	ExpandedBones(2)=abdomen
	ExpandedBones(3)=head
	ExpandedBones(4)=bicep_L
	ExpandedBones(5)=bicep_R

	ShrinkTime=1.5

	PeripheralVision=1.000000
	ShrinkRate=0.3
	bNotShrunkAtAll=true

	PelvisRotationScale=0.8
	AbdomenRotationScale=0.4	
	ChestRotationScale=0.4

	// JEP...
	SoundSyncScale_Jaw=0.450000
	SoundSyncScale_MouthCorner=0.095000
	SoundSyncScale_Lip_U=0.700000
	SoundSyncScale_Lip_L=0.450000

	TargetLipBlendPercent=0.85f
	TargetLipBlendRate=0.2f			// Half second to blend in/out of talking
	LipRampSpeed=19.0f
	LipScale=1.50f
	FacialTrack(0)=(CurIndex=-1)
	//FacialTrack(1)=(CurIndex=0,CurTrackBlendDir=1,CurFrameDelay=-1.0f,CurFrameBlend=2.0f)
	//FacialExpressions(0)=(FacialFrame[0]=(AnimName=F_FaceAngerC,Delay=2.0f,BlendTime=0.5f))
	//FacialExpressions(0)=(FacialFrame[1]=(AnimName=F_FaceFearA,Delay=2.0f,BlendTime=0.5f))
	FacialTrack(1)=(CurIndex=-1)

	bFacialNoise = true

	FacialNoise(0)=(BoneName=Head,Type=FNOISE_RotatePitch,Rate=4.0f,Limit=1.65f,PercentStop=0.055f,PercentStart=0.85f,PercentSameDir=0.9f)
	FacialNoise(1)=(BoneName=Head,Type=FNOISE_RotateYaw,Rate=5.0f,Limit=3.4f,PercentStop=0.06f,PercentStart=0.11f,PercentSameDir=0.9f)
	FacialNoise(2)=(BoneName=Head,Type=FNOISE_RotateRoll,Rate=5.0f,Limit=3.4f,PercentStop=0.06f,PercentStart=0.11f,PercentSameDir=0.9f)

	FacialNoise(3)=(BoneName=Brow,Type=FNOISE_TranslateX,Rate=0.4f,Limit=0.15f,PercentStop=0.26f,PercentStart=0.65f,PercentSameDir=0.5f)
	// ...JEP
}