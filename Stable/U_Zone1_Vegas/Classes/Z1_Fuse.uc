/*-----------------------------------------------------------------------------
	Z1_Fuse
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class Z1_Fuse extends QuestItem
	abstract;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx

defaultproperties
{
     bActivatable=True
     PickupIcon=Texture'hud_effects.ingame_hud.am_fuse'
     PlayerViewOffset=(X=170.000000,Y=100.000000,Z=1580.000000)
     PlayerViewMesh=DukeMesh'c_zone1_vegas.fuse'
     PlayerViewScale=0.050000
     PickupViewMesh=DukeMesh'c_zone1_vegas.fuse'
     PickupSound=Sound'dnGame.Pickups.AmmoSnd'
     Mesh=DukeMesh'c_zone1_vegas.fuse'
     CollisionRadius=8.000000
     CollisionHeight=18.000000
     AnimSequence=glow_off
	 dnCategoryPriority=2
}
