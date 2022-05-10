/*=============================================================================
	AIJetskiController
	Author: Jess Crable

	This handles Jetski/JetskiDude spawning.
=============================================================================*/
class AIJetskiController extends Info;

struct SJetskiInfo
{
	var() Name JetskiTag;
	var()  float JetskiSpeed;
};

struct SJetskiWave
{
	var()  int WaveNumber;
	var()  SJetskiInfo JetSkiGuys[ 5 ];
};

var() SJetskiWave JetskiWaves[ 16 ];

function Trigger( actor Other, pawn EventInstigator )
{
	local int i, x;
	local AIJetskiSpawnPoint JSP;
	local AIJetski Jetski;

	for( i = 0; i <= 15; i++ )
	{
		for( x = 0; x <= 4; x++ )
		{
			if( JetSkiWaves[ i ].JetSkiGuys[ x ].JetskiTag != '' )
			{
				foreach allactors( class'AIJetskiSpawnPoint', JSP, JetSkiWaves[ i ].JetSkiGuys[ x ].JetSkiTag )
				{
					Jetski = Spawn( class'AIJetski',, JetskiWaves[ i ].JetskiGuys[ x ].JetskiTag, JSP.Location );
					break;
				}
			}
		}
	}
}	

defaultproperties
{
}
