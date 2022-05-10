class Turtle expands Fish;

#exec obj load file=..\meshes\c_zone1_vegas.dmx

auto state Startup
{

Begin:
	LoopAnim( 'Turtle_Swim' );
}

DefaultProperties
{
	Mesh=DukeMesh'c_zone1_vegas.Turtle'
}
