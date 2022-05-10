/*-----------------------------------------------------------------------------
	PowerPuzzle
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class PowerPuzzle extends InputDecoration;

#exec OBJ LOAD FILE=..\Sounds\a_switch.dfx
#exec OBJ LOAD FILE=..\Meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\Textures\powerpuzzle1.dtx

var texture			BlankPiece[4];
var texture			BlockerPiece[3];
var texture			HighlightPiece[3];
var texture			DownLeftPiece[10];
var texture			LeftDownPiece[10];
var texture			RightDownPiece[10];
var texture			DownRightPiece[10];
var texture			LeftRightPiece[10];
var texture			RightLeftPiece[10];
var texture			LeftUpPiece[10];
var texture			UpLeftPiece[10];
var texture			UpRightPiece[10];
var texture			RightUpPiece[10];
var texture			UpDownPiece[10];
var texture			DownUpPiece[10];
var texture			PuzzleStartTex[10];
var texture			PuzzleEndTex[10];
var texture			PuzzleBackground;

var bool			bDirty, SaverActive;

enum ERouteType
{
	RT_None,
	RT_Empty,
	RT_DownLeft,
	RT_LeftDown,
	RT_RightDown,
	RT_DownRight,
	RT_LeftRight,
	RT_RightLeft,
	RT_LeftUp,
	RT_UpLeft,
	RT_UpRight,
	RT_RightUp,
	RT_UpDown,
	RT_DownUp,
	RT_Blocker,
};

enum EWalkDirection
{
	WD_Up,
	WD_Down,
	WD_Left,
	WD_Right,
};

var ERouteType		GridNodeTypes[36];
var int				GridBlankPiece[36];
var int				GridNodeFill[36];
var int				EnterNodeFill, ExitNodeFill;
var int				GridOffset, GridNodes, GridRows;
var int				PuzzleStart, PuzzleEnd, PuzzleEnterNode, PuzzleExitNode;
var int				BlockerFrame, HighlightNode;
var int				BlockerNodes[36];
var int				PlacedPath[36], PlacedPieces;
var int				LastPlaceNode, LastChangeNode, NextPlaceNode;
var int				CurrentFillNode, FillMod;
var float			FillTime;
var bool			PuzzlePlaying, PuzzleFailed, PuzzleWon;

var() enum EComplexity
{
	C_4x4,
	C_6x6,
}					Complexity;			// Grid complexity.
var() float			FillRate;			// Time to fill one node.
var() bool			HiddenBlockers;		// Hide the blockers until you get near them.
var() int			Blockers;			// Number of blockers. (-1 means default)

var string			InstructionsString1, InstructionsString2;
var string			StatusString, PowerBypassString;
var string			FailedString, SuccessString, RoutingString, InitString, WaitingString;

var sound			PowerTickSound, HighlightSound, SelectSound, SuccessSound, FailSound, ActivateSound;

var transient font	SmallFont;

function PostBeginPlay()
{
	Super.PostBeginPlay();

	// Build a puzzle.
	ConstructPuzzle();

	SaverActive = true;
}

function ConstructPuzzle()
{
	local int i, j, k;

	bDirty = true;

	for (i=0; i<36; i++)
	{
		GridNodeTypes[i] = RT_None;
		GridBlankPiece[i] = Rand(4);
	}

	// Setup the puzzle.
	switch (Complexity)
	{
	case C_4x4:
		GridOffset = 64;
		GridNodes = 4*4;
		GridRows = 4;
		if (Blockers == -1)
			Blockers = 4;
		if (Blockers > 8)
			Blockers = 8;
		if (Rand(2) == 0)
		{
			PuzzleStart = 0;
			PuzzleEnd   = 3;
		} else {
			PuzzleStart = 3;
			PuzzleEnd	= 0;
		}
		break;
	case C_6x6:
		GridOffset = 32;
		GridNodes = 6*6;
		GridRows = 6;
		if (Blockers == -1)
			Blockers = 8;
		if (Blockers > 16)
			Blockers = 16;
		if (Rand(2) == 0)
		{
			PuzzleStart = Rand(2);
			PuzzleEnd   = Rand(2)+4;
		} else {
			PuzzleStart = Rand(2)+4;
			PuzzleEnd	= Rand(2);
		}
		break;
	}
	PuzzleEnterNode = PuzzleStart*GridRows;
	PuzzleExitNode  = PuzzleEnd*GridRows + (GridRows-1);

	for (i=0; i<GridNodes; i++)
		GridNodeTypes[i] = RT_Empty;

	// Add blockers.
	for (i=0; i<Blockers; i++)
	{
		j = PuzzleEnterNode;
		while ((j == PuzzleEnterNode) || (j == PuzzleExitNode)) // Don't block these points.
		{
			j = Rand(GridNodes);
			for (k=0; k<i; k++) // Don't double up blockers.
			{
				if (j == BlockerNodes[k])
					j = PuzzleEnterNode;
			}
		}
		BlockerNodes[i] = j;
		GridNodeTypes[j] = RT_Blocker;
	}

	// Determine if this puzzle is solvable.
	if (!IsValid())
		ConstructPuzzle();

	// Reset the game.
	ResetPuzzle();
}

function ResetPuzzle()
{
	local int i;

	bDirty = true;

	// Clean up the board.
	for (i=0; i<GridNodes; i++)
	{
		if (GridNodeTypes[i] != RT_Blocker)
			GridNodeTypes[i] = RT_Empty;
	}

	// Wipe the user's path.
	for (i=0; i<36; i++)
		PlacedPath[i] = -1;
	PlacedPieces = 0;
	LastPlaceNode = -1;

	// Setup the flow.
	CurrentFillNode = -1;
	EnterNodeFill = 0;
	ExitNodeFill = 0;
	FillTime = 0;
	for (i=0; i<36; i++)
		GridNodeFill[i] = 0;
	FillMod = 1;
	CloseTime = 0.0;

	PuzzlePlaying = false;
}

function bool IsValid()
{
	local int CurrentNode;
	local bool ValidPath;

	// Start at the puzzle EnterNode.
	CurrentNode = PuzzleEnterNode;

	// Search for a valid path.
	if (NodeIsValidFrom(CurrentNode, WD_Right))
	{
		ValidPath = PathIsValidFrom(CurrentNode, WD_Right); // Right
		if (ValidPath)
			return true;
	}

	if (NodeIsValidFrom(CurrentNode, WD_Up))
	{
		ValidPath = PathIsValidFrom(CurrentNode, WD_Up); // Up
		if (ValidPath)
			return true;
	}

	if (NodeIsValidFrom(CurrentNode, WD_Down))
	{
		ValidPath = PathIsValidFrom(CurrentNode, WD_Down); // Down
		if (ValidPath)
			return true;
	}

	return false;
}

function bool PathIsValidFrom(int FromNode, EWalkDirection WalkDirection)
{
	local int Node;
	local bool Test;

	switch (WalkDirection)
	{
	case WD_Up:
		Node = FromNode - GridRows;
		break;
	case WD_Right:
		Node = FromNode + 1;
		break;
	case WD_Down:
		Node = FromNode + GridRows;
		break;
	}
	
	if (Node == PuzzleExitNode)
		return true;

	switch (WalkDirection)
	{
	case WD_Up:
		// Search right.
		if (NodeIsValidFrom(Node, WD_Right))
			Test = PathIsValidFrom(Node, WD_Right);
		if (Test)
			return Test;
		// Search up.
		if (NodeIsValidFrom(Node, WD_Up))
			Test = PathIsValidFrom(Node, WD_Up);
		if (Test)
			return Test;
		break;
	case WD_Right:
		// Search right.
		if (NodeIsValidFrom(Node, WD_Right))
			Test = PathIsValidFrom(Node, WD_Right);
		if (Test)
			return Test;
		// Search up.
		if (NodeIsValidFrom(Node, WD_Up))
			Test = PathIsValidFrom(Node, WD_Up);
		if (Test)
			return Test;
		// Search down.
		if (NodeIsValidFrom(Node, WD_Down))
			Test = PathIsValidFrom(Node, WD_Down);
		if (Test)
			return Test;
		break;
	case WD_Down:
		// Search right.
		if (NodeIsValidFrom(Node, WD_Right))
			Test = PathIsValidFrom(Node, WD_Right);
		if (Test)
			return Test;
		// Search down.
		if (NodeIsValidFrom(Node, WD_Down))
			Test = PathIsValidFrom(Node, WD_Down);
		if (Test)
			return Test;
		break;
	}

	return Test;
}

// Assumes a valid FromNode.
function bool NodeIsValidFrom(int FromNode, EWalkDirection WalkDirection)
{
	local int i, ToNode;

	switch (WalkDirection)
	{
	case WD_Up:
		ToNode = FromNode - GridRows;
		if (ToNode < 0)
			return false;
		break;
	case WD_Down:
		ToNode = FromNode + GridRows;
		if (ToNode >= GridNodes)
			return false;
		break;
	case WD_Left:
		ToNode = FromNode - 1;
		if ((FromNode%GridRows == 0) && (ToNode < FromNode))
			return false;
		break;
	case WD_Right:
		ToNode = FromNode + 1;
		if (((FromNode+1)%GridRows == 0) && (ToNode > FromNode))
			return false;
		break;
	}

	// Check blockers.
	for (i=0; i<Blockers; i++)
		if (ToNode == BlockerNodes[i])
			return false;

	// Passed all tests.
	return true;
}

function Tick(float DeltaTime)
{
	local int i;

	Super.Tick(DeltaTime);

	if (SaverActive)
		return;

	// Restore font refs if they go away (save/load).
	if ( (SmallFont == None) && (TouchPawn != None) )
		SmallFont = DukeHUD(TouchPawn.MyHUD).SmallFont;

	// Draw the background if needed.
	if (bDirty)
	{
		ScreenCanvas.DrawClear(0);
		DrawBackground();
		DrawText();
	}

	// Draw the blockers.
	DrawBlockers();

	// Draw the game area if its changed.
	if (bDirty)
	{
		DrawPuzzleStart();
		DrawPuzzleEnd();
		for (i=0; i<GridNodes; i++)
			DrawGridPiece(i);

		bDirty = false;
	}

	// Find the highlight node.
	FindHighlightNode();
	if (HighlightNode > -1)
		DrawGridPiece(HighlightNode, true);

	if (!PuzzlePlaying)
		return;

	// Perform puzzle logic.
	FillTime += DeltaTime * FillMod;
	if (FillTime > FillRate)
	{
		PlaySound( PowerTickSound, SLOT_None );

		bDirty = true;
		if (CurrentFillNode == -1)
		{
			EnterNodeFill += 1;
			if (EnterNodeFill == 9)
				CheckNextFillNode();
		}
		else if (CurrentFillNode == -2)
		{
			ExitNodeFill += 1;
			if (ExitNodeFill == 9)
				WinPuzzle();
		} 
		else
		{
			GridNodeFill[PlacedPath[CurrentFillNode]] += 1;
			if (GridNodeFill[PlacedPath[CurrentFillNode]] == 9)
				CheckNextFillNode();
		}
		FillTime = 0;
	}
}

function CheckNextFillNode()
{
	local int FillNode, NextFillNode, LastFillNode;
	local bool bLeft, bRight, bUp, bDown;
	local ERouteType NextFillType;

	if (CurrentFillNode != -1)
		FillNode = PlacedPath[CurrentFillNode];
	else
		FillNode = PuzzleEnterNode;
	NextFillNode = PlacedPath[CurrentFillNode+1];
	if (NextFillNode != -1)
		NextFillType = GridNodeTypes[NextFillNode];
	else
		NextFillType = RT_Empty;

	if (FillNode == PuzzleExitNode)
	{
		LastFillNode = PlacedPath[CurrentFillNode-1];
		bLeft	= IsLeft( LastFillNode, FillNode );
		bUp		= IsUp( LastFillNode, FillNode );
		bDown	= IsDown( LastFillNode, FillNode );
		if (bLeft)
		{
			if (GridNodeTypes[FillNode] != RT_LeftRight)
			{
				FailedPuzzle();
				return;
			}
		}
		else if (bUp)
		{
			if (GridNodeTypes[FillNode] != RT_UpRight)
			{
				FailedPuzzle();
				return;
			}
		}
		else if (bDown)
		{
			if (GridNodeTypes[FillNode] != RT_DownRight)
			{
				FailedPuzzle();
				return;
			}
		}
		CurrentFillNode = -2;
		return;
	}

	if (NextFillNode == -1)
	{
		FailedPuzzle();
		return;
	}

	if ( LastPlaceNode == -1 )
		bLeft = true;
	else
	{
		bLeft	= IsLeft( FillNode, NextFillNode );
		bRight	= IsRight( FillNode, NextFillNode );
		bUp		= IsUp( FillNode, NextFillNode );
		bDown	= IsDown( FillNode, NextFillNode );
	}
	if (bLeft)
	{
		if ((NextFillType != RT_LeftUp) &&
			(NextFillType != RT_LeftDown) &&
			(NextFillType != RT_LeftRight))
		{
			FailedPuzzle();
			return;
		}
	}
	else if (bRight)
	{
		if ((NextFillType != RT_RightUp) &&
			(NextFillType != RT_RightDown) &&
			(NextFillType != RT_RightLeft))
		{
			FailedPuzzle();
			return;
		}
	}
	else if (bUp)
	{
		if ((NextFillType != RT_UpLeft) &&
			(NextFillType != RT_UpRight) &&
			(NextFillType != RT_UpDown))
		{
			FailedPuzzle();
			return;
		}
	}
	else if (bDown)
	{
		if ((NextFillType != RT_DownLeft) &&
			(NextFillType != RT_DownRight) &&
			(NextFillType != RT_DownUp))
		{
			FailedPuzzle();
			return;
		}
	}

	CurrentFillNode++;
}

function DrawText()
{
	local Font pFont;
	local float XL, YL;
	local string StateString;

	if (!PuzzlePlaying)
	{
		if (PuzzleFailed)
			StateString = FailedString;
		else if (PuzzleWon)
			StateString = SuccessString;
		else
			StateString = WaitingString;
	} else {
		if (CurrentFillNode == -1)
			StateString = InitString;
		else
			StateString = RoutingString;
	}

	pFont = SmallFont;
	if (pFont == None)
		return;

	if (TouchPawn != None)
	{
		ScreenCanvas.TextSize( PowerBypassString, XL, YL, pFont );
		ScreenCanvas.DrawString( pFont, (256 - XL)/2, 6, PowerBypassString );
		ScreenCanvas.TextSize( StatusString@StateString, XL, YL, pFont );
		ScreenCanvas.DrawString( pFont, (256 - XL)/2, 6+YL, StatusString@StateString );

		ScreenCanvas.TextSize( InstructionsString1, XL, YL, pFont );
		ScreenCanvas.DrawString( pFont, (256 - XL)/2, 256 - 6 - YL*2, InstructionsString1 );
		ScreenCanvas.TextSize( InstructionsString2, XL, YL, pFont );
		ScreenCanvas.DrawString( pFont, (256 - XL)/2, 256 - 6 - YL, InstructionsString2 );
	} else {
		ScreenCanvas.TextSize( PowerBypassString, XL, YL, pFont );
		ScreenCanvas.DrawString( pFont, (256 - XL)/2, 6, PowerBypassString );
		ScreenCanvas.TextSize( StatusString@StateString, XL, YL, pFont );
		ScreenCanvas.DrawString( pFont, (256 - XL)/2, 6+YL, StatusString@StateString );
	}
}

function DrawBackground()
{
	ScreenCanvas.DrawBitmap( 1, 1, 0, 0, 0, 0, PuzzleBackground, false, false, false );
}

function DrawBlockers()
{
	local int i;

	for (i=0; i<Blockers; i++)
		DrawGridPiece(BlockerNodes[i]);
}

function DrawPuzzleStart()
{
	ScreenCanvas.DrawBitmap( GridOffset-32, PuzzleStart*32+GridOffset, 0, 0, 0, 0, PuzzleStartTex[EnterNodeFill], true, false, false );
}

function DrawPuzzleEnd()
{
	ScreenCanvas.DrawBitmap( 256-GridOffset, PuzzleEnd*32+GridOffset, 0, 0, 0, 0, PuzzleEndTex[ExitNodeFill], true, false, false );
}

function DrawGridPiece(int i, optional bool Highlight)
{
	local int S, X, Y;

	X = GetX(i)+GridOffset;
	Y = GetY(i)+GridOffset;

	if (GetPieceForNode(i) != none)
		ScreenCanvas.DrawBitmap( X, Y, 0, 0, 0, 0, GetPieceForNode(i), true, false, false );

	if (Highlight)
		ScreenCanvas.DrawBitmap( X, Y, 0, 0, 0, 0, HighlightPiece[BlockerFrame], true, false, false );
}

function int GetX(int i)
{
	local int j;
	j = i%GridRows;
	return j*32;
}

function int GetY(int i)
{
	return (i/GridRows)*32;
}

function texture GetPieceForNode(int i)
{
	local int j;

	switch (GridNodeTypes[i])
	{
	case RT_Empty:
		return BlankPiece[GridBlankPiece[i]];
	case RT_Blocker:
		if (HiddenBlockers && PuzzlePlaying)
		{
			// Only show blockers near existing pieces.
			for (j=0; j<PlacedPieces; j++)
			{
				if (( IsLeft(PlacedPath[j], i) ) ||
					( IsRight(PlacedPath[j], i) ) ||
					( IsUp(PlacedPath[j], i) ) ||
					( IsDown(PlacedPath[j], i) ))
				return BlockerPiece[BlockerFrame];
			}
			return BlankPiece[GridBlankPiece[i]];
		} else
			return BlockerPiece[BlockerFrame];
	case RT_DownLeft:
		return DownLeftPiece[GridNodeFill[i]];
	case RT_LeftDown:
		return LeftDownPiece[GridNodeFill[i]];
	case RT_RightDown:
		return RightDownPiece[GridNodeFill[i]];
	case RT_DownRight:
		return DownRightPiece[GridNodeFill[i]];
	case RT_LeftRight:
		return LeftRightPiece[GridNodeFill[i]];
	case RT_RightLeft:
		return RightLeftPiece[GridNodeFill[i]];
	case RT_LeftUp:
		return LeftUpPiece[GridNodeFill[i]];
	case RT_UpLeft:
		return UpLeftPiece[GridNodeFill[i]];
	case RT_UpRight:
		return UpRightPiece[GridNodeFill[i]];
	case RT_RightUp:
		return RightUpPiece[GridNodeFill[i]];
	case RT_UpDown:
		return UpDownPiece[GridNodeFill[i]];
	case RT_DownUp:
		return DownUpPiece[GridNodeFill[i]];
	default:
		return None;
	}
}

function ScreenTouched( Pawn Other, float X, float Y )
{
	if (bDisrupted || bPowerOff)
		return;

	if ( (TouchPawn == None) && !PuzzleWon )
	{
		// Setup the canvas.
		SaverActive			= false;
		ScreenSaver.pause	= true;
		MultiSkins[ScreenSurface] = ScreenCanvas;
		//SetSurfaceTexture( ScreenSurface, ScreenCanvas );
		ScreenCanvas.palette= PuzzleBackground.palette;
		bDirty				= true;

		// Setup the game.
		ResetPuzzle();
		SetTimer(0.3, true, 2);
		TouchPawn = PlayerPawn(Other);
		SmallFont = DukeHUD(TouchPawn.MyHUD).SmallFont;

		// Play a greeting.
		PlaySound( ActivateSound, SLOT_None );
	} else if ( (TouchPawn == None) && PuzzleWon ) {
		// Setup the canvas.
		SaverActive			= false;
		ScreenSaver.pause	= true;
		MultiSkins[ScreenSurface] = ScreenCanvas;
		//SetSurfaceTexture( ScreenSurface, ScreenCanvas );
		ScreenCanvas.palette= PuzzleBackground.palette;
		bDirty				= true;

		// Play a greeting.
		PlaySound( ActivateSound, SLOT_None );
	} else {
		if (CanChangeNode() && (FillMod == 1))
		{
			if (Other.IsA('DukePlayer'))
				DukePlayer(Other).Hand_PressButton();

			PlaySound( SelectSound, SLOT_None );
			ChangeNodeRouteType();
			if (LastChangeNode == PuzzleEnterNode)
				PuzzlePlaying = true;
			if (LastChangeNode == PuzzleExitNode)
				CheckVictory();
		}
	}
}

function Timer(optional int TimerNum)
{
	if (TimerNum == 2)
	{
		BlockerFrame++;
		if (BlockerFrame == 3)
			BlockerFrame = 0;
	}

	Super.Timer(TimerNum);
}

function bool CanChangeNode()
{
	local ERouteType LastRoute;
	local int i;

	// Can't change blockers.
	if (HighlightNode == -1)
		return false;

	if (GridNodeTypes[HighlightNode] == RT_Blocker)
		return false;

	// If we are starting, we can only place on the start node.
	if (PlacedPath[0] == -1)
	{
		if (HighlightNode == PuzzleEnterNode)
			return true;
		else
			return false;
	}

	// We can change anything in our current path, that isn't filling up.
	for (i=0; i<36; i++)
		if (PlacedPath[i] == HighlightNode)
		{
			if (GridNodeFill[HighlightNode] == 0)
				return true;
			else
				return false;
		}

	// We can change the block that is "next."
	if (HighlightNode == NextPlaceNode)
		return true;

	return false;
}

function ChangeNodeRouteType()
{
	local int i, PlacedNode, ConnectingNode;
	local bool bLeft, bRight, bUp, bDown;

	// Set to redraw.
	bDirty = true;

	// Update the last place node.
	if ( (HighlightNode != PuzzleEnterNode) && (LastChangeNode != HighlightNode) )
		LastPlaceNode = LastChangeNode;

	// Find out if we are placing over an existing path node.
	PlacedNode = -1;
	for (i=0; (i<36) && (PlacedNode==-1); i++)
		if (PlacedPath[i] == HighlightNode)
			PlacedNode = i;
	if (PlacedNode != -1)
	{
		// We are, delete all the path pieces after this one.
		for (i=PlacedNode+1; i<PlacedPieces; i++)
		{
			GridNodeTypes[PlacedPath[i]] = RT_Empty;
			PlacedPath[i] = -1;
		}
		PlacedPieces = PlacedNode;

		// Adjust the last place node.
		if (PlacedNode == 0)
			LastPlaceNode = -1;
		else
			LastPlaceNode = PlacedPath[PlacedNode-1];
	}

	// Find out which type of node to place.
	// Determine NextPlaceNode.
	if ( LastPlaceNode == -1 )
		bLeft = true;
	else {
		bLeft = IsLeft( LastPlaceNode, HighlightNode );
		bRight = IsRight( LastPlaceNode, HighlightNode );
		bUp = IsUp( LastPlaceNode, HighlightNode );
		bDown = IsDown( LastPlaceNode, HighlightNode );
	}
	if ( GridNodeTypes[HighlightNode] == RT_Empty )
	{
		if ( bDown )
			GridNodeTypes[HighlightNode] = RT_DownLeft;
		else
			GridNodeTypes[HighlightNode] = RT_LeftDown;

		if ( LastPlaceNode == -1 ) // If no previous node has been placed.
			SetNextPlaceNode( WD_Down );
		else
		{
			if ( bRight || bUp )
				NextPlaceNode = -1;
			else if ( bLeft )
				SetNextPlaceNode( WD_Down );
			else if ( bDown )
				SetNextPlaceNode( WD_Left );
		}
	} 
	else
	{
		switch ( GridNodeTypes[HighlightNode] )
		{
			case RT_LeftDown:
				if ( bDown )
					GridNodeTypes[HighlightNode] = RT_DownRight;
				else
					GridNodeTypes[HighlightNode] = RT_RightDown;
				if ( bUp || bLeft )
					NextPlaceNode = -1;
				else if ( bRight )
					SetNextPlaceNode( WD_Down );
				else if ( bDown )
					SetNextPlaceNode( WD_Right );
			case RT_DownLeft:
				if ( bDown )
					GridNodeTypes[HighlightNode] = RT_DownRight;
				else
					GridNodeTypes[HighlightNode] = RT_RightDown;
				if ( bUp || bLeft )
					NextPlaceNode = -1;
				else if ( bRight )
					SetNextPlaceNode( WD_Down );
				else if ( bDown )
					SetNextPlaceNode( WD_Right );
				break;
			case RT_DownRight:
				if ( bLeft )
					GridNodeTypes[HighlightNode] = RT_LeftRight;
				else
					GridNodeTypes[HighlightNode] = RT_RightLeft;
				if ( bUp || bDown )
					NextPlaceNode = -1;
				else if ( bRight )
					SetNextPlaceNode( WD_Left );
				else if ( bLeft )
					SetNextPlaceNode( WD_Right );
				break;
			case RT_RightDown:
				if ( bLeft )
					GridNodeTypes[HighlightNode] = RT_LeftRight;
				else
					GridNodeTypes[HighlightNode] = RT_RightLeft;
				if ( bUp || bDown )
					NextPlaceNode = -1;
				else if ( bRight )
					SetNextPlaceNode( WD_Left );
				else if ( bLeft )
					SetNextPlaceNode( WD_Right );
				break;
			case RT_RightLeft:
				if ( bLeft )
					GridNodeTypes[HighlightNode] = RT_LeftUp;
				else
					GridNodeTypes[HighlightNode] = RT_UpLeft;
				if ( bRight || bDown )
					NextPlaceNode = -1;
				else if ( bLeft )
					SetNextPlaceNode( WD_Up );
				else if ( bUp )
					SetNextPlaceNode( WD_Left );
				break;
			case RT_LeftRight:
				if ( bLeft )
					GridNodeTypes[HighlightNode] = RT_LeftUp;
				else
					GridNodeTypes[HighlightNode] = RT_UpLeft;
				if ( bRight || bDown )
					NextPlaceNode = -1;
				else if ( bLeft )
					SetNextPlaceNode( WD_Up );
				else if ( bUp )
					SetNextPlaceNode( WD_Left );
				break;
			case RT_UpLeft:
				if ( bUp )
					GridNodeTypes[HighlightNode] = RT_UpRight;
				else
					GridNodeTypes[HighlightNode] = RT_RightUp;
				if ( bLeft || bDown )
					NextPlaceNode = -1;
				else if ( bRight )
					SetNextPlaceNode( WD_Up );
				else if ( bUp )
					SetNextPlaceNode( WD_Right );
				break;
			case RT_LeftUp:
				if ( bUp )
					GridNodeTypes[HighlightNode] = RT_UpRight;
				else
					GridNodeTypes[HighlightNode] = RT_RightUp;
				if ( bLeft || bDown )
					NextPlaceNode = -1;
				else if ( bRight )
					SetNextPlaceNode( WD_Up );
				else if ( bUp )
					SetNextPlaceNode( WD_Right );
				break;
			case RT_RightUp:
				if ( bUp )
					GridNodeTypes[HighlightNode] = RT_UpDown;
				else
					GridNodeTypes[HighlightNode] = RT_DownUp;
				if ( bLeft || bRight )
					NextPlaceNode = -1;
				else if ( bUp )
					SetNextPlaceNode( WD_Down );
				else if ( bDown )
					SetNextPlaceNode( WD_Up );
				break;
			case RT_UpRight:
				if ( bUp )
					GridNodeTypes[HighlightNode] = RT_UpDown;
				else
					GridNodeTypes[HighlightNode] = RT_DownUp;
				if ( bLeft || bRight )
					NextPlaceNode = -1;
				else if ( bUp )
					SetNextPlaceNode( WD_Down );
				else if ( bDown )
					SetNextPlaceNode( WD_Up );
				break;
			case RT_DownUp:
				if ( bDown )
					GridNodeTypes[HighlightNode] = RT_DownLeft;
				else
					GridNodeTypes[HighlightNode] = RT_LeftDown;
				if ( bUp || bRight )
					NextPlaceNode = -1;
				else if ( bLeft )
					SetNextPlaceNode( WD_Down );
				else if ( bDown )
					SetNextPlaceNode( WD_Left );
				break;
			case RT_UpDown:
				if ( bDown )
					GridNodeTypes[HighlightNode] = RT_DownLeft;
				else
					GridNodeTypes[HighlightNode] = RT_LeftDown;
				if ( bUp || bRight )
					NextPlaceNode = -1;
				else if ( bLeft )
					SetNextPlaceNode( WD_Down );
				else if ( bDown )
					SetNextPlaceNode( WD_Left );
				break;
		}
	}
	LastChangeNode = HighlightNode;
	PlacedPath[PlacedPieces] = HighlightNode;
	PlacedPieces++;
}

function FindHighlightNode()
{
	local vector PointUV;
	local texture HitMeshTexture;
	local actor HitActor;
	local float U, V;
	local int OldHighlightNode;

	if (TouchPawn == None)
	{
		HighlightNode = -1;
		return;
	}

	HitActor = TouchPawn.TraceFromCrosshairMesh( TouchPawn.UseDistance,,,,,,HitMeshTexture, PointUV );

	U = PointUV.X*ScreenX;
	V = PointUV.Y*ScreenY;

	OldHighlightNode = HighlightNode;
	HighlightNode = FindNodeAt(U, V);
	if ((HighlightNode != -1) && (GridNodeTypes[HighlightNode] == RT_Blocker))
		HighlightNode = -1;
	if (HighlightNode != OldHighlightNode)
	{
		PlaySound( HighlightSound, SLOT_None );
		bDirty = true;
	}
}

function int FindNodeAt(float U, float V)
{
	local float X, Y;
	local int col, row;

	// Check grid bounds.
	if ((U < GridOffset) || (U > 256-GridOffset))
		return -1;
	if ((V < GridOffset) || (V > 256-GridOffset))
		return -1;

	// Find actual node.
	X = U - GridOffset;
	Y = V - GridOffset;

	col = X / 32;
	row = Y / 32;

	return (row*GridRows)+col;
}

function CloseDecoration( Actor Other )
{
	CloseTime = 0.0;
	TouchPawn = None;
	ScreenSaver.pause = false;
	MultiSkins[ScreenSurface] = ScreenSaver;
	SaverActive = true;
}

function SetNextPlaceNode( EWalkDirection WalkDirection )
{
	switch (WalkDirection)
	{
		case WD_Up:
			if (HighlightNode < GridRows)
				NextPlaceNode = -1;
			else
				NextPlaceNode = HighlightNode - GridRows;
			break;
		case WD_Down:
			if (HighlightNode >= GridNodes - (GridRows-1))
				NextPlaceNode = -1;
			else
				NextPlaceNode = HighlightNode + GridRows;
			break;
		case WD_Left:
			if (HighlightNode%GridRows == 0)
				NextPlaceNode = -1;
			else
				NextPlaceNode = HighlightNode - 1;
			break;
		case WD_Right:
			if ((HighlightNode+1)%GridRows == 0)
				NextPlaceNode = -1;
			else
				NextPlaceNode = HighlightNode + 1;
			break;
	}
}

function bool IsLeft( int Node1, int Node2 )
{
	if (Node2%GridRows == 0)
		return false;
	else if (Node1 == Node2 - 1)
		return true;
	else
		return false;
}

function bool IsRight( int Node1, int Node2 )
{
	if ((Node2+1)%GridRows == 0)
		return false;
	else if (Node1 == Node2 + 1)
		return true;
	else
		return false;
}

function bool IsUp( int Node1, int Node2 )
{
	if (Node2 < GridRows)
		return false;
	else if (Node1 == Node2 - GridRows)
		return true;
	else
		return false;
}

function bool IsDown( int Node1, int Node2 )
{
	if (Node2 >= GridNodes - GridRows)
		return false;
	else if (Node1 == Node2 + GridRows)
		return true;
	else
		return false;
}

function FailedPuzzle()
{
	local Actor A;

	PuzzleWon = false;
	PuzzleFailed = true;
	PuzzlePlaying = false;
	if( FailEvent != '' )
		foreach AllActors( class 'Actor', A, FailEvent )
			A.Trigger( Self, TouchPawn );

	PlaySound( FailSound, SLOT_None );

	CloseTime = 2.0;
}

function WinPuzzle()
{
	local Actor A;

	PuzzleWon = true;
	PuzzleFailed = false;
	PuzzlePlaying = false;
	if( SuccessEvent != '' )
		foreach AllActors( class 'Actor', A, SuccessEvent )
			A.Trigger( Self, TouchPawn );

	PlaySound( SuccessSound, SLOT_None );

	CloseTime = 2.0;
}

function CheckVictory()
{
	local ERouteType LastPiece, PieceBeforeLast;
	local bool Victory;

	LastPiece = GridNodeTypes[PlacedPath[PlacedPieces-1]];
	PieceBeforeLast = GridNodeTypes[PlacedPath[PlacedPieces-2]];
	if ( (LastPiece == RT_DownRight) && 
		((PieceBeforeLast == RT_LeftUp) || (PieceBeforeLast == RT_DownUp)) )
	{
		Victory = true;
	}
	else if ( (LastPiece == RT_LeftRight) && 
		((PieceBeforeLast == RT_DownRight) || (PieceBeforeLast == RT_LeftRight) || (PieceBeforeLast == RT_UpRight)) )
	{
		Victory = true;
	}
	else if ( (LastPiece == RT_UpRight) &&
		((PieceBeforeLast == RT_UpDown) || (PieceBeforeLast == RT_LeftDown)) )
	{
		Victory = true;
	}

	if (Victory)
		FillMod = 100;
}

defaultproperties
{
	Mesh=mesh'c_generic.puzzlescreen'
	ScreenSurface=1

	CollisionHeight=12
	CollisionRadius=8
	bMeshLowerByCollision=true
	bProjTarget=true

	PuzzleBackground=texture'powerpuzzle1.puzbackground1B'
	HighlightPiece(0)=texture'powerpuzzle1.highlightglow1B'
	HighlightPiece(1)=texture'powerpuzzle1.highlightglow2B'
	HighlightPiece(2)=texture'powerpuzzle1.highlightglow3B'
	BlankPiece(0)=texture'powerpuzzle1.blankpiece1BC'
	BlankPiece(1)=texture'powerpuzzle1.blankpiece2BC'
	BlankPiece(2)=texture'powerpuzzle1.blankpiece3BC'
	BlankPiece(3)=texture'powerpuzzle1.blankpiece4BC'
	BlockerPiece(0)=texture'powerpuzzle1.obstacle1BC'
	BlockerPiece(1)=texture'powerpuzzle1.obstacle2BC'
	BlockerPiece(2)=texture'powerpuzzle1.obstacle3BC'
	PuzzleStartTex(0)=texture'powerpuzzle1.start0BC'
	PuzzleStartTex(1)=texture'powerpuzzle1.start1BC'
	PuzzleStartTex(2)=texture'powerpuzzle1.start2BC'
	PuzzleStartTex(3)=texture'powerpuzzle1.start3BC'
	PuzzleStartTex(4)=texture'powerpuzzle1.start4BC'
	PuzzleStartTex(5)=texture'powerpuzzle1.start5BC'
	PuzzleStartTex(6)=texture'powerpuzzle1.start6BC'
	PuzzleStartTex(7)=texture'powerpuzzle1.start7BC'
	PuzzleStartTex(8)=texture'powerpuzzle1.start8BC'
	PuzzleStartTex(9)=texture'powerpuzzle1.start9BC'
	PuzzleEndTex(0)=texture'powerpuzzle1.end0BC'
	PuzzleEndTex(1)=texture'powerpuzzle1.end1BC'
	PuzzleEndTex(2)=texture'powerpuzzle1.end2BC'
	PuzzleEndTex(3)=texture'powerpuzzle1.end3BC'
	PuzzleEndTex(4)=texture'powerpuzzle1.end4BC'
	PuzzleEndTex(5)=texture'powerpuzzle1.end5BC'
	PuzzleEndTex(6)=texture'powerpuzzle1.end6BC'
	PuzzleEndTex(7)=texture'powerpuzzle1.end7BC'
	PuzzleEndTex(8)=texture'powerpuzzle1.end8BC'
	PuzzleEndTex(9)=texture'powerpuzzle1.end9BC'
	DownLeftPiece(0)=texture'powerpuzzle1.bottomleftA0BC'
	DownLeftPiece(1)=texture'powerpuzzle1.bottomleftA1BC'
	DownLeftPiece(2)=texture'powerpuzzle1.bottomleftA2BC'
	DownLeftPiece(3)=texture'powerpuzzle1.bottomleftA3BC'
	DownLeftPiece(4)=texture'powerpuzzle1.bottomleftA4BC'
	DownLeftPiece(5)=texture'powerpuzzle1.bottomleftA5BC'
	DownLeftPiece(6)=texture'powerpuzzle1.bottomleftA6BC'
	DownLeftPiece(7)=texture'powerpuzzle1.bottomleftA7BC'
	DownLeftPiece(8)=texture'powerpuzzle1.bottomleftA8BC'
	DownLeftPiece(9)=texture'powerpuzzle1.bottomleftA9BC'
	LeftDownPiece(0)=texture'powerpuzzle1.bottomleftB0BC'
	LeftDownPiece(1)=texture'powerpuzzle1.bottomleftB1BC'
	LeftDownPiece(2)=texture'powerpuzzle1.bottomleftB2BC'
	LeftDownPiece(3)=texture'powerpuzzle1.bottomleftB3BC'
	LeftDownPiece(4)=texture'powerpuzzle1.bottomleftB4BC'
	LeftDownPiece(5)=texture'powerpuzzle1.bottomleftB5BC'
	LeftDownPiece(6)=texture'powerpuzzle1.bottomleftB6BC'
	LeftDownPiece(7)=texture'powerpuzzle1.bottomleftB7BC'
	LeftDownPiece(8)=texture'powerpuzzle1.bottomleftB8BC'
	LeftDownPiece(9)=texture'powerpuzzle1.bottomleftB9BC'
	RightDownPiece(0)=texture'powerpuzzle1.bottomrightA0BC'
	RightDownPiece(1)=texture'powerpuzzle1.bottomrightA1BC'
	RightDownPiece(2)=texture'powerpuzzle1.bottomrightA2BC'
	RightDownPiece(3)=texture'powerpuzzle1.bottomrightA3BC'
	RightDownPiece(4)=texture'powerpuzzle1.bottomrightA4BC'
	RightDownPiece(5)=texture'powerpuzzle1.bottomrightA5BC'
	RightDownPiece(6)=texture'powerpuzzle1.bottomrightA6BC'
	RightDownPiece(7)=texture'powerpuzzle1.bottomrightA7BC'
	RightDownPiece(8)=texture'powerpuzzle1.bottomrightA8BC'
	RightDownPiece(9)=texture'powerpuzzle1.bottomrightA9BC'
	DownRightPiece(0)=texture'powerpuzzle1.bottomrightB0BC'
	DownRightPiece(1)=texture'powerpuzzle1.bottomrightB1BC'
	DownRightPiece(2)=texture'powerpuzzle1.bottomrightB2BC'
	DownRightPiece(3)=texture'powerpuzzle1.bottomrightB3BC'
	DownRightPiece(4)=texture'powerpuzzle1.bottomrightB4BC'
	DownRightPiece(5)=texture'powerpuzzle1.bottomrightB5BC'
	DownRightPiece(6)=texture'powerpuzzle1.bottomrightB6BC'
	DownRightPiece(7)=texture'powerpuzzle1.bottomrightB7BC'
	DownRightPiece(8)=texture'powerpuzzle1.bottomrightB8BC'
	DownRightPiece(9)=texture'powerpuzzle1.bottomrightB9BC'
	LeftRightPiece(0)=texture'powerpuzzle1.horizontalA0BC'
	LeftRightPiece(1)=texture'powerpuzzle1.horizontalA1BC'
	LeftRightPiece(2)=texture'powerpuzzle1.horizontalA2BC'
	LeftRightPiece(3)=texture'powerpuzzle1.horizontalA3BC'
	LeftRightPiece(4)=texture'powerpuzzle1.horizontalA4BC'
	LeftRightPiece(5)=texture'powerpuzzle1.horizontalA5BC'
	LeftRightPiece(6)=texture'powerpuzzle1.horizontalA6BC'
	LeftRightPiece(7)=texture'powerpuzzle1.horizontalA7BC'
	LeftRightPiece(8)=texture'powerpuzzle1.horizontalA8BC'
	LeftRightPiece(9)=texture'powerpuzzle1.horizontalA9BC'
	RightLeftPiece(0)=texture'powerpuzzle1.horizontalB0BC'
	RightLeftPiece(1)=texture'powerpuzzle1.horizontalB1BC'
	RightLeftPiece(2)=texture'powerpuzzle1.horizontalB2BC'
	RightLeftPiece(3)=texture'powerpuzzle1.horizontalB3BC'
	RightLeftPiece(4)=texture'powerpuzzle1.horizontalB4BC'
	RightLeftPiece(5)=texture'powerpuzzle1.horizontalB5BC'
	RightLeftPiece(6)=texture'powerpuzzle1.horizontalB6BC'
	RightLeftPiece(7)=texture'powerpuzzle1.horizontalB7BC'
	RightLeftPiece(8)=texture'powerpuzzle1.horizontalB8BC'
	RightLeftPiece(9)=texture'powerpuzzle1.horizontalB9BC'
	LeftUpPiece(0)=texture'powerpuzzle1.lefttopA0BC'
	LeftUpPiece(1)=texture'powerpuzzle1.lefttopA1BC'
	LeftUpPiece(2)=texture'powerpuzzle1.lefttopA2BC'
	LeftUpPiece(3)=texture'powerpuzzle1.lefttopA3BC'
	LeftUpPiece(4)=texture'powerpuzzle1.lefttopA4BC'
	LeftUpPiece(5)=texture'powerpuzzle1.lefttopA5BC'
	LeftUpPiece(6)=texture'powerpuzzle1.lefttopA6BC'
	LeftUpPiece(7)=texture'powerpuzzle1.lefttopA7BC'
	LeftUpPiece(8)=texture'powerpuzzle1.lefttopA8BC'
	LeftUpPiece(9)=texture'powerpuzzle1.lefttopA9BC'
	UpLeftPiece(0)=texture'powerpuzzle1.lefttopB0BC'
	UpLeftPiece(1)=texture'powerpuzzle1.lefttopB1BC'
	UpLeftPiece(2)=texture'powerpuzzle1.lefttopB2BC'
	UpLeftPiece(3)=texture'powerpuzzle1.lefttopB3BC'
	UpLeftPiece(4)=texture'powerpuzzle1.lefttopB4BC'
	UpLeftPiece(5)=texture'powerpuzzle1.lefttopB5BC'
	UpLeftPiece(6)=texture'powerpuzzle1.lefttopB6BC'
	UpLeftPiece(7)=texture'powerpuzzle1.lefttopB7BC'
	UpLeftPiece(8)=texture'powerpuzzle1.lefttopB8BC'
	UpLeftPiece(9)=texture'powerpuzzle1.lefttopB9BC'
	UpRightPiece(0)=texture'powerpuzzle1.righttopA0BC'
	UpRightPiece(1)=texture'powerpuzzle1.righttopA1BC'
	UpRightPiece(2)=texture'powerpuzzle1.righttopA2BC'
	UpRightPiece(3)=texture'powerpuzzle1.righttopA3BC'
	UpRightPiece(4)=texture'powerpuzzle1.righttopA4BC'
	UpRightPiece(5)=texture'powerpuzzle1.righttopA5BC'
	UpRightPiece(6)=texture'powerpuzzle1.righttopA6BC'
	UpRightPiece(7)=texture'powerpuzzle1.righttopA7BC'
	UpRightPiece(8)=texture'powerpuzzle1.righttopA8BC'
	UpRightPiece(9)=texture'powerpuzzle1.righttopA9BC'
	RightUpPiece(0)=texture'powerpuzzle1.righttopB0BC'
	RightUpPiece(1)=texture'powerpuzzle1.righttopB1BC'
	RightUpPiece(2)=texture'powerpuzzle1.righttopB2BC'
	RightUpPiece(3)=texture'powerpuzzle1.righttopB3BC'
	RightUpPiece(4)=texture'powerpuzzle1.righttopB4BC'
	RightUpPiece(5)=texture'powerpuzzle1.righttopB5BC'
	RightUpPiece(6)=texture'powerpuzzle1.righttopB6BC'
	RightUpPiece(7)=texture'powerpuzzle1.righttopB7BC'
	RightUpPiece(8)=texture'powerpuzzle1.righttopB8BC'
	RightUpPiece(9)=texture'powerpuzzle1.righttopB9BC'
	UpDownPiece(0)=texture'powerpuzzle1.verticalA0BC'
	UpDownPiece(1)=texture'powerpuzzle1.verticalA1BC'
	UpDownPiece(2)=texture'powerpuzzle1.verticalA2BC'
	UpDownPiece(3)=texture'powerpuzzle1.verticalA3BC'
	UpDownPiece(4)=texture'powerpuzzle1.verticalA4BC'
	UpDownPiece(5)=texture'powerpuzzle1.verticalA5BC'
	UpDownPiece(6)=texture'powerpuzzle1.verticalA6BC'
	UpDownPiece(7)=texture'powerpuzzle1.verticalA7BC'
	UpDownPiece(8)=texture'powerpuzzle1.verticalA8BC'
	UpDownPiece(9)=texture'powerpuzzle1.verticalA9BC'
	DownUpPiece(0)=texture'powerpuzzle1.verticalB0BC'
	DownUpPiece(1)=texture'powerpuzzle1.verticalB1BC'
	DownUpPiece(2)=texture'powerpuzzle1.verticalB2BC'
	DownUpPiece(3)=texture'powerpuzzle1.verticalB3BC'
	DownUpPiece(4)=texture'powerpuzzle1.verticalB4BC'
	DownUpPiece(5)=texture'powerpuzzle1.verticalB5BC'
	DownUpPiece(6)=texture'powerpuzzle1.verticalB6BC'
	DownUpPiece(7)=texture'powerpuzzle1.verticalB7BC'
	DownUpPiece(8)=texture'powerpuzzle1.verticalB8BC'
	DownUpPiece(9)=texture'powerpuzzle1.verticalB9BC'

	FillRate=0.20
	Blockers=-1
	HiddenBlockers=false
	Complexity=C_4x4

	HealthPrefab=HEALTH_NeverBreak
	ItemName="Terminal"
	LodMode=LOD_Disabled

	PowerBypassString="Power Bypass"
	StatusString="Status:"
	InstructionsString1="Highlight node and"
	InstructionsString2="press USE to route power."
	FailedString="Failed"
	SuccessString="Success"
	RoutingString="Routing"
	InitString="Initializing"
	WaitingString="Waiting"

	PowerTickSound=sound'a_switch.PPanTick1'
	HighlightSound=sound'a_switch.PPanNodeHL1'
	SelectSound=sound'a_switch.PPanNodeSel1'
	SuccessSound=sound'a_switch.PPanBypassOK1'
	FailSound=sound'a_switch.PPanBypassNo1'
	ActivateSound=sound'a_switch.PPanActive01'

	CanvasTexture=texturecanvas'powerpuzzle1.ppuzzle_screen'

	bTranslucentHand=true
}
