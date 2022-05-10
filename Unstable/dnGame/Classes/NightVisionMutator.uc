//=============================================================================
// NightVisionMutator
// gives all players Heat Vision
//=============================================================================
class NightVisionMutator expands Mutator;

function ModifyPlayer( Pawn Other )
{
	local Inventory InventoryItem;

	InventoryItem = Other.FindInventoryType( class'Upgrade_NightVision' );
		
	if ( InventoryItem == None )
	{
		InventoryItem = spawn( class'Upgrade_NightVision' );
		InventoryItem.GiveTo( Other );
	}

	if ( NextMutator != None )
		NextMutator.ModifyPlayer( Other );
}

defaultproperties
{
}