//=============================================================================
// Commander - a spectator who controls a team
//=============================================================================
class Commander extends TournamentPlayer
	config(User);

var bool bChaseCam;

function PostBeginPlay()
{
	if (Level.LevelEnterText != "" )
		ClientMessage(Level.LevelEnterText);
	bIsPlayer = true;
	FlashScale = vect(1,1,1);
	if ( Level.NetMode != NM_Client )
	{
		ScoringType = Level.Game.ScoreboardType;
		HUDType = Level.Game.HUDType;
	}
	PlayerReplicationInfo.bIsSpectator = true;
}

exec function Loaded()
{
}

function PlayDodge(eDodgeDir DodgeMove)
{
}

function PlayDyingSound()
{
}

simulated function PlayBeepSound()
{
	PlaySound(sound'NewBeep',SLOT_Interface, 2.0);
}

function PlayChatting()
{
}

function PlayWaiting()
{
}

/* Skin Stuff */
static function GetMultiSkin( Actor SkinActor, out string SkinName, out string FaceName )
{
}

static function SetMultiSkin(Actor SkinActor, string SkinName, string FaceName, byte TeamNum)
{
}

simulated function PlayFootStep()
{
}

function PlayHit(float Damage, vector HitLocation, name damageType, vector Momentum)
{
}

function PlayDeathHit(float Damage, vector HitLocation, name damageType, vector Momentum)
{
}

//-----------------------------------------------------------------------------
// Sound functions

function PlayTakeHitSound(int damage, name damageType, int Mult)
{
}

function ClientPlayTakeHit(vector HitLoc, byte Damage, bool bServerGuessWeapon)
{
}	

function Gasp()
{
}

//-----------------------------------------------------------------------------
// Animation functions

function PlayTurning()
{
}

function TweenToWalking(float tweentime)
{
}

function PlayWalking()
{
}

function TweenToRunning(float tweentime)
{
}

function PlayRunning()
{
}

function PlayRising()
{
}

function PlayFeignDeath()
{
}

function PlayGutHit(float tweentime)
{
}

function PlayHeadHit(float tweentime)
{
}

function PlayLeftHit(float tweentime)
{
}

function PlayRightHit(float tweentime)
{
}
	
function PlayLanded(float impactVel)
{	
}
	
function PlayInAir()
{
}

function PlayDuck()
{
}

function PlayCrawling()
{
}

function TweenToWaiting(float tweentime)
{
}
	
function PlayRecoil(float Rate)
{
}

function PlayFiring()
{
}

function PlayWeaponSwitch(Weapon NewWeapon)
{
}

function PlaySwimming()
{
}

function TweenToSwimming(float tweentime)
{
}

event FootZoneChange(ZoneInfo newFootZone)
{
}
	
event HeadZoneChange(ZoneInfo newHeadZone)
{
}

exec function Walk()
{	
}

exec function ActivateItem()
{
	bBehindView = !bBehindView;
	bChaseCam = bBehindView;
}

exec function BehindView( Bool B )
{
	bBehindView = B;
	bChaseCam = bBehindView;
}

function ChangeTeam( int N )
{
	Level.Game.ChangeTeam(self, N);
}

exec function Taunt( name Sequence )
{
}

exec function CallForHelp()
{
}

exec function ThrowWeapon()
{
}

exec function Suicide()
{
}

exec function Fly()
{
}

function StartWalk()
{
	bCollideWorld = true;
	ClientReStart();	
}

function ServerChangeSkin( coerce string SkinName, coerce string FaceName, byte TeamNum )
{
}

function ClientReStart()
{
	Velocity = vect(0,0,0);
	Acceleration = vect(0,0,0);
	BaseEyeHeight = Default.BaseEyeHeight;
	EyeHeight = BaseEyeHeight;
	
	GotoState(PlayerReStartState);
}

// This pawn was possessed by a player.
function Possess()
{
	bIsPlayer = true;
	EyeHeight = BaseEyeHeight;
	NetPriority = 2;
	Weapon = None;
	Inventory = None;
	bCollideWorld = true;
	ClientReStart();	
}

function PlayerTimeOut()
{
	if (Health > 0)
		Died(None, 'dropped', Location);
}

exec function Grab()
{
}

function InitPlayerReplicationInfo()
{
	Super.InitPlayerReplicationInfo();
	PlayerReplicationInfo.bIsSpectator = true;
}

exec function RestartLevel()
{
}

//=============================================================================
// Inventory-related input notifications.

// The player wants to switch to weapon group numer I.
exec function SwitchWeapon (byte F )
{
}

exec function NextItem()
{
}

exec function PrevItem()
{
}

exec function Fire( optional float F )
{
	ViewPlayerNum(-1);

	bBehindView = bChaseCam && (ViewTarget != None);
}

// The player wants to alternate-fire.
exec function AltFire( optional float F )
{
	bBehindView = false;
	Viewtarget = None;
	ClientMessage("Now viewing from own camera", 'Event', true);
}

//=================================================================================

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, name damageType)
{
}

state PlayerWaiting
{
ignores SeePlayer, HearNoise, Bump, TakeDamage, Died, ZoneChange, FootZoneChange;


	function EndState()
	{
		PlayerReplicationInfo.bWaitingPlayer = false;
	}
}

state CheatFlying
{
ignores SeePlayer, HearNoise, Bump, TakeDamage;

	function BeginState()
	{
		Super.BeginState();
		SetCollision(false,false,false);
	}
}

defaultproperties
{
	 PlayerRestartState=CheatFlying
	 bIsMultiSkinned=False
     AirSpeed=+00600.000000
     Visibility=0
     AttitudeToPlayer=ATTITUDE_Friendly
	 bHidden=true
	 bChaseCam=true
     bCollideActors=False
     bCollideWorld=False
     bBlockActors=False
     bBlockPlayers=False
     bProjTarget=False
	 Menuname="Commander"
     DrawType=DT_None
}

