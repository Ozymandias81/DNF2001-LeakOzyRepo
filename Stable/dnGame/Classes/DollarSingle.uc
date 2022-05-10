/*-----------------------------------------------------------------------------
	DollarSingle
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class DollarSingle extends Money;

#exec OBJ LOAD FILE=..\Meshes\c_generic.dmx

defaultproperties
{
	PickupViewScale=2.0
	PickupViewMesh=mesh'c_generic.dollarbill'
	Mesh=mesh'c_generic.dollarbill'
	CashAmount=1
	CollisionRadius=4
	CollisionHeight=4
	ItemName="Dollar Bill"
	PickupIcon=texture'hud_effects.am_cash_1'
}