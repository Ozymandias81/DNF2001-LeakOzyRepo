/*-----------------------------------------------------------------------------
	InputDecorationTrigger, Internal trigger for input deco's.
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class InputDecorationTrigger extends InternalTrigger;

var InputDecoration MyInputDeco;

function Touch( Actor Other )
{
	if (Other.IsA('PlayerPawn'))
		MyInputDeco.ActivateSaver();
}

function UnTouch( Actor Other )
{
	if (Other.IsA('PlayerPawn'))
		MyInputDeco.DeactivateSaver();
}

defaultproperties
{
	TriggerType=TT_PlayerProximity
	CollisionRadius=200
	CollisionHeight=30
}