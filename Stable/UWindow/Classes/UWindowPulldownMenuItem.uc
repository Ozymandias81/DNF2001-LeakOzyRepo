/*-----------------------------------------------------------------------------
	UWindowPulldownMenuItem
-----------------------------------------------------------------------------*/
class UWindowPulldownMenuItem extends UWindowList;

var string					Caption;
var Texture					Graphic;
var byte					HotKey;

var UWindowPulldownMenu		SubMenu;
var	bool					bChecked;
var	bool					bDisabled;

var UWindowPulldownMenu		Owner;
var float					ItemTop;
var int						Index;

function UWindowPulldownMenu CreateSubMenu( class<UWindowPulldownMenu> MenuClass, optional UWindowWindow InOwnerWindow )
{
	SubMenu = UWindowPulldownMenu( Owner.ParentWindow.CreateWindow(MenuClass, 0, 0, 100, 100, InOwnerWindow) );
	SubMenu.HideWindow();
	SubMenu.Owner = Self;
	return SubMenu;
}

function Select()
{
	if ( SubMenu != None && !bDisabled )
	{
		Owner.LookAndFeel.PlayMenuSound( Owner, MS_SubMenuActivate );

		SubMenu.WinLeft = Owner.WinLeft + Owner.WinWidth - Owner.HBORDER;
		SubMenu.WinTop = ItemTop - Owner.VBORDER;

		SubMenu.ShowWindow();
	}
	else
	{
		Owner.LookAndFeel.PlayMenuSound( Owner, MS_OptionHL );
	}
}

function SetCaption( string C )
{
	local string Junk, Junk2;

	Caption = C;
	HotKey = Owner.ParseAmpersand( C, Junk, Junk2, false );
}

function DeSelect()
{
	if ( SubMenu != None )
	{
		SubMenu.DeSelect();
		SubMenu.HideWindow();
	}
}

function CloseUp()
{
	Owner.CloseUp();
}

function UWindowMenuBar GetMenuBar()
{
	return Owner.GetMenuBar();
}