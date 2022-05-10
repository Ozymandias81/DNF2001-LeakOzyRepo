/*-----------------------------------------------------------------------------
	InversePuzzle
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class InversePuzzle extends InputDecoration;

#exec OBJ LOAD FILE=..\Textures\circuitpuzzle1.dtx

var int				GridNode[9];
var int				GridNodes, GridRows;

var bool			bDirty, SaverActive, PuzzleWon;

var texture			PuzzleBackground;
var texture			HighlightedPiece[9];
var texture			SelectedTopLeft[4];
var texture			SelectedTopMiddle[4];
var texture			SelectedTopRight[4];
var texture			SelectedMidLeft[4];
var texture			SelectedMidMiddle[4];
var texture			SelectedMidRight[4];
var texture			SelectedBotLeft[4];
var texture			SelectedBotMiddle[4];
var texture			SelectedBotRight[4];

var transient font	SmallFont, LargeFont;
var int				HighlightNode;
var sound			HighlightSound, SelectSound, SuccessSound, FailSound, ActivateSound;

var string			InstructionsString1, InstructionsString2, OperationalString;
var string			FailureString, SuccessString, GridString;

var float			SelectionCounter;
var int				LastTimeCheck, SelectionFrame;

function PostBeginPlay()
{
	Super.PostBeginPlay();

	// Build a puzzle.
	ConstructPuzzle();

	SaverActive = true;
}

function ConstructPuzzle()
{
	local int i;

	GridRows = 3;
	GridNodes = 3*3;

	for (i=0; i<9; i++)
		GridNode[i] = 1;

	HighlightNode = Rand(9);
	ToggleNodes();
	HighlightNode = Rand(9);
	ToggleNodes();
	HighlightNode = Rand(9);
	ToggleNodes();
	HighlightNode = Rand(9);
	ToggleNodes();
	HighlightNode = Rand(9);
	ToggleNodes();

	CloseTime = 0.0;
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
	if ( (LargeFont == None) && (TouchPawn != None) )
		LargeFont = DukeHUD(TouchPawn.MyHUD).MediumFont;

	SelectionCounter += DeltaTime;
	if (SelectionCounter >= 0.3)
	{
		SelectionCounter = 0.0;
		SelectionFrame++;
		bDirty = true;
		if (SelectionFrame > 3)
			SelectionFrame = 0;
	}

	if (int(Level.TimeSeconds) != LastTimeCheck)
	{
		bDirty = true;
		LastTimeCheck = int(Level.TimeSeconds);
	}

	// Find the highlight node.
	FindHighlightNode();

	// Draw the background if needed.
	if (bDirty)
	{
		ScreenCanvas.DrawClear(0);
		DrawBackground();
		DrawText();
	}

	// Draw the game area if changed.
	if (bDirty)
	{
		for (i=0; i<GridNodes; i++)
			DrawGridPiece(i);

		bDirty = false;
	}
}

function DrawText()
{
	local Font pFont;
	local float XL, YL, XL2, YL2;
	local string StateString;

	if (PuzzleWon)
		StateString = SuccessString;
	else
		StateString = FailureString;

	if ((SmallFont == None) || (LargeFont == None))
		return;

	if ((TouchPawn != None) && !PuzzleWon)
	{
		pFont = LargeFont;
		ScreenCanvas.TextSize( GridString, XL, YL, pFont );
		ScreenCanvas.DrawString( pFont, (256 - XL)/2, 4, GridString, false, false, false, true, 1 );

		if ((int(Level.TimeSeconds)%2 == 0) || PuzzleWon)
		{
			ScreenCanvas.TextSize( StateString, XL, YL, pFont );
			pFont = SmallFont;
			ScreenCanvas.TextSize( StateString, XL2, YL2, pFont );
			ScreenCanvas.DrawString( pFont, (256 - XL2)/2, 4+YL, StateString, false, false, false, true, 100 );
		}

		pFont = LargeFont;
		ScreenCanvas.TextSize( InstructionsString1, XL, YL, pFont );
		ScreenCanvas.DrawString( pFont, (256 - XL)/2, 256 - 4 - YL*2, InstructionsString1, false, false, false, true, 1 );
		ScreenCanvas.TextSize( InstructionsString2, XL, YL, pFont );
		ScreenCanvas.DrawString( pFont, (256 - XL)/2, 256 - 4 - YL, InstructionsString2, false, false, false, true, 1 );
	} else {
		pFont = LargeFont;
		ScreenCanvas.TextSize( GridString, XL, YL, pFont );
		ScreenCanvas.DrawString( pFont, (256 - XL)/2, 6, GridString, false, false, false, true, 1 );

		ScreenCanvas.TextSize( StateString, XL, YL, pFont );
		pFont = SmallFont;
		ScreenCanvas.TextSize( StateString, XL2, YL2, pFont );
		ScreenCanvas.DrawString( pFont, (256 - XL2)/2, 6+YL, StateString, false, false, false, true, 1 );

		pFont = LargeFont;
		ScreenCanvas.TextSize( OperationalString, XL, YL, pFont );
		ScreenCanvas.DrawString( pFont, (256 - XL)/2, 256 - 6 - YL*2 + YL/2, OperationalString, false, false, false, true, 1 );
	}
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
	if (HighlightNode != OldHighlightNode)
	{
		//PlaySound( HighlightSound, SLOT_None );
		bDirty = true;
	}
}

function int FindNodeAt(float U, float V)
{
	local int result;

	if ((U > 38) && (U < 38+57) && (V > 37) && (V < 37+57))
		result = 0;
	else if ((U > 98) && (U < 98+57) && (V > 37) && (V < 37+57))
		result = 1;
	else if ((U > 158) && (U < 158+57) && (V > 37) && (V < 37+57))
		result = 2;
	else if ((U > 38) && (U < 38+57) && (V > 98) && (V < 98+57))
		result = 3;
	else if ((U > 98) && (U < 98+57) && (V > 98) && (V < 98+57))
		result = 4;
	else if ((U > 158) && (U < 158+57) && (V > 98) && (V < 98+57))
		result = 5;
	else if ((U > 38) && (U < 38+57) && (V > 158) && (V < 158+57))
		result = 6;
	else if ((U > 98) && (U < 98+57) && (V > 158) && (V < 158+57))
		result = 7;
	else if ((U > 158) && (U < 158+57) && (V > 158) && (V < 158+57))
		result = 8;
	else
		result = -1;

	return result;
}

function DrawBackground()
{
	ScreenCanvas.DrawBitmap( 0, 0, 0, 0, 0, 0, PuzzleBackground, false, false, false );
}

function DrawGridPiece(int i, optional bool Highlight)
{
	local int S, X, Y;
	local texture Tex;

	X = GetX(i);
	Y = GetY(i);

	if (HighlightNode == i)
		ScreenCanvas.DrawBitmap( X, Y, 0, 0, 0, 0, HighlightedPiece[i], true, false, false );

	if (GridNode[i] == 1)
	{
		switch (i)
		{
		case 0:
			Tex = SelectedTopLeft[SelectionFrame];
			break;
		case 1:
			Tex = SelectedTopMiddle[SelectionFrame];
			break;
		case 2:
			Tex = SelectedTopRight[SelectionFrame];
			break;
		case 3:
			Tex = SelectedMidLeft[SelectionFrame];
			break;
		case 4:
			Tex = SelectedMidMiddle[SelectionFrame];
			break;
		case 5:
			Tex = SelectedMidRight[SelectionFrame];
			break;
		case 6:
			Tex = SelectedBotLeft[SelectionFrame];
			break;
		case 7:
			Tex = SelectedBotMiddle[SelectionFrame];
			break;
		case 8:
			Tex = SelectedBotRight[SelectionFrame];
			break;
		}
		ScreenCanvas.DrawBitmap( X, Y, 0, 0, 0, 0, Tex, true, false, false );
	}
}

function int GetX(int i)
{
	if ((i == 0) || (i == 3) || (i == 6))
		return 38;
	else if ((i == 1) || (i == 4) || (i == 7))
		return 98;
	else if ((i == 2) || (i == 5) || (i == 8))
		return 158;
}

function int GetY(int i)
{
	if ((i == 0) || (i == 1) || (i == 2))
		return 37;
	else if ((i == 3) || (i == 4) || (i == 5))
		return 98;
	else if ((i == 6) || (i == 7) || (i == 8))
		return 158;
}

function CheckVictory()
{
	local Actor A;
	local int i, Toggled;

	for (i=0; i<9; i++)
	{
		Toggled += GridNode[i];
	}
	if (Toggled == 9)
	{
		// Victory, all lights on or off.
		PuzzleWon = true;

		if( SuccessEvent != '' )
			foreach AllActors( class 'Actor', A, SuccessEvent )
				A.Trigger( Self, TouchPawn );

		PlaySound( SuccessSound, SLOT_None );
	}
}

function ScreenTouched( Pawn Other, float X, float Y )
{
	if (bDisrupted || bPowerOff)
		return;

	if (TouchPawn == None)
	{
		// Setup the canvas.
		SaverActive			= false;
		ScreenSaver.pause	= true;
		MultiSkins[ScreenSurface] = ScreenCanvas;
		ScreenCanvas.palette= PuzzleBackground.palette;
		bDirty				= true;

		TouchPawn = PlayerPawn(Other);
		SmallFont = DukeHUD(TouchPawn.MyHUD).SmallFont;
		LargeFont = DukeHUD(TouchPawn.MyHUD).MediumFont;

		// Play a greeting.
		PlaySound( ActivateSound, SLOT_None );
	}
	else if (!PuzzleWon && (HighlightNode != -1))
	{
		if (Other.IsA('DukePlayer'))
			DukePlayer(Other).Hand_PressButton();

		ToggleNodes();

		PlaySound( SelectSound, SLOT_None );

		CheckVictory();
	}
}

function ToggleNodes()
{
	local int i;

	for (i=0; i<9; i++)
	{
		if (i == HighlightNode)
			ToggleNode(i);
		else if (i == HighlightNode-GridRows)
			ToggleNode(i);
		else if (i == HighlightNode+GridRows)
			ToggleNode(i);

		if (!HighlightIsRightBorder())
		{
			if (i == HighlightNode+1)
				ToggleNode(i);
			else if (i == HighlightNode+GridRows+1)
				ToggleNode(i);
			else if (i == HighlightNode-GridRows+1)
				ToggleNode(i);
		}

		if (!HighlightIsLeftBorder())
		{
			if (i == HighlightNode-1)
				ToggleNode(i);
			else if (i == HighlightNode+GridRows-1)
				ToggleNode(i);
			else if (i == HighlightNode-GridRows-1)
				ToggleNode(i);
		}
	}
}

function ToggleNode(int i)
{
	if (GridNode[i] == 1)
	{
		GridNode[i] = 0;
	} else {
		GridNode[i] = 1;
	}
	bDirty = true;
}

function bool HighlightIsRightBorder()
{
	if ((HighlightNode == 2) ||
		(HighlightNode == 5) ||
		(HighlightNode == 8))
		return true;
	return false;
}

function bool HighlightIsLeftBorder()
{
	if ((HighlightNode == 0) ||
		(HighlightNode == 3) ||
		(HighlightNode == 6))
		return true;
	return false;
}

function CloseDecoration( Actor Other )
{
	CloseTime = 0.0;
	TouchPawn = None;
	ScreenSaver.pause = false;
	MultiSkins[ScreenSurface] = ScreenSaver;
	SaverActive = true;
}

// circuitpuzzle1.cell_highlight1
defaultproperties
{
	Mesh=mesh'c_generic.puzzlescreen'
	ScreenSurface=1

	CollisionHeight=12
	CollisionRadius=8
	bMeshLowerByCollision=true
	bProjTarget=true

	HealthPrefab=HEALTH_NeverBreak
	ItemName="Circuit Grid"
	LodMode=LOD_Disabled

	CanvasTexture=texturecanvas'powerpuzzle1.ppuzzle_screen'
	PuzzleBackground=texture'circuitpuzzle1.circuitpuz_back'

	GridString="Circuit Grid"
	FailureString="System Failure!"
	SuccessString="Grid Restored"
	InstructionsString1="Toggle all circuit nodes"
	InstructionsString2="to HOT to initiate reset."
	OperationalString="All Systems Operational"

	HighlightSound=sound'a_switch.PPanNodeHL1'
	SelectSound=sound'a_switch.PPanNodeSel1'
	SuccessSound=sound'a_switch.PPanBypassOK1'
	FailSound=sound'a_switch.PPanBypassNo1'
	ActivateSound=sound'a_switch.PPanActive01'

	HighlightedPiece(0)=texture'circuitpuzzle1.highlighted.topleftHL'
	HighlightedPiece(1)=texture'circuitpuzzle1.highlighted.topmiddleHL'
	HighlightedPiece(2)=texture'circuitpuzzle1.highlighted.toprightHL'
	HighlightedPiece(3)=texture'circuitpuzzle1.highlighted.midleftHL'
	HighlightedPiece(4)=texture'circuitpuzzle1.highlighted.midmiddleHL'
	HighlightedPiece(5)=texture'circuitpuzzle1.highlighted.midrightHL'
	HighlightedPiece(6)=texture'circuitpuzzle1.highlighted.botleftHL'
	HighlightedPiece(7)=texture'circuitpuzzle1.highlighted.botmiddleHL'
	HighlightedPiece(8)=texture'circuitpuzzle1.highlighted.botrightHL'

	SelectedTopLeft(0)=texture'circuitpuzzle1.selected.topleftglow1'
	SelectedTopLeft(1)=texture'circuitpuzzle1.selected.topleftglow2'
	SelectedTopLeft(2)=texture'circuitpuzzle1.selected.topleftglow3'
	SelectedTopLeft(3)=texture'circuitpuzzle1.selected.topleftglow2'
	SelectedTopMiddle(0)=texture'circuitpuzzle1.selected.topmiddleglow1'
	SelectedTopMiddle(1)=texture'circuitpuzzle1.selected.topmiddleglow2'
	SelectedTopMiddle(2)=texture'circuitpuzzle1.selected.topmiddleglow3'
	SelectedTopMiddle(3)=texture'circuitpuzzle1.selected.topmiddleglow2'
	SelectedTopRight(0)=texture'circuitpuzzle1.selected.toprightglow1'
	SelectedTopRight(1)=texture'circuitpuzzle1.selected.toprightglow2'
	SelectedTopRight(2)=texture'circuitpuzzle1.selected.toprightglow3'
	SelectedTopRight(3)=texture'circuitpuzzle1.selected.toprightglow2'
	SelectedMidLeft(0)=texture'circuitpuzzle1.selected.midleftglow1'
	SelectedMidLeft(1)=texture'circuitpuzzle1.selected.midleftglow2'
	SelectedMidLeft(2)=texture'circuitpuzzle1.selected.midleftglow3'
	SelectedMidLeft(3)=texture'circuitpuzzle1.selected.midleftglow2'
	SelectedMidMiddle(0)=texture'circuitpuzzle1.selected.midmiddleglow1'
	SelectedMidMiddle(1)=texture'circuitpuzzle1.selected.midmiddleglow2'
	SelectedMidMiddle(2)=texture'circuitpuzzle1.selected.midmiddleglow3'
	SelectedMidMiddle(3)=texture'circuitpuzzle1.selected.midmiddleglow2'
	SelectedMidRight(0)=texture'circuitpuzzle1.selected.midrightglow1'
	SelectedMidRight(1)=texture'circuitpuzzle1.selected.midrightglow2'
	SelectedMidRight(2)=texture'circuitpuzzle1.selected.midrightglow3'
	SelectedMidRight(3)=texture'circuitpuzzle1.selected.midrightglow2'
	SelectedBotLeft(0)=texture'circuitpuzzle1.selected.botleftglow1'
	SelectedBotLeft(1)=texture'circuitpuzzle1.selected.botleftglow2'
	SelectedBotLeft(2)=texture'circuitpuzzle1.selected.botleftglow3'
	SelectedBotLeft(3)=texture'circuitpuzzle1.selected.botleftglow2'
	SelectedBotMiddle(0)=texture'circuitpuzzle1.selected.botmiddleglow1'
	SelectedBotMiddle(1)=texture'circuitpuzzle1.selected.botmiddleglow2'
	SelectedBotMiddle(2)=texture'circuitpuzzle1.selected.botmiddleglow3'
	SelectedBotMiddle(3)=texture'circuitpuzzle1.selected.botmiddleglow2'
	SelectedBotRight(0)=texture'circuitpuzzle1.selected.botrightglow1'
	SelectedBotRight(1)=texture'circuitpuzzle1.selected.botrightglow2'
	SelectedBotRight(2)=texture'circuitpuzzle1.selected.botrightglow3'
	SelectedBotRight(3)=texture'circuitpuzzle1.selected.botrightglow2'

	ExamineFOV=75.0
}