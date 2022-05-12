 //=============================================================================
// Bot.
//=============================================================================
class Bot expands Pawn
	abstract;

var(Pawn) class<carcass> CarcassType;

// Advanced AI attributes.
var(Orders) name	Orders;			//orders a bot is carrying out 
var(Orders) name	OrderTag;		// tag of object referred to by orders
var		actor		OrderObject;		// object referred to by orders (if applicable)
var(Combat) float	TimeBetweenAttacks;  // seconds - modified by difficulty
var 	name		NextAnim;		// used in states with multiple, sequenced animations	
var(Combat) float	Aggressiveness; //0.0 to 1.0 (typically)
var		float       BaseAggressiveness; 
var   	Pawn		OldEnemy;
var		int			numHuntPaths;
var		vector		HidingSpot;
var		float		WalkingSpeed;
var(Combat) float	RefireRate;
var		float		StrafingAbility;

//AI flags
var	 	bool   		bReadyToAttack;		// can attack again 
var		bool		bCanFire;			//used by TacticalMove and Charging states
var		bool		bCanDuck;
var		bool		bStrafeDir;
var(Combat) bool	bLeadTarget;		// lead target with projectile attack
var		bool		bSpecialGoal;
var		bool		bChangeDir;			// tactical move boolean
var		bool		bFiringPaused;
var		bool		bComboPaused;
var		bool		bSpecialPausing;
var		bool		bGreenBlood;
var		bool		bFrustrated;
var		bool		bNoShootDecor;
var		bool		bGathering;
var		bool		bCamping;
var config	bool	bVerbose; //for debugging
var		bool		bViewTarget; //is being used as a viewtarget
var		bool		bWantsToCamp;
var		bool		bWallAdjust;
var		bool		bCanTranslocate;
var		bool		bInitLifeMessage;
var		bool		bNoClearSpecial;
var		bool		bStayFreelance;
var		bool		bNovice;
var		bool		bThreePlus;		// high skill novice
var		bool		bKamikaze;
var		bool		bClearShot;
var		bool		bQuickFire;		// fire quickly as moving in and out of cover
var		bool		bDevious;
var		bool		bDumbDown;		// dumb down team AI 
var		bool		bJumpy;
var		bool		bHasImpactHammer;
var		bool		bImpactJumping;
var		bool		bSniping;
var		bool		bFireFalling;
var		bool		bLeading;
var		bool		bSpecialAmbush;
var		bool		bCampOnlyOnce;
var		bool		bPowerPlay;
var		bool		bBigJump;
var     bool		bTacticalDir;		// used during movement between pathnodes
var		bool		bNoTact;
var		bool		bMustHunt;
var		bool		bIsCrouching;

var Weapon EnemyDropped;
var float LastInvFind;
var class<Weapon> FavoriteWeapon;
var float Accuracy;
var vector WanderDir;

var     name		LastPainAnim;
var		float		LastPainTime;
var		float		LastAcquireTime;

var(Sounds) sound 	drown;
var(Sounds) sound	breathagain;
var(Sounds) sound	Footstep1;
var(Sounds) sound	Footstep2;
var(Sounds) sound	Footstep3;
var(Sounds) sound	HitSound3;
var(Sounds) sound	HitSound4;
var(Sounds)	Sound	Deaths[6];
var(Sounds) sound	GaspSound;
var(Sounds) sound	UWHit1;
var(Sounds) sound	UWHit2;
var(Sounds) sound   LandGrunt;
var(Sounds) sound	JumpSound;

var name OldMessageType;
var int OldMessageID;

var float PointDied;
var float CampTime;
var float CampingRate;
var float LastCampCheck;
var float LastAttractCheck;
var Ambushpoint AmbushSpot;
var AlternatePath AlternatePath; //used by game AI for team games with bases
var Actor RoamTarget, ImpactTarget;
var float Rating;
var int	FaceSkin;
var int	FixedSkin;
var int	TeamSkin1;
var int	TeamSkin2;
var string DefaultSkinName;
var string DefaultPackage;
var float BaseAlertness;

var Translocator MyTranslocator;

var PlayerPawn SupportingPlayer;
var NavigationPoint BlockedPath;
var vector RealLastSeenPos;
var float TacticalOffset;

// for debugging
var string GoalString;

// HUD status 
var texture StatusDoll, StatusBelt;

// allowed voices
var string VoicePackMetaClass;

function PreBeginPlay()
{
	bIsPlayer = true;
	Super.PreBeginPlay();

	if (Orders == '')
		Orders = 'FreeLance';
}

// called when using movetoward with bAdvancedTactics true to temporarily modify destination
event AlterDestination()
{
	local float dir, dist;

	dist = VSize(Destination - Location);
	if ( dist < 120 )
	{
		bAdvancedTactics = false;
		return;
	}
	if ( bNoTact )
		return;

	if ( bTacticalDir )
		Dir = 1;
	else
		Dir = -1;
	Destination = Destination + 1.2 * Dir * dist * Normal((Destination - Location) Cross vect(0,0,1));
}

// Mover has notifies pawn that pawn is underneath it
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

simulated function PostBeginPlay()
{
	if ( class'GameInfo'.Default.bVeryLowGore )
		bGreenBlood = true;
	InitRating();
	Super.PostBeginPlay();
	if ( Level.NetMode != NM_DedicatedServer )
		Shadow = Spawn(class'PlayerShadow',self);
}
 
function StartMatch();

function StopFiring()
{
	bFire = 0;
	bAltFire = 0;
	SetTimer((0.5 + 0.5 * FRand()) * TimeBetweenAttacks, false);
}

function ShootTarget(Actor NewTarget);
	
function InitRating() 
{
	if ( !Level.Game.IsA('DeathMatchPlus') )
		return;
	
	Rating = 1000 + 400 * skill;
	if ( DeathMatchPlus(Level.Game).bNoviceMode )
		Rating -= 500;
}

function float GetRating()
{
	return Rating;
}

function PlayLookAround()
{
	PlayWaiting();
}

function PlayWaving()
{
	TweenToWaiting(0.4);
}

function PlayFlip()
{
	PlayAnim('Flip', 1.35 * FMax(0.35, Region.Zone.ZoneGravity.Z/Region.Zone.Default.ZoneGravity.Z), 0.06);
}

singular event BaseChange()
{
	local actor HitActor;
	local vector HitNormal, HitLocation;

	if ( Mover(Base) != None )
	{
		// handle shootable secret floors
		if ( Mover(Base).bDamageTriggered && !Mover(Base).bOpening
			&& (MoveTarget != None) )
		{
			HitActor = Trace(HitLocation, HitNormal, MoveTarget.Location, Location, true);
			if ( HitActor == Base )
			{
				Target = Base;
				bShootSpecial = true;
				FireWeapon();
				bFire = 0;
				bAltFire = 0;
				Base.Trigger(Base, Self);
				bShootSpecial = false;
			}
		}
	}
	else
		Super.BaseChange();
}

function YellAt(Pawn Moron)
{
	local float Threshold;

	if ( Enemy == None )
		Threshold = 0.4;
	else
		Threshold = 0.7;
	if ( FRand() < Threshold )
		return;

	SendTeamMessage(None, 'FRIENDLYFIRE', Rand(class<ChallengeVoicePack>(PlayerReplicationInfo.VoiceType).Default.NumFFires), 5);
}	

function bool AddInventory( inventory NewItem )
{
	Super.AddInventory(NewItem);

	if ( NewItem.IsA('Translocator') )
		MyTranslocator = Translocator(NewItem);
}

function HaltFiring()
{
	bCanFire = false;
	bFire = 0;
	bAltFire = 0;
	SetTimer((0.75 + 0.5 * FRand()) * TimeBetweenAttacks, false);
	if ( Weapon != None )
		Weapon.Tick(0.001);
}

function bool TryToward(inventory Inv, float Weight)
{
	return true;
}

function SendTeamMessage(PlayerReplicationInfo Recipient, name MessageType, byte MessageID, float Wait)
{
	//log(self@"Send message"@MessageType@MessageID@"at"@Level.TimeSeconds);
	if ( (MessageType == OldMessageType) && (MessageID == OldMessageID)
		&& (Level.TimeSeconds - OldMessageTime < Wait) )
		return;

	//log("Passed filter");
	OldMessageID = MessageID;
	OldMessageType = MessageType;

	SendVoiceMessage(PlayerReplicationInfo, Recipient, MessageType, MessageID, 'TEAM');
}

function SendGlobalMessage(PlayerReplicationInfo Recipient, name MessageType, byte MessageID, float Wait)
{
	//log(self@"Send message"@MessageType@MessageID@"at"@Level.TimeSeconds);
	if ( (MessageType == OldMessageType) && (MessageID == OldMessageID) 
		&& (Level.TimeSeconds - OldMessageTime < Wait) )
		return;

	//log("Passed filter");
	OldMessageID = MessageID;
	OldMessageType = MessageType;

	SendVoiceMessage(PlayerReplicationInfo, Recipient, MessageType, MessageID, 'GLOBAL');
}

function SetOrders(name NewOrders, Pawn OrderGiver, optional bool bNoAck)
{
	local Pawn P;
	local Bot B;

	if ( NewOrders != BotReplicationInfo(PlayerReplicationInfo).RealOrders )
	{ 
		if ( (IsInState('Roaming') && bCamping) || IsInState('Wandering') )
			GotoState('Roaming', 'PreBegin');
		else if ( !IsInState('Dying') )
			GotoState('Attacking');
	}

	bLeading = false;
	if ( NewOrders == 'Point' )
	{
		NewOrders = 'Attack';
		SupportingPlayer = PlayerPawn(OrderGiver);
	}
	else
		SupportingPlayer = None;

	if ( bSniping && (NewOrders != 'Defend') )
		bSniping = false;
	bStayFreelance = false;
	if ( !bNoAck && (OrderGiver != None) )
		SendTeamMessage(OrderGiver.PlayerReplicationInfo, 'ACK', Rand(class<ChallengeVoicePack>(PlayerReplicationInfo.VoiceType).Default.NumAcks), 5);

	BotReplicationInfo(PlayerReplicationInfo).SetRealOrderGiver(OrderGiver);
	BotReplicationInfo(PlayerReplicationInfo).RealOrders = NewOrders;

	Aggressiveness = BaseAggressiveness;
	if ( Orders == 'Follow' )
		Aggressiveness -= 1;
	Orders = NewOrders;
	if ( !bNoAck && (HoldSpot(OrderObject) != None) )
	{
		OrderObject.Destroy();
		OrderObject = None;
	}
	if ( Orders == 'Hold' )
	{
		Aggressiveness += 1;
		if ( !bNoAck )
			OrderObject = OrderGiver.Spawn(class'HoldSpot');
	}
	else if ( Orders == 'Follow' )
	{
		Aggressiveness += 1;
		OrderObject = OrderGiver;
	}
	else if ( Orders == 'Defend' )
	{
		if ( Level.Game.IsA('TeamGamePlus') )
			OrderObject = TeamGamePlus(Level.Game).SetDefenseFor(self);
		else
			OrderObject = None;
		if ( OrderObject == None )
		{
			Orders = 'Freelance';
			if ( bVerbose )
				log(self$" defender couldn't find defense object");
		}
		else
			CampingRate = 1.0;
	}
	else if ( Orders == 'Attack' )
	{
		CampingRate = 0.0;
		// set bLeading if have supporters
		if ( Level.Game.bTeamGame )
			for ( P=Level.PawnList; P!=None; P=P.NextPawn )
				if ( P.bIsPlayer && (P.PlayerReplicationInfo.Team == PlayerReplicationInfo.Team) )
				{
					B = Bot(P);
					if ( (B != None) && (B.OrderObject == self) && (BotReplicationInfo(B.PlayerReplicationInfo).RealOrders == 'Follow') )
					{
						bLeading = true;
						break;
					}
				}
	}	
				
	BotReplicationInfo(PlayerReplicationInfo).OrderObject = OrderObject;
}

function BotVoiceMessage(name messagetype, byte messageID, Pawn Sender)
{
	if ( !Level.Game.bTeamGame || (Sender.PlayerReplicationInfo.Team != PlayerReplicationInfo.Team) )
		return;

	if ( messagetype == 'ORDER' )
		SetOrders(class'ChallengeTeamHUD'.default.OrderNames[messageID], Sender);
}

function float AdjustDesireFor(Inventory Inv)
{
	if ( inv.class == FavoriteWeapon )
		return 0.35;

	return 0;
}

function bool SwitchToBestWeapon()
{
	local float rating;
	local int usealt, favalt;
	local inventory MyFav;

	if ( Inventory == None )
		return false;

	PendingWeapon = Inventory.RecommendWeapon(rating, usealt);
	if ( PendingWeapon == None )
		return false;

	if ( (FavoriteWeapon != None) && (PendingWeapon.class != FavoriteWeapon) )
	{
		MyFav = FindInventoryType(FavoriteWeapon);
		if ( (MyFav != None) && (Weapon(MyFav).RateSelf(favalt) + 0.22 > PendingWeapon.RateSelf(usealt)) )
		{
			usealt = favalt;
			PendingWeapon = Weapon(MyFav);
		}
	}
	if ( Weapon == None )
		ChangedWeapon();
	else if ( Weapon != PendingWeapon )
		Weapon.PutDown();

	return (usealt > 0);
}

// ASMD combo move
function SpecialFire()
{
	bComboPaused = true;
	SpecialPause = 0.75 + VSize(Target.Location - Location)/Weapon.AltProjectileSpeed;
	NextState = 'Attacking';
	NextLabel = 'Begin'; 
	Acceleration = vect(0,0,0);
	GotoState('RangedAttack');
}

//*********************************************************************
/* Default location specific take hits  - make sure pain frames are named right */
function PlayGutHit(float tweentime)
{
	if ( (LastPainTime - Level.TimeSeconds < 0.3) && (LastPainAnim == 'GutHit') )
	{
		if (FRand() < 0.5)
			TweenAnim('LeftHit', tweentime);
		else
			TweenAnim('RightHit', tweentime);
	}
	else
		TweenAnim('GutHit', tweentime);
}

function PlayHeadHit(float tweentime)
{
	if ( (LastPainTime - Level.TimeSeconds < 0.3) && (LastPainAnim == 'HeadHit') )
	{
		if (FRand() < 0.5)
			TweenAnim('LeftHit', tweentime);
		else
			TweenAnim('RightHit', tweentime);
	}
	else
		TweenAnim('HeadHit', tweentime);
}

function PlayLeftHit(float tweentime)
{
	if ( (LastPainTime - Level.TimeSeconds < 0.3) && (LastPainAnim == 'LeftHit') )
		TweenAnim('GutHit', tweentime);
	else
		TweenAnim('LeftHit', tweentime);
}

function PlayRightHit(float tweentime)
{
	if ( (LastPainTime - Level.TimeSeconds < 0.3) && (LastPainAnim == 'RightHit') )
		TweenAnim('GutHit', tweentime);
	else
		TweenAnim('RightHit', tweentime);
}

function bool StrafeFromDamage(vector momentum, float Damage,name DamageType, bool bFindDest);

//**********************************************************************

function PlayHit(float Damage, vector HitLocation, name damageType, vector Momentum)
{
	local float rnd;
	local Bubble1 bub;
	local bool bOptionalTakeHit;
	local vector BloodOffset, Mo;

	if (Damage > 1) //spawn some blood
	{
		if (damageType == 'Drowned')
		{
			bub = spawn(class 'Bubble1',,, Location 
				+ 0.7 * CollisionRadius * vector(ViewRotation) + 0.3 * BaseEyeHeight * vect(0,0,1));
			if (bub != None)
				bub.DrawScale = FRand()*0.06+0.04; 
		}
		else if ( damageType != 'Corroded' )
		{
			BloodOffset = 0.2 * CollisionRadius * Normal(HitLocation - Location);
			BloodOffset.Z = BloodOffset.Z * 0.5;
			if ( bGreenBlood )
				spawn(class 'UT_GreenBloodPuff',self,,hitLocation + BloodOffset, rotator(BloodOffset));
			else if ( (!Level.bDropDetail || (FRand() < 0.67))
				&& ((DamageType == 'shot') || (DamageType == 'decapitated') || (DamageType == 'shredded')) )
			{
				Mo = Momentum;
				if ( Mo.Z > 0 )
					Mo.Z *= 0.5;
				spawn(class 'UT_BloodHit',self,,hitLocation + BloodOffset, rotator(Mo));
			}
			else
				spawn(class 'UT_BloodBurst',self,,hitLocation + BloodOffset);
		}
	}	

	bFireFalling = false;
	bOptionalTakeHit = ( (Level.TimeSeconds - LastPainTime > 0.3 + 0.25 * skill)
						&& (Damage * FRand() > 0.08 * Health) && (bNovice || (Skill < 2))
						&& (GetAnimGroup(AnimSequence) != 'MovingAttack') 
						&& (GetAnimGroup(AnimSequence) != 'Attack') ); 

	if ( ((Weapon == None) || !Weapon.bPointing)
		 && (GetAnimGroup(AnimSequence) != 'Dodge') 
		&& (bOptionalTakeHit || (Momentum.Z > 140) 
			 || (Damage * FRand() > (0.17 + 0.04 * skill) * Health)) ) 
	{
		PlayTakeHitSound(Damage, damageType, 3);
		PlayHitAnim(HitLocation, Damage);
		if ( (Enemy != None) && !bNovice && (FRand() * Skill > 0.5) )
		{
			NextState = 'FallingState';
			NextLabel = 'FireWhileFalling';
		}
	}
	else if ( (Region.Zone.ZoneGravity.Z > Region.Zone.Default.ZoneGravity.Z)
				&& (Momentum.Z/Region.Zone.ZoneGravity.Z < -0.5) )
	{
		bFireFalling = true;
		PlayTakeHitSound(Damage, damageType, 2);
	}			 
	else if (NextState == 'TakeHit')
	{
		PlayTakeHitSound(Damage, damageType, 2);
		NextState = '';
	}
}

function PlayHitAnim(vector HitLocation, float Damage)
{
	NextAnim = ''; 
	NextState = 'TakeHit';
	PlayTakeHit(0.08, hitLocation, Damage); 
} 

function PlayDeathHit(float Damage, vector HitLocation, name damageType, vector Momentum)
{
	local Bubble1 bub;
	local UT_BloodBurst b;
	local vector Mo;

	if ( Region.Zone.bDestructive && (Region.Zone.ExitActor != None) )
		Spawn(Region.Zone.ExitActor);
	if (HeadRegion.Zone.bWaterZone)
	{
		bub = spawn(class 'Bubble1',,, Location 
			+ 0.3 * CollisionRadius * vector(Rotation) + 0.8 * BaseEyeHeight * vect(0,0,1));
		if (bub != None)
			bub.DrawScale = FRand()*0.08+0.03; 
		bub = spawn(class 'Bubble1',,, Location 
			+ 0.2 * CollisionRadius * VRand() + 0.7 * BaseEyeHeight * vect(0,0,1));
		if (bub != None)
			bub.DrawScale = FRand()*0.08+0.03; 
		bub = spawn(class 'Bubble1',,, Location 
			+ 0.3 * CollisionRadius * VRand() + 0.6 * BaseEyeHeight * vect(0,0,1));
		if (bub != None)
			bub.DrawScale = FRand()*0.08+0.03; 
	}
	if ( !bGreenBlood && (DamageType == 'shot') || (DamageType == 'decapitated') )
	{
		Mo = Momentum;
		if ( Mo.Z > 0 )
			Mo.Z *= 0.5;
		spawn(class 'UT_BloodHit',self,,hitLocation, rotator(Mo));
	}
	else if ( (damageType != 'Burned') && (damageType != 'Corroded') 
		 && (damageType != 'Drowned') && (damageType != 'Fell') )
	{
		b = spawn(class 'UT_BloodBurst',self,'', hitLocation);
		if ( bGreenBlood && (b != None) ) 
			b.GreenBlood();		
	}
}

function PlayChallenge()
{
	TweenToFighter(0.1);
}

simulated function PlayFootStep()
{
	local sound step;
	local float decision;

	if ( FootRegion.Zone.bWaterZone )
	{
		PlaySound(sound 'LSplash', SLOT_Interact, 1, false, 1500.0, 1.0);
		return;
	}

	decision = FRand();
	if ( decision < 0.34 )
		step = Footstep1;
	else if (decision < 0.67 )
		step = Footstep2;
	else
		step = Footstep3;

	PlaySound(step, SLOT_Interact, 2.2, false, 1000.0, 1.0);
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

function PlayTakeHitSound(int damage, name damageType, int Mult)
{
	if ( Level.TimeSeconds - LastPainSound < 0.25 )
		return;
	LastPainSound = Level.TimeSeconds;

	if ( HeadRegion.Zone.bWaterZone )
	{
		if ( damageType == 'Drowned' )
			PlaySound(drown, SLOT_Pain, 12);
		else if ( FRand() < 0.5 )
			PlaySound(UWHit1, SLOT_Pain,16,,,Frand()*0.15+0.9);
		else
			PlaySound(UWHit2, SLOT_Pain,16,,,Frand()*0.15+0.9);
		return;
	}
	damage *= FRand();

	if (damage < 8) 
		PlaySound(HitSound1, SLOT_Pain,16,,,Frand()*0.2+0.9);
	else if (damage < 25)
	{
		if (FRand() < 0.5) PlaySound(HitSound2, SLOT_Pain,16,,,Frand()*0.15+0.9);			
		else PlaySound(HitSound3, SLOT_Pain,16,,,Frand()*0.15+0.9);
	}
	else
		PlaySound(HitSound4, SLOT_Pain,16,,,Frand()*0.15+0.9);			
}

function CallForHelp()
{
	local Pawn P;

	//log(self$" call for help");
	SendTeamMessage(None, 'Other', 4, 15);
		
	for ( P=Level.PawnList; P!=None; P=P.NextPawn )
		if ( P.IsA('Bot') && (P.PlayerReplicationInfo.Team == PlayerReplicationInfo.Team) )
			P.HandleHelpMessageFrom(self);
}

function string KillMessage(name damageType, pawn Other)
{
	return ( Level.Game.PlayerKillMessage(damageType, Other.PlayerReplicationInfo)$PlayerReplicationInfo.PlayerName );
}

function Gasp()
{
	if ( PainTime < 2 )
		PlaySound(GaspSound, SLOT_Talk, 2.0);
	else
		PlaySound(BreathAgain, SLOT_Talk, 2.0);
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
				&& (Destination.Z >= Location.Z) 
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
	velocity.Z = 380; //set here so physics uses this for remainder of tick
	PlayOutOfWater();
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
	if ( bNovice )
	{
		RotationRate.Yaw = 30000 + 3000 * skill;
		bCanDuck = false;
		if ( bThreePlus )
			MaxDesiredSpeed = 1;
		else
			MaxDesiredSpeed = 0.5 + 0.1 * skill;
		bCanDuck = false;
	}
	else
	{
		MaxDesiredSpeed = 1;
		if ( Skill == 3 )
			RotationRate.Yaw = 100000;
		else
			RotationRate.Yaw = 40000 + 11000 * skill;
		bCanDuck = ( skill > 1 );
	}
}

function SetPeripheralVision()
{
	if ( bNovice )
		PeripheralVision = 0.7;
	else if ( Skill == 3 )
		PeripheralVision = -0.2;
	else
		PeripheralVision = 0.65 - 0.33 * skill;

	PeripheralVision = FMin(PeripheralVision - BaseAlertness, 0.9);
	if ( bSniping && (AmbushSpot != None) )
		SightRadius = AmbushSpot.SightRadius;
	else
		SightRadius = Default.SightRadius;
}

function PainTimer()
{
	local float depth;
	if (Health <= 0)
		return;

	if (FootRegion.Zone.bPainZone)
		Super.PainTimer();
	else if (HeadRegion.Zone.bWaterZone)
	{
		if (bDrowning)
			self.TakeDamage(5, None, Location + CollisionHeight * vect(0,0,0.5), vect(0,0,0), 'Drowned'); 
		else if ( !Level.Game.IsA('Assault') )
		{
			bDrowning = true;
			GotoState('FindAir');
		}
		if (Health > 0)
			PainTime = 2.0;
	}
}	

function ChangedWeapon()
{
	local int usealt;

	if ( Weapon == PendingWeapon )
	{
		if ( Weapon == None )
			SwitchToBestWeapon();
		else if ( Weapon.GetStateName() == 'DownWeapon' ) 
			Weapon.GotoState('Idle');
		PendingWeapon = None;
	}
	else
		Super.ChangedWeapon();

	if ( Weapon != None )
	{
		if ( (bFire > 0) || (bAltFire > 0) )
		{
			Weapon.RateSelf(usealt);
			if ( usealt == 0 )
			{
				bAltFire = 0;
				bFire = 1;
				Weapon.Fire(1.0);
			}
			else
			{
				bAltFire = 0;
				bFire = 1;
				Weapon.AltFire(1.0);
			}
		}
		Weapon.SetHand(0);
		// Weapon.FireOffset.Y = 0;
	}
}

function bool Gibbed( name damageType)
{
	if ( (damageType == 'decapitated') || (damageType == 'shot') )
		return false; 	
	return ( (Health < -80) || ((Health < -40) && (FRand() < 0.6)) );
}

function SpawnGibbedCarcass()
{
	local carcass carc;

	carc = Spawn(CarcassType);
	if ( carc != None )
	{
		carc.Initfor(self);
		carc.ChunkUp(-1 * Health);
	}
}

function Carcass SpawnCarcass()
{
	local carcass carc;

	carc = Spawn(CarcassType);
	if ( carc != None )
		carc.Initfor(self);

	return carc;
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

function FearThisSpot(Actor aSpot)
{
	Acceleration = vect(0,0,0);
	MoveTimer = -1.0;
}

function FastInAir()
{
	PlayInAir();
}

/*
SetAlertness()
Change creature's alertness, and appropriately modify attributes used by engine for determining
seeing and hearing.
SeePlayer() is affected by PeripheralVision, and also by SightRadius and the target's visibility
HearNoise() is affected by HearingThreshold
*/
final function SetAlertness(float NewAlertness)
{
	if ( Alertness != NewAlertness )
	{
		PeripheralVision += 0.707 * (Alertness - NewAlertness); //Used by engine for SeePlayer()
		HearingThreshold += 0.5 * (Alertness - NewAlertness); //Used by engine for HearNoise()
		Alertness = NewAlertness;
	}
}

function WhatToDoNext(name LikelyState, name LikelyLabel)
{
	if ( bVerbose )
	{
		log(self$" what to do next");
		log("enemy "$Enemy);
		log("old enemy "$OldEnemy);
	}
	if ( (Level.NetMode != NM_Standalone) 
		&& Level.Game.IsA('DeathMatchPlus')
		&& DeathMatchPlus(Level.Game).TooManyBots() )
	{
		Destroy();
		return;
	}

	BlockedPath = None;
	bDevious = false;
	bFire = 0;
	bAltFire = 0;
	bKamikaze = false;
	SetOrders(BotReplicationInfo(PlayerReplicationInfo).RealOrders, BotReplicationInfo(PlayerReplicationInfo).RealOrderGiver, true);
	Enemy = OldEnemy;
	OldEnemy = None;
	bReadyToAttack = false;
	if ( Enemy != None )
	{
		bReadyToAttack = !bNovice;
		GotoState('Attacking');
	}
	else if ( (Orders == 'Hold') && (Weapon.AIRating > 0.4) && (Health > 70) )
			GotoState('Hold');
	else
	{
		GotoState('Roaming');
		if ( Skill > 2.7 )
			bReadyToAttack = true; 
	}
}

function bool CheckBumpAttack(Pawn Other)
{
	local pawn CurrentEnemy;

	CurrentEnemy = Enemy;
	if ( SetEnemy(Other) )
	{
		if ( (Enemy == Other) && (Weapon != None) && !Weapon.bMeleeWeapon )
		{
			bReadyToAttack = true;
			GotoState('RangedAttack');
			return true;
		} 
		else 
		{
			Enemy = CurrentEnemy;
			if ( OldEnemy == CurrentEnemy )
				OldEnemy = None;
		}
	}
	return false;
}

function bool DeferTo(Bot Other)
{
	if ( (Other.PlayerReplicationInfo.HasFlag != None) 
		|| ((Orders == 'Follow') && (Other == OrderObject)) )
	{
		if ( Level.Game.IsA('TeamGamePlus') && TeamGamePlus(Level.Game).HandleTieUp(self, Other) )
			return false;
		if ( (Enemy != None) && LineOfSightTo(Enemy) )
			GotoState('TacticalMove', 'NoCharge');
		else
		{
			Enemy = None;
			OldEnemy = None;
			if ( (Health > 0) && (Acceleration == vect(0,0,0)) )
			{
				WanderDir = Normal(Location - Other.Location);
				GotoState('Wandering', 'Begin');
			}
		}
		Other.SetTimer(FClamp(TimerRate, 0.001, 0.2), false);
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
	if ( TimerRate <= 0 )
		setTimer(1.0, false);
	
	if ( Level.Game.bTeamGame && (P != None) && (MoveTarget != None) )
	{
		OtherDir = P.Location - MoveTarget.Location;
		if ( abs(OtherDir.Z) < P.CollisionHeight )
		{
			OtherDir.Z = 0;
			dist = VSize(OtherDir);
			bDestinationObstructed = ( VSize(OtherDir) < P.CollisionRadius ); 
			if ( P.IsA('Bot') )
				bAmLeader = ( Bot(P).DeferTo(self) || (PlayerReplicationInfo.HasFlag != None) );

			// check if someone else is on destination or within 3 * collisionradius
			for ( M=Level.PawnList; M!=None; M=M.NextPawn )
				if ( M != self )
				{
					dist = VSize(M.Location - MoveTarget.Location);
					if ( dist < M.CollisionRadius )
					{
						bDestinationObstructed = true;
						if ( M.IsA('Bot') )
							bAmLeader = Bot(M).DeferTo(self) || bAmLeader;
					}
					if ( dist < 3 * M.CollisionRadius ) 
					{
						num++;
						if ( num >= 2 )
						{
							bDestinationObstructed = true;
							if ( M.IsA('Bot') )
								bAmLeader = Bot(M).DeferTo(self) || bAmLeader;
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
						if ( !IsInState('TacticalMove') )
							GotoState('TacticalMove', 'NoCharge');
					}
					else if ( !IsInState('StakeOut') && (FRand() < 0.5) )
					{
						GotoState('StakeOut');
						LastSeenTime = 0;
						bClearShot = false;
					}		
				}
				else if ( (Health > 0) && !IsInState('Wandering') || (Acceleration == vect(0,0,0)) )
				{
					WanderDir = Normal(Location - P.Location);
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
		GotoState('Wandering', 'Begin');
	Disable('Bump');
}
		
singular function Falling()
{
	if (bCanFly)
	{
		SetPhysics(PHYS_Flying);
		return;
	}			
	//log(class$" Falling");
	// SetPhysics(PHYS_Falling); //note - done by default in physics
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
		NextAnim = AnimSequence;
		GotoState('FallingState');
	}
}

function LongFall()
{
	SetFall();
	if ( (Enemy != None) && (Region.Zone.ZoneGravity.Z > Region.Zone.Default.ZoneGravity.Z) )
		GotoState('FallingState', 'FireWhileFalling');
	else 
		GotoState('FallingState', 'LongFall');
}

event UpdateTactics(float DeltaTime)
{
	if ( bTacticalDir )
	{
		TacticalOffset += DeltaTime;
		if ( TacticalOffset > 0.5 )
		{
			bTacticalDir = false;
			bNoTact = ( FRand() < 0.3 );
		}
	}
	else
	{
		TacticalOffset -= DeltaTime;
		if ( TacticalOffset < -0.5 )
		{
			bTacticalDir = true;
			bNoTact = ( FRand() < 0.3 );
		}
	}
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

	//check if still viewtarget
	bViewTarget = false;
	for ( P=Level.PawnList; P!=None; P=P.NextPawn )
		if ( P.IsA('PlayerPawn') && (PlayerPawn(P).ViewTarget == self) )
		{
			bViewTarget = true;
			if ( bVerbose )
			{
				if ( (Enemy != None) && Enemy.bIsPlayer )
					P.ClientMessage(PlayerReplicationInfo.PlayerName@"Orders"@orders@"State"@GetStateName()@"MoveTarget"@MoveTarget@"AlternatePath"@AlternatePath@"Enemy"@Enemy.PlayerReplicationInfo.PlayerName@"See"@LineOfSightTo(Enemy), 'CriticalEvent' );
				else					
					P.ClientMessage(PlayerReplicationInfo.PlayerName@"Orders"@orders@"State"@GetStateName()@"MoveTarget"@MoveTarget@"AlternatePath"@AlternatePath@"Enemy"@Enemy, 'CriticalEvent' );
			}
			break;
		}

	if ( !bViewTarget )
	{
		bVerbose = false;
		return;
	}

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

function HearNoise(float Loudness, Actor NoiseMaker)
{
	//log(class@"heard noise by"@NoiseMaker.class);
	SetEnemy(NoiseMaker.instigator);
}

function GiveUpTactical(bool bNoCharge);

function SeePlayer(Actor SeenPlayer)
{
	SetEnemy(Pawn(SeenPlayer));
}

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

function bool NeedToTurn(vector targ)
{
	local int YawErr;

	DesiredRotation = Rotator(targ - location);
	DesiredRotation.Yaw = DesiredRotation.Yaw & 65535;
	YawErr = (DesiredRotation.Yaw - (Rotation.Yaw & 65535)) & 65535;
	if ( (YawErr < 4000) || (YawErr > 61535) )
		return false;

	return true;
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

function FireWeapon()
{
	local bool bUseAltMode;
	local Weapon MyAutomag;

	if ( (Enemy == None) && bShootSpecial )
	{
		//fake use automag
		MyAutomag = Weapon(FindInventoryType(class'Enforcer'));
		if ( MyAutoMag == None )
			Spawn(class'PlasmaSphere',,, Location,Rotator(Target.Location - Location));
		else
			MyAutoMag.TraceFire(0);

		return;
	}

	bUseAltMode = SwitchToBestWeapon();

	if( Weapon!=None )
	{
		if ( (Weapon.AmmoType != None) && (Weapon.AmmoType.AmmoAmount <= 0) )
		{
			bReadyToAttack = true;
			return;
		}

 		if ( !bComboPaused && !bShootSpecial && (Enemy != None) )
 			Target = Enemy;
		ViewRotation = Rotation;
		PlayFiring();
		if ( bUseAltMode )
		{
			bFire = 0;
			bAltFire = 1;
			Weapon.AltFire(1.0);
		}
		else
		{
			bFire = 1;
			bAltFire = 0;
			Weapon.Fire(1.0);
		}
	}
	bShootSpecial = false;
}

function PlayFiring();

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
		if ( (Target != Enemy) || (Enemy.Weapon == None) || !Enemy.Weapon.bMeleeWeapon || (TargetDist > 650) )
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

	viewRotation = FireRotation;			
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

	if ( Target == None )
		Target = Enemy;
	if ( Target == None )
	{
		bFire = 0;
		bAltFire = 0;
		return Rotation;
	}
	if ( !Target.bIsPawn || Target.IsA('FortStandard') )
		return rotator(Target.Location - projstart);
					
	FireSpot = Target.Location;
	TargetDist = VSize(Target.Location - Location);

	aimerror = aimerror * (11 - 10 *  
		((Target.Location - Location)/TargetDist 
			Dot Normal((Target.Location + 1.25 * Target.Velocity) - (Location + Velocity)))); 

	bDefendMelee = ( (Target == Enemy) && (Enemy.Weapon != None) && Enemy.Weapon.bMeleeWeapon && (TargetDist < 700) );
	if ( bDefendMelee )
		aimerror *= 0.5;
	if ( ((projSpeed == 0) || (Projspeed >= 1000000)) )
	{
		// instant hit
		if ( bNovice )
			aimerror *= 0.5;
		else
			aimerror *= 0.5 + 0.19 * skill;
	}

	if ( bNovice )
	{
		if ( !bDefendMelee )
			aimerror = aimerror * (2.4 - 0.2 * (skill + FRand()));
		if ( (Level.TimeSeconds - LastPainTime < 0.2) || (Physics == PHYS_Falling) || (Target.Physics == PHYS_Falling) )
			aimerror *= 1.5;
	}
	else
	{
		aimerror = aimerror * (1.7 - 0.4 * (skill + FRand()));
		if ( (Skill < 2) 
			&& ((Level.TimeSeconds - LastPainTime < 0.15) || (Physics == PHYS_Falling) || (Target.Physics == PHYS_Falling)) )
			aimerror *= 1.2;
	}

	if ( (bNovice && (LastAcquireTime > Level.TimeSeconds - 5 + 0.5 * skill))
		|| (LastAcquireTime > Level.TimeSeconds - 2.5 + skill) )
	{
		LastAcquireTime = Level.TimeSeconds - 5;
		if ( bDefendMelee )
			aimerror *= 1.3;
		else
			aimerror *= 2;
	}
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
			if ( Weapon.RefireRate < 0.99 )
				bFire = 0;
			if ( Weapon.AltRefireRate < 0.99 )
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

	viewRotation = FireRotation;			
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

	if ( (FireDir Dot Y) > 0 )
	{
		Y *= -1;
		TryToDuck(Y, true);
	}
	else
		TryToDuck(Y, false);
}

function TryToDuck(vector duckDir, bool bReversed)
{
	local vector HitLocation, HitNormal, Extent;
	local actor HitActor;
	local bool bSuccess, bDuckLeft;

	if ( Region.Zone.bWaterZone || (Region.Zone.ZoneGravity.Z > Region.Zone.Default.ZoneGravity.Z) )
		return;

	duckDir.Z = 0;
	bDuckLeft = !bReversed;
	Extent.X = CollisionRadius;
	Extent.Y = CollisionRadius;
	Extent.Z = CollisionHeight;
	HitActor = Trace(HitLocation, HitNormal, Location + 240 * duckDir, Location, false, Extent);
	bSuccess = ( (HitActor == None) || (VSize(HitLocation - Location) > 150) );
	if ( !bSuccess )
	{
		bDuckLeft = !bDuckLeft;
		duckDir *= -1;
		HitActor = Trace(HitLocation, HitNormal, Location + 240 * duckDir, Location, false, Extent);
		bSuccess = ( (HitActor == None) || (VSize(HitLocation - Location) > 150) );
	}
	if ( !bSuccess )
		return;
	
	if ( HitActor == None )
		HitLocation = Location + 240 * duckDir; 

	HitActor = Trace(HitLocation, HitNormal, HitLocation - MaxStepHeight * vect(0,0,1), HitLocation, false, Extent);
	if (HitActor == None)
		return;
		
	SetFall();
	Velocity = duckDir * 400;
	Velocity.Z = 160;
	PlayDodge(bDuckLeft);
	PlaySound(JumpSound, SLOT_Talk, 1.0, true, 800, 1.0 );
	SetPhysics(PHYS_Falling);
	if ( (Weapon != None) && Weapon.bSplashDamage
		&& ((bFire != 0) || (bAltFire != 0)) && (Enemy != None) 
		&& !FastTrace(Enemy.Location, HitLocation) 
		&& FastTrace(Enemy.Location, Location) )
	{
		bFire = 0;
		bAltFire = 0;
	}
	GotoState('FallingState','Ducking');
}

function PlayDodge(bool bDuckLeft)
{
	PlayDuck();
}

// CloseToPointMan - called if orders are 'follow' to check if close enough to point man
function bool CloseToPointMan(Pawn Other)
{
	local float dist;

	// for certain games, have bots wait for leader for a while
	if ( TeamGamePlus(Level.Game).WaitForPoint(self) )
		return true;

	if ( (Base != None) && (Other.Base != None) && (Other.Base != Base) )
		return false;	

	dist = VSize(Location - Other.Location);
	if ( dist > 400 )
		return false;
	
	// check if point is moving away
	if ( (Region.Zone.bWaterZone || (dist > 200)) && (((Other.Location - Location) Dot Other.Velocity) > 0) )
		return false;
				
	return ( LineOfSightTo(Other) );
}

// Can Stake Out - check if I can see my current Destination point, and so can enemy
function bool CanStakeOut()
{
	if ( VSize(Enemy.Location - LastSeenPos) > 800 )
		return false;		
	
	return ( FastTrace(LastSeenPos, Location + EyeHeight * vect(0,0,1))
			&& FastTrace(LastSeenPos , Enemy.Location + Enemy.BaseEyeHeight * vect(0,0,1)) );
}

function eAttitude AttitudeTo(Pawn Other)
{
	local byte result;

	if ( Level.Game.IsA('DeathMatchPlus') )
	{
		result = DeathMatchPlus(Level.Game).AssessBotAttitude(self, Other);
		Switch (result)
		{
			case 0: return ATTITUDE_Fear;
			case 1: return ATTITUDE_Hate;
			case 2: return ATTITUDE_Ignore;
			case 3: return ATTITUDE_Friendly;
		}
	}

	if ( Level.Game.bTeamGame && (PlayerReplicationInfo.Team == Other.PlayerReplicationInfo.Team) )
		return ATTITUDE_Friendly; //teammate

	return ATTITUDE_Hate;
}

function float AssessThreat( Pawn NewThreat )
{
	local float ThreatValue, NewStrength, Dist;
	local eAttitude NewAttitude;

	NewStrength = RelativeStrength(NewThreat);

	ThreatValue = FMax(0, NewStrength);
	if ( NewThreat.Health < 20 )
		ThreatValue += 0.3;

	Dist = VSize(NewThreat.Location - Location);
	if ( Dist < 800 )
		ThreatValue += 0.3;

	if ( (NewThreat != Enemy) && (Enemy != None) )
	{
		if ( Dist > 0.7 * VSize(Enemy.Location - Location) )
			ThreatValue -= 0.25;
		ThreatValue -= 0.2;

		if ( !LineOfSightTo(Enemy) )
		{
			if ( Dist < 1200 )
				ThreatValue += 0.2;
			if ( SpecialPause > 0 )
				ThreatValue += 5;
			if ( IsInState('Hunting') && (NewStrength < 0.2) 
				&& (Level.TimeSeconds - LastSeenTime < 3)
				&& (relativeStrength(Enemy) < FMin(0, NewStrength)) )
				ThreatValue -= 0.3;
		}
	}

	if ( NewThreat.IsA('PlayerPawn') )
	{
		if ( Level.Game.bTeamGame )
			ThreatValue -= 0.15;
		else
			ThreatValue += 0.15;
	}

	if ( Level.Game.IsA('DeathMatchPlus') )
		ThreatValue += DeathMatchPlus(Level.Game).GameThreatAdd(self, NewThreat);
	return ThreatValue;
}


function bool SetEnemy( Pawn NewEnemy )
{
	local bool result, bNotSeen;
	local eAttitude newAttitude, oldAttitude;
	local float newStrength;
	local Pawn Friend;

	if (Enemy == NewEnemy)
		return true;
	if ( (NewEnemy == Self) || (NewEnemy == None) || (NewEnemy.Health <= 0) || NewEnemy.IsA('FlockPawn') )
		return false;

	result = false;
	newAttitude = AttitudeTo(NewEnemy);
	if ( newAttitude == ATTITUDE_Friendly )
	{
		Friend = NewEnemy;
		if ( Level.TimeSeconds - Friend.LastSeenTime > 5 )
			return false;
		NewEnemy = NewEnemy.Enemy;
		if ( (NewEnemy == None) || (NewEnemy == Self) || (NewEnemy.Health <= 0) || NewEnemy.IsA('FlockPawn') || NewEnemy.IsA('StationaryPawn') )
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
		if ( AssessThreat(NewEnemy) > AssessThreat(Enemy) )
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
		if ( bNotSeen )
		{
			LastSeenTime = Friend.LastSeenTime;
			LastSeeingPos = Friend.LastSeeingPos;
			LastSeenPos = Friend.LastSeenPos;
		}
		else
		{
			LastSeenTime = Level.TimeSeconds;
			LastSeeingPos = Location;
			LastSeenPos = Enemy.Location;
		}
		EnemyAcquired();
	}
				
	return result;
}

function InitializeSkill(float InSkill)
{
	Skill = InSkill;
	bNovice = ( Skill < 4 );
	if ( !bNovice )
		Skill -= 4;
	Skill = FClamp(Skill, 0, 3);
	ReSetSkill();
}

function ReSetSkill()
{
	//log(self$" at skill "$Skill$" novice "$bNovice);
	bThreePlus = ( (Skill >= 3) && Level.Game.IsA('DeathMatchPlus') && DeathMatchPlus(Level.Game).bThreePlus );
	bLeadTarget = ( !bNovice || bThreePlus );
	if ( bNovice )
		ReFireRate = Default.ReFireRate;
	else
		ReFireRate = Default.ReFireRate * (1 - 0.25 * skill);

	PreSetMovement();
}

function MaybeTaunt(Pawn Other)
{
	if ( (FRand() < 0.25) && (Orders != 'Attack')
		&& (!Level.Game.IsA('TeamGamePlus') || (TeamGamePlus(Level.Game).PriorityObjective(self) < 1)) )
	{
		Target = Other;
		GotoState('VictoryDance');
	}
	else
		GotoState('Attacking'); 
}

function Killed(pawn Killer, pawn Other, name damageType)
{
	local Pawn aPawn;

	if ( Killer == self )
		Other.Health = FMin(Other.Health, -11); // don't let other do stagger death

	if ( Health <= 0 )
		return;

	if ( OldEnemy == Other )
		OldEnemy = None;

	if ( Enemy == Other )
	{
		bFire = 0;
		bAltFire = 0;
		bReadyToAttack = ( skill > 3 * FRand() );
		EnemyDropped = Enemy.Weapon;
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

			MaybeTaunt(Other);
		}
		else 
			GotoState('Attacking');
	}
	else if ( Level.Game.bTeamGame && Other.bIsPlayer
			&& (Other.PlayerReplicationInfo.Team == PlayerReplicationInfo.Team) )
	{
		if ( Other == Self )
			return;
		else
		{
			if ( (VSize(Location - Other.Location) < 1400)
				&& LineOfSightTo(Other) )
				SendTeamMessage(None, 'OTHER', 5, 10);
			if ( (Orders == 'follow') && (Other == OrderObject) )
				PointDied = Level.TimeSeconds;
		}
	}
}	

function EnemyAcquired()
{
	//log(Class$" just acquired an enemy - no action");
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

function float RelativeStrength(Pawn Other)
{
	local float compare;
	local int adjustedStrength, adjustedOther;
	local int bTemp;

	adjustedStrength = health;
	adjustedOther = 0.5 * (Other.health + Other.Default.Health);	
	compare = 0.01 * float(adjustedOther - adjustedStrength);
	if ( Weapon != None )
	{
		compare -= DamageScaling * (Weapon.RateSelf(bTemp) - 0.3);
		if ( Weapon.AIRating < 0.5 )
		{
			compare += 0.3;
			if ( (Other.Weapon != None) && (Other.Weapon.AIRating > 0.5) )
				compare += 0.35;
		}
	}
	if ( Other.Weapon != None )
		compare += Other.DamageScaling * (Other.Weapon.RateSelf(bTemp) - 0.3);

	if ( Other.Location.Z > Location.Z + 400 )
		compare -= 0.15;
	else if ( Location.Z > Other.Location.Z + 400 )
		compare += 0.15;
	//log(other.class@"relative strength to"@class@"is"@compare);
	return compare;
}

function bool CanFireAtEnemy()
{
	local vector HitLocation, HitNormal,X,Y,Z, projStart;
	local actor HitActor;
	
	if ( Weapon == None )
		return false;
	
	GetAxes(Rotation,X,Y,Z);
	projStart = Location + Weapon.CalcDrawOffset() + Weapon.FireOffset.X * X + 1.2 * Weapon.FireOffset.Y * Y + Weapon.FireOffset.Z * Z;
	if ( Weapon.bInstantHit )
		HitActor = Trace(HitLocation, HitNormal, Enemy.Location + Enemy.CollisionHeight * vect(0,0,0.7), projStart, true);
	else
		HitActor = Trace(HitLocation, HitNormal, 
				projStart + FMin(280, VSize(Enemy.Location - Location)) * Normal(Enemy.Location + Enemy.CollisionHeight * vect(0,0,0.7) - Location), 
				projStart, true);

	if ( HitActor == Enemy )
		return true;
	if ( (Pawn(HitActor) != None) && (AttitudeTo(Pawn(HitActor)) < ATTITUDE_Ignore) )
		return true;
	if ( HitActor != None )
		return false;

	return true;
}

function bool FaceDestination(float F)
{
	local float RelativeDir;

	if ( Level.TimeSeconds - LastSeenTime > 7.5 - F )
		return true;
	if ( (Enemy == None) || (Enemy.IsA('StationaryPawn') && !LineOfSightTo(Enemy)) )
		return true;
	if ( !bNovice && (skill >= 2) && !Weapon.bMeleeWeapon )
		return false;
	if ( Level.TimeSeconds - LastSeenTime > 4 - F)
		return true;

	RelativeDir = Normal(Enemy.Location - Location - vect(0,0,1) * (Enemy.Location.Z - Location.Z)) 
			Dot Normal(MoveTarget.Location - Location - vect(0,0,1) * (MoveTarget.Location.Z - Location.Z));

	if ( RelativeDir > 0.93 )
		return false;
	if ( Weapon.bMeleeWeapon && (RelativeDir < 0) )
		return true;

	if ( bNovice )
	{
		if ( 0.6 * Skill - F * FRand() + RelativeDir - 0.75 + StrafingAbility < 0 )
			return true;
	}
	else 
	{
		if ( FRand() < 0.2 * (2 - F) )
			return false;
		if ( Skill - F * FRand() + RelativeDir + 0.6 + StrafingAbility < 0 )
			return true;
	}
	return false;
}

function PlayMeleeAttack()
{
	//log("play melee attack");
	Acceleration = AccelRate * VRand();
	TweenToWaiting(0.15); 
	FireWeapon();
}

function PlayRangedAttack()
{
	TweenToWaiting(0.11);
	FireWeapon();
}

function PlayMovingAttack()
{
	PlayRunning();
	FireWeapon();
}

function PlayOutOfWater()
{
	PlayDuck();
}

function PlayCombatMove()
{	
	if ( (Physics == PHYS_Falling) && (Velocity.Z < -300) )
		FastInAir();
	else
		PlayRunning();
	if ( Enemy == None )
		return;
	if ( !bNovice && (Skill > 0) )
		bReadyToAttack = true;
	if ( Weapon == None )
	{
		bAltFire = 0;
		bFire = 0;
		return;
	}
	if ( bReadyToAttack && bCanFire )
	{
		if ( NeedToTurn(Enemy.Location) )
		{
			if ( Weapon.RefireRate < 0.99 )
				bFire = 0;
			if ( Weapon.AltRefireRate < 0.99 )
				bAltFire = 0;
		}
		else 
			FireWeapon(); 
	}		
	else 
	{
		// keep firing if rapid fire weapon unless can't see enemy
		if ( Weapon.RefireRate < 0.99 )
			bFire = 0;
		if ( Weapon.AltRefireRate < 0.99 )
			bAltFire = 0;

		if ( (bFire + bAltFire > 0) && ((Level.TimeSeconds - LastSeenTime > 1) || NeedToTurn(Enemy.Location)) )
		{
			bFire = 0;
			bAltFire = 0;
		}
	}
}

function float StrafeAdjust()
{
	local vector Focus2D, Loc2D, Dest2D;
	local float strafemag; 

	Focus2D = Focus;
	Focus2D.Z = 0;
	Loc2D = Location;
	Loc2D.Z = 0;
	Dest2D = Destination;
	Dest2D.Z = 0;
	strafeMag = Abs( Normal(Focus2D - Loc2D) dot Normal(Dest2D - Loc2D) );

	return ((strafeMag - 2.0)/GroundSpeed);
}

function Trigger( actor Other, pawn EventInstigator )
{
	local Pawn currentEnemy;

	if ( (Other == Self) || (Health <= 0) )
		return;
	currentEnemy = Enemy;
	SetEnemy(EventInstigator);
	if (Enemy != currentEnemy)
		GotoState('Attacking');
}

function TranslocateToTarget(Actor Destn)
{
	PendingWeapon = MyTranslocator;
	MyTranslocator.DesiredTarget = Destn;
	if ( Weapon == None )
		ChangedWeapon();
	else if ( Weapon != PendingWeapon )
		Weapon.PutDown();
	else
		MyTranslocator.PlayPostSelect();
	MoveTarget = Destn;
	DesiredRotation = rotator(MoveTarget.Location - Location);
	SpecialPause = 1.5;
}

function bool CanImpactJump()
{
	return ( bHasImpactHammer && (Health > 60) );
}

function ImpactJump(Actor JumpDest)
{
	if ( Health < 60 )
		return;

	SetFall();
	ImpactTarget = JumpDest;
	GotoState('ImpactJumping');
}

function BigJump(Actor JumpDest)
{
	SetPhysics(PHYS_Falling);
	Velocity = GroundSpeed * Normal(JumpDest.Location - Location);
	if ( JumpDest.IsA('JumpSpot') && JumpSpot(JumpDest).bAlwaysAccel )
	{
		bBigJump = true;
		Acceleration = AccelRate * Normal(Destination - Location);
	}
	else
		Acceleration = vect(0,0,0);
	if ( bCountJumps )
		Inventory.OwnerJumped();
	Velocity.Z = JumpZ;
	Velocity = EAdjustJump();
	bJumpOffPawn = true;
	DesiredRotation = Rotator(JumpDest.Location - Location);
	if ( Region.Zone.ZoneGravity == Region.Zone.Default.ZoneGravity )
		MoveTarget = None;
	SetFall();
}

function bool FindAmbushSpot()
{
	local Pawn P;

	bSpecialAmbush = false;
	if ( (AmbushSpot == None) && Level.Game.IsA('DeathMatchPlus') )
		DeathMatchPlus(Level.Game).PickAmbushSpotFor(self);
	if ( bSpecialAmbush )
		return true;

	if ( (AmbushSpot == None) && (Ambushpoint(MoveTarget) != None)
		&& !AmbushPoint(MoveTarget).taken )
		AmbushSpot = Ambushpoint(MoveTarget);
					
	if ( Ambushspot != None )
	{
		GoalString = "Ambush"@Ambushspot;
		Ambushspot.taken = true;
		if ( VSize(Ambushspot.Location - Location) < 2 * CollisionRadius )
		{
			GoalString = GoalString$" there";	
			if ( !bInitLifeMessage && (Orders == 'Defend') )
			{
				bInitLifeMessage = true;	
				SendTeamMessage(None, 'OTHER', 9, 60);
			}
			if ( Level.Game.bTeamGame )
				for ( P=Level.PawnList; P!=None; P=P.NextPawn )
					if ( P.bIsPlayer && (P.PlayerReplicationInfo != None)
						&& (P.PlayerReplicationInfo.Team == PlayerReplicationInfo.Team)
						&& P.IsA('Bot') && (P != self) 
						&& (Bot(P).Ambushspot == AmbushSpot) )
							Bot(P).AmbushSpot = None;

			bSniping = ((Orders == 'Defend') && AmbushSpot.bSniping);
			CampTime = 10.0;
			SightRadius = AmbushSpot.SightRadius;
			GotoState('Roaming', 'LongCamp');
			return true;
		}
		if ( ActorReachable(Ambushspot) )
		{
			GoalString = GoalString$" reachable";	
			MoveTarget = Ambushspot;
			return true;
		}
		GoalString = GoalString$" path there";	
		MoveTarget = FindPathToward(Ambushspot);
		if ( MoveTarget != None )
			return true;
		Ambushspot.taken = false;
		GoalString = "No ambush";
		Ambushspot = None;
	}
	return false;
}	

function bool PickLocalInventory(float MaxDist, float MinDistraction)
{
	local inventory Inv, BestInv, KnowPath;
	local float NewWeight, DroppedDist, BestWeight;
	local actor BestPath;
	local bool bCanReach;
	local NavigationPoint N;

	if ( (EnemyDropped != None) && !EnemyDropped.bDeleteMe 
		&& (EnemyDropped.Owner == None) )
	{
		DroppedDist = VSize(EnemyDropped.Location - Location);
		NewWeight = EnemyDropped.BotDesireability(self);
		if ( (DroppedDist < MaxDist) 
			&& ((NewWeight > MinDistraction) || (DroppedDist < 0.5 * MaxDist))
			&& ((EnemyDropped.Physics != PHYS_Falling) || (Region.Zone.ZoneGravity.Z == Region.Zone.Default.ZoneGravity.Z))
			&& ActorReachable(EnemyDropped) )
		{
			BestWeight = NewWeight; 		
			if ( BestWeight > 0.4 )
			{
				MoveTarget = EnemyDropped;
				EnemyDropped = None;
				return true; 
			}
			BestInv = EnemyDropped;
			BestWeight = BestWeight/DroppedDist;
			KnowPath = BestInv;
		}	
	}	

	EnemyDropped = None;
								
	//first look at nearby inventory < MaxDist
	foreach visiblecollidingactors(class'Inventory', Inv, MaxDist,,true)
		if ( (Inv.IsInState('PickUp')) && (Inv.MaxDesireability/60 > BestWeight)
			&& (Inv.Physics != PHYS_Falling)
			&& (Inv.Location.Z < Location.Z + MaxStepHeight + CollisionHeight) )
		{
			NewWeight = inv.BotDesireability(self);
			if ( (NewWeight > MinDistraction) 
				 || (Inv.bHeldItem && Inv.IsA('Weapon') && (VSize(Inv.Location - Location) < 0.6 * MaxDist)) )
			{
				NewWeight = NewWeight/VSize(Inv.Location - Location);
				if ( NewWeight > BestWeight )
				{
					BestWeight = NewWeight;
					BestInv = Inv;
				}
			}
		}

	if ( BestInv != None )
	{
		bCanJump = ( bCanTranslocate || (BestInv.Location.Z > Location.Z - CollisionHeight - MaxStepHeight) );
		bCanReach = ActorReachable(BestInv);
	}
	else
		bCanReach = false;
	bCanJump = true;
	if ( bCanReach )
	{
		//GoalString = "local"@BestInv;
		MoveTarget = BestInv;
		return true;
	}
	else if ( KnowPath != None )
	{
		//GoalString = "local"@KnowPath;
		MoveTarget = KnowPath;
		return true;
	}
	//GoalString="No local";
	return false;
}

//**********************************************************************************
//Base Monster AI

auto state StartUp
{
	function BeginState()
	{
		SetMovementPhysics(); 
		if (Physics == PHYS_Walking)
			SetPhysics(PHYS_Falling);
	}

Begin:
	WhatToDoNext('','');
}

state Holding
{
	function ShootTarget(Actor NewTarget)
	{
		Target = NewTarget;
		bFiringPaused = true;
		SpecialPause = 2.0;
		NextState = GetStateName();
		NextLabel = 'Begin';
		GotoState('RangedAttack');
	}	
	
	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
							Vector momentum, name damageType)
	{
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 )
			return;
		if ( (Enemy != None) && (Enemy == InstigatedBy) )
		{
			LastSeenPos = Enemy.Location;
			LastSeenTime = Level.TimeSeconds;
		}
		if (NextState == 'TakeHit')
		{
			NextState = 'Attacking'; 
			NextLabel = 'Begin';
			GotoState('TakeHit'); 
		}
		else if ( Enemy != None )
			GotoState('Attacking');
	}
	
	function Timer()
	{
		Enable('Bump');
	}
	
	function EnemyAcquired()
	{
		GotoState('Acquisition', 'PlayOut');
	}
	
	function AnimEnd()
	{
		PlayWaiting();
	}
 
	function Landed(vector HitNormal)
	{
		SetPhysics(PHYS_None);
	}

	function BeginState()
	{
		Enemy = None;
		bStasis = false;
		Acceleration = vect(0,0,0);
		SetAlertness(0.0);
	}

	function EndState()
	{
		if ( HoldSpot(OrderObject) != None )
			HoldSpot(OrderObject).Holder = None;
	}

TurnFromWall:
	if ( NearWall(2 * CollisionRadius + 50) )
	{
		PlayTurning();
		TurnTo(Focus);
	}
Begin:
	if ( HoldSpot(OrderObject) == None )
	{
		if ( bVerbose )
			log(self$" give up hold");
		SetOrders('Freelance', None);
		GotoState('Roaming');
	} 
	else 
		HoldSpot(OrderObject).Holder = self;
	TweenToWaiting(0.4);
Waving:
	bReadyToAttack = false;
	DesiredRotation = OrderObject.Rotation;
	Sleep(2.5);
	GotoState('Roaming');
}

state Hold
{
	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
							Vector momentum, name damageType)
	{
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 )
			return;
		if ( (Enemy != None) && (Enemy == InstigatedBy) )
		{
			LastSeenPos = Enemy.Location;
			LastSeenTime = Level.TimeSeconds;
		}
		if (NextState == 'TakeHit')
		{
			NextState = 'Attacking'; 
			NextLabel = 'Begin';
			GotoState('TakeHit'); 
		}
		else if ( Enemy != None )
			GotoState('Attacking');
	}
	
	function HandleHelpMessageFrom(Pawn Other)
	{
		if ( (Health > 70) && (Weapon.AIRating > 0.5) && (Other.Enemy != None)
			&& ((Other.bIsPlayer && (Other.PlayerReplicationInfo.Team == PlayerReplicationInfo.Team)))
			//	|| (Other.IsA('StationaryPawn') && StationaryPawn(Other).SameTeamAs(PlayerReplicationInfo.Team)))
			&& (VSize(Other.Enemy.Location - Location) < 800) )
			{
				if ( Other.bIsPlayer )
					SendTeamMessage(Other.PlayerReplicationInfo, 'OTHER', 10, 10);
				SetEnemy(Other.Enemy);
				GotoState('Attacking');
			}
	}

	function FearThisSpot(Actor aSpot)
	{
		Destination = Location + 120 * Normal(Location - aSpot.Location); 
		GotoState('Wandering', 'Moving');
	}
	
	function Timer()
	{
		bReadyToAttack = True;
		Enable('Bump');
	}

	function SetFall()
	{
		NextState = 'Hold'; 
		NextLabel = 'Landed';
		NextAnim = AnimSequence;
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
			if ( SpecialPause > 0 )
				Acceleration = vect(0,0,0);
			GotoState('Hold', 'SpecialNavig');
			return;
		}
		Focus = Destination;
		if (PickWallAdjust())
		{
			if ( Physics == PHYS_Falling )
				SetFall();
			else
				GotoState('Hold', 'AdjustFromWall');
		}
		else
			MoveTimer = -1.0;
	}
	
	function PickDestination()
	{
		local Vector Direction;

		if ( (HoldSpot(OrderObject) == None) )
		{
			SetOrders('Freelance', None);
			GotoState('Roaming');
		} 
		Direction = Location - OrderObject.Location;
		if ( (Direction.X * Direction.X + Direction.Y * Direction.Y < 256) 
			&& (Abs(Direction.Z) < 48) )
		{
			SendTeamMessage(None, 'OTHER', 9, 45);
			if ( !bInitLifeMessage )
			{
				bInitLifeMessage = true;
				PlayWaving();
			}
			else
				TweenToWaiting(0.25);
			GotoState('Holding', 'Waving');
			return;
		}
		if ( ActorReachable(OrderObject) )
		{
			if ( HoldSpot(OrderObject).Holder != None )
				GotoState('Wandering');
			MoveTarget = OrderObject;
			return;
		}
		MoveTarget = FindPathToward(OrderObject);
		if ( MoveTarget == None ) 
		{
			SetOrders('Freelance', None);
			GotoState('Roaming');
		} 
	}

	function AnimEnd()
	{
		PlayRunning();
	}
 
	function Landed(vector HitNormal)
	{
		SetPhysics(PHYS_None);
	}

	function BeginState()
	{
		SpecialGoal = None;
		SpecialPause = 0.0;
		bSpecialGoal = false;
	}

TurnFromWall:
	if ( NearWall(2 * CollisionRadius + 50) )
	{
		PlayTurning();
		TurnTo(Focus);
	}
Begin:
	SwitchToBestWeapon();
	TweenToRunning(0.1);
	WaitForLanding();
	
RunAway:
	PickDestination();
SpecialNavig:
	if (SpecialPause > 0.0)
	{
		Disable('AnimEnd');
		Acceleration = vect(0,0,0);
		TweenToPatrolStop(0.3);
		Sleep(SpecialPause);
		SpecialPause = 0.0;
		Enable('AnimEnd');
		TweenToRunning(0.1);
		Goto('RunAway');
	}
Moving:
	if ( !IsAnimating() )
		AnimEnd();
	if ( MoveTarget == None )
	{
		Acceleration = vect(0,0,0);
		Sleep(0.1);
		Goto('RunAway');
	}
	MoveToward(MoveTarget);
	Goto('RunAway');


TakeHit:
	TweenToRunning(0.12);
	Goto('Moving');

Landed:
	if ( MoveTarget == None )
		Goto('RunAway');
	Goto('Moving');

AdjustFromWall:
	if ( !IsAnimating() )
		AnimEnd();
	bCamping = false;
	StrafeTo(Destination, Focus); 
	Destination = Focus; 
	MoveTo(Destination);
	Goto('Moving');
}

state Roaming
{
	ignores EnemyNotVisible;

	function SetOrders(name NewOrders, Pawn OrderGiver, optional bool bNoAck)
	{
		Global.SetOrders(NewOrders, OrderGiver, bNoAck);
		if ( bCamping && ((Orders == 'Hold') || (Orders == 'Follow')) )
			GotoState('Roaming', 'PreBegin');
	}

	function HearPickup(Pawn Other)
	{
		if ( bNovice || (Skill < 4 * FRand() - 1) )
			return;
		if ( (Health > 70) && (Weapon.AiRating > 0.6) 
			&& (RelativeStrength(Other) < 0) )
			HearNoise(0.5, Other);
	}
				
	function ShootTarget(Actor NewTarget)
	{
		Target = NewTarget;
		bFiringPaused = true;
		SpecialPause = 2.0;
		NextState = GetStateName();
		NextLabel = 'Begin';
		GotoState('RangedAttack');
	}

	function MayFall()
	{
		bCanJump = ( (MoveTarget != None) 
					&& ((MoveTarget.Physics != PHYS_Falling) || !MoveTarget.IsA('Inventory')) );
	}
	
	function HandleHelpMessageFrom(Pawn Other)
	{
		if ( (Health > 70) && (Weapon.AIRating > 0.5) && (Other.Enemy != None)
			&& ((Other.bIsPlayer && (Other.PlayerReplicationInfo.Team == PlayerReplicationInfo.Team)))
			//	|| (Other.IsA('StationaryPawn') && StationaryPawn(Other).SameTeamAs(PlayerReplicationInfo.Team)))
			&& (VSize(Other.Enemy.Location - Location) < 800) )
		{
			if ( Other.bIsPlayer )
				SendTeamMessage(Other.PlayerReplicationInfo, 'OTHER', 10, 10);
			SetEnemy(Other.Enemy);
			GotoState('Attacking');
		}
	}

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
							Vector momentum, name damageType)
	{
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 )
			return;
		if (NextState == 'TakeHit')
		{
			NextState = 'Attacking'; 
			NextLabel = '';
			GotoState('TakeHit'); 
		}
		else if ( !bCanFire && (skill > 3 * FRand()) )
			GotoState('Attacking');
	}

	function FearThisSpot(Actor aSpot)
	{
		Destination = Location + 120 * Normal(Location - aSpot.Location); 
		GotoState('Wandering', 'Moving');
	}
	
	function Timer()
	{
		bReadyToAttack = True;
		Enable('Bump');
	}

	function SetFall()
	{
		bWallAdjust = false;
		NextState = 'Roaming'; 
		NextLabel = 'Landed';
		NextAnim = AnimSequence;
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
			if ( SpecialPause > 0 )
				Acceleration = vect(0,0,0);
			GotoState('Roaming', 'SpecialNavig');
			return;
		}
		Focus = Destination;
		if ( !bWallAdjust && PickWallAdjust() )
		{
			if ( Physics == PHYS_Falling )
				SetFall();
			else
				GotoState('Roaming', 'AdjustFromWall');
		}
		else
		{
			MoveTimer = -1.0;
			bWallAdjust = false;
		}
	}

	function PickDestination()
	{
		local inventory Inv, BestInv;
		local float Bestweight, NewWeight, DroppedDist;
		local actor BestPath;
		local decoration Dec;
		local NavigationPoint N;
		local int i;
		local bool bTriedToPick, bLockedAndLoaded, bNearPoint;
		local byte TeamPriority;
		local Pawn P;

		bCanTranslocate = ( Level.Game.IsA('DeathMatchPlus') && DeathMatchPlus(Level.Game).CanTranslocate(self) );
		if ( Level.Game.IsA('TeamGamePlus') )
		{
			if ( (Orders == 'FreeLance') && !bStayFreelance
				 &&	(Orders != BotReplicationInfo(PlayerReplicationInfo).RealOrders) ) 
				SetOrders(BotReplicationInfo(PlayerReplicationInfo).RealOrders, BotReplicationInfo(PlayerReplicationInfo).RealOrderGiver, true);
			if ( FRand() < 0.5 )
				bStayFreelance = false;
			LastAttractCheck = Level.TimeSeconds - 0.1;
			if ( TeamGamePlus(Level.Game).FindSpecialAttractionFor(self) )
			{
				if ( IsInState('Roaming') )
				{
					TeamPriority = TeamGamePlus(Level.Game).PriorityObjective(self);
					if ( TeamPriority > 16 )
					{
						PickLocalInventory(160, 1.8);
						return;
					}
					else if ( TeamPriority > 1 )
					{
						PickLocalInventory(200, 1);
						return;
					}
					else if ( TeamPriority > 0 )
					{
						PickLocalInventory(280, 0.55);
						return;
					}
					PickLocalInventory(400, 0.5);
				}
				return;
			}
		}
		bLockedAndLoaded = ( (Weapon.AIRating > 0.4) && (Health > 60) );

		if (  Orders == 'Follow' )
		{
			if ( Pawn(OrderObject) == None )
				SetOrders('FreeLance', None);
			else if ( (Pawn(OrderObject).Health > 0) )
			{
				bNearPoint = CloseToPointMan(Pawn(OrderObject));
				if ( !bNearPoint )
				{
					if ( !bLockedAndLoaded )
					{
						bTriedToPick = true;
						if ( PickLocalInventory(600, 0) )
							return;

						if ( !OrderObject.IsA('PlayerPawn') )
						{
							BestWeight = 0;
							BestPath = FindBestInventoryPath(BestWeight, !bNovice && (skill >= 2));
							if ( BestPath != None )
							{
								MoveTarget = BestPath;
								return;
							}
						}
					}				
					if ( ActorReachable(OrderObject) )
						MoveTarget = OrderObject;
					else
						MoveTarget = FindPathToward(OrderObject);
					if ( (MoveTarget != None) && (VSize(Location - MoveTarget.Location) > 2 * CollisionRadius) )
						return;
					if ( (VSize(OrderObject.Location - Location) < 1600) && LineOfSightTo(OrderObject) )
						bNearPoint = true;
					if ( bVerbose )
						log(self$" found no path to "$OrderObject);
				}
				else if ( !bInitLifeMessage && (Pawn(OrderObject).Health > 0) 
							&& (VSize(Location - OrderObject.Location) < 500) )
				{
					bInitLifeMessage = true;
					SendTeamMessage(Pawn(OrderObject).PlayerReplicationInfo, 'OTHER', 3, 10);
				}
			}
		}
		if ( (Orders == 'Defend') && bLockedAndLoaded )
		{
			if ( PickLocalInventory(300, 0.55) )
				return;
			if ( FindAmbushSpot() ) 
				return;
			if ( !LineOfSightTo(OrderObject) )
			{
				MoveTarget = FindPathToward(OrderObject);
				if ( MoveTarget != None )
					return;
			}
			else if ( !bInitLifeMessage )
			{
				bInitLifeMessage = true;
				SendTeamMessage(None, 'OTHER', 9, 10);
			}
		}

		if ( (Orders == 'Hold') && bLockedAndLoaded && !LineOfSightTo(OrderObject) )
		{
			GotoState('Hold');
			return;
		}

		if ( !bTriedToPick && PickLocalInventory(600, 0) )
			return;

		if ( (Orders == 'Hold') && bLockedAndLoaded )
		{
			if ( VSize(Location - OrderObject.Location) < 20 )
				GotoState('Holding');
			else
				GotoState('Hold');
			return;
		}

		if ( ((Orders == 'Follow') && (bNearPoint || (Level.Game.IsA('TeamGamePlus') && TeamGamePlus(Level.Game).WaitForPoint(self))))
			|| ((Orders == 'Defend') && bLockedAndLoaded && LineOfSightTo(OrderObject)) )
		{
			if ( FRand() < 0.35 )
				GotoState('Wandering');
			else
			{
				CampTime = 0.8;
				GotoState('Roaming', 'Camp');
			}
			return;
		}

		if ( (OrderObject != None) && !OrderObject.IsA('Ambushpoint') )
			bWantsToCamp = false;
		else if ( (Weapon.AIRating > 0.5) && (Health > 90) && !Region.Zone.bWaterZone )
		{
			bWantsToCamp = ( bWantsToCamp || (FRand() < CampingRate * FMin(1.0, Level.TimeSeconds - LastCampCheck)) );
			LastCampCheck = Level.TimeSeconds;
		}
		else 
			bWantsToCamp = false;

		if ( bWantsToCamp && FindAmbushSpot() )
			return;

		// if none found, check for decorations with inventory
		if ( !bNoShootDecor )
			foreach visiblecollidingactors(class'Decoration', Dec, 500,,true)
				if ( Dec.Contents != None )
				{
					bNoShootDecor = true;
					Target = Dec;
					GotoState('Roaming', 'ShootDecoration');
					return;
				}

		bNoShootDecor = false;
		BestWeight = 0;

		// look for long distance inventory 
		BestPath = FindBestInventoryPath(BestWeight, !bNovice && (skill >= 2));
		//log("roam to"@BestPath);
		//log("---------------------------------");
		if ( BestPath != None )
		{
			MoveTarget = BestPath;
			return;
		}

		// nothing around - maybe just wait a little
		if ( (FRand() < 0.35) && bNovice 
			&& (!Level.Game.IsA('DeathMatchPlus') || !DeathMatchPlus(Level.Game).OneOnOne())  )
		{
			GoalString = " Nothing cool, so camp ";
			CampTime = 3.5 + FRand() - skill;
			GotoState('Roaming', 'Camp');
		}

		// if roamed to ambush point, stay there maybe
		if ( (AmbushPoint(RoamTarget) != None)
			&& (VSize(Location - RoamTarget.Location) < 2 * CollisionRadius)
			&& (FRand() < 0.4) )
		{
			CampTime = 4.0;
			GotoState('Roaming', 'LongCamp');
			return;
		}

		// hunt player
		if ( (!bNovice || (Level.Game.IsA('DeathMatchPlus') && DeathMatchPlus(Level.Game).OneOnOne()))
			&& (Weapon.AIRating > 0.5) && (Health > 60) )
		{
			if ( (PlayerPawn(RoamTarget) != None) && !LineOfSightTo(RoamTarget) )
			{
				BestPath = FindPathToward(RoamTarget);
				if ( BestPath != None )
				{
					MoveTarget = BestPath;
					return;
				}
			}
			else
			{
				// high skill bots go hunt player
				for ( P=Level.PawnList; P!=None; P=P.NextPawn )
					if ( P.bIsPlayer && P.IsA('PlayerPawn') 
						&& ((VSize(P.Location - Location) > 1500) || !LineOfSightTo(P)) )
					{
						BestPath = FindPathToward(P);
						if ( BestPath != None )
						{
							RoamTarget = P;
							MoveTarget = BestPath;
							return;
						}
					}
			}
			bWantsToCamp = true; // don't camp if couldn't go to player
		}
		
		// look for ambush spot if didn't already try
		if ( !bWantsToCamp && FindAmbushSpot() )
		{
			RoamTarget = AmbushSpot;
			return;
		}
		
		// find a roamtarget
		if ( RoamTarget == None )
		{
			i = 0;
			for ( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
				if ( N.IsA('InventorySpot') )
				{
					i++;
					if ( (RoamTarget == None) || (Rand(i) == 0) )
						RoamTarget = N;
				}
		}	

		// roam around
		if ( RoamTarget != None )
		{
			if ( ActorReachable(RoamTarget) )
			{
				MoveTarget = RoamTarget;
				RoamTarget = None;
				if ( VSize(MoveTarget.Location - Location) > 2 * CollisionRadius )
					return;
			}
			else
			{
				BestPath = FindPathToward(RoamTarget);
				if ( BestPath != None )
				{
					MoveTarget = BestPath;
					return;
				}
				else
					RoamTarget = None;
			}
		}
												
		 // wander or camp
		if ( FRand() < 0.35 )
			GotoState('Wandering');
		else
		{
			GoalString = " Nothing cool, so camp ";
			CampTime = 3.5 + FRand() - skill;
			GotoState('Roaming', 'Camp');
		}
	}

	function AnimEnd() 
	{
		if ( bCamping )
		{
			SetPeripheralVision();
			if ( FRand() < 0.2 )
			{
				PeripheralVision -= 0.5;
				PlayLookAround();
			}
			else
				PlayWaiting();
		}
		else
			PlayRunning();
	}

	function ShareWith(Pawn Other)
	{
		local bool bHaveItem, bIsHealth, bOtherHas, bIsWeapon;
		local Pawn P;

		if ( MoveTarget.IsA('Weapon') )
		{
			if ( (Weapon == None) || (Weapon.AIRating < 0.5) || Weapon(MoveTarget).bWeaponStay )
				return;
			bIsWeapon = true;
			bHaveItem = (FindInventoryType(MoveTarget.class) != None);
		}
		else if ( MoveTarget.IsA('Health') )
		{
			bIsHealth = true;
			if ( Health < 80 )
				return;
		}

		if ( (Other.Health <= 0) || Other.PlayerReplicationInfo.bIsSpectator || (VSize(Other.Location - Location) > 1250)
			|| !LineOfSightTo(Other) )
			return;

		//decide who needs it more
		CampTime = 2.0;
		if ( bIsHealth )
		{
			if ( Health > Other.Health + 10 )
			{
				GotoState('Roaming', 'GiveWay');
				return;
			}
		}
		else if ( bIsWeapon && (Other.Weapon != None) && (Other.Weapon.AIRating < 0.5) )
		{
			GotoState('Roaming', 'GiveWay');
			return;
		}
		else
		{
			bOtherHas = (Other.FindInventoryType(MoveTarget.class) != None);
			if ( bHaveItem && !bOtherHas )
			{
				GotoState('Roaming', 'GiveWay');
				return;
			}
		}
	}
						 
	function BeginState()
	{
		bNoShootDecor = false;
		bCanFire = false;
		bCamping = false;
		if ( bNoClearSpecial )
			bNoClearSpecial = false;
		else
		{
			bSpecialPausing = false;
			bSpecialGoal = false;
			SpecialGoal = None;
			SpecialPause = 0.0;
		}
	}

	function EndState()
	{
		SetPeripheralVision();
		if ( !bSniping && (AmbushSpot != None) )
		{
			AmbushSpot.taken = false;
			AmbushSpot = None;
		}
		bCamping = false;
		bWallAdjust = false;
		bCanTranslocate = false;
	}

LongCamp:
	bCamping = true;
	Acceleration = vect(0,0,0);
	TweenToWaiting(0.15);
	TurnTo(Location + Ambushspot.lookdir);
	Sleep(CampTime);
	Goto('PreBegin');

GiveWay:	
	//log("sharing");	
	bCamping = true;
	Acceleration = vect(0,0,0);
	if ( GetAnimGroup(AnimSequence) != 'Waiting' )
		TweenToWaiting(0.15);
	if ( NearWall(200) )
	{
		PlayTurning();
		TurnTo(MoveTarget.Location);
	}
	Sleep(CampTime);
	Goto('PreBegin');

Camp:
	bCamping = true;
	Acceleration = vect(0,0,0);
	TweenToWaiting(0.15);
ReCamp:
	if ( NearWall(200) )
	{
		PlayTurning();
		TurnTo(Focus);
	}
	Sleep(CampTime);
	if ( bLeading || bCampOnlyOnce )
	{
		bCampOnlyOnce = false;
		Goto('PreBegin');
	}
	if ( ((Orders != 'Follow') || ((Pawn(OrderObject).Health > 0) && CloseToPointMan(Pawn(OrderObject)))) 
		&& (Weapon != None) && (Weapon.AIRating > 0.4) && (3 * FRand() > skill + 1) )
		Goto('ReCamp');
PreBegin:
	SetPeripheralVision();
	WaitForLanding();
	bCamping = false;
	PickDestination();
	TweenToRunning(0.1);
	bCanTranslocate = false;
	Goto('SpecialNavig');
Begin:
	SwitchToBestWeapon();
	bCamping = false;
	TweenToRunning(0.1);
	WaitForLanding();
	
RunAway:
	PickDestination();
	bCanTranslocate = false;
SpecialNavig:
	if (SpecialPause > 0.0)
	{
		Disable('AnimEnd');
		Acceleration = vect(0,0,0);
		TweenToPatrolStop(0.3);
		Sleep(SpecialPause);
		SpecialPause = 0.0;
		Enable('AnimEnd');
		TweenToRunning(0.1);
		Goto('RunAway');
	}
Moving:
	if ( !IsAnimating() )
		AnimEnd();
	if ( MoveTarget == None )
	{
		Acceleration = vect(0,0,0);
		Sleep(0.0);
		Goto('RunAway');
	}
	if ( MoveTarget.IsA('InventorySpot') )
	{
		if ( (!Level.Game.IsA('TeamGamePlus') || (TeamGamePlus(Level.Game).PriorityObjective(self) == 0))
			&& (InventorySpot(MoveTarget).markedItem != None)
			&& (InventorySpot(MoveTarget).markedItem.BotDesireability(self) > 0) )
		{
			if ( InventorySpot(MoveTarget).markedItem.GetStateName() == 'Pickup' )
				MoveTarget = InventorySpot(MoveTarget).markedItem;
			else if (	(InventorySpot(MoveTarget).markedItem.LatentFloat < 5.0)
						&& (InventorySpot(MoveTarget).markedItem.GetStateName() == 'Sleeping')	
						&& (abs(Location.Z - MoveTarget.Location.Z) < CollisionHeight)
						&& (VSize(Location - MoveTarget.Location + vect(0,0,1) * (MoveTarget.Location.Z - Location.Z)) < CollisionRadius * CollisionRadius) )
			{
				CampTime = FMin(5, InventorySpot(MoveTarget).markedItem.LatentFloat + 0.5);
				bCampOnlyOnce = true;
				Goto('Camp');
			}
		}
		else if ( MoveTarget.IsA('TrapSpringer')
				&& (abs(Location.Z - MoveTarget.Location.Z) < CollisionHeight)
				&& (VSize(Location - MoveTarget.Location + vect(0,0,1) * (MoveTarget.Location.Z - Location.Z)) < CollisionRadius * CollisionRadius) )
		{
			PlayVictoryDance();	
			bCampOnlyOnce = true;		
			bCamping = true;
			CampTime = 1.2;
			Acceleration = vect(0,0,0);
			Goto('ReCamp');
		}
	}
	else if ( MoveTarget.IsA('Inventory') && Level.Game.bTeamGame )
	{
		if ( Orders == 'Follow' )
			ShareWith(Pawn(OrderObject));
		else if ( SupportingPlayer != None )
			ShareWith(SupportingPlayer);
	}

	bCamping = false;
	MoveToward(MoveTarget);
	Goto('RunAway');

TakeHit:
	TweenToRunning(0.12);
	Goto('Moving');

Landed:
	if ( MoveTarget == None ) 
		Goto('RunAway');
	Goto('Moving');

AdjustFromWall:
	if ( !IsAnimating() )
		AnimEnd();
	bWallAdjust = true;
	bCamping = false;
	StrafeTo(Destination, Focus); 
	Destination = Focus; 
	MoveTo(Destination);
	bWallAdjust = false;
	Goto('Moving');

ShootDecoration:
	TurnToward(Target);
	if ( Target != None )
	{
		FireWeapon();
		bAltFire = 0;
		bFire = 0;
	}
	Goto('RunAway');
}

state Wandering
{
	ignores EnemyNotVisible;

	function bool DeferTo(Bot Other)
	{
		if ( Acceleration == vect(0,0,0) )
			return Global.DeferTo(Other);

		return false;
	}

	function SetOrders(name NewOrders, Pawn OrderGiver, optional bool bNoAck)
	{
		Global.SetOrders(NewOrders, OrderGiver, bNoAck);
		if ( (Orders == 'Hold') || (Orders == 'Follow') )
			GotoState('Roaming');
	}

	singular event BaseChange()
	{
		if ( (Base != None) && Base.IsA('Mover') )
			Destination = Location - 300 * Normal(Velocity);
		else
			Super.BaseChange();
	}

	function ShootTarget(Actor NewTarget)
	{
		Target = NewTarget;
		bFiringPaused = true;
		SpecialPause = 2.0;
		NextState = GetStateName();
		NextLabel = 'Begin';
		GotoState('RangedAttack');
	}

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, name damageType)
	{
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 )
			return;
		if ( (Enemy != None) && (Enemy == InstigatedBy) )
		{
			LastSeenPos = Enemy.Location;
			LastSeenTime = Level.TimeSeconds;
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

	function Timer()
	{
		Enable('Bump');
	}

	function SetFall()
	{
		NextState = 'Wandering'; 
		NextLabel = 'ContinueWander';
		NextAnim = AnimSequence;
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
			if ( SpecialPause > 0 )
				Acceleration = vect(0,0,0);
			GotoState('Wandering', 'Pausing');
			return;
		}
		Focus = Destination;
		if ( PickWallAdjust() && (FRand() < 0.7) )
		{
			if ( Physics == PHYS_Falling )
				SetFall();
			else
				GotoState('Wandering', 'AdjustFromWall');
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
			GotoState('Wandering', 'Turn');

		WanderDir = vect(0,0,0);
	}

	function AnimEnd()
	{
		PlayPatrolStop();
	}

	function FearThisSpot(Actor aSpot)
	{
		Destination = Location + 120 * Normal(Location - aSpot.Location); 
	}

	function BeginState()
	{
		Enemy = None;
		SetAlertness(0.2);
		bReadyToAttack = false;
		Disable('AnimEnd');
		NextAnim = '';
		bCanJump = false;
		bAvoidLedges = true;
		bStopAtLedges = true;
		MinHitWall += 0.15;
	}
	
	function EndState()
	{
		MinHitWall -= 0.15;
		bStopAtLedges = false;
		bAvoidLedges = false;
		if (JumpZ > 0)
			bCanJump = true;
	}


Begin:
	//log(class$" Wandering");

Wander: 
	WaitForLanding();
	PickDestination();
	TweenToWalking(0.15);
	FinishAnim();
	PlayWalking();
	
Moving:
	Enable('HitWall');
	MoveTo(Destination, WalkingSpeed);
Pausing:
	if ( Level.Game.bTeamGame 
		&& (bLeading || ((Orders == 'Follow') && !CloseToPointMan(Pawn(OrderObject)))) )
		GotoState('Roaming');
	Acceleration = vect(0,0,0);
	if ( NearWall(200) )
	{
		PlayTurning();
		TurnTo(Focus);
	}
	Enable('AnimEnd');
	NextAnim = '';
	TweenToPatrolStop(0.2);
	Sleep(1.0);
	Disable('AnimEnd');
	FinishAnim();
	GotoState('Roaming');

ContinueWander:
	FinishAnim();
	PlayWalking();
	if (FRand() < 0.2)
		Goto('Turn');
	Goto('Wander');

Turn:
	Acceleration = vect(0,0,0);
	PlayTurning();
	TurnTo(Location + 20 * VRand());
	Goto('Pausing');

AdjustFromWall:
	StrafeTo(Destination, Focus); 
	Destination = Focus; 
	Goto('Moving');
}
	
/* Acquisition - 
Creature has just reacted to stimulus, and set an enemy
- depending on strength of stimulus, and ongoing stimulii, vary time to focus on target and start attacking (or whatever.  FIXME - need some acquisition specific animation
HearNoise and SeePlayer used to improve/change stimulus
*/

state Acquisition
{
ignores falling, landed; 

	function WarnTarget(Pawn shooter, float projSpeed, vector FireDir)
	{
	}

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
							Vector momentum, name damageType)
	{
		LastSeenPos = Enemy.Location;
		LastSeenTime = Level.TimeSeconds;
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 )
			return;
		if (NextState == 'TakeHit')
		{
			NextState = 'Attacking'; 
			NextLabel = 'Begin';
			GotoState('TakeHit'); 
		}
		else
			GotoState('Attacking');
	}
	
	singular function HearNoise(float Loudness, Actor NoiseMaker)
	{
		local vector OldLastSeenPos;
		
		if ( SetEnemy(NoiseMaker.instigator) )
		{
			OldLastSeenPos = LastSeenPos;
			if ( Enemy ==  NoiseMaker.instigator  )
				LastSeenPos = 0.5 * (NoiseMaker.Location + VSize(NoiseMaker.Location - Location) * vector(Rotation));
			else if ( (Pawn(NoiseMaker) != None) && (Enemy == Pawn(NoiseMaker).Enemy) )
				LastSeenPos = 0.5 * (Pawn(NoiseMaker).Enemy.Location + VSize(Pawn(NoiseMaker).Enemy.Location - Location) * vector(Rotation));
			if ( VSize(OldLastSeenPos - Enemy.Location) < VSize(LastSeenPos - Enemy.Location) )
				LastSeenPos = OldLastSeenPos;				
		}
		
	}
	
	function SeePlayer(Actor SeenPlayer)
	{
		if ( SetEnemy(Pawn(SeenPlayer)) )
		{
			MakeNoise(1.0);
			NextAnim = '';
			GotoState('Attacking');
		}
	} 
	
	function BeginState()
	{
		Disable('Tick'); //only used for bounding anim time
		SetAlertness(-0.5);
	}

	function EndState()
	{
		LastAcquireTime = Level.TimeSeconds;
	}
		
PlayOut:
	Acceleration = vect(0,0,0);
	if ( (AnimFrame < 0.6) && IsAnimating() )
	{
		Sleep(0.05);
		Goto('PlayOut');
	}
		
Begin:
	Acceleration = vect(0,0,0);
	if (NeedToTurn(LastSeenPos))
	{	
		PlayTurning();
		TurnTo(LastSeenPos);
	}
	DesiredRotation = Rotator(LastSeenPos - Location);
	TweenToFighter(0.2); 
	FinishAnim();
	if ( Enemy == None )
		WhatToDoNext('','');	
	if ( Enemy.IsA('StationaryPawn') )
		GotoState('Attacking');
	////log("Stimulus="$Stimulus);
	if ( AttitudeTo(Enemy) == ATTITUDE_Fear )  //will run away from noise
	{
		LastSeenPos = Enemy.Location; 
		NextAnim = '';
		GotoState('Attacking');
	}
	else if ( !bNovice )
	{
		bMustHunt = true;
		GotoState('Attacking');
	}
	else
		WhatToDoNext('','');
}

/* Attacking
Master attacking state - choose which type of attack to do from here
*/
state Attacking
{
ignores SeePlayer, HearNoise, Bump, HitWall;

	function ChooseAttackMode()
	{
		local eAttitude AttitudeToEnemy;
		local float Aggression;
		local pawn changeEn;
		local TeamGamePlus TG;
		local bool bWillHunt;

		bWillHunt = bMustHunt;
		bMustHunt = false;
		if ((Enemy == None) || (Enemy.Health <= 0))
		{
			WhatToDoNext('','');
			return;
		}
		if ( Weapon == None )
		{
			log(self$" health "$health$" had no weapon");
			SwitchToBestWeapon();
		}
		AttitudeToEnemy = AttitudeTo(Enemy);
		TG = TeamGamePlus(Level.Game);
		if ( TG != None )
		{
			if ( (Level.TimeSeconds - LastAttractCheck > 0.5)
				|| (AttitudeToEnemy == ATTITUDE_Fear)
				|| (TG.PriorityObjective(self) > 1) ) 
			{
				goalstring = "attract check";
				if ( TG.FindSpecialAttractionFor(self) )
					return;
				if ( Enemy == None )
				{
					WhatToDoNext('','');
					return;
				}
			}
			else
			{
				goalstring = "no attract check";
			}
		}
			
		if (AttitudeToEnemy == ATTITUDE_Fear)
		{
			GotoState('Retreating');
			return;
		}
		else if (AttitudeToEnemy == ATTITUDE_Friendly)
		{
			WhatToDoNext('','');
			return;
		}
		else if ( !LineOfSightTo(Enemy) )
		{
			if ( (OldEnemy != None) 
				&& (AttitudeTo(OldEnemy) == ATTITUDE_Hate) && LineOfSightTo(OldEnemy) )
			{
				changeEn = enemy;
				enemy = oldenemy;
				oldenemy = changeEn;
			}	
			else 
			{
				goalstring = "attract check";
				if ( (TG != None) && TG.FindSpecialAttractionFor(self) )
					return;
				if ( Enemy == None )
				{
					WhatToDoNext('','');
					return;
				}
				if ( (Orders == 'Hold') && (Level.TimeSeconds - LastSeenTime > 5) )
				{
					NumHuntPaths = 0; 
					GotoState('StakeOut');
				}
				else if ( bWillHunt || (!bSniping && (VSize(Enemy.Location - Location) 
							> 600 + (FRand() * RelativeStrength(Enemy) - CombatStyle) * 600)) )
				{
					bDevious = ( !bNovice && !Level.Game.bTeamGame && Level.Game.IsA('DeathMatchPlus') 
								&& (FRand() < 0.52 - 0.12 * DeathMatchPlus(Level.Game).NumBots) );
					GotoState('Hunting');
				}
				else
				{
					NumHuntPaths = 0; 
					GotoState('StakeOut');
				}
				return;
			}
		}	
		
		if (bReadyToAttack)
		{
			////log("Attack!");
			Target = Enemy;
			SetTimer(TimeBetweenAttacks, False);
		}
			
		GotoState('TacticalMove');
	}
	
	//EnemyNotVisible implemented so engine will update LastSeenPos
	function EnemyNotVisible()
	{
		////log("enemy not visible");
	}

	function Timer()
	{
		bReadyToAttack = True;
	}

	function BeginState()
	{
		if ( TimerRate <= 0.0 )
			SetTimer(TimeBetweenAttacks  * (1.0 + FRand()),false); 
		if (Physics == PHYS_None)
			SetMovementPhysics(); 
	}

Begin:
	//log(class$" choose Attack");
	ChooseAttackMode();
}


/* Retreating for a bot is going toward an item while still engaged with an enemy, but fearing that enemy (so
no desire to remain engaged)
   TacticalGet is for going to an item while engaged, and remaining engaged. TBD
   Roaming is going to items w/ no enemy. TBD
*/

state Retreating
{
ignores EnemyNotVisible;

	function MayFall()
	{
		bAdvancedTactics = false;
		if ( bCanFire ) // MoveTarget is player, not destination
			bCanJump = ( (MoveTarget != None) 
						&& ((MoveTarget.Physics != PHYS_Falling) || !MoveTarget.IsA('Inventory')) );
	}

	function WarnTarget(Pawn shooter, float projSpeed, vector FireDir)
	{	
		if ( bCanFire && (FRand() < 0.4) ) 
			return;

		Super.WarnTarget(shooter, projSpeed, FireDir);
	}

	function SeePlayer(Actor SeenPlayer)
	{
		if ( (SeenPlayer == Enemy) || LineOfSightTo(Enemy) )
		{
			LastSeenTime = Level.TimeSeconds;
			return;
		}
		if ( SetEnemy(Pawn(SeenPlayer)) )
		{
			MakeNoise(1.0);
			GotoState('Attacking');
		}
	}

	singular function HearNoise(float Loudness, Actor NoiseMaker)
	{
		if ( (NoiseMaker.instigator == Enemy) || LineOfSightTo(Enemy) )
			return;

		if ( SetEnemy(NoiseMaker.instigator) )
		{
			MakeNoise(1.0);
			GotoState('Attacking');
		}
	}
	
	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
							Vector momentum, name damageType)
	{
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 )
			return;
		if (NextState == 'TakeHit')
		{
			NextState = 'Retreating'; 
			NextLabel = 'TakeHit';
			GotoState('TakeHit'); 
		}
		else if ( !bCanFire && (skill > 3 * FRand()) )
			GotoState('Retreating', 'Moving');
	}

	function Timer()
	{
		bReadyToAttack = True;
		Enable('Bump');
	}
	
	function SetFall()
	{
		NextState = 'Retreating'; 
		NextLabel = 'Landed';
		NextAnim = AnimSequence;
		GotoState('FallingState'); 
	}

	function HitWall(vector HitNormal, actor Wall)
	{
		if (Physics == PHYS_Falling)
			return;
		if ( Wall.IsA('Mover') && Mover(Wall).HandleDoor(self) )
		{
			if ( SpecialPause > 0 )
				Acceleration = vect(0,0,0);
			GotoState('Retreating', 'SpecialNavig');
			return;
		}
		bTacticalDir = !bTacticalDir;
		Focus = Destination;
		if ( PickWallAdjust() && (FRand() < 0.7) )
		{
			bAdvancedTactics = false;
			if ( Physics == PHYS_Falling )
				SetFall();
			else
				GotoState('Retreating', 'AdjustFromWall');
		}
		else
			MoveTimer = -1.0;
	}

	function PickDestination()
	{
	 	local inventory Inv, BestInv, SecondInv;
		local float Bestweight, NewWeight, invDist, MaxDist, SecondWeight;
		local actor BestPath;
		local bool bTriedFar;

		if ( !bReadyToAttack && (TimerRate == 0.0) )
			SetTimer(0.7, false);

		// do I still fear my enemy?
		if ( (Level.TimeSeconds - LastSeenTime > 12)
			|| (Level.Game.bTeamGame && (Level.TimeSeconds - LastSeenTime > 8)) )
			Enemy = None;
		if ( (Enemy == None) || (AttitudeTo(Enemy) > ATTITUDE_Fear) )
		{
			GotoState('Attacking');
			return;
		}

		bestweight = 0;

		//first look at nearby inventory < 500 dist
		MaxDist = 500 + 70 * skill;
		foreach visiblecollidingactors(class'Inventory', Inv, MaxDist,,true)
			if ( (Inv.IsInState('PickUp')) && (Inv.MaxDesireability/200 > BestWeight)
				&& (Inv.Location.Z < Location.Z + MaxStepHeight + CollisionHeight)
				&& (Inv.Location.Z > FMin(Location.Z, Enemy.Location.Z) - CollisionHeight) )
			{
				NewWeight = inv.BotDesireability(self)/VSize(Inv.Location - Location);
				if ( NewWeight > BestWeight )
				{
					SecondWeight = BestWeight;
					BestWeight = NewWeight;
					SecondInv = BestInv;
					BestInv = Inv;
				}
			}
			 
		 // see if better long distance inventory 
		if ( BestWeight < 0.001 )
		{ 
			bTriedFar = true;
			BestPath = FindBestInventoryPath(BestWeight, false);
			if ( Level.Game.bTeamGame && (BestWeight < 0.0002) )
			{
				if ( !Enemy.IsA('TeamCannon') && (Enemy.Location.Z < Location.Z + 500) )
				{
					bKamikaze = true;
					if ( LineOfSightTo(Enemy) )
					{
						LastInvFind = Level.TimeSeconds;
						GotoState('TacticalMove', 'NoCharge');
						return;
					}
				}
				else if ( Level.Game.IsA('TeamGamePlus') && TeamGamePlus(Level.Game).SendBotToGoal(self) )
					return;
			}
			if ( BestPath != None )
			{
				//GoalString = string(1000 * BestWeight);
				MoveTarget = BestPath;
				return;
			}
		}

		if ( (BestInv != None) && ActorReachable(BestInv) )
		{
			MoveTarget = BestInv;
			return;
		}

		if ( (SecondInv != None) && ActorReachable(SecondInv) )
		{
			MoveTarget = SecondInv;
			return;
		}
		if ( !bTriedFar )
		{ 
			BestWeight = 0;
			BestPath = FindBestInventoryPath(BestWeight, false);
			if ( BestPath != None )
			{
				MoveTarget = BestPath;
				return;
			}
		}
		if ( bVerbose )
			log(self$" give up retreat");

		// if nothing, then tactical move
		if ( LineOfSightTo(Enemy) )
		{
			LastInvFind = Level.TimeSeconds;
			bKamikaze = true;
			GotoState('TacticalMove', 'NoCharge');
			return;
		}
		WhatToDoNext('','');
	}


	function ChangeDestination()
	{
		local actor oldTarget;
		local Actor path;
		
		oldTarget = Home;
		PickDestination();
		if (Home == oldTarget)
		{
			bKamikaze = true;
			//log("same old target");
			GotoState('TacticalMove', 'TacticalTick');
		}
		else
		{
			path = FindPathToward(Home);
			if (path == None)
			{
				//log("no new target");
				bKamikaze = true;
				GotoState('TacticalMove', 'TacticalTick');
			}
			else 
			{
				MoveTarget = path;
				Destination = path.Location;
			}
		}
	}
	
	function bool CheckBumpAttack(Pawn Other)
	{
		if ( (Other == Enemy) && (((Other.Location - Location) Dot Velocity) > 0) )
			bKamikaze = true;
		
		if ( SetEnemy(Other) && (Enemy == Other) && (Weapon != None) && !Weapon.bMeleeWeapon )
		{
			bReadyToAttack = true;
			GotoState('RangedAttack');
			return true;
		}
		return false;
	}
	
	function ReachedHome()
	{
		if (LineOfSightTo(Enemy))
		{
			if (Homebase(home) != None)
			{
				//log(class$" reached home base - turn and fight");
				bKamikaze = true;
				MakeNoise(1.0);
				GotoState('Attacking');
			}
			else
				ChangeDestination();
		}
		else
		{
			if (Homebase(home) != None)
				MakeNoise(1.0);
			bKamikaze = true;
			GotoState('Attacking');
		}
	}

	function PickNextSpot()
	{
		local Actor path;
		local vector dist2d;
		local float zdiff;

		if ( Home == None )
		{
			PickDestination();
			if ( Home == None )
				return;
		}
		//log("find retreat spot");
		dist2d = Home.Location - Location;
		zdiff = dist2d.Z;
		dist2d.Z = 0.0;	
		if ((VSize(dist2d) < 2 * CollisionRadius) && (Abs(zdiff) < CollisionHeight))
			ReachedHome();
		else
		{
			if (ActorReachable(Home))
			{
				//log("almost there");
				path = Home;
				if (HomeBase(Home) == None)
					Home = None;
			}
			else
			{
				if (SpecialGoal != None)
					path = FindPathToward(SpecialGoal);
				else
					path = FindPathToward(Home);
			}
				
			if (path == None)
				ChangeDestination();
			else
			{
				MoveTarget = path;
				Destination = path.Location;
			}
		}
	}

	function AnimEnd() 
	{
		if ( bCanFire && LineOfSightTo(Enemy) )
			PlayCombatMove();
		else if ( (Physics == PHYS_Falling) && (Velocity.Z < -300) )
			FastInAir();
		else
			PlayRunning();
	}

	function BeginState()
	{
		if ( Level.Game.bTeamGame && !Enemy.IsA('StationaryPawn') )
			CallForHelp();
		bSpecialPausing = false;
		bCanFire = false;
		SpecialGoal = None;
		SpecialPause = 0.0;
	}

	function EndState()
	{
		bAdvancedTactics = false;
	}

Begin:
	if ( bReadyToAttack && (FRand() < 0.4 - 0.1 * Skill) )
		bReadyToAttack = false;
	if ( (TimerRate == 0.0) || !bReadyToAttack )
		SetTimer(TimeBetweenAttacks, false);

	TweenToRunning(0.1);
	WaitForLanding();
	
RunAway:
	PickDestination();
	bAdvancedTactics = ( !bNovice && (Level.TimeSeconds - LastSeenTime < 1.0) 
						&& (Skill > 2.5 * FRand() - 1)
						&& (!MoveTarget.IsA('NavigationPoint') || !NavigationPoint(MoveTarget).bNeverUseStrafing) );
SpecialNavig:
	if (SpecialPause > 0.0)
	{
		if ( LineOfSightTo(Enemy) )
		{
			if ( ((Base == None) || (Base == Level))
				&& (FRand() < 0.6) )
				GotoState('TacticalMove', 'NoCharge');
			Target = Enemy;
			bFiringPaused = true;
			NextState = 'Retreating';
			NextLabel = 'RunAway';
			GotoState('RangedAttack');
		}
		Disable('AnimEnd');
		Acceleration = vect(0,0,0);
		TweenToPatrolStop(0.3);
		Sleep(SpecialPause);
		SpecialPause = 0.0;
		Enable('AnimEnd');
		TweenToRunning(0.1);
		Goto('RunAway');
	}
Moving:
	if ( !IsAnimating() )
		AnimEnd();
	if ( MoveTarget == None )
	{
		Sleep(0.0);
		Goto('RunAway');
	}
	if ( MoveTarget.IsA('InventorySpot') && (InventorySpot(MoveTarget).markedItem != None) 
		&& (InventorySpot(MoveTarget).markedItem.GetStateName() == 'Pickup')
		&& (InventorySpot(MoveTarget).markedItem.BotDesireability(self) > 0) )
			MoveTarget = InventorySpot(MoveTarget).markedItem;
	if ( FaceDestination(2) )
	{
		HaltFiring();
		MoveToward(MoveTarget);
	}
	else
	{
		bCanFire = true;
		StrafeFacing(MoveTarget.Location, Enemy);
	}
	Goto('RunAway');

Landed:
	if ( MoveTarget == None )
		Goto('RunAway');
	Goto('Moving');

TakeHit:
	TweenToRunning(0.12);
	Goto('Moving');

AdjustFromWall:
	if ( !IsAnimating() )
		AnimEnd();
	StrafeTo(Destination, Focus); 
	Destination = Focus; 
	MoveTo(Destination);
	Goto('Moving');
}

state Fallback
{
ignores EnemyNotVisible;

	function MayFall()
	{
		bAdvancedTactics = false;
		bCanJump = ( (MoveTarget != None) 
					&& ((MoveTarget.Physics != PHYS_Falling) || !MoveTarget.IsA('Inventory')) );
	}

	function EnemyNotVisible()
	{
		local Pawn P;

		if ( (OldEnemy != None) && LineOfSightTo(OldEnemy) )
		{
			P = OldEnemy;
			OldEnemy = Enemy;
			Enemy = P;
		}
		if ( Enemy.IsA('TeamCannon') )
		{
			Enemy = OldEnemy;
			OldEnemy = None;
			if ( Enemy == None )
				GotoState('Roaming');
		}
	}

	function SeePlayer(Actor SeenPlayer)
	{
		if ( SeenPlayer == Enemy )
		{
			LastSeenTime = Level.TimeSeconds;
			return;
		}
		if ( SetEnemy(Pawn(SeenPlayer)) )
			MakeNoise(1.0);
	}

	singular function HearNoise(float Loudness, Actor NoiseMaker)
	{
		if ( (NoiseMaker.instigator == Enemy) || LineOfSightTo(Enemy) )
			return;

		if ( SetEnemy(NoiseMaker.instigator) )
		{
			LastSeenPos = 0.5 * (NoiseMaker.Location + VSize(NoiseMaker.Location - Location) * vector(Rotation));
			MakeNoise(1.0);
		}
	}
	
	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
							Vector momentum, name damageType)
	{
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 )
			return;
		if (NextState == 'TakeHit')
		{
			NextState = 'Fallback'; 
			NextLabel = 'TakeHit';
			GotoState('TakeHit'); 
		}
		else if ( !bCanFire && (skill > 3 * FRand()) )
			GotoState('Fallback', 'Moving');
	}

	function Timer()
	{
		bReadyToAttack = True;
		Enable('Bump');
	}
	
	function SetFall()
	{
		NextState = 'Fallback'; 
		NextLabel = 'Landed';
		NextAnim = AnimSequence;
		GotoState('FallingState'); 
	}

	function HitWall(vector HitNormal, actor Wall)
	{
		if (Physics == PHYS_Falling)
			return;
		if ( Wall.IsA('Mover') && Mover(Wall).HandleDoor(self) )
		{
			if ( SpecialPause > 0 )
				Acceleration = vect(0,0,0);
			GotoState('Fallback', 'SpecialNavig');
			return;
		}
		Focus = Destination;
		if (PickWallAdjust())
		{
			bAdvancedTactics = false;
			if ( Physics == PHYS_Falling )
				SetFall();
			else
				GotoState('Fallback', 'AdjustFromWall');
		}
		else
			MoveTimer = -1.0;
	}

	function PickDestination()
	{
		local byte TeamPriority;

		if ( Level.TimeSeconds - LastSeenTime > 9 )
			Enemy = None;
		if ( Enemy == None )
		{
			WhatToDoNext('','');
			return;
		}
		bCanTranslocate = ( Level.Game.IsA('DeathMatchPlus') && DeathMatchPlus(Level.Game).CanTranslocate(self) );
		LastAttractCheck = Level.TimeSeconds - 0.1;

		if ( Level.Game.IsA('TeamGamePlus')
			&& TeamGamePlus(Level.Game).FindSpecialAttractionFor(self) )
		{
			if ( IsInState('Fallback') )
			{
				TeamPriority = TeamGamePlus(Level.Game).PriorityObjective(self);
				if ( TeamPriority > 16 )
				{
					PickLocalInventory(160, 1.8);
					return;
				}
				else if ( TeamPriority > 1 )
				{
					PickLocalInventory(200, 1);
					return;
				}
				else if ( TeamPriority > 0 )
				{
					PickLocalInventory(200, 0.55);
					return;
				}
				PickLocalInventory(400, 0.5);
				if ( MoveTarget == None )
				{
					if ( bVerbose )
						log(self$" no destination in fallback!");
					Orders = 'Freelance';
					GotoState('Attacking');
				}
			}
			return;
		}
		else if ( (Orders == 'Attack') || (OrderObject == None) )
		{
			if ( bVerbose )
				log(self$" attack fallback turned to freelance");
			Orders = 'Freelance';
			GotoState('Attacking');
		}
		else if ( (VSize(Location - OrderObject.Location) < 20)
			|| ((VSize(Location - OrderObject.Location) < 600) && LineOfSightTo(OrderObject)) )
		{
			if ( Enemy.IsA('TeamCannon') || ((Level.TimeSeconds - LastSeenTime > 5) && (Orders == 'Hold')) )
			{
				Enemy = OldEnemy;
				OldEnemy = None;
			}
			GotoState('Attacking');
		}
		else if ( ActorReachable(OrderObject) )
			MoveTarget = OrderObject;
		else
		{
			MoveTarget = FindPathToward(OrderObject);
			if ( MoveTarget == None )
			{
				if ( bVerbose )
					log(self@"fallback turned to freelance (no path to"@OrderObject@")");
				Orders = 'Freelance';
				GotoState('Attacking');
			}
		}
	}

	function bool CheckBumpAttack(Pawn Other)
	{
		SetEnemy(Other);
		if ( Enemy == Other )
		{
			bReadyToAttack = true;
			bCanFire = true;
		}
		return false;
	}

	function AnimEnd() 
	{
		if ( bCanFire && LineOfSightTo(Enemy) )
			PlayCombatMove();
		else
		{
			bFire = 0;
			bAltFire = 0;
			if ( (Physics == PHYS_Falling) && (Velocity.Z < -300) )
				FastInAir();
			else
				PlayRunning();
		}
	}

	function BeginState()
	{
		//log(self$" fallback");
		bCanFire = false;
		if ( bNoClearSpecial )
			bNoClearSpecial = false;
		else
		{
			bSpecialPausing = false;
			SpecialGoal = None;
			SpecialPause = 0.0;
		}
	}

	function EndState()
	{
		bAdvancedTactics = false;
		bCanTranslocate = false;
	}

Begin:
	TweenToRunning(0.12);
	WaitForLanding();
	
RunAway:
	PickDestination();
	bAdvancedTactics = ( !bNovice && (Level.TimeSeconds - LastSeenTime < 1.0) 
						&& (Skill > 2.5 * FRand() - 1)
						&& (!MoveTarget.IsA('NavigationPoint') || !NavigationPoint(MoveTarget).bNeverUseStrafing) );
SpecialNavig:
	if (SpecialPause > 0.0)
	{
		if ( LineOfSightTo(Enemy) )
		{
			Target = Enemy;
			bFiringPaused = true;
			NextState = 'Fallback';
			NextLabel = 'RunAway';
			GotoState('RangedAttack');
		}
		Disable('AnimEnd');
		Acceleration = vect(0,0,0);
		TweenToPatrolStop(0.3);
		Sleep(SpecialPause);
		SpecialPause = 0.0;
		Enable('AnimEnd');
		TweenToRunning(0.1);
		Goto('RunAway');
	}
Moving:
	if ( !IsAnimating() )
		AnimEnd();

	if ( MoveTarget == None )
	{
		Sleep(0.0);
		Goto('RunAway');
	}
	if ( FaceDestination(1) )
	{
		HaltFiring();
		MoveToward(MoveTarget);
	}
	else
	{
		bReadyToAttack = True;
		bCanFire = true;
		StrafeFacing(MoveTarget.Location, Enemy);
	}
	Goto('RunAway');

Landed:
	if ( MoveTarget == None )
		Goto('RunAway');
	Goto('Moving');

TakeHit:
	TweenToRunning(0.12);
	Goto('Moving');

AdjustFromWall:
	if ( !IsAnimating() )
		AnimEnd();
	StrafeTo(Destination, Focus); 
	Destination = Focus; 
	MoveTo(Destination);
	Goto('Moving');
}

state Charging
{
ignores SeePlayer, HearNoise;

	/* MayFall() called by engine physics if walking and bCanJump, and
		is about to go off a ledge.  Pawn has opportunity (by setting 
		bCanJump to false) to avoid fall
	*/

	function MayFall()
	{
		bAdvancedTactics = false;
		if ( MoveTarget != Enemy )
			return;

		bCanJump = ActorReachable(Enemy);
		if ( !bCanJump )
				GotoState('TacticalMove', 'NoCharge');
	}

	function HitWall(vector HitNormal, actor Wall)
	{
		if (Physics == PHYS_Falling)
			return;
		if ( Wall.IsA('Mover') && Mover(Wall).HandleDoor(self) )
		{
			if ( SpecialPause > 0 )
				Acceleration = vect(0,0,0);
			GotoState('Charging', 'SpecialNavig');
			return;
		}
		Focus = Destination;
		if (PickWallAdjust())
		{
			bAdvancedTactics = false;
			if ( Physics == PHYS_Falling )
				SetFall();
			else
				GotoState('Charging', 'AdjustFromWall');
		}
		else
			MoveTimer = -1.0;
	}
	
	function SetFall()
	{
		NextState = 'Charging'; 
		NextLabel = 'ResumeCharge';
		NextAnim = AnimSequence;
		GotoState('FallingState'); 
	}

	function FearThisSpot(Actor aSpot)
	{
		Destination = Location + 120 * Normal(Normal(Destination - Location) + Normal(Location - aSpot.Location)); 
		GotoState('TacticalMove', 'DoStrafeMove');
	}

	function TryToDuck(vector duckDir, bool bReversed)
	{
		if ( FRand() < 0.6 )
		{
			Global.TryToDuck(duckDir, bReversed);
			return;
		}
		if ( MoveTarget == Enemy ) 
			TryStrafe(duckDir);
	}

	function bool StrafeFromDamage(vector momentum, float Damage, name DamageType, bool bFindDest)
	{
		local vector sideDir;
		local float healthpct;

		if ( (damageType == 'shot') || (damageType == 'jolted') || (damageType == 'Zapped') )
			healthpct = 0.17;
		else
			healthpct = 0.25;

		healthpct *= CombatStyle;
		if ( FRand() * Damage < healthpct * Health ) 
			return false;

		if ( !bFindDest )
			return true;

		sideDir = Normal( Normal(Enemy.Location - Location) Cross vect(0,0,1) );
		if ( (momentum Dot sidedir) > 0 )
			sidedir *= -1;

		return TryStrafe(sideDir);
	}

	function bool TryStrafe(vector sideDir)
	{ 
		local vector extent, HitLocation, HitNormal;
		local actor HitActor;

		Extent.X = CollisionRadius;
		Extent.Y = CollisionRadius;
		Extent.Z = CollisionHeight;
		HitActor = Trace(HitLocation, HitNormal, Location + 100 * sideDir, Location, false, Extent);
		if (HitActor != None)
		{
			sideDir *= -1;
			HitActor = Trace(HitLocation, HitNormal, Location + 100 * sideDir, Location, false, Extent);
		}
		if (HitActor != None)
			return false;
		
		if ( Physics == PHYS_Walking )
		{
			HitActor = Trace(HitLocation, HitNormal, Location + 100 * sideDir - MaxStepHeight * vect(0,0,1), Location + 100 * sideDir, false, Extent);
			if ( HitActor == None )
				return false;
		}
		Destination = Location + 250 * sideDir;
		GotoState('TacticalMove', 'DoStrafeMove');
		return true;
	}
			
	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
							Vector momentum, name damageType)
	{
		local float pick;
		local vector sideDir, extent;
		local bool bWasOnGround;

		bWasOnGround = (Physics == PHYS_Walking);
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 )
			return;
		if (NextState == 'TakeHit')
		{
			if ( AttitudeTo(Enemy) == ATTITUDE_Fear )
			{
				NextState = 'Retreating';
				NextLabel = 'Begin';
			}
			else if ( StrafeFromDamage(momentum, Damage, damageType, false) )
			{
				NextState = 'TacticalMove';
				NextLabel = 'NoCharge';
			}
			else
			{
				NextState = 'Charging';
				NextLabel = 'TakeHit';
			}
			GotoState('TakeHit'); 
		}
		else if ( StrafeFromDamage(momentum, Damage, damageType, true) )
			return;
		else if ( bWasOnGround && (MoveTarget == Enemy) && 
					(Physics == PHYS_Falling) ) //weave
		{
			pick = 1.0;
			if ( bStrafeDir )
				pick = -1.0;
			sideDir = Normal( Normal(Enemy.Location - Location) Cross vect(0,0,1) );
			sideDir.Z = 0;
			Velocity += pick * GroundSpeed * 0.7 * sideDir;   
			if ( FRand() < 0.2 )
				bStrafeDir = !bStrafeDir;
		}
	}
							
	function AnimEnd() 
	{
		PlayCombatMove();
	}
	
	function Timer()
	{
		bReadyToAttack = True;
		Target = Enemy;	
		if ( Enemy == None )
		{
			GotoState('Attacking');
			return;
		}
		if ( (VSize(Enemy.Location - Location) 
				<= (MeleeRange + Enemy.CollisionRadius + CollisionRadius))
			|| ((Weapon != None) && !Weapon.bMeleeWeapon && (FRand() > 0.7 + 0.1 * skill)) ) 
			GotoState('RangedAttack');
	}
	
	function EnemyNotVisible()
	{
		GotoState('Hunting'); 
	}

	function BeginState()
	{
		bCanFire = false;
		SpecialGoal = None;
		SpecialPause = 0.0;
	}

	function EndState()
	{
		bAdvancedTactics = false;
		if ( JumpZ > 0 )
			bCanJump = true;
	}

AdjustFromWall:
	StrafeTo(Destination, Focus); 
	Goto('CloseIn');

ResumeCharge:
	PlayRunning();
	Goto('Charge');

Begin:
	TweenToRunning(0.1);

Charge:
	bFromWall = false;
	
CloseIn:
	if ( (Enemy == None) || (Enemy.Health <=0) )
		GotoState('Attacking');

	if ( Enemy.Region.Zone.bWaterZone )
	{
		if (!bCanSwim)
			GotoState('TacticalMove', 'NoCharge');
	}
	else if (!bCanFly && !bCanWalk)
		GotoState('TacticalMove', 'NoCharge');

	if (Physics == PHYS_Falling)
	{
		DesiredRotation = Rotator(Enemy.Location - Location);
		Focus = Enemy.Location;
		Destination = Enemy.Location;
		WaitForLanding();
	}
	if( actorReachable(Enemy) )
	{
		bCanFire = true;
		bAdvancedTactics = ( !bNovice && !Level.Game.bTeamGame && (Weapon != None) && !Weapon.bMeleeWeapon && (FRand() < 0.75) );
		MoveToward(Enemy);
		if (bFromWall)
		{
			bFromWall = false;
			if (PickWallAdjust())
			{
				if ( Physics == PHYS_Falling )
					SetFall();
				else
					StrafeFacing(Destination, Enemy);
			}
			else
				GotoState('TacticalMove', 'NoCharge');
		}
	}
	else
	{
NoReach:
		bCanFire = false;
		bFromWall = false;
		//log("route to enemy"@Enemy);
		if ( !FindBestPathToward(Enemy, true) )
		{
			Sleep(0.0);
			GotoState('TacticalMove', 'NoCharge');
		}
SpecialNavig:
		if ( SpecialPause > 0.0 )
		{
			Target = Enemy;
			bFiringPaused = true;
			NextState = 'Charging';
			NextLabel = 'Begin';
			GotoState('RangedAttack');
		}
Moving:
		if (VSize(MoveTarget.Location - Location) < 2.5 * CollisionRadius)
		{
			bCanFire = true;
			StrafeFacing(MoveTarget.Location, Enemy);
		}
		else
		{
			if ( FaceDestination(1.5) )
			{
				if ( GetAnimGroup(AnimSequence) == 'MovingAttack' )
				{
					AnimSequence = '';
					TweenToRunning(0.12);
				}
				HaltFiring();
				MoveToward(MoveTarget);
			}
			else
			{
				bCanFire = true;
				StrafeFacing(MoveTarget.Location, Enemy);	
			}
		}
	}

	GotoState('Attacking');

GotThere:
	Target = Enemy;
	if ( !Weapon.bMeleeWeapon )
		GotoState('RangedAttack');
	Sleep(0.1 - 0.02 * Skill );
	Goto('Charge');

TakeHit:
	TweenToRunning(0.12);
	if (MoveTarget == Enemy)
	{
		bCanFire = true;
		MoveToward(MoveTarget);
	}
	
	Goto('Charge');
}

state TacticalMove
{
ignores SeePlayer, HearNoise;

	function WarnTarget(Pawn shooter, float projSpeed, vector FireDir)
	{	
		if ( bCanFire && (FRand() < 0.4) ) 
			return;

		Super.WarnTarget(shooter, projSpeed, FireDir);
	}

	function SetFall()
	{
		Acceleration = vect(0,0,0);
		Destination = Location;
		NextState = 'Attacking'; 
		NextLabel = 'Begin';
		NextAnim = 'Fighter';
		GotoState('FallingState');
	}

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, name damageType)
	{
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 )
			return;
		if ( NextState == 'TakeHit' )
		{
			NextState = 'TacticalMove'; 
			NextLabel = 'TakeHit';
			GotoState('TakeHit'); 
		}
	}

	function HitWall(vector HitNormal, actor Wall)
	{
		if (Physics == PHYS_Falling)
			return;
		Focus = Destination;
		if ( Enemy == None )
		{
			GotoState('Attacking');
			return;
		}
		//if (PickWallAdjust())
		//	GotoState('TacticalMove', 'AdjustFromWall');
		if ( bChangeDir || (FRand() < 0.5) 
			|| (((Enemy.Location - Location) Dot HitNormal) < 0) )
		{
			DesiredRotation = Rotator(Enemy.Location - location);
			GiveUpTactical(false);
		}
		else
		{
			bChangeDir = true;
			Destination = Location - HitNormal * FRand() * 500;
		}
	}

	function FearThisSpot(Actor aSpot)
	{
		Destination = Location + 120 * Normal(Location - aSpot.Location); 
	}

	function AnimEnd() 
	{
		if ( bCanFire && LineOfSightTo(Enemy) )
			PlayCombatMove();
		else if ( (Physics == PHYS_Falling) && (Velocity.Z < -300) )
			FastInAir();
		else
			PlayRunning();
	}

	function Timer()
	{
	
		bReadyToAttack = True;
		Enable('Bump');
		Target = Enemy;
		if ( Enemy == None )
			return;
		if (VSize(Enemy.Location - Location) 
				<= (MeleeRange + Enemy.CollisionRadius + CollisionRadius))
			GotoState('RangedAttack');		 
		else if ( !Weapon.bMeleeWeapon && ((Enemy.Weapon == None) || !Enemy.Weapon.bMeleeWeapon) )
		{
			if ( bNovice )
			{
				if ( FRand() > 0.4 + 0.18 * skill ) 
					GotoState('RangedAttack');
			}
			else if ( FRand() > 0.5 + 0.17 * skill ) 
				GotoState('RangedAttack');
		}
	}

	function EnemyNotVisible()
	{
		if ( !bGathering && (aggressiveness > relativestrength(enemy)) )
		{
			if ( FastTrace(Enemy.Location, LastSeeingPos) )
			{
				bCanFire = false;
				GotoState('TacticalMove','RecoverEnemy');
			}
			else
				GotoState('Attacking');
		}
		Disable('EnemyNotVisible');
	}
		
	function GiveUpTactical(bool bNoCharge)
	{	
		if ( !bNoCharge && (Weapon.bMeleeWeapon || (2 * CombatStyle + 0.1 * Skill > FRand())) )
			GotoState('Charging');
		else if ( bReadyToAttack && !Weapon.bMeleeWeapon && !bNovice )
			GotoState('RangedAttack');
		else
			GotoState('RangedAttack', 'Challenge'); 
	}		

	function bool TryToward(inventory Inv, float Weight)
	{
		local bool success; 
		local vector pickdir, collSpec, minDest, HitLocation, HitNormal;
		local Actor HitActor;

		if ( (Weight < 0.0008) && ((Weight < 0.0008 - 0.0002 * skill) 
				|| !Enemy.LineOfSightTo(Inv)) )
			return false;

		pickdir = Inv.Location - Location;
		if ( Physics == PHYS_Walking )
			pickDir.Z = 0;
		pickDir = Normal(PickDir);

		collSpec.X = CollisionRadius;
		collSpec.Y = CollisionRadius;
		collSpec.Z = FMax(6, CollisionHeight - 18);
		
		minDest = Location + FMin(160.0, 3*CollisionRadius) * pickDir;
		HitActor = Trace(HitLocation, HitNormal, minDest, Location, false, collSpec);
		if (HitActor == None)
		{
			success = (Physics != PHYS_Walking);
			if ( !success )
			{
				collSpec.X = FMin(14, 0.5 * CollisionRadius);
				collSpec.Y = collSpec.X;
				HitActor = Trace(HitLocation, HitNormal, minDest - (18 + MaxStepHeight) * vect(0,0,1), minDest, false, collSpec);
				success = (HitActor != None);
			}
			if ( success )
			{
				Destination = Inv.Location;
				bGathering = true;
				if ( 2.7 * FRand() < skill )
					GotoState('TacticalMove','DoStrafeMove');
				else
					GotoState('TacticalMove','DoDirectMove');
				return true;
			}
		}

		return false;
	}

	function PainTimer()
	{
		if ( (FootRegion.Zone.bPainZone) && (FootRegion.Zone.DamagePerSec > 0)
			&& (FootRegion.Zone.DamageType != ReducedDamageType) )
			GotoState('Retreating');
		Super.PainTimer();
	}


/* PickDestination()
Choose a destination for the tactical move, based on aggressiveness and the tactical
situation. Make sure destination is reachable
*/
	function PickDestination(bool bNoCharge)
	{
		local inventory Inv, BestInv, SecondInv;
		local float Bestweight, NewWeight, MaxDist, SecondWeight;

		// possibly pick nearby inventory
		// higher skill bots will always strafe, lower skill
		// both do this less, and strafe less

		if ( !bReadyToAttack && (TimerRate == 0.0) )
			SetTimer(0.7, false);
		if ( bNovice )
		{
			if ( Level.TimeSeconds - LastInvFind < 4 )
			{
				PickRegDestination(bNoCharge);
				return;
			}
		}
		else if ( Level.TimeSeconds - LastInvFind < 3 - 0.5 * skill )
		{
			PickRegDestination(bNoCharge);
			return;
		}

		LastInvFind = Level.TimeSeconds;
		bGathering = false;
		MaxDist = 700 + 70 * skill;
		BestWeight = 0.5/MaxDist;
		foreach visiblecollidingactors(class'Inventory', Inv, MaxDist,,true)
			if ( (Inv.IsInState('PickUp')) && (Inv.MaxDesireability/200 > BestWeight)
				&& (Inv.Location.Z < Location.Z + MaxStepHeight + CollisionHeight)
				&& (Inv.Location.Z > FMin(Location.Z, Enemy.Location.Z) - CollisionHeight) )
			{
				NewWeight = inv.BotDesireability(self)/VSize(Inv.Location - Location);
				if ( NewWeight > BestWeight )
				{
					SecondWeight = BestWeight;
					BestWeight = NewWeight;
					SecondInv = BestInv;
					BestInv = Inv;
				}
			}

		if ( BestInv == None )
		{
			PickRegDestination(bNoCharge);
			return;
		}

		if ( TryToward(BestInv, BestWeight) )
			return;

		if ( SecondInv == None )
		{
			PickRegDestination(bNoCharge);
			return;
		}

		if ( TryToward(SecondInv, SecondWeight) )
			return;

		PickRegDestination(bNoCharge);
	}

	function PickRegDestination(bool bNoCharge)
	{
		local vector pickdir, enemydir, enemyPart, X,Y,Z, minDest;
		local actor HitActor;
		local vector HitLocation, HitNormal, collSpec;
		local float Aggression, enemydist, minDist, strafeSize, optDist;
		local bool success, bNoReach;
	
		if ( Orders == 'Hold' )
			bNoCharge = true;

		bChangeDir = false;
		if (Region.Zone.bWaterZone && !bCanSwim && bCanFly)
		{
			Destination = Location + 75 * (VRand() + vect(0,0,1));
			Destination.Z += 100;
			return;
		}
		if ( Enemy.Region.Zone.bWaterZone )
			bNoCharge = bNoCharge || !bCanSwim;
		else 
			bNoCharge = bNoCharge || (!bCanFly && !bCanWalk);
		
		if( Weapon.bMeleeWeapon && !bNoCharge )
		{
			GotoState('Charging');
			return;
		}
		enemyDist = VSize(Location - Enemy.Location);
		if ( (bNovice && (FRand() > 0.3 + 0.15 * skill)) || (FRand() > 0.7 + 0.15 * skill) 
			&& ((EnemyDist > 900) || (Enemy.Weapon == None) || !Enemy.Weapon.bMeleeWeapon) 
			&& (!Level.Game.IsA('TeamGamePlus') || (TeamGamePlus(Level.Game).PriorityObjective(self) == 0)) )
			GiveUpTactical(true);

		success = false;
		if ( (bSniping || (Orders == 'Hold'))  
			&& (!Level.Game.IsA('TeamGamePlus') || (TeamGamePlus(Level.Game).PriorityObjective(self) == 0)) )
			bNoCharge = true;
		if ( bSniping && Weapon.IsA('SniperRifle') )
		{
			bReadyToAttack = true;
			GotoState('RangedAttack');
			return;
		}
						
		Aggression = 2 * (CombatStyle + FRand()) - 1.1;
		if ( Enemy.bIsPlayer && (AttitudeTo(Enemy) == ATTITUDE_Fear) && (CombatStyle > 0) )
			Aggression = Aggression - 2 - 2 * CombatStyle;
		if ( Weapon != None )
			Aggression += 2 * Weapon.SuggestAttackStyle();
		if ( Enemy.Weapon != None )
			Aggression += 2 * Enemy.Weapon.SuggestDefenseStyle();

		if ( enemyDist > 1000 )
			Aggression += 1;
		if ( !bNoCharge )
			bNoCharge = ( Aggression < FRand() );

		if ( (Physics == PHYS_Walking) || (Physics == PHYS_Falling) )
		{
			if (Location.Z > Enemy.Location.Z + 150) //tactical height advantage
				Aggression = FMax(0.0, Aggression - 1.0 + CombatStyle);
			else if (Location.Z < Enemy.Location.Z - CollisionHeight) // below enemy
			{
				if ( !bNoCharge && (Aggression > 0) && (FRand() < 0.6) )
				{
					GotoState('Charging');
					return;
				}
				else if ( (enemyDist < 1.1 * (Enemy.Location.Z - Location.Z)) 
						&& !actorReachable(Enemy) ) 
				{
					bNoReach = true;
					aggression = -1.5 * FRand();
				}
			}
		}
	
		if (!bNoCharge && (Aggression > 2 * FRand()))
		{
			if ( bNoReach && (Physics != PHYS_Falling) )
			{
				TweenToRunning(0.1);
				GotoState('Charging', 'NoReach');
			}
			else
				GotoState('Charging');
			return;
		}

		if ( !bNovice && ((Weapon == None) || !Weapon.bRecommendSplashDamage) && (FRand() < 0.35) && (bJumpy || (FRand()*Skill > 0.4)) )
		{
			GetAxes(Rotation,X,Y,Z);

			if ( FRand() < 0.5 )
			{
				Y *= -1;
				TryToDuck(Y, true);
			}
			else
				TryToDuck(Y, false);
			if ( !IsInState('TacticalMove') )
				return;
		}
			
		if (enemyDist > FMax(VSize(OldLocation - Enemy.OldLocation), 240))
			Aggression += 0.4 * FRand();
			 
		enemydir = (Enemy.Location - Location)/enemyDist;
		if ( bJumpy )
			minDist = 160;
		else
			minDist = FMin(160.0, 3*CollisionRadius);
		optDist = 80 + FMin(EnemyDist, 250 * (FRand() + FRand()));  
		Y = (enemydir Cross vect(0,0,1));
		if ( Physics == PHYS_Walking )
		{
			Y.Z = 0;
			enemydir.Z = 0;
		}
		else 
			enemydir.Z = FMax(0,enemydir.Z);
			
		strafeSize = FMax(-0.7, FMin(0.85, (2 * Aggression * FRand() - 0.3)));
		enemyPart = enemydir * strafeSize;
		strafeSize = FMax(0.0, 1 - Abs(strafeSize));
		pickdir = strafeSize * Y;
		if ( bStrafeDir )
			pickdir *= -1;
		bStrafeDir = !bStrafeDir;
		collSpec.X = CollisionRadius;
		collSpec.Y = CollisionRadius;
		collSpec.Z = FMax(6, CollisionHeight - 18);
		
		minDest = Location + minDist * (pickdir + enemyPart);
		HitActor = Trace(HitLocation, HitNormal, minDest, Location, false, collSpec);
		if (HitActor == None)
		{
			success = (Physics != PHYS_Walking);
			if ( !success )
			{
				collSpec.X = FMin(14, 0.5 * CollisionRadius);
				collSpec.Y = collSpec.X;
				HitActor = Trace(HitLocation, HitNormal, minDest - (18 + MaxStepHeight) * vect(0,0,1), minDest, false, collSpec);
				success = (HitActor != None);
			}
			if (success)
				Destination = minDest + (pickdir + enemyPart) * optDist;
		}
	
		if ( !success )
		{					
			collSpec.X = CollisionRadius;
			collSpec.Y = CollisionRadius;
			minDest = Location + minDist * (enemyPart - pickdir); 
			HitActor = Trace(HitLocation, HitNormal, minDest, Location, false, collSpec);
			if (HitActor == None)
			{
				success = (Physics != PHYS_Walking);
				if ( !success )
				{
					collSpec.X = FMin(14, 0.5 * CollisionRadius);
					collSpec.Y = collSpec.X;
					HitActor = Trace(HitLocation, HitNormal, minDest - (18 + MaxStepHeight) * vect(0,0,1), minDest, false, collSpec);
					success = (HitActor != None);
				}
				if (success)
					Destination = minDest + (enemyPart - pickdir) * optDist;
			}
			else 
			{
				if ( (CombatStyle <= 0) || (Enemy.bIsPlayer && (AttitudeTo(Enemy) == ATTITUDE_Fear)) )
					enemypart = vect(0,0,0);
				else if ( (enemydir Dot enemyPart) < 0 )
					enemyPart = -1 * enemyPart;
				pickDir = Normal(enemyPart - pickdir + HitNormal);
				minDest = Location + minDist * pickDir;
				collSpec.X = CollisionRadius;
				collSpec.Y = CollisionRadius;
				HitActor = Trace(HitLocation, HitNormal, minDest, Location, false, collSpec);
				if (HitActor == None)
				{
					success = (Physics != PHYS_Walking);
					if ( !success )
					{
						collSpec.X = FMin(14, 0.5 * CollisionRadius);
						collSpec.Y = collSpec.X;
						HitActor = Trace(HitLocation, HitNormal, minDest - (18 + MaxStepHeight) * vect(0,0,1), minDest, false, collSpec);
						success = (HitActor != None);
					}
					if (success)
						Destination = minDest + pickDir * optDist;
				}
			}	
		}
					
		if ( !success )
			GiveUpTactical(bNoCharge);
		else 
		{
			if ( bJumpy || (Weapon.bRecommendSplashDamage && !bNovice 
				&& (FRand() < 0.2 + 0.2 * Skill)
				&& (Enemy.Location.Z - Enemy.CollisionHeight <= Location.Z + MaxStepHeight - CollisionHeight)) 
				&& !NeedToTurn(Enemy.Location) )
			{
				FireWeapon();
				if ( (bJumpy && (FRand() < 0.75)) || Weapon.SplashJump() )
				{
					// try jump move
					SetPhysics(PHYS_Falling);
					Acceleration = vect(0,0,0);
					Destination = minDest;
					NextState = 'Attacking'; 
					NextLabel = 'Begin';
					NextAnim = 'Fighter';
					GotoState('FallingState');
					return;
				}
			}
			pickDir = (Destination - Location);
			enemyDist = VSize(pickDir);
			if ( enemyDist > minDist + 2 * CollisionRadius )
			{
				pickDir = pickDir/enemyDist;
				HitActor = Trace(HitLocation, HitNormal, Destination + 2 * CollisionRadius * pickdir, Location, false);
				if ( (HitActor != None) && ((HitNormal Dot pickDir) < -0.6) )
					Destination = HitLocation - 2 * CollisionRadius * pickdir;
			}
		}
	}

	function BeginState()
	{
		if ( bNovice ) 
			MaxDesiredSpeed = 0.4 + 0.08 * skill;
		MinHitWall += 0.15;
		bAvoidLedges = true;
		bStopAtLedges = true;
		bCanJump = false;
		bCanFire = false;
	}
	
	function EndState()
	{
		if ( bNovice ) 
			MaxDesiredSpeed = 0.5 + 0.1 * skill;
		bAvoidLedges = false;
		bStopAtLedges = false;
		bQuickFire = false;
		MinHitWall -= 0.15;
		if (JumpZ > 0)
			bCanJump = true;
	}

TacticalTick:
	Sleep(0.02);	
Begin:
	TweenToRunning(0.15);
	Enable('AnimEnd');
	if (Physics == PHYS_Falling)
	{
		DesiredRotation = Rotator(Enemy.Location - Location);
		Focus = Enemy.Location;
		Destination = Enemy.Location;
		WaitForLanding();
	}
	PickDestination(false);

DoMove:
	if ( !bCanStrafe )
	{ 
DoDirectMove:
		Enable('AnimEnd');
		if ( GetAnimGroup(AnimSequence) == 'MovingAttack' )
		{
			AnimSequence = '';
			TweenToRunning(0.12);
		}
		HaltFiring();
		MoveTo(Destination);
	}
	else
	{
DoStrafeMove:
		Enable('AnimEnd');
		bCanFire = true;
		StrafeFacing(Destination, Enemy);	
	}

	if ( (Enemy != None) && !LineOfSightTo(Enemy) && FastTrace(Enemy.Location, LastSeeingPos) )
		Goto('RecoverEnemy');
	else
	{
		bReadyToAttack = true;
		GotoState('Attacking');
	}
	
NoCharge:
	TweenToRunning(0.1);
	Enable('AnimEnd');
	if (Physics == PHYS_Falling)
	{
		DesiredRotation = Rotator(Enemy.Location - Location);
		Focus = Enemy.Location;
		Destination = Enemy.Location;
		WaitForLanding();
	}
	PickDestination(true);
	Goto('DoMove');
	
AdjustFromWall:
	Enable('AnimEnd');
	StrafeTo(Destination, Focus); 
	Destination = Focus; 
	Goto('DoMove');

TakeHit:
	TweenToRunning(0.12);
	Goto('DoMove');

RecoverEnemy:
	Enable('AnimEnd');
	bReadyToAttack = true;
	HidingSpot = Location;
	bCanFire = false;
	Destination = LastSeeingPos + 4 * CollisionRadius * Normal(LastSeeingPos - Location);
	StrafeFacing(Destination, Enemy);

	if ( !Weapon.bMeleeWeapon && LineOfSightTo(Enemy) && CanFireAtEnemy() )
	{
		Disable('AnimEnd');
		DesiredRotation = Rotator(Enemy.Location - Location);
		bQuickFire = true;
		FireWeapon();
		bQuickFire = false;
		Acceleration = vect(0,0,0);
		if ( Weapon.bSplashDamage )
		{
			bFire = 0;
			bAltFire = 0;
			bReadyToAttack = true;
			Sleep(0.2);
		}
		else
			Sleep(0.35 + 0.3 * FRand());
		if ( (FRand() + 0.1 > CombatStyle) )
		{
			bFire = 0;
			bAltFire = 0;
			bReadyToAttack = true;
			Enable('EnemyNotVisible');
			Enable('AnimEnd');
			Destination = HidingSpot + 4 * CollisionRadius * Normal(HidingSpot - Location);
			Goto('DoMove');
		}
	}

	GotoState('Attacking');
}

state Hunting
{
ignores EnemyNotVisible; 

	/* MayFall() called by engine physics if walking and bCanJump, and
		is about to go off a ledge.  Pawn has opportunity (by setting 
		bCanJump to false) to avoid fall
	*/
	function MayFall()
	{
		bCanJump = ( ((MoveTarget != None) 
					&& ((MoveTarget.Physics != PHYS_Falling) || !MoveTarget.IsA('Inventory')))
					|| PointReachable(Destination) );
	}

	function bool CheckBumpAttack(Pawn Other)
	{
		SetEnemy(Other);
		if ( Enemy == Other )
		{
			bReadyToAttack = true;
			LastSeenTime = Level.TimeSeconds;
			LastSeenPos = Enemy.Location;
			GotoState('Attacking');
			return true;
		}
		return false;
	}
	
	function FearThisSpot(Actor aSpot)
	{
		Destination = Location + 120 * Normal(Normal(Destination - Location) + Normal(Location - aSpot.Location)); 
		MoveTarget = None;
		GotoState('Hunting', 'SpecialNavig');
	}

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
							Vector momentum, name damageType)
	{
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 )
			return;
		bFrustrated = true;
		if (NextState == 'TakeHit')
		{
			if (AttitudeTo(Enemy) == ATTITUDE_Fear)
			{
				NextState = 'Retreating';
				NextLabel = 'Begin';
			}
			else
			{
				NextState = 'Hunting';
				NextLabel = 'AfterFall';
			}
			GotoState('TakeHit'); 
		}
	}

	singular function HearNoise(float Loudness, Actor NoiseMaker)
	{
		SetEnemy(NoiseMaker.instigator);
	}

	function SetFall()
	{
		NextState = 'Hunting'; 
		NextLabel = 'AfterFall';
		NextAnim = AnimSequence;
		GotoState('FallingState'); 
	}

	function bool SetEnemy(Pawn NewEnemy)
	{
		local float rnd;

		if (Global.SetEnemy(NewEnemy))
		{
			bDevious = false;
			BlockedPath = None;
			rnd = FRand();
			bReadyToAttack = true;
			DesiredRotation = Rotator(Enemy.Location - Location);
			if ( CombatStyle > FRand() )
				GotoState('Charging'); 
			else
				GotoState('Attacking');
			return true;
		}
		return false;
	} 

	function AnimEnd()
	{
		bFire = 0;
		bAltFire = 0;
		bReadyToAttack = true;
		if ( (Physics == PHYS_Falling) && (Velocity.Z < -300) )
			FastInAir();
		else
		{
			PlayRunning();
			Disable('AnimEnd');
		}
	}
	
	function Timer()
	{
		bReadyToAttack = true;
		Enable('Bump');
		SetTimer(1.0, false);
	}

	function HitWall(vector HitNormal, actor Wall)
	{
		if (Physics == PHYS_Falling)
			return;
		if ( Wall.IsA('Mover') && Mover(Wall).HandleDoor(self) )
		{
			if ( SpecialPause > 0 )
				Acceleration = vect(0,0,0);
			GotoState('Hunting', 'SpecialNavig');
			return;
		}
		Focus = Destination;
		if (PickWallAdjust())
		{
			if ( Physics == PHYS_Falling )
				SetFall();
			else
				GotoState('Hunting', 'AdjustFromWall');
		}
		else
			MoveTimer = -1.0;
	}

	function bool TryToward(inventory Inv, float Weight)
	{
		local bool success; 
		local vector pickdir, collSpec, minDest, HitLocation, HitNormal;
		local Actor HitActor;

		pickdir = Inv.Location - Location;
		if ( Physics == PHYS_Walking )
			pickDir.Z = 0;
		pickDir = Normal(PickDir);

		collSpec.X = CollisionRadius;
		collSpec.Y = CollisionRadius;
		collSpec.Z = FMax(6, CollisionHeight - 18);
		
		minDest = Location + FMin(160.0, 3*CollisionRadius) * pickDir;
		HitActor = Trace(HitLocation, HitNormal, minDest, Location, false, collSpec);
		if (HitActor == None)
		{
			success = (Physics != PHYS_Walking);
			if ( !success )
			{
				collSpec.X = FMin(14, 0.5 * CollisionRadius);
				collSpec.Y = collSpec.X;
				HitActor = Trace(HitLocation, HitNormal, minDest - (18 + MaxStepHeight) * vect(0,0,1), minDest, false, collSpec);
				success = (HitActor != None);
			}
			if ( success )
			{
				MoveTarget = Inv;
				return true;
			}
		}

		return false;
	}

	function PickDestination()
	{
		local inventory Inv, BestInv, SecondInv;
		local float Bestweight, NewWeight, MaxDist, SecondWeight;
		local NavigationPoint path;
		local actor HitActor;
		local vector HitNormal, HitLocation, nextSpot, ViewSpot;
		local float posZ;
		local bool bCanSeeLastSeen;
		local int i;

		// If no enemy, or I should see him but don't, then give up		
		if ( Level.TimeSeconds - LastSeenTime > 26 - Level.Game.NumPlayers - DeathMatchPlus(Level.Game).NumBots )
			Enemy = None;
		if ( (Enemy == None) || (Enemy.Health <= 0) )
		{
			WhatToDoNext('','');
			return;
		}
	
		bAvoidLedges = false;

		if ( JumpZ > 0 )
			bCanJump = true;
		
		if ( ActorReachable(Enemy) )
		{
			BlockedPath = None;
			if ( (numHuntPaths < 8 + Skill) || (Level.TimeSeconds - LastSeenTime < 15)
				|| ((Normal(Enemy.Location - Location) Dot vector(Rotation)) > -0.5) )
			{
				Destination = Enemy.Location;
				MoveTarget = None;
				numHuntPaths++;
			}
			else
				WhatToDoNext('','');
			return;
		}

		if ( Level.TimeSeconds - LastInvFind > 2.5 - 0.4 * skill )
		{
			LastInvFind = Level.TimeSeconds;
			MaxDist = 600 + 70 * skill;
			BestWeight = 0.6/MaxDist;
			foreach visiblecollidingactors(class'Inventory', Inv, MaxDist,, true)
				if ( (Inv.IsInState('PickUp')) && (Inv.MaxDesireability/200 > BestWeight)
					&& (Inv.Location.Z < Location.Z + MaxStepHeight + CollisionHeight)
					&& (Inv.Location.Z > FMin(Location.Z, Enemy.Location.Z) - CollisionHeight) )
				{
					NewWeight = inv.BotDesireability(self)/VSize(Inv.Location - Location);
					if ( NewWeight > BestWeight )
					{
						SecondWeight = BestWeight;
						BestWeight = NewWeight;
						SecondInv = BestInv;
						BestInv = Inv;
					}
				}

			if ( BestInv != None )
			{
				if ( TryToward(BestInv, BestWeight) )
					return;

				if ( (SecondInv != None) && TryToward(SecondInv, SecondWeight) )
					return;
			}
		}

		numHuntPaths++;

		ViewSpot = Location + BaseEyeHeight * vect(0,0,1);
		bCanSeeLastSeen = false;
		bCanSeeLastSeen = FastTrace(LastSeenPos, ViewSpot);
		if ( bCanSeeLastSeen )
			bHunting = !FastTrace(LastSeenPos, Enemy.Location);
		else
			bHunting = true;

		bCanTranslocate = ( Level.Game.IsA('DeathMatchPlus') && DeathMatchPlus(Level.Game).CanTranslocate(self) );

		if ( bDevious )
		{
			if ( BlockedPath == None )
			{
				// block the first path visible to the enemy
				if ( FindPathToward(Enemy) != None )
				{
					for ( i=0; i<16; i++ )
					{
						if ( RouteCache[i] == None )
							break;
						else if ( Enemy.LineOfSightTo(RouteCache[i]) )
						{
							BlockedPath = RouteCache[i];
							break;
						}
					}
				}
				else if ( CanStakeOut() )
				{
					GotoState('StakeOut');
					return;
				}
				else
				{
					WhatToDoNext('', '');
					return;
				}
			}
			// control path weights
			ClearPaths();
			BlockedPath.Cost = 1500;
			if ( FindBestPathToward(Enemy, false) )
				return;
		}
		else if ( FindBestPathToward(Enemy, true) )
			return;

		MoveTarget = None;
		if ( bFromWall )
		{
			bFromWall = false;
			if ( !PickWallAdjust() )
			{
				if ( CanStakeOut() )
					GotoState('StakeOut');
				else
					WhatToDoNext('', '');
			}
			return;
		}
		
		if ( (NumHuntPaths > 60) && (bNovice || !Level.Game.IsA('DeathMatchPlus') || !DeathMatchPlus(Level.Game).OneOnOne()) )
		{
			WhatToDoNext('', '');
			return;
		}

		if ( LastSeeingPos != vect(1000000,0,0) )
		{
			Destination = LastSeeingPos;
			LastSeeingPos = vect(1000000,0,0);		
			if ( FastTrace(Enemy.Location, ViewSpot) )
			{
				If (VSize(Location - Destination) < 20)
				{
					SetEnemy(Enemy);
					return;
				}
				return;
			}
		}

		bAvoidLedges = (CollisionRadius > 42);
		posZ = LastSeenPos.Z + CollisionHeight - Enemy.CollisionHeight;
		nextSpot = LastSeenPos - Normal(Enemy.Location - Enemy.OldLocation) * CollisionRadius;
		nextSpot.Z = posZ;
		if ( FastTrace(nextSpot, ViewSpot) )
			Destination = nextSpot;
		else if ( bCanSeeLastSeen )
			Destination = LastSeenPos;
		else
		{
			Destination = LastSeenPos;
			if ( !FastTrace(LastSeenPos, ViewSpot) )
			{
				// check if could adjust and see it
				if ( PickWallAdjust() || FindViewSpot() )
				{
					if ( Physics == PHYS_Falling )
						SetFall();
					else
						GotoState('Hunting', 'AdjustFromWall');
				}
				else if ( VSize(Enemy.Location - Location) < 1200 )
				{
					GotoState('StakeOut');
					return;
				}
				else
				{
					WhatToDoNext('Waiting', 'TurnFromWall');
					return;
				}
			}
		}
		LastSeenPos = Enemy.Location;				
	}	

	function bool FindViewSpot()
	{
		local vector X,Y,Z;
		local bool bAlwaysTry;

		GetAxes(Rotation,X,Y,Z);

		// try left and right
		// if frustrated, always move if possible
		bAlwaysTry = bFrustrated;
		bFrustrated = false;
		
		if ( FastTrace(Enemy.Location, Location + 2 * Y * CollisionRadius) )
		{
			Destination = Location + 2.5 * Y * CollisionRadius;
			return true;
		}

		if ( FastTrace(Enemy.Location, Location - 2 * Y * CollisionRadius) )
		{
			Destination = Location - 2.5 * Y * CollisionRadius;
			return true;
		}
		if ( bAlwaysTry )
		{
			if ( FRand() < 0.5 )
				Destination = Location - 2.5 * Y * CollisionRadius;
			else
				Destination = Location - 2.5 * Y * CollisionRadius;
			return true;
		}

		return false;
	}

	function BeginState()
	{
		//log(self$" hunting");
		SpecialGoal = None;
		SpecialPause = 0.0;
		bFromWall = false;
		SetAlertness(0.5);
	}

	function EndState()
	{
		bCanTranslocate = false;
		bAvoidLedges = false;
		bHunting = false;
		if ( JumpZ > 0 )
			bCanJump = true;
	}

AdjustFromWall:
	Enable('AnimEnd');
	StrafeTo(Destination, Focus); 
	Destination = Focus; 
	if ( MoveTarget != None )
		Goto('SpecialNavig');
	else
		Goto('Follow');

Begin:
	numHuntPaths = 0;
AfterFall:
	TweenToRunning(0.1);
	bFromWall = false;

Follow:
	if ( Level.Game.IsA('TeamGamePlus') )
		TeamGamePlus(Level.Game).FindSpecialAttractionFor(self);
	if ( bSniping )
		GotoState('StakeOut');
	if ( (Orders == 'Hold') || (Orders == 'Follow') ) 
	{
		if ( !LineOfSightTo(OrderObject) )
			GotoState('Fallback');
	}
	else if ( Orders == 'Defend' )
	{
		if ( AmbushSpot != None )
		{
			if ( !LineOfSightTo(AmbushSpot) )
				GotoState('Fallback');
		}
		else if ( !LineOfSightTo(OrderObject) )
			GotoState('Fallback');
	}
	WaitForLanding();
	if ( CanSee(Enemy) )
		SetEnemy(Enemy);
	PickDestination();
SpecialNavig:
	if ( SpecialPause > 0.0 )
	{
		Disable('AnimEnd');
		Acceleration = vect(0,0,0);
		bFire = 0;
		bAltFire = 0;
		PlayChallenge();
		Sleep(SpecialPause);
		SpecialPause = 0.0;
		Enable('AnimEnd');
		Goto('AfterFall');
	}
	if (MoveTarget == None)
		MoveTo(Destination);
	else
		MoveToward(MoveTarget); 

	Goto('Follow');
}

state StakeOut
{
ignores EnemyNotVisible; 

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
							Vector momentum, name damageType)
	{
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 )
			return;
		bFrustrated = true;
		LastSeenPos = Enemy.Location;
		if (NextState == 'TakeHit')
		{
			if (AttitudeTo(Enemy) == ATTITUDE_Fear)
			{
				NextState = 'Retreating';
				NextLabel = 'Begin';
			}
			else
			{
				NextState = 'Attacking';
				NextLabel = 'Begin';
			}
			GotoState('TakeHit'); 
		}
		else
			GotoState('Attacking');
	}

	singular function HearNoise(float Loudness, Actor NoiseMaker)
	{
		if ( SetEnemy(NoiseMaker.instigator) )
			LastSeenPos = Enemy.Location; 
	}

	function SetFall()
	{
		NextState = 'StakeOut'; 
		NextLabel = 'Begin';
		NextAnim = AnimSequence;
		GotoState('FallingState'); 
	}

	function bool SetEnemy(Pawn NewEnemy)
	{
		if (Global.SetEnemy(NewEnemy))
		{
			bReadyToAttack = true;
			DesiredRotation = Rotator(Enemy.Location - Location);
			GotoState('Attacking');
			return true;
		}
		return false;
	} 
	
	function Timer()
	{
		bReadyToAttack = true;
		Enable('Bump');
		SetTimer(1.0, false);
	}

	function rotator AdjustAim(float projSpeed, vector projStart, int aimerror, bool leadTarget, bool warnTarget)
	{
		local vector FireSpot, X,Y,Z;
		local actor HitActor;
		local vector HitLocation, HitNormal;
				
		FireSpot = LastSeenPos;
			 
		HitActor = Trace(HitLocation, HitNormal, FireSpot, ProjStart, false);
		if( HitActor != None ) 
		{
			FireSpot += 2 * Enemy.CollisionHeight * HitNormal;
			bClearShot = FastTrace(FireSpot, ProjStart);
			if ( !bClearShot )
			{
				FireSpot = LastSeenPos;
				bFire = 0;
				bAltFire = 0;
			}
		}
		
		ViewRotation = Rotator(FireSpot - ProjStart);
		return ViewRotation;
	}
	
	function bool ClearShot()
	{
		if ( Weapon.bSplashDamage && (VSize(Location - LastSeenPos) < 300) )
			return false;

		if ( !FastTrace(LastSeenPos + vect(0,0,0.9) * Enemy.CollisionHeight, Location) )
		{
			bFire = 0;
			bAltFire = 0;
			return false;
		}
		return true;
	}
	
	function FindNewStakeOutDir()
	{
		local NavigationPoint N, Best;
		local vector Dir, EnemyDir;
		local float Dist, BestVal, Val;

		EnemyDir = Normal(Enemy.Location - Location);
		for ( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
		{
			Dir = N.Location - Location;
			Dist = VSize(Dir);
			if ( (Dist < 800) && (Dist > 100) )
			{
				Val = (EnemyDir Dot Dir/Dist);
				if ( Level.Game.bTeamgame )
					Val += FRand();
				if ( (Val > BestVal) && LineOfSightTo(N) )
				{
					BestVal = Val;
					Best = N;
				}
			}
		}

		if ( Best != None )
			LastSeenPos = Best.Location + 0.5 * CollisionHeight * vect(0,0,1);			
	}
		
	function bool ContinueStakeOut()
	{
		local float relstr;

		relstr = RelativeStrength(Enemy);
		if ( (VSize(Enemy.Location - Location) > 300 + (FRand() * relstr - CombatStyle) * 350)
			 || (Level.TimeSeconds - LastSeenTime > 2.5 + FMax(-1, 3 * (FRand() + 2 * (relstr - CombatStyle))) ) || !ClearShot() )
			return false;
		else if ( CanStakeOut() )
			return true;
		else
			return false;
	}

	function BeginState()
	{

		Acceleration = vect(0,0,0);
		bClearShot = ClearShot();
		bCanJump = false;
		bReadyToAttack = true;
		SetAlertness(0.5);
		RealLastSeenPos = LastSeenPos;
		if ( !bClearShot || ((Level.TimeSeconds - LastSeenTime > 6) && (FRand() < 0.5)) )
			FindNewStakeOutDir();
	}

	function EndState()
	{
		LastSeenPos = RealLastSeenPos;
		if ( JumpZ > 0 )
			bCanJump = true;
	}

Begin:
	if ( AmbushSpot == None )
		bSniping = false;
	if ( (bSniping && (VSize(Location - AmbushSpot.Location) > 3 * CollisionRadius)) 
		|| (Level.Game.IsA('DeathMatchPlus') && DeathMatchPlus(Level.Game).NeverStakeOut(self)) )
	{
		Enemy = None;
		OldEnemy = None;
		WhatToDoNext('','');
	}
	Acceleration = vect(0,0,0);
	PlayChallenge();
	TurnTo(LastSeenPos);
	if ( Enemy == None )
		WhatToDoNext('','');
	if ( (Weapon != None) && !Weapon.bMeleeWeapon && (FRand() < 0.5) && (VSize(Enemy.Location - LastSeenPos) < 150) 
		 && ClearShot() && CanStakeOut() )
		PlayRangedAttack();
	else
	{
		bFire = 0;
		bAltFire = 0;
	}
	FinishAnim();
	if ( !bNovice || (FRand() < 0.65) )
		TweenToWaiting(0.17);
	else
		PlayChallenge();
	Sleep(1 + FRand());
	if ( Level.Game.IsA('TeamGamePlus') )
		TeamGamePlus(Level.Game).FindSpecialAttractionFor(self);
	if ( ContinueStakeOut() )
	{
		if ( bSniping && (AmbushSpot != None) )
			LastSeenPos = Location + Ambushspot.lookdir;
		else if ( (FRand() < 0.3) || !FastTrace(LastSeenPos + vect(0,0,0.9) * Enemy.CollisionHeight, Location + vect(0,0,0.8) * CollisionHeight) )
			FindNewStakeOutDir();
		Goto('Begin');
	}
	else
	{
		if ( bSniping )
			WhatToDoNext('','');
		BlockedPath = None;	
		bDevious = ( !bNovice && !Level.Game.bTeamGame && Level.Game.IsA('DeathMatchPlus') 
					&& (FRand() < 0.75 - 0.15 * DeathMatchPlus(Level.Game).NumBots) );
		GotoState('Hunting', 'AfterFall');
	}
}

state TakeHit 
{
ignores seeplayer, hearnoise, bump, hitwall;

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, name damageType)
	{
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
	}

	function Landed(vector HitNormal)
	{
		if (Velocity.Z < -1.4 * JumpZ)
			MakeNoise(-0.5 * Velocity.Z/(FMax(JumpZ, 150.0)));
		bJustLanded = true;
	}

	function Timer()
	{
		bReadyToAttack = true;
	}

	function PlayHitAnim(vector HitLocation, float Damage)
	{
		if ( LastPainTime - Level.TimeSeconds > 0.1 )
		{
			PlayTakeHit(0.1, hitLocation, Damage);
			BeginState();
			GotoState('TakeHit', 'Begin');
		} 
	}	

	function BeginState()
	{
		LastPainTime = Level.TimeSeconds;
		LastPainAnim = AnimSequence;
		if ( (NextState == 'TacticalMove') && (Region.Zone.ZoneGravity.Z > Region.Zone.Default.ZoneGravity.Z) )
			Destination = location;
	}
		
Begin:
	if ( bFireFalling )
	{
		bFireFalling = false;
		GotoState('FallingState', 'Ducking');
	}
	FinishAnim();
	if ( bNovice || (Skill < 2) )
		Sleep(0.05);
	if ( (Physics == PHYS_Falling) && !Region.Zone.bWaterZone )
	{
		NextAnim = '';
		GotoState('FallingState', 'Ducking');
	}
	else if (NextState != '')
		GotoState(NextState, NextLabel);
	else
		GotoState('Attacking');
}

state ImpactJumping
{
	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
							Vector momentum, name damageType)
	{
		local name RealState, RealLabel;

		RealState = NextState;
		RealLabel = NextLabel;
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 )
			return;
		if ( (Enemy != None) && (Enemy == InstigatedBy) )
		{
			LastSeenPos = Enemy.Location;
			LastSeenTime = Level.TimeSeconds;
		}
		NextState = RealState;
		NextLabel = RealLabel;
		MoveTarget = None;
		bJumpOffPawn = true;
		bImpactJumping = true;
		GotoState('fallingstate');
	}

	function vector ImpactLook()
	{
		local vector result;
		
		result = 1000 * Normal(ImpactTarget.Location - Location);
		result.Z = Location.Z - 400;
		return Result;
	}
	
	function AnimEnd()
	{
		bFire = 1;
		PlayWaiting();
		bFire = 0;
	}
				
	function ChangeToHammer()
	{
		local Inventory MyHammer;

		MyHammer = FindInventoryType(class'ImpactHammer');
		if ( MyHammer == None )
		{
			GotoState('NextState', 'NextLabel');
			return;
		}
		PendingWeapon = Weapon(MyHammer);
		PendingWeapon.AmbientSound = ImpactHammer(MyHammer).TensionSound;
		PendingWeapon.SetLocation(Location);
		if ( Weapon == None )
			ChangedWeapon();
		else if ( Weapon != PendingWeapon )
			Weapon.PutDown();
	}

	function EndState()
	{
		local Inventory MyHammer;
		MyHammer = FindInventoryType(class'ImpactHammer');
		if ( MyHammer != None )
			MyHammer.AmbientSound = None;
	}


Begin:
	Acceleration = vect(0,0,0);
	if ( !Weapon.IsA('ImpactHammer') )
		ChangeToHammer();
	else
	{
		Weapon.SetLocation(Location);
		Weapon.AmbientSound = ImpactHammer(Weapon).TensionSound;
	}
	TweenToWaiting(0.2);
	TurnTo(ImpactLook());
	CampTime = Level.TimeSeconds;
	While ( !Weapon.IsA('ImpactHammer') && (Level.TimeSeconds - Camptime < 2.0) )
		Sleep(0.1);
	CampTime = 1.0;
	Sleep(0.5);
	MakeNoise(1.0);	
	if ( Physics != PHYS_Falling )
	{
		Velocity = ImpactTarget.Location - Location;
		Velocity.Z = 320;
		Velocity = Default.GroundSpeed * Normal(Velocity);
		TakeDamage(36.0, self, Location, 69000.0 * 1.5 * vect(0,0,1), Weapon.MyDamageType);
	}
	GotoState(NextState, NextLabel);
}

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

	function AnimEnd()
	{
		PlayInAir();
	}

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

		PlaySound(JumpSound, SLOT_Talk, 1.5, true, 1200, 1.0 );
		Velocity = FullVel;
		Velocity.Z = Default.JumpZ + velZ;
		Velocity = EAdjustJump();
	}

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
							Vector momentum, name damageType)
	{
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);

		if (Enemy == None)
		{
			SetEnemy(instigatedBy);
			if ( Enemy != None )
			{ 
				NextState = 'Attacking'; 
				NextLabel = 'Begin';
			}
		}
		if ( (Enemy != None) && (instigatedBy == Enemy) )
		{
			LastSeenTime = Level.TimeSeconds;
			LastSeenPos = Enemy.Location;
		}
		if (NextState == 'TakeHit')
		{
			NextState = 'Attacking'; 
			NextLabel = 'Begin';
			GotoState('TakeHit'); 
		}
	}

	function bool SetEnemy(Pawn NewEnemy)
	{
		local bool result;
		result = false;
		if ( Global.SetEnemy(NewEnemy))
		{
			result = true;
			NextState = 'Attacking'; 
			NextLabel = 'Begin';
		}
		return result;
	} 

	function Timer()
	{
		if ( Enemy != None )
		{
			bReadyToAttack = true;
			if ( CanFireAtEnemy() )
				GotoState('FallingState', 'FireWhileFalling');
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
	
	function SeePlayer(Actor SeenPlayer)
	{
		Global.SeePlayer(SeenPlayer);
		disable('SeePlayer');
		disable('HearNoise');
	}

	function EnemyNotVisible()
	{
		enable('SeePlayer');
		enable('HearNoise');
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
		bUpAndOut = false;
		bJumpOffPawn = false;
		bBigJump = false;
		if ( bImpactJumping )
		{
			bImpactJumping = false;
			SwitchToBestWeapon();
		}
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
	if ( CanFireAtEnemy() )
		FireWeapon();
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
		if ( CanFireAtEnemy() )
		{
			PlayRangedAttack();
		}
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
	//log("Playing"@animsequence@"at"@animframe);
	Disable('AnimEnd');
	FinishAnim();
	//log("Finished"@animsequence@"at"@animframe);
Done:
	//log("After fall"@NextState@NextLabel);
	if ( NextAnim == '' )
	{
		bUpAndOut = false;
		if ( (NextState != '') && (NextState != 'FallingState') )
			GotoState(NextState, NextLabel);
		else 
			GotoState('Attacking');
	}
	if ( !bUpAndOut )
	{
		if ( NextAnim == 'Fighter' )
			TweenToFighter(0.2);
		else
			TweenAnim(NextAnim, 0.12);
	} 

Splash:
	bUpAndOut = false;
	if ( NextState != '' )
		GotoState(NextState, NextLabel);
	else 
		GotoState('Attacking');
			
Begin:
	if (Enemy == None)
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
		if ( (Velocity.Z > 300) && (MoveTarget != None)
			&& ((FRand() < 0.13) || ((Region.Zone.ZoneGravity.Z > Region.Zone.Default.ZoneGravity.Z) && (FRand() < 0.2)))
			&& (VSize(Destination - Location) > 160)
			&& ((Vector(Rotation) Dot (Destination - Location)) > 0) )
			PlayFlip();
		else
			TweenToFalling();
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
		if ( bBigJump )
		{
			While( bBigJump )
			{
				Sleep(0.25);
				Acceleration = AccelRate * Normal(Destination - Location);
			}
		}
		else
		{
			Sleep(0.2);
			While ( (Abs(Velocity.X) < 60) && (Abs(Velocity.Y) < 60) )
				Sleep(0.1);
			Acceleration = vect(0,0,0);
			Sleep(1.5);
		}
		bBigJump = false;
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

state RangedAttack
{
ignores SeePlayer, HearNoise, Bump;

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, name damageType)
	{
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 )
			return;
		if (NextState == 'TakeHit')
		{
			NextState = 'RangedAttack';
			NextLabel = 'Begin';
		}
	}

	function StopFiring()
	{
		Super.StopFiring();
		GotoState('Attacking');
	}

	function StopWaiting()
	{
		Timer();
	}

	function EnemyNotVisible()
	{
		////log("enemy not visible");
		//let attack animation complete
		if ( bComboPaused || bFiringPaused )
			return;
		if ( (Weapon == None) || Weapon.bMeleeWeapon
			|| (FRand() < 0.13) )
		{
			bReadyToAttack = true;
			GotoState('Attacking');
			return;
		}
	}

	function KeepAttacking()
	{
		local TranslocatorTarget T;
		local int BaseSkill;

		if ( bComboPaused || bFiringPaused )
		{
			if ( TimerRate <= 0.0 )
			{
				TweenToRunning(0.12);
				GotoState(NextState, NextLabel);
			}
			if ( bComboPaused )
				return;

			T = TranslocatorTarget(Target);
			if ( (T != None) && !T.Disrupted() && LineOfSightTo(T) )
				return;
			if ( (Enemy == None) || (Enemy.Health <= 0) || !LineOfSightTo(Enemy) )
			{
				bFire = 0;
				bAltFire = 0; 
				TweenToRunning(0.12);
				GotoState(NextState, NextLabel);
			}
		}
		if ( (Enemy == None) || (Enemy.Health <= 0) || !LineOfSightTo(Enemy) )
		{
			bFire = 0;
			bAltFire = 0; 
			GotoState('Attacking');
			return;
		}
		if ( (Weapon != None) && Weapon.bMeleeWeapon )
		{
			bReadyToAttack = true;
			GotoState('TacticalMove');
			return;
		}
		BaseSkill = Skill;
		if ( !bNovice )
			BaseSkill += 3;
		if ( (Enemy.Weapon != None) && Enemy.Weapon.bMeleeWeapon 
			&& (VSize(Enemy.Location - Location) < 500) )
			BaseSkill += 3;
		if ( (BaseSkill > 3 * FRand() + 2)
			|| ((bFire == 0) && (bAltFire == 0) && (BaseSkill > 6 * FRand() - 1)) )
		{
			bReadyToAttack = true;
			GotoState('TacticalMove');
		}
	}

	function Timer()
	{
		if ( bComboPaused || bFiringPaused )
		{
			TweenToRunning(0.12);
			GotoState(NextState, NextLabel);
		}
	}

	function AnimEnd()
	{
		local float decision;

		if ( (Weapon == None) || Weapon.bMeleeWeapon
			|| ((bFire == 0) && (bAltFire == 0)) )
		{
			GotoState('Attacking');
			return;
		}
		decision = FRand() - 0.2 * skill;
		if ( !bNovice )
			decision -= 0.5;
		if ( decision < 0 )
			GotoState('RangedAttack', 'DoneFiring');
		else
		{
			PlayWaiting();
			FireWeapon();
		}
	}
	
	// ASMD combo move
	function SpecialFire()
	{
		if ( Enemy == None )
			return;
		bComboPaused = true;
		SetTimer(0.75 + VSize(Enemy.Location - Location)/Weapon.AltProjectileSpeed, false);
		SpecialPause = 0.0;
		NextState = 'Attacking';
		NextLabel = 'Begin'; 
	}
	
	function BeginState()
	{
		Disable('AnimEnd');
		if ( bComboPaused || bFiringPaused )
		{
			SetTimer(SpecialPause, false);
			SpecialPause = 0;
		}
		else
			Target = Enemy;
	}
	
	function EndState()
	{
		bFiringPaused = false;
		bComboPaused = false;
	}

Challenge:
	Disable('AnimEnd');
	Acceleration = vect(0,0,0); //stop
	DesiredRotation = Rotator(Enemy.Location - Location);
	PlayChallenge();
	FinishAnim();
	TweenToFighter(0.1);
	Goto('FaceTarget');

Begin:
	if ( Target == None )
	{
		Target = Enemy;
		if ( Target == None )
			GotoState('Attacking');
	}
	Acceleration = vect(0,0,0); //stop
	DesiredRotation = Rotator(Target.Location - Location);
	TweenToFighter(0.16 - 0.2 * Skill);
	
FaceTarget:
	Disable('AnimEnd');
	if ( NeedToTurn(Target.Location) )
	{
		PlayTurning();
		TurnToward(Target);
		TweenToFighter(0.1);
	}
	FinishAnim();

ReadyToAttack:
	DesiredRotation = Rotator(Target.Location - Location);
	PlayRangedAttack();
	if ( Weapon.bMeleeWeapon )
		GotoState('Attacking');
	Enable('AnimEnd');
Firing:
	if ( Target == None )
		GotoState('Attacking');
	TurnToward(Target);
	Goto('Firing');
DoneFiring:
	Disable('AnimEnd');
	KeepAttacking();  
	Goto('FaceTarget');
}

state VictoryDance
{
ignores EnemyNotVisible; 

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
							Vector momentum, name damageType)
	{
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 )
			return;
		SetEnemy(instigatedBy);
		if ( Enemy == None )
			return;
		if ( NextState == 'TakeHit' )
		{
			NextState = 'Attacking'; //default
			NextLabel = 'Begin';
			GotoState('TakeHit'); 
		}
		else if (health > 0)
			GotoState('Attacking');
	}

	function EnemyAcquired()
	{
		GotoState('Acquisition');
	}
	
	function BeginState()
	{
		SpecialGoal = None;
		SpecialPause = 0.0;
		SetAlertness(-0.3);
	}

Begin:
	Acceleration = vect(0,0,0);
	TweenToFighter(0.2);
	FinishAnim();
	PlayTurning();
	TurnToward(Target);
	DesiredRotation = rot(0,0,0);
	DesiredRotation.Yaw = Rotation.Yaw;
	setRotation(DesiredRotation);
	TweenToFighter(0.2);
	FinishAnim();
	PlayVictoryDance();
	FinishAnim(); 
	WhatToDoNext('Waiting','TurnFromWall');
}

state GameEnded
{
ignores SeePlayer, EnemyNotVisible, HearNoise, TakeDamage, Died, Bump, Trigger, HitWall, HeadZoneChange, FootZoneChange, ZoneChange, Falling, WarnTarget, PainTimer;

	function SpecialFire()
	{
	}
	function TryToDuck(vector duckDir, bool bReversed)
	{
	}
	function SetFall()
	{
	}
	function LongFall()
	{
	}
	function Killed(pawn Killer, pawn Other, name damageType)
	{
	}
	function ClientDying(name DamageType, vector HitLocation)
	{
	}

	function BeginState()
	{
		AnimRate = 0.0;
		bFire = 0;
		bAltFire = 0;
		SimAnim.Y = 0;
		SetCollision(false,false,false);
		SetPhysics(PHYS_None);
		Velocity = vect(0,0,0);
	}
}

state Dying
{
ignores SeePlayer, EnemyNotVisible, HearNoise, Died, Bump, Trigger, HitWall, HeadZoneChange, FootZoneChange, ZoneChange, Falling, WarnTarget, LongFall, SetFall, PainTimer;

	function ReStartPlayer()
	{
		if( bHidden && Level.Game.RestartPlayer(self) )
		{
			if ( bNovice )
				bDumbDown = ( FRand() < 0.5 );
			else
				bDumbDown = ( FRand() < 0.35 );
			Velocity = vect(0,0,0);
			Acceleration = vect(0,0,0);
			ViewRotation = Rotation;
			ReSetSkill();
			SetPhysics(PHYS_Falling);
			SetOrders(BotReplicationInfo(PlayerReplicationInfo).RealOrders, BotReplicationInfo(PlayerReplicationInfo).RealOrderGiver, true);
			GotoState('Roaming');
		}
		else if ( !IsInState('GameEnded') )
			GotoState('Dying', 'TryAgain');
	}
	
	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
							Vector momentum, name damageType)
	{
		if ( !bHidden )
			Super.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
	}
	
	function BeginState()
	{
		if ( (Level.NetMode != NM_Standalone) 
			&& Level.Game.IsA('DeathMatchPlus')
			&& DeathMatchPlus(Level.Game).TooManyBots() )
		{
			Destroy();
			return;
		}
		SetTimer(0, false);
		Enemy = None;
		if ( bSniping && (AmbushSpot != None) )
			AmbushSpot.taken = false;
		AmbushSpot = None;
		PointDied = -1000;
		bFire = 0;
		bAltFire = 0;
		bSniping = false;
		bKamikaze = false;
		bDevious = false;
		bDumbDown = false;
		BlockedPath = None;
		bInitLifeMessage = false;
		MyTranslocator = None;
	}


Begin:
	if ( Level.Game.bGameEnded )
		GotoState('GameEnded');
	Sleep(0.2);
	if ( !bHidden )
		SpawnCarcass();
TryAgain:
	if ( !bHidden )
		HidePlayer();
	Sleep(0.25 + DeathMatchPlus(Level.Game).SpawnWait(self));
	ReStartPlayer();
	Goto('TryAgain');
WaitingForStart:
	bHidden = true;
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

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, name damageType)
	{
		Super.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 )
			return;
		if ( NextState == 'TakeHit' )
		{
			NextState = 'FindAir'; 
			NextLabel = 'TakeHit';
			GotoState('TakeHit'); 
		}
	}

	function HitWall(vector HitNormal, actor Wall)
	{
		//change directions
		Destination = 200 * (Normal(Destination - Location) + HitNormal);
	}

	function AnimEnd() 
	{
		if (Enemy != None)
			PlayCombatMove();
		else if ( (Physics == PHYS_Falling) && (Velocity.Z < -300) )
			FastInAir();
		else
			PlayRunning();
	}

	function Timer()
	{
		bReadyToAttack = True;
		settimer(0.5, false);
	}

	function EnemyNotVisible()
	{
		////log("enemy not visible");
		bReadyToAttack = false;
	}

/* PickDestination()
*/
	function PickDestination(bool bNoCharge)
	{
		Destination = VRand();
		Destination.Z = 1;
		Destination = Location + 200 * Destination;				
	}

Begin:
	//log("Find air");
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
	GotoState('Attacking');

TakeHit:
	TweenToRunning(0.12);
	Goto('DoMove');

}

/* Skin Stuff */
static function GetMultiSkin( Actor SkinActor, out string SkinName, out string FaceName )
{
	local string ShortSkinName, FullSkinName, ShortFaceName, FullFaceName;

	FullSkinName  = String(SkinActor.Multiskins[default.FixedSkin]);
	ShortSkinName = SkinActor.GetItemName(FullSkinName);

	FullFaceName = String(SkinActor.Multiskins[default.FaceSkin]);
	ShortFaceName = SkinActor.GetItemName(FullFaceName);

	SkinName = Left(FullSkinName, Len(FullSkinName) - Len(ShortSkinName)) $ Left(ShortSkinName, 4);
	FaceName = Left(FullFaceName, Len(FullFaceName) - Len(ShortFaceName)) $Mid(ShortFaceName, 5);
}

static function SetMultiSkin(Actor SkinActor, string SkinName, string FaceName, byte TeamNum)
{
	local string MeshName, FacePackage, SkinItem, FaceItem, SkinPackage;

	MeshName = SkinActor.GetItemName(string(SkinActor.Mesh));

	SkinItem = SkinActor.GetItemName(SkinName);
	FaceItem = SkinActor.GetItemName(FaceName);
	FacePackage = Left(FaceName, Len(FaceName) - Len(FaceItem));
	SkinPackage = Left(FaceName, Len(SkinName) - Len(SkinItem));

	if(SkinPackage == "")
	{
		SkinPackage=default.DefaultPackage;
		SkinName=SkinPackage$SkinName;
	}
	if(FacePackage == "")
	{
		FacePackage=default.DefaultPackage;
		FaceName=FacePackage$FaceName;
	}
	// Set the fixed skin element.  If it fails, go to default skin & no face.
	if(!SetSkinElement(SkinActor, default.FixedSkin, SkinName$string(default.FixedSkin+1), default.DefaultSkinName$string(default.FixedSkin+1)))
	{
		SkinName = default.DefaultSkinName;
		FaceName = "";
	}

	// Set the face - if it fails, set the default skin for that face element.
	SetSkinElement(SkinActor, default.FaceSkin, FacePackage$SkinItem$String(default.FaceSkin+1)$FaceItem, SkinName$String(default.FaceSkin+1));
	// Set the team elements
	if( TeamNum != 255 )
	{
		SetSkinElement(SkinActor, default.TeamSkin1, SkinName$string(default.TeamSkin1+1)$"T_"$String(TeamNum), SkinName$string(default.TeamSkin1+1));
		SetSkinElement(SkinActor, default.TeamSkin2, SkinName$string(default.TeamSkin2+1)$"T_"$String(TeamNum), SkinName$string(default.TeamSkin2+1));
	}
	else
	{
		SetSkinElement(SkinActor, default.TeamSkin1, SkinName$string(default.TeamSkin1+1), "");
		SetSkinElement(SkinActor, default.TeamSkin2, SkinName$string(default.TeamSkin2+1), "");
	}
	// Set the talktexture
	if(Pawn(SkinActor) != None)
	{
		if(FaceName != "")
			Pawn(SkinActor).PlayerReplicationInfo.TalkTexture = Texture(DynamicLoadObject(FacePackage$SkinItem$"5"$FaceItem, class'Texture'));
		else
			Pawn(SkinActor).PlayerReplicationInfo.TalkTexture = None;
	}
}

defaultproperties
{
	 PointDied=-1000.0
	 PlayerReplicationInfoClass=Class'Botpack.BotreplicationInfo'
	 VoiceType="BotPack.VoiceMaleTwo"
	 bIsPlayer=true
     CarcassType=Class'Engine.Carcass'
     TimeBetweenAttacks=0.600000
     WalkingSpeed=0.350000
	 bVerbose=false
     bLeadTarget=True
     HearingThreshold=0.300000
     Land=Sound'UnrealShare.Generic.Land1'
     WaterStep=Sound'UnrealShare.Generic.LSplash'
     SightRadius=+05000.000000
     Aggressiveness=+00000.30000
     BaseAggressiveness=+00000.30000
     ReFireRate=+00000.900000
     BaseEyeHeight=+00023.000000
     EyeHeight=+00023.000000
     UnderWaterTime=+00020.000000
     bCanStrafe=True
	 bAutoActivate=True
     MeleeRange=+00040.000000
     Intelligence=BRAINS_HUMAN
     GroundSpeed=+00400.000000
     AirSpeed=+00400.000000
	 AirControl=+0.35
     AccelRate=+02048.000000
     MaxStepHeight=+00025.000000
     CombatStyle=+00000.10000
     DrawType=DT_Mesh
     LightBrightness=70
     LightHue=40
     LightSaturation=128
     LightRadius=6
	 bStasis=false
     Buoyancy=+00100.000000
     RotationRate=(Pitch=3072,Yaw=30000,Roll=2048)
     NetPriority=+00003.000000
	 bIsMultiSkinned=True
	 StatusDoll=texture'Botpack.Man'
	 StatusBelt=texture'Botpack.ManBelt'
	 VoicePackMetaClass="BotPack.ChallengeVoicePack"
	 AmbientGlow=17
}

