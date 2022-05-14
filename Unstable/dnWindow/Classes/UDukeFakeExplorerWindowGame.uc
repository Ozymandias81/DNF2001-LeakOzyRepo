//==========================================================================
// 
// FILE:			UDukeFakeExplorerWindowGame.uc
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
class UDukeFakeExplorerWindowGame expands UDukeFakeExplorerWindow; 

function Created() 
{
	ClientClass=class'UDukeGameOptionsSC';
	WindowTitle="Game";

	Super.Created();
}

defaultproperties
{
}
