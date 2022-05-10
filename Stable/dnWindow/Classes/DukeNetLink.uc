//==========================================================================
// 
// FILE:			DukeNetLink.uc
// 
// AUTHOR:			Scott Alden
// 
// DESCRIPTION:		Created to be an interface between DukeNet client and windowing
// 
//==========================================================================
class DukeNetLink expands DukeNet;

var UDukeNetCW winClient;

const eSTATUS_CHANGE_ERROR  = -2;				// problem with status change on an item
const eSTATUS_CHANGE_REMOVE = -1;				// Remove an item
const eSTATUS_CHANGE_FLUSH  = 0;				// flush/remove all items
const eSTATUS_CHANGE_ADD    = 1;				// Add an item

var()	string	strCDKey;						// TEMP: remove or get from DukeNet once CDReg checking is in

var		INT		iNumMessagesSinceLastTick;		// # of messages that this client has sent
var()	INT		iMaxMessagesAllowed;			// Max # of allowed messages before being sent to spammer hell
var		float	fTimeSinceLastSpamCheck;		// amount of time that has passed since we've checked
												// the client for spamming too much
var()	float	fTimeIntervalToCheckSpamming;	// How much time to wait before spam checking

function SetClient( UDukeNetCW winNewClient )
{
	//TLW: TODO: Any other things to turn off?
	Log( "DUKENET: Set winClient to " $ winNewClient, Name );
	winClient = winNewClient;

	//TLW: TODO: get CDKey from intrinsic call or user input
	//Setup the registeration, before doing anything
	Message( "/REGISTER:" $ strCDKey );
}

function ClientClosing()
{
	//TLW: TODO: Any other things to turn off?
	Log( "DUKENETLINK: ClientClosing() was called" );
	winClient = None;
}

function Message( string strOutgoing )
{
	local INT iIndex;
	local string strReservedWord;

	//Only send the string, if there is something to send
	if ( IsValidString( strOutgoing ) )  
    {	
		iIndex = InStr( strOutgoing, ":" );
		if ( iIndex > 0 )
        {
			strReservedWord = Caps( Mid( strOutgoing, iIndex + 1 ) );
			if(	strReservedWord == "ON" ||
			//	strReservedWord == "FLUSH" ||	can't send to server anyway
				strReservedWord == "OFF" 
			)  
            {
				Log("DUKENETLINK: Can't send " $ strReservedWord $ 
					" to the server(reserved for commands) with the command " $ Left(strOutgoing, iIndex) 					
				);
				return;	//don't send
			}
		}
	
	//	Log("DUKENETLINK: Sending outgoing message unformatted to server - " $ strOutgoing);
		dncCommand( strOutgoing );
		if ( Left( strOutgoing, 1 ) != "/" )
        {
			iNumMessagesSinceLastTick++;	//if not a command, increment the count
        }
	}
}

function Tick( float DeltaSeconds )
{
	Super.Tick( DeltaSeconds );
	
	fTimeSinceLastSpamCheck += DeltaSeconds;

	if(	fTimeSinceLastSpamCheck > fTimeIntervalToCheckSpamming ) 
    {
	//	Log("DUKENETLINK: #Messages=" $ iNumMessagesSinceLastTick $
	//		", TimePassed=" $ fTimeSinceLastSpamCheck
	//	);

		fTimeSinceLastSpamCheck -= fTimeIntervalToCheckSpamming;
		
		//Check for spammers sending too many messages and clogging bandwidth just to scroll text 
		if ( iNumMessagesSinceLastTick > iMaxMessagesAllowed )  
        {		
			//Double-check time interval, see if its valid. if its been more
			//	than 1 minute, let it slide
			if ( fTimeSinceLastSpamCheck < 60 )
            {
				Message( "/CHANNEL:spammerhell" );
				winClient.MessageBox( "SpammersRLame", "ALL spammers must die!", MB_Ok, MR_None, MR_None, 50 ); 
			}
			else  
            {
				Log( "DUKENETLINK: Time interval was too great, lag rather than spamming? (secs=" $ fTimeSinceLastSpamCheck + fTimeIntervalToCheckSpamming );
				fTimeSinceLastSpamCheck = 0;
			}		
		}		
		iNumMessagesSinceLastTick = 0;
	}
}

event dncServerCommand( string command )
{
//	Log("DUKENETLINK: Received <" $ command $ ">", Name);

	if(  winClient != None &&
	 	!ParseTextForCommand( command ) &&
	 	!ParseTextForSystem( command )
      )
    {
		winClient.winTabClientChat.AddText( command );
    }

	Super.dncServerCommand(command); 
}

function bool ParseTextForCommand( string strInput )
{
	local int iIndex;
	local bool bParsedCommand;
	local string strParse;
	local string strCommand;

	//check the first char
	strParse = Left( strInput, 1 );

	if(strParse == "/")
    {
		strParse = Mid( strInput, 1 );

	//	Log("DUKENETLINK: Received command - " $ strParse);
	
		iIndex = InStr( strParse, ":" );
		if ( iIndex > 0 )
        {
			strCommand = Left( strParse, iIndex );
			strParse   = Mid( strParse, iIndex + 1 );
		}
		else  
        {
			strCommand = strParse;
        }
			
		bParsedCommand = true;
		Log( "DUKENETLINK: Command=" $ strCommand $ ", strRemainder=" $ strParse );
		
        switch(strCommand)  
        {			
			case "PING"		: Message( "/PONG" );	                            break;
			case "PONG"		: Log( "DUKENETLINK: received pong from server" );	break; 
                
			case "USER" 	: UserStatusChange( strParse );	    break;
			case "CHANNEL" 	: ChannelStatusChange( strParse );	break;
			case "GAME" 	: GameStatusChange( strParse );	    break;
			
			case "BANNER" 	: winClient.URLBanner( strParse );	break;
			case "MOTD" 	: winClient.URLNews( strParse );  	break;
			
			default			: Log( "DUKENETLINK: Unknown command " $ strCommand, Name );
							  bParsedCommand = false;
							  break;  
		}
	}
	
	return bParsedCommand;	//parsed a command or not
}

function bool ParseTextForSystem( string strInput )
{
	local int iIndex;
	local string strMessage;
	local string strCommand;

	iIndex = InStr( strInput, ":" );

	if ( iIndex > 0 )
    {
		strCommand = Left( strInput, iIndex );
		strMessage = Mid( strInput, iIndex + 2 );	//skip ": "

		//Check for system command in string		
		if ( strCommand == "System" )
        {
			winClient.SystemText( strMessage );
			return true;	//parsed a system command or message
		}
	}
	return false;	//did not parse a system command or message
}

function INT GetStatusChange( string strInToParse )
{
	local string strFirstChar;

	//Data strings of commands are prefixed with + or - to indicate the type of change
	//	strip that out and return with one it is
	strFirstChar = Left( strInToParse, 1 );

	if ( strFirstChar == "+" )		return eSTATUS_CHANGE_ADD;
	if ( strFirstChar == "-" )		return eSTATUS_CHANGE_REMOVE;
	if ( strInToParse == "flush" )	return eSTATUS_CHANGE_FLUSH;

	//not a valid status change type, return the error code
//	Log("DUKENETLINK: GetStatusChange wasn't passed a valid Add, Remove or Flush " $ strInToParse);
	return eSTATUS_CHANGE_ERROR;
}

function UserStatusChange( string strInput )
{
	//Data strings of commands are prefixed with +/- or flush to indicate the type of change
	//	strip that out and return with one it is
	switch ( GetStatusChange( strInput ) )
    {
		case eSTATUS_CHANGE_ADD 	:	winClient.AddUser( Mid( strInput, 1 ) );    break;
		case eSTATUS_CHANGE_REMOVE 	:	winClient.RemoveUser( Mid( strInput, 1 ) );	break;
		case eSTATUS_CHANGE_FLUSH	:	winClient.RemoveAllUsers();		            break;
		default						:	Log( "DUKENETLINK: Name change ", Name );
										winClient.ChangeClientsUserName( strInput );
										break;
	}
}

function ChannelStatusChange( string strInput )
{
	//Data strings of commands are prefixed with +/- or nothing to indicate the type of change
	//	strip that out and return with one it is
	switch ( GetStatusChange( strInput ) )
    {
		case eSTATUS_CHANGE_ADD		:	winClient.AddChannel( Mid( strInput, 1 ) );	    break;
		case eSTATUS_CHANGE_REMOVE	:  	winClient.RemoveChannel( Mid(strInput, 1 ) );	break;
	//	case eSTATUS_CHANGE_FLUSH	:  	winClient.RemoveAllChannels( strName );	        break;
		default						:	Log( "DUKENETLINK: Channel join ", Name );
										winClient.ClientJoinChannel( strInput );
										break;
	}
}

function GameStatusChange( string strInput )
{
	//Password for add game..???
	switch ( GetStatusChange( strInput ) )
    {
		case eSTATUS_CHANGE_ADD		:	winClient.AddGame( Mid( strInput, 1 ), "" );	break;
		case eSTATUS_CHANGE_REMOVE	:  	winClient.RemoveGame( Mid( strInput, 1 ) );	    break;
	//	case eSTATUS_CHANGE_FLUSH	:  	winClient.RemoveAllGames( strName );	        break;
		default						:	Log( "DUKENETLINK: Invalid status for GameStatusChange: ", Name );
										break;
	}
}

defaultproperties
{
     strCDKey="ADYE-B3N9-PZ4E-SA7Y"
     iMaxMessagesAllowed=2
     fTimeIntervalToCheckSpamming=2.500000
}
