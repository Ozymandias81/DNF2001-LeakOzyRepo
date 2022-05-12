//=============================================================================
// Ripper
// A human modification of the Skaarj Razorjack.
//=============================================================================
class Ripper extends TournamentWeapon;

#exec MESH IMPORT MESH=Razor2 ANIVFILE=MODELS\razorjack_a.3D DATAFILE=MODELS\razorjack_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=Razor2 X=0 Y=0 Z=0 YAW=64 PITCH=0 ROLL=0 
#exec MESH SEQUENCE MESH=razor2 SEQ=All     STARTFRAME=0   NUMFRAMES=76
#exec MESH SEQUENCE MESH=razor2 SEQ=Select  STARTFRAME=0   NUMFRAMES=30  RATE=40 GROUP=Select
#exec MESH SEQUENCE MESH=razor2 SEQ=Fire    STARTFRAME=32  NUMFRAMES=15
#exec MESH SEQUENCE MESH=razor2 SEQ=Load    STARTFRAME=42  NUMFRAMES=5
#exec MESH SEQUENCE MESH=razor2 SEQ=Idle    STARTFRAME=47  NUMFRAMES=19
#exec MESH SEQUENCE MESH=razor2 SEQ=Still   STARTFRAME=47  NUMFRAMES=19
#exec MESH SEQUENCE MESH=razor2 SEQ=Down    STARTFRAME=67  NUMFRAMES=6
#exec TEXTURE IMPORT NAME=JRazor2 FILE=MODELS\raz1.PCX GROUP=Skins LODSET=2
#exec TEXTURE IMPORT NAME=JRazor3 FILE=MODELS\raz2.PCX GROUP=Skins LODSET=2
#exec TEXTURE IMPORT NAME=JRazor4 FILE=MODELS\raz3.pCX GROUP=Skins LODSET=2
#exec TEXTURE IMPORT NAME=JRazor5 FILE=MODELS\raz4.PCX GROUP=Skins LODSET=2
#exec TEXTURE IMPORT NAME=JRazorw FILE=MODELS\razwhole.PCX GROUP=Skins LODSET=2
#exec TEXTURE IMPORT NAME=RazSkin FILE=MODELS\razorskin.PCX GROUP=Skins LODSET=2
#exec MESHMAP SCALE MESHMAP=razor2 X=0.008 Y=0.005 Z=0.016
#exec MESHMAP SETTEXTURE MESHMAP=razor2 NUM=0 TEXTURE=RazSkin
#exec MESHMAP SETTEXTURE MESHMAP=razor2 NUM=1 TEXTURE=Jrazor2
#exec MESHMAP SETTEXTURE MESHMAP=razor2 NUM=2 TEXTURE=Jrazor4
#exec MESHMAP SETTEXTURE MESHMAP=razor2 NUM=3 TEXTURE=Jrazor5 
#exec MESHMAP SETTEXTURE MESHMAP=razor2 NUM=4 TEXTURE=JRazor3

#exec MESH IMPORT MESH=RazPick2 ANIVFILE=MODELS\razorpick_a.3D DATAFILE=MODELS\razorpick_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=RazPick2 X=0 Y=0 Z=-23 YAW=64 PITCH=0 ROLL=0
#exec MESH SEQUENCE MESH=RazPick2 SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=RazPick2 SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec MESHMAP SCALE MESHMAP=RazPick2 X=0.1 Y=0.1 Z=0.2
#exec MESHMAP SETTEXTURE MESHMAP=RazPick2 NUM=2 TEXTURE=Jrazorw

#exec MESH IMPORT MESH=Razor3rd2 ANIVFILE=MODELS\Razorhand_a.3D DATAFILE=MODELS\Razorhand_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=Razor3rd2 X=260 Y=0 Z=-80 YAW=128 PITCH=0 ROLL=0
#exec MESH SEQUENCE MESH=Razor3rd2 SEQ=All  STARTFRAME=0  NUMFRAMES=1
#exec MESH SEQUENCE MESH=Razor3rd2 SEQ=Still  STARTFRAME=0  NUMFRAMES=1
#exec MESHMAP SCALE MESHMAP=Razor3rd2 X=0.05 Y=0.05 Z=0.1
#exec MESHMAP SETTEXTURE MESHMAP=Razor3rd2 NUM=2 TEXTURE=JRazorw

#exec TEXTURE IMPORT NAME=IconRazor FILE=TEXTURES\HUD\WpnRazJk.PCX GROUP="Icons" MIPS=OFF
#exec TEXTURE IMPORT NAME=UseRazor FILE=TEXTURES\HUD\UseRazJk.PCX GROUP="Icons" MIPS=OFF

function Projectile ProjectileFire(class<projectile> ProjClass, float ProjSpeed, bool bWarn)
{
	local Vector Start, X,Y,Z;

	Owner.MakeNoise(Pawn(Owner).SoundDampening);
	GetAxes(Pawn(owner).ViewRotation,X,Y,Z);
	Start = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z; 
	AdjustedAim = pawn(owner).AdjustAim(ProjSpeed, Start, AimError, True, bWarn);	
	return Spawn(ProjClass,,, Start,AdjustedAim);	
}

simulated function PlayFiring()
{
	LoopAnim( 'Fire', 0.7 + 0.6 * FireAdjust, 0.05 );
	PlayOwnedSound(class'Razor2'.Default.SpawnSound, SLOT_None,4.2);
}


function float RateSelf( out int bUseAltMode )
{
	local Pawn P;

	if ( (AmmoType != None) && (AmmoType.AmmoAmount <=0) )
		return -2;

	P = Pawn(Owner);
	if ( (P.Enemy == None ) || (P.Enemy.Location.Z < Owner.Location.Z - 60) || (FRand() < 0.5) )
		bUseAltMode = 1;
	else 
		bUseAltMode = 0;

	if ( P.Enemy != None )
	{
		if ( Owner.Location.Z > P.Enemy.Location.Z + 140 )
		{
			bUseAltMode = 1;
			return (AIRating + 0.25);
		}
		else if ( P.Enemy.Location.Z > Owner.Location.Z + 160 )
			return (AIRating - 0.07);
	}
	return (AIRating + FRand() * 0.05);
}

function AltFire( float Value )
{
	if ( AmmoType == None )
	{
		// ammocheck
		GiveAmmo(Pawn(Owner));
	}
	if (AmmoType.UseAmmo(1))
	{
		GotoState('AltFiring');
		bCanClientFire = true;
		bPointing=True;
		Pawn(Owner).PlayRecoil(FiringSpeed);
		ClientAltFire(Value);
		ProjectileFire(AltProjectileClass, AltProjectileSpeed, bAltWarnTarget);
	}
}

simulated function PlayAltFiring()
{
	LoopAnim('Fire', 0.4 + 0.3 * FireAdjust,0.05);
	PlayOwnedSound(class'Razor2Alt'.Default.SpawnSound, SLOT_None,4.2);
}

simulated function PlayIdleAnim()
{
	if ( Mesh != PickupViewMesh )
		LoopAnim('Idle', 0.3,0.4);
}

function float SuggestAttackStyle()
{
	return -0.2;
}

function float SuggestDefenseStyle()
{
	return -0.2;
}

state AltFiring
{
	function bool SplashJump()
	{
		return true;
	}
}

defaultproperties
{
	 bSplashDamage=true
	 bRecommendAltSplashDamage=true
 	 InstFlash=-0.3
     InstFog=(X=400.00000,Y=200.00000,Z=0.00000)
    AmmoName=Class'Botpack.BladeHopper'
     PickupAmmoCount=15
     shakemag=120.000000
     AIRating=0.500000
     RefireRate=1.00000
     AltRefireRate=0.830000
	 bRapidFire=true
	 FiringSpeed=2.0
     SelectSound=Sound'UnrealI.Razorjack.beam'
     AutoSwitchPriority=6
     InventoryGroup=6
     BobDamping=0.975000
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     bNoSmooth=False
     bMeshCurvy=False
     CollisionRadius=34.000000
     CollisionHeight=7.000000
     FireOffset=(Y=-15.000000,Z=-13.0)
     ProjectileClass=Class'Botpack.Razor2'
     AltProjectileClass=Class'Botpack.Razor2Alt'
     DeathMessage="%k ripped a chunk of meat out of %o with the %w."
     PickupMessage="You got the Ripper."
     ItemName="Ripper"
     PlayerViewOffset=(X=3.000000,Y=-1.600000,Z=-2.40000)
     PlayerViewMesh=Mesh'Botpack.Razor2'
     PlayerViewScale=1.400000
     PickupViewMesh=Mesh'Botpack.RazPick2'
     ThirdPersonMesh=Mesh'Botpack.Razor3rd2'
     StatusIcon=Texture'Botpack.Icons.UseRazor'
     Icon=Texture'Botpack.Icons.UseRazor'
     Mesh=Mesh'Botpack.RazPick2'
     Mass=50.000000
	 WeaponDescription="Classification: Ballistic Blade Launcher\\n\\nPrimary Fire: Razor sharp titanium disks are launched at a medium rate of speed. Shots will ricochet off of any surfaces.\\n\\nSecondary Fire: Explosive disks are launched at a slow rate of fire.\\n\\nTechniques: Aim for the necks of your opponents."
	 NameColor=(R=0,G=255,B=255)
}
