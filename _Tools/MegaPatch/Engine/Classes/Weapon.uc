/*-----------------------------------------------------------------------------
	Weapon
	Author: Brandon Reinhart

	Note to self: Clean up fixme's.

	When a client PlayerPawn fires, bFire and bJustFired are set on the PlayerPawn.
	When a server/singleplayer PlayerPawn fires, Fire() is called.

	Multiplayer Issues:
		- No 3rd person reload anims in netplay.
-----------------------------------------------------------------------------*/
class Weapon extends Inventory
	abstract
	native;

#exec Texture Import File=Textures\Weapon.pcx Name=S_Weapon Mips=Off Flags=2

// Ammo
var()			class<Ammo>			AmmoName;					// Type of ammo used.
var()			byte				ReloadCount;				// Amount of ammo depletion before reloading. 0 if no reloading is done.
var()			int					PickupAmmoCount[4];			// Amount of ammo initially in pick-up item.
var travel		Ammo				AmmoType;					// Inventory Ammo being used.
var()			bool				bInstantHit;				// If true, instant hit rather than projectile firing weapon
var()			bool				bAltInstantHit;				// If true, instant hit rather than projectile firing weapon for AltFire
var()			class<ammo>			AltAmmoName;
var()			byte				AltReloadCount;
var()			int					AltPickupAmmoCount[4];
var				travel ammo			AltAmmoType;
var				int					AmmoLoaded, AltAmmoLoaded, TempLoadCount;
var()			byte				ReloadClipAmmo;
var				bool				bWeaponPenetrates;

// State Management
var				bool				bWeaponUp;					// Used in Active State
var				bool				bChangeWeapon;				// Used in Active State
var				bool				bClientDown;

// AI Control
var(WeaponAI)	bool				bSplashDamage;				// Used by bot AI
var(WeaponAI)	bool				bRecommendSplashDamage;		// If true, bot preferentially tries to use splash damage.
var(WeaponAI)	bool				bRecommendAltSplashDamage;	// If true, bot preferentially tries to use splash damage.
var(WeaponAI)	bool				bMeleeWeapon;				// Weapon is only a melee weapon.
var(WeaponAI)	float				AIRating;
var				float				AimError;					// Aim Error for Bots (note this value doubled if instant hit weapon).
var				rotator				Weapon3rdRotation;			// Rotation of 3rd person weapon.
var				bool				bOwnerFire;					// Handle trace fire in the owner class rather than the weapon.

// Render
var				bool				bHideWeapon;				// If true, weapon is not rendered

// Projectile / Firing
var()			vector				FireOffset;					// Offset from drawing location for projectile/trace start
var()			vector				AltFireOffset;
var				bool				bShrunkProjectile;
var()			class<Projectile>	ProjectileClass;
var()			class<Projectile>	ShrunkProjectileClass;
var				bool				bShrunkAltProjectile;
var()			class<Projectile>	AltProjectileClass;
var()			class<Projectile>	ShrunkAltProjectileClass;
var				float				ProjectileSpeed;
var				float				AltProjectileSpeed;
var				Rotator				AdjustedAim;

// General Gameplay
var()			bool				bCanThrow;					// If true, player can toss this weapon out.
var()			bool				bWeaponStay;
var				bool				bFastActivate;

// Muzzle Flash
var				vector				Weapon3rdLocation;
var				class<Actor>		MuzzleFlashClass;
var				vector				MuzzleFlashOrigin;
var				bool				AttachMuzzleFlashFirst;
var				texture				MuzzleFlashSprites[6];
var				int					NumFlashSprites;
var				texture				MuzzleFlashSprite;
var				float				MuzzleFlashTime, MuzzleFlashLength;
var				float				MuzzleFlashScale, SpriteFlashX, SpriteFlashY, MuzzleSpriteAlpha, MuzzleFlashRotation;
var				bool				UseSpriteFlash, bMultiFrameFlash, bMuzzleFlashRotates;
var				Actor				MuzzleFlash3rd;

var				texture				AltMuzzleFlashSprites[6];
var				int					AltNumFlashSprites;
var				texture				AltMuzzleFlashSprite;
var				float				AltMuzzleFlashTime, AltMuzzleFlashLength;
var				float				AltMuzzleFlashScale, AltSpriteFlashX, AltSpriteFlashY, AltMuzzleSpriteAlpha, AltMuzzleFlashRotation;
var				bool				UseAltSpriteFlash, bAltMultiFrameFlash, bAltMuzzleFlashRotates;


// Safe Zone
var				bool				bUseAnytime;				// Weapon can be used in safe zone.

// MultiMode Weapon Support
var bool							bMultiMode, bCanChangeMode;
var float							ReloadTimer;
var sound							ModeChangeSound;

// Selective Audio Control
var ESoundSlot						LastSoundSlot;
var bool							bNoAnimSound;

// Bone Damage
var bool							bBoneDamage;
var bool							bDecapitates;

// Shells
var bool							bDropShell;
var	sound							ShellBounceSound;
var mesh							ShellMesh;
var vector							ShellOffset;
var vector							ShellVelocity;
var vector							ShellOffset3rd;
var vector							MuzzleLocation;

var bool							ReloadLoops;
var bool                            bDontPlayOwnerAnimation;	// Used for disabling the animations on the weapons owner

// Animation controls.
enum E3rdPersonWeaponAnimationChannel
{
    WAC_All,
    WAC_Top,
    WAC_Bottom,
    WAC_Special,
};

struct native WAMEntry
{
	var() float                              AnimChance;        // Percent chance of animation occuring, from 0 to 1.
	var() name                               AnimSeq;			// Name of sequence to play.
	var() float                              AnimRate;			// Rate of sequence.
	var() float                              AnimTween;			// Tween rate of sequence.
    var() E3rdPersonWeaponAnimationChannel   AnimChan;          // Which channel to play the sequence.
    var() bool                               AnimLoop;          // Loop the animation
 	var() sound                              AnimSound;			// Sound to play when sequence starts.
	var() sound                              AnimSound2;		// Another sound to play when sequence starts.
	var() bool                               AlternateSound;
    var() string                             DebugString;       // Used for debugging
    var() bool                               PlayNone;          // Force play 'None' on the channel
};

var			  bool				    StayAlert;
var transient int					ActiveWAMIndex;				// Internal index to keep track of currently selected anim.
var transient float					LargeIdleTimer;				// Internal time value used to limit when large idle anims are played.
var(Animation) WAMEntry				SAnimActivate[4];			// Weapon is being activated (brought up)
var(Animation) WAMEntry				SAnimDeactivate[4];			// Weapon is being deactivated (put down)
var(Animation) WAMEntry				SAnimFireStart[4];			// Weapon has started being fired (press)
var(Animation) WAMEntry				SAnimFire[4];				// Weapon is within a potentially looping sustained fire (drag)
var(Animation) WAMEntry				SAnimFireStop[4];			// Weapon has stopped being fired (release)
var(Animation) WAMEntry				SAnimAltFireStart[4];		// Weapon has started being altfired (press)
var(Animation) WAMEntry				SAnimAltFire[4];			// Weapon is within a potentially looping sustained altfire (drag)
var(Animation) WAMEntry				SAnimAltFireStop[4];		// Weapon has stopped being altfired (release)
var(Animation) WAMEntry				SAnimReloadStart[4];		// Weapon has started being reloaded
var(Animation) WAMEntry				SAnimReload[4];				// Weapon is within a potentially looping reload (see ReloadClipAmmo below)
var(Animation) WAMEntry				SAnimReloadStop[4];			// Weapon has stopped being reloaded
var(Animation) WAMEntry				SAnimIdleSmall[4];			// Weapon is idling normally (small anims, i.e. bobbings etc.)
var(Animation) WAMEntry				SAnimIdleLarge[4];			// Weapon is idling after a sustained period of no activity (large anims)
var(Weapon)    sound				NotifySounds[8];			// Additional sounds triggered by notifys.

// 3rd Person Animations
var(ThirdPersonAnimation) WAMEntry	IdleAnim;
var(ThirdPersonAnimation) WAMEntry	RunAnim;
var(ThirdPersonAnimation) WAMEntry	FireAnim;
var(ThirdPersonAnimation) WAMEntry	AltFireAnim;
var(ThirdPersonAnimation) WAMEntry	FireStartAnim;
var(ThirdPersonAnimation) WAMEntry	FireStopAnim;
var(ThirdPersonAnimation) WAMEntry	CrouchIdleAnim;
var(ThirdPersonAnimation) WAMEntry	CrouchWalkAnim;
var(ThirdPersonAnimation) WAMEntry  CrouchFireAnim;
var(ThirdPersonAnimation) WAMEntry	ReloadStartAnim;
var(ThirdPersonAnimation) WAMEntry 	ReloadLoopAnim;
var(ThirdPersonAnimation) WAMEntry 	ReloadStopAnim;
var(ThirdPersonAnimation) WAMEntry 	ThrowAnim;
var                       WAMEntry  NoAnim;                     // Used for returning No Animation available

// Client Side Weapon
enum EAnimSentry
{
	AS_None,
	AS_Start,
	AS_Middle,
	AS_Stop,
};
var EAnimSentry						FireAnimSentry;
var EAnimSentry						ReloadAnimSentry;
var bool							bCantSendFire;				// True if the client can send bFire to the server.
var bool							bDontAllowFire;				// If true, client can't send fire messages at all.
var bool							bReloadStart, bReloadStop;
var bool							bFireStart, bFireStop;
var bool							bAltFireStart, bAltFireStop;
var bool							bAltFiring, bInterruptFire;
var bool							bInterruptSingleReload;
var bool							bInterruptableReload;
enum EWeaponState
{
    WS_NONE,
    WS_ACTIVATE,
    WS_DEACTIVATED,
    WS_IDLE,
    WS_IDLE_SMALL,
    WS_IDLE_LARGE,
    WS_FIRE,   
    WS_FIRE_START,
    WS_FIRE_STOP,
    WS_ALT_FIRE,
    WS_ALT_FIRE_START,
    WS_ALT_FIRE_STOP,
    WS_RELOAD,
    WS_RELOAD_START,
    WS_RELOAD_STOP,
    WS_FIRE_JAM,
    WS_ALT_FIRE_JAM
};
var transient EWeaponState WeaponState, LastWeaponState;		// Replicated weapon state to clients
var transient int WeaponFireImpulse, LastWeaponFireImpulse;		// Replicated impulse for triggering client side fire effects.
var transient int SpecialFireCode;

var bool bNoShake;
var bool bFireIgnites, bAltFireIgnites;

var BeamAnchor						MuzzleAnchor;
var bool							bUseMuzzleAnchor;

/*-----------------------------------------------------------------------------
	Replication
-----------------------------------------------------------------------------*/

replication
{
	// Things the server should send to the client.
	reliable if( bNetOwner && Role==ROLE_Authority )
		AmmoType, AltAmmoType, bHideWeapon, AmmoLoaded, AltAmmoLoaded;
    reliable if ( !bNetOwner && (Role == ROLE_Authority) )
        WeaponState, WeaponFireImpulse, SpecialFireCode;

	// Functions called by server on client
	reliable if( Role==ROLE_Authority )
		ClientSelectWeapon;
}




/*-----------------------------------------------------------------------------
	Special notifications called from Cannibal.
-----------------------------------------------------------------------------*/

simulated function PlayNotifySound0() { if ( (Owner == None) || (Instigator == None) ) return; Owner.PlaySound(NotifySounds[0], SLOT_None, Instigator.SoundDampening*0.4); }
simulated function PlayNotifySound1() { if ( (Owner == None) || (Instigator == None) ) return; Owner.PlaySound(NotifySounds[1], SLOT_None, Instigator.SoundDampening*0.4); }
simulated function PlayNotifySound2() { if ( (Owner == None) || (Instigator == None) ) return; Owner.PlaySound(NotifySounds[2], SLOT_None, Instigator.SoundDampening*0.4); }
simulated function PlayNotifySound3() { if ( (Owner == None) || (Instigator == None) ) return; Owner.PlaySound(NotifySounds[3], SLOT_None, Instigator.SoundDampening*0.4); }
simulated function PlayNotifySound4() { if ( (Owner == None) || (Instigator == None) ) return; Owner.PlaySound(NotifySounds[4], SLOT_None, Instigator.SoundDampening*0.4); }
simulated function PlayNotifySound5() { if ( (Owner == None) || (Instigator == None) ) return; Owner.PlaySound(NotifySounds[5], SLOT_None, Instigator.SoundDampening*0.4); }
simulated function PlayNotifySound6() { if ( (Owner == None) || (Instigator == None) ) return; Owner.PlaySound(NotifySounds[6], SLOT_None, Instigator.SoundDampening*0.4); }
simulated function PlayNotifySound7() { if ( (Owner == None) || (Instigator == None) ) return; Owner.PlaySound(NotifySounds[7], SLOT_None, Instigator.SoundDampening*0.4); }



/*-----------------------------------------------------------------------------
	Object
-----------------------------------------------------------------------------*/

// Object initialization is handled here.
function PostBeginPlay()
{
	local mesh TempMesh;

	// Swap meshes so we can play the deactivated animation, then swap back.
	// We set bDontPlayOwnerAnimation so the player doesn't animate (even though there is no player owner at this point).
//	TempMesh = Mesh;
//	Mesh = PlayerViewMesh;
//	bDontPlayOwnerAnimation = true;
//	WpnDeactivated();
//	Mesh = TempMesh;

	// Call the super.
	Super.PostBeginPlay();

	// Set our gameplay stats.
	SetWeaponStay();
	MaxDesireability = 1.2 * AIRating;
	if ( ProjectileClass != None )
		ProjectileSpeed = ProjectileClass.Default.Speed;
	if ( AltProjectileClass != None )
		AltProjectileSpeed = AltProjectileClass.Default.Speed;

	// Adjust view offsets...used to adjust handedness.
	// The only reason this is around is in case we do decide to support handedness.
	AdjustOffsets();

	// Set our initial load count to a full clip.
	AmmoLoaded = ReloadCount;
}

// Clean up when the weapon is destroyed.
simulated function Destroyed()
{
	// If our instigator is using us, set our weapon to none.
	if ( (Instigator != None) && (Instigator.Weapon == Self) )
		Instigator.Weapon = None;

	// Not sure if we should destroy the ammo here or not.
	if ( AmmoType != None )
		AmmoType.Destroy();
	if ( AltAmmoType != None )
		AltAmmoType.Destroy();

	// Call the super.
	Super.Destroyed();
}

// Per-frame object update notification.
simulated event Tick( float Delta )
{
	Super.Tick( Delta );

	// Don't tick if we are in DownWeapon state.
	// FIXME: Probably better to use Disable.
	if ( (Owner == None) || (GetStateName() == 'DownWeapon') )
		return;

	// Check to see if we have an impulse event to process.
	WeaponStateChanges();

	// Heat fall off.  Weapon heat builds up as we fire and dissipates over time.
	if ( HeatRadius > 0.0 )
	{
		HeatRadius -= Delta/2;
		if ( HeatRadius < 0.0 )
			HeatRadius = 0.0;
	}

	// ReloadTimer elapses to give the player a chance to choose a different weapon mode.
	// When the timer is out, the weapon autoloads the currently selected ammo type.
	if ( ReloadTimer > 0.0 )
	{
		ReloadTimer -= Delta;
		if ( ReloadTimer < 0.0 )
		{
			ReloadTimer = 0.0;
			if ( Role < ROLE_Authority )
				ClientReload();
			else
				Reload();
		}
	}
}

// Handles weapon impulse events.
simulated function WeaponStateChanges()
{
    if ( bNetOwner || Role == ROLE_Authority )
        return;

    switch ( WeaponState )
    {
    case WS_FIRE:
        if ( WeaponFireImpulse != LastWeaponFireImpulse )  // Only do effect if the impulse has updated
        {
			ClientSideEffects();
            LastWeaponFireImpulse = WeaponFireImpulse;
        }
        break;
    default:
        break;
    }

    LastWeaponState = WeaponState;
}

// Helper function that returns a string for the current WeaponState.
simulated function string GetWeaponStateString()
{
    switch( WeaponState )
    {
        case WS_NONE:
            return "WS_NONE";
        case WS_DEACTIVATED:
            return "WS_DEACTIVATED";
        case WS_ACTIVATE:
            return "WS_ACTIVATE";
        case WS_IDLE:
            return "WS_IDLE:";
        case WS_IDLE_SMALL:
            return "WS_IDLE_SMALL";
        case WS_IDLE_LARGE:
            return "WS_IDLE_LARGE";
        case WS_FIRE:
            return "WS_FIRE";
        case WS_FIRE_START:
            return "WS_FIRE_START";
        case WS_FIRE_STOP:
            return "WS_FIRE_STOP";
        case WS_ALT_FIRE:
            return "WS_ALT_FIRE";
        case WS_ALT_FIRE_START:
            return "WS_ALT_FIRE_START";
        case WS_ALT_FIRE_STOP:
            return "WS_ALT_FIRE_STOP";
        case WS_RELOAD:
            return "WS_RELOAD";
        case WS_RELOAD_START:
            return "WS_RELOAD_START";
        case WS_RELOAD_STOP:
            return "WS_RELOAD_STOP";
        case WS_FIRE_JAM:
            return "WS_FIRE_JAM";
        case WS_ALT_FIRE_JAM:
            return "WS_ALT_FIRE_JAM";   
        default:
            return "UNKNOWN WS";
    }
}

// Called when the object is assigned to a pawn.
function GiveTo( Pawn Other )
{
	Super.GiveTo( Other );

	bTossedOut = false;
	bHeldItem = true;
	RespawnTime = 0.0;
	Instigator = Other;
	GiveAmmo( Other );
	if ( !Other.bNeverSwitchOnPickup )
		ClientSelectWeapon();
}


/*-----------------------------------------------------------------------------
	Weapon Rendering
-----------------------------------------------------------------------------*/

// Return true if we can draw a crosshair.
simulated function bool CanDrawCrosshair()
{
	return true;
}

// Return true if we can draw SOS function overlays.
simulated function bool CanDrawSOS()
{
	return true;
}

// Allows the weapon to draw something during the post render pass.
// Most weapons use RenderOverlays to do their drawing instead.
// The weapon's post render is called from DukeHUD's post render.
simulated event PostRender( canvas Canvas );

// Adjusts the view offsets (used to be for handedness, but that's no longer supported).
simulated function AdjustOffsets()
{
	// Adapted from the old UT set hand code.
    PlayerViewOffset.Y = Default.PlayerViewOffset.Y * -1;
	PlayerViewOffset.X = Default.PlayerViewOffset.X;
	PlayerViewOffset.Z = Default.PlayerViewOffset.Z;

	// Scale since network passes vector components as ints.
	PlayerViewOffset *= 100;
    PlayerViewOffset.Z += 1200.0;

	// Adjust fireoffset accordingly.
	FireOffset.Y = Default.FireOffset.Y * -1;
}

// Allows the weapon to draw directly to the canvas.
simulated event RenderOverlays( canvas Canvas )
{
	local bool bPlayerOwner;
	local int Hand, i;
	local PlayerPawn PlayerOwner;
	local vector X, Y, Z;

	// If the weapon is hidden, don't render any overlays.
	if ( bHideWeapon || (Owner == None) )
		return;

	// Get a quick ref to the playerpawn so we don't have to cast.
	// Casting and IsA() are generally slow and should be avoided.
	PlayerOwner = PlayerPawn(Owner);
	if ( PlayerOwner == None )
		return;

	// Don't draw the weapon if we have a weird FOV setting.
	if ( PlayerOwner.DesiredFOV != PlayerOwner.DefaultFOV )
		return;
	bPlayerOwner = true;
	Hand = PlayerOwner.Handedness;

	// Hand setting 2 means "hide weapon."
	if (  (Level.NetMode == NM_Client) && (Hand == 2) )
	{
		bHideWeapon = true;
		return;
	}

	// Not sure what this is for.  If (PlayerOwner.Player == None) something weird is going on.
	// This is Unreal Tournament code...
	if ( !bPlayerOwner || (PlayerOwner.Player == None) )
		PlayerOwner.WalkBob = vect(0,0,0);

	// Move the weapon to our draw location and rotation.
	SetLocation( Owner.Location + CalcDrawOffset() );
	SetRotation( PlayerOwner.ViewRotation );

	// Draw first person muzzle flash. (primary)
	if ( UseSpriteFlash && (MuzzleFlashSprite != None) )
	{
		Canvas.DrawColor.R = 255 * MuzzleSpriteAlpha;
		Canvas.DrawColor.G = 255 * MuzzleSpriteAlpha;
		Canvas.DrawColor.B = 255 * MuzzleSpriteAlpha;
		Canvas.Style = ERenderStyle.STY_Translucent;
		Canvas.SetPos(SpriteFlashX*PlayerOwner.MyHUD.HUDScaleX, SpriteFlashY*PlayerOwner.MyHUD.HUDScaleY);
		if ( bMultiFrameFlash )
		{
			if (Level.TimeSeconds - MuzzleFlashTime < MuzzleFlashLength/2)
				Canvas.DrawTile(MuzzleFlashSprites[0], MuzzleFlashSprite.USize * MuzzleFlashScale * PlayerOwner.MyHUD.HUDScaleX, MuzzleFlashSprite.VSize * MuzzleFlashScale * PlayerOwner.MyHUD.HUDScaleY, 0, 0, MuzzleFlashSprite.USize, MuzzleFlashSprite.VSize, MuzzleFlashRotation);
			else if	(Level.TimeSeconds - MuzzleFlashTime < MuzzleFlashLength)
				Canvas.DrawTile(MuzzleFlashSprites[1], MuzzleFlashSprite.USize * MuzzleFlashScale * PlayerOwner.MyHUD.HUDScaleX, MuzzleFlashSprite.VSize * MuzzleFlashScale * PlayerOwner.MyHUD.HUDScaleY, 0, 0, MuzzleFlashSprite.USize, MuzzleFlashSprite.VSize, MuzzleFlashRotation);
		}
		else if (Level.TimeSeconds - MuzzleFlashTime < MuzzleFlashLength)
			Canvas.DrawTile(MuzzleFlashSprite, MuzzleFlashSprite.USize * MuzzleFlashScale * PlayerOwner.MyHUD.HUDScaleX, MuzzleFlashSprite.VSize * MuzzleFlashScale * PlayerOwner.MyHUD.HUDScaleY, 0, 0, MuzzleFlashSprite.USize, MuzzleFlashSprite.VSize, MuzzleFlashRotation);
		Canvas.Style = ERenderStyle.STY_Normal;
	}

	// Draw first person muzzle flash. (alt)
	if ( UseAltSpriteFlash && (AltMuzzleFlashSprite != None) )
	{
		Canvas.DrawColor.R = 255 * AltMuzzleSpriteAlpha;
		Canvas.DrawColor.G = 255 * AltMuzzleSpriteAlpha;
		Canvas.DrawColor.B = 255 * AltMuzzleSpriteAlpha;
		Canvas.Style = ERenderStyle.STY_Translucent;
		Canvas.SetPos(AltSpriteFlashX*PlayerOwner.MyHUD.HUDScaleX, AltSpriteFlashY*PlayerOwner.MyHUD.HUDScaleY);
		if ( bAltMultiFrameFlash )
		{
			if (Level.TimeSeconds - AltMuzzleFlashTime < AltMuzzleFlashLength/2)
				Canvas.DrawTile(AltMuzzleFlashSprites[0], AltMuzzleFlashSprite.USize * AltMuzzleFlashScale * PlayerOwner.MyHUD.HUDScaleX, AltMuzzleFlashSprite.VSize * AltMuzzleFlashScale * PlayerOwner.MyHUD.HUDScaleY, 0, 0, AltMuzzleFlashSprite.USize, AltMuzzleFlashSprite.VSize, AltMuzzleFlashRotation);
			else if	(Level.TimeSeconds - AltMuzzleFlashTime < AltMuzzleFlashLength)
				Canvas.DrawTile(AltMuzzleFlashSprites[1], AltMuzzleFlashSprite.USize * AltMuzzleFlashScale * PlayerOwner.MyHUD.HUDScaleX, AltMuzzleFlashSprite.VSize * AltMuzzleFlashScale * PlayerOwner.MyHUD.HUDScaleY, 0, 0, AltMuzzleFlashSprite.USize, AltMuzzleFlashSprite.VSize, AltMuzzleFlashRotation);
		}
		else if (Level.TimeSeconds - AltMuzzleFlashTime < AltMuzzleFlashLength)
			Canvas.DrawTile(AltMuzzleFlashSprite, AltMuzzleFlashSprite.USize * AltMuzzleFlashScale * PlayerOwner.MyHUD.HUDScaleX, AltMuzzleFlashSprite.VSize * AltMuzzleFlashScale * PlayerOwner.MyHUD.HUDScaleY, 0, 0, AltMuzzleFlashSprite.USize, AltMuzzleFlashSprite.VSize, AltMuzzleFlashRotation, , , true);
		Canvas.Style = ERenderStyle.STY_Normal;
	}

	// Turn clamping off and draw the weapon actor.
	// This is slow, even when there are no polys in the visible weapon.
	// Averages 1.9 ms to execute.  Needs to be optimized, but is probably slow because mesh rendering is slow right now.
	Canvas.SetClampMode( false );
	Canvas.DrawActor( self, false, false );
	Canvas.SetClampMode( true );
}

// A function called by the player whenever he turns his weapon power off.
simulated function SOSPowerOff()
{
	// Weapons can choose to prevent the FOV change.
	PlayerPawn(Owner).DesiredFOV = PlayerPawn(Owner).DefaultFOV;
}

// A function called by the player whenever he changes SOS zoom.
simulated function bool AllowZoom()
{
	// Weapons can choose to disallow the zoom SOS power.
	return true;
}



/*-----------------------------------------------------------------------------
	Traces
-----------------------------------------------------------------------------*/

// Calculates the start and end points for the fire trace, adding optional error values as a mean deviation.
simulated function GetTraceFireSegment( out vector Start, out vector End, out vector BeamStart, optional float HorizError, optional float VertError )
{
	local Pawn PawnOwner;
	local vector X, Y, Z;
	local rotator AdjustedAim;
	local mesh OldMesh;

	PawnOwner = Pawn(Owner);
	GetAxes( PawnOwner.ViewRotation, X, Y, Z );
	Start = Owner.Location + PawnOwner.BaseEyeHeight * vect(0,0,1);
	AdjustedAim = PawnOwner.AdjustAim( 1000000, Start, 2*AimError, false, false );	
	End = Start + HorizError * (FRand() - 0.5) * Y * 3000 + VertError * (FRand() - 0.5) * Z * 3000;
	X = vector(AdjustedAim);
	End += (3000 * X);
	if ( MuzzleAnchor != None )
		BeamStart = MuzzleAnchor.Location;
}

// Generic logic for firing projectiles.  The projectiles themselves implement their functionality.
function Projectile ProjectileFire( class<projectile> ProjClass, float ProjSpeed, bool bWarn, vector inFireOffset )
{
	local Vector Start, X, Y, Z, HitLocation, HitNormal;
	local float BestAim, BestDist;
	local actor BestTarget, HitActor;
	local float Dist;
	local Projectile Proj;
	
	Owner.MakeNoise( Instigator.SoundDampening );
	GetAxes( Instigator.ViewRotation, X, Y, Z );
	Start = Owner.Location + Instigator.BaseEyeHeight * vect(0,0,1) + X*10;
	AdjustedAim = Instigator.AdjustAim(ProjSpeed, Start, AimError, True, bWarn);	
	bestAim = 0.93;
	BestTarget = Pawn(Owner).PickTarget( BestAim, BestDist, vector( Pawn(Owner).Rotation ), Pawn(Owner).Location );
	if (BestTarget != None && (BestTarget.IsA('AlienPig') || BestTarget.IsA('Octabrain')))
	{
		Dist = VSize(BestTarget.Location - Location);
		Pawn(BestTarget).NotifyDodge( Start+vector(AdjustedAim) * Dist );
	}
	Proj = Spawn(ProjClass,,, Start,AdjustedAim);

	return Proj;
}



/*-----------------------------------------------------------------------------
	Inventory / Ammo
-----------------------------------------------------------------------------*/

// Stub for ammo mode cycling handler for multimode weapons.
simulated function CycleAmmoMode( optional bool bFast );

// Gives the player ammo objects associated with this weapon.
function GiveAmmo( Pawn Other )
{
	local int i;

	// For primary ammo.
	if ( AmmoName != None )
	{
		AmmoType = Ammo(Other.FindInventoryType(AmmoName));
		if ( AmmoType != None )
		{
			for ( i=0; i<4; i++ )
				AmmoType.AddAmmo( PickupAmmoCount[i], i );
		}
		else
		{
			AmmoType = Spawn(AmmoName);		// Create ammo type required.
			Other.AddInventory(AmmoType);	// Add it to the player's inventory.
			AmmoType.BecomeItem();
			for ( i=0; i<4; i++ )
				AmmoType.ModeAmount[i] = PickupAmmoCount[i];
			AmmoType.GotoState('Waiting');
		}
	}

	// For secondary ammo.
	if ( AltAmmoName != None )
	{
		AltAmmoType = Ammo(Other.FindInventoryType(AltAmmoName));
		if ( AltAmmoType != None )
		{
			for ( i=0; i<4; i++ )
				AltAmmoType.AddAmmo( AltPickupAmmoCount[i], i );
		}
		else
		{
			AltAmmoType = Spawn(AltAmmoName);
			Other.AddInventory(AltAmmoType);
			AltAmmoType.BecomeItem();
			for ( i=0; i<4; i++ )
				AltAmmoType.ModeAmount[i] = AltPickupAmmoCount[i];
			AltAmmoType.GotoState('Waiting');
		}
	}
}

// A function implemented by all inventory.
// Allows the inventory object a chance to accept or reject a potential pickup item.
// Returns false if we aren't handling the pickup.
function bool HandlePickupQuery( inventory Item )
{
	// Can't pick up nothing!
	if ( Item == None )
		return false;

	// Are we picking up another weapon like this one?
//	if ( Item.Class == Class )
	if ( ClassIsChildOf( Item.Class, Class ) )
		return PickupLikeWeapon( Item );

	// If there's nothing in our inventory after this one, do default behavior.
	if ( Inventory == None )
		return false;

	// Ask the next item to try.
	return Inventory.HandlePickupQuery( Item );
}

// If we are picking up an object of the same class, we pick it up, but just add it's ammo to our own,
// instead of adding it to the inventory list.  This way, a player only has one weapon of a given class in his inventory.
function bool PickupLikeWeapon( Inventory Item )
{
	local int OldAmmo, OldAltAmmo, i;
	local Pawn P;

	// We might not be able to pick the item up in weapon stay.
	if ( Weapon(item).bWeaponStay && (!Weapon(item).bHeldItem || Weapon(item).bTossedOut) )
		return true;

	P = Pawn(Owner);

	// Check primary ammo.
	if ( AmmoType != None )
	{
		// Add the weapon's ammo to our own.
		for ( i=0; i<4; i++ )
			AmmoType.AddAmmo( Weapon(Item).PickupAmmoCount[i], i );

		// Possibly switch to this weapon.
		// If we never switch on pickup, don't.  If we already have this weapon up, don't.
		if ( (P != None) && !P.bNeverSwitchOnPickup && (P.Weapon.class != Item.class) )
			ClientSelectWeapon();
	}

	// Check secondary ammo.
	if ( AltAmmoType != None )
	{
		// Add the weapon's ammo to our own.
		for ( i=0; i<4; i++ )
			AltAmmoType.AddAmmo( Weapon(Item).AltPickupAmmoCount[i], i );

		// Possibly switch to this weapon.
		if ( (P != None) && !P.bNeverSwitchOnPickup && (P.Weapon.class != Item.class) )
			ClientSelectWeapon();
	}

	// Tell the world we grabbed it.
	Item.AnnouncePickup( Pawn(Owner) );

	// We are handling the pickup, instead of the default behavior.
	return true;
}

// Returns true if we can use the ammo type being picked up.
simulated function bool CanPickupAmmo( class<Ammo> AmmoClass )
{
	// Is it our primary ammo?
	if ( (AmmoType != None) && ((AmmoType.class == AmmoClass) || ClassIsChildOf(AmmoClass, AmmoType.class)) )
	{
		// We can't pick it up if we are already at max.
		if ( AmmoType.ModeAmount[AmmoClass.default.AmmoType] == AmmoType.MaxAmmo[AmmoClass.default.AmmoType] )
			return false;

		return true;
	}

	// Is it our secondary ammo?
	if ( (AltAmmoType != None) && ((AltAmmoType.class == AmmoClass) || ClassIsChildOf(AmmoClass, AltAmmoType.class)) )
	{
		// We can't pick it up if we are already at max.
		if ( AltAmmoType.ModeAmount[AmmoClass.default.AmmoType] == AltAmmoType.MaxAmmo[AmmoClass.default.AmmoType] )
			return false;

		return true;
	}

	return false;
}

// A simple helper function that returns true if the weapon is completely out of ammo.
simulated function bool OutOfAmmo()
{
	if ( (AmmoType != None) && bMultiMode )
		return AmmoType.OutOfAmmo();
	else 
	{
		if ( (AmmoType != None) && (AmmoType.GetModeAmmo() <= 0) )
			return true;
		return false;
	}
}

// Called by the engine when the map changes.
// Inventory is copied from one map to the next, this notifies the weapon the copy has completed.
event TravelPostAccept()
{
	Super.TravelPostAccept();

	// A weapon with no owner should not travel!
	if ( Pawn(Owner) == None )
	{
		Log("Error:"@Self@"traveled without a pawn owner.");
		return;
	}

	// Check to make sure we have an associated ammo object.
	GiveAmmo( Pawn(Owner) );

	// If we are the current weapon, bring us up.
	// Otherwise, go to the holding state.
	if ( Self == Pawn(Owner).Weapon )
		BringUp();
	else
		GotoState('Waiting');
}

// Called on all Inventory objects that go from being carried items to pickup items.
function BecomePickup()
{
	// Call the parent.
	Super.BecomePickup();

	// Set our default display properties.
	SetDisplayProperties( Default.Style, Default.Texture, Default.bUnlit, Default.bMeshEnviromap );
}

// Makes the weapon a pickup and throws it out into the world.
// Called from Pawn::TossWeapon.
function DropFrom( vector StartLocation )
{
	local int i;

	// Try to move us to the toss location.
	if ( !SetLocation(StartLocation) )
		return;
	
	AIRating = Default.AIRating;
	if ( Pawn(Owner) != None )
		Velocity = Vector(Pawn(Owner).ViewRotation) * 500 + vect(0,0,220);
	bTossedOut = true;
	bProjTarget = true;

	// Set our pickup ammo state and remove the ammo from owner's inventory.
	if ( AmmoType != None )
	{
		for ( i=0; i<4; i++ )
		{
			PickupAmmoCount[i] = AmmoType.ModeAmount[i];
			AmmoType.ModeAmount[i] = 0;
		}
//		AmmoLoaded = 0;
		if ( Pawn(Owner) != None )
			Pawn(Owner).DeleteInventory( AmmoType );
	}

	// Same with alt ammo.
	if ( AltAmmoType != None )
	{
		for ( i=0; i<4; i++ )
		{
			AltPickupAmmoCount[i] = AltAmmoType.ModeAmount[i];
			AltAmmoType.ModeAmount[i] = 0;
		}
//		AltAmmoLoaded = 0;
		if ( Pawn(Owner) != None )
			Pawn(Owner).DeleteInventory(AltAmmoType);
	}

	// Call parent.
	Super.DropFrom( StartLocation );
}

// A weapon selected via the Q-menu has activate called on it.
simulated function Activate()
{
	// In this case, we just punt to BringUp.
	BringUp();
}

// A weapon might have this general Inventory deactivate function called on it.
simulated function bool Deactivate()
{
	return PutDown();
}

// The main function for making a certain weapon come up.
simulated function BringUp( optional bool bNoSound )
{
	// Set anim sound state.
	if ( Pawn(Owner).bWeaponNoAnimSound )
		bNoSound = true;

	// Set anim sound state.
	if ( bNoSound )
		bNoAnimSound = true;

	// Perform playerpawn specific reset.
	if ( Owner.bIsPlayerPawn )
    {
		if ( PlayerPawn(Owner).CameraStyle != PCS_ZoomMode )
			PlayerPawn(Owner).DesiredFOV = PlayerPawn(Owner).DefaultFOV;		
        AdjustOffsets();
    }
	bWeaponUp = false;
	bChangeWeapon = false;

	// Reset animation settings.
	ActiveWAMIndex = 0;
	LargeIdleTimer = Level.TimeSeconds;

	// Go to the active state.
	GotoState('Active');
}

// The main function for making a weapon go down.
// Sets a flag that is monitored by the various weapon states.
// Switches as soon as the weapon is able.
simulated function bool PutDown() 
{
	bChangeWeapon = true;
	return true;
}

// Checks to see if the level allows weapon stay and sets it for this weapon.
function SetWeaponStay()
{
	bWeaponStay = bWeaponStay || Level.Game.bCoopWeaponMode;
}

// Either give this inventory to player Other, or spawn a copy
// and give it to the player Other, setting up original to be respawned.
function Inventory SpawnCopy( pawn Other )
{
	local Inventory ParentCopy;

	ParentCopy = Super.SpawnCopy( Other );

	if ( ParentCopy == None )
		return ParentCopy;

	if ( !bWeaponStay )
		GotoState('Sleeping');

	return ParentCopy;
}

// Gives us a change to modify the copy before GiveTo.
function ModifyCopy( Inventory Copy, pawn Other )
{
	local int i;

	for ( i=0; i<4; i++ )
		Weapon(Copy).PickupAmmoCount[i] = PickupAmmoCount[i];
	Weapon(Copy).AmmoLoaded = AmmoLoaded;
}

/*
function SetSwitchPriority(pawn Other)
{
	local int i;
	local name temp, carried;

	if ( PlayerPawn(Other) != None )
	{
		for ( i=0; i<20; i++)
			if ( PlayerPawn(Other).WeaponPriority[i] == class.name )
			{
				AutoSwitchPriority = i;
				return;
			}
		// else, register this weapon
		carried = class.name;
		for ( i=AutoSwitchPriority; i<20; i++ )
		{
			if ( PlayerPawn(Other).WeaponPriority[i] == '' )
			{
				PlayerPawn(Other).WeaponPriority[i] = carried;
				return;
			}
			else if ( i<19 )
			{
				temp = PlayerPawn(Other).WeaponPriority[i];
				PlayerPawn(Other).WeaponPriority[i] = carried;
				carried = temp;
			}
		}
	}		
}
*/

// This function performs several behaviors.
// First, it is called on the client or in single player games.
// It evaluates whether or we should switch and, if we can, it switches to this weapon.
simulated function ClientSelectWeapon()
{
	// Set our instigator reference.
	// We do this to make sure it is valid on the client.
	Instigator = Pawn(Owner);
	if ( (Instigator == None) || (AmmoType == None) )
	{
		// Uh oh.  Owner or AmmoType hasn't been replicated from the server yet.
		// Waiting for it is all we can do.  Weapons can't be used without a proper owner or ammotype reference.
		GotoState('WaitingForReplication');
		return;
	}
	else if ( IsInState('WaitingForReplication') )
	{
		// Our references has arrived.  Return to the waiting state.
		GotoState('Waiting');
	}

	// We can't select a weapon if we already have it up.
	if ( Instigator.Weapon == Self )
		return;

	// We can't select a weapon if our shield is up.
	if ( Instigator.ShieldProtection )
		return;

	// We can't select a weapon if it is out of ammo.
	if ( OutOfAmmo() )
		return;

	// If we have a weapon, only switch if it's better.
	if ( (Instigator.Weapon != None) && (Instigator.Weapon.SwitchPriority() > SwitchPriority()) )
		return;

	// Switch!
	Instigator.ChangeToWeapon( Self );
}

// Returns the switch priority of this weapon.
simulated function float SwitchPriority() 
{
	if ( OutOfAmmo() )
		return -1;
	else
		return AutoSwitchPriority;
}



/*-----------------------------------------------------------------------------
	Reloading
-----------------------------------------------------------------------------*/

// Returns true if we have ammo for the current mode, don't have to reload, 
// and aren't completely out of ammo.
simulated function bool CanFire()
{
	return ( HaveModeAmmo() && !GottaReload() && !OutOfAmmo() );
}

// Returns true if we have ammo for the currently selected mode.
simulated function bool HaveModeAmmo()
{
	if ( AmmoType == None )
		return false;

	return (AmmoType.GetModeAmmo() > 0);
}

// Returns true if we have to reload the weapon.
simulated function bool GottaReload()
{
	// Never have to reload if we don't use ammo.
	if ( AmmoType == None )
		return true;

	// Never have to reload if we don't use ammo.
	if ( AmmoName == None )
		return true;

	// Reload if we are out of ammo load.
	if ( (ReloadCount > 0) && (AmmoType.GetModeAmmo() > 0) && (AmmoLoaded <= 0) )
		return true;

	// Otherwise, don't reload.
    return false;
}

// Replicated to the client, this function performs client side reloading logic.
simulated function ClientReload()
{
	if ( (ReloadCount <= 0) || (AmmoLoaded >= ReloadCount) )
		return;
	if ( (AmmoType.GetModeAmmo() <= ReloadCount+1) && (AmmoLoaded == AmmoType.GetModeAmmo()) )
		return;

	ReloadTimer = 0.0;
	TempLoadCount = AmmoLoaded;
	GotoState('Reloading');
}

// Reloading performed on the server or in single player.
function Reload()
{
	if ( (ReloadCount <= 0) || (AmmoLoaded >= ReloadCount) )
		return;
	if ( (AmmoType.GetModeAmmo() <= ReloadCount+1) && (AmmoLoaded == AmmoType.GetModeAmmo()) )
		return;
	if ( !Pawn(Owner).IsLocallyControlled() )
	{
		GotoState('Idle');
		return;
	}

	ReloadTimer = 0.0;
	TempLoadCount = AmmoLoaded;
	GotoState('Reloading');
}




/*-----------------------------------------------------------------------------
	Firing and Input
-----------------------------------------------------------------------------*/

// Checks the player's area to see if we should ignite an actor.
function CheckForAreaIgnition( bool bWeaponIgnites )
{
	local RenderActor A;

	if ( bWeaponIgnites && (Pawn(Owner).ExplosiveArea > 0) )
	{
		foreach Owner.TouchingActors( class'RenderActor', A )
		{
			if ( A.bIgnitable )
				A.Ignite( Pawn(Owner) );
		}
	}
}

// Used in the firing state instead of BeginState.
// Allows for BeginState like functionality without exiting the state.
simulated function StartFiring();

// Check to see if the client can fire.
// If it returns true, a fire message will be sent to the server.
simulated function bool ClientFire()
{
	// If we are in multimode and switching modes, force the reload.
	if ( bMultiMode && (ReloadTimer > 0.0) && Pawn(Owner).IsLocallyControlled() )
	{
		if (Role < ROLE_Authority)
			ClientReload();
		else if( PlayerPawn( Owner ) != None )
			Reload();
		return false;
	}

	// If we have to reload, then reload.
	// This happens when we are out of loaded ammo (in a non multimode weapon) and then pick some up.
	if ( GottaReload() )
	{
		if ( Owner.bIsPlayerPawn )
			PlayerPawn(Owner).Reload();
		return false;
	}
	
	// Otherwise, fire if we aren't out of ammo and the server allows us...
	if ( (Role == ROLE_Authority) || (AmmoType == None) || !OutOfAmmo() )
	{
		// Perform screen effects.
		if ( !bNoShake && PlayerPawn(Owner) != None )
			PlayerPawn(Owner).WeaponShake();

		// Go to the client side firing state.
		if ( Role < ROLE_Authority )
		{
			bAltFiring = false;
			GotoState('Firing');
			StartFiring();
		}

		return true;
	}
	return false;
}

// Perform firing.
function Fire()
{
	// Force reload if we are waiting for it.
	if ( bMultiMode && (ReloadTimer > 0.0) && PlayerPawn( Owner ) != None )
	{
		Reload();
		return;
	}

    if ( (AmmoName == None) || (AmmoType.UseAmmo(1)) )
    {
		// Do firing animation & firing state.
		bAltFiring = false;
		GotoState('Firing');
		StartFiring();
		ClientFire();

		// Reduce the loaded ammo count.
		AmmoLoaded--;

		// Perform hit logic.
        if ( bInstantHit )
		{
			Owner.MakeNoise( Pawn(Owner).SoundDampening );
            if( !bOwnerFire )
				TraceFire( Owner, 0.0, 0.0, !bWeaponPenetrates );
			else
				Owner.TraceFire( Owner, 0.0, 0.0, !bWeaponPenetrates );
		}
		else
		{
			if ( bShrunkProjectile && (ThirdPersonScale < 0.5) && (ShrunkProjectileClass != None) )
	            ProjectileFire( ShrunkProjectileClass, ProjectileSpeed, false, FireOffset );
			else if ( ProjectileClass != None )
	            ProjectileFire( ProjectileClass, ProjectileSpeed, false, FireOffset );
		}

		// Check to see if we ignited the area.
		CheckForAreaIgnition( bFireIgnites );
    }
}

// Called when the player lets up on the fire button.
function UnFire();

// Client side unfiring.
simulated function ClientUnFire();
simulated function ClientUnAltFire();

// Checks to see if we can alt fire.
simulated function bool ClientAltFire()
{
	if ( (Role == ROLE_Authority) || (AmmoType == None) || !OutOfAmmo() )
	{
		// Perform screen effects.
		if ( !bMultiMode )
			PlayerPawn(Owner).WeaponShake();

		// If we are in multimode and are a true player, switch modes.
		if ( bMultiMode && Pawn(Owner).IsLocallyControlled() )
		{
			bCanChangeMode = false;
			CycleAmmoMode();
			return false;
		}

		// Go to the client side firing state.
		if ( Role < ROLE_Authority )
		{
			bAltFiring = true;
			GotoState('Firing');
			StartFiring();
		}

		return true;
	}
	return false;
}

// Alternative firing mode.
function AltFire()
{
	local int OldAmmoMode;

	// If we are in multimode, just switch ammo types.
	if ( bMultiMode )
	{
		if ( bCanChangeMode )
			ClientAltFire();
		return;
	}

    if ( (AltAmmoName == None) || (AltAmmoType.UseAmmo(1)) )
    {
		bAltFiring = true;
		GotoState('Firing');
		StartFiring();
		ClientAltFire();

		// Reduce the loaded ammo count.
		AltAmmoLoaded--;

		// Perform hit logic.
        if ( bAltInstantHit )
		{
			Owner.MakeNoise( Pawn(Owner).SoundDampening );
            TraceFire( Owner );
		}
		else
		{
			if ( bShrunkAltProjectile && (ThirdPersonScale < 0.5) && (ShrunkAltProjectileClass != None) )
	            ProjectileFire( ShrunkAltProjectileClass, AltProjectileSpeed, false, AltFireOffset );
			else if ( AltProjectileClass != None )
	            ProjectileFire( AltProjectileClass, AltProjectileSpeed, false, AltFireOffset );
		}

		// Check to see if we ignited the area.
		CheckForAreaIgnition( bAltFireIgnites );
    }
}

// Called when the player lets up on the altfire button.
function UnAltFire()
{
	bCanChangeMode = true;
}

// Helper functions that check and see if it's okay to fire.
simulated function bool ButtonFire()
{
	if ( (Pawn(Owner).Weapon == Self) && (Pawn(Owner).bFire != 0) )
		return true;
	else
		return false;
}

simulated function bool ButtonAltFire()
{
	if ( (Pawn(Owner).Weapon == Self) && (Pawn(Owner).bAltFire != 0) )
		return true;
	else
		return false;
}

// Stupid code from Hargrove.
function HandlePlayerInput( float DeltaTime )
{
	local PlayerPawn p;

	p = PlayerPawn(Owner);
	if (p == None)
		return;
	// CDH FIXME: this method of determining player action is lame, put some other hook in
	//            the system when a better input choke point is determined (if there is one)
	if (p.bEdgeForward || p.bEdgeBack || p.bEdgeLeft || p.bEdgeRight
	 || p.bWasForward || p.bWasBack || p.bWasLeft || p.bWasRight
	 || (p.aStrafe != 0) || (p.aTurn != 0) || (p.aForward != 0) || (p.aLookUp != 0)
	 || (p.bFire != 0) || (p.bAltFire != 0) )
	{
		LargeIdleTimer = Level.TimeSeconds;
	}
}

// Facilitates functions replicated from client to server with special codes.
function WeaponAction( int ActionCode, rotator ClientViewRotation );


/*-----------------------------------------------------------------------------
	Animation System.
-----------------------------------------------------------------------------*/

// Copys one entry to another.
simulated function CopyWAMEntry( WAMEntry FromEntry, WAMEntry ToEntry )
{
	ToEntry.AnimChance		= FromEntry.AnimChance;
	ToEntry.AnimSeq			= FromEntry.AnimSeq;
	ToEntry.AnimRate		= FromEntry.AnimRate;
	ToEntry.AnimTween		= FromEntry.AnimTween;
	ToEntry.AnimChan		= FromEntry.AnimChan;
	ToEntry.AnimLoop		= FromEntry.AnimLoop;
	ToEntry.AnimSound		= FromEntry.AnimSound;
	ToEntry.AnimSound2		= FromEntry.AnimSound2;
	ToEntry.AlternateSound	= FromEntry.AlternateSound;
	ToEntry.DebugString		= FromEntry.DebugString;
	ToEntry.PlayNone		= FromEntry.PlayNone;
}

// Plays the 3rd person animation for this weapon.
function bool PlayOwnerAnim( WAMEntry PlayAnim, Pawn Other )
{
	if ( Other == None )
		return false;

	// Force a play of None.
	if ( PlayAnim.PlayNone )
	{
		switch ( PlayAnim.AnimChan )
		{
			case WAC_All:
				Other.PlayAllAnim( 'None' );
				break;
			case WAC_Top:
				Other.PlayTopAnim( 'None' );
				break;
			case WAC_Bottom:
				Other.PlayBottomAnim( 'None' );
				break;
			case WAC_Special:
				Other.PlaySpecialAnim( 'None' );
				break;
			default:
				break;
		}
		return true;
	}

	if ( PlayAnim.AnimSeq == '' )
	{
		// Noisy debug message.
//		Log( self@"Weapon::PlayOwnerAnim: Animation "$PlayAnim.DebugString$" has no AnimSeq set" );
		return false;
	}


	switch ( PlayAnim.AnimChan )
	{
		case WAC_All:
			Other.PlayAllAnim( PlayAnim.AnimSeq, PlayAnim.AnimRate, PlayAnim.AnimTween, PlayAnim.AnimLoop );
			break;
		case WAC_Top:
			Other.PlayTopAnim( PlayAnim.AnimSeq, PlayAnim.AnimRate, PlayAnim.AnimTween, PlayAnim.AnimLoop );
			break;
		case WAC_Bottom:
			Other.PlayBottomAnim( PlayAnim.AnimSeq, PlayAnim.AnimRate, PlayAnim.AnimTween, PlayAnim.AnimLoop );
			break;
		case WAC_Special:
			Other.PlaySpecialAnim( PlayAnim.AnimSeq, PlayAnim.AnimRate, PlayAnim.AnimTween, PlayAnim.AnimLoop );
			break;
		default:
			break;
	}
}

// Returns the 3rd person fire anim for this weapon.
simulated function WAMEntry GetFireAnim()
{
	return FireAnim;
}

// Returns the 3rd person crouch fire anim for this weapon.
simulated function WAMEntry GetCrouchFireAnim()
{
	return CrouchFireAnim;
}

// Returns a random WAM entry associated with a WAM array.
// WAM is just a collection of animation data for easy use.
simulated function int GetRandomWAMEntry( WAMEntry inMap[4], out WAMEntry outEntry )
{
    local int i;
	local float f, chance, chanceBase;

	f = FRand();
	chanceBase = 0.0;
	for ( i=0; i<3; i++ )
	{
		chance = inMap[i].AnimChance;
		if ( (chance > 0.0) && (f >= chanceBase) && (f < (chanceBase+chance)) )
			break;
		chanceBase += chance;
	}
	outEntry = inMap[i];
	return i;
}

// Plays a given WAM entry.  Used in conjunction with GetRandomWAMEntry to facilitate animation.	
simulated function PlayWAMEntry(out WAMEntry inEntry, bool inWaitForFinish, name inTweenFrom, optional float inRateFactor)
{
//	if ( inEntry == None )
//		return;

	if ( !bNoAnimSound && (inEntry.AnimSound != None) )
	{
		if ( inEntry.AlternateSound )
		{
			if ( LastSoundSlot != SLOT_Misc )
			{
				Owner.PlayOwnedSound( inEntry.AnimSound, SLOT_Misc, Pawn(Owner).SoundDampening*0.4 );
				LastSoundSlot = SLOT_Misc;
			}
			else 
			{
				Owner.PlayOwnedSound( inEntry.AnimSound, SLOT_Interface, Pawn(Owner).SoundDampening*0.4 );
				LastSoundSlot = SLOT_Interface;
			}
		} else
			Owner.PlayOwnedSound( inEntry.AnimSound, SLOT_Misc, Pawn(Owner).SoundDampening*0.4 );
	}
	if ( !bNoAnimSound && (inEntry.AnimSound2 != None) )
		Owner.PlayOwnedSound( inEntry.AnimSound2, SLOT_Interface, Pawn(Owner).SoundDampening*0.4 );

    if ( (inTweenFrom != 'None') && (AnimSequence != 'None') && (GetAnimGroup(AnimSequence) == inTweenFrom) )
	{
        TweenAnim( AnimSequence, AnimFrame*0.4 );
	}
	else if ( inEntry.AnimSeq != 'None' )
	{		
		if ( inRateFactor != 0.0 )
			PlayAnim( inEntry.AnimSeq, inEntry.AnimRate*inRateFactor, inEntry.AnimTween );
		else
			PlayAnim( inEntry.AnimSeq, inEntry.AnimRate, inEntry.AnimTween );
		if ( inWaitForFinish )
			FinishAnim();
	}
}

// Play the activate animation.
// If bFastActivate is set, the anim will play really fast.
// Fast activation is used when the weapon comes up after the riot shield is put down.
simulated function WpnActivate()
{
	local WAMEntry entry;

	ActiveWAMIndex = GetRandomWAMEntry( SAnimActivate, entry );
	if ( bFastActivate )
		entry.AnimRate *= 10;
	bFastActivate = false;
	bHideWeapon = false;
	PlayWAMEntry( entry, true, 'None' );
	ThirdPersonScale = 1.0;

    if ( !bDontPlayOwnerAnimation )
        Pawn(Owner).WpnPlayActivate();

    WeaponState = WS_ACTIVATE;
    bDontPlayOwnerAnimation = false;
}

// Play the deactivate animation.
// FIXME: This also removes the HUD interface.  Probably shouldn't put gameplay logic in anim funcs.
simulated function WpnDeactivated()
{
	local WAMEntry entry;
	ActiveWAMIndex = GetRandomWAMEntry( SAnimDeactivate, entry );
	PlayWAMEntry( entry, true, 'Activate' );
	
    if ( Pawn(Owner) != None )
	{
		if ( !bDontPlayOwnerAnimation )
			Pawn(Owner).WpnPlayDeactivated();
	}
    
    WeaponState = WS_DEACTIVATED;
    bDontPlayOwnerAnimation = false;
}

// Play the start part of a fire animation.
// Many fire animations consist of some combination of a start, main, and stop.
simulated function WpnFireStart( optional bool noWait )
{
	local WAMEntry entry;
	ActiveWAMIndex = GetRandomWAMEntry( SAnimFireStart, entry );
	PlayWAMEntry( entry, !noWait, 'None' );
	
    if ( !bDontPlayOwnerAnimation )
        Pawn(Owner).WpnPlayFireStart();

    WeaponState = WS_FIRE_START;
    bDontPlayOwnerAnimation = false;
}

// Play the main part of the fire animation.
// This part could be a looping part.
// Also performs client side effects.
simulated function WpnFire( optional bool noWait )
{
	local WAMEntry entry;
	ActiveWAMIndex = GetRandomWAMEntry( SAnimFire, entry );
	PlayWAMEntry( entry, !noWait, 'None' );

    if ( !bDontPlayOwnerAnimation )
        Pawn(Owner).WpnPlayFire();

    WeaponState = WS_FIRE;

	// Increment the fire Impulse so the clients know that this weapon has fired
    WeaponFireImpulse++;

	// Do client side effects that are animation driven.
	ClientSideEffects();

    bDontPlayOwnerAnimation = false;
}

// Play the stop part of the fire animation.
simulated function WpnFireStop( optional bool noWait )
{
	local WAMEntry entry;
	ActiveWAMIndex = GetRandomWAMEntry( SAnimFireStop, entry );
	PlayWAMEntry( entry, !noWait, 'None' );
	
    if ( !bDontPlayOwnerAnimation )
        Pawn(Owner).WpnPlayFireStop();

    WeaponState = WS_FIRE_STOP;
    bDontPlayOwnerAnimation = false;
}

// Play the start part of the alt fire animation.
simulated function WpnAltFireStart()
{
	local WAMEntry entry;
	ActiveWAMIndex = GetRandomWAMEntry( SAnimAltFireStart, entry );
	PlayWAMEntry( entry, true, 'None' );
    
    if ( !bDontPlayOwnerAnimation )
    	Pawn(Owner).WpnPlayAltFireStart();
    
    WeaponState = WS_ALT_FIRE_START;
    bDontPlayOwnerAnimation = false;
}

// Play the main part of the fire animation.
// This part could be a looping part.
// FIXME: Hey Scott, shouldn't there be fire impulse logic here?
simulated function WpnAltFire()
{
	local WAMEntry entry;
	ActiveWAMIndex = GetRandomWAMEntry( SAnimAltFire, entry );
	PlayWAMEntry( entry, true, 'None' );
	
    if ( !bDontPlayOwnerAnimation )
        Pawn(Owner).WpnPlayAltFire();

    WeaponState = WS_ALT_FIRE;
    bDontPlayOwnerAnimation = false;
	ClientSideEffects( true );
}

// Play the stop part of the fire animation.
simulated function WpnAltFireStop()
{
	local WAMEntry entry;
	ActiveWAMIndex = GetRandomWAMEntry( SAnimAltFireStop, entry );
	PlayWAMEntry( entry, true, 'None' );

	if ( !bDontPlayOwnerAnimation )
        Pawn(Owner).WpnPlayAltFireStop();

    WeaponState = WS_ALT_FIRE_STOP;
    bDontPlayOwnerAnimation = false;
}

// Play the start part of the reload animation.
simulated function WpnReloadStart()
{
	local WAMEntry entry;
	ActiveWAMIndex = GetRandomWAMEntry( SAnimReloadStart, entry );
	PlayWAMEntry( entry, true, 'None' );
	
    if ( !bDontPlayOwnerAnimation )
        Pawn(Owner).WpnPlayReloadStart();

    WeaponState = WS_RELOAD_START;
    bDontPlayOwnerAnimation = false;
}

// Play the main part of the reload animation.
// This part could be a looping part.
simulated function WpnReload( optional bool noWait )
{
	local WAMEntry entry;
	ActiveWAMIndex = GetRandomWAMEntry( SAnimReload, entry );
	PlayWAMEntry( entry, !noWait, 'None' );

    if ( !bDontPlayOwnerAnimation )
	    Pawn(Owner).WpnPlayReload();

    WeaponState = WS_RELOAD;
    bDontPlayOwnerAnimation = false;
}

// Play the stopping part of the reload animation.
simulated function WpnReloadStop()
{
	local WAMEntry entry;
	ActiveWAMIndex = GetRandomWAMEntry( SAnimReloadStop, entry );
	PlayWAMEntry( entry, true, 'None' );

    if ( !bDontPlayOwnerAnimation )
        Pawn(Owner).WpnPlayReloadStop();

    WeaponState = WS_RELOAD_STOP;
    bDontPlayOwnerAnimation = false;
}

// Play a short idle.  These are the common idles.
// Called by WpnIdle.
simulated function WpnIdleSmall()
{
	local WAMEntry entry;
	ActiveWAMIndex = GetRandomWAMEntry( SAnimIdleSmall, entry );
    PlayWAMEntry( entry, false, 'None' );
    WeaponState = WS_IDLE_SMALL;
}

// Play a long idle.  These are played only rarely.
// Called by WpnIdle.
simulated function WpnIdleLarge()
{
	local WAMEntry entry;
	ActiveWAMIndex = GetRandomWAMEntry( SAnimIdleLarge, entry );
	PlayWAMEntry( entry, false, 'None' );
    WeaponState = WS_IDLE_LARGE;
}

// Plays an idle animation.
simulated function WpnIdle()
{
	// 20-30 seconds between large idles.
	if ( Level.TimeSeconds > (LargeIdleTimer + (20.0+FRand()*10.0)) )
	{
		WpnIdleLarge();
		LargeIdleTimer = Level.TimeSeconds;
	}
	else
	{
		WpnIdleSmall();
	}
}

// There are animation driven client side effects.
simulated function ClientSideEffects( optional bool bAltFire )
{
	local texture NewFlashSprite;
	local float RandRot;
	local int RandRoll;
	local BeamSystem bs;

	MountMuzzleAnchor();

	// Apply some heat.
    HeatRadius += 0.5;
	if (HeatRadius > 8)
		HeatRadius = 8;

	// Drop a shell if we need to.
//	if (bDropShell)
//		DropShell();

	// 1st person muzzle flash. (primary)
	if ( UseSpriteFlash && !bAltFire )
	{
		NewFlashSprite = MuzzleFlashSprites[Rand(NumFlashSprites)];
		MuzzleFlashSprite = NewFlashSprite;
		MuzzleFlashTime = Level.TimeSeconds;
		if ( bMuzzleFlashRotates )
			MuzzleFlashRotation = FRand() * 3.14;
		else
			MuzzleFlashRotation = 0.0;
	}

	// 1st person muzzle flash. (alt)
	if ( UseAltSpriteFlash && bAltFire )
	{
		NewFlashSprite = AltMuzzleFlashSprites[Rand(AltNumFlashSprites)];
		AltMuzzleFlashSprite = NewFlashSprite;
		AltMuzzleFlashTime = Level.TimeSeconds;
		if ( bAltMuzzleFlashRotates )
			AltMuzzleFlashRotation = FRand() * 3.14;
		else
			AltMuzzleFlashRotation = 0.0;
	}

	// 3rd person muzzle flash.
	if ( MuzzleFlashClass != None )
	{
		MuzzleFlash3rd = Spawn( MuzzleFlashClass,,,MuzzleAnchor.Location, MuzzleAnchor.Rotation );
		MuzzleFlash3rd.bOwnerSeeSpecial = true;
		MuzzleFlash3rd.SetOwner( Owner );
		MuzzleFlash3rd.SetPhysics( PHYS_MovingBrush );
		MuzzleFlash3rd.DrawScale = ThirdPersonScale;

		RandRot = FRand();
		if ( RandRot < 0.3 )
			RandRoll = 16384;
		else if ( RandRot < 0.6 )
			RandRoll = 32768;
		else
			RandRoll = 0;
		MuzzleFlash3rd.SetRotation( rot(MuzzleFlash3rd.Rotation.Pitch, MuzzleFlash3rd.Rotation.Yaw, MuzzleFlash3rd.Rotation.Roll+RandRoll) );
	}
}

simulated function MountMuzzleAnchor()
{
	if ( (MuzzleAnchor == None) && bUseMuzzleAnchor )
	{
		MuzzleAnchor = spawn(class'BeamAnchor');
		MuzzleAnchor.RemoteRole = ROLE_None;
		MuzzleAnchor.SetPhysics( PHYS_MovingBrush );
		MuzzleAnchor.MountMeshItem = 'MuzzleMount';
		MuzzleAnchor.AttachActorToParent( Self, true, true );
		MuzzleAnchor.MountType = MOUNT_MeshSurface;
	}
}



/*-----------------------------------------------------------------------------
	AI
-----------------------------------------------------------------------------*/
/*
event float BotDesireability(Pawn Bot)
{
	local Weapon AlreadyHas;
	local float desire;

	desire = MaxDesireability;
    if ( Bot.IsA('BotPawn') )
        desire += BotPawn(Bot).AdjustDesireFor(self);
	AlreadyHas = Weapon(Bot.FindInventoryType(class));
*/	
	/*
	if ( AlreadyHas != None )
	{
		if ( (RespawnTime < 10) 
			&& ( bHidden || (AlreadyHas.AmmoType == None) 
				|| (AlreadyHas.AmmoType.AmmoAmount < AlreadyHas.AmmoType.MaxAmmo)) )
			return 0;
		if ( (!bHeldItem || bTossedOut) && bWeaponStay )
			return 0;
		if ( AlreadyHas.AmmoType == None )
			return 0.25 * desire;

		if ( AlreadyHas.AmmoType.AmmoAmount > 0 )
			return FMax( 0.25 * desire, 
					AlreadyHas.AmmoType.MaxDesireability
					 * FMin(1, 0.15 * AlreadyHas.AmmoType.MaxAmmo/AlreadyHas.AmmoType.AmmoAmount) ); 
		else
			return 0.05;
	}
	*/
/*
	if ( (Bot.Weapon == None) || (Bot.Weapon.AIRating <= 0.4) )
		return 2*desire;

	return desire;
}
*/

// Used by the AI to pick a weapon depending on the situation.
function float RateSelf( out int bUseAltMode )
{
	if ( (AmmoType != None) && AmmoType.OutOfAmmo() )
		return -2;
	bUseAltMode = int(FRand() < 0.4);
	return (AIRating + FRand() * 0.05);
}

// Used by the AI.
function float SuggestAttackStyle()
{
	return 0.0;
}

// Used by the AI.
function float SuggestDefenseStyle()
{
	return 0.0;
}

// Compres self to next weapon.  Returns better of the two.
simulated function Weapon RecommendWeapon( out float Rating, out int bUseAltMode )
{
	local Weapon Recommended;
	local float oldRating, oldFiring;
	local int oldMode;

	if ( Owner.bIsPlayerPawn )
		Rating = SwitchPriority();
	else
	{
		Rating = RateSelf(bUseAltMode);
		if ( (self == Pawn(Owner).Weapon) && (Pawn(Owner).Enemy != None) 
			&& !OutOfAmmo() )
			rating += 0.21; // tend to stick with same weapon
	}
	if ( Inventory != None )
	{
		Recommended = Inventory.RecommendWeapon( oldRating, oldMode );
		if ( (Recommended != None) && (oldRating > Rating) )
		{
			Rating = oldRating;
			bUseAltMode = oldMode;
			return Recommended;
		}
	}
	return Self;
}
/*
function CheckVisibility()
{
	if( Owner.bHidden && (Instigator.Health > 0) && (Instigator.Visibility < Instigator.Default.Visibility) )
	{
		Owner.bHidden = false;
		Instigator.Visibility = Instigator.Default.Visibility;
	}
}
*/



/*-----------------------------------------------------------------------------
	States.
-----------------------------------------------------------------------------*/

// This state is used to bring the weapon up.
// ASSUMPTION: The weapon has an activate animation.
state Active
{
	function Fire()
	{
		// If a remote client sends a fire message, then break out and fire.
		if ( !Instigator.IsLocallyControlled() )
		{
			// Tag us as being up.
			bWeaponUp = true;

			Global.Fire();
		}
	}

	function AltFire()
	{
		// If a remote client sends an altfire message, then break out and altfire.
		if ( !Instigator.IsLocallyControlled() )
		{
			// Tag us as being up.
			bWeaponUp = true;

			Global.AltFire();
		}
	}

	simulated function bool ClientFire()
	{
		// Can't interrupt bringup.
		return false;
	}

	simulated function bool ClientAltFire()
	{
		// Can't interrupt bringup.
		return false;
	}

	// The main function for making a weapon go down.
	simulated function bool PutDown()
	{
		// Change when the animation is done.
		bChangeWeapon = true;

		return true;
	}

	// Called when the state is entered.
	// We reset any variables that need reset, install the hud, and play the activate anim.
	simulated function BeginState()
	{
		// Set our instigator.
		Instigator = Pawn(Owner);

		// Reset relevant variables.
		bWeaponUp = false;
		bChangeWeapon = false;
		bCantSendFire = false;
		bDontAllowFire = false;
		Instigator.LastWeaponClass = Class;

		// Play the activate animation.
		WpnActivate();
		bDontPlayOwnerAnimation = false;
		bFastActivate = false;

		// Mount the muzzle anchor.
		MountMuzzleAnchor();
	}

	// Called when the state is exited.
	simulated function EndState()
	{
	}

	// Played when an animation ends.
	// In this case, it is played when the activate animation ends.
	simulated function AnimEnd()
	{
		// If we have to change our weapon, do it.
		if ( bChangeWeapon )
		{
			GotoState('DownWeapon');
			return;
		}

		// Reset anim sound.
		if ( Pawn(Owner) != None && !Pawn(Owner).bWeaponNoAnimSound )
			bNoAnimSound = false;

		// Tag us as being up.
		bWeaponUp = true;

		// Go to the idle state.
		GotoState('Idle');
	}
}

// This state puts the weapon into its holstered position.
state DownWeapon
{
	ignores Fire, AltFire; // Cannot fire when downing a weapon.

	// The main function for making a weapon go down.
	// We are alrady going down, so just keep putting it down.
	simulated function bool PutDown()
	{
		return true;
	}

	// Called at the end of an animation.
	simulated function AnimEnd()
	{
		// In this case, we change weapons when done animating.
		if ( !bClientDown && (Instigator.Weapon == Self) )
			Instigator.FinishWeaponChange();
		bClientDown = false;

		// Remove the muzzle anchor.
		if ( MuzzleAnchor != None )
		{
			MuzzleAnchor.Destroy();
			MuzzleAnchor = None;
		}

		// Go to the waiting state.
		GotoState('Waiting');
	}

	// When we enter the state, animate to down and reset any relevant variables.
	simulated function BeginState()
	{
	    WpnDeactivated();
		bOnlyOwnerSee = false;
		bChangeWeapon = false;
	}

	// Can't fire when down.
	simulated function bool ClientFire()
	{
		return false;
	}

	// Can't fire when down.
	simulated function bool ClientAltFire()
	{
		return false;
	}
}

// This state is entered when the weapon is in a light idling state.
state Idle
{
	// Per-frame object update notification.
	simulated event Tick( float Delta )
	{
		// Monitor button presses and start shooting if the key is held down.
		if ( CanFire() && Owner.bIsPlayerPawn )
		{
			if ( ButtonFire() )
			{
				Fire();
				return;
			}
			else if ( ButtonAltFire() )
			{
				AltFire();
				return;
			}
		}

		Global.Tick( Delta );
	}

	// The main function for making a weapon go down.
	simulated function bool PutDown()
	{
		// Go to the down state right away.
		GotoState('DownWeapon');
		return true;
	}

	// Called when the current animation ends.
	simulated function AnimEnd()
	{
		// Play an idle animation.
		WpnIdle();
	}

	// Called when the state is entered.
	simulated function BeginState()
	{
		if ( bChangeWeapon )
		{
			// If we have to change weapons, do it!
			PutDown();
			return;
		}

		// Check to see if we should do something special.
		if ( Instigator.IsLocallyControlled() )
		{
			if ( OutOfAmmo() )
			{
				// If we are out of ammo, switch to another weapon.
				Pawn(Owner).SwitchToBestWeapon();
				return;
			}
			else if ( GottaReload() )
			{
				// If we have to reload, then reload.
				if ( Owner.bIsPlayerPawn )
				{
					PlayerPawn(Owner).Reload();
					return;
				}
			}
			else if ( bMultiMode && !HaveModeAmmo() )
			{
				// If we are out of ammo, switch to the next mode.
				CycleAmmoMode( true );
				return;
			}
			else if ( CanFire() )
			{
				// If we can fire and the key is down, do it.
				// This is so that the weapon will fire if the player is holding the key down when this state is entered.
				if ( ButtonFire() )
				{
					Global.ClientFire();
					return;
				}
				else if ( ButtonAltFire() )
				{
					Global.ClientAltFire();
					return;
				}
				else if ( PlayerPawn(Owner) == None )
				{
					// AI stop firing.
					Pawn(Owner).StopFiring();
				}
			}
		}

		// Start an idle animation loop.
		WpnIdle();
	}
}

// This is the firing state.
// Sailor Senshi says "WORLD SHAKING!!!"
state Firing
{
	// Returns true if we can fire.
	simulated function bool ClientFire()
	{
		if ( Level.NetMode == NM_Client )
		{
			if ( bInterruptFire && CanFire() )
			{
				FireAnimSentry = AS_Start;
				return Global.ClientFire();
			}
			else
				return false;
		}
		else
			return Global.ClientFire();
	}

	// Returns true if we can altfire.
	simulated function bool ClientAltFire()
	{
		if ( Level.NetMode == NM_Client )
		{
			if ( bMultiMode )
				return Global.ClientAltFire();
			else
				return false;
		}
		else
			return Global.ClientAltFire();
	}

	// Performs firing logic.
	function Fire()
	{
		if ( bInterruptFire && !GottaReload() )
			Global.Fire();
	}

	// Performs altfiring logic.
	function AltFire() {}

	// Chooses what kind of firing to perform.
	simulated function ChooseFire()
	{
		if ( Level.NetMode == NM_Client )
			Global.ClientFire();
		else
			Global.Fire();
	}

	// Chooses what kind of altfiring to perform.
	simulated function ChooseAltFire()
	{
		if ( Level.NetMode == NM_Client )
			Global.ClientAltFire();
		else
			Global.AltFire();
	}

	// After firing is finished, this chooses what finish state selector to use.
	simulated function FinishFire()
	{
		FireAnimSentry = AS_None;
		GotoState('Idle');
	}

	// Returns true if we've got a fire start anim for this fire type.
	simulated function bool HasFireStart()
	{
		if ( bAltFiring )
			return bAltFireStart;
		else
			return bFireStart;
	}

	// Returns true if we've got a fire stop anim for this fire type.
	simulated function bool HasFireStop()
	{
		if ( bAltFiring )
			return bAltFireStop;
		else
			return bFireStop;
	}

	// Plays a fire start anim for this fire type.
	simulated function AnimFireStart()
	{
		FireAnimSentry = AS_Start;
		if ( bAltFiring )
			WpnAltFireStart();
		else
			WpnFireStart();
	}

	// Plays a fire anim for this fire type.
	simulated function AnimFire()
	{
		FireAnimSentry = AS_Middle;
		if ( bAltFiring )
			WpnAltFire();
		else
			WpnFire();
	}

	// Plays a fire stop anim for this fire type.
	simulated function AnimFireStop()
	{
		FireAnimSentry = AS_Stop;
		if ( bAltFiring )
			WpnAltFireStop();
		else
			WpnFireStop();
	}

	// Called when the current animation ends.
	// Based on our FireAnimSentry, it either stops firing or plays the next part in the animation.
	simulated function AnimEnd()
	{
		if ( FireAnimSentry == AS_Start )
			AnimFire();
		else if ( FireAnimSentry == AS_Middle )
		{
			if ( CanFire() && ButtonFire() )
			{
				// Jess: Temporary hack. Very temporary!
				if( Owner.bIsPlayerPawn || self.IsA( 'M16' ) ) 
					ChooseFire();
				return;
			}
			else if ( CanFire() && ButtonAltFire() )
			{
				ChooseAltFire();
				return;
			}

			if ( HasFireStop() )
				AnimFireStop();
			else
				FinishFire();
		}
		else if ( FireAnimSentry == AS_Stop )
			FinishFire();
	}	
	
	// Effectively BeginState.
	simulated function StartFiring()
	{
		if ( HasFireStart() )
			AnimFireStart();
		else
			AnimFire();
	}

	// Called when the state is exited.
	simulated function EndState()
	{
		AmbientSound = None;
	}

	// Not used.
	simulated function BeginState();
}

// This reloads the entire weapon clip.
simulated function ReloadAll( out int LoadCount )
{
	if ( AmmoType.GetModeAmmo() >= ReloadCount )
		LoadCount = ReloadCount;
	else
		LoadCount = AmmoType.GetModeAmmo();
}

// This reloads a single round of a clip.
simulated function ReloadSingle( out int LoadCount )
{
	if ( AmmoType.GetModeAmmo() >= ReloadClipAmmo )
		LoadCount += ReloadClipAmmo;
	else
		LoadCount += AmmoType.GetModeAmmo();

	if ( LoadCount > ReloadCount )
		LoadCount = ReloadCount;
}

// The PlayerPawn does not send bFire messages while the weapon is in this state.
state Reloading
{
	ignores AltFire;

	simulated function bool ClientFire()
	{
		// We return true here so that bFire can be held down.
		// This allows firing to resume as soon as the state exits.
		if ( bInterruptableReload )
			bInterruptSingleReload = true;
		return false;
	}

	simulated function bool ClientAltFire()
	{
		return false;
	}

	function Fire()
	{
		ClientFire();
	}

	// When reloading is finished, this is called.  Chooses the next state to move into.
	simulated function FinishReload()
	{
		ReloadAnimSentry = AS_None;
		if ( bChangeWeapon )
			GotoState('DownWeapon');
		else
			GotoState('Idle');
	}

	// Called when the current anim ends.  Chooses the next part of the reload functionality to do based on ReloadAnimSentry.
	simulated function AnimEnd()
	{
		if ( ReloadAnimSentry == AS_Start )
		{
			ReloadAnimSentry = AS_Middle;
			WpnReload();
			if ( ReloadClipAmmo == 0 )
			{
				ReloadAll( TempLoadCount );
				Pawn(Owner).ServerSetLoadCount( TempLoadCount );
			}
			else if ( (AmmoType.GetModeAmmo()>0) && (TempLoadCount < AmmoType.GetModeAmmo()) && (TempLoadCount < ReloadCount) )
			{
				ReloadSingle( TempLoadCount );
				Pawn(Owner).ServerSetLoadCount( TempLoadCount );
			}
		}
		else if ( ReloadAnimSentry == AS_Middle )
		{
			if ( (ReloadClipAmmo == 0) && bReloadStop )
			{
				ReloadAnimSentry = AS_Stop;
				WpnReloadStop();
			} 
			else if ( (ReloadClipAmmo > 0) &&
					  (AmmoType.GetModeAmmo()>0) && 
					  (TempLoadCount < AmmoType.GetModeAmmo()) && 
					  (TempLoadCount < ReloadCount) && 
					  !bInterruptSingleReload && !bChangeWeapon )
			{
				ReloadAnimSentry = AS_Middle;
				WpnReload();
				ReloadSingle( TempLoadCount );
				Pawn(Owner).ServerSetLoadCount( TempLoadCount );
			}
			else if ( bReloadStop )
			{
				ReloadAnimSentry = AS_Stop;
				WpnReloadStop();
			}
			else
				FinishReload();
		}
		else if ( ReloadAnimSentry == AS_Stop )
			FinishReload();
	}

	// Called when the state is entered.
	simulated function BeginState()
	{
		bCantSendFire = true;
		bInterruptSingleReload = false;
		if ( (AmmoType.GetModeAmmo()>0) && (TempLoadCount < ReloadCount) )
		{
			ReloadAnimSentry = AS_None;
			if ( bReloadStart )
			{
				ReloadAnimSentry = AS_Start;
				WpnReloadStart();
			}
			else
			{
				ReloadAnimSentry = AS_Middle;
				WpnReload();
				if ( ReloadClipAmmo == 0 )
				{
					ReloadAll( TempLoadCount );
					Pawn(Owner).ServerSetLoadCount( TempLoadCount );
				}
				else if ( (AmmoType.GetModeAmmo()>0) && (TempLoadCount < AmmoType.GetModeAmmo()) && (TempLoadCount < ReloadCount) )
				{
					ReloadSingle( TempLoadCount );
					Pawn(Owner).ServerSetLoadCount( TempLoadCount );
				}
			}
		}
		else
			FinishReload();
	}

	// Called when the state is exited.
	simulated function EndState()
	{
		// Enable firing.
		bCantSendFire = false;
		ReloadAnimSentry = AS_None;
	}
}

// This state is entered by ClientSelectWeapon if we don't have an owner or ammotype reference.
// Here we wait until an owner and ammotype reference arrives from the server.
state WaitingForReplication
{
	// Check every once in a while for our reference.
	simulated function Timer( optional int TimerNum )
	{
		if ( (Pawn(Owner) != None) && (AmmoType != None) )
			ClientSelectWeapon();
	}

	// Set up a timer for checking.
	simulated function BeginState()
	{
		SetTimer( 0.05, true );
	}

	// Stop the timer when we leave the state.
	simulated function EndState()
	{
		SetTimer( 0.0, false );
	}
}

defaultproperties
{
    bCanThrow=true
    ProjectileSpeed=1000.000000
    AltProjectileSpeed=1000.000000
    aimerror=550.000000
    AIRating=0.100000
    ItemName="Weapon"
    AutoSwitchPriority=1
    RespawnTime=30.000000
    PlayerViewOffset=(X=30.000000,Z=-5.000000)
    MaxDesireability=0.500000
    Texture=Texture'Engine.S_Weapon'
    bNoSmooth=false
    Icon=Texture'Engine.S_Weapon'
    MaxDesiredActorLights=2
    CurrentDesiredActorLights=2
    LightDetail=LTD_Normal
    MuzzleSpriteAlpha=1.0
    AltMuzzleSpriteAlpha=1.0
    bDontReplicateSkin=true
    IdleAnim=(DebugString="IdleAnim");
    RunAnim=(DebugString="RunAnim");
    FireAnim=(DebugString="FireAnim");
    AltFireAnim=(DebugString="AltFireAnim");	
	FireStartAnim=(DebugString="FireStartAnim");
	FireStopAnim=(DebugString="FireStopAnim");
    CrouchIdleAnim=(DebugString="CrouchIdleAnim");
    CrouchWalkAnim=(DebugString="CrouchWalkAnim");
    CrouchFireAnim=(DebugString="CrouchFireAnim");
    ReloadStartAnim=(DebugString="ReloadStartAnim");
    ReloadLoopAnim=(DebugString="ReloadLoopAnim");
    ReloadStopAnim=(DebugString="ReloadStopAnim");	
	MuzzleFlashLength=0.06
	AltMuzzleFlashLength=0.06
	bWeaponPenetrates=true
	bCanChangeMode=true
}
