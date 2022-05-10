//=============================================================================
// HeatVisionMutator
// gives all players Heat Vision
//=============================================================================
class HeatVisionMutator expands Mutator;

function ModifyPlayer( Pawn Other )
{
	local Inventory InventoryItem;

	InventoryItem = Other.FindInventoryType( class'Upgrade_HeatVision' );
		
	if ( InventoryItem == None )
	{
		InventoryItem = spawn( class'Upgrade_HeatVision' );
		InventoryItem.GiveTo( Other );
	}

	if ( NextMutator != None )
		NextMutator.ModifyPlayer( Other );
}

defaultproperties
{
}