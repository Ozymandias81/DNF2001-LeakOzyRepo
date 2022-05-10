/*-----------------------------------------------------------------------------
	dnPawnFreeze
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class dnPawnFreeze extends ActorFreeze;

var class<Actor>	BodyBlockClass;
var Actor			BodyBlock;
var class<Actor>	LeftArmBlockClass, RightArmBlockClass;
var Actor			LeftArmBlock, RightArmBlock;
var class<Actor>	LegsBlockClass;
var Actor			LegsBlock;

function AttachEffect( Actor Other )
{
	local MeshInstance minst;
	local int i;

	Super.AttachEffect( Other );

	// Attach body effect.
	BodyBlock = spawn( BodyBlockClass, Self,, Location );
	BodyBlock.AttachActorToParent( Owner );

	LeftArmBlock = spawn( LeftArmBlockClass, Self,, Location );
	LeftArmBlock.AttachActorToParent( Owner );

	RightArmBlock = spawn( RightArmBlockClass, Self,, Location );
	RightArmBlock.AttachActorToParent( Owner );

	LegsBlock = spawn( LegsBlockClass, Self,, Location );
	LegsBlock.AttachActorToParent( Owner );
	LegsBlock.MountOrigin.Z -= 10;

	if ( Other.IsA('Pawn') && !Other.IsA('PlayerPawn') )
		Pawn(Other).GotoState( 'Frozen' );
}

defaultproperties
{
	BodyBlockClass=class'FrozenBlockBody'
	LeftArmBlockClass=class'FrozenBlockLeftArm'
	RightArmBlockClass=class'FrozenBlockRightArm'
	LegsBlockClass=class'FrozenBlockLegs'
}