/*-----------------------------------------------------------------------------
	HUDIndexItem_RiotShield
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class HUDIndexItem_RiotShield extends HUDIndexItem;

function DrawItem( canvas C, DukeHUD HUD, float YPos )
{
	Value = RiotShield(HUD.PawnOwner.ShieldItem).Charge;
	MaxValue = RiotShield(HUD.PawnOwner.ShieldItem).default.Charge;

	Super.DrawItem( C, HUD, YPos );
}

defaultproperties
{
	Text="SHIELD"
}