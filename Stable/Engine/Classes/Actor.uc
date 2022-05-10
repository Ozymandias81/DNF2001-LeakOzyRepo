/*-----------------------------------------------------------------------------
	Actor

	Notes:

    Group bools with bools for maximum bit-packing.
	Every () property should have a ?("") description.
	KEEP THIS FILE CLEAN! 
	Every variable you put in here adds to memory overhead.
-----------------------------------------------------------------------------*/
class Actor extends Object
	abstract
	native
	nativereplication;

// Imported data (during full rebuild).
#exec Texture Import File=Textures\S_Actor.pcx    Name=S_Actor    Mips=Off Flags=2
#exec Texture Import File=Textures\S_Obsolete.pcx Name=S_Obsolete Mips=Off Flags=2



/*-----------------------------------------------------------------------------
	Data Types / Enumerations
-----------------------------------------------------------------------------*/

// Identifies a unique convex volume in the world.
struct PointRegion
{
	var zoneinfo Zone;					// Zone.
	var int      iLeaf;					// Bsp leaf.
	var byte     ZoneNumber;			// Zone number.
};

// Travelling from server to server.
enum ETravelType
{
	TRAVEL_Absolute,					// Absolute URL.
	TRAVEL_Partial,						// Partial (carry name, reset server).
	TRAVEL_Relative,					// Relative URL.
};

// Input system states.
enum EInputAction
{
	IST_None,							// Not performing special input processing.
	IST_Press,							// Handling a keypress or button press.
	IST_Hold,							// Handling holding a key or button.
	IST_Release,						// Handling a key or button release.
	IST_Axis,							// Handling analog axis movement.
};

// Input keys.
enum EInputKey
{
/*00*/	IK_None			,IK_LeftMouse	,IK_RightMouse	,IK_Cancel		,
/*04*/	IK_MiddleMouse	,IK_Unknown05	,IK_Unknown06	,IK_Unknown07	,
/*08*/	IK_Backspace	,IK_Tab         ,IK_Unknown0A	,IK_Unknown0B	,
/*0C*/	IK_Unknown0C	,IK_Enter	    ,IK_Unknown0E	,IK_Unknown0F	,
/*10*/	IK_Shift		,IK_Ctrl	    ,IK_Alt			,IK_Pause       ,
/*14*/	IK_CapsLock		,IK_Unknown15	,IK_Unknown16	,IK_Unknown17	,
/*18*/	IK_Unknown18	,IK_Unknown19	,IK_Unknown1A	,IK_Escape		,
/*1C*/	IK_Unknown1C	,IK_Unknown1D	,IK_Unknown1E	,IK_Unknown1F	,
/*20*/	IK_Space		,IK_PageUp      ,IK_PageDown    ,IK_End         ,
/*24*/	IK_Home			,IK_Left        ,IK_Up          ,IK_Right       ,
/*28*/	IK_Down			,IK_Select      ,IK_Print       ,IK_Execute     ,
/*2C*/	IK_PrintScrn	,IK_Insert      ,IK_Delete      ,IK_Help		,
/*30*/	IK_0			,IK_1			,IK_2			,IK_3			,
/*34*/	IK_4			,IK_5			,IK_6			,IK_7			,
/*38*/	IK_8			,IK_9			,IK_Unknown3A	,IK_Unknown3B	,
/*3C*/	IK_Unknown3C	,IK_Unknown3D	,IK_Unknown3E	,IK_Unknown3F	,
/*40*/	IK_Unknown40	,IK_A			,IK_B			,IK_C			,
/*44*/	IK_D			,IK_E			,IK_F			,IK_G			,
/*48*/	IK_H			,IK_I			,IK_J			,IK_K			,
/*4C*/	IK_L			,IK_M			,IK_N			,IK_O			,
/*50*/	IK_P			,IK_Q			,IK_R			,IK_S			,
/*54*/	IK_T			,IK_U			,IK_V			,IK_W			,
/*58*/	IK_X			,IK_Y			,IK_Z			,IK_Unknown5B	,
/*5C*/	IK_Unknown5C	,IK_Unknown5D	,IK_Unknown5E	,IK_Unknown5F	,
/*60*/	IK_NumPad0		,IK_NumPad1     ,IK_NumPad2     ,IK_NumPad3     ,
/*64*/	IK_NumPad4		,IK_NumPad5     ,IK_NumPad6     ,IK_NumPad7     ,
/*68*/	IK_NumPad8		,IK_NumPad9     ,IK_GreyStar    ,IK_GreyPlus    ,
/*6C*/	IK_Separator	,IK_GreyMinus	,IK_NumPadPeriod,IK_GreySlash   ,
/*70*/	IK_F1			,IK_F2          ,IK_F3          ,IK_F4          ,
/*74*/	IK_F5			,IK_F6          ,IK_F7          ,IK_F8          ,
/*78*/	IK_F9           ,IK_F10         ,IK_F11         ,IK_F12         ,
/*7C*/	IK_F13			,IK_F14         ,IK_F15         ,IK_F16         ,
/*80*/	IK_F17			,IK_F18         ,IK_F19         ,IK_F20         ,
/*84*/	IK_F21			,IK_F22         ,IK_F23         ,IK_F24         ,
/*88*/	IK_Unknown88	,IK_Unknown89	,IK_Unknown8A	,IK_Unknown8B	,
/*8C*/	IK_Unknown8C	,IK_Unknown8D	,IK_Unknown8E	,IK_Unknown8F	,
/*90*/	IK_NumLock		,IK_ScrollLock  ,IK_Unknown92	,IK_Unknown93	,
/*94*/	IK_Unknown94	,IK_Unknown95	,IK_Unknown96	,IK_Unknown97	,
/*98*/	IK_Unknown98	,IK_Unknown99	,IK_Unknown9A	,IK_Unknown9B	,
/*9C*/	IK_Unknown9C	,IK_Unknown9D	,IK_Unknown9E	,IK_Unknown9F	,
/*A0*/	IK_LShift		,IK_RShift      ,IK_LControl    ,IK_RControl    ,
/*A4*/	IK_UnknownA4	,IK_UnknownA5	,IK_UnknownA6	,IK_UnknownA7	,
/*A8*/	IK_UnknownA8	,IK_UnknownA9	,IK_UnknownAA	,IK_UnknownAB	,
/*AC*/	IK_UnknownAC	,IK_UnknownAD	,IK_UnknownAE	,IK_UnknownAF	,
/*B0*/	IK_UnknownB0	,IK_UnknownB1	,IK_UnknownB2	,IK_UnknownB3	,
/*B4*/	IK_UnknownB4	,IK_UnknownB5	,IK_UnknownB6	,IK_UnknownB7	,
/*B8*/	IK_UnknownB8	,IK_UnknownB9	,IK_Semicolon	,IK_Equals		,
/*BC*/	IK_Comma		,IK_Minus		,IK_Period		,IK_Slash		,
/*C0*/	IK_Tilde		,IK_UnknownC1	,IK_UnknownC2	,IK_UnknownC3	,
/*C4*/	IK_UnknownC4	,IK_UnknownC5	,IK_UnknownC6	,IK_UnknownC7	,
/*C8*/	IK_Joy1	        ,IK_Joy2	    ,IK_Joy3	    ,IK_Joy4	    ,
/*CC*/	IK_Joy5	        ,IK_Joy6	    ,IK_Joy7	    ,IK_Joy8	    ,
/*D0*/	IK_Joy9	        ,IK_Joy10	    ,IK_Joy11	    ,IK_Joy12		,
/*D4*/	IK_Joy13		,IK_Joy14	    ,IK_Joy15	    ,IK_Joy16	    ,
/*D8*/	IK_UnknownD8	,IK_UnknownD9	,IK_UnknownDA	,IK_LeftBracket	,
/*DC*/	IK_Backslash	,IK_RightBracket,IK_SingleQuote	,IK_UnknownDF	,
/*E0*/  IK_JoyX			,IK_JoyY		,IK_JoyZ		,IK_JoyR		,
/*E4*/	IK_MouseX		,IK_MouseY		,IK_MouseZ		,IK_MouseW		,
/*E8*/	IK_JoyU			,IK_JoyV		,IK_UnknownEA	,IK_UnknownEB	,
/*EC*/	IK_MouseWheelUp ,IK_MouseWheelDown,IK_Unknown10E,UK_Unknown10F  ,
/*F0*/	IK_JoyPovUp     ,IK_JoyPovDown	,IK_JoyPovLeft	,IK_JoyPovRight	,
/*F4*/	IK_UnknownF4	,IK_UnknownF5	,IK_Attn		,IK_CrSel		,
/*F8*/	IK_ExSel		,IK_ErEof		,IK_Play		,IK_Zoom		,
/*FC*/	IK_NoName		,IK_PA1			,IK_OEMClear
};

// Damage Over Time (DOT)
enum EDamageOverTime
{
	DOT_Electrical,
	DOT_Fire,
	DOT_Cold,
	DOT_Poison,
	DOT_Radiation,
	DOT_Biochemical,
	DOT_Water,
	DOT_Burnout,
	DOT_Shrink,
	DOT_Expand,
	DOT_None,
};

// Facial expressions.
// This probably shouldn't be here.  Lights don't have facial expressions.
enum EFacialExpression
{
    FACE_NoChange,
    FACE_Normal,
	FACE_Breathe1,
	FACE_Breathe2,
	FACE_Clenched,
	FACE_Frown,
	FACE_Pain1,
	FACE_Pain2,
	FACE_Roar,
	FACE_AngrySmile,
	FACE_HappySmile,
	FACE_Sneer,
	FACE_Surprise,
	FACE_Scared1
};

// Forward Declared to resolve name case conflicts:
var transient actor	CarriedDecoration;	// Bogus forward name declaration.


/*-----------------------------------------------------------------------------
	Base Actor Flags
-----------------------------------------------------------------------------*/

var(Advanced) const bool	bStatic				?("Does not move or change over time.");
var(Advanced) travel bool	bHidden				?("Is hidden during gameplay.");
var(Advanced) const bool	bNoDelete			?("Cannot be deleted during play.");
var(Advanced) bool			bStasis				?("In StandAlone games, turn off if not in a recently rendered zone turned off if bCanStasis and physics = PHYS_None or PHYS_Rotating.");
var(Advanced) bool			bForceStasis		?("Force stasis when not recently rendered, even if physics not none or rotating.");
var(Advanced) bool			bGameRelevant		?("Always relevant for game.");
var(Advanced) bool			bDebugEvents		?("Show all events this actor is generating.");
var(Advanced) bool			bDebugEventsVerbose ?("Shows all targets that this actor triggers or untriggers.");
var const bool				bDeleteMe;			// Waiting to be conditionally destroyed
var const bool				bDeleting;			// Actor is in the process of being deleted (about to have bDeleteMe set)
var const bool				bDestroyed;			// Actor has been shutdown (ConditonalDestroy has been called)
var transient const bool	bAssimilated;		// Actor dynamics are assimilated in world geometry.
var	bool					bHurtEntry;			// Keep HurtRadius from being reentrant.
var const	  bool			bIsPawn;			// True only for pawns.
var const	  bool			bIsPlayerPawn;		// True only for playerpawns.
var const     bool			bIsMover;			// Is a mover.
var const bool				bIsRenderActor;		// True only for renderactors.


/*-----------------------------------------------------------------------------
	Time / Tick Flags
-----------------------------------------------------------------------------*/

var(Tick) bool				bTickNotRelevant	?("Tick this object only when in the sight radius.");
var(Tick) bool				bTickNotColliding	?("Tick this object only when within collision radius.");
var transient const bool	bTicked;			// Actor has been updated.
var const bool				bAlwaysTick;		// Update even when players-only.



/*-----------------------------------------------------------------------------
	Animation Flags
-----------------------------------------------------------------------------*/

var bool					bAnimByOwner;		// Animation dictated by owner.
var	bool					bClientAnim;



/*-----------------------------------------------------------------------------
	Lighting Flags
-----------------------------------------------------------------------------*/

var transient bool			bLightChanged;		// Recalculate this light's lighting now.
var bool					bDynamicLight;		// Temporarily treat this as a dynamic light.



/*-----------------------------------------------------------------------------
	Movement / Physics Flags
-----------------------------------------------------------------------------*/

var(Movement) bool			bCanTeleport		?("This actor can be teleported.");
var(Movement) bool			bMovable			?("Actor is capable of being moved.");
var(Collision) bool			bCollideWhenPlacing	?("This actor collides with the world when placing.");
var bool					bTrailerSameRotation;// If PHYS_Trailer and true, have same rotation as owner.
var bool					bTrailerPrePivot;	// If PHYS_Trailer and true, offset from owner by PrePivot.
var bool					bForcePhysicsUpdate;// force a physics update for simulated pawns

var(Movement) bool			bTravel				?("Actor is capable of travelling among servers.");
var(Movement) travel bool	bWillTravel			?("The actor will travel to the next map in single player.");
var(Movement) bool			bNeverTravel		?("Teleporters will never try to travel this actor.");
var travel vector			TravelLocation;
var travel rotator			TravelRotation;

// Discard physics in the first three frames.
var int						DiscardedPhysicsFrames;


/*-----------------------------------------------------------------------------
	Renderable Flags
-----------------------------------------------------------------------------*/

var(Display) bool			bAlwaysVisible		?("Do not perform render bound culling or other checks - CURRENTLY BROKEN (do not use)");
var bool					bPortalView;		// Actor is a portal view camera.
var name					PortalViewName;



/*-----------------------------------------------------------------------------
	Networking Flags
-----------------------------------------------------------------------------*/

var(Networking) const bool	bNetTemporary		?("Tear-off simulation in network play.");
var(Networking) const bool	bNetOptional		?("Actor should only be replicated if bandwidth available.");
var bool					bReplicateInstigator;// Replicate instigator to client (used by bNetTemporary projectiles).
var(Networking) bool		bAlwaysRelevant		?("Always relevant for network.");
var bool					bSimFall;			// Dumb proxy should simulate fall.



/*-----------------------------------------------------------------------------
	Editor Flags
-----------------------------------------------------------------------------*/

var(Editor) bool			bHiddenEd			?("Is hidden during editing.");
var(Editor) bool			bDirectional		?("Actor shows direction arrow during editing.");
var(Editor) bool			bEdShouldSnap		?("Snap to grid in editor.");
var(Editor) bool			bNoDrawEditorLines	?("If true, connecting lines like interpolation paths won't be drawn.");
var const bool				bSelected;			// Selected in UnrealEd.
var const bool				bMemorized;			// Remembered in UnrealEd.
var const bool				bHighlighted;		// Highlighted in UnrealEd.
var bool					bEdLocked;			// Locked in editor (no movement or rotation).
var transient bool			bEdSnap;			// Should snap to grid in UnrealEd.
var transient const bool	bTempEditor;		// Internal UnrealEd.



/*-----------------------------------------------------------------------------
	Base Object
-----------------------------------------------------------------------------*/

var const travel Actor		Owner;				// Owner actor.
var const travel Actor		Base;				// Moving brush actor we're standing on.
var const PointRegion		Region;				// Region this actor is in.
var const LevelInfo			Level;				// Level this actor is on.
var transient const Level	XLevel;				// Level object.
var const byte				StandingCount;		// Count of actors standing on this actor.
var const byte				MiscNumber;			// Internal use.
var const byte				LatentByte;			// Internal latent function use.
var const int				LatentInt;			// Internal latent function use.
var const float				LatentFloat;		// Internal latent function use.
var const actor				LatentActor;		// Internal latent function use.
var const actor				Deleted;			// Next actor in just-deleted chain.
var const transient int		CollisionTag, LightingTag, OtherTag, ExtraTag, SpecialTag;
var	bool					bScriptInitialized; // Set to prevent re-initializing of actors spawned during level startup.
var	transient bool			bSpawnInitialized2;

var Actor					Target;				// Actor we're aiming at (other uses as well).
var Pawn					Instigator;			// Pawn responsible for damage.
var Inventory				Inventory;			// Inventory chain.
var const array<Actor>		Touching;			// List of touching actors.

var(Object) state name		InitialState		?("Initial state of the object, uses default if none.");
var(Object) name			Group				?("Editor group this actor is a member of.");
var(Events) name			Tag					?("Actor's tag name.");
var(Events) name			Event				?("The event this actor causes.");
var(Events) bool			GrabTrigger			?("Trigger event whenever player attempts to grab this object.");
var(Movement) name			AttachTag;
var(Events) name			StartingInterpolationPoint;	// Name of the starting path corner.



/*-----------------------------------------------------------------------------
	Timing
-----------------------------------------------------------------------------*/

var(Tick) float				TimeWarp			?("Time dilation per actor. 1.0 is no dilation.");

// Old timer...
var float					TimerRate[6];		// Timer event, 0=no timer.
var const float				TimerCounter[6];	// Counts up until it reaches TimerRate.
var int						TimerLoop[6];		// Timer loops (else is one-shot).

// New timer...
var const array<float>		CallbackTimerRates;
var const array<float>		CallbackTimerCounters;
var const array<int>		CallbackTimerLoops;
var const array<int>		CallbackTimerPointers;

var int						MaxTimers;
var(Tick) float				LifeSpan			?("Force object to die after this many seconds has passed. 0.0 is unlimited lifespan");



/*-----------------------------------------------------------------------------
	Collision
-----------------------------------------------------------------------------*/

// Collision size.
var(Collision) travel float	CollisionRadius		?("Radius of the collision cylinder.");
var(Collision) travel float	CollisionHeight		?("Half the height of the collision cylinder.");

// Collision flags.
var(Collision) travel const bool bCollideActors		?("Actor collides with other actors.");
var(Collision) travel bool		 bCollideWorld		?("Actor collides with the world.");
var(Collision) travel bool		 bBlockActors		?("Actor blocks non-player actors.");
var(Collision) travel bool		 bBlockPlayers		?("Actor blocks player actors.");
var(Collision) travel bool		 bProjTarget			?("Projectiles and traces can hit this actor.");

var(Collision) travel bool		 bMeshLowerByCollision ?("Lower mesh by CollisionHeight instead of by MeshLowerHeight");

var(Collision) bool			bPushByRotation		?("If this actor is a mover, it will push other actors when rotating.");
var(Collision) bool			bCancelPushByRotation ?("This actor will not be allowed to be pushed by a rotating mover.");
var(Collision) float		PushVelocityScale	?("Amount to scale velocity by...");


/*-----------------------------------------------------------------------------
	Physics
-----------------------------------------------------------------------------*/

var(Movement) const vector	Location;			// Actor's location; use Move to set.
var(Movement) const rotator	Rotation;			// Rotation.
var	const coords CoordinateFrame;				// A coordinate frame that could be used instead of rotation.
var const vector			OldLocation;		// Actor's old location one tick ago.
var const vector			ColLocation;		// Actor's old location one move ago.
var(Movement) travel vector	Velocity;			// Velocity.
var travel vector			Acceleration;		// Acceleration.
var(Movement) rotator		CamRotAdjust;		// If the actor is a camera, use this to adjust it.
var(Movement) float			GroundFriction;
var(Movement) bool			bUseCoordinateFrame;

var(Movement) travel const enum EPhysics
{
	PHYS_None,
	PHYS_Walking,
	PHYS_Falling,
	PHYS_Swimming,
	PHYS_Flying,
	PHYS_Rotating,
	PHYS_Projectile,
	PHYS_Rolling,
	PHYS_Interpolating,
	PHYS_MovingBrush,
	PHYS_Spider,
	PHYS_Trailer,
	PHYS_Rope,
	PHYS_WheeledVehicle,
	PHYS_Jetpack,
}							Physics				?("Actor's current physics mode");
var(Movement) bool			PhysNoneOnStop;
var(Movement) bool			bBounce             ?("Bounces when hits ground fast.");
var(Movement) bool			bFixedRotationDir;	// Fixed direction of rotation.
var(Movement) bool			bRotateToDesired;	// Rotate to DesiredRotation.
var(Movement) bool			bRotateByQuat;		// Rotate at RotationRate using a quaternion.
var           bool			bInterpolating;		// Performing interpolating.
var			  const bool	bJustTeleported;	// Used by engine physics - not valid for scripts.
var(Movement) bool			bMoveToDesired;		// NJS: Should I move to desired location?
var(Movement) vector		DesiredLocation;	// NJS: Where to move to.
var(Movement) float			DesiredLocationSeconds;// NJS: How long to get there.
var(Movement) float			Mass;				// Mass of this actor.
var(Movement) float			Buoyancy;			// Water buoyancy.
var(Movement) rotator		RotationRate;		// Change in rotation per second.
var(Movement) rotator		DesiredRotation;	// Physics will rotate pawn to this if bRotateToDesired.
var           float			PhysAlpha;			// Interpolating position, 0.0-1.0.
var           float			PhysRate;			// Interpolation rate per second.
var			  Actor			PendingTouch;		// Actor touched during move which wants to add an effect after the movement completes 
var           Actor			TickBefore;			// If this actor is set, then we should tick it before we tick self
var(Movement) vector		SurfaceForce		?("For conveyor belts.");

// Index to the type of tracehit damage this actor does.
var() enum ETraceHitCategory
{
	TH_Bullet,
	TH_LaserBurn,
	TH_Foot,
	TH_Chainsaw,
	TH_Shrink,
	TH_Freeze,
	TH_NoMaterialEffectBullet,
	TH_Projectile,
	TH_Decoration
}							TraceHitCategory;
var bool					bTraceHitRicochets, bLastRicochet;
var bool					bBeamTraceHit;
var class<HitPackage_Level> HitPackageLevelClass;	// Anything that might TraceShot needs to define this.
var class<HitPackage>		HitPackageClass;
var class<DamageType>		TraceDamageType;
var class<Actor>			WaterSplashClass;


/*-----------------------------------------------------------------------------
	Mounting
-----------------------------------------------------------------------------*/

var			  travel Actor	MountParent;		// Actor this mount is on, none if no mount.
var			  vector		MountPreviousLocation;// previous location of actor, used internally.
var			  rotator		MountPreviousRotation;// previous rotation of actor, used internally.
var			  travel int	MountMeshSurfaceTri;// Dynamic surface mount triangle.
var			  travel vector	MountMeshSurfaceBarys;// Dynamic surface mount barycentric coordinates within triangle.

var(Mounting) enum EMountType
{
	MOUNT_Actor,								// Regular actor mounting, mesh independent (default).
	MOUNT_MeshSurface,							// Mesh surface mounting, uses mesh triangles.
	MOUNT_MeshBone,								// Mesh bone mounting, available with skeletal parents.
}							MountType;

var(Mounting) bool			IndependentRotation;// Rotates independently from mount.
var(Mounting) EPhysics		DismountPhysics;	// Physics to set when this object detaches.
var(Mounting) bool			DestroyOnDismount;	// This actor gets destroyed when dismounted.
var(Mounting) name			MountParentTag;		// Tag of the object to assign my MountParent to.
var(Mounting) travel vector	MountOrigin;		// Origin offset for attachment.
var(Mounting) travel rotator MountAngles;		// Rotation angles for attachment.
// Parent mesh item name (SurfaceMount or Bone model object) to mount to.
// Must be non-None Bone Name for MeshBone mounts, or SurfaceMount name for MeshSurface mounts.
// MeshSurface mounts may use a None item, in which case the dynamic surface mount members above are used.
var(Mounting) travel name	MountMeshItem;
// Tri rotation relative mounting.
var(Mounting) bool			bMountRotationRelative;
var			  rotator		MountRelativeRotation;
var			  bool			bEstablishedRelativeBase;
var			  coords		MountRelativeBase;



/*-----------------------------------------------------------------------------
	Networking
-----------------------------------------------------------------------------*/

enum ENetRole
{
	ROLE_None,									// No role at all.
	ROLE_DumbProxy,								// Dumb proxy of this actor.
	ROLE_SimulatedProxy,						// Locally simulated proxy of this actor.
	ROLE_AutonomousProxy,						// Locally autonomous proxy of this actor.
	ROLE_Authority,								// Authoritative control over the actor.
};
var(Networking) ENetRole	Role				?("The actor's local role.");
var(Networking) ENetRole	RemoteRole			?("The actor's remote role.");
var const transient int		NetTag;
var(Networking) float		NetPriority			?("Higher priorities means update it more frequently.");
var(Networking) float		NetUpdateFrequency	?("How many seconds between net updates.");

// Symmetric network flags, valid during replication only.
var const bool				bNetInitial;		// Initial network update.
var const bool				bNetOwner;			// Player owns this actor.
var const bool				bNetRelevant;		// Actor is currently relevant. Only valid server side, only when replicating variables.
var const bool				bNetSee;			// Player sees it in network play.
var const bool				bNetHear;			// Player hears it in network play.
var const bool				bNetFeel;			// Player collides with/feels it in network play.
var const bool				bSimulatedPawn;		// True if Pawn and simulated proxy.
var const bool				bDemoRecording;		// True we are currently demo recording
var const bool				bClientDemoRecording;// True we are currently recording a client-side demo
var const bool				bClientDemoNetFunc;	// True if we're client-side demo recording and this call originated from the remote.

// Partial replication conditions.
// This is just fucking stupid.  Replication is gay.
var(Networking) bool		bForceCollisionRep; // Forces replication of collision even if actor doesn't collide.
var(Networking) bool		bDontSimulateMotion;// Prevents replication of Location and Rotation on SimulatedProxies.
var(Networking) bool		bDontReplicateSkin; // Prevents replication of the skin variable.
var(Networking) bool		bDontReplicateMesh; // Prevents replication of the mesh variable.



/*-----------------------------------------------------------------------------
	Rendering
-----------------------------------------------------------------------------*/

var(Display) enum EDrawType
{
	DT_None,
	DT_Sprite,
	DT_Mesh,
	DT_Brush,
	DT_RopeSprite,
	DT_VerticalSprite,
	DT_Terraform,
	DT_SpriteAnimOnce,
	DT_StaticMesh,
} DrawType	?("Display type of the actor.");

var(Display) enum ERenderStyle
{
	STY_None,
	STY_Normal,
	STY_Masked,
	STY_Translucent,
	STY_Modulated,		   // NOTE: To use this style, a modulated style MUST be set on the texture itself to work with precaching.
	STY_Translucent2,
	STY_LightenModulate,   // NOTE: To use this style, a modulated style MUST be set on the texture itself to work with precaching.
	STY_DarkenModulate     // NOTE: To use this style, a modulated style MUST be set on the texture itself to work with precaching.
} Style		?("Rendering style of the actor.");

// NJS: Under testing:
// These alpha blend factors must directly correspond to the D3D blending factors, or bad things will happen.
enum EBlendFactor
{
	BLEND_INVALID,			 //=  0,
	BLEND_ZERO,              //=  1,
    BLEND_ONE,               //=  2,
    BLEND_SRCCOLOR,          //=  3,
    BLEND_INVSRCCOLOR,       //=  4,
    BLEND_SRCALPHA,          //=  5,
    BLEND_INVSRCALPHA,       //=  6,
    BLEND_DESTALPHA,         //=  7,
    BLEND_INVDESTALPHA,      //=  8,
    BLEND_DESTCOLOR,         //=  9,
    BLEND_INVDESTCOLOR,      //= 10,
    //BLEND_SRCALPHASAT      //= 11,	// Too dangerous to expose, not all cards support.
    //BLEND_BOTHSRCALPHA     //= 12,    // Obsolete.
    //BLEND_BOTHINVSRCALPHA  //= 13,	// Obsolete.
};

var(Blending) EBlendFactor		SrcBlend	 ?("The source blend factor.  Ignored if BLEND_INVALID set on either this or DstBlend.");
var(Blending) EBlendFactor		DstBlend 	 ?("The dest blend factor.    Ignored if BLEND_INVALID set on either this or SrcBlend.");
var(Blending) float				FactorAlpha  ?("Factor by which to scale vertex alpha, from 0-1");
var(Blending) float				FactorColor  ?("Factor by which to scale vertex color, from 0-1");

var(Display) texture		Sprite				?("Sprite texture if DrawType=DT_Sprite.");
var(Display) travel texture	Texture				?("Misc texture.");
var(Display) travel texture	Skin				?("Special skin or enviro map texture.");
var(Display) travel mesh	Mesh				?("Mesh if DrawType=DT_Mesh.");
var transient meshinstance	MeshInstance;		// CDH: Runtime mesh instance.
var transient meshinstance	LastMeshInstance;	// JEP: Last used MeshInstance for quick access
//var(Display) export StaticMesh	StaticMesh;	// StaticMesh if DrawType=DT_StaticMesh
var transient int			DX8MeshHandle;
var	float					LastRenderTime;

var(Display) bool			bShadowCast			?("Casts shadows.");
var(Display) bool			bShadowReceive		?("Accepts shadows.");

var(Display) bool			bUnlit				?("Lights don't affect actor.");
var(Display) bool			bNoSmooth			?("Don't smooth actor's texture.");
var(Display) bool			bParticles			?("Mesh renderers sprite particles on its vertices instead of its polygons.");
var(Display) bool			bRandomFrame		?("Particles use a random texture from among the default texture and the multiskins textures.");
var(Display) bool			bMeshEnviroMap		?("Environment-map the mesh.");
var(Display) bool			bMeshCurvy			?("Curvy mesh (not functional).");
var(Display) bool			bIgnoreBList;
var(Display) bool			bDontReflect		?("The actor won't be reflected in mirrors.");
var(Display) bool			bOwnerSeeSpecial	?("The actor's owner can only see this actor in special condition.");
var(Display) float			MeshLowerHeight		?("Amount to lower mesh by, if bMeshLowerByCollision is not set");

// Mesh Extent computation.
var(Display) bool			ComputeMeshExtent;	// NJS: Whether to compute the following or not
var vector					MeshLastScreenExtentMin;// NJS: The last computed extent for this mesh.	
var vector					MeshLastScreenExtentMax;// NJS: The last computed extent for this mesh.

// Legend's Render Iterator Stuff
var(Display) class<RenderIterator>	RenderIteratorClass;// Class to instantiate as the actor's RenderInterface.
var transient RenderIterator		RenderInterface;// Abstract iterator initialized in the Rendering engine.

// Mesh Decals
var MeshDecal				MeshDecalLink;		// CDH: First of linked list of mesh decals hung off instance.

var(Display) float			Alpha				?("Actor's display alpha level."); // NJS
var(Display) float			BillboardRotation	?("Billboarded sprite rotation, in radians."); // NJS
var(Display) bool			Bilinear			?("Whether actor uses bilinear filtering or not."); // NJS
var const export model		Brush;				// Brush if DrawType=DT_Brush.
var(Display) travel float	DrawScale			?("Draw scaling factor, 1.0=normal size.");
var vector					PrePivot;			 // Offset from box center for drawing.
var(Display) float			ScaleGlow			?("Multiplies lighting.");
var(Display) byte			AmbientGlow			?("Ambient brightness, or 255=pulsing.");
var(Display) byte			Fatness				?("Mesh fatness distortion, 128 = no distortion.");
var(Display) byte			SkinIndex			?("Model texture index the Skin property refers to."); // CDH



/*-----------------------------------------------------------------------------
	Lighting
-----------------------------------------------------------------------------*/

var(Lighting) bool			AffectMeshes			?("Whether the light affects meshes or not."); // NJS
var(Lighting) bool			bDarkLight				?("Light darkens surroundings instead of brightening them."); // CDH

// Light modulation.
var(Lighting) enum ELightType
{
	LT_None,
	LT_Steady,
	LT_Pulse,
	LT_Blink,
	LT_Flicker,
	LT_Strobe,
	LT_BackdropLight,
	LT_SubtlePulse,
	LT_TexturePaletteOnce,
	LT_TexturePaletteLoop,
	LT_StringLight
}							LightType;

// Spatial light effect to use.
var(Lighting) enum ELightEffect
{
	LE_None,
	LE_TorchWaver,
	LE_FireWaver,
	LE_WateryShimmer,
	LE_Searchlight,
	LE_SlowWave,
	LE_FastWave,
	LE_CloudCast,
	LE_StaticSpot,
	LE_Shock,
	LE_Disco,
	LE_Warp,
	LE_Spotlight,
	LE_NonIncidence,
	LE_Shell,
	LE_OmniBumpMap,
	LE_Interference,
	LE_Cylinder,
	LE_Rotor,
	LE_Unused
}							LightEffect;

var(LightColor) byte		LightBrightness;
var(LightColor) byte		LightHue;
var(LightColor) byte		LightSaturation;

var(Lighting) byte			LightRadius;
var(Lighting) byte			LightPeriod;
var(Lighting) byte			LightPhase;
var(Lighting) byte			LightCone;
var(Lighting) byte			VolumeBrightness;
var(Lighting) byte			VolumeRadius;
var(Lighting) byte			VolumeFog;

var(Lighting) bool			bSpecialLit				?("Only affects special-lit surfaces.");
var(Lighting) bool			bActorShadows			?("Light casts actor shadows.");
var(Lighting) bool			bCorona					?("Light uses Skin as a corona.");

var(Lighting) float			LightStringStart		?("The last time the light string was started.");
var(Lighting) bool			LightStringLoop			?("Whether or not to loop the light string.");
var(Lighting) name			LightString				?("Light string to use when LT_StringLight is set. a=0, z=26");
var(Lighting) name			LightStringRed;
var(Lighting) name			LightStringGreen;
var(Lighting) name			LightStringBlue;

var(Lighting) enum ELightDetail
{
	LTD_Normal,										// Normal default lighting.
	LTD_NormalNoSpecular,							// Normal without expensive gouraud specular computation.
	LTD_Classic,									// Classic Unreal-style lighting.
	LTD_SingleDynamic,								// Lit from a single dynamic light.
	LTD_SingleFixed,								// Lit from a fixed direction.
	LTD_AmbientOnly									// Flat ambient lighting.
} LightDetail;

var(Lighting) int			MaxDesiredActorLights	?("Maximum number of actor lights to apply to this actor.");
var(Lighting) int			MinDesiredActorLights	?("Minimum number of actor lights to apply to this actor.");
var			  int			CurrentDesiredActorLights; // Currently desired actor lights, taking LOD into account

var transient bool			AmbientApproxComptued;	// Whether the below is already computed.
var transient plane			AmbientApprox;			// Approximate Ambient
var transient plane			AmbientApproxPrevious;	// Previous Ambient value.

var transient int			ProjectorFlags;

/*-----------------------------------------------------------------------------
	Animation
-----------------------------------------------------------------------------*/

var			 bool			bAnimFinished;			// Unlooped animation sequence has finished.
var			 bool			bAnimLoop;				// Whether animation is looping.
var			 bool			bAnimNotify;			// Whether a notify is applied to the current sequence.
var(Display) bool			bAnimBlendAdditive		?("Animation uses additive rather than absolute blending.");
var(Display) name			AnimSequence			?("Animation sequence we're playing.");
var(Display) float			AnimFrame				?("Current animation frame, 0.0 to 1.0.");
var(Display) float			AnimRate				?("Animation rate in frames per second, 0=none, negative=velocity scaled.");
var(Display) float			AnimBlend				?("Animation blending factor.");
var          float			TweenRate;				// Tween-into rate.
var          float			AnimLast;				// Last frame.
var          float			AnimMinRate;			// Minimum rate for velocity-scaled animation.
var			 float			OldAnimRate;			// Animation rate of previous animation (= AnimRate until animation completes).
var			 plane			SimAnim;				// Replicated to simulated proxies.
var          bool			bUpdateSimAnim;			// Update the SimAnim field for this actor always
var			 MeshEffect		MeshEffect;				// CDH: Mesh effect actor, none for normal sequences.



/*-----------------------------------------------------------------------------
	Audio
-----------------------------------------------------------------------------*/

// Ambient sound.
var(Sound) byte				SoundRadius				?("Radius of the ambient sound.");
var(Sound) byte				SoundVolume				?("Volume of the ambient sound.");
var(Sound) byte				SoundPitch				?("Pitch shift of the ambient sound. 64=No Shift");
var(Sound) sound			AmbientSound			?("Ambient sound effect attached to actor.");

var transient float			MonitorSoundLevel;		// CDH: Updated by sound system, if a bMonitorSound sound is played.

// Regular sounds.
var(Sound) float			TransientSoundVolume;
var(Sound) float			TransientSoundRadius;
var(Sound) float			TransientSoundPitch;

// Sound slots for actors.
enum ESoundSlot
{
	SLOT_None,
	SLOT_Misc,
	SLOT_Pain,
	SLOT_Interact,
	SLOT_Ambient,
	SLOT_Talk,
	SLOT_Interface,
};

// Music transitions.
enum EMusicTransition
{
	MTRAN_None,
	MTRAN_Instant,
	MTRAN_Segue,
	MTRAN_Fade,
	MTRAN_FastFade,
	MTRAN_SlowFade,
};


/*-----------------------------------------------------------------------------
	Interactivity

	Everything here is a hack.
	Interactivity shouldn't exist at the Actor level.
-----------------------------------------------------------------------------*/
var bool					bCarriedItem;			// being carried, and not responsible for displaying self, so don't replicated location and rotation


/*-----------------------------------------------------------------------------
	Spawn Filter

	Controls what kind of gameplay scenarios to appear in.
-----------------------------------------------------------------------------*/

var(Filter) bool			bDifficulty0			?("Appear in difficulty 0.");
var(Filter) bool			bDifficulty1			?("Appear in difficulty 1.");
var(Filter) bool			bDifficulty2			?("Appear in difficulty 2.");
var(Filter) bool			bDifficulty3			?("Appear in difficulty 3.");
var(Filter) bool			bSinglePlayer			?("Appear in single player.");
var(Filter) bool			bNet					?("Appear in regular network play.");
var(Filter) bool			bNetSpecial				?("Appear in special network play mode.");
var(Filter) float			OddsOfAppearing			?("Chance actor will appear in relevant game modes, between 0.0 and 1.0.");



/*-----------------------------------------------------------------------------
	Replication
-----------------------------------------------------------------------------*/

replication
{
	// Relationships.
	unreliable if( Role==ROLE_Authority )
		Owner, Role, RemoteRole;
	unreliable if( bNetOwner && Role==ROLE_Authority )
		bNetOwner, Inventory;
	unreliable if( bReplicateInstigator && (RemoteRole>=ROLE_SimulatedProxy) && (Role==ROLE_Authority) )
		Instigator;

	// Ambient sound.
	unreliable if( (Role==ROLE_Authority) && (!bNetOwner || !bClientAnim) )
		AmbientSound;
	unreliable if( AmbientSound!=None && Role==ROLE_Authority  && (!bNetOwner || !bClientAnim) )
		SoundRadius, SoundVolume, SoundPitch;
	unreliable if( bDemoRecording )
		DemoPlaySound;

	// Collision.
	unreliable if( Role==ROLE_Authority )
		bCollideActors, bCollideWorld;
	unreliable if( (bCollideActors || bCollideWorld || bForceCollisionRep ) && Role==ROLE_Authority )
		bProjTarget, bBlockActors, bBlockPlayers, CollisionRadius, CollisionHeight;

	// Location.
	unreliable if( !bCarriedItem && (bNetInitial || bDontSimulateMotion || bSimulatedPawn || RemoteRole<ROLE_SimulatedProxy) && Role==ROLE_Authority )
		Location;
	unreliable if( !bCarriedItem && (DrawType==DT_Mesh || DrawType==DT_Brush) && (bNetInitial || bDontSimulateMotion || bSimulatedPawn || RemoteRole<ROLE_SimulatedProxy) && Role==ROLE_Authority )
		Rotation;
	unreliable if( RemoteRole==ROLE_SimulatedProxy )
		Base;

	// Velocity.
	unreliable if( bSimFall || ((RemoteRole==ROLE_SimulatedProxy && (bNetInitial || bSimulatedPawn)) || bIsMover) )
		Velocity;

	// Physics.
	unreliable if( bSimFall || (RemoteRole==ROLE_SimulatedProxy && bNetInitial && !bSimulatedPawn) )
		Physics, Acceleration, bBounce;
	unreliable if( RemoteRole==ROLE_SimulatedProxy && Physics==PHYS_Rotating && bNetInitial )
		bFixedRotationDir, bRotateToDesired, RotationRate, DesiredRotation;

	// Animation. 
	unreliable if( DrawType==DT_Mesh && ((RemoteRole<=ROLE_SimulatedProxy && (!bNetOwner || !bClientAnim)) || bDemoRecording) )
		AnimSequence, SimAnim, AnimMinRate, bAnimNotify, AnimBlend, bAnimBlendAdditive; 

	// Rendering.
	unreliable if( Role==ROLE_Authority )
		bHidden;
	unreliable if( Role==ROLE_Authority )
		Texture, DrawScale, PrePivot, DrawType, AmbientGlow, Fatness, ScaleGlow, bUnlit, Style;
	unreliable if( DrawType==DT_Sprite && !bHidden && Role==ROLE_Authority)
		Sprite;
	unreliable if( !bDontReplicateMesh && DrawType==DT_Mesh && Role==ROLE_Authority )
		Mesh, bMeshEnviroMap;
	unreliable if( !bDontReplicateSkin && DrawType==DT_Mesh && Role==ROLE_Authority )
		Skin;
	unreliable if( DrawType==DT_Brush && Role==ROLE_Authority )
		Brush;

	// Lighting.
	unreliable if( Role==ROLE_Authority )
		LightType;
	unreliable if( LightType!=LT_None && Role==ROLE_Authority )
		LightEffect, LightBrightness, LightHue, LightSaturation,
		LightRadius, LightPeriod, LightPhase,
		VolumeBrightness, VolumeRadius,
		bSpecialLit;

	// Mounting
	unreliable if( Role == ROLE_Authority )
		MountParent, MountMeshSurfaceTri, MountType, IndependentRotation, MountParentTag, 
		MountMeshItem, bMountRotationRelative, MountOrigin, MountAngles;

	// Messages
	reliable if( Role<ROLE_Authority )
		BroadcastMessage, BroadcastLocalizedMessage;

	// NJS: Trigger Related:
	unreliable if( Role < ROLE_Authority )
		GlobalTrigger, GlobalUntrigger;
}

//-----------------------------------------------------------------------------
// natives.

// Execute a console command in the context of the current level and game engine.
native function string ConsoleCommand( string Command, optional bool bAllowExecFuncs, optional bool bExecsOnly );

native static final function MusicPlay(string MusicFilename, optional bool immediete, optional float CrossfadeTime, optional bool Push);

//=============================================================================
// NJS: Misc utility:
native final function name NameForString(string S);

// JEP...
native final function EnumSurfsInRadius(optional vector Center, optional float Radius, optional bool bHitLocationFromSurf, optional int MaxSurfs);
//event EnumSurfsInRadiusCB(int SurfIndex, Texture SurfTex);		// Defined further below
// ...JEP

//=============================================================================
// NJS: Actor speech synthesis:
native final function SpeakText(string S);

//=============================================================================
// Actor error handling.

// Handle an error and kill this one actor.
native(233) final function Error( coerce string S );

//=============================================================================
// General functions.

// Latent functions.
native(256) final latent function Sleep( float Seconds );

// Collision.
native(262) final function SetCollision( optional bool NewColActors, optional bool NewBlockActors, optional bool NewBlockPlayers );
native(283) final function bool SetCollisionSize( float NewRadius, float NewHeight );

// Movement.
native(266) final function bool Move( vector Delta );
native(267) final function bool SetLocation( vector NewLocation );
native(299) final function bool SetRotation( rotator NewRotation );
native(3969) final function bool MoveSmooth( vector Delta );
native final function bool MoveActor(	vector				Delta, 
										optional out float	HitTime, 
										optional out vector HitNormal,
										optional out vector HitLocation,
										optional out actor	HitActor,
										optional bool		bTest,
										optional bool		bNoFail);

native final function bool FindSpot( optional bool	bCheckActors,			// 0 by default
									 optional bool	bAssumeFit);			// 0 by default

native final function bool DropToFloor(	optional float AmountToDrop,			// 1000 by default
										optional bool  bResetOnFailure);		// true by default

native(3971) final function AutonomousPhysics(float DeltaSeconds);
native(3972) final function ForcedGetFrame();

// Relations.
native(298) final function SetBase( actor NewBase );
native(272) final function SetOwner( actor NewOwner );

//=============================================================================
// Animation.

// Animation functions.
native(259) final function PlayAnim( name Sequence, optional float Rate, optional float TweenTime, optional int Channel );
native(260) final function LoopAnim( name Sequence, optional float Rate, optional float TweenTime, optional float MinRate, optional int Channel );
native(294) final function TweenAnim( name Sequence, float Time, optional int Channel );
native(282) final function bool IsAnimating( optional int Channel );
native(292) final function SetAnimGroup( name Sequence, name Group );
native(293) final function name GetAnimGroup( name Sequence );
native(261) final latent function FinishAnim( optional int Channel );
native(263) final function bool HasAnim( name Sequence );
native(257) final function MeshInstance GetMeshInstance();

// Animation notifications.
event AnimEnd(); // CDH: Called when an animation ends on Channel 0 (backward compatibility)
event AnimEndEx(int Channel); // CDH: Called when an animation ends on Channels 1 and above, uses AnimEnd's enable/disable setting
simulated event bool OnEvalBones(int channel); // CDH: Called during mesh channel evaluation, if a sequence is not active on the channel

//=========================================================================
// Physics.

// Physics control.
native(301) final latent function FinishInterpolation();
native(3970) final function SetPhysics( EPhysics newPhysics );

//=============================================================================
// Engine notification functions.

//
// Major notifications.
//
event Spawned();
event Destroyed();
event Expired();
event GainedChild( Actor Other );
event LostChild( Actor Other );
event Tick( float DeltaTime );

//
// Triggers.
//
event Trigger( Actor Other, Pawn EventInstigator );
event UnTrigger( Actor Other, Pawn EventInstigator );
event TriggerBySurface( int SurfaceIndex );
event BeginEvent();
event EndEvent();
event Used( Actor Other, Pawn EventInstigator ) { Trigger( Other, EventInstigator ); }
simulated function ClientUsed( Actor Other, Pawn EventInstigator ) {}

//
// Physics & world interaction.
//
event Timer(optional int TimerNum);
event HitWall( vector HitNormal, actor HitWall );
event Falling();
event Landed( vector HitNormal );
event Stopped();
event StoppedRolling();
event ZoneChange( ZoneInfo NewZone );
event Touch( Actor Other );
event PostTouch( Actor Other ); // called for PendingTouch actor after physics completes
event UnTouch( Actor Other );
event Bump( Actor Other );
event BaseChange();
event Attach( Actor Other );
event Detach( Actor Other );
event KillCredit( Actor Other );
event Actor SpecialHandling(Pawn Other);
event bool EncroachingOn( actor Other );
event PushedByMover(actor Other, vector PushedVelocity);
event EncroachedBy( actor Other );
event InterpolateBegin( actor Other );
event InterpolateEnd( actor Other );
event EndedRotation();

// !BR Examine notifications.
event Examine( Actor Other );
event UnExamine( Actor Other );

event FellOutOfWorld()
{
	SetPhysics(PHYS_None);
	Destroy();
}	

//
// Damage and kills.
//
event KilledBy( pawn EventInstigator );
event TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType );
function EMPBlast( float EMPtime, optional Pawn Instigator );

function SetDamageBone(name BoneName); // CDH

// Bone manipulation.
native final function NativeEvalSlack();

//
// Trace a line and see what it collides with first.
// Takes this actor's collision properties into account.
// Returns first hit actor, Level if hit level, or None if hit nothing.
//
native(277) final simulated function Actor Trace
(
	optional out vector HitLocation,
	optional out vector HitNormal,
	optional vector TraceEnd,
	optional vector TraceStart,
	optional bool bTraceActors,
	optional vector Extent,
    optional bool bMeshAccurate,
    optional out int HitMeshTri,
    optional out vector HitMeshBarys,
    optional out name HitMeshBone,
    optional out texture HitMeshTexture,
	optional out vector HitUV
);


// returns true if did not hit world geometry
native(548) final simulated function bool FastTrace
(
	vector          TraceEnd,
	optional vector TraceStart
);

// return the texture hit, or none.
native final simulated function Texture TraceTexture
(
	vector				TraceEnd,
	optional vector		TraceStart,
	optional texture	NewTexture,		// If I hit a surface with a texture, change it to this if specified and non none
	optional vector		SurfBase,		// !MBR, Returns the base vector of the surface (where U,V is 0,0)
	optional vector		SurfU,			// NJS: Can optionally pull the texture coordinates off the hit as well.
	optional vector		SurfV,
	optional vector		SurfUSize,
	optional vector		SurfVSize,
	optional int		SurfaceIndex,	// (JP) Surface index that was hit
	optional bool		bCalcXY,		// (JP) true if you want to know what x/y location that was hit in texture space
	optional int		x,				// (JP) x location in texture that was hit relative to texture upper-left corner
	optional int		y				// (JP) y location in texture that was hit relative to texture upper-left corner
);

final simulated function class<Material> TraceMaterial( vector EndTrace, vector StartTrace, out int SurfaceIndex )
{
	local texture t;
	local class<Material> m;

	t = TraceTexture( EndTrace,StartTrace,,,,,,,SurfaceIndex );
	if ( t == none )
		return none;

	m = t.GetMaterial();
	if ( m==none )
		return none;

	return m;
}

// BR: Weapon trace.
// GetTraceFireSegment gets the start and end of a weapon trace.
simulated function GetTraceFireSegment( out vector Start, out vector End, out vector BeamStart, optional float HorizError, optional float VertError )
{
}

// Trace fire performs a tracehit.
// Child classes that use this need to implement GetTraceFireSegment()
simulated function TraceFire( Actor HitInstigator, 
				    optional float HorizError, optional float VertError, 
					optional bool bDontPenetrate, optional bool bEffectsOnly,
					optional bool bNoActors, optional bool bNoMeshAccurate,
					optional bool bNoCreationSounds )
{
	local Actor HitActor;
	local vector Direction;
	local vector StartTrace, EndTrace, BeamStart;
	local vector HitLocation, HitNormal;
	local vector BackHitLocation, BackHitNormal;
	local vector HitMeshBarys;
	local int HitMeshTri, HitSurfaceIndex;
	local name HitMeshBone;
	local texture HitMeshTex;
	local PointRegion HitRegion;
	local class<Material> HitMat;
	local float MaxMaterialWidth;
	local int	i;

	if ( !Level.GRI.bMeshAccurateHits )
		bNoMeshAccurate = true;

	// Get the segment we should trace along.
	GetTraceFireSegment( StartTrace, EndTrace, BeamStart, HorizError, VertError );

	// Determine the unit direction of the trace.
	Direction = Normal( EndTrace - StartTrace );

	// Trace out to see what we hit.
	HitActor = Trace( 
		HitLocation, HitNormal, EndTrace, StartTrace, !bNoActors, ,
		!bNoMeshAccurate, HitMeshTri, HitMeshBarys, HitMeshBone, HitMeshTex
		);

	// Hit whatever we hit.
	if ( (HitActor != None) && !bEffectsOnly )
		TraceHit( 
			StartTrace, EndTrace, HitActor, HitLocation, HitNormal, 
			HitMeshTri, HitMeshBarys, HitMeshBone, HitMeshTex, HitInstigator, BeamStart
			);

	// JEP... Glass is penetrable, so keep going... (penetrate up to 4 pieces of glass (counting the first)
	if (HitActor != None && HitActor.IsA('BreakableGlass'))
	{
		MaxMaterialWidth = 5;
		
		for (i=0; i<3; i++)
		{
			StartTrace = HitLocation + (Direction * MaxMaterialWidth);
			
			//if ((StartTrace Dot Direction) > EndDist)		// EndDist = (EndTrace Dot Direction);
			//	break;
			
			HitRegion = GetPointRegion( StartTrace );

			//if (HitRegion.Zone == Level )
			if (HitRegion.iLeaf == -1)
				break;		// If we inside the level, then just stop

			// Find out what we hit on the other side of the glass
			HitActor =	Trace
						( 
							HitLocation, HitNormal, EndTrace, StartTrace, !bNoActors, ,
							!bNoMeshAccurate, HitMeshTri, HitMeshBarys, HitMeshBone, HitMeshTex 
						);

			if (HitActor == None)
				break;		// If we didn't hit anything, then stop
		
			// Hit whatever we hit.
			TraceHit
			(
				StartTrace, EndTrace, HitActor, HitLocation, HitNormal, 
				HitMeshTri, HitMeshBarys, HitMeshBone, HitMeshTex, HitInstigator, BackHitLocation + Direction
			);

			if (!HitActor.IsA('BreakableGlass'))
				break;		// If we didn't hit another piece of glass, then stop
		}
	}
	// ...JEP

	// Find the material if we hit a brush.
	if ( (HitActor != None) && ((HitActor == Level) || HitActor.IsA('Mover')) )
		HitMat = TraceMaterial( EndTrace, StartTrace, HitSurfaceIndex );

	// Hit the material.
	if ( (HitMat != None) && (Level.NetMode != NM_DedicatedServer) )
		HitMaterial( HitMat, TraceHitCategory, HitLocation, HitNormal, !bNoCreationSounds, HitSurfaceIndex );

	// If the material is penetrable, then see if we can penetrate it.
	if ( (HitMat != none) && (HitMat.default.bPenetrable) && !bDontPenetrate && (Level.NetMode != NM_Client) )
	{
		MaxMaterialWidth = 33;
		StartTrace = HitLocation + (Direction * MaxMaterialWidth);
		HitRegion = GetPointRegion( StartTrace );
		
		//if ( HitRegion.Zone != Level )
		if (HitRegion.iLeaf != -1)
		{
			// Ok, now reverse trace the way we came to leave a bullet mark on the other side.
			HitActor = Trace( BackHitLocation, BackHitNormal, HitLocation, StartTrace, true );

			// Hit whatever we hit. ! This hit may not be necessary.
			if ( (HitActor != None) && !bEffectsOnly )
				TraceHit(
					StartTrace, HitLocation, HitActor, BackHitLocation, BackHitNormal, 
					HitMeshTri, HitMeshBarys, HitMeshBone, HitMeshTex, HitInstigator, StartTrace
					);

			// Find the material if we hit a brush.
			if ( (HitActor != None) && ((HitActor == Level) || HitActor.IsA('Mover')) )
			{
				// Get the material for this surface.
				HitMat = TraceMaterial( HitLocation, StartTrace, HitSurfaceIndex );

				// Hit the material.
				if ( (HitMat != none) && (Level.NetMode != NM_DedicatedServer) )
					HitMaterial( HitMat, TraceHitCategory, BackHitLocation, BackHitNormal, !bNoCreationSounds, HitSurfaceIndex );

				// Ok, pick up again on the other side of the wall.
				HitActor = Trace( HitLocation, HitNormal, EndTrace, BackHitLocation + Direction, !bNoActors, ,
					!bNoMeshAccurate, HitMeshTri, HitMeshBarys, HitMeshBone, HitMeshTex );

				// Hit whatever we hit.
				if ( (HitActor != None) && !bEffectsOnly )
					TraceHit(
						BackHitLocation + Direction, EndTrace, HitActor, HitLocation, HitNormal, 
						HitMeshTri, HitMeshBarys, HitMeshBone, HitMeshTex, HitInstigator, BackHitLocation + Direction
						);

				// Hit all the way through.
				if ( (HitActor != None) && ((HitActor == Level) || HitActor.IsA('Mover')) )
				{
					HitMat = TraceMaterial( EndTrace, BackHitLocation + Direction, HitSurfaceIndex );
					if ( (HitMat != none) && (Level.NetMode != NM_DedicatedServer) )
						HitMaterial( HitMat, TraceHitCategory, HitLocation, HitNormal, !bNoCreationSounds, HitSurfaceIndex );
				}
			} // If we didn't hit the level, an actor blocked the shot.
		} // If the HitRegion.Zone is the Level, we hit the void.
	} // If we didn't penetrate, we didn't penetrate.
}

// Performs actual hit logic.
function TraceHit( vector StartTrace, vector EndTrace, Actor HitActor, vector HitLocation, 
				   vector HitNormal, int HitMeshTri, vector HitMeshBarys, name HitMeshBone, 
				   texture HitMeshTex, Actor HitInstigator, vector BeamStart )
{
	local Actor TestHitActor;
	local vector TestHitLocation, TestHitNormal, WaterPoint;
	local HitPackage hit;
	local float HitDamage;

	// JEP... Notify glass we want to break it, if it was part of the trace

	// BR: This is now done as a hitpackage.
	/*
	if (HitActor != None && HitActor.IsA('BreakableGlass'))
	{
		// Notify the glass that we hit it
		BreakableGlass(HitActor).BreakGlass(HitLocation);
		return;
	}
	*/
	// ...JEP

	// 80% chance that we perform near miss l0gic if we hit a wall.
	if ( (HitActor == Level) && (FRand() < 0.8) && (Level.NetMode == NM_Standalone) )
	{
		// Perform an additional trace to see if we had a "near miss"
		TestHitActor = Trace( TestHitLocation, TestHitNormal, EndTrace, StartTrace, true );
		if ( PlayerPawn(TestHitActor) != None )
			TestHitActor.NearMiss();
	}

	if ( IsInWaterRegion(StartTrace) != IsInWaterRegion(HitLocation) )
	{
		WaterPoint = TraceWaterPoint( StartTrace, HitLocation );
		spawn( WaterSplashClass,,,WaterPoint );
	}
//	else if ( IsInWaterRegion(StartTrace) )
//	{
//		// We started in water, create a bubble trace.
//		StartTrace = Owner.Location + CalcDrawOffset() + (FireOffset.X) * X + (FireOffset.Y+8) * Y + (FireOffset.Z-6) * Z;
//		Trail = spawn(class'BubbleTrail',,,StartTrace,PawnOwner.ViewRotation);
//	}

	// Perform extended processing if we don't hit the level and didn't hit ourselves.
	if ( (HitActor != None) && (HitActor != Self) && (HitActor != Owner) && (HitActor != Level) )
	{
		// Set a fake mesh hit bone if we aren't in mesh accurate hit mode.
		if ( !Level.GRI.bMeshAccurateHits )
		{
			if ( HitLocation.Z - HitActor.Location.Z > 0.7 * HitActor.CollisionHeight )
				HitMeshBone = 'head';
			else
				HitMeshBone = 'chest';
		}

		// Calculate the damage.
		HitDamage = GetHitDamage( HitActor, HitMeshBone );

		// Set the damage bone and hurt the target.
		HitActor.TakeHitDamage( HitLocation, HitNormal, HitMeshTri, HitMeshBarys, HitMeshBone, HitMeshTex, HitDamage, HitInstigator, TraceDamageType, normal(EndTrace - StartTrace) );

		// Setup the hit effect.
		SpawnHitPackage( hit, HitActor, HitLocation );
		FillHitPackage( hit, HitDamage, Pawn(Owner), StartTrace, BeamStart );
		DeliverHitPackage( hit );
	}
	else if ( HitActor == Level )
	{
		// Setup the hit effect.
		SpawnHitPackage( hit, Level, HitLocation );
		FillHitPackage( hit, 0, Pawn(Owner), StartTrace, BeamStart );
		DeliverHitPackage( hit );
	}
}

function NearMiss();

simulated function int GetHitDamage( actor Victim, name BoneName )
{
	return 0;
}

function TakeHitDamage( vector HitLocation, vector HitNormal,
						int HitMeshTri, vector HitMeshBarys, name HitMeshBone, 
						texture HitMeshTex, float HitDamage, Actor HitInstigator,
						class<DamageType> HitDamageType, vector HitMomentum )
{
	SetDamageBone( HitMeshBone );
//	if ( bDecapitates && (Pawn(Other) != None) && (Pawn(Other).GetPartForBone(HitMeshBone) == BODYPART_Head) )
//		DmgType = class'DecapitationDamage';
	TakeDamage( HitDamage, Pawn(HitInstigator), HitLocation, HitMomentum, HitDamageType );
	SetDamageBone( 'None' );
}

simulated function class<HitPackage> GetHitPackageClass( vector HitLocaiton )
{
	return HitPackageClass;
}

function SpawnHitPackage( out HitPackage hit, Actor HitOwner, vector HitLocation )
{
	local class<HitPackage> HitClass;

	if ( (HitOwner == Level) || HitOwner.IsA('Mover') )
		HitClass = HitPackageLevelClass;
	else
		HitClass = HitOwner.GetHitPackageClass( HitLocation );
	if ( HitClass == None ) 
	{
		Log("Failed to spawn hit package.  No HitClass specified.  HitOwner:"@HitOwner@"HitActor:"@Self);
		return;
	}
	hit = spawn( HitClass, HitOwner,, HitLocation );
	if ( hit == None )
	{
		Log("Failed to spawn hit package.  Unknown reason.");
	}
}

function FillHitPackage( HitPackage hit, float HitDamage, Pawn HitInstigator, vector StartTrace, vector BeamStart )
{
	if ( hit == None )
		return;

	// Tell the hit package to play a richochet if needed.
	if ( hit.Owner == Level )
	{
		if ( bTraceHitRicochets && !bLastRicochet && (FRand() < 0.2) )
		{
			bLastRicochet = true;
			hit.bRicochet = true;
		}
		else if ( bLastRicochet )
			bLastRicochet = false;

		// We only used the owner as the level for this check.
		// Make the owner none, so we can trace hit the level.
		hit.SetOwner( None );
	}

	// Set the stats.
	hit.HitDamage		= HitDamage;
	hit.ShotOriginX		= StartTrace.X;
	hit.ShotOriginY		= StartTrace.Y;
	hit.ShotOriginZ		= StartTrace.Z;
	hit.TraceOriginX	= BeamStart.X;
	hit.TraceOriginY	= BeamStart.Y;
	hit.TraceOriginZ	= BeamStart.Z;
	hit.bTraceBeam		= bBeamTraceHit;
	hit.Instigator		= HitInstigator;
	hit.TraceHitCategory = TraceHitCategory;

	// Deco stuff.
	if ( hit.IsA('HitPackage_Decoration') )
		HitPackage_Decoration(hit).DecoHealth = Decoration(hit.Owner).Health;
}

function DeliverHitPackage( HitPackage hit )
{
	if ( hit == None )
		return;

	// Deliver the package right away on the authortative side.
	if ( Role == ROLE_Authority )
		hit.Deliver();
}

final simulated function HitMaterial( class<Material> m, int DamageCategory, vector HitLocation, vector HitNormal, bool bPlayCreationSounds, int SurfaceIndex )
{
	local Actor a;
	local Texture SurfaceTexture;
	local name SurfaceName;
	local int i, j;

	// Create a wall hit effect.
	if ( m.default.DamageCategoryEffect[DamageCategory].HitEffect != none )
	{
		a = spawn( m.default.DamageCategoryEffect[DamageCategory].HitEffect,,, HitLocation+HitNormal, rotator(HitNormal) );
		if ( (SoftParticleSystem(a) != None) && bPlayCreationSounds )
			SoftParticleSystem(a).PlayCreationSounds();

		// Play hit sounds.
		/*
		for ( i=0; i<4; i++ )
		{
			if ( m.default.HitSounds[i] != None )
				j++;
		}
		a.PlaySound( m.default.HitSounds[Rand(j)], SLOT_Interact, 1.0 );
		*/
		if ( m.default.DamageCategoryEffect[DamageCategory].HitSounds[0] != None )
			a.PlaySound( m.default.DamageCategoryEffect[DamageCategory].HitSounds[0], SLOT_Interact, 1.0 );
	}

	// Perform surface specific behavior.
	if ( SurfaceIndex != 0 )
	{
		// Swap texture.
		SurfaceTexture = GetSurfaceTexture( SurfaceIndex );
		if ( (SurfaceTexture != None) && (SurfaceTexture.ChangeTextureOnHit != None) )
			SetSurfaceTexture( SurfaceIndex, SurfaceTexture.ChangeTextureOnHit );

		// Trigger surface event on hit.
		if ( m.default.TriggerSurfEventOnHit )
		{
			SurfaceName = FindNameForSurface( SurfaceIndex );
			if ( SurfaceName != '' )
			{
				GlobalTrigger( SurfaceName,, Level );
				if ( m.default.TriggerSurfEventOnce )
					SetSurfaceName( SurfaceIndex, '' );
			}
		}
	}
}

// BR: Water trace.
native final function PointRegion GetPointRegion( vector TestPoint );
native final function bool IsInWaterRegion( vector TestPoint );
native final function vector TraceWaterPoint( vector StartTrace, vector EndTrace );

// NJS: Raw surface manipulation primitives:
native final function int FindSurfaceByName( name SurfaceTag,	optional int After );
native final function name FindNameForSurface( int SurfaceIndex );
native final function SetSurfacePan( int SurfaceIndex, optional int panU, optional int panV );
native final function int GetSurfaceUPan( int SurfaceIndex );
native final function int GetSurfaceVPan( int SurfaceIndex );
native final function texture GetSurfaceTexture( int SurfaceIndex );
native final function SetSurfaceTexture( int SurfaceIndex,	texture NewTexture );
native final function SetSurfaceName( int SurfaceIndex, name NewName );
native final function RenameAllSurfaces( name OldName, name NewName );

// BR: Mesh surface manipulation primitives:
native final simulated function texture MeshGetTexture( int TextureNum );

//
// Spawn an actor. Returns an actor of the specified class, not
// of class Actor (this is hardcoded in the compiler). Returns None
// if the actor could not be spawned (either the actor wouldn't fit in
// the specified location, or the actor list is full).
// Defaults to spawning at the spawner's location.
//
native(278) final function actor Spawn
(
	class<actor>      SpawnClass,
	optional actor	  SpawnOwner,
	optional name     SpawnTag,
	optional vector   SpawnLocation,
	optional rotator  SpawnRotation
);

//
// Destroy this actor. Returns true if destroyed, false if indestructable.
// Destruction is latent. It occurs at the end of the tick.
//
native(279) final function bool Destroy();

//=============================================================================
// Timing.

// Causes Timer() events every NewTimerRate seconds.
native(280) final function SetTimer( float NewTimerRate, bool bLoop, optional int TimerNumber );
native final function SetTimerCounter( int TimerNumber, int NewTimerCounter );
native final simulated function SetCallbackTimer( float NewTimerRate, bool bLoop, name FunctionCallback );
native final simulated function EndCallbackTimer( name FunctionCallback );

// Callbacks
native final simulated function CallFunctionByName( name CallbackName );

//=============================================================================
// Sound functions.

// Play a sound effect.
native(264) final function PlaySound
(
	sound				Sound,
	optional ESoundSlot Slot,
	optional float		Volume,
	optional bool		bNoOverride,
	optional float		Radius,
	optional float		Pitch,
    optional bool       bMonitorSound
);
native(265) final function StopSound( ESoundSlot Slot );

// play a sound effect, but don't propagate to a remote owner
// (he is playing the sound clientside
native simulated final function PlayOwnedSound
(
	sound				Sound,
	optional ESoundSlot Slot,
	optional float		Volume,
	optional bool		bNoOverride,
	optional float		Radius,
	optional float		Pitch,
    optional bool       bMonitorSound,
    optional bool       bClientOnly    // set to true if you don't want the sound propogated to anyone else
);

native simulated event DemoPlaySound
(
	sound				Sound,
	optional ESoundSlot Slot,
	optional float		Volume,
	optional bool		bNoOverride,
	optional float		Radius,
	optional float		Pitch,
    optional bool       bMonitorSound
);

// Get a sound duration.
native final simulated function float GetSoundDuration( sound Sound );

// For use with windowing system.
simulated function ESoundSlot GetSlotForInt( int inSlot )
{
	switch ( inSlot )
	{
		case 0:
			return SLOT_None;
			break;
		case 1:
			return SLOT_Misc;
			break;
		case 2:
			return SLOT_Pain;
			break;
		case 3:
			return SLOT_Interact;
			break;
		case 4:
			return SLOT_Ambient;
			break;
		case 5:
			return SLOT_Talk;
			break;
		case 6:
			return SLOT_Interface;
			break;
	}

	return SLOT_None;
}

//=============================================================================
// AI functions.

//
// Inform other creatures that you've made a noise
// they might hear (they are sent a HearNoise message)
// Senders of MakeNoise should have an instigator if they are not pawns.
//
native(512) final function MakeNoise( float Loudness );

//
// PlayerCanSeeMe returns true if some player has a line of sight to 
// actor's location.
//
native(532) final function bool PlayerCanSeeMe();

//=============================================================================
// Regular engine functions.

// Teleportation.
event bool PreTeleport( Teleporter InTeleporter );
event PostTeleport( Teleporter OutTeleporter );

// Level state.
event BeginPlay();

//========================================================================
// Disk access.

// Find files.
native(539) final function string GetMapName( string NameEnding, string MapName, int Dir );
native(545) final function GetNextSkin( string ParentNames[4], string CategoryName, string CurrentSkin, int Dir, out string SkinName, out string SkinDesc );
native(547) final function string GetURLMap();
native final function string GetNextInt( string ClassName, int Num );
native final function GetNextIntDesc( string ClassName, int Num, out string Entry, out string Description );
native final function GetNextThing( string ThingClass, string BaseClass, string CurrentThing, int Dir, out string ThingName, out string ThingDesc, out string ExtraData );
native final function GetNextClass( string BaseCharacterClass, string CurrentCharacterClass, int Dir, out string CharacterClass, out string ClassDesc );
native final function GetNextMDSMap( string MapList, string CurrentMap, int Dir, out string MapName, out string MapDesc );
native final function GetNextMDSMapList( string GameClass, string CurrentMapList, int Dir, out string MapList, out string MapListDesc );
native final function GetSkinList( string CategoryName, string ParentNames[4], out string SkinNames[32], out string SkinDescs[32] );


//=============================================================================
// Iterator functions.

// Iterator functions for dealing with sets of actors.
native(304) final iterator function AllActors     ( class<actor> BaseClass, out actor Actor, optional name MatchTag );
native(305) final iterator function ChildActors   ( class<actor> BaseClass, out actor Actor );
native(306) final iterator function BasedActors   ( class<actor> BaseClass, out actor Actor );
native(307) final iterator function TouchingActors( class<actor> BaseClass, out actor Actor );
native(309) final iterator function TraceActors   ( class<actor> BaseClass, out actor Actor, out vector HitLoc, out vector HitNorm, vector End, optional vector Start, optional vector Extent );
native(310) final iterator function RadiusActors  ( class<actor> BaseClass, out actor Actor, float Radius, optional vector Loc );
native(311) final iterator function VisibleActors ( class<actor> BaseClass, out actor Actor, optional float Radius, optional vector Loc );
native(312) final iterator function VisibleCollidingActors ( class<actor> BaseClass, out actor Actor, optional float Radius, optional vector Loc, optional bool bIgnoreHidden );

//=============================================================================
// Mail functions.
native final function bool SendMailMessage(	string				Rcpt,			// Must have a rcpt
											optional string		Message,		// Defaults to "I was born to rock the world!"
											optional string		Subject,		// Defaults to "Message From Duke Nukem"
											optional string		Sender,			// Defaults to current email addr, or dukenukem@3drealms.com
											optional string		SMTPServer);	// Defaults to current SMTP server

//=============================================================================
//	Player Profile
native final function string	GetCurrentPlayerProfile();
native final function bool		ProfileSwitchNeedsReLaunch(string PlayerName);
native final function bool		SwitchToPlayerProfile(string PlayerName);
native final function bool		CreatePlayerProfile(string PlayerName);
native final function bool		DestroyPlayerProfile(string PlayerName);
native final function string	GetNextPlayerProfile(string Start);

//=============================================================================
//	Parental lock
native final function bool		SetParentalLockPassword(string OldPassword, string NewPassword);
native final function bool		ValidateParentalLockPassword(string Password);
native final function bool		SetParentalLockStatus(bool bParentalLockOn, string Password);
native final function bool		ParentalLockIsOn();

//=============================================================================
//	Save/Load

native final function bool		LoadGame(	ESaveType	Type, 
											int			Num);
native final function bool		SaveGame(	ESaveType	Type,
											int			Num,
											string		Description, 
											texture		Screenshot);
native final function bool		DeleteSavedGame(ESaveType	Type, 
												int			Num);
native final function int		GetNumSavedGames(ESaveType	Type);
native final function bool		GetSavedGameInfo(	ESaveType		Type,
													int				Num, 
													out string		Description, 
													out int			Month,
													out int			Day,
													out int			DayOfWeek,
													out int			Year,
													out int			Hour,
													out int			Minute,
													out int			Second);
native final function bool		GetSavedGameLongInfo(	ESaveType	Type,
														int			Num, 
														out string	LocationName, 
														out int		NumSaves, 
														out int		NumLoads, 
														out float	TotalGameTimeSeconds,
														out texture Screenshot);

//=============================================================================
//	Screenshot
native final function texture	ScreenShot(bool bNoMenus);
native final function bool		ScreenShotIsValid();

//=============================================================================
// Color operators FIXME MOVE TO OBJECT
native(549) static final operator(20)  color -     ( color A, color B );
native(550) static final operator(16) color *     ( float A, color B );
native(551) static final operator(20) color +     ( color A, color B );
native(552) static final operator(16) color *     ( color A, float B );

//=============================================================================
// Scripted Actor functions.

// draw on canvas before flash and fog are applied (used for drawing weapons)
event RenderOverlays( canvas Canvas );

//
// Called immediately before gameplay begins.
//
event PreBeginPlay()
{
	// Handle autodestruction if desired.
	if( !bGameRelevant && (Level.NetMode != NM_Client) && !Level.Game.IsRelevant(Self) )
		Destroy();
}

//
// Broadcast a message to all players.
//
event BroadcastMessage( coerce string Msg, optional bool bBeep, optional name Type )
{
	local Pawn P;

	if (Type == '')
		Type = 'Event';

	if ( Level.Game.AllowsBroadcast(self, Len(Msg)) )
		for( P=Level.PawnList; P!=None; P=P.nextPawn )
			if( P.IsA('PlayerPawn') )
				P.ClientMessage( Msg, Type, bBeep );
}

//
// Broadcast a localized message to all players.
// Switch is the message number
// Most message deal with 0 to 2 related PRIs.
// The LocalMessage class defines how the PRI's and optional actor are used.
//
event BroadcastLocalizedMessage
( 
    class<LocalMessage> Message,
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject,
	optional class<Actor> OptionalClass
)
{
	local Pawn P;

	for ( P=Level.PawnList; P != None; P=P.nextPawn )
    {
		if ( P.IsA('PlayerPawn') )
        {
			P.ReceiveLocalizedMessage( Message, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject, OptionalClass );
        }
    }
}

//
// Called immediately after gameplay begins.
//
simulated event PostBeginPlay()
{	
	if ( MountParent == none )
		AttachToParent(); // NJS: Attach to my parent:
	
	// NJS: Attach to path
	if ( StartingInterpolationPoint != '' )
		AttachToPath( StartingInterpolationPoint, true );

//	Disable( 'Tick' );
}

//
// Called after PostBeginPlay.
//
simulated event SetInitialState()
{
	bScriptInitialized = true;
	if( InitialState!='' )
		GotoState( InitialState );
	else
		GotoState( 'Auto' );
}

//
// Called after initial network update.
//
simulated event PostNetInitial()
{
}

simulated event PostNetReceive()
{
}

// JEP...
event EnumSurfsInRadiusCB(int SurfIndex, Texture SurfTex, vector HitLocation, vector SurfNormal)
{
	local class<Material>	Mat;	

	// Perform surface specific behavior.
	if (SurfTex != None)
	{
		//BroadcastMessage(self@": HitSurface: "@SurfTex);
		Mat = SurfTex.GetMaterial();

		if ((Mat != None) && (Level.NetMode != NM_DedicatedServer) )
			HitMaterial(Mat, TraceHitCategory, HitLocation, SurfNormal, true, SurfIndex);
	}
}
// ...JEP

//
// Hurt actors within the radius.
// CDH: augmented for directional cone support
//
final function HurtRadius ( 
	float DamageAmount, 
	float DamageRadius, 
	class<DamageType> DamageType, 
	float Momentum, 
	vector HitLocation,
	optional bool bDirectional, 
	optional vector Direction, 
	optional float DirectionAngleLimit, /* degrees 0 - 180 */ 
	optional bool bDontEnumSurfs
	)
{
	local actor Victims;
	local float DamageScale, dist, directionalScale;
	local vector dir;
	local bool directionalSkip;
	
	if( bHurtEntry )
		return;

	if ( bDirectional )
	{
		Direction = Normal(Direction);
		DirectionAngleLimit = cos(DirectionAngleLimit * pi / 180.0);
	}

	bHurtEntry = true;
	foreach VisibleCollidingActors( class 'Actor', Victims, DamageRadius, HitLocation )
	{
		// JEP...
		if (Victims.IsA('BreakableGlass'))
		{
			//BroadcastMessage("Glass Explode");
			BreakableGlass(Victims).ReplicateBreakGlass( HitLocation, true, DamageRadius );
		}
		// ...JEP

		if ( (Victims != self) && (Victims.bCollideActors) )
		{
			dir = Victims.Location - HitLocation;
            if (bDirectional)
            {
                directionalScale = Normal(dir) dot Direction;
                directionalSkip = (directionalScale < DirectionAngleLimit);
            }
            else
                directionalSkip = False;
            if (!directionalSkip)
            {
			    dist = FMax(1,VSize(dir));
			    dir = dir/dist; 
			    DamageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);
                if (bDirectional)
                    DamageScale *= Abs(directionalScale);
			    Victims.TakeDamage
			    (
				    DamageScale * DamageAmount,
				    Instigator, 
				    Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
				    (DamageScale * Momentum * dir),
				    DamageType
			    );
            }
		} 
	}

	// JEP: Trigger all surfaces in radius of this impact point (unless told NOT to)
	if (!bDontEnumSurfs)
		EnumSurfsInRadius(HitLocation, DamageRadius);		

	bHurtEntry = false;
}

//
// Called when carried onto a new level, before AcceptInventory.
//
event TravelPreAccept();

//
// Called when carried into a new level, after AcceptInventory.
//
event TravelPostAccept();

//
// Called when a scripted texture needs rendering
//
event RenderTexture(ScriptedTexture Tex);

//
// Called by PlayerPawn when this actor becomes its ViewTarget.
//
function BecomeViewTarget();

//
// Returns the string representation of the name of an object without the package
// prefixes.
//
function String GetItemName( string FullName )
{
	local int pos;

	pos = InStr(FullName, ".");
	While ( pos != -1 )
	{
		FullName = Right(FullName, Len(FullName) - pos - 1);
		pos = InStr(FullName, ".");
	}

	return FullName;
}

// NJS: Assorted exciting utility functions:
event GlobalTrigger( name TriggerEvent, optional Pawn Instigator, optional actor Other )
{
	local actor A, otherActor;

	if(Other!=none) otherActor=Other;
	else            otherActor=self;

	// Make sure event is valid 
	if( TriggerEvent != '' )
	{
		if(bDebugEvents)
			BroadcastMessage("GlobalTrigger: "$Tag$", Event:"$TriggerEvent);
		//bDebugEventsVerbose 

		// Trigger all actors with matching triggers 
		foreach AllActors( class 'Actor', A, TriggerEvent )		
		{
			if(Instigator!=none)
				A.Trigger( otherActor, Instigator );
			else
				A.Trigger( otherActor, self.Instigator );
		}
	}
}

final function GlobalUntrigger( name TriggerEvent, optional Pawn Instigator )
{
	local actor A;
	
	/* Make sure event is valid */
	if( TriggerEvent != '' )
	{
		if(bDebugEvents)
			BroadcastMessage("GlobalUntrigger: "$Tag$", Event:"$TriggerEvent);

		/* Trigger all actors with matching triggers */
		foreach AllActors( class 'Actor', A, TriggerEvent )		
		{
			if(Instigator!=none)
				A.Untrigger( self, Instigator );
			else
				A.Untrigger( self, self.Instigator );
		}
	}
}

// Returns true if two rectangles overlap, false if not.
final function bool RectanglesOverlap(int left, int top, int right, int bottom, int left1, int top1, int right1, int bottom1)
{
	if(right<left1) return false;
	if(left>right1) return false;
	if(bottom<top1) return false;
	if(top>bottom1) return false;
	return true;	
}

// Returns the actor corresponding to the class and tag:
simulated final function actor FindActorTagged(class<actor> FindClass, name FindTag)
{
	local actor a, result;

	if (FindClass==None || FindTag=='None')
		return None;
	result = None;
	foreach AllActors(FindClass, a, FindTag)
	{
		result = a;
		break;
	}
	return result;
}

simulated function DebugWatchBegin(DebugView D)
{
    D.AddWatch("Class");
    D.AddWatch("Name");
    D.AddWatch("Tag");
    D.AddWatch("Event");
    D.AddWatch("Role");
    D.AddWatch("RemoteRole");
    D.AddWatch("bNetOwner");
    D.AddWatch("MountParent");
    D.AddWatch("DrawType");
    D.AddWatch("DrawScale");
    D.AddWatch("Mesh");
    D.AddWatch("Sprite");
    D.AddWatch("AnimSequence");
    D.AddWatch("AnimFrame");
    D.AddWatch("AnimRate");
    D.AddWatch("Physics");
    D.AddWatch("Location");
    D.AddWatch("Rotation");
    D.AddWatch("Velocity");
    D.AddWatch("CollisionRadius");
    D.AddWatch("CollisionHeight");
}
simulated function bool DebugWatchExtra(DebugView D, int Index, out string S)
{
    local int Depth;

    if (Index > 0)
        return(false);

    Depth = GetStateDepth() - 1;
    S = "  State: ";
    while (Depth >= 0)
    {
        S = S$GetStateName(Depth);
        if (Depth > 0)
            S = S$".";
        Depth--;
    }
    return(true);
}
simulated function DebugWatchEnd(DebugView D)
{
}

// Set the display properties of an actor.  By setting them through this function, it allows
// the actor to modify other components (such as a Pawn's weapon) or to adjust the result
// based on other factors (such as a Pawn's other inventory wanting to affect the result)
function SetDisplayProperties(ERenderStyle NewStyle, texture NewTexture, bool bLighting, bool bEnviroMap )
{
	Style = NewStyle;
	texture = NewTexture;
	bUnlit = bLighting;
	bMeshEnviromap = bEnviromap;
}

function SetDefaultDisplayProperties()
{
	Style = Default.Style;
	texture = Default.Texture;
	bUnlit = Default.bUnlit;
	bMeshEnviromap = Default.bMeshEnviromap;
}

// NJS: Compute the optimal direction of rotation from current to desired:
simulated function int RotationDistance( int current, int desired )
{   
	local int result;

	result=0;
	
	if (current > desired)
	{
		if (current - desired < 32768)
			result -= (current - desired);
		else
			result += (desired + 65536 - current);
	}
	else
	{
		if (desired - current < 32768)
			result += (desired - current);
		else
			result -= (current + 65536 - desired);
	}
	     
	return result;
}

// NJS: Returns the angle from location to FocalPoint
final function rotator AngleTo( vector loc, vector focalPoint )
{
	return rotator(focalPoint-loc);	
}

// NJS: Converted from engine code:
final function int AddAngleConfined(int Angle, int Delta, int MinThresh, int MaxThresh )
{
	if( Delta < 0 )
	{
		if ( Delta<=-65536 || Delta<=-((Angle-MinThresh)&65535))
			return MinThresh;
	}
	else if( Delta > 0 )
	{
		if( Delta>=65536 || Delta>=((MaxThresh-Angle)&65535))
			return MaxThresh;
	}
	return ((Angle+Delta)&65535);
}

// NJS: A couple of useful functions for setting up rotation taking 
// the possibility the object is mounted into account:
function RotateTo( rotator RotateTo, optional bool RelativeRotation, optional float Seconds)
{
	if(!bool(Seconds))
	{
		if(bool(MountParent))
		{
			if(RelativeRotation)
				MountAngles=MountAngles+RotateTo;
			else
				MountAngles=RotateTo;
		}
		else
		{
			// If this is relative rotation, add in the original position. 
			if(RelativeRotation) 
				SetRotation(Rotation+RotateTo);			
			else 
				// This is absolute rotation, just set the rotation. 			
				SetRotation(RotateTo);
		
			// Make sure I snap to the rotation: 
			DesiredRotation=Rotation;	
			bRotateToDesired=false; 

		}
		
		RotationRate.yaw=0;
		RotationRate.pitch=0;
		RotationRate.roll=0;
	} 
	/************** Set up temporal Rotation: ********************/	
	else 
	{
		if(bool(MountParent))
		{
			DesiredRotation=RotateTo;

			if(RelativeRotation)
				DesiredRotation+=MountAngles;
			
			if(DesiredRotation!=MountAngles)
			{		
				RotationRate.yaw=Abs(RotationDistance(MountAngles.yaw,DesiredRotation.yaw))/Seconds;
				RotationRate.pitch=Abs(RotationDistance(MountAngles.pitch,DesiredRotation.pitch))/Seconds;
				RotationRate.roll=Abs(RotationDistance(MountAngles.roll,DesiredRotation.roll))/Seconds;			
				bRotateToDesired=true; // Make DesiredRotation valid. 
				bFixedRotationDir=false;			
			} 

		} else
		{
			DesiredRotation=RotateTo;

			if(RelativeRotation)
				DesiredRotation+=Rotation;
			
			if(DesiredRotation!=Rotation)
			{		
				RotationRate.yaw=Abs(RotationDistance(Rotation.yaw,DesiredRotation.yaw))/Seconds;
				RotationRate.pitch=Abs(RotationDistance(Rotation.pitch,DesiredRotation.pitch))/Seconds;
				RotationRate.roll=Abs(RotationDistance(Rotation.roll,DesiredRotation.roll))/Seconds;			
				bRotateToDesired=true; /* Make DesiredRotation valid. */
				bFixedRotationDir=false;			
			} 

		}
	}

}

simulated function int FixedTurn(int inCurrent, int inDesired, int inMaxChange, optional out int outDelta)
{
	local int result, delta;

	inCurrent = inCurrent & 65535;
	if (inMaxChange==0)
		return(inCurrent);
	inDesired = inDesired & 65535;
	inMaxChange = int(Abs(inMaxChange));
	
	if (inCurrent > inDesired)
	{
		if ((inCurrent - inDesired) < 32768)
			delta = -Min((inCurrent - inDesired), inMaxChange);
		else
			delta = Min(((inDesired + 65536) - inCurrent), inMaxChange);
	}
	else
	{
		if ((inDesired - inCurrent) < 32768)
			delta = Min((inDesired - inCurrent), inMaxChange);
		else
			delta = -Min(((inCurrent + 65536) - inDesired), inMaxChange);
	}
	outDelta = delta;
	inCurrent += delta;
	return(inCurrent);
}

// NJS: Attach an object to an interpolation point:
final function AttachToPath( name PathName, optional bool TeleportTo )
{
	local InterpolationPoint i;

	foreach AllActors( class 'InterpolationPoint', i, PathName)
	{
		if(TeleportTo)
			SetLocation(i.Location);

		// Hmmm....
		Target = i;
		//SetCollision(false,false,false);
		SetPhysics(PHYS_Interpolating);
		PhysRate = 1.0;
		PhysAlpha = 0.0;
		bInterpolating = true;
		break;
	}
}

native final function vector GetMountLocation( name Mount );
native final function SetToMount( name MountItem, Actor MountParent, Actor Mount, optional vector MountOffset );

simulated final function AttachActorToParent( actor Other, optional bool MatchLocation, optional bool MatchRotation )
{
	local actor a;

	MountParent = Other;
	if ( MountParent != none )
	{
		MountParentTag = Other.tag;

		if ( MatchLocation )
		{
			MountOrigin.X = 0;
			MountOrigin.Y = 0;
			MountOrigin.Z = 0;
		} 
		else if ( MountType == MOUNT_Actor )
		{
			MountOrigin = (Location - MountParent.Location) << MountParent.Rotation;
		}
		if ( MatchRotation )
		{ 
			MountAngles.Yaw = 0;
			MountAngles.Pitch = 0;
			MountAngles.Roll = 0;
		}
		else if ( MountType == MOUNT_Actor )
		{
			MountAngles = Rotation - MountParent.Rotation;
		}

		MountPreviousLocation = Location;
		MountPreviousRotation = Rotation;
	}
	else
	{
		MountParentTag = '';
	}
}

event CalcView(out vector CameraLocation, out rotator CameraRotation);

// NJS: Function to attach an object to it's tagged parent.
final function AttachToParent( optional name ParentName, optional bool MatchLocation, optional bool MatchRotation )
{
	local name MyParentName;
	local actor a;

	
	if(ParentName=='') MyParentName=MountParentTag;
	else MyParentName=ParentName;
	
	//Log("Tag:"$Tag$" MyParentName:"$MyParentName$" MountParentTag:"$MountParentTag);
	if(MyParentName=='') return;	// I'm not attached to anyone

	
	// Attach to my parent:
	foreach AllActors( class 'Actor', a, MyParentName)
	{
		AttachActorToParent(a,MatchLocation,MatchRotation);
		break;					// Only attach to first object
	}
}

// Quick utility functions for dealing with variables:
// I wish these could go in the variable class, but tim doesn't allow static members.

// Finds a given variable, given only it's name.
final function Variable FindVariableByName( name VariableName )
{
	local variable v;
	
	if(VariableName=='') 	// If I was passed an empty name, ignore.
		return none;	
	
	foreach allactors(class'variable',v,VariableName)
	{
		return v;	// Found one, return it.
	}
	
	return none;	// Didn't find any variables.
}

// Gets a variable by name, and returns it's value.  If it doesn't exist, DefaultValue
// is returned.
final function int GetVariableValue( name VariableName, optional int DefaultValue )
{
	local variable v;
	
	v=FindVariableByName(VariableName);	// Look up the variable.
	if(v==none) return DefaultValue;	// Didn't find the variable, return default value.
	return v.Value;						// Return the variable value.
}

// Sets a variable to a given value.
final function SetVariableValue( name VariableName, optional int Value )
{
	local variable v;
	
	if(VariableName!='')
		foreach allactors(class'variable',v,VariableName)
		{
			v.SetValue(Value);
		}	
}

// NJS: Input hook callback function, primarilly used in subcalsses:
function InputHook(out float aForward,out float aLookUp,out float aTurn,out float aStrafe,optional float DeltaTime)
{
}

// JP: Key event functions (called when a key is pressed, or when an input device does something)
event bool KeyType( EInputKey Key )
{
	return false;
}

event bool KeyEvent( EInputKey Key, EInputAction Action, FLOAT Delta )
{
	return false;		// Don't handle by default, let the console get it
}

function color VEC_HSVToRGB(Vector inHSV)
{
	local float h, s, v, m, n, f;
	local int i;
	
	h = inHSV.X*6.0f;	
	s = inHSV.Y;	
	v = inHSV.Z;
	
	if (s == 0.0f)
		return(NewColor(v,v,v));
		
	i = int(h);
	f = h - i;
	if ((i & 1) == 0)
		f = 1.0f - f;
	m = v * (1.0f - s);
	n = v * (1.0f - s*f);

	switch(i)  {
		case 6: 
		case 0:  return(NewColor(v,n,m));
		case 1:  return(NewColor(n,v,m));
		case 2:  return(NewColor(m,v,n));
		case 3:  return(NewColor(m,n,v));
		case 4:  return(NewColor(n,m,v));
		case 5:  return(NewColor(v,m,n));
		default: return(NewColor(0,0,0));
	}
}

function Vector VEC_RGBToHSV(color inRGB)
{
	local float r, g, b, v, x, f;
	local Vector vecResult;
	local int i;
	
	//Get values into range from 0.0-1.0
	r = inRGB.R / 255.0;	
	g = inRGB.G / 255.0;	
	b = inRGB.B / 255.0;
	
	x = FMin( r, FMin(g, b));
	v = FMax( r, FMax(g, b));
	
	vecResult.X = 0;
	vecResult.Y = 0;
	vecResult.Z = v;
	
	if(v == x)		 
		return vecResult;
	
	if(r == x)  	 {	f = g - b;	i = 3;	}
	else if(g == x)  {	f = b - r;	i = 5;	}
	else		 	 {	f = r - g;	i = 1;	}
	
	vecResult.X = (i-f / (v-x)) / 6.0f;
	vecResult.Y = (v-x) / v;
//	vecResult.Z = v;
	return vecResult;
}

function color NewColor(float fR, float fG, float fB)
{	
	local color C;
	//Get values out from range 0.0-1.0 to 0-255
	C.R = fR * 255;
	C.G = fG * 255;
	C.B = fB * 255;
	return C;
}

// Interface for mulitplayer viewmapper's that can interdict bFire messages to server.
simulated function bool CanSendFire() { return true; }
simulated function bool CanSendAltFire() { return true; }
// Interface for mulitplayer viewmapper's that removes control.
simulated function Relinquish() {}

defaultproperties
{
     bMovable=True
     Role=ROLE_Authority
     RemoteRole=ROLE_DumbProxy
     bDifficulty0=True
     bDifficulty1=True
     bDifficulty2=True
     bDifficulty3=True
     bSinglePlayer=True
     bNet=True
     bNetSpecial=True
     OddsOfAppearing=1.000000
     DrawType=DT_Sprite
     Style=STY_Normal
     Texture=Texture'Engine.S_Actor'
     DrawScale=1.000000
     ScaleGlow=1.000000
     Fatness=128
     SoundRadius=32
     SoundVolume=128
     SoundPitch=64
     TransientSoundVolume=1.000000
     TransientSoundPitch=1.000000
     CollisionRadius=22.000000
     CollisionHeight=22.000000
     bJustTeleported=True
     Mass=100.000000
     NetPriority=1.000000
     NetUpdateFrequency=100.000000
	 TimeWarp=1.000000
	 bTickNotRelevant=True
	 AffectMeshes=True
	 Alpha=1.000
	 Bilinear=false
	 BillboardRotation=0.000
     bMeshLowerByCollision=True
	 MaxTimers=4
	 bIgnoreBList=false
	 LightDetail=LTD_SingleDynamic
	 MaxDesiredActorLights=3
	 MinDesiredActorLights=1
	 CurrentDesiredActorLights=3
	 Bilinear=True
	 PhysNoneOnStop=false
	 TraceHitCategory=TH_Bullet
	 bTraceHitRicochets=false
	 bBeamTraceHit=false
	 TraceDamageType=class'BulletDamage'
	 PushVelocityScale=1.0
	 bShadowCast=true
	 bShadowReceive=true
	 SrcBlend=BLEND_INVALID
	 DstBlend=BLEND_INVALID
	 FactorAlpha=1.0
	 FactorColor=1.0
}
