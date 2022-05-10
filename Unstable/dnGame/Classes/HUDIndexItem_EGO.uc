/*-----------------------------------------------------------------------------
	HUDIndexItem_EGO
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class HUDIndexItem_EGO extends HUDIndexItem;

function DrawItem(canvas C, DukeHUD HUD, float YPos)
{
	local float XL, YL;
	local float HitDelta, HitScale, HitOffset;
	local int i;
	local Pawn PawnOwner;

	PawnOwner = HUD.PawnOwner;

	Value = PawnOwner.Health;
	MaxValue = PawnOwner.default.Health;

	Super.DrawItem( C, HUD, YPos );
}

defaultproperties
{
	Text="EGO"
	ItemSize=IS_Large
	StopLightingBar=true
	FlashingBar=true
	bDrawForSpectator=true
}
