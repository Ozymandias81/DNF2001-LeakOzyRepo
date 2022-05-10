//=============================================================================
// HumanNPC.uc
//=============================================================================
class HumanNPC expands AIPawn
	abstract;

#exec OBJ LOAD FILE=..\Textures\m_characters.dtx
#exec OBJ LOAD FILE=..\sounds\a_impact.dfx PACKAGE=A_Impact
#exec OBJ LOAD FILE=..\Textures\m_fx.dtx

var			float				DuckCollisionHeight;
var			float				OriginalCollisionHeight;
var			float				DestinationCollisionHeight;
var			float				CollisionHeightTime;
var			float				CollisionHeightStartTime;		

var( AIStartup ) float HeadCreeperOdds ?("Chance a HeadCreeper will appear, between 0.0 and 1.0, if Human is snatched.");

var( AIStartup ) float WakeRadius;
var dnDecoration MyRope;
var AIClimbControl MyClimbControl;
var( AIStartup ) bool bPanicOnFire;
/*-----------------------------------------------------------------------------
	Stuff to override NPC looking around.
-----------------------------------------------------------------------------*/
var( AIStartup ) float	LookInterval;
var( AIStartup ) bool	bFixedPosition;
var( AIStartup ) bool	bSleepAttack;

var float LastLookTime;
var actor NoiseInstigator;
var bool bLookingAround;
var bool bNoLookAround;
var bool bForceNoLookAround;
var float OldPeripheralVision;
var( AIStartup ) bool bPatrolIgnoreSeePlayer;
var( AIStartup ) bool bIdleSeeFriendlyMonsters	?("If true, pawn will look at and notice friendly idle non-players.");
var( AIStartup ) bool bIdleSeeFriendlyPlayer	?("If true, pawn will look at and notice friendly player.");

var float TempHeadFactor, TempChestFactor, TempAbdomenFactor;	// Temporary weights applied to bones.

/*-----------------------------------------------------------------------------
	Following related variables
-----------------------------------------------------------------------------*/
var( AIFollowing ) bool		bStopWhenReached	?("Leaves the following state when follow actor reached." );
var( AIFollowing ) float	FollowOffset		?("Maximum distance from follow actor to be considered reached." );
var( AIFollowing ) name		FollowTag			?("Tag of who to follow." );
var( AIFollowing ) bool		bWalkFollow			?("Toggles walking or running when following target." );
var( AIFollowing ) bool		bWanderAfterFollow	?("Transitions to wandering state when following state exits.");

var actor FollowActor;

/*-----------------------------------------------------------------------------
	Suffering State related variables
-----------------------------------------------------------------------------*/
var bool bSuffering;
var( AIStartup ) float SufferFrequency			?("Odds for suffering.");

/*-----------------------------------------------------------------------------
	Human skeleton specialist flags
-----------------------------------------------------------------------------*/
var( AIStartup ) bool		bSniper				?("This pawn will be a sniper.");
var( AIStartup ) bool	  	bShieldUser			?("Don't set this flag on regular guys.");
var( AIPatrolling )	name	StartPatrolEvent	?("Trigger this event when this pawn starts to patrol. Good for toggling FocalPoints on.");
var( AIPatrolling ) name	EndPatrolEvent		?("Trigger this event when this pawn exits the patrol state. Good for toggling FocalPoints off.");
var( AIShieldUser ) int		MaxShots			?("Max shots a shield user will take before holding up shield.");
var( AIShieldUser ) int		MinShots			?("Min shots a shield user will take before holding up shield.");

var EDFShield	MyShield;						// Shield that belongs to shield user.
var bool		bKnockedBack;					// Used for EDFHeavyWeps.
var int			ShieldShotCount;				// Used for determining when to kneel for shieldusers.
var NavigationPoint	FinalPatrolPoint;
		
/*-----------------------------------------------------------------------------
	Cowering State related variables
-----------------------------------------------------------------------------*/
var bool bCoweringDisabled;
var float LastCowerTime;

/*-----------------------------------------------------------------------------
	Cover related variables
-----------------------------------------------------------------------------*/
var NavigationPoint		NearestHidingSpot;
//var CornerPoint			MyCornerPoint;
var bool				bUsingCover;
var NavigationPoint		MyCoverPoint;
var bool				bEmergencyDeparture;
var float				JumpTimer;
var bool				bCanEmergencyJump;
var bool				bAtDuckPoint;


/*-----------------------------------------------------------------------------
	Death and Damage handling
-----------------------------------------------------------------------------*/
var( AIStartup ) int		LegHealthLeft		?("Used in determining when this pawn should limp.");
var( AIStartup ) int		LegHealthRight		?("Used in determining when this pawn should limp.");
var( AIStartup ) float		PainInterval		?("Min interval between playing pain animations.");
var( AIStartup ) bool		bNPCInvulnerable	?("I'm invulnerable! Grrr!");
var( AIStartup ) bool		bSneakAttack		?("If snatched & not aggressive, I will attack when enemy turns away from me.");
var bool					bDamagedByShotgun;	
var Actor					ShotgunInstigator;	
var Pawn					KilledByPawn;
var rotator					KillerRotation;
var bool					bArmless;
var float					LastPain;
var bool					bNoPain;
var bool					bEyesShut;

// Info (mounting offsets, etc. for the HeadCreeper to use)
struct SHeadCreeperInfo
{
	var() Texture		HeadTex;
	var() vector		MountOrigin;
	var() rotator		MountAngles;
};

var() SHeadCreeperInfo HeadCreeperInfo;

/*-----------------------------------------------------------------------------
	NPC Orders & Startup Info
-----------------------------------------------------------------------------*/
enum ENPCOrders
{
	ORDERS_Idle,
	ORDERS_Wander,
	ORDERS_Patrol,
	ORDERS_Defend,
	ORDERS_Follow,
	ORDERS_Retreat
};

var( AIStartup ) name SpecialWalkAnim;
var( AIStartup ) name SpecialRunAnim;
	
var( AIStartup ) ENPCOrders		NPCOrders;				// Current orders for this NPC.
var( AIStartup ) float			AggressionDistance;		// NPC won't be aggressive until within range.
var( AIStartup ) bool			bReuseIdlingAnim;	// Should I use this idling anim everytime I enter the state?

var( AIStartup ) EFacialExpression	FacialExpression;		// Initial facial expression.
var( AIStartup ) int				FacialExpressionIndex;	// Initial facial expression index.
var( Orders )  name					Orders;					// orders a bot is carrying out << JC: TBD >>

var bool		bAtCoverPoint;

// NPC Weapon arming info. 
struct SNPCWeaponInfo
{
	var() string		WeaponClass;
	var() int			PrimaryAmmoCount;
	var() int			AltAmmoCount;
};
var( AI ) float TimeBetweenCrouching;
var( AI ) float TimeBetweenStanding;

const MaxCarriedWeapons = 8;							// NPC can only carry 8 weapons.
var( AIStartup ) SNPCWeaponInfo WeaponInfo[ 9 ];

/*-----------------------------------------------------------------------------
	NPC/Creature Tracking
-----------------------------------------------------------------------------*/
struct SCreatureTrackingInfo
{
	var() float		TrackTimer;				// variable-used timer counted down to zero at tick time
	var() rotator	Rotation;				// current rotation of the tracking angle
	var() rotator	DesiredRotation;		// desired rotation of the tracking angle
	var() rotator	RotationRate;			// maximum rate of rotation toward desired
	var() rotator	RotationConstraints;	// rotation limits to clamp to
	var() float		Weight;					// current weight of tracking rotation against default forward angle, 1.0 is full tracking, 0.0 is no tracking
	var() float		DesiredWeight;			// desired weight of tracking angle
	var() float		WeightRate;				// maximum rate of change toward desired weight
};
var SCreatureTrackingInfo EyeTracking;
var SCreatureTrackingInfo HeadTracking;
var bool bTurning;

/*-----------------------------------------------------------------------------
	Combat Related
-----------------------------------------------------------------------------*/
var			  float			FireTimer;
var			  float			TimeBetweenBursts;
var			  bool			bWeaponFireDisabled;
var( Combat ) float			TimeBetweenAttacks;		// seconds - modified by difficulty
var( Combat ) float			Aggressiveness;			//0.0 to 1.0 (typically)
var( Combat ) float			RefireRate;
var( Combat ) bool			bLeadTarget;			// lead target with projectile attack << JC: TBD >>
var	          float			BaseAggressiveness; 
var			  bool			bCanFire;				//used by TacticalMove and Charging states
var		  	  bool			bCanDuck;
var			  bool			bFiringPaused;
var			  bool			bFrustrated;
var			  Actor			OldEnemy;
var	      	  bool			bNovice;		// << JC >> TBD
var			  bool			bThreePlus;		// high skill novice
var			  bool			bClearShot;
var			  bool			bDevious;
var			  bool			bMustHunt;
var			  Weapon		EnemyDropped;
var class<Weapon>			FavoriteWeapon;
var			  float			Accuracy;
var			  float			LastPainTime;
var			  float			LastAcquireTime;
var			  Ambushpoint	AmbushSpot;
var			  float			BaseAlertness;
var			  vector		RealLastSeenPos;
var()		  int			AmmoMode;

var			  Actor			TroubleMaker;
var			  float			AimAdjust;
var			  float			LastWeaponSwitchTime;

var			  bool			bSightlessFire;			// Will continue firing after line of sight is lost.
var			  float			SightlessFireTime;		// Used to track how long firing will continue.
var			  float			LeftoverFireTimer;

// Melee Combat variables
var( AIStartup )	float	PunchDamage;
var( AIStartup )	float	KickDamage;
var					bool	bMeleeMode;
var					int		NPCFaceNum;
var					int		RehuntCount;
var					float	LastSwitchTime;
var					int		SGReloadCount;

/*-----------------------------------------------------------------------------
	Movement/Animation Related
-----------------------------------------------------------------------------*/
var bool			bReloading;
var bool			bRangeDodging;
var bool			bRearming;
var bool			bSwitchSoundOn;
var float			CrouchTime;
var bool			bCrouchShiftingDisabled;
var bool			bLimpingLeft;
var bool			bLimpingRight;
var bool			bBackPeddling;
var bool			bWalkMode;
var bool			bHeadBlownOff;
var bool			bShortPains;			// use short pain animations instead of long ones.
var	bool			bStrafeDir;
var	bool			bSpecialGoal;
var	float			WalkingSpeed;
var	float			StrafingAbility;
var	int				numHuntPaths;
var bool			bTacticalDir;			// used during movement between pathnodes
var	bool			bCrouching;
var float			LastInvFind;
var	bool			bSpecialPausing;
var NavigationPoint BlockedPath;
var vector			JumpDestination;
var AlternatePath	AlternatePath;			//used by game AI for team games with bases  << JC >> TBD
var float			TacticalOffset;
var vector			ThreatLocation;
var bool			bCanTurn;

/*-----------------------------------------------------------------------------
	NPC Enemy Acquisition Info
-----------------------------------------------------------------------------*/
var( AIAcquisition )	float	PostAcquisitionDelay	?( "After acquisition state is done, I will sleep for this duration." );
var( AIAcquisition )	float	PreAcquisitionDelay		?( "Before I talk, animate, or play an acquisition sound I will sleep for this duration." );
var( AIAcquisition )	Name	AcquisitionTopAnim		?( "Special top channel animation played when enemy first acquired." );
var( AIAcquisition )	Name	AcquisitionBottomAnim	?( "Special bottom channel animation played when enemy first acquired." );
var( AIAcquisition )	Name	AcquisitionAllAnim		?( "Special all channel animation played when enemy first acquired." );
var( AIAcquisition )	Sound	AcquisitionSound		?( "Sound/speech played when enemy first acquired." );

var					bool	bAcquisitionComplete;
var					bool	bLoopAcquisitionAnim;

/*-----------------------------------------------------------------------------
	NPC Speech/Conversations
-----------------------------------------------------------------------------*/
enum EMouthExpression
{
	MOUTH_Normal,
	MOUTH_Smile,
	MOUTH_Frown,
};

enum EBrowExpression
{
	BROW_Normal,
	BROW_Raised,
	BROW_Lowered,
};

var EMouthExpression	MouthExpression;
var EBrowExpression		BrowExpression;

struct ESpeechInfo
{
	var() bool				RetainNoTorsoTracking;
	var() bool				RetainHeadTracking;
	var() bool				bCannotLookAround;
	var() float				LookAroundInterval;
	var() float				PauseBeforeSpeech;
	var() bool				bNoHeadTracking;
	var() bool				bNoTorsoTracking;
	var() sound				Sound;
	var() float				SoundVolume;
	var() Name				TopAnim;
	var() Name				BottomAnim;
	var() Name				AllAnim;
	var() bool				bWillNotTurn;
	var() float				TurnFactorHead			?("Optional override to control head rotation extent.");
	var() float				TurnFactorChest			?("Optional override to control chest rotation extent.");
	var() float				TurnFactorAbdomen		?("Optional override to control abdomen rotation extent.");
	var() bool				bLoopAllAnim			?("Loop the all channel animation.");
	var() name				FaceDispatcherTag		?("Tag of associated FaceDispatcher (TBD)");
	var bool				bAlreadyUsed;
	var bool				bRandomUsed;
	var() float				PauseBeforeAnim			?("Time to pause before playing the animation.");
	var() EFacialExpression FacialExpression		?("Optional facial expression.");
	var() EFacialExpression	ExitFacialExpression	?("Facial expression when finished conversation." );
	var() bool				bNoExitDelay			?("Timer is set for duration of wav + 1 second normally. This removes the 1 second additional pause." );
	var() bool				bUseFaceAsDefault		?("When done conversation keep the new facial expression.");
	var() bool				bLoopFaceAnim			?("Whether or not to loop the face animation.");
	var() int				FacialExpressionIndex	?("Index into the pawn class's facial expression array. (-1 = No Expression)");
	var() int				ExitFacialExpressionIndex ?("Facial expression when finished conversation. (-1 = No Expression)" );
};
var( AIStartup ) bool		bJumpCower				?("This pawn will cower if the player jumps nearby.");
var( AIStartup ) ESpeechInfo CriticalSpeech[ 32 ];
var( AIStartup ) ESpeechInfo IdleSpeech[ 32 ];
var ESpeechInfo		CurrentSpeechInfo;
var bool			bCanSpeak;
var Actor			SpeechTarget;
var bool			bCanExitConversation;
var bool			bCanSayPinDownPhrase;
var bool			bNotifiedByFriends;		 // My friends have warned me of danger.					  
var EDFSpeechCoordinator SpeechCoordinator;

/*-----------------------------------------------------------------------------
	Sound event related (Much of this TBD)
-----------------------------------------------------------------------------*/
var(Sounds) sound 	drown;
var(Sounds) sound	breathagain;
var(Sounds) sound	HitSound3;
var(Sounds) sound	HitSound4;
var(Sounds)	Sound	Deaths[6];
var(Sounds) sound	GaspSound;
var(Sounds) sound	UWHit1;
var(Sounds) sound	UWHit2;
var(Sounds) sound   LandGrunt;
var(Sounds) sound	JumpSound;

/*-----------------------------------------------------------------------------
	Snatched NPC/Tentacles
-----------------------------------------------------------------------------*/
var int		MultiSkinsCounter;		// Used for cycling between gradually snatched face/body textures.
var bool	bUseSnatchedEffectsDone;
var bool	bUseSnatchedEffects;

enum ETentacleAttack
{
	TENTACLE_Thrust,
	TENTACLE_Slash,
};

var ETentacleAttack TentacleAttackType;

// Potential aggressive and damage-displaying tentacles.
var Tentacle MyMouthTentacle, MyShoulderTentacle1, MyShoulderTentacle2, MyTemporaryTentacle;
var TentacleSmall MiniTentacle1, MiniTentacle2, MiniTentacle3, MiniTentacle4, TentacleBicepR,
	TentacleBicepL, TentacleForearmL, TentacleForearmR, TentacleChest, TentacleFootR, 
	TentacleFootL, TentacleShinR, TentacleShinL, TentaclePelvis;

// 0 = Mouth, 1 = Shoulder1, 2 = Shoulder2, 3 = Temporary
struct STentacleOffsets
{
	var() vector	MouthOffset;
	var() vector	RightShoulderOffset;
	var() vector	LeftShoulderOffset;
	var() vector	HeadOffset;

	var() rotator	MouthRotation;
	var() rotator	RightShoulderRotation;
	var() rotator	LeftShoulderRotation;
	var() rotator	HeadRotation;
};

var( AIStartup ) STentacleOffsets TentacleOffsets;

/*-----------------------------------------------------------------------------
	Miscellaneous
-----------------------------------------------------------------------------*/
var config	bool	bVerbose;	//for debugging (currently not used).
var			string  GoalString;	// Currently not used.	
var float			TimeExisted;
var( AIStartup ) bool			bReEnableUseTrigger;
var( AIStartup ) name			UseTriggerEvent;

const EnemyEgoKillValue = 8;
const FriendlyEgoKillValue = -25;

function TakeDamage( int Damage, Pawn instigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType )
{
	if( bNPCInvulnerable )
		return;
	else
		Super.TakeDamage( Damage, instigatedBy, HitLocation, Momentum, DamageType );
}

function Timer( optional int TimerNum )
{
	local actor A;

	bCanFire = true;

	if( TimerNum == 1 )
	{
		if( MyAE.SoundEvent != '' )
		{
			foreach allactors( class'Actor', A, MyAE.SoundEvent )
				A.Trigger( MyAE, self );
		}
	}
	else if( TimerNum == 2 )
		MyAE.TriggerMovementEvent( self );
	else if( TimerNum == 3 )
	{
		if( MyAE.EventAllAnim != '' )
			MyAE.TriggerEvent( MyAE.EventAllAnim, self );
		MyAE.TriggerAllAnimEvents( self );
	}
	else
		Super.Timer( TimerNum );
}

function SideStepDestination(vector targetpos)
{	
	local vector ToTarget, ToSide, ToHeight;
	
	ToTarget = targetpos - Location;
	if (ToTarget.Z > 0)
		ToHeight = vect(0,0,1);
	else
		ToHeight = vect(0,0,-1);
	ToTarget.Z = 0;
	ToTarget = Normal(ToTarget);
	ToSide = ToTarget cross vect(0,0,1);
	if (FRand() < 0.5)
		ToSide *= -1;
	Destination = Location - ToTarget*RandRange(100, 150) - ToSide*RandRange(8,50) - ToHeight*RandRange(40,50) - vect(0,0,1)*RandRange(-10,10);
}

function ChooseAttackState(  optional name NextLabel, optional bool bWounded  );

function PlayDeath( EPawnBodyPart BodyPart, class<DamageType> DamageType )
{
	local name DeathSequence;
	local MeshInstance minst;
	local int RandNum;

	PlayTopAnim( 'None' );
	PlayBottomAnim( 'None' );

	if( bSuffering )
		return;

	if( GetPostureState() == PS_Crouching )
	{
		PlayAllAnim( 'A_Death_KneelA',, 0.12, false );
		return;
	}

	if( bSteelSkin  )
	{
		if( bLegless )
		{
			PlayAllAnim( 'A_RobotCrawlDeath',, 0.12, false );
			return;
		}

		if( !bEMPed && !bSleeping )
		{
			if( FRand() < 0.5 )
				PlayAllAnim( 'A_RobotDeathA',, 0.12, false );
			else
				PlayAllAnim( 'A_RobotDeathB',, 0.12, false );
		}
		else
			if( bSleeping )
				PlayAllAnim( 'A_RobotDeathEMP',, 0.12, false );
		return;
	}

	if( GetSequence( 0 ) == 'A_KnockDownF_All' )
	{
		PlayAllAnim( 'A_Death_FallOnGround',, 0.25, false );
		return;
	}

	if( ClassIsChildOf(DamageType, class'DrowningDamage') )
	{
		DeathSequence = 'A_Death_Choke';
		return;
	}
	
	if( InFrontOfWall() )
	{
		if( FRand() < 0.5 )
			PlayAllAnim( 'A_Death_HitWall1',, 0.1, false );
		else 
			PlayAllAnim( 'A_Death_HitWall2',, 0.1, false );
		return;
	}
	if( FacingWall() )
	{
		PlayAllAnim( 'A_Death_HitWall_F',, 0.1, false );
		return;
	}
	
	switch(BodyPart)
	{
		case BODYPART_Head:
			if (ClassIsChildOf(DamageType, class'SniperLaserDamage') || ClassIsChildOf(DamageType, class'ShotgunDamage'))
			{
				//// // broadcastMessage("!!");
				bHeadBlownOff = true;
				if( GetPostureState() == PS_Crouching )
				{
					PlayAllAnim( 'A_Death_KneelA',, 0.12, false );
					return;
				}
			}
			PlayDeathHead();
			return;
			//DeathSequence = 'A_Death_HitHead';
			break;
		case BODYPART_Chest:
			//DeathSequence = 'A_Death_HitChest';			break;
			if( FRand() < SufferFrequency )
			{
				DeathSequence = 'A_Suffer_ChestFall';
				bSuffering = true;
			}
			else
			{
				PlayDeathChest();
				return;
			}
			break;

		case BODYPART_Stomach:
			PlayDeathStomach();
			return;
		case BODYPART_Crotch:
			PlayDeathPelvis();
			return;
		case BODYPART_ShoulderLeft: 
			PlayDeathShoulderLeft();
			return;
		case BODYPART_ShoulderRight:DeathSequence = 'A_Death_HitRShoulder';		PlayDeathShoulderRight();
			return;
		case BODYPART_HandLeft:		DeathSequence = 'A_Death_HitLShoulder';		break;
		case BODYPART_HandRight:	DeathSequence = 'A_Death_HitRShoulder';		break;
		case BODYPART_KneeLeft:		DeathSequence = 'A_Death_Hitback1';			break;
		case BODYPART_KneeRight:
			if( FRand() < SufferFrequency )
			{
				DeathSEquence = 'A_Suffer_RLegFall';
				bSuffering = true;
			}
			else
				DeathSequence = 'A_Death_Hitback1';
			break;
		case BODYPART_FootLeft:		DeathSequence = 'A_Death_Hitback2';			break;
		case BODYPART_FootRight:
			if( FRand() < SufferFrequency )
			{
				bSuffering = true;
				DeathSEquence = 'A_Suffer_RLegFall';
			}
			else
			{
				bSuffering = true;
				DeathSequence = 'A_Death_Hitback1';
			}
			break;

		case BODYPART_Default:		DeathSequence = 'A_Death_HitStomach';		break;
	}

	if( !bSuffering )
	{
		StopSound( SLOT_Talk );
		StopSound( SLOT_None );
		StopSound( SLOT_Misc );
	}
	PlayAllAnim(DeathSequence,,0.1,false);
}

function PlayDeathStomach()
{
	local int RandNum;
	local name DeathSequence;
	local int i;

	RandNum = Rand( 4 );

	switch( RandNum )
	{
		Case 0:
			DeathSequence = 'A_Death_HitStomach';
			break;
		Case 1:
			DeathSequence = 'A_Death_HitStomachB';
			break;
		Case 2:
			DeathSequence = 'A_Death_HitStomachC';
			break;
		Default:
			DeathSequence = 'A_Death_HitStomachD';
			break;
	}
	PlayAllAnim(DeathSequence,,0.1,false);
}

function PlayDeathPelvis()
{
	local int RandNum;
	local name DeathSequence;
	local int i;

	RandNum = Rand( 4 );

	switch( RandNum )
	{
		Case 0:
			DeathSequence = 'A_Death_Fallstraightdown';	
			break;
		Case 1:
			DeathSequence = 'A_Death_HitStomachC';	
			break;
		Case 2:
			DeathSequence = 'A_Death_HitStomachD';	
			break;
		Default: 
			DeathSequence = 'A_Death_HitStomachB';
			break;
	}
	PlayAllAnim(DeathSequence,,0.1,false);
}

function PlayDeathChest()
{
	local int RandNum;
	local name DeathSequence;
	local int i;

	RandNum = Rand( 9 );
	
	switch( RandNum )
	{
		Case 0:
			DeathSequence = 'A_Death_HitChest';	
			break;
		Case 1:
			DeathSequence = 'A_Death_HitLShoulder';
			break;
		Case 2:
			DeathSequence = 'A_Death_HitRShoulder';
			break;
		Case 3:
			DeathSequence = 'A_Death_FallStraightDown';
			break;
		Case 4:
			DeathSequence = 'A_Death_HitChestB';
			break;
		Case 5:
			DeathSequence = 'A_Death_HitChestC';
			break;
		Case 6:
			DeathSequence = 'A_Death_HitLShoulderB';
			break;
		Case 7:
			DeathSequence = 'A_Death_HitRShoulderB';
			break;
		Case 8:
			DeathSequence = 'A_Death_HitLShoulderC';
			break;
		Default:
			DeathSequence = 'A_Death_HitChest';
	}
	PlayAllAnim(DeathSequence,,0.1,false);
}	
	
function PlayDeathHead()
{
	local int RandNum;
	local name DeathSequence;

	RandNum = Rand( 9 );
	
	Switch( RandNum )
	{
		Case 0:
			DeathSequence = 'A_Death_FallStraightDown';	
			break;
		Case 1:
			DeathSequence = 'A_Death_FaceSuffer';
			break;
		Case 2:
			DeathSequence = 'A_Death_HitChest';
			break;
		Case 3:
			DeathSequence = 'A_Death_HitChestB';
			break;
		Case 4:
			DeathSequence = 'A_Death_HitChestC';
			break;
		Case 5:
			DeathSequence = 'A_Death_HitLShoulderB';
			break;
		Case 6:
			DeathSequence = 'A_Death_HitRShoulderB';
			break;
		Case 7:
			DeathSequence = 'A_Death_HitHead';
			break;
		Case 8:
			DeathSequence = 'A_Death_HitLShoulderC';
			break;

		Default:
			DeathSequence = 'A_Death_HitHead';
			break;
	}
	PlayAllAnim(DeathSequence,,0.1,false);
}

function PlayDeathShoulderLeft()
{
	local int RandNum;
	local name DeathSequence;

	RandNum = Rand( 3 );
	
	Switch( RandNum )
	{
		Case 0:
			DeathSequence = 'A_Death_HitChest';	
			break;
		Case 1:
			DeathSequence = 'A_Death_HitLShoulderC';
			break;
		Default:
			DeathSequence = 'A_Death_HitLShoulder';
			break;
	}
	log( "* PlayDeathShoulderLeft RandNum was "$RandNum$" deathsequence was "$DeathSequence );
	PlayAllAnim(DeathSequence,,0.1,false);
}	

function PlayDeathShoulderRight()
{
	local int RandNum;
	local name DeathSequence;

	RandNum = Rand( 2 );
	
	Switch( RandNum )
	{
		Case 0:
			DeathSequence = 'A_Death_HitChest';	
			break;
		Case 2:
			DeathSequence = 'A_Death_HitRShoulder';
			break;
		Default:
			DeathSequence = 'A_Death_HitRShoulder';
			break;
	}
	log( "* PlayDeathShoulderRight RandNum was "$RandNum$" deathsequence was "$DeathSequence );
}	

function PlayMovingAttack()
{
//	PlayToRunning();
//	FireWeapon();
}

function bool CanDirectlyReach( actor ReachActor )
{
	local vector HitLocation,HitNormal;
	local actor HitActor;
	
	HitActor = Trace( HitLocation, HitNormal, ReachActor.Location + vect( 0, 0, -19 ), Location + vect( 0, 0, -19 ), true );
	
	if( HitActor == ReachActor )
	{
		return true;
	}
	
	return false;
}

function PlayToStanding()
{
	//SetCollisionSize( CollisionRadius, CollisionHeight );
	BaseEyeheight = 27;
	EyeHeight = 27;
	bCrouching = false;
	PlayBottomAnim( 'B_KneelUp',, 0.2, false );
	bCrouchShiftingDisabled = true;
}

function PlayToCrouch( optional bool bCrouchLow )
{
	//SetCollisionSize( CollisionRadius, Default.CollisionHeight * 0.5 );
	if( bSteelSkin )
		return;

	StopFiring();
	BaseEyeHeight = 0;
	EyeHeight = 0;
	SetPostureState( PS_Crouching );
	bCrouching = true;
	if( bCrouchLow )
		PlayAllAnim( 'A_CrchIdle',, 0.35, true );
	else
		PlayBottomAnim( 'B_KneelDown',, 0.1, false );
	bCrouchShiftingDisabled = true;
}


// To be deleted (saving for shield user fixing).	
function PlayToWaiting( optional float TweenTime )
{
	local float f;

	if( bReloading )
		return;
	if( !IsRunning() && GetStateName() != 'Idling' )
	{
		PlayBottomAnim('None');
		if( TweenTime == 0.0 )
			TweenTime = 0.1;

		if( Enemy == None )
			bWalkMode = true;
		else
			bWalkMode = false;
	
		if( Physics == PHYS_Swimming )
		{
			PlayAllAnim( 'A_SwimStroke',, TweenTime, true );
			PlayBottomAnim( 'B_SwimKickFwrd',, TweenTime, true );
		}
		else if( Enemy == None )
		{
			if( Weapon == None )
				PlayAllAnim( 'A_IdleStandINactive',, TweenTime, true );
			else 
				PlayAllAnim( 'A_IdleStandActive',, TweenTime, true );
			if( bShieldUser && !IsAnimating( 1 ) && bFire == 0 )
				PlayTopAnim( 'T_ShieldIdle',, TweenTime, true );
		}
		else if( Weapon != None && Enemy != None )
		{
			if( !bShieldUser || ( GetSequence( 0 ) == 'A_Run_Shield' ) )
				PlayAllAnim( 'a_IdleStandActive',, TweenTime, true );
			if( bShieldUser &&  !IsAnimating( 1 ) && GetSequence( 1 ) != 'T_ShieldFireOut' ) /*&& bFire == 0 ) */
				PlayTopAnim( 'T_ShieldOutIdle',, TweenTime, true );
			else if( ( Weapon != None ) && !IsInState( 'CoverTest' ) && !bReloading && !bShieldUser )
			{
				if( IsInState( 'RangedAttack' )  || ( IsInState( 'NewCover' ) ) )
				{
					if (Weapon.IsA('pistol'))
						PlayTopAnim('T_Pistol2HandIdle',,TweenTime,true);
					else if (Weapon.IsA('m16'))
						PlayTopAnim('T_M16Idle',,TweenTime,true);
					else if (Weapon.IsA('shotgun'))
						PlayTopAnim('T_SGIdle',,TweenTime,true);
					else if( Weapon.IsA( 'RPG' ) )
						PlayTopAnim( 'T_RPGIdle',, TweenTime, true );
					else
						PlayTopAnim('None');
				}
			}
		}
		else
		{
			if( Weapon != None )
				PlayAllAnim( 'A_IdleStandActive',, TweenTime, true );
			else
				PlayAllAnim( 'A_IdleStandInactive',, TweenTime, true );
			if( bShieldUser && !IsAnimating( 1 ) ) /*&& bFire == 0 )*/
				PlayTopAnim( 'T_ShieldOutIdle',, TweenTime, true );
		}

		if( GetPostureState() == PS_Crouching )
		{
			//PlayBottomAnim( 'B_KneelIdle' );
				if( bAtDuckPoint )
				PlayToCrouch( true );
			else	
				PlayCrouching();
		}
	}
	if( bShieldUser && !IsAnimating( 0 ) && GetPostureState() != PS_Crouching )
		PlayAllAnim( 'a_IdleStandActive',, 0.12, true );

	if( bShieldUser && !IsAnimating( 1 ) && GetStateName() != 'RangedAttack' )
		PlayTopAnim( 'T_ShieldIdle',, TweenTime, true );
}

function PlayToWalking()
{
	local meshinstance m;

	m = GetMeshInstance();

	if( SpecialWalkAnim != '' )
	{
		PlayAllAnim( SpecialWalkAnim,, 0.1, true );
		return;
	}

	if( !bBackPedaling )
		WalkingSpeed = Default.WalkingSpeed;

	if( !IsAnimating( 2 ) )
		PlayBottomAnim( 'None' );

	if( bCrouching )
	{
		PlayAllAnim( 'A_CrchWalk_Pistol', 1.0 , 0.1, true );
		return;
	}
	else if ( bBackPedaling )
	{
		if( Weapon.IsA( 'm16' ) )
			PlayTopAnim( 'T_m16Idle',, 0.3, true );
		else
			PlayTopAnim( 'T_SGIdle',, 0.3, true );
		PlayBottomAnim('B_SneakWalkBack',,0.3,true);
		return;
	}
	else if (bWalkMode )
	{
		if (Weapon==None)
			PlayAllAnim('A_Walk',,0.1,true);
		else
			PlayAllAnim('A_WalkWeapon',,0.1,true);
		return;
	}
	else
	if (Weapon==None)
	{
		PlayAllAnim('A_Run',,0.2,true);
		return;
	}

	if (Weapon.IsA('pistol'))
	{
		if (FRand() < 0.5)
			PlayAllAnim('A_Run_1HandGun',,0.1,true);
		else
			PlayAllAnim('A_Run_1HandGunB',,0.1,true);
	}
	else if (Weapon.IsA('m16'))
		PlayAllAnim('A_Run_2HandGun',,0.1,true);
	else if (Weapon.IsA('shotgun'))
		PlayAllAnim('A_Run_Shotgun',,0.1,true);
	else if( GetSequence( 0 ) != 'A_Run' )
			PlayAllAnim('A_Run',,0.1,true);
	if( NeedToTurn( Destination ) )
	{
		if ((rotator(Focus - Location) - Rotation).Yaw < 0)
			PlayAllAnim( 'A_Run_StrafeRight',, 0.1, true );
		else
			PlayAllAnim( 'A_Run_StrafeLeft',, 0.1, true );
	}
}

function bool IsRunning()
{
	local string Test, Test2;

	Test = Left( String( GetSequence( 0 ) ), 5 );

}


function PlayToRunning()
{
	local float Speed;

	if( self.IsA( 'NPC' ) && bSnatched && GetStateName() != 'ActivityControl' && GetStateName() != 'Following' )
	{
		if( !bPanicOnFire )
		{
			bWalkMode = true;
			PlayToWalking();
		}
		else
		{
			PlayAllAnim('A_Run',Speed, 0.3,true);
			PlayTopAnim( 'T_ImOnFire',, 0.1, true );
		}
		return;
	}
	if( GetStateName() == 'NewCover' )
		HeadTrackingActor = None;
	Speed = 1.22;

	BaseEyeHeight = Default.BaseEyeHeight;
	PlayBottomAnim('None');
	if( Physics == PHYS_Swimming )
		PlayAllAnim( 'A_SwimStroke',, 0.1, true );
	else if( SpecialRunAnim != '' )
	{
		PlayAllAnim( SpecialRunAnim,, 0.1, true );
		return;
	}
	
	if( bShieldUser )
	{
		PlayAllAnim( 'A_Run_Shield',, 0.1, true );
		return;
	}

	if ( bBackPedaling )
		PlayAllAnim('A_BackPeddle',,0.1,true);
	else if( IsLimping() )
	{
		if( bLimpingRight )
		{
			if( Weapon != None )
				PlayAllAnim( 'A_LimpWalkR_Wep',, 0.2, true );
			else
				PlayAllAnim( 'A_LimpWalkR',, 0.2, true );
			return;
		}
		else if( bLimpingLeft )
		{
			if( Weapon != None )
				PlayAllAnim( 'A_LimpWalkL_Wep',, 0.2, true );
			else
				PlayAllAnim( 'A_LimpWalkL',, 0.2, true );
			return;
		}
	}
	else
	{
		if (Weapon==None)
		{
			if( GetSequence( 0 ) != 'A_Run' )
				PlayAllAnim('A_Run',Speed, 0.3,true);
			if( GetStateName() == 'Wandering' && bPanicking )
				PlayTopAnim( 'T_ImOnFire',, 0.1, true );
			return;
		}
		if( GetPostureState() == PS_Crouching )
		{
			PlayAllAnim( 'A_CrchWalk_Pistol', speed, 0.1, true );
			return;
		}

		if (Weapon.IsA('pistol'))
		{
			PlayTopAnim( 'None' );
			PlayAllAnim( 'A_Run_Hunch1HandB', speed, 0.1, true );
		}
		else if (Weapon.IsA('m16'))
		{
			//if( Enemy == None )
			//	PlayAllAnim('A_Run_2HandGun',speed,0.1,true);
			//else
			// Temp
			Speed = 1.35;
			PlayAllAnim( 'A_Run_Hunch2Hand', speed, 0.1, true );
		}
		else if (Weapon.IsA('shotgun'))
		{
			if( Enemy == None )
				PlayAllAnim('A_Run_Shotgun',speed,0.1,true);
			else
				PlayAllAnim( 'A_Run_HunchShotGun', speed, 0.1, true );
		}
		else
		{
			if( Enemy == None )
				PlayAllAnim('A_Run',speed,0.1,true);
			else
				PlayAllAnim( 'A_Run_HunchRun', speed, 0.1, true );
		}
	}
}

function PlaySwimming( optional ESwimDepth sd )
{
	BaseEyeHeight = 0.7 * Default.BaseEyeHeight;
	PlayAllAnim('A_SwimStroke',,0.1,true);
}

// To be deleted- obsolete.
function PlayCrouching()
{
	// // log( "PLAYING B_KNEEL IDLE FROM HUMANNPC" );
	PlayAllAnim( 'None' );
	PlayBottomAnim( 'B_KneelIdle',, 0.3, true );
}

function PlayJump()
{
	BaseEyeHeight =  0.7 * Default.BaseEyeHeight;
	PlayAllAnim('A_JumpAir_U',,0.1,false);
}

function PlayInAir()
{
	BaseEyeHeight =  0.7 * Default.BaseEyeHeight;
	PlayAllAnim('A_JumpAir_U',,0.1,false);
}

function PlayLanded(float impactVel)
{	
	if( ImpactVel < -150.00 )
	{
		BaseEyeHeight = Default.BaseEyeHeight;
		PlayAllAnim('A_JumpLand',,0.1,false);
		Super.PlayLanded( impactVel );
	}
}

function EvaluateEgoValue()
{
	if( bSnatched || bAggressiveToPlayer )
		EgoKillValue = EnemyEgoKillValue;
	else
		EgoKillValue = FriendlyEgoKillValue;
}

// Turning: 
function PlayTurnLeft()
{
	if( GetPostureState() != PS_Crouching && !bLegless )
	{
		if (bWalkMode)
			PlayBottomAnim('B_StepLeftInactive',,0.1,true);
		else
			PlayBottomAnim('B_StepLeft',,0.1,true);
	}
}

function PlayTurnRight()
{
	if( GetPostureState() != PS_Crouching && !bLegless )
	{
		if (bWalkMode)
			PlayBottomAnim('B_StepRightInactive',,0.1,true);
		else
			PlayBottomAnim('B_StepRight',,0.1,true);
	}
}

// To be deleted: Obsolete.
function bool PlayDamage(EPawnBodyPart BodyPart, optional bool bShortAnim, optional bool bKnockedDown, optional int Damage )
{
	local name BottomSeq;
		
	if( bNoPain || ( bSteelSkin && Damage < 70 ) || ( !bSteelSkin && Acceleration != vect( 0, 0, 0 ) ) ) //|| ( bSteelSkin && Damage < 50 ) )
	{
		return false;
	}
	
	if( Weapon != None && Weapon.IsA( 'Shotgun' ) )
	{
		bFire = 0;
		bAltFire = 0;
	}

	if( GetPostureState() == PS_Crouching || BottomSeq == 'B_KneelIdle' || BottomSeq == 'B_KneelUp' || BottomSeq == 'B_KneelDown' )
	{
		bFire = 0;
		bAltFire = 0;

		if( bShieldUser )
		{
			return true;
		}

		switch(BodyPart)
		{
			case BODYPART_Head: PlaySpecialAnim( 'S_PainHead' ); break;
			case BODYPART_ShoulderRight: PlaySpecialAnim( 'S_PainRShoulder' ); break;
			case BODYPART_ShoulderLeft: PlaySpecialAnim( 'S_PainLShoulder' ); break;
			case BODYPART_HandLeft: PlaySpecialAnim( 'S_PainLShoulder' ); break;
			case BODYPART_HandRight: PlaySpecialAnim( 'S_PainRShoulder' ); break;
			case BODYPART_Chest: PlaySpecialAnim( 'S_PainStomach' ); break;
			default: PlaySpecialAnim( 'S_PainStomach' ); break;
		}
		bNoPain = true;
		return true;
	}

	if( !bShieldUser )
		PlayTopAnim('None');
	PlayBottomAnim('None');
	bShortAnim = true;

	if( bSteelSkin )
	{
		bKnockedBack = true;
		PlayAllAnim( 'A_RobotKnockBack',, 0.1, false );
		return true;
	}

	if( bKnockedDown )
	{
		PlayAllAnim( 'A_KnockDownF_All',, 0.1, false );
		bNoPain = true;
		return true;
	}

	BottomSeq = GetSequence( 2 );
	if( FRand() < 0.03 )
		bShortAnim = false;

	if( bShieldUser )
		bShortAnim = true;
	if (!bShortAnim)
	{
		// long animations
		switch(BodyPart)
		{
		case BODYPART_Head: PlayAllAnim('A_PainHeadLONG', 1.25, 0.1, false ); break;
		case BODYPART_Chest: PlayAnim('A_PainChestLONG', 1.25); break;
		case BODYPART_Stomach: PlayAnim('A_PainStomachLONG', 1.25); break;
		case BODYPART_Crotch: PlayAnim('A_PainBallsLONG', 1.25); break;
		case BODYPART_ShoulderLeft:
			PlayAnim('A_PainLshlderLONG', 1.25);
		
			break;
		case BODYPART_ShoulderRight: PlayAnim('A_PainRshlderLONG', 1.25); break;			
		case BODYPART_HandLeft: PlayAnim('A_PainLhandLONG', 1.25); break;
		case BODYPART_HandRight: PlayAnim('A_PainRhandLONG', 1.25); break;
		case BODYPART_KneeLeft: PlayAnim('A_PainLkneeLONG', 1.25); break;
		case BODYPART_KneeRight: PlayAnim('A_PainRkneeLONG', 1.25); break;
		case BODYPART_FootLeft: PlayAnim('A_PainLfootLONG', 1.25); break;
		case BODYPART_FootRight: PlayAnim('A_PainRfootLONG', 1.25); break;
		case BODYPART_Default: PlayAnim('A_PainStomachLONG', 1.25); break;
		}
	}
	else
	{
		// short animations
		switch(BodyPart)
		{
		case BODYPART_Head: 
			PlayAllAnim('A_PainHeadSHRT',, 0.1, false );
			break;
		case BODYPART_Chest:
			PlayAllAnim('A_PainChestSHRT',, 0.1, false );
			if( FRand() < 0.5 && bSnatched && TentacleChest == None && bSnatched )
				TentacleChest = CreateMiniTentacle( vect( 4, 0, 2 ), rot( 20384, 0, 0 ), 'Chest' );
			else if( FRand() < 0.22 && bSnatched && TentacleChest == None )
				TentacleChest = CreateMiniTentacle( vect( 4, 0, -5 ), rot( -20384, 0, 0 ), 'Chest' );
			break;

		case BODYPART_Stomach:
			if( bShieldUser )
				PlayAllAnim( 'A_PainChestShrt' );
			else
				PlayAllAnim('A_PainStomachSHRT',, 0.1, false );
			if( FRand() < 0.5 && bSnatched && MyTemporaryTentacle == None && Health > 15 )
			{
				MyTemporaryTentacle = CreateTentacle( vect( 3, 0, -10 ), rot( 0, 32768, 32768 ), 'Abdomen' );
				MyTemporaryTentacle.bHidden = false;
				MyTemporaryTentacle.GotoState( 'MAttackA' );
			}
			break;
		case BODYPART_Crotch:
			bFire=0; bAltFire=0; PlayAllAnim('A_PainBallsSHRT',, 0.1, false );
			if( FRand() < 0.5 && bSnatched && TentaclePelvis == None )
				TentaclePelvis = CreateMiniTentacle( vect( 0, 0, -2.5 ), rot( -20384, 0, 0 ), 'Pelvis' );
			break;
		case BODYPART_ShoulderLeft: PlayAllAnim('A_PainLshlderSHRT',, 0.1, false );
			if( Damage > 8 && FRand() < 0.5 )
			{
				bArmless = true;
				PlayAllAnim( 'A_PainLshlderLONG',, 0.1, false );
				if( !Weapon.IsA( 'Pistol' ) )
					Weapon.PutDown();
			}
			else 
			if( !barmless && FRand() < 0.23 && bSnatched && MyShoulderTentacle2 == None && Health > 15 )
			{
				MyShoulderTentacle2 = CreateTentacle( TentacleOffsets.LeftShoulderOffset, TentacleOffsets.LeftShoulderRotation, 'Chest' );
				//MyShoulderTentacle2 = CreateTentacle( vect( 6, -4, 0 ), rot( -18300, 18300, -22300 ), 'Chest' );
				MyShoulderTentacle2.GotoState( 'ShoulderDamageTentacle' );
			}
			else if( !bArmless && bSnatched && TentacleBicepL == None )
				TentacleBicepL = CreateMiniTentacle( vect( 2, -2, 0 ), rot( 0, -10384, 0 ), 'Bicep_L' );
			break;
		case BODYPART_ShoulderRight: PlayAllAnim('A_PainRshlderSHRT',, 0.1, false );
			if( FRand() < 0.23 && bSnatched && MyShoulderTentacle1 == None && Health > 15 )
			{
				MyShoulderTentacle1 = CreateTentacle( TentacleOffsets.RightShoulderOffset, TentacleOffsets.RightShoulderRotation, 'Chest' );
				MyShoulderTentacle1.GotoState( 'ShoulderDamageTentacle' );
			}
  			else if( TentacleBicepR == None && bSnatched )
				TentacleBicepR = CreateMiniTentacle( vect( 2, 2, 0 ), rot( 0, 10384, 0 ), 'Bicep_R' );
			break;			
		case BODYPART_HandLeft:
			if( bShieldUser )
				PlayAllAnim( 'A_PainChestShrt' );
			else PlayAllAnim('A_PainLhandLSHRT',, 0.1, false );
			if( TentacleForearmL == None && bSnatched )
				TentacleForearmL = CreateMiniTentacle( vect( 0, 0, 0 ), rot( -10000, -12000, 0 ), 'Forearm_L' );
			break;
		case BODYPART_HandRight:
			if( bShieldUser )
				PlayAllAnim( 'A_PainChestShrt' );
			else PlayAllAnim('A_PainRhandSHRT',, 0.1, false );
			if( TentacleForearmR == None && bSnatched )
				TentacleForearmR = CreateMiniTentacle( vect( 0, 0, 0 ), rot( -10000, 12000, 0 ), 'Forearm_R' );
			break;
		case BODYPART_KneeLeft:
			PlayAllAnim('A_PainLkneeSHRT',, 0.1, false );
			if( FRand() < 0.5 && bSnatched && TentacleShinL == None )
				TentacleShinL = CreateMiniTentacle( vect( 0, 0, -1.5 ), rot( -23384, 16384 ), 'Shin_L' );
			break;
		case BODYPART_KneeRight: 
			PlayAllAnim('A_PainRkneeSHRT',, 0.1, false );
			if( FRand() < 0.5 && bSnatched && TentacleShinR== None )
				TentacleShinR = CreateMiniTentacle( vect( 0, 0, -1.5 ), rot( -9384, 16384, 0 ), 'Shin_R' );
			break;

		case BODYPART_FootLeft: 
			PlayAllAnim('A_PainLfootSHRT',, 0.1, false );
			if( FRand() < 0.5 && bSnatched && TentacleFootL == None )
				TentacleFootL = CreateMiniTentacle( vect( -1, 0, -5 ), rot( -7000, 0, 0 ), 'Foot_L' );
			break;
		case BODYPART_FootRight:
			PlayAllAnim('A_PainRfootSHRT',, 0.1, false );
			if( FRand() < 0.5 && bSnatched && TentacleFootR == None )
				TentacleFootR = CreateMiniTentacle( vect( -1, 0, -5 ), rot( -7000, 0, 0 ), 'Foot_R' );
			break;
		case BODYPART_Default:
			if( bShieldUser )
				PlayAllAnim( 'A_PainChestShrt' );
			else PlayAllAnim('A_PainStomachSHRT',, 0.1, false );
			if( FRand() < 0.5 && bSnatched && TentacleChest == None && bSnatched )
				TentacleChest = CreateMiniTentacle( vect( 4, 0, 2 ), rot( 20384, 0, 0 ), 'Chest' );
			else if( FRand() < 0.22 && bSnatched && TentacleChest == None )
				TentacleChest = CreateMiniTentacle( vect( 4, 0, -5 ), rot( -20384, 0, 0 ), 'Chest' );
			break;
		}
	}
	bNoPain = true;
	return true;
}



/*-----------------------------------------------------------------------------
	State Management
-----------------------------------------------------------------------------*/

function EnterControlState_Normal()
{
	if ( Mesh == None )
		Mesh = Default.Mesh;
	//// // // // // log( "Entering controlstate_Normal!" );
	WalkBob = vect(0,0,0);
	SetPostureState(PS_Standing, true);
	SetMovementState( MS_Running, true );
	if (Physics != PHYS_Falling) 
		SetPhysics(PHYS_Walking);
	PlayToWaiting();
}

function ExitControlState_Normal()
{
	WalkBob = vect(0,0,0);
	SetPostureState(PS_Standing, true);
	SetMovementState(MS_Waiting, true);
}

function EnterControlState_Swimming()
{
	Disable('Timer');
	if ( !IsAnimating() )
		TweenToWaiting(0.3);
}

function EnterControlState_Flying()
{
	EyeHeight = BaseEyeHeight;
	SetPhysics(PHYS_Flying);
}

// MovementState changes.
function MovementStateChange_Running(EMovementState OldState) 
{
//	WalkingSpeed = Default.WalkingSpeed * 2;
	if (GetPostureState() == PS_Crouching)
	{
		PlayToCrawling();
	}
//	else if (GetPostureState() != PS_Jumping)
//		PlayToRunning();
}

function MovementStateChange_Waiting(EMovementState OldState) 
{
	if (GetPostureState() != PS_Jumping)
	{
		PlayToWaiting();
	}
}

function MovementStateChange_Walking(EMovementState OldState) 
{
	WalkingSpeed = Default.WalkingSpeed;
	if (GetPostureState() == PS_Crouching)
	{
		PlayToCrawling();
	}
	else if (GetPostureState() != PS_Jumping)
		PlayToWalking();
}

function SetPostureState( EPostureState NewState, optional bool DontNotify )
{
	PostureState = NewState;
}

/*-----------------------------------------------------------------------------
	Miscellaneous functions.
-----------------------------------------------------------------------------*/
function TriggerFollow( optional actor anActor )
{
	if( AnActor == None )
		GetFollowActor();
	else
	{
		FollowActor = AnActor;
	}
	
	if(	Enemy == None && FollowActor != None )
	{
		if( FollowEvent != '' && !bFollowEventDisabled )
		{
			foreach allactors( class'Actor', anActor, FollowEvent )
			{
				anActor.Trigger( self, self );
			}
			if( bFollowEventOnceOnly )
			{
				bFollowEventDisabled = true;
			}
		}
		NextState = GetStateName();
		GotoState( 'Following' );
	}
}

function float GetRunSpeed()
{
	local float LimpSpeed;

	if( self.IsA( 'NPC' ) && bSnatched && GetStateName() != 'ActivityControl' && GetStateName() != 'Following' )
	{
		if( !bPanicOnFire )
			return GetWalkingSpeed();
		else
			return RunSpeed;
	}

	if( IsLimping() )
	{
		LimpSpeed = RunSpeed * 0.2;
		return LimpSpeed;
	}
	else
		return RunSpeed;
}

function TriggerHate()
{
	local actor NewEnemy;

	foreach allactors( class'Actor', NewEnemy, HateTag )
	{
		// // log( "** TRIGGER HATE SETTING "$self$" ENEMY "$Enemy );
		Enemy = NewEnemy;
		SetEnemy( NewEnemy );
		bForcedAttack = true;
		GotoState( 'Attacking' );
		break;
	}
}

function bool ShouldBeGibbed(class<DamageType> damageType)
{
	if (ShrinkCounter >= 1.0)
		return true;
	return DamageType.default.bGibDamage;
}

function KilledBy( pawn EventInstigator )
{
	Health = 0;
	PlaySuicide();
	KilledByPawn = EventInstigator;
	GotoState( 'Dying' );
}

function EnterControlState_Dead()
{
	GotoState( 'Dying' );
}

function EnterControlState_Frozen()
{
	Super.EnterControlState_Frozen();
	GotoState( 'Frozen' );
}

// Might be obsolete.
function PlayToCrawling()
{
	local vector X,Y,Z,Dir;

	PlayBottomAnim('None');
	if (Weapon.IsA('pistol'))
		PlayAllAnim('A_CrchWalk_Pistol',0.1,0.4,true);
	else if (Weapon.IsA('shotgun'))
		PlayAllAnim('A_CrchWalk_Shotgun',0.1,0.4,true);
	else
		PlayAllAnim('A_CrchWalk_GenGun',0.1,0.4,true);
	GetAxes(Rotation, X,Y,Z);
	Dir = Normal(Acceleration);
	if ( (Dir Dot X < 0.75) && (Dir != vect(0,0,0)) )
	{
		// Strafing or backing up.
		if ( Dir Dot X < -0.75 )
			PlayBottomAnim('B_CrchWalk_Backwards',,0.4,true);
		else if ( Dir Dot Y > 0 )
			PlayBottomAnim('B_CrchWalk_R',,0.4,true);
		else
			PlayBottomAnim('B_CrchWalk_L',,0.4,true);
	}
}


/*-----------------------------------------------------------------------------
	Startup stuff.
-----------------------------------------------------------------------------*/

function PreBeginPlay()
{
	bIsPlayer = true;
	Super.PreBeginPlay();
}

function SetPartsSequences();

function PlayMeleeImpactSound()
{
	local float Decision;

	Decision = FRand();

	if( Decision < 0.5 )
	{
		PlaySound( Sound'A_Impact.Body.ImpactMelee1', SLOT_Talk,,,,, false );
	}
	else
		PlaySound( Sound'A_Impact.Body.ImpactMelee2', SLOT_Talk,,,,, false );
}

simulated function bool EvalBlinking()
{
    local int bone;
    local MeshInstance minst;
    local vector t;
	local float deltaTime;

	if( bEyesShut )
	{
		CloseEyes();
		return false;
	}
    if( bSleepAttack || bVisiblySnatched || bSleeping || bEMPed || bEyeless )
	{
		Minst = GetMeshInstance();
		bone = minst.BoneFindNamed('Pupil_L');
		if (bone!=0)
			minst.bonesetscale( bone, vect( 0, 0, 0 ), false );
		bone = minst.BoneFindNamed('Pupil_R');
		if (bone!=0)
			minst.bonesetscale( bone, vect( 0, 0, 0 ), false );		
		return false;
	}
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

function bool CloseEyes()
{
    local int bone;
    local MeshInstance minst;
    local vector t;
	local float deltaTime;
    
	minst = GetMeshInstance();
    if (minst==None)
        return(false);

	CurrentBlinkAlpha = 1.0;
	bone = minst.BoneFindNamed( 'Eyelid_L' );
	if( Bone!=0 )
	{
		t = minst.BoneGetTranslate( bone, false, true );
		t -= BlinkEyelidPosition * CurrentBlinkAlpha;
		minst.BoneSetTranslate( bone, t, false );
	}

	bone = minst.BoneFindNamed( 'Eyelid_R' );
	if( Bone!=0 )
	{
		t = minst.BoneGetTranslate( bone, false, true );
		t -= BlinkEyelidPosition*CurrentBlinkAlpha;
		minst.BoneSetTranslate( bone, t, false );
	}

	bEyesShut = true;
}


// STATES

/*-----------------------------------------------------------------------------
	Tentacle Attacking State.
-----------------------------------------------------------------------------*/

// Tentacles (among other things) don't get removed from the actor list properly.
// This is a cheap temporary (I hope) fix for that to clear any references to them.
function InitializeTentacles()
{
	MyShoulderTentacle1 = None;
	MyShoulderTentacle2 = None;
}

state TentacleThrust
{
	ignores SeePlayer;

	function bool EvalLipSync()
	{
		return false;
	}

	function bool EvalBlink()
	{
		return false;
	}
	
	function BeginState()
	{
		local MeshInstance Minst;
		local int Bone;
		local Vector V, X;

		local Pawn P;

		OldEnemy = Enemy;
		SetEnemy( None );
		bFire = 0;
	}

	
Begin:
	StopMoving();
	StopFiring();
	if( MyMouthTentacle == None && GetSequence( 0 ) != 'A_KnockDownF_All' )
	{
		if( FRand() < 0.4 )
		{
			TentacleAttackType = TENTACLE_Thrust;
			MyMouthTentacle = CreateTentacle( TentacleOffsets.MouthOffset, TentacleOffsets.MouthRotation, 'Lip_U' );
		}
		else
		{
			TentacleAttackType = TENTACLE_Slash;
			MyMouthTentacle = CreateTentacle( TentacleOffsets.MouthOffset, TentacleOffsets.MouthRotation, 'Lip_U' );
		}

		if( MyShoulderTentacle1 == None && FRand() < 0.25 )
		{
			MyShoulderTentacle1 = CreateTentacle( TentacleOffsets.RightShoulderOffset, TentacleOffsets.RightShoulderRotation, 'Chest' );
			MyShoulderTentacle1.GotoState( 'ShoulderTentacle' );
		}
		if( MyShoulderTentacle2 == None && FRand() < 0.25 )
		{
			MyShoulderTentacle2 = CreateTentacle( TentacleOffsets.LeftShoulderOffset, TentacleOffsets.LeftShoulderRotation, 'Chest' );
			MyShoulderTentacle2.GotoState( 'ShoulderTentacle' );
		}

		HeadTrackingActor = OldEnemy;
		HeadTracking.DesiredWeight = 34.0;
		HeadTracking.WeightRate = 24.0;
		if( NeedToTurn( OldEnemy.Location ) )
		{
			StopMoving();
			if ((rotator(OldEnemy.Location - Location) - Rotation).Yaw < 0)
				PlayTurnLeft();
			else
				PlayTurnRight();
			TurnTo(OldEnemy.Location);
			PlayToWaiting();
		}
		bFire = 0;
		bAltFire = 0;
		Sleep( 0.1 );
		PlayTopAnim( 'None' );
		PlayBottomAnim( 'none' );
		DesiredRotation = rotator( OldEnemy.Location - Location );
		DesiredRotation.Pitch = 0;
		if( Physics != PHYS_Swimming )
		{
			if( TentacleAttackType == TENTACLE_Thrust ) 
				PlayAllAnim( 'A_Tentacle_Attck3', 1.0, 0.1, false );
			else if( TentacleAttackType == TENTACLE_Slash )
				PlayAllAnim( 'A_TentAttackMSwipeA', 1.0, 0.1, false );
		}

		MyMouthTentacle.bHidden = false;
		if( GetSequence( 0 ) == 'A_Tentacle_Attck3' )
		{
			MyMouthTentacle.bNewAttack = false;
			MyMouthTentacle.GotoState( 'MAttackA' );
		}
		else
		{
			MyMouthTentacle.bNewAttack = true;
			MyMouthTentacle.GotoState( 'MAttackA' );
		}
		if( Physics != PHYS_Swimming )
			FinishAnim( 0 );
		MyMouthTentacle.Destroy();
		MyMouthTentacle = None;
		SetEnemy( OldEnemy );
		PlayToWaiting();
	}
	if( VSize( Location - Enemy.Location ) > 72 )
	{
		if( bSteelSkin || ( self.IsA( 'NPC' ) && bSnatched ) )
		{
			log( self$" with "$bSleepAttack$" Going to ApproachingEnemy 1" );
			GotoState( 'ApproachingEnemy' );
		}
		else ChooseAttackState();
	}
	else
		GotoState( 'Attacking' );
}

function Landed( vector HitNormal )
{
	TakeFallingDamage();
	Super.Landed( HitNormal );
}

/*-----------------------------------------------------------------------------
	Idling State. 
-----------------------------------------------------------------------------*/
state Idling
{
	ignores HitWall;

	function PlayIdlingAnimation()
	{
		PlayAllAnim( InitialIdlingAnim,, 0.1, true );
	}

 	function BeginState()
	{
	//	HeadTrackingActor = FindTheNearestActor();
		NotifyMovementStateChange( MS_Waiting, MS_Walking );
		PlayBottomAnim( 'None' );
		EnableHeadTracking( true );
		EnableEyeTracking( true );
	
		if( Enemy != None )
		{
			GotoState( 'Attacking' );
		}
		bReadyToAttack = true;
	}

	function HearNoise(float Loudness, Actor NoiseMaker)
	{
		local vector OldLastSeenPos;
		
		if( NoiseMaker.IsA( 'LaserMine' ) && !LaserMine( NoiseMaker ).bNPCsIgnoreMe && Loudness == 0.5 && !LineOfSightTo( NoiseMaker ) )
		{
			SuspiciousActor = NoiseMaker;
			GotoState( 'Investigating' );
			return;
		}

		if( bAggressiveToPlayer && NoiseMaker.IsA( 'PlayerPawn' ) || ( bAggressiveToPlayer && NoiseMaker.Instigator.IsA( 'PlayerPawn' ) ) )
		{
			// // log( "HUMANNPC HEARNOISE SETTING ENEMY FOR "$self );
			Enemy = NoiseMaker.Instigator;
			if( Enemy != None )
			{
				GotoState( 'Attacking' );
			}
		}
	}

	function SeePlayer( actor SeenPlayer )
	{
		local float Dist;

		// // // // log( "SEE PLAYER 1" );
		if( bFixedEnemy )
			return;

		if( bAggressiveToPlayer && SeenPlayer.IsA( 'PlayerPawn' ) )
		{
			if( AggressionDistance > 0.0 )
			{
				Dist = VSize( Location - SeenPlayer.Location );
				if( Dist > AggressionDistance )
				{
					return;
				}
			}
			HeadTrackingActor = SeenPlayer;
			// // log( "HUMANNPC SEEPLAYER SETTING ENEMY FOR "$self );
			Enemy = SeenPlayer;
			if( Enemy == OldEnemy )
				GotoState( 'Attacking' );
			else
				GotoState( 'Acquisition' );
		}
		else if( bSnatched && !bAggressiveToPlayer && SeenPlayer.IsA( 'PlayerPawn' ) )
		{
			Dist = VSize( SeenPlayer.Location - Location );
	
			if( Dist <= AggroSnatchDistance )
			{
				if( !PlayerCanSeeMe()  )
				{
					Disable( 'SeePlayer' );
					log( "HUMANNPC SEEPLAYER SETTING ENEMY 4 FOR "$self );
					log( "DIST IS "$Dist );
					log( "AGGRO SNATCH DISTANCE IS: "$AggroSnatchDistance );

					Enemy = SeenPlayer;
					NextState = 'Attacking';
					bAggressiveToPlayer = true;
					NextState = 'Attacking';
					GotoState( 'SnatchedEffects' );
					//SetTimer( ), false, 8 );
				}
			}
		}
	}

Begin:
	WaitForLanding();
	PlayToWaiting();
	if( InitialIdlingAnim != '' )
	{	
		PlayIdlingAnimation();
		if( !bReuseIdlingAnim )
			InitialIdlingAnim = '';
	}
	if( bShieldUser )
		PlayTopAnim( 'T_ShieldIdle',,0.1, true );

	StopMoving();
	if( bFixedEnemy )
	{
		Sleep( 0.15 );
		GotoState( 'Attacking' );
	}
}

/*-----------------------------------------------------------------------------
	WaitingForEnemy State. 
-----------------------------------------------------------------------------*/
state WaitingForEnemy
{
	ignores EnemyNotVisible;

	function SeePlayer( actor SeenPlayer )
	{
		if( bFixedEnemy )
		{
			return;
		}
		if( SeenPlayer == Enemy )
			GotoState( 'Attacking' );
	}

	function EndState()
	{
		bCanSayPinDownPhrase = true;
	}

	function SawEnemy()
	{
		// // // // log( "WaitingForEnemy Saw Enemy" );
		ChooseAttackState();
	}

	function CheckEnemyPath()
	{
		if( !FindBestPathToward( Enemy, true ) )
			return;
		else
		{
			log( self$" with "$bSleepAttack$" Going to ApproachingEnemy 2" );
			GotoState( 'ApproachingEnemy' );		
			EndCallbackTimer( 'CheckEnemyPath' );
		}
	}

Begin:

	SetCallbackTimer( 2.0, true, 'CheckEnemyPath' );

	if( !IsAnimating( 0 ) )
	{
		PlayToWaiting();
	}

	if( bSightlessFire )
	{
		if( FRand() < 0.33 && !bSteelSkin && bCanSayPinDownPhrase )
		{
			SpeechCoordinator.RequestSound( self, 'PinDownFire' );
			bCanSayPinDownPhrase = false;
		}

		bReadyToAttack = true;
		bCanFire = true;
		bFire = 1;
		//PlayRangedAttack();
		Sleep( FRand() * 0.2 );
		Goto( 'Begin' );
	}
	// // // // // log( "Disable SeePlayer 2 for "$self );
	Disable( 'SeePlayer' );
	StopMoving();
	StopFiring();

	if( PostureState == PS_Crouching && !bFixedPosition )
	{
		PlayToStanding();
		FinishAnim( 2 );
		PlayToWaiting( 0.35 );
		Sleep( 0.35 );
	}
	Enable( 'SeePlayer' );
//	PlayToWaiting();
}

/*-----------------------------------------------------------------------------
	NPC Takehit (Damage) State. 
-----------------------------------------------------------------------------*/
state TakeHit 
{
	ignores seeplayer, hearnoise, bump, hitwall;

	function Landed(vector HitNormal)
	{
		if (Velocity.Z < -1.4 * JumpZ)
			MakeNoise(-0.5 * Velocity.Z/(FMax(JumpZ, 150.0)));
		bJustLanded = true;
	}

	function Timer( optional int TimerNum )
	{
		bReadyToAttack = true;
	}

	function BeginState()
	{
		if ( (NextState == 'TacticalTest') && (Region.Zone.ZoneGravity.Z > Region.Zone.Default.ZoneGravity.Z) )
			Destination = location;
		LastPainTime = Level.TimeSeconds;
	}
		
Begin:
	if( !bSteelSkin )
		SpeechCoordinator.RequestSound( self, 'Pain' );
	else if( GetSequence( 0 ) == 'A_RobotKnockBack' )
		StopMoving();

	AimAdjust = 10000;
	if( NextState != 'Reloading' )
		NextState = 'Attacking';
	if( IsAnimating( 3 ) )
	{
		FinishAnim( 3 );
		PlaySpecialAnim( 'None' );
	}
	else
		FinishAnim( 0 );
	StopMoving();	
	if( bSteelSkin )
		PlayToWaiting( 0.18 );
	else
		PlayToWaiting();
	//if( bArmless  )
	//	SwitchToWeapon( ChooseBestWeapon() );

	AimAdjust = 0;
/*	if( GetPostureState() != PS_Crouching && bAtDuckPoint && EvaluateDuckPoint( Location + vect( 0, 0, -12 ) ) )
	{
		StopFiring();
		bCanFire = false;
		PlayToCrouch( true );
		bCrouchShiftingDisabled = true;
		bCrouching = true;
		Sleep( 0.5 );
		bCanFire = true;
	}*/
	if( GetPostureState() != PS_Crouching && bShieldUser && FRand() < 0.75 )
	{
		StopFiring();
		PlayToCrouch( false );
		bCrouchShiftingDisabled = true;
		bCrouching = true;
		Sleep( FRand() );
		bCanFire = true;
	}
	ChooseAttackState();
}


/*-----------------------------------------------------------------------------
	NPC Jumping State. 
-----------------------------------------------------------------------------*/

state Jumping
{
	ignores HitWall, Bump;

Begin:
	StopMoving();
	PlayJump();
	SetPhysics( PHYS_Falling );
	Velocity = ( GroundSpeed /* * 1.25*/ ) * Normal( JumpDestination - Location );
	Velocity.Z += ( JumpZ ) ;
	PlayInAir();
	PlayLanded( VSize( Velocity ) );
	NotifyMovementStateChange( MS_Waiting, MS_Running );
	GotoState( NextState );
}

function TransitionToControlledState()
{
	NextState = GetStateName();
	GotoState( 'Controlled' );
}

function SetMouthExpression( int i )
{
	if( i == 0 )
		MouthExpression = MOUTH_Normal;
	else if( i == 1 )
		MouthExpression = MOUTH_Smile;
	else if( i == 2 )
		MouthExpression = MOUTH_Frown;
}

function SetBrowExpression( int i )
{
	if( i == 0 )
		BrowExpression = BROW_Normal;
	else if( i == 1 )
		BrowExpression = BROW_Raised;
	else if( i == 2 )
		BrowExpression = BROW_Lowered;
}

state Controlled
{
	function BeginState()
	{
		if( bFocusOnPlayer )
		{
			FocusOnPlayer();
		}
		else
		if( PendingFocusTag != '' )
		{
			SetFocus( PendingFocusTag );
		}
	}

	function FocusOnPlayer()
	{
		local PlayerPawn P;

		foreach allactors( class'PlayerPawn', P )
		{
			HeadTrackingActor = P;
			break;
		}
	}

	function SetFocus( name MatchTag )
	{
		local Actor A;

		foreach allactors( class'Actor', A, MatchTag )
		{
			//if( LineOfSightTo( A ) )
			//{
				HeadTrackingActor = A;
				break;
		}
	}

	function Timer( optional int TimerNum )
	{
		if( NextState == 'Controlled' ) 
		{
			GotoState( 'Idling' );
		}
		else
		{
			GotoState( NextState );
		}
	}

Begin:
	if( PendingTopAnimation != '' )
	{
		PlayTopAnim( PendingTopAnimation,, 0.1, false );
	}
	if( PendingBottomAnimation != '' )
	{
		PlayBottomAnim( PendingBottomAnimation,, 0.1, false );
	}
	if( PendingAllAnimation != '' )
	{
		PlayAllAnim( PendingAllAnimation,, 0.1, false );
	}

	if( PendingSound != None )
	{
		PlaySound( PendingSound, SLOT_Talk, SoundDampening * 0.5, true,,, true );
		SetTimer( GetSoundDuration( PendingSound ), false );
	}
	else
	{
		if( PendingTopAnimation != '' )
		{
			FinishAnim( 1 );
		}
		if( PendingBottomAnimation != '' )
		{
			FinishAnim( 2 );
		}
		if( PendingAllAnimation != '' )
		{
			FinishAnim( 0 );
		}
		if( NextState == 'Controlled' )
			GotoState( 'Attacking' );
		else
		{
			GotoState( NextState );
		}
	}
}

/*-----------------------------------------------------------------------------
	NPC Controlled State.
-----------------------------------------------------------------------------*/
state ActivityControl
{
	function HitWall( vector HitNormal, actor HitWall )
	{
		if ( HitWall.IsA('DoorMover')  )
		{
			SpecialPause = 0.45;
			if ( SpecialPause > 0 )
			{
				StopMoving();
				NotifyMovementStateChange( MS_Waiting, MS_Walking );
			}
			PendingDoor = HitWall;
			GotoState('ActivityControl', 'SpecialNavig');
			return;
		}
		else
			Super.HitWall( HitNormal, HitWall );
	}

	function Bump( actor Other )
	{
		if( Other.IsA( 'dnDecoration' ) && MoveTimer > 0.0 )
		{
			Obstruction = Other;
			GotoState( 'ActivityControl', 'AdjustMovement' );
		}
		else
		if( Other.IsA( 'PlayerPawn' ) && MoveTimer > 0.0 && MyAE.bWaitWhenBlocked )
		{
			if( !RouteClear() )
			{
				StopMoving();
				GotoState( 'ActivityControl', 'WaitForBlockingPawn' );
			}
		}
		else
			Super.Bump( Other );
	}
	
	function BeginState()
	{
		//// // // // // log( "ActivityControl state entered by: "$self );
	}

	function Timer( optional int TimerNum )
	{
		local actor A;

		if( TimerNum == 1 )
		{
			log( "ACTIVITY TIMER" );
			foreach allactors( class'Actor', A, MyAE.SoundEvent )
			{	
				if( A.IsA( 'NPCActivityEvent' ) && ( NPCActivityEvent( A ).NPCTag == Tag || NPCActivityEvent( A ).Event == Tag ) )
					PendingTriggerActor = A;
				else
				{
					A.Trigger( MyAE, self );
				}
				// JEP...
				//SetFacialExpression( FacialExpression );
				SetFacialExpressionIndex( FacialExpressionIndex );
				// ...JEP
				log( "GOTO STATE 1" );
				GotoState( 'ActivityControl', 'Exiting' );
				//A.Trigger( MyAE, self );
			}
		}
	} 

	function bool RouteClear()
	{
		local actor HitActor;
		local vector HitLocation, HitNormal;

		HitActor = Trace( HitLocation, HitNormal, Location + vector( Rotation ) * 256, Location, true );
		if( HitActor != None && HitActor.IsA( 'Pawn' ) )
			return false;
		else
			return true;
	}

	function bool KneeLineOfSightTo( actor DestActor )
	{
		local actor HitActor;
		local vector HitLocation, HitNormal;

		HitActor = Trace( HitLocation, HitNormal, DestActor.Location, Location + vect( 0, 0, -12 ), true );
		if( HitActor != None && ( HitActor == DestActor || !HitActor.IsA( 'LevelInfo' ) ) )
			return true;

		return false;
	}

	function SeePlayer( actor Seen )
	{
		if( bAggressiveToPlayer )
		{
			Enemy = Seen;
			GotoState( 'ApproachingENemy' );
		}
	}

Begin:

//	PlayActivityAnim();
//	PlayToWaiting();
	PendingTriggerActor = None;
	if( MyAE.bStopMoving && MyAE.bUseStopMoving )
	{
		StopMoving();
	}
	if( MyAE.DefaultAllAnim != '' )
	{
		InitialIdlingAnim = MyAE.DefaultAllAnim;
	}
	if( MyAE.bWeaponDown )
	{
		//PlayTopAnim( 'T_Hypo_Arm',,, true );
		PlayTopAnim('T_WeaponChange1', 0.5, 0.2, false );
		FinishAnim( 1 );
		Weapon.ThirdPersonMesh = None;
//		Sleep( 5.0 );
	}
	else if( MyAE.bWeaponUp )
	{
		PlayTopAnim('T_WeaponChange2', 0.5, 0.2, false );
		FinishAnim( 1 );
		Weapon.ThirdPersonMesh = Weapon.Default.ThirdPersonMesh;
	}
	if( MyAE.FocusTag != '' || MyAE.bUseFocusTag )
	{
		if( !MyAE.bWillNotHeadTrack )
			HeadTrackingActor = MyAE.GetFocusActor();
		if( MyAE.bWillNotTorsoTrack )
			bCanTorsoTrack = false;
		if( MyAE.bWillNotTurn )
		{

			RotationRate.Yaw *= 0;
			RotationRate.Pitch *= 0;
		}
	// turn 2
		if ( NeedToTurn(HeadTrackingActor.Location) && !MyAE.bWillNotTurn && CanSee( HeadTrackingActor ) )
		{
			//if ((rotator(HeadTrackingActor.Location - Location) - Rotation).Yaw < 0)
			//	PlayTurnLeft();
			//else
			//	PlayTurnRight();

			TurnToward( HeadTrackingActor );
			if( isAnimating( 2 ) )
				FinishAnim( 2 );
			PlayToWaiting();
		}

	}
//	else 
//	{
//		// log( MyAE$" resetting focus." );
//		HeadTrackingACtor = None;
//	}
	if( MyAE.AnimSeqAll != '' )
	{

		// log( MyAE$" Playing All Animation: "$MyAE.AnimSeqAll );
		if( GetSequence( 0 ) != MyAE.AnimSeqAll )
			PlayAllAnim( MyAE.AnimSeqAll, MyAE.GetRate( 0 ), MyAE.GetTweenTime( 0 ), MyAE.bLoopAllAnim );
	}
	/*
	// JEP Work in progress (need to convert all other classes to use FacialExpressionIndex instead of the enum
	if( MyAE.AnimSeqFace != FACE_NoChange )
	{
		// log( MyAE$" Playing Face Animation: "$MyAE.AnimSeqFace );
		SetFacialExpression( MyAE.AnimSeqFace, MyAE.bMakeFaceDefault, !MyAE.bLoopFaceAnim );
	}
	*/
	if( MyAE.AnimSeqTop != '' )
	{
		// log( MyAE$" Playing Top Animation: "$MyAE.AnimSeqTop );
		if( GetSequence( 1 ) != MyAE.AnimSeqTop )
			PlayTopAnim( MyAE.AnimSeqTop, MyAE.GetRate( 1 ), MyAE.GetTweenTime( 1 ), MyAE.bLoopTopAnim );
	}
	if( MyAE.AnimSeqBottom != '' )
	{
		// log( MyAE$" Playing All Animation: "$MyAE.AnimSeqBottom );
		if( GetSequence( 2 ) != MyAE.AnimSeqBottom )
			PlayBottomAnim( MyAE.AnimSeqBottom, MyAE.GetRate( 2 ), MyAE.GetTweenTime( 2 ), MyAE.bLoopBottomAnim );
	}
	if( MyAE.SoundToPlay != None )
	{
		/*
		// JEP Work in progress (need to convert all other classes to use FacialExpressionIndex instead of the enum
		if( MyAE.SoundFacialExpression != FacialExpression )
		{
			SetFacialExpression( MyAE.SoundFacialExpression );
		}
		*/

		if( MyAE.PauseBeforeSound > 0.0 )
		{

			// log( MyAE$" pausing "$MyAE.PauseBeforeSound$" before sound." );
			Sleep( MyAE.PauseBeforeSound );
		//	SetTimer( MyAE.PauseBeforeSound, false );
		}
//		else
//		{
//		Timer();
		//bLipSync = !MyAE.bNoLipSync;
		// log( MyAE$" playing sound: "$MyAE.SoundToPlay );
		PlaySound( MyAE.SoundToPlay, SLOT_Talk, SoundDampening * 0.5, false,,, true  );
		if( MyAE.SoundEvent != '' && MyAE.SoundToPlay != None )
		{
			// log( MyAE$" setting timer for event: "$MyAe.SoundEvent );
			Global.SetTimer( GetSoundDuration( MyAE.SoundToPlay ), false, 1 );

		}

//		}
	}
	if( MyAE.AnimSeqAll != '' )
	{

		if( !MyAE.bLoopAllAnim )
		{
			// log( MyAE$" finishing AllAnim." );
			if( !MyAE.bCanInterruptAll )
			{
				FinishAnim( 0 );
			}
			if( MyAE.DefaultAllAnim != '' )
				PlayAllAnim( MyAE.DefaultAllAnim,, 0.1, true );
		}
		else if( MyAE.LoopTimeAll > 0.0 )
		{
			Sleep( MyAE.LoopTimeAll );
		}
//		PlayToWaiting();
		// // // // // log( "FINISHED ALL ANIM" );
		// // // // // log( "MyAE: "$MyAE );
		// // // // // log( "Event: "$MyAE.EventAllAnim2 );

		// // // // // log( "EventAllAnim2: "$MyAE.EventAllAnim2 );
	//	if( MyAE.EventAllAnim2 != '' )
	//		MyAE.TriggerEvent( MyAE.EventAllAnim2, self );

		if( MyAE.EventAllAnim != '' )
		{
		//	Global.SetTimer( 0.25, false, 2 );
			MyAE.TriggerEvent( MyAE.EventAllAnim, self );
		//	GotoState( 'Idling' );
		}
		MyAE.TriggerAllAnimEvents( self );
	}
	if( MyAE.AnimSeqTop != '' )
	{
		if( !MyAE.bLoopTopAnim )
		{	
			 log( MyAE$" finishing top animation" );
			FinishAnim( 1 );
		}
		else if( MyAE.LoopTimeTop > 0.0 )
		{
			 log( MyAE$" sleeping for TopAnim LoopTime: "$MyAE.LoopTimeTop );
			Sleep( MyAE.LoopTimeTop );
		}
		//PlayTopAnim( 'None' );
		//PlayToWaiting();
		if( MyAE.EventTopAnim != '' )
		{
			// log( MyAE$" trigering event for top animation." );
			MyAE.TriggerEvent( MyAE.EventTopAnim, self );
		}
		MyAE.TriggerTopAnimEvents( self );
	}
	if( MyAE.AnimSeqBottom != '' )
	{
		if( !MyAE.bLoopBottomAnim )
		{
			// log( MyAE$" finishing bottom animation" );
			FinishAnim( 2 );
		}
		if( MyAE.EventBottomAnim != '' )
			MyAE.TriggerEvent( MyAE.EventBottomAnim, self );
		MyAE.TriggerBottomAnimEvents( self );

	}
	AEDestination = MyAE.GetActivityDestination();
	if( AEDestination != None )
	{
		// log( MyAE$" found destination. Going to moving." );
		Goto( 'Moving' );
	}
	else if( MyAE.ItemClass != none )
	{
		MyGiveItem = Spawn( MyAE.ItemClass, self );
		if( MyGiveItem.IsA( 'Inventory' ) )
		{
			Inventory( MyGiveItem ).PickupNotifyPawn = self;
		}

		Inventory( MyGiveItem ).bDontPickupOnTouch = true;

		if( MyAE.bUseItemScale )
		{
			MyGiveItem.DrawScale = MyAE.ItemScale;
		}

		MyGiveItem.AttachActorToParent( self, false, false );
		if( MyAE.GiveItemTag != '' )
		{
			MyGiveItem.Tag = MyAE.GiveItemTag;
		}
		MyGiveItem.MountOrigin = MyAE.ItemMountOrigin;
		MyGiveItem.MountAngles = MyAE.ItemMountAngles;
		MyGiveItem.MountMeshItem = MyAE.MountPoint;
		//MyGiveItem.MountMeshItem = 'Hand_L';
		MyGiveItem.MountType = MOUNT_MeshBone;
		MyGiveItem.SetPhysics( PHYS_MovingBrush );
		GotoState( 'WaitingToGive' );
	}
	else
	{
		log( MyAE$" no new destination found. Going to Idling state." );
		if( MyAE.bUseHateTag )
		{
			TriggerHate();
		}
		else
		{
			log( self$" Idling 1" );
			GotoState( 'Idling' );
		}
	}

Moving:
	if( MyAE.bUsePhysics )
	{
		SetPhysics( MyAE.MovePhysics );
	}
	if( LineOfSightTo( AEDestination ) && ( !MyAE.bLowerLOS || KneeLineOfSightTo( AEDestination ) ) ) //&& KneeLineOfSightTo( AEDestination ) )
	{
		// // log( self$" I have line of sight to "$AEDestination );

		NotifyMovementStateChange( MS_Walking, MS_Waiting );
		if( !MyAE.bRunning )
		{
			NotifyMovementStateChange( MS_Walking, MS_Waiting );
			PlayToWalking();
			MoveToward( AEDestination, WalkingSpeed );
			if( VSize( Location - AEDestination.Location ) < 48 )
			{
				StopMoving();
				AEDestination = None;
				PlayToWaiting();
			}
			else
				Goto( 'Moving' );
		}
		else
		{
			NotifyMovementStateChange( MS_Running, MS_Waiting );
			PlayToRunning();
			MoveToward( AEDestination, GetRunSpeed() );
			if( VSize( Location - AEDestination.location ) < 48 )
			{
				StopMoving();
				AEDestination = None;
				PlayToWaiting();
			}
			else
				Goto( 'Moving' );
		}
//		Global.SetTimer( 2.0, false, 2 );
//		PlayToWaiting();
		MyAE.TriggerMovementEvent( self );
//
//		// // // // // log( "Moving 2" );
//		GotoState( NextState );
	}

	else if( !FindBestPathToward( AEDestination, true ) )
	{
		AEDestination = None;
		if( MyAE.bUseHateTag )
		{
			TriggerHate();
		}
		else
		{
			// // log( self$" Idling 2" );
			GotoState( 'Idling' );
		}
	}
	else
	{
		NotifyMovementStateChange( MS_Walking, MS_Waiting );
		if( !MyAE.bRunning )
		{
			PlayToWalking();
			MoveTo( Destination, WalkingSpeed );
		}
		else
		{
			PlayToRunning();
			MoveTo( Destination, GetRunSpeed() );
		}
		if( VSize( Location - AEDestination.Location ) < MyAE.DestinationOffset )
		{
			StopMoving();
			PlayToWaiting();
			AEDestination = None;
			MyAE.TriggerMovementEvent( self );
			//Global.SetTimer( 2.0, false, 2 );
			//PlayToWaiting();
			if( MyAE.bUseHateTag )
			{
				TriggerHate();
			}
			else
				GotoState( NextState );
		}
		else
			Goto( 'Moving' );
	}


Exiting:
	// // // // // log( "IdleStandInactive 5" );
	PlayAllAnim( 'A_IdleStandInactive',, 0.5, true );
	if( PendingTriggerActor != None )
		PendingTriggerActor.Trigger( MyAE, self );
	if( MyAE.bUseHateTag )
	{
		TriggerHate();
	}


AdjustMovement:
	if( Obstruction != None )
	{
		StopMoving();
		PlayAllAnim( 'A_Kick_Front',, 0.2, false );
		Obstruction.TakeDamage( 10000, self, Obstruction.Location, vect( 0, 0, 0 ), class'KungFuDamage' );
		FinishAnim( 0 );
		PlayToWaiting();
	if ( NeedToTurn(AEDestination.Location) )
	{
		//if ((rotator(AEDestination.Location - Location) - Rotation).Yaw < 0)
		//	PlayTurnLeft();
		//else
		//	PlayTurnRight();
		TurnToward( AEDestination );
		PlayToWaiting();
	}
		Goto( 'Moving' );
	}

WaitForBlockingPawn:
	PlayToWaiting();
	if( RouteClear() )
	{
		Sleep( 0.3 );
		Goto( 'Moving' );
	}
	else
	{
		Sleep( FRand() );
		Goto( 'WaitForBlockingPawn' );
	}

SpecialNavig:
	if( PendingDoor != None && PendingDoor.IsA( 'DoorMover' ) && !DoorMover( PendingDoor ).bLocked && DoorMover( PendingDoor ).bKickable )
	{
		if ( SpecialPause > 0.0 )
		{
				StopMoving();
				TurnTo(PendingDoor.Location);
				PlayToWaiting();
			//}
			PlayAllAnim( 'A_Kick_Front',, 0.2, false );
			DoorMover( PendingDoor ).Trigger( self, self );			
			FinishAnim( 0 );
			PlayToWaiting();
			SpecialPause = 0;
		}
		else
		{
			Focus = Destination;
			if (PickWallAdjust())
				GotoState('ActivityControl', 'AdjustFromWall');
			else
				MoveTimer = -1.0;
		}
		//// // // // // log( "SpecialPause: "$SpecialPause );
		Sleep(SpecialPause);
		
		DoorMover( PendingDoor ).bLocked = DoorMover( PendingDoor ).Default.bLocked;
		
		SpecialPause = 0.0;
		Goto( 'Moving' );
	}

}

state WaitingToGive
{
	function Timer( optional int TimerNum )
	{
		if( IsInState( 'WaitingToGive' ) )
		{
			GotoState( 'Idling' );
		}
	}

	function Bump( actor Other )
	{}

	function ReactToJump()
	{}

	function NotifyPickup( actor Other, Pawn EventInstigator )
	{
		local actor A;

		local int i;

		if( MyGiveItem.IsA( 'Inventory' ) )
		{
			for( i = 0; i < 5; i++ )
			{
				if( MyGiveItem.Class == SearchableItems[ i ] )
				{
					SearchableItems[ i ] = None;
				}
			}
			Inventory( MyGiveItem ).bDontPickupOnTouch = false;
			MyGiveItem = None;
		}

		if( MyAE != None && MyAE.TakeEvent != '' )
		{
			foreach allactors( class'Actor', A, MyAE.TakeEvent )
				A.Trigger( MyAE, self );
		}
		if( MyAE.bResetIdleAnim )
			InitialIdlingAnim = Default.InitialIdlingAnim;
		PlayToWaiting();
		log( "WAITING TO GIVE SET TIMER" );
		SetTimer( 2.0, false );
	}

	// Do we want anything to happen when he's used?
	function Used( actor Other, Pawn EventInstigator )
	{
	}
}

/*-----------------------------------------------------------------
	NPC Patrolling State.
-----------------------------------------------------------------------------*/

state Patrolling
{
	ignores SeeMonster;

	event MayFall()
	{
		bCanJump = true;
	}

	function HearNoise(float Loudness, Actor NoiseMaker)
	{
		local vector OldLastSeenPos;
		
		return;

		if( NoiseMaker.IsA( 'HITPACKAGE_Level' ) )
		{
			bCanTorsoTrack = true;
			HeadTrackingActor = NoiseMaker;

			NoiseInstigator = NoiseMaker.Instigator;
			if( NoiseInstigator.IsA( 'PlayerPawn' ) )
			{
				Enemy = NoiseInstigator;
				StopMoving();
				GotoState( 'Reacting' );
			}
		}

		if( bAggressiveToPlayer && NoiseMaker.IsA( 'PlayerPawn' ) || ( bAggressiveToPlayer && NoiseMaker.Instigator.IsA( 'PlayerPawn' ) ) )
		{
			
			Enemy = NoiseMaker.Instigator;
			if( Enemy != None )
			{
				StopMoving();
				GotoState( 'Attacking' );
			}
		}
	}

	function SeeFocalPoint( actor Seen )
	{
		HeadTrackingActor = Seen;
		Disable( 'SeeFocalPoint' );
		Enable( 'FocalPointNotVisible' );
	}

	function FocalPointNotVisible()
	{
		HeadTrackingActor = None;
		Disable( 'FocalPointNotVisible' );
		Enable( 'SeeFocalPoint' );
	}

	function SeeMonster( actor Seen )
	{
		HeadTrackingActor = Seen;
		Enemy = Seen;
		Disable( 'SeeMonster' );
		// // // // log( "ENABLE 2" );
		Enable( 'EnemyNotVisible' );
	}


/*function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> DamageType)
	{
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 )
			return;
		Enemy = instigatedBy;
		if ( Enemy != None )
			LastSeenPos = Enemy.Location;

		if( !bSnatched && !bAggressiveToPlayer && Weapon == None )
		{
			GotoState( 'Cowering' );
			return;
		}

		if ( NextState == 'TakeHit' )
		{
			NextState = 'Attacking'; 
			NextLabel = 'Begin';
			GotoState('TakeHit'); 
		}
		else
			GotoState('Attacking');
	}
	*/
//	function HearNoise( float Loudness, Actor NoiseMaker )
//	{
//	}

	function SeePlayer( Actor SeenPlayer )
	{
// // // // log( "SEE PLAYER 3" );
		// // // log( "bPatrolIgnoreSeePlayer was "$bPatrolIgnoreSeePlayer );

		if( bPatrolIgnoreSeePlayer )
			return;

		if( bAggressiveToPlayer )
		{
			Enemy = SeenPlayer;
			HeadTrackingActor = SeenPlayer;
			//Disable( 'SeePlayer' );
			// // // // log( "ENABLE 3" );
			Enable( 'EnemyNotVisible' );
			CurrentPatrolControl = None;
			StopMoving();
			PlayToWaiting( 0.12 );
			ChooseAttackState();
			
		}
		else if( CurrentPatrolControl != None && CurrentPatrolControl.bAutoLookAt && !HeadTrackingActor.IsA( 'FocalPoint' ) )
		{
			//HeadTrackingActor = SeenPlayer;
			//Enemy = SeenPlayer;
			//Enable( 'EnemyNotVisible' );
			//Disable( 'SeePlayer' );
		}			
		else
			Disable( 'SeePlayer' );
	}

	
	function EnemyNotVisible()
	{
		HeadTrackingActor = None;
		Enemy = None;
		Disable( 'EnemyNotVisible' );
		Enable( 'SeePlayer' );
	}

	function AnimEnd()
	{
		if( GetSequence( 0 ) == 'A_StandToWalk' ) 
		{
			PlayAllAnim('A_Walk',,0.1,true);
			Disable( 'AnimEnd' );
		}
	}

//	function AnimEnd()
//	{	
//		if( CurrentPatrolEvent != None )
//		{
//			GotoState( 'Patrolling', 'Patrol' );
//		}
//	}
	
	// Special PatrolWaiting function for PatrolState to handle possible cases of overridden idle anims.
	function PlayPatrolWaiting()
	{
		local float f;

		PlayTopAnim( 'None' );
		PlayBottomAnim('None');
		bWalkMode = true;

		if( CurrentPatrolEvent != None )
		{
			if( CurrentPatrolEvent.AllAnim != 'None' )
			{
				PlayTopAnim( 'None' );
				PlayBottomAnim( 'None' );

				PlayAllAnim( CurrentPatrolEvent.AllAnim );
			}
		
			if( CurrentPatrolEvent.TopAnim != 'None' )
			{
				PlayTopAnim( CurrentPatrolEvent.TopAnim,, 0.1, false );
				//HeadTracking.DesiredWeight = 0;
			}

			if( CurrentPatrolEvent.BottomAnim != 'None' )
			{
				PlayBottomAnim( CurrentPatrolEvent.BottomAnim,, 0.1, false );
			}
		}
	}

	function Bump( actor Other )
	{
		local vector VelDir, OtherDir;
		local float speed, dist;
		local Pawn P,M;
		local bool bDestinationObstructed, bAmLeader;
		local int num;

		P = Pawn(Other);
		
		if( !P.IsA( 'PlayerPawn' ) ) 
		{
			MoveTimer = -1.0;
			StopMoving();
			PlayToWAiting( 0.12 );
			if( Enemy != None )
				ChooseAttackState();
			else
				GotoState( 'Idling' );
		}

		if ( TimerRate[ 0 ] <= 0 )
		{
			setTimer( 0.2, false );
		}
		if( P != None && MoveTarget != None )
		{
			OtherDir = P.Location - MoveTarget.Location;
			if ( abs( OtherDir.Z ) < P.CollisionHeight )
			{	
				OtherDir.Z = 0;
				dist = VSize( OtherDir );
				bDestinationObstructed = ( VSize( OtherDir ) < P.CollisionRadius ); 
				if ( P.IsA( 'HumanNPC' ) )
					bAmLeader = ( HumanNPC( P ).DeferTo( self ) || ( PlayerReplicationInfo.HasFlag != None ) );

				// Check if someone else is on destination or within 3 * CollisionRadius
				for ( M=Level.PawnList; M != None; M=M.NextPawn )
					if ( M != self )
					{
						dist = VSize( M.Location - MoveTarget.Location );
						if ( dist < M.CollisionRadius )
						{
							bDestinationObstructed = true;
							if ( M.IsA( 'HumanNPC' ) )
								bAmLeader = HumanNPC( M ).DeferTo( self ) || bAmLeader;
						}
						if ( dist < 3 * M.CollisionRadius ) 
						{
							num++;
							if ( num >= 2 )
							{
								bDestinationObstructed = true;
								if ( M.IsA( 'HumanNPC' ) )
									bAmLeader = HumanNPC( M ).DeferTo( self ) || bAmLeader;
							}
						}
					}
				
				if ( bDestinationObstructed && !bAmLeader )
				{
					// P is standing on my destination
					MoveTimer = -1;
					// Enemies don't exist yet. :P
					
					if ( (Health > 0) && !IsInState('Wandering') || (Acceleration == vect(0,0,0)) )
					{
						// JC: Should be optional to have HumanNPC go off wandering and breaking patrol if
						// his route is obstructed. Should be optional to have him attempt to resume
						// his patrol after a certain amount of time.  3 failures = give up entirely to
						// prevent from looking stupid over and over?
						if( Other.IsA( 'HumanNPC' ) )
						{
							HumanNPC( Other ).HeadTrackingActor = Self;
						}
					
						WanderDir = Normal(Location - P.Location);
						CurrentPatrolControl.SetTimer( 22 + FRand(), true );
						HeadTrackingActor = Other;
						// // // // // log( "GOING TO WANDERING STATE 1" );
						GotoState('Wandering', 'Begin');
						// JC: Here is determined what to do about bumping into someone else on patrol.
						// ADD A BUMP EVENT HERE
						//GotoState( 'Patrolling', 'BumpEvent' );
					}
				}
			}
		}	
		speed = VSize(Velocity);
		if ( speed > 10 )
		{
			VelDir = Velocity/speed;
			VelDir.Z = 0;
			OtherDir = Other.Location - Location;
			OtherDir.Z = 0;
			OtherDir = Normal(OtherDir);
			if ( (VelDir Dot OtherDir) > 0.8 )
			{
				Velocity.X = VelDir.Y;
				Velocity.Y = -1 * VelDir.X;
				Velocity *= FMax(speed, 280);
			}
		} 
		else if ( (Health > 0) && (Enemy == None) && (bCamping || ((Orders == 'Follow') && (MoveTarget == OrderObject) && (MoveTarget.Acceleration == vect(0,0,0)))) )
		{
			// // // // // log( "GOING TO WANDERING 2" );
			GotoState('Wandering', 'Begin');
		}
		Disable('Bump');
	}

	function SetFall()
	{
		NextState = 'Patrolling'; 
		NextLabel = 'ResumePatrol';
		//NextAnim = AnimSequence;
		GotoState('FallingState'); 
	}

	function HitWall(vector HitNormal, actor Wall)
	{
		// log( self$" HITWALL!!!" );

		log( self$" **** HIT WALL!!! FROM PATROLLING" );

		if( Physics == PHYS_Falling )
		{
			return;
		}
		
		if( Wall.IsA( 'Mover' ) && Mover( Wall ).HandleDoor( self ) )
		{
			if( SpecialPause > 0 )
				Acceleration = vect( 0,0,0 );
			GotoState( 'Patrolling', 'SpecialNavig' );
			return;
		}

		Focus = Destination;
		if( PickWallAdjust() )
		{
			GotoState( 'Patrolling', 'AdjustFromWall' );
		}
		else
		{
			MoveTimer = -1.0;
		}
	}
	
	function Timer( optional int TimerNum )
	{
		Enable('Bump');
	}

	
	// Temporarily disabled (JC) 
	function EnemyAcquired()
	{
		//log(Class$" just acquired an enemy");
		//GotoState('Acquisition');
	}
	
	function PickDestination()
	{
		local Actor Path;
		
		// // // log( "ORDER OBJECT FOR "$self$" is "$OrderObject );

		// log( self$" == pickDestination called from PatrolState 1" );
		Path = None;
		if( SpecialGoal != None )
		{
			// log( self$" == pickDestination called from PatrolState 2" );

			Path = FindPathToward( SpecialGoal );
		}
		else if( OrderObject != None )
		{
		 // log( self$" == pickDestination called from PatrolState 3" );

			Path = FindPathToward( OrderObject );
		}
		if( Path != None )
		{
			 // log( self$" == pickDestination called from PatrolState 4" );
			MoveTarget = Path;
			Destination = Path.Location;
			// // // log( "***** NEW MOVETARGET: "$MoveTarget );
		}
		else
		{
			 // log( self$" == pickDestination called from PatrolState 5" );
			OrderObject = None;
		}
	}

	/*function bool FindNextPatrol()
	{
		if( CurrentPatrolPoint != None )
		{
			OrderObject = CurrentPatrolControl.GetNextPatrolPoint( CurrentPatrolPoint );
		}
		else
		{
			OrderObject = CurrentPatrolControl.GetNextPatrolPoint( CurrentPatrolPoint );
		}
		if( CurrentPatrolPoint == NavigationPoint( OrderObject ) )
			return false;

		CurrentPatrolPoint = NavigationPoint( OrderObject );
		return true;
	}*/

	function bool FindNextPatrol()
	{
		if( CurrentPatrolPoint != None )
		{
			OrderObject = CurrentPatrolControl.GetNextPatrolPoint( CurrentPatrolPoint );
		}
		else
		{
			OrderObject = CurrentPatrolControl.GetNextPatrolPoint( CurrentPatrolPoint );
		}
		//if( CurrentPatrolPoint == NavigationPoint( OrderObject ) )
		//	return false;
		if( CurrentPatrolPoint == NavigationPoint( OrderObject ) )
			return false;

		CurrentPatrolPoint = NavigationPoint( OrderObject );
		return true;
	}


	function TriggerActor( name MatchTag )
	{
		local actor A;

		foreach allactors( class'Actor', A, MatchTag )
		{
			A.Trigger( self, self );
		}
	}

	function TriggerEvent( name MatchTag )
	{
		local Actor A;

		foreach allactors( class'Actor', A )
		{
			if( A.Tag == MatchTag )
				A.Trigger( self, self );
		}
	}

	function EndState()
	{
		if( EndPatrolEvent != '' )
		{
			TriggerEvent( EndPatrolEvent );
		}
		Default.PeripheralVision = OldPeripheralVision;
		SightRadius = Default.SightRadius;
	}


	function BeginState()
	{
//		// // // // // log( "--- "$self$" entered patrolling state at "$level.timeseconds );
//		// // // // // log( "--- "$self$" weapon is: "$Weapon );

		//SwitchToBestWeapon();
		if( bPanicOnFire && ImmolationActor == None )
		{
			bPanicking = true;
			ImmolationActor = spawn( class<ActorDamageEffect>(DynamicLoadObject( ImmolationClass, class'Class' )), Self );
			ImmolationActor.Initialize();
		}

		if( bPatrolIgnoreSeePlayer )
			Disable( 'SeePlayer' );
		if( StartPatrolEvent != '' )
		{
			// // // // // log( "Calling trigger event for "$StartPatrolEvent );
			TriggerEvent( StartPatrolEvent );
		}
		HeadTrackingActor = None;

		enable( 'AnimEnd' );

		if( CurrentPatrolControl == None )
		{
			CurrentPatrolControl = GetPatrolControl();
		}
		if( CurrentPatrolControl.NewSightRadius != 0.0 )
			SightRadius = CurrentPatrolControl.NewSightRadius;
		bCanTorsoTrack = false;
		if( CurrentPatrolControl == None )
		{
			bPatrolled = true;
			GotoState( 'Idling' );
		}
		else if( CurrentPatrolControl.NewPeripheralVision != 0.0 )
		{
			// // // // // log( "Setting up new peripheral vision to "$CurrentPatrolControl.NewPeripheralVision );
		//// // // // // log( "SETTING PERIPH 3" );
			Default.PeripheralVision = CurrentPatrolControl.NewPeripheralVision;
			PeripheralVision = CurrentPatrolControl.NewPeripheralVision;
			// // // // // log( "new periph is "$PeripheralVision );
			// // // // // log( "new default is "$Default.PeripheralVision );

		}
		if( CurrentPatrolControl.PatrolType == PATROL_Linear )
			FinalPatrolPoint = CurrentPatrolControl.GetLastPatrolPoint();

		SpecialGoal = None;
		SpecialPause = 0.0;
		Disable('AnimEnd');
		SetAlertness(0.0);
		bReadyToAttack = (FRand() < 0.3 + 0.2 * skill); 
		if( CurrentPatrolControl != None && CurrentPatrolControl.bAutoLookAt )
			Enable( 'SeeMonster' );
		else
			Disable( 'Seemonster' );

		if( !CurrentPatrolControl.bAutoLookAt )
		{
			Disable( 'SeeFocalPoint' );
		}
		else
			Enable( 'SeeFocalPoint' );
		
		if( CurrentPatrolControl.TempMaxStepHeight != 0 )
			MaxStepHeight = CurrentPatrolControl.TempMaxStepHeight;
		
		Disable( 'EnemyNotVisible' );
	}

	function SetNewPatrolEvent( PatrolEvent NewEvent )
	{
		CurrentPatrolEvent = NewEvent;
	}

	function vector TestFunction()
	{
		local vector X, Y, Z;

		GetAxes( CurrentPatrolPoint.Rotation, X, Y, Z );
		//return Location + X * 10;
		return CurrentPatrolPoint.Location + X * 10;
	}

AdjustFromWall:
	StrafeTo(Destination, Focus); 
	Destination = Focus; 
	if( CurrentPatrolControl.bRunning )
		MoveTo( Destination, GetRunSpeed() );
	else
		MoveTo(Destination, WalkingSpeed);
	Goto('MoveToPatrol');

ResumePatrol:
	if (MoveTarget != None)
	{
		//NotifyMovementStateChange( MS_Walking, MS_Waiting );
		if( GetSequence( 0 ) != 'A_Walk' ) 
		{
			bWalkMode = true;
			//NotifyMovementStateChange( MS_Walking, MS_Waiting );
			Enable( 'AnimEnd' );
			PlayAllAnim( 'A_StandToWalk',, 0.1, false );
			Sleep( 0.12 );
		}

		if( CurrentPatrolControl.bRunning )
			MoveToward( MoveTarget, GetRunSpeed() );
		else
			MoveToward(MoveTarget, WalkingSpeed);
	}
	else
		Goto('Patrol');
Begin:
	log( self$" == Patrolling Begin Label 1" );
	Enable( 'Bump' );
	PlayToWaiting();
	sleep(0.1);
	RunSpeed = 1.25;
Patrol: 
	log( self$" == Patrolling Patrol Label 1" );
	RotationRate.Yaw = Default.RotationRate.Yaw * 0.5;
	
	if( !FindNextPatrol() )
	{
		CurrentPatrolControl = None;
		if( Enemy == None )
		{
			bPatrolled = true;
			GotoState( 'Idling' );
		}
		else
			ChooseAttackState();
	}
	if( bPatrolIgnoreSeePlayer )
		Disable( 'SeePlayer' );
	else
		Enable( 'SeePlayer' );
	if( OrderObject == None )
	{
		log( self$" == Patrolling Patrol Label 2" );
		GotoState( 'Idling' );
	}
	else
		log( self$" ORDER OBJECT: "$OrderObject );

	Disable('AnimEnd');
	if( NavigationPoint( orderObject ) != None )
	{
		log( self$" == Patrolling Patrol Label 3" );
		PlayTopAnim( 'None' );
		PlayBottomAnim( 'None' );

		if( CurrentPatrolControl.bRunning )
			PlayToRunning();
		else if( GetSequence( 0 ) != 'A_Walk' ) 
		{
			bWalkMode = true;
			Enable( 'AnimEnd' );
			PlayAllAnim( 'A_StandToWalk',, 0.1, false );
			Sleep( 0.12 );

		}
		log( self$" == Patrolling Patrol Label 4" );

		numHuntPaths = 0;
MoveToPatrol:
		log( self$" == Patrolling MoveToPatrol Label 1" );

		if (actorReachable(OrderObject))
		{
			log( self$" == Patrolling MoveToPatrol Label 2" );

			if( CurrentPatrolControl.bRunning )
				PlayToRunning();
			else if( GetSequence( 0 ) != 'A_Walk' ) 
			{
				log( self$" == Patrolling MoveToPatrol Label 3" );
				bWalkMode = true;
				Enable( 'AnimEnd' );
				PlayAllAnim( 'A_StandToWalk',, 0.1, false );
				Sleep( 0.12 );
			}
			log( self$" **** PRE MOVE "$self$" OrderObject: "$OrderObject );
			if( !CurrentPatrolControl.bRunning )
			{
				log( "PreMove 1" );
				MoveTo( OrderObject.Location, WalkingSpeed );
			}
			else
			{
				log( "PReMove 2" );
				MoveTo( OrderObject.Location, GetRunSpeed() );
				log( self$" **** DONE MOVE "$self );
			}
		}
		else
		{
			log( self$" calling PickDestination" );
			PickDestination();
			if (OrderObject != None)
			{
				log( self$" == Patrolling MoveToPatrol Label 7 with order object of "$orderobject );

SpecialNavig:
				if (SpecialPause > 0.0)
				{
					log( self$" == Patrolling MoveToPatrol Label 8" );
					Acceleration = vect(0,0,0);
					if( CurrentPatrolControl.bRunning )
						PlayToRunning();
					else if( GetSequence( 0 ) != 'A_Walk' ) 
					{
						bWalkMode = true;
						Enable( 'AnimEnd' );
						PlayAllAnim( 'A_StandToWalk',, 0.1, false );
						Sleep( 0.12 );
					}
					Sleep(SpecialPause);
					SpecialPause = 0.0;
					if( CurrentPatrolControl.bRunning )
						PlayToRunning();
					else if( GetSequence( 0 ) != 'A_Walk' ) 
					{
						bWalkMode = true;
						Enable( 'AnimEnd' );
						PlayAllAnim( 'A_StandToWalk',, 0.1, false );
						Sleep( 0.12 );
					}
				}
				numHuntPaths++;
				if( CurrentPatrolControl.bRunning )
					MoveTo( MoveTarget.Location, GetRunSpeed() );
				else
					MoveTo(MoveTarget.Location, WalkingSpeed);
				if ( numHuntPaths < 30 )
					Goto('MoveToPatrol');
				else
					Goto('GiveUp');
			}

			else
				Goto('GiveUp');
		}
		
ReachedPatrol:		
		// log( self$" == Patrolling Reached Label 1" );

		if( CurrentPatrolControl.PatrolType == PATROL_Linear )
		{
			if( CurrentPatrolPoint == CurrentPatrolControl.GetLastPatrolPoint() )
			{
				TurnTo( TestFunction() );	
				CurrentPatrolControl = None;
				bPatrolled = true;
				GotoState( 'Idling' );
			}
		}

		//	if( !FindNextPatrol() )
		//	{
		//		GotoState( '
	//		{
	//			// // // // // log( "GOING BACK TO PATROL" );
	//			Goto( 'Patrol' );
	//		}
	//	}
		//	// // // // // log( "PATROL REACHED : "$CurrentPatrolPoint );
		//	//TurnTo( vector( CurrentPatrolPoint.Rotation ) );
		//	TurnTo( TestFunction() );
//
//			// // // // // log( "TURNED" );
//			// // // // // log( "ROTATION: "$Rotation );
//			// // // // // log( "COMPARE : "$currentPatrolPoint.Rotation );
//
//			CurrentPatrolControl = None;
//			NPCORders = ORDERS_Idle;
//			GotoState( 'Idling' );
//		}
		
		CurrentPatrolEvent = CurrentPatrolControl.GetPatrolEvent( CurrentPatrolPoint );
		if( CurrentPatrolEvent != None && CurrentPatrolEvent.TriggerEvent != '' )
			TriggerActor( CurrentPatrolEvent.TriggerEvent );
		else
		{
			// // log( self$" == Patrolling Reached Label 2" );
			CurrentPatrolEvent = CurrentPatrolControl.GetPatrolEvent( CurrentPatrolPoint );
			if( CurrentPatrolEvent != None )
				Goto( 'HandlePatrolEvent' );
			Goto('Patrol');
		}
	}

GiveUp:
		// // log( self$" == Patrolling GiveUp Label 1" );
		Acceleration = vect(0,0,0);		
		TweenToPatrolStop(0.3);
		FinishAnim();

DelayedPatrol:
		PlayPatrolStop();

HandleActivityEvent:
	// blah blah blah
	CurrentActivityEvent.Trigger( self, self );


// Break this up into smaller pieces.
HandlePatrolEvent:
		
	//// // // // // log( "--- "$self$" Handling Current Event: "$CurrentPatrolEvent );
	
	if( CurrentPatrolEvent.EventOdds == 0.0 )
	{
		//// // // // // log( "== PatrolEvent "$CurrentPatrolEvent$" tried to execute with odds of 0.0" );
		CurrentPatrolEvent = None;
		Goto( 'Patrol' );
	}
	else if( CurrentPatrolEvent.EventOdds > 0.0 && CurrentPatrolEvent.EventOdds < 1.0 )
	{
		// Check for a NextPatrolEvent field prior to reinitializing CurrentPatrolEvent
	
		if( FRand() > CurrentPatrolEvent.EventOdds )
		{
			if( CurrentPatrolEvent.NextEvent != None )
			{
				// // // // // log( "PLAY NONE 10" );
				PlayTopAnim( 'None' );
				PlayBottomAnim( 'None' );
				CurrentPatrolEvent.NextEvent.Trigger( Self, Self );
			}
			else
			{
				CurrentPatrolEvent = None;
			}
			Goto( 'Patrol' );
		}
	}
	StopMoving();
	if( CurrentPatrolEvent.TurnToTag != '' )
		TurnToward( FindActorTagged(class'Actor', CurrentPatrolEvent.TurnToTag ) );

	if( CurrentPatrolEvent.FocusActor != None )
	{
		//HeadTrackingActor = CurrentPatrolEvent.FocusActor;
		//if( CurrentPatrolEvent.FocusTime > 0.0 )
		//{
		//	MyFocusController = Spawn( class'AIFocusController', self );
		//	MyFocusController.SetTimer( CurrentPatrolEvent.FocusTime, false );
		//}
	}
	else if( CurrentPatrolEvent.bFocusOnPlayer )
	{
		//HeadTrackingActor = CurrentPatrolEvent.GetPlayer();
		//// // // // // log( "::: HeadTrackingActor: "$HeadTrackingActor );
	}
	else
	{
		//HeadTrackingActor = None;
	}
	if( CurrentPatrolEvent.TopAnim != 'None' || CurrentPatrolEvent.BottomAnim != 'None' || CurrentPatrolEvent.AllAnim != 'None' )
	{
		PlayPatrolWaiting();
	}
	else
		NotifyMovementStateChange( MS_Waiting, MS_Walking );
	
	// Disable this if check?
	if( CurrentPatrolEvent.TopAnim == 'None' && CurrentPatrolEvent.AllAnim == 'None' && CurrentPatrolEvent.BottomAnim == 'None' )
		Sleep( CurrentPatrolEvent.PauseDuration );
	else
	{
		if( CurrentPatrolEvent.AllAnim != 'None' )
			FinishAnim( 0 );
		if( CurrentPatrolEvent.TopAnim != 'None' )
			FinishAnim( 1 );
		// Problem here. What if you want to pause AND play a specific bottom, top, or all animation? ugh.
		//if( CurrentPatrolEvent.BottomAnim != 'None' )
		//{
		//	FinishAnim( 2 );
			//PlayBottomAnim( 'None' );
		//}
	}
	if( CurrentPatrolEvent.bToggleWalkMode && CurrentPatrolEvent.bWalkToggleable )
	{
		if( CurrentPatrolControl.bRunning == false )
		{
			CurrentPatrolControl.bRunning = true;
		}
		else
		{	
			CurrentPatrolControl.bRunning = false;
		}
	}
	
	if( CurrentPatrolEvent.bToggleOnceOnly )
	{
		//// // // // // log( "--- "$self$" Removing event for: "$self );
		CurrentPatrolControl.RemovePatrolEvent( CurrentPatrolEvent );
	}
		// Turn head back after this patrol event?
	if( CurrentPatrolEvent.bResetFocusAfterEvent )
	{
		//HeadTrackingActor = None;
	}
		if( CurrentPatrolEvent.NextEvent != None )
	{
		PlayTopAnim( 'None' );
		PlayBottomAnim( 'None' );
		// JC: The old code (above) wasn't properly executing a patrolevent from a patrolevent that was
		// executed by a patrolevent. Er, I swear.
		CurrentPatrolEvent = PatrolEvent( CurrentPatrolEvent.NextEvent );
		GotoState( 'Patrolling', 'HandlePatrolEvent' );
	}
	else
		Goto( 'Patrol' );
BumpEvent:
	StopMoving();
	NotifyMovementStateChange( MS_Waiting, MS_Walking );
	Sleep( 5 + FRand() );
	Goto( 'Patrol' );
}

function bool DeferTo(AIPawn Other)
{
	if ( (Other.PlayerReplicationInfo.HasFlag != None) 
		|| ((Orders == 'Follow') && (Other == OrderObject)) )
	{
		if ( (Enemy != None) && LineOfSightTo(Enemy) )
			GotoState('Attacking');
		else
		{
			Enemy = None;
			OldEnemy = None;
			if ( (Health > 0) && (Acceleration == vect(0,0,0)) )
			{
				WanderDir = Normal(Location - Other.Location);
				// // // // // log( "GOING TO WANDERING C" );
				GotoState('Wandering', 'Begin');
			}
		}
		Other.SetTimer(FClamp(TimerRate[ 0 ], 0.001, 0.2), false);
		return true;
	}
	return false;
}


// To be deleted.
// Called when using movetoward with bAdvancedTactics true to temporarily modify destination
// Am I ever going to need this? Hrm.
event AlterDestination()
{
	local float dir, dist;

	dist = VSize(Destination - Location);
	if ( dist < 120 )
	{
		bAdvancedTactics = false;
		return;
	}

	if ( bTacticalDir )
		Dir = 1;
	else
		Dir = -1;
	Destination = Destination + 1.2 * Dir * dist * Normal((Destination - Location) Cross vect(0,0,1));
}

function AlertNPC( actor WarningActor, optional name WarningType )
{
	if( WarningActor.IsA( 'LaserMine' ) && !LaserMine( WarningActor ).bNPCsIgnoreMe ) //&& SuspiciousActor != WarningActor )
	{
		NotifyMovementStateChange( MS_Running, MS_Walking );
		Destination = Location + 96* Normal(Location - WarningActor.Location); 
		Enemy = WarningActor;
		NextState = 'Attacking';
		GotoState( 'Avoidance' );
	}
}

// Mover has notifies pawn that pawn is underneath it
// JC: This is useful.
function UnderLift(Mover M)
{
	local NavigationPoint N;

	// find nearest lift exit and go for that
	if ( (MoveTarget != None) && MoveTarget.IsA('LiftCenter') )
		for ( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
			if ( N.IsA('LiftExit') && (LiftExit(N).LiftTag == M.Tag)
				&& ActorReachable(N) )
			{
				MoveTarget = N;
				return;
			}
}
 
function SetOrders( ENPCOrders NewOrders, optional Actor OrderGiver )
{
	if( NewOrders != NPCOrders )
	{
		if( ( IsInState( 'Roaming' ) && bCamping ) || IsInState( 'Wandering' ) )
		{
			GotoState( 'Roaming', 'PreBegin' );
		}
		else if( !IsInState( 'Dying' ) )
		{
			GotoState( 'Attacking' );
		}
	}
	Aggressiveness = BaseAggressiveness;
}

function float AdjustDesireFor(Inventory Inv)
{
	if ( inv.class == FavoriteWeapon )
		return 0.35;

	return 0;
}


function PlayGaspSound()
{
	if ( RemainingAir < 2 )
		PlaySound( GaspSound, SLOT_Talk, 2.0 );
	else
		PlaySound( BreathAgain, SLOT_Talk, 2.0 );
}

function ZoneChange(ZoneInfo newZone)
{
	local vector jumpDir;

	if ( newZone.bWaterZone )
	{
		if (!bCanSwim)
			MoveTimer = -1.0;
		else if (Physics != PHYS_Swimming)
		{
			if (Physics != PHYS_Falling)
				PlayDive(); 
			setPhysics(PHYS_Swimming);
			PlayToWaiting();
		}
	}
	else if (Physics == PHYS_Swimming)
	{
		if ( bCanFly )
			 SetPhysics(PHYS_Flying); 
		else
		{ 
			SetPhysics(PHYS_Falling);
			if ( bCanWalk && (Abs(Acceleration.X) + Abs(Acceleration.Y) > 0)
				&& (Destination.Z >= Location.Z) //)
				&& CheckWaterJump(jumpDir) )
				JumpOutOfWater(jumpDir);
		}
	}
}

function JumpOutOfWater(vector jumpDir)
{
	Falling();
	Velocity = jumpDir * WaterSpeed;
	Acceleration = jumpDir * AccelRate;
	velocity.Z = 300; //set here so physics uses this for remainder of tick
	PlayAllAnim( 'A_Jump',, 0.3, true );
	bUpAndOut = true;
}

function PreSetMovement()
{
	if (JumpZ > 0)
		bCanJump = true;
	bCanWalk = true;
	bCanSwim = true;
	bCanFly = false;
	MinHitWall = -0.5;
	bCanOpenDoors = true;
	bCanDoSpecial = true;
	SetPeripheralVision();
	MaxDesiredSpeed = 2;
}

function SetPeripheralVision()
{
	// // // // // log( "SETTING PERIPH 1" );
	if ( bNovice )
		PeripheralVision = 0.7;
	else if ( Skill == 3 )
		PeripheralVision = -0.2;
	else
		PeripheralVision = 0.65 - 0.33 * skill;

	PeripheralVision = FMin(PeripheralVision - BaseAlertness, 0.9);
	SightRadius = Default.SightRadius;
}

function Drowning()
{
	local float depth;
	if (Health <= 0)
		return;

	if ( HeadRegion.Zone.bWaterZone )
	{
		if ( bDrowning )
			Self.TakeDamage(5, None, Location + CollisionHeight * vect(0,0,0.5), vect(0,0,0), class'DrowningDamage'); 
		else if ( !Level.Game.IsA('Assault') )
		{
			bDrowning = true;
			GotoState('FindAir');
		}
		if ( Health > 0 )
			RemainingAir = 2.0;
	}
}		

function JumpOffPawn()
{
	Velocity += (100 + CollisionRadius) * VRand();
	Velocity.Z = 200 + CollisionHeight;
	SetPhysics(PHYS_Falling);
	bJumpOffPawn = true;
	SetFall();
}

//=============================================================================
	
function SetMovementPhysics()
{
	if (Physics == PHYS_Falling)
		return;
	if ( Region.Zone.bWaterZone )
		SetPhysics(PHYS_Swimming);
	else
		SetPhysics(PHYS_Walking); 
}

/*
SetAlertness()
Change creature's alertness, and appropriately modify attributes used by engine for determining
seeing and hearing.
SeePlayer() is affected by PeripheralVision, and also by SightRadius and the target's visibility
HearNoise() is affected by HearingThreshold
*/
function WhatToDoNext(name LikelyState, name LikelyLabel)
{
	local weapon W;

	// log( self$" WhatToNext 1 at "$Level.TimeSeconds );
	BlockedPath = None;
	bDevious = false;
	bFire = 0;
	bAltFire = 0;
	OldEnemy = Enemy;
	bReadyToAttack = false;
	// Start in a state based on orders mode defined by level designer; default to Roaming for now.
	switch ( NPCOrders )
	{
		Case ORDERS_Patrol:
			GotoState( 'Patrolling' );
			break;
		Case ORDERS_Wander:
			GotoState( 'Roaming' );
			break;
		Case ORDERS_Idle:
			GotoState( 'Idling' );
			break;
		Case ORDERS_Follow:
			GetFollowActor();
			GotoState( 'Following' );
			break;
		Default:
			GotoState( 'Idling' );
	}
}

function GetFollowActor()
{
	local actor A;

	foreach allactors( class'Actor', A, FollowTag )
	{
		FollowActor = A;
	}
}

function bool CheckBumpAttack(Pawn Other)
{
	local pawn CurrentEnemy;
	
	if( Other.IsA( 'PlayerPawn' ) && bAggressiveToPlayer && Enemy == None )
	{
		Enemy = Other;
		GotoState( 'Acquisition' );
		return true;
	}
  return false;
}

function Bump(actor Other)
{
	local vector VelDir, OtherDir;
	local float speed, dist;
	local Pawn P,M;
	local bool bDestinationObstructed, bAmLeader;
	local int num;

	P = Pawn(Other);

	if ( (P != None) && CheckBumpAttack(P) )
		return;
	if ( TimerRate[ 0 ] <= 0 )
		setTimer(1.0, false);
	
	if ( (P != None) && (MoveTarget != None) )
	{
		OtherDir = P.Location - MoveTarget.Location;
		if ( abs(OtherDir.Z) < P.CollisionHeight )
		{
			OtherDir.Z = 0;
			dist = VSize(OtherDir);
			bDestinationObstructed = ( VSize(OtherDir) < P.CollisionRadius ); 
			if ( P.IsA('HumanNPC') )
				bAmLeader = ( HumanNPC(P).DeferTo(self) || (PlayerReplicationInfo.HasFlag != None) );

			// check if someone else is on destination or within 3 * collisionradius
			for ( M=Level.PawnList; M!=None; M=M.NextPawn )
				if ( M != self )
				{
					dist = VSize(M.Location - MoveTarget.Location);
					if ( dist < M.CollisionRadius )
					{
						bDestinationObstructed = true;
						if ( M.IsA('HumanNPC') )
							bAmLeader = HumanNPC(M).DeferTo(self) || bAmLeader;
					}
					if ( dist < 3 * M.CollisionRadius ) 
					{
						num++;
						if ( num >= 2 )
						{
							bDestinationObstructed = true;
							if ( M.IsA('HumanNPC') )
								bAmLeader = HumanNPC(M).DeferTo(self) || bAmLeader;
						}
					}
				}
				
			if ( bDestinationObstructed && !bAmLeader )
			{
				// P is standing on my destination
				MoveTimer = -1;
				if ( Enemy != None )
				{
					if ( LineOfSightTo(Enemy) )
					{
						if ( !IsInState('TacticalTest') )
							GotoState('Attacking');
					}
					else if ( !IsInState('WaitingForEnemy') && (FRand() < 0.5) )
					{
						GotoState('WaitingForEnemy');
						LastSeenTime = 0;
						bClearShot = false;
					}		
				}
				else if ( (Health > 0) && !IsInState('Wandering') || (Acceleration == vect(0,0,0)) )
				{
					WanderDir = Normal(Location - P.Location);
					// // // // // log( "GOING TO WANDERING D" );
					GotoState('Wandering', 'Begin');
				}
			}
		}
	}
	speed = VSize(Velocity);
	if ( speed > 10 )
	{
		VelDir = Velocity/speed;
		VelDir.Z = 0;
		OtherDir = Other.Location - Location;
		OtherDir.Z = 0;
		OtherDir = Normal(OtherDir);
		if ( (VelDir Dot OtherDir) > 0.8 )
		{
			Velocity.X = VelDir.Y;
			Velocity.Y = -1 * VelDir.X;
			Velocity *= FMax(speed, 280);
		}
	} 
	else if ( (Health > 0) && (Enemy == None) && (bCamping 
				|| ((Orders == 'Follow') && (MoveTarget == OrderObject) && (MoveTarget.Acceleration == vect(0,0,0)))) )
	{
		// // // // // log( "GOING TO WANDERING E" );
		GotoState('Wandering', 'Begin');
	}
	Disable('Bump');
}
		
singular function Falling()
{
	if (bCanFly)
	{
		SetPhysics(PHYS_Flying);
		return;
	}			
 	if (health > 0)
		SetFall();
}
	
function SetFall()
{
	if (Enemy != None)
	{
		NextState = 'Attacking'; //default
		NextLabel = 'Begin';
		TweenToFalling();
		GotoState('FallingState');
	}
}

function LongFall()
{
	if( !bDamagedByShotgun && GetStateName() != 'Repelling' )
		PlayAllAnim( 'A_DeathFalling',, 0.1, true );
}

event UpdateTactics(float DeltaTime)
{
}

// UpdateEyeHeight() called if bot is viewtarget of a player
event UpdateEyeHeight(float DeltaTime)
{
	local float smooth, bound, TargetYaw, TargetPitch;
	local Pawn P;
	local rotator OldViewRotation;
	local vector T;

	// update viewrotation
	OldViewRotation = ViewRotation;			
	if ( (bFire == 0) && (bAltFire == 0) )
		ViewRotation = Rotation;

	if ( Enemy == None )
	{
		ViewRotation.Roll = 0;
		if ( DeltaTime < 0.2 )
		{
			OldViewRotation.Yaw = OldViewRotation.Yaw & 65535;
			OldViewRotation.Pitch = OldViewRotation.Pitch & 65535;
			TargetYaw = float(ViewRotation.Yaw & 65535);
			if ( Abs(TargetYaw - OldViewRotation.Yaw) > 32768 )
			{
				if ( TargetYaw < OldViewRotation.Yaw )
					TargetYaw += 65536;
				else
					TargetYaw -= 65536;
			}
			TargetYaw = float(OldViewRotation.Yaw) * (1 - 5 * DeltaTime) + TargetYaw * 5 * DeltaTime;
			ViewRotation.Yaw = int(TargetYaw);

			TargetPitch = float(ViewRotation.Pitch & 65535);
			if ( Abs(TargetPitch - OldViewRotation.Pitch) > 32768 )
			{
				if ( TargetPitch < OldViewRotation.Pitch )
					TargetPitch += 65536;
				else
					TargetPitch -= 65536;
			}
			TargetPitch = float(OldViewRotation.Pitch) * (1 - 5 * DeltaTime) + TargetPitch * 5 * DeltaTime;
			ViewRotation.Pitch = int(TargetPitch);
		}
	}

	smooth = FMin(1.0, 10.0 * DeltaTime/Level.TimeDilation);
	// smooth up/down stairs
	If ( (Physics == PHYS_Walking) && !bJustLanded)
	{
		EyeHeight = (EyeHeight - Location.Z + OldLocation.Z) * (1 - smooth) + BaseEyeHeight * smooth;
		bound = -0.5 * CollisionHeight;
		if (EyeHeight < bound)
			EyeHeight = bound;
		else
		{
			bound = CollisionHeight + FMin(FMax(0.0,(OldLocation.Z - Location.Z)), MaxStepHeight); 
			 if ( EyeHeight > bound )
				EyeHeight = bound;
		}
	}
	else
	{
		smooth = FMax(smooth, 0.35);
		bJustLanded = false;
		EyeHeight = EyeHeight * ( 1 - smooth) + BaseEyeHeight * smooth;
	}
}

/* Adjust hit location - adjusts the hit location in for pawns, and returns
true if it was really a hit, and false if not (for ducking, etc.)
*/
simulated function bool AdjustHitLocation(out vector HitLocation, vector TraceDir)
{
	local float adjZ, maxZ;

	TraceDir = Normal(TraceDir);
	HitLocation = HitLocation + 0.5 * CollisionRadius * TraceDir;
	if ( BaseEyeHeight == Default.BaseEyeHeight )
		return true;

	maxZ = Location.Z + BaseEyeHeight + 0.25 * CollisionHeight;
	if ( HitLocation.Z > maxZ )
	{
		if ( TraceDir.Z >= 0 )
			return false;
		adjZ = (maxZ - HitLocation.Z)/TraceDir.Z;
		HitLocation.Z = maxZ;
		HitLocation.X = HitLocation.X + TraceDir.X * adjZ;
		HitLocation.Y = HitLocation.Y + TraceDir.Y * adjZ;
		if ( VSize(HitLocation - Location) > CollisionRadius )	
			return false;
	}
	return true;
}

function HearPickup(Pawn Other);

function GiveUpTactical(bool bNoCharge);

function SeePlayer(Actor SeenPlayer)
{
	if( bFixedEnemy )
		return;

	if( bAggressiveToPlayer )
	{
		if (Enemy == None)
			EnableheadTracking( true );
	}
}


/* NearWall() returns true if there is a nearby barrier at eyeheight, and
changes Focus to a suggested value
*/
function bool NearWall(float walldist)
{
	local actor HitActor;
	local vector HitLocation, HitNormal, ViewSpot, ViewDist, LookDir;

	LookDir = vector(Rotation);
	ViewSpot = Location + BaseEyeHeight * vect(0,0,1);
	ViewDist = LookDir * walldist; 
	HitActor = Trace(HitLocation, HitNormal, ViewSpot + ViewDist, ViewSpot, false);
	if ( HitActor == None )
		return false;

	ViewDist = Normal(HitNormal Cross vect(0,0,1)) * walldist;
	if (FRand() < 0.5)
		ViewDist *= -1;

	if ( FastTrace(ViewSpot + ViewDist, ViewSpot) )
	{
		Focus = Location + ViewDist;
		return true;
	}

	ViewDist *= -1;

	if ( FastTrace(ViewSpot + ViewDist, ViewSpot) )
	{
		Focus = Location + ViewDist;
		return true;
	}

	Focus = Location - LookDir * 300;
	return true;
}

// check for line of sight to target deltatime from now.
function bool CheckFutureSight(float deltatime)
{
	local vector FutureLoc, FireSpot;

	if ( Target == None )
		Target = Enemy;
	if ( Target == None )
		return false;

	if ( Acceleration == vect(0,0,0) )
		FutureLoc = Location;
	else
		FutureLoc = Location + GroundSpeed * Normal(Acceleration) * deltaTime;

	if ( Base != None ) 
		FutureLoc += Base.Velocity * deltaTime;
	//make sure won't run into something
	if ( !FastTrace(FutureLoc, Location) && (Physics != PHYS_Falling) )
		return false;

	//check if can still see target
	if ( FastTrace(Target.Location + Target.Velocity * deltatime, FutureLoc) )
		return true;

	return false;
}

/*
Adjust the aim at target.  
	- add aim error
	- adjust up or down if barrier
*/
function rotator AdjustToss(float projSpeed, vector projStart, int aimerror, bool leadTarget, bool warnTarget)
{
	local rotator FireRotation;
	local vector FireSpot;
	local actor HitActor;
	local vector HitLocation, HitNormal, FireDir;
	local float TargetDist, TossSpeed, TossTime;
	local int realYaw;

	Skill = 3;
	if ( projSpeed == 0 )
		return AdjustAim(projSpeed, projStart, aimerror, leadTarget, warnTarget);
	if ( Target == None )
		Target = Enemy;
	if ( Target == None )
		return Rotation;
	FireSpot = Target.Location;
	TargetDist = VSize(Target.Location - ProjStart);

	if ( !Target.bIsPawn )
	{
		if ( (Region.Zone.ZoneGravity.Z != Region.Zone.Default.ZoneGravity.Z) 
			|| (TargetDist > projSpeed) )
		{
			TossTime = TargetDist/projSpeed;
			FireSpot.Z -= ((0.25 * Region.Zone.ZoneGravity.Z * TossTime + 200) * TossTime + 60);	
		}
		viewRotation = Rotator(FireSpot - ProjStart);
		return viewRotation;
	}					
	aimerror = aimerror * (11 - 10 *  
		((Target.Location - Location)/TargetDist 
			Dot Normal((Target.Location + 1.2 * Target.Velocity) - (ProjStart + Velocity)))); 
	if ( bNovice )
	{
		if ( (Target != Enemy) || (Pawn( Enemy ).Weapon == None) || !Pawn( Enemy ).Weapon.bMeleeWeapon || (TargetDist > 650) )
			aimerror = aimerror * (2.1 - 0.2 * (skill + FRand()));
		else
			aimerror *= 0.75;
		if ( Level.TimeSeconds - LastPainTime < 0.15 )
			aimerror *= 1.3;
	}
	else
	{
		aimerror = aimerror * (1.5 - 0.35 * (skill + FRand()));
		if ( (Skill < 2) && (Level.TimeSeconds - LastPainTime < 0.15) )
			aimerror *= 1.2;
	}
	if ( (bNovice && (LastAcquireTime > Level.TimeSeconds - 5 + 0.6 * Skill))
		|| (LastAcquireTime > Level.TimeSeconds - 2.5 + Skill) )
	{
		LastAcquireTime = Level.TimeSeconds - 5;
		aimerror *= 1.75;
	}

	if ( !leadTarget || (accuracy < 0) )
		aimerror -= aimerror * accuracy;

	if ( leadTarget )
	{
		FireSpot += FMin(1, 0.7 + 0.6 * FRand()) * (Target.Velocity * TargetDist/projSpeed);
		if ( !FastTrace(FireSpot, ProjStart) )
			FireSpot = 0.5 * (FireSpot + Target.Location);
	}

	//try middle
	FireSpot.Z = Target.Location.Z;

	if ( (Target == Enemy) && !FastTrace(FireSpot, ProjStart) )
	{
		FireSpot = LastSeenPos;
	 	HitActor = Trace(HitLocation, HitNormal, FireSpot, ProjStart, false);
		if ( HitActor != None )
		{
			bFire = 0;
			bAltFire = 0;
			FireSpot += 2 * Target.CollisionHeight * HitNormal;
			SetTimer(TimeBetweenAttacks, false);
		}
	}

	// adjust for toss distance (assume 200 z velocity add & 60 init height)
	if ( FRand() < 0.75 )
	{
		TossSpeed = projSpeed + 0.4 * VSize(Velocity); 
		if ( (Region.Zone.ZoneGravity.Z != Region.Zone.Default.ZoneGravity.Z) 
			|| (TargetDist > TossSpeed) )
		{
			TossTime = TargetDist/TossSpeed;
			FireSpot.Z -= ((0.25 * Region.Zone.ZoneGravity.Z * TossTime + 200) * TossTime + 60);	
		}
	}

	FireRotation = Rotator(FireSpot - ProjStart);
	realYaw = FireRotation.Yaw;
	aimerror = Rand(2 * aimerror) - aimerror;

	FireRotation.Yaw = (FireRotation.Yaw + aimerror) & 65535;

	if ( (Abs(FireRotation.Yaw - (Rotation.Yaw & 65535)) > 8192)
		&& (Abs(FireRotation.Yaw - (Rotation.Yaw & 65535)) < 57343) )
	{
		if ( (FireRotation.Yaw > Rotation.Yaw + 32768) || 
			((FireRotation.Yaw < Rotation.Yaw) && (FireRotation.Yaw > Rotation.Yaw - 32768)) )
			FireRotation.Yaw = Rotation.Yaw - 8192;
		else
			FireRotation.Yaw = Rotation.Yaw + 8192;
	}
	FireDir = vector(FireRotation);
	// avoid shooting into wall
	HitActor = Trace(HitLocation, HitNormal, ProjStart + FMin(VSize(FireSpot-ProjStart), 400) * FireDir, ProjStart, false); 
	if ( (HitActor != None) && (HitNormal.Z < 0.7) )
	{
		FireRotation.Yaw = (realYaw - aimerror) & 65535;
		if ( (Abs(FireRotation.Yaw - (Rotation.Yaw & 65535)) > 8192)
			&& (Abs(FireRotation.Yaw - (Rotation.Yaw & 65535)) < 57343) )
		{
			if ( (FireRotation.Yaw > Rotation.Yaw + 32768) || 
				((FireRotation.Yaw < Rotation.Yaw) && (FireRotation.Yaw > Rotation.Yaw - 32768)) )
				FireRotation.Yaw = Rotation.Yaw - 8192;
			else
				FireRotation.Yaw = Rotation.Yaw + 8192;
		}
		FireDir = vector(FireRotation);
	}

	if ( warnTarget && (Pawn(Target) != None) ) 
		Pawn(Target).WarnTarget(self, projSpeed, FireDir); 

	//viewRotation = FireRotation;			
	return FireRotation;
}

function rotator AdjustAim(float projSpeed, vector projStart, int aimerror, bool leadTarget, bool warnTarget)
{
	local rotator FireRotation, TargetLook;
	local vector FireSpot, FireDir, TargetVel;
	local float FireDist, TargetDist;
	local actor HitActor;
	local vector HitLocation, HitNormal;
	local int realYaw;
	local bool bDefendMelee, bClean;
	local float AccuracyMod;

	Skill = 1;

//	// // // log( "AIMERROR: "$AimError );
	AimError = 500;
	// // // // log( "Target: "$Target );
	// // // // log( "Enemy : "$Enemy );


	if ( Target == None || Target != Enemy )
		Target = Enemy;
	if ( Target == None )
	{
		bFire = 0;
		bAltFire = 0;
		return Rotation;
	}

	if ( !Target.bIsPawn )
		return rotator(Target.Location - projstart);
					
	FireSpot = Target.Location;
	TargetDist = VSize(Target.Location - Location);
	Accuracy = 0;
	if( TargetDist > 350 )
	{
		if( TargetDist < 624 )
			AccuracyMod = 11.5;
		else
			AccuracyMod = 12;
	}
	else
		AccuracyMod = 13;

	aimerror = aimerror * (AccuracyMod - 10 *  
		((Target.Location - Location)/( TargetDist ) /* + ( TargetDist * 0.75 ) )*/
			Dot Normal((Target.Location + 1.25 * Target.Velocity) - (Location + Velocity)))); 
	if ( ((projSpeed == 0) || (Projspeed >= 1000000)) )
	{
		// instant hit
		if ( bNovice )
			aimerror *= 0.5;
		else
			aimerror *= 0.3 + 0.19 * 0.1; // here
	}

	if ( bNovice )
	{
		if ( !bDefendMelee )
			aimerror = aimerror * (2.4 - 0.2 * (0.1 + FRand())); // here
		if ( (Level.TimeSeconds - LastPainTime < 0.2) || (Physics == PHYS_Falling) || (Target.Physics == PHYS_Falling) )
			aimerror *= 1.5;
	}
	else
		aimerror = aimerror * (1.7 - 0.4 * (0.1 + FRand())); // here

	if ( !leadTarget || (accuracy < 0) )
		aimerror -= aimerror * accuracy;

	if (leadTarget && (projSpeed > 0))
	{
		TargetVel = Target.Velocity;
		if ( Target.Physics == PHYS_Falling )
		{
			if ( Target.Region.Zone.ZoneGravity == Target.Region.Zone.Default.ZoneGravity )
				TargetVel.Z = FMin(-160, TargetVel.Z);
			else
				TargetVel.Z = FMin(0, TargetVel.Z);
		}
		FireSpot += FMin(1, 0.7 + 0.6 * FRand()) * TargetVel * TargetDist/projSpeed;
		FireSpot.Z = FMin(Target.Location.Z, FireSpot.Z);
		if ( (Target.Physics != PHYS_Falling) && (FRand() < 0.55) && (VSize(FireSpot - ProjStart) > 1000) )
		{
			TargetLook = Target.Rotation;
			if ( Target.Physics == PHYS_Walking )
				TargetLook.Pitch = 0;
			if ( ((Vector(TargetLook) Dot Normal(Target.Velocity)) < 0.71) )
				bClean = false;
			else
				bClean = FastTrace(FireSpot, ProjStart);
		}
		else
			bClean = FastTrace(FireSpot, ProjStart);
		if ( !bClean)
		{
			if ( FRand() < 0.3 )
				FireSpot = Target.Location;
			else
				FireSpot = 0.5 * (FireSpot + Target.Location);
		}
	}

	bClean = false; //so will fail first check unless shooting at feet  
	if ( Target.bIsPawn && (!bNovice || bDefendMelee) 
		&& (Weapon != None) 
		&& (Weapon.bRecommendSplashDamage || (Weapon.bRecommendAltSplashDamage && (bAltFire != 0))) 
		&& (((Target.Physics == PHYS_Falling) && (Location.Z + 80 >= Target.Location.Z))
			|| ((Location.Z + 19 >= Target.Location.Z) && (bDefendMelee || (skill > 2.5 * FRand() - 0.5)))) )
	{
	 	HitActor = Trace(HitLocation, HitNormal, FireSpot - vect(0,0,1) * (Target.CollisionHeight + 6), FireSpot, false);
 		bClean = (HitActor == None);
		if ( !bClean )
		{
			FireSpot = HitLocation + vect(0,0,3);
			bClean = FastTrace(FireSpot, ProjStart);
		}
		else if ( Target.Physics == PHYS_Falling )
			bClean = FastTrace(FireSpot, ProjStart);
		else
			bClean = false;
	}
	if ( !bClean )
	{
		//try middle
		FireSpot.Z = Target.Location.Z;
 		bClean = FastTrace(FireSpot, ProjStart);
	}
	if( !bClean ) 
	{
		////try head
 		FireSpot.Z = Target.Location.Z + 0.9 * Target.CollisionHeight;
 		bClean = FastTrace(FireSpot, ProjStart);
	}
	if ( !bClean && (Target == Enemy) )
	{
		FireSpot = LastSeenPos;
		if ( Location.Z >= LastSeenPos.Z )
			FireSpot.Z -= 0.7 * Enemy.CollisionHeight;
	 	HitActor = Trace(HitLocation, HitNormal, FireSpot, ProjStart, false);
		if ( HitActor != None )
		{
			FireSpot = LastSeenPos + 2 * Enemy.CollisionHeight * HitNormal;
			if ( Weapon.bSplashDamage && !bNovice )
			{
			 	HitActor = Trace(HitLocation, HitNormal, FireSpot, ProjStart, false);
				if ( HitActor != None )
					FireSpot += 2 * Enemy.CollisionHeight * HitNormal;
			}
//			if ( Weapon.RefireRate < 0.99 )
				bFire = 0;
//			if ( Weapon.AltRefireRate < 0.99 )
				bAltFire = 0;
			SetTimer(TimeBetweenAttacks, false);
		}
	}
	
	FireRotation = Rotator(FireSpot - ProjStart);
	realYaw = FireRotation.Yaw;
	aimerror = Rand(2 * aimerror) - aimerror;
	FireRotation.Yaw = (FireRotation.Yaw + aimerror) & 65535;

	if ( (Abs(FireRotation.Yaw - (Rotation.Yaw & 65535)) > 8192)
		&& (Abs(FireRotation.Yaw - (Rotation.Yaw & 65535)) < 57343) )
	{
		if ( (FireRotation.Yaw > Rotation.Yaw + 32768) || 
			((FireRotation.Yaw < Rotation.Yaw) && (FireRotation.Yaw > Rotation.Yaw - 32768)) )
			FireRotation.Yaw = Rotation.Yaw - 8192;
		else
			FireRotation.Yaw = Rotation.Yaw + 8192;
	}
	FireDir = vector(FireRotation);
	// avoid shooting into wall
	FireDist = FMin(VSize(FireSpot-ProjStart), 400);
	FireSpot = ProjStart + FireDist * FireDir;
	HitActor = Trace(HitLocation, HitNormal, FireSpot, ProjStart, false); 

	if ( HitActor != None )
	{
		if ( HitNormal.Z < 0.7 )
		{
			FireRotation.Yaw = (realYaw - aimerror) & 65535;
			if ( (Abs(FireRotation.Yaw - (Rotation.Yaw & 65535)) > 8192)
				&& (Abs(FireRotation.Yaw - (Rotation.Yaw & 65535)) < 57343) )
			{
				if ( (FireRotation.Yaw > Rotation.Yaw + 32768) || 
					((FireRotation.Yaw < Rotation.Yaw) && (FireRotation.Yaw > Rotation.Yaw - 32768)) )
					FireRotation.Yaw = Rotation.Yaw - 8192;
				else
					FireRotation.Yaw = Rotation.Yaw + 8192;
			}
			FireDir = vector(FireRotation);
			FireSpot = ProjStart + FireDist * FireDir;
			HitActor = Trace(HitLocation, HitNormal, FireSpot, ProjStart, false); 
		}
		if ( HitActor != None )
		{
			FireSpot += HitNormal * 2 * Target.CollisionHeight;
			if ( !bNovice )
			{
				HitActor = Trace(HitLocation, HitNormal, FireSpot, ProjStart, false); 
				if ( HitActor != None )
					FireSpot += Target.CollisionHeight * HitNormal; 
			}
			FireDir = Normal(FireSpot - ProjStart);
			FireRotation = rotator(FireDir);		
		}
	}

	if ( warnTarget && (Pawn(Target) != None) ) 
		Pawn(Target).WarnTarget(self, projSpeed, FireDir); 

	//viewRotation = FireRotation;			
	return FireRotation;
}

function WarnTarget(Pawn shooter, float projSpeed, vector FireDir)
{
	local float enemyDist;
	local vector X,Y,Z, enemyDir;

	// AI controlled creatures may duck if not falling
	if ( (health <= 0) || !bCanDuck || (Enemy == None) 
		|| (Physics == PHYS_Falling) || (Physics == PHYS_Swimming) )
		return;

	if ( bNovice )
	{
		if ( FRand() > 0.11 * skill )
			return;
	}
	else if ( FRand() > 0.22 * skill + 0.33 )
		return;

	// and projectile time is long enough
	enemyDist = VSize(shooter.Location - Location);
	if (enemyDist/projSpeed < 0.11 + 0.15 * FRand()) 
		return;
					
	// only if tight FOV
	GetAxes(Rotation,X,Y,Z);
	enemyDir = (shooter.Location - Location)/enemyDist;
	if ((enemyDir Dot X) < 0.8)
		return;

//	if ( (FireDir Dot Y) > 0 )
//	{
//		Y *= -1;
//		TryToDuck(Y, true);
//	}
//	else
//		TryToDuck(Y, false);
}

// Can Stake Out - check if I can see my current Destination point, and so can enemy
function bool CanStakeOut()
{
	if ( VSize(Enemy.Location - LastSeenPos) > 800 )
		return false;		
	
	return ( FastTrace(LastSeenPos, Location + EyeHeight * vect(0,0,1))
			&& FastTrace(LastSeenPos , Enemy.Location + Pawn( Enemy ).BaseEyeHeight * vect(0,0,1)) );
}

function eAttitude AttitudeTo(Actor Other)
{
	local byte result;

	if( Other != None && Other.IsA( 'PlayerPawn' ) )
	{
		return ATTITUDE_Ignore;
	}
	return ATTITUDE_Hate;
}

function float AssessThreat( Actor NewThreat )
{
	local float ThreatValue, NewStrength, Dist;
	local eAttitude NewAttitude;
	local Pawn PawnThreat;

	if( NewThreat.IsA( 'Pawn' ) )
	{
		PawnThreat = Pawn( NewThreat );
		NewStrength = RelativeStrength(PawnThreat);

		ThreatValue = FMax(0, NewStrength);
		if ( PawnThreat.Health < 20 )
			ThreatValue += 0.3;

		Dist = VSize(PawnThreat.Location - Location);
		if ( Dist < 800 )
			ThreatValue += 0.3;
	
		if ( (PawnThreat != Enemy) && (Enemy != None) )
		{
			if ( Dist > 0.7 * VSize(Enemy.Location - Location) )
				ThreatValue -= 0.25;
			ThreatValue -= 0.2;

			if( !LineOfSightTo(Enemy) )
			{
				if ( Dist < 1200 )
					ThreatValue += 0.2;
				if ( SpecialPause > 0 )
					ThreatValue += 5;
				if ( IsInState('Hunting') && (NewStrength < 0.2) 
					&& (Level.TimeSeconds - LastSeenTime < 3)
					&& (relativeStrength( Pawn( Enemy ) ) < FMin(0, NewStrength)) )
					ThreatValue -= 0.3;
			}
		}
		ThreatValue += 0.15;
	}
	else
		ThreatValue = 20;
	return ThreatValue;
}

function bool SetEnemy( actor NewEnemy )
{
	local bool result, bNotSeen;
	local eAttitude newAttitude, oldAttitude;
	local float newStrength;
	local Actor Friend;

	
	if ( Pawn( Enemy ) == NewEnemy && NewEnemy != None )
		return true;
	if ( (NewEnemy == Self) || (NewEnemy == None) /*|| (NewEnemy.Health <= 0)*/ || NewEnemy.IsA('FlockPawn') )
		return false;

	result = false;
	newAttitude = AttitudeTo(NewEnemy);
	if ( newAttitude == ATTITUDE_Friendly )
	{
		Friend = NewEnemy;
		if( Friend.IsA( 'Pawn' ) )
		{
			if ( Level.TimeSeconds - Pawn( Friend ).LastSeenTime > 5 )
				return false;
			NewEnemy = Pawn( NewEnemy ).Enemy;
		}
		if ( (NewEnemy == None) || (Pawn( NewEnemy ) == Self) || (Pawn( NewEnemy ).Health <= 0) || NewEnemy.IsA('FlockPawn') || NewEnemy.IsA('StationaryPawn') )
			return false;
		if (Enemy == NewEnemy)
			return true;

		bNotSeen = true;
		newAttitude = AttitudeTo(NewEnemy);
	}

	if ( newAttitude >= ATTITUDE_Ignore )
		return false;

	if ( Enemy != None )
	{
		if ( AssessThreat(Pawn( NewEnemy ) ) > AssessThreat( Pawn( Enemy ) ) )
		{
			OldEnemy = Enemy;
			Enemy = NewEnemy;
			result = true;
		}
		else if ( OldEnemy == None )
			OldEnemy = NewEnemy;
	}
	else
	{
		result = true;
		Enemy = NewEnemy;
	}

	if ( result )
	{
		if ( bNotSeen && Friend.IsA( 'Pawn' ) )
		{
			LastSeenTime = Pawn( Friend ).LastSeenTime;
			LastSeeingPos = Pawn( Friend ).LastSeeingPos;
			LastSeenPos = Pawn( Friend ).LastSeenPos;
		}
		else
		{
			LastSeenTime = Level.TimeSeconds;
			LastSeeingPos = Location;
			LastSeenPos = Enemy.Location;
		}
		//EnemyAcquired();
	}
				
	return result;
}


function Killed(pawn Killer, pawn Other, class<DamageType> DamageType)
{
	local Pawn aPawn;

	if ( Killer == self )
		Other.Health = FMin(Other.Health, -11); // don't let other do stagger death

	if ( Health <= 0 )
		return;

	if ( Pawn( OldEnemy ) == Other )
		OldEnemy = None;

	if ( Pawn( Enemy ) == Other )
	{
		bFire = 0;
		bAltFire = 0;
		bReadyToAttack = ( skill > 3 * FRand() );
		//EnemyDropped = Pawn( Enemy ).Weapon;
		Enemy = None;
		if ( (Killer == self) && (OldEnemy == None) )
		{
			for ( aPawn=Level.PawnList; aPawn!=None; aPawn=aPawn.nextPawn )
				if ( aPawn.bIsPlayer && aPawn.bCollideActors 
					&& (VSize(Location - aPawn.Location) < 1600)
					&& CanSee(aPawn) && SetEnemy(aPawn) )
				{
					GotoState('Attacking');
					return;
				}

			//MaybeTaunt(Other);
		}
		else 
			ChooseAttackState();
	}
	else if ( Level.Game.bTeamGame && Other.bIsPlayer
			&& (Other.PlayerReplicationInfo.Team == PlayerReplicationInfo.Team) )
	{
		if ( Other == Self )
			return;
	}
}	


/* RelativeStrength()
returns a value indicating the relative strength of other
0.0 = equal to self
> 0 stronger than self
< 0 weaker than self

Since the result will be compared to the creature's aggressiveness, it should be
on the same order of magnitude (-1 to 1)

Assess based on health and weapon
*/

function float RelativeStrength(Actor Other)
{
	local float compare;
	local int adjustedStrength, adjustedOther;
	local int bTemp;
	local Pawn PawnEnemy;
	
	if( Other.IsA( 'Pawn' ) )
	{
	PawnEnemy = Pawn( Other );

	adjustedStrength = health;
	adjustedOther = 0.5 * (PawnEnemy.health + PawnEnemy.Default.Health);	
	compare = 0.01 * float(adjustedOther - adjustedStrength);
	if ( Weapon != None )
	{
		compare -= DamageScaling * (Weapon.RateSelf(bTemp) - 0.3);
		if ( Weapon.AIRating < 0.5 )
		{
			compare += 0.3;
			if ( (PawnEnemy.Weapon != None) && (PawnEnemy.Weapon.AIRating > 0.5) )
				compare += 0.35;
		}
	}
	if ( PawnEnemy.Weapon != None )
		compare += PawnEnemy.DamageScaling * (PawnEnemy.Weapon.RateSelf(bTemp) - 0.3);

	if ( PawnEnemy.Location.Z > Location.Z + 400 )
		compare -= 0.15;
	else if ( Location.Z > PawnEnemy.Location.Z + 400 )
		compare += 0.15;
	}
	else
		Compare = 1.0;
	return compare;
}


// JC: Triggering HumanNPCs currently only activates a patrol.
function Trigger( actor Other, pawn EventInstigator )
{
	if ( (Other == Self) || (Health <= 0) )
		return;

	if( CurrentPatrolControl == None )
		CurrentPatrolControl = GetPatrolControl();
	
	if( CurrentPatrolControl != None )
	{
		GotoState( 'Patrolling' );
	}
}

function TranslocateToTarget(Actor Destn)
{
}

function bool CanImpactJump()
{
	return false;
}

function BigJump(Actor JumpDest)
{
	//// // // // // log( "BigJump called" );
	JumpDestination = JumpDest.Location;
	NextState = GetStateName();
	GotoState( 'Jumping' );
}

function TentacleSmall CreateMiniTentacle( vector MountOrigin, rotator MountAngles, name MountMeshItem )
{
	local TentacleSmall T;

	T = Spawn( class'TentacleSmall', self );

	T.AttachActorToParent( self, true, true );

	T.MountOrigin	= MountOrigin;
	T.MountAngles	= MountAngles;
	T.MountMeshItem = MountMeshItem;
	T.MountType		= MOUNT_MeshBone;
	
	T.SetPhysics( PHYS_MovingBrush );
	T.GotoState( 'TemporaryTentacle' );

	return T;
}

function Tentacle CreateTentacle( vector MountOrigin, rotator MountAngles, name MountMeshItem, optional actor Target )
{
	local Tentacle T;
	T = Spawn( class'Tentacle', Self );
	
	if( Target != None )
	{
		T.AttachActorToParent( target, true, false );
	}
	else
	{
		T.AttachActorToParent( self, true, true );
	}
	T.MountOrigin = MountOrigin;
	T.MountAngles = MountAngles;
	T.MountMeshItem = MountMeshItem;
	T.MountType = MOUNT_MeshBone;
	T.SetPhysics( PHYS_MovingBrush );
	
	if( T != None )
	{
		return T;
	}
}

function bool MeleeDamageTarget(int hitdamage, vector pushdir)
{
	local vector HitLocation, HitNormal, TargetPoint;
	local actor HitActor;

	Target = Enemy;
	// check if still in melee range
	If ( (VSize(Target.Location - Location) <= 256 * 1.4 + Target.CollisionRadius + CollisionRadius)
		&& ((Physics == PHYS_Flying) || (Physics == PHYS_Swimming) || (Abs(Location.Z - Enemy.Location.Z) 
			<= FMax(CollisionHeight, Enemy.CollisionHeight) + 0.5 * FMin(CollisionHeight, Enemy.CollisionHeight))) )
	{	

		HitActor = Trace(HitLocation, HitNormal, Enemy.Location, Location, false);
		if ( HitActor != None )
			return false;
		Target.TakeDamage(hitdamage, Self,HitLocation, pushdir, class'KungFuDamage');
		return true;
	}
	return false;
}

// a_jumpdivewater
state FallingState 
{
ignores Bump, Hitwall, WarnTarget;

	singular event BaseChange()
	{
		local actor HitActor;
		local vector HitNormal, HitLocation;

		if ( (Base != None) && Base.IsA('Mover')
			&& ((MoveTarget == Base) 
				|| ((MoveTarget != None) && (MoveTarget == Mover(Base).myMarker))) )
		{
			MoveTimer = -1.0;
			MoveTarget = None;
			acceleration = vect(0,0,0);
		}
		else
			Super.BaseChange();
	}

//	function AnimEnd()
//	{
//		PlayInAir();
//	}

	function ZoneChange(ZoneInfo newZone)
	{
		Global.ZoneChange(newZone);
		if (newZone.bWaterZone)
		{
			TweenToWaiting(0.15);
			GotoState('FallingState', 'Splash');
		}
	}
	
	//choose a jump velocity
	function adjustJump()
	{
		local float velZ;
		local vector FullVel;

		velZ = Velocity.Z;
		FullVel = Normal(Velocity) * GroundSpeed;
		Acceleration = vect(0,0,0);
		If (Location.Z > Destination.Z + CollisionHeight + 2 * MaxStepHeight)
		{
			Velocity = FullVel;
			Velocity.Z = velZ;
			Velocity = EAdjustJump();
			Velocity.Z = 0;
			if ( VSize(Velocity) < 0.9 * GroundSpeed )
			{
				Velocity.Z = velZ;
				return;
			}
		}

		//PlaySound(JumpSound, SLOT_Talk, 1.5, true, 1200, 1.0 );
		Velocity = FullVel;
		Velocity.Z = Default.JumpZ + velZ;
		Velocity = EAdjustJump();
	}

/*	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
							Vector momentum, class<DamageType> DamageType)
	{
		if( bNPCInvulnerable )
			return;

		Super.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
	}
*/

	function Timer( optional int TimerNum )
	{
		if ( Enemy != None )
		{
			bReadyToAttack = true;
		//	if ( CanFireAtEnemy() )
		//		GotoState('FallingState', 'FireWhileFalling');
		}
	}

	function Landed(vector HitNormal)
	{
		local vector Vel2D;

		if ( MoveTarget != None )
		{
			Vel2D = Velocity;
			Vel2D.Z = 0;
			if ( (Vel2D Dot (MoveTarget.Location - Location)) < 0 )
				Acceleration = vect(0,0,0);
		}
		//Note - physics changes type to PHYS_Walking by default for landed pawns
		PlayLanded(Velocity.Z);
		TakeFallingDamage();
		if (Velocity.Z < -1.4 * JumpZ)
		{
			if ( health > 0 )
				GotoState('FallingState', 'Landed');
		}
		else 
			GotoState('FallingState', 'Done');
	}
	
	function SetFall()
	{
		if (!bUpAndOut)
			GotoState('FallingState');
	}
	
	function EnemyAcquired()
	{
		NextState = 'Acquisition';
		NextLabel = 'Begin';
	}

	function FindNewJumpDest()
	{
		local NavigationPoint N, Best;
		local float BestRating, Rating;
		local vector Dist;

		// look for pathnode below current location and visible
		BestRating = 1;
		for ( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
			if ( N.Location.Z + 100 < Location.Z )
			{
				Dist = Location - N.Location;
				Rating = Dist.Z * Dist.Z/(Dist.X * Dist.X + Dist.Y * Dist.Y); 
				if ( (Rating > BestRating) && FastTrace(N.Location, Location) )
				{
					BestRating = Rating;
					Best = N;
				}
			}
				

		if ( Best != None )
			Destination = Best.Location;
	}

	function BeginState()
	{
		if (Enemy == None)
			Disable('EnemyNotVisible');
		else
		{
			Disable('HearNoise');
			Disable('SeePlayer');
		}
		if ( (bFire > 0) || (bAltFire > 0) || (Skill == 3) )
			SetTimer(0.01, false);
	}

	function EndState()
	{
		//log(self$" left falling state ");
		MaxStepHeight = Default.MaxStepHeight;	
		bUpAndOut = false;
		bJumpOffPawn = false;
//		bBigJump = false;
		if ( (MoveTarget != None) && (MoveTarget.Location.Z - Location.Z > 256) )
			MoveTarget = None;
	}

FireWhileFalling:
	Disable('HearNoise');
	Disable('SeePlayer');
	if ( Physics != PHYS_Falling )
		Goto('Done');
	if ( Enemy == None )
		Goto('LongFall');
	TurnToward(Enemy);
	//if ( CanFireAtEnemy() )
	//	FireWeapon();
	if ( Region.Zone.ZoneGravity.Z > Region.Zone.Default.ZoneGravity.Z )
	{
		if ( (Velocity.Z < 0) && (Destination.Z > Location.Z + MaxStepHeight + CollisionHeight) )
			FindNewJumpDest();			
		StrafeFacing(Destination, Enemy);
	}
	else
		Sleep(0.5 + 0.2 * FRand());
	if ( LineOfSightTo(Enemy) )
		Goto('FireWhileFalling');
 			
LongFall:
	if ( (Region.Zone.ZoneGravity.Z > Region.Zone.Default.ZoneGravity.Z)
		&& (Velocity.Z < 0) && (Destination.Z > Location.Z + MaxStepHeight + CollisionHeight) )
	{
		FindNewJumpDest();
		MoveTo(Destination);
	}			
	if ( bCanFly )
	{
		SetPhysics(PHYS_Flying);
		Goto('Done');
	}
	Sleep(0.7);
	if ( Enemy != None )
	{
		TurnToward(Enemy);
//		if ( CanFireAtEnemy() )
//		{
//			PlayRangedAttack();
//		}
	}
	if ( (Velocity.Z > -150) && (Region.Zone.ZoneGravity.Z <= Region.Zone.Default.ZoneGravity.Z) ) //stuck
	{
		SetPhysics(PHYS_Falling);
		if ( Enemy != None )
			Velocity = groundspeed * normal(Enemy.Location - Location);
		else
			Velocity = groundspeed * VRand();

		Velocity.Z = FMax(JumpZ, 250);
	}
	Goto('LongFall');	

Landed:
	//log("***Playing"@animsequence@"at"@animframe);
	//Disable('AnimEnd');
	FinishAnim();
	//log("***Finished"@animsequence@"at"@animframe);
Done:
	//log("***After fall"@NextState@NextLabel);
	bUpAndOut = false;
	if ( (NextState != '') && (NextState != 'FallingState') )
		GotoState(NextState, NextLabel);
	else 
		GotoState('Attacking');

Splash:
	
	bUpAndOut = false;
	if ( NextState != '' )
		GotoState(NextState, NextLabel);
	else 
		GotoState('Attacking');
			
Begin:
	if(Enemy == None)
		Disable('EnemyNotVisible');
	else
	{
		Disable('HearNoise');
		Disable('SeePlayer');
	}
	if ( !bUpAndOut ) // not water jump
	{	
		if ( Region.Zone.bWaterZone )
		{
			SetPhysics(PHYS_Swimming);
			GotoState(NextState, NextLabel);
		}	
		if ( !bJumpOffPawn )
			AdjustJump();
PlayFall:
//		if ( (Velocity.Z > 300) && (MoveTarget != None)
//			&& ((FRand() < 0.13) || ((Region.Zone.ZoneGravity.Z > Region.Zone.Default.ZoneGravity.Z) && (FRand() < 0.2)))
//			&& (VSize(Destination - Location) > 160)
//			&& ((Vector(Rotation) Dot (Destination - Location)) > 0) )
//			PlayFlip();
//		elseA_JumpAir_U
			
		//PlayAllAnim( 'A_JumpAir_U',, 0.3, true ) ;
		if( OverWater() )
		{
			PlayAllAnim( 'A_JumpAir_U', 1.5, 0.2, false );
			FinishAnim( 0 );
			PlayAllAnim( 'A_JumpDiveWater',, 0.2, false );
			WaitForLanding();
			Sleep( 0.2 );
		}
		else
		{
			PlayAllAnim( 'A_jumpAir_U',, 0.2, true );
		}
	}
	if (Physics != PHYS_Falling)
		Goto('Done');
	if ( !bNovice && (Enemy != None) && (Region.Zone.ZoneGravity.Z > Region.Zone.Default.ZoneGravity.Z) )
	{
		Acceleration = AccelRate * Normal(Destination - Location);
		Goto('FireWhileFalling');
	}

	if ( bJumpOffPawn )
	{
//		if ( bBigJump )
//		{
//			While( bBigJump )
//			{
//				Sleep(0.25);
//				Acceleration = AccelRate * Normal(Destination - Location);
//			}
//		}
//		else
//		{
			Sleep(0.2);
			While ( (Abs(Velocity.X) < 60) && (Abs(Velocity.Y) < 60) )
				Sleep(0.1);
			Acceleration = vect(0,0,0);
			Sleep(1.5);
//		}
//		bBigJump = false;
		bJumpOffPawn = false;
	}
	else
		Sleep(2);

	Goto('LongFall');

Ducking:
	if ( Region.Zone.ZoneGravity.Z > Region.Zone.Default.ZoneGravity.Z )
	{
		Acceleration = AccelRate * Normal(Destination - Location);
		if ( bNovice )
			Sleep(0.4);
		PlayInAir();
		if ( Enemy != None )
			Goto('FireWhileFalling');
	}
}

function bool OverWater()
{
	local actor HitActor;
	local vector HitLocation, HitNormal;

	HitActor = Trace( HitLocation, HitNormal, Location + ( vect( 0, 0, 1 ) * -1024 ), Location, true );

	if( IsInWaterRegion( HitLocation ) )
		return true;
	else
		return false;
}



state Dying
{
	ignores SeePlayer, EnemyNotVisible, HearNoise, Died, Bump, Trigger, HitWall, HeadZoneChange, FootZoneChange, ZoneChange, Falling, WarnTarget, LongFall, SetFall, Drowning;

	function Used( actor Other, Pawn EventInstigator )
	{
	}

	function ReactToJump();

	function ReStartPlayer()
	{
	}
	
	function BeginState()
	{
		local actor A;

		SetCollision( true, true, false );		
		StopSound( SLOT_Talk );
		if( Event != '' && KilledByPawn != None )
		{
			foreach AllActors( class 'Actor', A, Event )
			A.Trigger( Self, KilledByPawn );
		}
		SetTimer(0, false);
		Enemy = None;
		AmbushSpot = None;
		bFire = 0;
		bAltFire = 0;
		bDevious = false;
		BlockedPath = None;
	}

Begin:
	if( !Region.Zone.bWaterZone )
		bEyesShut = true;
	else
	{
		PlayAllAnim( 'A_DeadInWaterUp',, 0.7, true );
		bEyesShut = true;
	}
}

function bool InFrontOfWall()
{
	local actor HitActor;
	local vector HitLocation, HitNormal;

	HitActor = Trace( HitLocation, HitNormal, Location + ( vector( Rotation ) * -48 ) + vect( 0, 0, 16 ), Location, true );

	if( HitActor != None && HitActor.IsA( 'LevelInfo' ) )
	{
		return true;
	}
	return false;
}

function bool FacingEnemy()
{
	local actor HitActor;
	local vector HitLocation, HitNormal;
	local vector CollisionOffset;

	HitActor = Trace( HitLocation, HitNormal, Location + ( vector( Rotation ) * 256 ), Location, true );

	if( HitActor != None && HitActor == Enemy )
	{
		return true;
	}
}

function bool FacingWall()
{
	local actor HitActor;
	local vector HitLocation, HitNormal;
	local vector CollisionOffset;

	HitActor = Trace( HitLocation, HitNormal, Location + ( vector( Rotation ) * 48 ), Location, true );

	if( HitActor != None && HitActor.IsA( 'LevelInfo' ) )
	{
		CollisionOffset.X = -0.38 * VSize( Location - HitLocation );
		PrePivot = CollisionOffset;
		return true;
	}
}

function PlayDyingSound()
{
	local int rnd;

	if ( HeadRegion.Zone.bWaterZone )
	{
		if ( FRand() < 0.5 )
			PlaySound(UWHit1, SLOT_Pain,16,,,Frand()*0.2+0.9);
		else
			PlaySound(UWHit2, SLOT_Pain,16,,,Frand()*0.2+0.9);
		return;
	}

	rnd = Rand(6);
	PlaySound(Deaths[rnd], SLOT_Talk, 16);
	PlaySound(Deaths[rnd], SLOT_Pain, 16);
}

simulated function bool EvalArmBlownOff()
{
    local int bone;

	GetMeshInstance();
	if (MeshInstance==None)
		return(false);

    bone = MeshInstance.BoneFindNamed('Forearm_L');
	if (bone!=0)
		MeshInstance.BoneSetScale(bone, vect(0,0,0), true);
	return(true);
}

function SpawnGibbedCarcass( optional class<DamageType> DamageType, optional vector HitLocation, optional vector Momentum )
{
	local carcass carc;

	carc = Spawn(CarcassType);
	if( MySnatcher != None )
		MySnatcher.Destroy();
	if( MyMouthTentacle != None )
		MyMouthTentacle.Destroy();
	if( MyShoulderTentacle1 != None )
		MyShoulderTentacle1.Destroy();
	if( MyShoulderTentacle2 != None )
		MyShoulderTentacle2.Destroy();
	if( MyTemporaryTentacle != None )
		MyTemporaryTentacle.Destroy();
	if ( carc != None )
	{
		carc.InitFor(self);
		carc.ChunkDamageType	= DamageType;
		carc.ChunkUpBlastLoc	= HitLocation;
		carc.BlastVelocity		= Momentum;
		carc.ChunkCarcass();
	}
	Super.SpawnGibbedCarcass( DamageType, HitLocation, Momentum );
}

function AttachTentacleToCarcass( CreaturePawnCarcass CPC, TentacleSmall ThisTentacle )
{
	ThisTentacle.SetOwner( CPC );
	ThisTentacle.AttachActorToParent( CPC, true, false );
	ThisTentacle.GotoState( 'Dying' );
}

function SpawnHeadCreeper( carcass MyCarcass )
{
	local MeshInstance Minst;
	local int bone;
	local HeadCreeper Creeper;

	Minst = MyCarcass.GetMeshInstance();
	bone = Minst.BoneFindNamed( 'Head' );
	
	Creeper = Spawn( class'HeadCreeper',,, Minst.MeshToWorldLocation( Minst.BoneGetTranslate( bone, true, true ) ) );
	Creeper.InfectedCarcass = CreaturePawnCarcass( MyCarcass );

}

function Carcass SpawnCarcass( optional class<DamageType> DamageType, optional vector HitLocation, optional vector Momentum )
{
	local Carcass c;
	local CreaturePawnCarcass CPC;

	local SoftParticleSystem a;
	local Tentacle T;
	local meshinstance Minst, CMinst;
	local SnatchActor SA;
	local HeadCreeper Test;

	c = Spawn( CarcassType, self );

	if( C.IsA( 'dnCarcass' ) )
		dnCarcass( c ).bCanHaveCash = bCanHaveCash;

	if( C != None && C.IsA( 'CreaturePawnCarcass' ) )
		CPC = CreaturePawnCarcass( C );

	if( CPC != None )
	{
		cpc.bHeadBlownOff = bHeadBlownOff;
		cpc.bArmless = bArmless;
		cpc.bEyesShut = bEyesShut;
		cpc.Initfor(self);
		cpc.PrePivot = PrePivot;
		//cpc.bPlayerCarcass = false;
		if (cpc.bHeadBlownOff)
		{
			a = cpc.Spawn(class'dnBlood_Fountain1',,,Location + vect(FRand()*10.0 - 5.0, FRand()*10.0 - 5.0, CollisionHeight + FRand()*10.0 - 5.0) );
			a.AttachActorToParent(cpc,true,true);
			a.MountType = MOUNT_MeshBone;
			a.MountMeshItem = 'Neck';
			a.MountOrigin = vect(0,0,0);
			a.MountAngles = rot(0,0,0);
			a.SetPhysics(PHYS_MovingBrush);
			a.SpawnOnBounce = class<actor>(DynamicLoadObject("U_Generic.dnBloodSplatDecal", class'Class', true));
		}
		// Attach any lingering tentacles to the carcass.
		if( MySnatcher != None )
		{
			MySnatcher.SetOwner( cpc );
			MySnatcher.AttachActorToParent( cpc, true, true );
		}

		if(	MyMouthTentacle != None )
		{
			MyMouthTentacle.SetOwner( cpc );
			MyMouthTentacle.AttachActorToParent( cpc, true, true );
		}
		if( MyShoulderTentacle1 != None )
		{
			MyShoulderTentacle1.SetOwner( cpc );
			MyShoulderTentacle1.AttachActorToParent( cpc, true, true );
		}
		if( MyShoulderTentacle2 != None )
		{
			MyShoulderTentacle2.SetOwner( cpc );
			MyShoulderTentacle2.AttachActorToParent( cpc, true, true );
		}
		if( MyTemporaryTentacle != None )
		{
			MyTemporaryTentacle.SetOwner( cpc );
			MyTemporaryTentacle.AttachActorToParent( cpc, true, true );
		}
		if( MiniTentacle1 != None )
		{
			MiniTentacle1.SetOwner( cpc );
			MiniTentacle1.AttachActorToParent( cpc, true, false );
			MiniTentacle1.GotoState( 'Dying' );
		}
		if( MiniTentacle2 != None )
		{
			MiniTentacle2.SetOwner( cpc );
			MiniTentacle2.AttachActorToParent( cpc, true, false );
			MiniTentacle2.GotoState( 'Dying' );
		}
		if( MiniTentacle3 != None )
		{
			MiniTentacle3.SetOwner( cpc );
			MiniTentacle3.AttachActorToParent( cpc, true, false );
			MiniTentacle3.GotoState( 'Dying' );
		}
		if( MiniTentacle4 != None )
		{
			MiniTentacle4.SetOwner( cpc );
			MiniTentacle4.AttachActorToParent( cpc, true, false );
			MiniTentacle4.GotoState( 'Dying' );
		}
		if( TentacleBicepR != None )
			AttachTentacleToCarcass( cpc, TentacleBicepR );
		if( TentacleBicepL != None )
			AttachTentacleToCarcass( cpc, TentacleBicepL );
		if( TentacleChest != None )
			AttachTentacleToCarcass( cpc, TentacleChest );
		if( TentacleForearmL != None )
			AttachTentacleToCarcass( cpc, TentacleForearmL );
		if( TentacleForearmR != None )
			AttachTentacleToCarcass( cpc, TentacleForearmR );
		if( TentacleShinR != None )
			AttachTentacleToCarcass( cpc, TentacleShinR );
		if( TentacleShinL != None )
			AttachTentacleToCarcass( cpc, TentacleShinL );
		if( TentacleFootL != None )
			AttachTentacleToCarcass( cpc, TentacleFootL );
		if( TentacleFootR != None )
			AttachTentacleToCarcass( cpc, TentacleFootR );
		if( TentaclePelvis != None )
			AttachTentacleToCarcass( cpc, TentaclePelvis );
	
		if( bSnatched || bSteelSkin )
			CPC.bNoPupils = true;
	
		cpc.MeshDecalLink = MeshDecalLink;
	}

	Minst = GetMeshInstance();
	CMinst = CPC.GetMeshInstance();
	CMinst.MeshChannels[ 5 ].bAnimFinished = Minst.MeshChannels[ 5 ].bAnimFinished;
	CMinst.MeshChannels[ 5 ].bAnimLoop = false;
	CMinst.MeshChannels[ 5 ].bAnimNotify = Minst.MeshChannels[ 5 ].bAnimNotify;
	CMinst.MeshChannels[ 5 ].bAnimBlendAdditive = Minst.MeshChannels[ 5 ].bAnimBlendAdditive;
	CMinst.MeshChannels[ 5 ].AnimSequence = Minst.MeshChannels[ 5 ].AniMSequence;
	CMinst.MeshChannels[ 5 ].AnimFrame = Minst.MeshChannels[ 5 ].AnimFrame;
	CMinst.MeshChannels[ 5 ].AnimRate = Minst.MeshChannels[ 5 ].AnimRate;
	CMinst.MeshChannels[ 5 ].AnimBlend = Minst.MeshChannels[ 5 ].AnimBlend;
	CMinst.MeshChannels[ 5 ].TweenRate = Minst.MeshChannels[ 5 ].TweenRate;
	CMinst.MeshChannels[ 5 ].AnimLast = Minst.MeshChannels[ 5 ].AnimLast;
	CMinst.MeshChannels[ 5 ].AnimMinRate = Minst.MeshChannels[ 5 ].AnimMinRate;
	CMinst.MeshChannels[ 5 ].OldAnimRate = Minst.MeshChannels[ 5 ].OldAnimRate;
	CMinst.MeshChannels[ 5 ].SimAnim = Minst.MeshChannels[ 5 ].SimAnim;
	CMinst.MeshChannels[ 5 ].MeshEffect = Minst.MeshChannels[ 5 ].MeshEffect;
	if( bSnatched && Frand() < HeadCreeperOdds )
		SpawnHeadCreeper( CPC );
	return cpc;
}

state FindAir
{
	ignores SeePlayer, HearNoise, Bump;

	function HeadZoneChange(ZoneInfo newHeadZone)
	{
		Global.HeadZoneChange(newHeadZone);
		if (!newHeadZone.bWaterZone)
			GotoState('Attacking');
	}

	function HitWall(vector HitNormal, actor Wall)
	{
		//change directions
		Destination = 200 * (Normal(Destination - Location) + HitNormal);
	}

	function Timer( optional int TimerNum )
	{
		bReadyToAttack = True;
		settimer(0.5, false);
	}

	function EnemyNotVisible()
	{
		bReadyToAttack = false;
	}

	function PickDestination(bool bNoCharge)
	{
		Destination = VRand();
		Destination.Z = 1;
		Destination = Location + 200 * Destination;				
	}

Begin:
	//log("***Find air");
	TweenToRunning(0.2);
	Enable('AnimEnd');
	PickDestination(false);

DoMove:	
	if ( Enemy == None )
		MoveTo(Destination);
	else
	{
		bCanFire = true;
		StrafeFacing(Destination, Enemy);	
	}
	ChooseAttackState();

TakeHit:
	TweenToRunning(0.12);
	Goto('DoMove');

}

function bool FriendsNearEnemy( float Radius )
{
	local Pawn P;

	
	foreach enemy.radiusactors( class'Pawn', P, Radius )
	{
		if( P.IsA( 'HumanNPC' ) && P.bSnatched == bSnatched && P != Self )
		{
			if( LineOfSightTo( P ) )
			{
				return true;
			}
		}
	}
	return false;
}

event AnimTick(float DeltaTime)
{
	local int i;

	if( !bPlayerCanSeeMe )
	{
		return;
	}
	else
	{
		if ( bLaissezFaireBlending )
			return;

		// Update all the blending.
		TopAnimBlend     = UpdateRampingFloat(TopAnimBlend,     DesiredTopAnimBlend,     TopAnimBlendRate*DeltaTime);
		BottomAnimBlend  = UpdateRampingFloat(BottomAnimBlend,  DesiredBottomAnimBlend,  BottomAnimBlendRate*DeltaTime);
		SpecialAnimBlend = UpdateRampingFloat(SpecialAnimBlend, DesiredSpecialAnimBlend, SpecialAnimBlendRate*DeltaTime);
		FaceAnimBlend    = UpdateRampingFloat(FaceAnimBlend, DesiredFaceAnimBlend, FaceAnimBlendRate*DeltaTime);

		GetMeshInstance();
		if (MeshInstance != None)
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
			if ( DesiredFaceAnimBlend>=1.0 && FaceAnimBlend>=1.0 )
			{
				MeshInstance.MeshChannels[5].AnimSequence = 'None';
			}
		}
	}
}

function Tick(float inDeltaTime)
{	
	local float CrouchShiftTime;
	
	if( TimeExisted < 1.5 && !bSwitchSoundOn )
		TimeExisted += inDeltaTime;
	else
		bSwitchSoundOn = true;

	if( !bCanEmergencyJump )
	{
		JumpTimer += inDeltaTime;
		if( JumpTimer > 3.0 )
		{
			bCanEmergencyJump = true;
			JumpZ = -1;
			bCanJump = false;
			JumpTimer = 0.0;
		}
	}

	if( bSightlessFire )
	{
		LeftoverFireTimer += inDeltaTime;
		
		if( LeftoverFireTimer > 3.0 )
		{
			LeftoverFireTimer = 0;
			bSightlessFire = false;
		}
	}

	// Shrinking tick.
	TickShrinking( inDeltaTime );

	if( !bPlayerCanSeeMe )
		return;
	
	TickTracking( inDeltaTime );

	if( bWeaponFireDisabled )
	{
		FireTimer += inDeltaTime;

		if( FireTimer > TimeBetweenBursts )
		{
			FireTimer = 0.0;
			bWeaponFireDisabled = false;
		}
	}

/*	if( bCoweringDisabled )
	{
		LastCowerTime += inDeltaTime;
		if( LastCowerTime > 5.0 )
		{
			LastCowerTime = 0.0;
			bCoweringDisabled = false;
		}
	}*/

	if( bNoPain )
	{
		LastPain += inDeltaTime;
		if( LastPain > PainInterval )
		{
			bNoPain = false;
			LastPain = 0.0;
		}
	}
}

simulated event bool OnEvalBones(int Channel)
{
	if( Channel == 10 )	// JEP Changed lip sync, blinking, etc to use channel 10 (needed channels 6,7,8,9 for lip facial expression stuff)
	{
		if (!PlayerCanSeeMe())
		{
		//	EvalLipSync();
			bPlayerCanSeeMe = false;
			return false;
		}
		else
		{
			bPlayerCanSeeMe = true;
			if( bArmless )
			{
				EvalArmBlownOff();
			}
			return Super.OnEvalBones( Channel );
		}
	}
}

function EnableEyeTracking(bool bEnable)
{
	if( bEnable )
	{
		EyeTracking.DesiredWeight = 0.3;
		EyeTracking.WeightRate = 1.0;
	} else {
		EyeTracking.DesiredWeight = 0.3;
		EyeTracking.WeightRate = 1.0;
	}
}

simulated function bool EvalHeadLook()
{
    local int bone;
    local MeshInstance minst;
	local rotator r;
	local float f;
	local vector t;
	local rotator EyeLook, HeadLook, BodyLook;
	local rotator LookRotation;
	local float HeadFactor, ChestFactor, AbdomenFactor;
	local float PitchCompensation;
   
	local int RandHeadRot;

	minst = GetMeshInstance();

    if (minst==None || GetStateName() == 'Dying' )
        return false;

	if( GetStateName() == 'ActivityControl' && MyAE != None && MyAE.bIgnoreHeadLook )
		return false;

	if( !bPlayerCanSeeMe )
		return false;

	HeadLook = HeadTracking.Rotation - Rotation;
	HeadLook = Normalize(HeadLook);
	HeadLook = Slerp(HeadTracking.Weight, rot(0,0,0), HeadLook);
	r = Normalize(ClampHeadRotation(HeadTracking.DesiredRotation) - Rotation);
	EyeLook = minst.WorldToMeshRotation(EyeTracking.Rotation);
	if( bForceNoLookAround )
		EyeLook.yaw *= 0.2;
	else
		EyeLook.Yaw *= 0.125; // minimal eye movements cover large ground, so scale back rotation
	EyeLook = Slerp(EyeTracking.Weight, rot(0,0,0), EyeLook);
	if ( bCanTorsoTrack ) //&& ( Enemy != None || SpeechTarget != None ) ) // full body head look
	{
		LookRotation = HeadLook;

		if( bTurning )
		{
			HeadFactor = 0.45;
			ChestFactor = 0.5;
			AbdomenFactor = 0.77;
			PitchCompensation = 0.05;
		}
		else
		{
	
			HeadFactor = 0.35;
			ChestFactor = 0.65;
			AbdomenFactor = 0.77;
			PitchCompensation = 0.05;
		}
		bone = minst.BoneFindNamed('Abdomen');
		if (bone!=0 && bCanTorsoTrack && GetStateName() != 'Idling' && GetStateName() != 'Acquisition' )
		{
			if( TempAbdomenFactor > 0.0 )
				AbdomenFactor = TempAbdomenFactor;

			r = LookRotation;
			r = rot( r.Pitch*AbdomenFactor + Abs(r.Yaw)*PitchCompensation, 0 + r.Yaw*PitchCompensation,-r.Yaw*AbdomenFactor);
			minst.BoneSetRotate(bone, r, true, true);
		}
		bone = minst.BoneFindNamed('Chest');
		if (bone!=0 && bCanTorsoTrack && GetStateName() != 'Idling' && GetStateName() != 'Acquisition' )
		{
			if( TempChestFactor > 0.0 )
				ChestFactor = TempChestFactor;
			r = LookRotation;
			r = rot(/*r.Pitch*ChestFactor */ 0,0,-r.Yaw*ChestFactor);
			//minst.BoneSetRotate(bone, r, true, true);
		}
		bone = minst.BoneFindNamed('Head');

		if( TempHeadFactor > 0.0 )
			HeadFactor = TempHeadFactor;
		if( GetStateName() == 'Idling' ) 
			HeadFactor = 0.85;
		if (bone!=0 )
		{
			r = LookRotation;
			r = rot( r.Pitch *HeadFactor ,0,-r.Yaw*HeadFactor);
			minst.BoneSetRotate(bone, r, true, true);
		}
	}
	else // head-only head look
	{
		LookRotation = HeadLook;
		bone = minst.BoneFindNamed('Head');
		if (bone!=0)
		{
			r = LookRotation;
			r = rot(r.Pitch,0,-r.Yaw);
			minst.BoneSetRotate(bone, r, false, true);
		}
	}
	LookRotation = EyeLook;
	bone = minst.BoneFindNamed('Pupil_L');
	if (bone!=0)
	{			
		r = LookRotation;
		r = rot(r.pitch,0,-r.Yaw);
		minst.BoneSetRotate(bone, r, true, true);
	}
	bone = minst.BoneFindNamed('Pupil_R');
	if (bone!=0)
	{
		r = LookRotation;
		r = rot(r.pitch,0,-r.Yaw);
		minst.BoneSetRotate(bone, r, true, true);
	}
	return(true);
}


//----------------------------------------------------------------------------
//    Miscellaneous Utility Functions
//----------------------------------------------------------------------------
/*
	FindNearestActor - General utility function for finding the nearest actor of a given subclass to the
	creature, within an optional radius.  Can be restricted to world trace visibility like FindNearestPath.
	
	FIXME: FindNearestPath is fine without any FOV checks, but this may need them.  Should the fov check be
	based on head angle in addition to rotation, or is the head angle just for visual fluff?  Hmm...
*/
function actor FindNearestActor(class<actor> findClass, optional float maxDist, optional bool bVisibleOnly)
{
	local actor a, best;
	local float dist, bestDist;
	local vector viewLoc;

	viewLoc = Location + vect(0,0,BaseEyeHeight);
	best = None;
	bestDist = 999999.0;
	if (maxDist > 0.0)
		bestDist = maxDist;

	foreach AllActors(findClass, a)
	{
		if (a == self)
			continue;
		dist = VSize(viewLoc - a.Location);
		if (dist < bestDist)
		{
			if ((!bVisibleOnly) || (FastTrace(viewLoc, a.Location)))
			{
				bestDist = dist;
				best = a;
			}
		}
	}
	return(best);
}

//----------------------------------------------------------------------------
//    Eye & Head Tracking
//----------------------------------------------------------------------------
function rotator ClampEyeRotation(rotator r)
{
	local rotator adj;
	adj = Slerp(HeadTracking.Weight, Rotation, HeadTracking.Rotation);
	r = Normalize(r - adj);
	r.Pitch = Clamp(r.Pitch, -EyeTracking.RotationConstraints.Pitch, EyeTracking.RotationConstraints.Pitch);
	r.Yaw = Clamp(r.Yaw, -EyeTracking.RotationConstraints.Yaw, EyeTracking.RotationConstraints.Yaw);
	r.Roll = Clamp(r.Roll, -EyeTracking.RotationConstraints.Roll, EyeTracking.RotationConstraints.Roll);
	r = Normalize(r + adj);
	return(r);
}
function rotator ClampHeadRotation(rotator r)
{
	local rotator adj;
	adj = Rotation;
	r = Normalize(r - adj);
	r.Pitch = Clamp(r.Pitch, -HeadTracking.RotationConstraints.Pitch, HeadTracking.RotationConstraints.Pitch);
	r.Yaw = Clamp(r.Yaw, -HeadTracking.RotationConstraints.Yaw, HeadTracking.RotationConstraints.Yaw);
	r.Roll = Clamp(r.Roll, -HeadTracking.RotationConstraints.Roll, HeadTracking.RotationConstraints.Roll);
	r = Normalize(r + adj);
	return(r);
}

function EnableHeadTracking(bool bEnable)
{
	HeadTracking.DesiredWeight = 1.1;
	HeadTracking.WeightRate = 1.0;
}

function DisableHeadTracking()
{
	HeadTracking.DesiredWeight = 0.0;
}

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

/*
	FixedTurn - Takes a current rotation angle and a desired rotation angle, with a positive
	maximum to rotate by.  Returns a resulting angle.  Based on the internal physics "fixedTurn" method.
	FIXME: Perhaps this should be moved into a general native utility function.
*/
function int FixedTurn(int inCurrent, int inDesired, int inMaxChange, optional out int outDelta)
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

function TickTracking(float inDeltaTime)
{
	local rotator r;
	local MeshInstance Minst;
	local int bone;

	if( HeadTrackingActor != None )
		HeadTracking.DesiredWeight = 0.85;
	else
		HeadTracking.DesiredWeight = 0.55;
	if (HeadTracking.TrackTimer <= 0.0 && FRand() < 0.25 && HeadTrackingActor == None /*&& Enemy == None*/ && GetStateName() != 'ActivityControl' )
	{
		HeadTracking.TrackTimer = 2.5 + FRand()*1.5;
		if( Enemy == None )
		{
			HeadTracking.DesiredRotation = HeadTracking.Rotation + ( RotRand() * 0.5 );
			HeadTracking.DesiredRotation.Pitch *= 0.05;
			HeadTracking.DesiredRotation.Roll = 0;
		}
		else
			HeadTracking.DesiredRotation = Rotation;
	}

	if (HeadTracking.TrackTimer > 0.0)
	{
		HeadTracking.TrackTimer -= inDeltaTime;
		if (HeadTracking.TrackTimer < 0.0)
			HeadTracking.TrackTimer = 0.0;
	}
	HeadTracking.Weight = UpdateRampingFloat(HeadTracking.Weight, HeadTracking.DesiredWeight, HeadTracking.WeightRate*inDeltaTime);
	r = ClampHeadRotation(HeadTracking.DesiredRotation);
	HeadTracking.Rotation.Pitch = FixedTurn(HeadTracking.Rotation.Pitch, r.Pitch, int(HeadTracking.RotationRate.Pitch * inDeltaTime));
	HeadTracking.Rotation.Yaw = FixedTurn(HeadTracking.Rotation.Yaw, r.Yaw, int(HeadTracking.RotationRate.Yaw * inDeltaTime));
	HeadTracking.Rotation.Roll = FixedTurn(HeadTracking.Rotation.Roll, r.Roll, int(HeadTracking.RotationRate.Roll * inDeltaTime));
	HeadTracking.Rotation = ClampHeadRotation(HeadTracking.Rotation);

	// update eye tracking
	if (EyeTracking.TrackTimer > 0.0)
	{
		if( HeadTrackingActor != None && EyeTracking.DesiredRotation != Normalize( rotator( normal( HeadTrackingLocation - Location ) ) ) )
		{
			EyeTracking.TrackTimer = 0.0;
		}

		EyeTracking.TrackTimer -= inDeltaTime;
		if (EyeTracking.TrackTimer < 0.0)
			EyeTracking.TrackTimer = 0.0;
	}
	EyeTracking.Weight = UpdateRampingFloat(EyeTracking.Weight, EyeTracking.DesiredWeight, EyeTracking.WeightRate*inDeltaTime);
	r = EyeTracking.DesiredRotation;
	EyeTracking.Rotation.Pitch = FixedTurn(EyeTracking.Rotation.Pitch, r.Pitch, int(EyeTracking.RotationRate.Pitch * inDeltaTime));
	EyeTracking.Rotation.Yaw = FixedTurn(EyeTracking.Rotation.Yaw, r.Yaw, int(EyeTracking.RotationRate.Yaw * inDeltaTime));
	EyeTracking.Rotation.Roll = FixedTurn(EyeTracking.Rotation.Roll, r.Roll, int(EyeTracking.RotationRate.Roll * inDeltaTime));
	EyeTracking.Rotation = ClampEyeRotation(EyeTracking.Rotation);

	if (EyeTracking.TrackTimer <= 0.0 )
	{
		EyeTracking.TrackTimer = 0.5 + FRand()*1.5;
		if( HeadTrackingActor == None )
			EyeTracking.DesiredRotation = Normalize(Rotation + rot(0, int(FRand()*20384.0 - 8192.0), 0));
		else
			EyeTracking.DesiredRotation = Normalize( rotator( normal( HeadTrackingLocation - Location ) ) ) + rot( 0, int( FRand()* 140384.0 - 8192.0), 0);
		EyeTracking.DesiredRotation.Roll = 0;
	}

	if (HeadTrackingActor!=None)
	{
		HeadTrackingLocation = HeadTrackingActor.Location;
		HeadTracking.DesiredRotation = Normalize(rotator(Normal(HeadTrackingLocation - Location)));
		HeadTracking.DesiredRotation.Roll = 0;
	}
}

//----------------------------------------------------------------------------

function PostureStateChange_Standing(EPostureState OldState) 
{
}

function PostureStateChange_Crouching(EPostureState OldState) 
{
}

function PostureStateChange_Jumping(EPostureState OldState) 
{
}

function PostureStateChange_Swimming(EPostureState OldState) 
{
	PlaySwimming();
}

state Roaming
{
	ignores EnemyNotVisible;

	function Timer( optional int TimerNum )
	{
		Enable('Bump');
	}

	function Bump(Actor Other)
	{
		if ( FRand() < 0.03)
		{
			// // // // // log( "GOING TO WANDERING F" );
			GotoState('Wandering');
		}
		else
			Super.Bump(Other);
	}

	function SetFall()
	{
		NextState = 'Roaming'; 
		NextLabel = 'ContinueRoam';
		GotoState('FallingState'); 
	}

	function EnemyAcquired()
	{
		GotoState('Acquisition');
	}

	function HitWall(vector HitNormal, actor Wall)
	{
		if (Physics == PHYS_Falling)
			return;
		if ( Wall.IsA('Mover') && Mover(Wall).HandleDoor(self) )
		{
			bSpecialGoal = true;
			if ( SpecialPause > 0 )
				Acceleration = vect(0,0,0);
			GotoState('Roaming', 'Moving');
			return;
		}
		Focus = Destination;
		if (PickWallAdjust())
			GotoState('Roaming', 'AdjustFromWall');
		else
			MoveTimer = -1.0;
	}
	
	function PickDestination()
	{
		local Actor path;
		if ((OrderObject == None) || actorReachable(OrderObject))
		{
			numHuntPaths = 0;
			OrderObject = FindRandomDest();
			if ( OrderObject != None )
				GotoState('Roaming', 'Pausing');
			else
				GotoState('Idling');
			return;
		}
		numHuntPaths++;
		if ( numHuntPaths > 80 )
			GotoState('Wandering');
		if (SpecialGoal != None)
			path = FindPathToward(SpecialGoal);
		else if (OrderObject != None)
			path = FindPathToward(OrderObject);
		else
			path = None;
			
		if (path != None)
		{
			MoveTarget = path;
			Destination = path.Location;
		}
		else 
		{
						// // // // // log( "GOING TO WANDERING G" );

			GotoState('Wandering');
		}
	}
	
	function BeginState()
	{
		PlayTopAnim( 'None' );
		PlayBottomAnim( 'None' );
		EnableHeadTracking( true );
		EnableEyeTracking( true );
		HeadTrackingActor = None;
		SpecialGoal = None;
		//Disable( 'AnimEnd' );
		bSpecialGoal = false;
		SpecialPause = 0.0;
		Enemy = None;
		SetAlertness(0.2);
		bReadyToAttack = false;
	}
		
Begin:
	//log(class$" Roaming");

Roam:
	WaitForLanding();
	PickDestination();
	NotifyMovementStateChange( MS_Walking, MS_Waiting );	
Moving:
	if (SpecialPause > 0.0)
	{
		StopMoving();
		NotifyMovementStateChange( MS_Waiting, MS_Walking );
		Sleep(SpecialPause);
		EnableHeadTracking(true);
		EnableEyeTracking(true);
		SpecialPause = 0.0;
		NotifyMovementStateChange( MS_Walking, MS_Waiting );	
	}
	MoveToward(MoveTarget, GetWalkingSpeed());
	if ( bSpecialGoal )
	{
		bSpecialGoal = false;
		Goto('Roam');
	}
	StopMoving();
	NotifyMovementStateChange( MS_Waiting, MS_Walking );
Pausing:
	StopMoving();
	Sleep( 2.5 + FRand() );
	EnableHeadTracking(true);
	EnableEyeTracking(true);
	Goto('Roam');

ContinueRoam:
	NotifyMovementStateChange( MS_Walking, MS_Waiting );
	Goto('Roam');

AdjustFromWall:
	StrafeTo(Destination, Focus); 
	Destination = Focus; 
	Goto('Moving');
}

function SetSnatchedEffects( int SkinNum )
{
}

function SetSnatchedFace( int SkinNum );
function SetSnatchedParts( int SkinNum );

function SproutTentacles()
{
	local MeshInstance Minst;
	local int Bone;

	if( MyShoulderTentacle2 == None )
	{
		MyShoulderTentacle2 = CreateTentacle( TentacleOffsets.LeftShoulderOffset, TentacleOffsets.LeftShoulderRotation, 'Chest' );
		MyShoulderTentacle2.GotoState( 'ShoulderDamageTentacle' );
	}
	if( MyShoulderTentacle1 == None )
	{
		MyShoulderTentacle1 = CreateTentacle( TentacleOffsets.RightShoulderOffset, TentacleOffsets.RightShoulderRotation, 'Chest' );
		MyShoulderTentacle1.GotoState( 'ShoulderDamageTentacle' );
	}
	if( MiniTentacle1 == None && Mesh != DukeMesh'EDF1' && Mesh != DukeMesh'EDF2' && Mesh != DukeMesh'EDF2Desert' && Mesh != DukeMesh'EDF3' && Mesh != DukeMesh'EDF3Desert' 
		&& Mesh != DukeMesh'EDF6' && Mesh != DukeMesh'EDF6Desert' )
	{
		MiniTentacle1 = Spawn( class'TentacleSmall', self );
		MiniTentacle1.AttachActorToParent( self, true, true );
		MiniTentacle1.MountAngles.Pitch = -20384;
		MiniTentacle1.MountAngles.Yaw = 16384;
		MiniTentacle1.MountOrigin.Y = -0.3;
		MiniTentacle1.MountOrigin.Z = -1.5;
		MiniTentacle1.MountType = MOUNT_MeshBone;
		MiniTentacle1.MountMeshItem = 'Pupil_L';
		MiniTentacle1.bHidden = false;
		Minst = GetMeshInstance();
		Bone = Minst.BoneFindNamed( 'Pupil_L' );
		Spawn( class'dnParticles.dnBloodFX', self,, Minst.MeshToWorldLocation( Minst.BoneGetTranslate( Bone, true, false ) ), Minst.MeshToWorldRotation( Minst.BoneGetRotate( Bone ) ) * -1 );
		//BloodEffect( Minst.MeshToWorldLocation( Minst.BoneGetTranslate( Bone, true, false ) ), 'Shot', vect( 0, 0, 0 ) );
	}
	if( MiniTentacle2 == None )
	{
		MiniTentacle2 = Spawn( class'TentacleSmall', self );
		MiniTentacle2.AttachActorToParent( self, true, true );
		MiniTentacle2.MountAngles.Pitch = -20384;
		MiniTentacle2.MountAngles.Yaw = 16384;
		MiniTentacle2.MountOrigin.X = 2.000000;
		MiniTentacle2.MountOrigin.Y = 2.000000;
		MiniTentacle2.MountOrigin.Z = -2.000000;
		MiniTentacle2.MountAngles.Pitch = -12384;
		MinITentacle2.MountAngles.Yaw=19384;
		MiniTentacle2.MountType = MOUNT_MeshBone;
		MiniTentacle2.MountMeshItem = 'Neck';
		MiniTentacle2.bHidden = false;
	}
	if( MiniTentacle3 == None )
	{
		MiniTentacle3 = Spawn( class'TentacleSmall', self );
		MiniTentacle3.AttachActorToParent( self, true, true );
		MiniTentacle3.MountAngles.Pitch = -20384;
		MiniTentacle3.MountAngles.Yaw = 16384;
		MiniTentacle3.MountOrigin.X = 2.000000;
		MiniTentacle3.MountOrigin.Y = -2.000000;
		MiniTentacle3.MountOrigin.Z = -2.000000;
		MiniTentacle3.MountAngles.Pitch = -20384;
		MiniTentacle3.MountAngles.Yaw=19384;
		MiniTentacle3.MountType = MOUNT_MeshBone;
		MiniTentacle3.MountMeshItem = 'Neck';
		MiniTentacle3.bHidden = false;
	}
	if( MiniTentacle4 == None && Mesh != DukeMesh'EDF1' && Mesh != DukeMesh'EDF1Desert' && Mesh != DukeMesh'EDF2' && Mesh != DukeMesh'EDF2Desert' && Mesh != DukeMesh'EDF3' && Mesh != DukeMesh'EDF3Desert' 
		&& Mesh != DukeMesh'EDF6' && Mesh != DukeMesh'EDF6Desert' )
	{
		MiniTentacle4 = Spawn( class'TentacleSmall', self );
		MiniTentacle4.AttachActorToParent( self, true, true );
		MiniTentacle4.MountAngles.Pitch = -20384;
		MiniTentacle4.MountAngles.Yaw = 16384;
		MiniTentacle4.MountOrigin.Y = 0.300000;
		MiniTentacle4.MountOrigin.Z = -1.500000;
		MiniTentacle4.MountAngles.Pitch = -12384;
		MinITentacle4.MountAngles.Yaw=16384;
		MiniTentacle4.MountType = MOUNT_MeshBone;
		MiniTentacle4.MountMeshItem = 'Pupil_R';
		MiniTentacle4.bHidden = false;
	}
	if( MiniTentacle1 != None )
		MiniTentacle1.GotoState( 'Swinging' );
	if( MiniTentacle2 != None )
		MiniTentacle2.GotoState( 'Swinging' );
	if( MiniTentacle3 != None )
		MiniTentacle3.GotoState( 'Swinging' );
	if( MiniTentacle4 != None )
		MiniTentacle4.GotoState( 'Swinging' );
}

state SnatchedEffects
{
	ignores SeePlayer, Bump, EnemyNotVisible, HearNoise;

	function BeginState()
	{
		local MeshDecal a;
		local MeshInstance Minst;
		local int bone;

		log( self$" entered SnatchedEffects state" );

		if( self.IsA( 'EDFGrunts' ) )
			bUseSnatchedEffects = true;

		if( bSleepAttack )
			return;
		else
			SproutTentacles();
	//	Spawn( class'dnParticles.dnBloodFX', self,, Minst.MeshToWorldLocation( Minst.BoneGetTranslate( Bone, true, false ) ), Minst.MeshToWorldRotation( Minst.BoneGetRotate( Bone ) ) * -1 );
	}

	function Timer( optional int TimerNum )
	{
		local Texture FaceTex;
	
		if( self.IsA( 'NPC' ) )
		{
			FaceTex = MultiSkins[ 0 ];
				
		if( NPCFaceNum == 1 || self.IsA( 'NPCMale1' ) )
		{
			if( MultiSkinsCounter == 3 )
			{
				MultiSkins[ 0 ] = texture'm_characters.MaleHeadSnah1DRC';
				MultiSkins[ 3 ] = texture'm_characters.MalePartSnah1DRC';
				MultiSkinsCounter++;
			}
		}
		else if( NPCFaceNum == 2 || self.IsA( 'NPCMale2' ) )
		{
		
			if( MultiSkinsCounter == 3 )
			{
				MultiSkins[ 0 ] = texture'm_characters.MaleHeadSnah2DRC';
				MultiSkins[ 3 ] = Texture'm_characters.malepartsnah2dRC';
				MultiSkinsCounter++;
			}
		}
		else if( ( MultiSkins[ 0 ] == None && Mesh==DukeMesh'c_characters.NPC_M_OldA' && self.IsA( 'NPCRandom' ) ) ||  NPCFaceNum == 3 || self.IsA( 'NPCMale3' ) )
		{
			if( MultiSkinsCounter == 3 )
			{
				MultiSkins[ 0 ] = texture'm_characters.MaleHeadSnah3DRC';
				MultiSkins[ 3 ] = Texture'm_characters.malepartsnah3dRC';
				MultiSkinsCounter++;
			}
		}
		else if( NPCFaceNum == 4 || self.IsA( 'NPCMale4' ) )
		{
			if( MultiSkinsCounter == 3 )
			{
				MultiSkins[ 0 ] = texture'm_characters.MaleHeadSnah5DRC';
				MultiSkins[ 3 ] = Texture'm_characters.mechpartsnah1DRC';
				MultiSkinsCounter++;
			}
		}
	}
}

Begin:
	StopMoving();
	if( NextState != '' && !bSleepAttack )
	{
		bSnatched = false;
		Disable( 'Timer' );
		PlayAllAnim( 'A_PainHeadLONG',, 0.1, false );
	}
	Enable( 'Timer' );
	if( bSleepAttack )
	{
		MultiSkinsCounter = 3;
		Timer();
	}
	else
	if( !self.IsA( 'EDFGrunts' ) )
	{
		MultiSkinsCounter = 3;
		Timer();
	}
	bSnatched = true;
	if( !bSleepAttack )
	{
		//FinishAnim( 0 );
		//		FinishAnim( 0 );
		if( InitialIdlingAnim != '' )
			PlayAllAnim( InitialIdlingAnim,, 0.4, true );
		else
			PlayToWaiting();
	}
	if( /*bSnatched &&*/ bSleepAttack )
	{
		GotoState( 'SleepAttack' );
	}
	if( bHateWhenSnatched )
	{
		HateTag = 'DukePlayer';
		TriggerHate();
	}
	else
	if( bSnatchedAtStartup )
		WhatToDoNext( '','' );
	else
		GotoState( NextState );
}

function VictimScan()
{
	local Pawn P;
	foreach radiusactors( class'Pawn', P, AggroSnatchDistance )
	{
		if( !P.bSnatched && !P.IsA( 'PlayerPawn' ) )
		{
			if( CanSee( P ) && ActorReachable( P ) && !P.CanSee( self ) )
			{
				Enemy = P;
				bVisiblySnatched = true;
				bAggressiveToPlayer = true;
				NextState = 'Attacking';
				GotoState( 'SnatchedEffects' );
				break;
			}
		}
	}
}

state Wandering
{
	ignores EnemyNotVisible;

	function SeePlayer( actor SeenPlayer )
	{
		local float Dist;

		// // // // log( "SEE PLAYER 5" );

		if( bFixedEnemy )
			return;

		if( bAggressiveToPlayer && SeenPlayer.IsA( 'PlayerPawn' ) )
		{
			HeadTrackingActor = SeenPlayer;
			Enemy = SeenPlayer;
			GotoState( 'Attacking' );
		}
		else if( bSnatched && !bAggressiveToPlayer && SeenPlayer.IsA( 'PlayerPawn' ) )
		{
			Dist = VSize( SeenPlayer.Location - Location );
	
			if( Dist <= AggroSnatchDistance )
			{
				if( !PlayerCanSeeMe()  )
				{
					// // // // // log( "Disable SeePlayer 4 for "$self );
					Disable( 'SeePlayer' );
					Enemy = SeenPlayer;
					NextState = 'Attacking';
					bAggressiveToPlayer = true;
					GotoState( 'SnatchedEffects' );
					//SetTimer( ), false, 8 );
				}
			}
		}
	}

	function TurnToDestination()
	{
	    local int bone;
		local MeshInstance minst;
		local rotator r;
		local float f;
	
		local rotator EyeLook, HeadLook, BodyLook;
		local rotator LookRotation;
		local float HeadFactor, ChestFactor, AbdomenFactor;
		local float PitchCompensation;
		
		bone = minst.BoneFindNamed('Head');
		if (bone!=0)
		{
			r = rotator( Location - Destination );
			minst.BoneSetRotate(bone, r, true, true);
		}
	}

	function Timer( optional int TimerNum )
	{
		Enable('Bump');
	}

	function SetFall()
	{
		NextState = 'Wandering'; 
		NextLabel = 'ContinueWander';
		//NextAnim = AnimSequence;
		GotoState('FallingState'); 
	}

	function EnemyAcquired()
	{
		//GotoState('Acquisition');
	}

	function AnimEndEx(int Channel)
	{
		if (Channel==1  && GetSequence( 1 ) == 'T_IdleCough' )
		{
			GetMeshInstance();
			if (!MeshInstance.MeshChannels[Channel].bAnimLoop)
			{
				log(" **** NONE " );
				PlayTopAnim('None');
				HeadTracking.Weight = 0.0;
				EyeTracking.Weight = 0.0;
			}
		}
	}
	
	function HitWall(vector HitNormal, actor Wall)
	{
		if (Physics == PHYS_Falling)
			return;
		if ( Wall.IsA('Mover') && Mover(Wall).HandleDoor(self) )
		{
			if ( SpecialPause > 0 )
				Acceleration = vect(0,0,0);
			// // // // // log( "GOING TO WANDERING H" );

			GotoState('Wandering', 'Pausing');
			return;
		}
		Focus = Destination;
		if ( PickWallAdjust() && (FRand() < 0.7) )
		{
			if ( Physics == PHYS_Falling )
				SetFall();
			else
			{
							// // // // // log( "GOING TO WANDERING I" );

				GotoState('Wandering', 'AdjustFromWall');
			}
		}
		else
			MoveTimer = -1.0;
	}
	
	function bool TestDirection(vector dir, out vector pick)
	{	
		local vector HitLocation, HitNormal, dist;
		local float minDist;
		local actor HitActor;

		minDist = FMin(150.0, 4*CollisionRadius);
		if ( (Orders == 'Follow') && (VSize(Location - OrderObject.Location) < 500) )
			pick = dir * (minDist + (200 + 6 * CollisionRadius) * FRand());
		else
			pick = dir * (minDist + (450 + 12 * CollisionRadius) * FRand());

		HitActor = Trace(HitLocation, HitNormal, Location + pick + 1.5 * CollisionRadius * dir , Location, false);
		if (HitActor != None)
		{
			pick = HitLocation + (HitNormal - dir) * 2 * CollisionRadius;
			if ( !FastTrace(pick, Location) )
				return false;
		}
		else
			pick = Location + pick;
		 
		dist = pick - Location;
		if (Physics == PHYS_Walking)
			dist.Z = 0;
		
		return (VSize(dist) > minDist); 
	}
			
	function PickDestination()
	{
		local vector pick, pickdir;
		local bool success, bMustWander;
		local float XY;

		//Favor XY alignment
		XY = FRand();
		if ( WanderDir != vect(0,0,0) )
		{
			pickdir = WanderDir;
			XY = 1;
			bMustWander = true;
		}
		else if (XY < 0.3)
		{
			pickdir.X = 1;
			pickdir.Y = 0;
		}
		else if (XY < 0.6)
		{
			pickdir.X = 0;
			pickdir.Y = 1;
		}
		else
		{
			pickdir.X = 2 * FRand() - 1;
			pickdir.Y = 2 * FRand() - 1;
		}
		if (Physics != PHYS_Walking)
		{
			pickdir.Z = 2 * FRand() - 1;
			pickdir = Normal(pickdir);
		}
		else
		{
			pickdir.Z = 0;
			if (XY >= 0.6)
				pickdir = Normal(pickdir);
		}	

		success = TestDirection(pickdir, pick);
		if (!success)
			success = TestDirection(-1 * pickdir, pick);
		
		if (success)	
			Destination = pick;
		else if ( bMustWander )
		{
			WanderDir = Normal(WanderDir + VRand());
			WanderDir.Z = 0;
			Destination = Location + 100 * WanderDir;
		}
		else
		{
						// // // // // log( "GOING TO WANDERING J" );

			GotoState('Wandering', 'Turn');
		}

		WanderDir = vect(0,0,0);
	}


	function BeginState()
	{
		if( !self.IsA( 'NPC' ) )
			PlayTopAnim( 'None' );
		Enemy = None;
		HeadTrackingActor = None;
		SetAlertness(0.2);
		bReadyToAttack = false;
		bCanJump = false;
	}
	
	function EndState()
	{
		if (JumpZ > 0)
			bCanJump = true;
	}


Begin:
	//log(class$" Wandering");
	Disable( 'AnimEnd' );
Wander: 
	Enable( 'AnimEnd' );
	WaitForLanding();
	PickDestination();
	
Moving:
	Enable('HitWall');

	if( GetSequence( 2 ) != '' )
	{
		PlayBottomAnim( 'None' );
	}
	TurnTo( Destination );
	if( !bPanicking )
		PlayToWalking();
	else
		PlayToRunning();
	MoveTo(Destination, GetWalkingSpeed() );
	Disable( 'AnimEnd' );
	
Pausing:
	StopMoving();
	if ( NearWall( CollisionRadius + 12) )
	{
		TurnTo(Focus);
	}
	Enable('AnimEnd');
	PlayToWaiting();
	Sleep(1.0);
	Disable('AnimEnd');
	// Sneaky
	if( bSnatched && !bAggressiveToPlayer )
	{
//		VictimScan();
	}
	Goto('Wander');
	
ContinueWander:
	if (FRand() < 0.2)
		Goto('Turn');
	Goto('Wander');

Turn:
	if( !bPanicking )
	{
	StopMoving();
	// Was RandTurningPoint; might cause trouble using destination.
	Destination = Location + 20 * VRand();
	if ((rotator(Destination - Location) - Rotation).Yaw < 0)
		PlayTurnLeft();
	else
		PlayTurnRight();

	TurnTo( Destination );
	}
//	TurnTo(Location + Destination);
	if( !bPanicking )
		Goto('Pausing');
	else
		Goto( 'ContinueWander' );

AdjustFromWall:
	Enable( 'AnimEnd' );
	StrafeTo(Destination, Focus); 
	Disable( 'AnimEnd' );
	Destination = Focus; 
	Goto('Moving');
}

function AnimEndEx(int Channel)
{
	if (Channel==1)
	{
		GetMeshInstance();
	if (!MeshInstance.MeshChannels[Channel].bAnimLoop)
	{
		if( !bShieldUser )
		PlayTopAnim('None'); // smear top channel
	}
	}
	else if (Channel==2)
	{
		GetMeshInstance();
	if (!MeshInstance.MeshChannels[Channel].bAnimLoop)
		PlayBottomAnim('None'); // smear bottom channel
	}
}

simulated function DebugWatchBegin(DebugView D)
{
    Super.DebugWatchBegin(D);
    D.AddWatch("Health");
	D.AddWatch("Weapon");
}

function WarnFriendsOnDeath()
{
	local int i;
	local Pawn P;

	log( "WARN FRIENDS ON DEATH CALLED!" );
	for( P = Level.PawnList; P != None; P = P.NextPawn )
	{
		if( P.IsA( 'EDFGrunts' ) && P.CanSee( Self ) && P != Self )
		{
			if( !EDFGrunts( P ).bSteelSkin )
			{
				log( "HAVING "$P$" WARN FRIENDS" );
				EDFGrunts( P ).SpeechCoordinator.RequestSound( EDFGrunts( P ), 'SeeTeamDeath' );
			}
		}
	}
}

function Died(pawn Killer, class<DamageType> DamageType, vector HitLocation, optional vector Momentum )
{
	if( FRand() < 0.22 )
		PlayFaceAnim( 'F_Pain2',, 0.2, false );
	else PlayFaceAnim( 'F_Pain1',, 0.2, false );

//	if( MyCombatController == None )
	WarnFriendsOnDeath();
	
	if( MyGiveItem != None )
	{
		MyGiveItem.Destroy();
	}

	if( bShieldUser )
	{
		RemoveMountable( MyShield );
		MyShield.AttachActorToParent( none, false, false );
		MyShield.Tossed();
		MyShield.Velocity += VRand() * 128;
		MyShield.Velocity.Z = 200;
		MyShield.SetOwner( None );
		MyShield = None;
	}
	Super.Died( Killer, DamageType, HitLocation );
	if( MyCoverPoint != None )
	{
		MyCoverPoint.Taken = false;
		MyCoverPoint = None;
	}

	if( Killer != None && Killer.IsA( 'PlayerPawn' ) )
	{
		EvaluateEgoValue();
		if( EgoKillValue > 0 )
			PlayerPawn( Killer ).AddEgo( EgoKillValue );
		else
			PlayerPawn( Killer ).SubtractEgo( EgoKillValue );
	}
	Destroy();
}

function bool CanSeeEnemyFrom( vector aLocation, optional float NewEyeHeight, optional bool bUseNewEyeHeight )
{
	local actor HitActor;
	local vector HitNormal, HitLocation, HeightAdjust;
	if( bUseNewEyeHeight )
		HeightAdjust.Z = NewEyeHeight;
	else
		HeightAdjust.Z = BaseEyeHeight;
	HitActor = Trace( HitLocation, HitNormal, Enemy.Location, aLocation + HeightAdjust, true );
	if( HitActor == Enemy )
		return true;
	return false;
}

state Sniping
{
	ignores SeePlayer;

Begin:
	PlayAllAnim( 'A_GetDown',, 0.2, false );
	FinishAnim( 0 );
	PlayAllAnim( 'A_DownIdleA',, 0.1, true );
	GotoState( 'SnipeFiring' );
}

state SnipeFiring
{
	ignores EnemyNotVisible;

Begin:
	if( CanSee( Enemy ) )
	{
		TurnTo( Enemy.Location );
		Sleep( FRand() * 0.1 );
		bCanFire = true;
		bReadyToAttack = true;
		bFire = 1;
		//PlayRangedAttack();
		bFire = 0;
		Sleep( 3.0 );
	}
	Sleep( 0.2 );
	Goto( 'Begin' );
}

/*simulated function GetTraceFireSegment( out vector Start, out vector End, out vector BeamStart, optional float HorizError, optional float VertError )
{
	local Pawn PawnOwner;
	local vector X, Y, Z;
	local rotator AdjustedAim;

	GetAxes( ViewRotation, X, Y, Z );
	Start = Location + BaseEyeHeight * vect(0,0,1);
	AdjustedAim = AdjustAim( 1000000, Start, 500, false, false );	
	End = Start + HorizError * (FRand() - 0.5) * Y * 10000 + VertError * (FRand() - 0.5) * Z * 10000;
	X = vector(AdjustedAim);
	End += (10000 * X);
	if ( Weapon.MuzzleFlash3rd != None )
		BeamStart = Weapon.MuzzleFlash3rd.Location;
}
*/
/*
// Performs actual hit logic.
function TraceHit( vector StartTrace, vector EndTrace, Actor HitActor, vector HitLocation, 
				   vector HitNormal, int HitMeshTri, vector HitMeshBarys, name HitMeshBone, 
				   texture HitMeshTex, Actor HitInstigator, vector BeamStart )
{
	local Actor TestHitActor;
	local vector TestHitLocation, TestHitNormal;
	local HitPackage hit;
	local float HitDamage;
	// 80% chance that we perform near miss l0gic if we hit a wall.
	if ( (HitActor == Level) && (FRand() < 0.8) )
	{
		// Perform an additional trace to see if we had a "near miss"
		TestHitActor = Trace( TestHitLocation, TestHitNormal, EndTrace, StartTrace, true );
		if ( PlayerPawn(TestHitActor) != None )
			TestHitActor.NearMiss();
	}
	// Perform extended processing if we don't hit the level and didn't hit ourselves.
	if ( (HitActor != None) && (HitActor != Self) && (HitActor != Owner) && (HitActor != Level) )
	{
		// Set a fake mesh hit bone if we aren't in mesh accurate hit mode.
		if ( !Level.Game.bMeshAccurateHits )
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
		FillHitPackage( hit, HitDamage, self, StartTrace, BeamStart );
		DeliverHitPackage( hit );
	}
	else if ( HitActor == Level )
	{
//		HitLevel( HitLocation, StartTrace, BeamStart );
	}
}
*/
//simulated function int GetHitDamage( actor Victim, name BoneName )
//{
//	return Weapon.GetHitDamage( Victim, BoneName );
//}

/*-----------------------------------------------------------------------------
	Acquisition State. 
-----------------------------------------------------------------------------*/

state Acquisition
{
	ignores SeePlayer, SawEnemy;

	function BeginState()
	{
		if( Enemy != None )
			HeadTrackingActor = Enemy;
		if( !bSteelSkin )
			SpeechCoordinator.RequestSound( self, 'Acquisition' );
	}

	function Timer( optional int TimerNum )
	{
		GotoState( 'Attacking' );
	}

Begin:

	EnableHeadTracking( true );
	EnableEyeTracking( true );
	HeadTrackingActor = Enemy;
	if( MyAE != None )
	{
		GotoState( 'ApproachingEnemy' );
		MyAE = None;
	}

	if( NeedToTurn( Enemy.Location ) )
	{
		StopMoving();
	//	if ((rotator(Enemy.Location - Location) - Rotation).Yaw < 0)
	//		PlayTurnLeft();
	//	else
	//		PlayTurnRight();
		TurnTo(Enemy.Location);
		PlayToWaiting();
	}
	Sleep( PreAcquisitionDelay );

	if( AcquisitionSound != None )
	{
		PlaySound( AcquisitionSound, SLOT_Talk,,,,,true );
	}
	else
	{
		GotoState( 'Attacking' );
	}
	if( AcquisitionSound != None )
		SetTimer( GetSoundDuration( AcquisitionSound )+ 0.25, false );
	if( AcquisitionTopAnim != 'None' )
	{
		PlayTopAnim( AcquisitionTopAnim,, 0.1, false );
	}
	if( AcquisitionBottomAnim != 'None' )
	{
		PlayBottomAnim( AcquisitionBottomAnim,, 0.1, false );
	}
	if( AcquisitionAllAnim != 'None' )
	{
		PlayAllAnim( AcquisitionAllAnim,, 0.1, bLoopAcquisitionAnim );
	}

	if( PostAcquisitionDelay > 0 )
	{
	//	Sleep( AcquisitionDelay );
	}
}

  
/*-----------------------------------------------------------------------------
	Attacking State. 
-----------------------------------------------------------------------------*/

state Attacking
{
	ignores SeePlayer, HearNoise, Bump, HitWall;

	function ChooseAttackMode()
	{
		local eAttitude AttitudeToEnemy;
		local float Aggression;
		local pawn changeEn;
		local bool bWillHunt;
		if( ( Weapon == None || bMeleeMOde ) && VSize( Location - Enemy.Location ) < 164 /*&& Physics != PHYS_Swimming*/ )
		{
			//if( Physics == PHYS_Swimming )
/*			if( VSize( Location - Enemy.Location ) < 64 )
			{
				if( !bSnatched || FRand() < 0.33 )
				{
					// // // // // log( "Going back" );
					GotoState( 'MeleeCombat' );
					return;
				}
				else if( bSnatched )
				{
					GotoState( 'TentacleThrust' );
					return;
				}
			}
			else*/
			if( ( self.IsA( 'NPC' ) && bSnatched ) || bSteelSkin )
			{
			log( self$" with "$bSleepAttack$" Going to ApproachingEnemy 3" );
				GotoState( 'ApproachingEnemy' );
			}
			else
				GotoState( 'Charging' );
			//else
			//	GotoState( 'TacticalTest' );
			return;
		}
		if( bUsingCover && GetPostureState() == PS_Crouching )
		{
			GotoState( 'RangedAttack', 'DoneCrouchFiring' );
		}
	//	// // // // // log( "Ego: "$PlayerPawn( Enemy ).Ego );

		if( Enemy == None /* || Enemy.Health <= 0 */ || Enemy.IsInState( 'Detonation' ) )
		{
			if( Enemy != None && Enemy.Owner != None )
			{
				SetEnemy( Enemy.Owner );
			}
			else
			{
				bAggressiveToPlayer=Default.bAggressiveToPlayer;
				bAggressiveToPlayer = bSnatched;
				// TEMPORARY
				if( self.IsA( 'NPC' ) )
					bFixedEnemy = false;
				if( !bSteelSkin )
				{
					SpeechCoordinator.RequestSound( self, 'KilledDuke' );
				}

				GotoState( 'Idling' );
			}
		}
		bWillHunt = bMustHunt;
		bMustHunt = false;
	
		AttitudeToEnemy = AttitudeTo( Enemy );
		goalstring = "no attract check";
		if (AttitudeToEnemy == ATTITUDE_Fear)
		{
			//// // // // // log( "Retreating" );
			GotoState('Retreating');
			return;
		}
		else if (AttitudeToEnemy == ATTITUDE_Friendly)
		{
			//// // // // // log( "Friendly" );
			return;
		}
		else if ( !LineOfSightTo(Enemy) )
		{
			if ( (OldEnemy != None) 
				&& (AttitudeTo( OldEnemy ) == ATTITUDE_Hate) && LineOfSightTo( Pawn( OldEnemy ) ) )
			{
				changeEn = Pawn( enemy );
				enemy = oldenemy;
				oldenemy = changeEn;
			}	
			else 
			{
				goalstring = "attract check";
				if ( Enemy == None )
				{
					WhatToDoNext('','');
					return;
				}
				if ( bWillHunt || ((VSize(Enemy.Location - Location) 
							> 600 + (FRand() * RelativeStrength( Pawn( Enemy ) ) - CombatStyle) * 600)) )
				{
					if( !bFixedEnemy || ( bFixedEnemy && ActorReachable( Enemy ) ) )
					{
						log(" Hunting 9999" );
						GotoState('Hunting');
					}
					else
					{
						GotoState( 'WaitingForEnemy' );
					}
				}
				else
				{
					NumHuntPaths = 0; 
					if( bFixedPosition || ( ( bAtCoverPoint || bAtDuckPoint ) && !MyCoverPoint.bExitOnCantSee  ) )
					{
						SightlessFireTime = 4.0;
						bSightlessFire = true;
						GotoState( 'WaitingForEnemy' );
						return;
					}
					else
					{
						// // // // // log( "GOing To Hunting Z" );
						GotoState( 'Hunting' );
					}
				}
				return;
			}
		}	
		
		if (bReadyToAttack)
		{
			Target = Enemy;
			SetTimer(TimeBetweenAttacks, False);
		}
		// JC 1/18 commented out
		//		NotifyMovementStateChange( MS_Waiting, MS_Running );
		if( Physics != PHYS_Swimming )
		{
			if( Weapon != None )
				GotoState( 'RangedAttack' );
			// JC: Was TacticalTest
			else 
				if( bSteelSkin || ( self.IsA( 'NPC' ) && bSnatched ) )
				{
					bAggressiveToPlayer = true;
					if( !bSteelSkin )
						bVisiblySnatched = true;
			log( self$" with "$bSleepAttack$" Going to ApproachingEnemy 4" );
					GotoState( 'ApproachingEnemy' );
				}
				else
					GotoState( 'Charging' );
		}
		else
			GotoState( 'Charging' );
	}

	function EnemyNotVisible()
	{
		if( bFixedPosition )
		{
			SightlessFireTime = 4.0;
			bSightlessFire = true;
			GotoState( 'WaitingForEnemy' );
			return;
		}
		if( !bFixedEnemy )
		{
			// // // // // log( "Going to Hunting X" );
			GotoState( 'Hunting' );
		}
//		else if( !ActorReachable( Enemy ) )
//		{
//						log( "Going to WFE 5" );
//			GotoState( 'WaitingForEnemy' );
//		}
		else
		{
			// // // // // log( "Going to Hunting V" );
			GotoState( 'Hunting' );
		}
		////log("***enemy not visible");
	}

	function Timer( optional int TimerNum )
	{
		bReadyToAttack = True;
	}

	function BeginState()
	{
		if( bSnatched && bAggressiveToPlayer )
		{
			bVisiblySnatched = true;
			if( !bUseSnatchedEffectsDone && !bUseSnatchedEffects )
			{
				bUseSnatchedEffects = true;
			}
		}
		
		if ( TimerRate[ 0 ] <= 0.0 )
			SetTimer(TimeBetweenAttacks  * (1.0 + FRand()),false); 
		if (Physics == PHYS_None)
			SetMovementPhysics(); 
		EnableHeadTracking( true );
		EnableEyeTracking( true );
		if( Enemy != None )
			HeadTrackingActor = Enemy;
	}

Begin:
	//log(class$" choose Attack");
	if( bFixedPosition )
		PlayToCrouch();

	TurnToward( Enemy );
	ChooseAttackMode();
}

auto state StartUp
{
	function BeginState()
	{
		bCanFire = true;
		bCanSpeak = true;
		EnableHeadTracking( true );
		EnableEyeTracking( true );
		SetMovementPhysics(); 
		Orders = 'FreeLance';
		if (Physics == PHYS_Walking)
			SetPhysics(PHYS_Falling);
		bWalkMode = true;
		bShortPains = false;
		GroundSpeed = Default.GroundSpeed * 0.5;
	}// A_DodgeLeftA

Begin:
	SetPhysics( PHYS_Falling );
	WaitForLanding();
	NotifyMovementStateChange( MS_Waiting, MS_Waiting );
	SetMovementState( MS_Waiting, true );

	PlayToWaiting();
	if( bVisiblySnatched )
	{
		//Sleep( 1.0 );
		bSnatchedAtStartup = true;
		GotoState( 'SnatchedEffects' );
	}
	else
		WhatToDoNext( '', '' );
}

simulated function PostBeginPlay()
{
	local int i;
	local bool bMounted;

	bCanHeadTrack = true;
	bCanTorsoTrack = true;
	OldPeripheralVision = Default.PeripheralVision;

	if( bSnatched && bAggressiveToPlayer )
	{
		bVisiblySnatched = true;
		SpawnMiniTentacles();
	}
	if( self.IsA( 'NPC' ) && MultiSkins[ 0 ] != None )
	{
		if( MultiSkins[ 0 ] == texture'm_characters.MaleHead1ARC' )
			NPCFaceNum = 1;
		else if( MultiSkins[ 0 ] == texture'm_characters.MaleHead2ARC' )
			NPCFaceNum = 2;
		else if( MultiSkins[ 0 ] == texture'm_characters.MaleHead3ARC' )
			NPCFaceNum = 3;
		else if( MultiSkins[ 0 ] == texture'm_characters.MaleHead4ARC' )
			NPCFaceNum = 4;
		else if( MultiSkins[ 0 ] == texture'm_characters.MaleHead5ARC' )
			NPCFaceNum = 5;
	}

	bCanSayPinDownPhrase = true;
	// JEP...
	//SetFacialExpression( FacialExpression );
	SetFacialExpressionIndex( FacialExpressionIndex );
	// ...JEP
	if( LegHealthLeft == 0 )
		LegHealthLeft = 1 + Rand( 1 );
	if( LegHealthRight == 0 )
		LegHealthRight = LegHealthLeft;

	if( bShieldUser )
		TimeBetweenStanding = 9;

	bCanEmergencyJump = true;
	SetControlState( CS_Normal );


	SetPartsSequences();
	Super.PostBeginPlay();
}

function SpawnMiniTentacles()
{
	local MeshDecal a;
	local MeshInstance Minst;
	local int bone;
	
	if( MiniTentacle1 == None && Mesh != DukeMesh'EDF1' && Mesh != DukeMesh'EDF2' && Mesh != DukeMesh'EDF2Desert' && Mesh != DukeMesh'EDF3' && Mesh != DukeMesh'EDF3Desert' 
		&& Mesh != DukeMesh'EDF6' && Mesh != DukeMesh'EDF6Desert' )
	{
		MiniTentacle1 = Spawn( class'TentacleSmall', self );
		MiniTentacle1.AttachActorToParent( self, true, true );
		MiniTentacle1.MountAngles.Pitch = -20384;
		MiniTentacle1.MountAngles.Yaw = 16384;
		MiniTentacle1.MountOrigin.Y = -0.3;
		MiniTentacle1.MountOrigin.Z = -1.5;
		MiniTentacle1.MountType = MOUNT_MeshBone;
		MiniTentacle1.MountMeshItem = 'Pupil_L';
		MiniTentacle1.bHidden = false;
		Minst = GetMeshInstance();
		Bone = Minst.BoneFindNamed( 'Pupil_L' );
		//BloodEffect( Minst.MeshToWorldLocation( Minst.BoneGetTranslate( Bone, true, false ) ), 'Shot', vect( 0, 0, 0 ) );
	}
		if( MiniTentacle2 == None )
		{
			MiniTentacle2 = Spawn( class'TentacleSmall', self );
			MiniTentacle2.AttachActorToParent( self, true, true );
			MiniTentacle2.MountAngles.Pitch = -20384;
			MiniTentacle2.MountAngles.Yaw = 16384;
			MiniTentacle2.MountOrigin.X = 2.000000;
			MiniTentacle2.MountOrigin.Y = 2.000000;
			MiniTentacle2.MountOrigin.Z = -2.000000;
			MiniTentacle2.MountAngles.Pitch = -12384;
			MinITentacle2.MountAngles.Yaw=19384;
			MiniTentacle2.MountType = MOUNT_MeshBone;
			MiniTentacle2.MountMeshItem = 'Neck';
			MiniTentacle2.bHidden = false;
		}

		if( MiniTentacle3 == None )
		{
			MiniTentacle3 = Spawn( class'TentacleSmall', self );
			MiniTentacle3.AttachActorToParent( self, true, true );
			MiniTentacle3.MountAngles.Pitch = -20384;
			MiniTentacle3.MountAngles.Yaw = 16384;
			MiniTentacle3.MountOrigin.X = 2.000000;
			MiniTentacle3.MountOrigin.Y = -2.000000;
			MiniTentacle3.MountOrigin.Z = -2.000000;
			MiniTentacle3.MountAngles.Pitch = -20384;
			MinITentacle3.MountAngles.Yaw=19384;
			MiniTentacle3.MountType = MOUNT_MeshBone;
			MiniTentacle3.MountMeshItem = 'Neck';
			MiniTentacle3.bHidden = false;
		}
		if( MiniTentacle4 == None && Mesh != DukeMesh'EDF1' && Mesh != DukeMesh'EDF1Desert' && Mesh != DukeMesh'EDF2' && Mesh != DukeMesh'EDF2Desert' && Mesh != DukeMesh'EDF3' && Mesh != DukeMesh'EDF3Desert' 
			&& Mesh != DukeMesh'EDF6' && Mesh != DukeMesh'EDF6Desert' )
		{
		MiniTentacle4 = Spawn( class'TentacleSmall', self );
		MiniTentacle4.AttachActorToParent( self, true, true );
		MiniTentacle4.MountAngles.Pitch = -20384;
		MiniTentacle4.MountAngles.Yaw = 16384;
		MiniTentacle4.MountOrigin.Y = 0.300000;
		MiniTentacle4.MountOrigin.Z = -1.500000;
		MiniTentacle4.MountAngles.Pitch = -12384;
		MinITentacle4.MountAngles.Yaw=16384;
		MiniTentacle4.MountType = MOUNT_MeshBone;
		MiniTentacle4.MountMeshItem = 'Pupil_R';
		MiniTentacle4.bHidden = false;
		}
		if( MiniTentacle1 != None )
			MiniTentacle1.GotoState( 'Swinging' );
		if( MiniTentacle4 != None )
			MiniTentacle4.GotoState( 'Swinging' );
		MiniTentacle3.GotoState( 'Swinging' );
		MiniTentacle2.GotoState( 'Swinging' );
}

/*-----------------------------------------------------------------------------
	NPC Manipulation (trigger, using, etc.)
-----------------------------------------------------------------------------*/

function Used( actor Other, Pawn EventInstigator )
{
	local actor A;

	if( bCanBeUsed )
	{
		if( !IsInState( 'ActivityControl' ) )
		{
			if( UseTriggerEvent != '' && Enemy == None )
			{
				foreach allactors( class'Actor', A, UseTriggerEvent )
				{
					A.Trigger( self, self );
				}
				if( !bReEnableUseTrigger )
				{
					UseTriggerEvent = '';
				}
			}
			else
			if( bCanSpeak && Enemy == None )
			{
				SpeechTarget = Other;
				if(	!IsInState( 'ConverSation' ) )
					NextState = GetStateName();
				GotoState( 'Conversation' );
			}
		}
	}
}

/*-----------------------------------------------------------------------------
	Following State. 
-----------------------------------------------------------------------------*/
state Following
{
	function MayFall()
	{
		//// // // // // log( "Following MayFall" );
	}


	function Bump( actor Other )
	{
		local vector VelDir, OtherDir;
		local float speed, dist;
		local Pawn P,M;
		local bool bDestinationObstructed, bAmLeader;
		local int num;

		P = Pawn(Other);
		if( P != None )
		{
			Disable( 'Bump' );
			GotoState( 'Following', 'GetOutOfWay' );
		}

		if ( TimerRate[ 0 ] <= 0 )
		{
			setTimer( 0.2, false );
		}
	}

	function HitWall( vector HitNormal, actor HitWall )
	{
		Focus = Destination;
		if (PickWallAdjust())
		{
			if ( Physics == PHYS_Falling )
				SetFall();
			else
				GotoState('Following', 'AdjustFromWall');
		}
		else
			MoveTimer = -1.0;
	}

	function BeginState()
	{
		//// // // // // log( "--- Following state entered by "$self );
		//// // // // // log( "--- Follow actor is:" $FollowActor );
	}

	function bool CloseEnough()
	{
		if( VSize( Location - FollowActor.Location ) <= FollowOffset )
			return true;

		return false;
	}

/*	function Tick( float DeltaTime )
	{
		Super.Tick( DeltaTime );
	}
*/
	
	function Timer( optional int TimerNum )
	{
	//	if( !Pawn( FollowActor ).CanSee( self ) )
		if( !PlayerCanSeeMe() )
		{
			DesiredRotation = Pawn( FollowActor ).ViewRotation;
		}
		else
			DesiredRotation.Pitch = 0;
		if( !CloseEnough() )
			GotoState( 'Following', 'Begin' );
	}


GetOutOfWay:

	if( FollowActor.IsA( 'Pawn' ) )
	{
		if( FRand() < 0.5 )
			Destination = FollowActor.Location + ( 96 * vect( 0, -1, 0 ) ) * vector( Pawn( FollowActor ).ViewRotation );
		else
			Destination = FollowActor.Location + ( 96 * vect( 0, 1, 0 ) ) * vector( Pawn( FollowActor ).ViewRotation );

		PlayToWalking();
		MoveTo( Destination );
		PlayToWaiting();
	} 
	Enable( 'Bump' );

AdjustFromWall:
	//Enable('AnimEnd');
	TurnTo( Destination );
	StrafeTo(Destination, Focus); 
	Destination = Focus; 
	Goto('Begin');

Waiting:
	StopMoving();
	PlayToWaiting();
	Sleep( 1.0 );
	if( FollowTag == '' )
	{
		if( NextState == '' || NextState == 'Following' )
		{
			NextState = 'Idling';
		}
		if( bWanderAfterFollow )
		{
			NextState = 'Wandering';
		}
		GotoState( NextState );
	}
	Goto( 'Begin' );

Begin:
	if( FollowTag == '' )
	{
		if( NextState == '' || NextState == 'Following' )
		{
			NextState = 'Idling';
		}
		if( bWanderAfterFollow )
		{
			NextState = 'Wandering';
		}

		GotoState( NextState );
	}

Moving:
	if( VSize( FollowActor.Location - Location ) > 128 && !CanDirectlyReach( FollowActor ) )
	{
		if( !FindBestPathToward( FollowActor, true ) )
		{
			PlayToWaiting();
			Goto( 'Waiting' );
		}
		else
		{
			PlayToRunning();
			MoveTo( Destination, GetRunSpeed());
			if( VSize( FollowActor.Location - Location ) <= 128 )
			{
				Goto( 'FollowReached' );
			}
			else
			{
				Goto( 'Moving' );
			}
		}
	}
	else if( CanDirectlyReach( FollowActor ) && VSize( FollowActor.Location - Location ) > 128 )
	{
		PlayToRunning();
		MoveTo( Location - 64 * Normal( Location - FollowActor.Location), GetRunSpeed() );
	}
	else if( VSize( FollowActor.Location - Location ) <= 128 ) 
	{
		Goto( 'FollowReached' );
	}
	Goto( 'Moving' );
	/*
	// // // // // log( "== Following 2" );
	if( LineOfSightTo( FollowActor ) && ( VSize( FollowActor.Location - Location ) < 128 ) || !FindBestPathToward( FollowActor, true ) )
	{
	// // // // // log( "== Following 3" );
		if( bWalkFollow && VSize( FollowActor.Location - Location ) < 360 )
		{
	// // // // // log( "== Following 4" );
			NotifyMovementStateChange( MS_Walking, MS_Waiting );
			PlayToWalking();
			MoveToward( FollowActor, WalkingSpeed );
		}
		else
		{
	// // // // // log( "== Following 5" );
			NotifyMovementStateChange( MS_Running, MS_Waiting );
			PlayToRunning();
			MoveToward( FollowActor, GetRunSpeed() );
		}
	// // // // // log( "== Following 6" );		
		if( CloseEnough() )
		{
	// // // // // log( "== Following 7" );
			Goto( 'FollowReached' );
		}
		else
		{
				// // // // // log( "== Following 8" );
			Goto( 'Begin' );
		}
	}
	else
	if( !FindBestPathToward( FollowActor, false ) )
	{
	// // // // // log( "== Following 9" );
		// // log( self$" cannot find a path to "$FollowActor );
		Goto( 'Waiting' );
		//GotoState( NextState );
	}
	else
	{
	// // // // // log( "== Following 10" );
		if( bWalkFollow && VSize( FollowActor.Location - Location ) < 128 )
		{
				// // // // // log( "== Following 11" );
			NotifyMovementStateChange( MS_Walking, MS_Waiting );
			PlayToWalking();
			MoveToward( FollowActor, WalkingSpeed );
		}
		else
		{
	// // // // // log( "== Following 12" );
	// // // // // log( "Destination: "$MoveTarget );
			NotifyMovementStateChange( MS_Running, MS_Waiting );
			PlayToRunning();
			MoveTo( Destination, GetRunSpeed() );
		}
	// // // // // log( "== Following 13" );
		if( CloseEnough() )
		{
	// // // // // log( "== Following 14" );
			Goto( 'FollowReached' );
		}
		else
		{
				// // // // // log( "== Following 15" );
			Goto( 'Begin' );
		}
	}*/

FollowReached:
	StopMoving();
	PlayToWaiting();
	if( bStopWhenReached )
	{
		if( bWanderAfterFollow )
		{
			NextState = 'Wandering';
		}
		GotoState( NextState );
	}
	else
	{
		SetTimer( 0.5, true );
	}
}


/*-----------------------------------------------------------------------------
	NPC Conversation state.
-----------------------------------------------------------------------------*/

function PrepareForStomp( Pawn StompInstigator )
{
	HeadTrackingActor = StompInstigator;
	TurnTo( StompInstigator.Location );
}

state Conversation
{
	ignores Bump;

	function BeginState()
	{
		HeadTrackingActor = SpeechTarget;
		if( !GetCriticalSpeech() )
		{
			//if( !GetIdleSpeech() )
			//{
			// // // // // log( "Get critical speech failed, getting idle speech." );
				if( !GetRandomIdleSpeech() )
				{
					// // // // // log( "Get Idle speech failed. Aborting" );
					GotoState( NextState );
				}
			//}
			
		}
	}

	function EndState()
	{
		if( !CurrentSpeechInfo.RetainNoTorsoTracking )
			bCanTorsoTrack = false;

		if( !CurrentSpeechInfo.RetainHeadTracking )
			HeadTrackingActor = None;

		TempHeadFactor = 0;
		TempChestFactor = 0;
		TempAbdomenFactor = 0;
		bCanSpeak = true;
		//HeadTrackingActor = None;
		//bCanTorsoTrack = true;
		bForceNoLookAround = false;
	}

	function Timer( optional int TimerNum )
	{
/*		if( NextState == 'Patrolling' )
		{
			GotoState( 'Patrolling', 'ResumePatrol' );
		}
		else
			GotoState( NextState );
*/
		if( InitialIdlingAnim != '' )
			PlayAllAnim( InitialIdlingAnim,, 0.4, true );
		else
		{
			// // // // // log( "IdleStandInactive 4" );
			PlayAllAnim( 'A_IdleStandInactive',, 0.4, true );
		}
		// JEP...
		/*
		if( CurrentSpeechInfo.ExitFacialExpression != FACE_NoChange )
		{
			SetFacialExpression( CurrentSpeechInfo.ExitFacialExpression );
			//PlayFaceAnim( 'None' );
		}
		*/
		SetFacialExpressionIndex(CurrentSpeechInfo.ExitFacialExpressionIndex);
		// ...JEP

//		SetFacialExpression( FACE_Normal );
		bCanExitConversation = true;
		bCanSpeak = true;
//		Super.SetTimer( 3.0, false );
	}

	function bool GetCriticalSpeech()
	{
		local int i;

		for( i = 0; i <= 31; i++ )
		{
			if( CriticalSpeech[ i ].Sound != None )
			{
				if( !CriticalSpeech[ i ].bAlreadyUsed )
				{
					CurrentSpeechInfo = CriticalSpeech[ i ];
					CriticalSpeech[ i ].bAlreadyUsed = true;
					return true;
				}
			}
			else
				break;
		}
		return false;
	}

	function HandleSpeechAnim( name TopAnim, name BottomAnim, name AllAnim )
	{
		// // // // // log( "SpeechAnim played at "$Level.TimeSeconds );
		// // // // // log( "SpeechAnim TopAnim: "$TopAnim );
		// // // // // log( "SpeechAnim BotAnim: "$BottomAnim );
		// // // // // log( "SpeechAnim AllAnim: "$AllAnim );

		if( TopAnim != 'None' )
		{
		//	PlayTopAnim( 'None' );
			PlayTopAnim( TopAnim,, 0.1, false );
		}
		if( BottomAnim != 'None' )
		{
			PlayBottomAnim( BottomAnim,, 0.1, false );
		}
		if( AllAnim != 'None' )
		{
			PlayTopAnim( 'None' );
			PlayBottomAnim( 'None' );
			//PlayAllAnim( AllAnim,, 0.1, CurrentSpeechInfo.bLoopAllAnim );
			PlayAllAnim( AllAnim,, 0.5, CurrentSpeechInfo.bLoopAllAnim );		// JEP Changed to .5, removes the pop
		}
	}

	function bool GetIdleSpeech()
	{
		local int i, j;
		
		for( i = 0; i <= 31; i++ )
		{
			if( IdleSpeech[ i ].Sound != None )
			{
				if( !IdleSpeech[ i ].bAlreadyUsed )
				{
					CurrentSpeechInfo = IdleSpeech[ i ];
					IdleSpeech[ i ].bAlreadyUsed = true;
					if( i < 31 && IdleSpeech[ i + 1 ].Sound == None )
					{
						for( j = 0; j <= 31; j++ )
						{
 							IdleSpeech[ j ].bAlreadyUsed = false;
							if( IdleSpeech[ j ].Sound == None )
							{
								break;
							}
						}
					}
					return true;
				}
			}
			else
				break;
		}
		return false;
	}

	function bool GetRandomIdleSpeech()
	{
		local int i, j;

		for( i = 0; i <= 31; i++ )
		{
			j = Rand( 31 );
			if( !IdleSpeech[ j ].bRandomUsed )
			{
				if( IdleSpeech[ j ].Sound != None )
				{
					CurrentSpeechInfo = IdleSpeech[ j ];
					IdleSpeech[ j ].bRandomUsed = true;
					return true;
				}
			}
		}
		ClearIdlePhrases();
		//return false;
	}

	function ClearIdlePhrases()
	{
		local int i;

		for( i = 0; i <= 31; i++ )
		{
			if( IdleSpeech[ i ].Sound != None )
			{
				IdleSpeech[ i ].bRandomUsed = false;
			}
		}
	}

	function Used( actor Other, Pawn EventInstigator )
	{
		if( bCanSpeak && Enemy == None )
		{
			SpeechTarget = Other;
			HeadTrackingActor = SpeechTarget;
			if( !GetCriticalSpeech() )
			{
			//if( !GetIdleSpeech() )
			//{
				if( !GetRandomIdleSpeech() )
				{
					GotoState( NextState );
				}
			//}
				
			}
			GotoState( 'Conversation', 'Begin' );
		}
	}
	
	function ConversationTracking()
	{
		if( CurrentSpeechInfo.TurnFactorHead > 0.0 )
			TempHeadFactor = CurrentSpeechInfo.TurnFactorHead;

		if( CurrentSpeechInfo.TurnFactorChest > 0.0 )
			TempChestFactor = CurrentSpeechInfo.TurnFactorChest;

		if( CurrentSpeechInfo.TurnFactorAbdomen > 0.0 )
			TempAbdomenFactor = CurrentSpeechInfo.TurnFactorAbdomen;

		if( CurrentSpeechInfo.bCannotLookAround )
		{
			// // // // // log( "Setting bForceNoLookAround to true" );
			bForceNoLookAround = true;
		}

		if( CurrentSpeechInfo.LookAroundInterval > 0.0 )
			LookInterval = CurrentSpeechInfo.LookAroundInterval;
	}

	//function FaceDispatcher GetFaceDispatcher()
	//{
	//	local FaceDispatcher FD;

		//foreach allactors( class'FaceDispatcher', FD, CurrentSpeechInfo.FaceDispatcherTag )
		//{
		//	return FD;
		//}
	//}

Begin:
	bCanExitConversation = false;
	bNoLookAround = true;
	LastLookTime = 0.0;
	if( CurrentSpeechInfo.bNoTorsoTracking )
		bCanTorsoTrack = false;
	if( CurrentSpeechInfo.bNoHeadTracking )
	{
		HeadTrackingActor = None;
	}
	else
	{
		EnableHeadTracking( true );
		HeadTrackingActor = SpeechTarget;
	}
	ConversationTracking();
	bCanSpeak = false;
	StopMoving();
	//NotifyMovementStateChange( MS_Waiting, MS_Walking );
	PlayToWaiting();
	if( CurrentSpeechInfo.Sound == None )
		GotoState( NextState );
	
	//MouthExpression = CurrentSpeechInfo.Mouth;
	//BrowExpression = CurrentSpeechInfo.Brow;

	if( CurrentSpeechInfo.PauseBeforeSpeech > 0.0 )
		Sleep( CurrentSpeechInfo.PauseBeforeSpeech );
	Sleep( 0.15 );
	if( !CurrentSpeechInfo.bWillNotTurn && NeedToTurn( SpeechTarget.Location ) )
	{
		StopMoving();
		bTurning = true;
		Sleep( 0.15 );
		if ((rotator(SpeechTarget.Location - Location) - Rotation).Yaw < 0)
			PlayTurnLeft();
		else
			PlayTurnRight();
		TurnTo(SpeechTarget.Location);
		bTurning = false;
		PlayToWaiting();
	}
	if( SoundVolume == 0 )
	{
		SoundVolume = 155;
	}
	
	// JEP...
	/*
	if( CurrentSpeechInfo.FacialExpression != FacialExpression )
	{
		SetFacialExpression( CurrentSpeechInfo.FacialExpression, CurrentSpeechInfo.bUseFaceAsDefault, !CurrentSpeechInfo.bLoopFaceAnim );
	}
	*/
	if( CurrentSpeechInfo.FacialExpressionIndex != FacialExpressionIndex )
		SetFacialExpressionIndex(CurrentSpeechInfo.FacialExpressionIndex);
	// JEP...

	//if( CurrentSpeechInfo.FaceDispatcherTag != '' )
	//	GetFaceDispatcher().GotoState( 'Dispatch' );

	PlaySound( CurrentSpeechInfo.Sound, SLOT_Talk, SoundDampening * 0.5, false,,, true );

	if( CurrentSpeechInfo.PauseBeforeAnim > 0.0 )
	{
		Sleep( CurrentSpeechInfo.PauseBeforeAnim );
	}

	HandleSpeechAnim( CurrentSpeechInfo.TopAnim, CurrentSpeechInfo.BottomAnim, CurrentSpeechInfo.AllAnim );
	if( CurrentSpeechInfo.Sound != None )
	{
		if( !CurrentSpeechInfo.bNoExitDelay )
			SetTimer( GetSoundDuration( CurrentSpeechInfo.Sound ) + 1.0, false );
		else
			SetTimer( GetSoundDuration( CurrentSpeechInfo.Sound ), false );
	}
	if( CurrentSpeechInfo.bLoopAllAnim )
	{
		// // // // // log( "Sleeping for sound duration." );
		Sleep( GetSoundDuration( CurrentSpeechInfo.Sound ) );
	}
	else if( !IsAnimating( 0 ) )
		PlayToWaiting();

	if( IsAnimating( 0 ) && !CurrentSpeechInfo.bLoopAllAnim )
	{
		FinishAnim( 0 );
		PlayToWaiting();
	}

ExitConversation:
	//FinishAnim( 5 );
	if( bCanExitConversation )
	{
		if( NextState == 'Patrolling' )
		{
			GotoState( 'Patrolling', 'ResumePatrol' );
		}
		else
		{
			GotoState( NextState );
		}
	}
}

/*-----------------------------------------------------------------------------
	Animation functions.
-----------------------------------------------------------------------------*/

function bool IsLimping()
{
	if( bSteelSkin )
		return false;

	if( bLimpingLeft || bLimpingRight )
		return true;
	else
		return false;
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
			WalkingSpeed = Default.WalkingSpeed * 0.7;
			break;
		case MS_Running:
			MovementStateChange_Running(OldState);
			WalkingSpeed = Default.WalkingSpeed;
			break;
	}
}

function PlaySuicide()
{
	PlayAllAnim( 'A_Death_Fallstraightdown',, 0.2, false );
}

function PlayDying( class<DamageType> DamageType, vector HitLoc)
{
	local EPawnBodyPart BodyPart;

	if( bDamagedByShotgun )
		return;

	PlayDyingSound();
	BodyPart = GetPartForBone(DamageBone);
	if( !bDamagedByShotgun )
	PlayDeath( Bodypart, DamageType );
}

state Repelling
{
	ignores SeeFocalPoint, SeePlayer, FocalPOintNOtVisible;

	function SeeMonster( actor Seen)
	{
	}

	event Landed( vector HitNormal )
	{
//		PlayAllAnim( 'A_JumpLand',, 0.1, false );
//		GotoState( 'Idling', 'Landed' );
//		PlayToWaiting( 0.12 );
	//	GotoState( 'Idling' );
	}

	function BeginState()
	{
		// // // // log( "--- Repelling state entered by "$self );

		Disable( 'SeeMonster' );
		Disable( 'EnemyNotVisible' );
		Disable( 'SeePlayer' );
		bCanFly = true;
		SetPhysics( PHYS_Flying );
		if( MyClimbControl.MyRope == None )
		{
			MyRope = Spawn( class'dnDecoration', self );
			MyRope.Mesh = mesh'c_generic.cable_repel1';
			if( MyClimbControl != None )
				MyRope.SetOwner( MyClimbControl );
			MyClimbControl.MyRope = MyRope;
			MyRope.AttachActorToParent( MyClimbControl, true, true );
			MyRope.MountType = MOUNT_Actor;
			MyRope.Texture = Texture'm_fx.roperc';
			MyRope.SetPhysics( PHYS_MovingBrush );
			MyClimbControl.SetLocation( MyClimbControl.Location + vect( 13, 0, 0 ) );
		}
	}

	function TakeDamage( int Damage, Pawn InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType)
	{
		Super.TakeDamage( Damage, InstigatedBy, HitLocation, Momentum, DamageType );
		if( Physics != PHYS_Falling && GetSequence( 0 ) == MyClimbControl.AllAnimClimb )
		{
			SetPhysics( PHYS_Falling );
			GotoState( 'Repelling', 'Fall' );
		}
	}

/*	function SeePLayer( actor Seen )
	{
		if( FRand() < 0.12 )
		{
			// // broadcastmessage( "I SEE PLAYER!" );
			HeadTrackingActor = Seen;
			Enemy = Seen;
			Disable( 'SeePlayer' );
			MoveTimer = -1.0;
			GotoState( 'Repelling', 'StopFire' );
		}
	}*/

	function Bump( actor Other )
	{
		if( Other.IsA( 'Pawn' ) )
		{
			GotoState( 'Repelling', 'ClimbUp' );
			Disable( 'Bump' );
		}
	}

	function EndState()
	{
		bRotateToDesired = Default.bRotateToDesired;
		RotationRate = Default.RotationRate;
	}

	function TriggerDeathEvent()
	{
		local actor A;

		foreach AllActors( class 'Actor', A, Event )
			A.Trigger( Self, Self );
	}

Fall: 
	if( VSize( Location - MyClimbControl.FloorLocation ) > 200 )
		PlayAllAnim( 'A_FallingRopeA',, 0.1, true );
	else
		PlayAllAnim( 'A_JumpAir_B',, 0.12, true );
	WaitForLanding();
	if( MyClimbControl.bRetractRope )
		MyClimbControl.RetractRope();
	else
		MyClimbControl.AnchorRope( Location );

	// This isn't playing right get up anim. Fixme.
	if( GetSequence( 0 ) == 'A_FallingRopeA' ) 
		PlayAllAnim( 'A_FallGetUp',, 0.1, false );
	else
		PlayAllAnim( 'A_JumpLand',, 0.1, false );

	FinishAnim( 0 );
	GotoState( 'Idling' );


StopFire:
	StopMoving();
	SetPhysics( PHYS_None );
	PlayAllANim( 'A_CLimbRopeIdle',, 0.12, true );
	PlayTopAnim( 'T_Pistol2HandIdle',, 0.12, true );
	FinishAnim( 1 );
	Sleep( 0.12 );
	Goto( 'StopFire' );

Landed:
	FinishAnim( 0 );
	PlayToWaiting( 0.12 );
	Sleep( 1.0 );
	Goto( 'Begin' );

ClimbUp:
	bCanStrafe = true;
	bRotateToDesired = false;
	RotationRate.Yaw = 0;
	RotationRate.Pitch = 0;
	PlayAllAnim( 'A_ClimbRopeUp',, 0.12, true );
	Sleep( 0.1 );
	SetPhysics( PHYS_Flying );
	MoveTo( MyClimbControl.Location, 0.27 );
	if( MyClimbControl.bRetractRope )
		MyClimbControl.RetractRope();
	DesiredRotation = Rotation;
	Weapon.Destroy();
	if( Event != '' )
		TriggerDeathEvent();
	Destroy();

Begin:
	bCanStrafe = true;
	bRotateToDesired = false;
	RotationRate.Yaw = 0;
	RotationRate.Pitch = 0;
	PlayAllAnim( MyClimbControl.AllAnimClimb,, 0.12, true );
	Sleep( 0.1 );
	SetPhysics( PHYS_Flying );
	MoveTo( MyClimbControl.FloorLocation + ( vect( 0, 0, 1 ) * MyClimbControl.JumpHeightFromFloor ), MyClimbControl.ClimbSpeed );
	StopMoving();
	SetPhysics( PHYS_Falling );
	PlayAllAnim( 'A_JumpLand',, 0.1, false );
	WaitForLanding();
	Disable( 'Bump' );
	if( MyClimbControl.bRetractRope )
		MyClimbControl.RetractRope();
	else
		MyClimbControl.AnchorRope( Location );

	DesiredRotation = Rotation;
	if( MyClimbControl.AutoHateTag != '' )
	{
		Enemy = FindActorTagged( class'Actor', MyClimbControl.AutoHateTag );
		GotoState( 'Hunting' );
	}
	else
		GotoState( 'Idling' );
}

state SleepAttack
{
/*A_FakeDeadA
A_FakeDeadA_GetUp
A_FakeDeadB
A_FakeDeadB_GetUp*/

	function bool EvalHeadLook();

	function BeginState()
	{
		log( self$" entered SleepAttack state" );
		if( FRand() < 0.5 )
			PlayFaceAnim( 'F_Pain1' );
		else
			PlayFaceAniM( 'F_Pain2' );
		bEyesShut = true;
		ChangeCollisionHeightToCrouching();
		Enable( 'SeePlayer' );
	}

	function SeePlayer( actor Seen )
	{
		if( VSize( Location - Seen.Location ) < WakeRadius )
		{
			Enemy = Seen;
			GotoState( 'SleepAttack', 'StandUp' );
			Disable( 'SeePlayer' );
		}
	}

	function EndState()
	{
		ChangeCollisionHeightToStanding();
		PlayFaceAnim( 'None' );
	}

	function PlayGetUp()
	{
		local name CurrentSeq;

		CurrentSeq = GetSequence( 0 );

		if( CurrentSeq == 'A_FakeDeadA' )
			PlayAllAnim( 'A_FakeDeadA_GetUp',, 0.12, false );
		else if( CurrentSeq == 'A_FakeDeadB' )
			PlayAllAnim( 'A_FakeDeadB_GetUp',, 0.12, false );
	}

StandUp:
	bEyesShut = false;
	PlayGetUp();
	SproutTentacles();
	//PlayAllAnim( 'A_FakeDeadA_GetUp',, 0.12, false );
	ChangeCollisionHeightToStanding();
	FinishAnim( 0 );
	PlayToWaiting( 0.13 );
	bSleepAttack = false;
	GotoState( 'Attacking' );

Begin:
	if( FRand() < 0.5 )
		PlayAllAnim( 'A_FakeDeadA',, 0.1, true );
	else PlayAllAnim( 'A_FakeDeadB',, 0.1, true );
}

function ChangeCollisionHeightToLyingDown()
{
	if( Shrunken() )
		return;

	OriginalCollisionHeight = CollisionHeight;
	DestinationCollisionHeight = 4;
	CollisionHeightStartTime = Level.TimeSeconds;
}

function ChangeCollisionHeightToStanding()
{
	if ( Shrunken() )
		return;

	DestinationCollisionHeight  = default.CollisionHeight;
	OriginalCollisionHeight     = CollisionHeight;
	CollisionHeightStartTime    = Level.TimeSeconds;
}

// Move this to Pawn- copied from PlayerPawn.
function ChangeCollisionHeightToCrouching()
{
	if ( Shrunken() )
		return;

	OriginalCollisionHeight     = CollisionHeight;				
	DestinationCollisionHeight  = DuckCollisionHeight;		
	CollisionHeightStartTime    = Level.TimeSeconds;
}

// Move this to Pawn- copied from PlayerPawn.
function InterpolateCollisionHeight()
{
    local vector LocationAdjust;
    local float StartHeight, EndHeight, HeightChange;

	if (CollisionHeightStartTime > 0)
	{
		CollisionHeightTime = 0.85/3*2;

		if ( Level.TimeSeconds - CollisionHeightStartTime >= CollisionHeightTime )
		{
			// We have interpolated the full time.
			SetCollisionSize( default.CollisionRadius, DestinationCollisionHeight );
			CollisionHeightStartTime = 0;
		} 
        else
        {
			// We need to interpolate.
			StartHeight = CollisionHeight;
			SetCollisionSize( default.CollisionRadius, Lerp( (Level.TimeSeconds - CollisionHeightStartTime) / CollisionHeightTime,
				OriginalCollisionHeight, DestinationCollisionHeight ) );
			EndHeight = CollisionHeight;
			HeightChange = EndHeight - StartHeight;
			LocationAdjust = Location;
			LocationAdjust.Z += HeightChange;
			SetLocation(LocationAdjust);
		}
	}
}

defaultproperties
{
     TimeBetweenCrouching=10
     TimeBetweenStanding=5
	 CarcassType=Class'HumanPawnCarcass'
     HeadTracking=(RotationRate=(Pitch=40000,Yaw=40000),RotationConstraints=(Pitch=8000,Yaw=16000))
 	 EyeTracking=(RotationRate=(Pitch=0,Yaw=35000,Roll=0),RotationConstraints=(Pitch=50000,Yaw=100000,Roll=0))
     TimeBetweenAttacks=0.600000
     Aggressiveness=0.300000
     RefireRate=0.900000
     bLeadTarget=True
     BaseAggressiveness=0.300000
     WalkingSpeed=0.170000
     TentacleOffsets=(MouthOffset=(X=0.500000,Z=6.000000),RightShoulderOffset=(X=6.000000,Y=4.000000),LeftShoulderOffset=(X=6.000000,Y=-4.000000),MouthRotation=(Pitch=-16384),RightShoulderRotation=(Pitch=-18300,Yaw=-14300,Roll=18300),LeftShoulderRotation=(Pitch=-18300,Yaw=-22300,Roll=18300))
     MeleeRange=40.000000
     CombatStyle=-0.500000
     Intelligence=BRAINS_HUMAN
     HearingThreshold=0.300000
     SightRadius=5000.000000
     bIsPlayer=True
     bAutoActivate=True
     bHumanSkeleton=True
     GroundSpeed=475.000000
     AirSpeed=400.000000
     AccelRate=2048.000000
     AirControl=0.350000
     bIsMultiSkinned=True
     UnderWaterTime=20.000000
     VoiceType="BotPack.VoiceMaleTwo"
     BaseEyeHeight=23.000000
     EyeHeight=23.000000
     bStasis=False
     LodMode=LOD_StopMinimum
     DrawType=DT_Mesh
     bHeated=True
     HeatIntensity=255.000000
     HeatRadius=15.000000
     Buoyancy=100.000000
     RotationRate=(Pitch=3072,Yaw=130000,Roll=2048)
     NetPriority=3.000000
     bUseTriggered=True
     PunchDamage=5
     KickDamage=8
     BloodHitDecalName="DNGAme.DNBloodHit"
	 BloodPuffName="DNParticles.DNBloodFX"
	 WaterSpeed=200
	 ExitSplash=sound'a_generic.water.splashout12'
	 BigSplash=sound'a_generic.water.splashin01'
	 LittleSplash(0)=sound'a_generic.water.splashout05'
	 LittleSplash(1)=sound'a_generic.water.splashout22'
	 //RotationRate=(Pitch=4096,Yaw=150,Roll=3072)
	 bCanBeUsed=true
     PainInterval=1.0
     BlinkEyelidPosition=(X=1.200000,Y=-0.100000,Z=0.000000)
	 SufferFrequency=0.25
	 RunSpeed=1.25
     JumpZ=-1
	 //JumpZ=250
	 bCanJump=false
	 // FIXME: Was 18, is 23 too large? Raised to help Grunt in rooftop level patrolling.
	 MaxStepHeight=23
     AmbientGlow=17
     LightBrightness=70
     LightHue=40
     LightSaturation=128
     LightRadius=6
	 bStopWhenReached=false
	 Orders=ORDERS_Following
	 FollowTag=DukePlayer
	 FollowOffset=128
	 LegHealthRight=0
	 LegHealthLeft=0
	 bSniper=false
	 PreAcquisitionDelay=0.5
	 AggroSnatchDistance=128
	 AIMeleeRange=72
     MaxShots=7
     MinShots=3
     ImmolationClass="dnGame.dnPawnImmolation"
	 ShrinkClass="dnGame.dnPawnShrink"
     DuckCollisionHeight=35.500000
     HeadCreeperOdds=0.250000
}