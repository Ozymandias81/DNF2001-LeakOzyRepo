/*-----------------------------------------------------------------------------
	ControllableTurret_MachineGun
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class ControllableTurret_MachineGun extends ControllableTurret;

// Barrel Spin
var int GunRBone, GunLBone, TraceFireBone;
var vector OrigGR, OrigGL;
var bool bSpinUp, bSpinDown, bLockFiring, bWasFiring;
var float SpinRate, MaxSpinRate;

// Sounds
var int BrapChannel;
var bool bSpinSound;
var sound SpinSound, SpinDownSound, ShotSound;

// Damage
var bool bLastRicochet;
var() float DamagePerShot;

// Bottom screen.
var SmackerTexture LeftBarrelGauge;
var SmackerTexture RightBarrelGauge;
var int BarrelGaugeFrame, TempGaugeFrame;

simulated function PostBeginPlay()
{
	local vector t;
	local rotator r;

	Super.PostBeginPlay();

	// Find the bones so we don't have to do it later.
	GunRBone = MeshInstance.BoneFindNamed( 'Gun_R' );
	GunLBone = MeshInstance.BoneFindNamed( 'Gun_L' );

	// Get the barrel's base location.
	t = MeshInstance.BoneGetTranslate( GunRBone, false, false ); OrigGR = t;
	t = MeshInstance.BoneGetTranslate( GunLBone, false, false ); OrigGL = t;
}

simulated function Fire()
{
	if ( bOverheated || (bLocalControl && bInterlock) )
	{
		bSavedFire = true;
		return;
	}
	bSavedFire = false;
	bSpinUp = true;
	bSpinDown = false;
	SpinRate += 32;
	if ( SpinRate >= MaxSpinRate )
		SpinRate = MaxSpinRate;
}

simulated function FireEnd()
{
	EndCallbackTimer( 'FireShot' );
	bSavedFire = false;
	bSpinUp = false;
	bSpinDown = true;
	bLockFiring = false;
	bWasFiring = false;
}

simulated function Tick( float Delta )
{
	local int NewBarrelGaugeFrame, NewTempGaugeFrame;

	if ( bSpinUp )
	{
		if ( !bSpinSound )
		{
			bSpinSound = true;
			PlaySound( SpinSound, SLOT_Talk );
		}
		if ( SpinRate < MaxSpinRate )
			SpinRate += 2500 * Delta;
		if ( SpinRate >= MaxSpinRate )
		{
			SpinRate = MaxSpinRate;
			bSpinUp = false;
			bLockFiring = true;
			FireShot();
			SetCallbackTimer( 0.11, true, 'FireShot' );
		}
	}
	else if ( bSpinDown )
	{
		if ( bSpinSound )
		{
			bSpinSound = false;
			StopSound( SLOT_Talk );
			PlaySound( SpinDownSound, SLOT_Talk );
		}
		if ( SpinRate > 0 )
			SpinRate -= 1500 * Delta;
		if ( SpinRate <= 0 )
		{
			SpinRate = 0;
			bSpinDown = false;
		}
	}

	// Cool down the barrel if we aren't firing.
	if ( !bLockFiring && (OverheatTime > 0) )
	{
		bDirtyBot = true;
		OverheatTime -= Delta;
		if ( OverheatTime < 0.0 )
			OverheatTime = 0.0;
	}

	NewBarrelGaugeFrame = Clamp( int((SpinRate / MaxSpinRate) * 24.0), 0, 23 );
	if ( NewBarrelGaugeFrame != BarrelGaugeFrame )
		bDirtyBot = true;
	BarrelGaugeFrame = NewBarrelGaugeFrame;

	NewTempGaugeFrame = Clamp( int((OverheatTime / MaxOverheatTime) * 24.0), 0, 23 );
	if ( NewTempGaugeFrame != TempGaugeFrame )
		bDirtyBot = true;
	TempGaugeFrame = NewTempGaugeFrame;
	if ( (TempGaugeFrame == 15) && bOverheated )
		CoolDown();

	Super.Tick( Delta );
}

simulated function WarningOverheat()
{
	bDirtyTop = true;
	bOverheated = true;
	bWasFiring = true;
	bLockFiring = false;
}

simulated function CoolDown()
{
	bDirtyTop = true;
	bOverheated = false;
	bLockFiring = bWasFiring;

	if ( bSavedFire )
		Fire();
}

simulated function FireShot()
{
	local vector t;
	local rotator r;

	if ( !bLockFiring )
		return;

	bDirtyBot = true;
	OverheatTime += 0.1;
	if ( OverheatTime > MaxOverheatTime )
	{
		OverheatTime = MaxOverheatTime;
		WarningOverheat();
	}

	// Muzzle Flashes
	r.Pitch = RotatePitch;
	r.Yaw   = RotateRoll;
	r.Roll  = Rand(8192);

	t = MeshInstance.BoneGetTranslate( GunRBone, true, false );
	t = MeshInstance.MeshToWorldLocation( t );
	spawn(class'CannonFlash2',,, t+vector(r)*40, r );
	t = MeshInstance.BoneGetTranslate( GunLBone, true, false );
	t = MeshInstance.MeshToWorldLocation( t );
	spawn(class'CannonFlash2',,, t+vector(r)*40, r );

	if ( BrapChannel == 0 )
		PlaySound( ShotSound, SLOT_None );
	else if ( BrapChannel == 1 )
		PlaySound( ShotSound, SLOT_Misc );
	else if ( BrapChannel == 2 )
		PlaySound( ShotSound, SLOT_Pain );
	else if ( BrapChannel == 3 )
		PlaySound( ShotSound, SLOT_Interface );
	else if ( BrapChannel == 4 )
		PlaySound( ShotSound, SLOT_Interact );
	BrapChannel++;
	if ( BrapChannel > 4 )
		BrapChannel = 0;

	Instigator = InputActor;
	TraceFireBone = GunRBone;
	if ( Role == ROLE_Authority )
		TraceFire( InputActor );
	TraceFireBone = GunLBone;
	if ( Role == ROLE_Authority )
		TraceFire( InputActor );
}

simulated function bool OnEvalBones( int Channel )
{
	local rotator r;
	local vector t;

	if ( Channel != 0 )
		return false;

	// Do nothing on a dedicated server?
	if ( Level.NetMode == NM_DedicatedServer )
		return false;

	// Get the mesh instance.
	GetMeshInstance();
	if ( MeshInstance == None )
		return false;

	r = MeshInstance.BoneGetRotate( GunRBone, false, false );
	r.Roll -= SpinRate;
	MeshInstance.BoneSetRotate( GunRBone, r, false );

	r = MeshInstance.BoneGetRotate( GunLBone, false, false );
	r.Roll += SpinRate;
	MeshInstance.BoneSetRotate( GunLBone, r, false );

	Super.OnEvalBones( Channel );
}

simulated function GetTraceFireSegment( out vector Start, out vector End, out vector BeamStart, optional float HorizError, optional float VertError )
{
	local rotator r;

	r.Pitch	= RotatePitch;
	r.Yaw	= RotateRoll;
	Start	= MeshInstance.BoneGetTranslate( TraceFireBone, true, false );
	Start	= MeshInstance.MeshToWorldLocation( Start );
	End		= Start+vector(r)*10000;
	BeamStart = Start+vector(r)*30;
}

simulated function int GetHitDamage( actor Victim, name BoneName )
{
	return DamagePerShot;
}

simulated function UpdateBottomScreen( float DeltaSeconds )
{
	TemperatureGauge.CurrentFrame = TempGaugeFrame;
	TemperatureGauge.ForceTick( DeltaSeconds );
	LeftBarrelGauge.CurrentFrame = BarrelGaugeFrame;
	LeftBarrelGauge.ForceTick( DeltaSeconds );
	RightBarrelGauge.CurrentFrame = BarrelGaugeFrame;
	RightBarrelGauge.ForceTick( DeltaSeconds );

	CanvasBot.Palette = Background.Palette;
	CanvasBot.DrawBitmap( 31, 5, 0, 0, 0, 0, LeftBarrelGauge, true );
	CanvasBot.DrawBitmap( 85, 7, 0, 0, 0, 0, TemperatureGauge, true );
	CanvasBot.DrawBitmap( 173, 5, 0, 0, 0, 0, RightBarrelGauge, true );
}

defaultproperties
{
	Mesh=DukeMesh'c_dnWeapon.Turret_MannedGat'
	ItemName="EDF .50 Autogun"
	MaxPitch=4291
	MinPitch=-3000
	DamagePerShot=20
	MaxSpinRate=3300
	bClampRoll=true
	Background=texture'm_turretfx.pieces.gatlingtop_backgbc'
	IntroBot=texture'm_turretfx.smacks.gat_bot_intro'
	IntroTop=texture'm_turretfx.smacks.gat_top_intro'
	LeftBarrelGauge=texture'm_turretfx.smacks.gat_bot_barrel1'
	RightBarrelGauge=texture'm_turretfx.smacks.gat_bot_barrel2'
	SpinSound=sound'dnsWeapn.Vulcan.VStartSpinLp07'
	SpinDownSound=sound'dnsWeapn.Vulcan.VOff07'
	ShotSound=sound'dnsWeapn.Vulcan.VShot01'
	bBeamTraceHit=true
}