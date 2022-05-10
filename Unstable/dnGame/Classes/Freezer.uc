/*-----------------------------------------------------------------------------
	Freezer
	Author: Brandon Reinhart

	"Goodnight, sweet prince."
-----------------------------------------------------------------------------*/
class Freezer expands dnWeapon;

var SoftParticleSystem NozzleStream, DamageStream;
var bool bStreamOn;

var sound DryFireSound;

/*-----------------------------------------------------------------------------
	Object
-----------------------------------------------------------------------------*/

simulated function Destroyed()
{
	if ( NozzleStream != None )
	{
		NozzleStream.Destroy();
		NozzleStream = None;
	}
	if ( DamageStream != None )
	{
		DamageStream.Destroy();
		DamageStream = None;
	}

	Super.Destroyed();
}



/*-----------------------------------------------------------------------------
	Firing
-----------------------------------------------------------------------------*/

function Fire()
{
	// Do firing animation & firing state.
	bAltFiring = false;
	GotoState('Firing');
	StartFiring();
	ClientFire();
}

simulated function bool ClientAltFire()
{
	if ( AmmoType.GetModeAmmo() < 50 )
	{
		PlayOwnedSound( DryFireSound );
		return false;
	}

	return Super.ClientAltFire();
}

function AltFire()
{
	if ( AmmoType.GetModeAmmo() < 50 )
	{
		PlayOwnedSound( DryFireSound );
		return;
	}

	// Do firing animation & firing state.
	bAltFiring = true;
	GotoState('Firing');
	StartFiring();
	ClientAltFire();
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
	if ( (ReloadCount > 0) && (AmmoType.GetModeAmmo() > 0) && (AmmoLoaded < ReloadCount) )
		return true;

	// Otherwise, don't reload.
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

			if ( !bStreamOn && (SpecialFireCode == 0) )
			{
				// Non controlling remote client stream on.
				SpawnNozzleStream();
				ToggleStream( NozzleStream );
			}

            LastWeaponFireImpulse = WeaponFireImpulse;
        }
        break;
	case WS_FIRE_STOP:
	case WS_IDLE_SMALL:
	case WS_IDLE_LARGE:
		if ( bStreamOn && (SpecialFireCode == 0) )
		{
			// Non controlling remote client stream off.
			ToggleStream( NozzleStream );
		}
		break;
    default:
        break;
    }

    LastWeaponState = WeaponState;
}

// The damage stream is the version of the stream system that does damage.
// It only exists on the server and is never visible.
simulated function SpawnDamageStream()
{
	local vector FreezeOffset, X, Y, Z;

	if ( DamageStream != None )
		return;

	GetAxes( Pawn(Owner).ViewRotation, X, Y, Z );
	FreezeOffset = Owner.Location + CalcDrawOffset() + FireOffset.X*X + FireOffset.Y*Y + FireOffset.Z*Z;
	DamageStream = spawn( class'dnFreezeRayFX_NozzleStream',,, FreezeOffset );
	DamageStream.CollisionInstigator = Pawn(Owner);
	DamageStream.InheritVelocityActor = Owner;
	DamageStream.SetOnlyOwnerSee( true );
}

// The nozzle stream is used for the visual side of things and may be updated like the damage stream
// or, in third person, mounted to the tip of the gun.
simulated function SpawnNozzleStream()
{
	local vector FreezeOffset, X, Y, Z;

	if ( NozzleStream != None )
		return;

	// Mount the muzzle anchor if we haven't yet.
	MountMuzzleAnchor();

	GetAxes( Pawn(Owner).ViewRotation, X, Y, Z );
	FreezeOffset = Owner.Location + CalcDrawOffset() + FireOffset.X*X + FireOffset.Y*Y + FireOffset.Z*Z;
	NozzleStream = spawn( class'dnFreezeRayFX_NozzleStream',,, FreezeOffset );
	NozzleStream.CollisionInstigator = Pawn(Owner);
	NozzleStream.InheritVelocityActor = Owner;
	NozzleStream.UseParticleCollisionActors = false;
	bStreamOn = false;

	if ( !Pawn(Owner).IsLocallyControlled() )
	{
		NozzleStream.SetPhysics( PHYS_MovingBrush );
		NozzleStream.AttachActorToParent( MuzzleAnchor, true, true );
		NozzleStream.MountOrigin.Z += 8;
	}
}

// Toggles a stream on and off.
simulated function ToggleStream( SoftParticleSystem inStream )
{
	if ( inStream != None )
	{
//		GlobalTrigger( inStream.Tag );
		inStream.Trigger( Self, None );
		if ( inStream == NozzleStream )
			bStreamOn = !bStreamOn;
	}
}

// Updates a stream's origin offset.
simulated function UpdateStream( float DeltaTime, SoftParticleSystem inStream )
{
	local vector X, Y, Z, FreezeOffset;
	local float PressureFactor;

	// Update the flame's location.
	GetAxes( Pawn(Owner).ViewRotation, X, Y, Z );
	FreezeOffset = Owner.Location + CalcDrawOffset() + FireOffset.X*X + FireOffset.Y*Y + FireOffset.Z*Z;
	inStream.SetLocation( FreezeOffset );
	inStream.SetRotation( Pawn(Owner).ViewRotation );
}

function Tick( float DeltaTime )
{
	if ( Instigator != None )
	{
		if ( Role == ROLE_Authority )
		{
			if ( DamageStream != None )
				UpdateStream( DeltaTime, DamageStream );
		}
		if ( Instigator.IsLocallyControlled() )
		{
			if ( NozzleStream != None )
				UpdateStream( DeltaTime, NozzleStream );
		}
	}

	Super.Tick( DeltaTime );
}



/*-----------------------------------------------------------------------------
	States
-----------------------------------------------------------------------------*/

state Firing
{
	function UnFire()
	{
		if ( !bAltFiring && (FireAnimSentry != AS_Stop) )
			AnimFireStop();
	}

	simulated function AnimFireStart()
	{
		FireAnimSentry = AS_Start;
		if ( bAltFiring )
			WpnAltFireStart();
		else
			WpnFireStart();
	}

	simulated function AnimFire()
	{
		FireAnimSentry = AS_Middle;
		if ( bAltFiring )
			WpnAltFire();
		else
			WpnFire();

		if ( !bStreamOn && !bAltFiring )
		{
			ToggleStream( DamageStream );
			ToggleStream( NozzleStream );
		}

		if ( bAltFiring )
		{
			AmmoType.UseAmmo(50);
			AmmoLoaded -= 50;
			ProjectileFire( AltProjectileClass, AltProjectileSpeed, false, FireOffset );
		}
	}

	simulated function AnimFireStop()
	{
		FireAnimSentry = AS_Stop;
		if ( bAltFiring )
			WpnAltFireStop();
		else
			WpnFireStop();

		if ( bStreamOn && !bAltFiring )
		{
			SetTimer( 0.0, false );

			ToggleStream( DamageStream );
			ToggleStream( NozzleStream );
		}
	}

	simulated function AnimEnd()
	{
		if ( FireAnimSentry == AS_Start )
		{
			AnimFire();
			if ( !bAltFiring )
			{
				SetTimer( 0.07, true );
				AmmoLoaded--;
				AmmoType.UseAmmo(1);
			}
		}
		else if ( FireAnimSentry == AS_Middle )
		{
			if ( CanFire() )
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

			if ( HasFireStop() )
				AnimFireStop();
			else
				FinishFire();
		}
		else if ( FireAnimSentry == AS_Stop )
			FinishFire();
	}

	simulated function Timer( optional int TimerNum )
	{
		if ( (TimerNum == 0) && !bAltFiring )
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
		SpawnDamageStream();
		SpawnNozzleStream();
		
		Super.StartFiring();
	}
}
/*
state Idle
{
	simulated function BeginState()
	{
		if ( AmmoLoaded < ReloadCount )
			Reload();
		else
			Super.BeginState();
	}
}
*/



defaultproperties
{
    SAnimActivate(0)=(AnimChance=1.000000,animSeq=4_Activate,AnimRate=1.000000)
    SAnimDeactivate(0)=(AnimChance=1.000000,animSeq=4_Deactivate,AnimRate=1.000000)
    SAnimFire(0)=(AnimChance=1.000000,animSeq=4_Fire,AnimRate=1.000000)
	SAnimFireStart(0)=(AnimChance=1.000000,animSeq=4_FireStart,AnimRate=1.000000)
	SAnimFireStop(0)=(AnimChance=1.000000,animSeq=4_FireStop,AnimRate=1.000000)
    SAnimAltFire(0)=(AnimChance=1.000000,animSeq=4_AltFire,AnimRate=1.000000)
    SAnimAltFireStart(0)=(AnimChance=1.000000,animSeq=4_AltFireStart,AnimRate=1.000000)
	SAnimIdleSmall(0)=(AnimChance=0.5,animSeq=4_IdleA,AnimRate=1.0,AnimTween=0.1)
	SAnimIdleSmall(1)=(AnimChance=0.5,animSeq=4_IdleB,AnimRate=1.0,AnimTween=0.1)
	SAnimIdleLarge(0)=(AnimChance=1.0,animSeq=4_IdleA,AnimRate=1.0,AnimTween=0.1)
    SAnimReload(0)=(AnimChance=1.000000,animSeq=4_Pump,AnimRate=1.000000)
	SAnimReloadStart(0)=(AnimChance=1.000000,animSeq=4_PumpStart,AnimRate=1.000000)
	SAnimReloadStop(0)=(AnimChance=1.000000,animSeq=4_PumpStop,AnimRate=1.000000)

	AmmoName=class'dnGame.FreezerAmmo'
	ReloadClipAmmo=10
	ReloadCount=50
	PickupAmmoCount(0)=50
	AmmoItemClass=class'HUDIndexItem_Freezer'
	AltAmmoItemClass=class'HUDIndexItem_FreezerAlt'

	ItemName="Freeze Cannon"
	PlayerViewMesh=Mesh'c_dnWeapon.icecannon'
	PickupSound=Sound'dnGame.Pickups.WeaponPickup'
	PickupViewMesh=Mesh'c_dnWeapon.w_shrinkray'
	ThirdPersonMesh=Mesh'c_dnWeapon.w_shrinkray'
    Mesh=Mesh'c_dnWeapon.w_shrinkray'
	Icon=Texture'hud_effects.mitem_freezecannon'
    PickupIcon=texture'hud_effects.am_shinkray'

	bAltFireStart=true
	bFireStart=true
	bFireStop=true

    CollisionHeight=8.0
    dnInventoryCategory=3
    dnCategoryPriority=2
    LodMode=LOD_Disabled
    PlayerViewScale=0.1
    PlayerViewOffset=(X=1.6,Y=-0.7,Z=-7.0)

	bReloadStart=true
	bReloadStop=true

	FireOffset=(X=30.0,Y=-10.0,Z=-20.0)
	AltProjectileClass=class'IceNuke'
	AutoSwitchPriority=12

	DryFireSound=sound'dnsWeapn.foley.DryFire01'
}
