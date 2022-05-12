//=============================================================================
// TFemale1Bot.
//=============================================================================
class TFemale1Bot extends FemaleBotPlus;

function ForceMeshToExist()
{
	Spawn(class'TFemale1');
}

defaultproperties
{
	Menuname="Female Commando"
	Mesh=Mesh'Botpack.FCommando'
	SelectionMesh="Botpack.SelectionFemale1"
	CarcassType=TFemale1Carcass
	VoiceType="BotPack.VoiceFemaleOne"
	TeamSkin1=0
	TeamSkin2=1
	FixedSkin=0
	FaceSkin=3
	DefaultSkinName="FCommandoSkins.cmdo"
	DefaultPackage="FCommandoSkins."
}
