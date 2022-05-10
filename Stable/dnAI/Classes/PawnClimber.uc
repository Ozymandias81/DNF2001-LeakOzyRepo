class PawnClimber extends Pawn;

var vector			Dist;
var dnDecoration	MyRope;
var AIClimbControl	Controller;

state Climbing
{
	function BeginState()
	{
		//log( self$" entered climbing state" );
	}

Begin:
	bCanStrafe = true;
	bCanFly = true;
	SetPhysics( PHYS_Flying );
	MoveTo( Location + ( VSize( Dist ) * vect( 0, 0, 1 ) ), 0.85 );
	MyRope.Destroy();
	Destroy();
}

DefaultProperties
{
    DrawType=DT_None
	AirSpeed=400
	CollisionHeight=0
	CollisionRadius=0
	bBlockPlayers=false
	bBlockActors=false
}
