//=============================================================================
// ZoomModeMutator
// gives all players Heat Vision
//=============================================================================
class ZoomModeMutator expands Mutator;

function ModifyPlayer( Pawn Other )
{
	local Inventory InventoryItem;

	InventoryItem = Other.FindInventoryType( class'Upgrade_ZoomMode' );
	
	if ( InventoryItem == None )
	{
		InventoryItem = spawn( class'Upgrade_ZoomMode' );
		InventoryItem.GiveTo( Other );
	}

	if ( NextMutator != None )
		NextMutator.ModifyPlayer( Other );
}

defaultproperties
{
}