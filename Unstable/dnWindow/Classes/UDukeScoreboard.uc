/*-----------------------------------------------------------------------------
	UDukeScoreboard
	Author: Scott Alden
-----------------------------------------------------------------------------*/
class UDukeScoreboard extends UDukeFramedWindow;

var bool bTellActive;

event bool KeyEvent( byte Key, byte Action, FLOAT Delta )
{	
	if ( 
	     ( DukeConsole( Root.Console ) != None ) &&
	     ( Key == DukeConsole( Root.Console ).ScoreboardKey ) && 
		 ( Action == 1 ) // IST_Press
	   )
	{		
		Root.Console.HideScoreboard();
		return true;
	}
	else if ( Key == 0x20 && Action == 1 ) // Spacebar
	{
		if ( GetPlayerOwner() != None )
		{			
			if ( GetPlayerOwner().DoRespawn() )
			{
				Root.Console.HideScoreboard();
				return true;
			}
		}
	}
	return false;
}

function Resized()
{
	Super.Resized();

	SetSize( Min( Root.WinWidth-50, 600 ), Min( Root.WinHeight-50, 425 ) );
	
	WinLeft = ( Root.WinWidth - WinWidth ) / 2;
	WinTop  = ( Root.WinHeight - WinHeight ) / 2;
}

function DelayedClose()
{
	Super.DelayedClose();

	DukeConsole( Root.Console ).bShowScoreboard = false;

	if ( Root.bQuickKeyEnable )
	{
		Root.Console.bCloseForSureThisTime = true;
		Root.Console.CloseUWindow();
		Root.Console.bCloseForSureThisTime = false;
	}
}

defaultproperties
{
	ClientClass=class'UDukeScoreboardSC'
	WindowTitle="Scoreboard"
}

