//=============================================================================
// MaleTwoBot.
//=============================================================================
class MaleTwoBot extends MaleBot;

#exec AUDIO IMPORT FILE="..\UnrealShare\Sounds\male\jump10.WAV" NAME="MJump2" GROUP="Male"
#exec AUDIO IMPORT FILE="..\UnrealShare\Sounds\male\land10.WAV" NAME="MLand2" GROUP="Male"

function ForceMeshToExist()
{
	Spawn(class'MaleTwo');
}


defaultproperties
{
     Skin=Texture'Unreali.Ash'
     Mesh=Male2
	 JumpSound=MJump2
	 LandGrunt=MLand2
	 CarcassType=MaleTwoCarcass
}
