/*-----------------------------------------------------------------------------
	AddEmailTrigger
	Author: Brandon Reinhart

	"It is a work of pure genius! Absolute MADNESS! MUAHAHAHAHAHAHAAHA"
-----------------------------------------------------------------------------*/
class AddEmailTrigger extends Triggers;

var () string	FromAddress;
var () string	Subject;
var () string	TextLines[10];

function Trigger( actor Other, pawn EventInstigator )
{
	local dnEmailSystem DES;

	foreach AllActors( class'dnEmailSystem', DES, Event )
	{
		DES.AddMessage( Self );
	}
}