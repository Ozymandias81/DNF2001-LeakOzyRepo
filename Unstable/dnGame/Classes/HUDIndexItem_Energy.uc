/*-----------------------------------------------------------------------------
	HUDIndexItem_Energy
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class HUDIndexItem_Energy extends HUDIndexItem;

function DrawItem(canvas C, DukeHUD HUD, float YPos)
{
	local Pawn PawnOwner;

	PawnOwner = HUD.PawnOwner;

	Value = int(PawnOwner.Energy);
	MaxValue = PawnOwner.default.Energy;

	Super.DrawItem(C, HUD, YPos);
}

defaultproperties
{
	Text="POWER"
	ItemSize=IS_Medium
	StopLightingBar=true
	FlashingBar=true
}