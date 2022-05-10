//=============================================================================
// dnPoolBall. (NJS)
//=============================================================================
class dnPoolBall expands dnBall;

// Sound imports:
#exec AUDIO IMPORT FILE=sounds\Break06.wav NAME="S_Break" GROUP=PoolBall
#exec AUDIO IMPORT FILE=sounds\RackEm01.wav NAME="S_Rack" GROUP=PoolBall
#exec AUDIO IMPORT FILE=sounds\PocketBall08.wav NAME="S_PocketSound" GROUP=PoolBall

var () sound		PocketSound;
var () sound		BreakSound;
var () sound		RackSound;

var () int			BallValue			?("Ball value (0-9).  0 = Cue Ball, 1-9 = Normal balls.");

var bool			bHitByCue;

// Master owns these
var dnPoolBall		Master;					// Master ball (the one cotrolling the game)
var dnPoolBall		Balls[10];				// All the balls on the table
var int				NumBalls;
var int				NumBallsIn;
var DukePlayer		Duke;
var	int				MasterResetCount;
var int				LastBallValue;

//=============================================================================
//	PreBeginPlay
//=============================================================================
function PreBeginPlay()
{
	local dnPoolBall	Ball;

	Super.PreBeginPlay();

	if (Master == None)		// No one has found a master
	{
		// The very first poolball will control the game.
		foreach allactors(class'dnPoolBall', Ball)
		{
			if (NumBalls >= ArrayCount(Balls))
				break;

			if (Ball.Master != None)
				continue;			// Already found a master

			Balls[NumBalls++] = Ball;
			Ball.Master = self;		// Notify other balls we are the master
		}
	}

	Super.PreBeginPlay();
}

//=============================================================================
//	PostBeginPlay
//=============================================================================
function PostBeginPlay()
{
	Super.PostBeginPlay();
}

//=============================================================================
//	Destroyed
//=============================================================================
function Destroyed()
{
	RemoveBall(self);

	Super.Destroyed();
}

//=============================================================================
//	AssignNewMaster
//=============================================================================
function AssignNewMaster(dnPoolBall OldMaster)
{
	local int			i;
	local dnPoolBall	NewMaster;

	if (OldMaster.Master != OldMaster)
		return;			// The oldmaster is not really isn't the master, imposter!

	for (i=0; i< OldMaster.NumBalls; i++)
	{
		if (OldMaster.Balls[i] != OldMaster)
			break;
	}

	if (i == OldMaster.NumBalls)
		return;			// Nobody left

	NewMaster = OldMaster.Balls[i];

	//BroadcastMessage("NewMaster:"@Balls[i].ItemName);

	// Assign new master to everyone
	for (i=0; i< OldMaster.NumBalls; i++)
		OldMaster.Balls[i].Master = NewMaster;
	
	// Copy master data over
	for (i=0; i< OldMaster.NumBalls; i++)
		NewMaster.Balls[i] = OldMaster.Balls[i];

	NewMaster.NumBalls = OldMaster.NumBalls;
	NewMaster.NumBallsIn = OldMaster.NumBallsIn;
	NewMaster.Duke = OldMaster.Duke;
	NewMaster.MasterResetCount = OldMaster.MasterResetCount;
}

//=============================================================================
//	RemoveBall
//=============================================================================
function RemoveBall(dnPoolBall Ball)
{
	local int		i;
	local bool		bFoundBall;

	// If this ball was the master, Give master rights to another ball
	if (Ball.Master == Ball)
		AssignNewMaster(Ball);

	bFoundBall = false;

	for (i=0; i< Master.NumBalls; i++)
	{
		if (bFoundBall)
		{
			Master.Balls[i-1] = Master.Balls[i];
			continue;
		}

		if (Master.Balls[i] == Ball)
			bFoundBall = true;
	}

	if (!bFoundBall)
	{
		BroadcastMessage("RemoveBall: Ball not found.");
		return;
	}

	SetResetState(Ball, RS_None);

	Master.NumBalls--;
}

//=============================================================================
// Script updates:
// Periodic update:
//=============================================================================
function Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);
}

//=============================================================================
//	MasterEnableTicks
//=============================================================================
function MasterEnableTicks()
{
	local int		i;

	for (i=0; i<Master.NumBalls; i++)
	{
		Master.Balls[i].Enable('Tick');
		Master.Balls[i].bUseTriggered=true;
		Master.Balls[i].bExaminable=false;
	}
}		

//=============================================================================
//	impartForce
//=============================================================================
function impartForce(vector force)
{
	Velocity=force;										// Normalize

	if(StickSound!=none) 
		PlaySound(StickSound,,3.0);	// Crack!
	
	SetRotation(rotator(Normal(Velocity)));
}

//=============================================================================
//	Trigger
//=============================================================================
function Trigger(actor Other, pawn EventInstigator )
{
	MasterEnableTicks();

	if (Master.MasterResetCount > 0)
	{
		//DukePlayer(EventInstigator).ClientMessage("Table is busy...");
		return;
	}

	Instigator=EventInstigator;
	Velocity=Location-EventInstigator.Location;	// Compute new direction
	Velocity.Z=0;
	impartForce(Normal(Velocity)*ImpulseMagnitude);
	
	if (DukePlayer(EventInstigator) != None)
	{
		Master.Duke = DukePlayer(EventInstigator);
		bHitByCue = false;
		//BroadcastMessage("Ball:"@ItemName@"Vel:"@Velocity);
	}

	Super.Trigger(Other, EventInstigator);
}

//=============================================================================
//	BallHitWall
//=============================================================================
function BallHitWall(vector HitNormal, actor Wall)
{
	local float		VelocitySize;

	if (bOnGround)
	{
		//Super.BallHitWall(HitNormal, Wall);
		VelocitySize = Velocity Dot HitNormal;
		Velocity -= HitNormal*VelocitySize*1.2f;
		return;
	}

	VelocitySize=VSize(Velocity);
	
	Velocity = MirrorVectorByNormal(Velocity, HitNormal);
	Velocity = Normal(Velocity)*VelocitySize*0.9;

	if(BumperSound!=none) 
		PlaySound(BumperSound);					// Crack!
}

//=============================================================================
// Collisions:
//=============================================================================
function HitWall(vector HitNormal, actor Wall)
{
	local dnPoolBall		Ball;

   	Ball = dnPoolBall(Wall);

	if (Ball != None)	// is this a ball?
    {
    	if (ItemName == "Cue Ball" || bHitByCue)	// If this ball was previously hit by the cue, or is the cue...
			Ball.bHitByCue = true;					//	then pass off the cue status to the new ball
		else
			Ball.bHitByCue = false;
	}

	Super.HitWall(HitNormal, Wall);
}

//=============================================================================
//	SetResetState
//=============================================================================
function SetResetState(dnBall Ball, EResetState State)
{
	if (Ball.ResetState == State)
		return;

	if (State == RS_Step1)
	{
		if (Ball.ResetState == RS_None)
			Master.MasterResetCount++;
	}
	else if (State == RS_Step2)
	{
	}
	else if (State == RS_None)
	{
		if (Ball.ResetState != RS_None)
			Master.MasterResetCount--;
		//BroadcastMessage("ResetDone:"@Master.MasterResetCount);
	}

	Super.SetResetState(Ball, State);
}

//=============================================================================
//=============================================================================
function MasterReset()
{
	local int		i;

	for (i=0; i< Master.NumBalls; i++)
		Master.Balls[i].Reset();

	Master.NumBallsIn = 0;
}

//=============================================================================
//	Reset
//=============================================================================
function Reset()
{
	bHitByCue = false;
	Super.Reset();
}

//=============================================================================
//	Touch
//=============================================================================
function Touch( actor Other )
{
	if(TriggerSetPhysics(Other)!=none && !bHidden)
	{
		if (ItemName == "Cue Ball")
		{
			//Master.Duke.ClientMessage("Scratch");
			Reset();				// Scratch
		}
		else if (!bHitByCue || (BallValue < Master.LastBallValue))
		{
			//Master.Duke.ClientMessage("Illegal shot");
			Reset();				// Illegal shot
		}
		else
		{
			Hide();
			Master.NumBallsIn++;

			Master.LastBallValue = BallValue;

			if (Master.NumBallsIn >= Master.NumBalls-1)		// Everything but the cue ball
			{
				//Master.Duke.ClientMessage("You Win!");
				MasterReset();
			}
		}

		if(PocketSound!=none) 
			PlaySound(PocketSound);
	}
}

//=============================================================================
//	defaultproperties
//=============================================================================
defaultproperties
{
	BallElasticity=0.500000
	PocketSound=Sound'dnGame.PoolBall.S_PocketSound'
	Ball2BallImpact(0)=Sound'dnGame.PoolBall.S_BallImpact2'
	Ball2BallImpact(1)=Sound'dnGame.PoolBall.S_BallImpact3'
	BreakSound=Sound'dnGame.PoolBall.S_Break'
	BumperSound=Sound'dnGame.PoolBall.S_Bumper'
	RackSound=Sound'dnGame.PoolBall.S_Rack'
	StickSound=Sound'dnGame.PoolBall.S_StickHitsCueBall'
	ImpulseMagnitude=300.000000
	bStasis=False
	//Physics=PHYS_Rolling
	bHitByCue=false

	FadeOutEffect=None
	FadeInEffect=None
	
	FadeOutSpeed=1.0
	FadeInSpeed=1.0

	BallValue=0
	
	BallGroundFriction=1.2
}
