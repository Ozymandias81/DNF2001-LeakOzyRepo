class UDukeBuddyListBox expands UWindowListBox;

var     UDukeRightClickBuddyMenu		Menu;

function Created()
{
	Super.Created();

	Menu = UDukeRightClickBuddyMenu( Root.CreateWindow( class'UDukeRightClickBuddyMenu', 0, 0, 100, 100, self ) );
	Menu.HideWindow();
	Menu.ServerFilter = UDukeServerFilterCW( GetParent( class'UDukeServerFilterCW' ) );
	Menu.BuddyListBox = self;
}

function DrawItem( Canvas C, UWindowList Item, float X, float Y, float W, float H )
{
	C.Font = Root.Fonts[F_Normal];
	C.DrawColor = LookAndFeel.GetTextColor( Self );

	if ( !UDukeBuddyList(Item).bSelected )
	{
		C.DrawColor.R = 3 * (C.DrawColor.R / 4);
		C.DrawColor.G = 3 * (C.DrawColor.G / 4);
		C.DrawColor.B = 3 * (C.DrawColor.B / 4);
	}

	ClipText( C, X, Y, UDukeBuddyList( Item ).PlayerName );
}

function RMouseDown(float X, float Y)
{
	Super.RMouseDown( X, Y );

	if(SelectedItem != None)
	{
		SelectedItem.bSelected = False;
		SelectedItem = None;
	}

	SetSelected( X, Y );

	RightClickRow( X, Y, UDukeBuddyList( SelectedItem ) );
}

function RightClickRow( float X, float Y, UDukeBuddyList Sel )
{
    local float MenuX, MenuY;

	WindowToGlobal( X, Y, MenuX, MenuY );

	Menu.WinLeft    = MenuX;
	Menu.WinTop     = MenuY;
	Menu.List       = Sel;	

    Menu.ShowWindow();
}

function DeleteSelection()
{
	// User deleted the selected item
	SelectedItem = None;
}

defaultproperties
{
	ListClass=class'UDukeBuddyList'
	ItemHeight=13
}
