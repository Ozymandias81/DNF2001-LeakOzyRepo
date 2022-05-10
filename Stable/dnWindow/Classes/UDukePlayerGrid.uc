//=============================================================================
// UDukePlayerGrid
//=============================================================================
class UDukePlayerGrid extends UWindowGrid;

var localized string NameText;
var localized string FragsText;
var localized string PingText;
var localized string TeamText;

function Created() 
{
	Super.Created();

	RowHeight = 12;

	AddColumn( NameText,  280 );
	AddColumn( FragsText, 60  );
	AddColumn( PingText,  60  );
	AddColumn( TeamText,  60  );
}

function PaintColumn( Canvas C, UWindowGridColumn Column, float MouseX, float MouseY ) 
{
	local UDukeServerList Server;
	local UDukePlayerList PlayerList, l;
	local int Visible;
	local int Count;
	local int Skipped;
	local int Y;
	local int TopMargin;
	local int BottomMargin;
	
	if ( bShowHorizSB )
		BottomMargin = LookAndFeel.SBPosIndicator.W;
	else
		BottomMargin = 0;

	TopMargin = LookAndFeel.ColumnHeadingHeight;

	Server = UDukeInfoCW( GetParent( class'UDukeInfoCW' ) ).Server;
	if ( Server == None )
		return;
    
	PlayerList = Server.PlayerList;
	if ( PlayerList == None )
		return;

	Count = PlayerList.Count();
    
	C.Font = Root.Fonts[F_Small];

	Visible = int( ( WinHeight - ( TopMargin + BottomMargin ) ) / RowHeight );
	
	VertSB.SetRange( 0, Count+1, Visible );
	TopRow = VertSB.Pos;
	Skipped = 0;

	Y = 1;
	l = UDukePlayerList( PlayerList.Next );
	while( ( Y < RowHeight + WinHeight - RowHeight - ( TopMargin + BottomMargin ) ) && ( l != None ) )
	{
		if ( Skipped >= VertSB.Pos )
		{
			switch ( Column.ColumnNum )
			{
			case 0:
				Column.ClipText( C, 6, Y + TopMargin, l.PlayerName );
				break;
			case 1:
				Column.ClipText( C, 6, Y + TopMargin, l.PlayerFrags );
				break;
			case 2:
				Column.ClipText( C, 6, Y + TopMargin, l.PlayerPing);
				break;
			case 3:
				Column.ClipText( C, 6, Y + TopMargin, l.PlayerTeam );
				break;
			}

			Y = Y + RowHeight;			
		} 
		Skipped ++;
		l = UDukePlayerList( l.Next );
	}
}

function RightClickRow( int Row, float X, float Y )
{
	local UBrowserInfoMenu Menu;
	local float MenuX, MenuY;
	local UWindowWindow W;

	W = GetParent( class'UBrowserInfoWindow' );
	
    if( W == None )
		return;

	Menu = UBrowserInfoWindow( W ).Menu;

	WindowToGlobal( X, Y, MenuX, MenuY );

	Menu.WinLeft = MenuX;
	Menu.WinTop = MenuY;

	Menu.ShowWindow();
}

function SortColumn( UWindowGridColumn Column ) 
{
	UDukeInfoCW( GetParent( class'UDukeInfoCW' ) ).Server.PlayerList.SortByColumn( Column.ColumnNum );
}

function SelectRow( int Row ) 
{
}

defaultproperties
{
     NameText="Name"
     FragsText="Frags"
     PingText="Ping"
     TeamText="Team"
     bNoKeyboard=True
}
