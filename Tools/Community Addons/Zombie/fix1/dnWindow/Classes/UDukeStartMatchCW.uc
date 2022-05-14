class UDukeStartMatchCW expands UDukePageWindow;

var UDukeCreateMultiCW  myParent;

var bool                bInitialized;
// Game Type
var UWindowComboControl GameCombo;
var localized string    GameText;
var localized string    GameHelp;
var string              Games[64];
var int                 MaxGames;

// Map
var UWindowComboControl MapCombo;
var localized string    MapText;
var localized string    MapHelp;

var UWindowCheckbox     ChangeLevelsCheck;
var localized string    ChangeLevelsText;
var localized string    ChangeLevelsHelp;

var UWindowEditControl  GamePasswordEdit;
var localized string    GamePasswordText;
var localized string    GamePasswordHelp;

function Created()
{
	local int               i, j, Selection;
	local class<GameInfo>   TempClass;
	local string            TempGame;
	local string            NextGame;
	local string            TempGames[64];
	local int               ControlWidth, ControlHeight, ControlLeft, ControlRight;
	local int               CenterWidth, CenterPos;
    local int               YOffset;

	Super.Created();

    ControlWidth    = WinWidth / 2.5;
	ControlLeft     = ( WinWidth / 2 - ControlWidth ) / 2;
	ControlRight    = WinWidth / 2 + ControlLeft;
	CenterWidth     = ( WinWidth / 4 ) * 3;
	CenterPos       = ( WinWidth - CenterWidth ) / 2;
    
    ControlHeight   = 16;

    YOffset         = 16;

	myParent = UDukeCreateMultiCW( GetParent( class'UDukeCreateMultiCW' ) );

	if ( myParent == None )
    {
		Log( "Error: UDukeStartMatchCW without UDukeCreateMultiCW parent." );
    }

	// Game Type combo box
	GameCombo = UWindowComboControl( CreateControl( class'UWindowComboControl', CenterPos, YOffset, CenterWidth, 1 ) );
	GameCombo.SetButtons( True );
	GameCombo.SetText( GameText );
	GameCombo.SetHelpText( GameHelp );
	GameCombo.SetFont( F_Normal );
	GameCombo.SetEditable( False );    

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
    
	if ( myParent.GameClass == None )
	{
		Log( "Could not load Game Class:" @ myParent.GameClass );
	}
    
    YOffset += ControlHeight + 5;

	// Map Combo Box
	MapCombo = UWindowComboControl( CreateControl( class'UWindowComboControl', CenterPos, YOffset, CenterWidth, 1 ) );
	MapCombo.SetButtons( True );
	MapCombo.SetText( MapText );
	MapCombo.SetHelpText( MapHelp );
	MapCombo.SetFont( F_Normal );
	MapCombo.SetEditable( False );
	
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
}

function AfterCreate()
{
	myParent.Map = MapCombo.GetValue2();
	//myParent.ScreenshotWindow.SetMap(myParent.Map);
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

defaultproperties
{
     GameText="Game Type:"
     GameHelp="Select the type of game to play."
     MapText="Start Map Name:"
     MapHelp="Select the starting map to play."
     ChangeLevelsText="Auto Change Levels"
     ChangeLevelsHelp="If this setting is checked, the server will change levels according to the map list for this game type."
     GamePasswordText="Game Password"
     GamePasswordHelp="If this is set, a player needs use this password to be allowed to login to the server."
     bBuildDefaultButtons=False
     bNoScanLines=True
     bNoClientTexture=True
}
