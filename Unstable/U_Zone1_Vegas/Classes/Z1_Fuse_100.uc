/*-----------------------------------------------------------------------------
	Z1_Fuse_100
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class Z1_Fuse_100 extends Z1_Fuse;

#exec OBJ LOAD FILE=..\Textures\hud_effects.dtx

defaultproperties
{
     PickupEvent=Fuse100Event
     Icon=Texture'hud_effects.Inventory.mitem_fuse100'
     PickupViewScale=0.900000
     MultiSkins(3)=Texture'm_zone1_vegas.fuse_amps3'
     ItemName="Fuse (100 Amps)"
     DrawScale=0.900000
}
