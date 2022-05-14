//==========================================================================
// 
// FILE:			UDukeFakeExplorerWindowDukeNet.uc
// 
// AUTHOR:			Timothy L. Weisser
// 
// DESCRIPTION:		Unique windowframe class required by UT's UI
// 
// NOTES:			
//  
// MOD HISTORY: 
// 
//==========================================================================
class UDukeFakeExplorerWindowDukeNet expands UDukeFakeExplorerWindow;

function Created() 
{
	ClientClass=class'UDukeNetSC';
	WindowTitle="Duke Net";
	Super.Created();
}

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
}
