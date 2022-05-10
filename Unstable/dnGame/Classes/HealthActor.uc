//=============================================================================
// HealthActor
// An actor that can be bound to the player so it takes damage and shows up on the
// hud
//=============================================================================
class HealthActor extends Triggers;

var() name   HUDActorTag;
var() string HUDActorDescription;

var HUDIndexItem_ActorHealth ActorHealthHUD;

function Trigger( actor Other, Pawn Instigator )
{
    local DukePlayer C;
    local RenderActor A;

    // When this actor is triggered, it will set itself up as the health actor that the 
    // player will display on the HUD.    

    foreach AllActors( class'RenderActor', A, HUDActorTag )
    {
        if ( ActorHealthHUD == None || ActorHealthHUD.bDeleteMe )  // Create a new HUD item if there isn't one already
            ActorHealthHUD = spawn( class'HUDIndexItem_ActorHealth' );

        ActorHealthHUD.AssignHealthActor( A );      // Link up the actor and description
        ActorHealthHUD.Text = HUDActorDescription;

        foreach AllActors( class'DukePlayer', C )
            DukeHUD(C.MyHUD).RegisterActorHealthItem( ActorHealthHUD );
    }
    Super.Trigger( Other, Instigator );
}

defaultproperties
{
    HUDActorDescription="Thing"
}
