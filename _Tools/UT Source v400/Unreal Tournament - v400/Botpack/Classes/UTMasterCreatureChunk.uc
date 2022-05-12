//=============================================================================
// UTMasterCreatureChunk
//=============================================================================
class UTMasterCreatureChunk extends UTCreatureChunks;

var PlayerReplicationInfo PlayerRep;
var bool bChunked;

replication
{
	// Things the server should send to the client.
	unreliable if( Role==ROLE_Authority )
		PlayerRep;
}


simulated function Tick(float DeltaTime)
{
	if ( PlayerRep != None )
		PlayerOwner = PlayerRep;
	if ( !bChunked && (Physics != PHYS_None) && bBounce && (Level.NetMode == NM_Client) ) //only if client
		ClientExtraChunks();
	bChunked = true;
	Disable('Tick');
}

function Initfor(actor Other)
{
	Super.InitFor(Other);
	if ( Level.NetMode != NM_Client ) //only if server
		ClientExtraChunks();
}

function InitVelocity(Actor Other)
{
	Velocity = Other.Velocity;
	CarcassAnim = Other.AnimSequence;
	CarcHeight = Other.CollisionHeight;
}

defaultproperties
{
	TrailSize=0.5
	CarcHeight=+39.0
}