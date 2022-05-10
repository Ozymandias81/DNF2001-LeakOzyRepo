/*-----------------------------------------------------------------------------
	DrawActorMount
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class DrawActorMount extends InfoActor;

simulated function MountedActor( Actor Mountee )
{
	if ( Mountee == None )
		return;
	if ( PlayerPawn(Mountee) == None )
		return;
	PlayerPawn(Mountee).OverlayActor = MountParent;
	MountParent.bHidden = true;
}

defaultproperties
{
	bHidden=true
}