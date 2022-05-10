//=============================================================================
// Jetpacks
// gives all players a jetpack
//=============================================================================
class Jetpacks expands Mutator;

function ModifyPlayer( Pawn Other )
{
	local Inventory InventoryItem;

	InventoryItem = Other.FindInventoryType( class'Jetpack' );
	
	if ( InventoryItem == None )
	{
		InventoryItem = spawn( class'Jetpack' );
		InventoryItem.GiveTo( Other );
	}

	if ( NextMutator != None )
		NextMutator.ModifyPlayer( Other );
}

defaultproperties
{
}