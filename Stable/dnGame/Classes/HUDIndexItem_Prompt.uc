/*-----------------------------------------------------------------------------
	HUDIndexItem_Prompt
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class HUDIndexItem_Prompt extends HUDIndexItem;

function DrawItem( canvas C, DukeHUD HUD, float YPos )
{
	local float XL, YL;
	local float Length, MaxLength, Scale;
	local color MidColor, LightColor, DarkColor;

	GetSize( C, HUD, XL, YL );
	C.DrawColor = HUD.TextColor;
	C.SetPos( HUD.TextRightAdjust-XL, YPos );
	C.DrawText( Text,,,, FontScaleX, FontScaleY );

	C.SetPos( HUD.BarPos, YPos );
	C.DrawText( HUD.GetTypingPrompt(),,false,, FontScaleX, FontScaleY );

	C.DrawColor = HUD.WhiteColor;
}

defaultproperties
{
	Text="C:\\"
}