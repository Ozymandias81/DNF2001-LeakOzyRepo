/*-----------------------------------------------------------------------------
	HUDIndexItem_Air
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class HUDIndexItem_Air extends HUDIndexItem;

function DrawItem( canvas C, DukeHUD HUD, float YPos )
{
	local Pawn PawnOwner;

	PawnOwner = HUD.PawnOwner;

	if ( (PawnOwner.UsedItem == None) || !PawnOwner.UsedItem.IsA('Rebreather') )
	{
		Text = default.Text;
		Value = int(PawnOwner.RemainingAir);
		MaxValue = 30;
		FlashThreshold = 5;
	} 
	else if ( PawnOwner.UsedItem.IsA('Rebreather') ) 
	{
		Text = PawnOwner.UsedItem.ItemName;
		Value = Rebreather(PawnOwner.UsedItem).BreatheTime;
		MaxValue = Rebreather(PawnOwner.UsedItem).default.BreatheTime;
		FlashThreshold = 25;
	}

	Super.DrawItem( C, HUD, YPos );

	LastValue = Value;
}

defaultproperties
{
	Text="BREATH"
	StopLightingBar=true
	FlashingBar=true
	FlashThreshold=5
	LastValue=30
}