class UMenuBotmatchClientWindow extends UWindowDialogClientWindow;

// Game Information
var config string Map;
var config string GameType;
var class<GameInfo> GameClass;

var bool bNetworkGame;

// Window
var UMenuPageControl Pages;
var UWindowSmallCloseButton CloseButton;
var UWindowSmallButton StartButton;
var UMenuScreenshotCW ScreenshotWindow;
var UWindowHSplitter Splitter;

var localized string StartMatchTab, RulesTab, SettingsTab, BotConfigTab;
var localized string StartText;

var config string MutatorList;
var config bool bKeepMutators;

function Created()
{
	if(!bKeepMutators)
		MutatorList = "";

	Splitter = UWindowHSplitter(CreateWindow(class'UWindowHSplitter', 0, 0, WinWidth, WinHeight));
	Splitter.SplitPos = 280;
	Splitter.MaxSplitPos = 280;
	Splitter.bRightGrow = True;

	ScreenshotWindow = UMenuScreenshotCW(Splitter.CreateWindow(class'UMenuScreenshotCW', 0, 0, WinWidth, WinHeight));

	CreatePages();

	Splitter.LeftClientWindow = Pages;
	Splitter.RightClientWindow = ScreenshotWindow;

	CloseButton = UWindowSmallCloseButton(CreateControl(class'UWindowSmallCloseButton', WinWidth-56, WinHeight-24, 48, 16));
	StartButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', WinWidth-106, WinHeight-24, 48, 16));
	StartButton.SetText(StartText);

	Super.Created();
}

function CreatePages()
{
	local class<UWindowPageWindow> PageClass;

	Pages = UMenuPageControl(Splitter.CreateWindow(class'UMenuPageControl', 0, 0, WinWidth, WinHeight));
	Pages.SetMultiLine(True);
	Pages.AddPage(StartMatchTab, class'UMenuStartMatchScrollClient');

	PageClass = class<UWindowPageWindow>(DynamicLoadObject(GameClass.Default.RulesMenuType, class'Class'));
	if(PageClass != None)
		Pages.AddPage(RulesTab, PageClass);

	PageClass = class<UWindowPageWindow>(DynamicLoadObject(GameClass.Default.SettingsMenuType, class'Class'));
	if(PageClass != None)
		Pages.AddPage(SettingsTab, PageClass);

	PageClass = class<UWindowPageWindow>(DynamicLoadObject(GameClass.Default.BotMenuType, class'Class'));
	if(PageClass != None)
		Pages.AddPage(BotConfigTab, PageClass);
}

function Resized()
{
	if(ParentWindow.WinWidth == 520)
	{
		Splitter.bSizable = False;
		Splitter.MinWinWidth = 0;
	}
	else
		Splitter.MinWinWidth = 100;

	Splitter.WinWidth = WinWidth;
	Splitter.WinHeight = WinHeight - 24;	// OK, Cancel area

	CloseButton.WinLeft = WinWidth-52;
	CloseButton.WinTop = WinHeight-20;
	StartButton.WinLeft = WinWidth-102;
	StartButton.WinTop = WinHeight-20;
}

function Paint(Canvas C, float X, float Y)
{
	local Texture T;

	T = GetLookAndFeelTexture();
	DrawUpBevel( C, 0, LookAndFeel.TabUnselectedM.H, WinWidth, WinHeight-LookAndFeel.TabUnselectedM.H, T);
}

function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);

	switch(E)
	{
	case DE_Click:
		switch (C)
		{
		case StartButton:
			StartPressed();
			break;
		}
	}
}

function StartPressed()
{
	local string URL;
	local GameInfo NewGame;

	// Reset the game class.
	GameClass.Static.ResetGame();

	URL = Map $ "?Game="$GameType$"?Mutator="$MutatorList;

	ParentWindow.Close();
	Root.Console.CloseUWindow();
	GetPlayerOwner().ClientTravel(URL, TRAVEL_Absolute, false);
}

function GameChanged()
{
	local UWindowPageControlPage RulesPage, SettingsPage, BotConfigPage;
	local class<UWindowPageWindow> PageClass;

	// Change out the rules page...
	PageClass = class<UWindowPageWindow>(DynamicLoadObject(GameClass.Default.RulesMenuType, class'Class'));
	RulesPage = Pages.GetPage(RulesTab);
	if(PageClass != None)
		Pages.InsertPage(RulesPage, RulesTab, PageClass);
	Pages.DeletePage(RulesPage);

	// Change out the settings page...
	PageClass = class<UWindowPageWindow>(DynamicLoadObject(GameClass.Default.SettingsMenuType, class'Class'));
	SettingsPage = Pages.GetPage(SettingsTab);
	if(PageClass != None)
		Pages.InsertPage(SettingsPage, SettingsTab, PageClass);
	Pages.DeletePage(SettingsPage);

	// Change out the bots page...
	PageClass = class<UWindowPageWindow>(DynamicLoadObject(GameClass.Default.BotMenuType, class'Class'));
	BotConfigPage = Pages.GetPage(BotConfigTab);
	if(PageClass != None)
		Pages.InsertPage(BotConfigPage, BotConfigTab, PageClass);
	Pages.DeletePage(BotConfigPage);
}

function SaveConfigs()
{
	if (GameClass != None)
		GameClass.Static.StaticSaveConfig();
	Super.SaveConfigs();
}

defaultproperties
{
	GameType="UnrealShare.DeathMatchGame"
	StartText="Start"
	StartMatchTab="Match"
	RulesTab="Rules"
	SettingsTab="Settings"
	BotConfigTab="Bots"
	bKeepMutators=False
}