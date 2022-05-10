class Coyote extends Creature;

#exec obj load file=..\meshes\c_zone3_canyon.dmx

function PlayToWaiting( optional float TweenTime )
{
	LoopAnim( 'SitIdle',1.5, 0.2 );
}

state Idling
{
begin:
	PlayToWaiting();
	Sleep( 2 + Rand( 3 ) );
	if( FRand() < 0.42 )
	{
		PlayAnim( 'Lick_Balls',, 0.2 );
		FinishAnim();
	}
	Goto( 'Begin' );
}

DefaultProperties
{
	Mesh=DukeMesh'c_zone3_canyon.Coyote'
}
