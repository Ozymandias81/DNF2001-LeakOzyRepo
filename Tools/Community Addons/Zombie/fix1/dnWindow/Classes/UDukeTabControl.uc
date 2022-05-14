//=============================================================================
// 
// FILE:			UDukeStatusBar.uc
// 
// AUTHOR:			Timothy L. Weisser
// 
// DESCRIPTION:		BattleNet-ish Button/Icon
// 
// NOTES:			Expands DukeButton to provide a similar but different
//					Fake Windowing Icon for the DukeNet menu, similar 
//					(almost verbatim) of BattleNet 
//
//					TODO: still has placeholder graphics stolen from BattleNet
//
// MOD HISTORY:		
// 
//==========================================================================
class UDukeTabControl expands UDukeButton;

var bool bTabIsDown;

simulated function Click(float X, float Y) 
{
	Super.Click(X, Y);
//	Log("TIM: Clicked on " $ Name);
}

function PerformSelect()
{
	Super.PerformSelect();

	//pass the selection back to the parent to handle, since it has to access the other tabs, 
	//which UDukeTabControl has no concept of

    // FIXME: This could be handled a little better, currently only UDukePageWindow will respond to a SelectedThisTab call
	if(	UDukePageWindow(ParentWindow) != None )  {

		UDukePageWindow(ParentWindow).SelectedThisTab(self);
		bTabIsDown = true;
    } 
}	

function bool UseOverTexture()
{
	if(bTabIsDown)
		return true;
//	else

	return Super.UseOverTexture();
}

function DrawHighlightedButton(Canvas C, optional float fAlpha)
{
	if(!MouseIsOver())
		DrawStretchedTexture( C, ImageX, ImageY, UpTexture.USize, UpTexture.VSize, UpTexture, fAlpha );	
	else
		Super.DrawHighlightedButton(C, fAlpha);
}

defaultproperties
{
}
