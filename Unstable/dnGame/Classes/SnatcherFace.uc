/*-----------------------------------------------------------------------------
	SnatcherFace
	Author: Jess Crable
-----------------------------------------------------------------------------*/
class SnatcherFace expands MeleeWeapon;

#exec OBJ LOAD FILE=..\Sounds\dnsWeapn.dfx

var()		vector			HitOffset;

var			sound			AttackingAmbientSound;
var			sound			IdleAmbientSound;

var()		float			MaxTimeBetween;
var			float			BetweenTime;

var()		float			TimeToRemove;
var			float			RemoveTime;

var			bool			bAttacking;
var			bool			bReEnter;
var			bool			bDisabled;

var()		int				MaxDamage;
var()		int				MinDamage;
var			class<actor>	MySnatcher;
var			actor			SpawnedSnatcher;



/*-----------------------------------------------------------------------------
	Object
-----------------------------------------------------------------------------*/

function PostBeginPlay()
{
	// Override RemoveTime with random time.
	TimeToRemove = 1 + Rand( 3 );

	Super.PostBeginPlay();
}



/*-----------------------------------------------------------------------------
	Screen Damage
-----------------------------------------------------------------------------*/

function DamageOwner()
{
	local int BiteDamage;

	BiteDamage = 6;
	
	Pawn( Owner ).TakeDamage( BiteDamage, Pawn( Owner ), Pawn( Owner ).Location, vect( 0, 0, 0 ), class'WhippedDownDamage' );
	if ( Owner.IsA( 'DukePlayer' ) )
		DukeHUD( DukePlayer( Owner ).MyHUD ).RegisterBloodSlash( 0 );
}



/*-----------------------------------------------------------------------------
	Weapon Behavior
-----------------------------------------------------------------------------*/

function Fire()
{
	if ( AnimSequence == 'Activate1' )
	{	
		Pawn( Owner ).bFire = 0;
		Pawn( Owner ).bAltFire = 0;
		return;
	}
	if ( Pawn( Owner ).bFire != 0 )
		WpnFire();
	else if ( Pawn( Owner ).bAltFire != 0 )
		WpnAltFire();	

	if ( Owner.bHidden )
	{
        if ( (Pawn(Owner).Health > 0) && (Pawn(Owner).Visibility < Pawn(Owner).Default.Visibility) )
        {
	        Owner.bHidden = false;
	        Pawn(Owner).Visibility = Pawn(Owner).Default.Visibility;
        }
	}
}

function AltFire()
{
	Fire();
}



/*-----------------------------------------------------------------------------
	Animation Notifications
-----------------------------------------------------------------------------*/

function sound GetShakeSound()
{
	local sound ShakeSound;
	local int RandShake;

	RandShake = Rand( 2 );

	if( RandShake == 0 )
		ShakeSound = Sound'a_creatures.Snatcher.SnatcherShake10';
	else if( RandShake == 1 )
		ShakeSound = Sound'a_creatures.Snatcher.SnatcherShake06';
	else 
		ShakeSound = Sound'a_creatures.Snatcher.SnatcherShake05';

	return ShakeSound;
}

function WpnFire( optional bool noWait )
{
	local WAMEntry entry;
	local Actor S;
	local texture NewFlashSprite;
	local float RandRot;
	local int RandShake;

	if ( AnimSequence == 'Activate1' )
	{	
		Pawn( Owner ).bFire = 0;
		Pawn( Owner ).bAltFire = 0;
		return;
	}

	// Play the animation.
	ActiveWAMIndex = GetRandomWAMEntry( default.SAnimFire, entry );
	PlayWAMEntry( entry, !noWait, 'None' );
	Pawn(Owner).WpnPlayFire();
	
	PlayerPawn(Owner).PlaySound( GetShakeSound(), SLOT_Misc );
	if ( AmbientSound != AttackingAmbientSound )
		AmbientSound = AttackingAmbientSound;
}

function WpnAltFire()
{
	local WAMEntry entry;
	local Actor S;
	local texture NewFlashSprite;
	local float RandRot;

	if ( AnimSequence == 'Activate1' )
	{	
		Pawn( Owner ).bFire = 0;
		Pawn( Owner ).bAltFire = 0;
		return;
	}

	// Play the animation.
	ActiveWAMIndex = GetRandomWAMEntry( default.SAnimAltFire, entry );
	PlayWAMEntry( entry, false, 'None' );
	PlayerPawn(Owner).ClientPlaySound( GetShakeSound() );
	Pawn(Owner).WpnPlayFire();

	if ( AmbientSound != AttackingAmbientSound )
		AmbientSound = AttackingAmbientSound;
}

function WpnIdleSmall()
{
	local WAMEntry entry;
	ActiveWAMIndex = GetRandomWAMEntry( default.SAnimIdleSmall, entry );
	PlayWAMEntry( entry, false, 'None' );
	if ( AnimSequence == 'BiteA1' )
		DamageOwner();
}

function WpnFireStop( optional bool noWait )
{
	local WAMEntry entry;
	ActiveWAMIndex = GetRandomWAMEntry( default.SAnimFireStop, entry );
	PlayWAMEntry( entry, !noWait, 'None' );
	Pawn(Owner).WpnPlayFireStop();
}

function WpnAltFireStop()
{
	WpnFireStop( false );
}

function WpnDeactivated()
{
	local WAMEntry entry;
	ActiveWAMIndex = GetRandomWAMEntry( default.SAnimDeactivate, entry );
	if ( Entry.AnimSeq == 'PullLegsA1' )
	{
		if ( FRand() < 0.5 )
			Entry.AnimSEq = 'PullLegsB1';
	}
	PlayWAMEntry( entry, true, 'Activate1' );
	if ( AnimSequence == 'PullLegsA1' )
		PlayerPawn( Owner ).ClientPlaySound( sound'SnatcherRip02' );
	else
		PlayerPawn( Owner ).ClientPlaySound( sound'SnatcherRip01' );

	if ( Pawn(Owner) != None )
	{
		Pawn(Owner).WpnPlayDeactivated();
	}
    WeaponState = WS_DEACTIVATED;
}

simulated function bool HaveModeAmmo() { return false; }



/*-----------------------------------------------------------------------------
	Timers
-----------------------------------------------------------------------------*/

function Tick( float DeltaTime )
{
	if ( !bDisabled )
	{	
		if ( AnimSequence == 'Activate1' )
		{
			Pawn( Owner ).bFire = 0;
			Pawn( Owner ).bAltFire = 0;
			FinishAnim( 0 );
			return;
		}

		if ( ( Pawn( Owner ).bFire != 0 || Pawn( Owner ).bAltFire != 0 ) || ( bAttacking && BetweenTime < MaxTimeBetween ) )
		{
			if ( Pawn( Owner ).bFire != 0 || Pawn( Owner ).bAltFire != 0 )
				BetweenTime = 0;
			if ( AnimSequence == 'PullLeft' || AnimSequence == 'PullRight' )
			{
				FinishAnim( 0 );
				//Pawn( Owner ).bFire = 0;
				//Pawn( Owner ).bAltFire = 0;
			}
			bReEnter = true;
			bAttacking = true;
			if ( RemoveTime >= TimeToRemove )
			{
				bAttacking = false;
				DukePlayer( Owner ).bWeaponsActive = true;
				Deactivate();
				Disable( 'Tick' );
			}
			else
			{
				RemoveTime += DeltaTime;
			}
		}
	
		if ( bAttacking && ( Pawn( Owner ).bFire == 0 && Pawn( Owner ).bAltFire == 0 ) )
		{
			//BroadcastMessage( "Button depressed time: "$BetweenTime );
			BetweenTime += DeltaTime;
			if ( BetweenTime >= MaxTimeBetween )
			{
				bAttacking = false;
				ResetTimer();
			}
			if ( !bReEnter )
			{
				GotoState( 'FireStop' );
				bReEnter = true;
			}
		}
	}
	Super.Tick( DeltaTime );
}

function ResetTimer()
{
	BetweenTime = 0;	
	RemoveTime = 0;
	PlayAnim( 'BiteA1' );
	DamageOwner();
	FinishAnim(0 );
}

state AltFireStart
{
    ignores Fire, AltFire;

Begin:
	if( !bAttacking )
		WpnAltFireStart();
	GotoState('AltFiring');
}



/*-----------------------------------------------------------------------------
	States
-----------------------------------------------------------------------------*/

state Active
{
	simulated function BeginState()
	{
		local class<Weapon> LWC;

		LWC = Pawn(Owner).LastWeaponClass;
		Super.BeginState();
		Pawn(Owner).LastWeaponClass = LWC;
	}
}

state FireStart
{
    ignores Fire, AltFire;

	function BeginState() {}
	function EndState() {}

Begin:
	if( !bAttacking )
		WpnFireStart();
	GotoState('Firing');
}

state Idle
{
	function BeginState() {}
	function EndState() {}

Begin:
    if ( ButtonFire() )
        Global.Fire();
	if ( ButtonAltFire() )
		Global.AltFire();

	if ( !bAttacking )
		WpnIdle();
	else
		LoopAnim( 'ShakeA1',, 0.2 );
}

state FireStop
{
	function BeginState() {}
	function EndState() {}

	function Fire()
	{
		if (!GottaReload())
			GotoState('FireStart');
	}
	function AltFire()
	{
		if (!GottaReload())
			Global.Fire();
	}

Begin:
	if( bDisabled )
		GotoState( 'DownWeapon' );

	if ( AmbientSound != IdleAmbientSound )
		AmbientSound = IdleAmbientSound;

	if( !bAttacking )
		WpnFireStop();
	else
		LoopAnim( 'ShakeA1',, 0.2 );

	if ( bChangeWeapon )
		GotoState('DownWeapon');
	else
	{
		GotoState('Idle');
	}
}

state AltFireStop
{
	function BeginState() {}
	function EndState() {}

	function Fire()
	{
		if (!GottaReload())
			GotoState('FireStart');
	}
	function AltFire()
	{
		if (!GottaReload())
			GotoState('FireStart');
	}

Begin:
	if( bDisabled )
		GotoState( 'DownWeapon' );

	if ( AmbientSound != IdleAmbientSound )
		AmbientSound = IdleAmbientSound;

	WpnFireStop();

	if ( bChangeWeapon )
		GotoState('DownWeapon');
	else
	{
		GotoState('Idle');
	}
}

function bool Deactivate()
{
	bDisabled = true;
	Super.Deactivate();
}

state DownWeapon
{
	ignores Fire, AltFire;

	function AnimEnd()
	{
		MySnatcher = class<Actor>( DynamicLoadObject( "dnAI.Snatcher", class'Class', true ) );
		if ( Pawn( Owner ).bDuck != 0 )
			SpawnedSnatcher = Spawn( MySnatcher,,, Pawn( Owner ).Location + vect( 0, 0, -8 ) + vector( Pawn( Owner ).ViewRotation ) * ( Pawn( Owner ).CollisionRadius * 0.6 ), Pawn( Owner ).ViewRotation * -1  );
		else
			SpawnedSnatcher = Spawn( MySnatcher,,, Pawn( Owner ).Location + vector( Pawn( Owner ).ViewRotation ) * ( Pawn( Owner ).CollisionRadius * 0.6 ), Pawn( Owner ).ViewRotation * -1 );
		SpawnedSnatcher.bBlockPlayers = false;
		SpawnedSnatcher.SetPhysics( PHYS_Falling );
		Pawn( SpawnedSnatcher ).AddVelocity( vector( Pawn( Owner ).ViewRotation ) * 128 );

		if ( AnimSequence == 'PullLegsA1' || AnimSequence == 'PullLegsB1' )
			Pawn( SpawnedSnatcher ).TakeDamage( 50, Pawn( Owner ), Pawn( SpawnedSnatcher ).Location, vect( 0, 0, 0 ), class'SnatcherDeLeggedDamage' );
		else if ( AnimSequence == 'PullLegR' )
			Pawn ( SpawnedSnatcher ).TakeDamage( 50, Pawn( Owner ), Pawn( SpawnedSnatcher ).Location, vect( 0, 0, 0 ), class'SnatcherDeLeggedRDamage' );
		else if ( AnimSequence == 'PullLegL' )
			Pawn( SpawnedSnatcher ).TakeDamage( 50, Pawn( Owner ), Pawn( SpawnedSnatcher ).Location, vect( 0, 0, 0 ), class'SnatcherDeLeggedLDamage' );
		else
			Pawn( SpawnedSnatcher ).TakeDamage( 0, Pawn( Owner ), Pawn( SpawnedSnatcher ).Location, vect( 0, 0, 0 ), class'SnatcherRollDamage' );

		AutoSwitchPriority = 0;
		dnCategoryPriority = 0;
		PlayerPawn(Owner).PlaySound( Sound'a_creatures.Snatcher.SnatcherOff07', SLOT_Misc );

		Pawn( Owner ).WeaponUp( true );
		Pawn( Owner ).bSnatched = false;
		Destroy();
	}
}



defaultproperties
{
	SAnimActivate(0)=(AnimChange=1.000000,animSeq=Activate1,AnimRate=0.750000,AnimTween=0.100000)
    SAnimDeactivate(0)=(AnimChance=0.250000,animSeq=ThrowOffA1,AnimRate=0.750000,AnimTween=0.100000)
	SAnimDeactivate(1)=(AnimChance=0.250000,animSeq=PullLegsA1,AnimRate=0.750000,AnimTween=0.100000)//,AnimSound=sound'SnatcherRip02')
	SAnimDeactivate(2)=(AnimChance=0.250000,animSeq=PullLegR,AnimRate=0.750000,AnimTween=0.100000)//,AnimSound=sound'SnatcherRip01')
	SAnimDeactivate(3)=(AnimChance=0.250000,animSeq=PullLegL,AnimRate=0.750000,AnimTween=0.100000)//,AnimSound=sound'SnatcherRip01')
	SAnimFire(0)=(animSeq=PullLeft1,AnimRate=1.000000,AnimChance=1.000000)
	SAnimAltFire(0)=(animSeq=PullRight1,AnimRate=1.000000,AnimChance=1.000000)
    SAnimFireStart(0)=(AnimChance=1.000000,animSeq=Grab1,AnimRate=1.000000,AnimTween=0.070000)
    SAnimFireStop(0)=(AnimChance=1.000000,animSeq=IdleA1,AnimRate=1.000000,AnimTween=0.070000)
    SAnimAltFireStart(0)=(AnimChance=1.000000,animSeq=Grab1,AnimRate=1.000000,AnimTween=0.070000)
    SAnimAltFireStop(0)=(AnimChance=1.000000,animSeq=IdleA1,AnimRate=1.000000,AnimTween=0.070000)
    SAnimIdleSmall(0)=(AnimChance=0.6500000,animSeq=BiteA1,AnimRate=1.000000,AnimTween=0.100000)
    SAnimIdleSmall(1)=(AnimChance=0.450000,animSeq=IdleA1,AnimRate=0.750000,AnimTween=0.100000)
    SAnimIdleLarge(0)=(AnimChance=0.6500000,animSeq=BiteA1,AnimRate=1.000000)
    SAnimIdleLarge(1)=(AnimChance=0.450000,animSeq=IdleA1,AnimRate=1.000000)
    ReloadCount=0
    PickupAmmoCount(0)=0
    bInstantHit=True
    bAltInstantHit=True
    FireOffset=(X=0.0,Y=-0.83,Z=-5.6)
    AIRating=0.000000
    AutoSwitchPriority=30
    PlayerViewOffset=(X=2.55,Y=0.0,Z=-9.7)
	PlayerViewScale=0.25
    PlayerViewMesh=DukeMesh'c_hands.SnatcherFace'
    PickupViewMesh=DukeMesh'c_hands.SnatcherFace'
    ThirdPersonMesh=DukeMesh'c_hands.SnatcherFace'
    AnimRate=4.000000
    Mesh=DukeMesh'c_hands.SnatcherFace'
    SoundRadius=64
    SoundVolume=200
    CollisionHeight=8.000000
    Mass=1.000000

	AmmoName=class'SnatcherFaceAmmo'

	AltAmmoItemClass=None
	AmmoItemClass=None
	bMultiMode=false

	UseSpriteFlash=false

	bDropShell=false
	bBoneDamage=false

	ItemName="Harvesting Snatcher"

	LodMode=LOD_Disabled
	dnInventoryCategory=0
	dnCategoryPriority=30
	MaxTimeBetween=0.5
	TimeToRemove=6.0
	MaxDamage=10
	MinDamage=7
	LightDetail=LTD_Normal
}
