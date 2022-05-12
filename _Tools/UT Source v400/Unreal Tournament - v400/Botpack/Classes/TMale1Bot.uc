//=============================================================================
// TMale1Bot.
//=============================================================================
class TMale1Bot extends MaleBotPlus;

function ForceMeshToExist()
{
	Spawn(class'TMale1');
}

defaultproperties
{
	Menuname="Male Commando"
	Mesh=Mesh'Botpack.Commando'
	SelectionMesh="Botpack.SelectionMale1"
	JumpSound=TMJump3
	LandGrunt=MLand3
	CarcassType=TMale1Carcass
	VoiceType="BotPack.VoiceMaleOne"
	TeamSkin1=2
	TeamSkin2=3
	FixedSkin=0
	FaceSkin=1
	DefaultSkinName="CommandoSkins.cmdo"
	DefaultPackage="CommandoSkins."
}
