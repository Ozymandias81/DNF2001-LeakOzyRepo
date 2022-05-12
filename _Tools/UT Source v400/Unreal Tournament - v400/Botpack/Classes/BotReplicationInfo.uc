//=============================================================================
// BotReplicationInfo.
//=============================================================================
class BotReplicationInfo extends PlayerReplicationInfo;

var Actor OrderObject;
var name RealOrders;
var pawn RealOrderGiver;
var PlayerReplicationInfo RealOrderGiverPRI;
replication
{
	// Things the server should send to the client.
	unreliable if ( Role == ROLE_Authority )
		RealOrders, RealOrderGiverPRI, OrderObject;
}

function SetRealOrderGiver(Pawn P)
{
	RealOrderGiver = P;
	if ( P != None )
		RealOrderGiverPRI = P.PlayerReplicationInfo;
	else
		RealOrderGiverPRI = None;
}

defaultproperties
{
	bIsABot=true
}
