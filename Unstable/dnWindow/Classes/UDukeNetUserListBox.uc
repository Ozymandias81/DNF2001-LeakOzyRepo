//=============================================================================
// 
// FILE:			UDukeNetUserListBox.uc
// 
// AUTHOR:			Timothy L. Weisser
// 
// DESCRIPTION:		Container for users of a single channel
// 
// NOTES:			
//  
// MOD HISTORY: 
// 
//==========================================================================
class UDukeNetUserListBox expands UWindowListBox;

var string strClientsName;		//no longer necessary?
var int iNumUsers;
var int iUserID;

function UDukeNetUserItem AddUser( string strName )
{
	local UDukeNetUserItem NewUser;

	NewUser = UDukeNetUserItem( Items.Append( Class'UDukeNetUserItem' ) );
	NewUser.strName = strName;
	
	//If this is the first user added, assume this is client
	if ( strClientsName == strName )
    {
		Log( "DUKENET: setting clientitem to selected - " $ strName );
		SetSelectedItem( NewUser );
	}

	//TODO: Use the users ID# from the server, not this count
	NewUser.SetUsersColor( iUserID );
	iUserID++;
	iNumUsers++;
	
	return NewUser;
}

function UDukeNetUserItem RemoveUser( string strName )
{
	local UDukeNetUserItem itemUser;

	itemUser = FindUser( strName );
	if ( itemUser != None )
    {  
		itemUser.Remove();
		iNumUsers--;
	}

	return itemUser;
}

function FlushList()
{
	iNumUsers = 0;
	Items.DestroyList();
	Items = new ListClass;
	Items.SetupSentinel();
}

function ChangeName( string strNameOld, string strNameNew )
{
	local UDukeNetUserItem itemUser;
	itemUser = FindUser(strNameOld);
	
    if ( itemUser != None )
    {
		itemUser.strName = strNameNew;
		strClientsName = strNameNew;
		Sort();
	}
}

// Call only on sentinel
function UDukeNetUserItem FindUser( string strName )
{
	local UDukeNetUserItem itemUser;

	for ( itemUser = UDukeNetUserItem(Items.Next); 
          itemUser != None; 
          itemUser = UDukeNetUserItem( itemUser.Next ) )
    {
		if ( itemUser.strName == strName )
			return itemUser;
	}

	return None;	//not found
}

function LMouseDown( float X, float Y )
{
	//Do nothing for now, don't want highlight to change from clients name
}

function Paint( Canvas C, float X, float Y )
{    
    Super.Paint( C, X, Y );
    DrawMiscBevel( C, 0, 0, WinWidth, WinHeight, GetLookAndFeelTexture(), 2, 0.9 );    
}

function DrawItem( Canvas C, UWindowList Item, float X, float Y, float W, float H )
{
	//TODO: Necessary or remove?
	//Draw the player-type icon
	DrawStretchedTexture( C, 
						  X, Y + 1, 
						  8, 8,
						  UDukeNetTabWindowChat( ParentWindow ).texDukeIcon,
                          1.0
	                    );

	C.DrawColor = UDukeLookAndFeel( LookAndFeel ).colorTextUnselected;

	if ( SelectedItem == Item )
	{
	//	Draw a background in the unselected color
	//	C.DrawColor = UDukeLookAndFeel(LookAndFeel).colorTextUnselected;
		DrawStretchedTexture( C, X + 10, Y, W - 10, H, Texture'WhiteTexture', 1.0f );
		C.DrawColor = UDukeLookAndFeel(LookAndFeel).colorTextSelected;
	}

	C.Font = Root.Fonts[F_Normal];
	ClipText( C, X + 10, Y, UDukeNetUserItem( Item ).strName );

	C.DrawColor.r = 255;
	C.DrawColor.g = 255;
	C.DrawColor.b = 255;
}

defaultproperties
{
     ListClass=Class'dnWindow.UDukeNetUserItem'
}
