/*-----------------------------------------------------------------------------
	TripMine
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class TripMine extends dnWeapon;

#exec OBJ LOAD FILE=..\Sounds\dnsWeapn.dfx
#exec OBJ LOAD FILE=..\Meshes\c_dnWeapon.dmx
#exec OBJ LOAD FILE=..\Textures\smk4.dtx
#exec OBJ LOAD FILE=..\Textures\smk5.dtx

var SmackerTexture					FireScreens[3];
var int								FlicFrames[3];
var float							IdleTweenTime;
var bool							PauseScreen, WasInRange;

var(Animation) WAMEntry				SAnimInRange[4];
var(Animation) WAMEntry				SAnimInDeactivate[4];
var(Animation) WAMEntry				SAnimOutRange[4];
var(Animation) WAMEntry				SAnimIdleInRange[4];
var(Animation) WAMEntry             FireAnimA;
var(Animation) WAMEntry             FireAnimB;
var(Animation) WAMEntry             FireAnimC;

var sound							TouchScreenSound, FlipSwitchSound, ReadySound, SlideSound;



/*-----------------------------------------------------------------------------
	Object Methods
-----------------------------------------------------------------------------*/

// Initialization.  Store references to the various fire smacks.
simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	FireScreens[0] = smackertexture'smk4.s_tripfirea';
	FireScreens[1] = smackertexture'smk4.s_tripfireb';
	FireScreens[2] = smackertexture'smk4.s_tripfirec';
}

// When we become a pickup, turn off any special smacks.
function BecomePickup()
{
	Super.BecomePickup();
	MultiSkins[0] = None;
	AnimSequence = 'close';
}



/*-----------------------------------------------------------------------------
	Notifies
-----------------------------------------------------------------------------*/

// Function called when Duke touches the screen.
simulated function TouchScreen()
{
	Owner.PlaySound( TouchScreenSound, SLOT_None, Pawn(Owner).SoundDampening*0.4 );

}

// Function called when Duke flips the switch.
simulated function FlipSwitch()
{
	Owner.PlaySound( FlipSwitchSound, SLOT_None, Pawn(Owner).SoundDampening*0.4 );
}

// Function called when mine slides open.
simulated function Slide()
{
	Owner.PlaySound( SlideSound, SLOT_None, Pawn(Owner).SoundDampening*0.4 );
}



/*-----------------------------------------------------------------------------
	Firing
-----------------------------------------------------------------------------*/

// Check to see if the client can fire.
// If it returns true, a fire message will be sent to the server.
simulated function bool ClientFire()
{
	local Actor HitActor;

	// Are we in range?
	HitActor = Pawn(Owner).TraceFromCrosshair(50);
	if ( HitActor != Level )
		return false;

	// Place a mine!
	if ( (Role == ROLE_Authority) || (AmmoType == None) || !OutOfAmmo() )
	{
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
	// Do firing animation & firing state.
	GotoState('Firing');
	StartFiring();
	ClientFire();
}



/*-----------------------------------------------------------------------------
	Weapon Action
-----------------------------------------------------------------------------*/

// If the ActionCode is zero, place a mine.
function WeaponAction( int ActionCode,  rotator ClientViewRotation )
{
	if ( ActionCode == 0 )
		PlaceMine( ClientViewRotation );
}

// Place a mine in front of us.
function PlaceMine( rotator ClientViewRotation )
{
	local vector X,Y,Z, StartTrace, EndTrace, HitLocation, HitNormal;
	local vector DrawOffset;
	local coords HitCoords, RotCoords, OutCoords;
	local LaserMine LM;
	local rotator r, r2;
	local texture ScreenCanvas;
	local Actor HitActor;

	DrawOffset = Pawn(Owner).EyeHeight * vect(0,0,1);
	StartTrace = Pawn(Owner).Location + DrawOffset;
	EndTrace   = StartTrace + (vector(ClientViewRotation)*50);

	HitActor = Trace( HitLocation, HitNormal, EndTrace, StartTrace, false );

	if ( HitActor != Level )
		return;

	AmmoType.UseAmmo(1);

	if ( AmmoType.AmmoMode == 0 )
		LM = spawn(class'LaserMine',,,HitLocation, ClientViewRotation);
	else if ( AmmoType.AmmoMode == 1 )
		LM = spawn(class'RoamingLaserMine',,,HitLocation, ClientViewRotation);
	else if ( AmmoType.AmmoMode == 2 )
		LM = spawn(class'ShieldedLaserMine',,,HitLocation, ClientViewRotation);

	// If the user is shrunken, put up a mine half this size.
	if ( ThirdPersonScale < 0.5 )
		LM.DrawScale /= 2.f;
}



/*-----------------------------------------------------------------------------
	Reloading
-----------------------------------------------------------------------------*/

// We return false, because the TripMine never reloads.  Reloading is a part of firing.
simulated function bool GottaReload()
{
	return false;
}

// Do nothing.
simulated function ClientReload()
{
}

// Do nothing.
function Reload()
{
}

// For the tripmine, only toss out a single bomb at a time.
// Called from Pawn::TossWeapon.
function DropFrom( vector StartLocation )
{
	local TripMine DropBomb;

	if ( (AmmoType == None) || (AmmoType.ModeAmount[0] == 1) )
		Super.DropFrom( StartLocation );
	else
	{
		AmmoType.UseAmmo(1);

		DropBomb = spawn( class'TripMine',,, StartLocation );
		DropBomb.PickupAmmoCount[0] = 1;
		if ( Pawn(Owner) != None )
			DropBomb.Velocity = Vector(Pawn(Owner).ViewRotation) * 500 + vect(0,0,220);
		DropBomb.bTossedOut = true;
		DropBomb.DropFrom( StartLocation );
	}
}



/*-----------------------------------------------------------------------------
	Animation
-----------------------------------------------------------------------------*/

// Play the activate animation.
// Reset the screen.
simulated function WpnActivate()
{
	local SmackerTexture Screen;

	// Call super...
	Super.WpnActivate();

	// Reset screen.
	if ( SmackerTexture(MultiSkins[0]) != none )
	{
		SmackerTexture(MultiSkins[0]).currentFrame = 0;
		PauseScreen = true;
	}
	MultiSkins[0] = None;

	// Start the check-in-range timer.
	SetTimer(0.1, true);
}

// Play the deactivate animation.
simulated function WpnDeactivated()
{
	// Choose correct deactivation anim.
	if ( WasInRange )
		WpnInDeactivated();
	else if ( !OutOfAmmo() )
		Super.WpnDeactivated();

	// Reset in range var.
	WasInRange = false;

	// Stop the check-in-range timer.
	SetTimer(0.0, false);
}

// Play the main part of the fire animation.
simulated function WpnFire( optional bool noWait )
{
	local WAMEntry entry;

	// Play the animation based on our mode.
	entry = default.SAnimFire[AmmoType.AmmoMode];
	PlayWAMEntry( entry, !noWait, 'None' );

	// Set the screen to the right one.
	MultiSkins[0] = FireScreens[AmmoType.AmmoMode];

    if ( !bDontPlayOwnerAnimation )
		Pawn(Owner).WpnPlayFire();

    WeaponState = WS_FIRE;
    bDontPlayOwnerAnimation = false;
}

// Play the stop part of the fire animation.
simulated function WpnFireStop( optional bool noWait )
{
	local WAMEntry entry;
	entry = default.SAnimFireStop[AmmoType.AmmoMode];
	PlayWAMEntry(entry, !noWait, 'None');
    
    if ( !bDontPlayOwnerAnimation )
        Pawn(Owner).WpnPlayFireStop();
    WeaponState = WS_FIRE_STOP;
    bDontPlayOwnerAnimation = false;
}

// Play the main part of the reload animation.
simulated function WpnReload( optional bool noWait )
{
	// Reset the screen.
	PauseScreen = true;
	SmackerTexture(MultiSkins[0]).currentFrame = 0;
	MultiSkins[0] = None;

	Super.WpnReload( noWait );
}

// Anim when we come in range of a wall.
simulated function WpnInRange()
{
	local WAMEntry entry;
	ActiveWAMIndex = GetRandomWAMEntry(default.SAnimInRange, entry);
	PlayWAMEntry(entry, false, 'None');
}

// Anim when we move outside of a wall's range.
simulated function WpnOutRange()
{
	local WAMEntry entry;
	ActiveWAMIndex = GetRandomWAMEntry(default.SAnimOutRange, entry);
	PlayWAMEntry(entry, false, 'None');
}

// Anim for idling in range of a wall.
simulated function WpnIdleInRange()
{
	local WAMEntry entry;
	ActiveWAMIndex = GetRandomWAMEntry(default.SAnimIdleInRange, entry);
	PlayWAMEntry(entry, false, 'None');
}

// Anim for when we deactivate in range of a wall.
simulated function WpnInDeactivated()
{
	local WAMEntry entry;

	if ( !OutOfAmmo() )
	{
		ActiveWAMIndex = GetRandomWAMEntry( default.SAnimInDeactivate, entry );
		PlayWAMEntry( entry, true, 'Activate' );

		if ( Pawn(Owner) != None )
		{
			if ( !bDontPlayOwnerAnimation )
				Pawn(Owner).WpnPlayDeactivated();
		}
    
		WeaponState = WS_DEACTIVATED;
		bDontPlayOwnerAnimation = false;
	}
}



/*-----------------------------------------------------------------------------
	Rendering
-----------------------------------------------------------------------------*/

// Allows the weapon to draw directly to the canvas.
simulated function RenderOverlays(canvas C)
{
	local float AnimTime;
	local int AnimFrame;

	// If we are firing play the fire screen anim.
	if ( GetStateName() == 'Firing' )
	{
		AnimTime = MeshInstance.MeshChannels[0].AnimFrame / MeshInstance.MeshChannels[0].AnimLast;
		AnimFrame = AnimTime * FlicFrames[AmmoType.AmmoMode];
		SmackerTexture(MultiSkins[0]).currentFrame = AnimFrame-1;
		SmackerTexture(MultiSkins[0]).pause = false;
	}

	// If we want to pause...pause...
	if ( PauseScreen && (SmackerTexture(MultiSkins[0]) != None) && (SmackerTexture(MultiSkins[0]).currentFrame != 0) )
	{
		SmackerTexture(MultiSkins[0]).pause = true;
		PauseScreen = false;
	}

	// Call super.
	Super.RenderOverlays( C );
}



/*-----------------------------------------------------------------------------
	States
-----------------------------------------------------------------------------*/

// Global stub for a state function that checks if we are in range of a wall.
simulated function bool CheckInRange() {}

// This state puts the weapon into its holstered position.
state DownWeapon
{
	// When we enter the state, animate to down and reset any relevant variables.
	simulated function BeginState()
	{
		bOnlyOwnerSee = false;
		bChangeWeapon = false;

		// If we just fired, there is no deactivate animation.
		if ( AnimSequence == 'FireEndA' )
			AnimEnd();
		else
			Super.BeginState();
	}
}

// State that is entered when the weapon is firing.
state Firing
{
	// This is a little odd.  'Activate' just happens to be the name for this
	// ready sound notification.  It's also a core inventory function.
	// We'll try to avoid collisions like this in the future.
	// In this case, we want to play the ready sound at the notification.
	function Activate()
	{
		Owner.PlaySound( ReadySound, SLOT_None, Pawn(Owner).SoundDampening*0.4 );
	}

	// After firing is finished, this chooses what finish state selector to use.
	simulated function FinishFire()
	{
		FireAnimSentry = AS_None;
		GotoState('UpNextMine');
	}

	simulated function AnimEnd()
	{
		if ( FireAnimSentry == AS_Middle )
		{
			if ( Instigator.IsLocallyControlled() )
				Instigator.ServerWeaponAction( 0, Instigator.ViewRotation );

			AnimFireStop();
		}
		else if ( FireAnimSentry == AS_Stop )
			FinishFire();
	}
}

// State that is entered when the next mine is brought up.
state UpNextMine
{
	ignores Fire, AltFire;

	// Called when we want to see if we can fire.
	simulated function bool ClientFire()
	{
		// Can't interrupt bringup.
		return false;
	}

	// Called when we want to see if we can altfire.
	simulated function bool ClientAltFire()
	{
		// Can't interrupt bringup.
		return false;
	}

	// Checks to see if we are in range of a wall.
	simulated function bool CheckInRange()
	{
		local Actor HitActor;

		// Check to see if we are in range of a wall.
		HitActor = Pawn(Owner).TraceFromCrosshair(50);
		if ( HitActor == Level )
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

	// The main function for making a weapon go down.
	simulated function bool PutDown()
	{
		// Go to the down state right away.
		GotoState('DownWeapon');
		return true;
	}

	// Called when animation ends.
	simulated function AnimEnd()
	{
		// Are we in range of a wall?
		CheckInRange();
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
			
		// Play the reloading animation.
		WpnReload();
	}
}

// This state is entered when the weapon is in a light idling state.
state Idle
{
	ignores Fire;

	// Called to see if we can fire.
	simulated function bool ClientFire()
	{
		// Can't fire when not near a wall.
		return false;
	}

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
		if ( HitActor == Level )
		{
			GotoState('InRange');
			return true;
		} else
			return false;
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

		// Check and see if we are in range.
		if ( !CheckInRange() )
			WpnIdle();
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

	// The main function for making a weapon go down.
	simulated function bool PutDown()
	{
		// Go to the down state right away.
		WasInRange = true;
		GotoState('DownWeapon');
		return true;
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
		if ( HitActor == Level )
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

	// The main function for making a weapon go down.
	simulated function bool PutDown()
	{
		// Go to the down state right away.
		GotoState('DownWeapon');
		return true;
	}

	// We are done animating...are we in range?
	simulated function AnimEnd()
	{
		CheckInRange();
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
		WasInRange = true;
		GotoState('DownWeapon');
		return true;
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
		if ( HitActor != Level )
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
	}
}

// Return the proper fire anim depending on our mode.
simulated function WAMEntry GetFireAnim()
{
	switch ( AmmoType.AmmoMode )
	{
	case 0:
		return FireAnimA;
		break;
	case 1:
		return FireAnimB;
		break;
	case 2:
		return FireAnimC;
		break;
	}
}

// Return the 3rd person fire anim.
simulated function WAMEntry GetCrouchFireAnim()
{
    return GetFireAnim();
}



/*-----------------------------------------------------------------------------
	Inventory System
-----------------------------------------------------------------------------*/

// Draws the weapon's ammo bar on the Q-menu.
simulated function DrawAmmoAmount( Canvas C, DukeHUD HUD, float X, float Y )
{
	local float AmmoScale;

	AmmoScale = float(AmmoType.GetModeAmount(0)) / AmmoType.MaxAmmo[0];
	DrawAmmoBar( C, HUD, AmmoScale, X+4*HUD.HUDScaleX*0.8, Y+51*HUD.HUDScaleY*0.8 );
}



defaultproperties
{
    SAnimActivate(0)=(AnimChance=1.000000,animSeq=Activate,AnimRate=1.000000,AnimSound=sound'dnsWeapn.Bombs.PBTMActivate1')
    SAnimIdleSmall(0)=(AnimSeq=IdleA,AnimRate=1.000000,AnimTween=0.000000,AnimChance=0.5)
	SAnimIdleSmall(1)=(AnimSeq=IdleB,AnimRate=1.000000,AnimTween=0.000000,AnimChance=0.5)
    SAnimFire(0)=(AnimChance=1.000000,animSeq=FireA,AnimRate=1.000000)
    SAnimFire(1)=(AnimChance=1.000000,animSeq=FireB,AnimRate=1.000000)
    SAnimFire(2)=(AnimChance=1.000000,animSeq=FireC,AnimRate=1.000000)
	SAnimFireStop(0)=(AnimChance=1.000000,animSeq=FireEndA,AnimRate=1.000000,AnimTween=0.000000)
	SAnimFireStop(1)=(AnimChance=1.000000,animSeq=FireEndA,AnimRate=1.000000,AnimTween=0.000000)
	SAnimFireStop(2)=(AnimChance=1.000000,animSeq=FireEndA,AnimRate=1.000000,AnimTween=0.000000)
    SAnimReload(0)=(AnimChance=1.000000,animSeq=Activate,AnimRate=1.000000,AnimSound=sound'dnsWeapn.PBTMActivate1')
    SAnimInRange(0)=(AnimChance=1.000000,animSeq=InRange,AnimRate=1.200000)
    SAnimInDeactivate(0)=(AnimChance=1.000000,animSeq=InDeactivate,AnimRate=1.500000)
    SAnimOutRange(0)=(AnimChance=1.000000,animSeq=OutRange,AnimRate=1.000000)
    SAnimIdleInRange(0)=(AnimSeq=InIdleA,AnimRate=1.000000,AnimTween=0.000000,AnimChance=0.5)
	SAnimIdleInRange(1)=(AnimSeq=InIdleB,AnimRate=1.000000,AnimTween=0.000000,AnimChance=0.5)
	PlayerViewScale=0.1
    PlayerViewOffset=(X=1.1,Y=0.0,Z=-11.5)
	ItemName="Trip Mine"
	PlayerViewMesh=mesh'c_dnWeapon.tripmine'
    PickupViewMesh=Mesh'c_dnWeapon.p_tripmine'
	ThirdPersonMesh=Mesh'c_dnWeapon.w_tripmine'
	Mesh=mesh'c_dnWeapon.w_tripmine'
	ReloadCount=1
 	ReloadClipAmmo=1
    PickupAmmoCount(0)=1
	AmmoName=Class'dnGame.TripMineAmmo'
	AmmoItemClass=class'HUDIndexItem_TripMine'
	AltAmmoItemClass=class'HUDIndexItem_TripMineAlt'
	bMultiMode=true
	bInstantHit=true
	dnInventoryCategory=2
	dnCategoryPriority=1
    AutoSwitchPriority=7
	FlicFrames(0)=11
	FlicFrames(1)=32
	FlicFrames(2)=67
	PickupSound=Sound'dnGame.Pickups.AmmoSnd'
    CollisionHeight=3.000000
    CollisionRadius=8.000000
    Icon=Texture'hud_effects.mitem_tripmines'
	PickupIcon=texture'hud_effects.am_tripmine'
	StayAlert=true
	LodMode=LOD_Disabled
	bFireStop=true
	RunAnim=(AnimSeq=A_Run,AnimChan=WAC_All,AnimRate=1.0,AnimTween=0.1,AnimLoop=true)
    FireAnimA=(AnimSeq=T_TMineFireA,AnimChan=WAC_Top,AnimRate=1.0,AnimTween=0.1,AnimLoop=false)
    FireAnimB=(AnimSeq=T_TMineFireB,AnimChan=WAC_Top,AnimRate=1.0,AnimTween=0.1,AnimLoop=false)
    FireAnimC=(AnimSeq=T_TMineFireC,AnimChan=WAC_Top,AnimRate=1.0,AnimTween=0.1,AnimLoop=false)
    IdleAnim=(AnimSeq=T_TMineIdle,AnimChan=WAC_Top,AnimRate=1.0,AnimTween=0.1,AnimLoop=true)
    CrouchIdleAnim=(AnimSeq=T_TMineIdle,AnimChan=WAC_Top,AnimRate=1.0,AnimTween=0.1,AnimLoop=true)
    CrouchWalkAnim=(AnimSeq=T_TMineIdle,AnimChan=WAC_All,AnimRate=1.0,AnimTween=0.1,AnimLoop=true)
	FlipSwitchSound=sound'dnsWeapn.TripMineSwitch1'
	TouchScreenSound=sound'dnsWeapn.TripMineType1'
	ReadySound=sound'dnsWeapn.TripMineEndSel1'
	SlideSound=sound'dnsWeapn.TMOpen07'
	CrosshairIndex=5
	bReloadOnModeChange=false
	bInstantHit=false
}