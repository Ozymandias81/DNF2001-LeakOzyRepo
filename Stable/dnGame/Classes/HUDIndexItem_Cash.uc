/*-----------------------------------------------------------------------------
	HUDIndexItem_Cash
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class HUDIndexItem_Cash extends HUDIndexItem;

var float LastValue;

function DrawItem( canvas C, DukeHUD HUD, float YPos )
{
	local Pawn PawnOwner;

	PawnOwner = HUD.PawnOwner;

	Value = PawnOwner.Cash;
	MaxValue = Value;

	Super.DrawItem( C, HUD, YPos );
	LastValue = Value;
}

defaultproperties
{
	Text="CASH"
	StopLightingBar=false
	FlashingBar=false
	LastValue=100
}