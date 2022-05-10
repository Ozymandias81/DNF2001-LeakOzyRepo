//=============================================================================
// 
// FILE:			UDukeNetTabWindowChat.uc
// 
// AUTHOR:			Scott Alden
// 
// DESCRIPTION:		DukeNet Chat Client
// 
//=============================================================================

class UDukeNetTabWindowChat expands UDukeNetTabWindow;

var		UWindowVSplitter			winVSplitter;
									
var		UDukeNetTextArea			txtMessagesArea;
var		UDukeNetTextArea			txtSystemArea;
									
var		UWindowEditControl			editNewChannel;
var		localized string			editNewChannelText;
var		localized string			editNewChannelHelp;

var		UDukeNetChannelListBox		listChannels;
var		UDukeNetUserListBox			listUsers;

var     Texture                     texDukeIcon;

var     UWindowEditControl          chatCommands;

var     UWindowLabelControl         ChannelsLabel;
var     localized string            ChannelsText;
var     localized string            ChannelsHelp;

var     UWindowLabelControl         UsersLabel;
var     localized string            UsersText;
var     localized string            UsersHelp;

const WidthFactor = 0.8f;

function Created() 
{
	local float fListLeft; 
	local INT   iSplitAreaHeight;
    local INT   XOffset, YOffset, ControlWidth, ControlHeight;
	
    Super.Created();
	
	texDukeIcon = Texture(DynamicLoadObject("DukeLookAndFeel.DukeIcon", class'Texture'));
	
	
	fListLeft = WinWidth * WidthFactor;	

	chatCommands = UWindowEditControl( CreateControl( class'UWindowEditControl', 
													  0, WinHeight-16, 
													  fListLeft, 16
                                                    ) );
	chatCommands.SetFont( F_Normal );
	chatCommands.SetNumericOnly( false );
	chatCommands.SetMaxLength( 80 );
	chatCommands.SetHistory( true );

	iSplitAreaHeight = WinHeight - chatCommands.WinHeight;

    XOffset          = fListLeft;
    ControlWidth     = WinWidth - fListLeft;

    // Channels Label
    ChannelsLabel   = UWindowLabelControl( CreateControl( class'UWindowLabelControl',
                                                          XOffset,
                                                          YOffset,
                                                          ControlWidth,
                                                          16 ) );
    ChannelsLabel.SetText( ChannelsText);
    ChannelsLabel.SetHelpText( ChannelsHelp );
    ChannelsLabel.SetFont( F_Normal );
    ChannelsLabel.Align = TA_Center;

    YOffset += ChannelsLabel.WinHeight;

    ControlHeight = ( iSplitAreaHeight / 2 ) + 64;
    
    // Channels List
	listChannels = UDukeNetChannelListBox( CreateControl( class'UDukeNetChannelListBox',
													      XOffset,
                                                          YOffset,
													      ControlWidth,
                                                          ControlHeight,
													      self ) );
    listChannels.SetHelpText( ChannelsHelp );

    YOffset += listChannels.WinHeight;

    // Users Label
    UsersLabel   = UWindowLabelControl( CreateControl( class'UWindowLabelControl',
                                                       XOffset,
                                                       YOffset,
                                                       ControlWidth,
                                                       16 ) );
    UsersLabel.SetText( UsersText );
    UsersLabel.SetHelpText( UsersHelp );
    UsersLabel.SetFont( F_Normal );
    UsersLabel.Align = TA_Center;

    YOffset += UsersLabel.WinHeight;

    // Users List
	listUsers = UDukeNetUserListBox( CreateWindow( class'UDukeNetUserListBox', 
									  			   XOffset,
                                                   YOffset,
												   ControlWidth,
                                                   ControlHeight,
												   self ) );

    YOffset += listUsers.WinHeight;

    // New Channel Edit Box
    editNewChannel   = UWindowEditControl( CreateControl( class'UWindowEditControl', 
					  									  XOffset, 
                                                          YOffset, 
					  									  ControlWidth,
                                                          16 ) );

	editNewChannel.SetNumericOnly( true );
	editNewChannel.SetAlphaOnly( true );
	editNewChannel.SetHistory( false );
	editNewChannel.SetFont( F_Normal );
	editNewChannel.SetMaxLength( 32 );
    editNewChannel.SetText( editNewChannelText );
    editNewChannel.SetHelpText( editNewChannelHelp );
    editNewChannel.Align = TA_Left;

    YOffset         += editNewChannel.WinHeight;

    // Splitter
	winVSplitter = UWindowVSplitter( CreateWindow( class'UWindowVSplitter', 
												   0,
                                                   0, 
												   WinWidth,
                                                   iSplitAreaHeight ) );
	
    // Text Messages Area
	txtMessagesArea = UDukeNetTextArea(	winVSplitter.CreateWindow( class'UDukeNetTextArea',
												                   0,
                                                                   0,
												                   fListLeft,
                                                                   iSplitAreaHeight,
												                   self ) );

    // Text System Area
	txtSystemArea = UDukeNetTextArea( winVSplitter.CreateWindow( class'UDukeNetTextArea',
											                     0,
                                                                 0,
											                     fListLeft,
                                                                 16 * 4,	//at least 4 lines to start
											                     self ) );

	// Make system area text, look like system green text
	txtSystemArea.TextColor.R       = 0;
	txtSystemArea.TextColor.G       = 128;
	txtSystemArea.TextColor.B       = 0;

	winVSplitter.TopClientWindow    = txtMessagesArea;
	winVSplitter.BottomClientWindow = txtSystemArea;
	winVSplitter.SplitPos           = txtMessagesArea.WinHeight - txtSystemArea.WinHeight;
	winVSplitter.MinWinHeight       = 0;
	winVSplitter.bSizable           = true;
	winVSplitter.bBottomGrow        = true;
}

function AfterCreate()
{
    Super.AfterCreate();
    chatCommands.FocusWindow();
}

function UWindowDynamicTextRow AddText( string strText )
{
	local INT iIndex;
	local UDukeNetUserItem itemUser;
	local UDukeColoredDynamicTextRow dnTextRow;
	local float fOldVertPos;

	fOldVertPos = txtMessagesArea.VertSB.Pos;

	//Add the text to the message/chat text window
	dnTextRow = UDukeColoredDynamicTextRow( txtMessagesArea.AddText( strText ) );

	//If we just added a UDukeColoredDynamicTextRow, setup the colors and length of label
	if ( dnTextRow != None )
    {
		iIndex = InStr( strText, ": " );

		if ( iIndex > 0 )
        {
			dnTextRow.iLengthOfLabel = iIndex + 1;	//want to include ":"
			itemUser = listUsers.FindUser( Left( strText, iIndex ) );
			
			//Calculate the user label's color, and its body text color
			if ( itemUser != None )
            {
				dnTextRow.colorLabelText = itemUser.colorIdentifier;
				dnTextRow.colorBodyText  = itemUser.colorData;
			}
			else  
            {
				Log( "DUKENET: Error, could not find user name of " $ Left(strText, iIndex ) );
            }
		}
		else
        {
			Log( "DUKENET: Couldn't find label start in string - " $ strText );
        }
	}
}

function DoChatCommand()
{
    if( IsValidString( chatCommands.GetValue() ) )
    {
	    if(	UDukeNetCW( ParentWindow ).dnClient != None)  
        {
		    UDukeNetCW( ParentWindow ).dnClient.Message( chatCommands.GetValue() );
        }
	    else
        {
		    Log("DUKENET: Invalid dnClient value " $ UDukeNetCW( ParentWindow ).dnClient, Name);
        }

	    chatCommands.Clear();
    }
}

function DoNewChannel()
{
	if ( IsValidString(editNewChannel.GetValue() ) )
	{
		if(	UDukeNetCW( ParentWindow ).dnClient != None )  
        {
			UDukeNetCW( ParentWindow ).dnClient.Message( "/CHANNEL:" $ editNewChannel.GetValue() );
        }
		else
        {
			Log( "DUKENET: Invalid dnClient value " $ UDukeNetCW( ParentWindow ).dnClient, Name );
        }
		editNewChannel.Clear();
	}
}

function Notify( UWindowDialogControl C, byte E )
{
	Super.Notify(C, E);

	switch ( E )
	{
	case DE_EnterPressed:
		switch ( C )
		{
		case chatCommands:
            DoChatCommand();
			break;
		case editNewChannel:
            DoNewChannel();
            break;
		}
		break;
	case DE_WheelUpPressed:
		switch ( C )
		{
		case chatCommands:
			txtMessagesArea.VertSB.Scroll( -1 );
			break;
		}
		break;
	case DE_WheelDownPressed:
		switch ( C )
		{
		case chatCommands:
			txtMessagesArea.VertSB.Scroll( 1 );
			break;
		}
		break;
	}
}

function BeforePaint( Canvas C, float X, float Y )
{
	local int   iSplitHeight;
    local int   YOffset;
    local int   ListHeight;
    local int   LeftWidth, RightWidth;

	Super.BeforePaint( C, X, Y );

	LeftWidth  = WinWidth * WidthFactor;
	RightWidth = WinWidth - LeftWidth;

	chatCommands.SetSize( LeftWidth, chatCommands.WinHeight );
	chatCommands.EditBoxWidth   = chatCommands.WinWidth;
    iSplitHeight                = WinHeight - chatCommands.WinHeight;
	chatCommands.WinTop         = iSplitHeight;		    

    listHeight = ( WinHeight - (  ChannelsLabel.WinHeight + UsersLabel.WinHeight + editNewChannel.WinHeight ) ) / 2;

    // Channels Label
    ChannelsLabel.SetSize( RightWidth, ChannelsLabel.WinHeight );
    ChannelsLabel.WinLeft       = WinWidth - ChannelsLabel.WinWidth;
    ChannelsLabel.WinTop        = YOffset;
    
    YOffset += ChannelsLabel.WinHeight;

    // Channel List
	listChannels.SetSize( RightWidth, ListHeight );
	listChannels.WinLeft        = chatCommands.WinWidth;
    listChannels.WinTop         = YOffset;

    YOffset += listChannels.WinHeight;

    // Users Label
    UsersLabel.SetSize( RightWidth, UsersLabel.WinHeight );
    UsersLabel.WinLeft       = WinWidth - UsersLabel.WinWidth;
    UsersLabel.WinTop        = YOffset;    

    YOffset += UsersLabel.WinHeight;

    // User List
    listUsers.SetSize( RightWidth, ListHeight );
	listUsers.WinLeft           = chatCommands.WinWidth;
    listUsers.WinTop            = YOffset;

    YOffset += listUsers.WinHeight;
	
	// New Channel Edit Box
    editNewChannel.SetSize( RightWidth-5, editNewChannel.WinHeight );
	editNewChannel.EditBoxWidth = editNewChannel.WinWidth / 2;
    editNewChannel.WinLeft      = WinWidth - editNewChannel.WinWidth;
    editNewChannel.WinTop       = YOffset;

    YOffset += editNewChannel.WinHeight;

    // Text Messages
    txtMessagesArea.SetSize( LeftWidth, iSplitHeight );
	
    // System Messages
    txtSystemArea.SetSize( LeftWidth, iSplitHeight );
	
    // Splitter
    winVSplitter.SetSize( LeftWidth, iSplitHeight );
}


function Paint( Canvas C, float X, float Y )
{
	//draw opaque black backdrop for each text area
	DrawStretchedTexture( C, 
						  txtMessagesArea.WinLeft, txtMessagesArea.WinTop, 
						  txtMessagesArea.WinWidth, txtMessagesArea.WinHeight, 
						  Texture'BlackTexture', 
						  1.0f	//opaque
	                    );

	DrawStretchedTexture( C, 
						  txtSystemArea.WinLeft, txtSystemArea.WinTop, 
						  txtSystemArea.WinWidth, txtSystemArea.WinHeight, 
						  Texture'BlackTexture', 
						  1.0f	//opaque
	                    );
}


defaultproperties
{
     editNewChannelText="New Channel"
     editNewChannelHelp="Type in the name of a new channel to create."
	 bBuildDefaultButtons=false
	 bNoScanLines=true
	 bNoClientTexture=true
     ChannelsText="Channels"
     ChannelsHelp="A list of channels on DukeNet, double click a channel to join it"
     UsersText="Users"
     UsersHelp="A list of users in the current DukeNet channel"
}
