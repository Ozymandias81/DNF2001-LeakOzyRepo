//=============================================================================
// UWindowGrid - a grid with sizable columns and clickable column headings.
//=============================================================================
class UWindowGrid extends UWindowWindow;

var UWindowGridColumn FirstColumn;
var UWindowGridColumn LastColumn;
var UWindowGridClient ClientArea;

var int					TopRow;
var float				RowHeight;
var UWindowVScrollbar	VertSB;
var UWindowHScrollbar	HorizSB;
var bool				bShowHorizSB;
var bool				bSizingColumn;
var bool				bNoKeyboard;
var float				FillAlpha;

function Created()
{
	ClientArea = UWindowGridClient(CreateWindow(class'UWindowGridClient', 0, 0, WinWidth - LookAndFeel.SBPosIndicator.W, WinHeight));
	VertSB = UWindowVScrollbar( CreateWindow(class'UWindowVScrollbar', 1, 1, 1, 1) );
	VertSB.bAlwaysOnTop = true;
	VertSB.bInBevel = true;

	HorizSB = UWindowHScrollbar(CreateWindow(class'UWindowHScrollbar', 0, WinHeight-LookAndFeel.SBPosIndicator.W, WinWidth, LookAndFeel.SBPosIndicator.H));
	HorizSB.bAlwaysOnTop = true;
	HorizSB.HideWindow();
	bShowHorizSB = false;

	if(!bNoKeyboard)
		SetAcceptsFocus();

	Super.Created();
}


function BeforePaint(Canvas C, float X, float Y)
{
	Super.BeforePaint(C, X, Y);
	Resized();
}

function Resized()
{
	LookAndFeel.Grid_SizeGrid( Self );
}

function UWindowGridColumn AddColumn( string ColumnHeading, float DefaultWidth )
{
	local UWindowGridColumn NewColumn;
	local UWindowGridColumn OldLastColumn;

	OldLastColumn = LastColumn;

	if ( LastColumn == None )
	{
		NewColumn = UWindowGridColumn(ClientArea.CreateWindow(class'UWindowGridColumn', 0, 0, DefaultWidth, WinHeight));
		FirstColumn = NewColumn;
		NewColumn.ColumnNum = 0;
	}
	else
	{
		NewColumn = UWindowGridColumn(ClientArea.CreateWindow(class'UWindowGridColumn', LastColumn.WinLeft + LastColumn.WinWidth, 0, DefaultWidth, WinHeight));
		LastColumn.NextColumn = NewColumn;
		NewColumn.ColumnNum = LastColumn.ColumnNum + 1;
	}

	LastColumn = NewColumn;
	NewColumn.NextColumn = None;
	NewColumn.PrevColumn = OldLastColumn;

	NewColumn.ColumnHeading = ColumnHeading;	
	return NewColumn;
}

function Paint( Canvas C, float MouseX, float MouseY )
{
	LookAndFeel.Grid_DrawGrid( Self, C );
}


function PaintColumn(Canvas C, UWindowGridColumn Column, float MouseX, float MouseY)
{
	// defined in subclass
}

function SortColumn(UWindowGridColumn Column)
{
	// defined in subclass
}

function SelectRow(int Row)
{
	// defined in subclass
}

function SelectColumn(UWindowGridColumn Column)
{
	// defined in subclass
}

function RightClickRow(int Row, float X, float Y)
{
	// defined in subclass
}

function RightClickRowDown(int Row, float X, float Y)
{
	// defined in subclass
}

function DoubleClickRow(int Row)
{
	// defined in subclass
}

function MouseLeaveColumn(UWindowGridColumn Column)
{
	// defined in subclass
}

function KeyDown(int Key, float X, float Y)
{
	switch(Key) {
	case 0x26: // IK_Up
	case 0xEC: // IK_MouseWheelUp
		VertSB.Scroll(-1);
		break;
	case 0x28: // IK_Down
	case 0xED: // IK_MouseWheelDown
		VertSB.Scroll(1);
		break;
	case 0x21: // IK_PageUp
		VertSB.Scroll(-(VertSB.MaxVisible-1));
		break;
	case 0x22: // IK_PageDown
		VertSB.Scroll(VertSB.MaxVisible-1);
		break;
	}
}

defaultproperties
{
	RowHeight=10.000000
	FillAlpha=1.0
}
