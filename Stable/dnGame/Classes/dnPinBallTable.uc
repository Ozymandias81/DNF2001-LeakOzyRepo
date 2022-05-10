//=============================================================================
// dnPinBallTable (JP)
//=============================================================================
class dnPinBallTable expands Dispatchers;

#exec OBJ LOAD FILE=..\Textures\t_fonts.dtx

var () TextureCanvas	ScoreBoardCanvas;				// The canvas that we will draw the scores into
var () Texture			BackGroundTexture;
var () byte 			BackgroundColor;				// Background color.
var () name				GameName;
var () font				PinballFont;

var () float			MaxTilt;
var () float			TiltSensitivity;
var () float			TiltResetSpeed;

var () name				StartGameEvent;
var () name				GameOverEvent;
var () name				TiltEvent;

var () struct SPlayer
{
	var	int				Score; 
	var int				Balls;
	var bool			bActive;						// false = GameOver for this player
	var int				Multiplier;						// Current Score multiplier for this player
	var () int			ScorePosX;
	var () int			ScorePosY;
	var () int			BallPosX;
	var () int			BallPosY;
} Players[4];

var () bool				bDrawBalls;
var () int				StartingBalls;

var int					CurrentPlayerIndex;				// The pinball table keeps track of the current player
var bool				bIsPlaying;
var	int					NumPlayers;
var int					NumActivePlayers;


var dnPinBall			Balls[4];						// Balls currently on the table
var int					NumBalls;						// Number of balls on the table

var dnPinBallBumper		Bumpers[64];
var int					NumBumpers;

var vector				StartBallLoc;
var bool				bRenderScoreBoard;

var bool				bTilt;
var vector				TiltVelocity;
var float				OverTilt;
var bool				bOverTilted;

//=============================================================================
//	PostBeginPlay
//=============================================================================
function PostBeginPlay()
{
	local dnPinBallBumper		t;

	Super.PostBeginPlay();

	Disable('Tick');

	// Find all the Bumpers to reset when ResetGame is called
	foreach allactors(class'dnPinBallBumper', t)
	{
		if (NumBumpers >= ArrayCount(Bumpers))
			break;

		if (t.GameName != GameName)
			continue;			// Not part of this game

		Bumpers[NumBumpers++] = t;
	}

	ResetGame();
}

//=============================================================================
//	ResetGame
//=============================================================================
function ResetGame(optional bool bRender)
{
	local int		i;

	//BroadcastMessage("ResetGame");

	CurrentPlayerIndex = 0;

	// Reset all the Bumpers
	for (i=0; i< NumBumpers; i++)
		Bumpers[i].Reset();

	// Reset the players
	for (i=0; i< ArrayCount(Players); i++)
	{
		Players[i].Score = 0;
		Players[i].Balls = 0;
		Players[i].bActive = false;
		Players[i].Multiplier = 1;
	}

	// Remove all balls from the table
	RemoveAllBalls();
	
	bRenderScoreBoard = true;
	bIsPlaying = false;
}

//=============================================================================
//	RemoveAllBalls
//=============================================================================
function RemoveAllBalls()
{
	local int		i;

	for (i=0; i< ArrayCount(Balls); i++)
	{
		if (Balls[i] != None)
		{
			Balls[i].Destroy();
			Balls[i] = None;
		}
	}

	NumBalls = 0;
}

//=============================================================================
//	StartGame
//=============================================================================
function StartGame(int NPlayers, vector BallLoc)
{
	local int		i;

	if (bIsPlaying)
		return;				// Already playing

	ResetGame(false);

	//BroadcastMessage("StartGame");

	NumPlayers = NPlayers;
	NumActivePlayers = NPlayers;

	if (NumPlayers > ArrayCount(Players))
		NumPlayers = ArrayCount(Players);

	for (i=0; i< NumPlayers; i++)
	{
		Players[i].Balls = StartingBalls;
		Players[i].bActive = true;
	}

	StartBallLoc = BallLoc;
	SpawnBall(BallLoc);

	bIsPlaying = true;
	
	bRenderScoreBoard = true;
	Enable('Tick');
	
	if (StartGameEvent != '')
		GlobalTrigger(StartGameEvent);
}

//=============================================================================
//	Tick
//=============================================================================
function Tick(float DeltaSeconds)
{
	local int		i;

	if (bTilt && !bOverTilted)
	{
		OverTilt += DeltaSeconds*TiltSensitivity;

		if (OverTilt > MaxTilt)
		{
			if (TiltEvent != '')
			{
				GlobalTrigger(TiltEvent);
				//BroadcastMessage("TILT EVENT!!!!!");
			}

			BroadcastMessage("TILT!");
			bOverTilted = true;
		}
		else
		{
			for (i=0; i< NumBalls; i++)
				Balls[i].Velocity += TiltVelocity*DeltaSeconds;
		}
	}
	
	bTilt = false;
	
	OverTilt -= TiltResetSpeed*DeltaSeconds;

	if (OverTilt < 0.0001)
	{
		if (bOverTilted)
			bOverTilted = false;

		OverTilt = 0.0f;
	}

	//BroadcastMessage("Tilt:"@OverTilt);

	if (bRenderScoreBoard)
	{
		RenderScoreBoard();
		bRenderScoreBoard = false;
	}
	
	if (!bIsPlaying)
		Disable('Tick');
}

//=============================================================================
//	DrawNumber
//=============================================================================
function DrawNumber(int x, int y, int num, bool bRightJustify)
{
	local string	NumString;
	local float		XSize, YSize;
	
	NumString = string(num);

	//ScoreBoardCanvas.TextSize(Left(NumString,Len(NumString)-1), XSize, YSize, PinballFont);
	ScoreBoardCanvas.TextSize(NumString, XSize, YSize, PinballFont);

	x -= XSize;

	ScoreBoardCanvas.DrawString(PinballFont, x, y, NumString);
}

//=============================================================================
//	RenderScoreBoard
//=============================================================================
function RenderScoreBoard()
{
	local int		i;
	
	if (ScoreBoardCanvas == None)
		return;

	// Clear the background (use BackGroundTexture if they supply one)
	if (BackGroundTexture != None)
		ScoreBoardCanvas.DrawBitmap(0,0,0,0,0,0,BackGroundTexture);
	else
		ScoreBoardCanvas.DrawClear(BackgroundColor);

	// Draw the balls if told so
	if (bDrawBalls)
	{
		for (i=0; i< NumPlayers; i++)
			DrawNumber(Players[i].BallPosX, Players[i].BallPosY, Players[i].Balls, true);
	}

	// Draw the scores
	for (i=0; i< NumPlayers; i++)
		DrawNumber(Players[i].ScorePosX, Players[i].ScorePosY, Players[i].Score, true);
}

//=============================================================================
//	ValidatePlayerIndex
//=============================================================================
function ValidatePlayerIndex(int PlayerIndex)
{
	if (!Players[PlayerIndex].bActive)
		BroadcastMessage("ValidatePlayerIndex: Player is not active...");
}

//=============================================================================
//	GameOver
//	GameOver for everyone
//=============================================================================
function GameOver()
{
	//ResetGame(true);
	bIsPlaying = false;
	BroadcastMessage("Game Over");
	
	if (GameOverEvent != '')
		GlobalTrigger(GameOverEvent);
}		

//=============================================================================
//	PlayerGameOver
//	GameOver for a particular player
//=============================================================================
function PlayerGameOver()
{
	if (!Players[CurrentPlayerIndex].bActive)
	{
		BroadcastMessage("PlayerGameOver: Player is not active...");
		return;
	}

	Players[CurrentPlayerIndex].bActive = false;		// GameOver for this player
	NumActivePlayers--;

	if (NumActivePlayers <= 0)
		GameOver();							// GameOver for everyone
}

//=============================================================================
//	AddToPlayerScore
//=============================================================================
function AddToPlayerScore(int Amount)
{
	ValidatePlayerIndex(CurrentPlayerIndex);
	Players[CurrentPlayerIndex].Score += Amount*Players[CurrentPlayerIndex].Multiplier;
	bRenderScoreBoard = true;
	//BroadcastMessage("Add To Score:"@Amount@"Score:"@Players[CurrentPlayerIndex].Score);
}

//=============================================================================
//	AddToPlayerMultiplier
//=============================================================================
function AddToPlayerMultiplier(int Amount)
{
	ValidatePlayerIndex(CurrentPlayerIndex);
	Players[CurrentPlayerIndex].Multiplier += Amount;
	bRenderScoreBoard = true;
}

//=============================================================================
//	NextPlayer
//	Increment the CurrentPlayerIndex
//=============================================================================
function NextPlayer(vector BallLoc)
{
	if (NumActivePlayers < 2)
		return;			// Not enough active players to change

	// Remove all the current balls
	RemoveAllBalls();

	CurrentPlayerIndex++;
	CurrentPlayerIndex = CurrentPlayerIndex%NumPlayers;

	while (!Players[CurrentPlayerIndex].bActive)
	{
		CurrentPlayerIndex++;
		CurrentPlayerIndex = CurrentPlayerIndex%NumPlayers;
	}
	
	// Spawn a ball for the current player
	SpawnBall(BallLoc);
	bRenderScoreBoard = true;
}

//=============================================================================
//	AddToPlayerBalls
//	Increases the balls a player has
//=============================================================================
function bool AddToPlayerBalls(int Amount)
{
	ValidatePlayerIndex(CurrentPlayerIndex);

	if (Players[CurrentPlayerIndex].Balls+Amount < 0)
		return false;		// Not enough balls

	Players[CurrentPlayerIndex].Balls += Amount;

	bRenderScoreBoard = true;

	return true;
}

//=============================================================================
//	SpawnBall
//	Adds a ball to the table
//=============================================================================
function SpawnBall(vector SpawnPos)
{
	if (NumBalls >= ArrayCount(Balls))
		return;		// Too many balls

	// Remove a ball from current players inventory
	if (!AddToPlayerBalls(-1))
		return;		// Not enough balls to spawn another one
	
	// Spawn the ball at the position specified in BallSpawnPos
	Balls[NumBalls] = Spawn(class'dnPinBall',,,SpawnPos);//+vect(0,0,30));

	//BroadcastMessage("SpawnBall:"@Balls[NumBalls]);

	if (Balls[NumBalls] != None)
	{
		Balls[NumBalls].SetLocation(SpawnPos);
		Balls[NumBalls].FindSpot();
		NumBalls++;
	}
	
	bRenderScoreBoard = true;
}

//=============================================================================
//	RemoveBall
//	Removes a ball from the table
//=============================================================================
function RemoveBall(dnPinBall Ball)
{
	local int	i, NumNewBalls;
	local bool	bFoundBall;

	if (Ball == None)
	{
		BroadcastMessage("dnPinballTable->RemoveBall: Ball is None.");
		return;
	}

	NumNewBalls = 0;
	bFoundBall = false;

	for (i=0; i< NumBalls; i++)
	{
		if (Balls[i] == Ball)
		{
			Ball.Destroy();
			bFoundBall = true;
			continue;
		}

		Balls[NumNewBalls++] = Balls[i];
	}

	if (!bFoundBall)
	{
		BroadcastMessage("dnPoolTable->RemoveBall: Ball not found.");
		return;
	}

	NumBalls = NumNewBalls;
	
	if (NumBalls <= 0 && Players[CurrentPlayerIndex].Balls <= 0)
	{
		// No balls on the table, or in the inventory for this player, game over...
		PlayerGameOver();
	}
	else if (NumBalls == 0)		// Last ball dropped, spawn another ball
	{
		// Take a ball from this players inventory, and put it on the table
		//	(in a 2 player game, we would change players here as well)
		SpawnBall(StartBallLoc);
	}
	
	bRenderScoreBoard = true;
}

//=============================================================================
//	Tilt
//=============================================================================
function Tilt(vector NewVelocity)
{
	bTilt = true;
	TiltVelocity = NewVelocity;
}

//=============================================================================
//	defaultproperties
//=============================================================================
defaultproperties
{
	BackgroundColor=97
	NumPlayers=1
	StartingBalls=3
	PinballFont=Font't_fonts.LEDFont2BC'
	MaxTilt=0.3f
	TiltSensitivity=11.0f
	TiltResetSpeed=0.5f
}
