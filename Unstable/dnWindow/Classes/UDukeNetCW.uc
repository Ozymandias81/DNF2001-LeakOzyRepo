//==========================================================================
// 
// FILE:			UDukeNetCW.uc
// 
// AUTHOR:			Scott Alden
// 
// DESCRIPTION:		Container for all the DukeNet tabs
//
//==========================================================================
class UDukeNetCW expands UDukePageWindow;

enum eTabType
{
	 eTAB_TYPE_MAIN,
	 eTAB_TYPE_CREATE,
	 eTAB_TYPE_JOIN,
	 eTAB_TYPE_NEWS,
	 
	 eTAB_TYPE_MAX
};

const VERT_OFFSET = 10;
const TAB_OFFSET  = 10;

var()	localized string			strTabsText[4];			//eTAB_TYPE_MAX
var		UDukeTabControl				tabVerticalTabs[4];		//eTAB_TYPE_MAX

var		UDukeNetTabWindowChat		winTabClientChat;
var		UDukeCreateMultiSC   		winTabClientCreate;
var		UDukeJoinMultiSC     		winTabClientJoin;
var		UDukeNetTabWindowNews		winTabClientNews;

var		float						fHeaderAnimCount;
var		Texture						texHeader;				//Used for background for all windows

var		DukeNetLink					dnClient;

function Created() 
{
	local INT i, iButtonPos_Y;
	local string strTexNames[4];
	local string strPlayerName;
	local Texture texButton;
	Super.Created();

	//Used for all client tabs
	texHeader = Texture(DynamicLoadObject("DukeLookAndFeel.DNHeader", class'Texture'));

	strTexNames[0] = "DukeLookAndFeel.DNChannels";	
	strTexNames[1] = "DukeLookAndFeel.DNCreate";
	strTexNames[2] = "DukeLookAndFeel.DNJoin";
	strTexNames[3] = "DukeLookAndFeel.DNNews";

	for ( i = eTabType.eTAB_TYPE_MAIN; i < eTabType.eTAB_TYPE_MAX; i++ )
	{	
		texButton = Texture( DynamicLoadObject(strTexNames[i], class'Texture' ) );

		iButtonPos_Y = ( WinHeight * ( ( i * 2 + 1 ) * 0.125 ) ) - ( texButton.VSize / 2 );

		tabVerticalTabs[i] = UDukeTabControl( CreateWindow( class'UDukeTabControl', 
											     			TAB_OFFSET / 2, iButtonPos_Y, 
												    		texButton.USize, texButton.VSize * 1.2,
													    	self
										    ) );

		tabVerticalTabs[i].UpTexture   = texButton;
		tabVerticalTabs[i].OverTexture = Texture(DynamicLoadObject(strTexNames[i] $ "_fl", class'Texture'));
		tabVerticalTabs[i].DownTexture = texButton;
		tabVerticalTabs[i].SetText(strTabsText[i]);
		tabVerticalTabs[i].TextY = texButton.VSize;
	}

	winTabClientChat = UDukeNetTabWindowChat( CreateWindow(	class'UDukeNetTabWindowChat', 
	   										  tabVerticalTabs[0].WinWidth + TAB_OFFSET, VERT_OFFSET, 
											  WinWidth - tabVerticalTabs[0].WinWidth - TAB_OFFSET, WinHeight - VERT_OFFSET,
											  self
									 		) );
	winTabClientChat.HideWindow();

	winTabClientCreate = UDukeCreateMultiSC( CreateWindow(	class'UDukeCreateMultiSC', 
	   										  tabVerticalTabs[0].WinWidth + TAB_OFFSET, VERT_OFFSET, 
											  WinWidth - tabVerticalTabs[0].WinWidth - TAB_OFFSET, WinHeight - VERT_OFFSET,
											  self
									 	   ) );
	winTabClientCreate.HideWindow();

	winTabClientJoin = UDukeJoinMultiSC( CreateWindow( class'UDukeJoinMultiSC', 
	   										  tabVerticalTabs[0].WinWidth + TAB_OFFSET, VERT_OFFSET, 
											  WinWidth - tabVerticalTabs[0].WinWidth - TAB_OFFSET, WinHeight - VERT_OFFSET,
											  self
									 	   ) );
	
	winTabClientJoin.serverListFactoryType = "dnWindow.UDukeGSpyFact";
	winTabClientJoin.HideWindow();

	winTabClientNews = UDukeNetTabWindowNews( CreateWindow( class'UDukeNetTabWindowNews', 
	   										  tabVerticalTabs[0].WinWidth + TAB_OFFSET, VERT_OFFSET, 
											  WinWidth - tabVerticalTabs[0].WinWidth - TAB_OFFSET, WinHeight - VERT_OFFSET,
											  self
									 		) );
	winTabClientNews.HideWindow();
	//Setup tabs by clicking on the one to have open initially
	//tabVerticalTabs[eTabType.eTAB_TYPE_NEWS].Click( tabVerticalTabs[eTabType.eTAB_TYPE_NEWS].WinLeft, tabVerticalTabs[eTabType.eTAB_TYPE_NEWS].WinTop);

	UDukeRootWindow(Root).Desktop.bHideSunglasses = true;

	//spawn a DukeNetClient if needed
	SpawnADukeNetClient();	
}

function Resized()
{
    local INT i;

    Super.Resized();

    for(i = eTabType.eTAB_TYPE_CREATE; i < eTabType.eTAB_TYPE_MAX; i++)
    {
        tabVerticalTabs[i].WinTop  = ( WinHeight * ( ( i * 2 + 1 ) * 0.125 ) ) - (tabVerticalTabs[i].UpTexture.VSize / 2 );
    }

    winTabClientChat.SetSize( WinWidth - tabVerticalTabs[0].WinWidth - TAB_OFFSET, WinHeight - VERT_OFFSET );
    winTabClientCreate.SetSize( WinWidth - tabVerticalTabs[0].WinWidth - TAB_OFFSET, WinHeight - VERT_OFFSET );
	winTabClientJoin.SetSize( WinWidth - tabVerticalTabs[0].WinWidth - TAB_OFFSET, WinHeight - VERT_OFFSET );
	winTabClientNews.SetSize( WinWidth - tabVerticalTabs[0].WinWidth - TAB_OFFSET, WinHeight - VERT_OFFSET );
}

function SpawnADukeNetClient()  
{	
	local string strPlayerName;

	if( dnClient == None )
	{
		dnClient = GetPlayerOwner().Spawn( class'DukeNetLink' );

		Log( "DUKENET: Created DukeNetLink=" $ dnClient, Name );

		if ( dnClient != None )
		{ 
			dnClient.SetClient( self );
			
			//If there is a valid playername, change the dukenet name to that
			strPlayerName = GetPlayerOwner().PlayerReplicationInfo.PlayerName;

			if ( IsValidString( strPlayerName ) ) 
			{
				dnClient.Message( "/USER:" $ strPlayerName );
			//	winTabClientChat.listUsers.strClientsName = strPlayerName;
			}
		}
	}
	else
	{
		Log( "DUKENET: Already a have valid dnClient (" $ dnClient, Name );
	}
}


function Close( optional bool bByParent )
{
	if ( bByParent )  
	{
		if( dnClient != None ) 
		{
			dnClient.ClientClosing();
			dnClient.Destroy();
		}
	}
	
	UDukeRootWindow(Root).Desktop.bHideSunglasses = false;

	Super.Close( bByParent );
}

function SelectedThisTab( UDukeTabControl tabSelected )
{
	local INT i;
	
	//Want to unselect all the tabs, and hide all the windows,
	for( i = eTabType.eTAB_TYPE_MAIN; i < eTabType.eTAB_TYPE_MAX; i++ )
	{
		tabVerticalTabs[i].bTabIsDown = false;
	}
		
	winTabClientChat.HideWindow();
	winTabClientCreate.HideWindow();
	winTabClientJoin.HideWindow();
	winTabClientNews.HideWindow();

	//...then show the newly selected one
	if(tabSelected == tabVerticalTabs[eTabType.eTAB_TYPE_MAIN])  
		winTabClientChat.ShowWindow();
	else if(tabSelected == tabVerticalTabs[eTabType.eTAB_TYPE_CREATE]) 
		winTabClientCreate.ShowWindow();
	else if(tabSelected == tabVerticalTabs[eTabType.eTAB_TYPE_JOIN]) 
		winTabClientJoin.ShowWindow();
	else if(tabSelected == tabVerticalTabs[eTabType.eTAB_TYPE_NEWS]) 
		winTabClientNews.ShowWindow();
	else  
		Log("DUKENET: ERROR! SelectedThisTab() called with invalid tabtype - " $ tabSelected);
}

function SystemText(string strSysText)
{
	local INT iIndex;
	local UDukeNetChannelItem itemChannel;

/*	TLW: Can't depend on Joined channel for indicating this client successfully joined the channel 
	iIndex = InStr(strSysText, "Joined channel ");
	if(iIndex >= 0)  {
		//index + 15 to get past "Joined channel "
		itemChannel = winTabClientChat.listChannels.FindChannel( Mid(strSysText, iIndex + 15) );  	
		if(itemChannel != None)
			winTabClientChat.listChannels.SetSelectedItem(itemChannel);
		else
			Log("DUKENET: Couldn't find Channel " $ Mid(strSysText, iIndex + 15) $ " to set as joined/selected");
	}
*/
	winTabClientChat.txtSystemArea.AddText( strSysText );
}

function AddUser( string strName )
{
	local UDukeNetUserItem itemNewUser;

	itemNewUser = winTabClientChat.listUsers.AddUser(strName);
	winTabClientChat.listUsers.Items.MoveItemSorted(itemNewUser);
}

function RemoveUser( string strName )
{
	local UDukeNetUserItem itemUserToRemove;

	itemUserToRemove = winTabClientChat.listUsers.RemoveUser( strName );
}

function RemoveAllUsers()
{
	if ( !winTabClientChat.listChannels.bFirstChannelAdded )  
		winTabClientChat.listUsers.FlushList();
}

function ChangeClientsUserName( string strNewName )
{
	local UDukeNetUserItem itemUser;

	winTabClientChat.listUsers.strClientsName = strNewName;
	itemUser = winTabClientChat.listUsers.FindUser( strNewName );

	if ( itemUser != None )
	{  
		winTabClientChat.listUsers.SetSelectedItem( itemUser );
	}
	else
	{
		Log( "DUKENET: Couldn't find client's name in the user list to set " $ strNewName) ;
	}
}

function AddChannel( string strName )
{
	local UDukeNetChannelItem itemNewChannel;

	//TODO: Password?
	itemNewChannel = winTabClientChat.listChannels.AddChannel(strName, "");	
}

function RemoveChannel( string strName )
{
	winTabClientChat.listChannels.RemoveChannel( strName );
}

function ClientJoinChannel( string strNameJoined )
{
	local UDukeNetChannelItem itemChannelJoined;
	itemChannelJoined = winTabClientChat.listChannels.FindChannel( strNameJoined );
	
	if ( itemChannelJoined != None )
	{
		winTabClientChat.listChannels.SetSelectedItem( itemChannelJoined );
	}
	else  
	{
		Log( "DUKENET: Couldn't find channel name in the list to join, waiting for add " $ strNameJoined );
		winTabClientChat.listChannels.JoinChannel( strNameJoined );
	}

	//wipe out old channel traffic to make room for new
	winTabClientChat.txtMessagesArea.Clear();	
}

function AddGame( string strGameString, string strPassword )
{
    /*
	local INT iNumParsed;
	local string strIP;
	local string strGameName;
	local UDukeNetGameItem itemNewGame;

	//Parse the IP address
	strIP = GetNextSubString(strGameString, ":");

	//and removed the Port #
	iNumParsed = INT(GetNextSubString(strGameString));
	
	//and get the game name, before we can create a listbox item
	strGameName = GetNextSubString(strGameString);
	
	if(	IsValidString(strIP) && IsValidString(strGameName))  {
		itemNewGame = winTabClientJoin.listGames.AddGame(strGameName, strPassword);	

		//Setup the IP Address
		itemNewGame.strAddress = strIP;
		itemNewGame.iPort = iNumParsed;
		
		//Set the map name and type
		itemNewGame.strMapName = GetNextSubString(strGameString);
		itemNewGame.strType = GetNextSubString(strGameString);
		
		//set the frag and player #s
		itemNewGame.byteFragLimit = BYTE(GetNextSubString(strGameString));
		itemNewGame.byteNumPlayersCurrent = BYTE(GetNextSubString(strGameString));
		itemNewGame.byteNumPlayersMax = BYTE(GetNextSubString(strGameString));
		
		//and finally set the note to the remainder of the string
		itemNewGame.strNote = strGameString;	//GetNextSubString(strGameString);
		
	    Log("DUKENET: Created Game = " $ itemNewGame.strName $
			", Address=" $ itemNewGame.strAddress $
			":" $ itemNewGame.iPort $
			", Type=" $ itemNewGame.strType 
		);
		Log("DUKENET: FragLimit=" $ itemNewGame.byteFragLimit $
			", Players=" $ itemNewGame.byteNumPlayersCurrent $
			"/" $ itemNewGame.byteNumPlayersMax $
			", Note=" $ itemNewGame.strNote 
		);	
	}
	else 
		Log("DUKENET: ERROR, not enough information to create a game", Name);
	*/
}

function string GetNextSubString( out string strGameString, optional string strStopChar )
{	
	local INT iIndex;
	local string strParsed;
	
	if ( !IsValidString( strStopChar ) )
	{
		strStopChar = ",";
	}
		
	iIndex = InStr(strGameString, strStopChar);

	if ( iIndex > 0 )
	{
		strParsed     = Left( strGameString, iIndex );
		strGameString = Mid( strGameString, iIndex + 1 );
	}
	else 
	{
		Log( "DUKENET: ERROR in game string " $ strGameString );	
		return "";	
	}
	
	return strParsed;
}

function RemoveGame( string strName )
{
	//winTabClientJoin.listGames.RemoveGame(strName);
}

function string GetLocalIPAddress()
{
	return winTabClientNews.httpClient.GetLocalIPAddress();
}

function URLBanner( string strBannerURL )
{
	//TODO: crack this Banner? pull from TextureCanvas?
	winTabClientNews.strURLBanner = strBannerURL;
}

function URLNews( string strNewsURL )
{
	winTabClientNews.SetMOTD( strNewsURL );
}

function Paint( Canvas C, float X, float Y )
{
	Super.Paint(C, X, Y);

	/*
	local INT iCenterPoint;
	local INT iUsableWidth;
	Super.Paint(C, X, Y);
	
	iUsableWidth =  WinWidth - tabVerticalTabs[0].WinWidth - TAB_OFFSET;
	iCenterPoint = 	tabVerticalTabs[0].WinWidth + iUsableWidth / 2 + TAB_OFFSET; 
	
	//TLW: TODO: Need to replace this banner and animation with real banner and anim
	//draw header
	DrawStretchedTextureSegment( C, 
						 		 tabVerticalTabs[0].WinWidth + TAB_OFFSET, 0, 
						 		 iUsableWidth / 2, texHeader.VSize, 
						 		 texHeader.USize - fHeaderAnimCount, 0,
						 		 texHeader.USize, texHeader.VSize, 
						 		 texHeader );

	DrawStretchedTextureSegment( C, 
						 		 iCenterPoint, 0, 
						 		 iUsableWidth / 2, texHeader.VSize, 
						 		 texHeader.USize - fHeaderAnimCount, 0,
						 		 texHeader.USize, texHeader.VSize, 
						 		 texHeader );

	fHeaderAnimCount += 0.666666;	//a little more than a half-pixel to get rid of swimming while panning
	
	if( fHeaderAnimCount > texHeader.USize )
	{
		fHeaderAnimCount = 0;
	}
	*/
}

defaultproperties
{
     strTabsText(0)="Chat"
     strTabsText(1)="Create"
     strTabsText(2)="Join"
     strTabsText(3)="News"
	 bBuildDefaultButtons=false
	 bNoScanLines=true
	 bNoClientTexture=true
}
