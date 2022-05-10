//=============================================================================
// PatrolControl.uc
//=============================================================================
class PatrolControl extends Info;

#exec OBJ LOAD FILE=..\Textures\DukeED_Gfx.dtx

//#exec Texture Import File=Textures\Pathnode.pcx Name=S_Patrol Mips=Off Flags=2

/*
var() name Nextpatrol; //next point to go to
var() float pausetime; //how long to pause here
var	 vector lookdir; //direction to look while stopped
var() name PatrolAnim;
var() sound PatrolSound;
var() byte numAnims;
var int	AnimCount;
var PatrolPoint NextPatrolPoint;
*/

// Add specific patrol point navigation point class to handle animation calls, or allow pathnodes to be
// patrolled and include ANOTHER optional actor per "special event" to define it.

const MaxPatrolEvents = 63;

//var( PatrolIndex ) NavigationPoint	PatrolPoints[ 64 ];
//var( PatrolIndex ) PatrolEvent		PatrolEvents[ 64 ];		

struct SNPCPatrolInfo
{
	var() Name				PatrolTag		?( "Tags of pathnodes, in order, to patrol." );
	var NavigationPoint		PatrolPoints;
	var() PatrolEvent		PatrolEvents	?( "Any patrol event directly associated with this patrol point will be executed when the pawn arrives." );
	var() NPCActivityEvent	ActivityEvents  ?( "Any activity event directly associated with this patrol point will be executed when the pawn arrives." );
	var() float				OffsetOverride;
};

var( PatrolIndex ) SNPCPatrolInfo PatrolInfo[ 64 ];

//var bool bSneaking;

enum EPatrolType
{
	PATROL_Oscillating,
	PATROL_Circular,
	PATROL_Linear,
	PATROL_Random
};

var( PatrolInfo ) EPatrolType	PatrolType;
//var( PatrolInfo ) Pawn			PatrolPawn;
var( PatrolInfo ) bool			bRunning			?( "If true, this pawn will use run animations/speeds." );
var( PatrolInfo ) bool			bAutoLookAt			?( "If true, pawn will auto look at other pawns and monsters." );
var( PatrolInfo ) float			NewSightRadius		?( "Adjusts the distance at which this pawn will receive sight notifications. Sight radius returns to default when done patrolling." );
var( PatrolInfo ) float			NewPeripheralVision	?( "Adjusts the pawn's peripheral vision only for Patrolling state." );
var bool bPawnReturning;
var( PatrolInfo ) int			 TempMaxStepHeight;

function PostBeginPlay()
{
	CachePatrolPoints();
}

function Actor MatchTagWithActor( name MatchTag )
{ 
	local actor A;

	foreach allactors( class'Actor', A, MatchTag )
	{
		if( A.IsA( 'NavigationPoint' ) )
			return A;
	}
}

function CachePatrolPoints()
{
	local int i;

	for( i = 0; i <= 63; i++ )
	{
		if( PatrolInfo[ i ].PatrolTag != '' )
		{
			PatrolInfo[ i ].PatrolPoints = NavigationPoint( MatchTagWithActor( PatrolInfo[ i ].PatrolTag ) );
		}
	}
}

function NavigationPoint GetPatrolPoint( int Index )
{
	return PatrolInfo[ Index ].PatrolPoints;
}


function PatrolEvent GetPatrolEvent( optional NavigationPoint CurrentPatrolPoint )
{
	local int CurrentIndex;

	CurrentIndex = GetPatrolIndex( CurrentPatrolPoint );

	if( PatrolInfo[ CurrentIndex ].PatrolEvents != None )
	{
		return PatrolInfo[ CurrentIndex ].PatrolEvents;
	}

	return None;
}

function NPCActivityEvent GetActivityEvent( optional navigationPoint CurrentPatrolPoint )
{
	local int CurrentIndex;

	CurrentIndex = GetPatrolIndex( CurrentPatrolPoint );

	if( PatrolInfo[ CurrentIndex ].ActivityEvents != None )
		return PatrolInfo[ CurrentIndex ].ActivityEvents;

	return none;
}

// Called when an event is toggleable only once.
function RemovePatrolEvent( PatrolEvent RemoveEvent )
{
	local int CurrentIndex;

	for( CurrentIndex = 0; CurrentIndex <= 63; CurrentIndex++ )
	{
		if( PatrolInfo[ CurrentIndex ].PatrolEvents == RemoveEvent )
		{
			PatrolInfo[ CurrentIndex ].PatrolEvents = None;
		}
	}
}


function NavigationPoint GetNextPatrolPoint( optional NavigationPoint CurrentPatrolPoint )
{
	local int CurrentIndex;
	local NavigationPoint NextPatrolPoint;

	// log( "CurrentPatrolPoint is "$CurrentPatrolPoint );

	if( CurrentPatrolPoint != None )
		CurrentIndex = GetPatrolIndex( CurrentPatrolPoint );
	else 
		CurrentIndex = 0;
	// log( "CurrentPatrolPoint 2 is "$CurrentPatrolPoint );

	if( PatrolType == PATROL_Oscillating )
	{
		//// log( "# CurrentIndex: "$CurrentIndex );
		if( CurrentIndex == 63 )
		{
			bPawnReturning = true;
		}
		else if( CurrentIndex == 0 )
		{
			bPawnReturning = false;
		}
		if( bPawnReturning )
		{
			if( ( PatrolInfo[ CurrentIndex - 1 ].PatrolPoints ) == None )
			{
				bPawnReturning = false;
			}
		}
		else
		{	
			if( ( PatrolInfo[ CurrentIndex + 1 ].PatrolPoints ) == None )
			{
				bPawnReturning = true;
			}	
		}
		if( !bPawnReturning )
		{
			//// log( "# Pawn not returning" );
			if( ( PatrolInfo[ CurrentIndex + 1 ].PatrolPoints ) != None )
			{
				NextPatrolpoint = PatrolInfo[ CurrentIndex + 1 ].PatrolPoints;
			}	
		}

		if( bPawnReturning )
		{
			//// log( "# Pawn is returning" );
			if( ( PatrolInfo[ CurrentIndex - 1 ].PatrolPoints ) != None )
			{
				NextPatrolPoint = PatrolInfo[ CurrentIndex - 1 ].PatrolPoints;
			}
		}

		//// log( "# Returning NextPatrolpoint: "$nextPatrolPoint );
	}

	else if( PatrolType == PATROL_Circular )
	{
		NextPatrolPoint = PatrolInfo[ CurrentIndex + 1 ].PatrolPoints;

		if( NextPatrolPoint == None )
		{
			NextPatrolPoint = PatrolInfo[ 0 ].PatrolPoints;
		}
	}
	else if( PatrolType == PATROL_Linear )
	{
		if( CurrentIndex > 0 || CurrentPatrolPoint != None )
				NextPatrolPoint = PatrolInfo[ CurrentIndex + 1 ].PatrolPoints;
		else
			NextPatrolPoint = PatrolInfo[ CurrentIndex ].PatrolPoints;
		// log( "CURRENT INDEX IS "$CurrentIndex );
		// log( "Next linear PatrolPoint is "$NextPatrolPoint );
	}
	else if( PatrolType == PATROL_Random )
	{
		NextPatrolPoint = GetRandomPatrolpoint( CurrentIndex );
	}

	return NextPatrolPoint;
}

function NavigationPoint GetLastPatrolPoint()
{
	local int i;

	for( i = 0; i <= 63; i++ )
	{
		if( PatrolInfo[ i ].PatrolPoints == None )
			return PatrolInfo[ i - 1 ].PatrolPoints;
	}
}

function NavigationPoint GetRandomPatrolPoint( int CurrentIndex )
{
	local int i;
	local NavigationPoint RandomPatrolPoint;

	for( i = 0; i <= 63; i++ )
	{
		if( ( PatrolInfo[ i ].PatrolPoints == None ) && ( PatrolInfo[ i ].PatrolPoints != PatrolInfo[ CurrentIndex ].PatrolPoints ) )
		{
			break;
		}
	}

	RandomPatrolPoint = PatrolInfo[ Rand( i ) ].PatrolPoints;

	return RandomPatrolPoint;
}

function int GetPatrolPointCount()
{
	local int i;
	local int Count;

	for( i = 0; i <= 63; i++ )
	{
		if( PatrolInfo[ i ].PatrolPoints != None )
		{
			Count++;
		}
		else
			break;
	}
	return Count;
}

function int GetPatrolIndex( NavigationPoint PatrolPoint )
{
	local int i;

	for( i = 0; i <= 63; i++ )
	{
		if( PatrolInfo[ i ].PatrolPoints == PatrolPoint )
		{
			// log( "** GetPatrolIndex returning "$i );
			return i;
		}
	}
}


// Pawn with broken patrol calls Timer; Timer sends pawn back on patrol from wandering.
function Timer( optional int TimerNum )
{
//	PatrolPawn.GotoState( 'Patrolling' );
//	SetTimer( 0.0, false );
}


defaultproperties
{
     bDirectional=True
     SoundVolume=128
	 Texture=Texture'DukeED_Gfx.PatrolControl'
}
