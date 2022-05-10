/*-----------------------------------------------------------------------------
	UDukeFrameButton
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class UDukeFrameButton extends UWindowButton;

var UDukeFramedWindow FrameWindow;

function Notify( byte E )
{
	if ( FrameWindow != None )
	{
		FrameWindow.Notify( Self, E );
	}
}
