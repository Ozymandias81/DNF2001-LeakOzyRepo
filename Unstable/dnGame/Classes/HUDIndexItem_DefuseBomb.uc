/*-----------------------------------------------------------------------------
	HUDIndexItem_DefuseBomb
	Author: Scott Alden
-----------------------------------------------------------------------------*/
class HUDIndexItem_DefuseBomb extends HUDIndexItem;

var PlantedBomb		theBomb;

function DrawItem(canvas C, DukeHUD HUD, float YPos)
{
	local Pawn PawnOwner;

	if ( theBomb != None ) 
	{
		Value			= theBomb.DefuseTime;
		MaxValue		= theBomb.default.DefuseTime;
	}

	Super.DrawItem(C, HUD, YPos);
	LastValue = Value;
}

defaultproperties
{
	Text="DEFUSE"
	StopLightingBar=true
	FlashingBar=true
	FlashThreshold=3
	LastValue=25
}