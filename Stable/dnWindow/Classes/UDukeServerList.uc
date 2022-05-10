//=============================================================================
// UDukeServerList
//=============================================================================

class UDukeServerList extends UWindowList;

// Valid for sentinel only
var	UDukeServerBrowserCW        Owner;
var int					        TotalServers;
var int					        TotalPlayers;
var int					        TotalMaxPlayers;
var bool				        bNeedUpdateCount;

// Config
var config int			        MaxSimultaneousPing;

// Master server variables
var string				        IP;
var int					        QueryPort;
var string				        Category;		// Master server categorization
var string				        GameName;		// Unreal, Unreal Tournament
                                
// State of the ping            
var UDukeServerPing	            ServerPing;
var bool				        bPinging;
var bool				        bPingFailed;
var bool				        bPinged;
var bool				        bNoInitalPing;
var bool				        bOldServer;
var bool                        bHidden;
                                
// Rules and Lists              
var UDukeRulesList	            RulesList;
var UDukePlayerList             PlayerList;
var bool				        bKeepDescription;	// don't overwrite HostName

// Unreal server variables
var bool			        	bLocalServer;
var float			        	Ping;
var string			        	HostName;
var int				        	GamePort;
var string			        	MapName;
var string			        	MapTitle;
var string			        	MapDisplayName;
var string			        	GameType;
var string			        	GameMode;
var int				        	NumPlayers;
var int				        	MaxPlayers;
var int				        	GameVer;
var int				        	MinNetVer;

var int                         ShownCount;

function DestroyListItem() 
{
	Owner = None;

	if ( ServerPing != None )
	{
		ServerPing.Destroy();
		ServerPing = None;
	}
	Super.DestroyListItem();
}

function QueryFinished( UDukeServerListFactory Fact, bool bSuccess, optional string ErrorMsg )
{
	Owner.QueryFinished( Fact, bSuccess, ErrorMsg );
}


// Functions for server list entries only.
function PingServer( bool bInitial, bool bJustThisServer, bool bNoSort )
{
	// Create the UdpLink to ping the server
	ServerPing = GetPlayerOwner().GetEntryLevel().Spawn( class'UDukeServerPing' );
	ServerPing.Server           = Self;
	ServerPing.StartQuery( 'GetInfo', 2 );
	ServerPing.bInitial         = bInitial;
	ServerPing.bJustThisServer  = bJustThisServer;
	ServerPing.bNoSort          = bNoSort;
	bPinging                    = true;
}

function ServerStatus()
{
	// Create the UdpLink to ping the server
	ServerPing          = GetPlayerOwner().GetEntryLevel().Spawn( class'UDukeServerPing' );
	ServerPing.Server   = Self;
	ServerPing.StartQuery( 'GetStatus', 2 );
	bPinging            = true;
}

function StatusDone( bool bSuccess )
{
	// Destroy the UdpLink
	ServerPing.Destroy();
	ServerPing = None;

	bPinging = false;

	RulesList.SortByColumn( RulesList.SortColumn );
	PlayerList.SortByColumn( PlayerList.SortColumn );
}

function CancelPing()
{
	if( bPinging && ServerPing != None && ServerPing.bJustThisServer )
		PingDone( false, true, false, true );
}

function PingDone( bool bInitial, bool bJustThisServer, bool bSuccess, bool bNoSort )
{
	local UDukeServerBrowserCW      W;
	local UDukeServerList           OldSentinel;

	// Destroy the UdpLink
	if ( ServerPing != None )
    {
		ServerPing.Destroy();
    }
	
	ServerPing  = None;
	
    bPinging    = false;
	bPingFailed = !bSuccess;
	bPinged     = true;

	OldSentinel = UDukeServerList( Sentinel );

	if ( !bNoSort )
	{
		Remove();

		// Move to the ping list
		if ( !bPingFailed || ( OldSentinel != None && OldSentinel.Owner != None && OldSentinel.Owner.bShowFailedServers ) )
		{
			if ( OldSentinel.Owner.PingedList != None )
            {   
				OldSentinel.Owner.PingedList.AppendItem( Self );
                OldSentinel.Owner.UpdateFilters( self );
            }
		}
	}
	else
	{
		if ( OldSentinel != None && OldSentinel.Owner != None && OldSentinel != OldSentinel.Owner.PingedList )
        {
			Log( "Unsorted PingDone lost as it's not in ping list!" );
        }
	}

	if ( Sentinel != None )
	{
		UDukeServerList( Sentinel ).bNeedUpdateCount = true;
	}

	if ( !bJustThisServer )
    {
		if ( OldSentinel != None )
		{
			W = OldSentinel.Owner;

			if( W.bPingSuspend )
			{
				W.bPingResume = true;
				W.bPingResumeIntial = bInitial;
			}
			else
            {
				OldSentinel.PingNext(bInitial, bNoSort);
            }
		}
    }
}

// Functions for sentinel only

function InvalidatePings()
{
	local UDukeServerList l;

	for( l = UDukeServerList( Next ); l != None; l = UDukeServerList( l.Next ) )
    {
        if ( !l.bHidden ) // Only invalidate unhidden pings
    		l.Ping = 9999;
    }
}

function PingServers( bool bInitial, bool bNoSort )
{
	local UDukeServerList l;
	
	bPinging = false;

	for( l = UDukeServerList( Next ); l != None; l = UDukeServerList( l.Next ) ) 
	{
        if ( !l.bHidden )
        {
    		l.bPinging      = false;
	    	l.bPingFailed   = false;
		    l.bPinged       = false;
        }
	}

	PingNext( bInitial, bNoSort );
}

function PingNext( bool bInitial, bool bNoSort )
{
	local int TotalPinging;
	local UDukeServerList l;
	local bool bDone;
	
	TotalPinging = 0;
	
	bDone = true;
	for ( l = UDukeServerList( Next ); l != None; l = UDukeServerList( l.Next ) ) 
	{
		if ( !l.bPinged )
			bDone = false;

		if ( l.bPinging )
			TotalPinging++;
	}
	
	if ( bDone && Owner != None )
	{
		bPinging = false;
		Owner.PingFinished();
	}
	else if ( TotalPinging < MaxSimultaneousPing )
	{
		for ( l = UDukeServerList( Next ); l != None; l = UDukeServerList( l.Next ) )
		{
			if ( !l.bHidden && 
                 !l.bPinging &&
				 !l.bPinged  &&
                 ( !bInitial || !l.bNoInitalPing ) &&
                 TotalPinging < MaxSimultaneousPing
			   )
			{
				TotalPinging++;
				l.PingServer( bInitial, false, bNoSort );
			}

			if( TotalPinging >= MaxSimultaneousPing )
				break;
		}
	}
}

function UDukeServerList FindExistingServer( string FindIP, int FindQueryPort )
{
	local UWindowList l;

	for( l = Next;l != None;l = l.Next )
	{
		if( UDukeServerList(l).IP == FindIP && UDukeServerList(l).QueryPort == FindQueryPort )
        {
			return UDukeServerList(l);
        }
	}
	return None;
}

function PlayerPawn GetPlayerOwner()
{
	return UDukeServerList( Sentinel ).Owner.GetPlayerOwner();
}

function UWindowList CopyExistingListItem( Class<UWindowList> ItemClass, UWindowList SourceItem )
{
	local UDukeServerList L;

	L = UDukeServerList( Super.CopyExistingListItem( ItemClass, SourceItem ) );

	L.bLocalServer	    = UDukeServerList(SourceItem).bLocalServer;
	L.IP			    = UDukeServerList(SourceItem).IP;
	L.QueryPort		    = UDukeServerList(SourceItem).QueryPort;
	L.Ping			    = UDukeServerList(SourceItem).Ping;
	L.HostName		    = UDukeServerList(SourceItem).HostName;
	L.GamePort		    = UDukeServerList(SourceItem).GamePort;
	L.MapName		    = UDukeServerList(SourceItem).MapName;
	L.MapTitle		    = UDukeServerList(SourceItem).MapTitle;
	L.MapDisplayName    = UDukeServerList(SourceItem).MapDisplayName;
	L.MapName		    = UDukeServerList(SourceItem).MapName;
	L.GameType		    = UDukeServerList(SourceItem).GameType;
	L.GameMode		    = UDukeServerList(SourceItem).GameMode;
	L.NumPlayers	    = UDukeServerList(SourceItem).NumPlayers;
	L.MaxPlayers	    = UDukeServerList(SourceItem).MaxPlayers;
	L.GameVer		    = UDukeServerList(SourceItem).GameVer;
	L.MinNetVer		    = UDukeServerList(SourceItem).MinNetVer;
	L.bKeepDescription  = UDukeServerList(SourceItem).bKeepDescription;

	return L;
}

function int Compare( UWindowList T, UWindowList B )
{
	CompareCount++;
	return UDukeServerList( Sentinel ).Owner.Grid.Compare( UDukeServerList( T ), UDukeServerList( B ) );
}

function AppendItem( UWindowList L )
{
	Super.AppendItem( L );
	UDukeServerList( Sentinel ).bNeedUpdateCount = true;
}

function Remove()
{
	local UDukeServerList S;

	S = UDukeServerList( Sentinel );
	Super.Remove();

	if ( S != None )
		S.bNeedUpdateCount = true;
}

// Sentinel only
// FIXME: slow when lots of servers!!
function UpdateServerCount()
{
	local UDukeServerList l;

	TotalServers    = 0;
	TotalPlayers    = 0;
	TotalMaxPlayers = 0;
    ShownCount      = 0;

	for( l = UDukeServerList( Next ); l != None;l = UDukeServerList( l.Next ) )
	{
		TotalServers++;
		TotalPlayers    += l.NumPlayers;
		TotalMaxPlayers += l.MaxPlayers;

        if ( !l.bHidden )
            ShownCount++;
	}
}

function bool DecodeServerProperties( string Data )
{
	return true;
}

function int PingedCount()
{
    local UDukeServerList       l;
    local int                   count;

	for( l = UDukeServerList( Next ); l != None; l = UDukeServerList( l.Next ) )
    {
        if ( l.bPinged && !l.bHidden )
            count++;
    }

    return count;
}

function UpdateShownCount()
{
    local UDukeServerList       l;

    ShownCount = 0;

	for( l = UDukeServerList( Next ); l != None; l = UDukeServerList( l.Next ) )
    {
        if ( !l.bHidden )
            ShownCount++;
    }
}

defaultproperties
{
	MaxSimultaneousPing=10
}