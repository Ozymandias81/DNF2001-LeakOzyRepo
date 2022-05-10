/*-----------------------------------------------------------------------------
	Flamethrower
	Author: Brandon Reinhart

Multiplayer notes:

	In order to make sure all flamethrowers had proper damage effects I'm
	always ensuring they have a DamageFlame that shoots from the player's view.
	However, for third person visual effects I spawn a weapon mounted system.
	This might not be a performance optimal approach.

	Fire:
	The nozzle flame is client side and either mounted to the front of the gun, 
	or upated into the player's view depending on whether the player is being 
	viewed by third or first person respectively.

	Firewall:
	Projectile is normal, rest is all clientside.

	Gas:
	The spray and the cloud are split into two systems.  Cloud is spawned
	on the server and replicated.  The spray behaves like the nozzle flame.

-----------------------------------------------------------------------------*/
class Flamethrower extends dnWeapon;

#exec OBJ LOAD FILE=..\Meshes\c_dnWeapon.dmx
#exec OBJ LOAD FILE=..\Sounds\dnsWeapn.dfx
#exec OBJ LOAD FILE=..\Textures\m_dnWeapon.dtx

// Additional animations.
var(Animation) WAMEntry				SAnimActivateGas[4];
var(Animation) WAMEntry				SAnimDeactivateGas[4];
var(Animation) WAMEntry				SAnimTurnPilotLightOn[4];
var(Animation) WAMEntry				SAnimTurnPilotLightOff[4];
var(Animation) WAMEntry				SAnimIdleSmallGas[4];
var(Animation) WAMEntry				SAnimFireStartGas[4];
var(Animation) WAMEntry				SAnimFireStopGas[4];
var(Animation) WAMEntry				SAnimFireGas[4];

var bool bIdleNextFrame;

// Multiple mesh support.
var	mesh PlayerViewMesh2;
var bool bSwapMeshNextTick;

// Flamethrower particle systems.
var SoftParticleSystem NozzleFlame, DamageFlame, GasSpawner;
var bool bFlameOn, bCanUnfire;
var vector EffectOffset, NozzleOffset, ShrunkenNozzleOffset;

var sound LighterFlick, LighterClose, PilotBurn, BarrelOpen, BarrelClose, BlowOut, DryFireSound, FireFlameSound;



/*-----------------------------------------------------------------------------
	Object
-----------------------------------------------------------------------------*/

// Destroy any allocated subobjects.
simulated function Destroyed()
{
	if ( Owner != None )
	{
		Owner.StopSound( SLOT_Talk );
		Owner.StopSound( SLOT_Pain );
		Owner.StopSound( SLOT_Interface );
	}

	if ( NozzleFlame != None )
	{
		NozzleFlame.Destroy();
		NozzleFlame = None;
	}
	if ( DamageFlame != None )
	{
		DamageFlame.Destroy();
		DamageFlame = None;
	}

	Super.Destroyed();
}

/*-----------------------------------------------------------------------------
	Cannibal notifications.
-----------------------------------------------------------------------------*/

// PilotOn, Activate:
simulated function NotifyLighterFlick()
{
	if ( (Owner == None) || (Instigator == None) )
		return;
	
	Owner.PlaySound( LighterFlick, SLOT_None );
}

// PilotOn, Activate:
simulated function NotifyLighterClose()
{
	if ( (Owner == None) || (Instigator == None) )
		return;
	
	Owner.PlaySound( LighterClose, SLOT_None );
}

// PilotOn, Activate:
simulated function NotifyPilotOn()
{
	if ( (Owner == None) || (Instigator == None) )
		return;
	
	Owner.PlaySound( PilotBurn, SLOT_Talk );
}

// PilotOff, PilotOn, Activate:
simulated function NotifyCoverOpen()
{
	if ( (Owner == None) || (Instigator == None) )
		return;
	
	Owner.PlaySound( BarrelOpen, SLOT_None );
}

// PilotOff, PilotOn, Activate:
simulated function NotifyCoverClose()
{
	if ( (Owner == None) || (Instigator == None) )
		return;
	
	Owner.PlaySound( BarrelClose, SLOT_None );
}

// PilotOff:
simulated function NotifyPilotBlow()
{
	if ( (Owner == None) || (Instigator == None) )
		return;
	
	Owner.PlaySound( BlowOut, SLOT_None );
	Owner.StopSound( SLOT_Talk );
}


/*-----------------------------------------------------------------------------
	Firing
	Only firing mode 0 is enabled for now.
-----------------------------------------------------------------------------*/

simulated function bool ClientFire()
{
	if ( (AmmoType.AmmoMode == 1) && (AmmoType.GetModeAmmo() < 20) )
	{
		PlayOwnedSound( DryFireSound );
		return false;
	}

	if ( (AmmoType.AmmoMode == 2) && (AmmoType.GetModeAmmo() < 5) )
	{
		PlayOwnedSound( DryFireSound );
		return false;
	}

	if ( Owner.Region.Zone.bWaterZone )
	{
		PlayOwnedSound( DryFireSound );
		return false;
	}

	return Super.ClientFire();
}

// Main firing function.
function Fire()
{
	local Projectile Proj;
	local vector X, Y, Z;

	if ( (AmmoType.AmmoMode == 1) && (AmmoType.GetModeAmmo() < 20) )
	{
		PlayOwnedSound( DryFireSound );
		if ( Owner.IsA('PlayerPawn') )
			PlayerPawn(Owner).bFire = 0;
		return;
	}

	if ( (AmmoType.AmmoMode == 2) && (AmmoType.GetModeAmmo() < 5) )
	{
		PlayOwnedSound( DryFireSound );
		if ( Owner.IsA('PlayerPawn') )
			PlayerPawn(Owner).bFire = 0;
		return;
	}

	if ( Owner.Region.Zone.bWaterZone )
	{
		PlayOwnedSound( DryFireSound );
		if ( Owner.IsA('PlayerPawn') )
			PlayerPawn(Owner).bFire = 0;
		return;
	}

	// Do firing animation & firing state.
	bAltFiring = false;
	GotoState('Firing');
	StartFiring();
	ClientFire();

	if ( (AmmoType.AmmoMode == 1) && (AmmoType.GetModeAmmo() >= 20) )
	{
		// Reduce ammo count.
		AmmoType.UseAmmo(20);

		// Launch the firewall projectile.
		if ( ThirdPersonScale < 0.5 )
			Proj = ProjectileFire( class'FireWallBombShrunk', ProjectileSpeed, false, FireOffset );
		else
			Proj = ProjectileFire( ProjectileClass, ProjectileSpeed, false, FireOffset );

		// Calculate the bomb's speed.
		GetAxes( Pawn(Owner).ViewRotation, X, Y, Z );	
		Proj.Speed = 300;
		Proj.Velocity = X * (Owner.Velocity Dot X)*0.4 + Vector(Proj.Rotation) * (Proj.Speed + FRand() * 100);
		Proj.Velocity.Z += 50;
		Proj.Instigator = Instigator;
	}
}

// This weapon never plays a reload anim, we draw ammo from a tank.
simulated function bool GottaReload()
{
	return false;
}



/*-----------------------------------------------------------------------------
	Weapon Effects
-----------------------------------------------------------------------------*/

// Handles weapon impulse events.
simulated function WeaponStateChanges()
{
    if ( bNetOwner || Role == ROLE_Authority )
        return;

	if ( WeaponState == LastWeaponState )
		return; // Only do this stuff if the weapon state has changed.

    switch ( WeaponState )
    {
    case WS_FIRE:
        if ( WeaponFireImpulse != LastWeaponFireImpulse )  // Only do effect if the impulse has updated
        {
			ClientSideEffects();

			if ( !bFlameOn && (SpecialFireCode == 0) )
			{
				// Non controlling remote client fire stream on.
				SpawnNozzleFlame();
				ToggleFlame( NozzleFlame );
			}
			else if ( SpecialFireCode == 1 )
			{
				// Non controlling remote client gas effects.
				SpawnGas();
			}

            LastWeaponFireImpulse = WeaponFireImpulse;
        }
        break;
	case WS_FIRE_STOP:
	case WS_IDLE_SMALL:
	case WS_IDLE_LARGE:
		if ( bFlameOn && (SpecialFireCode == 0) )
		{
			// Non controlling remote client fire stream off.
			ToggleFlame( NozzleFlame );
		}
		break;
    default:
        break;
    }

    LastWeaponState = WeaponState;
}

// The damage flame is the version of the flame system that does damage.
// It only exists on the server and is never visible.
function SpawnDamageFlame()
{
	local vector FlameOffset, X, Y, Z;

	if ( DamageFlame != None )
	{
		if ( (ThirdPersonScale < 0.5) && (DamageFlame.Class == class'dnFlamethrowerFX_Shrunk_NozzleFlame') )
			return;
		else if ( DamageFlame.Class == class'dnFlamethrowerFX_NozzleFlame' )
			return;
		DamageFlame.Destroy();
	}

	GetAxes( Pawn(Owner).ViewRotation, X, Y, Z );
	FlameOffset = Owner.Location + CalcDrawOffset() + NozzleOffset.X*X + NozzleOffset.Y*Y + NozzleOffset.Z*Z;
	if ( ThirdPersonScale < 0.5 )
		DamageFlame = spawn( class'dnFlamethrowerFX_Shrunk_NozzleFlame',,, FlameOffset );
	else
		DamageFlame = spawn( class'dnFlamethrowerFX_NozzleFlame',,, FlameOffset );
	DamageFlame.CollisionInstigator = Pawn(Owner);
	DamageFlame.InheritVelocityActor = Owner;
	DamageFlame.SetOnlyOwnerSee( true );
}

// The nozzle flame is used for the visual side of things and may be updated like the damage flame
// or, in third person, mounted to the tip of the gun.
simulated function SpawnNozzleFlame()
{
	local vector FlameOffset, X, Y, Z;

	if ( NozzleFlame != None )
	{
		if ( (ThirdPersonScale < 0.5) && (NozzleFlame.Class == class'dnFlamethrowerFX_Shrunk_NozzleFlame') )
			return;
		else if ( NozzleFlame.Class == class'dnFlamethrowerFX_NozzleFlame' )
			return;
		NozzleFlame.Destroy();
	}

	// Mount the muzzle anchor if we haven't yet.
	MountMuzzleAnchor();

	GetAxes( Pawn(Owner).ViewRotation, X, Y, Z );
	if ( (ThirdPersonScale < 0.5) )
	{
		FlameOffset = Owner.Location + CalcDrawOffset() + ShrunkenNozzleOffset.X*X + ShrunkenNozzleOffset.Y*Y + ShrunkenNozzleOffset.Z*Z;
		NozzleFlame = spawn( class'dnFlamethrowerFX_Shrunk_NozzleFlame',,, FlameOffset );
	}
	else
	{
		FlameOffset = Owner.Location + CalcDrawOffset() + NozzleOffset.X*X + NozzleOffset.Y*Y + NozzleOffset.Z*Z;
		NozzleFlame = spawn( class'dnFlamethrowerFX_NozzleFlame',,, FlameOffset );
	}
	NozzleFlame.CollisionInstigator = Pawn(Owner);
	NozzleFlame.InheritVelocityActor = Owner;
	NozzleFlame.UseParticleCollisionActors = false;
	bFlameOn = false;

	if ( !Pawn(Owner).IsLocallyControlled() )
	{
		NozzleFlame.SetPhysics( PHYS_MovingBrush );
		NozzleFlame.AttachActorToParent( MuzzleAnchor, true, true );
		NozzleFlame.MountOrigin.Z += 8;
	}
}

// Toggles a flame on and off.
simulated function ToggleFlame( SoftParticleSystem inFlame )
{
	if ( inFlame != None )
	{
		inFlame.Trigger( Self, None );
		if ( inFlame == NozzleFlame )
			bFlameOn = !bFlameOn;
	}

	if ( bFlameOn )
	{
		Owner.PlaySound( FireFlameSound, SLOT_Pain, 0.75, true );
		Owner.PlaySound( FireFlameSound, SLOT_Interface, 0.75, true );
	}
	else
	{
		Owner.StopSound( SLOT_Pain );
		Owner.StopSound( SLOT_Interface );
	}
}

// Updates a flame's origin offset.
simulated function UpdateFlame( float DeltaTime, SoftParticleSystem inFlame )
{
	local vector X, Y, Z, FlameOffset;

	// Update the flame's location.
	GetAxes( Pawn(Owner).ViewRotation, X, Y, Z );
	if ( ThirdPersonScale < 0.5 )
		FlameOffset = Owner.Location + CalcDrawOffset() + ShrunkenNozzleOffset.X*X + ShrunkenNozzleOffset.Y*Y + ShrunkenNozzleOffset.Z*Z;
	else
		FlameOffset = Owner.Location + CalcDrawOffset() + NozzleOffset.X*X + NozzleOffset.Y*Y + NozzleOffset.Z*Z;
	inFlame.SetLocation( FlameOffset );
	inFlame.SetRotation( Pawn(Owner).ViewRotation );
}

// Spray gas out into the world.
// Might be called on non controlling remote clients where Instigator is null.
simulated function SpawnGas()
{
	local vector GasOffset, X, Y, Z;

	if ( GasSpawner != None )
		GasSpawner.Destroy();

	GetAxes( Pawn(Owner).ViewRotation, X, Y, Z );
	GasOffset = Owner.Location + CalcDrawOffset() + EffectOffset.X*X + EffectOffset.Y*Y + EffectOffset.Z*Z;
	if ( ThirdPersonScale < 0.5 )
		GasSpawner = spawn( class'dnGasMineFX_Shrunk_Spawner',,, GasOffset );
	else
		GasSpawner = spawn( class'dnGasMineFX_Spawner',,, GasOffset );
	if ( !Pawn(Owner).IsLocallyControlled() )
	{
		GasSpawner.SetPhysics( PHYS_MovingBrush );
		GasSpawner.AttachActorToParent( MuzzleAnchor, true, true );
		GasSpawner.MountOrigin.Z += 4;
	}
	if ( Role == ROLE_Authority )
	{
		if ( ThirdPersonScale < 0.5 )
		{
			GasOffset = Owner.Location + CalcDrawOffset() + (EffectOffset.X+30.0)*X + EffectOffset.Y*Y + (EffectOffset.Z+30.0)*Z;
			spawn( class'dnGasMineFX_Shrunk_FadeIn', Instigator,, GasOffset );
		}
		else
		{
			GasOffset = Owner.Location + CalcDrawOffset() + (EffectOffset.X+96.0)*X + EffectOffset.Y*Y + (EffectOffset.Z+96.0)*Z;
			spawn( class'dnGasMineFX_FadeIn', Instigator,, GasOffset );
		}
	}
}

// Update the location of the gas emission.
simulated function UpdateGas( float DeltaTime )
{
	local vector X, Y, Z, GasOffset;

	// Update the gas spawner's location.
	GetAxes( Instigator.ViewRotation, X, Y, Z );
	GasOffset = Instigator.Location + CalcDrawOffset() + EffectOffset.X*X + EffectOffset.Y*Y + EffectOffset.Z*Z;
	GasSpawner.SetLocation( GasOffset );
	GasSpawner.SetRotation( Instigator.ViewRotation );
}

// Per-frame update, updates the position of the first-person effects.
simulated function Tick( float DeltaTime )
{
	if ( Instigator != None )
	{
		if ( Role == ROLE_Authority )
		{
			if ( DamageFlame != None )
				UpdateFlame( DeltaTime, DamageFlame );
		}
		if ( Instigator.IsLocallyControlled() )
		{
			if ( NozzleFlame != None )
				UpdateFlame( DeltaTime, NozzleFlame );
			if ( GasSpawner != None )
				UpdateGas( DeltaTime );
		}
	}

	Super.Tick( DeltaTime );
}

simulated event ZoneChange( ZoneInfo NewZone )
{
	if ( NewZone.bWaterZone )
	{
		AmmoType.AmmoMode = 2;
		bBurning = false;
		SetCollision( bBurning, bBlockActors, bBlockPlayers );
		if ( (AnimSequence == 'IdleA') || (AnimSequence == 'IdleB') )
			WpnIdle();
	}
}



/*-----------------------------------------------------------------------------
	Ammo
-----------------------------------------------------------------------------*/

// Cycles through the ammo modes.
simulated function CycleAmmoMode( optional bool bFast )
{
	local int OldAmmoMode;

	if ( Owner.Region.Zone.bWaterZone )
		return;

	// Keep our old ammo mode.
	OldAmmoMode = AmmoType.AmmoMode;

	// Call parent.
	Super.CycleAmmoMode( bFast );

	// Check to see if we need to toggle the pilot light.
	if ( (OldAmmoMode == 2) && (AmmoType.AmmoMode != 2) )
		GotoState('TurnPilotLightOn');
	else if ( (OldAmmoMode != 2) && (AmmoType.AmmoMode == 2) )
		GotoState('TurnPilotLightOff');
}

function UpdateAmmoMode( int NewAmmoMode )
{
	Super.UpdateAmmoMode( NewAmmoMode );

	if ( NewAmmoMode == 2 )
		bBurning = false;
	else
	{
		bBurning = true;
		bProjTarget = false;
	}
	SetCollision( bBurning, bBlockActors, bBlockPlayers );
}


/*-----------------------------------------------------------------------------
	Animation System.
-----------------------------------------------------------------------------*/

// Animation played as we bring up the weapon.
simulated function WpnActivate()
{
	local WAMEntry entry;

	if ( (AmmoType.AmmoMode == 2) || bFastActivate )
	{
		bBurning = false;
		SetCollision( bBurning, bBlockActors, bBlockPlayers );
		ActiveWAMIndex = GetRandomWAMEntry(SAnimActivateGas, entry);
	}
	else
	{
		bBurning = true;
		bProjTarget = false;
		SetCollision( bBurning, bBlockActors, bBlockPlayers );
		ActiveWAMIndex = GetRandomWAMEntry(SAnimActivate, entry);
	}
	if (bFastActivate)
		entry.AnimRate *= 10;
	ThirdPersonScale = 1.0;
	bFastActivate = false;
	bHideWeapon = false;
	PlayWAMEntry(entry, true, 'None');

    if ( !bDontPlayOwnerAnimation )
        Pawn(Owner).WpnPlayActivate();

    WeaponState = WS_ACTIVATE;
    bDontPlayOwnerAnimation=false;
}

// Controls animation played when the weapon goes down.
simulated function WpnDeactivated()
{
	local WAMEntry entry;

	if ( AmmoType.AmmoMode != 2 )
		ActiveWAMIndex = GetRandomWAMEntry(SAnimDeactivate, entry);
	else
		ActiveWAMIndex = GetRandomWAMEntry(SAnimDeactivateGas, entry);
	PlayWAMEntry(entry, true, 'Activate');
	bBurning = false;
	
    if ( Pawn(Owner) != None )
	{
		if ( !bDontPlayOwnerAnimation )
			Pawn(Owner).WpnPlayDeactivated();
	}

    WeaponState = WS_DEACTIVATED;
    bDontPlayOwnerAnimation=false;
}

// Idle animation.
simulated function WpnIdleSmall()
{
	local WAMEntry entry;

	if ( AmmoType.AmmoMode != 2 )
		ActiveWAMIndex = GetRandomWAMEntry( SAnimIdleSmall, entry );
	else
		ActiveWAMIndex = GetRandomWAMEntry( SAnimIdleSmallGas, entry );
    PlayWAMEntry( entry, false, 'None' );
    WeaponState = WS_IDLE_SMALL;
}

simulated function WpnIdleLarge()
{
	WpnIdleSmall();
}

// Animation function for turning on the pilot light.
simulated function WpnTurnPilotLightOn()
{
	local WAMEntry entry;

	bBurning = true;
	bProjTarget = false;
	SetCollision( bBurning, bBlockActors, bBlockPlayers );
	ActiveWAMIndex = GetRandomWAMEntry(SAnimTurnPilotLightOn, entry);
    PlayWAMEntry(entry, false, 'None');
    WeaponState = WS_IDLE_SMALL;
}

// Animation function for turning off the pilot light.
simulated function WpnTurnPilotLightOff()
{
	local WAMEntry entry;

	// Stop the pilot light sound.
	Owner.StopSound( SLOT_Talk );

	bBurning = false;
	SetCollision( bBurning, bBlockActors, bBlockPlayers );
	ActiveWAMIndex = GetRandomWAMEntry(SAnimTurnPilotLightOff, entry);
    PlayWAMEntry(entry, false, 'None');
    WeaponState = WS_IDLE_SMALL;
}

// Played at the start of firing.
simulated function WpnFireStart( optional bool noWait )
{
	local WAMEntry entry;
	if ( AmmoType.AmmoMode != 2 )
		ActiveWAMIndex = GetRandomWAMEntry( SAnimFireStart, entry );
	else
		ActiveWAMIndex = GetRandomWAMEntry( SAnimFireStartGas, entry );
	PlayWAMEntry( entry, !noWait, 'None' );
	
    if ( !bDontPlayOwnerAnimation )
        Pawn(Owner).WpnPlayFireStart();

    WeaponState = WS_FIRE_START;
    bDontPlayOwnerAnimation = false;
}

// Played at the middle of firing.
simulated function WpnFire( optional bool noWait )
{
	local WAMEntry entry;

	// Play the animation.
	if ( AmmoType.AmmoMode == 0 )
	{
		SpecialFireCode = 0;
		ActiveWAMIndex = GetRandomWAMEntry( SAnimFire, entry );
	}
	else
	{
		SpecialFireCode = 1;
		ActiveWAMIndex = GetRandomWAMEntry( SAnimFireGas, entry );
	}
	PlayWAMEntry( entry, !noWait, 'None' );

    if ( !bDontPlayOwnerAnimation )
        Pawn(Owner).WpnPlayFire();

    WeaponState = WS_FIRE;
    WeaponFireImpulse++; // Increment the fire Impulse so the clients know that this weapon has fired

	// Do client side effects that are animation driven.
	ClientSideEffects();
    bDontPlayOwnerAnimation=false;
}

// Played at the end of firing.
simulated function WpnFireStop( optional bool noWait )
{
	local WAMEntry entry;
	if ( AmmoType.AmmoMode != 2 )
		ActiveWAMIndex = GetRandomWAMEntry( SAnimFireStop, entry );
	else
		ActiveWAMIndex = GetRandomWAMEntry( SAnimFireStopGas, entry );
	PlayWAMEntry( entry, !noWait, 'None' );
	
    if ( !bDontPlayOwnerAnimation )
        Pawn(Owner).WpnPlayFireStop();

    WeaponState = WS_FIRE_STOP;
    bDontPlayOwnerAnimation = false;
}



/*-----------------------------------------------------------------------------
	States.
-----------------------------------------------------------------------------*/

// State entered when the weapon comes up.
state Active
{
	// Called when the state is entered.
	simulated function BeginState()
	{
		if ( (AmmoType.AmmoMode == 2) || bFastActivate )
			Mesh = default.PlayerViewMesh2;
		else
			Mesh = default.PlayerViewMesh;
		Super.BeginState();
	}

	// Played when an animation ends.
	// In this case, it is played when the activate animation ends.
	// In order to idle correctly, because of the mesh change, we have to delay a frame.
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
		bIdleNextFrame = true;
	}

	// Monitor for mode change.
	simulated function Tick( float Delta )
	{
		Super.Tick( Delta );

		if ( bIdleNextFrame )
			GotoState('Idle');
	}

	// Called when the state is exited.
	simulated function EndState()
	{
		Mesh = default.PlayerViewMesh2;
		Super.EndState();
	}
}

// State entered while we turn the pilot light on.
state TurnPilotLightOn
{
	ignores Fire;

	simulated function bool ClientFire()
	{
		// Can't interrupt.
		return false;
	}

	simulated function bool ClientAltFire()
	{
		// Can't interrupt.
		return false;
	}

	// Per frame update.
	simulated function Tick( float Delta )
	{
		Global.Tick( Delta );

		// We need to switch meshes.
		// We do this here because we can't during an anim end.
		if ( bSwapMeshNextTick )
		{
			Mesh = default.PlayerViewMesh2;
			GotoState('Idle');
			bSwapMeshNextTick = false;
		}
	}

	// Called when the animation ends, we need to swap meshes.
	simulated function AnimEnd()
	{
		bSwapMeshNextTick = true;
	}

	// Called when the state is entered.
	simulated function BeginState()
	{
		Mesh = default.PlayerViewMesh;
		WpnTurnPilotLightOn();
	}
}

// State entered when turning the pilot light off.
state TurnPilotLightOff
{
	ignores Fire;

	simulated function bool ClientFire()
	{
		// Can't interrupt.
		return false;
	}

	simulated function bool ClientAltFire()
	{
		// Can't interrupt.
		return false;
	}

	// Per frame update.
	simulated function Tick( float Delta )
	{
		Global.Tick( Delta );

		// We need to switch meshes.
		// We do this here because we can't during an anim end.
		if ( bSwapMeshNextTick )
		{
			Mesh = default.PlayerViewMesh2;
			GotoState('Idle');
			bSwapMeshNextTick = false;
		}
	}

	// Called when the animation ends, we need to swap meshes.
	simulated function AnimEnd()
	{
		bSwapMeshNextTick = true;
	}

	// Called when the state is entered.
	simulated function BeginState()
	{
		Mesh = default.PlayerViewMesh;
		WpnTurnPilotLightOff();
	}
}

// This is the firing state.
state Firing
{
	function UnFire()
	{
		if ( bCanUnfire && (AmmoType.AmmoMode == 0) && (FireAnimSentry != AS_Stop) )
			AnimFireStop();
	}

	simulated event ZoneChange( ZoneInfo NewZone )
	{
		if ( NewZone.bWaterZone && (FireAnimSentry != AS_Stop) )
			UnFire();
	}

	simulated function AnimFire()
	{
		FireAnimSentry = AS_Middle;
		if ( AmmoType.AmmoMode == 1 )
			WpnAltFire();
		else
			WpnFire();

		if ( !bFlameOn && (AmmoType.AmmoMode == 0) )
		{
			ToggleFlame( DamageFlame );
			ToggleFlame( NozzleFlame );
		}
		else if ( AmmoType.AmmoMode == 2 )
		{
			AmmoType.UseAmmo(5);
			SpawnGas();
		}
	}

	simulated function AnimFireStop()
	{
		FireAnimSentry = AS_Stop;
		if ( bAltFiring )
			WpnAltFireStop();
		else
			WpnFireStop();

		if ( (AmmoType.AmmoMode == 0) && bFlameOn )
		{
			SetTimer( 0.0, false );

			ToggleFlame( DamageFlame );
			ToggleFlame( NozzleFlame );
		}
	}

	simulated function AnimEnd()
	{
		if ( FireAnimSentry == AS_Start )
		{
			bCanUnfire = false;
			AnimFire();
			if ( AmmoType.AmmoMode == 0 )
			{
				SetTimer( 0.3, true );
				AmmoLoaded--;
				AmmoType.UseAmmo(1);
			}
		}
		else if ( FireAnimSentry == AS_Middle )
		{
			bCanUnfire = true;
			if ( CanFire() && (AmmoType.AmmoMode == 0) )
			{
				if ( ButtonFire() )
				{
					AnimFire();
					return;
				}
				else if ( ButtonAltFire() )
				{
					ChooseAltFire();
					return;
				}
			}

			if ( HasFireStop() && (AmmoType.AmmoMode != 1) )
				AnimFireStop();
			else
				FinishFire();
		}
		else if ( FireAnimSentry == AS_Stop )
			FinishFire();
	}

	simulated function Timer( optional int TimerNum )
	{
		if ( (TimerNum == 0) && (AmmoType.AmmoMode == 0) )
		{
			if ( AmmoLoaded == 0 )
			{
				AnimFireStop();
			}
			else
			{
				AmmoType.UseAmmo(1);
				AmmoLoaded--;
			}
		}
		Global.Timer( TimerNum );
	}

	simulated function StartFiring()
	{
		SpawnDamageFlame();
		SpawnNozzleFlame();

		if ( HasFireStart() && (AmmoType.AmmoMode != 1 ) )
			AnimFireStart();
		else
			AnimFire();
	}
}

// The reloading state.
state Reloading
{
	// Pass through to idle.
	simulated function BeginState()
	{
		GotoState('Idle');
	}

	// Do nothing on exit.
	simulated function EndState()
	{
	}
}



defaultproperties
{
    SAnimIdleSmall(0)=(AnimSeq=IdleA,AnimRate=1.000000,AnimTween=0.000000,AnimChance=0.5)
	SAnimIdleSmall(1)=(AnimSeq=IdleB,AnimRate=1.000000,AnimTween=0.000000,AnimChance=0.5)
    SAnimIdleLarge(0)=(AnimSeq=IdleA,AnimRate=1.000000,AnimTween=0.000000,AnimChance=1.0)
    SAnimFireStart(0)=(AnimChance=1.000000,animSeq=FireStart,AnimRate=1.000000,AnimSound=sound'dnsWeapn.Flamethrower.FTBarrelSlide')
    SAnimFireStop(0)=(AnimChance=1.000000,animSeq=FireStop,AnimRate=1.000000,AnimSound=sound'dnsWeapn.Flamethrower.FTBarrelSlide')
    SAnimFire(0)=(AnimChance=1.000000,animSeq=Fire,AnimRate=1.000000)
    SAnimAltFire(0)=(AnimChance=1.000000,animSeq=AltFire,AnimRate=1.000000)
    SAnimActivateGas(0)=(AnimChance=1.000000,animSeq=ActivateGas,AnimRate=1.000000)
    SAnimDeactivateGas(0)=(AnimChance=1.000000,animSeq=DeactivateGas,AnimRate=1.000000)
    SAnimTurnPilotLightOn(0)=(AnimChance=1.000000,animSeq=PilotOn,AnimRate=1.000000)
    SAnimTurnPilotLightOff(0)=(AnimChance=1.000000,animSeq=PilotOff,AnimRate=1.000000)
    SAnimIdleSmallGas(0)=(AnimSeq=IdleAGas,AnimRate=1.000000,AnimTween=0.000000,AnimChance=0.5)
	SAnimIdleSmallGas(1)=(AnimSeq=IdleBGas,AnimRate=1.000000,AnimTween=0.000000,AnimChance=0.5)
	SAnimFireStartGas(0)=(AnimChance=1.000000,animSeq=FireStartGas,AnimRate=1.000000,AnimSound=sound'dnsWeapn.Flamethrower.FTBarrelOpen')
	SAnimFireStopGas(0)=(AnimChance=1.000000,animSeq=FireStopGas,AnimRate=1.000000,AnimSound=sound'dnsWeapn.Flamethrower.FTBarrelClose')
	SAnimFireGas(0)=(AnimChance=1.000000,animSeq=FireGas,AnimRate=0.700000,AnimSound=sound'dnsWeapn.Flamethrower.FTGasRelease')
	bFireStart=true
	bFireStop=true
	bNoShake=true

    PlayerViewMesh=Mesh'c_dnWeapon.Flamethrower_H'
    PlayerViewMesh2=Mesh'c_dnWeapon.Flamethrower'
    PickupViewMesh=Mesh'c_dnWeapon.w_flamethrower'
    Mesh=Mesh'c_dnWeapon.w_flamethrower'
    ThirdPersonMesh=Mesh'c_dnWeapon.w_flamethrower'
	AnimSequence=Activate

	AltAmmoItemClass=class'HUDIndexItem_FlamethrowerAlt'
	AmmoItemClass=class'HUDIndexItem_Flamethrower'

	bMultiMode=true
	AmmoName=class'dnGame.ChainsawFuel'
	ReloadCount=200
	PickupAmmoCount(0)=50
	bReloadOnModeChange=false

	CollisionHeight=8
	PlayerViewScale=0.1
    PlayerViewOffset=(X=1.3,Y=0.3,Z=-6.9)

    Icon=texture'hud_effects.mitem_flamethro'
	PickupIcon=texture'hud_effects.am_flamethrow'

    dnInventoryCategory=3
	dnCategoryPriority=1

	ItemName="Flamethrower"

	NozzleOffset=(X=25.0,Y=5.5,Z=-16.0)
	ShrunkenNozzleOffset=(X=5.0,Y=1.7,Z=-8.0)
	EffectOffset=(X=25.0,Y=6.0,Z=-18.0)
	FireOffset=(X=15.0,Y=-6.0,Z=-60.0)
	ProjectileClass=class'FireWallBomb'

	AltMuzzleFlashSprites(0)=texture't_firefx.firespray.flamehotend1RC'
	AltNumFlashSprites=1
	AltSpriteFlashX=330.0
	AltSpriteFlashY=260.0
	AltMuzzleFlashScale=2.3
	UseAltSpriteFlash=true
	AltMuzzleFlashLength=0.12
	bAltMuzzleFlashRotates=false
	AutoSwitchPriority=11

	LighterFlick=sound'dnsWeapn.Flamethrower.FTLighterOpen'
	LighterClose=sound'dnsWeapn.Flamethrower.FTLighterClose'
	PilotBurn=sound'dnsWeapn.Flamethrower.FTPilotBurnLp'
	BarrelOpen=sound'dnsWeapn.Flamethrower.FTBarrelOpen'
	BarrelClose=sound'dnsWeapn.Flamethrower.FTBarrelClose'
	BlowOut=sound'dnsWeapn.Flamethrower.FTBlowOut'
	bUseMuzzleAnchor=true
	DryFireSound=sound'dnsWeapn.foley.DryFire01'
	FireFlameSound=sound'dnsWeapn.Flamethrower.FTFire'
    
	FireStartAnim=(AnimSeq=T_Gen2HandFire,AnimChan=WAC_Top,AnimRate=1.0,AnimTween=0.2,AnimLoop=false)    
	FireAnim=(AnimSeq=T_Gen2HandFireLoop,AnimChan=WAC_Top,AnimRate=1.0,AnimTween=0.2,AnimLoop=true)	
    IdleAnim=(AnimSeq=T_Gen2HandIdle,AnimChan=WAC_Top,AnimRate=1.0,AnimTween=0.1,AnimLoop=true)
}