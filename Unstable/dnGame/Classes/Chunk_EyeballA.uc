/*-----------------------------------------------------------------------------
	Chunk_EyeballA
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class Chunk_EyeballA extends PlayerChunks;

#exec OBJ LOAD FILE=..\meshes\c_FX.dmx

defaultproperties
{
	Mesh=DukeMesh'c_FX.Gib_Eyeball'
	CollisionRadius=10
	CollisionHeight=10
}