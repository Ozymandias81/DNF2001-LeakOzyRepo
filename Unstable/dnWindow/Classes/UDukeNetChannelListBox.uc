//=============================================================================
// UDukeNetChannelListBox
//=============================================================================
class UDukeNetChannelListBox expands UWindowListBox;

var bool bFirstChannelAdded; 
var bool bChannelSelectedByMouse;

var string strChannelJoinRequest;

function UDukeNetChannelItem AddChannel( string strName, string strPassword )
{
	local UDukeNetChannelItem NewChannel;

	NewChannel = UDukeNetChannelItem( Items.Append( Class'UDukeNetChannelItem' ) );
	NewChannel.strName = strName;
	NewChannel.strPassword = strPassword;

	//If this is the first channel added, assume user be in it
	if(	bFirstChannelAdded || strChannelJoinRequest == strName )  
    {
		bFirstChannelAdded = false;
		strChannelJoinRequest = "";
		SetSelectedItem(NewChannel);
	}

	return NewChannel;
}

function JoinChannel( string strName )
{
	//save this name for the additional add that should come later
	strChannelJoinRequest = strName;
}

function UDukeNetChannelItem RemoveChannel( string strName )
{
	local UDukeNetChannelItem itemChannel;

	itemChannel = FindChannel( strName );
	
    if ( itemChannel != None )
    {
		itemChannel.Remove();
    }

	return itemChannel;
}

// Call only on sentinel
function UDukeNetChannelItem FindChannel(string strName)
{
	local UDukeNetChannelItem itemChannel;

	for ( itemChannel = UDukeNetChannelItem( Items.Next ); 
          itemChannel != None; 
          itemChannel = UDukeNetChannelItem( itemChannel.Next )
        )
    {
		if ( itemChannel.strName == strName )
        {
			return itemChannel;
        }
	}

	return None;	//not found
}

function LMouseDown( float X, float Y )
{
	//TLW: Next channel selection is by mouse, not from editbox/typing in command
	bChannelSelectedByMouse = true;
	Super.LMouseDown( X, Y );
}

function SetSelectedItem( UWindowListBoxItem NewSelected )
{
	//Clicked on existing channel, send command to server first before 
	//	selecting/changing to it
	if(	bChannelSelectedByMouse )  
    {
		bChannelSelectedByMouse = false;	//have to reset after sending, or get into an infinite feedback loop
	
		if(	UDukeNetCW( ParentWindow.ParentWindow ).dnClient != None )  
        {
			UDukeNetCW( ParentWindow.ParentWindow ).dnClient.Message( "/CHANNEL:" $ UDukeNetChannelItem( NewSelected ).strName );
        }
		else
        {
			Log("DUKENET: Invalid dnClient value " $ UDukeNetCW(ParentWindow.ParentWindow).dnClient, Name);
        }
	}
	else  
    {
		Super.SetSelectedItem( NewSelected );
    }
}

function Paint( Canvas C, float X, float Y )
{
    Super.Paint( C, X, Y );
    DrawMiscBevel( C, 0, 0, WinWidth, WinHeight, GetLookAndFeelTexture(), 2, 0.9 );
}

function DrawItem( Canvas C, UWindowList Item, float X, float Y, float W, float H )
{
	local string strToDisplay;

    C.DrawColor = UDukeLookAndFeel(LookAndFeel).colorTextUnselected;
	
	strToDisplay = UDukeNetChannelItem(Item).strName;

	if ( SelectedItem == Item )
	{
	//	Draw a background in the unselected color
	//	C.DrawColor = UDukeLookAndFeel(LookAndFeel).colorTextUnselected;
		
        DrawStretchedTexture(C, X, Y, W, H-1, Texture'WhiteTexture', 1.0f);
		
        C.DrawColor = UDukeLookAndFeel(LookAndFeel).colorTextSelected;
		
        strToDisplay = strToDisplay $ " (" $ 
					   UDukeNetCW(ParentWindow.ParentWindow).winTabClientChat.listUsers.iNumUsers $ 
					   ")";
	}

	C.Font = Root.Fonts[F_Bold];

	ClipText( C, X, Y, strToDisplay );

	C.DrawColor.r = 255;
	C.DrawColor.g = 255;
	C.DrawColor.b = 255;
}

defaultproperties
{
     bFirstChannelAdded=True
     ListClass=Class'dnWindow.UDukeNetChannelItem'
}
