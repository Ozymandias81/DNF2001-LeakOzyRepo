class UTPlayerSetupClient extends UMenuPlayerSetupClient;

// VoicePack
var UWindowComboControl VoicePackCombo;
var localized string VoicePackText;
var localized string VoicePackHelp;

var UWindowCheckbox SpectatorCheck;
var localized string SpectatorText;
var localized string SpectatorHelp;

/*var UWindowCheckbox CommanderCheck;
var localized string CommanderText;
var localized string CommanderHelp;*/

var UMenuLabelControl StatsLabel;
var localized string StatsText;
var UWindowSmallButton StatsButton;
var localized string StatsButtonText;

var bool ClassChanging;

function Created()
{
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos;
	local int I, Num;

	Super.Created();
	
	DesiredWidth = 220;
	DesiredHeight = 80;

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	ControlOffset += 25;
	VoicePackCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, ControlOffset, CenterWidth, 1));
	VoicePackCombo.SetText(VoicePackText);
	VoicePackCombo.SetHelpText(VoicePackHelp);
	VoicePackCombo.SetFont(F_Normal);
	VoicePackCombo.SetEditable(False);

	ControlOffset += 25;
	SpectatorCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', CenterPos, ControlOffset, CenterWidth, 1));
	SpectatorCheck.SetText(SpectatorText);
	SpectatorCheck.SetHelpText(SpectatorHelp);
	SpectatorCheck.SetFont(F_Normal);
	SpectatorCheck.Align = TA_Left;

/*	ControlOffset += 25;
	CommanderCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', CenterPos, ControlOffset, CenterWidth, 1));
	CommanderCheck.SetText(CommanderText);
	CommanderCheck.SetHelpText(CommanderHelp);
	CommanderCheck.SetFont(F_Normal);
	CommanderCheck.Align = TA_Left;*/

	ControlOffset += 25;
	StatsLabel = UMenuLabelControl(CreateControl(class'UMenuLabelControl', CenterPos, ControlOffset, CenterWidth, 1));
	StatsLabel.SetText(StatsText);
	StatsLabel.SetFont(F_Normal);
	StatsLabel.Align = TA_Left;

	StatsButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', CenterPos + CenterWidth - 48, ControlOffset, 48, 16));
	StatsButton.SetText(StatsButtonText);
	StatsButton.SetFont(F_Normal);
}

function LoadCurrent()
{
	local string Voice, OverrideClassName;
	local class<PlayerPawn> OverrideClass;
	local string SN, FN;

	Voice = "";
	NameEdit.SetValue(GetPlayerOwner().PlayerReplicationInfo.PlayerName);
	TeamCombo.SetSelectedIndex(Max(TeamCombo.FindItemIndex2(string(GetPlayerOwner().PlayerReplicationInfo.Team)), 0));
	if(GetLevel().Game != None && GetLevel().Game.IsA('UTIntro') || GetPlayerOwner().IsA('Commander') || GetPlayerOwner().IsA('Spectator'))
	{
		SN = GetPlayerOwner().GetDefaultURL("Skin");
		FN = GetPlayerOwner().GetDefaultURL("Face");
		ClassCombo.SetSelectedIndex(Max(ClassCombo.FindItemIndex2(GetPlayerOwner().GetDefaultURL("Class"), True), 0));
		Voice = GetPlayerOwner().GetDefaultURL("Voice");
	}
	else
	{
		ClassCombo.SetSelectedIndex(Max(ClassCombo.FindItemIndex2(string(GetPlayerOwner().Class), True), 0));
		GetPlayerOwner().static.GetMultiSkin(GetPlayerOwner(), SN, FN);
	}
	SkinCombo.SetSelectedIndex(Max(SkinCombo.FindItemIndex2(SN, True), 0));
	FaceCombo.SetSelectedIndex(Max(FaceCombo.FindItemIndex2(FN, True), 0));

	if(Voice == "")
		Voice = string(GetPlayerOwner().PlayerReplicationInfo.VoiceType);

	IterateVoices();
	VoicePackCombo.SetSelectedIndex(Max(VoicePackCombo.FindItemIndex2(Voice, True), 0));

	OverrideClassName = GetPlayerOwner().GetDefaultURL("OverrideClass");
	if(OverrideClassName != "")
		OverrideClass = class<PlayerPawn>(DynamicLoadObject(OverrideClassName, class'Class'));

	SpectatorCheck.bChecked = (OverrideClass != None && ClassIsChildOf(OverrideClass, class'CHSpectator'));
/*	CommanderCheck.bChecked = (OverrideClass != None && ClassIsChildOf(OverrideClass, class'Commander'));*/
}

function ClassChanged()
{
	Super.ClassChanged();

	if(ClassIsChildOf(NewPlayerClass, class'TournamentPlayer'))
	{
		if(Initialized)
		{
			ClassChanging = True;
			IterateVoices();
			VoicePackCombo.SetSelectedIndex(Max(VoicePackCombo.FindItemIndex2(class<TournamentPlayer>(NewPlayerClass).default.VoiceType, True), 0));
			ClassChanging = False;
		}
		VoicePackCombo.ShowWindow();
	}
	else
	{
		VoicePackCombo.HideWindow();
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

	if(ClassIsChildOf(NewPlayerClass, class'TournamentPlayer'))
		VoicePackMetaClass = class<TournamentPlayer>(NewPlayerClass).default.VoicePackMetaClass;
	else
		VoicePackMetaClass = "Botpack.ChallengeVoicePack";

	// Load the base class into memory to prevent GetNextIntDesc crashing as the class isn't loadded.
	DynamicLoadObject(VoicePackMetaClass, class'Class');

	GetPlayerOwner().GetNextIntDesc(VoicePackMetaClass, 0, NextVoice, NextDesc);
	while( (NextVoice != "") && (NumVoices < 64) )
	{
		if(!(NextVoice ~= "Botpack.VoiceBoss") || class'Ladder'.Default.HasBeatenGame)
			VoicePackCombo.AddItem(NextDesc, NextVoice, 0);

		NumVoices++;
		GetPlayerOwner().GetNextIntDesc(VoicePackMetaClass, NumVoices, NextVoice, NextDesc);
	}

	VoicePackCombo.Sort();
}

function BeforePaint(Canvas C, float X, float Y)
{
	local float W, H;
	local float XWidth, YHeight, XMod, YMod, XPos, YPos, YOffset, XL, YL;
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos;

	W = Min(WinWidth, 220);

	ControlWidth = W/3;
	ControlLeft = (W/2 - ControlWidth)/2;
	ControlRight = W/2 + ControlLeft;

	CenterWidth = (W/7)*6;
	CenterPos = (W - CenterWidth)/2;

	W = Root.WinWidth / 4;
	H = W;

	if(W > 256 || H > 256)
	{
		W = 256;
		H = 256;
	}

	XMod = 4*W;
	YMod = 3*H;


	Super.BeforePaint(C, X, Y);

	VoicePackCombo.SetSize(CenterWidth, 1);
	VoicePackCombo.WinLeft = CenterPos;
	VoicePackCombo.EditBoxWidth = 105;

	SpectatorCheck.SetSize(CenterWidth, 1);
	SpectatorCheck.WinLeft = CenterPos;

/*	CommanderCheck.SetSize(CenterWidth, 1);
	CommanderCheck.WinLeft = CenterPos;*/

	StatsLabel.SetSize(CenterWidth, 1);
	StatsLabel.WinLeft = CenterPos;

	StatsButton.AutoWidth(C);
	StatsButton.WinLeft = CenterPos + CenterWidth - 48;
}

function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);

	switch(E)
	{
	case DE_Change:
		switch(C)
		{
		case VoicePackCombo:
			VoiceChanged();
			break;
		case SpectatorCheck:
			SpectatorChanged();
			break;
/*		case CommanderCheck:
			CommanderChanged();
			break;*/
		}
		break;
	case DE_Click:
		switch(C)
		{
		case StatsButton:
			StatsPressed();
			break;
		}
		break;

	}
}

function StatsPressed()
{
	Root.CreateWindow(class<UWindowWindow>(DynamicLoadObject("UTMenu.ngWorldSecretWindow", class'Class')), 100, 100, 200, 200, Root, True);
}

function SpectatorChanged()
{
/*	CommanderCheck.bChecked = False;*/

	if(SpectatorCheck.bChecked)
		GetPlayerOwner().UpdateURL("OverrideClass", "Botpack.CHSpectator", True);
	else
		GetPlayerOwner().UpdateURL("OverrideClass", "", True);
}

/*function CommanderChanged()
{
	SpectatorCheck.bChecked = False;

	if(CommanderCheck.bChecked)
		GetPlayerOwner().UpdateURL("OverrideClass", "Botpack.Commander", True);
	else
		GetPlayerOwner().UpdateURL("OverrideClass", "", True);
}*/

simulated function VoiceChanged()
{
	local class<ChallengeVoicePack> VoicePackClass;

	if(Initialized)
	{
		VoicePackClass = class<ChallengeVoicePack>(DynamicLoadObject(VoicePackCombo.GetValue2(), class'Class'));
		if(!ClassChanging)
			GetPlayerOwner().PlaySound(VoicePackClass.Default.AckSound[Rand(VoicePackClass.Default.NumAcks)]);

		GetPlayerOwner().UpdateURL("Voice", VoicePackCombo.GetValue2(), True);

		if( ClassCombo.GetValue2() ~= string(GetPlayerOwner().Class) && GetPlayerOwner().IsA('TournamentPlayer') )
			TournamentPlayer(GetPlayerOwner()).SetVoice(VoicePackClass);
	}
}

function LoadClasses()
{
	local int NumPlayerClasses;
	local string NextPlayer, NextDesc;

	GetPlayerOwner().GetNextIntDesc("TournamentPlayer", 0, NextPlayer, NextDesc);
	while( (NextPlayer != "") && (NumPlayerClasses < 64) )
	{
		if (!(NextPlayer ~= "Botpack.TBoss") || class'Ladder'.Default.HasBeatenGame)
			ClassCombo.AddItem(NextDesc, NextPlayer, 0);

		NumPlayerClasses++;
		GetPlayerOwner().GetNextIntDesc("TournamentPlayer", NumPlayerClasses, NextPlayer, NextDesc);
	}

	ClassCombo.Sort();
}

defaultproperties
{
	VoicePackText="Voice"
	VoicePackHelp="Choose a voice for your player's taunts and commands."
	SpectatorText="Play as Spectator"
	SpectatorHelp="Check this checkbox to watch the action in the game as a spectator."
//	CommanderText="Play as Commanding Spectator"
//	CommanderHelp="A Commanding Spectator is a special type of spectator who can command bots on their team."
	StatsText="ngWorldStats Password:"
	StatsButtonText="Change"
}