//=============================================================================
// UWindowGridColumn - a grid column
//=============================================================================
class UWindowGridColumn extends UWindowWindow;

var UWindowGridColumn NextColumn;
var UWindowGridColumn PrevColumn;
var bool				bSizing;
var string				ColumnHeading;
var int					ColumnNum;
var bool                bAllowDoubleClick;

function Created() {
	Super.Created();
}

function BeforePaint(Canvas C, float X, float Y)
{
	Super.BeforePaint(C, X, Y);
	if(WinWidth < 1) WinWidth = 1;
}

function LMouseDown(float X, float Y)
{
	Super.LMouseDown(X, Y);

	if(X > Min(WinWidth - 5, ParentWindow.WinWidth - WinLeft - 5) && Y < LookAndFeel.ColumnHeadingHeight)
	{
		bSizing = True;
		UWindowGrid(ParentWindow.ParentWindow).bSizingColumn = True;
		Root.CaptureMouse();
	}
}

function LMouseUp(float X, float Y)
{
	Super.LMouseUp(X, Y);

	UWindowGrid(ParentWindow.ParentWindow).bSizingColumn = False;
}

function MouseMove(float X, float Y)
{
	if(X > Min(WinWidth - 5, ParentWindow.WinWidth - WinLeft - 5) && Y < LookAndFeel.ColumnHeadingHeight)
	{
		Cursor = Root.HSplitCursor;
	}
	else
	{
		Cursor = Root.NormalCursor;
	}

	if(bSizing && bMouseDown)
	{
		WinWidth = X;
		if(WinWidth < 1) WinWidth = 1;
		if(WinWidth > ParentWindow.WinWidth - WinLeft - 1) WinWidth = ParentWindow.WinWidth - WinLeft - 1;
	}
	else
	{
		bSizing = False;
		UWindowGrid(ParentWindow.ParentWindow).bSizingColumn = False;
	}
}

function Paint(Canvas C, float X, float Y)
{
	local Region R;
	local Texture T;
	local Color FC;

	UWindowGrid(ParentWindow.ParentWindow).PaintColumn(C, Self, X, Y);

	T = LookAndFeel.Active;
	FC = LookAndFeel.HeadingActiveTitleColor;

	DrawUpBevel( C, 0, 0, WinWidth, LookAndFeel.ColumnHeadingHeight, T);

	C.DrawColor = LookAndFeel.GetTextColor( Self );
	C.Font = Root.Fonts[F_Small];
	ClipText( C, 6, 2, ColumnHeading);

	C.DrawColor.r = 255;
	C.DrawColor.g = 255;
	C.DrawColor.b = 255;
}

function Click(float X, float Y)
{
	local int Row;

	if(Y < LookAndFeel.ColumnHeadingHeight)
	{
		if(X <= Min(WinWidth - 5, ParentWindow.WinWidth - WinLeft - 5))
		{
			UWindowGrid(ParentWindow.ParentWindow).SortColumn(Self);
		}
	}
	else
	{
		Row = ((Y - LookAndFeel.ColumnHeadingHeight) / UWindowGrid(ParentWindow.ParentWindow).RowHeight) + UWindowGrid(ParentWindow.ParentWindow).TopRow;
		UWindowGrid(ParentWindow.ParentWindow).SelectRow(Row);
		UWindowGrid(ParentWindow.ParentWindow).SelectColumn(self);
	}
}

function RMouseDown(float X, float Y)
{
	local int Row;
	Super.RMouseDown(X, Y);

	if(Y > LookAndFeel.ColumnHeadingHeight)
	{
		Row = ((Y - LookAndFeel.ColumnHeadingHeight) / UWindowGrid(ParentWindow.ParentWindow).RowHeight) + UWindowGrid(ParentWindow.ParentWindow).TopRow;
		UWindowGrid(ParentWindow.ParentWindow).SelectRow(Row);
		UWindowGrid(ParentWindow.ParentWindow).RightClickRowDown(Row, X+WinLeft, Y+WinTop);
	}
}

function RMouseUp(float X, float Y)
{
	local int Row;
	Super.RMouseUp(X, Y);

	if(Y > LookAndFeel.ColumnHeadingHeight)
	{
		Row = ((Y - LookAndFeel.ColumnHeadingHeight) / UWindowGrid(ParentWindow.ParentWindow).RowHeight) + UWindowGrid(ParentWindow.ParentWindow).TopRow;
		UWindowGrid(ParentWindow.ParentWindow).SelectRow(Row);
		UWindowGrid(ParentWindow.ParentWindow).RightClickRow(Row, X+WinLeft, Y+WinTop);
	}
}

function DoubleClick(float X, float Y)
{
	local int Row;

	if(Y < LookAndFeel.ColumnHeadingHeight)
	{
		Click(X, Y);
	}
	else if ( bAllowDoubleClick )
	{
		Row = ((Y - LookAndFeel.ColumnHeadingHeight) / UWindowGrid(ParentWindow.ParentWindow).RowHeight) + UWindowGrid(ParentWindow.ParentWindow).TopRow;
		UWindowGrid(ParentWindow.ParentWindow).DoubleClickRow(Row);
	}
}

function MouseLeave()
{
	Super.MouseLeave();
	UWindowGrid(ParentWindow.ParentWindow).MouseLeaveColumn(Self);
}

defaultproperties
{
	bAllowDoubleClick=true
}
