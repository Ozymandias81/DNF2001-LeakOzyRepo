/*-----------------------------------------------------------------------------
	UDukeNewGameWindow
	Author: John Pollard
-----------------------------------------------------------------------------*/
class UDukeNewGameWindow expands UDukeFramedWindow;

var bool bLocked;

function Close( optional bool bByParent )
{
	if ( bLocked )
		return;
	Super.Close( bByParent );
}

defaultproperties
{
	ClientClass=class'UDukeNewGameWindowSC'
	WindowTitle="New Game Selection"
}