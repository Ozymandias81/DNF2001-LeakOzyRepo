//=============================================================================
// UDukeInfoClientWindow - extra info on a specific server
//=============================================================================
class UDukeInfoCW extends UWindowClientWindow;

var UDukeServerList     Server;
var UWindowVSplitter    VSplitter;
var UWindowHSplitter    HSplitter;
var float               PrevSplitPos;

function Created()
{
	Super.Created();
	
	VSplitter = UWindowVSplitter(           CreateWindow( class'UWindowVSplitter', 0, 0, WinWidth, WinHeight ) );
	HSplitter = UWindowHSplitter( VSplitter.CreateWindow( class'UWindowHSplitter', 0, 0, WinWidth, WinHeight ) );

	VSplitter.BottomClientWindow = HSplitter;
    VSplitter.TopClientWindow    = UDukePlayerGrid  ( VSplitter.CreateWindow( class'UDukePlayerGrid',   0, 0, WinWidth, WinHeight ) );
	HSplitter.LeftClientWindow   = UDukeRulesGrid   ( HSplitter.CreateWindow( class'UDukeRulesGrid',    0, 0, WinWidth, WinHeight ) );
	HSplitter.RightClientWindow  = UDukeScreenshotCW( HSplitter.CreateWindow( class'UDukeScreenshotCW', 0, 0, WinWidth, WinHeight ) );   
}

function Resized()
{
	VSplitter.SetSize( WinWidth, WinHeight );

	VSplitter.OldWinHeight  = VSplitter.WinHeight;
	VSplitter.SplitPos      = WinHeight / 2;
	PrevSplitPos            = VSplitter.SplitPos;

	HSplitter.WinWidth      = WinWidth;
	HSplitter.OldWinWidth   = WinWidth;
	HSplitter.SplitPos      = WinWidth - VSplitter.SplitPos;
}

function Paint(Canvas C, float X, float Y)
{
	DrawStretchedTexture( C, 0, 0, WinWidth, WinHeight, Texture'BlackTexture' );
	
    if ( VSplitter.SplitPos != PrevSplitPos )
	{
		PrevSplitPos        = VSplitter.SplitPos;
		HSplitter.SplitPos  = HSplitter.WinWidth - ( VSplitter.WinHeight - VSplitter.SplitPos );
	}
}

function BeforePaint( Canvas C, float X, float Y )
{
	Super.BeforePaint( C, X, Y );
	if ( VSplitter.SplitPos != PrevSplitPos )
	{
		PrevSplitPos = VSplitter.SplitPos;
		HSplitter.SplitPos = HSplitter.WinWidth - ( VSplitter.WinHeight - VSplitter.SplitPos );
	}
}
