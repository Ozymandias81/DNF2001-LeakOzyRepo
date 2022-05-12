//=============================================================================
// TournamentWeapon.
//=============================================================================
class TournamentWeapon extends Weapon
	abstract;

var TournamentPickup Affector;
var float FireAdjust;
var localized string WeaponDescription;
var float InstFlash;
var vector InstFog;
var bool bCanClientFire;
var bool bForceFire, bForceAltFire;
var() float FireTime, AltFireTime; //used to synch server and client firing up
var float FireStartTime;

Replication
{
	Reliable if ( bNetOwner && (Role == ROLE_Authority) )
		Affector, bCanClientFire;
}

function ForceFire()
{
	Fire(0);
}

function ForceAltFire()
{
	AltFire(0);
}

function SetWeaponStay()
{
	if ( Level.NetMode != NM_Standalone && Level.Game.IsA('DeathMatchPlus') )
		bWeaponStay = bWeaponStay || DeathMatchPlus(Level.Game).bMultiWeaponStay;
	else		
		bWeaponStay = bWeaponStay || Level.Game.bCoopWeaponMode;
}

// Finish a firing sequence
function Finish()
{
	local Pawn PawnOwner;
	local bool bForce, bForceAlt;

	bForce = bForceFire;
	bForceAlt = bForceAltFire;
	bForceFire = false;
	bForceAltFire = false;

	if ( bChangeWeapon )
	{
		GotoState('DownWeapon');
		return;
	}

	PawnOwner = Pawn(Owner);
	if ( PawnOwner == None )
		return;
	if ( PlayerPawn(Owner) == None )
	{
		if ( (AmmoType != None) && (AmmoType.AmmoAmount<=0) )
		{
			PawnOwner.StopFiring();
			PawnOwner.SwitchToBestWeapon();
			if ( bChangeWeapon )
				GotoState('DownWeapon');
		}
		else if ( (PawnOwner.bFire != 0) && (FRand() < RefireRate) )
			Global.Fire(0);
		else if ( (PawnOwner.bAltFire != 0) && (FRand() < AltRefireRate) )
			Global.AltFire(0);	
		else 
		{
			PawnOwner.StopFiring();
			GotoState('Idle');
		}
		return;
	}
	if ( ((AmmoType != None) && (AmmoType.AmmoAmount<=0)) || (PawnOwner.Weapon != self) )
		GotoState('Idle');
	else if ( (PawnOwner.bFire!=0) || bForce )
		Global.Fire(0);
	else if ( (PawnOwner.bAltFire!=0) || bForceAlt )
		Global.AltFire(0);
	else 
		GotoState('Idle');
}

//
// Toss this item out.
//
function DropFrom(vector StartLocation)
{
	bCanClientFire = false;
	bSimFall = true;
	if ( !SetLocation(StartLocation) )
		return; 
	AIRating = Default.AIRating;
	bMuzzleFlash = 0;
	if ( AmmoType != None )
	{
		PickupAmmoCount = AmmoType.AmmoAmount;
		AmmoType.AmmoAmount = 0;
	}
	RespawnTime = 0.0; //don't respawn
	SetPhysics(PHYS_Falling);
	RemoteRole = ROLE_DumbProxy;
	BecomePickup();
	NetPriority = 2.5;
	bCollideWorld = true;
	if ( Pawn(Owner) != None )
		Pawn(Owner).DeleteInventory(self);
	Inventory = None;
	GotoState('PickUp', 'Dropped');
}

simulated function ClientPutDown(weapon NextWeapon)
{
	if ( Level.NetMode == NM_Client )
	{
		bCanClientFire = false;
		bMuzzleFlash = 0;
		TweenDown();
		if ( TournamentPlayer(Owner) != None )
			TournamentPlayer(Owner).ClientPending = NextWeapon;
		GotoState('ClientDown');
	}
}

simulated function TweenToStill()
{
	TweenAnim('Still', 0.1);
}

function BecomeItem()
{
	local Bot B;
	local Pawn P;

	Super.BecomeItem();
	B = Bot(Instigator);
	if ( (B != None) && B.bNovice && (B.Skill < 2) )
		FireAdjust = B.Skill * 0.5;
	else
		FireAdjust = 1.0;

	if ( (B != None) || Level.Game.bTeamGame || !Level.Game.IsA('DeathMatchPlus')
		|| DeathMatchPlus(Level.Game).bNoviceMode
		|| (DeathMatchPlus(Level.Game).NumBots > 4) )
		return;

	// let high skill bots hear pickup if close enough
	for ( P=Level.PawnList; P!=None; P=P.NextPawn )
	{
		B = Bot(p);
		if ( (B != None)
			&& (VSize(B.Location - Instigator.Location) < 800 + 100 * B.Skill) )
		{
			B.HearPickup(Instigator);
			return;
		}
	}
}

simulated function AnimEnd()
{
	if ( (Level.NetMode == NM_Client) && (Mesh != PickupViewMesh) )
		PlayIdleAnim();
}

simulated function ForceClientFire()
{
	ClientFire(0);
}

simulated function ForceClientAltFire()
{
	ClientAltFire(0);
}

simulated function bool ClientFire( float Value )
{
	if ( bCanClientFire && ((Role == ROLE_Authority) || (AmmoType == None) || (AmmoType.AmmoAmount > 0)) )
	{
		if ( (PlayerPawn(Owner) != None) 
			&& ((Level.NetMode == NM_Standalone) || PlayerPawn(Owner).Player.IsA('ViewPort')) )
		{
			if ( InstFlash != 0.0 )
				PlayerPawn(Owner).ClientInstantFlash( InstFlash, InstFog);
			PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
		}
		if ( Affector != None )
			Affector.FireEffect();
		PlayFiring();
		if ( Role < ROLE_Authority )
			GotoState('ClientFiring');
		return true;
	}
	return false;
}		

function Fire( float Value )
{
	if ( (AmmoType == None) && (AmmoName != None) )
	{
		// ammocheck
		GiveAmmo(Pawn(Owner));
	}
	if ( AmmoType.UseAmmo(1) )
	{
		GotoState('NormalFire');
		bPointing=True;
		bCanClientFire = true;
		ClientFire(Value);
		if ( bRapidFire || (FiringSpeed > 0) )
			Pawn(Owner).PlayRecoil(FiringSpeed);
		if ( bInstantHit )
			TraceFire(0.0);
		else
			ProjectileFire(ProjectileClass, ProjectileSpeed, bWarnTarget);
	}
}

simulated function bool ClientAltFire( float Value )
{
	if ( bCanClientFire && ((Role == ROLE_Authority) || (AmmoType == None) || (AmmoType.AmmoAmount > 0)) )
	{
		if ( (PlayerPawn(Owner) != None) 
			&& ((Level.NetMode == NM_Standalone) || PlayerPawn(Owner).Player.IsA('ViewPort')) )
		{
			if ( InstFlash != 0.0 )
				PlayerPawn(Owner).ClientInstantFlash( InstFlash, InstFog);
			PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
		}
		if ( Affector != None )
			Affector.FireEffect();
		PlayAltFiring();
		if ( Role < ROLE_Authority )
			GotoState('ClientAltFiring');
		return true;
	}
	return false;
}

function AltFire( float Value )
{
	if ( (AmmoType == None) && (AmmoName != None) )
	{
		// ammocheck
		GiveAmmo(Pawn(Owner));
	}
	if (AmmoType.UseAmmo(1))
	{
		GotoState('AltFiring');
		bPointing=True;
		bCanClientFire = true;
		ClientAltFire(Value);
		if ( bRapidFire || (FiringSpeed > 0) )
			Pawn(Owner).PlayRecoil(FiringSpeed);
		if ( bAltInstantHit )
			TraceFire(0.0);
		else
			ProjectileFire(AltProjectileClass, AltProjectileSpeed, bAltWarnTarget);
	}
}


simulated function PlaySelect()
{
	bForceFire = false;
	bForceAltFire = false;
	bCanClientFire = false;
	if ( !IsAnimating() || (AnimSequence != 'Select') )
		PlayAnim('Select',1.0,0.0);
	Owner.PlaySound(SelectSound, SLOT_Misc, Pawn(Owner).SoundDampening);	
}

simulated function PlayPostSelect()
{
	if ( Level.NetMode == NM_Client )
	{
		if ( (bForceFire || (PlayerPawn(Owner).bFire != 0)) && Global.ClientFire(0) )
			return;
		else if ( (bForceAltFire || (PlayerPawn(Owner).bAltFire != 0)) && Global.ClientAltFire(0) )
			return;
		GotoState('');
		AnimEnd();
	}
}

simulated function TweenDown()
{
	if ( IsAnimating() && (AnimSequence != '') && (GetAnimGroup(AnimSequence) == 'Select') )
		TweenAnim( AnimSequence, AnimFrame * 0.4 );
	else
		PlayAnim('Down', 1.0, 0.05);
}

simulated function PlayIdleAnim()
{
}

simulated function Landed(vector HitNormal)
{
	local rotator newRot;

	newRot = Rotation;
	newRot.pitch = 0;
	SetRotation(newRot);
}

function bool HandlePickupQuery( inventory Item )
{
	local int OldAmmo;
	local Pawn P;

	if (Item.Class == Class)
	{
		if ( Weapon(item).bWeaponStay && (!Weapon(item).bHeldItem || Weapon(item).bTossedOut) )
			return true;
		P = Pawn(Owner);
		if ( AmmoType != None )
		{
			OldAmmo = AmmoType.AmmoAmount;
			if ( AmmoType.AddAmmo(Weapon(Item).PickupAmmoCount) && (OldAmmo == 0) 
				&& (P.Weapon.class != item.class) && !P.bNeverSwitchOnPickup )
					WeaponSet(P);
		}
		P.ReceiveLocalizedMessage( class'PickupMessagePlus', 0, None, None, Self.Class );
		Item.PlaySound(Item.PickupSound);
		if (Level.Game.LocalLog != None)
			Level.Game.LocalLog.LogPickup(Item, Pawn(Owner));
		if (Level.Game.WorldLog != None)
			Level.Game.WorldLog.LogPickup(Item, Pawn(Owner));
		Item.SetRespawn();   
		return true;
	}
	if ( Inventory == None )
		return false;

	return Inventory.HandlePickupQuery(Item);
}

auto state Pickup
{
	ignores AnimEnd;

	// Landed on ground.
	simulated function Landed(Vector HitNormal)
	{
		local rotator newRot;

		newRot = Rotation;
		newRot.pitch = 0;
		SetRotation(newRot);
		if ( Role == ROLE_Authority )
		{
			bSimFall = false;
			SetTimer(2.0, false);
		}
	}
}

state ClientFiring
{
	simulated function bool ClientFire(float Value)
	{
		return false;
	}

	simulated function bool ClientAltFire(float Value)
	{
		return false;
	}

	simulated function AnimEnd()
	{
		if ( (Pawn(Owner) == None)
			|| ((AmmoType != None) && (AmmoType.AmmoAmount <= 0)) )
		{
			PlayIdleAnim();
			GotoState('');
		}
		else if ( !bCanClientFire )
			GotoState('');
		else if ( Pawn(Owner).bFire != 0 )
			Global.ClientFire(0);
		else if ( Pawn(Owner).bAltFire != 0 )
			Global.ClientAltFire(0);
		else
		{
			PlayIdleAnim();
			GotoState('');
		}
	}

	simulated function EndState()
	{
		AmbientSound = None;
	}
}

state ClientAltFiring
{
	simulated function bool ClientFire(float Value)
	{
		return false;
	}

	simulated function bool ClientAltFire(float Value)
	{
		return false;
	}
	simulated function AnimEnd()
	{
		if ( (Pawn(Owner) == None)
			|| ((AmmoType != None) && (AmmoType.AmmoAmount <= 0)) )
		{
			PlayIdleAnim();
			GotoState('');
		}
		else if ( !bCanClientFire )
			GotoState('');
		else if ( Pawn(Owner).bFire != 0 )
			Global.ClientFire(0);
		else if ( Pawn(Owner).bAltFire != 0 )
			Global.ClientAltFire(0);
		else
		{
			PlayIdleAnim();
			GotoState('');
		}
	}

	simulated function EndState()
	{
		AmbientSound = None;
	}
}

///////////////////////////////////////////////////////
state NormalFire
{
	function ForceFire()
	{
		bForceFire = true;
	}

	function ForceAltFire()
	{
		bForceAltFire = true;
	}

	function Fire(float F) 
	{
	}
	function AltFire(float F) 
	{
	}

	function AnimEnd()
	{
		Finish();
	}

Begin:
	Sleep(0.0);
}

////////////////////////////////////////////////////////
state AltFiring
{
	function Fire(float F) 
	{
	}

	function AltFire(float F) 
	{
	}

	function ForceFire()
	{
		bForceFire = true;
	}

	function ForceAltFire()
	{
		bForceAltFire = true;
	}

	function AnimEnd()
	{
		Finish();
	}

Begin:
	Sleep(0.0);
}

state Active
{
	ignores animend;

	function ForceFire()
	{
		bForceFire = true;
	}

	function ForceAltFire()
	{
		bForceAltFire = true;
	}

	function EndState()
	{
		Super.EndState();
		bForceFire = false;
		bForceAltFire = false;
	}

Begin:
	FinishAnim();
	if ( bChangeWeapon )
		GotoState('DownWeapon');
	bWeaponUp = True;
	PlayPostSelect();
	FinishAnim();
	bCanClientFire = true;
	
	if ( (Level.Netmode != NM_Standalone) && Owner.IsA('TournamentPlayer')
		&& (PlayerPawn(Owner).Player != None)
		&& !PlayerPawn(Owner).Player.IsA('ViewPort') )
	{
		if ( bForceFire || (Pawn(Owner).bFire != 0) )
			TournamentPlayer(Owner).SendFire(self);
		else if ( bForceAltFire || (Pawn(Owner).bAltFire != 0) )
			TournamentPlayer(Owner).SendAltFire(self);
		else if ( !bChangeWeapon )
			TournamentPlayer(Owner).UpdateRealWeapon(self);
	} 
	Finish();
}

State ClientActive
{
	simulated function ForceClientFire()
	{
		Global.ClientFire(0);
	}

	simulated function ForceClientAltFire()
	{
		Global.ClientAltFire(0);
	}

	simulated function bool ClientFire(float Value)
	{
		bForceFire = true;
		return bForceFire;
	}

	simulated function bool ClientAltFire(float Value)
	{
		bForceAltFire = true;
		return bForceAltFire;
	}

	simulated function AnimEnd()
	{
		if ( Owner == None )
		{
			Global.AnimEnd();
			GotoState('');
		}
		else if ( Owner.IsA('TournamentPlayer') 
			&& (TournamentPlayer(Owner).ClientPending != None) )
			GotoState('ClientDown');
		else if ( bWeaponUp )
		{
			if ( (bForceFire || (PlayerPawn(Owner).bFire != 0)) && Global.ClientFire(0) )
				return;
			else if ( (bForceAltFire || (PlayerPawn(Owner).bAltFire != 0)) && Global.ClientAltFire(0) )
				return;
			PlayIdleAnim();
			GotoState('');
		}
		else
		{
			PlayPostSelect();
			bWeaponUp = true;
		}
	}

	simulated function BeginState()
	{
		bForceFire = false;
		bForceAltFire = false;
		bWeaponUp = false;
		PlaySelect();
	}

	simulated function EndState()
	{
		bForceFire = false;
		bForceAltFire = false;
	}
}

State ClientDown
{
	simulated function ForceClientFire()
	{
		Global.ClientFire(0);
	}

	simulated function ForceClientAltFire()
	{
		Global.ClientAltFire(0);
	}

	simulated function bool ClientFire(float Value)
	{
		return false;
	}

	simulated function bool ClientAltFire(float Value)
	{
		return false;
	}

	simulated function Tick(float DeltaTime)
	{
		local TournamentPlayer T;

		T = TournamentPlayer(Owner);
		if ( !T.bNeedActivate || ((T.Weapon != self) && (T.Weapon != None)) )
			GotoState('');
	}
		
	simulated function AnimEnd()
	{
		local TournamentPlayer T;

		T = TournamentPlayer(Owner);
		if ( T != None )
		{
			if ( (T.ClientPending != None) 
				&& (T.ClientPending.Owner == Owner) )
			{
				T.Weapon = T.ClientPending;
				T.Weapon.GotoState('ClientActive');
				T.ClientPending = None;
				GotoState('');
			}
			else
			{
				Enable('Tick');
				T.NeedActivate();
			}
		}
	}

	simulated function BeginState()
	{
		Disable('Tick');
	}
}

State DownWeapon
{
ignores Fire, AltFire, AnimEnd;

	function BeginState()
	{
		Super.BeginState();
		bCanClientFire = false;
	}
}

defaultproperties
{
	bClientAnim=true
	FireAdjust=1.0
	MyDamageType=Unspecified
	AltDamageType=Unspecified
	PickupMessageClass=class'Botpack.PickupMessagePlus'
}
