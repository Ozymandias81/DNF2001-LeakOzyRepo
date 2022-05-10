/*-----------------------------------------------------------------------------
	M-16
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class M16 expands dnWeapon;

#exec OBJ LOAD FILE=..\Meshes\c_dnWeapon.dmx
#exec OBJ LOAD FILE=..\Sounds\dnsWeapn.dfx
#exec OBJ LOAD FILE=..\Textures\m_dnWeapon.dtx

var float						FireAccuracy;
var int							BurstCount;

var rotator						RestRotation, DesiredViewRotation, ViewRotationRate;
var float						LastLookUp, LastTurn;
var bool						RotateToDesiredView;

var sound						DryFireSound;



/*-----------------------------------------------------------------------------
	Initialization
-----------------------------------------------------------------------------*/

// Object initialization is handled here.
simulated function PreBeginPlay()
{
	Super.PreBeginPlay();
}



/*-----------------------------------------------------------------------------
	Damage & Tracing
-----------------------------------------------------------------------------*/

// Returns the damage for this hit.
simulated function int GetHitDamage( actor Victim, name BoneName )
{
    local Pawn.EPawnBodyPart BodyPart;
	local float Dmg;
    
    BodyPart = BODYPART_Default;
    if ( Pawn(Victim)!=None )
		BodyPart = Pawn(Victim).GetPartForBone( BoneName );

	switch( BodyPart )
	{
	case BODYPART_Head:
		Dmg = 17.5 + FRand()*5.0;
		break;
	case BODYPART_Chest:
	case BODYPART_Stomach:
		Dmg = 4.0 + FRand()*5.0;
		break;
	case BODYPART_Crotch:
	case BODYPART_ShoulderLeft:
	case BODYPART_ShoulderRight:
	case BODYPART_KneeLeft:
	case BODYPART_KneeRight:
	case BODYPART_Default:
		Dmg = 3.0 + FRand()*5.0;
		break;
	case BODYPART_HandLeft:
	case BODYPART_HandRight:
	case BODYPART_FootLeft:
	case BODYPART_FootRight:
		Dmg = 2.0 + FRand()*5.0;
		break;
	}

	if ( (Victim != None) && (Victim.IsA('PlayerPawn')) )
	{
		// JC Temporary hack.
		if ( (!Owner.IsA('PlayerPawn')) )
			Dmg = 4.0;
		else Dmg = 7.0;
	}
	// Multiply by weapon third person scale for the shrinkray effect.
	Dmg *= ThirdPersonScale;

	return Max( (int(Dmg+0.5)), 1 );
}

// Counts bursts for hit effects.
simulated function TraceFire( Actor HitInstigator, 
				    optional float HorizError, optional float VertError, 
					optional bool bDontPenetrate, optional bool bEffectsOnly,
					optional bool bNoActors, optional bool bNoMeshAccurate,
					optional bool bNoCreationSounds )
{
	BurstCount++;
	if ( (BurstCount>=4) && ((BurstCount%3) != 0) )
		TraceHitCategory = TH_NoMaterialEffectBullet;
	else
		TraceHitCategory = TH_Bullet;

	if ( BurstCount < 3 )
		Super.TraceFire( HitInstigator, 0.005, 0.005, bDontPenetrate, bEffectsOnly, bNoActors, bNoMeshAccurate, bNoCreationSounds );
	else
		Super.TraceFire( HitInstigator, HorizError + 0.03, VertError + 0.03, bDontPenetrate, bEffectsOnly, bNoActors, bNoMeshAccurate, bNoCreationSounds );
}



/*-----------------------------------------------------------------------------
	Firing and Input
-----------------------------------------------------------------------------*/

// Plays a dry fire sound if we are out of ammo.
simulated function bool ClientFire()
{
	if ( AmmoType.OutOfAmmo() )
	{
		PlayOwnedSound( DryFireSound );
		return false;
	}

	return Super.ClientFire();
}

// Plays a dry fire sound if we are out of ammo.
simulated function bool ClientAltFire()
{
	if ( AltAmmoType.OutOfAmmo() )
	{
		PlayOwnedSound( DryFireSound );
		return false;
	}

	return Super.ClientAltFire();
}

// Plays a dry fire sound if we are out of ammo.
function Fire()
{
	if ( AmmoType.OutOfAmmo() )
	{
		if ( Owner.IsA('PlayerPawn') )
			PlayerPawn(Owner).bFire = 0;
		PlayOwnedSound( DryFireSound );
		return;
	}

	if ( GottaReload() )
	{
		Reload();
		return;
	}

	Super.Fire();
}

// Plays a dry fire sound if we are out of ammo.
function AltFire()
{
	if ( AltAmmoType.OutOfAmmo() )
	{
		if ( Owner.IsA('PlayerPawn') )
			PlayerPawn(Owner).bAltFire = 0;
		PlayOwnedSound( DryFireSound );
		return;
	}

	Super.AltFire();
}



/*-----------------------------------------------------------------------------
	Ammo
-----------------------------------------------------------------------------*/

// Returns true if we are out of ammo.
simulated function bool OutOfAmmo()
{
	if ((AmmoType != None) && (AmmoType.ModeAmount[0] == 0) &&
		(AltAmmoType != None) && (AltAmmoType.ModeAmount[0] == 0))
		return true;
	else
		return false;
}

// Draws the ammo amount in the Q-menu.
simulated function DrawAmmoAmount( Canvas C, DukeHUD HUD, float X, float Y )
{
	local float AmmoScale;

	// 7.62
	AmmoScale = float(AmmoType.ModeAmount[0]) / AmmoType.MaxAmmo[0];
	DrawAmmoBar( C, HUD, AmmoScale, X+4*HUD.HUDScaleX*0.8, Y+51*HUD.HUDScaleY*0.8 );

	// Grenades
	AmmoScale = float(AltAmmoType.ModeAmount[0]) / AltAmmoType.MaxAmmo[0];
	DrawAmmoBar( C, HUD, AmmoScale, X+4*HUD.HUDScaleX*0.8, Y+55*HUD.HUDScaleY*0.8 );
}



/*-----------------------------------------------------------------------------
	Animation Events
-----------------------------------------------------------------------------*/

// Overridden for weapon creep logic.
simulated function WpnFire( optional bool noWait )
{
	local bool bWild;

	Super.WpnFire( noWait );

	if ( Owner.IsA('PlayerPawn') && (Level.NetMode == NM_Standalone) )
	{
		RotateToDesiredView = false;
		if ( Normalize(PlayerPawn(Owner).ViewRotation).Pitch < 16384 )
		{
			if ( BurstCount == 2 )
				RestRotation = PlayerPawn(Owner).ViewRotation;
			else if ( PlayerPawn(Owner).ViewRotation.Pitch == RestRotation.Pitch )
				PlayerPawn(Owner).ViewRotation.Pitch += 92 + Rand(64);
			else if ( (BurstCount > 3) && (PlayerPawn(Owner) != None) )
			{
				if ( (PlayerPawn(Owner).ViewRotation.Pitch - RestRotation.Pitch > 0) &&
				    (PlayerPawn(Owner).ViewRotation.Pitch - RestRotation.Pitch < 1670) )
					PlayerPawn(Owner).ViewRotation.Pitch += 92 + Rand(64);
				else if ( (PlayerPawn(Owner).ViewRotation.Pitch - RestRotation.Pitch < 0) &&
						 (PlayerPawn(Owner).ViewRotation.Pitch - RestRotation.Pitch < -63866) )
					PlayerPawn(Owner).ViewRotation.Pitch += 92 + Rand(64);
				else
					bWild = true; // Reach top of deviation.

				// Left right deviance.  If we are "wild" kick more left and right.
				if ( bWild )
				{
					PlayerPawn(Owner).ViewRotation.Yaw += Rand(256);
					PlayerPawn(Owner).ViewRotation.Yaw -= Rand(256);
				} else if ( BurstCount > 10 )
				{
					PlayerPawn(Owner).ViewRotation.Yaw += Rand(128);
					PlayerPawn(Owner).ViewRotation.Yaw -= Rand(128);
				} else {
					PlayerPawn(Owner).ViewRotation.Yaw += Rand(64);
					PlayerPawn(Owner).ViewRotation.Yaw -= Rand(64);
				}
			}
		}
	}
}

// Overridden for weapon creep logic.
simulated function WpnFireStop( optional bool noWait )
{
	Super.WpnFireStop( noWait );

	BurstCount = 0;
	if ( (Owner != None) && Owner.IsA('PlayerPawn') )
		RotateViewTo( RestRotation );
}

// Overridden for weapon creep logic.
simulated function WpnAltFireStop()
{
	FireAccuracy = 0.0;
	Super.WpnAltFireStop();
}

// Overridden for weapon creep logic.
simulated function Tick( float Delta )
{
	Super.Tick( Delta );

	if ( Level.NetMode != NM_Standalone )
		return;

	if ( (Owner != None) && (Owner.IsA('PlayerPawn')) )
	{
		if ( (PlayerPawn(Owner).LastLookUp != LastLookUp) || (PlayerPawn(Owner).LastTurn != LastTurn) )
		{
			RestRotation = PlayerPawn(Owner).ViewRotation;
			LastLookUp = PlayerPawn(Owner).LastLookUp;
			LastTurn = PlayerPawn(Owner).LastTurn;
			RotateToDesiredView = false;
		}
		if ( RotateToDesiredView && (PlayerPawn(Owner).ViewRotation != DesiredViewRotation) )
		{
			PlayerPawn(Owner).ViewRotation.Pitch = 
				FixedTurn( PlayerPawn(Owner).ViewRotation.Pitch, DesiredViewRotation.Pitch, ViewRotationRate.Pitch * Delta );
			PlayerPawn(Owner).ViewRotation.Yaw = 
				FixedTurn( PlayerPawn(Owner).ViewRotation.Yaw, DesiredViewRotation.Yaw, ViewRotationRate.Yaw * Delta );
		}
	}
}

// Rotates the player's view to a given rotation.
simulated function RotateViewTo( rotator NewViewRotation )
{
	local float Seconds;

	if ( Level.NetMode != NM_Standalone )
		return;

	Seconds = 0.2;
	DesiredViewRotation = NewViewRotation;
	RotateToDesiredView = true;

	if ( DesiredViewRotation != PlayerPawn(Owner).ViewRotation )
	{
		ViewRotationRate.Yaw   = Abs(RotationDistance(PlayerPawn(Owner).ViewRotation.Yaw,   DesiredViewRotation.yaw)) / Seconds;
		ViewRotationRate.Pitch = Abs(RotationDistance(PlayerPawn(Owner).ViewRotation.Pitch, DesiredViewRotation.pitch)) / Seconds;
		ViewRotationRate.Roll  = Abs(RotationDistance(PlayerPawn(Owner).ViewRotation.Roll,  DesiredViewRotation.roll)) / Seconds;
	}
}



defaultproperties
{
    SAnimActivate(0)=(AnimSound=Sound'dnsWeapn.m16.M16Cock1')
    SAnimFire(0)=(AnimSeq=FireA,AnimRate=1.2,AnimSound=Sound'dnsWeapn.m16.GunFire053',AlternateSound=true)
    SAnimFireStop(0)=(AnimChance=1.000000,animSeq=FireEndA,AnimRate=1.000000,AnimTween=0.070000)
    SAnimAltFire(0)=(AnimSeq=AltFire,AnimSound=Sound'dnsWeapn.m16.M16GrenadeFire22')
    SAnimIdleSmall(0)=(AnimSeq=IdleA,AnimRate=0.750000,AnimTween=0.000000,AnimChance=0.5)
	SAnimIdleSmall(1)=(AnimSeq=IdleB,AnimRate=1.000000,AnimTween=0.000000,AnimChance=0.5)
	SAnimIdleLarge(0)=(AnimSeq=IdleC,AnimRate=1.000000,AnimTween=0.000000,AnimChance=0.8)
	SAnimIdleLarge(1)=(AnimSeq=IdleD,AnimRate=1.000000,AnimTween=0.000000,AnimChance=0.2)
    SAnimReload(0)=(AnimRate=1.620000)

    NotifySounds(0)=Sound'dnsWeapn.m16.M16ClipEj1'
    NotifySounds(1)=Sound'dnsWeapn.m16.M16ClipLoad1'
    NotifySounds(2)=Sound'dnsWeapn.m16.M16Cock1'
    NotifySounds(3)=Sound'dnsWeapn.m16.M16GrenRel1'
	ShellBounceSound=sound'dnsWeapn.pistol.PShellPing1'

    AmmoName=Class'dnGame.m16Clip'
    AltAmmoName=Class'dnGame.m16GAmmo'
	AmmoItemClass=class'HUDIndexItem_M16Gun'
	AltAmmoItemClass=class'HUDIndexItem_M16GunAlt'
	ReloadCount=30
	PickupAmmoCount(0)=30
    AltPickupAmmoCount(0)=0

    bInstantHit=true
    FireOffset=(X=2.0,Y=-0.9,Z=-6.15)
    AltFireOffset=(X=40.0,Y=14.0,Z=-30.0)

    AIRating=0.9

    AutoSwitchPriority=5

	ItemName="M-16"
    PickupSound=Sound'dnGame.Pickups.WeaponPickup'
	PickupIcon=texture'hud_effects.am_m16'
    Icon=Texture'hud_effects.mitem_m16'
    AnimRate=0.750000

	PlayerViewScale=0.1
    PlayerViewOffset=(X=0.45,Y=0.384,Z=-8.77)
    PlayerViewMesh=Mesh'c_dnWeapon.m16'
    PickupViewMesh=Mesh'c_dnWeapon.w_m16'
    ThirdPersonMesh=Mesh'c_dnWeapon.w_m16'
    Mesh=Mesh'c_dnWeapon.w_m16'

    SoundRadius=64
    SoundVolume=200
    CollisionHeight=6.0
    CollisionRadius=19.0

	RunAnim=(AnimSeq=A_Run_2HandGun,AnimChan=WAC_All,AnimRate=1.0,AnimTween=0.1,AnimLoop=true)
    FireAnim=(AnimSeq=T_M16Fire,AnimChan=WAC_Top,AnimRate=1.0,AnimTween=0.1,AnimLoop=false)
    AltFireAnim=(AnimSeq=T_M16AltFire,AnimChan=WAC_Top,AnimRate=1.0,AnimTween=0.1,AnimLoop=false)
    IdleAnim=(AnimSeq=T_M16Idle,AnimChan=WAC_Top,AnimRate=1.0,AnimTween=0.1,AnimLoop=true)
    ReloadStartAnim=(AnimSeq=T_M16Reload,AnimChan=WAC_Top,AnimRate=1.0,AnimTween=0.1,AnimLoop=false)
    CrouchIdleAnim=(AnimSeq=T_CrchIdle_GenGun,AnimChan=WAC_Top,AnimRate=1.0,AnimTween=0.1,AnimLoop=true)
    CrouchWalkAnim=(AnimSeq=A_CrchWalk_GenGun,AnimChan=WAC_All,AnimRate=1.0,AnimTween=0.1,AnimLoop=true)
    CrouchFireAnim=(AnimSeq=T_CrchFire_GenGun,AnimChan=WAC_Top,AnimRate=1.0,AnimTween=0.1,AnimLoop=false)

	MuzzleFlashOrigin=(X=0,Y=0,Z=8)
	MuzzleFlashClass=class'M16Flash'

	bDropShell=true
	ShellOffset=(X=10.0,Y=6.5,Z=-10.0)
	ShellVelocity=(X=0.4,Y=0.4,Z=0.3)
	bBoneDamage=true

	dnInventoryCategory=1
	dnCategoryPriority=2

	LodMode=LOD_Disabled

	MuzzleFlashSprites(0)=texture'm_dnWeapon.m16flash1aRC'
	MuzzleFlashSprites(1)=texture'm_dnWeapon.m16flash1bRC'
	MuzzleFlashSprites(2)=texture'm_dnWeapon.m16flash1cRC'
	NumFlashSprites=3
	SpriteFlashX=370.0
	SpriteFlashY=265.0
	MuzzleFlashScale=2.0
	UseSpriteFlash=true

	AltMuzzleFlashSprites(0)=texture'm_dnWeapon.muzzleflash11arc'
	AltMuzzleFlashSprites(1)=texture'm_dnWeapon.muzzleflash11brc'
	AltNumFlashSprites=1
	AltSpriteFlashX=320.0
	AltSpriteFlashY=240.0
	AltMuzzleFlashScale=4
	UseAltSpriteFlash=true
	AltMuzzleFlashLength=0.12
	bAltMultiFrameFlash=true
	bAltMuzzleFlashRotates=false

	bTraceHitRicochets=true
	bBeamTraceHit=true
	DryFireSound=sound'dnsWeapn.foley.DryFire01'

	bFireStart=false
	bFireStop=true
	bAltFireStart=false
	bAltFireStop=false
	bInterruptFire=true

	CrosshairIndex=10
	TraceDamageType=class'M16Damage'

	bFireIgnites=true
	bAltFireIgnites=true
	bUseMuzzleAnchor=true

	bShrunkAltProjectile=true
	AltProjectileClass=class'dnGrenade'
	ShrunkAltProjectileClass=class'dnGrenadeShrunk'
	AltProjectileSpeed=600.0
}
