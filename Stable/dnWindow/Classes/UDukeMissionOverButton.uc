/*-----------------------------------------------------------------------------
	UDukeMissionOverButton
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class UDukeMissionOverButton extends UWindowButton;

var UDukeDesktopWindow Desktop;

function Notify(byte E)
{
	Desktop.DeathButtonEvent(Self, E);
}