/*-----------------------------------------------------------------------------
	Snack_MRE_Veggie
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class Snack_MRE_Veggie extends VendSnack;

#exec OBJ LOAD FILE=..\Meshes\c_dukeitems.dmx
#exec OBJ LOAD FILE=..\Textures\hud_effects.dtx

defaultproperties
{
     HealingAmount=15
     PickupIcon=Texture'hud_effects.ingame_hud.am_mreveg'
     PickupViewMesh=DukeMesh'c_dukeitems.MRE_vegetarian'
     Mesh=DukeMesh'c_dukeitems.MRE_vegetarian'
     ItemName="Vegetarian MRE"
     CollisionRadius=10.000000
     CollisionHeight=8.000000
}
