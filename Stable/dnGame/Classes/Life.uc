//=============================================================================
// Life. (NJS)
// 
// Simple driver and base class for playing Conway's life.
// Triggering an instance of this root life object will cause all life cells in
// the map to perform their next generation.
//=============================================================================
class Life expands RenderActor;

#exec Texture Import File=Textures\Life.pcx Name=S_Life Mips=Off Flags=2

// Causes ALL life cells to process a generation.
function Trigger( actor Other, pawn Instigator )
{
	local LifeCell l;
	
	foreach AllActors( class 'LifeCell', l )
	{
		l.ComputeNextState();
	}
	
	foreach AllActors( class 'LifeCell', l )
	{
		l.SetNewState();
	}
}

defaultproperties
{
     Texture=Texture'dnGame.S_Life'
}
