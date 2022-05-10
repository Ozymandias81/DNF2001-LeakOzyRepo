//=============================================================================
// LifeGridAssign. (NJS)
//
// Event is the LifeGrid tag name.
// See the 'Public Variables' section below for a description of each of the 
// options.
//=============================================================================
class LifeGridAssign expands Life;

// Public Variables:
enum LifeGridAssignType
{
	LGA_Set,			// Set the given cell in the life grid.
	LGA_Clear,			// Clear the given cell in the life grid.
	LGA_Toggle,			// Toggle the given cell in the life grid.
	LGA_Randomize,		// Randomize the given cell in the life grid.
	LGA_ToggleClosest	// Toggles the closest cell.
};

var () LifeGridAssignType AssignType;
var () int Row;				// Row to assign
var () int Column;			// Column to assign
var () float maxDistance;	// Used with LGA_ToggleClosest

function Trigger( actor Other, pawn Instigator )
{
	local LifeGrid Grid;
	local LifeCell Cell;
	
	foreach AllActors( class 'LifeGrid', Grid, Event )
	{
		if(AssignType==LGA_ToggleClosest)
		{
			// Try to get the closest cell:
			Cell=Grid.ClosestCell(Instigator.Location,maxDistance);
			if(Cell!=none)		// If I got a cell, toggle it:
			{
				// Toggle the value:
				if(Cell.bHidden) Cell.bHidden=false;
				else Cell.bHidden=true;
			}
			return;
		}
		
		Cell=Grid.CellFromGrid(Row,Column);
		if(bool(Cell))
		{
			switch(AssignType)
			{
				case LGA_Set:		Cell.bHidden=false;	break;
				case LGA_Clear:		Cell.bHidden=true; 	break;
				case LGA_Toggle:	if(Cell.bHidden) Cell.bHidden=false; else Cell.bHidden=true; break;
				case LGA_Randomize:	Cell.bHidden=bool(Rand(2)); break;
			}		
		}	
	}
}

defaultproperties
{
}
