//=============================================================================
// ChainSaw.
//=============================================================================
class ChainSaw extends TournamentWeapon;

#exec MESH IMPORT  MESH=chainsawM ANIVFILE=MODELS\chains_a.3D DATAFILE=MODELS\chains_d.3D X=0 Y=0 Z=0 
#exec MESH ORIGIN MESH=chainsawM X=0 Y=0 Z=0 YAW=0 PITCH=0  ROLL=0
#exec MESH SEQUENCE MESH=chainsawM SEQ=All       STARTFRAME=0   NUMFRAMES=70
#exec MESH SEQUENCE MESH=chainsawM SEQ=Select    STARTFRAME=2   NUMFRAMES=15
#exec MESH SEQUENCE MESH=chainsawM SEQ=Idle      STARTFRAME=17  NUMFRAMES=10
#exec MESH SEQUENCE MESH=chainsawM SEQ=Still     STARTFRAME=17  NUMFRAMES=10
#exec MESH SEQUENCE MESH=chainsawM SEQ=Swipe     STARTFRAME=27  NUMFRAMES=11
#exec MESH SEQUENCE MESH=chainsawM SEQ=Jab       STARTFRAME=42  NUMFRAMES=20
#exec MESH SEQUENCE MESH=chainsawM SEQ=Jab2      STARTFRAME=48  NUMFRAMES=13
#exec MESH SEQUENCE MESH=chainsawM SEQ=Down      STARTFRAME=62  NUMFRAMES=6
#exec TEXTURE IMPORT NAME=Jchainsaw1  FILE=MODELS\chain1.PCX GROUP=Skins  LODSET=2
#exec TEXTURE IMPORT NAME=Jchainsaw2 FILE=MODELS\chain2.PCX GROUP=Skins  LODSET=2
#exec TEXTURE IMPORT NAME=Jchainsaw3 FILE=MODELS\chain3.PCX GROUP=Skins  LODSET=2
#exec TEXTURE IMPORT NAME=Jchainsaw4 FILE=MODELS\chain4.PCX GROUP=Skins  LODSET=2
#exec MESHMAP SCALE MESHMAP=chainsawM X=0.004 Y=0.006 Z=0.012
#exec MESHMAP SETTEXTURE MESHMAP=chainsawM NUM=0 TEXTURE=Jchainsaw1
#exec MESHMAP SETTEXTURE MESHMAP=chainsawM NUM=1 TEXTURE=Jchainsaw2
#exec MESHMAP SETTEXTURE MESHMAP=chainsawM NUM=2 TEXTURE=Jchainsaw3
#exec MESHMAP SETTEXTURE MESHMAP=chainsawM NUM=3 TEXTURE=Jchainsaw4

#exec MESH IMPORT MESH=ChainSawPick ANIVFILE=MODELS\chainpick_a.3D DATAFILE=MODELS\chainpick_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=ChainSawPick X=150 Y=-10 Z=0 YAW=0 ROLL=-64
#exec MESH SEQUENCE MESH=ChainSawPick SEQ=All         STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=ChainSawPick SEQ=Still       STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JChainSawPick1 FILE=MODELS\ChainSaw.PCX GROUP=Skins  LODSET=2
#exec MESHMAP SCALE MESHMAP=ChainSawPick X=0.07 Y=0.07 Z=0.14
#exec MESHMAP SETTEXTURE MESHMAP=ChainSawPick NUM=1 TEXTURE=JChainSawPick1

#exec MESH IMPORT MESH=CSHand ANIVFILE=MODELS\Chainpick_a.3D DATAFILE=MODELS\Chainpick_d.3D
#exec MESH ORIGIN MESH=CSHand X=-430 Y=-70 Z=0 YAW=0 ROLL=-64
#exec MESH SEQUENCE MESH=CSHand SEQ=All         STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=CSHand SEQ=Still       STARTFRAME=0   NUMFRAMES=1
#exec MESHMAP SCALE MESHMAP=CSHand X=0.04 Y=0.04 Z=0.08
#exec MESHMAP SETTEXTURE MESHMAP=CSHand NUM=1 TEXTURE=JChainSawPick1

#exec TEXTURE IMPORT NAME=IconSaw FILE=TEXTURES\HUD\WpnCSaw.PCX GROUP="Icons" MIPS=OFF
#exec TEXTURE IMPORT NAME=UseSaw FILE=TEXTURES\HUD\UseCSaw.PCX GROUP="Icons" MIPS=OFF

#exec MESH NOTIFY MESH=chainsawM SEQ=Swipe TIME=0.45 FUNCTION=Slash

#exec AUDIO IMPORT FILE="Sounds\ChainSaw\ChainIdle.WAV" NAME="ChainIdle" GROUP="ChainSaw"
#exec AUDIO IMPORT FILE="Sounds\ChainSaw\ChainPickup.WAV" NAME="ChainPickup" GROUP="ChainSaw"
#exec AUDIO IMPORT FILE="Sounds\ChainSaw\ChainPowerDown.WAV" NAME="ChainPowerDown" GROUP="ChainSaw"
#exec AUDIO IMPORT FILE="Sounds\ChainSaw\SawHit.WAV" NAME="SawHit" GROUP="ChainSaw"

var() float Range;
var() sound HitSound, DownSound;
var Playerpawn LastHit;

function float RateSelf( out int bUseAltMode )
{
	local float EnemyDist;
	local bool bRetreating;
	local vector EnemyDir;

	bUseAltMode = 0;

	if ( (Pawn(Owner) == None) || (Pawn(Owner).Enemy == None) )
		return 0;

	EnemyDist = VSize(Pawn(Owner).Enemy.Location - Owner.Location);
	if ( EnemyDist > 400 )
		return -2;

	if ( EnemyDist < 110 )
		bUseAltMode = 1;

	return ( FMin(1.0, 81/(EnemyDist + 1)) );
}

function float SuggestAttackStyle()
{
	return 1.0;
}

function float SuggestDefenseStyle()
{
	return -0.7;
}

function Fire( float Value )
{
	GotoState('NormalFire');
	bPointing=True;
	bCanClientFire = true;
	Pawn(Owner).PlayRecoil(FiringSpeed);
	ClientFire(value);
	TraceFire(0.0);
}

simulated function PlayFiring()
{
	LoopAnim( 'Jab2', 0.7, 0.0 );
	AmbientSound = HitSound;
	SoundVolume = 255;		
}

function AltFire( float Value )
{
	GotoState('AltFiring');
	Pawn(Owner).PlayRecoil(FiringSpeed);
	bCanClientFire = true;
	bPointing=True;
	ClientAltFire(value);
}

simulated function PlayAltFiring()
{
	PlayAnim( 'Swipe', 0.6 );
	AmbientSound = HitSound;
	SoundVolume = 255;		
}

simulated function EndAltFiring()
{
	AmbientSound = Sound'Botpack.ChainIdle';
	TweenAnim('Idle', 1.0);
}


state NormalFire
{
	ignores AnimEnd;

	function BeginState()
	{
		Super.BeginState();
		AmbientSound = HitSound;
		SoundVolume = 255;		
	}

	function EndState()
	{
	    AmbientSound = Sound'Botpack.ChainIdle';
		Super.EndState();
		SoundVolume = Default.SoundVolume;		
	}

Begin:
	Sleep(0.15);
	if ( PlayerPawn(Owner) != None )
		PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
	TraceFire(0.0);
	Sleep(0.15);
	if ( PlayerPawn(Owner) != None )
		PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
	if ( LastHit != None )
	{
		LastHit.ClientFlash( -0.38, vect(530, 90, 90));
		LastHit.ShakeView(0.25, 600, 6); 
	}
	if ( Pawn(Owner).bFire == 0 )
		Finish();
	Goto('Begin');
}

////////////////////////////////////////////////////////
state ClientFiring
{
	simulated function EndState()
	{
	    AmbientSound = Sound'Botpack.ChainIdle';
		Super.EndState();
		SoundVolume = Default.SoundVolume;		
	}
}

state ClientAltFiring
{
	simulated function AnimEnd()
	{
		if ( AnimSequence != 'Idle' )
		{
			EndAltFiring();
		}
		else if ( !bCanClientFire )
			GotoState('');
		else if ( Pawn(Owner) == None )
		{
			PlayIdleAnim();
			GotoState('');
		}
		else if ( Pawn(Owner).bFire != 0 )
			Global.ClientFire(0);
		else if ( Pawn(Owner).bAltFire != 0 )
			Global.ClientAltFire(0);
		else
		{
			PlayIdleAnim();
			GotoState('');
		}
	}

	function EndState()
	{
	    AmbientSound = Sound'Botpack.ChainIdle';
		Super.EndState();
		SoundVolume = Default.SoundVolume;		
	}
}

state AltFiring
{
	ignores AnimEnd;

	function Fire(float F) 
	{
	}

	function AltFire(float F) 
	{
	}

	function BeginState()
	{
		Super.BeginState();
		AmbientSound = HitSound;
		SoundVolume = 255;		
	}

	function EndState()
	{
		Super.EndState();
	    AmbientSound = Sound'Botpack.ChainIdle';
		SoundVolume = Default.SoundVolume;		
	}

Begin:
	AmbientSound = HitSound;
	Sleep(0.1);
	FinishAnim();
	EndAltFiring();
	FinishAnim();
	Finish();
}

state Idle
{
	ignores animend;

	function bool PutDown()
	{
		GotoState('DownWeapon');
		return True;
	}

Begin:
	bPointing=False;
	if ( (AmmoType != None) && (AmmoType.AmmoAmount<=0) ) 
		Pawn(Owner).SwitchToBestWeapon();  //Goto Weapon that has Ammo
	if ( Pawn(Owner).bFire!=0 ) 
		Fire(0.0);
	if ( Pawn(Owner).bAltFire!=0 ) 
		AltFire(0.0);
	FinishAnim();
	AnimFrame=0;
	PlayIdleAnim();
	Goto('Begin');
}

simulated function PlayIdleAnim()
{
	if ( Mesh != PickupViewMesh )
		PlayAnim( 'Idle', 1.0, 0.0 );
}

// Finish a firing sequence
function Finish()
{
	if ( bChangeWeapon )
	{
		GotoState('DownWeapon');
		return;
	}

	if ( PlayerPawn(Owner) == None )
	{
		if ( (Pawn(Owner).bFire != 0) && (FRand() < RefireRate) )
			Global.Fire(0);
		else if ( (Pawn(Owner).bAltFire != 0) && (FRand() < AltRefireRate) )
			Global.AltFire(0);	
		else 
		{
			Pawn(Owner).StopFiring();
			GotoState('Idle');
		}
		return;
	}
	if ( Pawn(Owner).bFire!=0 )
		Global.Fire(0);
	else if ( Pawn(Owner).bAltFire!=0 )
		Global.AltFire(0);
	else 
		GotoState('Idle');
}

function Slash()
{
	local vector HitLocation, HitNormal, EndTrace, X, Y, Z, Start;
	local actor Other;

	Owner.MakeNoise(Pawn(Owner).SoundDampening);
	GetAxes(Pawn(owner).ViewRotation, X, Y, Z);
	Start =  Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;
	AdjustedAim = pawn(owner).AdjustAim(1000000, Start, AimError, False, False);	
	EndTrace = Owner.Location + (Range * vector(AdjustedAim)); 
	Other = Pawn(Owner).TraceShot(HitLocation, HitNormal, EndTrace, Start);

	if ( (Other == None) || (Other == Owner) || (Other == self) )
		return;

	if ( PlayerPawn(Owner) != None )
		PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
	Other.TakeDamage(110, Pawn(Owner), HitLocation, -10000.0 * Y, AltDamageType);
	if ( !Other.bIsPawn && !Other.IsA('Carcass') )
		spawn(class'SawHit',,,HitLocation+HitNormal, rotator(HitNormal));
}


function TraceFire(float accuracy)
{
	local vector HitLocation, HitNormal, EndTrace, X, Y, Z, Start;
	local actor Other;

	LastHit = None;
	Owner.MakeNoise(Pawn(Owner).SoundDampening);
	GetAxes(Pawn(owner).ViewRotation, X, Y, Z);
	Start =  Owner.Location + CalcDrawOffset() + FireOffset.Y * Y + FireOffset.Z * Z;
	AdjustedAim = pawn(owner).AdjustAim(1000000, Start, 2 * AimError, False, False);	
	EndTrace = Owner.Location + (10 + Range) * vector(AdjustedAim); 
	Other = Pawn(Owner).TraceShot(HitLocation, HitNormal, EndTrace, Start);

	if ( (Other == None) || (Other == Owner) || (Other == self) )
		return;

	Other.TakeDamage(20.0, Pawn(Owner), HitLocation, -15000 * X, MyDamageType);
	if ( !Other.bIsPawn && !Other.IsA('Carcass') )
		spawn(class'SawHit',,,HitLocation+HitNormal, Rotator(HitNormal));
	else if ( Other.IsA('PlayerPawn') && (Pawn(Other).Health > 0) )
		LastHit = PlayerPawn(Other);
}


simulated function PlayPostSelect()
{
    AmbientSound = Sound'Botpack.ChainIdle';
	if ( Level.NetMode == NM_Client )
	{
		Super.PlayPostSelect();
		return;
	}
}


simulated function TweenDown()
{
	Owner.PlayOwnedSound(DownSound,, 4.0 * Pawn(Owner).SoundDampening);
	Super.TweenDown();
	AmbientSound = None;
}

defaultproperties
{
	 bNoSmooth=false
     Range=90.000000
     HitSound=Sound'Botpack.ChainSaw.SawHit'
     DownSound=Sound'Botpack.ChainSaw.ChainPowerDown'
     bMeleeWeapon=True
     bRapidFire=True
     MyDamageType=slashed
     AltDamageType=Decapitated
     RefireRate=1.000000
     AltRefireRate=1.000000
     SelectSound=Sound'Botpack.ChainSaw.ChainPickup'
     DeathMessage="%k ripped into %o with a blood soaked %w."
     PickupMessage="Its been five years since I've seen one of these."
     ItemName="Chainsaw"
	 FireOffset=(X=10.000000,Y=-2.5.000000,Z=5.000000)
     PlayerViewOffset=(X=2.000000,Y=-1.100000,Z=-0.900000)
     PlayerViewMesh=LodMesh'Botpack.chainsawM'
     PickupViewMesh=LodMesh'Botpack.ChainSawPick'
     ThirdPersonMesh=LodMesh'Botpack.CSHand'
     StatusIcon=Texture'Botpack.Icons.UseSaw'
	 PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     Icon=Texture'Botpack.Icons.UseSaw'
     Mesh=LodMesh'Botpack.ChainSawPick'
     SoundVolume=100
	 WeaponDescription="Classification: Melee Blade\\n\\nPrimary Fire: When the trigger is held down, the chain covered blade will rev up. Drive this blade into opponents to inflict massive damage.\\n\\nSecondary Fire: The revved up blade can be swung horizontally and can cause instant decapitation of foes.\\n\\nTechniques: The chainsaw makes a loud and recognizable roar and can be avoided by listening for audio cues."
}
