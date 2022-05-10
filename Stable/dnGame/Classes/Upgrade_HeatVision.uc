/*-----------------------------------------------------------------------------
	Upgrade_HeatVision
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class Upgrade_HeatVision extends Inventory;

simulated function Activate()
{    
    if ( PlayerPawn(Owner) != None && PlayerPawn(Owner).Energy <= 0 )
        return;
    
	if (Owner.IsA('PlayerPawn'))
		PlayerPawn(Owner).HeatVision();
}

defaultproperties
{
	bCanActivateWhileHandUp=true
    dnInventoryCategory=4
    dnCategoryPriority=2
    Icon=Texture'hud_effects.mitem_thermvisi'
    bActivatable=true
    SpecialKey=2
    ItemName="Heat Vision"
    RespawnTime=30
    PickupViewScale=4.0
    PickupViewMesh=mesh'c_dukeitems.sos_powercell'
    Mesh=mesh'c_dukeitems.sos_powercell'
}