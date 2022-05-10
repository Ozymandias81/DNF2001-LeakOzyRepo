/*-----------------------------------------------------------------------------
	HUDIndexItem_Bomb
	Author: Scott Alden
-----------------------------------------------------------------------------*/
class HUDIndexItem_Bomb extends HUDIndexItem;

function DrawItem(canvas C, DukeHUD HUD, float YPos)
{
	local Pawn PawnOwner;
	local Bomb B;

	PawnOwner = HUD.PawnOwner;

	B = Bomb(PawnOwner.FindInventoryType( class'Bomb' ));
	if ( B != None ) 
	{
		Text			= B.ItemName;
		Value			= B.Charge;
		MaxValue		= B.MaxCharge;
		FlashThreshold	= 25;
	}

	Super.DrawItem(C, HUD, YPos);
	LastValue = Value;
}

defaultproperties
{
	Text="BOMB"
	StopLightingBar=true
	FlashingBar=true
	FlashThreshold=5
	LastValue=100
}