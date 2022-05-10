/*-----------------------------------------------------------------------------
	UDukeServerBrowserCW
	Author: Brandon Reinhart, Scott Alden
-----------------------------------------------------------------------------*/
class UDukeServerBrowserCW expands UDukePageWindow;

// Status info
enum EPingState
{
	PS_QueryServer,
	PS_QueryFailed,
	PS_Pinging,
	PS_RePinging,
	PS_Done
};

// Splitter between the games and the player/rule info
var     UWindowVSplitter            VSplitter;

// Client window for Player/Rule info, should be updated with info from game currently selected
var     UDukeInfoCW                 InfoClient;
var     UDukeServerList			    InfoItem;

var     UWindowLabelControl         StatusLabel;
                                                                        
// Server Grid
var     UDukeServerGrid             Grid;	    		    // Grid to show game info

// Server factories
var     string						serverListClassName;
var     class<UDukeServerList>	    serverListClass;
var     UDukeServerListFactory      serverListFactory;      // Object that goes out and gets server lists (local or dukenet)
var     string                      serverListFactoryType;  // Type of server list factory to create 
var     bool                        serverListQueryDone;    // Set when the current query is completed
var     UDukeServerList			    PingedList;
var     UDukeServerList			    UnpingedList;

var     int                         AutoRefreshTime;        // Automatically refresh time
var     int                         TimeElapsed;            // Amount of time since last refresh

var     bool                        bHadInitialRefresh;     // Set to true on first refresh
var     bool						bNoSort;
var     bool						bPingSuspend;
var     bool						bPingResume;
var     bool						bPingResumeIntial;
var     bool						bSuspendPingOnClose;
var     bool                        bUseFilter;

var		localized string			PlayerCountName;
var		localized string			ServerCountName;
var		localized string			QueryServerText;
var		localized string			QueryFailedText;
var		localized string			PingingText;
var		localized string			CompleteText;
var		localized string			ShownText;
var		localized string			FilterText;

var     string				        URLAppend;
var     EPingState                  PingState;
var     string                      ErrorString;
var     config bool					bNoAutoSort;
var     bool						bShowFailedServers;
var     config string               AllGameTypes[64];
var     class<UDukeRightClickMenu>  RightClickMenuClass;
var     UDukeServerFilterCW         ServerFilter;

// Server filter strings and ints
var		config string				Filter_GameType;
var		config int					Filter_MaxPing;
var		config int					Filter_MaxPlayers;
var		config int					Filter_MinPlayers;
var		config string				Filter_MapName;
var		config string				Filter_BuddyList[32];
var     config bool                 Filter_bUseBuddyList;

function Created()
{
    Super.Created();

	serverListClass = class<UDukeServerList>( DynamicLoadObject( serverListClassName, class'Class' ) );

	// Splitter
	VSplitter = UWindowVSplitter( CreateWindow( class'UWindowVSplitter', 0, 0, WinWidth, WinHeight ) );

    // Server Grid
	Grid = UDukeServerGrid( VSplitter.CreateWindow( class'UDukeServerGrid', 0, 0, WinWidth, WinHeight / 2, self ) );
    Grid.SetAcceptsFocus();

    // Info about a game.  It's a split window with information about the players and rules in a game.
	InfoClient = UDukeInfoCW( VSplitter.CreateWindow( class'UDukeInfoCW', 0, 0, WinWidth, WinHeight / 2, self ) );

    // Browser Grids
	VSplitter.TopClientWindow    = Grid;
	VSplitter.BottomClientWindow = InfoClient;
	VSplitter.SplitPos           = ( Grid.WinHeight + InfoClient.WinHeight ) * 0.5;
	VSplitter.MinWinHeight       = 50;
	VSplitter.bSizable           = true;
}

function GetServerListFactoryType()
{
    local UDukeJoinMultiSC myParent;

    myParent = UDukeJoinMultiSC( GetParent( class'UDukeJoinMultiSC' ) );

    if ( myParent == None )
    {
        Log( "Could not find parent UDukeJoinMultiSC for GetServerListFactoryType()" );
        return;
    }

    serverListFactoryType  = myParent.serverListFactoryType;
}

function Resized()
{
	Super.Resized();

    Grid.SetSize( WinWidth, WinHeight / 2 );
    InfoClient.SetSize( WinWidth, WinHeight / 2 );
    
    VSplitter.SetSize( WinWidth, WinHeight );
    VSplitter.SplitPos = ( Grid.WinHeight + InfoClient.WinHeight ) * 0.5;
}

function ShowInfoArea( bool bShow )
{    
	if ( bShow )
	{
		VSplitter.ShowWindow();
		VSplitter.SetSize( WinWidth, WinHeight );
		Grid.SetParent( VSplitter );
		InfoClient.SetParent( VSplitter );
		VSplitter.TopClientWindow       = Grid;
		VSplitter.BottomClientWindow    = InfoClient;
	}
	else
	{
		VSplitter.HideWindow();
		VSplitter.TopClientWindow       = None;
		VSplitter.BottomClientWindow    = None;		
		Grid.SetParent( Self );
		Grid.SetSize( WinWidth, WinHeight );
	}
}

function TagServersAsOld()
{
	local UDukeServerList l;

	for (l = UDukeServerList( PingedList.Next ); l != None; l = UDukeServerList( l.Next ) ) 
		l.bOldServer = true;
}

function RemoveOldServers()
{
	local UDukeServerList l, n;

	l = UDukeServerList( PingedList.Next );

	while ( l != None ) 
	{
		n = UDukeServerList( l.Next );

		if ( l.bOldServer )
		{
			if ( Grid.SelectedServer == l )
				Grid.SelectedServer = n;

			l.Remove();
		}
		l = n;
	}
}

function ClearInfo()
{
	InfoItem                = None;
	InfoClient.Server       = None;
}

function ShowInfo( UDukeServerList I  )
{
	if ( I == None ) 
        return;
	
    ShowInfoArea( true );

	InfoItem                = I;
	InfoClient.Server       = InfoItem;	
	I.ServerStatus();
}

function AutoInfo( UDukeServerList I )
{
	ShowInfo( I );
}

function QueryFinished( UDukeServerListFactory Fact, bool bSuccess, optional string ErrorMsg )
{
	local int i;
	local bool bDone;

    serverlistQueryDone = true;

	if ( !bSuccess )
	{
		PingState   = PS_QueryFailed;
		ErrorString = ErrorMsg;

		// don't ping and report success if we have no servers.
		if ( UnpingedList.Count() == 0)
		{
			return;
		}
	}
	else
    {
		ErrorString = "";
    }

	RemoveOldServers();

	PingState = PS_Pinging;

	if( !bNoSort && !Fact.bIncrementalPing )
    {
		PingedList.Sort();
    }

	UnpingedList.PingServers( true, bNoSort || Fact.bIncrementalPing );
}

function ResumePinging()
{
	if ( !bHadInitialRefresh )
    {
		Refresh( false, true );	
    }

	bPingSuspend = false;

	if ( bPingResume )
	{
		bPingResume = false;
		UnpingedList.PingNext( bPingResumeIntial, bNoSort );
	}
}

function SuspendPinging()
{
	if( bSuspendPingOnClose )
		bPingSuspend = true;
}

function PingFinished()
{
	PingState = PS_Done;

    // Ping is finished, fill the combo box with all the different game types
    BuildGameTypes();
}

function RePing()
{
	PingState = PS_RePinging;
	PingedList.InvalidatePings();
	PingedList.PingServers( true, false );
}

function TestList()
{
    local int				i,j;
    local string			gametype;
    local UDukeServerList	NewListEntry;
	local UDukePlayerList	PlayerEntry;
    local string			mapnames[10];
    local string			gamenames[10];
	local string			playernames[10];

    mapnames[0] = "Fish";
    mapnames[1] = "Apple";
    mapnames[2] = "Train";
    mapnames[3] = "Mini";
    mapnames[4] = "Me";
    mapnames[5] = "Evil";
    mapnames[6] = "Duke";
    mapnames[7] = "Proton";
    mapnames[8] = "Loser";
    mapnames[9] = "Shit";

    gamenames[0] = "Deathmatch";
    gamenames[1] = "CTF";
    gamenames[2] = "Assault";
    gamenames[3] = "War";
    gamenames[4] = "Lame";
    gamenames[5] = "FFA";
    gamenames[6] = "Team";
    gamenames[7] = "Counterstrike";
    gamenames[8] = "DoD";
    gamenames[9] = "Shack";

	playernames[0] = "Joe";
	playernames[1] = "Scott";
	playernames[2] = "Brandon";
	playernames[3] = "Nick";
	playernames[4] = "Jess";
	playernames[5] = "George";
	playernames[6] = "Tim";
	playernames[7] = "John";
	playernames[8] = "Andy";
	playernames[9] = "Ruben";

    for ( i=0; i<100; i++ )
    {
        if ( ( i % 10 ) == 0 )
        {
            GameType = gamenames[rand(10)];
        }

    	// Add it to the server list(s)
		NewListEntry = UDukeServerList( PingedList.CreateItem( PingedList.Class ) );

		NewListEntry.IP             = "192.168.1.112";
		NewListEntry.QueryPort      = 7777;
		NewListEntry.Ping           = rand(9999);	
		NewListEntry.Category       = "TestCat";
		NewListEntry.GameName       = "TestGameName";
		NewListEntry.bLocalServer   = False;
	    NewListEntry.HostName       = NewListEntry.IP;
        NewListEntry.GameType       = gametype;
        NewListEntry.MapName        = mapnames[rand(10)];
        NewListEntry.MapName        = mapnames[rand(10)];
        NewListEntry.MapDisplayName = NewListEntry.MapName;
        NewListEntry.MaxPlayers     = rand(64);
        NewListEntry.NumPlayers     = Min( rand(64), NewListEntry.MaxPlayers );
		
		NewListEntry.PlayerList		= New(None) class'UDukePlayerList';
		NewListEntry.PlayerList.SetupSentinel();	

		for( j=0; j<NewListEntry.NumPlayers; j++ )
		{
			PlayerEntry = UDukePlayerList( NewListEntry.PlayerList.Append( class'UDukePlayerList' ) );
			PlayerEntry.PlayerID = j;
			PlayerEntry.PlayerName = playernames[rand(10)];
			if ( rand(100) == 0 )
			{
				PlayerEntry.PlayerName = "Zippy";
			}
		}
		PingedList.AppendItem( NewListEntry );
    }
    BuildGameTypes();
}

function bool CheckGameType( UDukeServerList l )
{
    local int i;

    if ( l.GameType == "" )
    {
        return false;
    }

    for ( i=0; i<ArrayCount( AllGameTypes ); i++ )
    {
        if ( AllGameTypes[i] == "" )
        {
            // New Gametype Found, add it to the list
            AllGameTypes[i] = l.GameType;
            return true;
            break;
        }

        if ( l.GameType == AllGameTypes[i] )
        {
            // Found the type already... skip to next one
            break;
        }
    }

    return false;
}

function BuildGameTypes( optional UDukeServerList newServer )
{
    local UDukeServerList   l;
    local bool              NewGameTypeFound;    

    if ( newServer != None )
    {
        NewGameTypeFound = CheckGameType( newServer );
    }
    else
    {
        // Check all the servers for new gametypes and add them to the array.
        for ( l = UDukeServerList( PingedList.Next ); l != None; l = UDukeServerList( l.Next ) ) 
        {
            NewGameTypeFound = CheckGameType( l );
        }
    }

    if ( ServerFilter != None )
    {
        ServerFilter.InitGameTypesFilter();
    }

    // Save the config if we got a new entry
    if ( NewGameTypeFound )
    {
        SaveConfigs();
    }
}

function UpdateFilters( UDukeServerList newServer )
{
    if ( ServerFilter == None )
    {
        return;
    }
    
    // Update the filter selections boxes based on this server's new values
    BuildGameTypes( newServer );
}

function ApplyFilter()
{
    local UDukeServerList	l, NewItem, Swap;
	local UDukePlayerList	p;
    local string			type, BuddyName;
	local int				i;

    SaveConfig();

    if ( PingedList == None )
    {
        return;
    }

    // Take any servers that match the filter and put it on the pinged list.
    for ( l = UDukeServerList( PingedList.Next ); l != None; l = UDukeServerList( l.Next ) )
    {       
        l.bHidden = false;

        if ( !bUseFilter )
            continue;

        if ( ( Filter_GameType != "" ) && ( Filter_GameType != "All" ) )
        {
            if ( l.GameType != Filter_GameType )
            {
                l.bHidden = true;
                continue;
            }
        }

        if ( Filter_MaxPing > 0 )
        {
            if ( l.Ping > Filter_MaxPing )
            {
                l.bHidden = true;
                continue;
            }
        }

        if ( Filter_MinPlayers > 0 )
        {
            if ( l.numPlayers < Filter_MinPlayers )
            {
                l.bHidden = true;
                continue;
            }
        }

        if ( Filter_MaxPlayers > 0 )
        {
            if ( l.numPlayers > Filter_MaxPlayers )
            {
                l.bHidden = true;
                continue;
            }
        }

		// Go through the buddy list and find any matching players
		if ( Filter_bUseBuddyList )
		{
			for ( i=0; i<ArrayCount(Filter_BuddyList); i++ )
			{
				BuddyName = Filter_BuddyList[i];
				
				if ( BuddyName == "" )
					break;

				l.bHidden = true; // Assume there's no match with this list

				if ( l.PlayerList != None )
				{				
					// Loop through the server's player list
					p = l.PlayerList;

					for ( p = UDukePlayerList( p.Next ); p != None; p = UDukePlayerList( p.Next ) )
					{

						if ( p.PlayerName ~= BuddyName )
						{
							l.bHidden = false; // Found a player match
							break;
						}
					}

					if ( l.bHidden == false ) // Found a buddy already
					{
						break;
					}
				}
				else
				{
					break; // No player list for this server
				}
			}
		}
    }

	// Check to see if the server grid's selected server has been hidden and fixup stuff
	if ( Grid.SelectedServer.bHidden )
	{
		ClearInfo();
		Grid.SelectedServer = None;
	}

    PingedList.UpdateShownCount();
}

function Query(optional bool bBySuperset, optional bool bInitial, optional bool bInNoSort)
{
	bNoSort = bInNoSort;

    if ( serverListFactory != None )
    {
        serverListFactory.Query( bBySuperSet, bInitial );
    }
}

function Refresh( optional bool bBySuperset, optional bool bInitial, optional bool bSaveExistingList, optional bool bInNoSort )
{
	bHadInitialRefresh = true;

	if ( !bSaveExistingList )
	{
		InfoItem = None;
		InfoClient.Server = None;
	}

	if ( !bSaveExistingList && PingedList != None )
	{
		PingedList.DestroyList();
		PingedList = None;
		Grid.SelectedServer = None;
	}

	if ( PingedList == None )
	{
		PingedList=New ServerListClass;
		PingedList.Owner = Self;
		PingedList.SetupSentinel(true);
		PingedList.bSuspendableSort = true;
	}
	else
	{
		TagServersAsOld();
	}

	if ( UnpingedList != None )
    {
		UnpingedList.DestroyList();
    }
	
	if ( !bSaveExistingList )
	{
		UnpingedList = New ServerListClass;
		UnpingedList.Owner = Self;
		UnpingedList.SetupSentinel(false);
	}

    // Set the PS state to Query mode
	PingState = PS_QueryServer;
	
    // Shutdown all factories that are out getting servers
    ShutdownFactories( bBySuperset );
	
    // Re-create the server factories
    CreateFactories( bSaveExistingList );
	
    // Do the query
    Query( bBySuperset, bInitial, bInNoSort );
}

function CreateFactories( bool bUsePingedList )
{   
    GetServerListFactoryType();

    serverListFactory = UDukeServerListFactory( BuildObjectWithProperties( serverListFactoryType ) );

    if ( serverListFactory == None )
    {
        Log( "Could not create ServerFactory" @ serverListFactoryType );
        return;
    }

    serverListFactory.PingedList    = PingedList;
    serverListFactory.UnpingedList  = UnpingedList;
    
    if ( bUsePingedList )
        serverListFactory.Owner     = PingedList;
    else
        serverListFactory.Owner     = UnpingedList;

    serverListQueryDone = false;
}

function ShutdownFactories(optional bool bBySuperset)
{
	local int i;

	if ( serverListFactory != None )
    {
	    serverListFactory.Shutdown( bBySuperset );
	    serverListFactory = None;
    }
}

function WindowShown()
{
	Super.WindowShown();

    InfoClient.SetParent( VSplitter );
	InfoClient.Server   = InfoItem;

	ResumePinging();
}

function Notify(UWindowDialogControl C, byte E)
{
    Super.Notify( C, E );
}

function BeforePaint( Canvas C, float X, float Y )
{
	local EPingState            P;
	local string                E;
	local int                   PercentComplete;
	local int                   TotalReturnedServers;
	local int                   TotalServers;
	local int                   PingedServers;
	local int                   MyServers;
    local int                   ShownServers;
	local string                SBText;

    Super.BeforePaint( C, X, Y );

	P = PingState;

    if ( P == PS_QueryServer )
		TotalReturnedServers = UnpingedList.Count();

    if ( P == PS_RePinging ) // Repinging, just used numbers from PingedList
    {
        PingedServers   = PingedList.PingedCount();
        TotalServers    = PingedList.Count();
        MyServers       = TotalServers;
    }
    else
    {
	    PingedServers   = PingedList.Count();
    	TotalServers    = UnpingedList.Count() + PingedServers;
	    MyServers       = PingedList.Count();
        ShownServers    = PingedList.ShownCount;
    }

	E = ErrorString;

	if ( TotalServers > 0 )
    {
		PercentComplete = PingedServers * 100.0 / TotalServers;
    }

	switch(P)
	{
	case PS_QueryServer:
		if ( TotalReturnedServers > 0 )
			SBText = QueryServerText$" ("$TotalReturnedServers$" "$ServerCountName$")";
		else
			SBText = QueryServerText;
		break;
	case PS_QueryFailed:
		SBText = E;
		break;
	case PS_Pinging:
	case PS_RePinging:
		SBText = PingingText$" "$PercentComplete$"% "$CompleteText$". "$MyServers$" "$ServerCountName$", "$PingedList.TotalPlayers$" "$PlayerCountName;
		break;
	case PS_Done:
        if ( bUseFilter )
            SBText = FilterText;
		SBText = SBText @ MyServers$" "$ServerCountName$" ("$ShownServers@ShownText$"), "$PingedList.TotalPlayers$" "$PlayerCountName;
		break;
	}

    StatusLabel.SetText( SBText );
}


function Paint( Canvas C, float X, float Y )
{
	local float fDraw_X;
	local color colorOld;

	Super.Paint( C, X, Y );
}

function Tick( float Delta )
{
	PingedList.Tick( Delta );

	if ( PingedList.bNeedUpdateCount )
	{
		PingedList.UpdateServerCount();
		PingedList.bNeedUpdateCount = false;
	}

	// AutoRefresh local servers
	if( AutoRefreshTime > 0 )
	{
		TimeElapsed += Delta;
		
		if( TimeElapsed > AutoRefreshTime )
		{
			TimeElapsed = 0;
			Refresh( ,,true, bNoAutoSort );
		}
	}	
}

function AddFavorite( UDukeServerList I )
{

}

defaultproperties
{
    bBuildDefaultButtons=false
    serverListClassName="dnWindow.UDukeServerList"     
    bNoScanLines=true
    bNoClientTexture=true
	PlayerCountName="Players"
	ServerCountName="Servers"
	QueryServerText="Querying master server"
	QueryFailedText="Master Server Failed: "
	PingingText="Pinging Servers"
	CompleteText="Complete"
    ShownText="Shown"
    FilterText="(Filters on)"
    RightClickMenuClass=class'UDukeRightClickMenu'
    bUseFilter=true
}
