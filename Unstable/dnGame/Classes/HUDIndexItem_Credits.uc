/*-----------------------------------------------------------------------------
	HUDIndexItem_Credits
	Author: Scott Alden
-----------------------------------------------------------------------------*/
class HUDIndexItem_Credits extends HUDIndexItem;

var float LastValue;

function DrawItem( canvas C, DukeHUD HUD, float YPos )
{
	local Pawn PawnOwner;

	PawnOwner = HUD.PawnOwner;

	Value = PawnOwner.PlayerReplicationInfo.Credits;
	MaxValue = Value;

	Super.DrawItem( C, HUD, YPos );
	LastValue = Value;
}

defaultproperties
{
	Text="CREDITS"
	StopLightingBar=false
	FlashingBar=false
	LastValue=100
}