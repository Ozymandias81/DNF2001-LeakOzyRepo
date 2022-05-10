/*-----------------------------------------------------------------------------
	UDukeCreateMultiCW
	Author: Scott Alden, Brandon Reinhart
-----------------------------------------------------------------------------*/
class UDukeCreateMultiCW expands UDukePageWindow;

var UWindowComboControl		PageCombo;
var localized string		PageHelp;
var UDukeArrowButton		NextButton;
var UDukeArrowButton		PrevButton;

var UWindowWindow			Windows[5];
var UWindowSmallButton      DedicatedButton;
var UWindowSmallButton      StartButton;
var localized string		PageText[5];
var int						CurrentWindow;

var localized string        DedicatedText;
var localized string        ServerText;
var localized string        StartText;

// Game Information
var config string           Map;
var config string           GameType;
var config string           MutatorList;
var config bool				bKeepMutators;
var class<GameInfo>         GameClass;

var UWindowPageControlPage  ServerTab;
var UWindowPageControlPage  MutatorTab;

var bool bInitialized;

function Created()
{
	local class<UWindowWindow> PageClass;
	local int i;

	if ( !bKeepMutators )
		MutatorList = "";

	// Page combo
	PageCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', 1, 1, 1, 1));
	PageCombo.SetHelpText(PageHelp);
	PageCombo.SetFont(F_Normal);
	PageCombo.SetEditable(false);
	PageCombo.Align = TA_Right;
	for ( i=0; i<5; i++ )
	{
		PageCombo.AddItem( PageText[i], string(i) );
	}
	PageCombo.SetSelectedIndex(0);
	CurrentWindow = 0;

	// Scroll left button
	PrevButton = UDukeArrowButton( CreateControl( class'UDukeArrowButton', WinWidth/2-256/2-36, 10, 36, 29 ) );
	PrevButton.SetHelpText("Scroll options category left.");
	PrevButton.bLeft = true;

	// Scroll right button
	NextButton = UDukeArrowButton( CreateControl( class'UDukeArrowButton', WinWidth/2+256/2, 10, 36, 29 ) );
	NextButton.SetHelpText("Scroll options category right.");

	// Pages
	Windows[0] = CreateWindow( class'UDukeStartMatchSC', 0, 0, WinWidth, WinHeight );
	Windows[0].ShowWindow();

    ChangePage( GameClass.Default.RulesMenuType,    1 );
    ChangePage( GameClass.Default.BotMenuType,      2 );
    ChangePage( GameClass.Default.MapMenuType,      3 );
	ChangePage( GameClass.Default.MutatorMenuType,  4 );

	UDukeCreateMultiWindow(ParentWindow.ParentWindow).ScrollClient = UDukeEmbeddedClient(Windows[0]);
	
	// Start
    StartButton = UWindowSmallButton( CreateControl( class'UWindowSmallButton', 1, 1, 1, 1 ) );
	StartButton.SetText( StartText );
	StartButton.bAlwaysOnTop = true;

	// Dedicated
	DedicatedButton = UWindowSmallButton( CreateControl( class'UWindowSmallButton', 1, 1, 1, 1 ) );
	DedicatedButton.SetText( DedicatedText );
	DedicatedButton.bAlwaysOnTop = true;

	Super.Created();

	bInitialized = true;
	ResizeFrames = 3;
}

function AfterCreate()
{
	ReloadMapList();
}

function ReloadMapList()
{
	local dnMapListCW MapList;

	MapList = dnMapListCW( dnMapListSC( Windows[3] ).ClientArea );

	if ( MapList != None )
	{
		MapList.LoadMapList();
	}
}

function GameChanged()
{
    ChangePage( GameClass.Default.RulesMenuType,    1 );
    ChangePage( GameClass.Default.BotMenuType,      2 );
    ChangePage( GameClass.Default.MapMenuType,      3 );
	ChangePage( GameClass.Default.MutatorMenuType,  4 );

	ResizeFrames = 3;

	ReloadMapList();
}

function ChangePage( string PageType, int Index )
{
	local class<UWindowWindow> PageClass;

	PageClass = class<UWindowWindow>( DynamicLoadObject( PageType, class'Class' ) );
	Windows[Index] = CreateWindow( PageClass, 0, 0, WinWidth, WinHeight );
	Windows[Index].HideWindow();
}

function BeforePaint( Canvas C, float X, float Y )
{
	local int i;
	local float W;

    Super.BeforePaint( C, X, Y );

	if ( ResizeFrames == 0 )
		return;
	ResizeFrames--;

	PageCombo.SetSize( 256, PageCombo.WinHeight );
	PageCombo.WinLeft = (WinWidth - 256)/2.0;
	PageCombo.WinTop = 10;

	for ( i=0; i<5; i++ )
	{
		Windows[i].WinLeft = 0;
		Windows[i].WinTop = 15 + PageCombo.WinHeight;
		Windows[i].WinHeight = WinHeight - (15 + PageCombo.WinHeight);
	}

	StartButton.AutoSize(C);
	DedicatedButton.AutoSize(C);

	W = StartButton.WinWidth + DedicatedButton.WinWidth + 5;
	StartButton.WinLeft = (WinWidth - W)/2;
	StartButton.WinTop = WinHeight - StartButton.WinHeight - 10;

	DedicatedButton.WinLeft = StartButton.WinLeft + StartButton.WinWidth + 5;
	DedicatedButton.WinTop = StartButton.WinTop;
}

function Notify( UWindowDialogControl C, byte E )
{
	local int i;

	if ( !bInitialized )
		return;

	switch( E )
	{
	case DE_Click:
		switch ( C )
		{
			case StartButton:
				StartPressed();
				return;
			case DedicatedButton:
				DedicatedPressed();
				return;
			case PrevButton:
				i = PageCombo.GetSelectedIndex();
				i--;
				if ( i < 0 )
					i = PageCombo.List.Items.Count() - 1;
				PageCombo.SetSelectedIndex( i );
				return;
			case NextButton:
				i = PageCombo.GetSelectedIndex();
				i++;
				if ( i >= PageCombo.List.Items.Count() )
					i = 0;
				PageCombo.SetSelectedIndex( i );
				return;
			default:
				Super.Notify( C, E );
				return;
		}
	case DE_Change:
		switch ( C )
		{
			case PageCombo:
				PageChanged();
				return;
		}

	default:
		Super.Notify( C, E );
		return;
	}
}

function PageChanged()
{
	Windows[CurrentWindow].HideWindow();
	CurrentWindow = int(PageCombo.GetValue2());
	Windows[CurrentWindow].ShowWindow();
	UDukeCreateMultiWindow(ParentWindow.ParentWindow).ScrollClient = UDukeEmbeddedClient(Windows[CurrentWindow]);

	if ( CurrentWindow == 0 )
	{
		StartButton.ShowWindow();
		DedicatedButton.ShowWindow();
	}
	else
	{
		StartButton.HideWindow();
		DedicatedButton.HideWindow();
	}
}

function GetMutators()
{
	// Force a SaveConfigs() which builds the MutatorList here.
	if ( dnMutatorListCW( dnMutatorListSC( Windows[4] ).ClientArea) != None ) 
		dnMutatorListCW( dnMutatorListSC( Windows[4] ).ClientArea).SaveConfigs();
}

function DedicatedPressed()
{
	local string URL;
	local GameInfo NewGame;
	local string LanPlay;

	GetMutators();

	if( UDukeMultiRulesBase( UDukeMultiRulesSC( Windows[1] ).ClientArea).bLanPlay )
		LanPlay = " -lanplay";

	URL = Map $ "?Game="$GameType$"?Mutator="$MutatorList;
	URL = URL $ "?Listen";

	ParentWindow.Close();
	Root.Console.CloseUWindow();
	GetPlayerOwner().ConsoleCommand( "RELAUNCH "$URL$LanPlay$" -server log="$GameClass.Default.ServerLogName );
}

function StartPressed()
{
	local string URL, Checksum;
	local GameInfo NewGame;

	GameClass.Static.ResetGame();

	GetMutators();

	URL = Map $ "?Game="$GameType$"?Mutator="$MutatorList;
	URL = URL $ "?Listen";

    Log( "URL="@URL );

	ParentWindow.Close();
	Root.Console.CloseUWindow();
	GetPlayerOwner().ClientTravel( URL, TRAVEL_Absolute, false );
}

function SaveConfigs()
{
	SaveConfig();

	if ( GameClass != None )
		GameClass.Static.StaticSaveConfig();
	Super.SaveConfigs();
}

defaultproperties
{
    DedicatedText="Dedicated"
    StartText="Start"
    ServerText="Server"

	PageText[0]="Game and Map"
	PageText[1]="Server Rules"
	PageText[2]="Bot Settings"
	PageText[3]="Map Rotation"
	PageText[4]="Mutator List"

    GameType="dnGame.dnDeathmatchGame"
	GameClass=class'dnGame.dnDeathmatchGame'

    bBuildDefaultButtons=false
	bKeepMutators=false
}
