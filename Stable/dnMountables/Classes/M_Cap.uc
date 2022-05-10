/*-----------------------------------------------------------------------------
	M_Cap
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class M_Cap extends M_Hat;

#exec OBJ LOAD FILE=..\Meshes\c_characters.dmx

defaultproperties
{
     bCanBeShotOff=True
     CollisionRadius=6.000000
     CollisionHeight=6.000000
     Mesh=DukeMesh'c_characters.BB_HatA'
}
