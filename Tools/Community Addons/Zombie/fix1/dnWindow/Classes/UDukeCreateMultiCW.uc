//=============================================================================
// 
// FILE:			UDukeCreateMultiCW.uc
// 
// AUTHOR:			Scott Alden
// 
// DESCRIPTION:		Tabwindow for creating any multiplayer game.  This will be common to all game types
//                  Consists of multiple pages
//                  - StartMatchTabText
//                  - RulesTabText
//                  - Settings Tab
// 
// MOD HISTORY: 
// 
//==========================================================================
class UDukeCreateMultiCW expands UDukePageWindow;

var UWindowPageControl      Pages;
var UWindowSmallButton      DedicatedButton;
var UWindowSmallButton      StartButton;

var localized string        DedicatedText;
var localized string        ServerText;
var localized string        StartText;

// Game Information
var config string           Map;
var config string           GameType;
var config string           MutatorList;
var config bool				bKeepMutators;
var class<GameInfo>         GameClass;

var localized string        StartMatchTabText;
var localized string        RulesTabText;
var localized string        SettingsTabText;
var localized string        BotsTabText;
var localized string        ServerTabText;
var localized string        MapsTabText;
var localized string        MutatorTabText;

var UWindowPageControlPage  ServerTab;
var UWindowPageControlPage  MutatorTab;

function Created()
{
	if( !bKeepMutators )
		MutatorList = "";

    CreatePages();
	
    StartButton = UWindowSmallButton( CreateControl( class'UWindowSmallButton', WinWidth-106, WinHeight-24, 48, 16 ) );
	StartButton.SetText( StartText );

	// Dedicated
	DedicatedButton = UWindowSmallButton( CreateControl( class'UWindowSmallButton', WinWidth-156, WinHeight-24, 48, 16 ) );
	DedicatedButton.SetText( DedicatedText );

	Super.Created();
}

function CreatePages()
{
    local class<UWindowPageWindow> PageClass;

	Pages = UWindowPageControl( CreateWindow( class'UWindowPageControl', 0, 0, WinWidth, WinHeight-26 ) );
	Pages.SetMultiLine( True );

    Pages.AddPage( StartMatchTabText, class'UDukeStartMatchSC' );

    // Load these pages basd on the current GameClass

	PageClass = class<UWindowPageWindow>( DynamicLoadObject( GameClass.Default.RulesMenuType, class'Class' ) );
	if ( PageClass != None )
		Pages.AddPage( RulesTabText, PageClass );

	PageClass = class<UWindowPageWindow>( DynamicLoadObject( GameClass.Default.SettingsMenuType, class'Class' ) );
	if ( PageClass != None )
		Pages.AddPage( SettingsTabText, PageClass );

    PageClass = class<UWindowPageWindow>( DynamicLoadObject( GameClass.Default.BotMenuType, class'Class' ) );
	if ( PageClass != None )
		Pages.AddPage( BotsTabText, PageClass );

    PageClass = class<UWindowPageWindow>( DynamicLoadObject( GameClass.Default.MapMenuType, class'Class' ) );
	if ( PageClass != None )
		Pages.AddPage( MapsTabText, PageClass );

	PageClass = class<UWindowPageWindow>( DynamicLoadObject( GameClass.Default.MutatorMenuType, class'Class' ) );
	if ( PageClass != None )
		MutatorTab = Pages.AddPage( MutatorTabText, PageClass );

    PageClass = class<UWindowPageWindow>( DynamicLoadObject( GameClass.Default.ServerMenuType, class'Class' ) );
	if ( PageClass != None )
		ServerTab = Pages.AddPage( ServerTabText, PageClass );
}

function AfterCreate()
{
	ReloadMapList();
}

function ChangePage( string PageType, string TabName )
{
    local UWindowPageControlPage   NewPage;
	local class<UWindowPageWindow> PageClass;

	PageClass = class<UWindowPageWindow>( DynamicLoadObject( PageType, class'Class' ) );
	NewPage = Pages.GetPage( TabName );
	if( PageClass != None )
		Pages.InsertPage( NewPage, TabName, PageClass );
	Pages.DeletePage( NewPage );
}

function ReloadMapList()
{
	local dnMapListCW MapList;

	MapList = dnMapListCW( dnMapListSC( Pages.GetPage( MapsTabText ).Page ).ClientArea );

	if ( MapList != None )
	{
		MapList.LoadMapList();
	}
}

function GameChanged()
{
	local UWindowPageControlPage	RulesPage, SettingsPage;
	local class<UWindowPageWindow>	PageClass;

    ChangePage( GameClass.Default.RulesMenuType,    RulesTabText );
    ChangePage( GameClass.Default.SettingsMenuType, SettingsTabText );
    ChangePage( GameClass.Default.BotMenuType,      BotsTabText );
    ChangePage( GameClass.Default.MapMenuType,      MapsTabText );
	ChangePage( GameClass.Default.MutatorMenuType,  MutatorTabText );
    ChangePage( GameClass.Default.ServerMenuType,   ServerTabText );

	ReloadMapList();
}

function BeforePaint( Canvas C, float X, float Y )
{
    Super.BeforePaint( C, X, Y );

    StartButton.WinLeft     = WinWidth  - 106;
    StartButton.WinTop      = WinHeight - 24;
    DedicatedButton.WinLeft = WinWidth  - 156;
	DedicatedButton.WinTop  = WinHeight - 24;
}

function Resized()
{
	Super.Resized();

    Pages.WinWidth  = WinWidth;
    Pages.WinHeight = WinHeight - 26;
}

function Notify( UWindowDialogControl C, byte E )
{
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
			default:
				Super.Notify( C, E );
				return;
		}
	default:
		Super.Notify( C, E );
		return;
	}
}

function GetMutators()
{
	// Force a SaveConfigs() which builds the MutatorList here.
	if ( dnMutatorListCW( dnMutatorListSC( MutatorTab.Page ).ClientArea) != None ) 
		dnMutatorListCW( dnMutatorListSC( MutatorTab.Page ).ClientArea).SaveConfigs();
}

function DedicatedPressed()
{
	local string URL;
	local GameInfo NewGame;
	local string LanPlay;

	GetMutators();

	if( UDukeServerSettingsCW( UDukeServerSettingsSC( ServerTab.Page ).ClientArea).bLanPlay )
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
     ServerText="Server"
     StartText="Start"
     GameType="dnGame.dnDeathmatchGame"
     StartMatchTabText="Game"
     RulesTabText="Rules"
     SettingsTabText="Settings"
     BotsTabText="Bots"
     ServerTabText="Server"
     MapsTabText="Map List"
     MutatorTabText="Mutators"
     bBuildDefaultButtons=False
     bNoScanLines=True
     bNoClientTexture=True
}
