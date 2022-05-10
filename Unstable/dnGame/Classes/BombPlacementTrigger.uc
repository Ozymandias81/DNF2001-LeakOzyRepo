/*-----------------------------------------------------------------------------
	BombPlacementTrigger
	Author: Scott Alden

	Used for teamplay to tell where a bomb can be placed.    
-----------------------------------------------------------------------------*/
class BombPlacementTrigger extends Triggers;

function Touch( actor Other )
{
	if ( PlayerPawn( Other ) != None )
		PlayerPawn( Other ).bCanPlantBomb = true;
}

function UnTouch( actor Other )
{
	if ( PlayerPawn( Other ) != None )
		PlayerPawn( Other ).bCanPlantBomb = false;
}

defaultproperties
{
}