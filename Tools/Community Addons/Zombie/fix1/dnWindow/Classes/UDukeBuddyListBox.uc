class UDukeBuddyListBox expands UWindowListBox;

var     UDukeRightClickBuddyMenu		Menu;

function Created()
{
	Super.Created();

	Menu = UDukeRightClickBuddyMenu( Root.CreateWindow( class'UDukeRightClickBuddyMenu', 
									                    0, 0, 100, 100, self ) );
	Menu.HideWindow();
	Menu.ServerFilter = UDukeServerFilterCW( GetParent( class'UDukeServerFilterCW' ) );
	Menu.BuddyListBox = self;
}

function DrawItem( Canvas C, UWindowList Item, float X, float Y, float W, float H )
{	
	UDukeLookAndFeel( LookAndFeel ).List_DrawItem( self, C, X,Y,W,H, UDukeBuddyList( Item ).PlayerName, UDukeBuddyList( Item ).bSelected );
}

function Paint( Canvas C, float X, float Y )
{
	Super.Paint( C, X, Y );

	DrawMiscBevel( C, 0, 0, WinWidth, WinHeight, GetLookAndFeelTexture(), 1 );
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
     ItemHeight=13.000000
     ListClass=Class'dnWindow.UDukeBuddyList'
}
