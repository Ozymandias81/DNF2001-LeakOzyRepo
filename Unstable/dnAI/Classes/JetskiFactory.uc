/*-----------------------------------------------------------------------------
	JetskiFactory
-----------------------------------------------------------------------------*/
class JetskiFactory extends Info;

enum EJetskiPointCycle
{
	CYCLE_Random,
	CYCLE_Linear,
	CYCLE_Oscillating
};

struct SJetskiPathInfo
{
	var JetskiPoint JetskiPath[ 16 ];
	var bool bOccupied;
	var() name JetskiPathTag			?( "At startup the factory will add jetski points with matching tags to this path's array." );
	var() name SequentialPathTags[ 16 ] ?( "If you're using sequential paths use this array." );
	var() bool bSequentialPath			?( "Set this to true if this path is a sequential path." );
};

var() SJetskiPathInfo JetskiPathInfo[ 16 ];

var() EJetskiPointCycle JS_PointCycle			?( "Random, linear, or oscillating between jetski points." );
var() float				JS_WaterSpeed			?( "Waterspeed of spawned jetski guy." );
var() rotator			JS_RotationRate			?( "Rotation rate of spawned jetski guy." );
var() float				JS_AccelRate			?( "AccelRate of spawned jetski guy." );
var() float				JS_Buoyancy				?( "Buoyancy of spawned jetski guy." );
var() name				JS_Event				?( "New event for jetski guy." );
var() name				JS_EnemyTag				?( "Tag of jetski guy's enemy." );
var() vector			JS_CarcassVelocity		?( "Extra velocity to give to the carcass." );
var() int				JS_EngineVolume			?( "Volume of the Jetski engine sound." );
var() int				JS_EngineVolRadius		?( "Sound radius of the Jetski engine." );
var() float				JS_DestroyTime			?( "How long before carcasses are destroyed." );

function PostBeginPlay()
{
	Initialize();
}

function AddSequentialPath( AIJetski JetskiGuy )
{
	local int i, x;
	local JetskiPoint JSP;

	for( i = 0; i <= 15; i++ )
	{
		if( JetskiPathInfo[ i ].SequentialPathTags[ x ] != '' )
		{
			foreach allactors( class'JetskiPoint', JSP, JetskiPathInfo[ i ].SequentialPathTags[ x ] )
			{
				JetskiGuy.MyJetskiPoints[ x ] = JSP;
				x++;
			}
		}
		x = 0;
	}
}

function Initialize()
{
	local int i, x;
	local JetskiPoint JSP;

	for( i = 0; i <= 15; i++ )
	{
		if( JetskiPathInfo[ i ].JetskiPathTag != '' )
		{
			foreach allactors( class'JetskiPoint', JSP, JetskiPathInfo[ i ].JetskiPathTag )
			{
				JetskiPathInfo[ i ].JetskiPath[ x ] = JSP;
				x++;
			}
		}
		x = 0;
	}
}

function bool JetskiPathFree( int PathInfoNumber )
{
	return !JetskiPathInfo[ PathInfoNumber ].bOccupied;
}

function SetPathUnoccupied( name PathTag )
{
	local int i;

	for( i = 0; i <= 15; i++ )
	{
		if( JetskiPathInfo[ i ].JetskiPathTag == PathTag )
		{
			JetskiPathInfo[ i ].bOccupied = false;
		}
	}
}


function SetPathOccupied( name PathTag )
{
	local int i;

	for( i = 0; i <= 15; i++ )
	{
		if( JetskiPathInfo[ i ].JetskiPathTag == PathTag )
		{
			JetskiPathInfo[ i ].bOccupied = true;
		}
	}
}

function vector GetSpawnLocation()
{
	local AIJetskiSpawnPoint A;
	
	foreach allactors( class'AIJetskiSpawnPoint', A, Event )
	{
		return A.Location;
	}
}

function AddSpawnVelocity( AIJetski JetskiGuy )
{
	local AIJetskiSpawnPoint A;
	
	foreach allactors( class'AIJetskiSpawnPoint', A, Event )
	{
		///log( "Adding velocity "$A.InitialVelocity$" to "$JetskiGuy );
		if( JetskiGuy.Physics == PHYS_Falling ) 
		{
			//log( "His physics WAS falling." );
		}
		JetskiGuy.AddVelocity( A.InitialVelocity );
		break;
	}
}

function rotator GetSpawnRotation()
{
	local AIJetskiSpawnPoint A;

	foreach allactors( class'AIJetskiSpawnPoint', A, Event )
	{
		return A.Rotation;
	}
}

function int GetJetskiPathInfo( name MatchTag )
{
	local int i;

	//log( "* GetJetskiPathInfo matching tag "$MatchTag );

	for( i = 0; i <= 15; i++ )
	{
		//log( "* Against tag "$JetskiPathInfo[ i ].JetskiPathTag );
		if( JetskiPathInfo[ i ].JetskiPathTag == MatchTag )
		{
//			log( "Returning "$i );
			return i;
		}
	}
}

function SetJetskiEnemy( AIJetski JetskiGuy )
{
	local actor A;

	foreach allactors( class'Actor', A, JS_EnemyTag )
	{
		JetskiGuy.Enemy = A;
		return;
	}
}

function Name FindBestJetskiPathTag()
{
	local int i;

	for( i = 0; i <= 15; i++ )
	{
		if( JetskiPathFree( i ) )
		{
			return JetskiPathInfo[ i ].JetskiPathTag;
		}
	}
	
	return 'None';
}

function Trigger( actor Other, pawn EventInstigator )
{
	local AIJetski JetskiGuy;
	local int i;
	local name BestTag;

	log( self$" Triggered by "$Other );

	BestTag = FindBestJetskiPathTag();
	if( BestTag != '' )
	{
		JetskiGuy = Spawn( class'AIJetski', self, BestTag, GetSpawnLocation(), GetSpawnRotation() );
		//log( "JetskiGuy "$JetskiGuy$" spawned with tag "$JetskiGuy.Tag );

		if( JS_WaterSpeed != 0 ) 
			JetskiGuy.WaterSpeed	= JS_WaterSpeed;

		if( JS_AccelRate != 0 )
			JetskiGuy.AccelRate		= JS_AccelRate;

		if( JS_Buoyancy != 0 )
			JetskiGuy.Buoyancy		= JS_Buoyancy;

		if( JS_DestroyTime > 0 )
			JetskiGuy.DestroyTime	= JS_DestroyTime;

		if( JS_EngineVolume > 0 )
			JetskiGuy.SoundVolume	= JS_EngineVolume;

		if( JS_EngineVolRadius > 0 )
			JetskiGuy.SoundRadius	= JS_EngineVolRadius;

		if( JS_RotationRate != rot( 0, 0, 0 ) )
			JetskiGuy.RotationRate	= JS_RotationRate;

		JetskiGuy.Event = JS_Event;
		JetskiGuy.SetJetskiPointCycle( GetJetskiPointCycle() );
		//log( "--- JetskiFactory "$self$" calling AddSpawnVelocity" );

		AddSpawnVelocity( JetskiGuy );		
		SetJetskiEnemy( JetskiGuy );
		JetskiGuy.CarcassVelocity = JS_CarcassVelocity;

		if( !JetskiPathInfo[ GetJetskiPathInfo( JetskiGuy.Tag ) ].bSequentialPath )
		{
			for( i = 0; i <= 15; i++ )
			{
				//log( "* Adding path "$JetskiPathInfo[ GetJetskiPathInfo( JetskiGuy.Tag ) ].JetskiPath[ i ] );
				JetskiGuy.MyJetskiPoints[ i ] = JetskiPathInfo[ GetJetskiPathInfo( JetskiGuy.Tag ) ].JetskiPath[ i ];
				SetPathOccupied( JetskiGuy.Tag );
				//log( "-- Added "$JetskiGuy.MyJetskiPoints[ i ]$" to "$JetskiGuy );
			}
		}
		else
		{
			AddSequentialPath( JetskiGuy );
		}
	}
	else
	{
//		log( "Ran out of free paths." );
	}
}

function int GetJetskiPointCycle()
{
	switch ( JS_PointCycle )
	{
		Case CYCLE_Random:
			return 0;
			break;
		Case CYCLE_Linear:
			return 1;
			break;
		Case CYCLE_Oscillating:
			return 2;
			break;
		Default:
			return 0;
			break;
	}
}

defaultproperties
{
}
