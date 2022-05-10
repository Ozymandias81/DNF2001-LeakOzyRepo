/*-----------------------------------------------------------------------------
	UDukePlayerSetupTopCW
	Author: Scott Alden, Brandon Reinhart
-----------------------------------------------------------------------------*/
class UDukePlayerSetupTopCW extends UDukePageWindow;

var UWindowHSplitter        Splitter;
var class<UWindowWindow>    PlayerSetupClass;

function Created()
{
	Super.Created();

	Splitter = UWindowHSplitter( CreateWindow( class'UWindowHSplitter', 0, 0, WinWidth, WinHeight ) );
	
	Splitter.RightClientWindow = UDukePlayerMeshCW( Splitter.CreateWindow( class'UDukePlayerMeshCW', 0, 0, 100, 100 ) );
	Splitter.LeftClientWindow  = Splitter.CreateWindow( PlayerSetupClass, 0, 0, 100, 100, OwnerWindow );

	Splitter.bSizable = false;
	Splitter.bRightGrow = true;
	Splitter.SplitPos   = WinWidth * 0.55f;
}

function Resized()
{
	Super.Resized();
	Splitter.SetSize( WinWidth, WinHeight );
}

defaultproperties
{
	PlayerSetupClass=class'UDukePlayerSetupSC'
}