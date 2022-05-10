/*-----------------------------------------------------------------------------
	Z1_Fuse_50
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class Z1_Fuse_50 extends Z1_Fuse;

#exec OBJ LOAD FILE=..\Textures\hud_effects.dtx

defaultproperties
{
     PickupEvent=Fuse50Event
     Icon=Texture'hud_effects.Inventory.mitem_fuse50'
     PickupViewScale=0.800000
     MultiSkins(3)=Texture'm_zone1_vegas.fuse_amps2'
     ItemName="Fuse (50 Amps)"
     DrawScale=0.800000
}
