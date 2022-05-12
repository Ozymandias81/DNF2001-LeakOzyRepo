class UTMenuStartMatchCW expands UMenuStartMatchClientWindow;

var UWindowCheckbox ChangeLevelsCheck;
var localized string ChangeLevelsText;
var localized string ChangeLevelsHelp;

function Created()
{
	local int i, j, Selection, Pos;
	local class<GameInfo> TempClass;
	local string TempGame;
	local string NextGame;
	local string TempGames[64];
	local bool bFoundSavedGameClass;

	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos;

	Super(UMenuDialogClientWindow).Created();

	DesiredWidth = 270;
	DesiredHeight = 100;

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	BotmatchParent = UMenuBotmatchClientWindow(GetParent(class'UMenuBotmatchClientWindow'));
	if (BotmatchParent == None)
		Log("Error: UMenuStartMatchClientWindow without UMenuBotmatchClientWindow parent.");

	// Game Type
	GameCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, 20, CenterWidth, 1));
	GameCombo.SetButtons(True);
	GameCombo.SetText(GameText);
	GameCombo.SetHelpText(GameHelp);
	GameCombo.SetFont(F_Normal);
	GameCombo.SetEditable(False);

	// Compile a list of all gametypes.
	i=0;
	TempClass = class'TournamentGameInfo';
	NextGame = GetPlayerOwner().GetNextInt("TournamentGameInfo", 0); 
	while (NextGame != "")
	{
		Pos = InStr(NextGame, ".");
		TempGames[i] = NextGame;
		i++;
		if(i == 64)
		{
			Log("More than 64 gameinfos listed in int files");
			break;
		}
		NextGame = GetPlayerOwner().GetNextInt("TournamentGameInfo", i);
	}

	// Fill the control.
	for (i=0; i<64; i++)
	{
		if (TempGames[i] != "")
		{
			Games[MaxGames] = TempGames[i];
			if ( !bFoundSavedGameClass && (Games[MaxGames] ~= BotmatchParent.GameType) )
			{
				bFoundSavedGameClass = true;
				Selection = MaxGames;
			}
			TempClass = Class<GameInfo>(DynamicLoadObject(Games[MaxGames], class'Class'));
			GameCombo.AddItem(TempClass.Default.GameName);
			MaxGames++;
		}
	}

	GameCombo.SetSelectedIndex(Selection);	
	BotmatchParent.GameType = Games[Selection];
	BotmatchParent.GameClass = Class<GameInfo>(DynamicLoadObject(BotmatchParent.GameType, class'Class'));

	// Map
	MapCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, 45, CenterWidth, 1));
	MapCombo.SetButtons(True);
	MapCombo.SetText(MapText);
	MapCombo.SetHelpText(MapHelp);
	MapCombo.SetFont(F_Normal);
	MapCombo.SetEditable(False);

	IterateMaps(BotmatchParent.Map);

	// Map List Button
	MapListButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', CenterPos, 70, 48, 16));
	MapListButton.SetText(MapListText);
	MapListButton.SetFont(F_Normal);
	MapListButton.SetHelpText(MapListHelp);

	// Mutator Button
	MutatorButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', CenterPos, 95, 48, 16));
	MutatorButton.SetText(MutatorText);
	MutatorButton.SetFont(F_Normal);
	MutatorButton.SetHelpText(MutatorHelp);

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	ChangeLevelsCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', CenterPos, 120, ControlWidth, 1));
	ChangeLevelsCheck.SetText(ChangeLevelsText);
	ChangeLevelsCheck.SetHelpText(ChangeLevelsHelp);
	ChangeLevelsCheck.SetFont(F_Normal);
	ChangeLevelsCheck.Align = TA_Right;

	SetChangeLevels();

	Initialized = True;
}

function BeforePaint(Canvas C, float X, float Y)
{
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos;

	Super.BeforePaint(C, X, Y);

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	ChangeLevelsCheck.SetSize(ControlWidth, 1);		
	ChangeLevelsCheck.WinLeft = (WinWidth - ChangeLevelsCheck.WinWidth) / 2;
}

function GameChanged()
{
	if (!Initialized)
		return;

	Super.GameChanged();
	SetChangeLevels();
}

function SetChangeLevels()
{
	local class<DeathMatchPlus> DMP;

	DMP = class<DeathMatchPlus>(BotmatchParent.GameClass);
	if(DMP == None)
	{
		ChangeLevelsCheck.HideWindow();
	}
	else
	{
		ChangeLevelsCheck.ShowWindow();
		ChangeLevelsCheck.bChecked = DMP.default.bChangeLevels;
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
		case ChangeLevelsCheck:
			ChangeLevelsChanged();
			break;
		}
		break;
	}
}

function ChangeLevelsChanged()
{
	local class<DeathMatchPlus> DMP;

	DMP = class<DeathMatchPlus>(BotmatchParent.GameClass);
	if(DMP != None)
	{
		DMP.default.bChangeLevels = ChangeLevelsCheck.bChecked;
		DMP.static.StaticSaveConfig();
	}
}

defaultproperties
{
	ChangeLevelsText="Auto Change Levels"
	ChangeLevelsHelp="If this setting is checked, the server will change levels according to the map list for this game type."
}