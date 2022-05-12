//=============================================================================
// TournamentPlayer.
//=============================================================================
class TournamentPlayer extends PlayerPawn
	config(User)
	abstract;

#exec AUDIO IMPORT FILE="Sounds\chatsound\chat8a.WAV" NAME="NewBeep" GROUP="ChatSound"
#exec AUDIO IMPORT FILE="Sounds\chatsound\spree-sound.WAV" NAME="SpreeSound" GROUP="ChatSound"

#exec TEXTURE IMPORT NAME=Man FILE=TEXTURES\HUD\IMale2.PCX GROUP="Icons" MIPS=OFF
#exec TEXTURE IMPORT NAME=ManBelt FILE=TEXTURES\HUD\IMaleSBelt.PCX GROUP="Icons" MIPS=OFF

var(Messages)	localized string spreenote[10];
var(Sounds)		Sound Deaths[6];
var int			FaceSkin;
var int			FixedSkin;
var int			TeamSkin1;
var int			TeamSkin2;
var int			MultiLevel;
var string		DefaultSkinName;
var string		DefaultPackage;
var float		LastKillTime;

var(Sounds) sound 	drown;
var(Sounds) sound	breathagain;
var(Sounds) sound	Footstep1;
var(Sounds) sound	Footstep2;
var(Sounds) sound	Footstep3;
var(Sounds) sound	HitSound3;
var(Sounds) sound	HitSound4;
var(Sounds) sound	Die2;
var(Sounds) sound	Die3;
var(Sounds) sound	Die4;
var(Sounds) sound	GaspSound;
var(Sounds) sound	UWHit1;
var(Sounds) sound	UWHit2;
var(Sounds) sound	LandGrunt;

var bool bLastJumpAlt;
var  globalconfig bool bInstantRocket;
var	 globalconfig bool bAutoTaunt; // player automatically generates taunts when fragging someone
var	 globalconfig bool bNoAutoTaunts; // don't receive auto-taunts
var  globalconfig bool bNoVoiceTaunts; // don't receive any taunts
var  globalconfig bool bNoMatureLanguage;
var  globalconfig bool bNoVoiceMessages; // don't receive any voice messages
var bool bNeedActivate;
var bool b3DSound;

var int WeaponUpdate;

// HUD status 
var texture StatusDoll, StatusBelt;

// allowed voices
var string VoicePackMetaClass;

var NavigationPoint StartSpot; //where player started the match

var Weapon ClientPending;
var Weapon OldClientWeapon;

var globalconfig int AnnouncerVolume;
var class<CriticalEventPlus> TimeMessageClass;

var class<Actor> BossRef;

replication
{
	// Things the server should send to the client.
	unreliable if( Role==ROLE_Authority )
		ClientPlayTakeHit, TimeMessage;
	reliable if ( Role == ROLE_Authority )
		SendClientFire, SendClientAltFire, RealWeapon, PlayWinMessage; 

	// client to server
	reliable if ( Role < ROLE_Authority )
		Advance, AdvanceAll, ServerSetTaunt, ServerSetInstantRocket, ServerSetVoice, IAmTheOne;
}

function PlayWinMessage(bool bWinner)
{
	local sound Announcement;

	if ( bWinner )
		Announcement = Sound(DynamicLoadObject("Announcer.Winner", class'Sound'));
	else
		Announcement = Sound(DynamicLoadObject("Announcer.LostMatch", class'Sound'));

	ClientPlaySound(Announcement, true, true);
}

//Player Jumped
function DoJump( optional float F )
{
	if ( CarriedDecoration != None )
		return;
	if ( !bIsCrouching && (Physics == PHYS_Walking) )
	{
		if ( !bUpdating )
			PlayOwnedSound(JumpSound, SLOT_Talk, 1.5, true, 1200, 1.0 );
		if ( (Level.Game != None) && (Level.Game.Difficulty > 0) )
			MakeNoise(0.1 * Level.Game.Difficulty);
		PlayInAir();
		if ( bCountJumps && (Role == ROLE_Authority) && (Inventory != None) )
			Inventory.OwnerJumped();
		if ( bIsWalking )
			Velocity.Z = Default.JumpZ;
		else
			Velocity.Z = JumpZ;
		if ( (Base != Level) && (Base != None) )
			Velocity.Z += Base.Velocity.Z; 
		SetPhysics(PHYS_Falling);
	}
}
//Play a sound client side (so only client will hear it
simulated function ClientPlaySound(sound ASound, optional bool bInterrupt, optional bool bVolumeControl )
{	
	local actor SoundPlayer;
	local int Volume;

	if ( b3DSound )
		Volume = 1;
	else if ( bVolumeControl )
		Volume = AnnouncerVolume;
	else
		Volume = 4;

	LastPlaySound = Level.TimeSeconds;	// so voice messages won't overlap
	if ( ViewTarget != None )
		SoundPlayer = ViewTarget;
	else
		SoundPlayer = self;

	if ( Volume == 0 )
		return;
	SoundPlayer.PlaySound(ASound, SLOT_None, 16.0, bInterrupt);
	if ( Volume == 1 )
		return;
	SoundPlayer.PlaySound(ASound, SLOT_Interface, 16.0, bInterrupt);
	if ( Volume == 2 )
		return;
	SoundPlayer.PlaySound(ASound, SLOT_Misc, 16.0, bInterrupt);
	if ( Volume == 3 )
		return;
	SoundPlayer.PlaySound(ASound, SLOT_Talk, 16.0, bInterrupt);
}

//==============
// Encroachment
event bool EncroachingOn( actor Other )
{
	if ( GameReplicationInfo.bTeamGame && Other.bIsPawn 
		&& (Pawn(Other).PlayerReplicationInfo != None)
		&& (Pawn(Other).PlayerReplicationInfo.Team == PlayerReplicationInfo.Team) )
	{
		if ( (Role == ROLE_Authority) && Level.Game.IsA('DeathMatchPlus')
			&& DeathMatchPlus(Level.Game).bStartMatch )
			return Super.EncroachingOn(Other);
		else
			return true;
	}
	return Super.EncroachingOn(Other);
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	if ( Level.NetMode != NM_DedicatedServer )
		Shadow = Spawn(class'PlayerShadow',self);
	if ( (Role == ROLE_Authority) && (Level.NetMode != NM_Standalone) )
		BossRef = class<Actor>(DynamicLoadObject("Botpack.TBoss",class'Class'));

	b3DSound = bool(ConsoleCommand("get ini:Engine.Engine.AudioDevice Use3dHardware"));
}

function ClientReplicateSkins(texture Skin1, optional texture Skin2, optional texture Skin3, optional texture Skin4)
{
	local class<Actor> C;

	// do nothing (just loading other player skins onto client)
	log("Getting "$Skin1$", "$Skin2$", "$Skin3$", "$Skin4);
	if ( Role != ROLE_Authority )
		BossRef = class<Actor>(DynamicLoadObject("Botpack.TBoss",class'Class'));
}

function PreCacheReferences()
{
	//never called - here to force precaching of meshes
	spawn(class'TMale1');
	spawn(class'TMale2');
	spawn(class'TFemale1');
	spawn(class'TFemale2');
	spawn(class'ImpactHammer');
	spawn(class'Translocator');
	spawn(class'Enforcer');
	spawn(class'UT_Biorifle');
	spawn(class'ShockRifle');
	spawn(class'PulseGun');
	spawn(class'Ripper');
	spawn(class'Minigun2');
	spawn(class'UT_FlakCannon');
	spawn(class'UT_Eightball');
	spawn(class'SniperRifle');
}

function SendClientFire(weapon W, int N)
{
	RealWeapon(W,N);
	if ( Weapon.IsA('TournamentWeapon') )
	{
		TournamentWeapon(Weapon).bCanClientFire = true;
		TournamentWeapon(Weapon).ForceClientFire();
	}
}

function SendClientAltFire(weapon W, int N)
{
	RealWeapon(W,N);
	if ( Weapon.IsA('TournamentWeapon') )
	{
		TournamentWeapon(Weapon).bCanClientFire = true;
		TournamentWeapon(Weapon).ForceClientAltFire();
	}
}

exec function KillAll(class<actor> aClass)
{
	if ( (Level.NetMode != NM_Standalone) && Level.Game.IsA('DeathMatchPlus')
		&& ((aClass == class'Bot') || (aClass == class'Pawn')) )
		DeathMatchPlus(Level.Game).MinPlayers = 0;

	Super.KillAll(aClass);
}

function ClientPutDown(Weapon Current, Weapon Next)
{	
	if ( Role == ROLE_Authority )
		return;
	bNeedActivate = false;
	if ( (Current != None) && (Current != Next) )
		Current.ClientPutDown(Next);
	else if ( Weapon != None )
	{
		if ( Weapon != Next )
			Weapon.ClientPutDown(Next);
		else
		{
			bNeedActivate = false;
			ClientPending = None;
			if ( Weapon.IsInState('ClientDown') || !Weapon.IsAnimating() )
			{
				Weapon.GotoState('');
				Weapon.TweenToStill();
			}
		}
	}
}

function SendFire(Weapon W)
{
	WeaponUpdate++;
	SendClientFire(W,WeaponUpdate);
}

function SendAltFire(Weapon W)
{
	WeaponUpdate++;
	SendClientAltFire(W,WeaponUpdate);
}

function UpdateRealWeapon(Weapon W)
{
	WeaponUpdate++;
	RealWeapon(W,WeaponUpdate);
}
	
function RealWeapon(weapon Real, int N)
{
	if ( N <= WeaponUpdate )
		return;
	WeaponUpdate = N;
	Weapon = Real;
	if ( (Weapon != None) && !Weapon.IsAnimating() )
	{
		if ( bNeedActivate || (Weapon == ClientPending) )
			Weapon.GotoState('ClientActive');
		else
			Weapon.TweenToStill();
	}
	bNeedActivate = false;
	ClientPending = None;	// make sure no client side weapon changes pending
}

function ReplicateMove
(
	float DeltaTime, 
	vector NewAccel, 
	eDodgeDir DodgeMove, 
	rotator DeltaRot
)
{
	Super.ReplicateMove(DeltaTime,NewAccel,DodgeMove,DeltaRot);
	if ( (Weapon != None) && !Weapon.IsAnimating() )
	{
		if ( (Weapon == ClientPending) || (Weapon != OldClientWeapon) )
		{
			if ( Weapon.IsInState('ClientActive') )
				AnimEnd();
			else
				Weapon.GotoState('ClientActive');
			if ( (Weapon != ClientPending) && (myHUD != None) && myHUD.IsA('ChallengeHUD') )
				ChallengeHUD(myHUD).WeaponNameFade = 1.3;
			if ( (Weapon != OldClientWeapon) && (OldClientWeapon != None) )
				OldClientWeapon.GotoState('');

			ClientPending = None;
			bNeedActivate = false;
		}
		else
		{
			Weapon.GotoState('');
			Weapon.TweenToStill();
		}
	}
	OldClientWeapon = Weapon;
}
	
function TimeMessage(int Num)
{
	if ( TimeMessageClass == None )
		TimeMessageClass = class<CriticalEventPlus>(DynamicLoadObject("Botpack.TimeMessage", class'Class'));
	ReceiveLocalizedMessage( TimeMessageClass, 16 - Num );
}

function SetVoice(class<ChallengeVoicePack> V)
{
	PlayerReplicationInfo.VoiceType = V;
	UpdateURL("Voice", string(V), True);
	ServerSetVoice(V);
}

function ServerSetVoice(class<ChallengeVoicePack> V)
{
	PlayerReplicationInfo.VoiceType = V;
}

exec function ListBots()
{
	local Pawn P;

	for (P=Level.PawnList; P!=None; P=P.NextPawn)
		if ( P.bIsPlayer && P.IsA('Bot') ) 
			log(P.PlayerReplicationInfo.PlayerName$" skill "$P.Skill$" novice "$Bot(P).bNovice);
}

function PreSetMovement()
{
	bCanJump = true;
	bCanWalk = true;
	bCanSwim = true;
	bCanFly = false;
	bCanOpenDoors = true;
	bCanDoSpecial = true;
}

function ServerSetTaunt(bool B)
{
	bAutoTaunt = B;
}

function SetAutoTaunt(bool B)
{
	bAutoTaunt = B;
	ServerSetTaunt(B);
}

function ServerSetInstantRocket(bool B)
{
	bInstantRocket = B;
}

exec function SetInstantRocket(bool B)
{
	bInstantRocket = B;
	ServerSetInstantRocket(B);
}

function ChangeSetHand( string S )
{
	Super.ChangeSetHand(S);
	if ( Handedness == 1 )
		LoadLeftHand();
}

function LoadLeftHand()
{
	local mesh M;

	// load left handed weapon meshes
	M = mesh(DynamicLoadObject("Botpack.PulseGunL", class'Mesh'));
	M = mesh(DynamicLoadObject("Botpack.Rifle2mL", class'Mesh'));
	M = mesh(DynamicLoadObject("Botpack.EightML", class'Mesh'));
	M = mesh(DynamicLoadObject("Botpack.Minigun2L", class'Mesh'));
}

event Possess()
{
	local byte i;

	if ( Handedness == 1 )
		LoadLeftHand();

	if ( Level.Netmode == NM_Client )
	{
		ServerSetTaunt(bAutoTaunt);
		ServerSetInstantRocket(bInstantRocket);
	}

	Super.Possess();
}

function ClientVoiceMessage(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageID)
{
	if ( bNoVoiceMessages )
		return;
	if ( bNoVoiceTaunts && ((messageType == 'TAUNT') || (messageType == 'AUTOTAUNT')) )
		return;
	if ( bNoAutoTaunts && (messageType == 'AUTOTAUNT') )
		return;

	Super.ClientVoiceMessage(Sender, Recipient, messagetype, messageID);
}

function SendGlobalMessage(PlayerReplicationInfo Recipient, name MessageType, byte MessageID, float Wait)
{
	if ( Level.TimeSeconds - OldMessageTime < 5 )
		return;

	SendVoiceMessage(PlayerReplicationInfo, Recipient, MessageType, MessageID, 'GLOBAL');
}


function SendTeamMessage(PlayerReplicationInfo Recipient, name MessageType, byte MessageID, float Wait)
{
	if ( Level.TimeSeconds - OldMessageTime < 10 )
		return;

	SendVoiceMessage(PlayerReplicationInfo, Recipient, MessageType, MessageID, 'TEAM');
}

function Killed(pawn Killer, pawn Other, name damageType)
{
	Super.Killed(Killer, Other, damageType);

	if ( (Killer == self) 
		&& (((bFire == 0) && (bAltFire == 0))
			|| ((Weapon != None) && !Weapon.IsA('Minigun2') && !Weapon.IsA('PulseGun'))) )
		Other.Health = FMin(Other.Health, -11); // don't let other do stagger death
}

exec function Loaded()
{
	local inventory Inv;
	local weapon Weap;
	local DeathMatchPlus DM;

	if( !bCheatsEnabled )
		return;
	if( Level.Netmode!=NM_Standalone )
		return;

	DM = DeathMatchPlus(Level.Game);
	if ( DM == None )
		return;

	DM.GiveWeapon(self, "Botpack.PulseGun");
	DM.GiveWeapon(self, "Botpack.ShockRifle");
	DM.GiveWeapon(self, "Botpack.UT_FlakCannon");
	DM.GiveWeapon(self, "Botpack.UT_BioRifle");
	DM.GiveWeapon(self, "Botpack.Minigun2");
	DM.GiveWeapon(self, "Botpack.SniperRifle");
	DM.GiveWeapon(self, "Botpack.Ripper");
	DM.GiveWeapon(self, "Botpack.UT_Eightball");
	
	for ( inv=inventory; inv!=None; inv=inv.inventory )
	{
		weap = Weapon(inv);
		if ( (weap != None) && (weap.AmmoType != None) )
			weap.AmmoType.AmmoAmount = weap.AmmoType.MaxAmmo;
	}

	inv = Spawn(class'Armor2');
	if( inv != None )
	{
		inv.bHeldItem = true;
		inv.RespawnTime = 0.0;
		inv.GiveTo(self);
	}
	inv = Spawn(class'Thighpads');
	if( inv != None )
	{
		inv.bHeldItem = true;
		inv.RespawnTime = 0.0;
		inv.GiveTo(self);
	}
}

function PlayDodge(eDodgeDir DodgeMove)
{
	Velocity.Z = 210;
	if ( DodgeMove == DODGE_Left )
		TweenAnim('DodgeL', 0.25);
	else if ( DodgeMove == DODGE_Right )
		TweenAnim('DodgeR', 0.25);
	else if ( DodgeMove == DODGE_Back )
		TweenAnim('DodgeB', 0.25);
	else 
		PlayAnim('Flip', 1.35 * FMax(0.35, Region.Zone.ZoneGravity.Z/Region.Zone.Default.ZoneGravity.Z), 0.06);
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

simulated function PlayBeepSound()
{
	PlaySound(sound'NewBeep',SLOT_Interface, 2.0);
}

function PlayChatting()
{
	if ( mesh != None )
		LoopAnim('Chat1', 0.7, 0.25);
}

function PlayWaiting()
{
	local name newAnim;

	if ( Mesh == None )
		return;

	if ( bIsTyping )
	{
		PlayChatting();
		return;
	}

	if ( (IsInState('PlayerSwimming')) || (Physics == PHYS_Swimming) )
	{
		BaseEyeHeight = 0.7 * Default.BaseEyeHeight;
		if ( (Weapon == None) || (Weapon.Mass < 20) )
			LoopAnim('TreadSM');
		else
			LoopAnim('TreadLG');
	}
	else
	{	
		BaseEyeHeight = Default.BaseEyeHeight;
		ViewRotation.Pitch = ViewRotation.Pitch & 65535;
		If ( (ViewRotation.Pitch > RotationRate.Pitch) 
			&& (ViewRotation.Pitch < 65536 - RotationRate.Pitch) )
		{
			If (ViewRotation.Pitch < 32768) 
			{
				if ( (Weapon == None) || (Weapon.Mass < 20) )
					TweenAnim('AimUpSm', 0.3);
				else
					TweenAnim('AimUpLg', 0.3);
			}
			else
			{
				if ( (Weapon == None) || (Weapon.Mass < 20) )
					TweenAnim('AimDnSm', 0.3);
				else
					TweenAnim('AimDnLg', 0.3);
			}
		}
		else if ( (Weapon != None) && Weapon.bPointing )
		{
			if ( Weapon.bRapidFire && ((bFire != 0) || (bAltFire != 0)) )
				LoopAnim('StillFRRP');
			else if ( Weapon.Mass < 20 )
				TweenAnim('StillSMFR', 0.3);
			else
				TweenAnim('StillFRRP', 0.3);
		}
		else
		{
			if ( FRand() < 0.1 )
			{
				if ( (Weapon == None) || (Weapon.Mass < 20) )
					PlayAnim('CockGun', 0.5 + 0.5 * FRand(), 0.3);
				else
					PlayAnim('CockGunL', 0.5 + 0.5 * FRand(), 0.3);
			}
			else
			{
				if ( (Weapon == None) || (Weapon.Mass < 20) )
				{
					if ( (FRand() < 0.75) && ((AnimSequence == 'Breath1') || (AnimSequence == 'Breath2')) )
						newAnim = AnimSequence;
					else if ( FRand() < 0.5 )
						newAnim = 'Breath1';
					else
						newAnim = 'Breath2';
				}
				else
				{
					if ( (FRand() < 0.75) && ((AnimSequence == 'Breath1L') || (AnimSequence == 'Breath2L')) )
						newAnim = AnimSequence;
					else if ( FRand() < 0.5 )
						newAnim = 'Breath1L';
					else
						newAnim = 'Breath2L';
				}
								
				if ( AnimSequence == newAnim )
					LoopAnim(newAnim, 0.4 + 0.4 * FRand());
				else
					PlayAnim(newAnim, 0.4 + 0.4 * FRand(), 0.25);
			}
		}
	}
}

function EndSpree(PlayerReplicationInfo Killer, PlayerReplicationInfo Other)
{
	if ( (Killer == Other) || (Killer == None) )
		ReceiveLocalizedMessage( class'KillingSpreeMessage', 1, None, Other );
	else
		ReceiveLocalizedMessage( class'KillingSpreeMessage', 0, Other, Killer );
}

exec function IAmTheOne()
{
	// What are you doing looking at this?!  CHEATER!!!
	bCheatsEnabled = True;
}

exec function SetAirControl(float F)
{
	if ( bAdmin || (Level.Netmode == NM_Standalone) )
		AirControl = F;
}

exec function Verbose()
{
	if ( Bot(ViewTarget) != None )
		Bot(ViewTarget).bVerbose = true;
}

// Skip any map.
exec function Advance()
{
	if( !bCheatsEnabled )
		return;
	if ( !bAdmin && (Level.Netmode != NM_Standalone) )
		return;

	if (Level.Game.IsA('DeathMatchPlus'))
		DeathMatchPlus(Level.Game).Skip();
}

// Skip all maps.
exec function AdvanceAll()
{
	if( !bCheatsEnabled )
		return;
	if ( !bAdmin && (Level.Netmode != NM_Standalone) )
		return;

	if (Level.Game.IsA('DeathMatchPlus'))
		DeathMatchPlus(Level.Game).SkipAll();
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
	SkinPackage = Left(SkinName, Len(SkinName) - Len(SkinItem));

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

exec function Summon( string ClassName )
{
	local class<actor> NewClass;
	if( !bCheatsEnabled )
		return;
	if( !bAdmin && (Level.Netmode != NM_Standalone) )
		return;
	if( instr(ClassName,".")==-1 )
		ClassName = "Botpack." $ ClassName;
	Super.Summon( ClassName );
}

function CheckBob(float DeltaTime, float Speed2D, vector Y)
{
	local float OldBobTime;
	local int m,n;

	OldBobTime = BobTime;
	if ( Speed2D < 10 )
		BobTime += 0.2 * DeltaTime;
	else
		BobTime += DeltaTime * (0.3 + 0.7 * Speed2D/GroundSpeed);
	WalkBob = Y * 0.4 * Bob * Speed2D * sin(8 * BobTime);
	AppliedBob = FMin(1, 16 * deltatime) * LandBob + AppliedBob * (1 - FMin(1, 16 * deltatime));
	if ( Speed2D < 10 )
		WalkBob.Z = AppliedBob;
	else
		WalkBob.Z = AppliedBob + 0.3 * Bob * Speed2D * sin(16 * BobTime);
	LandBob *= (1 - 8*Deltatime);

	if ( bBehindView || (Speed2D < 10) )
		return;

	m = int(0.5 * Pi + 9.0 * OldBobTime/Pi);
	n = int(0.5 * Pi + 9.0 * BobTime/Pi);

	if ( (m != n) && !bIsWalking )
		FootStepping();
}

simulated function PlayFootStep()
{
	if ( (Level.Game != None) && ((Weapon == None) || !Weapon.bPointing) )
		MakeNoise(0.1);

	if ( bBehindView || (Role==ROLE_SimulatedProxy) )	
		FootStepping();
}

simulated function FootStepping()
{
	local sound step;
	local float decision;

	if ( FootRegion.Zone.bWaterZone )
	{
		PlaySound(WaterStep, SLOT_Interact, 1, false, 1000.0, 1.0);
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

function PlayHit(float Damage, vector HitLocation, name damageType, vector Momentum)
{
	local float rnd;
	local Bubble1 bub;
	local bool bServerGuessWeapon;
	local class<DamageType> DamageClass;
	local vector BloodOffset, Mo;
	local int iDam;

	if ( (Damage <= 0) && (ReducedDamageType != 'All') )
		return;

	//DamageClass = class(damageType);
	if ( ReducedDamageType != 'All' ) //spawn some blood
	{
		if (damageType == 'Drowned')
		{
			bub = spawn(class 'Bubble1',,, Location 
				+ 0.7 * CollisionRadius * vector(ViewRotation) + 0.3 * EyeHeight * vect(0,0,1));
			if (bub != None)
				bub.DrawScale = FRand()*0.06+0.04; 
		}
		else if ( (damageType != 'Burned') && (damageType != 'Corroded') 
					&& (damageType != 'Fell') )
		{
			BloodOffset = 0.2 * CollisionRadius * Normal(HitLocation - Location);
			BloodOffset.Z = BloodOffset.Z * 0.5;
			if ( (DamageType == 'shot') || (DamageType == 'decapitated') || (DamageType == 'shredded') )
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

	rnd = FClamp(Damage, 20, 60);
	if ( damageType == 'Burned' )
		ClientFlash( -0.009375 * rnd, rnd * vect(16.41, 11.719, 4.6875));
	else if ( damageType == 'Corroded' )
		ClientFlash( -0.01171875 * rnd, rnd * vect(9.375, 14.0625, 4.6875));
	else if ( damageType == 'Drowned' )
		ClientFlash(-0.390, vect(312.5,468.75,468.75));
	else 
		ClientFlash( -0.019 * rnd, rnd * vect(26.5, 4.5, 4.5));

	ShakeView(0.15 + 0.005 * Damage, Damage * 30, 0.3 * Damage); 
	PlayTakeHitSound(Damage, damageType, 1);
	bServerGuessWeapon = ( ((Weapon != None) && Weapon.bPointing) || (GetAnimGroup(AnimSequence) == 'Dodge') );
	iDam = Clamp(Damage,0,200);
	ClientPlayTakeHit(hitLocation - Location, iDam, bServerGuessWeapon ); 
	if ( !bServerGuessWeapon 
		&& ((Level.NetMode == NM_DedicatedServer) || (Level.NetMode == NM_ListenServer)) )
	{
		Enable('AnimEnd');
		BaseEyeHeight = Default.BaseEyeHeight;
		bAnimTransition = true;
		PlayTakeHit(0.1, hitLocation, Damage);
	}
}

function PlayDeathHit(float Damage, vector HitLocation, name damageType, vector Momentum)
{
	local Bubble1 bub;
	local vector Mo;

	if ( Region.Zone.bDestructive && (Region.Zone.ExitActor != None) )
		Spawn(Region.Zone.ExitActor);
	if (HeadRegion.Zone.bWaterZone)
	{
		bub = spawn(class 'Bubble1',,, Location 
			+ 0.3 * CollisionRadius * vector(Rotation) + 0.8 * EyeHeight * vect(0,0,1));
		if (bub != None)
			bub.DrawScale = FRand()*0.08+0.03; 
		bub = spawn(class 'Bubble1',,, Location 
			+ 0.2 * CollisionRadius * VRand() + 0.7 * EyeHeight * vect(0,0,1));
		if (bub != None)
			bub.DrawScale = FRand()*0.08+0.03; 
		bub = spawn(class 'Bubble1',,, Location 
			+ 0.3 * CollisionRadius * VRand() + 0.6 * EyeHeight * vect(0,0,1));
		if (bub != None)
			bub.DrawScale = FRand()*0.08+0.03; 
	}

	if ( (!Level.bDropDetail || (FRand() < 0.67))
			&& ((DamageType == 'shot') || (DamageType == 'decapitated') || (DamageType == 'shredded')) )
	{
		Mo = Momentum;
		if ( Mo.Z > 0 )
			Mo.Z *= 0.5;
		spawn(class 'UT_BloodHit',self,,hitLocation, rotator(Mo));
	}
	else if ( (damageType != 'Drowned') && (damageType != 'Corroded') )
		spawn(class 'UT_BloodBurst',self,'', hitLocation);
}

//-----------------------------------------------------------------------------
// Sound functions

function PlayTakeHitSound(int damage, name damageType, int Mult)
{
	if ( Level.TimeSeconds - LastPainSound < 0.3 )
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
		PlaySound(HitSound1, SLOT_Pain,16,,,Frand()*0.15+0.9);
	else if (damage < 25)
	{
		if (FRand() < 0.5) PlaySound(HitSound2, SLOT_Pain,16,,,Frand()*0.15+0.9);			
		else PlaySound(HitSound3, SLOT_Pain,16,,,Frand()*0.15+0.9);
	}
	else
		PlaySound(HitSound4, SLOT_Pain,16,,,Frand()*0.15+0.9);			
}

function ClientPlayTakeHit(vector HitLoc, byte Damage, bool bServerGuessWeapon)
{
	local ChallengeHUD CHUD;

	CHUD = ChallengeHUD(myHUD);
	if ( CHUD != None )
		CHUD.SetDamage(HitLoc, damage);

	HitLoc += Location;
	if ( bServerGuessWeapon && ((GetAnimGroup(AnimSequence) == 'Dodge') || ((Weapon != None) && Weapon.bPointing)) )
		return;
	Enable('AnimEnd');
	bAnimTransition = true;
	BaseEyeHeight = Default.BaseEyeHeight;
	PlayTakeHit(0.1, HitLoc, Damage);
}	

function Gasp()
{
	if ( Role != ROLE_Authority )
		return;
	if ( PainTime < 2 )
		PlaySound(GaspSound, SLOT_Talk, 2.0);
	else
		PlaySound(BreathAgain, SLOT_Talk, 2.0);
}

//-----------------------------------------------------------------------------
// Animation functions

function PlayTurning()
{
	BaseEyeHeight = Default.BaseEyeHeight;
	if ( (Weapon == None) || (Weapon.Mass < 20) )
		PlayAnim('TurnSM', 0.3, 0.3);
	else
		PlayAnim('TurnLG', 0.3, 0.3);
}

function TweenToWalking(float tweentime)
{
	BaseEyeHeight = Default.BaseEyeHeight;
	if (Weapon == None)
		TweenAnim('Walk', tweentime);
	else if ( Weapon.bPointing || (CarriedDecoration != None) ) 
	{
		if (Weapon.Mass < 20)
			TweenAnim('WalkSMFR', tweentime);
		else
			TweenAnim('WalkLGFR', tweentime);
	}
	else
	{
		if (Weapon.Mass < 20)
			TweenAnim('WalkSM', tweentime);
		else
			TweenAnim('WalkLG', tweentime);
	} 
}

function PlayWalking()
{
	BaseEyeHeight = Default.BaseEyeHeight;
	if (Weapon == None)
		LoopAnim('Walk');
	else if ( Weapon.bPointing || (CarriedDecoration != None) ) 
	{
		if (Weapon.Mass < 20)
			LoopAnim('WalkSMFR');
		else
			LoopAnim('WalkLGFR');
	}
	else
	{
		if (Weapon.Mass < 20)
			LoopAnim('WalkSM');
		else
			LoopAnim('WalkLG');
	}
}

function TweenToRunning(float tweentime)
{
	local vector X,Y,Z, Dir;

	BaseEyeHeight = Default.BaseEyeHeight;
	if (bIsWalking)
	{
		TweenToWalking(0.1);
		return;
	}

	GetAxes(Rotation, X,Y,Z);
	Dir = Normal(Acceleration);
	if ( (Dir Dot X < 0.75) && (Dir != vect(0,0,0)) )
	{
		// strafing or backing up
		if ( Dir Dot X < -0.75 )
			PlayAnim('BackRun', 0.9, tweentime);
		else if ( Dir Dot Y > 0 )
			PlayAnim('StrafeR', 0.9, tweentime);
		else
			PlayAnim('StrafeL', 0.9, tweentime);
	}
	else if (Weapon == None)
		PlayAnim('RunSM', 0.9, tweentime);
	else if ( Weapon.bPointing ) 
	{
		if (Weapon.Mass < 20)
			PlayAnim('RunSMFR', 0.9, tweentime);
		else
			PlayAnim('RunLGFR', 0.9, tweentime);
	}
	else
	{
		if (Weapon.Mass < 20)
			PlayAnim('RunSM', 0.9, tweentime);
		else
			PlayAnim('RunLG', 0.9, tweentime);
	} 
}

function PlayRunning()
{
	local vector X,Y,Z, Dir;

	BaseEyeHeight = Default.BaseEyeHeight;

	// determine facing direction
	GetAxes(Rotation, X,Y,Z);
	Dir = Normal(Acceleration);
	if ( (Dir Dot X < 0.75) && (Dir != vect(0,0,0)) )
	{
		// strafing or backing up
		if ( Dir Dot X < -0.75 )
			LoopAnim('BackRun');
		else if ( Dir Dot Y > 0 )
			LoopAnim('StrafeR');
		else
			LoopAnim('StrafeL');
	}
	else if (Weapon == None)
		LoopAnim('RunSM');
	else if ( Weapon.bPointing ) 
	{
		if (Weapon.Mass < 20)
			LoopAnim('RunSMFR');
		else
			LoopAnim('RunLGFR');
	}
	else
	{
		if (Weapon.Mass < 20)
			LoopAnim('RunSM');
		else
			LoopAnim('RunLG');
	}
}

function PlayRising()
{
	BaseEyeHeight = 0.4 * Default.BaseEyeHeight;
	TweenAnim('DuckWlkS', 0.7);
}

function PlayFeignDeath()
{
	local float decision;

	BaseEyeHeight = 0;
	if ( decision < 0.33 )
		TweenAnim('DeathEnd', 0.5);
	else if ( decision < 0.67 )
		TweenAnim('DeathEnd2', 0.5);
	else 
		TweenAnim('DeathEnd3', 0.5);
}

function PlayGutHit(float tweentime)
{
	if ( (AnimSequence == 'GutHit') || (AnimSequence == 'Dead2') )
	{
		if (FRand() < 0.5)
			TweenAnim('LeftHit', tweentime);
		else
			TweenAnim('RightHit', tweentime);
	}
	else if ( FRand() < 0.6 )
		TweenAnim('GutHit', tweentime);
	else
		TweenAnim('Dead2', tweentime);

}

function PlayHeadHit(float tweentime)
{
	if ( (AnimSequence == 'HeadHit') || (AnimSequence == 'Dead4') )
		TweenAnim('GutHit', tweentime);
	else if ( FRand() < 0.6 )
		TweenAnim('HeadHit', tweentime);
	else
		TweenAnim('Dead4', tweentime);
}

function PlayLeftHit(float tweentime)
{
	if ( (AnimSequence == 'LeftHit') || (AnimSequence == 'Dead3') )
		TweenAnim('GutHit', tweentime);
	else if ( FRand() < 0.6 )
		TweenAnim('LeftHit', tweentime);
	else 
		TweenAnim('Dead3', tweentime);
}

function PlayRightHit(float tweentime)
{
	if ( (AnimSequence == 'RightHit') || (AnimSequence == 'Dead5') )
		TweenAnim('GutHit', tweentime);
	else if ( FRand() < 0.6 )
		TweenAnim('RightHit', tweentime);
	else
		TweenAnim('Dead5', tweentime);
}
	
function PlayLanded(float impactVel)
{	
	impactVel = impactVel/JumpZ;
	impactVel = 0.1 * impactVel * impactVel;
	BaseEyeHeight = Default.BaseEyeHeight;

	if ( impactVel > 0.17 )
		PlayOwnedSound(LandGrunt, SLOT_Talk, FMin(5, 5 * impactVel),false,1200,FRand()*0.4+0.8);
	if ( !FootRegion.Zone.bWaterZone && (impactVel > 0.01) )
		PlayOwnedSound(Land, SLOT_Interact, FClamp(4 * impactVel,0.5,5), false,1000, 1.0);
	if ( (impactVel > 0.06) || (GetAnimGroup(AnimSequence) == 'Jumping') || (GetAnimGroup(AnimSequence) == 'Ducking') )
	{
		if ( (Weapon == None) || (Weapon.Mass < 20) )
			TweenAnim('LandSMFR', 0.12);
		else
			TweenAnim('LandLGFR', 0.12);
	}
	else if ( !IsAnimating() )
	{
		if ( GetAnimGroup(AnimSequence) == 'TakeHit' )
		{
			SetPhysics(PHYS_Walking);
			AnimEnd();
		}
		else 
		{
			if ( (Weapon == None) || (Weapon.Mass < 20) )
				TweenAnim('LandSMFR', 0.12);
			else
				TweenAnim('LandLGFR', 0.12);
		}
	}
}
	
function PlayInAir()
{
	local vector X,Y,Z, Dir;
	local float f, TweenTime;

	BaseEyeHeight =  0.7 * Default.BaseEyeHeight;

	if ( (GetAnimGroup(AnimSequence) == 'Landing') && !bLastJumpAlt )
	{
		GetAxes(Rotation, X,Y,Z);
		Dir = Normal(Acceleration);
		f = Dir dot Y;
		if ( f > 0.7 )
			TweenAnim('DodgeL', 0.35);
		else if ( f < -0.7 )
			TweenAnim('DodgeR', 0.35);
		else if ( Dir dot X > 0 )
			TweenAnim('DodgeF', 0.35);
		else
			TweenAnim('DodgeB', 0.35);
		bLastJumpAlt = true;
		return;
	}
	bLastJumpAlt = false;
	if ( GetAnimGroup(AnimSequence) == 'Jumping' )
	{
		if ( (Weapon == None) || (Weapon.Mass < 20) )
			TweenAnim('DuckWlkS', 2);
		else
			TweenAnim('DuckWlkL', 2);
		return;
	}
	else if ( GetAnimGroup(AnimSequence) == 'Ducking' )
		TweenTime = 2;
	else 
		TweenTime = 0.7;

	if ( AnimSequence == 'StrafeL' )
		TweenAnim('DodgeR', TweenTime);
	else if ( AnimSequence == 'StrafeR' )
		TweenAnim('DodgeL', TweenTime);
	else if ( AnimSequence == 'BackRun' )
		TweenAnim('DodgeB', TweenTime);
	else if ( (Weapon == None) || (Weapon.Mass < 20) )
		TweenAnim('JumpSMFR', TweenTime);
	else
		TweenAnim('JumpLGFR', TweenTime); 
}

function PlayDuck()
{
	BaseEyeHeight = 0;
	if ( (Weapon == None) || (Weapon.Mass < 20) )
		TweenAnim('DuckWlkS', 0.25);
	else
		TweenAnim('DuckWlkL', 0.25);
}

function PlayCrawling()
{
	//log("Play duck");
	BaseEyeHeight = 0;
	if ( (Weapon == None) || (Weapon.Mass < 20) )
		LoopAnim('DuckWlkS');
	else
		LoopAnim('DuckWlkL');
}

function TweenToWaiting(float tweentime)
{
	if ( (IsInState('PlayerSwimming')) || (Physics == PHYS_Swimming) )
	{
		BaseEyeHeight = 0.7 * Default.BaseEyeHeight;
		if ( (Weapon == None) || (Weapon.Mass < 20) )
			TweenAnim('TreadSM', tweentime);
		else
			TweenAnim('TreadLG', tweentime);
	}
	else
	{
		BaseEyeHeight = Default.BaseEyeHeight;
		if ( (Weapon == None) || (Weapon.Mass < 20) )
			TweenAnim('StillSMFR', tweentime);
		else 
			TweenAnim('StillFRRP', tweentime);
	}
}
	
function PlayRecoil(float Rate)
{
	if ( Weapon.bRapidFire )
	{
		if ( !IsAnimating() && (Physics == PHYS_Walking) )
			LoopAnim('StillFRRP', 0.02);
	}
	else if ( AnimSequence == 'StillSmFr' )
		PlayAnim('StillSmFr', Rate, 0.02);
	else if ( (AnimSequence == 'StillLgFr') || (AnimSequence == 'StillFrRp') )	
		PlayAnim('StillLgFr', Rate, 0.02);
}

function PlayFiring()
{
	// switch animation sequence mid-stream if needed
	if (AnimSequence == 'RunLG')
		AnimSequence = 'RunLGFR';
	else if (AnimSequence == 'RunSM')
		AnimSequence = 'RunSMFR';
	else if (AnimSequence == 'WalkLG')
		AnimSequence = 'WalkLGFR';
	else if (AnimSequence == 'WalkSM')
		AnimSequence = 'WalkSMFR';
	else if ( AnimSequence == 'JumpSMFR' )
		TweenAnim('JumpSMFR', 0.03);
	else if ( AnimSequence == 'JumpLGFR' )
		TweenAnim('JumpLGFR', 0.03);
	else if ( (GetAnimGroup(AnimSequence) == 'Waiting') || (GetAnimGroup(AnimSequence) == 'Gesture')
		&& (AnimSequence != 'TreadLG') && (AnimSequence != 'TreadSM') )
	{
		if ( Weapon.Mass < 20 )
			TweenAnim('StillSMFR', 0.02);
		else
			TweenAnim('StillFRRP', 0.02);
	}
}

function PlayWeaponSwitch(Weapon NewWeapon)
{
	if ( (Weapon == None) || (Weapon.Mass < 20) )
	{
		if ( (NewWeapon != None) && (NewWeapon.Mass > 20) )
		{
			if ( (AnimSequence == 'RunSM') || (AnimSequence == 'RunSMFR') )
				AnimSequence = 'RunLG';
			else if ( (AnimSequence == 'WalkSM') || (AnimSequence == 'WalkSMFR') )
				AnimSequence = 'WalkLG';	
		 	else if ( AnimSequence == 'JumpSMFR' )
		 		AnimSequence = 'JumpLGFR';
			else if ( AnimSequence == 'DuckWlkL' )
				AnimSequence = 'DuckWlkS';
		 	else if ( AnimSequence == 'StillSMFR' )
		 		AnimSequence = 'StillFRRP';
			else if ( AnimSequence == 'AimDnSm' )
				AnimSequence = 'AimDnLg';
			else if ( AnimSequence == 'AimUpSm' )
				AnimSequence = 'AimUpLg';
		 }	
	}
	else if ( (NewWeapon == None) || (NewWeapon.Mass < 20) )
	{		
		if ( (AnimSequence == 'RunLG') || (AnimSequence == 'RunLGFR') )
			AnimSequence = 'RunSM';
		else if ( (AnimSequence == 'WalkLG') || (AnimSequence == 'WalkLGFR') )
			AnimSequence = 'WalkSM';
	 	else if ( AnimSequence == 'JumpLGFR' )
	 		AnimSequence = 'JumpSMFR';
		else if ( AnimSequence == 'DuckWlkS' )
			AnimSequence = 'DuckWlkL';
	 	else if (AnimSequence == 'StillFRRP')
	 		AnimSequence = 'StillSMFR';
		else if ( AnimSequence == 'AimDnLg' )
			AnimSequence = 'AimDnSm';
		else if ( AnimSequence == 'AimUpLg' )
			AnimSequence = 'AimUpSm';
	}
}

function PlaySwimming()
{
	BaseEyeHeight = 0.7 * Default.BaseEyeHeight;
	if ((Weapon == None) || (Weapon.Mass < 20) )
		LoopAnim('SwimSM');
	else
		LoopAnim('SwimLG');
}

function TweenToSwimming(float tweentime)
{
	BaseEyeHeight = 0.7 * Default.BaseEyeHeight;
	if ((Weapon == None) || (Weapon.Mass < 20) )
		TweenAnim('SwimSM',tweentime);
	else
		TweenAnim('SwimLG',tweentime);
}

function NeedActivate()
{
	bNeedActivate = true;
}

state FeigningDeath
{
	function NeedActivate()
	{
		bNeedActivate = false;
	}

	function BeginState()
	{
		if ( (Role == ROLE_Authority) && (PlayerReplicationInfo.HasFlag != None)
			&& PlayerReplicationInfo.HasFlag.IsA('CTFFlag')  )
			PlayerReplicationInfo.HasFlag.Drop(vect(0,0,0));
		Super.BeginState();
		bNeedActivate = false;
	}
}
state Dying
{
ignores SeePlayer, HearNoise, KilledBy, Bump, HitWall, HeadZoneChange, FootZoneChange, ZoneChange, SwitchWeapon, Falling, PainTimer;

	function ViewFlash(float DeltaTime)
	{
		if ( Carcass(ViewTarget) != None )
		{
			InstantFlash = -0.3;
			InstantFog = vect(0.25, 0.03, 0.03);
		}
		Super.ViewFlash(DeltaTime);
	}

	function BeginState()
	{
		Super.BeginState();
		LastKillTime = 0;
	}
}
	
state GameEnded
{
	ignores SeePlayer, HearNoise, KilledBy, Bump, HitWall, HeadZoneChange, FootZoneChange, ZoneChange, Falling, TakeDamage, PainTimer, Died;

	exec function Fire( optional float F )
	{
		if ( Role < ROLE_Authority )
			return;

		if ( (Level.NetMode == NM_Standalone) && !bFrozen )
			ServerReStartGame();
	}
}

defaultproperties
{
	 bIsHuman=true
     Footstep1=FemaleSounds.stone02
     Footstep2=FemaleSounds.stone04
     Footstep3=FemaleSounds.stone05
     BaseEyeHeight=+00027.000000
     EyeHeight=+00027.000000
     CollisionRadius=+00017.000000
     CollisionHeight=+00039.000000
     Buoyancy=+00099.000000
	 bSinglePlayer=true
	 Land=Land1
     UnderWaterTime=+00020.000000
     bCanStrafe=True
     MeleeRange=+00050.000000
     Intelligence=BRAINS_HUMAN
     GroundSpeed=+00400.000000
     AirSpeed=+00400.000000
     AccelRate=+02048.000000
     DrawType=DT_Mesh
     LightBrightness=70
     LightHue=40
     LightSaturation=128
     LightRadius=6
     RotationRate=(Pitch=3072,Yaw=65000,Roll=2048)
	 AnimSequence=WalkSm
	 WaterStep=UnrealShare.LSplash
	 VoiceType="BotPack.VoiceMaleOne"
	 SpreeNote(0)="is on a killing spree!"
	 SpreeNote(1)="is on a rampage!"
	 SpreeNote(2)="is dominating!"
	 SpreeNote(3)="is brutalizing the competition!"
	 SpreeNote(4)="is unstoppable!"
	 SpreeNote(5)="owns you!"
	 SpreeNote(6)="needs to find some real competition!"
	 SpreeNote(7)="is a GOD!"
	 LastKillTime=-1000.0
	 bIsMultiSkinned=True
	 AirControl=+0.35
     WeaponPriority(0)=Translocator
     WeaponPriority(1)=Chainsaw
     WeaponPriority(2)=ImpactHammer
     WeaponPriority(3)=Enforcer
     WeaponPriority(4)=DoubleEnforcer
     WeaponPriority(5)=SniperRifle
     WeaponPriority(6)=UT_BioRifle
     WeaponPriority(7)=ShockRifle
     WeaponPriority(8)=PulseGun
     WeaponPriority(9)=Ripper
     WeaponPriority(10)=Minigun2
	 WeaponPriority(11)=UT_FlakCannon
	 WeaponPriority(12)=UT_Eightball
	 WeaponPriority(13)=Warheadlauncher
	 StatusDoll=texture'Botpack.Man'
	 StatusBelt=texture'Botpack.ManBelt'
	 VoicePackMetaClass="BotPack.ChallengeVoicePack"
	 AnnouncerVolume=4
	 AmbientGlow=17
	 DodgeClickTime=-1.0
}

