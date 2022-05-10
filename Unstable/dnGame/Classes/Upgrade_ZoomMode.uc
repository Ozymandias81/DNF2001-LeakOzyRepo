/*-----------------------------------------------------------------------------
	Upgrade_ZoomMode
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class Upgrade_ZoomMode extends Inventory;

simulated function Activate()
{
	if (Owner.IsA('PlayerPawn'))
		PlayerPawn(Owner).ZoomDown();
}

defaultproperties
{
	bCanActivateWhileHandUp=true
    dnInventoryCategory=4
    dnCategoryPriority=0
    Icon=Texture'hud_effects.mitem_digizoom'
    bActivatable=true
    SpecialKey=1
    ItemName="Zoom Vision"
    RespawnTime=30
    PickupViewScale=4.0
    PickupViewMesh=mesh'c_dukeitems.sos_powercell'
    Mesh=mesh'c_dukeitems.sos_powercell'
}