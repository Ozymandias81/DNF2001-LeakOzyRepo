//=============================================================================
// UT_FlakCannon.
//=============================================================================
class UT_FlakCannon extends TournamentWeapon;

#exec MESH IMPORT MESH=flakm ANIVFILE=MODELS\flakcannon_a.3D DATAFILE=MODELS\flakcannon_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=flakm X=40 Y=0 Z=0 YAW=64 ROLL=124 PITCH=128
#exec MESH SEQUENCE MESH=Flakm SEQ=All     STARTFRAME=0   NUMFRAMES=96
#exec MESH SEQUENCE MESH=Flakm SEQ=Select  STARTFRAME=0   NUMFRAMES=30 RATE=48 GROUP=Select
#exec MESH SEQUENCE MESH=Flakm SEQ=Loading STARTFRAME=30  NUMFRAMES=15
#exec MESH SEQUENCE MESH=Flakm SEQ=Still   STARTFRAME=45  NUMFRAMES=1
#exec MESH SEQUENCE MESH=Flakm SEQ=Fire    STARTFRAME=46  NUMFRAMES=10
#exec MESH SEQUENCE MESH=Flakm SEQ=AltFire STARTFRAME=57  NUMFRAMES=10 RATE=24
#exec MESH SEQUENCE MESH=Flakm SEQ=Sway    STARTFRAME=80  NUMFRAMES=2
#exec MESH SEQUENCE MESH=Flakm SEQ=Down    STARTFRAME=82  NUMFRAMES=10
#exec TEXTURE IMPORT NAME=Flak_t FILE=MODELS\Flak.PCX GROUP="Skins" LODSET=2
#exec TEXTURE IMPORT NAME=Flak_t1 FILE=MODELS\Flak1.PCX GROUP="Skins" LODSET=2
#exec TEXTURE IMPORT NAME=Flak_t2 FILE=MODELS\Flak2.PCX GROUP="Skins" LODSET=2
#exec TEXTURE IMPORT NAME=Flak_t3 FILE=MODELS\Flak3.PCX GROUP="Skins" LODSET=2
#exec TEXTURE IMPORT NAME=Flak_t4 FILE=MODELS\Flak4.PCX GROUP="Skins" LODSET=2
#exec MESHMAP SCALE MESHMAP=flakm  X=0.007 Y=0.003 Z=0.014
#exec MESHMAP SETTEXTURE MESHMAP=flakm NUM=0 TEXTURE=Flak_t1
#exec MESHMAP SETTEXTURE MESHMAP=flakm NUM=1 TEXTURE=Flak_t2
#exec MESHMAP SETTEXTURE MESHMAP=flakm NUM=2 TEXTURE=Flak_t3
#exec MESHMAP SETTEXTURE MESHMAP=flakm NUM=3 TEXTURE=Flak_t4
#exec MESHMAP SETTEXTURE MESHMAP=flakm NUM=4 TEXTURE=Botpack.Ammocount.flakAmmoled

#exec OBJ LOAD FILE=Textures\Ammocount.utx  PACKAGE=Botpack.Ammocount
#exec TEXTURE IMPORT NAME=Flakmuz FILE=MODELS\FlakFlash.PCX GROUP="Skins" LODSET=2

#exec MESH IMPORT MESH=Flak2Pick ANIVFILE=MODELS\FlakPick2_a.3D DATAFILE=MODELS\FlakPick2_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=Flak2Pick X=0 Y=-540 Z=0 YAW=64
#exec MESH SEQUENCE MESH=Flak2Pick SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=Flak2Pick SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec MESHMAP SCALE MESHMAP=Flak2Pick X=0.07 Y=0.07 Z=0.14
#exec MESHMAP SETTEXTURE MESHMAP=Flak2Pick NUM=1 TEXTURE=Flak_t

#exec MESH IMPORT MESH=FlakHand ANIVFILE=MODELS\flakhand_a.3D DATAFILE=MODELS\flakhand_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=FlakHand X=20 Y=-230 Z=-55 YAW=-64 ROLL=0 PITCH=0
#exec MESH SEQUENCE MESH=FlakHand SEQ=All  STARTFRAME=0  NUMFRAMES=10
#exec MESH SEQUENCE MESH=FlakHand SEQ=Still  STARTFRAME=0  NUMFRAMES=1
#exec MESH SEQUENCE MESH=FlakHand SEQ=Fire  STARTFRAME=1  NUMFRAMES=9 RATE=40.0
#exec MESHMAP SCALE MESHMAP=FlakHand X=0.04 Y=0.04 Z=0.08
#exec MESHMAP SETTEXTURE MESHMAP=FlakHand NUM=1 TEXTURE=Flak_t

#exec TEXTURE IMPORT NAME=IconFlak FILE=TEXTURES\HUD\WpnFlak.PCX GROUP="Icons" MIPS=OFF
#exec TEXTURE IMPORT NAME=UseFlak FILE=TEXTURES\HUD\UseFlak.PCX GROUP="Icons" MIPS=OFF

#exec MESH IMPORT MESH=muzzFF3 ANIVFILE=MODELS\flakflash_a.3d DATAFILE=MODELS\flakflash_d.3d X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=muzzFF3 MINVERTS=8 STRENGTH=0.7 ZDISP=800.0
#exec MESH ORIGIN MESH=muzzFF3 X=0 Y=740 Z=-90 YAW=64
#exec MESH SEQUENCE MESH=muzzFF3 SEQ=All                      STARTFRAME=0 NUMFRAMES=1
#exec MESHMAP NEW   MESHMAP=muzzFF3 MESH=muzzFF3
#exec MESHMAP SCALE MESHMAP=muzzFF3 X=0.03 Y=0.075 Z=0.06
#exec TEXTURE IMPORT NAME=MuzzyFlak FILE=MODELS\flakflash2.PCX GROUP=Skins LODSET=2

// return delta to combat style
function float SuggestAttackStyle()
{
	local bot B;

	B = Bot(Owner);
	if ( (B != None) && B.bNovice )
		return 0.2;
	return 0.4;
}

function float SuggestDefenseStyle()
{
	return -0.3;
}

simulated event RenderTexture(ScriptedTexture Tex)
{
	local Color C;
	local string Temp;
	
	if ( AmmoType != None )
		Temp = String(AmmoType.AmmoAmount);

	while(Len(Temp) < 3) Temp = "0"$Temp;

	C.R = 255;
	C.G = 0;
	C.B = 0;

	Tex.DrawColoredText( 30, 10, Temp, Font'LEDFont2', C );	
}


function float RateSelf( out int bUseAltMode )
{
	local float EnemyDist, rating;
	local vector EnemyDir;

	if ( AmmoType.AmmoAmount <=0 )
		return -2;
	if ( Pawn(Owner).Enemy == None )
	{
		bUseAltMode = 0;
		return AIRating;
	}
	EnemyDir = Pawn(Owner).Enemy.Location - Owner.Location;
	EnemyDist = VSize(EnemyDir);
	rating = FClamp(AIRating - (EnemyDist - 450) * 0.001, 0.2, AIRating);
	if ( Pawn(Owner).Enemy.IsA('StationaryPawn') )
	{
		bUseAltMode = 0;
		return AIRating + 0.3;
	}
	if ( EnemyDist > 900 )
	{
		bUseAltMode = 0;
		if ( EnemyDist > 2000 )
		{
			if ( EnemyDist > 3500 )
				return 0.2;
			return (AIRating - 0.3);
		}			
		if ( EnemyDir.Z < -0.5 * EnemyDist )
		{
			bUseAltMode = 1;
			return (AIRating - 0.3);
		}
	}
	else if ( (EnemyDist < 750) && (Pawn(Owner).Enemy.Weapon != None) && Pawn(Owner).Enemy.Weapon.bMeleeWeapon )
	{
		bUseAltMode = 0;
		return (AIRating + 0.3);
	}
	else if ( (EnemyDist < 340) || (EnemyDir.Z > 30) )
	{
		bUseAltMode = 0;
		return (AIRating + 0.2);
	}
	else
		bUseAltMode = int( FRand() < 0.65 );
	return rating;
}


simulated event RenderOverlays( canvas Canvas )
{
	Texture'FlakAmmoled'.NotifyActor = Self;
	Super.RenderOverlays(Canvas);
	Texture'FlakAmmoled'.NotifyActor = None;
}


// Fire chunks
function Fire( float Value )
{
	local Vector Start, X,Y,Z;
	local Bot B;
	local Pawn P;

	if ( AmmoType == None )
	{
		// ammocheck
		GiveAmmo(Pawn(Owner));
	}
	if (AmmoType.UseAmmo(1))
	{
		bCanClientFire = true;
		bPointing=True;
		Start = Owner.Location + CalcDrawOffset();
		B = Bot(Owner);
		P = Pawn(Owner);
		P.PlayRecoil(FiringSpeed);
		Owner.MakeNoise(2.0 * P.SoundDampening);
		AdjustedAim = P.AdjustAim(AltProjectileSpeed, Start, AimError, True, bWarnTarget);
		GetAxes(AdjustedAim,X,Y,Z);
		Spawn(class'WeaponLight',,'',Start+X*20,rot(0,0,0));		
		Start = Start + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;	
		Spawn( class 'UTChunk1',, '', Start, AdjustedAim);
		Spawn( class 'UTChunk2',, '', Start - Z, AdjustedAim);
		Spawn( class 'UTChunk3',, '', Start + 2 * Y + Z, AdjustedAim);
		Spawn( class 'UTChunk4',, '', Start - Y, AdjustedAim);
		Spawn( class 'UTChunk1',, '', Start + 2 * Y - Z, AdjustedAim);
		Spawn( class 'UTChunk2',, '', Start, AdjustedAim);

		// lower skill bots fire less flak chunks
		if ( (B == None) || !B.bNovice || ((B.Enemy != None) && (B.Enemy.Weapon != None) && B.Enemy.Weapon.bMeleeWeapon) )
		{
			Spawn( class 'UTChunk3',, '', Start + Y - Z, AdjustedAim);
			Spawn( class 'UTChunk4',, '', Start + 2 * Y + Z, AdjustedAim);
		}
		else if ( B.Skill > 1 )
			Spawn( class 'UTChunk3',, '', Start + Y - Z, AdjustedAim);

		ClientFire(Value);
		GoToState('NormalFire');
	}
}

simulated function PlayFiring()
{
	PlayAnim( 'Fire', 0.9, 0.05);
	PlayOwnedSound(FireSound, SLOT_Misc,Pawn(Owner).SoundDampening*4.0);	
	bMuzzleFlash++;
}

simulated function PlayAltFiring()
{
	PlayOwnedSound(AltFireSound, SLOT_Misc,Pawn(Owner).SoundDampening*4.0);
	PlayAnim('AltFire', 1.3, 0.05);
	bMuzzleFlash++;
}

function AltFire( float Value )
{
	local Vector Start, X,Y,Z;

	if ( AmmoType == None )
	{
		// ammocheck
		GiveAmmo(Pawn(Owner));
	}
	if (AmmoType.UseAmmo(1))
	{
		Pawn(Owner).PlayRecoil(FiringSpeed);
		bPointing=True;
		bCanClientFire = true;
		Owner.MakeNoise(Pawn(Owner).SoundDampening);
		GetAxes(Pawn(owner).ViewRotation,X,Y,Z);
		Start = Owner.Location + CalcDrawOffset();
		Spawn(class'WeaponLight',,'',Start+X*20,rot(0,0,0));		
		Start = Start + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z; 
		AdjustedAim = pawn(owner).AdjustToss(AltProjectileSpeed, Start, AimError, True, bAltWarnTarget);	
		Spawn(class'FlakSlug',,, Start,AdjustedAim);
		ClientAltFire(Value);	
		GoToState('AltFiring');
	}	
}

////////////////////////////////////////////////////////////
state AltFiring
{
	function EndState()
	{
		Super.EndState();
		OldFlashCount = FlashCount;
	}

	function AnimEnd()
	{
		if ( (AnimSequence != 'Loading') && (AmmoType.AmmoAmount > 0) )
			PlayReloading();
		else
			Finish();
	}
		
Begin:
	FlashCount++;
}

/////////////////////////////////////////////////////////////
simulated function PlayReloading()
{
	PlayAnim('Loading',0.7, 0.05);
	Owner.PlayOwnedSound(CockingSound, SLOT_None,0.5*Pawn(Owner).SoundDampening);		
}

simulated function PlayFastReloading()
{
	PlayAnim('Loading',1.4, 0.05);
	Owner.PlayOwnedSound(CockingSound, SLOT_None,0.5*Pawn(Owner).SoundDampening);		
}

state ClientReload
{
	simulated function bool ClientFire(float Value)
	{
		bForceFire = bForceFire || ( bCanClientFire && (Pawn(Owner) != None) && (AmmoType.AmmoAmount > 0) );
		return bForceFire;
	}

	simulated function bool ClientAltFire(float Value)
	{
		bForceAltFire = bForceAltFire || ( bCanClientFire && (Pawn(Owner) != None) && (AmmoType.AmmoAmount > 0) );
		return bForceAltFire;
	}

	simulated function AnimEnd()
	{
		if ( bCanClientFire && (PlayerPawn(Owner) != None) && (AmmoType.AmmoAmount > 0) )
		{
			if ( bForceFire || (Pawn(Owner).bFire != 0) )
			{
				Global.ClientFire(0);
				return;
			}
			else if ( bForceAltFire || (Pawn(Owner).bAltFire != 0) )
			{
				Global.ClientAltFire(0);
				return;
			}
		}			
		GotoState('');
		Global.AnimEnd();
	}

	simulated function EndState()
	{
		bForceFire = false;
		bForceAltFire = false;
	}

	simulated function BeginState()
	{
		bForceFire = false;
		bForceAltFire = false;
	}
}

state ClientFiring
{
	simulated function AnimEnd()
	{
		if ( (Pawn(Owner) == None) || (Ammotype.AmmoAmount <= 0) )
		{
			PlayIdleAnim();
			GotoState('');
		}
		else if ( !bCanClientFire )
			GotoState('');
		else
		{
			PlayFastReloading();
			GotoState('ClientReload');
		}
	}
}

state ClientAltFiring
{
	simulated function AnimEnd()
	{
		if ( (Pawn(Owner) == None) || (Ammotype.AmmoAmount <= 0) )
		{
			PlayIdleAnim();
			GotoState('');
		}
		else if ( !bCanClientFire )
			GotoState('');
		else
		{
			PlayReloading();
			GotoState('ClientReload');
		}

	}
}

state NormalFire
{
	function EndState()
	{
		Super.EndState();
		OldFlashCount = FlashCount;
	}

	function AnimEnd()
	{
		if ( (AnimSequence != 'Loading') && (AmmoType.AmmoAmount > 0) )
			PlayFastReloading();
		else
			Finish();
	}
		
Begin:
	FlashCount++;
}

///////////////////////////////////////////////////////////
simulated function TweenDown()
{
	if ( IsAnimating() && (AnimSequence != '') && (GetAnimGroup(AnimSequence) == 'Select') )
		TweenAnim( AnimSequence, AnimFrame * 0.4 );
	else if ( AmmoType.AmmoAmount < 1 )
		TweenAnim('Select', 0.5);
	else
		PlayAnim('Down',1.0, 0.05);
}

simulated function PlayIdleAnim()
{
}

simulated function PlayPostSelect()
{
	PlayAnim('Loading', 1.3, 0.05);
	Owner.PlayOwnedSound(Misc2Sound, SLOT_None,1.3*Pawn(Owner).SoundDampening);	
}

defaultproperties
{
	 InstFlash=-0.4
     InstFog=(X=650.00000,Y=450.00000,Z=190.00000)
     AmmoName=Class'Botpack.flakammo'
     PickupAmmoCount=10
     bWarnTarget=True
     bAltWarnTarget=True
     bSplashDamage=True
     FiringSpeed=1.000000
     FireOffset=(X=10.000000,Y=-11.000000,Z=-15.000000)
     ProjectileClass=Class'Botpack.UTChunk'
     AltProjectileClass=Class'Botpack.FlakSlug'
     aimerror=700.000000
     shakemag=350.000000
     shaketime=0.150000
     shakevert=8.500000
     AIRating=0.750000
     FireSound=Sound'UnrealShare.flak.shot1'
     AltFireSound=Sound'UnrealShare.flak.Explode1'
     CockingSound=Sound'UnrealI.flak.load1'
     SelectSound=Sound'UnrealI.flak.pdown'
     Misc2Sound=Sound'UnrealI.flak.Hidraul2'
     DeathMessage="%o was ripped to shreds by %k's %w."
     bDrawMuzzleFlash=True
     MuzzleScale=2.000000
     FlashY=0.160000
     FlashO=0.015000
     FlashC=0.10000
     FlashLength=0.020000
     FlashS=256
     MFTexture=Texture'Botpack.Skins.Flakmuz'
     AutoSwitchPriority=8
     InventoryGroup=8
     PickupMessage="You got the Flak Cannon."
     ItemName="Flak Cannon"
     PlayerViewOffset=(X=1.500000,Y=-1.000000,Z=-1.650000)
     PlayerViewMesh=LodMesh'Botpack.flakm'
     PlayerViewScale=1.200000
     BobDamping=0.972000
     PickupViewMesh=LodMesh'Botpack.Flak2Pick'
     ThirdPersonMesh=LodMesh'Botpack.FlakHand'
     StatusIcon=Texture'Botpack.Icons.UseFlak'
     bMuzzleFlashParticles=True
     MuzzleFlashStyle=STY_Translucent
     MuzzleFlashMesh=LodMesh'Botpack.muzzFF3'
     MuzzleFlashScale=0.400000
     MuzzleFlashTexture=Texture'Botpack.Skins.MuzzyFlak'
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     Icon=Texture'Botpack.Icons.UseFlak'
     Mesh=LodMesh'Botpack.Flak2Pick'
     bNoSmooth=False
     CollisionRadius=32.000000
     CollisionHeight=23.000000
     LightBrightness=228
     LightHue=30
     LightSaturation=71
     LightRadius=14
	 WeaponDescription="Classification: Heavy Shrapnel\\n\\nPrimary Fire: White hot chunks of scrap metal are sprayed forth, shotgun style.\\n\\nSecondary Fire: A grenade full of shrapnel is lobbed at the enemy.\\n\\nTechniques: The Flak Cannon is far more useful in close range combat situations."
	 NameColor=(R=255,G=96,B=0)
}
