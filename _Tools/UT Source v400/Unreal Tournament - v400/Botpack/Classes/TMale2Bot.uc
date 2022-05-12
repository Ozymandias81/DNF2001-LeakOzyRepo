//=============================================================================
// TMale2Bot.
//=============================================================================
class TMale2Bot extends MaleBotPlus;

function ForceMeshToExist()
{
	Spawn(class'TMale2');
}

defaultproperties
{
	Menuname="Male Soldier"
	Mesh=Mesh'Botpack.Soldier'
	SelectionMesh="Botpack.SelectionMale2"
	LandGrunt=MaleSounds.land10
	CarcassType=TMale2Carcass
	VoiceType="BotPack.VoiceMaleTwo"
	TeamSkin1=0
	TeamSkin2=1
	FixedSkin=2
	FaceSkin=3
	DefaultSkinName="SoldierSkins.blkt"
	DefaultPackage="SoldierSkins."
}
