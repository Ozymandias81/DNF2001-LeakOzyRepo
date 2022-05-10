class Vulture expands Birds;

#exec obj load file=..\meshes\c_zone3_canyon.dmx

function PlayFlyAnim()
{
	if( AnimSequence != 'Fly' )
		LoopAnim( 'Fly' );
}


DefaultProperties
{
	Mesh=DukeMesh'c_zone3_canyon.Vulture'
}
