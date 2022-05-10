/*-----------------------------------------------------------------------------
	HUDIndexItem_Jetpack
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class HUDIndexItem_Jetpack extends HUDIndexItem;

function DrawItem(canvas C, DukeHUD HUD, float YPos)
{
	local Pawn PawnOwner;
	local Jetpack JP;

	PawnOwner = HUD.PawnOwner;

	JP = Jetpack(PawnOwner.FindInventoryType( class'Jetpack' ));
	if ( JP != None ) 
	{
		Value = JP.Charge;
		MaxValue = JP.MaxCharge;
		FlashThreshold = 25;
	}

	Super.DrawItem(C, HUD, YPos);

	LastValue = Value;
}

function SetTextFont( canvas C, DukeHUD HUD )
{
	if ( C.ClipX > 640 )
	{
		FontScaleX = 0.6;
		FontScaleY = 0.6;
	}
	else
	{
		FontScaleX = 0.5;
		FontScaleY = 0.5;
	}

	C.DrawColor = GetBarColor();
	if ( C.ClipX > 640 )
	{
		FontScaleX *= HUD.HUDScaleX;
		FontScaleY *= HUD.HUDScaleY;
		C.Font = font'hudfont';
	}
	else
	{
		C.Font = font'hudfontsmall';
	}
}

defaultproperties
{
	Text="JETPACK"
	StopLightingBar=true
	FlashingBar=true
	FlashThreshold=5
	LastValue=100
	FontAdjust(2)=3
}