class TournamentConsole extends UnrealConsole
	abstract;

// Speech
var bool				bShowSpeech;

function EvaluateMatch(int PendingChange, bool Evaluate)
{
}

function StartNewGame()
{
}

function LoadGame()
{
}

/*
 * Tutorial Message Interface
 */

function CreateMessage()
{
	// Implemented in child.
}

function ShowMessage()
{
	// Implemented in child.
}

function HideMessage()
{
	// Implemented in child.
}

function AddMessage(string NewMessage)
{
	// Implemented in child.
}

/*
 * Speech Interface
 */

function CreateSpeech()
{
	// Implemented in child.
}

function ShowSpeech()
{
	// Implemented in child.
}

function HideSpeech()
{
	// Implemented in child.
}

function PrintActionMessage( Canvas C, string BigMessage )
{
	local float XL, YL;

	if ( Len(BigMessage) > 10 )
		C.Font = class'FontInfo'.Static.GetStaticBigFont(C.ClipX);
	else
		C.Font = class'FontInfo'.Static.GetStaticHugeFont(C.ClipX);
	C.bCenter = false;
	C.StrLen( BigMessage, XL, YL );
	C.SetPos(FrameX/2 - XL/2 + 1, (FrameY/3)*2 - YL/2 + 1);
	C.DrawColor.R = 0;
	C.DrawColor.G = 0;
	C.DrawColor.B = 0; 
	C.DrawText( BigMessage, false );
	C.SetPos(FrameX/2 - XL/2, (FrameY/3)*2 - YL/2);
	C.DrawColor.R = 0;
	C.DrawColor.G = 0;
	C.DrawColor.B = 255; 
	C.DrawText( BigMessage, false );
}

defaultproperties
{
}