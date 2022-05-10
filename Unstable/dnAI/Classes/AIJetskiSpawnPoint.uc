/*=============================================================================
	AIJetskiSpawnPoint
	Author: Jess Crable

	Special actor representing spawn locations for AIJetskis.
=============================================================================*/
class AIJetskiSpawnpoint extends Info;

var() vector InitialVelocity;

function PostBeginPlay()
{
	log( "-- AIJetskiPoint "$self$" spawned with InitialVelocity of "$InitialVelocity );
	Super.PostBeginPlay();
}

defaultproperties
{
	bDirectional=true
}
