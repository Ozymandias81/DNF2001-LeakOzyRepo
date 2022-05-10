/*-----------------------------------------------------------------------------
	DukeChainsaw
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class DukeChainsaw expands MeleeWeapon;

#exec OBJ LOAD FILE=..\Sounds\dnsWeapn.dfx

var(Animation) WAMEntry SAnimIdleOffSmall[4];
var(Animation) WAMEntry SAnimIdleOffLarge[4];
var(Animation) WAMEntry SAnimEngineStop[4];
var(Animation) WAMEntry SAnimEngineStart[4];
var(Animation) WAMEntry SAnimEngineStartTrouble[4];
var(Animation) WAMEntry SAnimChewFire[4];

var transient float				LargeIdleOffTimer;
var()		vector				HitOffset;
var			bool				bChewItUp;

var			sound				AttackingAmbientSound;
var			sound				IdleAmbientSound;



/*-----------------------------------------------------------------------------
	Damage & Trace
-----------------------------------------------------------------------------*/
/*
simulated function int GetHitDamage( actor Victim, name BoneName )
{
	return 3;
}

function TraceHit( vector StartTrace, vector EndTrace, Actor HitActor, vector HitLocation, 
				   vector HitNormal, int HitMeshTri, vector HitMeshBarys, name HitMeshBone, 
				   texture HitMeshTex, Actor HitInstigator, vector BeamStart )
{

	if ( HitActor != none )
	{
		ChewItUp( true );
		Super.TraceHit( StartTrace, EndTrace, HitActor, HitLocation, HitNormal, HitMeshTri, HitMeshBarys, HitMeshBone, HitMeshTex, HitInstigator, BeamStart );
	} else
		ChewItUp( false );
}

function Timer( optional int TimerNum )
{
	if ( TimerNum == 2 )
	{
		AmmoType.UseAmmo(1);
	} else
		TraceFire( Owner );
}

*/

/*-----------------------------------------------------------------------------
	Firing and Input
-----------------------------------------------------------------------------*/
/*
function Fire()
{
//	if ( (PlayerPawn(Owner) != None) && bChewItUp )
//		PlayerPawn(Owner).WeaponShake();
  
	GotoState('Firing');
}

function AltFire()
{
	GotoState('EngineStop');
}

function Activate()
{
	Super.Activate();

	LargeIdleOffTimer = Level.TimeSeconds;
}

function ChewItUp(bool ChewChew)
{
	local WAMEntry entry;

	if (ChewChew != bChewItUp)
	{
		bChewItUp = ChewChew;
		if (ChewChew && (AnimSequence != 'attackgrind'))
			AnimSequence = 'attackgrind';
		else if (AnimSequence != 'attacksolo') 
			AnimSequence = 'attacksolo';
	}
}


*/
/*-----------------------------------------------------------------------------
	Animation Notifications
-----------------------------------------------------------------------------*/
/*
function WpnFire(optional bool noWait)
{
	local WAMEntry entry;

	// Play the animation.
	if (bChewItUp)
		ActiveWAMIndex = GetRandomWAMEntry(default.SAnimChewFire, entry);
	else
		ActiveWAMIndex = GetRandomWAMEntry(default.SAnimFire, entry);
	PlayWAMEntry(entry, !noWait, 'None');
	
    if ( !bDontPlayOwnerAnimation )
        Pawn(Owner).WpnPlayFire();
    
	ClientSideEffects();
    bDontPlayOwnerAnimation = false;

	if (AmbientSound != AttackingAmbientSound)
		AmbientSound = AttackingAmbientSound;
}

function WpnEngineStart()
{
	local WAMEntry entry;
	if (FRand() < 0.1)
	{
		ActiveWAMIndex = GetRandomWAMEntry(default.SAnimEngineStartTrouble, entry);
		PlayWAMEntry(entry, true, 'None');
	} else {
		ActiveWAMIndex = GetRandomWAMEntry(default.SAnimEngineStart, entry);
		PlayWAMEntry(entry, true, 'None');
	}
}

function WpnEngineStop()
{
	local WAMEntry entry;
	ActiveWAMIndex = GetRandomWAMEntry(default.SAnimEngineStop, entry);
	PlayWAMEntry(entry, true, 'None');
}

function WpnIdleOffSmall()
{
	local WAMEntry entry;
	ActiveWAMIndex = GetRandomWAMEntry(default.SAnimIdleOffSmall, entry);
	PlayWAMEntry(entry, false, 'None');
}

function WpnIdleOffLarge()
{
	local WAMEntry entry;
	ActiveWAMIndex = GetRandomWAMEntry(default.SAnimIdleOffLarge, entry);
	PlayWAMEntry(entry, false, 'None');
}

function WpnIdleOff()
{
	WpnIdleOffSmall();
}

function WpnActivate()
{
	Super.WpnActivate();
	AmbientSound = IdleAmbientSound;
	SetTimer(1.0, true, 2);
}

function WpnDeactivated()
{
	Super.WpnDeactivated();
	AmbientSound = None;
}
*/


/*-----------------------------------------------------------------------------
	States
-----------------------------------------------------------------------------*/
/*
state Firing
{
	// Allow the weapon to interrupt firing and fire again.
	function ForceFire()
	{
		if (!GottaReload())
			Global.Fire();
	}

	function Fire() 
	{
		if (!GottaReload())
			GotoState('Firing', 'FireAgain');
	}

Begin:
	// Play the start of firing animation.
	if (bFireStart)
	{
		WpnFireStart();
		FinishAnim();
	}

	// Play the firing animation.
	SetTimer(0.1, true);
	WpnFire();
	FinishAnim();
	SetTimer(0.0, false);
	AmbientSound = IdleAmbientSound;

	// If the fire button is down, fire again.
	if ( CanFire() && ButtonFire() )
		Fire();
	else if ( CanFire() && ButtonAltFire()  )
		AltFire();
	else
	{
		// Play the end of firing animation.
		if (bFireStop)
		{
			WpnFireStop();
			FinishAnim();
		}

		// Perform end of fire l0gic.
		FinishServerFire();
	}

FireAgain:
	// Play the firing animation.
	SetTimer(0.1, true);
	WpnFire();
	FinishAnim();
	SetTimer(0.0, false);
	AmbientSound = IdleAmbientSound;

	// If the fire button is down, fire again.
	if ( CanFire() && ButtonFire() )
		Fire();
	else if ( CanFire() && ButtonAltFire()  )
		AltFire();
	else
	{
		// Play the end of firing animation.
		if (bFireStop)
		{
			WpnFireStop();
			FinishAnim();
		}

		// Perform end of fire l0gic.
		FinishServerFire();
	}
}

state ClientFiring
{
	// Allow the weapon to interrupt firing and fire again.
	simulated function bool ClientFire()
	{
		if ( CanFire() )
		{
//			bFireStartClient = true;
//			bFireClient = false;
//			bFireStopClient = false;
			return Global.ClientFire();
		} else
			return false;
	}
}

state EngineStart
{
	function ForceFire()
	{
		bForceFire = true;
	}

	function ForceAltFire()
	{
		bForceAltFire = true;
	}

	function Fire() {}

	function AltFire() {}

Begin:
    WpnEngineStart();
	SetTimer(1.0, true, 2);
	AmbientSound = IdleAmbientSound;
	GotoState('Idle');
}

state EngineStop
{
	function ForceFire()
	{
		bForceFire = true;
	}

	function ForceAltFire()
	{
		bForceAltFire = true;
	}

	function Fire() {}

	function AltFire() {}

Begin:
	AmbientSound = None;
	SetTimer(0.0, false, 2);
    WpnEngineStop();
	GotoState('IdleOff');
}

state IdleOff
{
	function ForceFire()
	{
		bForceFire = true;
	}

	function ForceAltFire()
	{
		bForceAltFire = true;
	}

	function Fire() {}

	function AltFire()
	{
		GotoState('EngineStart');
	}

	function AnimEnd()
	{
		WpnIdleOff();
	}

	function bool Deactivate()
	{
		GotoState('DownWeapon');
		return true;
	}

Begin:
	WpnIdleOff();
}
*/


defaultproperties
{
	 MeleeHitRadius=80.0
     SAnimActivate(0)=(AnimSound=Sound'dnsWeapn.chainsaw.CSawStart')
	 SAnimDeactivate(0)=(AnimSound=Sound'dnsWeapn.chainsaw.CSawStop')
     SAnimFireStart(0)=(AnimChance=1.0,animSeq=attackstart,AnimRate=1.0)
     SAnimFire(0)=(animSeq=attacksolo)
     SAnimChewFire(0)=(AnimChance=1.0,animSeq=attackgrind,AnimRate=1.0)
     SAnimFireStop(0)=(AnimChance=1.0,animSeq=attackstop,AnimRate=1.0)
     SAnimReload(0)=(animSeq=multienginestart)
     SAnimIdleSmall(0)=(AnimChance=0.200000,animSeq=idlea_on)
     SAnimIdleSmall(1)=(AnimChance=0.200000,animSeq=idleb_on)
     SAnimIdleSmall(2)=(AnimChance=0.200000,animSeq=idlec_on)
     SAnimIdleSmall(3)=(AnimChance=0.200000,animSeq=idled_on)
     SAnimIdleOffSmall(0)=(AnimChance=0.200000,animSeq=idlea_off)
     SAnimIdleOffSmall(1)=(AnimChance=0.200000,animSeq=idleb_off)
     SAnimIdleOffSmall(2)=(AnimChance=0.200000,animSeq=idlec_off)
     SAnimIdleOffSmall(3)=(AnimChance=0.200000,animSeq=idled_off)
     SAnimEngineStop(0)=(AnimChance=1.0,animSeq=enginestop,AnimRate=1.0,AnimSound=Sound'dnsWeapn.chainsaw.CSawStop')
     SAnimEngineStart(0)=(AnimChance=1.0,animSeq=enginestart,AnimRate=1.0,AnimSound=Sound'dnsWeapn.chainsaw.CSawStart')
     SAnimEngineStartTrouble(0)=(AnimChance=1.0,animSeq=multienginestart,AnimRate=1.0)

	 ItemName="Chainsaw"
     PlayerViewMesh=Mesh'c_dnWeapon.dukechainsaw'
     PickupViewMesh=Mesh'c_dnWeapon.w_chainsaw'
     ThirdPersonMesh=Mesh'c_dnWeapon.w_chainsaw'
	 Mesh=Mesh'c_dnWeapon.w_chainsaw'
     PickupSound=Sound'Duke3d.urinal.Ahmuch03'
     PlayerViewOffset=(X=2.5,Y=0.512,Z=-6.6)
     Icon=Texture'hud_effects.mitem_chainsaw'
	 PickupIcon=texture'hud_effects.am_chainsaw'
     dnInventoryCategory=0
	 dnCategoryPriority=1
	 PlayerViewScale=0.1
	 PickupViewScale=2.0
	 DrawScale=2.0
	 HitOffset=(Y=4.0,Z=-8.0)
	 bBoneDamage=true

	 IdleAmbientSound=sound'dnsWeapn.chainsaw.CSawIdleLp'
	 AttackingAmbientSound=sound'dnsWeapn.chainsaw.CSawRunLp'

	 AmmoItemClass=class'HUDIndexItem_Chainsaw'
	 AltAmmoItemClass=none

	 AmmoName=class'dnGame.ChainsawFuel'
	 PickupAmmoCount(0)=20

	 bFireStart=true
	 bFireStop=true

	 TraceHitCategory=TH_Chainsaw
	 TraceDamageType=class'ChainsawDamage'

	 CrosshairIndex=1
	 AutoSwitchPriority=2
}
