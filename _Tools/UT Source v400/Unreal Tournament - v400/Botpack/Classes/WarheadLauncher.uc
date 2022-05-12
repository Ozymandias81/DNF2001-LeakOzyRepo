//=============================================================================
// WarHeadLauncher
//=============================================================================
class WarHeadLauncher extends TournamentWeapon;

#exec MESH IMPORT  MESH=WarHead ANIVFILE=MODELS\war_a.3D DATAFILE=MODELS\war_d.3D X=0 Y=0 Z=0 
#exec MESH ORIGIN MESH=WarHead X=0 Y=-210 Z=-50 YAW=64 PITCH=16  ROLL=-62
#exec MESH SEQUENCE MESH=WarHead SEQ=All         STARTFRAME=0   NUMFRAMES=35
#exec MESH SEQUENCE MESH=WarHead SEQ=Select      STARTFRAME=0   NUMFRAMES=15
#exec MESH SEQUENCE MESH=WarHead SEQ=Still       STARTFRAME=15  NUMFRAMES=1
#exec MESH SEQUENCE MESH=WarHead SEQ=Idle        STARTFRAME=15  NUMFRAMES=5
#exec MESH SEQUENCE MESH=WarHead SEQ=Down        STARTFRAME=20  NUMFRAMES=7
#exec MESH SEQUENCE MESH=WarHead SEQ=Fire        STARTFRAME=28  NUMFRAMES=7
#exec TEXTURE IMPORT NAME=Jwarhead1 FILE=MODELS\warh1.PCX GROUP=Skins LODSET=2
#exec TEXTURE IMPORT NAME=Jwarhead2 FILE=MODELS\warh2.PCX GROUP=Skins LODSET=2
#exec TEXTURE IMPORT NAME=Jwarhead3 FILE=MODELS\warh3.PCX GROUP=Skins LODSET=2
#exec TEXTURE IMPORT NAME=Jwarhead4 FILE=MODELS\warh4.PCX GROUP=Skins LODSET=2
#exec MESHMAP SCALE MESHMAP=WarHead X=0.006 Y=0.006 Z=0.012
#exec MESHMAP SETTEXTURE MESHMAP=WarHead NUM=0 TEXTURE=Jwarhead1
#exec MESHMAP SETTEXTURE MESHMAP=WarHead NUM=1 TEXTURE=Jwarhead2
#exec MESHMAP SETTEXTURE MESHMAP=WarHead NUM=2 TEXTURE=Jwarhead3
#exec MESHMAP SETTEXTURE MESHMAP=WarHead NUM=3 TEXTURE=Jwarhead4

#exec MESH IMPORT MESH=WHPick ANIVFILE=MODELS\WHPick_a.3D DATAFILE=MODELS\WHPick_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=WHPick X=150 Y=-10 Z=0 YAW=0 ROLL=-64
#exec MESH SEQUENCE MESH=WHPick SEQ=All         STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=WHPick SEQ=Still       STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=Jwhpick1 FILE=MODELS\whpick.PCX GROUP=Skins LODSET=2
#exec MESHMAP SCALE MESHMAP=WHPick X=0.1 Y=0.1 Z=0.2
#exec MESHMAP SETTEXTURE MESHMAP=WHPick NUM=1 TEXTURE=Jwhpick1

#exec MESH IMPORT MESH=WHHand ANIVFILE=MODELS\WHpick_a.3D DATAFILE=MODELS\WHpick_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=WHHand X=-150 Y=-110 Z=0 YAW=0 ROLL=-64
#exec MESH SEQUENCE MESH=WHHand SEQ=All         STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=WHHand SEQ=Still       STARTFRAME=0   NUMFRAMES=1
#exec MESHMAP SCALE MESHMAP=WHHand X=0.05 Y=0.05 Z=0.1
#exec MESHMAP SETTEXTURE MESHMAP=WHHand NUM=1 TEXTURE=JWHPick1

#exec TEXTURE IMPORT NAME=Readout FILE=MODELS\data.PCX GROUP="Icons" FLAGS=2 MIPS=OFF
#exec TEXTURE IMPORT NAME=GuidedX FILE=MODELS\crshair.PCX GROUP="Icons" FLAGS=2 MIPS=OFF

#exec AUDIO IMPORT FILE="Sounds\Warhead\warheadshot.wav" NAME="WarheadShot" GROUP=Redeemer
#exec AUDIO IMPORT FILE="Sounds\Warhead\warheadpickup.wav" NAME="WarheadPickup" GROUP=Redeemer

#exec TEXTURE IMPORT NAME=IconWarH FILE=TEXTURES\HUD\WpnRdeem.PCX GROUP="Icons" MIPS=OFF
#exec TEXTURE IMPORT NAME=UseWarH FILE=TEXTURES\HUD\UseRdeem.PCX GROUP="Icons" MIPS=OFF

var GuidedWarShell GuidedShell;
var int Scroll;
var PlayerPawn GuidingPawn;
var bool	bGuiding, bCanFire, bShowStatic;
var rotator StartRotation;

replication
{
	// Things the server should send to the client.
	reliable if( Role==ROLE_Authority )
		bGuiding, bShowStatic;
}

function SetWeaponStay()
{
	bWeaponStay = false; // redeemer never stays
}

simulated function PostRender( canvas Canvas )
{
	local int i, numReadouts, OldClipX, OldClipY;
	local float XScale;

	bOwnsCrossHair = ( bGuiding || bShowStatic );

	if ( !bGuiding )
	{
		if ( !bShowStatic )
			return;

		Canvas.SetPos( 0, 0);
		Canvas.Style = ERenderStyle.STY_Normal;
		Canvas.DrawIcon(Texture'LadrStatic.Static_a00', FMax(Canvas.ClipX, Canvas.ClipY)/256.0);
		if ( Owner.IsA('PlayerPawn') )
			PlayerPawn(Owner).ViewTarget = None;
		return;
	}
	GuidedShell.PostRender(Canvas);
	OldClipX = Canvas.ClipX;
	OldClipY = Canvas.ClipY;
	XScale = FMax(0.5, int(Canvas.ClipX/640.0));
	Canvas.SetPos( 0.5 * OldClipX - 128 * XScale, 0.5 * OldClipY - 128 * XScale );
	if ( Level.bHighDetailMode )
		Canvas.Style = ERenderStyle.STY_Translucent;
	else
		Canvas.Style = ERenderStyle.STY_Normal;
	Canvas.DrawIcon(Texture'GuidedX', XScale);

	numReadouts = OldClipY/128 + 2;
	for ( i = 0; i < numReadouts; i++ )
	{ 
		Canvas.SetPos(1,Scroll + i * 128);
		Scroll--;
		if ( Scroll < -128 )
			Scroll = 0;
		Canvas.DrawIcon(Texture'Readout', 1.0);
	}
}	

function float RateSelf( out int bUseAltMode )
{
	local Pawn P, E;
	local Bot O;

	O = Bot(Owner);
	if ( (O == None) || (AmmoType.AmmoAmount <=0) || (O.Enemy == None) )
		return -2;

	bUseAltMode = 0;
	E = O.Enemy;

	for ( P=Level.PawnList; P!=None; P=P.NextPawn )
		if ( P.bIsPlayer && (P != O) && (P != E)
			&& (!Level.Game.bTeamGame || (O.PlayerReplicationInfo.Team != P.PlayerReplicationInfo.Team))
			&& (VSize(E.Location - P.Location) < 650) 
			&& (!Level.Game.IsA('TeamGamePlus') || TeamGamePlus(Level.Game).PriorityObjective(O) < 2)
			&& FastTrace(P.Location, E.Location) )
		{
			if ( VSize(E.Location - O.Location) > 500 )
				return 2.0;
			else
				return 1.0;
		}

	return 0.35;
}

// return delta to combat style
function float SuggestAttackStyle()
{
	return -1.0;
}

simulated function PlayFiring()
{
	PlayAnim( 'Fire', 0.3 );		
	PlayOwnedSound(FireSound, SLOT_None,4.0*Pawn(Owner).SoundDampening);
}

function setHand(float Hand)
{
	if ( Hand == 2 )
	{
		bHideWeapon = true;
		return;
	}
	else
		bHideWeapon = false;

	PlayerViewOffset.Y = Default.PlayerViewOffset.Y;
	PlayerViewOffset.X = Default.PlayerViewOffset.X;
	PlayerViewOffset.Z = Default.PlayerViewOffset.Z;
	
	PlayerViewOffset *= 100; //scale since network passes vector components as ints
}

function AltFire( float Value )
{
	if ( !Owner.IsA('PlayerPawn') )
	{
		Fire(Value);
		return;
	}

	if (AmmoType.UseAmmo(1))
	{
		PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
		bPointing=True;
		Pawn(Owner).PlayRecoil(FiringSpeed);
		PlayFiring();
		GuidedShell = GuidedWarShell(ProjectileFire(AltProjectileClass, ProjectileSpeed, bWarnTarget));
		GuidedShell.SetOwner(Owner);
		PlayerPawn(Owner).ViewTarget = GuidedShell;
		GuidedShell.Guider = PlayerPawn(Owner);
		ClientAltFire(0);
		GotoState('Guiding');
	}
}

simulated function bool ClientAltFire( float Value )
{
	if ( bCanClientFire && ((Role == ROLE_Authority) || (AmmoType == None) || (AmmoType.AmmoAmount > 0)) )
	{
		if ( Affector != None )
			Affector.FireEffect();
		PlayOwnedSound(FireSound, SLOT_None,4.0*Pawn(Owner).SoundDampening);
		return true;
	}
	return false;
}

State Guiding
{
	function Fire ( float Value )
	{
		if ( !bCanFire )
			return;
		if ( GuidedShell != None )
			GuidedShell.Explode(GuidedShell.Location,Vect(0,0,1));
		bCanClientFire = true;

		GotoState('Finishing');
	}

	function AltFire ( float Value )
	{
		Fire(Value);
	}

	function BeginState()
	{
		Scroll = 0;
		bGuiding = true;
		bCanFire = false;
		if ( Owner.IsA('PlayerPawn') )
		{
			GuidingPawn = PlayerPawn(Owner);
			StartRotation = PlayerPawn(Owner).ViewRotation;
			PlayerPawn(Owner).ClientAdjustGlow(-0.2,vect(200,0,0));
		}
	}

	function EndState()
	{
		bGuiding = false;
		if ( GuidingPawn != None )
		{
			GuidingPawn.ClientAdjustGlow(0.2,vect(-200,0,0));
			GuidingPawn.ClientSetRotation(StartRotation);
			GuidingPawn = None;
		}
	}


Begin:
	Sleep(1.0);
	bCanFire = true;
}

State Finishing
{
	ignores Fire, AltFire;

	function BeginState()
	{
		bShowStatic = true;
	}

Begin:
	Sleep(0.3);
	bShowStatic = false;
	Sleep(1.0);
	GotoState('Idle');
}

defaultproperties
{
	 InstFlash=-0.4
     InstFog=(X=950.00000,Y=650.00000,Z=290.00000)
     AmmoName=Class'Botpack.WarheadAmmo'
     ReloadCount=1
     PickupAmmoCount=1
     bWarnTarget=True
     bAltWarnTarget=True
     bSplashDamage=True
     FireOffset=(X=18.000000,Z=-10.000000)
     ProjectileClass=Class'BotPack.WarShell'
     AltProjectileClass=Class'BotPack.GuidedWarShell'
     shakemag=350.000000
     shaketime=0.200000
     shakevert=7.500000
     AIRating=1.000000
     RefireRate=0.250000
     AltRefireRate=0.250000
	 FiringSpeed=1.0
     AutoSwitchPriority=10
     InventoryGroup=10
     PickupMessage="You got the Redeemer."
     ItemName="Redeemer"
     RespawnTime=60.000000
     PlayerViewOffset=(X=1.800000,Y=1.000000,Z=-1.890000)
     PlayerViewMesh=Mesh'BotPack.WarHead'
     BobDamping=0.975000
     PickupViewMesh=Mesh'BotPack.WHPick'
     ThirdPersonMesh=Mesh'BotPack.WHHand'
     Mesh=Mesh'BotPack.WHPick'
     bNoSmooth=False
     bMeshCurvy=False
     CollisionRadius=45.000000
     CollisionHeight=23.000000
	 DeathMessage="%o was vaporized by %k's %w!!"
	 PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'     
	 SelectSound=Sound'WarheadPickup'
	 FireSound=Sound'WarheadShot'
	 Icon=Texture'Botpack.UseWarH'
	 StatusIcon=Texture'Botpack.UseWarH'
     WeaponDescription="Classification: Thermonuclear Device\\n\\nPrimary Fire: Launches a huge yet slow moving missile that, upon striking a solid surface, will explode and send out a gigantic shock wave, instantly pulverizing anyone or anything within its colossal radius, including yourself.\\n\\nSecondary Fire: Take control of the missile and fly it anywhere.  You can press the primary fire button to explode the missile early.\\n\\nTechniques: Remember that while this rocket is being piloted you are a sitting duck.  If an opponent manages to hit your incoming Redeemer missile while it's in the air, the missile will explode harmlessly."
	 NameColor=(R=255,G=128,B=128)
	 bSpecialIcon=true
}
