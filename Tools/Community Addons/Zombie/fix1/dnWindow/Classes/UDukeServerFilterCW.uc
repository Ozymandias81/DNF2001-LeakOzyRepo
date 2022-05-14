class UDukeServerFilterCW extends UDukePageWindow;

var     bool                        bInitialized;

// GameTypes
var     UWindowComboControl         GameTypesCombo;
var()   localized string            GameTypesText;
var()   localized string            GameTypesHelp;

// Map Name
var     UWindowEditControl          MapNameEdit;
var()   localized string            MapNameText;
var()   localized string            MapNameHelp;

// Max Ping
var     UWindowEditControl          MaxPingEdit;
var()   localized string            MaxPingText;
var()   localized string            MaxPingHelp;

// Min Players
var     UWindowEditControl          MinPlayersEdit;
var()   localized string            MinPlayersText;
var()   localized string            MinPlayersHelp;

// Max Players
var     UWindowEditControl          MaxPlayersEdit;
var()   localized string            MaxPlayersText;
var()   localized string            MaxPlayersHelp;

// Buddy List
var     UWindowCheckBox             BuddyListCheck;
var     localized string            BuddyListCheckText;
var     localized string            BuddyListCheckHelp;

var		UDukeBuddyListBox			BuddyList;

var     UWindowEditControl          NewBuddyEdit;
var     localized string            NewBuddyEditText;
var     localized string            NewBuddyEditHelp;

var     UDukeServerBrowserCW        ServerBrowser;

function Created()
{
	local int ControlWidth, ControlHeight, XLOffset, XROffset, YLOffset, YROffset;
	local int CenterWidth, CenterPos, ButtonWidth, ButtonLeft;

    Super.Created();

	ControlWidth    = WinWidth/2.5;
	ControlHeight   = 15;
	YLOffset        = 15;
	XLOffset        = ( WinWidth/2 - ControlWidth )/2;
	XROffset        = WinWidth/2 + XLOffset;

	CenterWidth     = ( WinWidth/4 )*3;
	CenterPos       = ( WinWidth - CenterWidth )/2;

	ButtonWidth     = WinWidth - 140;
	ButtonLeft      = WinWidth - ButtonWidth - 40;

    GameTypesCombo  = UWindowComboControl( CreateControl( class'UWindowComboControl', 
					   									  XLOffset, YLOffset, 
														  ControlWidth, ControlHeight
								                        )
	                                     );

	GameTypesCombo.SetButtons( true );
	GameTypesCombo.SetText( GameTypesText );
	GameTypesCombo.SetHelpText( GameTypesHelp );
	GameTypesCombo.SetFont( F_Normal );
	GameTypesCombo.SetEditable( false );
	GameTypesCombo.EditBoxWidth = ControlWidth * 0.666666;	    

    YLOffset        += ControlHeight + 5;

	MaxPingEdit = UWindowEditControl( CreateControl( class'UWindowEditControl', XLOffset, YLOffset, ControlWidth, 1 ) );
	MaxPingEdit.SetText( MaxPingText );
	MaxPingEdit.SetHelpText( MaxPingHelp );
	MaxPingEdit.SetFont( F_Normal );
	MaxPingEdit.SetNumericOnly( true );
	MaxPingEdit.SetMaxLength( 4 );
	MaxPingEdit.SetDelayedNotify( true );

    YLOffset        += ControlHeight + 5;

	MinPlayersEdit = UWindowEditControl( CreateControl( class'UWindowEditControl', XLOffset, YLOffset, ControlWidth, 1 ) );
	MinPlayersEdit.SetText( MinPlayersText );
	MinPlayersEdit.SetHelpText( MinPlayersHelp );
	MinPlayersEdit.SetFont( F_Normal );
	MinPlayersEdit.SetNumericOnly( true );
	MinPlayersEdit.SetMaxLength( 4 );
	MinPlayersEdit.SetDelayedNotify( true );

    YLOffset        += ControlHeight + 5;

	MaxPlayersEdit = UWindowEditControl( CreateControl( class'UWindowEditControl', XLOffset, YLOffset, ControlWidth, 1 ) );
	MaxPlayersEdit.SetText( MaxPlayersText );
	MaxPlayersEdit.SetHelpText( MaxPlayersHelp );
	MaxPlayersEdit.SetFont( F_Normal );
	MaxPlayersEdit.SetNumericOnly( true );
	MaxPlayersEdit.SetMaxLength( 4 );
	MaxPlayersEdit.SetDelayedNotify( true );

	YLOffset        += ControlHeight + 5;

	MapNameEdit = UWindowEditControl( CreateControl( class'UWindowEditControl', XLOffset, YLOffset, ControlWidth, ControlHeight ) );
	MapNameEdit.SetText( MaxPlayersText );
	MapNameEdit.SetHelpText( MaxPlayersHelp );
	MapNameEdit.SetFont( F_Normal );
	MapNameEdit.SetNumericOnly( false );
	MapNameEdit.SetMaxLength( 32 );
	MapNameEdit.SetDelayedNotify( true );

	// Right hand side
	YROffset = 15;
	
    // Filter checkbox
    BuddyListCheck = UWindowCheckbox( CreateControl( class'UWindowCheckbox', XROffset, YROffset, ControlWidth, ControlHeight ) );
	BuddyListCheck.SetText( BuddyListCheckText );
	BuddyListCheck.SetHelpText( BuddyListCheckHelp );
	BuddyListCheck.SetFont( F_Normal );
	BuddyListCheck.Align = TA_Left;

	YROffset += ControlHeight + 5;
	
	BuddyList = UDukeBuddyListBox( CreateWindow( class'UDukeBuddyListBox', XROffset, YROffset, 100, 200 ) );	
	
	YROffset += BuddyList.WinHeight + 5;

	NewBuddyEdit = UWindowEditControl( CreateControl( class'UWindowEditControl', XLOffset, YROffset, ControlWidth, 1 ) );
	NewBuddyEdit.SetText( NewBuddyEditText );
	NewBuddyEdit.SetHelpText( NewBuddyEditHelp );
	NewBuddyEdit.SetFont( F_Normal );
	NewBuddyEdit.SetNumericOnly( false );
	NewBuddyEdit.SetMaxLength( 32 );
	NewBuddyEdit.SetDelayedNotify( true );

	YROffset = BuddyList.WinHeight + 15;
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


function Paint(Canvas C, float X, float Y)
{
}

function BeforePaint( Canvas C, float X, float Y )
{
    local INT iHalfWidth;
	local INT XLOffset, XROffset, YLOffset, YROffset;
	local INT ControlWidth, ControlHeight;

	ControlWidth    = WinWidth/2.5;
	XLOffset        = ( WinWidth/2 - ControlWidth )/2;
	XROffset        = WinWidth/2 + XLOffset;	
	YLOffset        = 15;
	YROffset        = 15;
	ControlHeight   = 15;

    GameTypesCombo.SetSize( ControlWidth, ControlHeight );
    GameTypesCombo.EditBoxWidth = GameTypesCombo.WinWidth * 0.666666;
    GameTypesCombo.WinLeft      = XLOffset;
	GameTypesCombo.WinTop       = YLOffset;
	YLOffset += ControlHeight + 10;

    MaxPingEdit.SetSize( ControlWidth, ControlHeight );
    MaxPingEdit.WinLeft = XLOffset;
	MaxPingEdit.WinTop  = YLOffset;
	YLOffset += ControlHeight + 10;

    MaxPlayersEdit.SetSize( ControlWidth, ControlHeight );
    MaxPlayersEdit.WinLeft = XLOffset;
	MaxPlayersEdit.WinTop  = YLOffset;
	YLOffset += ControlHeight + 10;

    MinPlayersEdit.SetSize( ControlWidth, ControlHeight );
    MinPlayersEdit.WinLeft = XLOffset;
	MinPlayersEdit.WinTop  = YLOffset;
	YLOffset += ControlHeight + 10;

    MapNameEdit.SetSize( ControlWidth, ControlHeight );
    MapNameEdit.WinLeft = XLOffset;
	MapNameEdit.WinTop  = YLOffset;
	YLOffset += ControlHeight + 10;

	// Right hand side
	YROffset = 15;

	BuddyListCheck.SetSize( ControlWidth, ControlHeight );
	BuddyListCheck.WinLeft = XROffset;
	BuddyListCheck.WinTop  = YROffset;

	YROffset += ControlHeight + 10;

	BuddyList.SetSize( ControlWidth, 200 );
	BuddyList.WinLeft = XROffset;
	BuddyList.WinTop  = YROffset;

	YRoffset += BuddyList.WinHeight + 10;

	NewBuddyEdit.SetSize( ControlWidth, ControlHeight );
	NewBuddyEdit.WinLeft = XROffset;
	NewBuddyEdit.WinTop  = YROffset;
}

defaultproperties
{
     GameTypesText="Game Types"
     GameTypesHelp="Only display servers which are running this game type."
     MapNameText="Map Name"
     MapNameHelp="Only display servers which are running this map."
     MaxPingText="Max Ping Time"
     MaxPingHelp="Only display servers with ping less than this value."
     MinPlayersText="Min Players"
     MinPlayersHelp="Only display servers with at least this many players."
     MaxPlayersText="Max Players"
     MaxPlayersHelp="Only display servers with at most this many players."
     BuddyListCheckText="Buddy List Active"
     BuddyListCheckHelp="If checked, only servers that contain your buddies will be visible on the server browser."
     NewBuddyEditText="Add New Buddy"
     NewBuddyEditHelp="Enter the name of a buddy to keep track of"
     bBuildDefaultButtons=False
     bNoScanLines=True
     bNoClientTexture=True
}
