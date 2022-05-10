//=============================================================================
// dnBall (JP)
//=============================================================================
class dnBall expands dnDecoration;

// Sound imports:
#exec AUDIO IMPORT FILE=sounds\BallImpact02.wav NAME="S_BallImpact2" GROUP=PoolBall
#exec AUDIO IMPORT FILE=sounds\BallImpact03.wav NAME="S_BallImpact3" GROUP=PoolBall
#exec AUDIO IMPORT FILE=sounds\BumperImpact05.wav NAME="S_Bumper" GROUP=PoolBall
#exec AUDIO IMPORT FILE=sounds\StickHitsCueBall01.wav NAME="S_StickHitsCueBall" GROUP=PoolBall

#exec OBJ LOAD FILE=..\Textures\CanvasFx.dtx

var () float		BallElasticity;
var bool			SetNewAcceleration;
var vector			NewAcceleration;

var () class <ParticleSystem> FadeOutEffect;
var () class <ParticleSystem> FadeInEffect;

var () sound		Ball2BallImpact[4];
var () sound		BumperSound;
var () sound		StickSound;

var () float		ImpulseMagnitude;
var () float		FadeOutSpeed;
var () float		FadeInSpeed;
var () texture		FadeOutTexture;
var () texture		FadeInTexture;
var () float		BallGroundFriction;
var () float		BallPushVelocityScale;

var vector			OriginalLocation;
var enum			EResetState {RS_None, RS_Step1, RS_Step2} ResetState;
var vector			ResetLocation1;
var vector			ResetLocation2;
var vector			ResetLocation3;
var vector			ResetLocation4;
var float			ResetTime;

var texture			OldTexture;

var float			LastDeltaTime;
var bool			bOnGround;

//=============================================================================
//	PreBeginPlay
//=============================================================================
function PreBeginPlay()
{
	local int		i;

	Super.PreBeginPlay();
   	
	//SetPhysics(PHYS_Rolling);
	OriginalLocation = Location;
    
	for ( i=0; i < ArrayCount(FragType); i++ )
		FragType[i] = None;

	for ( i=0; i < ArrayCount(SpawnOnDestroyed); i++ )
		SpawnOnDestroyed[i].SpawnClass = None;
}

//=============================================================================
//	PostBeginPlay
//=============================================================================
function PostBeginPlay()
{
	Super.PostBeginPlay();
	OldTexture = MultiSkins[0];
}

//=============================================================================
//	SetResetState
//=============================================================================
function SetResetState(dnBall Ball, EResetState State)
{
	//BroadcastMessage("Trying to change State:"@State);

	if (Ball.ResetState == State)
		return;

	//BroadcastMessage("Changing State:"@State);

	if (State == RS_Step1)
	{
		Ball.Style=STY_Translucent;
		Ball.ResetLocation1 = Location;
		Ball.ResetLocation2 = Location + Normal(Location-OriginalLocation)*5;
		Ball.ResetLocation3 = OriginalLocation + Normal(OriginalLocation-Location)*5;
		Ball.ResetLocation4 = OriginalLocation;
		
		Ball.ResetLocation2.Z += 15.0f;
		Ball.ResetLocation3.Z += 15.0f;

		//Ball.SetPhysics(PHYS_Rolling);

		Ball.bblockactors=true;
		Ball.bCollideWorld=true;
		Ball.bHidden=false;

		Ball.Velocity = vect(0,0,0);

		if (FadeOutEffect != None)
			Ball.Spawn(FadeOutEffect);

		if (FadeOutTexture != None)
			Ball.MultiSkins[0] = FadeOutTexture;
	}
	else if (State == RS_Step2)
	{
		Ball.Style=STY_Translucent;
		Ball.SetLocation(OriginalLocation);

		if (FadeInTexture != None)
			Ball.MultiSkins[0] = FadeInTexture;

		if (FadeInEffect != None)
			Ball.Spawn(FadeInEffect);
	}
	else if (State == RS_None)
	{
		Ball.SetLocation(OriginalLocation);
		Ball.bblockactors=true;
		Ball.bCollideWorld=true;
		//Ball.SetPhysics(PHYS_Rolling);
		Ball.Velocity = vect(0,0,0);
		Ball.bHidden=false;
		Ball.MultiSkins[0] = OldTexture;
			
		Ball.Style = default.Style;
		Ball.ScaleGlow = 1.0f;
	}

	Ball.ResetState = State;
	ResetTime = 0.0;
}

// Ball specific functions:
//=============================================================================
//	CubicBlendVector
//	Simple Cubic blending
//=============================================================================
function CubicBlendVector(vector a, vector b, vector c, vector d, out vector Result, float t)
{
	local vector	v1, v2, v3;

	v1 = a+(b-a)*t;
	v2 = b+(c-b)*t;
	v3 = c+(d-c)*t;

	v1 = v1+(v2-v1)*t;
	v2 = v2+(v3-v2)*t;

	Result = v1+(v2-v1)*t;
}

//=============================================================================
// Script updates:
// Periodic update:
//=============================================================================
function Tick(float DeltaTime)
{
	local vector		v;
	local float			d;
	local rotator		r;

	bUseTriggered=true;
	bExaminable=false;
	
	d = VSize(Velocity*vect(1,1,0));

	if (d > 0.05)
	{
		r = Rotation;
		r.Pitch = 0;
		r = Slerp(DeltaTime*7.0, r, rotator(Normal(Velocity*vect(1,1,0))) );
		r.Pitch = Rotation.Pitch;		// Preserve pitch
		
		SetRotation(r+rot(1,0,0)*(-2000*d*DeltaTime));
	}
	else
		Velocity *= vect(0,0,1);

	if (ResetState != RS_None)
	{
		bblockactors=false;
		bCollideWorld=false;

		SetPhysics(PHYS_None);
		Velocity = vect(0,0,0);
		
		if (ResetTime >= 1.0)
		{
			//BroadcastMessage("Done.");

			if (ResetState == RS_Step1)
				SetResetState(self, RS_Step2);
			else if (ResetState == RS_Step2)
				SetResetState(self, RS_None);
		}
		
		if (ResetState == RS_Step1)
		{
			ScaleGlow = 1.0-(ResetTime/0.5f);		// Fade out
			ResetTime += DeltaTime*FadeOutSpeed;
		}
		else if (ResetState == RS_Step2)
		{
			ScaleGlow = ResetTime/1.0f;				// Fade back in
			ResetTime += DeltaTime*FadeInSpeed;
		}
		
		/*
		CubicBlendVector(ResetLocation1, ResetLocation2, ResetLocation3, ResetLocation4, v, ResetTime);
		SetLocation(v);
		*/
	}
	
	MoveBall(DeltaTime);

	LastDeltaTime = DeltaTime;
}

//=============================================================================
//	Trigger
//=============================================================================
function Trigger(actor Other, pawn EventInstigator )
{
}

//=============================================================================
//	TakeDamage
//=============================================================================
function TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType )
{
	//Velocity -= Momentum*LastDeltaTime;
	Velocity += Normal(Location - EventInstigator.Location)*vect(1,1,0)*LastDeltaTime*4000.0f;
	Velocity.Z += 11000.0f*LastDeltaTime;
}

//=============================================================================
//	MoveBall
//=============================================================================
function MoveBall(float DeltaSeconds)
{
	local vector	HitNormal, HitLocation, Delta;
	local vector	CHitNormal, CHitLocation;
	local actor		HitActor, CHitActor;
	local float		HitTime, d;
	local int		Iterations;
	//local vector	OldLocation;

	Iterations = 0;

	//BroadcastMessage(FMin(BallGroundFriction*DeltaSeconds, 1.0));

	/*
	OldLocation = Location;

	if (!MoveActor(vect(0,0,-0.1)))
	{
		if (Velocity.Z < 0)
			Velocity.Z = 0.0f;

		bOnGround = true;
	}
	else
	{
		SetLocation(OldLocation);
		bOnGround = false;
	}
	*/

	// Apply friction+Acceleration
	Velocity *= 1.0-FMin(BallGroundFriction*DeltaSeconds, 1.0);
	Velocity += Acceleration * DeltaSeconds;

	if (!bOnGround && ResetState == RS_None)
		Velocity.Z += Region.Zone.ZoneGravity.Z*DeltaSeconds;

	Delta = Velocity*DeltaSeconds;

	while (VSize(Delta) > 0.0001 && !MoveActor(Delta, HitTime, HitNormal, HitLocation, HitActor) && Iterations < 8)
	{
		// Actor did not move entire path, adjust Velocity, and clamp by remaining time
		d = (Delta Dot HitNormal);

		Delta = (Delta-HitNormal*d*1.001f)*(1-HitTime);

		Iterations++;
		CHitNormal = HitNormal;
		CHitLocation = HitLocation;
		CHitActor = HitActor;
	}

	bOnGround = false;

	// if Iterations is > 0, we know we hit a wall.  Just use the last HitNormal, and d 
	if (Iterations > 0)
	{
		HitNormal = CHitNormal;
		HitLocation = CHitLocation;
		HitACtor = CHitActor;

		if (HitNormal Dot vect(0,0,1) > 0.7)
		{
			bOnGround = true;

			if (Velocity.Z < 0)
				Velocity.Z = 0.0f;
		}

		// Call the HitWall function
		HitWall(HitNormal, HitActor);
	}
}

//=============================================================================
//	PushedByMover
//=============================================================================
function PushedByMover(actor Other, vector PushedVelocity)
{
	//BroadcastMessage(Name@" was pushed by:"@Other.Name);
	Velocity += PushedVelocity*LastDeltaTime*10000.0f*BallPushVelocityScale;
	//Velocity += PushedVelocity*LastDeltaTime*3000.0f;
	//Velocity += PushedVelocity*VSize(Velocity)*LastDeltaTime*100.0f;
}

//=============================================================================
//	BallHitBall
//=============================================================================
function BallHitBall(vector HitNormal, dnBall OtherBall)
{
	local float		VelocitySize, otherVelocitySize;
	local vector	vectorToCenter;
	local float		transferPercent;
    	
	VelocitySize=VSize(Velocity);
	otherVelocitySize=VSize(OtherBall.Velocity);
    	
    // Compute transfer percent:
    vectorToCenter=OtherBall.Location-Location;
    vectorToCenter.Z=0;
    vectorToCenter=Normal(vectorToCenter);
    	
    transferPercent=Normal(Velocity) dot vectorToCenter;
    transferPercent=Abs(transferPercent);
    	
 	OtherBall.velocity+=vectorToCenter * (VelocitySize*(transferPercent))*BallElasticity;

    // Compute my velocity:
	Velocity -= (vectorToCenter * (VelocitySize*(1.0-transferPercent)))*(2.0-BallElasticity); 
	
	if ((transferPercent>0.05)&&(VelocitySize>10))
		PlaySound(Ball2BallImpact[Rand(256)&1],,transferPercent);					// Crack!
}

//=============================================================================
//	BallHitWall
//=============================================================================
function BallHitWall(vector HitNormal, actor Wall)
{
	local float		VelocitySize;

	VelocitySize=VSize(Velocity);

	Velocity = Velocity - HitNormal*((Velocity Dot HitNormal)*1.32f);

	if(BumperSound!=none) 
		PlaySound(BumperSound);					// Crack!
}

//=============================================================================
// Collisions:
//=============================================================================
function HitWall(vector HitNormal, actor Wall)
{
	local dnBall	Other;

    Other = dnBall(Wall);

	if (Other != None)	// is this a ball?
		BallHitBall(HitNormal, Other);
	else				// Collision with a wall
		BallHitWall(HitNormal, Wall);
}

//=============================================================================
//	Reset
//=============================================================================
function Reset()
{
	SetResetState(self, RS_Step1);
}

//=============================================================================
//	Hide
//=============================================================================
function Hide()
{
	bblockactors=false;
	bCollideWorld=false;
	bHidden=true;
}

//=============================================================================
//	defaultproperties
//=============================================================================
defaultproperties
{
	BallElasticity=0.500000
	Ball2BallImpact(0)=Sound'dnGame.PoolBall.S_BallImpact2'
	Ball2BallImpact(1)=Sound'dnGame.PoolBall.S_BallImpact3'
	BumperSound=Sound'dnGame.PoolBall.S_Bumper'
	StickSound=Sound'dnGame.PoolBall.S_StickHitsCueBall'
	ImpulseMagnitude=300.000000
	bStasis=False
	//Physics=PHYS_Rolling
	Physics=PHYS_None

	FadeOutEffect=None
	FadeInEffect=None
	
	FadeOutSpeed=1.0
	FadeInSpeed=1.0

	FadeOutTexture=texture'CanvasFX.Monitors.Static64'
	FadeInTexture=texture'CanvasFX.Monitors.Static64'
	BallGroundFriction=1.0
	BallPushVelocityScale=1.0
}
