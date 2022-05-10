/*-----------------------------------------------------------------------------
	Keycard
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class Keycard extends QuestItem;

#exec OBJ LOAD FILE=..\Textures\hud_effects.dtx
#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx

defaultproperties
{
    PickupSound=Sound'dnGame.Pickups.AmmoSnd'
	PickupIcon=texture'hud_effects.am_genkeycard'
	PlayerViewScale=0.1
	PlayerViewOffset=(X=100.0,Y=30.0,Z=240.0)
    PickupViewMesh=mesh'c_zone1_vegas.keycard'
    PlayerViewMesh=mesh'c_zone1_vegas.keycard'
	Mesh=mesh'c_zone1_vegas.keycard'
    CollisionRadius=3.0
    CollisionHeight=3.0
	bActivatable=true
	dnCategoryPriority=1
	ItemName="Keycard"
    Icon=Texture'hud_effects.mitem_gencard'
}