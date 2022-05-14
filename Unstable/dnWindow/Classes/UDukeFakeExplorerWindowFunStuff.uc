//==========================================================================
// 
// FILE:			UDukeFakeExplorerWindowFunStuff.uc
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
class UDukeFakeExplorerWindowFunStuff expands UDukeFakeExplorerWindow;

//TLW: A bogus abstraction, so that createwindow is fooled to think this is
//		a unique window, so it doesn't open inside another UDukeFakeExplorerWindow 

function Created() 
{
	WindowTitle="Fun Stuff";
	Super.Created();
}

defaultproperties
{
}
