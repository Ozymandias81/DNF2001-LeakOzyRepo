/*-----------------------------------------------------------------------------
	NewLocationTrigger
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class NewLocationTrigger extends Triggers;

var() string LocationName;

function Trigger( actor Other, pawn EventInstigator )
{
	local int i;
	local DukePlayer P;
	
	foreach AllActors( class'DukePlayer', P )
	{
		DukeHUD(P.MyHUD).RegisterSOSEventMessage( Level.LocationName, LocationName, 128, 512, 2 );
	}
}

defaultproperties
{
	LocationName="Unnamed Location"
}