/*-----------------------------------------------------------------------------
	Z1_Keycard
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class Z1_Keycard extends Keycard;

#exec OBJ LOAD FILE=..\Textures\hud_effects.dtx
#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx

defaultproperties
{
     PickupEvent=Z1_KeycardEvent
     Icon=Texture'hud_effects.Inventory.mitem_lkcard'
     PickupIcon=Texture'hud_effects.ingame_hud.am_lkkeycard'
     PlayerViewOffset=(X=160.000000,Y=50.000000,Z=190.000000)
}
