/*-----------------------------------------------------------------------------
	Money
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class Money extends Inventory
	abstract;

#exec OBJ LOAD FILE=..\Textures\hud_effects.dtx
#exec OBJ LOAD FILE=..\Sounds\a_generic.dfx

var int	CashAmount;

function bool HandlePickupQuery( inventory Item )
{
	// If there's nothing in our inventory after this one, do default behavior.
	if ( Inventory == None )
		return false;

	// Ask the next item to try.
	return Inventory.HandlePickupQuery( Item );
}

function DisplayPickupEvent( Inventory Inv, Actor ByOwner )
{
	Super.DisplayPickupEvent( Inv, ByOwner );

	if ( ByOwner.IsA('PlayerPawn') )
		PlayerPawn(ByOwner).AddCash( CashAmount );
}

defaultproperties
{
    RespawnTime=+00030.000000
	PickupSound=sound'a_generic.whoosh.WhooshGrab1'
	PickupIcon=texture'hud_effects.am_cash'
	LodMode=LOD_Disabled
}