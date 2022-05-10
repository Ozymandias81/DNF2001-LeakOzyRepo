//=============================================================================
// EMPMutator
// gives all players Heat Vision
//=============================================================================
class EMPMutator expands Mutator;

function ModifyPlayer( Pawn Other )
{
	local Inventory InventoryItem;

	InventoryItem = Other.FindInventoryType( class'Upgrade_EMP' );
		
	if ( InventoryItem == None )
	{
		InventoryItem = spawn( class'Upgrade_EMP' );
		InventoryItem.GiveTo( Other );
	}

	if ( NextMutator != None )
		NextMutator.ModifyPlayer( Other );
}

defaultproperties
{
}