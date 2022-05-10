//=============================================================================
// dnPinballBumper. (NJS)
// a pinball bumper
//=============================================================================
class dnPinballBumper expands dnDecoration;

var () vector			BumpForce;
var () sound			BumperSound;
var () bool				Enabled;		// Manipulated by TriggerPinballBumper and our trigger function
var () bool				ForceFromDirection;

var () name				GameName;

var () enum EPinBallTriggerType
{
	PT_None,							// Don't do anything extra
	PT_SpawnBall,						// Spawns a ball at this location
	PT_StartGame,						// Starts the game, and spawns a ball at this loc
	PT_EnableOnTrigger,					// Enable when trigger is called, then reset after bump
	PT_AddToBalls,						// Adds to the players balls
	PT_AddToBallsAndSpawn,				// Adds to balls, then spawns a ball (can be used for free balls)
	PT_Tilt,
	PT_AddToScore,						// Adds to score
	PT_AddToMultiplier,					// Adds amount to multiplier value
} PinBallTriggerType;

var () enum EPinBallBumpType
{
	PB_None,							// Don't do anything extra
	PB_AddToScore,						// Adds to score
	PB_AddToMultiplier,					// Adds amount to multiplier value
	PB_RemoveBall,						// Removes ball from table
	PB_AddToBalls
} PinBallBumpType;

var () int				Amount;			// For AddToScore, and AddToMultiplier

var () vector			TiltVelocity;

var dnPinBallTable		PinBallTable;
var bool				OldEnable;

var dnPinBall			CurrentPinball;
					
//=============================================================================
//	PostBeginPlay
//=============================================================================
function PostBeginPlay()
{
	local dnPinBallTable		Table;

	// Find the pooltable that controls this trigger
	foreach allactors(class'dnPinBallTable', Table)
	{
		if (Table.GameName != GameName)
			continue;			// Not part of this game

		PinBallTable = Table;
	}

	Super.PostBeginPlay();
}

//=============================================================================
//	Reset
//=============================================================================
function Reset()
{
}

//=============================================================================
//	Tick
//=============================================================================
function Tick(float DeltaSeconds)
{
	Super.Tick(DeltaSeconds);
	
	if (!Enabled)
		return;

	if (CurrentPinball == None)
		return;

	if (PinBallTable != None)
	{
		switch (PinBallBumpType)
		{
			case PB_AddToScore: 
				PinBallTable.AddToPlayerScore(Amount);
				break;
			case PB_AddToMultiplier:
				PinBallTable.AddToPlayerMultiplier(Amount);
				break;
			case PB_RemoveBall:
				PinBallTable.RemoveBall(CurrentPinball);
				return;
			case PB_AddToBalls:
				PinBallTable.AddToPlayerBalls(Amount);
				break;
		}
	}

	BumperHit(CurrentPinball);
	CurrentPinball = None;			// Only bump once per touch
}

//=============================================================================
//	BumperHit
//=============================================================================
function BumperHit(actor other)
{
	local dnPinBall		pb;
	local vector		newForce;
	
	if (!Enabled) 
		return;		// Ignore when not enabled.
	
	pb=dnPinBall(other);

	if(pb==none) 
		return; 	// Other isn't a ball

	if (VSize(BumpForce) <= 0.0)
		return;

	if (ForceFromDirection)
		newForce = vector(Rotation);
	else
		newForce = Normal(pb.location-Location);

	newForce = newForce*BumpForce;

	pb.Velocity = newForce;
	pb.Enable('tick');
		
	if(bumperSound!=none) 
		PlaySound(bumperSound);
		
	if (PinBallTriggerType == PT_EnableOnTrigger)
		Enabled = false;		// Reset if we are a PT_EnableOnTrigger
}

//=============================================================================
//	Trigger
//=============================================================================
function Trigger( actor Other, pawn EventInstigator )
{
	if (PinBallTable != None)
	{
		switch (PinBallTriggerType)
		{
			case PT_SpawnBall:
				PinBallTable.SpawnBall(Location);
				break;
			case PT_StartGame:
				PinBallTable.StartGame(1, Location);
				break;
			case PT_EnableOnTrigger:
				Enabled = true;
				break;
			case PT_AddToBalls:
				PinBallTable.AddToPlayerBalls(Amount);
				break;
			case PT_AddToBallsAndSpawn:
				PinBallTable.AddToPlayerBalls(Amount);
				PinBallTable.SpawnBall(Location);
				break;
			case PT_Tilt:
				PinBallTable.Tilt(TiltVelocity);
				break;
			case PT_AddToScore: 
				PinBallTable.AddToPlayerScore(Amount);
				break;
			case PT_AddToMultiplier:
				PinBallTable.AddToPlayerMultiplier(Amount);
				break;
		}
	}

	super.Trigger(Other,EventInstigator);
}

//=============================================================================
//	Touch
//=============================================================================
function Touch( actor Other )
{
	super.Touch(Other);
	
	CurrentPinball = dnPinBall(Other);

	if (CurrentPinball != None)
		Enable('Tick');
}

//=============================================================================
//	UnTouch
//=============================================================================
function UnTouch( actor Other )
{
	Super.UnTouch(Other);

	Disable('Tick');

	CurrentPinball = None;
	
	if (PinBallTriggerType == PT_EnableOnTrigger)
		Enabled = false;		// Reset if we are a PT_EnableOnTrigger
}


//=============================================================================
//	defaultproperties
//=============================================================================
defaultproperties
{
     BumpForce=(X=0.0,Y=0.0,Z=0.0)
     Enabled=True
	 bBlockActors=false
	 ForceFromDirection=false
}
