//=============================================================================
// TriggerDestroy. (NJS)
//
// When triggered, *DESTROYS* the object(s) indicated by 'Event'.
//=============================================================================
class TriggerDestroy expands Triggers;

#exec Texture Import File=Textures\TriggerDestroy.pcx Name=S_TriggerDestroy Mips=Off Flags=2

var () bool SelfDestruct;	// Destroy self after destroying event actors.
var () name AdditionalEvents[16];

// Destroys all objects with tag equal to Event:
function Trigger( actor Other, pawn EventInstigator )
{
	local Actor A;
	local int i;
		
	// Validate Event.
	if( Event != '' ) 
		// Destroy all actors with matching triggers 
		foreach AllActors( class 'Actor', A, Event )	
		{		
			if( !A.IsA( 'NavigationPoint' ) )
				A.Destroy();
		}

	for(i=0;i<ArrayCount(AdditionalEvents);i++)
	{
		if(AdditionalEvents[i]!='')
			foreach AllActors(class 'Actor',A,AdditionalEvents[i])
			{
				if( !A.IsA( 'Navigationpoint' ) )	
					A.Destroy();
			}
	}

	if(SelfDestruct)
		Destroy();
}

defaultproperties
{
     Texture=Texture'Engine.S_TriggerDestroy'
}
