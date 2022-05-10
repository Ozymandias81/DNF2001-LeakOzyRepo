//=============================================================================
// UDukeRulesGrid
//=============================================================================
class UDukeRulesGrid extends UWindowGrid;

var localized string RuleText;
var localized string ValueText;

function Created() 
{
	Super.Created();

	RowHeight = 12;

	AddColumn( RuleText,    200 );
	AddColumn( ValueText,   150 );
}

function PaintColumn( Canvas C, UWindowGridColumn Column, float MouseX, float MouseY ) 
{
	local UDukeServerList   Server;
	local UDukeRulesList    RulesList, l;
	local int               Visible;
	local int               Count;
	local int               Skipped;
	local int               Y;
	local int               TopMargin;
	local int               BottomMargin;
	
	if ( bShowHorizSB )
		BottomMargin = LookAndFeel.SBPosIndicator.W;
	else
		BottomMargin = 0;

	TopMargin = LookAndFeel.ColumnHeadingHeight;
	
	Server = UDukeInfoCW( GetParent( class'UDukeInfoCW' ) ).Server;
	if ( Server == None )
		return;

	RulesList = Server.RulesList;
	if ( RulesList == None )
		return;

	Count = RulesList.Count();

	C.Font = Root.Fonts[F_Small];
	Visible = int( ( WinHeight - ( TopMargin + BottomMargin ) ) / RowHeight );
	
	VertSB.SetRange( 0, Count+1, Visible );
	TopRow = VertSB.Pos;

	Skipped = 0;

	Y = 1;
	l = UDukeRulesList( RulesList.Next );
	while( ( Y < RowHeight + WinHeight - RowHeight - ( TopMargin + BottomMargin ) ) && ( l != None ) ) 
	{
		if ( Skipped >= VertSB.Pos )
		{
			switch ( Column.ColumnNum )
			{
			case 0:
				Column.ClipText( C, 6, Y + TopMargin, l.Rule );
				break;
			case 1:
				Column.ClipText( C, 6, Y + TopMargin, l.Value );
				break;
			}

			Y = Y + RowHeight;			
		} 
		Skipped ++;
		l = UDukeRulesList( l.Next );
	}
}

function RightClickRow( int Row, float X, float Y )
{
    /*
	local UBrowserInfoMenu Menu;
	local float MenuX, MenuY;
	local UWindowWindow W;

	W = GetParent(class'UBrowserInfoWindow');
	if(W == None)
		return;
	Menu = UBrowserInfoWindow(W).Menu;

	WindowToGlobal(X, Y, MenuX, MenuY);
	Menu.WinLeft = MenuX;
	Menu.WinTop = MenuY;

	Menu.ShowWindow();
    */
}

function SortColumn(UWindowGridColumn Column) 
{
	UDukeInfoCW( GetParent( class'UDukeInfoCW' ) ).Server.RulesList.SortByColumn( Column.ColumnNum );
}

function SelectRow( int Row )
{
}

defaultproperties
{
     RuleText="Rule"
     ValueText="Value"
     bNoKeyboard=True
}
