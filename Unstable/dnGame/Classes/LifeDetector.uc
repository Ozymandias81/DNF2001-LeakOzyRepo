//=============================================================================
// LifeDetector. (NJS)
//
// For now, see the 'Public Variables' section. 
//=============================================================================
class LifeDetector expands Life;

// Public Variables:
var () bool TriggerOnState; // State to trigger on, on or off.
var () bool CheckRange;		// Whether to check a range, or just a single point
var () int  Row;			// Row to detect
var () int  Column;	        // Column to detect
var () name LifeGridTag;	// Tag of the grid we're detecting in
var () int  Left;			// Left of the rectangle range to check.
var () int  Top;			// Top of the rectange range to check.
var () int  Right;			// Right of the rectangle range to check.
var () int  Bottom;			// Bottom of the rectangle range to check.

function Trigger( actor Other, pawn Instigator )
{
	local LifeGrid Grid;
	local LifeCell Cell;
	local int x,y, localTop, localLeft, localRight, localBottom;
	local bool foundOne;

	if(CheckRange)
	{	
		if(Top>Bottom) { localTop=Bottom; localBottom=Top; }
		else 		   { localTop=Top; localBottom=Bottom; }

		if(Left>Right) { localLeft=Right; localRight=Left; }
		else 		   { localLeft=Left; localRight=Right; }

	}
	
	foreach AllActors( class 'LifeGrid', Grid, LifeGridTag )
	{
		if(CheckRange)
		{
			foundOne=false;
			
			for(y=localTop;y<=localBottom;y++)		
				for(x=localLeft;x<=localRight;x++)
				{
					Cell=Grid.CellFromGrid(y,x);
					if(Cell!=none)
					{
						if(!Cell.bHidden&&TriggerOnState) 		 { foundOne=true; break; }
						else if(Cell.bHidden&&!TriggerOnState) { foundOne=true; break; }												
					}
				}
				
			if(foundOne) GlobalTrigger(Event,Instigator);
				
		} else
		{		 
			Cell=Grid.CellFromGrid(Row,Column);
			if(!Cell.bHidden&&TriggerOnState) 		GlobalTrigger(Event,Instigator);
			else if(Cell.bHidden&&!TriggerOnState)	GlobalTrigger(Event,Instigator);
		}
	}
}

defaultproperties
{
}
