class UDukeLocalFact extends UDukeServerListFactory;

var UDukeLocalLink	    Link;

// Config
var config string		BeaconProduct;
var config int			ServerBeaconPort;

function Query( optional bool bBySuperset, optional bool bInitial )
{
	Super.Query( bBySuperset, bInitial );
	Owner = PingedList;

	// Update status bar
	Owner.Owner.PingFinished();

	Link = GetPlayerOwner().GetEntryLevel().Spawn( class'UDukeLocalLink' );
	
	Link.BeaconProduct      = BeaconProduct;
	Link.ServerBeaconPort   = ServerBeaconPort;
	Link.OwnerFactory       = Self;
	Link.Start();
}

function UDukeServerList FoundServer( string IP, int QueryPort, string Category, string GameName, optional string HostName )
{
	local UDukeServerList l;
	
	l               = Super.FoundServer( IP, QueryPort, Category, GameName );
	l.bLocalServer  = true;

	if ( !l.bPinging )
    {
		l.PingServer( true, true, Owner.Owner.bNoSort );
    }

	return l;
}

function QueryFinished( bool bSuccess, optional string ErrorMsg )
{
	Link.Destroy();
	Link = None;

	Super.QueryFinished( bSuccess, ErrorMsg );	

	// Update status bar
	Owner.Owner.PingFinished();
}

function Shutdown( optional bool bBySuperset )
{
	if ( Link != None )
    {
		Link.Destroy();
    }
	
    Link = None;
	Super.Shutdown( bBySuperset );
}

defaultproperties
{
	BeaconProduct="dnf"
	ServerBeaconPort=8777
	bIncrementalPing=true
}
