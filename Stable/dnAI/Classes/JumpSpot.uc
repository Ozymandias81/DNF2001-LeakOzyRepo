//=============================================================================
// JumpSpot.
// specifies positions that can be reached in jumpmatch or with jumpboots or translocator
//=============================================================================
class JumpSpot extends Info;

function Touch( actor Other )
{
	log( "Touched: "$other );
	if( Other.IsA( 'HumanNPC' ) )
	{
		HumanNPC( Other ).BigJump( self );
		Disable( 'Touch' );
		SetTimer( 5.0, false );
	}
}

function Timer( optional int TimerNum )
{
	SetCollision( true, true );
	SetCollisionSize( Default.CollisionRadius, Default.CollisionHeight );
}


DefaultProperties
{
	bCollideActors=true
	bCollideWorld=true
	CollisionHeight=32
	CollisionRadius=32
}
