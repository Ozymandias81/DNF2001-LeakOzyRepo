/*-----------------------------------------------------------------------------
	UDukeDukeNetWindow
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class UDukeDukeNetWindow extends UDukeFramedWindow;

function Resized()
{
    local int newW, newH;

    Super.Resized();
    
    newW = Root.WinWidth - Root.WinWidth / 12;
    newH = Root.WinHeight - Root.WinHeight / 12;

    SetSize( newW, newH );

    WinLeft = ( Root.WinWidth / 12 ) / 2;
    WinTop  = ( Root.WinHeight / 12 ) / 2;
}

defaultproperties
{
	ClientClass=class'UDukeNetSC'
	WindowTitle="Duke Net"
}
