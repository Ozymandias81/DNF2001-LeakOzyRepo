//=============================================================================
// LifeGrid. (NJS)
// 
// LifeGrid automatically creates and connects a grid of LifeCells.  See the
// 'Public Variables' section below for a descripton of each of the various 
// options.
//=============================================================================
class LifeGrid expands Life;

// Public Variables:
var () int  rows;			// Number of rows in the grid.
var () int  columns;		// Number of columns in the grid
var () int  width;			// Width of each grid element.
var () int  height;			// Height of each grid element.
var () bool RandomStates;	// Should initial grid states be random or clear.
var () bool Wrap;			// Should the grid wrap at the edges.

var LifeCell Cells[256];

enum LifeAxis
{
	LG_XY,
	LG_XZ,			
	LG_YZ
};

var () LifeAxis Axis;		// Axis to build the grid on.

var int i;	// Index used for latent destroy()


function LifeCell CellFromGrid(int row, int column)
{
	if(row<0)     		return none;
	if(row>=rows) 		return none;	
	if(column<0)  		return none;
	if(column>=columns) return none;
	
	return Cells[(row*columns)+column];
}

function LifeCell CellFromWrappedGrid( int row, int column )
{
	while(row<0) 		   row+=rows; ;
	while(row>=rows) 	   row-=rows; ;
	while(column<0)        column+=columns; ;
	while(column>=columns) column-=columns; ;
	
	return Cells[(row*columns)+column];
}

function LifeCell CellFromUserGrid( int row, int column )
{
	if(Wrap) return CellFromWrappedGrid(row, column);
	return CellFromGrid(row, column );
}

function LifeCell ClosestCell(vector point, float maxDistance)
{
	local LifeCell closest;
	local int row, column, cellsIndex;
	local float closestDistance, distance;	
	closest=none; closestDistance=maxDistance;
	
	cellsIndex=0;
	for(row=0;row<rows;row++)
	{
		for(column=0;column<columns;column++)
		{
			distance=VSize(Cells[cellsIndex].Location-point);	
			
			// Is this the closest one I've found so far?
			if(distance<=closestDistance)
			{
				closestDistance=distance;
				closest=Cells[cellsIndex];
			}
			
			cellsIndex++;
		}
	}
	
	return closest;
}

function PostBeginPlay()
{
	local int row, column, cellsIndex;
	local vector position;
	local LifeCell current;
	
	cellsIndex=0;      // Initialize cells index
	position=location; // I define the upper left
		
	// Construct the grid:
	for(row=0;row<rows;row++)
	{
		// Reset my column coordinate:
		switch(Axis)
		{
			case LG_XY: position.x=location.x; break;
			case LG_XZ: position.x=location.x; break;			
			case LG_YZ: position.y=location.y; break;
		}
		
		//position.x=location.x;	// Reset my X coordinate
		for(column=0;column<columns;column++)
		{
			Cells[cellsIndex]=Spawn(class'LifeCell',self,'LifeCell',position);
			
			// Should I randomize my initial state?
			if(RandomStates) Cells[cellsIndex].bHidden=bool(Rand(2));
			else Cells[cellsIndex].bHidden=true;
			
			// Accumulate on my column:
			switch(Axis)
			{
				case LG_XY: position.x+=width; break;
				case LG_XZ: position.x+=width; break;			
				case LG_YZ: position.y+=width; break;
			}
			
			//position.x+=width; // Accumulate width
			cellsIndex++;
			if(cellsIndex>=ArrayCount(Cells))
			{
				Log("LifeGrid: Cell count maximum " $ArrayCount(Cells)$" exceeded!");
				return;
			}				
		}
		
		// Accumulate on my row:
		switch(Axis)
		{
			case LG_XY: position.y+=height; break;
			case LG_XZ: position.z+=height; break;			
			case LG_YZ: position.z+=height; break;
		}

		//position.y+=height;		// Accumulate height 
	}
	
	// All the cells are spawned, now hook them up:
	cellsIndex=0;
	for(row=0;row<rows;row++)
	{
		for(column=0;column<columns;column++)
		{
			// Connect top row:
			Cells[cellsIndex].SurroundingCells[0]=CellFromUserGrid(row-1,column-1);
			Cells[cellsIndex].SurroundingCells[1]=CellFromUserGrid(row-1,column);
			Cells[cellsIndex].SurroundingCells[2]=CellFromUserGrid(row-1,column+1);

			// Connect middle row: (except center):
			Cells[cellsIndex].SurroundingCells[3]=CellFromUserGrid(row,column-1);
			Cells[cellsIndex].SurroundingCells[4]=CellFromUserGrid(row,column+1);

			// Connect bottom row:
			Cells[cellsIndex].SurroundingCells[5]=CellFromUserGrid(row+1,column-1);
			Cells[cellsIndex].SurroundingCells[6]=CellFromUserGrid(row+1,column);
			Cells[cellsIndex].SurroundingCells[7]=CellFromUserGrid(row+1,column+1);
			
			cellsIndex++;
		}
	}
}

// Destroy each of my children.
function Destroyed()
{	
	for(i=0;i<ArrayCount(Cells);i++)
		if(Cells[i]!=none)
			Cells[i].Destroy();
}

// When triggered, either clear or randomize the grid (depending on the random states setting):
function Trigger( actor Other, pawn Instigator )
{
	local int row, column, cellsIndex;

	cellsIndex=0;
	for(row=0;row<rows;row++)
	{
		for(column=0;column<columns;column++)
		{
			if(RandomStates) Cells[cellsIndex].bHidden=bool(Rand(2));	// Randomize
			else Cells[cellsIndex].bHidden=true;						// Or just clear.
			
			cellsIndex++;
		}
	}
}

defaultproperties
{
}
