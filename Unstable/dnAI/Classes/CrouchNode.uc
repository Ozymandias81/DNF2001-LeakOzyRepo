class CrouchNode extends Pathnode;

function Touch( actor Other )
{
	broadcastmessage( "TOUCHED BY "$Other );
	Super.Touch( Other );
}

function Actor SpecialHandling( Pawn Other )
{
	broadcastmessage( "TEST HANDLING FOR "$Other );
}
