/*-----------------------------------------------------------------------------
	SwitchInpatcher
	Author: Brandon Reinhart

	Special inpatcher used with switch decos.
-----------------------------------------------------------------------------*/
class SwitchInpatcher extends Inpatcher;

var dnSwitchDecoration MySwitch;

function Trigger( actor Other, pawn EventInstigator )
{
	MySwitch.Broken( Other, EventInstigator );
}