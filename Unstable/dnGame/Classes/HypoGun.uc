/*-----------------------------------------------------------------------------
	HypoGun
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class HypoGun expands dnWeapon;

#exec OBJ LOAD FILE=..\Meshes\c_dnWeapon.dmx
#exec OBJ LOAD FILE=..\Sounds\dnsWeapn.dfx
#exec OBJ LOAD FILE=..\Textures\m_dnWeapon.dtx
#exec OBJ LOAD FILE=..\Sounds\a_inventory.dfx

var(Animation) WAMEntry				SAnimInRange[4];
var(Animation) WAMEntry				SAnimOutRange[4];
var(Animation) WAMEntry				SAnimIdleInRange[4];

var actor InjectionActor;
var bool bJustFired, bInRange;



/*-----------------------------------------------------------------------------
	Object Methods
-----------------------------------------------------------------------------*/

// Initialization is here.
simulated function PostBeginPlay()
{
	MultiSkins[2] = texture'm_dnWeapon.vial_efx_blue';
	Super.PostBeginPlay();
}



/*-----------------------------------------------------------------------------
	Firing
-----------------------------------------------------------------------------*/

// Check to see if the client can fire.
// If it returns true, a fire message will be sent to the server.
simulated function bool ClientFire()
{
	local actor HitActor;
	local vector HitLocation;

	// If we are in multimode and switching modes, force the reload.
	if ( bMultiMode && (ReloadTimer > 0.0) && Pawn(Owner).IsLocallyControlled() )
	{
		if (Role < ROLE_Authority)
			ClientReload();
		else if( PlayerPawn( Owner ) != None )
			Reload();
		return false;
	}

	// Check to see if we can affect what's in front of us or ourselves.
	if ( bInRange )
	{
		HitActor = Pawn(Owner).TraceFromCrosshair( 50 );
		if ( (HitActor != None) && HitActor.bIsPawn )
		{
			if ( HypoVial_Health(AmmoType).CanAffect(Pawn(HitActor)) )
				bAltFiring = true;
			else
				return false;
		}
	}
	if ( !bAltFiring && !HypoVial_Health(AmmoType).CanAffect(Pawn(Owner)) )
		return false;

	// Otherwise, fire if we aren't out of ammo and the server allows us...
	if ( (Role == ROLE_Authority) || (AmmoType == None) || !OutOfAmmo() )
	{
		// Set the just fired indicator.
		bJustFired = true;

		// Go to the client side firing state.
		if ( Role < ROLE_Authority )
		{
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
	local Actor HitActor;

	// Force reload if we are waiting for it.
	if ( bMultiMode && (ReloadTimer > 0.0) && PlayerPawn( Owner ) != None )
	{
		Reload();
		return;
	}

	// Check to see if we can affect what's in front of us or ourselves.
	InjectionActor = None;
	if ( bInRange )
	{
		HitActor = Pawn(Owner).TraceFromCrosshair( 50 );
		if ( (HitActor != None) && HitActor.bIsPawn )
		{
			if ( HypoVial_Health(AmmoType).CanAffect(Pawn(HitActor)) )
			{
				bAltFiring = true;
				InjectionActor = HitActor;
			}
			else
				return;
		}
	}
	if ( !bAltFiring && !HypoVial_Health(AmmoType).CanAffect(Pawn(Owner)) )
		return;
	if ( InjectionActor == None )
		InjectionActor = Owner;

    if ( (AmmoName == None) || (AmmoType.UseAmmo(1)) )
    {
		// Standard fire behavior.
		GotoState('Firing');
		StartFiring();
		ClientFire();

		// Reduce the loaded ammo count.
		AmmoLoaded--;

		// Set our injection timer.
		SetCallbackTimer( 0.6, false, 'ApplyInjectionEffect' );
	}
}

function ApplyInjectionEffect()
{
	// Inject the target.
	HypoVial_Health(AmmoType).HypoEffect( Pawn(InjectionActor) );
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

	// Cycle to the next mode.
	AmmoType.NextAmmoMode();

	// If we didn't find a mode with ammo, do nothing.
	if ( OldAmmoMode == AmmoType.AmmoMode )
		return;

	// Tell the server that we changed modes.
	if ( Owner.IsA('DukePlayer') )
		DukePlayer(Owner).ServerUpdateAmmoMode( AmmoType.AmmoMode );

	// Play the menu interface sound.
	PlayerPawn(Owner).PlayOwnedSound(ModeChangeSound, SLOT_Interface);

	// Set us up for reloading.
	if ( bReloadOnModeChange )
	{
		AmmoLoaded = 0;
		if ( bFast )
			PlayerPawn(Owner).Reload();
		else
			ReloadTimer = 0.75;
	}
}


/*-----------------------------------------------------------------------------
	Animation
-----------------------------------------------------------------------------*/

// Play the main part of the reload animation.
simulated function WpnReload( optional bool noWait )
{
	local WAMEntry entry;

	if ( bJustFired )
	{
		MultiSkins[2] = HypoVial_Health(AmmoType).GetSkinForMode();
		ActiveWAMIndex = GetRandomWAMEntry( default.SAnimActivate, entry );
	} else
		ActiveWAMIndex = GetRandomWAMEntry( default.SAnimReload, entry );
	PlayWAMEntry(entry, !noWait, 'None');
	
    if ( !bDontPlayOwnerAnimation )
        Pawn(Owner).WpnPlayReload();
    bDontPlayOwnerAnimation = false;
}

// Play the main part of the reload animation.
simulated function WpnReloadStop()
{
	if ( bJustFired )
	{
		bJustFired = false;
		return;
	}

	MultiSkins[2] = HypoVial_Health(AmmoType).GetSkinForMode();
	Super.WpnReloadStop();
}

// Anim when we come in range of a wall.
simulated function WpnInRange()
{
	local WAMEntry entry;
	ActiveWAMIndex = GetRandomWAMEntry( default.SAnimInRange, entry );
	PlayWAMEntry( entry, false, 'None' );
}

// Anim when we move outside of a wall's range.
simulated function WpnOutRange()
{
	local WAMEntry entry;
	ActiveWAMIndex = GetRandomWAMEntry( default.SAnimOutRange, entry );
	PlayWAMEntry( entry, false, 'None' );
}

// Anim for idling in range of a wall.
simulated function WpnIdleInRange()
{
	local WAMEntry entry;
	ActiveWAMIndex = GetRandomWAMEntry( default.SAnimIdleInRange, entry );
	PlayWAMEntry( entry, false, 'None' );
}

// Play the activate animation.
simulated function WpnActivate()
{
	local WAMEntry entry;

	if ( AmmoType.GetModeAmmo() == 0 )
	{
		AmmoType.NextAmmoMode();
		if ( Owner.IsA('DukePlayer') && (Level.NetMode == NM_Client) )
			DukePlayer(Owner).ServerUpdateAmmoMode( AmmoType.AmmoMode );
	}

	AmmoLoaded = 1;
	MultiSkins[2] = HypoVial_Health(AmmoType).GetSkinForMode();
	ActiveWAMIndex = GetRandomWAMEntry( default.SAnimActivate, entry );
	if ( bFastActivate )
		entry.AnimRate *= 10;
	bFastActivate = false;
	bHideWeapon = false;
	PlayWAMEntry( entry, true, 'None' );
	ThirdPersonScale = 1.0;

    if ( !bDontPlayOwnerAnimation )
        Pawn(Owner).WpnPlayActivate();
    bDontPlayOwnerAnimation = false;

	// Start the check-in-range timer.
	SetTimer(0.1, true);
}

// Play the deactivate animation.
simulated function WpnDeactivated()
{
	local WAMEntry entry;

	bJustFired = false;
	if ( (AnimSequence == 'fireself') || (AnimSequence == 'fireother') )
		return;

	ActiveWAMIndex = GetRandomWAMEntry( default.SAnimDeactivate, entry );
	PlayWAMEntry( entry, true, 'Activate' );
	if ( Owner != None && !bDontPlayOwnerAnimation )
		Pawn(Owner).WpnPlayDeactivated();
    bDontPlayOwnerAnimation = false;

	// Stop the check-in-range timer.
	SetTimer(0.0, false);
}



/*-----------------------------------------------------------------------------
	States
-----------------------------------------------------------------------------*/

// Global stub for a state function that checks if we are in range of a wall.
simulated function bool CheckInRange() {}

// This state is entered when the weapon is in a light idling state.
state Idle
{
	// Called periodically to see if we are close to a wall.
	simulated function Timer( optional int TimerNum )
	{
		CheckInRange();
	}

	// Check an see if we are close to a wall.
	simulated function bool CheckInRange()
	{
		local Actor HitActor;

		// Check to see if we are in range of a wall, if we are change to in range.
		HitActor = Pawn(Owner).TraceFromCrosshair(50);
		if ( (HitActor != None) && HitActor.bIsPawn )
		{
			GotoState('InRange');
			return true;
		} else
			return false;
	}
}

// State entered when weapon switches to being close enough to a wall to place a mine.
state InRange
{
	ignores Fire;

	// Called to see if we can fire.
	simulated function bool ClientFire()
	{
		// Can't fire during range switch.
		return false;
	}

	// Called at the end of an animation.
	simulated function AnimEnd()
	{
		// Go to the in range idle.
		GotoState('IdleInRange');
	}

	// Called when state is entered.
	simulated function BeginState()
	{
		if ( bChangeWeapon )
		{
			// If we have to change weapons, do it!
			PutDown();
			return;
		}

		// Play in range animation.
		WpnInRange();
	}
}

// State entered when we move out of range of a wall.
state OutRange
{
	ignores Fire;

	// Called to see if we can fire.
	simulated function bool ClientFire()
	{
		// Can't fire during range switch.
		return false;
	}

	// Check to see if we are close to a wall, if so, switch modes.
	simulated function bool CheckInRange()
	{
		local Actor HitActor;

		// Check to see if we are in range of a wall.
		HitActor = Pawn(Owner).TraceFromCrosshair(50);
		if ( (HitActor != None) && HitActor.bIsPawn )
		{
			GotoState('InRange');
			return true;
		}
		else
		{
			GotoState('Idle');
			return false;
		}
	}

	// We are done animating...are we in range?
	simulated function AnimEnd()
	{
		if ( bChangeWeapon )
		{
			// If we have to change weapons, do it!
			GotoState('DownWeapon');
			return;
		}

		CheckInRange();
	}

	// Called when state is entered.
	simulated function BeginState()
	{
		// Play moving out of range animation.
		WpnOutRange();
	}
}

// State entered when we are idling next to a wall.
state IdleInRange
{
	// Called when animation ends.
	simulated function AnimEnd()
	{		
		// Loop the in range idle...
		WpnIdleInRange();
	}

	// The main function for making a weapon go down.
	simulated function bool PutDown()
	{
		// Go to the down state right away.
		bChangeWeapon = true;
		GotoState('OutRange');
		return false;
	}

	// Called periodically to see if we are close to a wall.
	simulated function Timer( optional int TimerNum )
	{
		CheckInRange();
	}

	// Are we in range of a wall?
	simulated function bool CheckInRange()
	{
		local Actor HitActor;

		// Check to see if we are in range of a wall, if not, go to out range.
		HitActor = Pawn(Owner).TraceFromCrosshair(50);
		if ( (HitActor == None) || !HitActor.bIsPawn )
		{
			GotoState('OutRange');
			return false;
		} else
			return true;
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
		}

		// Check to see if we are in range.
		if ( CheckInRange() )
			WpnIdleInRange();

		bInRange = true;
	}

	// Called when state is exited.
	simulated function EndState()
	{
		bInRange = false;
	}
}

// The PlayerPawn does not send bFire messages while the weapon is in this state.
state Reloading
{
	// Called when the current anim ends.  Chooses the next part of the reload functionality to do based on ReloadAnimSentry.
	simulated function AnimEnd()
	{
		if ( (ReloadAnimSentry == AS_Middle) && bJustFired )
		{
			WpnReloadStop();
			GotoState('Idle');
		} else
			Super.AnimEnd();
	}
}

// This state puts the weapon into its holstered position.
state DownWeapon
{
	// When we enter the state, animate to down and reset any relevant variables.
	simulated function BeginState()
	{
		// Call super.
		Super.BeginState();
		
		// Maybe go down right away.
		if ( (AnimSequence == 'fireself') || (AnimSequence == 'fireother') )
			AnimEnd();
	}
}

defaultproperties
{
    SAnimIdleSmall(0)=(AnimSeq=IdleA,AnimRate=1.0,AnimTween=0.0,AnimChance=0.5)
	SAnimIdleSmall(1)=(AnimSeq=IdleB,AnimRate=1.0,AnimTween=0.0,AnimChance=0.5)
	SAnimIdleLarge(1)=(AnimSeq=IdleA,AnimRate=1.0,AnimTween=0.0,AnimChance=1.0)
    SAnimFire(0)=(AnimSeq=fireself)
    SAnimAltFire(0)=(AnimSeq=fireother,animrate=1.0,animchance=1.0,animtween=0.0)
    SAnimReload(0)=(animSeq=changevialb)
    SAnimReloadStop(0)=(animSeq=changeviala,animrate=1.0,animchance=1.0)
    SAnimInRange(0)=(AnimChance=1.000000,animSeq=InRange,AnimRate=1.000000)
    SAnimOutRange(0)=(AnimChance=1.000000,animSeq=OutRange,AnimRate=1.000000)
    SAnimIdleInRange(0)=(AnimSeq=InIdleA,AnimRate=1.000000,AnimTween=0.000000,AnimChance=1.0)

    AmmoName=Class'dnGame.HypoVial_Health'
	AmmoItemClass=class'HUDIndexItem_Hypo'
	AltAmmoItemClass=class'HUDIndexItem_HypoAlt'
	bMultiMode=true
	ReloadCount=1
 	ReloadClipAmmo=0
    PickupAmmoCount(0)=1
	bInstantHit=true

    CollisionHeight=6.0
    CollisionRadius=19.0
	PlayerViewScale=0.1
    PlayerViewOffset=(X=0.8,Y=0.0,Z=-9.0)
    PlayerViewMesh=Mesh'c_dnWeapon.hypogun'
    PickupViewMesh=Mesh'c_dnWeapon.w_hypogun'
    ThirdPersonMesh=Mesh'c_dnWeapon.w_hypogun'
    Mesh=Mesh'c_dnWeapon.w_hypogun'

	ItemName="HypoSpray Gun"
    PickupSound=Sound'dnGame.Pickups.WeaponPickup'
	PickupIcon=texture'hud_effects.am_hypogun'
    Icon=Texture'hud_effects.mitem_hypogun'

	dnInventoryCategory=5
	dnCategoryPriority=1

	LodMode=LOD_Disabled

	NotifySounds(0)=sound'a_inventory.hypo.HypoInject10'
	NotifySounds(1)=sound'a_inventory.hypo.HypoVialOff1'
	NotifySounds(2)=sound'a_inventory.hypo.HypoVialOn1'

	bUseAnytime=true

	bReloadStop=true
}