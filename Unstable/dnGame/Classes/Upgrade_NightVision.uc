/*-----------------------------------------------------------------------------
	Upgrade_NightVision
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class Upgrade_NightVision extends Inventory;

simulated function Activate()
{
    if ( PlayerPawn(Owner) != None && PlayerPawn(Owner).Energy <= 0 )
        return;

	if (Owner.IsA('PlayerPawn'))
		PlayerPawn(Owner).NightVision();
}

defaultproperties
{
	bCanActivateWhileHandUp=true
    dnInventoryCategory=4
    dnCategoryPriority=1
    Icon=Texture'hud_effects.mitem_nightvisi'
    bActivatable=true
    SpecialKey=3
    ItemName="Night Vision"
    RespawnTime=30
    PickupViewScale=4.0
    PickupViewMesh=mesh'c_dukeitems.sos_powercell'
    Mesh=mesh'c_dukeitems.sos_powercell'
}