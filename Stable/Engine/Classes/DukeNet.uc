//=============================================================================
// DukeNet Client.
//
// Client -> Server Commands:
//  PING						- causes server to send a 'PONG'
//  PONG						- in response to a server 'PING'
//  MSG							- sends a private message to another client.
//  USER:ON						- turns client listing update on.
//  USER:OFF					- turns client listing update off.
//  USER:<name>					- set this client's name.
//  CHANNEL:ON					- turns client channel listing update on.
//  CHANNEL:OFF					- turns client channel listing update off.
//  CHANNEL:<name>				- changes client to the given channel.
//  GAME:ON						- turns on the list of games.
//  GAME:OFF					- turns off the list of games.
//  GAME:<info>					- Sends the info for my game.
//  CHAT:ON						- Turn on channel chat update.
//  CHAT:OFF					- Turn off channel chat update.
//	REGISTER:RegistrationKey	- Sends the user's registration key.
//
// Server -> Client Commands:
//  PING            - causes client to send a 'PONG'
//  PONG            - in response to a client 'PING'
//  USER:+<name>    - client has been added to the current channel.
//  USER:-<name>    - client has been removed from the current channel.
//  USER:<name>		- your user name has been changed to this.
//  USER:flush		- empty the entire user list (instead of a hoard of /USER:-'s)
//  CHANNEL:+<name> - channel has been added
//  CHANNEL:-<name> - channel has been removed
//	CHANNEL:<name>  - your channel has been changed to this.
//  GAME:+<info>    - game has been added
//  GAME:-<info>    - game has been removed
//  BANNER:<url>	- display the given advertising banner (URL)
//	MOTD:<url>		- display the following message of the day (URL)
//
// Game String Format:
//	<IP>:<Port>,Game Name,Game Map,Game Type,<frag limit>,<Current # Players>,<Max # Players>,Note
//
// Examples:
//	192.168.0.1:8102,Nick's Game of Death,Morpheus.Dnf,JumpMatch,100,3,16,This game rocks!
//
//
//=============================================================================
class DukeNet expands InfoActor
	native;

var globalconfig string CDKey;
enum EConnectionStatus
{
	EDNC_CONNECTING,
	EDNC_CONNECTED,
	EDNC_DISCONNECTED
};

var string DisconnectReason;			// Reason the disconnection occured.

// The server address and port.
var string DefaultServerAddress;
var int	   DefaultServerPort;

var EConnectionStatus ConnectionState;	// Current connection state.

// Interface to the internal DukeNet client: 
native final function dncInitialize(string ServerAddress, int Port);
native final function dncShutdown();
native final function EConnectionStatus dncUpdate();
native final function dncCommand(string command);
native final function URLDownloadBanner(string URL,texturecanvas left,texturecanvas right);

// On creation of this object initialize and create a connection to dukenet
function Spawned()
{
	ConnectionState=EDNC_DISCONNECTED;						// Assume disconnected to start
	dncInitialize(DefaultServerAddress,DefaultServerPort);	// Connect to server
}

// On destruction of this object, shut down my connection to dukenet
function Destroyed()
{
	dncShutdown();
	ConnectionState=EDNC_DISCONNECTED;
}

// Update the network connection each tick.
function Tick( float DeltaSeconds )
{
	local EConnectionStatus previousConnectionState;
	local string stateName;

	previousConnectionState=ConnectionState;
	ConnectionState=dncUpdate();
	if(previousConnectionState!=ConnectionState)
	{
		switch(ConnectionState)
		{
			case EDNC_CONNECTING:	stateName="Connecting";								break;
			case EDNC_CONNECTED:	stateName="Connected";								break;
			case EDNC_DISCONNECTED: stateName="Disconnected - reason"$DisconnectReason; break;
			default:				stateName="Unknown";								break;
		}

		BroadcastMessage("Dukenet State Changed:"$stateName);
	}
	
}

event dncServerCommand(string command)
{
	BroadcastMessage(command);
}

defaultproperties
{
	ConnectionState=EDNC_DISCONNECTED
	DefaultServerAddress="dukenet.3drealms.com"
	DefaultServerPort=4662
	bAlwaysTick=True
	DisconnectReason="unknown"
}
	