//=============================================================================
// UnrealIPlayer.
//=============================================================================
class UnrealIPlayer extends PlayerPawn
	config(user)
	abstract;

#exec AUDIO IMPORT FILE="Sounds\Generic\land1.WAV" NAME="Land1" GROUP="Generic"
#exec AUDIO IMPORT FILE="Sounds\Generic\lsplash.WAV" NAME="LSplash" GROUP="Generic"
#exec AUDIO IMPORT FILE="Sounds\Generic\Say3A.WAV" NAME="Beep" GROUP="Generic"

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

var class<VoicePack> VoiceType;

replication
{
	// Functions server can call.
	unreliable if( Role==ROLE_Authority )
		ClientPlayTakeHit;
}

event Possess()
{
	local UnrealMeshMenu M;

	Super.Possess();

	if ( Level.Netmode == NM_Client )
	{
		M = spawn(class'UnrealMeshMenu');
		M.LoadAllMeshes();
		M.Destroy();
	}
}

simulated function PlayBeepSound()
{
	PlaySound(sound'Beep',SLOT_Interface, 2.0);
}

exec event ShowUpgradeMenu()
{
	bSpecialMenu = true;
	SpecialMenu = class'UpgradeMenu';
	ShowMenu();
}

exec function ShowLoadMenu()
{
	bSpecialMenu = true;
	SpecialMenu = class'UnrealLoadMenu';
	ShowMenu();
}

exec function Summon( string ClassName )
{
	local class<actor> NewClass;
	if( !bAdmin && (Level.Netmode != NM_Standalone) )
		return;
	if( instr(ClassName,".")==-1 )
		ClassName = "UnrealI." $ ClassName;
	Super.Summon( ClassName );
}

simulated function PlayFootStep()
{
	local sound step;
	local float decision;

	if ( !bIsWalking && (Level.Game != None) && (Level.Game.Difficulty > 1) && ((Weapon == None) || !Weapon.bPointing) )
		MakeNoise(0.05 * Level.Game.Difficulty);
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

	if ( bIsWalking )
		PlaySound(step, SLOT_Interact, 0.5, false, 400.0, 1.0);
	else 
		PlaySound(step, SLOT_Interact, 2, false, 800.0, 1.0);
}

function PlayHit(float Damage, vector HitLocation, name damageType, vector Momentum)
{
	local float rnd;
	local Bubble1 bub;
	local bool bServerGuessWeapon;
	local class<DamageType> DamageClass;
	local vector BloodOffset;

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
			if ( (Level.Game != None) && Level.Game.bVeryLowGore )
				spawn(class 'BloodBurst',self,,hitLocation + BloodOffset, rotator(BloodOffset));
			else
				spawn(class 'BloodSpray',self,,hitLocation + BloodOffset, rotator(BloodOffset));
		}
	}	

	rnd = FClamp(Damage, 20, 60);
	if ( damageType == 'Burned' )
		ClientFlash( -0.009375 * rnd, rnd * vect(16.41, 11.719, 4.6875));
	else if ( damageType == 'corroded' )
		ClientFlash( -0.01171875 * rnd, rnd * vect(9.375, 14.0625, 4.6875));
	else if ( damageType == 'Drowned' )
		ClientFlash(-0.390, vect(312.5,468.75,468.75));
	else 
		ClientFlash( -0.019 * rnd, rnd * vect(26.5, 4.5, 4.5));

	ShakeView(0.15 + 0.005 * Damage, Damage * 30, 0.3 * Damage); 
	PlayTakeHitSound(Damage, damageType, 1);
	bServerGuessWeapon = ( ((Weapon != None) && Weapon.bPointing) || (GetAnimGroup(AnimSequence) == 'Dodge') );
	ClientPlayTakeHit(0.1, hitLocation, Damage, bServerGuessWeapon ); 
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

	if ( (damageType != 'Drowned') && (damageType != 'Corroded') )
		spawn(class 'BloodSpray',self,'', hitLocation);
}

//-----------------------------------------------------------------------------
// Sound functions

function PlayDyingSound()
{
	local float rnd;

	if ( HeadRegion.Zone.bWaterZone )
	{
		if ( FRand() < 0.5 )
			PlaySound(UWHit1, SLOT_Pain,,,,Frand()*0.2+0.9);
		else
			PlaySound(UWHit2, SLOT_Pain,,,,Frand()*0.2+0.9);
		return;
	}

	rnd = FRand();
	if (rnd < 0.25)
		PlaySound(Die, SLOT_Talk);
	else if (rnd < 0.5)
		PlaySound(Die2, SLOT_Talk);
	else if (rnd < 0.75)
		PlaySound(Die3, SLOT_Talk);
	else 
		PlaySound(Die4, SLOT_Talk);
}

function PlayTakeHitSound(int damage, name damageType, int Mult)
{
	if ( Level.TimeSeconds - LastPainSound < 0.3 )
		return;
	LastPainSound = Level.TimeSeconds;

	if ( HeadRegion.Zone.bWaterZone )
	{
		if ( damageType == 'Drowned' )
			PlaySound(drown, SLOT_Pain, 1.5);
		else if ( FRand() < 0.5 )
			PlaySound(UWHit1, SLOT_Pain,2.0,,,Frand()*0.15+0.9);
		else
			PlaySound(UWHit2, SLOT_Pain,2.0,,,Frand()*0.15+0.9);
		return;
	}
	damage *= FRand();

	if (damage < 8) 
		PlaySound(HitSound1, SLOT_Pain,2.0,,,Frand()*0.15+0.9);
	else if (damage < 25)
	{
		if (FRand() < 0.5) PlaySound(HitSound2, SLOT_Pain,2.0,,,Frand()*0.15+0.9);			
		else PlaySound(HitSound3, SLOT_Pain,2.0,,,Frand()*0.15+0.9);
	}
	else
		PlaySound(HitSound4, SLOT_Pain,2.0,,,Frand()*0.15+0.9);			
}

function ClientPlayTakeHit(float tweentime, vector HitLoc, int Damage, bool bServerGuessWeapon)
{
	if ( bServerGuessWeapon && ((GetAnimGroup(AnimSequence) == 'Dodge') || ((Weapon != None) && Weapon.bPointing)) )
		return;
	Enable('AnimEnd');
	bAnimTransition = true;
	BaseEyeHeight = Default.BaseEyeHeight;
	PlayTakeHit(tweentime, HitLoc, Damage);
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

static function SetMultiSkin( Actor SkinActor, string SkinName, string FaceName, byte TeamNum )
{
	local Texture NewSkin;
	local string MeshName;
	local int i;
	local string TeamColor[4];

	TeamColor[0]="Red";
    TeamColor[1]="Blue";
    TeamColor[2]="Green";
    TeamColor[3]="Gold";


	MeshName = SkinActor.GetItemName(string(SkinActor.Mesh));

	if( InStr(SkinName, ".") == -1 )
		SkinName = MeshName$"Skins."$SkinName;

	if(TeamNum >=0 && TeamNum <= 3)
		NewSkin = texture(DynamicLoadObject(MeshName$"Skins.T_"$TeamColor[TeamNum], class'Texture'));
	else if( Left(SkinName, Len(MeshName)) ~= MeshName )
		NewSkin = texture(DynamicLoadObject(SkinName, class'Texture'));

	// Set skin
	if ( NewSkin != None )
		SkinActor.Skin = NewSkin;
}


defaultproperties
{
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
     WeaponPriority(0)=DispersionPistol
     WeaponPriority(1)=AutoMag
     WeaponPriority(2)=Stinger
     WeaponPriority(3)=ASMD
     WeaponPriority(4)=Eightball
     WeaponPriority(5)=FlakCannon
     WeaponPriority(6)=GESBioRifle
     WeaponPriority(7)=Razorjack
     WeaponPriority(8)=Rifle
     WeaponPriority(9)=Minigun
}
