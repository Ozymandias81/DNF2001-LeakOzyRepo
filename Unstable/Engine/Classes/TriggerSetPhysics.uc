//=============================================================================
// TriggerSetPhysics. (NJS)
// When triggered will set the physics of the thing that triggered it.
//=============================================================================
class TriggerSetPhysics expands Triggers;

var () bool     SetOnTouch;
var () EPhysics SetPhysicsTo;

function Trigger( actor Other, pawn EventInstigator )
{
	Other.SetPhysics(SetPhysicsTo);
}

function Touch( actor Other )
{
	//if(dnDecoration(Other)!=none)
	//	dnDecoration(Other).touch(self);
	
	if(SetOnTouch)
		Other.SetPhysics(SetPhysicsTo);
}

defaultproperties
{
}
