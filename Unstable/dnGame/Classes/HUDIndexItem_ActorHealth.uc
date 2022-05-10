/*-----------------------------------------------------------------------------
	HUDIndexItem_ActorHealth
	Author: Scott Alden
-----------------------------------------------------------------------------*/
class HUDIndexItem_ActorHealth extends HUDIndexItem;

var RenderActor HealthActor;

// Draws the health from a specific actor on the level.  Used for special levels
// where there is need to see the health of some actor at all times.  

function PostBeginPlay()
{
    Super.PostBeginPlay();
}

function AssignHealthActor( RenderActor A )
{
	HealthActor = A;
}

function DrawItem( canvas C, DukeHUD HUD, float YPos )
{
    if ( healthActor.bDeleteMe )
    {
        Destroy();
        return;
    }

	if ( healthActor != None )
    {
    	Value    = healthActor.Health;
	    MaxValue = healthActor.default.Health;

    	Super.DrawItem( C, HUD, YPos );
    }
}

defaultproperties
{
    Text="ACTOR"
	StopLightingBar=true
	FlashingBar=true
}
