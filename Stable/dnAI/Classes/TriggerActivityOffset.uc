class TriggerActivityOffset expands Triggers;

var Pawn MyBot;

function Touch( actor Other )
{}

function Trigger( actor Other, Pawn Instigator )
{
	log( self$" Triggered" );
	if( Instigator.IsA( 'BUDDBot' ) )
	{
		MyBot = Instigator;
		GotoState( 'MoveBot' );
	}
}

state MoveBot
{
Begin:
	MyBot.SetPhysics( PHYS_Flying );	
	MyBot.MoveTo( MyBot.Location + vect( 0, 0, 64 ), 1.0 );
}

DefaultProperties
{
	bCollideActors=false
	CollisionHeight=0
	CollisionRadius=0
}

