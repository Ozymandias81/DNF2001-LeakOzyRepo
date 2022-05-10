/*-----------------------------------------------------------------------------
	ControllableTurret_Cannon
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class ControllableTurret_Cannon extends ControllableTurret;

#exec OBJ LOAD FILE=..\Sounds\dnsWeapn.dfx

var int BarrelRBone, GunRBone, BarrelLBone, GunLBone;

// Barrel recoil.
var float RecoilR, RecoilGR, RecoilL, RecoilGL;
var vector OrigR, OrigGR, OrigL, OrigGL;
var bool OddBarrel, ReadyToFireR, ReadyToFireL, bLockFiring, bWasFiring;

// Explosion.
var() class<Actor> ExplosionClass;
var() float DamagePerBlast, DamageBlastRadius;

// Bottom screen.
var SmackerTexture LeftBarrelGauge;
var SmackerTexture RightBarrelGauge;
var int TempGaugeFrame;

var sound TurretBang;

simulated function PostBeginPlay()
{
	local vector t;
	local rotator r;

	Super.PostBeginPlay();

	// Find the bones so we don't have to do it later.
	GunRBone	= MeshInstance.BoneFindNamed( 'Gun_R' );
	GunLBone	= MeshInstance.BoneFindNamed( 'Gun_L' );
	BarrelRBone = MeshInstance.BoneFindNamed( 'Barrel_R' );
	BarrelLBone = MeshInstance.BoneFindNamed( 'Barrel_L' );

	// Get the barrel's base location.
	t = MeshInstance.BoneGetTranslate( GunRBone, false, false );	OrigGR = t;
	t = MeshInstance.BoneGetTranslate( BarrelRBone, false, false );	OrigR  = t;
	t = MeshInstance.BoneGetTranslate( GunLBone, false, false );	OrigGL = t;
	t = MeshInstance.BoneGetTranslate( BarrelLBone, false, false );	OrigL  = t;
}

simulated function Fire()
{
	if ( bOverheated || (bLocalControl && bInterlock) )
	{
		bSavedFire = true;
		return;
	}
	bSavedFire = false;
	FireShot();
	SetCallbackTimer( 0.2, true, 'FireShot' );
	bLockFiring = true;
}

simulated function FireEnd()
{
	EndCallbackTimer( 'FireShot' );
	bLockFiring = false;
	bSavedFire = false;
	bWasFiring = false;
}

simulated function FireShot()
{
	local vector t;

	if ( !bLockFiring )
		return;

	bDirtyBot = true;

	PlaySound( TurretBang );

	if ( OddBarrel && ReadyToFireR )
	{
		// Gun (RIGHT)
		RecoilGR = -5;

		// Gun Barrel (RIGHT)
		RecoilR = -10;

		// Fire!
		RightBarrelGauge.pause = false;
		RightBarrelGauge.CurrentFrame = 0;
		ReadyToFireR = false;
		FireProjectile( BarrelRBone );

		OddBarrel = false;
	}
	else if ( !OddBarrel && ReadyToFireL )
	{
		// Gun (LEFT)
		RecoilGL = -5;

		// Gun Barrel (LEFT)
		RecoilL = -10;

		// Fire!
		LeftBarrelGauge.pause = false;
		LeftBarrelGauge.CurrentFrame = 0;
		ReadyToFireL = false;
		FireProjectile( BarrelLBone );

		OddBarrel = true;
	}

	OverheatTime += 0.4;
	if ( OverheatTime > MaxOverheatTime )
	{
		OverheatTime = MaxOverheatTime;
		WarningOverheat();
	}
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

simulated function Tick( float Delta )
{
	local int NewBarrelGaugeFrame, NewTempGaugeFrame;

	if ( InputActor != None )
		bDirtyBot = true;

	// Cool down the barrels.
	if ( OverheatTime > 0 )
	{
		bDirtyBot = true;
		OverheatTime -= Delta;
		if ( OverheatTime < 0.0 )
			OverheatTime = 0.0;
	}

	NewTempGaugeFrame = Clamp( int((OverheatTime / MaxOverheatTime) * 24.0), 0, 23 );
	if ( NewTempGaugeFrame != TempGaugeFrame )
		bDirtyBot = true;
	TempGaugeFrame = NewTempGaugeFrame;
	if ( (TempGaugeFrame == 15) && bOverheated )
		CoolDown();

	// Get the mesh instance.
	GetMeshInstance();
	if ( MeshInstance == None )
		return;

	RecoilGR = FClamp( RecoilGR + Delta*25, -100, 0 );
	RecoilR  = FClamp(  RecoilR + Delta*50, -100, 0 );
	if ( RecoilR == 0 )
		ReadyToFireR = true;

	RecoilGL = FClamp( RecoilGL + Delta*25, -100, 0 );
	RecoilL  = FClamp(  RecoilL + Delta*50, -100, 0 );
	if ( RecoilL == 0 )
		ReadyToFireL = true;

	Super.Tick( Delta );
}

simulated function bool OnEvalBones( int Channel )
{
	local vector t;

	Super.OnEvalBones( Channel );

	if ( Channel != 0 )
		return false;

	// Do nothing on a dedicated server?
	if ( Level.NetMode == NM_DedicatedServer )
		return false;

	t = MeshInstance.BoneGetTranslate( GunRBone, false, false );
	t.Z = OrigGR.Z + -RecoilGR;
	MeshInstance.BoneSetTranslate( GunRBone, t, false );

	t = MeshInstance.BoneGetTranslate( BarrelRBone, false, false );
	t.X = OrigR.X + RecoilR;
	MeshInstance.BoneSetTranslate( BarrelRBone, t, false );

	t = MeshInstance.BoneGetTranslate( GunLBone, false, false );
	t.Z = OrigGL.Z + -RecoilGL;
	MeshInstance.BoneSetTranslate( GunLBone, t, false );

	t = MeshInstance.BoneGetTranslate( BarrelLBone, false, false );
	t.X = OrigL.X + RecoilL;
	MeshInstance.BoneSetTranslate( BarrelLBone, t, false );
}

simulated function FireProjectile( int Bone )
{
	local vector t, HitLocation, HitNormal;
	local rotator r;
	local Actor HitActor;

	t = MeshInstance.BoneGetTranslate( Bone, true, false );
	t = MeshInstance.MeshToWorldLocation( t );

	r.Pitch = RotatePitch;
	r.Yaw   = RotateRoll;

	// Muzzle Flash
	spawn( class'CannonFlash',,, t, r);

	HitActor = Trace( HitLocation, HitNormal, t+vector(r)*50000, t, true );
	if ( HitActor != None )
	{
		spawn( ExplosionClass, Self,, HitLocation, rotator(HitNormal) );
		Instigator = InputActor;
		HurtRadius( DamagePerBlast, DamageBlastRadius, class'CannonDamage', 0, HitLocation );
	}
}

simulated function UpdateBottomScreen( float DeltaSeconds )
{
	TemperatureGauge.CurrentFrame = TempGaugeFrame;
	TemperatureGauge.ForceTick( DeltaSeconds );
	LeftBarrelGauge.ForceTick( DeltaSeconds );
	RightBarrelGauge.ForceTick( DeltaSeconds );

	CanvasBot.Palette = Background.Palette;
	CanvasBot.DrawBitmap( 31, 5, 0, 0, 0, 0, LeftBarrelGauge, true );
	CanvasBot.DrawBitmap( 85, 7, 0, 0, 0, 0, TemperatureGauge, true );
	CanvasBot.DrawBitmap( 173, 5, 0, 0, 0, 0, RightBarrelGauge, true );
}

defaultproperties
{
	Mesh=DukeMesh'c_dnWeapon.Turret_Manned'
	ItemName="EDF High-Velocity Cannon"
	MaxPitch=4291
	MinPitch=-3000
	ExplosionClass=class'dnTurret_Cannon'
	DamagePerBlast=35
	DamageBlastRadius=100
	bClampRoll=true
	Background=texture'm_turretfx.pieces.cannontop_backgbc'
	IntroBot=texture'm_turretfx.smacks.canon_bot_intro'
	IntroTop=texture'm_turretfx.smacks.canon_top_intro'
	LeftBarrelGauge=texture'm_turretfx.smacks.canon_bot_barrel1'
	RightBarrelGauge=texture'm_turretfx.smacks.canon_bot_barrel2'
	LastIntroFrameTop=7
	LastIntroFrameBot=8
	TurretBang=sound'dnsWeapn.TurretGun08'
}