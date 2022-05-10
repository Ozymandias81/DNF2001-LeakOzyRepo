/*-----------------------------------------------------------------------------
	DollarWad
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class DollarWad extends Money;

#exec OBJ LOAD FILE=..\Meshes\c_generic.dmx

defaultproperties
{
	PickupViewScale=2.0
	PickupViewMesh=mesh'c_generic.dollarwad'
	Mesh=mesh'c_generic.dollarwad'
	CashAmount=10
	CollisionRadius=4
	CollisionHeight=4
	ItemName="Cash Wad"
	PickupIcon=texture'hud_effects.am_cash_10'
}