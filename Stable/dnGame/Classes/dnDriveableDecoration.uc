//=============================================================================
// dnDriveableDecoration.
// Flexible base class for Duke specific decorations. (!z3l1_1)
//=============================================================================
class dnDriveableDecoration expands dnDecoration;

#exec OBJ LOAD FILE=..\Meshes\c_hands.dmx 
#exec OBJ LOAD FILE=..\Sounds\a_transport.dfx 

var PlayerPawn			AttachedPlayer;		// Player currently driving this driveable

var(Sounds) sound		IdleSound;
var(Sounds) sound		DriveSound;
var(Sounds) sound		DecelerateSound;
var(Sounds) sound		HornSound;
var(Sounds) sound		GearSounds[5];
var(Sounds) sound		CrashSounds[2];
var(Sounds) sound		SkidSounds[2];
var(Sounds) sound		RevSound;
var(Sounds) sound		ClutchClick;
var(Sounds) sound		LandSound;

var   float				CurrentSpeed;
var() name				CurrentSpeedVariable;
var() float				CurrentSpeedVariableScale;

var   float				KeyringRoll;
var   float				KeyringVelocity;
var() float				KeyringGravity;

var   float				AmstKeyringRoll;
var   float				AmstKeyringVelocity;
var() float				AmstKeyringGravity;

var   float				KeyKeyringRoll;
var   float				KeyKeyringVelocity;
var() float				KeyKeyringGravity;

var(Animations) name	Accel_Pull;
var(Animations) name	Accel_Release;
var(Animations) name	Accel_Idle;

var(Animations) name	Brake_Pull;
var(Animations) name	Brake_Release;
var(Animations) name	Brake_Idle;

var(Animations) name	Horn_Pull;
var(Animations) name	Horn_Idle;
var(Animations) name	Horn_Release;

var(Animations) name	Clutch_Pull;
var(Animations) name	Clutch_Idle;
var(Animations) name	Clutch_Release;

var(Animations) name	Idle;
var(Animations) name	RareIdle;

var int					Gear;				// Current gear.
var () float			MaxGearSpeed[5];	// Max Speeds for each gear.

var bool				Clutch;
var bool				Horn;
var bool				OnGround;

var () float			RandomBumpinessAmplitude;
var () float			RandomBumpinessPercent;

var enum EDrivableState
{
	DS_Idle,
	DS_Accelerating,
	DS_Braking,
} DrivableState;

var enum ELerpState
{
	LS_ToBike,
	LS_FromBike1,	
	LS_FromBike2,
	LS_Done,
} LerpState;

var float			LerpTime;

var(Bike) float		MaxSpeed;
var(Bike) float		Acceleration;
var(Bike) float		TurnScale;

var(Bike) float		ForwardFriction1	?("Forward and Skidding friction.");			// Forward and Skidding
var(Bike) float		ForwardFriction2	?("Forward and Braking friction");				// Forward and Braking
var(Bike) float		ForwardFriction3	?("Forward friction normal");					// Forward velocity normal
var(Bike) float		ForwardFriction4	?("Forward friction in air");					// Forward in air

var(Bike) float		SideFriction1		?("Side and Skidding friction ");				// Side and Skidding
var(Bike) float		SideFriction2		?("Side friction normal");						// Side normal
var(Bike) float		SideFriction3		?("Side friction in air");						// Side in air
var(Bike) float		WheelieScale		?("How much rpm's affect wheelie (0.0-10.0)");
var(Bike) float		WheelSlipScale		?("How much traction the bike has (0.0-10.0)");
var(Bike) float		ShockDampening		?("How mushy the shocks are when you slam down on them (0.1-30.0)");
var(Bike) float		WheelieResistance	?("How hard it is to get the front wheel off the ground (0.0-1.0)");
var(Bike) int		WheelieResistanceAngle ?("Angle at which WheelieResistance stops taking affect (0-6000)");
var(Bike) float		ShockTightness1		?("How easy it is to have acceleration raise front wheel (0.0-1.0)");
var(Bike) int		ShockTightness1Angle ?("Angle at which ShockTightness1 stops taking affect (0-6000)");
var(Bike) float		ShockTightness2		?("How fast nose will come back up from being below center (0.0-1.0)");
var(Bike) float		SkidSensitivity		?("How sensitive bike is to losing traction (0.0-5.0)");

var(Bike) float		ViewInterpSpeed		?("How fast you transition from being off the bike to being on it");
var(Bike) float		ViewInterpPitch		?("How high the view raises up while transitioning to the bike view");

var(Bike) float		ViewPitchPercent	?("How much of bike Pitch to pass to view Pitch (0.0-1.0)");
var(Bike) float		ViewYawPercent		?("How much of bike Yaw to pass to view Yaw (0.0-1.0)");
var(Bike) float		ViewRollPercent		?("How much of bike Roll to pass to view Roll (0.0-1.0)");

var(Bike) float		ViewPitchDampen		?("How much to soften transition from bike Pitch to view Pitch (0.0-1.0)");
var(Bike) float		ViewYawDampen		?("How much to soften transition from bike Yaw to view Yaw (0.0-1.0)");
var(Bike) float		ViewRollDampen		?("How much to soften transition from bike Roll to view Roll (0.0-1.0)");

var(Bike) float		GroundOffset		?("How far off the ground should collision be performed.  Used for steps, etc.");

var(Bike) vector	ViewOffset1			?("View offset when NOT in a wheelie");
var(Bike) vector	ViewOffset2			?("View offset when bike is doing a wheelie");
var(Bike) vector	ViewOffset3			?("View offset when bike is leaning forward");

var(Bike) float		BikeMeshZOffset;
var(Bike) float		CrashSoundSensitivity;
var(Bike) float		CrashSpinScale;

var(Bike) float		JumpScale;
var(Bike) float		MaxAutoJumpForce;
var(Bike) int		MinAutoJumpPitch;

var(Bike) int		WheelieLandSoundPitch	?("Wheelie Pitch of bike before landing sound kicks in...");
var(Bike) float		WheelieLandSoundHeight	?("Height of bike off ground before landing sound kicks in...");

var float			LastOnGroundHeight;

var(Bike) mesh		SwapMesh;
var		  mesh		OldMesh;

var(Bike) float		WheelieHeightAdjScale	?("How much to raise the bike up when doing a wheelie (0.0-2.0)");

var vector			ForwardVelocity;
var	vector			UpVector;
var	vector			UpVector2;
var bool			bBraking;
var bool			bReverse;
var bool			bSkidding;
var bool			bCanJump;
var float			OldPitch;
var rotator			FinalRotation;
var rotator			FinalRotation1;		// For quadratic blend 1
var rotator			FinalRotation2;		// For quadratic blend 2
var rotator			FinalRotation3;		// For quadratic blend 3
var vector			FinalLocation1;
var vector			FinalLocation2;
var vector			FinalLocation3;
var bool			bInReverseGear;
var float			CrashSpin;
var float			LastDeltaSeconds;
var vector			LastLocation;
var vector			LastCameraLocation;
var rotator			LastCameraRotation;
var float			MaxReverseSpeed;
var float			WheeliePitch;
var float			WheelieVelocity;
var float			OldSpeed;
var DukePlayer		Duke;				// The Duke standing by this bike

var byte			OldbFire;
var byte			OldbAltFire;
var byte			OldbUse;

var float			Rpm;
var float			WheelSlip;
var bool			bCanPlayWheelSlipSound;
var bool			bCanPlaySkidSound;
var bool			bCanPlayLandSound;
var bool			bCanPlayLandSoundFromWheelie;
var bool			bHitWall;

var sound			CurrentPlayingSound;
var float			CurrentSoundDuration;

var vector			MaxForwardVelocity;

//=============================================================================
//	PostBeginPlay
//=============================================================================
function PostBeginPlay()
{
	local int i;

	super.PostBeginPlay();

	AttachedPlayer=none;

	// If gear speed isn't initialized, set it to default:
	if(MaxGearSpeed[0]==0)
		for(i=0;i<ArrayCount(MaxGearSpeed);i++)
			MaxGearSpeed[i]=MaxSpeed/ArrayCount(MaxGearSpeed)*(i+1);

	//SetPhysics(PHYS_Projectile);
	SetPhysics(PHYS_None);
	bBounce=false;

	bCollideWorld=True;
	MeshLowerHeight=-BikeMeshZOffset;
	bMeshLowerByCollision=false;
	SetCollision(true, false, false);
	CollisionRadius=45;
	CollisionHeight=5;

	// Put on the floor
	MoveActor(vect(0,0,-100));
	MoveActor(vect(0,0,GroundOffset));

	//ViewInterpSpeed = 1.0f;

	Disable('Tick');
}

//=============================================================================
//	AttachPlayer
//=============================================================================
function AttachPlayer(PlayerPawn p)
{
	AttachedPlayer=p;
	
	LastCameraLocation = AttachedPlayer.Location + AttachedPlayer.BaseEyeHeight * vect(0,0,1);
	LastCameraRotation = AttachedPlayer.ViewRotation;

	//AttachedPlayer.Autoduck=false;
	AttachedPlayer.DontUpdateEyeHeight=true;
	AttachedPlayer.SetPhysics(PHYS_MovingBrush);
	AttachedPlayer.SetCollision(false,false,false);
	AttachedPlayer.bCollideWorld=false;
	AttachedPlayer.AttachToParent(Tag);
	AttachedPlayer.InputHookActor=self;
	AttachedPlayer.WeaponDown( false, true );
	AttachedPlayer.ViewMapper = Self;
	AttachedPlayer.bWeaponsActive = false;

	FinalRotation = Normalize(Rotation);

	// Gonna do a quadratic blend
	FinalRotation1 = LastCameraRotation;
	FinalRotation2 = FinalRotation;
	FinalRotation2.Pitch = ViewInterpPitch;
	FinalRotation3 = FinalRotation;
	FinalRotation3.Pitch = 0;

	FinalLocation1 = LastCameraLocation;
	FinalLocation3 = GetCameraLocation(Location);
	FinalLocation2 = FinalLocation1+(FinalLocation3-FinalLocation1)*0.91f;

	LerpState = LS_ToBike;
	LerpTime = 0.0;

	// Remember current mesh
	OldMesh = Mesh;
	bHidden = true;
	DukePlayer(AttachedPlayer).OverlayActor = self;
}

//=============================================================================
//	DetachPlayer
//=============================================================================
function DetachPlayer()
{
	if(AttachedPlayer==none)
	{
		BroadcastMessage("DetachPlayer: No Attached Player!");
		return;
	}

	//AttachedPlayer.Autoduck=true;
	AttachedPlayer.DontUpdateEyeHeight=false;
	AttachedPlayer.SetPhysics(PHYS_Falling);
	AttachedPlayer.bCollideWorld=true;
	AttachedPlayer.SetCollision(true,true,true);
	AttachedPlayer.MountParent=none;
	AttachedPlayer.InputHookActor=none;
	AttachedPlayer.FireEvent='';
	AttachedPlayer.FireEventEnd='';
	AttachedPlayer.AltFireEvent='';
	AttachedPlayer.AltFireEventEnd='';
	AttachedPlayer.ViewMapper = None;
	AttachedPlayer.Velocity = vect(0,0,0);
	AttachedPlayer.bWeaponsActive = true;

	// Bring the weapon up.
	AttachedPlayer.BringUpLastWeapon();

	// Set the locations one more time for good luck
	AttachedPlayer.SetRotation(FinalRotation3);
	AttachedPlayer.ViewRotation = FinalRotation3;

	// Restore bike mesh
	Mesh = OldMesh;
	bHidden = false;
	DukePlayer(AttachedPlayer).OverlayActor = none;

	// Reset bike physics
	ResetPhysics();

	Duke = None;
	AttachedPlayer=none;
	
	Disable('Tick');
}

//=============================================================================
//	MyPlaySound
//=============================================================================
function MyPlaySound(sound s)
{
	if (CurrentPlayingSound == s)
		return;

	CurrentSoundDuration = GetSoundDuration(s);
	PlaySound(s, SLOT_Interact);
	CurrentPlayingSound = s;
}

//=============================================================================
//	FixRotator
//=============================================================================
function FixRotator(out rotator r)
{
	r.Pitch = r.Pitch&65535;
	r.Yaw = r.Yaw&65535;
	r.Roll = r.Roll&65535;

	if (r.Pitch > (65535/2))
		r.Pitch -= 65535;
	if (r.Yaw > (65535/2))
		r.Yaw -= 65535;
	if (r.Roll > (65535/2))
		r.Roll -= 65535;
}

//=============================================================================
//	UnFixRotator
//=============================================================================
function UnFixRotator(out rotator r)
{
	if (r.Pitch < 0)
		r.Pitch += 65535;
	if (r.Yaw < 0)
		r.Yaw += 65535;
	if (r.Roll < 0)
		r.Roll += 65535;
}

//=============================================================================
//	FixInterpolator
//=============================================================================
function FixInterpolator(out rotator r)
{
	if (r.Pitch > (65535/2))
		r.Pitch -= 65535;
	else if (r.Pitch < -(65535/2))
		r.Pitch += 65535;
	
	if (r.Roll > (65535/2))
		r.Roll -= 65535;
	else if (r.Roll < -(65535/2))
		r.Roll += 65535;
	
	if (r.Yaw > (65535/2))
		r.Yaw -= 65535;
	else if (r.Yaw < -(65535/2))
		r.Yaw += 65535;

	r = Normalize(r);
}

//=============================================================================
//	GetCameraLocation
//	Determines where the players head should be relative to the bikes location
//=============================================================================
function vector GetCameraLocation(vector SrcLocation)
{
	local vector	NewLocation, NewLocation2;
	local vector	In, Up, Left;
	local rotator	r;

	In = vector(FinalRotation);

	r = Normalize(FinalRotation);
	r.Pitch = -r.Roll;
	r.Roll = 0;
	r.Yaw += 16384;		// Add 90 degres
	Up = In Cross vector(r);
	Left = Up Cross In;
	
	NewLocation = SrcLocation + Left*ViewOffset1.X + In*ViewOffset1.Y + Up*ViewOffset1.Z;

	// Modify location based on the wheelie pitch of the bike
	//	Should I just use the actual pitch? instead of wheeliepitch? 
	if (WheeliePitch > 0)
	{
		NewLocation2 = SrcLocation + Left*ViewOffset2.X + In*ViewOffset2.Y + Up*ViewOffset2.Z;
		NewLocation += (NewLocation2 - NewLocation)*FMin(WheeliePitch/6000, 1.0);
	}
	else if (WheeliePitch < 0)
	{
		NewLocation2 = SrcLocation + Left*ViewOffset3.X + In*ViewOffset3.Y + Up*ViewOffset3.Z;
		NewLocation += (NewLocation2 - NewLocation)*FMin(abs(WheeliePitch)/2000, 1.0);
	}

	return NewLocation;
}

//=============================================================================
//	QuadraticBlendVector
//	Simple Quadratic blending
//=============================================================================
function QuadraticBlendVector(vector a, vector b, vector c, out vector Result, float t)
{
	local vector	v1, v2;

	v1 = a+(b-a)*t;
	v2 = b+(c-b)*t;
	Result = v1+(v2-v1)*t;
}

//=============================================================================
//	QuadraticBlendRotator
//	Simple Quadratic blending
//=============================================================================
function QuadraticBlendRotator(rotator a, rotator b, rotator c, out rotator Result, float t)
{
	local rotator	r1, r2;

	r1 = a+Normalize(b-a)*t;
	r2 = b+Normalize(c-b)*t;
	Result = r1+Normalize(r2-r1)*t;
}

//=============================================================================
//	CalcView
//=============================================================================
function CalcView(out vector CameraLocation, out rotator CameraRotation)
{
	local vector	NewLocation, v;
	local rotator	r;
	
	if (LerpState != LS_Done)
	{
		if (LerpTime >= 0.5)
		{
			// Swap to the new mesh half way between interpolating view so they don't see it
			if (LerpState == LS_ToBike)
			{
				if (SwapMesh != None)
					Mesh = SwapMesh;
			}
			else
			{
				Mesh = OldMesh;
			}
			
			PlayAnim(Accel_Pull);
		}

		if (LerpTime >= 1.0)
		{
			// We are done, show the last frame, and let them ride the bike
			if (LerpState == LS_ToBike)
				LerpState = LS_Done;
			else
				LerpState = LS_FromBike2;

			LastCameraLocation = FinalLocation3;
			LastCameraRotation = FinalRotation3;
		}
		else
		{
			QuadraticBlendVector(FinalLocation1, FinalLocation2, FinalLocation3, LastCameraLocation, LerpTime);
			QuadraticBlendRotator(FinalRotation1, FinalRotation2, FinalRotation3, LastCameraRotation, LerpTime);

			LerpTime += LastDeltaSeconds*ViewInterpSpeed;		// 
		}
	}
	else
	{
		NewLocation = GetCameraLocation(Location);
		LastCameraRotation = Normalize(LastCameraRotation);
		FinalRotation = Normalize(FinalRotation);

		LastCameraLocation += (NewLocation - LastCameraLocation)*0.75;
		LastCameraLocation.X = NewLocation.X;
		LastCameraLocation.Y = NewLocation.Y;
	
		if(frand()<=RandomBumpinessPercent)
			LastCameraLocation.Z += (frand()*RandomBumpinessAmplitude*2-RandomBumpinessAmplitude)*FMax(CurrentSpeed/MaxSpeed*2,0.3);

		if (LastCameraLocation.Z > NewLocation.Z+7.5f)
			LastCameraLocation.Z = NewLocation.Z+7.5f;
		else if (LastCameraLocation.Z < NewLocation.Z-3.0f)
			LastCameraLocation.Z = NewLocation.Z-3.0f;

		r = Normalize(FinalRotation - LastCameraRotation);

		LastCameraRotation.Pitch += r.Pitch*ViewPitchDampen;
		LastCameraRotation.Yaw += r.Yaw*ViewYawDampen;
		LastCameraRotation.Roll += r.Roll*ViewRollDampen;

		//LastCameraRotation = FinalRotation;
	}

	CameraLocation = LastCameraLocation;
	CameraRotation = LastCameraRotation;
}

//=============================================================================
//	ResetPhysics
//=============================================================================
function ResetPhysics()
{
	local rotator		r;

	ForwardVelocity = vect(0,0,0);
	Velocity = vect(0,0,0);
	bBraking = false;
	bReverse = false;
	bSkidding = false;
	WheelSlip = 0;
	WheelieVelocity = 0;
	bCanJump = false;
	OldPitch = 0;
	bInReverseGear = false;
	CrashSpin = 0;
	WheeliePitch = 0;
	Rpm = 0;
	OnGround = true;
	AmbientSound = none;
	CrashSpin = 0;
	
	r = Rotation;
	//r.Pitch = 0;
	r.Roll = 0;
	SetRotation(r);
	
}

//=============================================================================
//	GetAnimSequenceEx
//=============================================================================
function name GetAnimSequenceEx(int channel)
{
	local MeshInstance m;

	m=GetMeshInstance();
	if(m==none) 
	{
//		BroadcastMessage("MeshInstance is none");
		return '';
	}
	return m.MeshChannels[channel].AnimSequence;
}

//=============================================================================
//	Upshift
//=============================================================================
function Upshift()
{
	if (bReverse)
		return;		// Can't change gears while reversing
	if (Gear==ArrayCount(MaxGearSpeed)-1) 
		return; // Already at top gear.
	if (CurrentSpeed>=MaxGearSpeed[Gear]*0.6) 
		Gear++;
}

simulated event RenderOverlays( canvas Canvas )
{
	bHidden = false;
	Canvas.SetClampMode( false );
	Canvas.DrawActor( self, false );
	Canvas.SetClampMode( true );
	bHidden = true;
}

//=============================================================================
//	Tick
//=============================================================================
function Tick(float DeltaSeconds)
{
	local rotator	r;
	
	//bHidden = true;

	// Remember this delta
	LastDeltaSeconds = DeltaSeconds;

	if (LastDeltaSeconds < 0.01)
		LastDeltaSeconds = 0.01;
	else if (LastDeltaSeconds > 0.1)
		LastDeltaSeconds = 0.1;

	// Tick dnDecoration:
	super.Tick(DeltaSeconds);

	// Take care of current sound stuff
	if (CurrentSoundDuration > 0)
		CurrentSoundDuration -= DeltaSeconds;
	
	if (CurrentSoundDuration <= 0)
		CurrentPlayingSound = None;

	// If we have a Duke, then see if he is hitting use key
	if (Duke != None)
	{
		if (Duke.bUse > 0 && OldbUse == 0)
		{
			// Hit the use key, see if we need to attach or detach
			if (AttachedPlayer == None)
				AttachPlayer(Duke); 
			else if (LerpState == LS_Done && abs(WheeliePitch)<500 && CurrentSpeed < 20 && OnGround && !bSkidding)
			{
				//DukePlayer(AttachedPlayer).OverlayActor = None;
				//bHidden = false;

				AttachedPlayer.DontUpdateEyeHeight=false;
				AttachedPlayer.SetPhysics(PHYS_Falling);
				AttachedPlayer.bCollideWorld=true;
				AttachedPlayer.SetCollision(true,true,true);
				AttachedPlayer.MountParent=none;
				AttachedPlayer.FireEvent='';
				AttachedPlayer.FireEventEnd='';
				AttachedPlayer.AltFireEvent='';
				AttachedPlayer.AltFireEventEnd='';
				AttachedPlayer.Velocity = vect(0,0,0);

				// First, make sure the player is at a good location... 
				AttachedPlayer.SetLocation(Location);		// Set player to bikes location

				if (!AttachedPlayer.FindSpot(false))
				{
					AttachedPlayer.ClientMessage("There is not enough room.");
				}
				else
				{
					AttachedPlayer.DropToFloor();

					// Getting off the bike, set of the iterpolating values
					FinalRotation1 = FinalRotation;
					FinalRotation1.Pitch = 0;
					FinalRotation2 = FinalRotation;
					FinalRotation2.Pitch = ViewInterpPitch;
					FinalRotation3 = AttachedPlayer.Rotation;

					FinalLocation1 = GetCameraLocation(AttachedPlayer.Location);
					FinalLocation3 = AttachedPlayer.Location + AttachedPlayer.BaseEyeHeight * vect(0,0,1);
					FinalLocation2 = FinalLocation1+(FinalLocation3-FinalLocation1)*0.91f;

					LerpState = LS_FromBike1;
					LerpTime = 0.0;
				}
			}
		}

		OldbUse = Duke.bUse;
	}

	// Final interpolating state to get off the bike, detach the player, and bail
	if (LerpState == LS_FromBike2)
	{
		if (AttachedPlayer != None)
			DetachPlayer();
		return;
	}

	// If no attached player, do nothing on tick:
	if (AttachedPlayer==none) 
		return;

	//AttachedPlayer.CollisionHeight = AttachedPlayer.default.CollisionHeight;

	// Handle standard player input
	if (AttachedPlayer.bFire > 0 && OldbFire == 0)
	{ 
		Clutch=true;  
		if (GetAnimSequenceEx(2)=='')
			PlayAnim('Clutch_Pull',,,2);
	}
	else if (AttachedPlayer.bFire == 0 && OldbFire > 0)
	{ 
		Clutch=false; 
		Upshift(); 
	}
	else if (AttachedPlayer.bAltFire > 0 && OldbAltFire == 0)
	{ 
		Horn=true;    
		if (GetAnimSequenceEx(2)=='') 
			PlayAnim(Horn_Pull,,,2); 
	}
	else if (AttachedPlayer.bAltFire == 0 && OldbAltFire > 0)
		Horn=false;

	OldbFire = AttachedPlayer.bFire;
	OldbAltFire = AttachedPlayer.bAltFire;
}

//=============================================================================
//	DoKeyPhysics
//=============================================================================
function DoKeyPhysics()
{
	// Root Keyring:
	KeyringVelocity+=Rotation.Roll;

	if(KeyringRoll>0)		
		KeyringVelocity-=KeyringGravity;
	else if(KeyringRoll<0)	
		KeyringVelocity+=KeyringGravity;

	KeyringRoll+=KeyringVelocity*LastDeltaSeconds;

	if(KeyringRoll>3000) 
	{ 
		KeyringRoll=3000; 
		
		if (KeyringVelocity>0) 
			KeyringVelocity *=-0.5; 
	}
	else if (KeyringRoll<-12000) 
	{ 
		KeyringRoll=-12000; 
		
		if (KeyringVelocity<0) 
			KeyringVelocity *=-0.8; 
	}

	if(CurrentSpeed<100) 
		KeyringRoll*=0.97;

	// Amst Key:
	AmstKeyringVelocity += Rotation.Roll*0.9+Rand(2)-1;

	if (AmstKeyringRoll>0)		
		AmstKeyringVelocity-=AmstKeyringGravity;
	else if (AmstKeyringRoll<0)	
		AmstKeyringVelocity+=AmstKeyringGravity;

	AmstKeyringRoll += AmstKeyringVelocity*LastDeltaSeconds;

	if (AmstKeyringRoll>2000) 
	{ 
		AmstKeyringRoll=2000; 

		if (AmstKeyringVelocity>0) 
			AmstKeyringVelocity*=-0.6; 
	}
	else if (AmstKeyringRoll<-2000) 
	{ 
		AmstKeyringRoll=-2000; 

		if (AmstKeyringVelocity<0) 
			AmstKeyringVelocity *=-0.6; 
	}

	if(CurrentSpeed<100) 
		AmstKeyringRoll*=0.97;

	// Keyhang Key:
	KeyKeyringVelocity += Rotation.Roll*1.1+Rand(2)-1;

	if (KeyKeyringRoll>0)		
		KeyKeyringVelocity-=KeyKeyringGravity;
	else if(KeyKeyringRoll<0)	
		KeyKeyringVelocity+=KeyKeyringGravity;

	KeyKeyringRoll += KeyKeyringVelocity*LastDeltaSeconds;

	if (KeyKeyringRoll>2500) 
	{ 
		KeyKeyringRoll=2500; 
	
		if (KeyKeyringVelocity>0) 
			KeyKeyringVelocity*=-0.75; 
	}
	else if (KeyKeyringRoll<-2500) 
	{ 
		KeyKeyringRoll=-2500; 
		if (KeyKeyringVelocity<0) 
			KeyKeyringVelocity*=-0.75; 
	}

	if(CurrentSpeed<100) 
		KeyKeyringRoll*=0.97;
}

//=============================================================================
//	ApplyGravityToVelocity
//=============================================================================
function ApplyGravityToVelocity()
{
	if (!OnGround)
		ForwardVelocity.Z += Region.Zone.ZoneGravity.Z*LastDeltaSeconds;
}

//=============================================================================
//	SetSkidding
//=============================================================================
function SetSkidding(bool Skid)
{
	bSkidding = Skid;
}

//=============================================================================
//	ApplyFrictionToVelocity
//=============================================================================
function ApplyFrictionToVelocity()
{
	local rotator	r;
	local vector	InVector, SideVector, UpVector;
	local float		FDist, SDist, UDist;

	// Clip up/down
	if (OnGround)
	{
		//if (UpVector2 Dot vect(0,0,1) > 0.8 && ForwardVelocity.Z < 0.0)
		if (ForwardVelocity.Z < 0.0)
			ForwardVelocity.Z = 0.0;
	}

	// only intersted in yaw
	r = Rotation; r.Pitch = 0.0; r.Roll = 0.0;

	// Get in
	InVector = vector(r);

	// Get left
	SideVector = Normal(InVector cross vect(0,0,1));
	UpVector = SideVector Cross InVector;

	// Get velocity magnitude in all directions
	FDist = (ForwardVelocity Dot InVector);
	SDist = (ForwardVelocity Dot SideVector);
	UDist = (ForwardVelocity Dot UpVector);

	ForwardVelocity = vect(0,0,0);

	// Turn Skidding on/off
	if (OnGround)
	{
		if (SkidSensitivity > 0 && abs(SDist) > (abs(FDist)/(2.4*SkidSensitivity)) && abs(SDist) > 5.0)
			SetSkidding(true);
		else if (bBraking)
		{
			if (SkidSensitivity > 0 && FDist > (MaxGearSpeed[4]*(0.5/SkidSensitivity)) )
				SetSkidding(true);
			else if (FDist < MaxGearSpeed[0])
				SetSkidding(false);
		}
		else 
			SetSkidding(false);
	}

	// Play some sounds if the bike is skidding
	// Only play a skid when they first go into it, then stop, and wait for it to reset
	if (CurrentPlayingSound != CrashSounds[0] && CurrentPlayingSound != CrashSounds[1])
	{
		if (bSkidding)
		{
			MyPlaySound(SkidSounds[1]);
			bCanPlaySkidSound = false;
		}
		else if (bBraking && (abs(SDist) > 10 || abs(FDist) > 50) && bCanPlaySkidSound)
		{
			MyPlaySound(SkidSounds[0]);			// Baby skid
			bCanPlaySkidSound = false;
		}
	}

	if ((abs(SDist) < 5 && abs(FDist) < 50) || !OnGround || !bBraking)
		bCanPlaySkidSound = true;

	// Clip forward back
	if (OnGround)
	{
		if (bSkidding)
			FDist *= (1.0f - FMin(ForwardFriction1*LastDeltaSeconds, 1.0f));
		else if (bBraking)
			FDist *= (1.0f - FMin(ForwardFriction2*LastDeltaSeconds, 1.0f));
		else
			FDist *= (1.0f - FMin(ForwardFriction3*LastDeltaSeconds, 1.0f));
	}
	else	// In air
		FDist *= (1.0f - FMin(ForwardFriction4*LastDeltaSeconds, 1.0f));

	if (FDist > MaxGearSpeed[Gear]) 
		FDist = MaxGearSpeed[Gear];
	else if (FDist < -MaxReverseSpeed)
		FDist = -MaxReverseSpeed;

	if (abs(FDist) < 50.0)
		FDist *= 0.999;

	if (FDist > 0.0 && abs(FDist) < 5.0)
		FDist = 0.0f;

	ForwardVelocity += InVector*FDist;

	// Clip left/right
	if (OnGround)
	{
		if (bSkidding)
			SDist *= (1.0f - FMin(SideFriction1*LastDeltaSeconds, 1.0f));
		else
			SDist *= (1.0f - FMin(SideFriction2*LastDeltaSeconds, 1.0f));
	}
	else
		SDist *= (1.0f - FMin(SideFriction3*LastDeltaSeconds, 1.0f));

	if (abs(SDist) < 50.0)
		SDist *= 0.999;

	if (abs(SDist) < 5.0)
		SDist = 0.0f;

	ForwardVelocity += SideVector*SDist;
	ForwardVelocity += UpVector*UDist;

	CurrentSpeed = VSize(ForwardVelocity);

	//BroadcastMessage("OnGround:"@OnGround@", Reverse:"@bReverse@", Skidding:"@bSkidding@",SDist:"@SDist@",FDist:"@FDist@",UDist:"@UDist);
	//BroadcastMessage("Skidding:"@bSkidding@"CanPlaySkidSound"@bCanPlaySkidSound);
}

//=============================================================================
//	MoveBike
//	Moves the bike by ForwardVelocity amount
//	Does not let bike penetrate world geometry
//	Modifies ForwardVelocity to slide/bounce along walls
//	Performs crash detection
//=============================================================================
function MoveBike()
{
	local vector	HitNormal, HitLocation, Delta;
	local vector	CHitNormal, CHitLocation;
	local float		HitTime, d;
	local int		Iterations;
	local rotator	r, r2;

	Iterations = 0;

	bHitWall = false;

	while (!MoveActor(ForwardVelocity*LastDeltaSeconds*1.5f, HitTime, HitNormal, HitLocation) && Iterations < 8)
	{
		// Actor did not move entire path, adjust Velocity, and clamp by remaining time
		d = (ForwardVelocity Dot HitNormal);

		ForwardVelocity -= HitNormal*d*1.1f;

		Iterations++;
		CHitNormal = HitNormal;
		CHitLocation = HitLocation;
		//BroadcastMessage("HitNormal:"@HitNormal@",HitTime:"@HitTime);
	}

	// if Iterations is > 0, we know we hit a wall.  Just use the last HitNormal, and d 
	if (Iterations > 0)
	{
		HitNormal = CHitNormal;
		HitLocation = CHitLocation;

		if (HitNormal Dot vect(0,0,1) < 0.2)		// Wall
		{
			r = Normalize(rotator(HitNormal*-1));
			r = Normalize(r - Normalize(Rotation));

			d *= CurrentSpeed*LastDeltaSeconds*0.1;

			if (abs(r.Yaw) < 16384)		// 90 degres
			{
				d *= (16384-abs(r.Yaw))/16384;

				if (r.Yaw < 0)
					CrashSpin -= d*CrashSpinScale;
				else
					CrashSpin += d*CrashSpinScale;
			}

			bHitWall = true;

			WheeliePitch *= 0.7;		// Make the nose come down when they hit a wall
		
			//BroadcastMessage(d);

			if (abs(d)*CrashSoundSensitivity > 200.0)
			{
				if (frand() > 0.5)
					MyPlaySound(CrashSounds[0]);
				else
					MyPlaySound(CrashSounds[1]);
			}
		}
	}
	
	//BroadcastMessage("OnGround:"@OnGround@",FV:"@ForwardVelocity);
}

//=============================================================================
//	GetGroundStatus
//	Determines whether the bike is on the ground
//	Move the bike up by GroundOffset amount, this is to allow it to pop up steps
//	Doing a wheelie modifies GroundOffset
//=============================================================================
function GetGroundStatus()
{
	local vector	HitNormal, HitLocation, OldLocation;
	local float		HitTime, Off2, Off3;

	OldLocation = Location;

	Off2 = GroundOffset;


	if (bCanJump && ForwardVelocity.Z <= 0)
		Off3 = 15.0f;
	//else if (ForwardVelocity.Z > 2)
	//	Off3 = 1.0f;
	else
		Off3 = 5.0f;

	Off2 += FMin(20.0f, (WheeliePitch/300.0)*WheelieHeightAdjScale);

	if (!MoveActor(vect(0,0,-(Off2+Off3)), HitTime, HitNormal, HitLocation))
	{
		if (HitNormal Dot vect(0,0,1) > 0.3)
		{
			if (!OnGround && bCanPLayLandSound)
			{
				bCanPlayLandSound = false;
				MyPlaySound(LandSound);
			}

			OnGround=true;
			UpVector2 = HitNormal;
			MoveActor(vect(0,0,Off2));
			LastOnGroundHeight = Location.Z;
		}
	}
	else
	{
		OnGround=false;
		UpVector2 = vect(0,0,1);
		SetLocation(OldLocation);
	}

	if (abs(Location.Z - LastOnGroundHeight) > WheelieLandSoundHeight)
		bCanPlayLandSound = true;

	//BroadcastMessage("OnGround:"@OnGround);
}

//=============================================================================
//	QuadraticBlendFloat
//=============================================================================
function QuadraticBlendFloat(float a, float b, float c, out float Result, float t)
{
	local float	f1, f2;

	f1 = a+(b-a)*t;
	f2 = b+(c-b)*t;
	Result = f1+(f2-f1)*t;
}

//=============================================================================
//	HandleTurning
//	Applies roll and yaw to bike
//	When turning, takes into account how much the back wheel is spinning
//	Also takes into account CrashSpin, kind of a hack, but it look cool :)
//=============================================================================
function HandleTurning(float aTurn, float aStrafe, out rotator r)
{
	local float	TurnVal, Temp;
	local float SpeedPercent;

	SpeedPercent = CurrentSpeed/MaxSpeed;

	// Apply roll
	if (aStrafe != 0)
		TurnVal = aStrafe*2.0;
	else
	{
		TurnVal = aTurn;
		TurnVal *= (15.0f/AttachedPlayer.MouseSensitivity);
	}

	Temp = FMin(CurrentSpeed/120, 1.0);

	r.Roll += Temp*TurnVal*abs(TurnVal*0.00004)*TurnScale*LastDeltaSeconds*40.0;		// Exponential steering

	r.Roll=(float(r.Roll)/10.0*9.92); 

	if (r.Roll > (65535/7))
		r.Roll = (65535/7);
	else if (r.Roll < -(65535/7))
		r.Roll = -(65535/7);

	// Apply turning (based off how much roll)
	Temp = float(r.Roll)*TurnScale*LastDeltaSeconds*40.0;
	
	if (!Clutch)
		Temp += float(r.Roll)*WheelSlip*LastDeltaSeconds*0.02;

	// Can't turn as much when in the air
	if (!OnGround)
		Temp *= 0.7;
	else
		Temp *= FMin(SpeedPercent, 0.2)*5.0f;

	if (bReverse && OnGround && !bSkidding)
		Temp = -Temp;	

	r.Yaw += Temp;
	r.Yaw += CrashSpin*LastDeltaSeconds*30.0f;

	if (bHitWall && abs(Temp) < 100 && CurrentSpeed < 300)
	{
		if (bReverse)
			r.Yaw -= TurnVal*LastDeltaSeconds*1.2;
		else
			r.Yaw += TurnVal*LastDeltaSeconds*1.2;
	}

	CrashSpin *= 0.98f;

	WheeliePitch *= 1 - (abs(float(r.Roll))*0.000001);		// Make the nose come down while turning
}


//=============================================================================
//	GroundNormal
//=============================================================================
function vector GroundNormal()
{
	local vector		TraceEnd, TraceLocation, TraceNormal;

	TraceEnd = Location - vect(0,0,1)*100.0f;

	if (Trace(TraceLocation, TraceNormal, TraceEnd, Location) != None)
		return TraceNormal;

	return vect(0,0,1);
}

//=============================================================================
//	HandleJump
//	Tries to detect when you are going over a "hump", and will bunnyhop the bike in this case
//	Looks pretty cool, and makes it feel more arcade like
//	It does this by checking when the nose of the bike is going back down
//	This should only happen when going up and over a hump...
//	Once the bike does a fake jump, it needs to be reset by coming to a flat 
//		pitch on the ground before it will jump again...
//=============================================================================
function HandleJump(rotator r)
{
	local float	Pitch, Temp;

	//Pitch = PitchFromVector(UpVector2);
	Pitch = PitchFromVector(GroundNormal());

	if (Pitch < 5 && OldPitch > float(MinAutoJumpPitch) && bCanJump)
	{
		if (CurrentSpeed > 100.0)
		{			
			Temp = (CurrentSpeed*0.08+OldPitch*0.04f)*JumpScale;
			
			if (Temp > MaxAutoJumpForce)
				Temp = MaxAutoJumpForce;

			ForwardVelocity.Z += Temp;
			bCanJump = false;
			
			//BroadcastMessage("Jump:"@Temp@", Pitch:"@OldPitch);
		}
	}
	
	if (OnGround && Pitch < 10 && !bCanJump || (CurrentSpeed < 50.0))
		bCanJump = true;		// Reset

	OldPitch = Pitch;		
}

//=============================================================================
//	HandleWheelie
//	Modifies WheelieVelocity based on acceleration
//	Applies WheelieVelocity to WheeliePitch
//	Applies gravity to WheelieVelocity
//	Models the shocks a little bit on a bike
//=============================================================================
function HandleWheelie(vector InVector)
{
	local float		Val;

	CurrentSpeed = VSize(ForwardVelocity);

	if (!bReverse)
	{
		if (CurrentSpeed > OldSpeed)
			//WheelieVelocity += 34*LastDeltaSeconds*40.0f;
			WheelieVelocity += FMin((CurrentSpeed-OldSpeed)*15.0, 34.0f)*LastDeltaSeconds*40.0f;
			//WheelieVelocity += CurrentSpeed*Gear*LastDeltaSeconds*0.2;
	}

	OldSpeed = CurrentSpeed;

	WheeliePitch += WheelieVelocity*LastDeltaSeconds*40.0f;

	if (bCanPlayLandSoundFromWheelie && WheeliePitch < 20)
	{
		bCanPlayLandSoundFromWheelie = false;
		MyPlaySound(LandSound);
	}

	if (WheeliePitch > WheelieLandSoundPitch)
		bCanPlayLandSoundFromWheelie = true;

	if (WheeliePitch > (65535/6))
		WheeliePitch = (65535/6);
	else if (WheeliePitch < -(65535/12))
		WheeliePitch = -(65535/12);

	if (WheeliePitch > 0)				// Above center
	{
		// Shock dampen
		if (WheeliePitch < ShockTightness1Angle && WheelieVelocity > 0)		// Going up, just starting
			WheelieVelocity *= ShockTightness1;
		else if (WheeliePitch >= ShockTightness1Angle && WheeliePitch < WheelieResistanceAngle && WheelieVelocity > 0)	// Going up, mid way
			WheelieVelocity *= (1.0-WheelieResistance);
		else if (WheelieVelocity > 0)						// We are in a wheelie
			WheelieVelocity *= 0.99-FMin(abs(WheeliePitch)/18000, 0.99);
		else
			WheelieVelocity *= 0.99;
	}
	else if (WheeliePitch < 0 && WheelieVelocity > 0)							// Below center Coming back up
	{
		WheelieVelocity *= ShockTightness2;
	}
	else if (WheeliePitch < 0 && WheelieVelocity < 0 && ShockDampening > 0)		// Below center, Going down
	{
		WheelieVelocity *= 0.99-FMin(abs(WheeliePitch)/(2000/ShockDampening), 0.99);
	}
	else
		WheelieVelocity *= 0.99;

	if (abs(WheeliePitch) < 150 && abs(WheelieVelocity) < 10)
	{
		WheeliePitch = 0;
		WheelieVelocity = 0;
	}

	if (bBraking && !bReverse)
	{
		if ((ForwardVelocity Dot InVector) <= 0)
			WheelieVelocity -= 50*LastDeltaSeconds*40.0f*FMin(CurrentSpeed/80,1);
		else
			WheelieVelocity += 50*LastDeltaSeconds*40.0f*FMin(CurrentSpeed/80,1);
	}

	if (WheeliePitch > 0)
		WheelieVelocity -= 26*LastDeltaSeconds*40.0f;
	else if (WheeliePitch < 0)
		WheelieVelocity += 26*LastDeltaSeconds*40.0f;

	if (abs(CrashSpin) > 100)
		WheeliePitch -= abs(CrashSpin)*0.2;

	//BroadcastMessage("WP:"@WheeliePitch@",WV:"@WheelieVelocity);
}

//=============================================================================
//	PitchFromVector
//	Returns the pitch the bike should be at based on the passed in normal
//=============================================================================
function float PitchFromVector(vector v)
{
	local rotator	r;
	local vector	InVector;
	
	r = Rotation;
	r.Pitch = 0.0;
	r.Roll = 0.0;
	
	// Get InVector from rotator, and reverse it
	InVector = vector(r)*-1.0;

	return (InVector Dot v)*(16384);		// * 90 degres
}

//=============================================================================
//	BikePhysics1
//	Main physics loop
//=============================================================================
function BikePhysics1(out float aForward,out float aLookUp,out float aTurn,out float aStrafe)
{
	local rotator	r, r2;
	local vector	InVector;
	local vector	ForwardVector;
	local float		Temp;

	if (LerpState != LS_Done)
		return;

	// Calculate forward vector (this is the direction to the wheels will add velocity to the bike)
	r = Rotation;
	r.Pitch = 0.0;
	r.Roll = 0.0;

	// Get InVector from rotator, and reverse it
	InVector = vector(r)*-1.0;

	UpVector += (UpVector2 - UpVector)*0.06f*LastDeltaSeconds*67.0f;
	UpVector = Normal(UpVector);

	r.Pitch = PitchFromVector(UpVector);

	ForwardVector = vector(r);

	CurrentSpeed = VSize(ForwardVelocity);

	r = Normalize(r);

	// Fake jump!
	HandleJump(r);

	// Reset bool's
	bBraking = false;
	bReverse = false;
	
	if (aForward>0)
	{
		if(!Clutch && OnGround) // Holding down the clutch, or being in the air negates acceleration.
		{
			// Add to our forward velocity
			//ForwardVelocity += ForwardVector*(Acceleration*(0.8+(1.0-CurrentSpeed/MaxGearSpeed[Gear])*0.2))*LastDeltaSeconds*FMax((float(Gear+1)/3.0),0.4f);
			ForwardVelocity += ForwardVector*Acceleration*(1.1-CurrentSpeed/MaxGearSpeed[Gear])*LastDeltaSeconds*(Gear+1);
		
			// This is totally faked out until we can get some real gear reduction type math in here :)
			ForwardVelocity += ForwardVector*Rpm*(4-Gear)*0.09;
			WheelieVelocity += Rpm*(4-Gear)*LastDeltaSeconds*30.0f*WheelieScale;
			WheelSlip += Rpm*(4-Gear)*LastDeltaSeconds*WheelSlipScale;
			Rpm *= 0.99;
			//BroadcastMessage("FV:"@ForwardVelocity);
		}
		
		if (Clutch && OnGround)		// Don't let rpm rev while in air
			Rpm += Acceleration*LastDeltaSeconds*0.05;

		if (Rpm > 50.0)
			Rpm = 50.0f;

		DrivableState=DS_Accelerating;
		
		if ((ForwardVelocity Dot InVector) < -1.0)
			bInReverseGear = false;
	} 
	else if (aForward<0)
	{
		if (OnGround)
		{
			if (CurrentSpeed > 15.0 && !bInReverseGear)
			{
				bBraking = true;
				DrivableState=DS_Braking;
			}
			else if (!bSkidding && DrivableState == DS_Idle)
			{
				bInReverseGear = true;
				// Add to our forward velocity
				ForwardVelocity -= ForwardVector*Acceleration*LastDeltaSeconds*0.5f;
			}
		}
	}
	else
	{
		DrivableState = DS_Idle;
		Rpm *= 0.70;
	} 

	WheelSlip *= 0.93;

	if (WheelSlip > 30)
	{
		if (bCanPlayWheelSlipSound || CurrentPlayingSound == SkidSounds[0])	// Let long skid sound override small skid sound
		{
			bCanPlayWheelSlipSound = false;
			MyPlaySound(SkidSounds[1]);
		}
	}
	else if (WheelSlip > 10 && CurrentPlayingSound != SkidSounds[1] && WheeliePitch < 2000)
	{
		if (bCanPlayWheelSlipSound)
		{
			MyPlaySound(SkidSounds[0]);		// only play small skid sound once
			bCanPlayWheelSlipSound = false;
		}
	}

	if (WheelSlip < 10)
		bCanPlayWheelSlipSound = true;		// Hack-a-rama
	
	CurrentSpeed = VSize(ForwardVelocity);

	if (CurrentSpeed > 0.01 && bInReverseGear)
		bReverse = true;
	
	// See if I downshift automatically:
	if(Gear>0)
	{
		if(CurrentSpeed<MaxGearSpeed[Gear-1]*0.6)
			Gear--;
	}

	if (aForward > 0 && OnGround)
		AmbientSound = GearSounds[Gear];
	else if (CurrentSpeed > -2.0 && CurrentSpeed < 2.0)
		AmbientSound=IdleSound;
	else
		AmbientSound=DecelerateSound;

	// Apply gravity to the velocity
	ApplyGravityToVelocity();

	// Clip && Apply friction to the velocity
	ApplyFrictionToVelocity();

	// Update orientation
	r2 = Rotation;
	r2.Pitch = r.Pitch+WheeliePitch;

	// Handle turning
	HandleTurning(aTurn, aStrafe, r2);

	// See if on ground
	GetGroundStatus();

	// Set the bike rotation
	FinalRotation = Normalize(r2);
	SetRotation(FinalRotation);

	FinalRotation.Pitch *= ViewPitchPercent;
	FinalRotation.Roll *= ViewRollPercent;
	FinalRotation.Yaw *= ViewYawPercent;

	HandleWheelie(InVector);

	MoveBike();
}

//=============================================================================
//	InputHook
// NJS: Input hook callback function:
//=============================================================================
function InputHook(out float aForward,out float aLookUp,out float aTurn,out float aStrafe,optional float DeltaTime)
//function InputHook(out float aForward,out float aLookUp,out float aTurn,out float aStrafe)
{
	// Super
	super.InputHook(aForward,aLookUp,aTurn,aStrafe);

	BikePhysics1(aForward, aLookUp, aTurn, aStrafe);

	// Zero out unneeded input:
	aForward=0; aTurn=0; aStrafe=0; aLookUp=0;

	// Do key physics
	DoKeyPhysics();

	if((AnimSequence==Idle)&&(DrivableState!=DS_Idle)) 
		AnimEnd();
}

//=============================================================================
//	OnEvalBones
//=============================================================================
function bool OnEvalBones(int channel)
{
	local MeshInstance minst;
	local int bone;
	local rotator r;

	if(channel!=3) return false;

	minst=GetMeshInstance();
	if(minst==none) return false;

	// Speedometer rotato:
	bone=minst.BoneFindNamed('SpeedNeedle');
	if(bone==0) return false;
	r=minst.BoneGetRotate(bone,false,true);
	minst.BoneSetRotate(bone,r,false);
	r.yaw=0;
	r.pitch=0;
	r.roll=-int((CurrentSpeed/MaxSpeed)*40000.0);
	minst.BoneSetRotate(bone,r,false,true);

	// Key Hierarchy:
	bone=minst.BoneFindNamed('Keyring');
	if(bone==0) return false;
	r=minst.BoneGetRotate(bone,false,true);
	minst.BoneSetRotate(bone,r,false);
	r.yaw=KeyringRoll;
	r.pitch=0;
	r.roll=0;
	minst.BoneSetRotate(bone,r,false,true);		

	// AmstXXX:
	bone=minst.BoneFindNamed('AmstXXX');
	if(bone==0) return false;
	r=minst.BoneGetRotate(bone,false,true);
	minst.BoneSetRotate(bone,r,false);
	r.yaw=AmstKeyringRoll;
	r.pitch=0;
	r.roll=0;
	minst.BoneSetRotate(bone,r,false,true);		

	// KeyHang:
	bone=minst.BoneFindNamed('Keyhang');
	if(bone==0) return false;
	r=minst.BoneGetRotate(bone,false,true);
	minst.BoneSetRotate(bone,r,false);
	r.yaw=KeyKeyringRoll;
	r.pitch=0;
	r.roll=0;
	minst.BoneSetRotate(bone,r,false,true);		

	return true;
}

//=============================================================================
//	AnimEnd
//=============================================================================
function AnimEnd()	// Animatiions drive the state machine.
{
	// Do nothing when deactivated:
	if(AnimSequence==Accel_Pull)
	{
		switch(DrivableState)
		{
			case DS_Idle:			PlayAnim(Accel_Release); break;
			case DS_Accelerating:	PlayAnim(Accel_Idle);    break;
			case DS_Braking:		PlayAnim(Accel_Release); break;
		}
	} 
	else if(AnimSequence==Accel_Release)
	{
		switch(DrivableState)
		{
			case DS_Idle:			PlayAnim(Idle);		  break;
			case DS_Accelerating:	PlayAnim(Accel_Pull); break;
			case DS_Braking:		PlayAnim(Brake_Pull); break;
		}
	} 
	else if(AnimSequence==Accel_Idle)
	{
		switch(DrivableState)
		{
			case DS_Idle:			PlayAnim(Accel_Release); break;
			case DS_Accelerating:	PlayAnim(Accel_Idle);    break;
			case DS_Braking:		PlayAnim(Accel_Release); break;
		}

	}
	else if(AnimSequence==Brake_Pull)
	{
		switch(DrivableState)
		{
			case DS_Idle:			PlayAnim(Brake_Release); break;
			case DS_Accelerating:	PlayAnim(Brake_Release); break;
			case DS_Braking:		PlayAnim(Brake_Idle);    break;
		}

	} 
	else if(AnimSequence==Brake_Release)
	{
		switch(DrivableState)
		{
			case DS_Idle:			PlayAnim(Idle);		  break;
			case DS_Accelerating:	PlayAnim(Accel_Pull); break;
			case DS_Braking:		PlayAnim(Accel_Pull); break;
		}
	} 
	else if(AnimSequence==Brake_Idle)
	{
		switch(DrivableState)
		{
			case DS_Idle:			PlayAnim(Brake_Release); break;
			case DS_Accelerating:	PlayAnim(Brake_Release); break;
			case DS_Braking:		PlayAnim(Brake_Idle);	 break;
		}
	} 
	else
	{
		switch(DrivableState)
		{
			case DS_Idle:			
				if(frand()<=0.01) 
					PlayAnim(RareIdle); 
				else 
					PlayAnim(Idle);			
			break;
			case DS_Accelerating:	PlayAnim(Accel_Pull); break;
			case DS_Braking:		PlayAnim(Brake_Pull); break;
		}
	}
}


//=============================================================================
//	AnimEndEx
//=============================================================================
function AnimEndEx(int channel)
{
	local name CurrentSequence;

	if(channel!=2) 
		return;

	CurrentSequence=GetAnimSequenceEx(channel);
	AttachedPlayer.AmbientSound=none;

	if(Clutch) 
	{
		if (CurrentSequence==Clutch_Pull || CurrentSequence==Clutch_Idle)	 	
			PlayAnim(Clutch_Idle,,,channel); 
		else if (CurrentSequence==Horn_Pull || CurrentSequence==Horn_Idle)		
			PlayAnim(Horn_Release,,,channel);
		else	
			PlayAnim(Clutch_Pull,,,channel);
	} 
	else if (Horn) 
	{
		if (CurrentSequence==Horn_Pull || CurrentSequence==Horn_Idle)			
		{ 
			AttachedPlayer.AmbientSound=HornSound; 
			PlayAnim(Horn_Idle,,,channel); 
		}
		else if (CurrentSequence==Clutch_Pull || CurrentSequence==Clutch_Idle) 
			PlayAnim(Clutch_Release,,,channel);
		else																
			PlayAnim(Horn_Pull,,,channel);
	}
	else
	{
		if (CurrentSequence==Clutch_Release || CurrentSequence==Horn_Release)  
			PlayAnim('',,,channel);
		else if (CurrentSequence==Horn_Pull || CurrentSequence==Horn_Idle)	    
			PlayAnim(Horn_Release,,,channel);
		else if (CurrentSequence==Clutch_Pull || CurrentSequence==Clutch_Idle) 
			PlayAnim(Clutch_Release,,,channel);
	}
}

//=============================================================================
//	Touch
//=============================================================================
function Touch( actor Other )
{
	Super.Touch(Other);

	// Only one Duke at a time please
	if (Duke == None && Other.IsA('DukePlayer'))
	{
		Enable('Tick');
		Duke = DukePlayer(Other);
	}
}

//=============================================================================
//	UnTouch
//=============================================================================
function UnTouch( actor Other )
{
	Super.UnTouch(Other);

	// Make sure it's the correct duke
	if (Other == Duke && AttachedPlayer == None)
	{
		Duke = None;
		Disable('Tick');
	}
}

//=============================================================================
//	defaultproperties
//=============================================================================
defaultproperties
{
	MaxSpeed=1400.000000
	Acceleration=750.000000
	TurnScale=0.070000

	IdleSound=Sound'a_transport.Motorcycles.MotoIdleLp05'
	DriveSound=Sound'a_transport.Motorcycles.MotoRunLp08'
	DecelerateSound=Sound'a_transport.Motorcycles.MotoDecelRunLp01'
	HornSound=Sound'dnGame.Motorcycle.BikeHorn'

	RevSound=Sound'a_transport.Motorcycles.MotoRevUpLp01'
	ClutchClick=Sound'a_transport.Motorcycles.MotoClutchClick01'
	
	GearSounds(0)=Sound'a_transport.Motorcycles.MotoAccelRunLp13b'
	GearSounds(1)=Sound'a_transport.Motorcycles.MotoAccelRunLp14b'
	GearSounds(2)=Sound'a_transport.Motorcycles.MotoAccelRunLp13b'
	GearSounds(3)=Sound'a_transport.Motorcycles.MotoAccelRunLp14b'
	GearSounds(4)=Sound'a_transport.Motorcycles.MotoAccelRunLp15b'

	CrashSounds(0)=sound'a_transport.wrecks.wreck01'
	CrashSounds(1)=sound'a_transport.wrecks.wreck02'

	SkidSounds(0)=Sound'a_transport.motorcycles.motoskid01'
	SkidSounds(1)=Sound'a_transport.motorcycles.motoskid03'

	LandSound=Sound'a_transport.motorcycles.MotoLand13'

	IdleAnimations(0)=IdleA
	
	MaxGearSpeed(0)=280
	MaxGearSpeed(1)=560
	MaxGearSpeed(2)=840
	MaxGearSpeed(3)=1120
	MaxGearSpeed(4)=1400

	TriggerRadius=50.000000
	TriggerHeight=50.000000

	Skin=None
	
	Mesh=DukeMesh'c_hands.hawg'
	SwapMesh=DukeMesh'c_hands.hawg'

	KeyringGravity=2500
	AmstKeyringGravity=2200
	KeyKeyringGravity=2200

	Accel_Pull=Accel_Pull
	Accel_Release=Accel_Release
	Accel_Idle=Accel_Idle
	Brake_Pull=Brake_Pull
	Brake_Release=Brake_Release
	Brake_Idle=Brake_Idle
	Idle=IdleA
	RareIdle=Idle_FlipOff
	DrivableState=DS_Idle
	Clutch_Pull=Clutch_Pull
	Clutch_Idle=Clutch_Idle
	Clutch_Release=Clutch_Release
	Horn_Pull=Horn_Push
	Horn_Idle=Horn_Idle
	Horn_Release=Horn_Release
	//bCollideWorld=False
	bCollideWorld=True
	
	RandomBumpinessAmplitude=0.2
	RandomBumpinessPercent=0.5
	
	UpVector=(X=0,Y=0,Z=1)
	UpVector2=(X=0,Y=0,Z=1)
	
	/*
	ForwardFriction1=0.990	   // Forward and Skidding    
	ForwardFriction2=0.94	   // Forward and Braking     
	ForwardFriction3=0.993	   // Forward velocity normal 
	ForwardFriction4=0.9999	   // Forward in air          
	*/
	/*
	SideFriction1=0.955		   // Side and Skidding       
	SideFriction2=0.922		   // Side normal             
	SideFriction3=0.9999	   // Side in air             
	*/

	ForwardFriction1=0.90		// Forward and Skidding    
	ForwardFriction2=3.00		// Forward and Braking     
	ForwardFriction3=0.50		// Forward velocity normal 
	ForwardFriction4=0.00001	// Forward in air          
							                              
	SideFriction1=2.80			// Side and Skidding       
	SideFriction2=5.00			// Side normal             
	SideFriction3=0.0001		// Side in air             

	SkidSensitivity=1.0

	ViewPitchPercent=0.7
	ViewYawPercent=1.0
	ViewRollPercent=0.8

	ViewPitchDampen=0.85
	ViewYawDampen=0.75
	ViewRollDampen=0.25

	ViewOffset1=(X= 0,Y= 0,Z=30)
	ViewOffset2=(X= 0,Y= -1,Z=34)
	ViewOffset3=(X= 0,Y=-6,Z=32)

	BikeMeshZOffset=-30.0

	WheelieScale=1.0
	WheelSlipScale=1.5

	ShockDampening=1.0
	WheelieResistance=0.17		// 17% resistance (1 = 100% resistance = no wheelies)
	WheelieResistanceAngle=2000
	ShockTightness1Angle=300
	ShockTightness1=0.70
	ShockTightness2=0.85

	ViewInterpSpeed=1.1
	ViewInterpPitch=13000

	CrashSoundSensitivity=1.0
	CrashSpinScale=1.0

	JumpScale=1.0
	MaxAutoJumpForce=600.0f;
	MinAutoJumpPitch=2100;

	MaxReverseSpeed=200.0

	GroundOffset=25.0

	bCollideActors=true
	bBlockActors=true
	
	CollisionRadius=50
	CollisionHeight=10

	WheelieLandSoundPitch=2000
	WheelieLandSoundHeight=20
	WheelieHeightAdjScale=1

	DontDie=true
	Health=0
}

