class UBrowserLocalFact extends UBrowserServerListFactory;

var UBrowserLocalLink	Link;

// Config
var config string		BeaconProduct;
var config int			ServerBeaconPort;

function Query(optional bool bBySuperset, optional bool bInitial)
{
	Super.Query(bBySuperset, bInitial);

	Owner = PingedList;

	// Update status bar
	Owner.Owner.PingFinished();

	Link = GetPlayerOwner().GetEntryLevel().Spawn(class'UBrowserLocalLink');
	
	Link.BeaconProduct = BeaconProduct;
	Link.ServerBeaconPort = ServerBeaconPort;

	Link.OwnerFactory = Self;
	Link.Start();
}

function UBrowserServerList FoundServer(string IP, int QueryPort, string Category, string GameName, optional string HostName)
{
	local UBrowserServerList l;
	
	l = Super.FoundServer(IP, QueryPort, Category, GameName);
	l.bLocalServer = True;

	if(!l.bPinging)
		l.PingServer(True, True, Owner.Owner.bNoSort);

	return l;
}

function QueryFinished(bool bSuccess, optional string ErrorMsg)
{
	Link.Destroy();
	Link = None;

	Super.QueryFinished(bSuccess, ErrorMsg);	

	// Update status bar
	Owner.Owner.PingFinished();
}

function Shutdown(optional bool bBySuperset)
{
	if(Link != None)
		Link.Destroy();
	Link = None;
	Super.Shutdown(bBySuperset);
}

defaultproperties
{
	BeaconProduct="unreal"
	ServerBeaconPort=8777
	bIncrementalPing=True
}
