//=============================================================================
// TriggerEtherial. (NJS)
//=============================================================================
class TriggerEtherial expands Triggers;

var () bool ClearEtherial;

function SetEtherial(actor Other, bool SetEtherial)
{
	if(other==none) return;
	
	other.bblockactors=false;
	//other.SetCollision( !SetEtherial, !SetEtherial, !SetEtherial);
	other.bCollideWorld=!SetEtherial;
	other.bHidden=SetEtherial;
	
	if(SetEtherial)
	{
		other.velocity=vect(0,0,0);
		other.acceleration=vect(0,0,0);
		other.SetPhysics(PHYS_None);
	}
}

function Trigger( actor Other, pawn EventInstigator )
{
	SetEtherial(other,!ClearEtherial);
}

function Touch( actor Other )
{
	SetEtherial(other,!ClearEtherial);
}

defaultproperties
{
}
