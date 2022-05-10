class Snake expands Creature;

#exec obj load file=..\meshes\c_zone3_canyon.dmx

auto state Snake
{
Begin:
	SetPhysics( PHYS_Falling );
	WaitForLanding();
	LoopAnim( 'idle_rattle' );
}

DefaultProperties
{
	Mesh=DukeMesh'c_zone3_canyon.snake_rattler'
}