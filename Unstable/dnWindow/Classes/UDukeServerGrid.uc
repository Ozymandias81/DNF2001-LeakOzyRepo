/*-----------------------------------------------------------------------------
	UDukeServerGrid
	Author: Brandon Reinhart, Scott Alden
-----------------------------------------------------------------------------*/
class UDukeServerGrid extends UWindowGrid;

var     UDukeRightClickMenu             Menu;
var     UWindowGridColumn               Server, Ping, MapName, Players, SortByColumn, GameType;
var     bool                            bSortDescending;
var     localized string                ServerName, PingName, MapNameName, PlayersName, GameTypeName;
var     UDukeServerList                 SelectedServer;
var     int                             Count;
var     float                           TimePassed;
var     int                             AutoPingInterval;
var     UDukeServerList                 OldPingServer;

function Created()
{
	Super.Created();

	RowHeight = 12;

	CreateColumns();

	Menu = UDukeRightClickMenu( Root.CreateWindow( UDukeServerBrowserCW( GetParent( class'UDukeServerBrowserCW' ) ).RightClickMenuClass, 
                                                      0, 0, 100, 100, Self ) );
	Menu.HideWindow();
}

function Close( optional bool bByParent ) 
{
	Super.Close(bByParent);

	if ( Menu != None && Menu.bWindowVisible )
    {
		Menu.CloseUp();
    }
}

function CreateColumns()
{
    local float w;

    w = WinWidth - VertSB.WinWidth;

	Server	 = AddColumn( ServerName,     0.3  * w );
	Ping	 = AddColumn( PingName,       0.08 * w );
	Players	 = AddColumn( PlayersName,    0.08 * w );
    MapName	 = AddColumn( MapNameName,    0.3  * w );	
    GameType = AddColumn( GameTypeName,   0.2  * w );

	SortByColumn = Ping;
}

function DrawCell( Canvas C, float X, float Y, UWindowGridColumn Column, UDukeServerList List )
{
	C.Font = Root.Fonts[F_Small];
	switch( Column )
	{
	case Server:
		Column.ClipText( C, X, Y, List.HostName );
		break;
	case Ping:
		Column.ClipText( C, X, Y, Int(List.Ping) );
		break;
	case MapName:
        if ( List.MapDisplayName != "" )
    		Column.ClipText( C, X, Y, List.MapDisplayName );
		break;
	case Players:
		Column.ClipText( C, X, Y, List.NumPlayers$"/"$List.MaxPlayers );
		break;
	case GameType:
		Column.ClipText( C, X, Y, List.GameType );
		break;

	}
}

function PaintColumn( Canvas C, UWindowGridColumn Column, float MouseX, float MouseY ) 
{
	local UDukeServerList   List;
	local float             Y;
	local int               Visible;
	local int               Skipped;
	local int               TopMargin;
	local int               BottomMargin;

	C.Font = Root.Fonts[F_Small];

	List = UDukeServerBrowserCW( GetParent( class'UDukeServerBrowserCW' ) ).PingedList;

	if ( List == None )
		Count = 0;
	else
    {
		Count = List.ShownCount;
    }

	if ( bShowHorizSB )
		BottomMargin = LookAndFeel.SBPosIndicator.W;
	else
		BottomMargin = 0;

	TopMargin = LookAndFeel.ColumnHeadingHeight;

	Visible = int( ( WinHeight - ( TopMargin + BottomMargin ) ) /RowHeight );
	
	VertSB.SetRange( 0, Count+1, Visible );
	TopRow = VertSB.Pos;

	Skipped = 0;

	List = UDukeServerList( List.Next );

	if ( List != None )
	{
		Y = 1;

		while ( ( Y < RowHeight + WinHeight - RowHeight - ( TopMargin + BottomMargin ) ) && ( List != None ) )
		{	
            if ( !List.bHidden )
            {
			    if ( Skipped >= VertSB.Pos )
			    {
				    // Draw highlight
//				    if(List == SelectedServer)
//					    Column.DrawStretchedTexture( C, 0, Y-1 + TopMargin, Column.WinWidth, RowHeight + 1, Texture'WhiteTexture', 0.5 );

				    DrawCell( C, 6, Y + TopMargin, Column, List );
				    Y = Y + RowHeight;			
			    } 
			    Skipped ++;
            }

			List = UDukeServerList( List.Next );
		}
	}
}

function SortColumn( UWindowGridColumn Column )
{
	if ( SortByColumn == Column )
    {
		bSortDescending = !bSortDescending;
    }
	else
    {
		bSortDescending = False;
    }

	SortByColumn = Column;

	UDukeServerBrowserCW( GetParent( class'UDukeServerBrowserCW' ) ).PingedList.Sort();	
}

function Tick(float DeltaTime)
{
	local UDukeServerBrowserCW W;

	W = UDukeServerBrowserCW( GetParent( class'UDukeServerBrowserCW' ) );

	if ( W.PingState == PS_Done && SelectedServer == None )
	{
		SelectedServer = UDukeServerList( W.PingedList.Next );

		if ( SelectedServer == None || SelectedServer.bPinging || SelectedServer.bHidden )
        {
			SelectedServer = None;
        }
		else
        {
			UDukeServerBrowserCW( GetParent( class'UDukeServerBrowserCW' ) ).AutoInfo( SelectedServer );
        }
	}

	if ( W.PingState == PS_Done )
	{
		if ( TimePassed >= AutoPingInterval )
		{
			TimePassed = 0;

			if ( SelectedServer != OldPingServer )
			{
				if ( OldPingServer != None )
                {
				    OldPingServer.CancelPing();
                }
				OldPingServer = SelectedServer;
			}

			if ( SelectedServer != None && !SelectedServer.bPinging )
            {
				SelectedServer.PingServer( False, True, True );
            }
		}
		TimePassed = TimePassed + DeltaTime;
	}
}

function SelectRow( int Row )
{
	local UDukeServerList S;

	S = GetServerUnderRow( Row );

	if ( SelectedServer != S )
	{
		if ( S != None )
        {
			UDukeServerBrowserCW( GetParent ( class'UDukeServerBrowserCW' ) ).AutoInfo( S );
        }
		TimePassed = 0;
	}

	if( S != None )
    {
		SelectedServer = S;
    }
}

function RightClickRow( int Row, float X, float Y )
{
    local float MenuX, MenuY;

	WindowToGlobal( X, Y, MenuX, MenuY );

	Menu.WinLeft    = MenuX;
	Menu.WinTop     = MenuY;
	Menu.List       = GetServerUnderRow( Row );
	Menu.Grid       = Self;

    Menu.ShowWindow();
}

function UDukeServerList GetServerUnderRow( int Row )
{
	local int i;
	local UDukeServerList List;

	List = UDukeServerBrowserCW( GetParent( class'UDukeServerBrowserCW' ) ).PingedList;
	
    if( List != None )
	{
		i = 0;
		List = UDukeServerList( List.Next );
		while ( List != None )
		{
            if ( !List.bHidden )
            {
    			if ( i == Row )
	    			return List;
                i++;
            }
			List = UDukeServerList( List.Next );			
		}
	}
	return None;
}

function int GetSelectedRow()
{
	local int i;
	local UDukeServerList List;

	List = UDukeServerBrowserCW( GetParent( class'UDukeServerBrowserCW' ) ).PingedList;
	
    if( List != None )
	{
		i = 0;
		List = UDukeServerList( List.Next );
		
        while( List != None )
		{
            if ( !List.bHidden )
            {
			    if( List == SelectedServer )
				    return i;
                i++;
            }
			List = UDukeServerList( List.Next );			
		}
	}
	return -1;
}

function JoinServer( UDukeServerList Server )
{
	if ( Server != None && Server.GamePort != 0 ) 
	{
		GetPlayerOwner().ClientTravel( Server.IP$":"$Server.GamePort$UDukeServerBrowserCW( GetParent( class'UDukeServerBrowserCW' ) ).URLAppend, TRAVEL_Absolute, false );
		GetParent( class'UWindowFramedWindow' ).Close();
		Root.Console.CloseUWindow();
	}
}

function DoubleClickRow( int Row )
{
	local UDukeServerList Server;

	Server = GetServerUnderRow( Row );
	
    if ( SelectedServer != Server )
    {
        return; 
    }

	JoinServer( Server );
}

function MouseLeaveColumn( UWindowGridColumn Column )
{
	ToolTip( "" );
}

function KeyDown( int Key, float X, float Y ) 
{
	switch( Key )
	{
	case 0x74: // IK_F5;
		Refresh();
		break;
	case 0x26: // IK_Up
		SelectRow( Clamp( GetSelectedRow() - 1, 0, Count - 1 ) );
		VertSB.Show( GetSelectedRow() );
		break;
	case 0x28: // IK_Down
		SelectRow( Clamp( GetSelectedRow() + 1, 0, Count - 1 ) );
		VertSB.Show( GetSelectedRow() );
		break;
	case 0x0D: // IK_Enter:
		DoubleClickRow( GetSelectedRow() );
		break;
	default:
		Super.KeyDown( Key, X, Y );
		break;
	}
}

function int Compare( UDukeServerList T, UDukeServerList B )
{
	switch( SortByColumn )
	{
	case Server:
		return ByName( T, B );
	case Ping:
		return ByPing( T, B );
	case MapName:
		return ByMap( T, B );
	case Players:
		return ByPlayers( T, B );
    case GameType:
        return ByGameType( T, B );
	default:
		return 0;
	}	
}

function int ByPing( UDukeServerList T, UDukeServerList B )
{
	local int Result;

	if ( B == None )
        return -1;
	
	if ( T.Ping < B.Ping )
	{
		Result = -1;
	}
	else if ( T.Ping > B.Ping )
	{
		Result = 1;
	}
	else
	{
/*		if(T.HostName < B.HostName)
			Result = -1;
		else
		if(T.HostName > B.HostName)
			Result = 1;
		else
*/
			Result = 0;
	}

	if ( bSortDescending )
		Result = -Result;

	return Result;
}

function int ByName( UDukeServerList T, UDukeServerList B )
{
	local int Result;

	if ( B == None )
        return -1;

	if ( T.Ping == 9999 )
        return 1;

	if ( B.Ping == 9999 )
        return -1;
	
	if ( T.HostName < B.HostName )
	{
		Result = -1;
	}
	else if ( T.HostName > B.HostName )
	{
		Result = 1;
	}
	else
	{
		Result = 0;//T.Ping - B.Ping;
	}

	if ( bSortDescending )
		Result = -Result;

	return Result;
}

function int ByMap( UDukeServerList T, UDukeServerList B )
{
	local int Result;

	if ( B == None )
        return -1;
	
	if ( T.Ping == 9999 )
        return 1;

	if ( B.Ping == 9999 )
        return -1;

	if ( T.MapDisplayName < B.MapDisplayName )
	{
		Result = -1;
	}
	else if ( T.MapDisplayName > B.MapDisplayName )
	{
		Result = 1;
	}
	else
	{
		Result = T.Ping - B.Ping;
	}

	if ( bSortDescending )
		Result = -Result;
	
	return Result;
}

function int ByGameType( UDukeServerList T, UDukeServerList B )
{
	local int Result;

	if ( B == None )
        return -1;
	
	if ( T.Ping == 9999 )
        return 1;

	if ( B.Ping == 9999 )
        return -1;

	if ( T.GameType < B.GameType )
	{
		Result = -1;
	}
	else if ( T.GameType > B.GameType )
	{
		Result = 1;
	}
	else
	{
		Result = T.Ping - B.Ping;
	}

	if ( bSortDescending )
		Result = -Result;
	
	return Result;
}

function int ByPlayers( UDukeServerList T, UDukeServerList B )
{
	local int Result;

	if ( B == None )
        return -1;
	
	if ( T.Ping == 9999 )
        return 1;

	if ( B.Ping == 9999 )
        return -1;

	if ( T.NumPlayers > B.NumPlayers )
	{
		Result = -1;
	}
	else if ( T.NumPlayers < B.NumPlayers )
	{
		Result = 1;
	}
	else
	{
		if ( T.MaxPlayers > B.MaxPlayers )
		{
			Result = -1;
		}
		else if( T.MaxPlayers < B.MaxPlayers )
		{
			Result = 1;
		}
		else
		{
			Result = T.Ping - B.Ping;
		}
	}

	if( bSortDescending )
		Result = -Result;

	return Result;
}

function ShowInfo( UDukeServerList List )
{
	UDukeServerBrowserCW( GetParent( class'UDukeServerBrowserCW' ) ).ShowInfo( List );
}

function Refresh()
{
	UDukeServerBrowserCW( GetParent( class'UDukeServerBrowserCW' ) ).Refresh();
}

function RefreshServer()
{
	TimePassed = AutoPingInterval;
}

function RePing()
{
	UDukeServerBrowserCW( GetParent( class'UDukeServerBrowserCW' ) ).RePing();
}

defaultproperties
{
     ServerName="Server"
     PingName="Ping"
     MapNameName="Map Name"
     PlayersName="Players"
     GameTypeName="GameType"
     AutoPingInterval=5
}
