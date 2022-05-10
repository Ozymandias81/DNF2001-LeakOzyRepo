/*-----------------------------------------------------------------------------
	Z1_Fuse_200
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class Z1_Fuse_200 extends Z1_Fuse;

#exec OBJ LOAD FILE=..\Textures\hud_effects.dtx

defaultproperties
{
     PickupEvent=Fuse200Event
     Icon=Texture'hud_effects.Inventory.mitem_fuse200'
     ItemName="Fuse (200 Amps)"
}
