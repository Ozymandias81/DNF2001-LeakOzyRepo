/*-----------------------------------------------------------------------------
	LaserMine
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class LaserMine extends Projectile;

#exec OBJ LOAD FILE=..\Meshes\c_dnWeapon.dmx
#exec OBJ LOAD FILE=..\Textures\m_dnWeapon.dtx
#exec OBJ LOAD FILE=..\Textures\t_generic.dtx
#exec OBJ LOAD FILE=..\Sounds\ts01.dfx
#exec OBJ LOAD FILE=..\Textures\ShieldFX.dtx

// TMOpen07

var BeamSystem LaserBeam;
var actor Shield;

var() float					ArmingTime		?("Time in seconds to arm the laser");
var() bool					bHeatVisionOnly ?("Only visible with heat vision active");
var() bool					bTripPawnsOnly  ?("Only trip laser when pawns cross it, not other actors");
var() bool					bIndestructible ?("Cannot be destroyed; tripping will re-arm mine but not remove it");
var() bool					bNoInitialNoise ?("Don't make noise during first arming, use for map-placed mines etc.");
var() bool					bNPCsIgnoreMe;

var() bool					bToggleOnTrigger;

var() name					DestroyedEvent;

var bool					bArmed;
var bool					bHasArmedBefore;
var bool					bDamageDetonate;
var bool					bFadingOut;
var bool					bDetonateOnClient;
var bool					bShieldOnClient, OldbShieldOnClient;
var Actor					SparksActor;
var float					GlowFade;

const TIMER_DestroyShield=0;
const TIMER_Indestructible=1;
const TIMER_HeatVision=2;

var NPCAlertBeacon			AlertBeacon;

var int						DamageState;

var() bool					bNoArmSound;
var sound					ArmedSound;
var sound					ArmingCharge;

// Rotating beams
var() bool					bRotatingBeam;
var() float					RotationAnglePitch, RotationAngleYaw;
var() float					RotationRatePitch, RotationRateYaw;
var() bool					RotationPitchForward, RotationYawForward;
var() float					RotationPitchDelta, RotationYawDelta;
var rotator					BeamRotation;
var rotator					OriginalRot;

// Ambient laser sound.
var sound					AmbientHum;

replication
{
	reliable if ( Role == ROLE_Authority )
		bDetonateOnClient, bShieldOnClient;
}


/*-----------------------------------------------------------------------------
	Object Methods
-----------------------------------------------------------------------------*/

simulated function PostBeginPlay()
{
    local vector HitNormal, HitLocation;
    local actor a;
	local rotator HitRotation;

	if (Level.NetMode != NM_Client)
	{
		// Automatically adjusts for forward trace to wall for actual position.
		// Distance from wall check should be done by the spawner.
		OriginalRot = Rotation;
		a = Trace( HitLocation, HitNormal, Location+vector(Rotation)*4096.0 );
		if ( a == None )
		{
			Destroy();
			return;
		}

		SetLocation(HitLocation + HitNormal*4);
		HitRotation = rotator(HitNormal);
		HitRotation .Pitch -= 16384;
		SetRotation(HitRotation);
		if( !bNPCsIgnoreMe )
		{
			AlertBeacon = Spawn( class'NPCAlertBeacon', self );
			AlertBeacon.WarningActor = self;
		}
		SetCollision(false,false,false);
	}

	if ( !bNoInitialNoise )
		PlaySound(Sound'ts01.Duke3D_lsrbmbpt');

	Super.PostBeginPlay();

	if ( ArmingTime == 0 )
		ArmMine();
	else
		GotoState('Arming');
}

simulated function Destroyed()
{
    if ( AlertBeacon != none )
		AlertBeacon.Destroy();

	DisarmMine();
	DestroyShield();

    if ( SparksActor != none )
    {
        SparksActor.Destroy();
        SparksActor = none;
    }

	if ( DestroyedEvent != '' )
		GlobalTrigger( DestroyedEvent );

	bHidden = true;

    Super.Destroyed();
}

function DebugWatchBegin(DebugView D)
{
    Super.DebugWatchBegin(D);
    D.AddWatch("Health");
}


/*-----------------------------------------------------------------------------
	Timing
-----------------------------------------------------------------------------*/

simulated function Timer(optional int TimerNum)
{
    if ( TimerNum == TIMER_DestroyShield )
    {
        DestroyShield();
    }
    else if ( TimerNum == TIMER_Indestructible )  
    {
        bIndestructible = true;
        CreateShield();
        SetTimer( 1.0, false, TIMER_DestroyShield );
    }
    else if ( TimerNum == TIMER_HeatVision )
    {
	    Style = STY_Translucent;
		bHidden = false;
        bHeatVisionOnly = true;
		GlowFade = 2.0;
		bFadingOut = true;
    }
}

simulated function Tick(float Delta)
{
	local float pf, yf;
	local rotator r;
	local vector HitLocation, HitNormal;

	if (bArmed && bDetonateOnClient && (Level.NetMode == NM_Client))
	{
		bDamageDetonate = true;
		Detonate();
	}

	if (bIndestructible && (bShieldOnClient != OldbShieldOnClient) && (Level.NetMode == NM_Client))
	{
        CreateShield();
        SetTimer( 1.0, false, TIMER_DestroyShield );
	}
	OldbShieldOnClient = bShieldOnClient;

	if (bFadingOut)
	{
		if (GlowFade <= 0)
		{
			bHidden = true;
			ScaleGlow = 2.0;
			Style = STY_Normal;
			bFadingOut = false;
			return;
		}
		if (Role != ROLE_Authority)
		{
		    Style = STY_Translucent;
			bHidden = false;
		}
		GlowFade -= Delta*4;
		ScaleGlow = GlowFade;
	}

	if ( (LaserBeam != None) && bRotatingBeam )
	{
		if ( RotationRatePitch > 0 )
		{
			if ( RotationPitchForward )
			{
				RotationPitchDelta += RotationRatePitch * Delta * 10;
				if ( RotationPitchDelta > RotationAnglePitch )
					RotationPitchForward = false;
			}
			else 
			{
				RotationPitchDelta -= RotationRatePitch * Delta * 10;
				if ( RotationPitchDelta < -RotationAnglePitch )
					RotationPitchForward = true;
			}
		}
		if ( RotationRateYaw > 0 )
		{
			if ( RotationYawForward )
			{
				RotationYawDelta += RotationRateYaw * Delta * 10;
				if ( RotationYawDelta > RotationAngleYaw )
					RotationYawForward = false;
			}
			else 
			{
				RotationYawDelta -= RotationRateYaw * Delta * 10;
				if ( RotationYawDelta < -RotationAngleYaw )
					RotationYawForward = true;
			}
		}
		pf = 1.0; yf = 1.0;
//		pf = sin((RotationPitchDelta / RotationAnglePitch) * (PI/2)) + 0.5;
//		yf = sin((RotationYawDelta / RotationAngleYaw) * (PI/2)) + 0.5;
		r = Rotation + rot(RotationPitchDelta*pf+16384,RotationYawDelta*yf,0);
		Trace( HitLocation, HitNormal, Location+vector(r)*1000, Location, false );
		LaserBeam.SetLocation(HitLocation);
	}
}


/*-----------------------------------------------------------------------------
	Invulnurability
-----------------------------------------------------------------------------*/

simulated function CreateShield()
{
    if (Shield == none)
    {
        Shield = spawn(class'Effects',self,,Location,Rotation);
        Shield.SetCollisionSize(CollisionRadius, CollisionHeight);
        Shield.SetCollision(false, false, false);
        Shield.bProjTarget = false;
        Shield.SetPhysics(PHYS_Rotating);
        Shield.DrawType = DT_Mesh;
		Shield.Style = STY_Translucent;
        Shield.Mesh = Mesh;
		Shield.Texture = texture'ShieldFX.ShieldLightning';
		Shield.bMeshEnviroMap = true;
        Shield.DrawScale = 1.3;
		Shield.ScaleGlow = 50;
        Shield.bMeshLowerByCollision=true;
        Shield.MeshLowerHeight=0.0;
		Shield.RemoteRole = ROLE_None;
    }
}

simulated function DestroyShield()
{
    if (Shield != none)
    {
        Shield.Destroy();
        Shield = none;
    }
}


/*-----------------------------------------------------------------------------
	EMP
-----------------------------------------------------------------------------*/

simulated function Sparks()
{
    SparksActor = spawn(class'dnEMPFX_Spark1',,,Location);
    AttachActorToParent( SparksActor, true, true );
}

function EMPBlast( float EMPtime, optional Pawn Instigator )
{    
    // Remove any current shield effect
    DestroyShield();

    // Make destructible and set a timer to turn back on shield after 10 seconds
    if ( bIndestructible )
    {
        Sparks();
        bIndestructible = false;
        SetTimer( EMPTime, false, TIMER_Indestructible );
    }

    // Make visible and set a timer to re-cloak after 10 seconds
    if ( bHeatVisionOnly )
    {
        bHeatVisionOnly = false;
        bHidden         = false;
        bFadingOut      = false;
        Style           = STY_Normal;
        ScaleGlow       = 1.0;
        Sparks();
        SetTimer( EMPTime, false, TIMER_HeatVision );
    }
}


/*-----------------------------------------------------------------------------
	Arming
-----------------------------------------------------------------------------*/

simulated function bool ArmMine()
{
    local actor a;
    local vector endPos, startPos, Offset, X, Y, Z;
	local rotator lasRot;

	SetCollision(true,true,true);
	lasRot = Rotation;
	lasRot.Pitch += 16384;
	startPos = Location + vector(lasRot)*4096.0;
    a = Trace(endPos,,startPos);
    if ( (a == None) || ((a != Level) && (dnDecoration(a) == None)) )
	{
		bArmed = true;
		Detonate();
		return false;
	}

	// Find a placement offset.
	Offset = vector(lasRot) * -2;		// Back a bit.
	Offset += vector(Rotation) * -1;	// And up a bit.
	lasRot.Yaw += 16384;
	Offset += vector(lasRot) * 0.2;		// And left a bit.

    if ( LaserBeam == none )
    {
        LaserBeam = spawn(class'BeamSystem',Self,,endPos,Rotation);
		LaserBeam.BeamTexture = texture'a_generic.beam15arc';
		LaserBeam.BeamReversePanPass = true;
		LaserBeam.BeamTexturePanX = 0.2;
		LaserBeam.BeamTexturePanY = 0.0;
		LaserBeam.BeamTextureScaleX = 1.0;
		LaserBeam.BeamTextureScaleY = 1.0;
		LaserBeam.BeamTexturePanOffsetX = 256*FRand();
		LaserBeam.ScaleToWorld = true;
		LaserBeam.FlipHorizontal = false;
		LaserBeam.FlipVertical = false;
		LaserBeam.SubTextureCount = 1;
		LaserBeam.Style = STY_Translucent;
        LaserBeam.TesselationLevel = 5;
        LaserBeam.MaxAmplitude = 100.0;
        LaserBeam.MaxFrequency = 50.0;
        LaserBeam.Noise = 0.0;
        LaserBeam.BeamColor.R = 255;
        LaserBeam.BeamColor.G = 0;
        LaserBeam.BeamColor.B = 0;
        LaserBeam.BeamEndColor.R = 255;
        LaserBeam.BeamEndColor.G = 0;
        LaserBeam.BeamEndColor.B = 0;
        LaserBeam.BeamStartWidth = 2.0;
        LaserBeam.BeamEndWidth = 2.0;
        LaserBeam.BeamType = BST_Straight;
        LaserBeam.DepthCued = true;
		LaserBeam.Enabled = true;
        LaserBeam.TriggerType = BSTT_None;
        LaserBeam.BeamBrokenWhen = BBW_ClassProximity;
        LaserBeam.BeamBrokenAction = BBA_TriggerOwner;
        LaserBeam.NumberDestinations = 1;
        LaserBeam.DestinationActor[0] = self;
		LaserBeam.DestinationOffset[0] = Offset;
		LaserBeam.RemoteRole = ROLE_None;
        if ( bHeatVisionOnly )
        {
            LaserBeam.BeamPlayerCameraStyle = PCS_HeatVision;
            LaserBeam.BeamPlayerCameraStyleMode = BPCS_Equal;
        }
        if ( bTripPawnsOnly )
        {
            LaserBeam.BeamBrokenWhenClass = class'Pawn';
        }
        else
        {
            LaserBeam.BeamBrokenWhenClass = class'Actor';
            LaserBeam.BeamBrokenIgnoreWorld = true;
        }
    }
    bArmed = true;
    bHasArmedBefore = true;

	AmbientSound = AmbientHum;
	SoundVolume  = 255;
	SoundRadius  = 6;
	SoundPitch   = 64;

	GotoState('');

	return true;
}

simulated function DisarmMine()
{
    if (LaserBeam != none)
    {
        LaserBeam.Destroy();
        LaserBeam = none;
    }
    bArmed = false;
    if (bHeatVisionOnly)
        bHidden = false;
}

simulated function Detonate()
{
    if (bArmed)
        GotoState('Detonation');
}


/*-----------------------------------------------------------------------------
	Physics
-----------------------------------------------------------------------------*/

function HitWall(vector HitNormal, actor Wall)
{
}

simulated singular function Touch(Actor Other)
{
	Detonate();
}

simulated function Trigger( actor Other, Pawn Instigator )
{
	if ( bToggleOnTrigger && (Other != LaserBeam) )
	{
		if ( bArmed )
			DisarmMine();
		else
			ArmMine();
	}
	else
	{
		if ( bArmed )
		{
		    bDamageDetonate = false;
			Detonate();
		}
	}
}

function TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType)
{
	if ( bIndestructible )
	{
		CreateShield();
		bShieldOnClient = !bShieldOnClient;
		SetTimer( 1.0, false, TIMER_DestroyShield );
	}
	else
	{
		if ( bArmed )
		{
			bDetonateOnClient = true;
		    bDamageDetonate = true;
			Detonate();
		}
	}
}


/*-----------------------------------------------------------------------------
	States
-----------------------------------------------------------------------------*/

auto state Arming
{
	simulated function Timer( optional int TimerNum )
	{
		if ( TimerNum == 2 )
		{
			ArmMine();
			return;
		}
		else if ( TimerNum == 3 )
		{
			PlaySound( ArmedSound, SLOT_Interact, 1.0, false, 800 );
			SetTimer( GetSoundDuration( ArmedSound ), false, 2 );
		}
	}

	simulated function BeginState()
	{
		PlaySound( ArmingCharge, SLOT_Interact, 1.0, false, 800 );
		SetTimer( GetSoundDuration( ArmingCharge ), false, 3 );
		if ( bNoArmSound )
			ArmMine();
		if (bHeatVisionOnly)
		{
			Style = STY_Translucent;
			bHidden = false;
			GlowFade = 2.0;
			bFadingOut = true;
		}
	}
}

state Detonation
{
	simulated function Trigger(actor Other, Pawn Instigator) {}

	simulated function SpawnBlast()
	{
		local actor s;
		local vector x,y,z;
		local rotator r, blastrot;
		local float BlastDamage, RealMomentum;

		r = Rotation;
		if ( bRotatingBeam )
			r += rot(RotationPitchDelta+16384,RotationYawDelta,0);
		else
			r.Pitch += 16384;

		// Put a blastmark on the opposite wall if the blast reaches it.
		blastrot = Rotation;
		blastrot.Pitch -= 16384;
		if ( (LaserBeam != None) && (VSize(LaserBeam.Location - Location) <= 450) )
			spawn( class'dnDecal_BlastMark3',,,LaserBeam.Location,blastrot );

		// Put a blast on the current wall.
		blastrot.Pitch += 32768;
		spawn( class'dnDecal_BlastMarkBlack',,,Location,blastrot );

		// Disarm mine and do damage.
		DisarmMine();
		if ( Level.NetMode != NM_Client )
		{
			// If this is a shrunken tripmine, do 15% damage.
			if ( DrawScale < default.DrawScale )
			{
				BlastDamage = Damage * 0.15;
				RealMomentum = MomentumTransfer * 0.25;
				HurtRadius( BlastDamage, 120, class'LaserMineDamage', RealMomentum, Location, true, vector(r), 20.0 );
				HurtRadius( BlastDamage, 30 , class'LaserMineDamage', RealMomentum, Location );
			}
			else
			{
				BlastDamage = Damage;
				RealMomentum = MomentumTransfer;
				HurtRadius( BlastDamage, 450, class'LaserMineDamage', RealMomentum, Location, true, vector(r), 20.0 );
				HurtRadius( BlastDamage, 100, class'LaserMineDamage', RealMomentum, Location );
			}
		}
        MakeNoise( 1.0 );
        
		// Spawn other effects.
		GetAxes( r,x,y,z );
		if ( DrawScale < default.DrawScale )
			spawn( class'dnTripMineFX_Shrunk_Flash',,,Location + x*16.0,r );
		else 
			spawn( class'dnTripMineFX_Flash',,,Location + x*16.0,r );
    }

	simulated function Timer( optional int TimerNum )
	{
		if ( TimerNum == 2 )
		{
			Destroy();
			SetTimer( 0.0, false, 2 );
		}
		else
			Super.Timer( TimerNum );
	}

	simulated function Destroyed()
	{
		SpawnBlast();

		Global.Destroyed();
	}

	simulated function BeginState()
	{
	    if ( bDamageDetonate )
		{
		    SetTimer( 0.15, false, 2 );
		}
		else
		{
			PlaySound( Sound'ts01.Duke3D_lsrbmbwn', SLOT_Talk );
			Destroy();
		}
	}
}

defaultproperties
{
    DrawType=DT_Mesh
    Damage=150.000000
    MomentumTransfer=100000
    Physics=PHYS_MovingBrush
    RemoteRole=ROLE_SimulatedProxy
    Mesh=Mesh'c_dnWeapon.w_tripmine'
    MeshLowerHeight=5.500000
    bMeshLowerByCollision=true
    CollisionHeight=4.000000
    CollisionRadius=10.000000
    bCollideActors=true
    bCollideWorld=false
    bBlockActors=true
    bBlockPlayers=true
    bProjTarget=true
    Health=1
    LifeSpan=0.000000
	bHeated=True
    bHeatNoHide=True
	HeatIntensity=255
	HeatRadius=5
	HeatFalloff=0
    bHeatVisionOnly=False
    bIndestructible=False
    bNoInitialNoise=False
    ArmingTime=3.000000
	Speed=0
	MaxSpeed=0
	bNetTemporary=false
	bAlwaysRelevant=true
	NetPriority=1.5
	ArmedSound=sound'dnsWeapn.Bombs.TripMineArmed1'
	ArmingCharge=sound'dnsWeapn.Bombs.TMCharge02'
	AmbientHum=sound'dnsWeapn.Bombs.TMBeamLp02'
}