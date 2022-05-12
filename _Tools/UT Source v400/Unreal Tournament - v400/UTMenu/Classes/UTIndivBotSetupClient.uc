class UTIndivBotSetupClient extends UMenuBotSetupBase;

var ChallengeBotInfo BotInfo;

// VoicePack
var UWindowHSliderControl SkillSlider;
var localized string SkillText;
var localized string SkillHelp;

var UWindowComboControl VoicePackCombo;
var localized string VoicePackText;
var localized string VoicePackHelp;

var UWindowComboControl FavoriteWeaponCombo;
var localized string FavoriteWeaponText;
var localized string FavoriteWeaponHelp;
var localized string NoFavoriteWeapon;

var UWindowHSliderControl AccuracySlider;
var localized string AccuracyText;
var localized string AccuracyHelp;

var UWindowHSliderControl AlertnessSlider;
var localized string AlertnessText;
var localized string AlertnessHelp;

var UWindowHSliderControl CampingSlider;
var localized string CampingText;
var localized string CampingHelp;

var UWindowHSliderControl StrafingAbilitySlider;
var localized string StrafingAbilityText;
var localized string StrafingAbilityHelp;

var UWindowComboControl CombatStyleCombo;
var localized string CombatStyleText;
var localized string CombatStyleHelp;
var localized float CombatStyleValues[10];
var localized string CombatStyleNames[10];

var UWindowCheckbox JumpyCheck;
var localized string JumpyText;
var localized string JumpyHelp;

var bool ClassChanging;

function Created()
{
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos;
	local int i;

	ControlWidth = WinWidth/3;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	Super.Created();

	ControlOffset += 25;
	SkillSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', CenterPos, ControlOffset, CenterWidth, 1));
	SkillSlider.bNoSlidingNotify = True;
	SkillSlider.SetRange(0, 6, 1);
	SkillSlider.SetText(SkillText);
	SkillSlider.SetHelpText(SkillHelp);
	SkillSlider.SetFont(F_Normal);

	ControlOffset += 25;
	VoicePackCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, ControlOffset, CenterWidth, 1));
	VoicePackCombo.SetText(VoicePackText);
	VoicePackCombo.SetHelpText(VoicePackHelp);
	VoicePackCombo.SetFont(F_Normal);
	VoicePackCombo.SetEditable(False);

	ControlOffset += 25;
	FavoriteWeaponCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, ControlOffset, CenterWidth, 1));
	FavoriteWeaponCombo.SetText(FavoriteWeaponText);
	FavoriteWeaponCombo.SetHelpText(FavoriteWeaponHelp);
	FavoriteWeaponCombo.SetFont(F_Normal);
	FavoriteWeaponCombo.SetEditable(False);
	LoadWeapons();

	ControlOffset += 25;
	AccuracySlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', CenterPos, ControlOffset, CenterWidth, 1));
	AccuracySlider.bNoSlidingNotify = True;
	AccuracySlider.SetRange(0, 200, 5);
	AccuracySlider.SetText(AccuracyText);
	AccuracySlider.SetHelpText(AccuracyHelp);
	AccuracySlider.SetFont(F_Normal);

	ControlOffset += 25;
	AlertnessSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', CenterPos, ControlOffset, CenterWidth, 1));
	AlertnessSlider.bNoSlidingNotify = True;
	AlertnessSlider.SetRange(0, 200, 5);
	AlertnessSlider.SetText(AlertnessText);
	AlertnessSlider.SetHelpText(AlertnessHelp);
	AlertnessSlider.SetFont(F_Normal);

	ControlOffset += 25;
	CampingSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', CenterPos, ControlOffset, CenterWidth, 1));
	CampingSlider.bNoSlidingNotify = True;
	CampingSlider.SetRange(0, 100, 10);
	CampingSlider.SetText(CampingText);
	CampingSlider.SetHelpText(CampingHelp);
	CampingSlider.SetFont(F_Normal);

	ControlOffset += 25;
	StrafingAbilitySlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', CenterPos, ControlOffset, CenterWidth, 1));
	StrafingAbilitySlider.bNoSlidingNotify = True;
	StrafingAbilitySlider.SetRange(0, 8, 1);
	StrafingAbilitySlider.SetText(StrafingAbilityText);
	StrafingAbilitySlider.SetHelpText(StrafingAbilityHelp);
	StrafingAbilitySlider.SetFont(F_Normal);

	ControlOffset += 25;
	CombatStyleCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, ControlOffset, CenterWidth, 1));
	CombatStyleCombo.SetText(CombatStyleText);
	CombatStyleCombo.SetHelpText(CombatStyleHelp);
	CombatStyleCombo.SetFont(F_Normal);
	CombatStyleCombo.SetEditable(False);
	for(i=0;i<10 && CombatStyleNames[i] != "";i++)
		CombatStyleCombo.AddItem(CombatStyleNames[i], string(CombatStyleValues[i]));

	ControlOffset += 25;
	JumpyCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', CenterPos, ControlOffset, CenterWidth, 1));
	JumpyCheck.SetText(JumpyText);
	JumpyCheck.SetHelpText(JumpyHelp);
	JumpyCheck.SetFont(F_Normal);
	JumpyCheck.Align = TA_Left;
}

function LoadBots()
{
	local class<ChallengeBotInfo> C;
	local int i;
	local int NumBots;

	C = class<ChallengeBotInfo>(DynamicLoadObject("Botpack.ChallengeBotInfo", class'Class'));
	BotInfo = GetEntryLevel().Spawn(C);

	if(UMenuBotConfigBase(OwnerWindow).RandomCheck.bChecked)
		NumBots = 32;
	else
		NumBots = Int(UMenuBotConfigBase(OwnerWindow).NumBotsEdit.GetValue());


	// Add the bots into the combo
	for(i=0;i<NumBots;i++)
		BotCombo.AddItem(BotWord@string(i+1), String(i));	
}

function ResetBots()
{
	local class<ChallengeBotInfo> C;
	C = BotInfo.Class;
	BotInfo.Destroy();
	class'ChallengeBotInfo'.static.ResetConfig();
	BotInfo = GetEntryLevel().Spawn(C);

	Initialized = False;
	ConfigureBot = 0;
	BotCombo.SetSelectedIndex(0);
	LoadCurrent();
	UseSelected();
	Initialized = True;
}

function LoadWeapons()
{
	local int NumWeaponClasses;
	local string NextWeapon, NextDesc;
	local string WeaponBaseClass;

	WeaponBaseClass = "TournamentWeapon";

	FavoriteWeaponCombo.AddItem(NoFavoriteWeapon, "None");

	GetPlayerOwner().GetNextIntDesc(WeaponBaseClass, 0, NextWeapon, NextDesc);
	while( (NextWeapon != "") && (NumWeaponClasses < 64) )
	{
		FavoriteWeaponCombo.AddItem(NextDesc, NextWeapon);
		NumWeaponClasses++;
		GetPlayerOwner().GetNextIntDesc(WeaponBaseClass, NumWeaponClasses, NextWeapon, NextDesc);
	}
	FavoriteWeaponCombo.Sort();
}

function LoadClasses()
{
	local int i;
	local int SortWeight;

	for(i=0;i<BotInfo.NumClasses;i++)
	{
		if(!(BotInfo.AvailableClasses[i] ~= "Botpack.TBossBot") || class'Ladder'.Default.HasBeatenGame)
			ClassCombo.AddItem(BotInfo.AvailableDescriptions[i], BotInfo.AvailableClasses[i], SortWeight);
	}
}

function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);

	switch(E)
	{
	case DE_Change:
		switch(C)
		{
		case SkillSlider:
			SkillChanged();
			break;
		case FavoriteWeaponCombo:
			FavouriteWeaponChanged();
			break;
		case CampingSlider:
			CampingChanged();
			break;
		case StrafingAbilitySlider:
			StrafingAbilityChanged();
			break;
		case AlertnessSlider:
			AlertnessChanged();
			break;
		case AccuracySlider:
			AccuracyChanged();
			break;
		case CombatStyleCombo:
			CombatStyleChanged();
			break;
		case JumpyCheck:
			JumpyChanged();
			break;
		case VoicePackCombo:
			VoiceChanged();
			break;
		}
	}
}

function Close(optional bool bByParent)
{
	Super.Close(bByParent);
	BotInfo.SaveConfig();
	BotInfo.Destroy();
	BotInfo = None;
}

function ClassChanged()
{
	Super.ClassChanged();

	if(Initialized)
	{
		ClassChanging = True;
		IterateVoices();
		VoicePackCombo.SetSelectedIndex(Max(VoicePackCombo.FindItemIndex2(class<Bot>(NewPlayerClass).default.VoiceType, True), 0));
		ClassChanging = False;
	}
}

function IterateVoices()
{
	local int NumVoices;
	local string NextVoice, NextDesc;
	local string VoicepackMetaClass;
	local bool OldInitialized;

	OldInitialized = Initialized;
	Initialized = False;
	VoicePackCombo.Clear();
	Initialized = OldInitialized;

	if(ClassIsChildOf(NewPlayerClass, class'Bot'))
		VoicePackMetaClass = class<Bot>(NewPlayerClass).default.VoicePackMetaClass;
	else
		VoicePackMetaClass = "Botpack.ChallengeVoicePack";

	// Load the base class into memory to prevent GetNextIntDesc crashing as the class isn't loadded.
	DynamicLoadObject(VoicePackMetaClass, class'Class');

	GetPlayerOwner().GetNextIntDesc(VoicePackMetaClass, 0, NextVoice, NextDesc);
	while( (NextVoice != "") && (NumVoices < 64) )
	{
		if(!(NextVoice ~= "Botpack.VoiceBoss") || class'Ladder'.Default.HasBeatenGame)
		{
			if(NextVoice ~=  "Botpack.VoiceBoss")
				VoicePackCombo.AddItem(NextDesc, "Botpack.VoiceBotBoss", 0);
			else
				VoicePackCombo.AddItem(NextDesc, NextVoice, 0);
		}

		NumVoices++;
		GetPlayerOwner().GetNextIntDesc(VoicePackMetaClass, NumVoices, NextVoice, NextDesc);
	}

	VoicePackCombo.Sort();
}

function LoadCurrent()
{
	local int i;
	local string Voice;

	NameEdit.SetValue(BotInfo.GetBotName(ConfigureBot));
	i = TeamCombo.FindItemIndex2(string(BotInfo.BotTeams[ConfigureBot]));
	if(i == -1)
		i = 255;
	TeamCombo.SetSelectedIndex(i);
	ClassCombo.SetSelectedIndex(Max(ClassCombo.FindItemIndex2(BotInfo.GetBotClassName(ConfigureBot), True), 0));
	SkinCombo.SetSelectedIndex(Max(SkinCombo.FindItemIndex2(BotInfo.GetBotSkin(ConfigureBot), True), 0));
	FaceCombo.SetSelectedIndex(Max(FaceCombo.FindItemIndex2(BotInfo.BotFaces[ConfigureBot], True), 0));
	FavoriteWeaponCombo.SetSelectedIndex(Max(FavoriteWeaponCombo.FindItemIndex2(BotInfo.FavoriteWeapon[ConfigureBot], True), 0));
	AccuracySlider.SetValue(100*(BotInfo.BotAccuracy[ConfigureBot]+1));
	AlertnessSlider.SetValue(100*(BotInfo.Alertness[ConfigureBot]+1));
	CampingSlider.SetValue(100*(BotInfo.Camping[ConfigureBot]));
	StrafingAbilitySlider.SetValue(4*(BotInfo.StrafingAbility[ConfigureBot]+1));
	CombatStyleCombo.SetSelectedIndex(Max(CombatStyleCombo.FindItemIndex2(string(BotInfo.CombatStyle[ConfigureBot]), False), 0));
	JumpyCheck.bChecked = BotInfo.BotJumpy[ConfigureBot] != 0;
	SkillSlider.SetValue(BotInfo.BotSkills[ConfigureBot] + 3);

	ClassChanging = True;
	IterateVoices();
	i= VoicePackCombo.FindItemIndex2(BotInfo.VoiceType[ConfigureBot], True);
	if(i != -1)
		VoicePackCombo.SetSelectedIndex(i);
	else
		VoicePackCombo.SetSelectedIndex(Max(VoicePackCombo.FindItemIndex2(class<Bot>(NewPlayerClass).default.VoiceType, True), 0));
	ClassChanging = False;
}

function JumpyChanged()
{
	if (Initialized)
	{
		if(JumpyCheck.bChecked)
			BotInfo.BotJumpy[ConfigureBot] = 1;
		else
			BotInfo.BotJumpy[ConfigureBot] = 0;
	}
}

simulated function VoiceChanged()
{
	local class<ChallengeVoicePack> VoicePackClass;

	if(Initialized)
	{
		if(!ClassChanging)
		{
			VoicePackClass = class<ChallengeVoicePack>(DynamicLoadObject(VoicePackCombo.GetValue2(), class'Class'));
			GetPlayerOwner().PlaySound(VoicePackClass.Default.AckSound[Rand(VoicePackClass.Default.NumAcks)]);
		}
		BotInfo.VoiceType[ConfigureBot] = VoicePackCombo.GetValue2();
	}
}

function NameChanged()
{
	if (Initialized)
		BotInfo.SetBotName(NameEdit.GetValue(), ConfigureBot);
}

function FavouriteWeaponChanged()
{
	local string NewWeapon;

	if (Initialized)
	{
		NewWeapon = FavoriteWeaponCombo.GetValue2();
		if(NewWeapon == "None")
			BotInfo.FavoriteWeapon[ConfigureBot] = "";
		else
			BotInfo.FavoriteWeapon[ConfigureBot] = NewWeapon;
	}
}

function CampingChanged()
{
	if (Initialized)
		BotInfo.Camping[ConfigureBot] = (CampingSlider.GetValue() / 100);
}

function StrafingAbilityChanged()
{
	if (Initialized)
		BotInfo.StrafingAbility[ConfigureBot] = (StrafingAbilitySlider.GetValue() / 4) - 1;
}

function AlertnessChanged()
{
	if (Initialized)
		BotInfo.Alertness[ConfigureBot] = (AlertnessSlider.GetValue() / 100) - 1;
}

function AccuracyChanged()
{
	if (Initialized)
		BotInfo.BotAccuracy[ConfigureBot] = (AccuracySlider.GetValue() / 100) - 1;
}

function CombatStyleChanged()
{
	if (Initialized)
		BotInfo.CombatStyle[ConfigureBot] = float(CombatStyleCombo.GetValue2());
}

function SkillChanged()
{
	if (Initialized)
		BotInfo.BotSkills[ConfigureBot] = SkillSlider.GetValue() - 3;
}

function UseSelected()
{
	if (Initialized)
	{
		// store the stuff in the required botinfo
		BotInfo.SetBotClass(ClassCombo.GetValue2(), ConfigureBot);
		BotInfo.SetBotSkin(SkinCombo.GetValue2(), ConfigureBot);
		BotInfo.SetBotFace(FaceCombo.GetValue2(), ConfigureBot);
		BotInfo.SetBotTeam(Int(TeamCombo.GetValue2()), ConfigureBot);
	}

	// setup the mesh window appropriately
	MeshWindow.SetMeshString(NewPlayerClass.Default.SelectionMesh);
	MeshWindow.ClearSkins();
	NewPlayerClass.static.SetMultiSkin(MeshWindow.MeshActor, SkinCombo.GetValue2(), FaceCombo.GetValue2(), Int(TeamCombo.GetValue2()));
}

function SaveConfigs()
{
	Super.SaveConfigs();
	if(BotInfo != None)
		BotInfo.SaveConfig();
}

function BeforePaint(Canvas C, float X, float Y)
{
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos;
	local float W;

	W = Min(WinWidth, 220);

	ControlWidth = W/3;
	ControlLeft = (W/2 - ControlWidth)/2;
	ControlRight = W/2 + ControlLeft;

	CenterWidth = (W/7)*6;
	CenterPos = (W - CenterWidth)/2;
	Super.BeforePaint(C, X, Y);

	FavoriteWeaponCombo.SetSize(CenterWidth, 1);
	FavoriteWeaponCombo.WinLeft = CenterPos;
	FavoriteWeaponCombo.EditBoxWidth = 105;

	AccuracySlider.SetSize(CenterWidth, 1);
	AccuracySlider.WinLeft = CenterPos;
	AccuracySlider.SliderWidth = 105;

	SkillSlider.SetSize(CenterWidth, 1);
	SkillSlider.WinLeft = CenterPos;
	SkillSlider.SliderWidth = 105;

	AlertnessSlider.SetSize(CenterWidth, 1);
	AlertnessSlider.WinLeft = CenterPos;
	AlertnessSlider.SliderWidth = 105;

	CampingSlider.SetSize(CenterWidth, 1);
	CampingSlider.WinLeft = CenterPos;
	CampingSlider.SliderWidth = 105;

	StrafingAbilitySlider.SetSize(CenterWidth, 1);
	StrafingAbilitySlider.WinLeft = CenterPos;
	StrafingAbilitySlider.SliderWidth = 105;

	CombatStyleCombo.SetSize(CenterWidth, 1);
	CombatStyleCombo.WinLeft = CenterPos;
	CombatStyleCombo.EditBoxWidth = 105;

	JumpyCheck.SetSize(CenterWidth-105+16, 1);
	JumpyCheck.WinLeft = CenterPos;

	VoicePackCombo.SetSize(CenterWidth, 1);
	VoicePackCombo.WinLeft = CenterPos;
	VoicePackCombo.EditBoxWidth = 105;
}

defaultproperties
{
	FavoriteWeaponText="Favorite Weapon:"
	FavoriteWeaponHelp="Select this bot's favorite weapon."
	NoFavoriteWeapon="(no favorite)"
	SkillText="Skill Adjust"
	SkillHelp="Adjust this bot's skill up or down, from the base skill level."; 
	AccuracyText="Accuracy:"
	AccuracyHelp="Change this bot's weapon accuracy.  The cental position is normal, far left is low accuracy, far right is high accuracy."
	AlertnessText="Alertness:"
	AlertnessHelp="Change this bot's alertness.  The central position is normal."
	CampingText="Camping:"
	CampingHelp="Change this bot's willingness to camp."
	CombatStyleText="Combat Style:"
	CombatStyleHelp="Select this bot's combat style."
	CombatStyleValues(0)=0
	CombatStyleNames(0)="Normal"
	CombatStyleValues(1)=0.5
	CombatStyleNames(1)="Aggressive"
	CombatStyleValues(2)=1
	CombatStyleNames(2)="Berserk"
	CombatStyleValues(3)=-0.5
	CombatStyleNames(3)="Cautious"
	CombatStyleValues(4)=-1
	CombatStyleNames(4)="Avoidant"
	JumpyText="Jumpy Behavior:"
	JumpyHelp="This bot is inclined to jump excessively around the level, like some players do."
	VoicePackText="Voice"
	VoicePackHelp="Choose a voice for your player's taunts and commands."
	StrafingAbilityText="Strafing:"
	StrafingAbilityHelp="Change the amount this bot likes to strafe."
}
