/*-----------------------------------------------------------------------------
	MultiBomb
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class MultiBomb extends dnWeapon;

#exec OBJ LOAD FILE=..\Sounds\dnsWeapn.dfx
#exec OBJ LOAD FILE=..\Meshes\c_dnWeapon.dmx
#exec OBJ LOAD FILE=..\Textures\smk4.dtx
#exec OBJ LOAD FILE=..\Textures\smk5.dtx

var(Animation) WAMEntry AnimCycle[4];
var(Animation) WAMEntry AnimThrowStick[4];
var(Animation) WAMEntry AnimThrowPipe[4];
var(Animation) WAMEntry AnimStickWall[4];
var(Animation) WAMEntry AnimDetonatorActivate[4];
var(Animation) WAMEntry AnimDetonatorIdle[4];
var(Animation) WAMEntry AnimDetonatorFire[4];
var(Animation) WAMEntry AnimDetonatorDeactivate[4];

var		smackertexture		IntroSmack[2];
var		smackertexture		ModeSmack[2];

var		Actor				HitActor;

var		class<Projectile>	MultiBombProjectile[2];
var		class<Projectile>	MultiBombProjectileShrunk[2];
var		float				FireStartTime;
var		mesh				DetonatorMesh;

var		bool				bPipeBombsDeployed;
var		bool				bDetonatorDeactivate;

var		bool				ThrowTossBomb, bSwapMeshNextTick;

var		sound				SwitchSound1, SwitchSound2;
var		sound				BOOMSound;



/*-----------------------------------------------------------------------------
	Object
-----------------------------------------------------------------------------*/

// If we are destroyed, kill any owned multibombs.
simulated function Destroyed()
{
	bPipeBombsDeployed = false;
	WeaponAction( -1, rot(0,0,0) );
	Super.Destroyed();
}



/*-----------------------------------------------------------------------------
	Firing
-----------------------------------------------------------------------------*/

// Forward to client fire.
function Fire()
{
	ClientFire();
}

// If the player begins to fire and we are locally controlled, start to throw.
simulated function bool ClientFire()
{
	if ( Instigator.IsLocallyControlled() )
		GotoState('ThrowStart');
	return true;
}

// Cycle ammo modes.  Play cycling animation.
simulated function CycleAmmoMode( optional bool bFast )
{
	local int OldAmmoMode;

	// Store current mode.
	OldAmmoMode = AmmoType.AmmoMode;

	// Cycle through the custom ammo types.
	Super.CycleAmmoMode( bFast );

	// Play cycle anim.
	WpnPlayCycle(OldAmmoMode, AmmoType.AmmoMode);
}



/*-----------------------------------------------------------------------------
	Weapon Action
-----------------------------------------------------------------------------*/

// Handles weapon action requests from the client.
// -1: Destroy all bombs.
// -2: Slap bomb onto wall.
// >0: Fire bomb at force ActionCode / 10000
function WeaponAction( int ActionCode, rotator ClientViewRotation )
{
	local PipeBomb P;

	if ( ActionCode == -1 )
	{
		bPipeBombsDeployed = false;
		foreach AllActors( class'PipeBomb', P )
		{
			if ( P.Owner == Self )
				P.Explode( P.Location+Vect(0,0,1)*16 );
		}
	}
	else if ( ActionCode == -2 )
		PlaceSticky( ClientViewRotation );
	else
	{
		if ( ThirdPersonScale < 0.5 )
			ProjectileFire( MultiBombProjectileShrunk[AmmoType.AmmoMode], ActionCode/10000, false, FireOffset );
		else
			ProjectileFire( MultiBombProjectile[AmmoType.AmmoMode], ActionCode/10000, false, FireOffset );
	}
}

// Place a sticky bomb.
function PlaceSticky( rotator ClientViewRotation )
{
	local vector X,Y,Z, StartTrace, EndTrace, HitLocation, HitNormal;
	local vector DrawOffset, BombLocation;
	local coords HitCoords, RotCoords, OutCoords;
	local StickyBomb Bomb;
	local rotator r, r2;
	local texture ScreenCanvas;
	local Actor HitActor;

	DrawOffset = Pawn(Owner).default.BaseEyeHeight * vect(0,0,1);

	StartTrace = Pawn(Owner).Location + DrawOffset;
	EndTrace   = StartTrace + (vector(ClientViewRotation)*50);

	HitActor = Trace( HitLocation, HitNormal, EndTrace, StartTrace, false );

	if ( HitActor != Level )
		return;

	AmmoType.UseAmmo( 1 );

	BombLocation = HitLocation + 3*HitNormal;
	if ( ThirdPersonScale < 0.5 )
		Bomb = spawn( class'StickyBombShrunk',,,BombLocation, rotator(HitNormal) );
	else
		Bomb = spawn( class'StickyBomb',,,BombLocation, rotator(HitNormal) );

	Bomb.SetPhysics( PHYS_None );
}

// Throw a sticky bomb.
function Projectile ProjectileFire( class<projectile> ProjClass, float ProjSpeed, bool bWarn, vector inFireOffset )
{
	local Vector Start, X, Y, Z;
	local Pawn PawnOwner;
	local Projectile Proj;
	local Vector HitLocation, HitNormal;
	local Actor HitActor;

	// Use ammo.
	AmmoType.UseAmmo(1);

	PawnOwner = Pawn(Owner);
	Owner.MakeNoise(PawnOwner.SoundDampening);
	GetAxes(PawnOwner.ViewRotation,X,Y,Z);
	Start = Owner.Location + CalcDrawOffset() + inFireOffset.X * X + inFireOffset.Y * Y + inFireOffset.Z * Z;
//	Start = PawnOwner.Location + PawnOwner.BaseEyeHeight * vect(0,0,1);

	// See if we can get to the start location.
	// This is to prevent us from throwing through doors and into walls.
//	HitActor = Trace( HitLocation, HitNormal, Start, PawnOwner.Location + PawnOwner.BaseEyeHeight * vect(0,0,1), true );
//	if ( HitActor != None )
//	{
		// We hit something, so throw from our eyeheight instead of from the hand tip.
//		Start = PawnOwner.Location + PawnOwner.BaseEyeHeight * vect(0,0,1);
//	}

	AdjustedAim = PawnOwner.AdjustAim(ProjSpeed, Start, AimError, True, bWarn);
	Proj = Spawn(ProjClass, Self,, Start,AdjustedAim);

	if ( Owner.IsA('PlayerPawn') &&
		 (AmmoType.AmmoMode == 0) &&
		 (PawnOwner.GetPostureState() == PS_Crouching) &&
		 (Normalize(PlayerPawn(Owner).ViewRotation).Pitch < 0) )
		dnProjectile(Proj).bRollOnGround = true;

	// Calculate the bomb's speed.
	GetAxes(Proj.Instigator.ViewRotation,X,Y,Z);

	Proj.Speed = ProjSpeed;
	Proj.Velocity = X * (Proj.Instigator.Velocity Dot X)*0.4 + Vector(Proj.Rotation) * (Proj.Speed + 50);// (Proj.Speed + FRand() * 100);
	Proj.Velocity.Z += 200;

	return Proj;
}

// Return the throw force.
simulated function float GetThrowForce()
{
	local float HoldScale;
	local float ThrowForce;

	HoldScale = FMin((Level.TimeSeconds - FireStartTime) + 0.3, 1.0);
	ThrowForce = HoldScale * MultiBombProjectile[AmmoType.AmmoMode].default.Speed;
	return ThrowForce;
}



/*-----------------------------------------------------------------------------
	Reloading
-----------------------------------------------------------------------------*/

// We return false, because the MultiBomb never reloads.  Reloading is a part of firing.
simulated function bool OutOfAmmo()
{
	if ( bPipeBombsDeployed )
		return false;
	if ( AmmoType == None )
		return false;
	else
		return AmmoType.OutOfAmmo();
}

// Do nothing.
simulated function ClientReload()
{
}

// Do nothing.
function Reload()
{
}

// For the multibomb, only toss out a single bomb at a time.
// Called from Pawn::TossWeapon.
function DropFrom( vector StartLocation )
{
	local MultiBomb DropBomb;

	if ( (AmmoType == None) || (AmmoType.ModeAmount[0] == 1) )
		Super.DropFrom( StartLocation );
	else
	{
		AmmoType.UseAmmo(1);

		DropBomb = spawn( class'MultiBomb',,, StartLocation );
		DropBomb.PickupAmmoCount[0] = 1;
		if ( Pawn(Owner) != None )
			DropBomb.Velocity = Vector(Pawn(Owner).ViewRotation) * 500 + vect(0,0,220);
		DropBomb.bTossedOut = true;
		DropBomb.DropFrom( StartLocation );
	}
}



/*-----------------------------------------------------------------------------
	Notifications
-----------------------------------------------------------------------------*/

// Anim notify for switch modes.
simulated function SwitchModes()
{
	Owner.PlaySound( SwitchSound1, SLOT_None, Pawn(Owner).SoundDampening*0.4 );
	Owner.PlaySound( SwitchSound2, SLOT_Interact, Pawn(Owner).SoundDampening*0.4 );
}

// Anim notify for BOOM sound.
simulated function BOOM()
{
	Owner.PlaySound( SwitchSound2, SLOT_None, Pawn(Owner).SoundDampening*0.4 );
}



/*-----------------------------------------------------------------------------
	Animation
-----------------------------------------------------------------------------*/

// Stops animations and switches mesh.
simulated function SwitchMesh( mesh NewMesh )
{
	GetMeshInstance();

	AnimSequence = 'none';
	AnimFrame = 0.0;
	MeshInstance.MeshChannels[0].AnimSequence = 'none';
	MeshInstance.MeshChannels[0].AnimFrame = 0.0;

	Mesh = NewMesh;
}

// Plays activate animation.
simulated function WpnActivate()
{
	local WAMEntry entry;

	if ( AmmoType == None )
		BroadcastMessage("MULTIBOMB ACTIVATED WITHOUT AMMOTYPE!!! Owner:"@Owner);

	ActiveWAMIndex = AmmoType.AmmoMode;
	MultiSkins[4] = IntroSmack[AmmoType.AmmoMode];
	SmackerTexture(MultiSkins[4]).currentFrame = 0;
	SmackerTexture(MultiSkins[4]).pause = false;
	entry = SAnimActivate[AmmoType.AmmoMode];
	if ( bFastActivate )
		entry.AnimRate *= 10;
	ThirdPersonScale = 1.0;
	bFastActivate = false;
	bHideWeapon = false;
	PlayWAMEntry( entry, true, 'None' );
	
    if ( !bDontPlayOwnerAnimation )
        Pawn(Owner).WpnPlayActivate();
    
    bDontPlayOwnerAnimation = false;
    WeaponState = WS_ACTIVATE;
}

// Play the deactivate animation.
simulated function WpnDeactivated()
{
	local WAMEntry entry;

	ActiveWAMIndex = AmmoType.AmmoMode;
	if ( bDetonatorDeactivate )
		entry = AnimDetonatorDeactivate[AmmoType.AmmoMode];
	else
		entry = SAnimDeactivate[AmmoType.AmmoMode];
	bDetonatorDeactivate = false;
	if ( AnimSequence != 'fire' )
		PlayWAMEntry(entry, true, 'Activate');
	if ( Instigator != None )
	{
		if ( !bDontPlayOwnerAnimation )
			Instigator.WpnPlayDeactivated();
	}
    WeaponState = WS_DEACTIVATED;
    bDontPlayOwnerAnimation = false;
}

// Plays the throwing animation.
simulated function WpnPlayThrow( int Phase, optional bool bNoWait )
{
	local WAMEntry entry;
	ActiveWAMIndex = Phase;
	if ( AmmoType.AmmoMode == 0 )
		entry = AnimThrowPipe[Phase];
	else
		entry = AnimThrowStick[Phase];
	PlayWAMEntry( entry, !bNoWait, 'None' );

    if ( !bDontPlayOwnerAnimation )
        Pawn(Owner).WpnPlayThrow();
    
    bDontPlayOwnerAnimation = false;
}

// Plays the stick the bomb to the wall anim.
simulated function WpnPlayStickWall( int Phase, optional bool bNoWait )
{
	local WAMEntry entry;
	ActiveWAMIndex = Phase;
	entry = AnimStickWall[Phase];
	PlayWAMEntry(entry, !bNoWait, 'None');
}

// Plays animation to cycle between modes.
simulated function WpnPlayCycle( int OldMode, int NewMode )
{
	local WAMEntry entry;

	if ( (OldMode == 1) && (NewMode != 1) )
	{
		ActiveWAMIndex = 0;
		entry = AnimCycle[0];
		PlayWAMEntry( entry, true, 'None' );
	}
	else if ( (OldMode != 1) && (NewMode == 1) )
	{
		ActiveWAMIndex = 1;
		entry = AnimCycle[1];
		PlayWAMEntry( entry, true, 'None' );
	}
	MultiSkins[4] = ModeSmack[NewMode];
	SmackerTexture(MultiSkins[4]).currentFrame = 0;
	SmackerTexture(MultiSkins[4]).pause = false;
}

// Play a long idle.  These are played only rarely.
// Called by WpnIdle.
simulated function WpnIdleLarge()
{
	local WAMEntry entry;
	ActiveWAMIndex = AmmoType.AmmoMode;
	entry = SAnimIdleLarge[AmmoType.AmmoMode];
	PlayWAMEntry( entry, false, 'None' );
    WeaponState = WS_IDLE_LARGE;
}

// Play a short idle.  These are the common idles.
// Called by WpnIdle.
simulated function WpnIdleSmall()
{
	local WAMEntry entry;
	ActiveWAMIndex = AmmoType.AmmoMode;
	entry = SAnimIdleSmall[AmmoType.AmmoMode];
	PlayWAMEntry( entry, false, 'None' );
    WeaponState = WS_IDLE_SMALL;
}

// Play idle anim for the detonator.
simulated function WpnDetonatorIdle()
{
	local WAMEntry entry;
	ActiveWAMIndex = GetRandomWAMEntry( AnimDetonatorIdle, entry );
	PlayWAMEntry( entry, false, 'None' );
    WeaponState = WS_IDLE_SMALL;
}

// Play activate anim for detonator.
simulated function WpnDetonatorActivate()
{
	local WAMEntry entry;
	ActiveWAMIndex = GetRandomWAMEntry( AnimDetonatorActivate, entry );
	PlayWAMEntry( entry, false, 'None' );
    WeaponState = WS_IDLE_SMALL;
}

// Play down anim for detonator.
simulated function WpnDetonatorDeactivate()
{
	local WAMEntry entry;
	ActiveWAMIndex = GetRandomWAMEntry( AnimDetonatorDeactivate, entry );
	PlayWAMEntry( entry, true, 'None' );
    WeaponState = WS_IDLE_SMALL;
}

// Play fire anim for detonator.
simulated function WpnDetonatorFire()
{
	local WAMEntry entry;
	ActiveWAMIndex = GetRandomWAMEntry( AnimDetonatorFire, entry );
	PlayWAMEntry( entry, true, 'None' );
    WeaponState = WS_IDLE_SMALL;
}

// No reload anim.
simulated function WpnReload( optional bool noWait )
{
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



/*-----------------------------------------------------------------------------
	States
-----------------------------------------------------------------------------*/

// The bringup state!
state Active
{
	// Called when the state is entered.
	simulated function BeginState()
	{
		// Set our mesh.
		SwitchMesh( PlayerViewMesh );

		// Call super.
		Super.BeginState();

		// If bombs are out, switch to detonator.
		if ( bPipeBombsDeployed )
		{
			MultiSkins[4] = None;
			GotoState('DetonatorIdle');
		}
	}
}

// Extends the base down weapon behavior and doesn't play a down weapon anim.
state DownWeaponAlreadyDown extends DownWeapon
{
	// When we enter the state, animate to down and reset any relevant variables.
	simulated function BeginState()
	{
		// Call super.
		Super.BeginState();
		
		// Go down right away.
		AnimEnd();
	}
}

// State entered when we start to toss a bomb.
state ThrowStart
{
	ignores Fire, AltFire;

	// Called to see if we can fire.
	simulated function bool ClientFire()
	{
		// Can't fire when throwing.
		return false;
	}

	// Called to see if we can altfire.
	simulated function bool ClientAltFire()
	{
		// Can't altfire when throwing.
		return false;
	}

	// Called when we release the fire button.
	function UnFire()
	{
		// Go to the throwing state.
		GotoState('Throw');
	}

	// Called when we release the fire button.
	simulated function ClientUnFire()
	{
		// Go to the throwing state.
		GotoState('Throw');
	}

	// Called when we enter the state.
	simulated function BeginState()
	{
		// Start to throw...
		// If we are near a wall, just toss it up close.
		FireStartTime = Level.TimeSeconds;
		if ( AmmoType.AmmoMode == 1)
		{
			HitActor = Pawn(Owner).TraceFromCrosshair(40);
			if ( HitActor == Level )
				GotoState('ThrowInRange');
			else
				WpnPlayThrow(0);
		} else
			WpnPlayThrow(0);
	}
}

// State entered when we toss the bomb.
state Throw
{
	ignores Fire, AltFire;

	// Called to see if we can fire.
	simulated function bool ClientFire()
	{
		// Can't fire when throwing.
		return false;
	}

	// Called to see if we can altfire.
	simulated function bool ClientAltFire()
	{
		// Can't altfire when throwing.
		return false;
	}

	// Called when the animation ends.
	simulated function AnimEnd()
	{
		// If we are playing the toss bomb anim toss the bomb and bring up another.
		if ( ThrowTossBomb )
		{
			// Toss the bomb.
			ThrowTossBomb = false;
			Instigator.ServerWeaponAction( GetThrowForce()*10000, Instigator.ViewRotation );

			// If we tossed a pipebomb, set the deployed flag.
			if ( AmmoType.AmmoMode == 0 )
				bPipeBombsDeployed = true;
	
			// Play the hand going down.
			WpnPlayThrow(2);			
		}
		else
		{
			// Choose whether to bring up a bomb or go to the detonator.
			if ( AmmoType.AmmoMode == 1 )
			{
				// And bring up another sticky bomb.
				if ( AmmoType.OutOfAmmo() )
				{
					// Out of ammo, but maybe we should swtich to the detonator.
					if ( bPipeBombsDeployed )
						GotoState('DetonatorIdle');
					else
					{
						Instigator.SwitchToBestWeapon();
						GotoState('DownWeaponAlreadyDown');
					}
				} else
					GotoState('NextBombUp');
			}
			else
			{
				// Or go to the detonator idle.
				GotoState('DetonatorIdle');
			}
		}
	}

	// Called when the state is entered.
	simulated function BeginState()
	{
		// We are tossing...
		ThrowTossBomb = true;

		// Play the hand tossing the bomb.
		WpnPlayThrow(1);
	}
}

// State entered when we want to bring up another bomb.
state NextBombUp
{
	ignores Fire, AltFire;

	// Called to see if we can fire.
	simulated function bool ClientFire()
	{
		// Can't fire when bringup.
		return false;
	}

	// Called to see if we can altfire.
	simulated function bool ClientAltFire()
	{
		// Can't altfire when bringup.
		return false;
	}

	// Called when animation ends.
	simulated function AnimEnd()
	{
		GotoState('Idle');
	}

	// Called when state is entered.
	simulated function BeginState()
	{
		WpnActivate();
	}
}

// State entered when we are tossing a bomb in close range to a wall.
state ThrowInRange
{
	ignores Fire, AltFire;

	// Called to see if we can fire.
	simulated function bool ClientFire()
	{
		// Can't fire when throwing.
		return false;
	}

	// Called to see if we can altfire.
	simulated function bool ClientAltFire()
	{
		// Can't altfire when throwing.
		return false;
	}

	// Called when animation ends.
	simulated function AnimEnd()
	{
		if ( Owner.bIsPlayerPawn )
			PlayerPawn(Owner).ServerWeaponAction( -2, Instigator.ViewRotation );
		GotoState('ThrowInRangeEnd');
	}

	// Called when state is entred.
	simulated function BeginState()
	{
		WpnPlayStickWall(0);
	}
}

// State entered when we are finishing a toss close to the wall.
state ThrowInRangeEnd
{
	ignores Fire, AltFire;

	// Called to see if we can fire.
	simulated function bool ClientFire()
	{
		// Can't fire when throwing.
		return false;
	}

	// Called to see if we can altfire.
	simulated function bool ClientAltFire()
	{
		// Can't altfire when throwing.
		return false;
	}

	// Called when the anim finishes.
	simulated function AnimEnd()
	{
		GotoState('DetonatorFireEnd');
	}

	// Called when the state is entered.
	simulated function BeginState()
	{
		WpnPlayStickWall(1);
	}
}

// State entered when we have the detonator up.
state DetonatorIdle
{
	// Called when we fire.
	function Fire()
	{
		// Detonate the bombs.
		bPipeBombsDeployed = false;
		WeaponAction( -1, Instigator.ViewRotation );
		GotoState('DetonatorFire');
	}

	// Called when we alt fire.
	function AltFire()
	{
		// Put the detonator down.
		if ( !AmmoType.OutOfAmmo() )
			GotoState('DetonatorDown');
	}

	// Called to see if we can fire.
	simulated function bool ClientFire()
	{
		// Detonate the bombs.
		bPipeBombsDeployed = false;
		Instigator.ServerWeaponAction( -1, Instigator.ViewRotation );
		GotoState('DetonatorFire');
		return false;
	}

	// Called to see if we can altfire.
	simulated function bool ClientAltFire()
	{
		// Put the detonator down.
		if ( !AmmoType.OutOfAmmo() )
			GotoState('DetonatorDown');
		return false;
	}

	// Called when the animation ends.
	simulated function AnimEnd()
	{
		WpnDetonatorIdle();
	}

	// Check periodically to see if there are pipe bombs in the world.
	// If not, put the detonator down.
	/*
	simulated function Timer( optional int TimerNum )
	{
		local PipeBomb P;
		local int PipeCount;

		if ( TimerNum == 1 )
		{
			foreach AllActors(class'PipeBomb', P)
			{
				if (P.Owner == Self)
					PipeCount++;
			}

			if (PipeCount == 0)
				GotoState('DetonatorDown');
		}
	}
	*/

	// Called when we want to be deactivated.
	simulated function bool PutDown()
	{
		// Go to the down state if we are deactivated.
		bDetonatorDeactivate = true;
		GotoState('DownWeapon');
		return true;
	}

	// Called each frame.
	simulated function Tick( float Delta )
	{
		// We wait a frame to swap meshes.
		// Swapping a mesh during an anim end is illegal.
		if ( bSwapMeshNextTick )
		{
			bSwapMeshNextTick = false;

			// Start a state that checks to see if we own pipebombs in the world.
			SetTimer(0.1, true, 1);

			// Set our skins to none and our mesh to the detonator.
			MultiSkins[4] = None;
			SwitchMesh( DetonatorMesh );
		
			// Bringup the detonator.
			WpnDetonatorActivate();
		}
	}

	// Called when the state is entered.
	simulated function BeginState()
	{
		bSwapMeshNextTick = true;
	}

	// Called when the state is exited.
	simulated function EndState()
	{
		// Turn off the check timer.
		SetTimer(0.0, true, 1);
	}
}

// State entered when we fire the detonator.
state DetonatorFire
{
	ignores Fire, AltFire;

	// Called to see if we can fire.
	simulated function bool ClientFire()
	{
		// Can't fire here.
		return false;
	}

	// Called to see if we can fire.
	simulated function bool ClientAltFire()
	{
		// Nope, go away.
		return false;
	}

	// Called at the end of an animation.
	simulated function AnimEnd()
	{
		// If we are out of ammo, switch to our best weapon.
		if ( AmmoType.OutOfAmmo() )
		{
			Instigator.SwitchToBestWeapon();
			GotoState('DownWeaponAlreadyDown');
		}
		else
			GotoState('DetonatorFireEnd');
	}

	// Called when the state is entered.
	simulated function BeginState()
	{
		WpnDetonatorFire();
	}
}

// State entered when detonator fire ends.
state DetonatorFireEnd
{
	ignores Fire, AltFire;

	// Called to see if we can fire.
	simulated function bool ClientFire()
	{
		// Can't fire here.
		return false;
	}

	// Called to see if we can fire.
	simulated function bool ClientAltFire()
	{
		// Nope, go away.
		return false;
	}

	// Called at the end of an animation.
	simulated function AnimEnd()
	{
		GotoState('Idle');
	}
	
	// Called each tick.
	simulated function Tick( float Delta )
	{
		if ( bSwapMeshNextTick )
		{
			bSwapMeshNextTick = false;

			// Switch to the weapon mesh.
			MultiSkins[4] = IntroSmack[AmmoType.AmmoMode];
			SwitchMesh( PlayerViewMesh );
			WpnActivate();
		}
	}

	// Called when the state is entered.
	simulated function BeginState()
	{
		bSwapMeshNextTick = true;
	}
}

// State entered when the detonator is put down.
state DetonatorDown
{
	ignores Fire, AltFire;

	// Called to see if we can fire.
	simulated function bool ClientFire()
	{
		// Can't fire when detonator down.
		return false;
	}

	// Called to see if we can altfire.
	simulated function bool ClientAltFire()
	{
		// Can't altfire when detonator down.
		return false;
	}

	// Called when the animation ends.
	simulated function AnimEnd()
	{
		GotoState('DetonatorDownEnd');
	}

	// Called when the state is entered.
	simulated function BeginState()
	{
		WpnDetonatorDeactivate();
	}
}

// State entered when the detonator down is finished.
state DetonatorDownEnd
{
	ignores Fire, AltFire;

	// Called to see if we can fire.
	simulated function bool ClientFire()
	{
		// Can't fire when detonator down.
		return false;
	}

	// Called to see if we can altfire.
	simulated function bool ClientAltFire()
	{
		// Can't altfire when detonator down.
		return false;
	}

	// Called when the animation ends.
	simulated function AnimEnd()
	{
		GotoState('Idle');
	}

	// Called each frame.
	simulated function Tick( float Delta )
	{
		if ( bSwapMeshNextTick )
		{
			bSwapMeshNextTick = false;

			// Bring up the normal pipe mesh.
			MultiSkins[4] = IntroSmack[AmmoType.AmmoMode];
			SwitchMesh( PlayerViewMesh );
			WpnActivate();
		}
	}

	// Called when the state is entered.
	simulated function BeginState()
	{
		bSwapMeshNextTick = true;
	}
}



defaultproperties
{
	AnimCycle(0)=(AnimSeq=Stick-Pipe,AnimRate=1.0,AnimTween=0.0,AnimChance=1.0)
	AnimCycle(1)=(AnimSeq=Pipe-Stick,AnimRate=1.0,AnimTween=0.0,AnimChance=1.0)
    SAnimIdleSmall(0)=(AnimSeq=IdlePipeA,AnimRate=1.0,AnimTween=0.0,AnimChance=1.0)
    SAnimIdleSmall(1)=(AnimSeq=IdleStickA,AnimRate=1.0,AnimTween=0.0,AnimChance=1.0)
    SAnimIdleLarge(0)=(AnimSeq=IdlePipeC,AnimRate=1.0,AnimTween=0.0,AnimChance=1.0)
    SAnimIdleLarge(1)=(AnimSeq=IdleStickC,AnimRate=1.0,AnimTween=0.0,AnimChance=1.0)
    SAnimActivate(0)=(AnimChance=1.0,animSeq=ActivatePipe,AnimRate=1.0,AnimSound=sound'dnsWeapn.Bombs.PBTMActivate1')
    SAnimActivate(1)=(AnimChance=1.0,animSeq=ActivateStick,AnimRate=1.0,AnimSound=sound'dnsWeapn.Bombs.PBTMActivate1')
    SAnimDeactivate(0)=(AnimChance=1.0,animSeq=DeactivatePipe,AnimRate=1.0)
    SAnimDeactivate(1)=(AnimChance=1.0,animSeq=DeactivateStick,AnimRate=1.0)
	AnimThrowStick(0)=(AnimChance=1.0,animSeq=ThrowStickStart,AnimRate=0.75)
	AnimThrowStick(1)=(AnimChance=1.0,animSeq=ThrowStick,AnimRate=0.75)
	AnimThrowStick(2)=(AnimChance=1.0,animSeq=ThrowStickStop,AnimRate=0.75)
	AnimThrowPipe(0)=(AnimChance=1.0,animSeq=ThrowPipeStart,AnimRate=0.75)
	AnimThrowPipe(1)=(AnimChance=1.0,animSeq=ThrowPipe,AnimRate=0.75)
	AnimThrowPipe(2)=(AnimChance=1.0,animSeq=ThrowPipeStop,AnimRate=0.75)
	AnimStickWall(0)=(AnimChance=1.0,animSeq=StickWallStart,AnimRate=0.75)
	AnimStickWall(1)=(AnimChance=1.0,animSeq=StickWallStop,AnimRate=1.0)
	AnimDetonatorActivate(0)=(AnimChance=1.0,animSeq=activate,AnimRate=1.0)
	AnimDetonatorIdle(0)=(AnimChance=1.0,animSeq=idleA,AnimRate=1.0)
	AnimDetonatorFire(0)=(AnimChance=1.0,animSeq=fire,AnimRate=1.0)
	AnimDetonatorDeactivate(0)=(AnimChance=1.0,animSeq=deactivate,AnimRate=1.0)
	PlayerViewScale=0.1
    PlayerViewOffset=(X=1.3,Y=0.0,Z=-11.85)
	ItemName="Multi-Bomb"
	PlayerViewMesh=mesh'c_dnWeapon.multibomb'
    PickupViewMesh=Mesh'c_dnWeapon.w_multipipe'
	ThirdPersonMesh=Mesh'c_dnWeapon.w_multipipe'
	Mesh=Mesh'c_dnWeapon.w_multipipe'
	DetonatorMesh=mesh'c_dnWeapon.MultibombDetonator'
	ReloadCount=1
 	ReloadClipAmmo=1
    PickupAmmoCount(0)=1
	bMultiMode=true
	dnInventoryCategory=2
	dnCategoryPriority=0
    AutoSwitchPriority=6
    CollisionHeight=3.0
    CollisionRadius=7.0
    Icon=Texture'hud_effects.mitem_multibomb'
	PickupIcon=texture'hud_effects.am_multibomb'
//    FireOffset=(X=20.0,Y=0.0,Z=-10.0)
    FireOffset=(X=10.0,Y=0.0,Z=-10.0)

	AmmoName=Class'dnGame.MultiBombAmmo'
	AmmoItemClass=class'HUDIndexItem_MultiBomb'
	AltAmmoItemClass=class'HUDIndexItem_MultiBombAlt'

	MultiBombProjectile(0)=class'dnGame.PipeBomb'
	MultiBombProjectile(1)=class'dnGame.StickyBomb'
	MultiBombProjectileShrunk(0)=class'dnGame.PipeBombShrunk'
	MultiBombProjectileShrunk(1)=class'dnGame.StickyBombShrunk'
    PickupSound=Sound'dnGame.Pickups.AmmoSnd'

	AnimSequence=ActivatePipe

	IntroSmack(0)=smackertexture'm_dnWeapon.mbomb_explointro'
	IntroSmack(1)=smackertexture'm_dnWeapon.mbomb_stickintro'
	ModeSmack(0)=smackertexture'm_dnWeapon.mbomb_explomode'
	ModeSmack(1)=smackertexture'm_dnWeapon.mbomb_stickmode'

    RunAnim=(AnimSeq=A_Run,AnimChan=WAC_All,AnimRate=1.0,AnimTween=0.1,AnimLoop=true)
    ThrowAnim=(AnimSeq=T_MultiBombToss,AnimChan=WAC_Top,AnimRate=1.2,AnimTween=0.1,AnimLoop=false)
    IdleAnim=(PlayNone=true,AnimChan=WAC_Top)
	//IdleAnim=(AnimSeq=T_MultiBombIdle,AnimChan=WAC_Top,AnimRate=1.0,AnimTween=0.1,AnimLoop=true)
    CrouchIdleAnim=(AnimSeq=T_CrchIdle_GenGun,AnimChan=WAC_Top,AnimRate=1.0,AnimTween=0.1,AnimLoop=true)
    CrouchWalkAnim=(AnimSeq=A_CrchWalk_GenGun,AnimChan=WAC_All,AnimRate=1.0,AnimTween=0.1,AnimLoop=true)
    CrouchFireAnim=(AnimSeq=T_CrchFire_GenGun,AnimChan=WAC_Top,AnimRate=1.0,AnimTween=0.1,AnimLoop=false)

	CrosshairIndex=5

	SwitchSound1=sound'dnsWeapn.Bombs.MultiBombSw07'
	SwitchSound2=sound'dnsWeapn.Bombs.MBThumbSw01a'
}
