//=============================================================================
// FemaleTwoBot.
//=============================================================================
class FemaleTwoBot extends FemaleBot;

function ForceMeshToExist()
{
	Spawn(class'FemaleTwo');
}


defaultproperties
{
    Mesh=Female2
    Skin=Texture'Unreali.Sonya'
	CarcassType=FemaleTwoCarcass
}