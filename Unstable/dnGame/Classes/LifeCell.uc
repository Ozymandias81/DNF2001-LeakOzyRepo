//=============================================================================
// LifeCell. (NJS)
//
// A single life Cell, connected to it's neighbors by the SurroundingCells.
// The current state is stored as bHidden, next state is stored as NextState.
// When triggered, it will set it's current state to it's next state.
//=============================================================================
class LifeCell expands Life;

#exec TEXTURE IMPORT NAME=RocketFlare FILE=MODELS\rflare.pcx GROUP=Effects

// Surrounding cell connections organization (U is this cell):
// 0 1 2 
// 3 U 4
// 5 6 7 
var () name     SurroundingCellTags[8];
var    LifeCell SurroundingCells[8];
var    bool     NextState;

function PostBeginPlay()
{
	local int i;
	local LifeCell l;
	
	// Fill in all my neighbor structures (if they aren't already):
	for(i=0;i<ArrayCount(SurroundingCellTags);i++)
	{
		if(SurroundingCellTags[i]!='')
		{
			// Look for items with correct tags:
			foreach AllActors( class 'LifeCell', l, SurroundingCellTags[i] )
			{
				SurroundingCells[i]=l; 
				break;
			}
		}
	}
}

function ComputeNextState()
{
	local int Neighbors, i;
	
	Neighbors=0;

	// Count my surrounding neighbors:	
	for(i=0;i<8;i++)
		if((SurroundingCells[i]!=none)&&(!SurroundingCells[i].bHidden)) 
			Neighbors++;
	
	// Compute my next state:
	if(Neighbors==3) 					NextState=false;	// If I have 3 neighbors, I always turn on or stay on.
	else if((Neighbors==2)&&!bHidden)	NextState=false;	// If I have 2 neighbors, I stay alive.
	else								NextState=true;		// If I have any other number of neighbors, I die.
}

// Set the new state:
function SetNewState()
{
	bHidden=NextState;
}

// Toggles my hidden state.
function Trigger( actor Other, pawn Instigator )
{
	// Toggle my current state:
	if(bHidden) bHidden=false;
	else bHidden=true;
}

defaultproperties
{
     Style=STY_Translucent
     Texture=Texture'dnGame.Effects.RocketFlare'
     bUnlit=True
}
