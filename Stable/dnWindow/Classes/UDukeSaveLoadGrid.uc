//=============================================================================
// UDukeSaveLoadGrid
// John Pollard
//=============================================================================
class UDukeSaveLoadGrid extends UWindowGrid;

var UWindowGridColumn               Description, DateTime;

var UDukeSaveLoadList				SaveLoadList;
var UDukeSaveLoadList				SelectedItem;
var int								SelectedRow;

var localized string				MonthNames[12];
var localized string				DayNames[7];

var UDukeSaveEditBox				RowEditBox;

var UDukeDialogClientWindow			Owner;

//=============================================================================
//=============================================================================
function Created()
{
	Super.Created();

	RowHeight = 12;

	// Setup the saveload list
	SaveLoadList = New class'dnWindow.UDukeSaveLoadList';
	SaveLoadList.SetupSentinel(false);
	SaveLoadList.bSuspendableSort = false;
}

//=============================================================================
//	AfterCreate
//=============================================================================
function AfterCreate()
{
	Super.AfterCreate();

	CreateColumns();
}


//=============================================================================
//	RegisterEditBox
//=============================================================================
function RegisterEditBox(UWindowDialogClientWindow Window)
{
	RowEditBox = UDukeSaveEditBox(CreateWindow(class'UDukeSaveEditBox', 2, 10, 200, 20, self));
	RowEditBox.Font = F_Small;
	RowEditBox.MaxLength = 64;

	RowEditBox.Register(Window);
}

//=============================================================================
//=============================================================================
function Close( optional bool bByParent ) 
{
	Super.Close(bByParent);
}

//=============================================================================
//=============================================================================
function CreateColumns()
{
    local float w;

    //w = WinWidth - VertSB.WinWidth;
	w = WinWidth - LookAndFeel.SBPosIndicator.W-5;

	//Description	 = AddColumn( "Description", 0.60 * w);
	Description	 = AddColumn( "Location", w*0.50);
	DateTime	 = AddColumn( "Date/Time",w*0.50);
}

//=============================================================================
//=============================================================================
function DrawCell( Canvas C, float X, float Y, UWindowGridColumn Column, UDukeSaveLoadList Item)
{
	local font OldFont;

	OldFont = C.Font;
	C.Font = font'mainmenufontsmall';
	switch( Column )
	{
		case Description:
			Column.ClipText( C, 4+X, Y, Item.Description);
			break;
		case DateTime:
			Column.ClipText( C, 6+X, Y, Item.DateTime);
			break;
	}
	C.Font = OldFont;
}

//=============================================================================
//	EmptyItems
//=============================================================================
function EmptyItems()
{
	if (SaveLoadList == None)
		return;
	
	SaveLoadList.Clear();	

	SelectedItem = None;
	SelectedRow = 0;
}

//=============================================================================
//	AddSaveLoadItem
//=============================================================================
function UDukeSaveLoadList AddSaveLoadItem(string Description, int Year, int Month, int Day, int DayOfWeek, int Hour, int Minute, int Second, int ID, ESaveType SaveType)
{
	local UDukeSaveLoadList		Item;

	if (SaveLoadList == None)
		return None;

	Item = UDukeSaveLoadList(SaveLoadList.Append(class'UDukeSaveLoadList'));

	if (Item == None)
		return None;

	Item.Description = Description;
	Item.Month = Month;
	Item.Day = Day;
	Item.DayOfWeek = DayOfWeek;
	Item.Year = Year;
	Item.Hour = Hour;
	Item.Minute = Minute;
	Item.Second = Second;
	Item.DateTime = BuildDateTime(Item.Year, Item.Month, Item.Day, Item.DayOfWeek, Item.Hour, Item.Minute, Item.Second);

	Item.ID = ID;
	Item.SaveType = SaveType;

	return Item;
}

//=============================================================================
//	BeforePaint
//=============================================================================
function BeforePaint(Canvas C, float X, float Y)
{
	local float				W, H;
	
	// Don't let them change the size of the column headings... 
	Description.Cursor = Root.NormalCursor;
	Description.bSizing = false;
	DateTime.Cursor = Root.NormalCursor;
	DateTime.bSizing = false;
	bSizingColumn = false;

	// Disable horiz stabilizer bar
	HorizSB.bDisabled = true;

	C.Font = font'mainmenufontsmall';
	if ( RowEditBox != None )
	{
		if ( SelectedItem.ID == -1 )
			TextSize( C, "[NEW]", W, H );
		else if ( SelectedItem.SaveType == SAVE_Quick )
			TextSize( C, "[Quick]", W, H );
		else if ( SelectedItem.SaveType == SAVE_Auto )
			TextSize( C, "[Auto]", W, H );
		else
		{
			TextSize( C, "TESTy", W, H );
			W = 0;
		}

		RowEditBox.SetSize( RowEditBox.WinWidth, H );
		RowEditBox.WinTop = (GetSelectedRow()-VertSB.Pos)*RowHeight + LookAndFeel.Bevel_GetHeaderedTop() + 2;;
		RowEditBox.WinLeft = W+6;
		RowEditBox.Font = F_Small;
	}

	Super.BeforePaint(C, X, Y);
}

//=============================================================================
//=============================================================================
function PaintColumn( Canvas C, UWindowGridColumn Column, float MouseX, float MouseY ) 
{
	local float				W, H;
	local float             Y;
	local int               Visible, Skipped;
	local int               TopMargin;
	local int               BottomMargin;
	local UDukeSaveLoadList List, Item;
	
	C.Font = font'mainmenufontsmall';

	//C.DrawColor.R = 255;
	//C.DrawColor.G = 255;
	//C.DrawColor.B = 255;

	if ( SaveLoadList == None )
		return;

    List = UDukeSaveLoadList( SaveLoadList.Next );		// Skip sentinel

	if ( bShowHorizSB )
		BottomMargin = LookAndFeel.SBPosIndicator.W;
	else
		BottomMargin = 0;

	TopMargin = LookAndFeel.Bevel_GetHeaderedTop() + 2;

	Visible = int( ( WinHeight /*- ( TopMargin + BottomMargin )*/ ) / RowHeight );
	
	VertSB.SetRange(0, GetCount(), Visible );
	TopRow = VertSB.Pos;

//	Y = LookAndFeel.Bevel_GetHeaderedTop();
	Skipped = 0;

	for (Item = List; Item != None; Item = UDukeSaveLoadList(Item.Next))
	{
//		if (Y > WinHeight /*- RowHeight*/ /*- ( TopMargin + BottomMargin )*/)
//			break;

		if (List.bHidden)
			continue;

		if ( Skipped++ < VertSB.Pos)
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

		if (Column == Description)
		{
			if (Item.ID == -1)
			{
				Column.ClipText( C, 6, Y+TopMargin, "[NEW]");
				TextSize(C, "[NEW]", W, H);
			}
			else if (Item.SaveType == SAVE_Quick)
			{
				Column.ClipText( C, 6, Y+TopMargin, "[Quick]");
				TextSize(C, "[Quick]", W, H);
			}
			else if (Item.SaveType == SAVE_Auto)
			{
				Column.ClipText( C, 6, Y+TopMargin, "[Auto]");
				TextSize(C, "[Auto]", W, H);
			}
		}

		// Draw highlight
//		if(Item == SelectedItem)
//			Column.DrawStretchedTexture( C, 0, Y-1 + TopMargin, Column.WinWidth, RowHeight + 1, Texture'WhiteTexture', 0.5 );

		if (Item != SelectedItem || RowEditBox == None || Column == DateTime)
			DrawCell( C, W, Y + TopMargin, Column, Item);
		
		Y = Y + RowHeight;			
	}
}

//=============================================================================
//	GetItemFromRow
//=============================================================================
function UDukeSaveLoadList GetItemFromRow( int Row )
{
	local int				i;
	local UDukeSaveLoadList List;

	if (SaveLoadList == None)
		return None;

	if (Row < 0 || Row >= GetCount())
		return None;

    List = UDukeSaveLoadList( SaveLoadList.Next );		// Skip sentinel

	i = 0;
	
	while ( List != None )
	{
		if ( !List.bHidden )
		{
    		if ( i == Row )
	    		return List;
			i++;
		}
		List = UDukeSaveLoadList( List.Next );			
	}

	return None;
}

//=============================================================================
//	GetRowFromItem
//=============================================================================
function int GetRowFromItem(UDukeSaveLoadList Item)
{
	local int				i;
	local UDukeSaveLoadList List;

	if (SaveLoadList == None)
		return -1;
	
	if (Item == None)
		return -1;

    List = UDukeSaveLoadList( SaveLoadList.Next );

	i = 0;
	
	while ( List != None )
	{
		if ( !List.bHidden )
		{
    		if (Item == List)
	    		return i;
			i++;
		}
		List = UDukeSaveLoadList( List.Next );			
	}

	return -1;
}

//=============================================================================
//=============================================================================
function SelectRow( int Row )
{
	local UDukeSaveLoadList	Item;
	
	Item = GetItemFromRow(Row);
	
	if (Item == None)
		return;

	SelectedItem = Item;
	SelectedRow = Row;
	
	VertSB.Show(SelectedRow);
}

//=============================================================================
//	SelectItem
//=============================================================================
function SelectItem(UDukeSaveLoadList Item)
{
	local int		Row;

	Row = GetRowFromItem(Item);

	if (Row == -1)
		return;
	
	SelectedItem = Item;
	SelectedRow = Row;
}

//=============================================================================
//=============================================================================
function int GetSelectedRow()
{
	return SelectedRow;
}

//=============================================================================
//	GetSelectedItem
//=============================================================================
function UDukeSaveLoadList GetSelectedItem()
{
	return SelectedItem;
}

//=============================================================================
//=============================================================================
function DoubleClickRow( int Row )
{
	SelectRow(Row);
	if (Owner != None)
		Owner.Notify(None, DE_EnterPressed);
}

//=============================================================================
//	
//=============================================================================
function DoubleClick(float X, float Y)
{
	Super.DoubleClick(X, Y);
	DoubleClickRow( GetSelectedRow());
}

//=============================================================================
//=============================================================================
function MouseLeaveColumn( UWindowGridColumn Column )
{
	ToolTip( "" );
}

//=============================================================================
//=============================================================================
function KeyDown( int Key, float X, float Y ) 
{
	switch( Key )
	{
	case 0x26: // IK_Up
		SelectRow( Clamp( GetSelectedRow() - 1, 0, GetCount() - 1 ) );
		VertSB.Show( GetSelectedRow());
		break;
	case 0x28: // IK_Down
		SelectRow( Clamp( GetSelectedRow() + 1, 0, GetCount() - 1 ) );
		VertSB.Show( GetSelectedRow());
		break;
	case 0x0D: // IK_Enter:
		DoubleClickRow( GetSelectedRow());
		break;
	default:
		Super.KeyDown( Key, X, Y );
		break;
	}
}

//=============================================================================
//	GetCount
//=============================================================================
function int GetCount()
{
	if (SaveLoadList == None)
		return 0;

	return SaveLoadList.InternalCount;
}

//==========================================================================================
//	BuildDateTime
//==========================================================================================
function string BuildDateTime(int Year, int Month, int Day, int DayOfWeek, int Hour, int Minute, int Second)
{
	local int		i, Hour2;
	local string	DateTime;

	Hour2 = Hour;

	if ( Hour > 12 )
		Hour2 -= 12;
		
	if (Hour2 == 0)
		Hour2 = 12;			
			
	if (Minute < 10)
		DateTime = Hour2$"\:0"$Minute;
	else
		DateTime = Hour2$"\:"$Minute;

	if (Second < 10)
		DateTime = DateTime$"\:0"$Second;
	else
		DateTime = DateTime$"\:"$Second;

	if (Hour >= 12)
		DateTime = DateTime$" "$"PM";
	else
		DateTime = DateTime$" "$"AM";
		
	return DayNames[DayOfWeek-1]$" "$MonthNames[Month - 1]$" "$Day$" "$DateTime;
}

//=============================================================================
//	Sort
//=============================================================================
function Sort()
{
	if (SaveLoadList == None)
		return;

	SaveLoadList.Sort();
}

//=============================================================================
//=============================================================================
defaultproperties
{
	MonthNames(0)="January"
	MonthNames(1)="February"
	MonthNames(2)="March"
	MonthNames(3)="April"
	MonthNames(4)="May"
	MonthNames(5)="June"
	MonthNames(6)="July"
	MonthNames(7)="August"
	MonthNames(8)="September"
	MonthNames(9)="October"
	MonthNames(10)="November"
	MonthNames(11)="December"

	DayNames(0)="Mon"
	DayNames(1)="Tues"
	DayNames(2)="Wed"
	DayNames(3)="Thurs"
	DayNames(4)="Fri"
	DayNames(5)="Sat"
	DayNames(6)="Sun"
}
