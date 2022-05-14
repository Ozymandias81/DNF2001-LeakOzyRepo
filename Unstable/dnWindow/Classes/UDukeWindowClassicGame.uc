//==========================================================================
// 
// FILE:			UDukeWeaponPriorityCW.uc
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
class UDukeWindowClassicGame expands UWindowBitmap;

function Created()
{
	Super.Created();

	bStretch = true;
	T = Texture(DynamicLoadObject("DukeLookAndFeel.SpaceInvaders", class'Texture'));
	R.W = T.USize;
	R.H = T.VSize;
}

defaultproperties
{
}
