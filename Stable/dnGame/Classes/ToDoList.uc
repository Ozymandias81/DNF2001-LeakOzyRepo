/*-----------------------------------------------------------------------------
	ToDoList
	This inventory item assumes single player only.
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class ToDoList extends Inventory;

function Activate()
{
	DukeHUD(PlayerPawn(Owner).MyHUD).ShowObjectives();
}

defaultproperties
{
	dnInventoryCategory=6
	dnCategoryPriority=0
	Icon=Texture'hud_effects.mitem_todo'
	bActivatable=true
	ItemName="Objectives List"
}