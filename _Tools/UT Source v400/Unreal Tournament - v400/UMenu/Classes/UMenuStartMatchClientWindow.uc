class UMenuStartMatchClientWindow extends UMenuDialogClientWindow;

var UMenuBotmatchClientWindow BotmatchParent;

var bool Initialized;

// Game Type
var UWindowComboControl GameCombo;
var localized string GameText;
var localized string GameHelp;
var string Games[64];
var int MaxGames;

// Map
var UWindowComboControl MapCombo;
var localized string MapText;
var localized string MapHelp;

// Map List Button
var UWindowSmallButton MapListButton;
var localized string MapListText;
var localized string MapListHelp;

var UWindowSmallButton MutatorButton;
var localized string MutatorText;
var localized string MutatorHelp;

function Created()
{
	local int i, j, Selection;
	local class<GameInfo> TempClass;
	local string TempGame;
	local string NextGame;
	local string TempGames[64];
	local bool bFoundSavedGameClass;

	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos;

	Super.Created();

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
	NextGame = GetPlayerOwner().GetNextInt("GameInfo", 0); 
	while (NextGame != "")
	{
		TempGames[i] = NextGame;
		i++;
		NextGame = GetPlayerOwner().GetNextInt("GameInfo", i);
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

	Initialized = True;
}

function IterateMaps(string DefaultMap)
{
	local string FirstMap, NextMap, TestMap;
	local int Selected;

	FirstMap = GetPlayerOwner().GetMapName(BotmatchParent.GameClass.Default.MapPrefix, "", 0);

	MapCombo.Clear();
	NextMap = FirstMap;

	while (!(FirstMap ~= TestMap))
	{
		// Add the map.
		if(!(Left(NextMap, Len(NextMap) - 4) ~= (BotmatchParent.GameClass.Default.MapPrefix$"-tutorial")))
			MapCombo.AddItem(Left(NextMap, Len(NextMap) - 4), NextMap);

		// Get the map.
		NextMap = GetPlayerOwner().GetMapName(BotmatchParent.GameClass.Default.MapPrefix, NextMap, 1);

		// Text to see if this is the last.
		TestMap = NextMap;
	}
	MapCombo.Sort();

	MapCombo.SetSelectedIndex(Max(MapCombo.FindItemIndex2(DefaultMap, True), 0));	
}

function AfterCreate()
{
	BotmatchParent.Map = MapCombo.GetValue2();
	BotmatchParent.ScreenshotWindow.SetMap(BotmatchParent.Map);
}

function BeforePaint(Canvas C, float X, float Y)
{
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos;

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	GameCombo.SetSize(CenterWidth, 1);
	GameCombo.WinLeft = CenterPos;
	GameCombo.EditBoxWidth = 150;

	MapCombo.SetSize(CenterWidth, 1);
	MapCombo.WinLeft = CenterPos;
	MapCombo.EditBoxWidth = 150;

	MapListButton.AutoWidth(C);
	MutatorButton.AutoWidth(C);

	MapListButton.WinWidth = Max(MapListButton.WinWidth, MutatorButton.WinWidth);
	MutatorButton.WinWidth = MapListButton.WinWidth;

	MapListButton.WinLeft = (WinWidth - MapListButton.WinWidth)/2;
	MutatorButton.WinLeft = (WinWidth - MapListButton.WinWidth)/2;
}

function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);

	switch(E)
	{
	case DE_Change:
		switch(C)
		{
		case GameCombo:
			GameChanged();
			break;
		case MapCombo:
			MapChanged();
			break;
		}
		break;
	case DE_Click:
		switch(C)
		{
		case MapListButton:
			GetParent(class'UWindowFramedWindow').ShowModal(Root.CreateWindow(class'UMenuMapListWindow', 0, 0, 100, 100, BotmatchParent));
			break;
		case MutatorButton:
			GetParent(class'UWindowFramedWindow').ShowModal(Root.CreateWindow(class'UMenuMutatorWindow', 0, 0, 100, 100, BotmatchParent));
			break;
		}
	}
}

function GameChanged()
{
	local int CurrentGame, i;

	if (!Initialized)
		return;

	if(BotmatchParent.GameClass != None)
		BotmatchParent.GameClass.static.StaticSaveConfig();

	CurrentGame = GameCombo.GetSelectedIndex();

	BotmatchParent.GameType = Games[CurrentGame];
	BotmatchParent.GameClass = Class<GameInfo>(DynamicLoadObject(BotmatchParent.GameType, class'Class'));

	if ( BotmatchParent.GameClass == None )
	{
		MaxGames--;
		if ( MaxGames > CurrentGame )
		{
			for ( i=CurrentGame; i<MaxGames; i++ )
				Games[i] = Games[i+1];
		}
		else if ( CurrentGame > 0 )
			CurrentGame--;
		GameCombo.SetSelectedIndex(CurrentGame);
		return;
	}
	if (MapCombo != None)
		IterateMaps(BotmatchParent.Map);

	BotmatchParent.GameChanged();
}

function MapChanged()
{
	if (!Initialized)
		return;

	BotmatchParent.Map = MapCombo.GetValue2();
	BotmatchParent.ScreenshotWindow.SetMap(BotmatchParent.Map);
}

defaultproperties
{
	GameText="Game Type:"
	GameHelp="Select the type of game to play."
	MapText="Map Name:"
	MapHelp="Select the map to play."
	MapListText="Map List"
	MapListHelp="Click this button to change the list of maps which will be cycled."
	MutatorText="Mutators"
	MutatorHelp="Mutators are scripts which modify gameplay.  Press this button to choose which mutators to use."
}
