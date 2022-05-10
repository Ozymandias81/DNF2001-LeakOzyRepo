//=============================================================================
// Transporter.
// NJS: If event is non-None, then it is used to compute the offset 
//		automatically (ie. the offset is the distance from this actor to the 
//		actor named by 'Event').
//=============================================================================
class Transporter extends NavigationPoint;

#exec Texture Import File=Textures\Transporter.pcx Name=S_Transporter Mips=Off Flags=2

var() Vector		Offset;
var() bool			TeleportPlayer;				// If True, teleport all player pawns
var() bool			TeleportInstigator;			// If True, teleport the instigator.
var() bool			TeleportOther;				// If True, teleport 'Other'
var() bool			Retriggerable;				// If True, this teleport may be retriggered.				
var() name			TeleportItemTags[16];		// Teleport these items as well.
var() class<actor>	TeleportItemClasses[16];	// Teleport items of these classes as well.

function Trigger( Actor Other, Pawn EventInstigator )
{
	local PlayerPawn tempPlayer;
	local actor a;
	local int i;

	// Check if I need to compute the offset:
	if(Event!='')
	{
		foreach AllActors( class 'Actor', a, Event )
		{	
			Offset=a.Location-Location;
			break;
		}
	}

	
	// Find the players
	if(TeleportPlayer)
		foreach AllActors( class 'PlayerPawn', tempPlayer )
		{	
			if( !tempPlayer.SetLocation( tempPlayer.Location + Offset ) )
			{
				// The player could not be moved, probably destination is inside a wall
			}
		}

	if(TeleportInstigator)
	{
		EventInstigator.setLocation(EventInstigator.Location+Offset);
	}

	if(TeleportOther)
	{
		Other.setLocation(Other.Location+Offset);
	}

	for(i=0;i<ArrayCount(TeleportItemTags);i++)
	{
		if(TeleportItemTags[i]!='')
			foreach AllActors( class 'Actor', a, TeleportItemTags[i] )
			{
				a.SetLocation(a.Location+Offset);	
			}
	}

	for(i=0;i<ArrayCount(TeleportItemClasses);i++)
	{
		if(TeleportItemClasses[i]!=None)
			foreach AllActors( TeleportItemClasses[i], a )
			{
				a.SetLocation(a.Location+Offset);	
			}
	}

	if(!Retriggerable)
		Disable( 'Trigger' );
}

defaultproperties
{
	Retriggerable=False
	TeleportPlayer=True
    Texture=Texture'dnGame.S_Transporter'

}
