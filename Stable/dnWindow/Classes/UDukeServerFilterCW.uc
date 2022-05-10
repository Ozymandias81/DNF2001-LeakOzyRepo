class UDukeServerFilterCW extends UDukePageWindow;

var     bool                        bInitialized;

// GameTypes
var		UWindowLabelControl			GameTypesLabel;
var     UWindowComboControl         GameTypesCombo;
var()   localized string            GameTypesText;
var()   localized string            GameTypesHelp;

// Map Name
var		UWindowLabelControl			MapNameLabel;
var     UWindowEditControl          MapNameEdit;
var()   localized string            MapNameText;
var()   localized string            MapNameHelp;

// Max Ping
var		UWindowLabelControl			MaxPingLabel;
var     UWindowEditControl          MaxPingEdit;
var()   localized string            MaxPingText;
var()   localized string            MaxPingHelp;

// Min Players
var		UWindowLabelControl			MinPlayersLabel;
var     UWindowEditControl          MinPlayersEdit;
var()   localized string            MinPlayersText;
var()   localized string            MinPlayersHelp;

// Max Players
var		UWindowLabelControl			MaxPlayersLabel;
var     UWindowEditControl          MaxPlayersEdit;
var()   localized string            MaxPlayersText;
var()   localized string            MaxPlayersHelp;

// Buddy List
var		UWindowLabelControl			BuddyListLabel;
var     UWindowCheckBox             BuddyListCheck;
var     localized string            BuddyListCheckText;
var     localized string            BuddyListCheckHelp;
var		UDukeBuddyListBox			BuddyList;

// Buddy Edit
var		UWindowLabelControl			NewBuddyLabel;
var     UWindowEditControl          NewBuddyEdit;
var     localized string            NewBuddyEditText;
var     localized string            NewBuddyEditHelp;

// Browser Reference
var     UDukeServerBrowserCW        ServerBrowser;

function Created()
{
    Super.Created();

	// Game Types
	GameTypesLabel = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 1, 1, 1, 1));
	GameTypesLabel.SetText(GameTypesText);
	GameTypesLabel.SetFont(F_Normal);
	GameTypesLabel.Align = TA_Right;

    GameTypesCombo  = UWindowComboControl( CreateControl( class'UWindowComboControl', 1, 1, 1, 1 ) );
	GameTypesCombo.SetButtons( true );
	GameTypesCombo.SetHelpText( GameTypesHelp );
	GameTypesCombo.SetFont( F_Normal );
	GameTypesCombo.SetEditable( false );
	GameTypesCombo.Align = TA_Right;

	// Max Ping
	MaxPingLabel = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 1, 1, 1, 1));
	MaxPingLabel.SetText(MaxPingText);
	MaxPingLabel.SetFont(F_Normal);
	MaxPingLabel.Align = TA_Right;

	MaxPingEdit = UWindowEditControl( CreateControl( class'UWindowEditControl', 1, 1, 1, 1 ) );
	MaxPingEdit.SetHelpText( MaxPingHelp );
	MaxPingEdit.SetFont( F_Normal );
	MaxPingEdit.SetNumericOnly( true );
	MaxPingEdit.SetMaxLength( 4 );
	MaxPingEdit.SetDelayedNotify( true );
	MaxPingEdit.Align = TA_Right;

	// Min Players
	MinPlayersLabel = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 1, 1, 1, 1));
	MinPlayersLabel.SetText(MinPlayersText);
	MinPlayersLabel.SetFont(F_Normal);
	MinPlayersLabel.Align = TA_Right;

	MinPlayersEdit = UWindowEditControl( CreateControl( class'UWindowEditControl', 1, 1, 1, 1 ) );
	MinPlayersEdit.SetHelpText( MinPlayersHelp );
	MinPlayersEdit.SetFont( F_Normal );
	MinPlayersEdit.SetNumericOnly( true );
	MinPlayersEdit.SetMaxLength( 4 );
	MinPlayersEdit.SetDelayedNotify( true );
	MinPlayersEdit.Align = TA_Right;

	// Max Players
	MaxPlayersLabel = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 1, 1, 1, 1));
	MaxPlayersLabel.SetText(MaxPlayersText);
	MaxPlayersLabel.SetFont(F_Normal);
	MaxPlayersLabel.Align = TA_Right;

	MaxPlayersEdit = UWindowEditControl( CreateControl( class'UWindowEditControl', 1, 1, 1, 1 ) );
	MaxPlayersEdit.SetHelpText( MaxPlayersHelp );
	MaxPlayersEdit.SetFont( F_Normal );
	MaxPlayersEdit.SetNumericOnly( true );
	MaxPlayersEdit.SetMaxLength( 4 );
	MaxPlayersEdit.SetDelayedNotify( true );
	MaxPlayersEdit.Align = TA_Right;

	// Map Name
	MapNameLabel = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 1, 1, 1, 1));
	MapNameLabel.SetText(MapNameText);
	MapNameLabel.SetFont(F_Normal);
	MapNameLabel.Align = TA_Right;

	MapNameEdit = UWindowEditControl( CreateControl( class'UWindowEditControl', 1, 1, 1, 1 ) );
	MapNameEdit.SetHelpText( MaxPlayersHelp );
	MapNameEdit.SetFont( F_Normal );
	MapNameEdit.SetNumericOnly( false );
	MapNameEdit.SetMaxLength( 32 );
	MapNameEdit.SetDelayedNotify( true );
	MapNameEdit.Align = TA_Right;

    // Filter checkbox
	BuddyListLabel = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 1, 1, 1, 1));
	BuddyListLabel.SetText(BuddyListCheckText);
	BuddyListLabel.SetFont(F_Normal);
	BuddyListLabel.Align = TA_Right;

    BuddyListCheck = UWindowCheckbox( CreateControl( class'UWindowCheckbox', 1, 1, 1, 1 ) );
	BuddyListCheck.SetHelpText( BuddyListCheckHelp );
	BuddyListCheck.SetFont( F_Normal );
	BuddyListCheck.Align = TA_Right;

	// List box.
	BuddyList = UDukeBuddyListBox( CreateWindow( class'UDukeBuddyListBox', 1, 1, 1, 1 ) );	
	
	// New Buddy.
	NewBuddyLabel = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 1, 1, 1, 1));
	NewBuddyLabel.SetText(NewBuddyEditText);
	NewBuddyLabel.SetFont(F_Normal);
	NewBuddyLabel.Align = TA_Right;

	NewBuddyEdit = UWindowEditControl( CreateControl( class'UWindowEditControl', 1, 1, 1, 1 ) );
	NewBuddyEdit.SetHelpText( NewBuddyEditHelp );
	NewBuddyEdit.SetFont( F_Normal );
	NewBuddyEdit.SetNumericOnly( false );
	NewBuddyEdit.SetMaxLength( 32 );
	NewBuddyEdit.SetDelayedNotify( true );
	NewBuddyEdit.Align = TA_Right;

	ResizeFrames = 3;
}

function BeforePaint( Canvas C, float X, float Y )
{
	local int CenterWidth;
	local int CColLeft, CColRight;
	local float W, W2;

	Super.BeforePaint(C, X, Y);

	if ( ResizeFrames == 0 )
		return;
	ResizeFrames--;

	CenterWidth = (WinWidth/4)*3;
	CColLeft = (WinWidth / 2) - 60;
	CColRight = (WinWidth / 2) - 46;

	GameTypesCombo.SetSize( 200, GameTypesCombo.WinHeight );
	GameTypesCombo.WinLeft = CColRight;
	GameTypesCombo.WinTop = 10;

	GameTypesLabel.AutoSize( C );
	GameTypesLabel.WinLeft = CColLeft - GameTypesLabel.WinWidth;
	GameTypesLabel.WinTop = GameTypesCombo.WinTop + 8;

	MapNameEdit.SetSize( 200, MapNameEdit.WinHeight );
	MapNameEdit.WinLeft = CColRight;
	MapNameEdit.WinTop = GameTypesCombo.WinTop + GameTypesCombo.WinHeight + 5;

	MapNameLabel.AutoSize( C );
	MapNameLabel.WinLeft = CColLeft - MapNameLabel.WinWidth;
	MapNameLabel.WinTop = MapNameEdit.WinTop + 8;

	MinPlayersEdit.SetSize( 50, MinPlayersEdit.WinHeight );
	MinPlayersLabel.AutoSize( C );
	MaxPlayersEdit.SetSize( 50, MaxPlayersEdit.WinHeight );
	MaxPlayersLabel.AutoSize( C );

	MinPlayersEdit.WinTop = MapNameEdit.WinTop + MapNameEdit.WinHeight + 5;
	MinPlayersLabel.WinTop = MinPlayersEdit.WinTop + 8;

	MaxPlayersEdit.WinTop = MinPlayersEdit.WinTop;
	MaxPlayersLabel.WinTop = MaxPlayersEdit.WinTop + 8;

	W = MinPlayersEdit.WinWidth + MinPlayersLabel.WinWidth + 14;
	W2 = MaxPlayersEdit.WinWidth + MaxPlayersLabel.WinWidth + 14;

	MinPlayersLabel.WinLeft = (WinWidth - (W+W2+32))/2;
	MinPlayersEdit.WinLeft = MinPlayersLabel.WinLeft + MinPlayersLabel.WinWidth + 14;

	MaxPlayersLabel.WinLeft = MinPlayersEdit.WinLeft + MinPlayersEdit.WinWidth + 32;
	MaxPlayersEdit.WinLeft = MaxPlayersLabel.WinLeft + MaxPlayersLabel.WinWidth + 14;

	MaxPingEdit.SetSize( 50, MaxPingEdit.WinHeight );
	MaxPingEdit.WinLeft = MinPlayersEdit.WinLeft;
	MaxPingEdit.WinTop = MinPlayersEdit.WinTop + MinPlayersEdit.WinHeight + 5;

	MaxPingLabel.AutoSize( C );
	MaxPingLabel.WinLeft = MinPlayersEdit.WinLeft - 14 - MaxPingLabel.WinWidth;
	MaxPingLabel.WinTop = MaxPingEdit.WinTop + 8;

	BuddyListCheck.SetSize( 32, BuddyListCheck.WinHeight );
	BuddyListCheck.WinLeft = MaxPlayersEdit.WinLeft;
	BuddyListCheck.WinTop = MinPlayersEdit.WinTop + MinPlayersEdit.WinHeight + 5;

	BuddyListLabel.AutoSize( C );
	BuddyListLabel.WinLeft = BuddyListCheck.WinLeft - 14 - BuddyListLabel.WinWidth;
	BuddyListLabel.WinTop = BuddyListCheck.WinTop + 10;

	BuddyList.SetSize( 300, 150 );
	BuddyList.WinLeft = (WinWidth - BuddyList.WinWidth)/2;
	BuddyList.WinTop  = BuddyListCheck.WinTop + BuddyListCheck.WinWidth + 20;

	NewBuddyEdit.SetSize( 200, NewBuddyEdit.WinHeight );
	NewBuddyEdit.WinLeft = CColRight;
	NewBuddyEdit.WinTop = BuddyList.WinTop + BuddyList.WinHeight + 20;

	NewBuddyLabel.AutoSize( C );
	NewBuddyLabel.WinLeft = CColLeft - NewBuddyLabel.WinWidth;
	NewBuddyLabel.WinTop = NewBuddyEdit.WinTop + 8;
}

function Paint( Canvas C, float X, float Y )
{
	Super.Paint( C, X, Y );

	LookAndFeel.Bevel_DrawSimpleBevel( Self, C, BuddyList.WinLeft, BuddyList.WinTop, BuddyList.WinWidth, BuddyList.WinHeight );
}

function DeletedBuddy()
{
	BuildBuddyFilter();
	ServerBrowser.ApplyFilter();
}

function DeleteAllBuddies()
{
	BuddyList.Items.DestroyList();
	BuildBuddyFilter();
	ServerBrowser.ApplyFilter();
}

function InitGameTypesFilter()
{
    local INT i;

    bInitialized = false;
    GameTypesCombo.Clear();

    // Use all the gametypes that have been received so far.
    for ( i=0; i<ArrayCount( ServerBrowser.AllGameTypes ); i++ )
    {
        if( ServerBrowser.AllGameTypes[i] != "" )
        {
            GameTypesCombo.AddItem( ServerBrowser.AllGameTypes[i] );
        }
    }

    GameTypesCombo.SetSelectedIndex( GameTypesCombo.FindItemIndex( ServerBrowser.Filter_GameType ) );
    GameTypesCombo.Sort();
    GameTypesCombo.InsertItem( "All" );
	bInitialized = true;
}

function InitializeFilter()
{    
	local int i;
	
    InitGameTypesFilter();

	if ( ServerBrowser != None )
	{
		MinPlayersEdit.SetValue( string( ServerBrowser.Filter_MinPlayers ) );
		MaxPlayersEdit.SetValue( string( ServerBrowser.Filter_MaxPlayers ) );
		MaxPingEdit.SetValue( string( ServerBrowser.Filter_MaxPing ) );   
		MapNameEdit.SetValue( ServerBrowser.Filter_MapName );   
		
		BuddyListCheck.bChecked = ServerBrowser.Filter_bUseBuddyList;

		for ( i=0; i<ArrayCount( ServerBrowser.Filter_BuddyList ); i++ )
		{
			if ( ServerBrowser.Filter_BuddyList[i] == "" )
			{
				break;
			}
			else
			{
				AddNewBuddy( ServerBrowser.Filter_BuddyList[i], false );
			}
		}
	}
}

function GameTypeChanged()
{
    if ( ServerBrowser != None )
    {
        ServerBrowser.Filter_GameType = GameTypesCombo.GetValue();
        ServerBrowser.ApplyFilter();
    }
}

function MaxPingChanged()
{
    if ( ServerBrowser != None )
    {
        ServerBrowser.Filter_MaxPing = float( MaxPingEdit.GetValue() );
        ServerBrowser.ApplyFilter();
    }
}

function MinPlayersChanged()
{
    if ( ServerBrowser != None )
    {
        ServerBrowser.Filter_MinPlayers = int( MinPlayersEdit.GetValue() );
        ServerBrowser.ApplyFilter();
    }
}

function MaxPlayersChanged()
{
    if ( ServerBrowser != None )
    {
        ServerBrowser.Filter_MaxPlayers = int( MaxPlayersEdit.GetValue() );
        ServerBrowser.ApplyFilter();
    }
}

function MapNameChanged()
{
    if ( ServerBrowser != None )
    {
        ServerBrowser.Filter_MapName = MapNameEdit.GetValue();
        ServerBrowser.ApplyFilter();
    }
}

function AddNewBuddy( string BuddyName, bool updateFilter )
{
	local UDukeBuddyList	NewBuddyItem,l;

	if ( BuddyName == "" )
		return;
	
	// Search for this buddy name already in the list
	L = UDukeBuddyList( BuddyList.Items ).FindName( BuddyName );

	if ( L != None )
	{
		NewBuddyEdit.Clear();
		return;
	}

	NewBuddyItem			= UDukeBuddyList( BuddyList.Items.CreateItem( BuddyList.Items.Class ) );	
	NewBuddyItem.PlayerName = BuddyName;
	
	BuddyList.Items.AppendItem( NewBuddyItem );	
	
	if ( updateFilter )
		BuildBuddyFilter();
}

function NewBuddyEditEnterPressed()
{
	AddNewBuddy( NewBuddyEdit.GetValue(), true );
	NewBuddyEdit.Clear();
	ServerBrowser.ApplyFilter();
}

function BuddyListCheckChanged()
{
	if ( ServerBrowser != None )
	{
		ServerBrowser.Filter_bUseBuddyList = BuddyListCheck.bChecked;
		ServerBrowser.ApplyFilter();
	}
}

function BuildBuddyFilter()
{
	local int				i;
	local UDukeBuddyList	L;

	// Clear old one and rebuild
	for ( i=0; i<ArrayCount( ServerBrowser.Filter_BuddyList ); i++ )
	{
		ServerBrowser.Filter_BuddyList[i] = "";
	}
	
	i = 0;
	for ( L = UDukeBuddyList( BuddyList.Items.Next ); L != None; L = UDukeBuddyList( L.Next ) )
	{
		ServerBrowser.Filter_BuddyList[i] = L.PlayerName;
		i++;
	}

	ServerBrowser.SaveConfig();
}

function Notify( UWindowDialogControl C, byte E )
{
	Super.Notify( C, E );
    
    if ( !bInitialized )
        return;

	switch( E )
	{
        case DE_Change:
            switch ( C )
            {
                case GameTypesCombo:
                    GameTypeChanged();
                    break;
                case MaxPingEdit:
                    MaxPingChanged();
                    break;
                case MaxPlayersEdit:
                    MaxPlayersChanged();
                    break;
                case MinPlayersEdit:
                    MinPlayersChanged();
                    break;
                case MapNameEdit:
                    MapNameChanged();
                    break;
				case BuddyListCheck:
					BuddyListCheckChanged();
            }
			break;
		case DE_EnterPressed:
			switch( C )
			{
				case NewBuddyEdit:
					NewBuddyEditEnterPressed();
					break;
			}
			break;
    }
}

function Close( optional bool bByParent )
{
    Super.Close( bByParent );
}

defaultproperties
{
    GameTypesText="Game Types:"
    GameTypesHelp="Only display servers which are running this game type."    
    MaxPingText="Max Ping:"
    MaxPingHelp="Only display servers with ping less than this value."
    MinPlayersText="Min Players:"
    MinPlayersHelp="Only display servers with at least this many players."
    MaxPlayersText="Max Players:"
    MaxPlayersHelp="Only display servers with at most this many players."
	MapNameText="Map Name:"
	MapNameHelp="Only display servers which are running this map."
	NewBuddyEditText="Add Buddy:"
	NewBuddyEditHelp="Enter the name of a buddy to keep track of."
	BuddyListCheckText="Buddy List:"
	BuddyListCheckHelp="If checked, only servers that contain your buddies will be visible on the server browser."
}