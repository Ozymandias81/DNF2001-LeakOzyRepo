/*-----------------------------------------------------------------------------
	UDukeScoreboardGrid
	Author: Scott Alden
-----------------------------------------------------------------------------*/
class UDukeScoreboardGrid extends UWindowGrid;

var UWindowGridColumn               PlayerName;
var UWindowGridColumn               Kills;
var UWindowGridColumn               Deaths;
var UWindowGridColumn               Ping;
var UWindowGridColumn               Time;
var UWindowGridColumn               Squelch;

var UDukeScoreboardList				ScoreboardList;
var UDukeScoreboardList				SelectedItem;
var int								SelectedRow;
var Color							SelfColor;
var UDukeScoreboardMenu				Menu;

var UWindowMessageBox				TellBox;
var localized string				TellTitle;
var localized string				TellMessage;

//=============================================================================
//Created
//=============================================================================
function Created()
{
	local float XL, YL;

	Super.Created();

	// Setup the saveload list
	ScoreboardList = New class'dnWindow.UDukeScoreboardList';
	ScoreboardList.SetupSentinel( false );
	ScoreboardList.bSuspendableSort = false;

	Menu = UDukeScoreboardMenu( Root.CreateWindow( class'UDukeScoreboardMenu',
                                                   0, 0, 100, 100, Self ) );
	Menu.bLeaveOnScreen=true;
	Menu.HideWindow();
	CreateColumns();
}

//=============================================================================
//Close
//=============================================================================
function Close( optional bool bByParent ) 
{
	Super.Close( bByParent );

	if ( Menu != None  )
    {
		Menu.CloseUp();
    }
}

//=============================================================================
//CreateColumns
//=============================================================================
function CreateColumns()
{
    local float w;
    
	w = WinWidth - LookAndFeel.SBPosIndicator.W-5;
	
	PlayerName	 = AddColumn( "Name",    w * 0.4  );
	Kills    	 = AddColumn( "Kills",   w * 0.10 );
	Deaths    	 = AddColumn( "Deaths",  w * 0.10 );
	Ping    	 = AddColumn( "Ping",    w * 0.10 );
	Time    	 = AddColumn( "Time",    w * 0.10 );
	Squelch      = AddColumn( "Squelch", w * 0.10 );
	Squelch.bAllowDoubleClick = false;
}

//=============================================================================
//Resized
//=============================================================================
function Resized()
{
	local float w;
	
	Super.Resized();

	w = WinWidth - LookAndFeel.SBPosIndicator.W-5;

	PlayerName.SetSize( w * 0.4,  PlayerName.WinHeight );
	Kills.SetSize(		w * 0.10, Kills.WinHeight	   );
	Deaths.SetSize(		w * 0.10, Deaths.WinHeight	   );
	Ping.SetSize(		w * 0.10, Ping.WinHeight	   );
	Time.SetSize(		w * 0.10, Time.WinHeight	   );
	Squelch.SetSize(	w * 0.10, Time.WinHeight	   );
}

//=============================================================================
//	Sort
//=============================================================================
function Sort()
{
	if ( ScoreboardList == None )
		return;

	ScoreboardList.Sort();
}

//=============================================================================
//EmptyItems
//=============================================================================
function EmptyItems()
{
	if ( ScoreboardList == None )
		return;
	
	ScoreboardList.Clear();	
	
	SelectedItem = None;
	SelectedRow  = 0;
}

//=============================================================================
//AddPlayerItem
//=============================================================================
function UDukeScoreboardList AddPlayerItem( PlayerReplicationInfo PRI )
{
	local UDukeScoreboardList	Item;

	if ( ScoreboardList == None )
		return None;

	Item = UDukeScoreboardList( ScoreboardList.Append( class'UDukeScoreboardList' ) );

	if ( Item == None )
		return None;
	
	Item.PRI        = PRI;
	Item.PlayerName = PRI.PlayerName;
	Item.Kills      = PRI.Score;
	Item.Deaths     = PRI.Deaths;
	Item.Ping       = PRI.Ping;
	Item.Time       = Max( 1, ( GetLevel().TimeSeconds + GetPlayerOwner().PlayerReplicationInfo.StartTime - PRI.StartTime ) / 60 );
	Item.PlayerID   = PRI.PlayerID;	
	return Item;
}

//=============================================================================
//BeforePaint
//=============================================================================
function BeforePaint(Canvas C, float X, float Y)
{
	local float				W, H;
	
	// Don't let them change the size of the column headings... 
	PlayerName.Cursor   = Root.NormalCursor;
	PlayerName.bSizing  = false;
	Kills.Cursor		= Root.NormalCursor;
	Kills.bSizing		= false;
	Deaths.Cursor		= Root.NormalCursor;
	Deaths.bSizing		= false;
	Ping.Cursor			= Root.NormalCursor;
	Ping.bSizing		= false;
	Time.Cursor			= Root.NormalCursor;
	Time.bSizing		= false;
	Squelch.Cursor		= Root.NormalCursor;
	Squelch.bSizing		= false;
	bSizingColumn       = false;

	// Disable horiz stabilizer bar
	HorizSB.bDisabled	= true;

	C.Font    = Font'mainmenufont';
	C.TextSize( "TEST", W, H );
	RowHeight = H + 1;

	Super.BeforePaint(C, X, Y);
}

//=============================================================================
//PaintColumn
//=============================================================================
function PaintColumn( Canvas C, UWindowGridColumn Column, float MouseX, float MouseY ) 
{
	local float					W, H;
	local float					Y;
	local int					Visible, Skipped;
	local int					TopMargin;
	local int					BottomMargin;
	local UDukeScoreboardList	List, Item;
	
	C.Font = font'mainmenufont';

	if ( ScoreboardList == None )
		return;

    List = UDukeScoreboardList( ScoreboardList.Next );		// Skip sentinel

	if ( bShowHorizSB )
		BottomMargin = LookAndFeel.SBPosIndicator.W;
	else
		BottomMargin = 0;

	TopMargin = LookAndFeel.Bevel_GetHeaderedTop() + 2;

	Visible = int( ( WinHeight / RowHeight ) );
	VertSB.SetRange( 0, GetCount(), Visible );
	TopRow = VertSB.Pos;

	Skipped = 0;

	for ( Item = List; Item != None; Item = UDukeScoreboardList( Item.Next ) )
	{
		if ( List.bHidden )
			continue;

		if ( Skipped++ < VertSB.Pos )
			continue;

		W = 0;
		
		if ( Item == SelectedItem )
		{
			C.DrawColor = LookAndFeel.GetTextColor( Self );
		}
		else
		{
			C.DrawColor = LookAndFeel.GetTextColor( Self );
			C.DrawColor.R = 3 * (C.DrawColor.R / 4);
			C.DrawColor.G = 3 * (C.DrawColor.G / 4);
			C.DrawColor.B = 3 * (C.DrawColor.B / 4);
		}

		// Draw highlight
		if(Item == SelectedItem)
			Column.DrawStretchedTexture( C, 4, Y-1 + TopMargin, Column.WinWidth, RowHeight + 1, Texture'WhiteTexture', 0.5 );
	
		DrawCell( C, 8+W, Y + TopMargin, Column, Item );
		
		Y = Y + RowHeight;			
	}
}

//=============================================================================
//DrawCell
//=============================================================================
function DrawCell( Canvas C, float X, float Y, UWindowGridColumn Column, UDukeScoreboardList Item )
{
	local font	OldFont;
	local color SaveColor;

	OldFont = C.Font;
	C.Font  = font'mainmenufont';

	switch( Column )
	{
		case PlayerName:
			SaveColor = C.DrawColor;
			if ( Item.PlayerName == GetPlayerOwner().PlayerReplicationInfo.PlayerName )
			{
				C.DrawColor = SelfColor;
			}
			Column.ClipText( C, X, Y, Item.PlayerName );
			C.DrawColor = SaveColor;
			break;
		case Kills:
			Column.ClipText( C, X, Y, Item.Kills );
			break;
		case Deaths:
			Column.ClipText( C, X, Y, Item.Deaths );
			break;
		case Ping:
			Column.ClipText( C, X, Y, Item.Ping );
			break;
		case Time:
			Column.ClipText( C, X, Y, Item.Time );
			break;
		case Squelch:
			LookAndFeel.Checkbox_ManualDraw( self, C, X, Y, 12, 12, Item.PRI.bSquelch );
			break;

	}
	C.Font = OldFont;
}


//=============================================================================
//GetItemFromRow
//=============================================================================
function UDukeScoreboardList GetItemFromRow( int Row )
{
	local int					i;
	local UDukeScoreboardList	List;

	if ( ScoreboardList == None )
		return None;

	if ( Row < 0 || Row >= GetCount() )
		return None;

    List = UDukeScoreboardList( ScoreboardList.Next );		// Skip sentinel

	i = 0;
	
	while ( List != None )
	{
		if ( !List.bHidden )
		{
    		if ( i == Row )
	    		return List;
			i++;
		}
		List = UDukeScoreboardList( List.Next );			
	}

	return None;
}


//=============================================================================
//SelectRow
//=============================================================================
function SelectRow( int Row )
{
	local UDukeScoreboardList	Item;
	
	Item = GetItemFromRow( Row );
	
	if ( Item == None )
	{
		SelectedItem = None;
		return;
	}

	SelectedItem	= Item;
	SelectedRow		= Row;
	
	VertSB.Show( SelectedRow );
}

//=============================================================================
//SelectColumn
//=============================================================================
function SelectColumn( UWindowGridColumn Column )
{
	if ( Column == Squelch )
	{
		// Squelch this player
		if ( SelectedItem != None )
		{
			SelectedItem.PRI.bSquelch = !SelectedItem.PRI.bSquelch;
		}
	}
}

//=============================================================================
//RightClickRow
//=============================================================================
function RightClickRow( int Row, float X, float Y )
{
    local float MenuX, MenuY;

	WindowToGlobal( X, Y, MenuX, MenuY );

	Menu.WinLeft    = MenuX;
	Menu.WinTop     = MenuY;

	SelectRow( Row );

	if ( SelectedItem == None )
		return;

	Menu.Item       = SelectedItem;
	Menu.Grid       = Self;

    Menu.ShowWindow();
}

//=============================================================================
//DoubleClickRow
//=============================================================================
function DoubleClickRow( int Row )
{
	SelectRow( Row );

	if ( SelectedItem == None )
		return;

	DoTell( SelectedItem.PlayerID, SelectedItem.PlayerName );
}

//=============================================================================
//DoTell
//=============================================================================
function DoTell( int PlayerID, string PlayerName )
{
	TellBox = UWindowMessageBox( Root.CreateWindow( class'UWindowMessageBox', 100, 100, 150, 250 ) );	
	TellBox.bLeaveOnScreen = true;
	TellBox.SetupMessageBox( TellTitle, TellMessage @ PlayerName, MB_OKCancelEdit, MR_Cancel, MR_OK );	
	TellBox.OwnerWindow = self;

	TellBox.WinTop = ( WinHeight - TellBox.WinHeight ) / 2; 
	TellBox.WinLeft = ( WinWidth - TellBox.WinWidth ) / 2;
	ShowModal( TellBox );
}

//=============================================================================
//MessageBoxDone
//=============================================================================
function MessageBoxDone( UWindowMessageBox W, MessageBoxResult Result )
{
	if ( W == TellBox && Result == MR_OK )
	{
		GetPlayerOwner().Tell( SelectedItem.PlayerID, W.StringResult );
	}
}

//=============================================================================
//	GetCount
//=============================================================================
function int GetCount()
{
	if ( ScoreboardList == None )
		return 0;

	return ScoreboardList.InternalCount;
}

defaultproperties
{
	SelfColor=(R=255,G=255,B=0)
	FillAlpha=1.0
	TellTitle="Private Message"
	TellMessage="Send a private message to"
}