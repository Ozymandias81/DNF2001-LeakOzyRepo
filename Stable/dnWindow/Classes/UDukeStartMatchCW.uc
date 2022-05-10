class UDukeStartMatchCW expands UDukePageWindow;

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

// Game password
var UWindowLabelControl GamePasswordLabel;
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

	Super.Created();

	myParent = UDukeCreateMultiCW( GetParent( class'UDukeCreateMultiCW' ) );
	if ( myParent == None )
		Log( "Error: UDukeStartMatchCW without UDukeCreateMultiCW parent." );

	// Game Type combo box
	GameLabel = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 1, 1, 1, 1));
	GameLabel.SetText( GameText );
	GameLabel.SetFont( F_Normal );
	GameLabel.Align = TA_Right;

	GameCombo = UWindowComboControl( CreateControl( class'UWindowComboControl', 1, 1, 1, 1 ) );
	GameCombo.SetHelpText( GameHelp );
	GameCombo.SetFont( F_Normal );
	GameCombo.SetEditable( false );
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
    
	if ( myParent.GameClass == None )
		Log( "Could not load Game Class:" @ myParent.GameClass );
    
	// Map Combo Box
	MapLabel = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 1, 1, 1, 1));
	MapLabel.SetText( MapText );
	MapLabel.SetFont( F_Normal );
	MapLabel.Align = TA_Right;

	MapCombo = UWindowComboControl( CreateControl( class'UWindowComboControl', 1, 1, 1, 1 ) );
	MapCombo.SetHelpText( MapHelp );
	MapCombo.SetFont( F_Normal );
	MapCombo.SetEditable( false );
	MapCombo.Align = TA_Right;

    IterateMaps( myParent.Map );

	GamePasswordLabel = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 1, 1, 1, 1));
	GamePasswordLabel.SetText( GamePasswordText );
	GamePasswordLabel.SetFont( F_Normal );
	GamePasswordLabel.Align = TA_Right;

	GamePasswordEdit = UWindowEditControl( CreateControl(class'UWindowEditControl', 1, 1, 1, 1 ) );
	GamePasswordEdit.SetHelpText( GamePasswordHelp );
	GamePasswordEdit.SetFont( F_Normal );
	GamePasswordEdit.SetNumericOnly( false );
	GamePasswordEdit.Align = TA_Right;
	GamePasswordEdit.SetDelayedNotify( true );    

	bInitialized = true;
	ResizeFrames = 3;
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

function BeforePaint( Canvas C, float X, float Y )
{
	local int CenterWidth;
	local int CColLeft, CColRight;

	Super.BeforePaint( C, X, Y );

	if ( ResizeFrames == 0 )
		return;
	ResizeFrames--;

	CenterWidth = (WinWidth/4)*3;
	CColLeft = (WinWidth / 2) - 7;
	CColRight = (WinWidth / 2) + 7;

	GameCombo.SetSize( 300, GameCombo.WinHeight );
	GameCombo.WinLeft = CColRight - 80;
	GameCombo.WinTop = 192+20;

	GameLabel.AutoSize( C );
	GameLabel.WinLeft = CColLeft - GameLabel.WinWidth - 80;
	GameLabel.WinTop = GameCombo.WinTop + 8;

	MapCombo.SetSize( 300, MapCombo.WinHeight );
	MapCombo.WinLeft = CColRight - 80;
	MapCombo.WinTop = GameCombo.WinTop + GameCombo.WinHeight + 2;

	MapLabel.AutoSize( C );
	MapLabel.WinLeft = CColLeft - MapLabel.WinWidth - 80;
	MapLabel.WinTop = MapCombo.WinTop + 8;

	GamePasswordEdit.SetSize( 300, GamePasswordEdit.WinHeight );
	GamePasswordEdit.WinLeft = CColRight - 80;
	GamePasswordEdit.WinTop = MapCombo.WinTop + MapCombo.WinHeight + 2;

	GamePasswordLabel.AutoSize( C );
	GamePasswordLabel.WinLeft = CColLeft - GamePasswordLabel.WinWidth - 80;
	GamePasswordLabel.WinTop = GamePasswordEdit.WinTop + 8;
}

function Paint( Canvas C, float X, float Y )
{
	Super.Paint( C, X, Y );

	LookAndFeel.Bevel_DrawSimpleBevel( Self, C, (WinWidth-256)/2, 10, 256, 192 );
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

function GamePasswordChanged()
{
    GetPlayerOwner().ConsoleCommand( "set engine.gameinfo GamePassword "$GamePasswordEdit.GetValue() );
}

function Notify(UWindowDialogControl C, byte E)
{
    Super.Notify(C, E);

	if ( !bInitialized )
		return;

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
	MapText="Start Map:"
	MapHelp="Select the starting map to play."
	GamePasswordText="Game Password:"
	GamePasswordHelp="If this is set, a player needs use this password to be allowed to login to the server."
    bBuildDefaultButtons=false
    bNoScanLines=true
    bNoClientTexture=true
}