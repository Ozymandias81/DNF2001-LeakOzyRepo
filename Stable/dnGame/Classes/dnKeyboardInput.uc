//=============================================================================
// dnKeyboardInput (JP)
//	Sort of a window interface that takes over the users keyboard through the main pawn
//
// Windowing extensions by Brandon Reinhart
// Also added new text editing system.
//=============================================================================
class dnKeyboardInput expands dnDecoration;

#exec OBJ LOAD FILE=..\Textures\canvasfx.dtx

var () TextureCanvas	ScreenCanvas;			// What to render the windows on
var () Texture			BackgroundTexture;
var () byte				BackgroundColor;
var () byte				BorderColorFocus;
var () vector			DstViewOffs;
var () vector			SrcViewOffs;
var () name				OptViewInfoActorName;
var () float			ViewLerpSpeed;
var int					BackgroundFrame;

var () int				WindowOffsX;
var () int				WindowOffsY;

var () byte				TextColor;
var () bool				bUseTextColor;

var () name				ScreenTag;
var () int				MeshScreenIndex;

var actor				OptViewInfoActor;
var bool				bLerping;
var float				LerpingPercent;
var vector				StartLocation;
var rotator				StartRotation;
var rotator				StartViewRotation;

var bool				bShiftDown;

var DukePlayer			Duke;			// Duke currently using the keyboard

var bool				DrawCursor;		// Whether to draww the cursor or not
var float				CursorTime;

var transient font		SmallFont;		// Font to use
var transient font		OldSmallFont;
var float				XSize, YSize;	// Font sizes

var int					CW;
var int					NumWindows;
var int					MaxHighlightWindow;

var texture				OldScreenTexture;
var int					ScreenSurfaceIndex;

//	This structure is big and bulky, but unless I turn it into a class
//	there is no other way...  And I can't make it an Object cause I need EInputKey
//	which is not visible from Object :(  The only way would be to make it an ActorInfo, and that
//	would be bigger than this bulky structure just for the darn class... so this is what I chose :)
struct SWindowControl
{
	var string			Name;
	var bool			IsConsole;		// Acts like a console with a command prompt, else acts like an editor
	var bool			IsButton;		// Acts like a button
	var float			ButtonDownTime;
	var int				x;
	var int				y;
	var int				Width;
	var int				Height;
	var int				ClickWidth, ClickHeight;
	var int				hx, hy;

	var bool			PrivateEcho;
	var bool			NoEdit;

	var string			TextLines[64];	// Text buffer for window
	var int				MaxLines;		// Used when not a console (will destroy old text otherwise)
	var int				CurrentLine;	// Where new text gets inserted.
	var int				CurrentPos;		// Cursor position on current line.
	var int				Start;
	var int				HighestEditLine;

	var texture			ButtonTex;
	var texture			ButtonDownTex;
	var texture			HighlightTex;
};

// These aren't really windows.  These are more like window fields like Text box's, and butttons, etc
//var array <SWindowControl>	Windows;
var SWindowControl		Windows[16];

// Mouse support
var texture MouseTexture;
var float MouseX, MouseY, OldMouseX, OldMouseY;
var float TimeToOut;

// Login system.
var () bool				LoginRequired;
var () string			LoginUsername;
var () string			LoginPassword;
var () smackertexture	LoginSmack;
var    bool				LoggingIn;
var () texture			LoginFailedTexture;
var () int				LoginFailedX, LoginFailedY;
var    bool				LoginFailed;
var    float			LoginFailedTime;
var    bool				TransitionToBackground;
var () smackertexture   TransitionToBackgroundSmack;
var () int				TransitionToBackgroundFrames;

//=============================================================================
//	PostBeginPlay
//=============================================================================
function PostBeginPlay()
{
	local int		i;

	Super.PostBeginPlay();

	// Clear the screen
	ClearCanvas();

	// Add keyboard input window.
	if ( !LoginRequired )
		EnableKeyboardInput();

	// Prime offscreen smacks.
	PrimeOffscreenSmacks();

	LerpingPercent = 0.0f;
	bLerping = false;

	if (OptViewInfoActorName != '')
	{
		foreach allactors(class'Actor', OptViewInfoActor, OptViewInfoActorName)
		{
			if (OptViewInfoActor != None)
				break;
		}
	}

	//SrcViewOffs=vect(-70,-11.0,3.0);
	//DstViewOffs=vect(0.0,-11.0,3.0);
	ScreenSurfaceIndex = -1;

	Disable('Tick');
}

function PrimeOffscreenSmacks()
{
	if ( LoginSmack != None )
	{
		LoginSmack.currentFrame = 0;
		LoginSmack.pause = true;
		LoginSmack.ForceTick(1.0);
	}
	if ( TransitionToBackgroundSmack != None )
	{
		TransitionToBackgroundSmack.currentFrame = 0;
		TransitionToBackgroundSmack.pause = true;
		TransitionToBackgroundSmack.ForceTick(1.0);
	}
}

simulated function EnableKeyboardInput()
{
	NumWindows = 1;
	
	// Message
	Windows[0].Name = "KeyboardInput";
	Windows[0].IsConsole = true;
	Windows[0].x = 4; Windows[0].y = 80;
	Windows[0].Width = 48; Windows[0].Height = 10;
	Windows[0].MaxLines = 0;
}

simulated function EnableLoginWindow()
{
}

//=============================================================================
//	KeyType
//=============================================================================
function bool KeyType( EInputKey Key )
{
	local int MaxLen, CurrentLine, CurrentPos, Length;
	local string NewText;
	local float XL, YL;

	if (CW >= NumWindows)
		return true;

	if (Windows[CW].NoEdit)
		return true;

	if (Windows[CW].IsButton)
		return true;			// Can't type in buttons

	if (ScreenCanvas == None)
		return true;

	if (SmallFont == None)
		return true;

	if ( Key >= 0x20 && Key < 0x100 && Key != Asc("~") && Key != Asc("`") )
	{
		AddCharacter( Chr(Key), CW, Windows[CW].CurrentLine, Windows[CW].CurrentPos, true );
	}

	return true;
}

function AddCharacter( string Char, int Index, int CurLine, int CurPos, bool bAdvanceCursor )
{
	local int Length, i;
	local string NewText, RemString;
	local float XL, YL, XL2, YL2, Overflow;
	local bool FoundRemainder;

	Length  = Len( Windows[Index].TextLines[CurLine] );
	NewText = Left( Windows[Index].TextLines[CurLine], CurPos );
	NewText = NewText $ Char;
	NewText = NewText $ Right( Windows[Index].TextLines[CurLine], Length - CurPos );

	ScreenCanvas.TextSize( NewText, XL, YL, SmallFont );

	if ( XL > Windows[Index].Width )
	{
		if ( !Windows[Index].IsConsole )
			return; // No room on single line control for character.

		if ( CurLine == Windows[Index].MaxLines-1 )
			return; // No room on the last line for the character.

		// No room on this line for the character.
		// Find out how much we need to cut off the end.
		Overflow = XL - Windows[Index].Width;
		for ( i=0; (i<Len(NewText)) && !FoundRemainder; i++ )
		{
			RemString = Right( NewText, i );
			ScreenCanvas.TextSize( RemString, XL2, YL2, SmallFont );
			if ( XL2 >= Overflow )
			{
				// Cut the same amount of characters from the end.
				FoundRemainder = true;
				NewText = Left( NewText, Len(NewText) - i );
			}
		}

		// Set the line.
		Windows[Index].TextLines[CurLine] = NewText;

		// Add the remaining string to the start of the next line.
		AddCharacter( RemString, Index, CurLine+1, 0, false );

		// Advance the cursor.
		if ( bAdvanceCursor )
		{
			if ( CurPos == Len(NewText) )
			{
				Windows[Index].CurrentPos = 1;
				Windows[Index].CurrentLine++;
			}
			else
			{
				Windows[Index].CurrentPos++;
			}
		}
	}
	else
	{
		// Room for the character.  Set the line and advance.
		Windows[Index].TextLines[CurLine] = NewText;
		if ( bAdvanceCursor )
			Windows[Index].CurrentPos++;
	}

	if ( Windows[Index].CurrentLine > Windows[Index].HighestEditLine )
		Windows[Index].HighestEditLine = Windows[Index].CurrentLine;
}

//=============================================================================
//	PotentialConsoleCommand
//=============================================================================
function bool PotentialConsoleCommand(string Command, int WindowIndex)
{
	return false;
}

//=============================================================================
//	ButtonPressed
//=============================================================================
function ButtonPressed(int WindowIndex)
{
}

//=============================================================================
//	KeyEvent
//=============================================================================
function bool KeyEvent( EInputKey Key, EInputAction Action, FLOAT Delta )
{
	local int CurrentLine, CurrentPos, Length;
	local string NewText, NextLine;

	CurrentLine = Windows[CW].CurrentLine;
	CurrentPos = Windows[CW].CurrentPos;

	// Brandon says: Here is the mouse input hook.
	if ( Action == IST_Axis )
	{
		switch (Key) 
		{
			case IK_MouseX: 
				MouseX += Delta;
				MouseX = FClamp( MouseX, 0, 252 );
				break;
			case IK_MouseY:
				MouseY -= Delta;
				MouseY = FClamp( MouseY, 0, 252 );
				break;
		}
		return true;
	}
	// End mouse input hook.

	if ( CW >= NumWindows )
		return true;

	if ( Action == IST_Release )
	{
		if ( Key == IK_Shift )
			bShiftDown = false;
		return true;
	}

	if ( Action != IST_Press )
		return true;

	// Brandon says: Input hook for button press.
	if ( Key == IK_LeftMouse )
	{
		MouseClick();
		return true;
	}
	// End mouse input hook.

	if ( Key == IK_Shift )
		bShiftDown = true;

	if ( Key == IK_Escape )
	{
		DetachDuke();
		return true;
	}
	else if ( Key == IK_Tab )
	{
		if ( bShiftDown )
		{
			CW --;
			if ( CW < 0 )
				CW = MaxHighlightWindow;
		}
		else
		{
			CW ++;
			if ( CW > MaxHighlightWindow )
				CW = 0;
		}
	}
	else if ( Windows[CW].IsButton )
	{
		if ( Key == IK_Enter )
			ButtonPressed(CW);
		return true;
	}
	else if ( Key == IK_Enter )
	{
		if ( HandleEnter() )
			return true;
		else if ( Windows[CW].IsConsole )
		{
			// Advance the cursor.
			Windows[CW].CurrentPos = 0;
			if ( Windows[CW].CurrentLine < Windows[CW].MaxLines-1 )
				Windows[CW].CurrentLine++;
		}
	}
	else if ( Key == IK_MouseWheelDown )
	{
		ScrollDown( 3 );
	}
	else if ( Key == IK_MouseWheelUp )
	{
		ScrollUp( 3 );
	}
	else if ( Key == IK_PageUp || Key == IK_MouseWheelUp )
	{
		ScrollUp( Windows[CW].Height );
	}
	else if ( Key == IK_PageDown || Key == IK_MouseWheelDown )
	{
		ScrollDown( Windows[CW].Height );
	}
	else if ( Key == IK_Delete )
	{
		if ( Windows[CW].CurrentPos < Len( Windows[CW].TextLines[CurrentLine] ) )
		{
			NewText = Left( Windows[CW].TextLines[CurrentLine], CurrentPos );
			NewText = NewText $ Right( Windows[CW].TextLines[CurrentLine], Len( Windows[CW].TextLines[CurrentLine] ) - CurrentPos - 1 );
			Windows[CW].TextLines[CurrentLine] = NewText;
		}
	}
	else if ( Key == IK_Backspace )
	{
		if ( Windows[CW].CurrentPos > 0 )
			Windows[CW].CurrentPos--;
		else if ( Windows[CW].CurrentLine > 0 )
		{
			Windows[CW].CurrentLine--;
			CurrentLine = Windows[CW].CurrentLine;
			Windows[CW].CurrentPos = Len(Windows[CW].TextLines[CurrentLine]);
		}

		NewText = Left( Windows[CW].TextLines[CurrentLine], CurrentPos - 1 );
		NewText = NewText $ Right( Windows[CW].TextLines[CurrentLine], Len( Windows[CW].TextLines[CurrentLine] ) - CurrentPos );
		Windows[CW].TextLines[CurrentLine] = NewText;
	}
	else if ( Key == IK_Left )
	{
		if ( Windows[CW].CurrentPos > 0 )
			Windows[CW].CurrentPos--;
		else if ( Windows[CW].CurrentLine > 0 )
		{
			Windows[CW].CurrentLine--;
			CurrentLine = Windows[CW].CurrentLine;
			Windows[CW].CurrentPos = Len(Windows[CW].TextLines[CurrentLine]);
		}
	}
	else if ( Key == IK_Right )
	{
		Windows[CW].CurrentPos++;
		if ( Windows[CW].CurrentPos > Len(Windows[CW].TextLines[CurrentLine]) )
		{
			if ( Windows[CW].CurrentLine < Windows[CW].MaxLines - 1 )
			{
				Windows[CW].CurrentLine++;
				Windows[CW].CurrentPos = 0;
			} else
				Windows[CW].CurrentPos--;
		}
	}
	else if ( Key == IK_Up )
	{
		ScrollUp( 1 );
	}
	else if ( Key == IK_Down )
	{
		ScrollDown( 1 );
	}
	else if ( Key == IK_Home )
	{
		Windows[CW].CurrentPos = 0;
	}
	else if ( Key == IK_End )
	{
		Windows[CW].CurrentPos = Len(Windows[CW].TextLines[CurrentLine]);
	}
	
	return true;	
}

function ScrollDown( int i )
{
	if ( Windows[CW].CurrentLine + i >= Windows[CW].MaxLines )
		i = Windows[CW].MaxLines - Windows[CW].CurrentLine - 1;

	Windows[CW].CurrentLine += i;
	if ( Windows[CW].CurrentPos > Len(Windows[CW].TextLines[Windows[CW].CurrentLine]) )
		Windows[CW].CurrentPos = Len(Windows[CW].TextLines[Windows[CW].CurrentLine]);
}

function ScrollUp( int i )
{
	if ( Windows[CW].CurrentLine - i < 0 )
		Windows[CW].CurrentLine = 0;
	else
		Windows[CW].CurrentLine -= i;

	if ( Windows[CW].CurrentPos > Len(Windows[CW].TextLines[Windows[CW].CurrentLine]) )
		Windows[CW].CurrentPos = Len(Windows[CW].TextLines[Windows[CW].CurrentLine]);
}

function bool HandleEnter()
{
	return false;
}

// Current window clicked by mouse.
function WindowClick()
{
	local float XL, YL;
	local int i, Start, End, ClickedLine, ClickedPos, X, Y, LeftX, RightX, Length;
	local string Letter, FoundLetter, Text;
	local bool bPassedCursor;
	
	Start = Windows[CW].Start;
	End   = Start + Windows[CW].Height;

	if ( End - Start > Windows[CW].Height )
		End += Windows[CW].Height - (End - Start);

	X = Windows[CW].X;
	Y = Windows[CW].Y;

	ClickedLine = -1;
	for ( i=0; (i<Windows[CW].Height) && (ClickedLine == -1); i++ )
	{
		if ( (MouseY >= Y) && (MouseY <= Y+YSize) )
		{
			ClickedLine = i;
		}
		Y += YSize;
	}
	if ( ClickedLine == -1 )
		return;

	ClickedLine += Start;

	// If we clicked the current line, account for the position of the cursor.
	if ( ClickedLine == Windows[CW].CurrentLine )
	{
		// Get the first part of line.
		Length = Len( Windows[CW].TextLines[ClickedLine] );
		Text = Left( Windows[CW].TextLines[ClickedLine], Windows[CW].CurrentPos );
		Text = Text $ "|" $ Right( Windows[CW].TextLines[ClickedLine], Length - Windows[CW].CurrentPos );
	} else
		Text = Windows[CW].TextLines[ClickedLine];

	for ( i=0; (i<Len(Text)) && (FoundLetter == ""); i++ )
	{
		ScreenCanvas.TextSize( Left( Text, i ), XL, YL, SmallFont );
		LeftX = XL + X;
		Letter = Mid( Text, i, 1 );

		if ( Letter == "|" )
			bPassedCursor = true;

		ScreenCanvas.TextSize( Letter, XL, YL, SmallFont );
		RightX = LeftX + XL;
		if ( (MouseX >= LeftX) && (MouseX <= LeftX + ((RightX-LeftX)/2)) )
		{
			FoundLetter = Letter;
			ClickedPos = i;
			if ( bPassedCursor )
				ClickedPos--;
		}
		else if ( (MouseX >= LeftX + ((RightX-LeftX)/2)) && (MouseX <= RightX) )
		{
			FoundLetter = Letter;
			ClickedPos = i+1;
			if ( bPassedCursor )
				ClickedPos--;
		}
	}

	if ( ClickedPos > Len(Text) )
		ClickedPos = Len(Text);

	if ( FoundLetter == "|" )
		return;
	else if ( FoundLetter == "" )
	{
		if ( MouseX < X )
		{
			Windows[CW].CurrentLine = ClickedLine;
			Windows[CW].CurrentPos = 0;
			return;
		}

		ScreenCanvas.TextSize( Text, XL, YL, SmallFont );
		if ( MouseX > XL+X )
		{
			Windows[CW].CurrentLine = ClickedLine;
			Windows[CW].CurrentPos = Len(Text);
			return;
		}
	}

	Windows[CW].CurrentLine = ClickedLine;
	Windows[CW].CurrentPos = ClickedPos;
}

//=============================================================================
//	MouseClick
//=============================================================================
function MouseClick()
{
}

//=============================================================================
//	CalcView
//=============================================================================
function CalcView(out vector CameraLocation, out rotator CameraRotation)
{
	local vector	a, b, FinalLocation;
	local rotator	FinalRotation;

	if (OptViewInfoActor != None)
	{
		FinalRotation = OptViewInfoActor.Rotation;
		FinalLocation = OptViewInfoActor.Location;
	}
	else
	{
		a = (Location+SrcViewOffs);
		b = (Location+DstViewOffs);

		if (VSize(b-a) < 0.00001)
			return;

		FinalRotation = rotator(Normal(b-a));
		FinalLocation = a;
	}

	if (bLerping)
	{
		a = StartLocation + Duke.BaseEyeHeight * vect(0,0,1);
		CameraRotation = Slerp(LerpingPercent, StartViewRotation, FinalRotation);
		CameraLocation = a + (FinalLocation - a)*LerpingPercent;
	}
	else
	{
		CameraRotation = FinalRotation;
		CameraLocation = FinalLocation;
	}
}

//=============================================================================
//	AttachDuke
//=============================================================================
function AttachDuke(DukePlayer NewDuke)
{
	if ( Duke != None )
		return;			// One duke at a time plz

	if ( NewDuke == None )
		return;			// Bad programmer...

	EmptyAllWindows();
	PrimeOffscreenSmacks();

	TimeToOut = 0.0;

	Duke = NewDuke;

	Duke.KeyEventHookActor = self;
	Duke.ViewMapper = Self;
	
	StartLocation = Duke.Location;
	StartRotation = Duke.Rotation;
	StartViewRotation = Duke.ViewRotation;

	LerpingPercent = 0.0f;
	bLerping = true;

	Enable('Tick');
}

function DoneLerping()
{
	bLerping = false;

	if ( ScreenTag != '' )
		ScreenSurfaceIndex = FindSurfaceByName(ScreenTag);
	else
		ScreenSurfaceIndex = -1;

	if ( LoginRequired && (LoginSmack == None) )
		BroadcastMessage(Self@"isn't set up correctly.  LoginRequired set, but LoginSmack missing.");

	if ( LoginRequired )
	{
		LoginSmack.pause = false;
		LoginSmack.loop = true;
		if ( ScreenSurfaceIndex != -1 )
			LoginSmack.currentFrame = SmackerTexture(GetSurfaceTexture(ScreenSurfaceIndex)).currentFrame;
		else
			LoginSmack.currentFrame = SmackerTexture(MultiSkins[MeshScreenIndex]).currentFrame;
		BackgroundFrame = LoginSmack.currentFrame;
		LoggingIn = true;
		EnableLoginWindow();
	}
	else
	{
		EmptyAllWindows();
		TransitionToBackground = true;
		TransitionToBackgroundSmack.currentFrame = 0;
		TransitionToBackgroundSmack.pause = false;
	}

	if (ScreenSurfaceIndex != -1)
	{
		// Save old texture
		OldScreenTexture = GetSurfaceTexture(ScreenSurfaceIndex);		
		// Set new texture
		SetSurfaceTexture(ScreenSurfaceIndex, ScreenCanvas);
	}
	else if (MeshScreenIndex != -1)
	{
		// Save old texture
		OldScreenTexture = MeshGetTexture(MeshScreenIndex);
		// Set new texture
		MultiSkins[MeshScreenIndex] = ScreenCanvas;
	}
}

//=============================================================================
//	DetachDuke
//=============================================================================
function DetachDuke()
{
	Duke.KeyEventHookActor = None;
	Duke.ViewMapper = None;

	OldSmallFont = SmallFont;

	Duke = None;

	LerpingPercent = 0.0f;
	bLerping = false;

	OldMouseX = MouseX;
	OldMouseY = MouseY;

	TimeToOut = 0.6;
}

//=============================================================================
//	RenderScreen
//=============================================================================
function RenderScreen(float DeltaSeconds)
{
	local int		i;

	if (ScreenCanvas == None)
		return;

	// Get the font
	if (Duke != None)
		SmallFont = DukeHUD(Duke.MyHUD).SmallFont;

	if (SmallFont == None)
		SmallFont = OldSmallFont;

	if (SmallFont == None)
		return;

	// Get font size
	ScreenCanvas.TextSize("T", XSize, YSize, SmallFont);
	YSize = YSize+1;

	// Clear the screen
	ClearCanvas();

	for (i=0; i< NumWindows; i++)
		RenderWindow(i, DeltaSeconds);

	// Login failed?
	if ( LoginFailed )
		ScreenCanvas.DrawBitmap( LoginFailedX, LoginFailedY, 0, 0, 0, 0, LoginFailedTexture, true );

	// Draw the mouse
	ScreenCanvas.DrawBitmap( MouseX, MouseY, 0, 0, 0, 0, MouseTexture, true );
}

//=============================================================================
//	RenderWindow
//=============================================================================
function RenderWindow( int Index, float DeltaSeconds )
{
	local int		i, Start, End, TextHeight;
	local int		x, y, Width, Height, CurrentLine, CurrentPos,  y2, Length;
	local float		XL, YL;
	local string	Text;

	x = Windows[Index].x + WindowOffsX;
	y = Windows[Index].y + WindowOffsY;

	Width = Windows[Index].Width;
	Height = Windows[Index].Height;

	// Handle buttons differently
	if ( Windows[Index].IsButton )
	{
		if ( Windows[Index].ButtonDownTime > 0.0 )
		{
			if ( Windows[Index].ButtonDownTex.IsA('SmackerTexture') )
			{
				SmackerTexture(Windows[Index].ButtonDownTex).currentFrame = BackgroundFrame;
				SmackerTexture(Windows[Index].ButtonDownTex).ForceTick(DeltaSeconds);
			}
			ScreenCanvas.DrawBitmap( Windows[Index].x, Windows[Index].y, 0, 0, 0, 0, Windows[Index].ButtonDownTex, true );
		}
		else if ( Windows[Index].ButtonTex != None )
		{
			if ( Windows[Index].ButtonTex.IsA('SmackerTexture') )
				SmackerTexture(Windows[Index].ButtonTex).ForceTick(DeltaSeconds);
			ScreenCanvas.DrawBitmap( Windows[Index].x, Windows[Index].y, 0, 0, 0, 0, Windows[Index].ButtonTex, true );
		}
		return;
	}

	CurrentLine = Windows[Index].CurrentLine;
	CurrentPos = Windows[Index].CurrentPos;

	if ( (Index == CW) && (Windows[Index].HighlightTex != None) )
	{
		if ( Windows[Index].HighlightTex.IsA('SmackerTexture') )
		{
			SmackerTexture(Windows[Index].HighlightTex).pause = true;
			SmackerTexture(Windows[Index].HighlightTex).currentFrame = BackgroundFrame;
			SmackerTexture(Windows[Index].HighlightTex).ForceTick(0.01);
		}
		ScreenCanvas.DrawBitmap( Windows[Index].hx, Windows[Index].hy, 0, 0, 0, 0, Windows[Index].HighlightTex, true );
	}

	if ( !Windows[Index].IsConsole )
	{
		if ( (Index == CW) && !Windows[Index].NoEdit )
		{
			// Draw first part of line.
			Length = Len( Windows[Index].TextLines[0] );
			Text = Left( Windows[Index].TextLines[0], CurrentPos );
			ScreenCanvas.DrawString( SmallFont, x, y, Text,,,,bUseTextColor, TextColor );

			// Add the cursor if it's time
			if ( DrawCursor && !Windows[Index].NoEdit )
			{
				ScreenCanvas.TextSize( Text, XL, YL, SmallFont );
				Text = "|" $ Right( Windows[Index].TextLines[0], Length - CurrentPos );
			}
			else
			{
				ScreenCanvas.TextSize( Text$"|", XL, YL, SmallFont );
				Text = Right( Windows[Index].TextLines[0], Length - CurrentPos );
			}

			// Draw the second part of line.
			ScreenCanvas.DrawString( SmallFont, x+XL, y, Text,,,,bUseTextColor, TextColor );
		}
		else
		{
			// Draw single line edit controls here.
			Text = Windows[Index].TextLines[0];
			ScreenCanvas.DrawString( SmallFont, x, y, Text,,,,bUseTextColor, TextColor );
		}
		return;
	}

	Start = Windows[Index].Start;
	End   = Start + Height;

	if ( CurrentLine > End )
	{
		Start += CurrentLine - End;
		End += CurrentLine - End;
	}
	else if ( CurrentLine < Start )
	{
		Start -= Start - CurrentLine;
		End -= Start - CurrentLine;
	}

	if ( End - Start > Height )
		End += Height - (End - Start);

	Windows[Index].Start = Start;

	for ( i=Start; i<=End; i++ )
	{
		if ( (i == CurrentLine) && (Index == CW) && !Windows[Index].NoEdit )
		{
			// Draw first part of line.
			Length = Len( Windows[Index].TextLines[i] );
			Text = Left( Windows[Index].TextLines[i], CurrentPos );
			ScreenCanvas.DrawString( SmallFont, x, y, Text,,,,bUseTextColor, TextColor );

			// Add the cursor if it's time
			if ( DrawCursor && !Windows[Index].NoEdit )
			{
				ScreenCanvas.TextSize( Text, XL, YL, SmallFont );
				Text = "|" $ Right( Windows[Index].TextLines[i], Length - CurrentPos );
			}
			else
			{
				ScreenCanvas.TextSize( Text$"|", XL, YL, SmallFont );
				Text = Right( Windows[Index].TextLines[i], Length - CurrentPos );
			}

			// Draw the second part of line.
			ScreenCanvas.DrawString( SmallFont, x+XL, y, Text,,,,bUseTextColor, TextColor );
		}
		else
		{
			// Draw the text line.
			Text = Windows[Index].TextLines[i];
			ScreenCanvas.DrawString( SmallFont, x, y, Text,,,,bUseTextColor, TextColor );
		}

		// Increment y location.
		y += YSize;
	}
}

//=============================================================================
//	Tick
//=============================================================================
function Tick(float DeltaSeconds)
{
	local int i;

	CursorTime += DeltaSeconds;
	if (CursorTime >= 0.2)
	{
		if (DrawCursor)
			DrawCursor = false;
		else
			DrawCursor = true;

		CursorTime = 0.0f;
	}
	
	// Force rendering since login smack is offscreen.
	if ( LoggingIn )
	{
		LoginSmack.ForceTick( DeltaSeconds );
		BackgroundFrame = LoginSmack.currentFrame;
	}

	if ( LoginFailedTime > 0.0 )
	{
		LoginFailedTime -= DeltaSeconds;
		if ( LoginFailedTime < 0.0 )
			LoginFailed = false;
	}

	// Force rendering since transition smack is offscreen.
	if ( TransitionToBackground )
	{
		if ( TransitionToBackgroundSmack.currentFrame >= TransitionToBackgroundFrames )
			TransitionToBackgroundFinished();
		else
			TransitionToBackgroundSmack.ForceTick( DeltaSeconds );
		BackgroundFrame = TransitionToBackgroundSmack.currentFrame;
	}
	
	if (bLerping)
	{
		LerpingPercent += DeltaSeconds*ViewLerpSpeed;

		if (LerpingPercent >= 1.0f)
			DoneLerping();
	}

	for (i=0; i<16; i++)
	{
		if ( Windows[i].ButtonDownTime > 0.0 )
		{
			Windows[i].ButtonDownTime -= DeltaSeconds;
			if ( Windows[i].ButtonDownTime < 0.0 )
				Windows[i].ButtonDownTime = 0.0;
		}
	}

	if ( TimeToOut > 0.0 )
	{
		// Send mouse to home.
		TimeToOut -= DeltaSeconds;

		if ( TimeToOut < 0.0 )
		{
			Logout();
			TimeToOut = 0.0;
		}
	}

	RenderScreen( DeltaSeconds );
}

function Logout()
{
	// Restore to old texture
	if (ScreenSurfaceIndex != -1)
		SetSurfaceTexture(ScreenSurfaceIndex, OldScreenTexture);
	else if (MeshScreenIndex != -1)
		MultiSkins[MeshScreenIndex] = OldScreenTexture;
	OldSmallFont = None;
	Disable('Tick');
	EmptyAllWindows();
}

//=============================================================================
//	Used
//=============================================================================
function Used( Actor Other, Pawn EventInstigator )
{
	if (Duke != None)
		return;				// Only one duke at a time plz

	if (!EventInstigator.IsA('DukePlayer'))
		return;

	AttachDuke(DukePlayer(EventInstigator));
}

//=============================================================================
//	ClearCanvas
//=============================================================================
function ClearCanvas()
{
	if ( BackgroundTexture != None )
		ScreenCanvas.Palette = BackgroundTexture.Palette;
	if ( LoggingIn && (LoginSmack != None) )
		ScreenCanvas.DrawBitmap(0,0,0,0,0,0,LoginSmack);
	else if ( TransitionToBackground && (TransitionToBackgroundSmack != None) )
		ScreenCanvas.DrawBitmap(0,0,0,0,0,0,TransitionToBackgroundSmack);
	else if ( BackgroundTexture != None )
		ScreenCanvas.DrawBitmap(0,0,0,0,0,0,BackgroundTexture);
	else
		ScreenCanvas.DrawClear( BackgroundColor );
}

//=============================================================================
//	DrawBox
//=============================================================================
function DrawBox(TextureCanvas c, int x1, int y1, int x2, int y2, byte Color)
{
	local int		i;

	// Top/Bottom
	for (i=x1+1; i < x2; i++)
	{
		c.DrawPixel (i, y1, Color);
		c.DrawPixel (i, y2, Color);
	}
	
	// Sides
	for (i=y1; i <= y2; i++)
	{
		c.DrawPixel (x1, i, Color);
		c.DrawPixel (x2, i, Color);
	}
}

//=============================================================================
//	LoginSuccessful
//=============================================================================
simulated function LoginSuccessful()
{
	LoggingIn = false;
	TransitionToBackground = true;
	TransitionToBackgroundSmack.currentFrame = 0;
	TransitionToBackgroundSmack.pause = false;
}

function TransitionToBackgroundFinished()
{
	TransitionToBackground = false;
}

function EmptyAllWindows()
{
	local int i, j;

	for (i=0; i<16; i++)
	{
		Windows[i].Name = "";
		Windows[i].IsConsole = false;
		Windows[i].IsButton = false;
		Windows[i].x = 0; Windows[i].y = 0;
		Windows[i].Width = 0; Windows[i].Height = 0;
		Windows[i].ClickWidth = 0; Windows[i].ClickHeight = 0;
		Windows[i].hx = 0; Windows[i].hy = 0;
		Windows[i].PrivateEcho = false;
		for (j=0; j<64; j++)
		{
			Windows[i].TextLines[j] = "";
		}
		Windows[i].MaxLines = 0;
		Windows[i].CurrentLine = 0;
		Windows[i].CurrentPos = 0;
		Windows[i].ButtonTex = None;
		Windows[i].ButtonDownTex = None;
		Windows[i].HighlightTex = None;
		Windows[i].NoEdit = false;
	}
	NumWindows = 0;
	CW = 0;
}


//=============================================================================
//	defaultproperties
//=============================================================================
defaultproperties
{
	bUseTriggered=True
	bUnlit=true
	BorderColorFocus=20
	BackgroundColor=96
	SrcViewOffs=(X=-70.0,Y=-11.0,Z=3.0)
	DstViewOffs=(X=0.0,Y=-11.0,Z=3.0)
	OptViewInfoActorName=None
	OptViewInfoActor=None
	ViewLerpSpeed=1.5
	WindowOffsX=0
	WindowOffsY=0
	TextColor=0
	bUseTextColor=false
	ScreenTag=None
	MeshScreenIndex=-1
	bShadowReceive=false
}
