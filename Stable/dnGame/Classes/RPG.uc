/*-----------------------------------------------------------------------------
	RPG
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class RPG extends dnWeapon;

#exec OBJ LOAD FILE=..\Meshes\c_dnWeapon.dmx
#exec OBJ LOAD FILE=..\Sounds\dnsWeapn.dfx
#exec OBJ LOAD FILE=..\Textures\m_dnWeapon.dtx

var(Animation) WAMEntry	SAnimIdleSmallNuke[4];	// Special small idle when nuke is loaded.
var(Animation) WAMEntry	SAnimIdleLargeNuke[4];	// Special large idle when nuke is loaded.
var(Animation) WAMEntry	SAnimDisarmNuke[4];		// Special reload when nuke is loaded.

var				bool			bPlayNukeBootup;
var				bool			bCountingDown, bGreenForLaunch;
var				SmackerTexture  NukeScreen;



/*-----------------------------------------------------------------------------
	Object
-----------------------------------------------------------------------------*/

// Object initialization is handled here.
simulated function PostBeginPlay()
{
	// Assign our nuke screen texture.
	NukeScreen = SmackerTexture(DynamicLoadObject("smk6.s_rpgdisplay1", class'SmackerTexture'));
	NukeScreen.CurrentFrame = 0;
	NukeScreen.Pause = true;

	// Set the skin to that texture.
	MultiSkins[7] = NukeScreen;

	// Do parent init.
	Super.PostBeginPlay();
}



/*-----------------------------------------------------------------------------
	Fire Events
-----------------------------------------------------------------------------*/

// Check to see if the client can fire.
// If it returns true, a fire message will be sent to the server.
simulated function bool ClientFire()
{
	// We have a nuke selected and are not green for launch.
	if ( (AmmoType.AmmoMode == 1) && !bGreenForLaunch )
	{
		// If we are playing the nuke bootup, do nothing.
		if ( bPlayNukeBootup )
			return false;

		// We are counting down, do nothing.
		if ( bCountingDown )
			return false;

		// Start the countdown!
		bCountingDown = true;
		NukeScreen.Pause = false;
		return false;
	}

	return Super.ClientFire();
}

// Perform firing.
function Fire()
{
	// Choose a projectile based on our mode.
	if ( AmmoType.AmmoMode == 1 )
		ProjectileClass = default.AltProjectileClass;
	else
	{
		// The soliders fire special rockets.
		if( !Owner.IsA('PlayerPawn') )
			ProjectileClass = class'dnGame.EDFRocket';
		else
			ProjectileClass = default.ProjectileClass;
	}

	// We have a nuke selected and aren't ready to launch.
	if ( (AmmoType.AmmoMode == 1) && !bGreenForLaunch )
	{
		// Do the nuke behavior in ClientFire.
		ClientFire();
		return;
	}
	
	// Otherwise, do the super behavior.
	Super.Fire();
}


// Checks to see if we can alt fire.
simulated function bool ClientAltFire()
{
	// Can't change ammo modes when counting down.
	if ( bCountingDown )
		return false;

	// Call parent mode change behavior.
	Super.ClientAltFire();

	return false;
}



/*-----------------------------------------------------------------------------
	Inventory Behavior
-----------------------------------------------------------------------------*/

// Switches through the available ammo modes to find the next ammo mode.
// Also tells the server we've changed ammo modes.
simulated function CycleAmmoMode( optional bool bFast )
{
	local int OldAmmoMode;

	// Keep our old ammo mode.
	OldAmmoMode = AmmoType.AmmoMode;

	// Perform the super behavior.
	Super.CycleAmmoMode();

	// Check to see if we should load the nuke.
	if ( (OldAmmoMode == 1) && (AmmoType.AmmoMode == 0) )
		GotoState('UnloadNuke');
	else if ( (OldAmmoMode == 0) && (AmmoType.AmmoMode == 1) )
		GotoState('LoadNuke');
}



/*-----------------------------------------------------------------------------
	Reloading
-----------------------------------------------------------------------------*/

// We return false, because the RPG never reloads.  Reloading is a part of firing.
simulated function bool GottaReload()
{
	return false;
}

// Do nothing.
simulated function ClientReload()
{
}

// Do nothing here also.
function Reload()
{
}



/*-----------------------------------------------------------------------------
	Overlays
-----------------------------------------------------------------------------*/

// Allows the weapon to draw something during the post render pass.
simulated function RenderOverlays( canvas C )
{
	if ( bPlayNukeBootup )
	{
		// Play the nuke bootup screen.
		if ( NukeScreen.CurrentFrame >= 8 )
		{
			NukeScreen.CurrentFrame = 7;
			NukeScreen.Pause = true;
			bPlayNukeBootup = false;
		}
	}
	else if ( bCountingDown )
	{
		// The nuke countdown animation is playing.
		if ( NukeScreen.CurrentFrame >= 47 )
		{
			// Stop the countdown.
			NukeScreen.CurrentFrame = 0;
			NukeScreen.Pause = true;
			bCountingDown = false;

			// NUKE 'EM!!!!!
			if ( PlayerPawn(Owner) != None )
			{
				// Send nuke fire weapon action.
				PlayerPawn(Owner).ServerWeaponAction( 0, Instigator.ViewRotation );

				// Play firing animation if client.
				if ( Level.NetMode == NM_Client )
				{
					bAltFiring = false;
					GotoState('Firing');
					StartFiring();

					// Force switch back to mode 0.
					AmmoType.AmmoMode = 0;
					if ( Owner.IsA('DukePlayer') )
						DukePlayer(Owner).ServerUpdateAmmoMode( AmmoType.AmmoMode );
				}
			}
		}
	}

	Super.RenderOverlays( C );
}

// Action Code 0: Fire Nuke
function WeaponAction( int ActionCode, rotator ClientViewRotation )
{
	if ( ActionCode == 0 )
	{
		bPlayNukeBootup = false;
		bCountingDown = false;
		bGreenForLaunch = true;
		Fire();
		bGreenForLaunch = false;
	}
}


/*-----------------------------------------------------------------------------
	Animation Events
-----------------------------------------------------------------------------*/

// Play activation animation.
simulated function WpnActivate()
{
	// Reset the nuke screen frame to zero.
	NukeScreen.CurrentFrame = 0;
	NukeScreen.Pause = true;

	// Call the parent behavior.
	Super.WpnActivate();
}

// Play deactivation animation.
simulated function WpnDeactivated()
{
	// Reset nuke mode and nuke screen.
	NukeScreen.CurrentFrame = 0;
	NukeScreen.Pause = true;
	bPlayNukeBootup = false;
	bCountingDown   = false;
	bGreenForLaunch = false;

	// Call the parent.
	Super.WpnDeactivated();
}

// Overridden for idle when nuke is loaded.
simulated function WpnIdleSmall()
{
	local WAMEntry entry;

	if ( AmmoType.AmmoMode == 1 )
		ActiveWAMIndex = GetRandomWAMEntry( default.SAnimIdleSmallNuke, entry );
	else
		ActiveWAMIndex = GetRandomWAMEntry( default.SAnimIdleSmall, entry );

	PlayWAMEntry( entry, false, 'None' );
}

// Overridden for idle when nuke is loaded.
simulated function WpnIdleLarge()
{
	local WAMEntry entry;

	if (AmmoType.AmmoMode == 1)
		ActiveWAMIndex = GetRandomWAMEntry(default.SAnimIdleLargeNuke, entry);
	else
		ActiveWAMIndex = GetRandomWAMEntry(default.SAnimIdleLarge, entry);
	PlayWAMEntry(entry, false, 'None');
}

// For playing the nuke loading animation.
simulated function WpnLoadNuke( optional bool noWait )
{
	local WAMEntry entry;

	entry = default.SAnimReload[1];
	NukeScreen.CurrentFrame = 0;
	NukeScreen.Pause = true;
	PlayWAMEntry( entry, !noWait, 'None' );
	Pawn(Owner).WpnPlayReload();
}

// For playing the nuke unloading animation.
simulated function WpnUnloadNuke( optional bool noWait )
{
	local WAMEntry entry;

	entry = default.SAnimReload[0];
	PlayWAMEntry( entry, !noWait, 'None' );
	Pawn(Owner).WpnPlayReload();
}

// Play the main part of the fire animation.
// Overridden to choose fire anim based on mode.
simulated function WpnFire(optional bool noWait)
{
 	local WAMEntry entry;
	entry = default.SAnimFire[AmmoType.AmmoMode];
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



/*-----------------------------------------------------------------------------
	States
-----------------------------------------------------------------------------*/

// This state puts the weapon into its holstered position.
state DownWeapon
{
	// Called when the state is entered.
	simulated function BeginState()
	{
		// If we have a nuke loaded, we need to unload it before putting our weapon down.
		if ( AmmoType.AmmoMode == 1 )
		{
			// Switch it...
			bChangeWeapon = true;
			AmmoType.AmmoMode = 0;

			// Tell the server that we changed modes.
			if ( Owner.IsA('DukePlayer') )
				DukePlayer(Owner).ServerUpdateAmmoMode( AmmoType.AmmoMode );

			// Unload it (we must have had a nuke in the chamber).
			if ( AmmoType.GetModeAmount(1) > 0 )
				GotoState('UnloadNuke');
			else
				Super.BeginState();
		}
		else
			Super.BeginState();
	}
}

// This state plays the nuke loading animation.
state LoadNuke
{
	ignores Fire, AltFire;

	// Can't interrupt this state.
	simulated function bool ClientFire()
	{
		return false;
	}

	// Can't interrupt this state.
	simulated function bool ClientAltFire()
	{
		return false;
	}

	// Called when the current animation ends.
	simulated function AnimEnd()
	{
		// Unpause the nuke screen and play the bootup smack.
		NukeScreen.pause = false;
		bPlayNukeBootup = true;

		// Idle...
		GotoState('Idle');
	}

	// Called when the state is entered.
	simulated function BeginState()
	{
		// Play the loading anim.
		WpnLoadNuke();
	}
}

// This state plays the nuke unloading animation.
state UnloadNuke
{
	ignores Fire, AltFire;

	// Can't interrupt this state.
	simulated function bool ClientFire()
	{
		return false;
	}

	// Can't interrupt this state.
	simulated function bool ClientAltFire()
	{
		return false;
	}

	// Called when the current animation ends.
	simulated function AnimEnd()
	{
		// Idle...
		GotoState('Idle');
	}

	// Called when the state is entered.
	simulated function BeginState()
	{
		// Reset the nuke screen frame.
		NukeScreen.CurrentFrame = 0;

		// Play the unloading anim.
		WpnUnloadNuke();
	}
}

// This state is entered when the weapon is in a light idling state.
state Idle
{
	// The main function for making a weapon go down.
	simulated function bool PutDown()
	{
		// If we are counting down, don't stop!
		if ( bCountingDown )
		{
			bChangeWeapon = true;
			return true;
		} else
			return Super.PutDown();
	}

	// Called when the state is entered.
	simulated function BeginState()
	{
		Super.BeginState();
	}
}
/*
// FinishServerFire is called after the Firing mode ends on the server.
// It evaluates the weapon's condition and chooses a new state to enter.
function FinishServerFire()
{
	// If we are out of nukes, set our ammo mode to zero.
	if ( (PlayerPawn(Owner) != None) && (Viewport(PlayerPawn(Owner).Player) != None) && (AmmoType.AmmoMode == 1) )
	{
		// Set to zero and notify server.
		AmmoType.AmmoMode = 0;
		if ( Owner.IsA('DukePlayer') )
			DukePlayer(Owner).ServerUpdateAmmoMode( AmmoType.AmmoMode );
	}

	Super.FinishServerFire();
}
*/

defaultproperties
{
    SAnimIdleSmall(0)=(AnimSeq=IdleA,AnimRate=1.000000,AnimTween=0.000000,AnimChance=0.5)
	SAnimIdleSmall(1)=(AnimSeq=IdleB,AnimRate=1.000000,AnimTween=0.000000,AnimChance=0.5)
	SAnimIdleLarge(0)=(AnimSeq=IdleC,AnimRate=1.000000,AnimTween=0.000000,AnimChance=0.8)
    SAnimIdleSmallNuke(0)=(AnimSeq=NukeIdleA,AnimRate=1.000000,AnimTween=0.000000,AnimChance=0.5)
	SAnimIdleSmallNuke(1)=(AnimSeq=NukeIdleB,AnimRate=1.000000,AnimTween=0.000000,AnimChance=0.5)
	SAnimIdleLargeNuke(0)=(AnimSeq=NukeIdleC,AnimRate=1.000000,AnimTween=0.000000,AnimChance=0.8)
    SAnimReload(0)=(AnimSeq=DisArmNuke,AnimRate=1.000000,AnimTween=0.000000,AnimSound=Sound'dnsWeapn.shotgun.GF03007')
    SAnimReload(1)=(AnimSeq=ArmNuke,AnimRate=1.000000,AnimTween=0.000000,AnimSound=Sound'dnsWeapn.shotgun.GF03007')
	SAnimFire(1)=(AnimChance=1.000000,animSeq=NukeFire,AnimRate=1.000000)

    NotifySounds(0)=Sound'dnsWeapn.m16.M16Cock1'

    AmmoName=Class'dnGame.rocketPack'
    ReloadCount=1
	ReloadClipAmmo=0
    PickupAmmoCount(0)=5
    FireOffset=(X=3.0,Y=-15.0,Z=-20.0)
    AIRating=0.900000
    AutoSwitchPriority=8
	ItemName="RPG"
	PlayerViewScale=0.1
    PlayerViewOffset=(X=01.55,Y=-0.3,Z=-6.85)
    PlayerViewMesh=Mesh'c_dnWeapon.rpg'
    PickupViewMesh=Mesh'c_dnWeapon.w_rpg'
    ThirdPersonMesh=Mesh'c_dnWeapon.w_rpg'
    PickupSound=Sound'dnGame.Pickups.WeaponPickup'
    Icon=Texture'hud_effects.mitem_RPG'
	PickupIcon=Texture'hud_effects.am_rpg'

    AnimRate=0.750000
    Mesh=Mesh'c_dnWeapon.w_rpg'
    bMeshCurvy=false
    SoundRadius=64
    SoundVolume=200
    CollisionHeight=8.000000

	bShrunkProjectile=true
	ProjectileClass=class'dnRocket'
	ShrunkProjectileClass=class'dnRocketShrunk'

	bShrunkAltProjectile=true
	AltProjectileClass=class'dnNuke'
	ShrunkAltProjectileClass=class'dnNukeShrunk'

	AltAmmoItemClass=class'HUDIndexItem_RPGAlt'
	AmmoItemClass=class'HUDIndexItem_RPG'
	bMultiMode=true
	dnCategoryPriority=2
	dnInventoryCategory=2

	RunAnim=(AnimSeq=A_Run_RPG,AnimChan=WAC_All,AnimRate=1.0,AnimTween=0.1,AnimLoop=true)
    FireAnim=(AnimSeq=T_RPGFire,AnimChan=WAC_Top,AnimRate=1.0,AnimTween=0.1,AnimLoop=false)
    AltFireAnim=(AnimSeq=T_RPGFire,AnimChan=WAC_Top,AnimRate=1.0,AnimTween=0.1,AnimLoop=false)
    IdleAnim=(AnimSeq=T_RPGIdle,AnimChan=WAC_Top,AnimRate=1.0,AnimTween=0.1,AnimLoop=true)
    CrouchIdleAnim=(AnimSeq=T_CrchIdle_GenGun,AnimChan=WAC_Top,AnimRate=1.0,AnimTween=0.1,AnimLoop=true)
    CrouchWalkAnim=(AnimSeq=A_CrchWalk_GenGun,AnimChan=WAC_All,AnimRate=1.0,AnimTween=0.1,AnimLoop=true)
    CrouchFireAnim=(AnimSeq=T_CrchFire_GenGun,AnimChan=WAC_Top,AnimRate=1.0,AnimTween=0.1,AnimLoop=false)

	StayAlert=true

	MuzzleFlashOrigin=(X=0,Y=0,Z=0)
//	MuzzleFlashClass=class'dnMuzzleRPG'
	MuzzleFlashSprites(0)=texture'm_dnWeapon.muzzleflash11arc'
	MuzzleFlashSprites(1)=texture'm_dnWeapon.muzzleflash11brc'
	NumFlashSprites=1
	SpriteFlashX=260.0
	SpriteFlashY=130.0
	MuzzleFlashScale=7
	UseSpriteFlash=true
	MuzzleFlashLength=0.12
	bMultiFrameFlash=true
	bMuzzleFlashRotates=false

	LodMode=LOD_Disabled

	CrosshairIndex=7

	bFireIgnites=true
}
