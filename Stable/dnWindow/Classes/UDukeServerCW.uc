 /*-----------------------------------------------------------------------------
	UDukeServerCW
	Author: Scott Alden, Brandon Reinhart
-----------------------------------------------------------------------------*/
class UDukeServerCW expands UDukePageWindow;

var UDukeCreateMultiCW  myParent;
var bool                bInitialized;

// Game Type
var UWindowLabelControl GameLabel;
var UWindowComboControl GameCombo;
var localized string    GameText;
var localized string    GameHelp;
var string              Games[64];
var int                 MaxGames;

// Map
var UWindowLabelControl MapLabel;
var UWindowComboControl MapCombo;
var localized string    MapText;
var localized string    MapHelp;

var UWindowCheckbox     ChangeLevelsCheck;
var localized string    ChangeLevelsText;
var localized string    ChangeLevelsHelp;

var UWindowEditControl  GamePasswordEdit;
var localized string    GamePasswordText;
var localized string    GamePasswordHelp;

// Frag Limit
var UWindowEditControl  FragEdit;
var localized string    FragText;
var localized string    FragHelp;

// Time Limit
var UWindowEditControl  TimeEdit;
var localized string    TimeText;
var localized string    TimeHelp;

// Max Players
var UWindowEditControl  MaxPlayersEdit;
var localized string    MaxPlayersText;
var localized string    MaxPlayersHelp;

var UWindowEditControl  MaxSpectatorsEdit;
var localized string    MaxSpectatorsText;
var localized string    MaxSpectatorsHelp;

// Weapons Stay
var UWindowCheckbox     WeaponsCheck;
var localized string    WeaponsText;
var localized string    WeaponsHelp;

// Tourney
var UWindowCheckbox		TourneyCheck;
var localized string	TourneyText;
var localized string	TourneyHelp;

// Force Respawns
var UWindowCheckbox		ForceRespawnCheck;
var localized string	ForceRespawnText;
var localized string	ForceRespawnHelp;

// Respawn Markers
var UWindowCheckbox     RespawnMarkersCheck;
var localized string    RespawnMarkersText;
var localized string    RespawnMarkersHelp;

function Created()
{
	local int               i, j, Selection;
	local class<GameInfo>   TempClass;
	local string            TempGame;
	local string            NextGame;
	local string            TempGames[64];

	Super.Created();
	myParent = UDukeCreateMultiCW( GetParent( class'UDukeCreateMultiCW' ) );

	// Game
	GameLabel = UWindowLabelControl( CreateControl(class'UWindowLabelControl', 1, 1, 1, 1) );
	GameLabel.SetText( GameText );
	GameLabel.SetFont( F_Normal );
	GameLabel.Align = TA_Right;

	GameCombo = UWindowComboControl( CreateControl( class'UWindowComboControl', 1, 1, 1, 1 ) );
	GameCombo.SetHelpText( GameHelp );
	GameCombo.SetFont( F_Normal );
	GameCombo.SetEditable( False );    
	GameCombo.Align = TA_Right;

	// Compile a list of all gametypes.
	NextGame = GetPlayerOwner().GetNextInt( "GameInfo", 0 ); 
	while ( NextGame != "" )
	{
		TempGames[i] = NextGame;
		i++;
		NextGame = GetPlayerOwner().GetNextInt( "GameInfo", i );
	}

	// Fill the control.
	for ( i=0; i<64; i++ )
	{
		if ( TempGames[i] != "" )
		{
			Games[MaxGames] = TempGames[i];
			TempClass       = Class<GameInfo>( DynamicLoadObject( Games[MaxGames], class'Class' ) );
			GameCombo.AddItem( TempClass.Default.GameName );
			MaxGames++;
		}
	}
	GameCombo.SetSelectedIndex( 0 );
	myParent.GameType   = Games[0];
	myParent.GameClass  = Class<GameInfo>( DynamicLoadObject( myParent.GameType, class'Class' ) );

	// Map Combo Box
	MapLabel = UWindowLabelControl( CreateControl(class'UWindowLabelControl', 1, 1, 1, 1) );
	MapLabel.SetText( MapText );
	MapLabel.SetFont( F_Normal );
	MapLabel.Align = TA_Right;

	MapCombo = UWindowComboControl( CreateControl( class'UWindowComboControl', 1, 1, 1, 1 ) );
	MapCombo.SetHelpText( MapHelp );
	MapCombo.SetFont( F_Normal );
	MapCombo.SetEditable( False );
	MapCombo.Align = TA_Right;
/*

	
    YOffset += ControlHeight + 5;

    IterateMaps( myParent.Map );

	GamePasswordEdit = UWindowEditControl( CreateControl(class'UWindowEditControl', CenterPos, YOffset, ControlWidth, 1 ) );
	GamePasswordEdit.SetText( GamePasswordText );
	GamePasswordEdit.SetHelpText( GamePasswordHelp );
	GamePasswordEdit.SetFont( F_Normal );
	GamePasswordEdit.SetNumericOnly( false );
	GamePasswordEdit.Align = TA_Left;
	GamePasswordEdit.SetDelayedNotify( true );    

    YOffset += ControlHeight + 5;

    // Change Levels Checkbox
    ChangeLevelsCheck = UWindowCheckbox( CreateControl( class'UWindowCheckbox', CenterPos, YOffset, ControlWidth, 1 ) );
	ChangeLevelsCheck.SetText( ChangeLevelsText );
	ChangeLevelsCheck.SetHelpText( ChangeLevelsHelp );
	ChangeLevelsCheck.SetFont( F_Normal );
	ChangeLevelsCheck.Align = TA_Right;

    YOffset += ControlHeight + 5;

	bInitialized = True;

	SetChangeLevels();

	// Frag Limit
	FragEdit = UWindowEditControl( CreateControl(class'UWindowEditControl', ControlLeft, ControlOffset, ControlWidth, 1 ) );
	FragEdit.SetText( FragText );
	FragEdit.SetHelpText( FragHelp );
	FragEdit.SetFont( F_Normal );
	FragEdit.SetNumericOnly( True );
	FragEdit.SetMaxLength( 3 );
	FragEdit.Align = TA_Right;
    ControlOffset += 25;

	// Time Limit
	TimeEdit = UWindowEditControl( CreateControl( class'UWindowEditControl', ControlLeft, ControlOffset, ControlWidth, 1 ) );
	TimeEdit.SetText( TimeText );
	TimeEdit.SetHelpText( TimeHelp );
	TimeEdit.SetFont( F_Normal );
	TimeEdit.SetNumericOnly( True );
	TimeEdit.SetMaxLength( 3 );
	TimeEdit.Align = TA_Right;
	ControlOffset += 25;

	// WeaponsStay
	WeaponsCheck = UWindowCheckbox( CreateControl( class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, 1 ) );
	WeaponsCheck.SetText( WeaponsText );
	WeaponsCheck.SetHelpText( WeaponsHelp );
	WeaponsCheck.SetFont( F_Normal );
	WeaponsCheck.bChecked = myParent.GameClass.Default.bCoopWeaponMode;
	WeaponsCheck.Align = TA_Right;
	ControlOffset += 25;

	// Tournament
	TourneyCheck = UWindowCheckbox( CreateControl( class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, 1 ) );
	TourneyCheck.SetText( TourneyText );
	TourneyCheck.SetHelpText( TourneyHelp );
	TourneyCheck.SetFont( F_Normal );
	TourneyCheck.Align = TA_Right;
	ControlOffset += 25;

	// Force Respawn
	ForceRespawnCheck = UWindowCheckbox( CreateControl( class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, 1 ) );
	ForceRespawnCheck.SetText( ForceRespawnText );
	ForceRespawnCheck.SetHelpText( ForceRespawnHelp );
	ForceRespawnCheck.SetFont( F_Normal );
	ForceRespawnCheck.Align = TA_Right;
	ControlOffset += 25;

	SetupNetworkOptions();
	LoadCurrentValues();

	// Respawn Markers
	RespawnMarkersCheck = UWindowCheckbox( CreateControl( class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, 1 ) );
	RespawnMarkersCheck.SetText( RespawnMarkersText );
	RespawnMarkersCheck.SetHelpText( RespawnMarkersHelp );
	RespawnMarkersCheck.SetFont( F_Normal );
	RespawnMarkersCheck.bChecked = myParent.GameClass.Default.bRespawnMarkers;
	RespawnMarkersCheck.Align = TA_Right;
*/
}

function BeforePaint( Canvas C, float X, float Y )
{
	local int CenterWidth;
	local int CColLeft, CColRight;

	Super.BeforePaint( C, X, Y );

//	if ( !bSetSizeNextFrame )
//		return;

	CenterWidth = (WinWidth/4)*3;
	CColLeft = (WinWidth / 2) - 51;
	CColRight = (WinWidth / 2) - 44;

	GameCombo.SetSize( 200, GameCombo.WinHeight );
	GameCombo.WinLeft = CColRight;
	GameCombo.EditBoxWidth = 200;
	GameCombo.WinTop = 10;

	GameLabel.AutoSize( C );
	GameLabel.WinLeft = CColLeft - GameLabel.WinWidth;
	GameLabel.WinTop = GameCombo.WinTop + 8;

	MapCombo.SetSize( 200, MapCombo.WinHeight );
	MapCombo.WinLeft = CColRight;
	MapCombo.EditBoxWidth = 200;
	MapCombo.WinTop = 10;

	MapLabel.AutoSize( C );
	MapLabel.WinLeft = CColLeft - MapLabel.WinWidth;
	MapLabel.WinTop = GameCombo.WinTop + 8;
}

/*
function AfterCreate()
{
	myParent.Map = MapCombo.GetValue2();
	//myParent.ScreenshotWindow.SetMap(myParent.Map);
}

function SetupNetworkOptions()
{
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos, ButtonWidth, ButtonLeft;

	ControlWidth = WinWidth/2.5;
	ControlLeft = ( WinWidth/2 - ControlWidth )/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = ( WinWidth/4 )*3;
	CenterPos = ( WinWidth - CenterWidth )/2;

	// Max Players
	MaxPlayersEdit = UWindowEditControl( CreateControl( class'UWindowEditControl', 1, 1, 1, 1 ) );
	MaxPlayersEdit.SetText( MaxPlayersText );
	MaxPlayersEdit.SetHelpText( MaxPlayersHelp );
	MaxPlayersEdit.SetFont( F_Normal );
	MaxPlayersEdit.SetNumericOnly( True );
	MaxPlayersEdit.SetMaxLength( 2 );
	MaxPlayersEdit.Align = TA_Right;
	MaxPlayersEdit.SetDelayedNotify( True );
    ControlOffset += 25;

	// Max Spectators
	MaxSpectatorsEdit = UWindowEditControl( CreateControl(class'UWindowEditControl', 1, 1, 1, 1 ) );
	MaxSpectatorsEdit.SetText( MaxSpectatorsText );
	MaxSpectatorsEdit.SetHelpText( MaxSpectatorsHelp );
	MaxSpectatorsEdit.SetFont( F_Normal );
	MaxSpectatorsEdit.SetNumericOnly( True );
	MaxSpectatorsEdit.SetMaxLength( 2 );
	MaxSpectatorsEdit.Align = TA_Right;
	MaxSpectatorsEdit.SetDelayedNotify( True );
	ControlOffset += 25;
}

function LoadCurrentValues()
{
	FragEdit.SetValue( string( Class<dnDeathMatchGame>(myParent.GameClass).Default.FragLimit ) );
	TimeEdit.SetValue( string( Class<dnDeathMatchGame>(myParent.GameClass).Default.TimeLimit ) );

	if(MaxPlayersEdit != None)
		MaxPlayersEdit.SetValue( string( Class<dnDeathMatchGame>(myParent.GameClass).Default.MaxPlayers ) );
	
	if( MaxSpectatorsEdit != None )
		MaxSpectatorsEdit.SetValue( string( Class<dnDeathMatchGame>(myParent.GameClass).Default.MaxSpectators ) );

	WeaponsCheck.bChecked = Class<dnDeathMatchGame>(myParent.GameClass).Default.bCoopWeaponMode;
	TourneyCheck.bChecked = Class<dnDeathMatchGame>(myParent.GameClass).Default.bTournament;
	ForceRespawnCheck.bChecked = Class<dnDeathMatchGame>(myParent.GameClass).Default.bForceRespawn;
}

function IterateMaps( string DefaultMap )
{
	local string FirstMap, NextMap, TestMap;	

	FirstMap = GetPlayerOwner().GetMapName( myParent.GameClass.Default.MapPrefix, "", 0 );

	MapCombo.Clear();
	NextMap = FirstMap;

	while ( !( FirstMap ~= TestMap ) )
	{
		// Add the map
		MapCombo.AddItem( Left( NextMap, Len(NextMap) - 4 ), NextMap );

		// Get the map.
		NextMap = GetPlayerOwner().GetMapName( myParent.GameClass.Default.MapPrefix, NextMap, 1 );

		// Text to see if this is the last.
		TestMap = NextMap;
	}

	MapCombo.Sort();
	MapCombo.SetSelectedIndex( Max( MapCombo.FindItemIndex2( DefaultMap, True ), 0 ) );	
}

function BeforePaint(Canvas C, float X, float Y)
{
	local int ControlWidth, ControlHeight, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos;
    local int YOffset;

    ControlHeight   = 16;
	ControlWidth    = WinWidth / 2.5;
	ControlLeft     = ( WinWidth / 2 - ControlWidth ) / 2;
	ControlRight    = WinWidth / 2 + ControlLeft;

	CenterWidth     = ( WinWidth / 4 ) * 3;
	CenterPos       = ( WinWidth - CenterWidth ) / 2;

    YOffset = 16;

	GameCombo.SetSize( CenterWidth,ControlHeight );
	GameCombo.WinLeft       = CenterPos;
    GameCombo.WinTop        = YOffset;
	GameCombo.EditBoxWidth  = ControlWidth;
    
    YOffset += ControlHeight + 5;

	MapCombo.SetSize( CenterWidth, 1 );
	MapCombo.WinLeft        = CenterPos;
    MapCombo.WinTop         = YOffset;
	MapCombo.EditBoxWidth   = ControlWidth;

    YOffset += ControlHeight + 5;

    GamePasswordEdit.SetSize( CenterWidth, 1);
    GamePasswordEdit.WinLeft        = CenterPos;
    GamePasswordEdit.WinTop         = YOffset;
    GamePasswordEdit.EditBoxWidth   = ControlWidth;

    YOffset += ControlHeight + 5;

    ChangeLevelsCheck.SetSize( ControlWidth, 1 );
    ChangeLevelsCheck.WinLeft   = ( WinWidth - ChangeLevelsCheck.WinWidth ) / 2;    
    ChangeLevelsCheck.WinTop    = YOffset;
}

function GameChanged()
{
    local int CurrentGame, i;

	if ( !bInitialized )
		return;

    // Save config for the old class
	if( myParent.GameClass != None )
		myParent.GameClass.static.StaticSaveConfig();

	CurrentGame = GameCombo.GetSelectedIndex();

    // Load the game class
	myParent.GameType = Games[CurrentGame];
	myParent.GameClass = Class<GameInfo>( DynamicLoadObject( myParent.GameType, class'Class' ) );

    // Check to make sure Game exists, otherwise just select a different one
	if ( myParent.GameClass == None )
	{
		MaxGames--;
		if ( MaxGames > CurrentGame )
		{
			for ( i=CurrentGame; i<MaxGames; i++ )
				Games[i] = Games[i+1];
		}
		else if ( CurrentGame > 0 )
			CurrentGame--;

		GameCombo.SetSelectedIndex( CurrentGame );
		return;
	}

    // Redo maps
	if ( MapCombo != None )
		IterateMaps( myParent.Map );

	SetChangeLevels();

    // Notify parent that the game changed
	myParent.GameChanged();	
}

function MapChanged()
{
    if (!bInitialized)
		return;

	myParent.Map = MapCombo.GetValue2();
	//myParent.ScreenshotWindow.SetMap(myParent.Map);  // FIXME: Add screenshot stuff
}


function ChangeLevelsChanged()
{
	local class<dnDeathMatchGame>DMG;

	DMG = class<dnDeathMatchGame>(myParent.GameClass);

	if ( DMG != None )
	{
		DMG.default.bChangeLevels = ChangeLevelsCheck.bChecked;
		DMG.static.StaticSaveConfig();
	}
}

function SetChangeLevels()
{
	local class<dnDeathMatchGame> DMG;

	DMG = class<dnDeathMatchGame>(myParent.GameClass);
	
	if ( DMG == None )
	{
		ChangeLevelsCheck.HideWindow();
	}
	else
	{
		ChangeLevelsCheck.ShowWindow();
		ChangeLevelsCheck.bChecked = DMG.default.bChangeLevels;
	}
}

function GamePasswordChanged()
{
    GetPlayerOwner().ConsoleCommand( "set engine.gameinfo GamePassword "$GamePasswordEdit.GetValue() );
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
		case ChangeLevelsCheck:
			ChangeLevelsChanged();
			break;
		case GamePasswordEdit:
			GamePasswordChanged();
			break;
		}
		break;
	case DE_Click:
		break;
	}

}
*/
defaultproperties
{
    GameText="Game Type:"
	GameHelp="Select the type of game to play."
	MapText="Start Map Name:"
	MapHelp="Select the starting map to play."
	GamePasswordText="Game Password"
	GamePasswordHelp="If this is set, a player needs use this password to be allowed to login to the server."
	ChangeLevelsText="Auto Change Levels"
	ChangeLevelsHelp="If this setting is checked, the server will change levels according to the map list for this game type."
}