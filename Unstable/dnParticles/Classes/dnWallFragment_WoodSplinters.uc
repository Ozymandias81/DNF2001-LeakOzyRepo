/*-----------------------------------------------------------------------------
	dnWallFragment_WoodSplinters
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class dnWallFragment_WoodSplinters extends RenderActor;

#exec OBJ LOAD FILE=..\Meshes\c_fx.dmx

defaultproperties
{
	mesh=mesh'c_fx.WoodSplinters'
	DrawType=DT_Mesh
	DrawScale=0.75
	CollisionHeight=0
	CollisionRadius=0
	bCollideWorld=false
	bCollideActors=false
	bBlockActors=false
	bBlockPlayers=false
}
