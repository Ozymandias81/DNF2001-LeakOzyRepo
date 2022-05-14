//==========================================================================
// 
// FILE:			UDukeFakeExplorerWindowPlayerSetup.uc
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
class UDukeFakeExplorerWindowPlayerSetup expands UDukeFakeExplorerWindow; 

function Created()
{
	ClientClass = class'UDukePlayerSetupTopSC';
    WindowTitle="Player Setup";
	Super.Created();	
}

defaultproperties
{
}
