//=============================================================================
// TranslocStart.
//=============================================================================
class TranslocStart extends LiftExit;

/* SpecialHandling is called by the navigation code when the next path has been found.  
It gives that path an opportunity to modify the result based on any special considerations
*/
function Actor SpecialHandling(Pawn Other)
{
	local Bot B;

	if ( (Other.MoveTarget == None) || (!Other.MoveTarget.IsA('TranslocDest') && (Other.MoveTarget != self)) )
		return self;
	B = Bot(Other);

	if ( (B.MyTranslocator == None) || (B.MyTranslocator.TTarget != None) )
		return None;

	B.TranslocateToTarget(self);	
	return self;
}

defaultproperties
{
	bStatic=false
	bNoDelete=true
	bSpecialCost=true
}